-- Lurek2D Parallax API unit tests
-- One owner test per public parallax symbol.

local function load_image()
    return lurek.render.newImage("assets/icon.png")
end

local function make_layer(opts)
    local config = { texture = load_image() }
    if opts ~= nil then
        for k, v in pairs(opts) do
            config[k] = v
        end
    end
    return lurek.parallax.newLayer(config)
end

local function make_set(name)
    return lurek.parallax.newSet(name or "scene")
end

-- @describe lurek.parallax
describe("lurek.parallax", function()
    -- @covers lurek.parallax.newLayer
    it("creates a layer from a texture-backed options table", function()
        local layer = make_layer({
            scroll_factor_x = 0.3,
            scroll_factor_y = 0.1,
            offset_x = 50.0,
            offset_y = 20.0,
            opacity = 0.5,
            z = -5,
            blend_mode = "additive",
            visible = false,
        })
        expect_type("userdata", layer)
        local sx, sy = layer:getScrollFactor()
        local ox, oy = layer:getOffset()
        expect_near(0.3, sx, 0.001)
        expect_near(0.1, sy, 0.001)
        expect_near(50.0, ox, 0.001)
        expect_near(20.0, oy, 0.001)
        expect_near(0.5, layer:getOpacity(), 0.001)
        expect_equal(-5, layer:getZ())
        expect_equal("additive", layer:getBlendMode())
        expect_false(layer:isVisible())
    end)

    -- @covers LParallaxLayer:type
    it("reports the parallax layer type name", function()
        expect_equal("LParallaxLayer", make_layer():type())
    end)

    -- @covers LParallaxLayer:getScrollFactor
    it("returns default scroll factor values", function()
        local x, y = make_layer():getScrollFactor()
        expect_near(1.0, x, 0.001)
        expect_near(0.0, y, 0.001)
    end)

    -- @covers LParallaxLayer:getOffset
    it("returns default offsets", function()
        local x, y = make_layer():getOffset()
        expect_near(0.0, x, 0.001)
        expect_near(0.0, y, 0.001)
    end)

    -- @covers LParallaxLayer:getOpacity
    it("returns full opacity by default", function()
        expect_near(1.0, make_layer():getOpacity(), 0.001)
    end)

    -- @covers LParallaxLayer:getZ
    it("returns zero z by default", function()
        expect_equal(0, make_layer():getZ())
    end)

    -- @covers LParallaxLayer:getBlendMode
    it("returns normal blend mode by default", function()
        expect_equal("normal", make_layer():getBlendMode())
    end)

    -- @covers LParallaxLayer:isVisible
    it("returns true by default", function()
        expect_true(make_layer():isVisible())
    end)

    -- @covers LParallaxLayer:getAutoscroll
    it("returns zero autoscroll by default", function()
        local vx, vy = make_layer():getAutoscroll()
        expect_near(0.0, vx, 0.001)
        expect_near(0.0, vy, 0.001)
    end)

    -- @covers LParallaxLayer:setScrollFactor
    it("updates the layer scroll factor", function()
        local layer = make_layer()
        layer:setScrollFactor(0.25, 0.75)
        local x, y = layer:getScrollFactor()
        expect_near(0.25, x, 0.001)
        expect_near(0.75, y, 0.001)
    end)

    -- @covers LParallaxLayer:setOffset
    it("updates the layer offset", function()
        local layer = make_layer()
        layer:setOffset(100.0, -50.0)
        local x, y = layer:getOffset()
        expect_near(100.0, x, 0.001)
        expect_near(-50.0, y, 0.001)
    end)

    -- @covers LParallaxLayer:setAutoscroll
    it("updates the layer autoscroll velocity", function()
        local layer = make_layer()
        layer:setAutoscroll(30.0, -10.0)
        local vx, vy = layer:getAutoscroll()
        expect_near(30.0, vx, 0.001)
        expect_near(-10.0, vy, 0.001)
    end)

    -- @covers LParallaxLayer:setZ
    it("updates the z ordering value", function()
        local layer = make_layer()
        layer:setZ(10)
        expect_equal(10, layer:getZ())
    end)

    -- @covers LParallaxLayer:setOpacity
    it("round-trips and clamps opacity", function()
        local layer = make_layer()
        layer:setOpacity(0.4)
        expect_near(0.4, layer:getOpacity(), 0.001)
        layer:setOpacity(2.0)
        expect_near(1.0, layer:getOpacity(), 0.001)
        layer:setOpacity(-1.0)
        expect_near(0.0, layer:getOpacity(), 0.001)
    end)

    -- @covers LParallaxLayer:setTint
    it("updates the layer tint", function()
        local layer = make_layer()
        layer:setTint(0.5, 0.3, 0.8, 0.7)
        local r, g, b, a = layer:getTint()
        expect_near(0.5, r, 0.001)
        expect_near(0.3, g, 0.001)
        expect_near(0.8, b, 0.001)
        expect_near(0.7, a, 0.001)
    end)

    -- @covers LParallaxLayer:setBlendMode
    it("accepts supported blend modes and aliases", function()
        local layer = make_layer()
        for _, mode in ipairs({ "normal", "additive", "multiply", "replace", "screen" }) do
            layer:setBlendMode(mode)
            expect_equal(mode, layer:getBlendMode())
        end
        layer:setBlendMode("alpha")
        expect_equal("normal", layer:getBlendMode())
        layer:setBlendMode("add")
        expect_equal("additive", layer:getBlendMode())
        expect_error(function()
            layer:setBlendMode("bogus")
        end)
    end)

    -- @covers LParallaxLayer:setVisible
    it("toggles layer visibility", function()
        local layer = make_layer()
        layer:setVisible(false)
        expect_false(layer:isVisible())
        layer:setVisible(true)
        expect_true(layer:isVisible())
    end)

    -- @covers LParallaxLayer:update
    it("updates autoscroll state without error", function()
        local layer = make_layer({ autoscroll_x = 60.0, autoscroll_y = -20.0 })
        expect_no_error(function()
            layer:update(1.0 / 60.0)
        end)
    end)

    -- @covers LParallaxLayer:resetAutoscroll
    it("resets autoscroll after accumulated updates", function()
        local layer = make_layer({ autoscroll_x = 80.0 })
        layer:update(5.0)
        expect_no_error(function()
            layer:resetAutoscroll()
        end)
    end)

    -- @covers LParallaxLayer:render
    it("renders safely with visibility and clamp changes", function()
        local layer = make_layer({ scroll_factor_x = 0.5, visible = false })
        layer:setClamp(-50, -50, 50, 50)
        expect_no_error(function()
            layer:render(1200, 800)
        end)
    end)

    -- @covers LParallaxLayer:renderAuto
    it("auto-renders without error", function()
        expect_no_error(function()
            make_layer():renderAuto()
        end)
    end)

    -- @covers LParallaxLayer:setClamp
    it("accepts clamp bounds", function()
        local layer = make_layer()
        expect_no_error(function()
            layer:setClamp(-200, -100, 200, 100)
        end)
    end)

    -- @covers LParallaxLayer:clearClamp
    it("clears clamp bounds after they are set", function()
        local layer = make_layer()
        layer:setClamp(-100, -100, 100, 100)
        expect_no_error(function()
            layer:clearClamp()
        end)
    end)

    -- @covers lurek.parallax.newSet
    it("creates an empty named set", function()
        local set = make_set("background")
        expect_type("userdata", set)
        expect_equal("background", set:getName())
        expect_equal(0, set:layerCount())
    end)

    -- @covers LParallaxSet:type
    it("reports the parallax set type name", function()
        expect_equal("LParallaxSet", make_set():type())
    end)

    -- @covers LParallaxSet:layerCount
    it("tracks the number of layers in the set", function()
        local set = make_set()
        set:addLayer(make_layer())
        set:addLayer(make_layer())
        expect_equal(2, set:layerCount())
    end)

    -- @covers LParallaxSet:getName
    it("returns the current set name", function()
        expect_equal("scene", make_set("scene"):getName())
    end)

    -- @covers LParallaxSet:setName
    it("updates the set name", function()
        local set = make_set("old")
        set:setName("new")
        expect_equal("new", set:getName())
    end)

    -- @covers LParallaxSet:isVisible
    it("is visible by default", function()
        expect_true(make_set():isVisible())
    end)

    -- @covers LParallaxSet:setVisible
    it("toggles set visibility", function()
        local set = make_set()
        set:setVisible(false)
        expect_false(set:isVisible())
        set:setVisible(true)
        expect_true(set:isVisible())
    end)

    -- @covers LParallaxSet:addLayer
    it("adds layers to the set", function()
        local set = make_set()
        set:addLayer(make_layer())
        expect_equal(1, set:layerCount())
    end)

    -- @covers LParallaxSet:removeLayerAt
    it("removes valid layer indices and rejects invalid ones", function()
        local set = make_set()
        set:addLayer(make_layer())
        expect_true(set:removeLayerAt(1))
        expect_equal(0, set:layerCount())
        expect_false(set:removeLayerAt(99))
    end)

    -- @covers LParallaxSet:sortByZ
    it("sorts layers by z order", function()
        local set = make_set()
        set:addLayer(make_layer({ z = 10 }))
        set:addLayer(make_layer({ z = -3 }))
        set:addLayer(make_layer({ z = 5 }))
        set:sortByZ()
        expect_equal(-3, set:getLayerZAt(1))
        expect_equal(5, set:getLayerZAt(2))
        expect_equal(10, set:getLayerZAt(3))
    end)

    -- @covers LParallaxSet:render
    it("renders safely with multiple layers", function()
        local set = make_set()
        set:addLayer(make_layer({ z = 0 }))
        set:addLayer(make_layer({ z = 1 }))
        expect_no_error(function()
            set:render(300, 200)
        end)
    end)

    -- @covers LParallaxSet:renderAuto
    it("auto-renders safely", function()
        local set = make_set()
        set:addLayer(make_layer())
        expect_no_error(function()
            set:renderAuto()
        end)
    end)

    -- @covers LParallaxSet:update
    it("updates all layers without error", function()
        local set = make_set()
        set:addLayer(make_layer({ autoscroll_x = 50.0 }))
        expect_no_error(function()
            set:update(1.0 / 60.0)
        end)
    end)

    -- @covers LParallaxSet:getLayerZAt
    it("returns nil for out-of-range layer indices", function()
        local set = make_set()
        expect_nil(set:getLayerZAt(1))
    end)

    -- @covers LParallaxLayer:addEffectPass
    it("adds effect passes to the layer", function()
        local layer = make_layer()
        layer:addEffectPass("blur", { radius = 2.0 })
        expect_equal(1, layer:effectCount())
    end)

    -- @covers LParallaxLayer:effectCount
    it("starts with zero effect passes", function()
        expect_equal(0, make_layer():effectCount())
    end)

    -- @covers LParallaxLayer:clearEffects
    it("removes configured effect passes", function()
        local layer = make_layer()
        layer:addEffectPass("blur", { radius = 2.0 })
        layer:clearEffects()
        expect_equal(0, layer:effectCount())
    end)

    -- @covers LParallaxLayer:setMotionStretch
    it("updates motion stretch configuration", function()
        local layer = make_layer()
        layer:setMotionStretch(true, 0.0025, 1.7)
        local enabled, strength, max_scale = layer:getMotionStretch()
        expect_true(enabled)
        expect_near(0.0025, strength, 0.0001)
        expect_near(1.7, max_scale, 0.0001)
    end)

    -- @covers LParallaxLayer:getMotionStretch
    it("returns motion stretch defaults as a tuple", function()
        local enabled, strength, max_scale = make_layer():getMotionStretch()
        expect_type("boolean", enabled)
        expect_type("number", strength)
        expect_type("number", max_scale)
    end)

    -- @covers lurek.parallax.newPresetLayer
    it("creates known presets and rejects unknown ones", function()
        local img = load_image()
        expect_equal("LParallaxLayer", lurek.parallax.newPresetLayer("far", img):type())
        expect_equal("LParallaxLayer", lurek.parallax.newPresetLayer("mid", img):type())
        expect_equal("LParallaxLayer", lurek.parallax.newPresetLayer("fog", img):type())
        expect_error(function()
            lurek.parallax.newPresetLayer("unknown", img)
        end)
    end)

    -- @covers LParallaxLayer:getDepth
    it("returns zero depth by default", function()
        expect_near(0.0, make_layer():getDepth(), 0.001)
    end)

    -- @covers LParallaxLayer:setDepth
    it("updates depth independently from integer z", function()
        local layer = make_layer()
        layer:setZ(5)
        layer:setDepth(2.5)
        expect_equal(5, layer:getZ())
        expect_near(2.5, layer:getDepth(), 0.001)
    end)

    -- @covers LParallaxLayer:getTiling
    it("returns tiling disabled by default", function()
        expect_false(make_layer():getTiling())
    end)

    -- @covers LParallaxLayer:setTiling
    it("toggles tiling state", function()
        local layer = make_layer()
        layer:setTiling(true)
        expect_true(layer:getTiling())
        layer:setTiling(false)
        expect_false(layer:getTiling())
    end)

    -- @covers LParallaxLayer:setTileSize
    it("accepts tile size changes", function()
        local layer = make_layer()
        expect_no_error(function()
            layer:setTileSize(128.0, 64.0)
            layer:setTileSize(0.0, 64.0)
        end)
    end)

    -- @covers LParallaxLayer:setRepeat
    it("accepts repeat flags", function()
        local layer = make_layer()
        expect_no_error(function()
            layer:setRepeat(true, true)
        end)
    end)

    -- @covers LParallaxLayer:setScale
    it("accepts scaling factors", function()
        local layer = make_layer()
        expect_no_error(function()
            layer:setScale(1.5, 1.5)
        end)
    end)
end)

test_summary()
