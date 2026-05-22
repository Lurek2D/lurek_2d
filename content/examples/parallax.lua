-- content/examples/parallax.lua
-- Auto-generated from content/examples2/parallax_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/parallax.lua

--- Parallax Module Part 1: layer creation, scroll, visibility, tiling, depth


--@api-stub: lurek.parallax.newLayer
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"), scroll_factor_x = 0.3, scroll_factor_y = 0.1, z = 10, opacity = 0.9 })
    print("type = " .. layer:type())
end

--@api-stub: lurek.parallax.newPresetLayer
do
    ---@type LImage
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    ---@type LParallaxLayer
    local far = lurek.parallax.newPresetLayer("far", img)
    print("far depth = " .. far:getDepth())
end

--@api-stub: LParallaxLayer:setScrollFactor
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setScrollFactor(0.5, 0.2)
    local sx, sy = layer:getScrollFactor()
    print("scroll = " .. sx .. "," .. sy)
end

--@api-stub: LParallaxLayer:getScrollFactor
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setScrollFactor(0.5, 0.2)
    local sx, sy = layer:getScrollFactor()
    print("scroll = " .. sx .. "," .. sy)
end

--@api-stub: LParallaxLayer:setOffset
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setOffset(10, -5)
    local ox, oy = layer:getOffset()
    print("offset = " .. ox .. "," .. oy)
end

--@api-stub: LParallaxLayer:getOffset
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setOffset(10, -5)
    local ox, oy = layer:getOffset()
    print("offset = " .. ox .. "," .. oy)
end

--@api-stub: LParallaxLayer:setDepth
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setDepth(0.5)
    print("depth = " .. layer:getDepth())
end

--@api-stub: LParallaxLayer:getDepth
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setDepth(0.5)
    print("depth = " .. layer:getDepth())
end

--@api-stub: LParallaxLayer:setZ
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setZ(-5)
    print("z = " .. layer:getZ())
end

--@api-stub: LParallaxLayer:getZ
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setZ(-5)
    print("z = " .. layer:getZ())
end

--@api-stub: LParallaxLayer:setVisible
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setVisible(false)
    print("visible = " .. tostring(layer:isVisible()))
end

--@api-stub: LParallaxLayer:isVisible
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setVisible(false)
    print("visible = " .. tostring(layer:isVisible()))
end

--@api-stub: LParallaxLayer:setOpacity
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setOpacity(0.7)
    print("opacity = " .. layer:getOpacity())
end

--@api-stub: LParallaxLayer:getOpacity
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setOpacity(0.7)
    print("opacity = " .. layer:getOpacity())
end

--@api-stub: LParallaxLayer:setTiling
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setTiling(true)
    print("tiling = " .. tostring(layer:getTiling()))
end

--@api-stub: LParallaxLayer:getTiling
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setTiling(true)
    print("tiling = " .. tostring(layer:getTiling()))
end

--@api-stub: LParallaxLayer:setTileSize
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setTileSize(64, 64)
    print("tile size set")
end

--@api-stub: LParallaxLayer:setRepeat
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setRepeat(true, false)
    print("repeat set: horizontal only")
end

--@api-stub: LParallaxLayer:setScale
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setScale(2.0, 2.0)
    print("scaled 2x")
end

