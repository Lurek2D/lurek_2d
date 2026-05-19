--@api-stub: lurek.runtime.getDebugOverlay
--@api-stub: lurek.runtime.parseArgs
--@api-stub: lurek.runtime.reloadConfig
-- Runtime debug overlay state, arg parsing, config reload.
do
    local overlay = lurek.runtime.getDebugOverlay()
    local parsed = lurek.runtime.parseArgs({"--debug", "--level=5", "game.lua"})
    lurek.runtime.reloadConfig()
    print("getDebugOverlay:", overlay, "parseArgs flags:", type(parsed.flags), "reloadConfig ok")
end
