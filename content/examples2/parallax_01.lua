--- Parallax Module Part 2: autoscroll, motion stretch, effects, sets, rendering

--@api-stub: LParallaxLayer:setAutoscroll
--@api-stub: LParallaxLayer:getAutoscroll
--@api-stub: LParallaxLayer:resetAutoscroll
-- Automatic scrolling velocity.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "bg.png"})
    layer:setAutoscroll(20, 0)
    local vx, vy = layer:getAutoscroll()
    print("autoscroll = " .. vx .. "," .. vy)
    layer:update(1.0)
    layer:resetAutoscroll()
    print("autoscroll reset")
end

--@api-stub: LParallaxLayer:setMotionStretch
--@api-stub: LParallaxLayer:getMotionStretch
-- Motion stretch settings.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "bg.png"})
    layer:setMotionStretch(true, 0.5, 2.0)
    local enabled, strength, max_scale = layer:getMotionStretch()
    print("stretch enabled=" .. tostring(enabled))
    print("strength=" .. strength .. " max=" .. max_scale)
end

--@api-stub: LParallaxLayer:addEffectPass
--@api-stub: LParallaxLayer:effectCount
--@api-stub: LParallaxLayer:clearEffects
-- Shader effect passes.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "bg.png"})
    layer:addEffectPass("blur", {1.5})
    layer:addEffectPass("tint", {1.0, 0.8, 0.6, 1.0})
    print("effects = " .. layer:effectCount())
    layer:clearEffects()
    print("after clear = " .. layer:effectCount())
end

--@api-stub: LParallaxLayer:render
--@api-stub: LParallaxLayer:renderAuto
--@api-stub: LParallaxLayer:update
-- Rendering and animation.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "bg.png"})
    layer:setAutoscroll(50, 0)
    layer:update(0.016)
    layer:render(100, 50)
    layer:renderAuto()
    print("rendered")
end

--@api-stub: lurek.parallax.newSet
-- Creates a parallax layer set.
do
    ---@type LParallaxSet
    local set = lurek.parallax.newSet("background")
    print("name = " .. set:getName() .. " type = " .. set:type())
    print("layers = " .. set:layerCount())
end

--@api-stub: LParallaxSet:addLayer
--@api-stub: LParallaxSet:layerCount
--@api-stub: LParallaxSet:removeLayerAt
-- Managing layers in a set.
do
    ---@type LParallaxSet
    local set = lurek.parallax.newSet("scene")
    ---@type LParallaxLayer
    local l1 = lurek.parallax.newLayer({texture = "sky.png", z = 0})
    ---@type LParallaxLayer
    local l2 = lurek.parallax.newLayer({texture = "mountains.png", z = 5})
    ---@type LParallaxLayer
    local l3 = lurek.parallax.newLayer({texture = "trees.png", z = 10})
    set:addLayer(l1)
    set:addLayer(l2)
    set:addLayer(l3)
    print("layers = " .. set:layerCount())
    local removed = set:removeLayerAt(2)
    print("removed = " .. tostring(removed) .. " layers = " .. set:layerCount())
end

--@api-stub: LParallaxSet:getLayerZAt
--@api-stub: LParallaxSet:sortByZ
-- Z-order queries and sorting.
do
    ---@type LParallaxSet
    local set = lurek.parallax.newSet("sorted")
    ---@type LParallaxLayer
    local far = lurek.parallax.newLayer({texture = "far.png", z = 100})
    ---@type LParallaxLayer
    local near = lurek.parallax.newLayer({texture = "near.png", z = 1})
    set:addLayer(far)
    set:addLayer(near)
    print("z at 1 = " .. set:getLayerZAt(1))
    print("z at 2 = " .. set:getLayerZAt(2))
    set:sortByZ()
    print("sorted: z at 1 = " .. set:getLayerZAt(1))
end

--@api-stub: LParallaxSet:setName
--@api-stub: LParallaxSet:getName
--@api-stub: LParallaxSet:setVisible
--@api-stub: LParallaxSet:isVisible
-- Set metadata.
do
    ---@type LParallaxSet
    local set = lurek.parallax.newSet("temp")
    set:setName("sky_layers")
    print("name = " .. set:getName())
    set:setVisible(false)
    print("visible = " .. tostring(set:isVisible()))
    set:setVisible(true)
    print("visible = " .. tostring(set:isVisible()))
end

--@api-stub: LParallaxSet:render
--@api-stub: LParallaxSet:renderAuto
--@api-stub: LParallaxSet:update
-- Set-level rendering and update.
do
    ---@type LParallaxSet
    local set = lurek.parallax.newSet("world")
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "bg.png", z = 0})
    layer:setAutoscroll(30, 0)
    set:addLayer(layer)
    set:update(0.016)
    set:render(200, 100)
    set:renderAuto()
    print("set rendered")
end

print("parallax_01.lua")
