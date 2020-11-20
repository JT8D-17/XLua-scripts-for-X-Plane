function Init_FFI_XPLM()
    print(string.format("FFI XPLM: Operating system is: %s",ffi.os))
    --[[ Load XPLM library ]]
    XPLM = nil
    if ffi.os == "Windows" then XPLM = ffi.load("XPLM_64")  -- Windows 64bit
    elseif ffi.os == "Linux" then XPLM = ffi.load("Resources/plugins/XPLM_64.so")  -- Linux 64bit (Requires "Resources/plugins/" for some reason)
    elseif ffi.os == "OSX" then XPLM = ffi.load("Resources/plugins/XPLM.framework/XPLM") -- 64bit MacOS (Requires "Resources/plugins/" for some reason)
    else return 
    end
    if XPLM ~= nil then print("FFI XPLM: Initialized!") end
    --[[ Add Lua-translated XPLM header files to FFI ]]
    FFI_Init_XPLMDefs()
    FFI_Init_XPLMUtilities()
    FFI_Init_XPLMMenus()        --[[ REQUIRES FFI.XPLMDefs.lua and FFI.XPLMUtilities.lua ]]
    FFI_Init_XPLMDisplay()      --[[ REQUIRES FFI.XPLMDefs.lua ]]
    FFI_Init_XPLMGraphics()     --[[ REQUIRES FFI.XPLMDefs.lua ]]
end
