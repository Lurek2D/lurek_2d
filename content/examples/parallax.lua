-- content/examples/parallax.lua
-- Auto-generated from content/examples2/parallax_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/parallax.lua

--- Parallax Module Part 1: layer creation, scroll, visibility, tiling, depth

local function load_parallax_image()
    return lurek.render.newImage("assets/textures/ray_water.png")
end


--@api-stub: lurek.parallax.newLayer
-- Creates a parallax layer from options.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({
        texture = load_parallax_image(),
        scroll_factor_x = 0.3,
        scroll_factor_y = 0.1,
        z = 10,
        opacity = 0.9,
    })
    print("type = " .. layer:type())
end

--@api-stub: lurek.parallax.newPresetLayer
-- Creates a layer from a named preset.
do
    ---@type LImage
    local img = lurek.render.newImage("assets/textures/ray_water.png")
    ---@type LParallaxLayer
    local far = lurek.parallax.newPresetLayer("far", img)
    print("far depth = " .. far:getDepth())
end

--@api-stub: LParallaxLayer:setScrollFactor
-- Controls parallax scrolling speed. Focus: setScrollFactor.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setScrollFactor(0.5, 0.2)
    local sx, sy = layer:getScrollFactor()
    print("scroll = " .. sx .. "," .. sy)
end

--@api-stub: LParallaxLayer:getScrollFactor
-- Controls parallax scrolling speed. Focus: getScrollFactor.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setScrollFactor(0.5, 0.2)
    local sx, sy = layer:getScrollFactor()
    print("scroll = " .. sx .. "," .. sy)
end

--@api-stub: LParallaxLayer:setOffset
-- Pixel offset for fine positioning. Focus: setOffset.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setOffset(10, -5)
    local ox, oy = layer:getOffset()
    print("offset = " .. ox .. "," .. oy)
end

--@api-stub: LParallaxLayer:getOffset
-- Pixel offset for fine positioning. Focus: getOffset.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setOffset(10, -5)
    local ox, oy = layer:getOffset()
    print("offset = " .. ox .. "," .. oy)
end

--@api-stub: LParallaxLayer:setDepth
-- Depth value for sorting and parallax strength. Focus: setDepth.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setDepth(0.5)
    print("depth = " .. layer:getDepth())
end

--@api-stub: LParallaxLayer:getDepth
-- Depth value for sorting and parallax strength. Focus: getDepth.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setDepth(0.5)
    print("depth = " .. layer:getDepth())
end

--@api-stub: LParallaxLayer:setZ
-- Z order for rendering order. Focus: setZ.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setZ(-5)
    print("z = " .. layer:getZ())
end

--@api-stub: LParallaxLayer:getZ
-- Z order for rendering order. Focus: getZ.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setZ(-5)
    print("z = " .. layer:getZ())
end

--@api-stub: LParallaxLayer:setVisible
-- Visibility toggle. Focus: setVisible.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setVisible(false)
    print("visible = " .. tostring(layer:isVisible()))
end

--@api-stub: LParallaxLayer:isVisible
-- Visibility toggle. Focus: isVisible.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setVisible(false)
    print("visible = " .. tostring(layer:isVisible()))
end

--@api-stub: LParallaxLayer:setOpacity
-- Layer opacity (0-1). Focus: setOpacity.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setOpacity(0.7)
    print("opacity = " .. layer:getOpacity())
end

--@api-stub: LParallaxLayer:getOpacity
-- Layer opacity (0-1). Focus: getOpacity.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setOpacity(0.7)
    print("opacity = " .. layer:getOpacity())
end

--@api-stub: LParallaxLayer:setTiling
-- Tiling configuration. Focus: setTiling.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setTiling(true)
    print("tiling = " .. tostring(layer:getTiling()))
end

--@api-stub: LParallaxLayer:getTiling
-- Tiling configuration. Focus: getTiling.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setTiling(true)
    print("tiling = " .. tostring(layer:getTiling()))
end

--@api-stub: LParallaxLayer:setTileSize
-- Tiling configuration. Focus: setTileSize.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setTileSize(64, 64)
    print("tile size set")
end

--@api-stub: LParallaxLayer:setRepeat
-- Repeat flags per axis.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setRepeat(true, false)
    print("repeat set: horizontal only")
end

--@api-stub: LParallaxLayer:setScale
-- Layer scale factor.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setScale(2.0, 2.0)
    print("scaled 2x")
end