--@api-stub: LParallaxLayer:setTint
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setTint(1.0, 0.8, 0.6, 1.0)
    local r, g, b, a = layer:getTint()
    print("tint = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LParallaxLayer:getTint
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setTint(1.0, 0.8, 0.6, 1.0)
    local r, g, b, a = layer:getTint()
    print("tint = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LParallaxLayer:setBlendMode
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setBlendMode("add"); print("blend = " .. layer:getBlendMode())
    layer:setBlendMode("alpha")
    print("blend = " .. layer:getBlendMode())
end

--@api-stub: LParallaxLayer:getBlendMode
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setBlendMode("add"); print("blend = " .. layer:getBlendMode())
    layer:setBlendMode("alpha")
    print("blend = " .. layer:getBlendMode())
end

--@api-stub: LParallaxLayer:setClamp
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setClamp(-100, -50, 100, 50); print("clamped")
    layer:clearClamp()
    print("clamp cleared")
end

--@api-stub: LParallaxLayer:clearClamp
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setClamp(-100, -50, 100, 50); print("clamped")
    layer:clearClamp()
    print("clamp cleared")
end

--- Parallax Module Part 2: autoscroll, motion stretch, effects, sets, rendering


--@api-stub: LParallaxLayer:setAutoscroll
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setAutoscroll(20, 0)
    local vx, vy = layer:getAutoscroll(); print("autoscroll = " .. vx .. "," .. vy)
    layer:update(1.0); layer:resetAutoscroll()
    print("autoscroll reset")
end

--@api-stub: LParallaxLayer:getAutoscroll
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setAutoscroll(20, 0)
    local vx, vy = layer:getAutoscroll(); print("autoscroll = " .. vx .. "," .. vy)
    layer:update(1.0); layer:resetAutoscroll()
    print("autoscroll reset")
end

--@api-stub: LParallaxLayer:resetAutoscroll
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setAutoscroll(20, 0)
    local vx, vy = layer:getAutoscroll(); print("autoscroll = " .. vx .. "," .. vy)
    layer:update(1.0); layer:resetAutoscroll()
    print("autoscroll reset")
end

--@api-stub: LParallaxLayer:setMotionStretch
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setMotionStretch(true, 0.5, 2.0)
    local enabled, strength, max_scale = layer:getMotionStretch()
    print("stretch enabled=" .. tostring(enabled) .. " strength=" .. strength .. " max=" .. max_scale)
end

--@api-stub: LParallaxLayer:getMotionStretch
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setMotionStretch(true, 0.5, 2.0)
    local enabled, strength, max_scale = layer:getMotionStretch()
    print("stretch enabled=" .. tostring(enabled) .. " strength=" .. strength .. " max=" .. max_scale)
end

--@api-stub: LParallaxLayer:addEffectPass
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:addEffectPass("blur", { 1.5 }); layer:addEffectPass("tint", { 1.0, 0.8, 0.6, 1.0 })
    print("effects = " .. layer:effectCount())
    layer:clearEffects()
    print("after clear = " .. layer:effectCount())
end

--@api-stub: LParallaxLayer:effectCount
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:addEffectPass("blur", { 1.5 }); layer:addEffectPass("tint", { 1.0, 0.8, 0.6, 1.0 })
    print("effects = " .. layer:effectCount())
    layer:clearEffects()
    print("after clear = " .. layer:effectCount())
end

--@api-stub: LParallaxLayer:clearEffects
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:addEffectPass("blur", { 1.5 }); layer:addEffectPass("tint", { 1.0, 0.8, 0.6, 1.0 })
    print("effects = " .. layer:effectCount())
    layer:clearEffects()
    print("after clear = " .. layer:effectCount())
end

--@api-stub: LParallaxLayer:render
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setAutoscroll(50, 0)
    layer:update(0.016); layer:render(100, 50)
    layer:renderAuto()
    print("rendered")
end

--@api-stub: LParallaxLayer:renderAuto
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setAutoscroll(50, 0)
    layer:update(0.016); layer:render(100, 50)
    layer:renderAuto()
    print("rendered")
end

--@api-stub: LParallaxLayer:update
do
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png") })
    layer:setAutoscroll(50, 0)
    layer:update(0.016); layer:render(100, 50)
    layer:renderAuto()
    print("rendered")
end

--@api-stub: lurek.parallax.newSet
do
    ---@type LParallaxSet
    local set = lurek.parallax.newSet("background")
    print("name = " .. set:getName() .. " type = " .. set:type())
    print("layers = " .. set:layerCount())
end

--@api-stub: LParallaxSet:addLayer
do
    local set = lurek.parallax.newSet("scene")
    set:addLayer(lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"), z = 0 }))
    set:addLayer(lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"), z = 5 })); set:addLayer(lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"), z = 10 }))
    print("layers = " .. set:layerCount())
    print("removed = " .. tostring(set:removeLayerAt(2)) .. " layers = " .. set:layerCount())
end

