--[[ Menu items ]]
Menu_Items = {"Hello","[Separator]","Item 2"}
--[[ Temp ]]
MenuIndex = {}
for i=1,#Menu_Items do
   MenuIndex[i] = 0 
end





--[[ Menu item callbacks ]]
function Menu_Callback(itemref,intable)
    if itemref == intable[1] then Menu_Watchdog(0) --[[XPLM.XPLMCheckMenuItem(Menu_ID,MenuIndex[1],xplm_Menu_Checked)]] end
    if itemref == intable[2] then print("Empty Item") end
    if itemref == intable[3] then Menu_Watchdog(2) end
end
--[[ Menu initialization ]]
function Menu_Init()
    --[[ Variables for FFI pointers ]]
    Menu_Pointer = ffi.new("const char")
    if XPLM ~= nil then
        Menu_ID = XPLM.XPLMCreateMenu(Script_Name,nil,0, function(inMenuRef,inItemRef) Menu_Callback(inItemRef,Menu_Items) end,ffi.cast("void *",Menu_Pointer))
        for i=1,#Menu_Items do
            if Menu_Items[i] ~= "[Separator]" then
                --Menu_Pointer = tostring(i)
                Menu_Pointer = Menu_Items[i]
                --print(ffi.string(Menu_Pointer))
                MenuIndex[i] = XPLM.XPLMAppendMenuItem(Menu_ID,Menu_Items[i],ffi.cast("void *",Menu_Pointer),1)
                Menu_Watchdog(MenuIndex[i])
                --print("TEST "..MenuIndex[i])
            else
                XPLM.XPLMAppendMenuSeparator(Menu_ID)
            end
        end
        print("PropAutoAdjust menu initialized!")
    end
end

function Menu_Watchdog(index)
    local out = ffi.new("XPLMMenuCheck[1]")
    --local enabledname = "Disable "..Menu_Items[index+1]
    --local disabledname = "Enable "..Menu_Items[index+1]
    --print(enabledname)
    --print(disabledname)
    XPLM.XPLMCheckMenuItemState(Menu_ID,index,ffi.cast("XPLMMenuCheck *",out))
    if tonumber(out[0]) == 0 then 
        XPLM.XPLMCheckMenuItem(Menu_ID,index,1)
        XPLM.XPLMSetMenuItemName(Menu_ID,index,"Enable "..Menu_Items[index+1],1)
    elseif tonumber(out[0]) == 1 then 
        XPLM.XPLMCheckMenuItem(Menu_ID,index,2)
        XPLM.XPLMSetMenuItemName(Menu_ID,index,"Disable "..Menu_Items[index+1],1)
    elseif tonumber(out[0]) == 2 then 
        XPLM.XPLMCheckMenuItem(Menu_ID,index,1) 
        XPLM.XPLMSetMenuItemName(Menu_ID,index,"Enable "..Menu_Items[index+1],1)
    end
end

--[[ Menu cleanup upon script reload or session exit ]]
function Menu_CleanUp()
   --XPLM.XPLMClearAllMenuItems(XPLM.XPLMFindPluginsMenu())
   XPLM.XPLMDestroyMenu(Menu_ID)
end