--@api-stub: LParallaxLayer:setTint
-- Color tinting. Focus: setTint.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setTint(1.0, 0.8, 0.6, 1.0)
    local r, g, b, a = layer:getTint()
    print("tint = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LParallaxLayer:getTint
-- Color tinting. Focus: getTint.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setTint(1.0, 0.8, 0.6, 1.0)
    local r, g, b, a = layer:getTint()
    print("tint = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LParallaxLayer:setBlendMode
-- Blend mode selection. Focus: setBlendMode.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setBlendMode("add")
    print("blend = " .. layer:getBlendMode())
    layer:setBlendMode("alpha")
    print("blend = " .. layer:getBlendMode())
end

--@api-stub: LParallaxLayer:getBlendMode
-- Blend mode selection. Focus: getBlendMode.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setBlendMode("add")
    print("blend = " .. layer:getBlendMode())
    layer:setBlendMode("alpha")
    print("blend = " .. layer:getBlendMode())
end

--@api-stub: LParallaxLayer:setClamp
-- Movement bounds. Focus: setClamp.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setClamp(-100, -50, 100, 50)
    print("clamped")
    layer:clearClamp()
    print("clamp cleared")
end

--@api-stub: LParallaxLayer:clearClamp
-- Movement bounds. Focus: clearClamp.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setClamp(-100, -50, 100, 50)
    print("clamped")
    layer:clearClamp()
    print("clamp cleared")
end

--- Parallax Module Part 2: autoscroll, motion stretch, effects, sets, rendering

local function load_parallax_image()
    return lurek.render.newImage("assets/textures/ray_water.png")
end


--@api-stub: LParallaxLayer:setAutoscroll
-- Automatic scrolling velocity. Focus: setAutoscroll.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setAutoscroll(20, 0)
    local vx, vy = layer:getAutoscroll()
    print("autoscroll = " .. vx .. "," .. vy)
    layer:update(1.0)
    layer:resetAutoscroll()
    print("autoscroll reset")
end

--@api-stub: LParallaxLayer:getAutoscroll
-- Automatic scrolling velocity. Focus: getAutoscroll.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setAutoscroll(20, 0)
    local vx, vy = layer:getAutoscroll()
    print("autoscroll = " .. vx .. "," .. vy)
    layer:update(1.0)
    layer:resetAutoscroll()
    print("autoscroll reset")
end

--@api-stub: LParallaxLayer:resetAutoscroll
-- Automatic scrolling velocity. Focus: resetAutoscroll.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setAutoscroll(20, 0)
    local vx, vy = layer:getAutoscroll()
    print("autoscroll = " .. vx .. "," .. vy)
    layer:update(1.0)
    layer:resetAutoscroll()
    print("autoscroll reset")
end

--@api-stub: LParallaxLayer:setMotionStretch
-- Motion stretch settings. Focus: setMotionStretch.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setMotionStretch(true, 0.5, 2.0)
    local enabled, strength, max_scale = layer:getMotionStretch()
    print("stretch enabled=" .. tostring(enabled))
    print("strength=" .. strength .. " max=" .. max_scale)
end

--@api-stub: LParallaxLayer:getMotionStretch
-- Motion stretch settings. Focus: getMotionStretch.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setMotionStretch(true, 0.5, 2.0)
    local enabled, strength, max_scale = layer:getMotionStretch()
    print("stretch enabled=" .. tostring(enabled))
    print("strength=" .. strength .. " max=" .. max_scale)
end

--@api-stub: LParallaxLayer:addEffectPass
-- Shader effect passes. Focus: addEffectPass.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:addEffectPass("blur", {1.5})
    layer:addEffectPass("tint", {1.0, 0.8, 0.6, 1.0})
    print("effects = " .. layer:effectCount())
    layer:clearEffects()
    print("after clear = " .. layer:effectCount())
end

--@api-stub: LParallaxLayer:effectCount
-- Shader effect passes. Focus: effectCount.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:addEffectPass("blur", {1.5})
    layer:addEffectPass("tint", {1.0, 0.8, 0.6, 1.0})
    print("effects = " .. layer:effectCount())
    layer:clearEffects()
    print("after clear = " .. layer:effectCount())
end

--@api-stub: LParallaxLayer:clearEffects
-- Shader effect passes. Focus: clearEffects.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:addEffectPass("blur", {1.5})
    layer:addEffectPass("tint", {1.0, 0.8, 0.6, 1.0})
    print("effects = " .. layer:effectCount())
    layer:clearEffects()
    print("after clear = " .. layer:effectCount())
end

--@api-stub: LParallaxLayer:render
-- Rendering and animation. Focus: render.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setAutoscroll(50, 0)
    layer:update(0.016)
    layer:render(100, 50)
    layer:renderAuto()
    print("rendered")
end

--@api-stub: LParallaxLayer:renderAuto
-- Rendering and animation. Focus: renderAuto.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
    layer:setAutoscroll(50, 0)
    layer:update(0.016)
    layer:render(100, 50)
    layer:renderAuto()
    print("rendered")
end

--@api-stub: LParallaxLayer:update
-- Rendering and animation. Focus: update.
do
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image()})
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
-- Managing layers in a set. Focus: addLayer.
do
    ---@type LParallaxSet
    local set = lurek.parallax.newSet("scene")
    ---@type LParallaxLayer
    local l1 = lurek.parallax.newLayer({texture = load_parallax_image(), z = 0})
    ---@type LParallaxLayer
    local l2 = lurek.parallax.newLayer({texture = load_parallax_image(), z = 5})
    ---@type LParallaxLayer
    local l3 = lurek.parallax.newLayer({texture = load_parallax_image(), z = 10})
    set:addLayer(l1)
    set:addLayer(l2)
    set:addLayer(l3)
    print("layers = " .. set:layerCount())
    local removed = set:removeLayerAt(2)
    print("removed = " .. tostring(removed) .. " layers = " .. set:layerCount())
