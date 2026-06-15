-- content/examples/parallax.lua
-- Auto-generated from content/examples2/parallax_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/parallax.lua

--- Parallax Module Part 1: layer creation, scroll, visibility, tiling, depth

--@api: lurek.parallax.newLayer
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

--@api: lurek.parallax.newPresetLayer
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local far = lurek.parallax.newPresetLayer("far", img)
    local mid = lurek.parallax.newPresetLayer("mid", img)
    print("far depth = " .. far:getDepth())
    print("mid z = " .. mid:getZ())
end

--@api: LParallaxLayer:setScrollFactor
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setScrollFactor(0.5, 0.2)
    local sx, sy = layer:getScrollFactor()
    print("scroll = " .. sx .. "," .. sy)
end

--@api: LParallaxLayer:getScrollFactor
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

--@api: LParallaxLayer:setOffset
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setOffset(10, -5)
    local ox, oy = layer:getOffset()
    print("offset = " .. ox .. "," .. oy)
end

--@api: LParallaxLayer:getOffset
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

--@api: LParallaxLayer:setDepth
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setDepth(0.5)
    print("depth = " .. layer:getDepth())
end

--@api: LParallaxLayer:getDepth
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        depth = 0.8,
    })
    print("depth = " .. layer:getDepth())
end

--@api: LParallaxLayer:setZ
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setZ(-5)
    print("z = " .. layer:getZ())
end

--@api: LParallaxLayer:getZ
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        z = -5,
    })
    print("z = " .. layer:getZ())
end

--@api: LParallaxLayer:setVisible
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setVisible(false)
    print("visible = " .. tostring(layer:isVisible()))
    layer:setVisible(true)
    print("visible = " .. tostring(layer:isVisible()))
end

--@api: LParallaxLayer:isVisible
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        visible = false,
    })
    print("visible = " .. tostring(layer:isVisible()))
end

--@api: LParallaxLayer:setOpacity
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setOpacity(0.7)
    print("opacity = " .. layer:getOpacity())
end

--@api: LParallaxLayer:getOpacity
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        opacity = 0.35,
    })
    print("opacity = " .. layer:getOpacity())
end

--@api: LParallaxLayer:setTiling
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setTiling(true)
    print("tiling = " .. tostring(layer:getTiling()))
end

--@api: LParallaxLayer:getTiling
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        tiling = true,
    })
    print("tiling = " .. tostring(layer:getTiling()))
end

--@api: LParallaxLayer:setTileSize
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

--@api: LParallaxLayer:setRepeat
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setRepeat(true, false)
    layer:render(32, 16)
    print("repeat set: horizontal only")
    print("z = " .. layer:getZ())
end

--@api: LParallaxLayer:setScale
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setScale(2.0, 2.0)
    layer:render(0, 0)
    print("scaled 2x")
    print("type = " .. layer:type())
end

--@api: LParallaxLayer:setTint
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setTint(1.0, 0.8, 0.6, 1.0)
    local r, g, b, a = layer:getTint()
    print("tint = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LParallaxLayer:getTint
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

--@api: LParallaxLayer:setBlendMode
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setBlendMode("add")
    print("blend = " .. layer:getBlendMode())
    layer:setBlendMode("alpha")
    print("blend = " .. layer:getBlendMode())
end

--@api: LParallaxLayer:getBlendMode
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        blend_mode = "screen",
    })
    print("blend = " .. layer:getBlendMode())
end

--@api: LParallaxLayer:setClamp
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setClamp(-100, -50, 100, 50)
    print("clamped")
    layer:clearClamp()
    print("clamp cleared")
end

--@api: LParallaxLayer:clearClamp
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setClamp(-100, -50, 100, 50)
    print("clamped")
    layer:clearClamp()
    print("clamp cleared")
end

--- Parallax Module Part 2: autoscroll, motion stretch, effects, sets, rendering

--@api: LParallaxLayer:setAutoscroll
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

--@api: LParallaxLayer:getAutoscroll
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

--@api: LParallaxLayer:resetAutoscroll
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

--@api: LParallaxLayer:setMotionStretch
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setMotionStretch(true, 0.5, 2.0)
    local enabled, strength, max_scale = layer:getMotionStretch()
    print("stretch enabled=" .. tostring(enabled) .. " strength=" .. strength .. " max=" .. max_scale)
end

--@api: LParallaxLayer:getMotionStretch
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

