-- content/examples/parallax.lua
-- Auto-generated from content/examples2/parallax_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/parallax.lua

--- Parallax Module Part 1: layer creation, scroll, visibility, tiling, depth


--@api: lurek.parallax.newLayer
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    example_print_log("type = " .. layer:type())
    example_print_log("scroll = " .. sx .. "," .. sy)
    example_print_log("z = " .. layer:getZ())
end

--@api: lurek.parallax.newPresetLayer
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local far = lurek.parallax.newPresetLayer("far", img)
    local mid = lurek.parallax.newPresetLayer("mid", img)
    example_print_log("far depth = " .. far:getDepth())
    example_print_log("mid z = " .. mid:getZ())
end

--@api: LParallaxLayer:setScrollFactor
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setScrollFactor(0.5, 0.2)
    local sx, sy = layer:getScrollFactor()
    example_print_log("scroll = " .. sx .. "," .. sy)
end

--@api: LParallaxLayer:getScrollFactor
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        scroll_factor_x = 0.75,
        scroll_factor_y = 0.15,
    })
    local sx, sy = layer:getScrollFactor()
    example_print_log("scroll = " .. sx .. "," .. sy)
end

--@api: LParallaxLayer:setOffset
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setOffset(10, -5)
    local ox, oy = layer:getOffset()
    example_print_log("offset = " .. ox .. "," .. oy)
end

--@api: LParallaxLayer:getOffset
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        offset_x = 24,
        offset_y = -8,
    })
    local ox, oy = layer:getOffset()
    example_print_log("offset = " .. ox .. "," .. oy)
end

--@api: LParallaxLayer:setDepth
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    example_print_log("depth before = " .. layer:getDepth())
    layer:setDepth(0.5)
    example_print_log("depth = " .. layer:getDepth())
    layer:setZ(layer:getZ() + 1)
end

--@api: LParallaxLayer:getDepth
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        depth = 0.8,
    })
    example_print_log("depth = " .. layer:getDepth())
end

--@api: LParallaxLayer:setZ
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    example_print_log("z before = " .. layer:getZ())
    layer:setZ(-5)
    example_print_log("z = " .. layer:getZ())
    layer:render(0, 0)
end

--@api: LParallaxLayer:getZ
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        z = -5,
    })
    example_print_log("z = " .. layer:getZ())
end

--@api: LParallaxLayer:setVisible
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setVisible(false)
    example_print_log("visible = " .. tostring(layer:isVisible()))
    layer:setVisible(true)
    example_print_log("visible = " .. tostring(layer:isVisible()))
end

--@api: LParallaxLayer:isVisible
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        visible = false,
    })
    example_print_log("visible = " .. tostring(layer:isVisible()))
end

--@api: LParallaxLayer:setOpacity
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    example_print_log("opacity before = " .. layer:getOpacity())
    layer:setOpacity(0.7)
    example_print_log("opacity = " .. layer:getOpacity())
    layer:render(0, 0)
end

--@api: LParallaxLayer:getOpacity
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        opacity = 0.35,
    })
    example_print_log("opacity = " .. layer:getOpacity())
end

--@api: LParallaxLayer:setTiling
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    example_print_log("tiling before = " .. tostring(layer:getTiling()))
    layer:setTiling(true)
    example_print_log("tiling = " .. tostring(layer:getTiling()))
    layer:render(0, 0)
end

--@api: LParallaxLayer:getTiling
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        tiling = true,
    })
    example_print_log("tiling = " .. tostring(layer:getTiling()))
end

--@api: LParallaxLayer:setTileSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        tiling = true,
    })
    layer:setTileSize(64, 64)
    layer:render(0, 0)
    example_print_log("tile size set to 64x64")
    example_print_log("rendered tiled layer")
end

--@api: LParallaxLayer:setRepeat
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setRepeat(true, false)
    layer:render(32, 16)
    example_print_log("repeat set: horizontal only")
    example_print_log("z = " .. layer:getZ())
end

--@api: LParallaxLayer:setScale
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setScale(2.0, 2.0)
    layer:render(0, 0)
    example_print_log("scaled 2x")
    example_print_log("type = " .. layer:type())
end

--@api: LParallaxLayer:setTint
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setTint(1.0, 0.8, 0.6, 1.0)
    local r, g, b, a = layer:getTint()
    example_print_log("tint = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LParallaxLayer:getTint
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        tint_r = 0.6,
        tint_g = 0.8,
        tint_b = 1.0,
        tint_a = 0.75,
    })
    local r, g, b, a = layer:getTint()
    example_print_log("tint = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LParallaxLayer:setBlendMode
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setBlendMode("add")
    example_print_log("blend = " .. layer:getBlendMode())
    layer:setBlendMode("alpha")
    example_print_log("blend = " .. layer:getBlendMode())
end

--@api: LParallaxLayer:getBlendMode
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        blend_mode = "screen",
    })
    example_print_log("blend = " .. layer:getBlendMode())
