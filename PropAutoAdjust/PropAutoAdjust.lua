--[[
PropAutoAdjust for X-Plane 11+ and XLua
Based on an idea by Gary Hensley

Licensed under the EUPL v1.2: https://eupl.eu/1.2/en/

BK, 10/2020
]]
--[[
Proportional control/gain: Error amount determines amount of corrective output
Integral control/gain: Tries to eliminate error and residual steady state error as quickly as possible
Derivative control/gain: Tries to minimize error rate, used for dampening overshoots
]]
ffi = require ("ffi") -- LuaJIT FFI module
dofile("SDK_303_XPLM/FFI.XPLM.Init.lua") --[[ XPLM initialization script ]]
dofile("SDK_303_XPLM/FFI.XPLMDefs.lua")
dofile("SDK_303_XPLM/FFI.XPLMUtilities.lua")
dofile("SDK_303_XPLM/FFI.XPLMMenus.lua")    --[[ REQUIRES FFI.XPLMDefs.lua and FFI.XPLMUtilities.lua ]]
dofile("SDK_303_XPLM/FFI.XPLMDisplay.lua")  --[[ REQUIRES FFI.XPLMDefs.lua ]]
dofile("SDK_303_XPLM/FFI.XPLMGraphics.lua") --[[ REQUIRES FFI.XPLMDefs.lua ]]
dofile("SDK_303_XPWidgets/FFI.XPWidgets.Init.lua")          --[[ XPWidgets initialization script ]]
dofile("SDK_303_XPWidgets/FFI.XPWidgetDefs.lua")            --[[ REQUIRES FFI.XPLMDefs.lua ]]
dofile("SDK_303_XPWidgets/FFI.XPStandardWidgets.lua")       --[[ REQUIRES FFI.XPWidgetDefs.lua ]]
dofile("SDK_303_XPWidgets/FFI.XPUIGraphics.lua")            --[[ REQUIRES FFI.XPWidgetDefs.lua ]]
dofile("SDK_303_XPWidgets/FFI.XPWidgets.lua")               --[[ REQUIRES FFI.XPWidgetDefs.lua, XPLMDisplay.lua ]]
dofile("SDK_303_XPWidgets/FFI.XPWidgetUtils.lua")           --[[ REQUIRES FFI.XPWidgetDefs.lua ]]
dofile("PropAutoAdjust.Menu.lua")
dofile("PropAutoAdjust.Widget.lua")
--[[ End-user configuration ]]
RPM_max = 2300            -- Maximum RPM
RPM_min = 850             -- Minimum RPM
PID_time_step = 0.25      -- Time step for I and D control calculation (seconds)
P_gain = 0.0010           -- Proportional gain
I_gain = 0.0075           -- Integral gain
D_gain = 0.005            -- Derivative gain
Prop_limits = {0.0,1.0}   -- Prop lever limits (low,high)
Debug_Output = false      -- Prints debug output to console
Script_Name = "PropAutoAdjust"
--[[ 

DATAREFS 

]]
num_engines =       find_dataref("sim/aircraft/engine/acf_num_engines")                 -- Number of engines
throttle_ratio =    find_dataref("sim/cockpit2/engine/actuators/throttle_ratio")        -- Throttle lever position array dataref
flap_handle =       find_dataref("sim/cockpit2/controls/flap_ratio")                    -- Flap handle dataref
gear_handle =       find_dataref("sim/cockpit2/controls/gear_handle_down")              -- Gear handle dataref
sim_paused =        find_dataref("sim/time/paused")                                     -- Simulator pause dataref
eng_running =       find_dataref("sim/flightmodel2/engines/engine_is_burning_fuel")     -- Engine combustion status dataref
prop_RPM =          find_dataref("sim/cockpit2/engine/indicators/prop_speed_rpm")       -- Prop RPM dataref
prop_ratio =        find_dataref("sim/cockpit2/engine/actuators/prop_ratio")            -- Prop lever dataref
--[[ 

HELPER ITEMS

]]
throttle_ratio_prev = {}  -- Previous throttle position
RPM_target = {}           -- Target prop RPM
RPM_error = {}            -- Current prop RPM error
RPM_time_prev = {}        -- For time step usage
RPM_error_prev = {}       -- Previous prop RPM error
P_output = {}           -- Proportional output
I_output = {}           -- Integral output
D_output = {}           -- Derivative output
PID_output = {}         -- Combined PID output
--XPLM = nil            -- Define namespace for XPLM library
--[[ 

FUNCTIONS

]]
--[[ Initialization ]]
function PropAutoAdjustInit()
    num_engines_corr = num_engines - 1                           -- Corrects number of engines dataref starting at one for use with dataref tables which start at zero
    for i = 0,num_engines_corr do
        RPM_target[i] = ((RPM_max - RPM_min) * throttle_ratio[i]) + RPM_min -- Assign initial RPM targets
        throttle_ratio_prev[i] = 0      -- Mandatory init table for previous throttle ratio per number of installed engines
        RPM_time_prev[i] = os.clock()   -- Init timer table
    end
    Log_time_prev = os.clock()
    print("PropAutoAdjust initialized!")