--@api-stub: LParallaxSet:layerCount
do
    local set = lurek.parallax.newSet("scene")
    set:addLayer(lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"), z = 0 }))
    set:addLayer(lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"), z = 5 })); set:addLayer(lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"), z = 10 }))
    print("layers = " .. set:layerCount())
    print("removed = " .. tostring(set:removeLayerAt(2)) .. " layers = " .. set:layerCount())
end

--@api-stub: LParallaxSet:removeLayerAt
do
    local set = lurek.parallax.newSet("scene")
    set:addLayer(lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"), z = 0 }))
    set:addLayer(lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"), z = 5 })); set:addLayer(lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"), z = 10 }))
    print("layers = " .. set:layerCount())
    print("removed = " .. tostring(set:removeLayerAt(2)) .. " layers = " .. set:layerCount())
end

--@api-stub: LParallaxSet:getLayerZAt
do
    local set = lurek.parallax.newSet("sorted")
    set:addLayer(lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"), z = 100 }))
    set:addLayer(lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"), z = 1 })); print("z at 1 = " .. set:getLayerZAt(1) .. " z at 2 = " .. set:getLayerZAt(2))
    set:sortByZ()
    print("sorted: z at 1 = " .. set:getLayerZAt(1))
end

--@api-stub: LParallaxSet:sortByZ
do
    local set = lurek.parallax.newSet("sorted")
    set:addLayer(lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"), z = 100 }))
    set:addLayer(lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"), z = 1 })); print("z at 1 = " .. set:getLayerZAt(1) .. " z at 2 = " .. set:getLayerZAt(2))
    set:sortByZ()
    print("sorted: z at 1 = " .. set:getLayerZAt(1))
end

--@api-stub: LParallaxSet:setName
do
    local set = lurek.parallax.newSet("temp")
    set:setName("sky_layers"); print("name = " .. set:getName())
    set:setVisible(false); print("visible = " .. tostring(set:isVisible()))
    set:setVisible(true)
    print("visible = " .. tostring(set:isVisible()))
end

--@api-stub: LParallaxSet:getName
do
    local set = lurek.parallax.newSet("temp")
    set:setName("sky_layers"); print("name = " .. set:getName())
    set:setVisible(false); print("visible = " .. tostring(set:isVisible()))
    set:setVisible(true)
    print("visible = " .. tostring(set:isVisible()))
end

--@api-stub: LParallaxSet:setVisible
do
    local set = lurek.parallax.newSet("temp")
    set:setName("sky_layers"); print("name = " .. set:getName())
    set:setVisible(false); print("visible = " .. tostring(set:isVisible()))
    set:setVisible(true)
    print("visible = " .. tostring(set:isVisible()))
end

--@api-stub: LParallaxSet:isVisible
do
    local set = lurek.parallax.newSet("temp")
    set:setName("sky_layers"); print("name = " .. set:getName())
    set:setVisible(false); print("visible = " .. tostring(set:isVisible()))
    set:setVisible(true)
    print("visible = " .. tostring(set:isVisible()))
end

--@api-stub: LParallaxSet:render
do
    local set = lurek.parallax.newSet("world")
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"), z = 0 })
    layer:setAutoscroll(30, 0); set:addLayer(layer); set:update(0.016); set:render(200, 100)
    set:renderAuto()
    print("set rendered")
end

--@api-stub: LParallaxSet:renderAuto
do
    local set = lurek.parallax.newSet("world")
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"), z = 0 })
    layer:setAutoscroll(30, 0); set:addLayer(layer); set:update(0.016); set:render(200, 100)
    set:renderAuto()
    print("set rendered")
end

--@api-stub: LParallaxSet:update
do
    local set = lurek.parallax.newSet("world")
    local layer = lurek.parallax.newLayer({ texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"), z = 0 })
    layer:setAutoscroll(30, 0); set:addLayer(layer); set:update(0.016); set:render(200, 100)
    set:renderAuto()
    print("set rendered")
end

--- Parallax Module Part 2: layer type, set type


--@api-stub: LParallaxLayer:type
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ image = img, scroll_factor = 0.5, z = -1 })
    print(layer:type())
end

--@api-stub: LParallaxSet:type
do
    local set = lurek.parallax.newSet("bg_set")
    print(set:type())
end

print("content/examples/parallax.lua")