--@api: LParallaxLayer:addEffectPass
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:addEffectPass("blur", { radius = 1.5 })
    layer:addEffectPass("tint", { r = 1.0, g = 0.8, b = 0.6, a = 1.0 })
    print("effects = " .. layer:effectCount())
    layer:clearEffects()
    print("after clear = " .. layer:effectCount())
end

--@api: LParallaxLayer:effectCount
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:addEffectPass("blur", { radius = 1.5 })
    layer:addEffectPass("tint", { r = 1.0, g = 0.8, b = 0.6, a = 1.0 })
    print("effects = " .. layer:effectCount())
    layer:clearEffects()
    print("after clear = " .. layer:effectCount())
end

--@api: LParallaxLayer:clearEffects
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:addEffectPass("blur", { radius = 1.5 })
    layer:addEffectPass("tint", { r = 1.0, g = 0.8, b = 0.6, a = 1.0 })
    print("effects = " .. layer:effectCount())
    layer:clearEffects()
    print("after clear = " .. layer:effectCount())
end

--@api: LParallaxLayer:render
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setAutoscroll(50, 0)
    layer:update(0.016)
    layer:render(100, 50)
    layer:renderAuto()
    print("rendered")
end

--@api: LParallaxLayer:renderAuto
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setAutoscroll(50, 0)
    layer:update(0.016)
    layer:render(100, 50)
    layer:renderAuto()
    print("rendered")
end

--@api: LParallaxLayer:update
do
    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setAutoscroll(50, 0)
    layer:update(0.016)
    layer:render(100, 50)
    layer:renderAuto()
    print("rendered")
end

--@api: lurek.parallax.newSet
do
    local set = lurek.parallax.newSet("background")
    print("name = " .. set:getName() .. " type = " .. set:type())
    print("layers = " .. set:layerCount())
end

--@api: LParallaxSet:addLayer
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

--@api: LParallaxSet:layerCount
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

--@api: LParallaxSet:removeLayerAt
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

--@api: LParallaxSet:getLayerZAt
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

--@api: LParallaxSet:sortByZ
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

--@api: LParallaxSet:setName
do
    local set = lurek.parallax.newSet("temp")
    set:setName("sky_layers")
    print("name = " .. set:getName())
    set:setVisible(false)
    print("visible = " .. tostring(set:isVisible()))
    set:setVisible(true)
    print("visible = " .. tostring(set:isVisible()))
end

--@api: LParallaxSet:getName
do
    local set = lurek.parallax.newSet("temp")
    set:setName("sky_layers")
    print("name = " .. set:getName())
end

--@api: LParallaxSet:setVisible
do
    local set = lurek.parallax.newSet("temp")
    set:setName("sky_layers")
    print("name = " .. set:getName())
    set:setVisible(false)
    print("visible = " .. tostring(set:isVisible()))
    set:setVisible(true)
    print("visible = " .. tostring(set:isVisible()))
end

--@api: LParallaxSet:isVisible
do
    local set = lurek.parallax.newSet("temp")
    set:setVisible(false)
    print("visible = " .. tostring(set:isVisible()))
end

--@api: LParallaxSet:render
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

--@api: LParallaxSet:renderAuto
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

--@api: LParallaxSet:update
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

--@api: LParallaxLayer:type
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

--@api: LParallaxSet:type
do
    local set = lurek.parallax.newSet("bg_set")
    print(set:type())
end

--@api: LParallaxLayer:getStats
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = img, z = 3, depth = 0.4, tiling = true })
    layer:setAutoscroll(16, 0)
    layer:addEffectPass("tint", { r = 1.0, g = 0.8, b = 0.6, a = 1.0 })
    local stats = layer:getStats()
    print("layer stats tiles=" .. stats.visible_tile_count .. " effects=" .. stats.effect_pass_count)
    print("layer stats z=" .. stats.z .. " depth=" .. stats.depth)
end


--@api: LParallaxSet:getStats
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local set = lurek.parallax.newSet("stats_set")
    set:addLayer(lurek.parallax.newLayer({ texture = img, z = 1, tiling = true }))
    set:addLayer(lurek.parallax.newLayer({ texture = img, z = 5, depth = 0.7 }))
    local stats = set:getStats()
    print("set stats name=" .. stats.name .. " layers=" .. stats.layer_count)
    print("set stats visible tiles=" .. stats.visible_tile_count .. " effects=" .. stats.effect_pass_count)
end

