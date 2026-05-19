--@api-stub: lurek.scene.transitions.iris
--@api-stub: lurek.scene.transitions.slide
--@api-stub: lurek.scene.transitions.wipe
-- Scene built-in transition presets.
do
    local iris = lurek.scene.transitions.iris(0.5)
    local slide = lurek.scene.transitions.slide("left", 0.4)
    local wipe = lurek.scene.transitions.wipe(0.6)
    print("transitions iris:", iris ~= nil, "slide:", slide ~= nil, "wipe:", wipe ~= nil)
end