end
--[[ Get previous RPM error ]]
function Prev_RPM_Error(engindex)
    RPM_error_prev[engindex] = RPM_target[engindex] - prop_RPM[engindex]       -- Previous error
end
--[[ Runtime ]]
function PropAutoAdjust()
    for i=0,num_engines_corr do
        --[[ Determine target RPM ]]
        if throttle_ratio[i] ~= throttle_ratio_prev[i] and flap_handle == 0 --[[and gear_handle == 0]] then     -- Detect throttle position changes and only run when flaps (and gear) are up
                RPM_target[i] = ((RPM_max - RPM_min) * throttle_ratio[i]) + RPM_min                             -- Calculate target RPM as a linear function between max and min RPM
                --XLuaDebugString(string.format("Eng %d | RPM target: % 4d (Thr: %.4f)",i,RPM_target[i],throttle_ratio[i]))   -- Debug output to developer console when using XLua fork
                if Debug_Output then print(string.format("Eng %d | RPM target: % 4d (Thr: %.4f)",i,RPM_target[i],throttle_ratio[i])) end  -- Debug output to terminal/command window
                throttle_ratio_prev[i] = throttle_ratio[i]
        end
        if (flap_handle > 0 --[[or gear_handle == 1]]) and RPM_target[i] ~= RPM_max then 
            RPM_target[i] = RPM_max -- Maximum RPM when flaps (and maybe gear) are not up, i.e. takeoff or landing
            if Debug_Output then print(string.format("Eng %d | RPM target: Max (%d)",i,RPM_max)) end -- Debug output to terminal/command window
        end    
        --[[ Calculate prop lever response ]]
        if sim_paused == 0 and eng_running[i] == 1 then         -- Only run when sim is not paused and engine is combusting
            RPM_error[i] = RPM_target[i] - prop_RPM[i]          -- Current RPM error
            if os.clock() > (RPM_time_prev[i] + PID_time_step) then    -- Manual timer because run_at_interval is junk
                RPM_error_prev[i] = RPM_target[i] - prop_RPM[i]       -- Previous error
                RPM_time_prev[i] = os.clock() 
            end
            P_output[i] = RPM_error[i] * P_gain                                           -- Proportional control
            I_output[i] = (RPM_error[i] - RPM_error_prev[i]) * PID_time_step * I_gain     -- Integral control
            D_output[i] = ((RPM_error[i] - RPM_error_prev[i]) / PID_time_step) * D_gain   -- Derivative control
            PID_output[i] = P_output[i] + D_output[i] + I_output[i]                       -- PID output
            prop_ratio[i] = prop_ratio[i] - PID_output[i]                                 -- Write to prop lever dataref. Subtract PID output because lever 0 = max RPM, lever 1 = min RPM
            if prop_ratio[i] < Prop_limits[1] then prop_ratio[i] = Prop_limits[1] end     -- Avoid busting lower prop lever limit
            if prop_ratio[i] > Prop_limits[2] then prop_ratio[i] = Prop_limits[2] end     -- Avoid busting upper prop lever limit
        end
    end
    if Debug_Output and os.clock() > (Log_time_prev + 1) then                            -- Manual timer because run_at_interval is junk
        for i=0,num_engines_corr do
            print(string.format("Eng %d | Errors: % 09.3f / % 09.3f | P: % .5f I: % .5f D: % .5f --> PID: % .6f | PL: % .3f",i,RPM_error[i],RPM_error_prev[i],P_output[i],I_output[i],D_output[i],PID_output[i],prop_ratio[i])) -- Debug output to terminal/command window
        end
        Log_time_prev = os.clock()
    end
end
--[[ 

X-PLANE WRAPPERS

]]
-- 1: Aircraft loading
--[[function aircraft_load()
end]]
function aircraft_unload()
    print("UNLOADING")
end
-- 2: Flight start
function flight_start()
    Init_FFI_XPLM()         -- XPLM initialization function
    Init_FFI_XPWidgets()    -- XPWidgets initialization function
    PropAutoAdjustInit()
    Menu_Init()
    Widget_Init()
end
-- 3: Flight crash
--[[function flight_crash() 
end]]
-- 4: Before physics
--[[function before_physics() 
end]]
-- 5: After physics
function after_physics()
    PropAutoAdjust()
end
--[[

SUBMODULES

]]
