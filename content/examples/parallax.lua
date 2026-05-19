-- content/examples/parallax.lua
-- Auto-generated from content/examples2/parallax_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/parallax.lua

--- Parallax Module Part 1: layer creation, scroll, visibility, tiling, depth

--@api-stub: lurek.parallax.newLayer
-- Creates a parallax layer from options.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({
        texture = "bg_mountains.png",
        scrollFactor = {0.3, 0.1},
        z = 10,
        opacity = 0.9,
    })
    print("type = " .. layer:type())
    print("z = " .. layer:getZ())
    print("opacity = " .. layer:getOpacity())
end

--@api-stub: lurek.parallax.newPresetLayer
-- Creates a layer from a named preset.
do
    ---@type LImage
    local img = lurek.render.newImage("assets/textures/ray_water.png")
    ---@type LParallaxLayer
    local far = lurek.parallax.newPresetLayer("far", img)
    ---@type LParallaxLayer
    local mid = lurek.parallax.newPresetLayer("mid", img)
    ---@type LParallaxLayer
    local fog = lurek.parallax.newPresetLayer("fog", img)
    print("far depth = " .. far:getDepth())
    print("mid depth = " .. mid:getDepth())
    print("fog depth = " .. fog:getDepth())
end

--@api-stub: LParallaxLayer:setScrollFactor
--@api-stub: LParallaxLayer:getScrollFactor
-- Controls parallax scrolling speed.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "bg.png"})
    layer:setScrollFactor(0.5, 0.2)
    local sx, sy = layer:getScrollFactor()
    print("scroll = " .. sx .. "," .. sy)
end

--@api-stub: LParallaxLayer:setOffset
--@api-stub: LParallaxLayer:getOffset
-- Pixel offset for fine positioning.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "bg.png"})
    layer:setOffset(10, -5)
    local ox, oy = layer:getOffset()
    print("offset = " .. ox .. "," .. oy)
end

--@api-stub: LParallaxLayer:setDepth
--@api-stub: LParallaxLayer:getDepth
-- Depth value for sorting and parallax strength.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "bg.png"})
    layer:setDepth(0.5)
    print("depth = " .. layer:getDepth())
end

--@api-stub: LParallaxLayer:setZ
--@api-stub: LParallaxLayer:getZ
-- Z order for rendering order.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "bg.png"})
    layer:setZ(-5)
    print("z = " .. layer:getZ())
end

--@api-stub: LParallaxLayer:setVisible
--@api-stub: LParallaxLayer:isVisible
-- Visibility toggle.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "bg.png"})
    layer:setVisible(false)
    print("visible = " .. tostring(layer:isVisible()))
    layer:setVisible(true)
    print("visible = " .. tostring(layer:isVisible()))
end

--@api-stub: LParallaxLayer:setOpacity
--@api-stub: LParallaxLayer:getOpacity
-- Layer opacity (0-1).
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "bg.png"})
    layer:setOpacity(0.7)
    print("opacity = " .. layer:getOpacity())
end

--@api-stub: LParallaxLayer:setTiling
--@api-stub: LParallaxLayer:getTiling
--@api-stub: LParallaxLayer:setTileSize
-- Tiling configuration.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "tile_bg.png"})
    layer:setTiling(true)
    layer:setTileSize(64, 64)
    print("tiling = " .. tostring(layer:getTiling()))
end

--@api-stub: LParallaxLayer:setRepeat
-- Repeat flags per axis.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "bg.png"})
    layer:setRepeat(true, false)
    print("repeat set: horizontal only")
end

--@api-stub: LParallaxLayer:setScale
-- Layer scale factor.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "bg.png"})
    layer:setScale(2.0, 2.0)
    print("scaled 2x")
end

--@api-stub: LParallaxLayer:setTint
--@api-stub: LParallaxLayer:getTint
-- Color tinting.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "bg.png"})
    layer:setTint(1.0, 0.8, 0.6, 1.0)
    local r, g, b, a = layer:getTint()
    print("tint = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LParallaxLayer:setBlendMode
--@api-stub: LParallaxLayer:getBlendMode
-- Blend mode selection.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "bg.png"})
    layer:setBlendMode("add")
    print("blend = " .. layer:getBlendMode())
    layer:setBlendMode("alpha")
    print("blend = " .. layer:getBlendMode())
end

--@api-stub: LParallaxLayer:setClamp
--@api-stub: LParallaxLayer:clearClamp
-- Movement bounds.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = "bg.png"})
    layer:setClamp(-100, -50, 100, 50)
    print("clamped")
    layer:clearClamp()
    print("clamp cleared")
end

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

--- Parallax Module Part 2: layer type, set type

--@api-stub: LParallaxLayer:type
-- Type introspection on LParallaxLayer.
do
    local img = lurek.render.newImage("assets/textures/ray_water.png")
    local layer = lurek.parallax.newLayer({ image = img, scroll_factor = 0.5, z = -1 })
    print(layer:type())
end

--@api-stub: LParallaxSet:type
-- Type introspection on LParallaxSet.
do
    local set = lurek.parallax.newSet("bg_set")
    print(set:type())
end

print("content/examples/parallax.lua")
