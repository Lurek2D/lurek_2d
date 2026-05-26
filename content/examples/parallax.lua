-- content/examples/parallax.lua
-- Auto-generated from content/examples2/parallax_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/parallax.lua

--- Parallax Module Part 1: layer creation, scroll, visibility, tiling, depth

--@api-stub: lurek.parallax.newLayer
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        scroll_factor_x = 0.3,
        scroll_factor_y = 0.1,
        z = 10,
        opacity = 0.9,
        tiling = true,
    })
    local sx, sy = layer:getScrollFactor()
    print("type = " .. layer:type())
    print("scroll = " .. sx .. "," .. sy)
    print("z = " .. layer:getZ())
end

--@api-stub: lurek.parallax.newPresetLayer
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local far = lurek.parallax.newPresetLayer("far", img)
    local mid = lurek.parallax.newPresetLayer("mid", img)
    print("far depth = " .. far:getDepth())
    print("mid z = " .. mid:getZ())
end

--@api-stub: LParallaxLayer:setScrollFactor
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setScrollFactor(0.5, 0.2)
    local sx, sy = layer:getScrollFactor()
    print("scroll = " .. sx .. "," .. sy)
end

--@api-stub: LParallaxLayer:getScrollFactor
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        scroll_factor_x = 0.75,
        scroll_factor_y = 0.15,
    })
    local sx, sy = layer:getScrollFactor()
    print("scroll = " .. sx .. "," .. sy)
end

--@api-stub: LParallaxLayer:setOffset
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setOffset(10, -5)
    local ox, oy = layer:getOffset()
    print("offset = " .. ox .. "," .. oy)
end

--@api-stub: LParallaxLayer:getOffset
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        offset_x = 24,
        offset_y = -8,
    })
    local ox, oy = layer:getOffset()
    print("offset = " .. ox .. "," .. oy)
end

--@api-stub: LParallaxLayer:setDepth
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setDepth(0.5)
    print("depth = " .. layer:getDepth())
end

--@api-stub: LParallaxLayer:getDepth
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        depth = 0.8,
    })
    print("depth = " .. layer:getDepth())
end

--@api-stub: LParallaxLayer:setZ
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setZ(-5)
    print("z = " .. layer:getZ())
end

--@api-stub: LParallaxLayer:getZ
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        z = -5,
    })
    print("z = " .. layer:getZ())
end

--@api-stub: LParallaxLayer:setVisible
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setVisible(false)
    print("visible = " .. tostring(layer:isVisible()))
    layer:setVisible(true)
    print("visible = " .. tostring(layer:isVisible()))
end

--@api-stub: LParallaxLayer:isVisible
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        visible = false,
    })
    print("visible = " .. tostring(layer:isVisible()))
end

--@api-stub: LParallaxLayer:setOpacity
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setOpacity(0.7)
    print("opacity = " .. layer:getOpacity())
end

--@api-stub: LParallaxLayer:getOpacity
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        opacity = 0.35,
    })
    print("opacity = " .. layer:getOpacity())
end

--@api-stub: LParallaxLayer:setTiling
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setTiling(true)
    print("tiling = " .. tostring(layer:getTiling()))
end

--@api-stub: LParallaxLayer:getTiling
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        tiling = true,
    })
    print("tiling = " .. tostring(layer:getTiling()))
end

--@api-stub: LParallaxLayer:setTileSize
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        tiling = true,
    })
    layer:setTileSize(64, 64)
    layer:render(0, 0)
    print("tile size set to 64x64")
    print("rendered tiled layer")
end

--@api-stub: LParallaxLayer:setRepeat
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setRepeat(true, false)
    layer:render(32, 16)
    print("repeat set: horizontal only")
    print("z = " .. layer:getZ())
end

--@api-stub: LParallaxLayer:setScale
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setScale(2.0, 2.0)
    layer:render(0, 0)
    print("scaled 2x")
    print("type = " .. layer:type())
end