end

--@api: LParallaxLayer:setClamp
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setClamp(-100, -50, 100, 50)
    example_print_log("clamped")
    layer:clearClamp()
    example_print_log("clamp cleared")
end

--@api: LParallaxLayer:clearClamp
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setClamp(-100, -50, 100, 50)
    example_print_log("clamped")
    layer:clearClamp()
    example_print_log("clamp cleared")
end

--- Parallax Module Part 2: autoscroll, motion stretch, effects, sets, rendering

--@api: LParallaxLayer:setAutoscroll
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setAutoscroll(20, 0)
    local vx, vy = layer:getAutoscroll()
    example_print_log("autoscroll = " .. vx .. "," .. vy)
    layer:update(1.0)
    layer:resetAutoscroll()
    example_print_log("autoscroll reset")
end

--@api: LParallaxLayer:getAutoscroll
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        autoscroll_x = 12,
        autoscroll_y = -4,
    })
    local vx, vy = layer:getAutoscroll()
    example_print_log("autoscroll = " .. vx .. "," .. vy)
end

--@api: LParallaxLayer:resetAutoscroll
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setAutoscroll(20, 0)
    layer:update(1.0)
    layer:resetAutoscroll()
    local vx, vy = layer:getAutoscroll()
    example_print_log("velocity still = " .. vx .. "," .. vy)
    example_print_log("autoscroll reset")
end

--@api: LParallaxLayer:setMotionStretch
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setMotionStretch(true, 0.5, 2.0)
    local enabled, strength, max_scale = layer:getMotionStretch()
    example_print_log("stretch enabled=" .. tostring(enabled) .. " strength=" .. strength .. " max=" .. max_scale)
end

--@api: LParallaxLayer:getMotionStretch
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = image,
        motion_stretch = true,
        motion_stretch_strength = 0.5,
        motion_stretch_max = 2.0,
    })
    local enabled, strength, max_scale = layer:getMotionStretch()
    example_print_log("stretch enabled=" .. tostring(enabled) .. " strength=" .. strength .. " max=" .. max_scale)
end

--@api: LParallaxLayer:addEffectPass
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:addEffectPass("blur", { radius = 1.5 })
    layer:addEffectPass("tint", { r = 1.0, g = 0.8, b = 0.6, a = 1.0 })
    example_print_log("effects = " .. layer:effectCount())
    layer:clearEffects()
    example_print_log("after clear = " .. layer:effectCount())
end

--@api: LParallaxLayer:effectCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:addEffectPass("blur", { radius = 1.5 })
    layer:addEffectPass("tint", { r = 1.0, g = 0.8, b = 0.6, a = 1.0 })
    example_print_log("effects = " .. layer:effectCount())
    layer:clearEffects()
    example_print_log("after clear = " .. layer:effectCount())
end

--@api: LParallaxLayer:clearEffects
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:addEffectPass("blur", { radius = 1.5 })
    layer:addEffectPass("tint", { r = 1.0, g = 0.8, b = 0.6, a = 1.0 })
    example_print_log("effects = " .. layer:effectCount())
    layer:clearEffects()
    example_print_log("after clear = " .. layer:effectCount())
end

--@api: LParallaxLayer:render
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setAutoscroll(50, 0)
    layer:update(0.016)
    layer:render(100, 50)
    layer:renderAuto()
    example_print_log("rendered")
end

--@api: LParallaxLayer:renderAuto
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setAutoscroll(50, 0)
    layer:update(0.016)
    layer:render(100, 50)
    layer:renderAuto()
    example_print_log("rendered")
end

--@api: LParallaxLayer:update
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local image = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = image })
    layer:setAutoscroll(50, 0)
    layer:update(0.016)
    layer:render(100, 50)
    layer:renderAuto()
    example_print_log("rendered")
end

--@api: lurek.parallax.newSet
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local set = lurek.parallax.newSet("background")
    local layer = lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 0,
    })
    set:addLayer(layer)
    example_print_log("name = " .. set:getName() .. " type = " .. set:type())
    example_print_log("layers = " .. set:layerCount())
end

--@api: LParallaxSet:addLayer
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    example_print_log("layers = " .. set:layerCount())
    example_print_log("removed = " .. tostring(set:removeLayerAt(2)) .. " layers = " .. set:layerCount())
end

--@api: LParallaxSet:layerCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    example_print_log("layers = " .. set:layerCount())
    example_print_log("removed = " .. tostring(set:removeLayerAt(2)) .. " layers = " .. set:layerCount())
end

--@api: LParallaxSet:removeLayerAt
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    example_print_log("layers = " .. set:layerCount())
    example_print_log("removed = " .. tostring(set:removeLayerAt(2)) .. " layers = " .. set:layerCount())
end