end

--@api-stub: LParallaxSet:layerCount
-- Managing layers in a set. Focus: layerCount.
do
    ---@type LParallaxSet
    local set = lurek.parallax.newSet("scene")
    ---@type LParallaxLayer
    local l1 = lurek.parallax.newLayer({texture = load_parallax_image(), z = 0})
    ---@type LParallaxLayer
    local l2 = lurek.parallax.newLayer({texture = load_parallax_image(), z = 5})
    ---@type LParallaxLayer
    local l3 = lurek.parallax.newLayer({texture = load_parallax_image(), z = 10})
    set:addLayer(l1)
    set:addLayer(l2)
    set:addLayer(l3)
    print("layers = " .. set:layerCount())
    local removed = set:removeLayerAt(2)
    print("removed = " .. tostring(removed) .. " layers = " .. set:layerCount())
end

--@api-stub: LParallaxSet:removeLayerAt
-- Managing layers in a set. Focus: removeLayerAt.
do
    ---@type LParallaxSet
    local set = lurek.parallax.newSet("scene")
    ---@type LParallaxLayer
    local l1 = lurek.parallax.newLayer({texture = load_parallax_image(), z = 0})
    ---@type LParallaxLayer
    local l2 = lurek.parallax.newLayer({texture = load_parallax_image(), z = 5})
    ---@type LParallaxLayer
    local l3 = lurek.parallax.newLayer({texture = load_parallax_image(), z = 10})
    set:addLayer(l1)
    set:addLayer(l2)
    set:addLayer(l3)
    print("layers = " .. set:layerCount())
    local removed = set:removeLayerAt(2)
    print("removed = " .. tostring(removed) .. " layers = " .. set:layerCount())
end

--@api-stub: LParallaxSet:getLayerZAt
-- Z-order queries and sorting. Focus: getLayerZAt.
do
    ---@type LParallaxSet
    local set = lurek.parallax.newSet("sorted")
    ---@type LParallaxLayer
    local far = lurek.parallax.newLayer({texture = load_parallax_image(), z = 100})
    ---@type LParallaxLayer
    local near = lurek.parallax.newLayer({texture = load_parallax_image(), z = 1})
    set:addLayer(far)
    set:addLayer(near)
    print("z at 1 = " .. set:getLayerZAt(1))
    print("z at 2 = " .. set:getLayerZAt(2))
    set:sortByZ()
    print("sorted: z at 1 = " .. set:getLayerZAt(1))
end

--@api-stub: LParallaxSet:sortByZ
-- Z-order queries and sorting. Focus: sortByZ.
do
    ---@type LParallaxSet
    local set = lurek.parallax.newSet("sorted")
    ---@type LParallaxLayer
    local far = lurek.parallax.newLayer({texture = load_parallax_image(), z = 100})
    ---@type LParallaxLayer
    local near = lurek.parallax.newLayer({texture = load_parallax_image(), z = 1})
    set:addLayer(far)
    set:addLayer(near)
    print("z at 1 = " .. set:getLayerZAt(1))
    print("z at 2 = " .. set:getLayerZAt(2))
    set:sortByZ()
    print("sorted: z at 1 = " .. set:getLayerZAt(1))
end

--@api-stub: LParallaxSet:setName
-- Set metadata. Focus: setName.
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

--@api-stub: LParallaxSet:getName
-- Set metadata. Focus: getName.
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

--@api-stub: LParallaxSet:setVisible
-- Set metadata. Focus: setVisible.
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

--@api-stub: LParallaxSet:isVisible
-- Set metadata. Focus: isVisible.
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
-- Set-level rendering and update. Focus: render.
do
    ---@type LParallaxSet
    local set = lurek.parallax.newSet("world")
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image(), z = 0})
    layer:setAutoscroll(30, 0)
    set:addLayer(layer)
    set:update(0.016)
    set:render(200, 100)
    set:renderAuto()
    print("set rendered")
end

--@api-stub: LParallaxSet:renderAuto
-- Set-level rendering and update. Focus: renderAuto.
do
    ---@type LParallaxSet
    local set = lurek.parallax.newSet("world")
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image(), z = 0})
    layer:setAutoscroll(30, 0)
    set:addLayer(layer)
    set:update(0.016)
    set:render(200, 100)
    set:renderAuto()
    print("set rendered")
end

--@api-stub: LParallaxSet:update
-- Set-level rendering and update. Focus: update.
do
    ---@type LParallaxSet
    local set = lurek.parallax.newSet("world")
    ---@type LParallaxLayer
    local layer = lurek.parallax.newLayer({texture = load_parallax_image(), z = 0})
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