--@api-stub: LParallaxLayer:setTint
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setTint(1.0, 0.8, 0.6, 1.0)
    local r, g, b, a = layer:getTint()
    print("tint = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LParallaxLayer:getTint
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        tint_r = 0.6,
        tint_g = 0.8,
        tint_b = 1.0,
        tint_a = 0.75,
    })
    local r, g, b, a = layer:getTint()
    print("tint = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: LParallaxLayer:setBlendMode
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setBlendMode("add")
    print("blend = " .. layer:getBlendMode())
    layer:setBlendMode("alpha")
    print("blend = " .. layer:getBlendMode())
end

--@api-stub: LParallaxLayer:getBlendMode
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        blend_mode = "screen",
    })
    print("blend = " .. layer:getBlendMode())
end

--@api-stub: LParallaxLayer:setClamp
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setClamp(-100, -50, 100, 50)
    print("clamped")
    layer:clearClamp()
    print("clamp cleared")
end

--@api-stub: LParallaxLayer:clearClamp
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setClamp(-100, -50, 100, 50)
    print("clamped")
    layer:clearClamp()
    print("clamp cleared")
end

--- Parallax Module Part 2: autoscroll, motion stretch, effects, sets, rendering

--@api-stub: LParallaxLayer:setAutoscroll
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setAutoscroll(20, 0)
    local vx, vy = layer:getAutoscroll()
    print("autoscroll = " .. vx .. "," .. vy)
    layer:update(1.0)
    layer:resetAutoscroll()
    print("autoscroll reset")
end

--@api-stub: LParallaxLayer:getAutoscroll
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        autoscroll_x = 12,
        autoscroll_y = -4,
    })
    local vx, vy = layer:getAutoscroll()
    print("autoscroll = " .. vx .. "," .. vy)
end

--@api-stub: LParallaxLayer:resetAutoscroll
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setAutoscroll(20, 0)
    layer:update(1.0)
    layer:resetAutoscroll()
    local vx, vy = layer:getAutoscroll()
    print("velocity still = " .. vx .. "," .. vy)
    print("autoscroll reset")
end

--@api-stub: LParallaxLayer:setMotionStretch
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setMotionStretch(true, 0.5, 2.0)
    local enabled, strength, max_scale = layer:getMotionStretch()
    print("stretch enabled=" .. tostring(enabled) .. " strength=" .. strength .. " max=" .. max_scale)
end

--@api-stub: LParallaxLayer:getMotionStretch
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        motion_stretch = true,
        motion_stretch_strength = 0.5,
        motion_stretch_max = 2.0,
    })
    local enabled, strength, max_scale = layer:getMotionStretch()
    print("stretch enabled=" .. tostring(enabled) .. " strength=" .. strength .. " max=" .. max_scale)
end

--@api-stub: LParallaxLayer:addEffectPass
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:addEffectPass("blur", { radius = 1.5 })
    layer:addEffectPass("tint", { r = 1.0, g = 0.8, b = 0.6, a = 1.0 })
    print("effects = " .. layer:effectCount())
    layer:clearEffects()
    print("after clear = " .. layer:effectCount())
end

--@api-stub: LParallaxLayer:effectCount
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:addEffectPass("blur", { radius = 1.5 })
    layer:addEffectPass("tint", { r = 1.0, g = 0.8, b = 0.6, a = 1.0 })
    print("effects = " .. layer:effectCount())
    layer:clearEffects()
    print("after clear = " .. layer:effectCount())
end

--@api-stub: LParallaxLayer:clearEffects
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:addEffectPass("blur", { radius = 1.5 })
    layer:addEffectPass("tint", { r = 1.0, g = 0.8, b = 0.6, a = 1.0 })
    print("effects = " .. layer:effectCount())
    layer:clearEffects()
    print("after clear = " .. layer:effectCount())
end

--@api-stub: LParallaxLayer:render
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setAutoscroll(50, 0)
    layer:update(0.016)
    layer:render(100, 50)
    layer:renderAuto()
    print("rendered")
end

--@api-stub: LParallaxLayer:renderAuto
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setAutoscroll(50, 0)
    layer:update(0.016)
    layer:render(100, 50)
    layer:renderAuto()
    print("rendered")
end

--@api-stub: LParallaxLayer:update
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setAutoscroll(50, 0)
    layer:update(0.016)
    layer:render(100, 50)
    layer:renderAuto()
    print("rendered")
end

--@api-stub: lurek.parallax.newSet
do
    local set = lurek.parallax.newSet("background")
    print("name = " .. set:getName() .. " type = " .. set:type())
    print("layers = " .. set:layerCount())