--@api: LParallaxSet:getLayerZAt
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local set = lurek.parallax.newSet("sorted")
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 100,
    }))
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 1,
    }))
    example_print_log("z at 1 = " .. tostring(set:getLayerZAt(1)))
    example_print_log("z at 2 = " .. tostring(set:getLayerZAt(2)))
    set:sortByZ()
    example_print_log("sorted: z at 1 = " .. tostring(set:getLayerZAt(1)))
end

--@api: LParallaxSet:sortByZ
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local set = lurek.parallax.newSet("sorted")
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 100,
    }))
    set:addLayer(lurek.parallax.newLayer({
        texture = lurek.render.newImage("content/examples/assets/images/sample_texture.png"),
        z = 1,
    }))
    example_print_log("before sort z1 = " .. tostring(set:getLayerZAt(1)))
    example_print_log("before sort z2 = " .. tostring(set:getLayerZAt(2)))
    set:sortByZ()
    example_print_log("sorted: z at 1 = " .. tostring(set:getLayerZAt(1)))
end

--@api: LParallaxSet:setName
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local set = lurek.parallax.newSet("temp")
    set:setName("sky_layers")
    example_print_log("name = " .. set:getName())
    set:setVisible(false)
    example_print_log("visible = " .. tostring(set:isVisible()))
    set:setVisible(true)
    example_print_log("visible = " .. tostring(set:isVisible()))
end

--@api: LParallaxSet:getName
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local set = lurek.parallax.newSet("temp")
    example_print_log("initial name = " .. set:getName())
    set:setName("sky_layers")
    example_print_log("name = " .. set:getName())
    set:setVisible(true)
    example_print_log("visible = " .. tostring(set:isVisible()))
end

--@api: LParallaxSet:setVisible
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local set = lurek.parallax.newSet("temp")
    set:setName("sky_layers")
    example_print_log("name = " .. set:getName())
    set:setVisible(false)
    example_print_log("visible = " .. tostring(set:isVisible()))
    set:setVisible(true)
    example_print_log("visible = " .. tostring(set:isVisible()))
end

--@api: LParallaxSet:isVisible
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local set = lurek.parallax.newSet("temp")
    example_print_log("visible before = " .. tostring(set:isVisible()))
    set:setVisible(false)
    example_print_log("visible = " .. tostring(set:isVisible()))
    set:setVisible(true)
    example_print_log("visible after restore = " .. tostring(set:isVisible()))
end

--@api: LParallaxSet:render
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    example_print_log("set rendered")
end

--@api: LParallaxSet:renderAuto
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    example_print_log("set rendered")
end

--@api: LParallaxSet:update
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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
    example_print_log("set rendered")
end

--- Parallax Module Part 2: layer type, set type

--@api: LParallaxLayer:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({
        texture = img,
        scroll_factor_x = 0.5,
        scroll_factor_y = 0.2,
        z = -1,
    })
    example_print_log(layer:type())
end

--@api: LParallaxSet:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local set = lurek.parallax.newSet("bg_set")
    local type_name = set:type()
    set:setVisible(true)
    example_print_log("set type = " .. type_name)
    example_print_log("set name = " .. set:getName())
    example_print_log("layers = " .. set:layerCount())
end

--@api: LParallaxLayer:getStats
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = img, z = 3, depth = 0.4, tiling = true })
    layer:setAutoscroll(16, 0)
    layer:addEffectPass("tint", { r = 1.0, g = 0.8, b = 0.6, a = 1.0 })
    local stats = layer:getStats()
    example_print_log("layer stats tiles=" .. stats.visible_tile_count .. " effects=" .. stats.effect_pass_count)
    example_print_log("layer stats z=" .. stats.z .. " depth=" .. stats.depth)
end


--@api: LParallaxSet:getStats
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local set = lurek.parallax.newSet("stats_set")
    set:addLayer(lurek.parallax.newLayer({ texture = img, z = 1, tiling = true }))
    set:addLayer(lurek.parallax.newLayer({ texture = img, z = 5, depth = 0.7 }))
    local stats = set:getStats()
    example_print_log("set stats name=" .. stats.name .. " layers=" .. stats.layer_count)
    example_print_log("set stats visible tiles=" .. stats.visible_tile_count .. " effects=" .. stats.effect_pass_count)
end

--@api: LParallaxLayer:setShader
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = img, z = -10, tiling = true })
    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.r, color.g * (0.6 + uv.y * 0.4), color.b, color.a);
}
]], { target = "draw" })
    layer:setShader(shader)
    layer:render(0, 0)
    layer:setShader(nil)
end

--@api: LParallaxLayer:getShader
do
    local img = lurek.render.newImage("content/examples/assets/images/sample_texture.png")
    local layer = lurek.parallax.newLayer({ texture = img, opacity = 0.8 })
    local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb * vec3<f32>(0.85, 0.95, 1.0), color.a);
}
]], { target = "draw" })
    layer:setShader(shader)
    local active = layer:getShader()
    lurek.log.info("parallax shader id = " .. tostring(active and active:getId()))
end