end

--@api-stub: LParallaxSet:addLayer
do
    local set = lurek.parallax.newSet("scene")
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 0,
    }))
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 5,
    }))
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 10,
    }))
    print("layers = " .. set:layerCount())
    print("removed = " .. tostring(set:removeLayerAt(2)) .. " layers = " .. set:layerCount())
end

--@api-stub: LParallaxSet:layerCount
do
    local set = lurek.parallax.newSet("scene")
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 0,
    }))
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 5,
    }))
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 10,
    }))
    print("layers = " .. set:layerCount())
    print("removed = " .. tostring(set:removeLayerAt(2)) .. " layers = " .. set:layerCount())
end

--@api-stub: LParallaxSet:removeLayerAt
do
    local set = lurek.parallax.newSet("scene")
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 0,
    }))
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 5,
    }))
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 10,
    }))
    print("layers = " .. set:layerCount())
    print("removed = " .. tostring(set:removeLayerAt(2)) .. " layers = " .. set:layerCount())
end

--@api-stub: LParallaxSet:getLayerZAt
do
    local set = lurek.parallax.newSet("sorted")
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 100,
    }))
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 1,
    }))
    print("z at 1 = " .. tostring(set:getLayerZAt(1)))
    print("z at 2 = " .. tostring(set:getLayerZAt(2)))
    set:sortByZ()
    print("sorted: z at 1 = " .. tostring(set:getLayerZAt(1)))
end

--@api-stub: LParallaxSet:sortByZ
do
    local set = lurek.parallax.newSet("sorted")
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 100,
    }))
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 1,
    }))
    print("before sort z1 = " .. tostring(set:getLayerZAt(1)))
    print("before sort z2 = " .. tostring(set:getLayerZAt(2)))
    set:sortByZ()
    print("sorted: z at 1 = " .. tostring(set:getLayerZAt(1)))
end

--@api-stub: LParallaxSet:setName
do
    local set = lurek.parallax.newSet("temp")
    set:setName("sky_layers")
    print("name = " .. set:getName())
    set:setVisible(false)
    print("visible = " .. tostring(set:isVisible()))
    set:setVisible(true)
    print("visible = " .. tostring(set:isVisible()))
end

--@api-stub: LParallaxSet:getName
do
    local set = lurek.parallax.newSet("temp")
    set:setName("sky_layers")
    print("name = " .. set:getName())
end

--@api-stub: LParallaxSet:setVisible
do
    local set = lurek.parallax.newSet("temp")
    set:setName("sky_layers")
    print("name = " .. set:getName())
    set:setVisible(false)
    print("visible = " .. tostring(set:isVisible()))
    set:setVisible(true)
    print("visible = " .. tostring(set:isVisible()))
end

--@api-stub: LParallaxSet:isVisible
do
    local set = lurek.parallax.newSet("temp")
    set:setVisible(false)
    print("visible = " .. tostring(set:isVisible()))
end

--@api-stub: LParallaxSet:render
do
    local set = lurek.parallax.newSet("world")
    local layer = lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 0,
    })
    layer:setAutoscroll(30, 0)
    set:addLayer(layer)
    set:update(0.016)
    set:render(200, 100)
    set:renderAuto()
    print("set rendered")
end

--@api-stub: LParallaxSet:renderAuto
do
    local set = lurek.parallax.newSet("world")
    local layer = lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 0,
    })
    layer:setAutoscroll(30, 0)
    set:addLayer(layer)
    set:update(0.016)
    set:render(200, 100)
    set:renderAuto()
    print("set rendered")
end

--@api-stub: LParallaxSet:update
do
    local set = lurek.parallax.newSet("world")
    local layer = lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 0,
    })
    layer:setAutoscroll(30, 0)
    set:addLayer(layer)
    set:update(0.016)
    set:render(200, 100)
    set:renderAuto()
    print("set rendered")
end

--- Parallax Module Part 2: layer type, set type

--@api-stub: LParallaxLayer:type
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = img,
        scroll_factor_x = 0.5,
        scroll_factor_y = 0.2,
        z = -1,
    })
    print(layer:type())
end

--@api-stub: LParallaxSet:type
do
    local set = lurek.parallax.newSet("bg_set")
    print(set:type())
end
