-- Integration: camera position driving parallax layer rendering
-- @integration lurek.camera.new
-- @integration lurek.parallax.newLayer
-- @integration lurek.parallax.newSet
-- @integration lurek.render.newImage


local function load_image()
    return lurek.render.newImage("assets/icon.png")
end

local function expect_cam_xy(cam, x, y, msg)
    local cx, cy = cam:getPosition()
    expect_near(x, cx, 1e-5, msg .. " x")
    expect_near(y, cy, 1e-5, msg .. " y")
end


-- @describe camera + parallax integration
describe("camera + parallax integration", function()
    -- @integration LCamera:getPosition
    -- @integration LCamera:setPosition
    -- @integration LParallaxLayer:isVisible
    -- @integration LParallaxLayer:render
    -- @integration lurek.camera.new
    -- @integration lurek.parallax.newLayer
    it("camera position feeds layer render coordinates", function()
        local cam = lurek.camera.new(800, 600)
        local layer = lurek.parallax.newLayer({ texture = load_image(), scroll_factor_x = 0.5 })

        cam:setPosition(640.0, 360.0)
        expect_cam_xy(cam, 640.0, 360.0, "camera round trip")
        expect_true(layer:isVisible(), "layer starts visible")

        local cx, cy = cam:getPosition()
        layer:render(cx, cy)
    end)

    -- @integration LCamera:getPosition
    -- @integration LCamera:setPosition
    -- @integration LParallaxSet:addLayer
    -- @integration LParallaxSet:isVisible
    -- @integration LParallaxSet:render
    -- @integration lurek.camera.new
    -- @integration lurek.parallax.newLayer
    -- @integration lurek.parallax.newSet
    it("camera position drives multi-layer set render", function()
        local img = load_image()
        local set = lurek.parallax.newSet("bg_auto")
        set:addLayer(lurek.parallax.newLayer({ texture = img, scroll_factor_x = 0.2, z = 0 }))
        set:addLayer(lurek.parallax.newLayer({ texture = img, scroll_factor_x = 0.6, z = 1 }))

        local cam = lurek.camera.new(800, 600)
        cam:setPosition(500.0, 200.0)
        expect_cam_xy(cam, 500.0, 200.0, "camera set position")
        expect_true(set:isVisible(), "parallax set starts visible")

        local cx, cy = cam:getPosition()
        set:render(cx, cy)
    end)

    -- @integration LCamera:getPosition
    -- @integration LCamera:setPosition
    -- @integration LParallaxLayer:render
    -- @integration lurek.camera.new
    -- @integration lurek.parallax.newLayer
    it("multiple layer render calls stay stable while camera moves", function()
        local cam = lurek.camera.new(800, 600)
        local layer = lurek.parallax.newLayer({ texture = load_image(), scroll_factor_x = 0.3 })

        local render_count = 0
        for i = 1, 5 do
            cam:setPosition(i * 120.0, i * 40.0)
            local cx, cy = cam:getPosition()
            layer:render(cx, cy)
            render_count = render_count + 1
        end

        expect_equal(5, render_count, "all camera-driven renders succeed")
        expect_cam_xy(cam, 600.0, 200.0, "camera ends on last swept position")
    end)

    -- @integration LCamera:getPosition
    -- @integration LCamera:setPosition
    -- @integration LParallaxLayer:getOpacity
    -- @integration LParallaxLayer:render
    -- @integration LParallaxLayer:update
    -- @integration lurek.camera.new
    -- @integration lurek.parallax.newLayer
    it("autoscroll update works with changing camera follow position", function()
        local cam = lurek.camera.new(800, 600)
        local layer = lurek.parallax.newLayer({ texture = load_image(), autoscroll_x = 80.0 })

        local dt = 1.0 / 60.0
        local render_count = 0
        for i = 1, 30 do
            layer:update(dt)
            cam:setPosition(i * 10.0, 0.0)
            local cx, cy = cam:getPosition()
            layer:render(cx, cy)
            render_count = render_count + 1
        end

        expect_equal(30, render_count, "all autoscroll renders succeed with camera motion")
        expect_near(1.0, layer:getOpacity(), 0.001, "autoscroll updates keep default opacity")
        expect_cam_xy(cam, 300.0, 0.0, "camera tracks the last follow position")
    end)

    -- @integration LCamera:getPosition
    -- @integration LCamera:setPosition
    -- @integration LParallaxSet:addLayer
    -- @integration LParallaxSet:isVisible
    -- @integration LParallaxSet:render
    -- @integration LParallaxSet:update
    -- @integration lurek.camera.new
    -- @integration lurek.parallax.newLayer
    -- @integration lurek.parallax.newSet
    it("set update and render remain stable during camera sweep", function()
        local img = load_image()
        local set = lurek.parallax.newSet("wind")
        set:addLayer(lurek.parallax.newLayer({ texture = img, autoscroll_x = 20.0, z = 0 }))
        set:addLayer(lurek.parallax.newLayer({ texture = img, autoscroll_x = 50.0, z = 1 }))

        local cam = lurek.camera.new(800, 600)
        local dt = 1.0 / 60.0
        local render_count = 0

        for i = 1, 30 do
            set:update(dt)
            cam:setPosition(i * 8.0, 0.0)
            local cx, cy = cam:getPosition()
            set:render(cx, cy)
            render_count = render_count + 1
        end

        expect_equal(30, render_count, "all set renders succeed during camera sweep")
        expect_true(set:isVisible(), "set remains visible during camera sweep")
        expect_cam_xy(cam, 240.0, 0.0, "camera sweep ends on last position")
    end)

    -- @integration LCamera:getPosition
    -- @integration LCamera:setPosition
    -- @integration LParallaxLayer:getOpacity
    -- @integration LParallaxLayer:render
    -- @integration LParallaxLayer:setOpacity
    -- @integration lurek.camera.new
    -- @integration lurek.parallax.newLayer
    it("opacity crossfade works while camera moves", function()
        local img = load_image()
        local cam = lurek.camera.new(800, 600)
        local day = lurek.parallax.newLayer({ texture = img, opacity = 1.0 })
        local night = lurek.parallax.newLayer({ texture = img, opacity = 0.0 })

        local render_count = 0
        for i = 0, 30 do
            local t = i / 30.0
            day:setOpacity(1.0 - t)
            night:setOpacity(t)
            cam:setPosition(i * 6.0, 0.0)
            local cx, cy = cam:getPosition()

            day:render(cx, cy)
            night:render(cx, cy)
            render_count = render_count + 1
        end

        expect_equal(31, render_count, "all crossfade renders succeed")
        expect_near(0.0, day:getOpacity(), 0.001, "day layer fades out completely")
        expect_near(1.0, night:getOpacity(), 0.001, "night layer fades in completely")
    end)

    -- @integration LCamera:getPosition
    -- @integration LCamera:setPosition
    -- @integration LParallaxSet:addLayer
    -- @integration LParallaxSet:isVisible
    -- @integration LParallaxSet:render
    -- @integration LParallaxSet:setVisible
    -- @integration LParallaxSet:update
    -- @integration lurek.camera.new
    -- @integration lurek.parallax.newLayer
    -- @integration lurek.parallax.newSet
    it("visibility transition preserves camera-driven rendering", function()
        local img = load_image()
        local set = lurek.parallax.newSet("level1_bg")
        set:addLayer(lurek.parallax.newLayer({ texture = img, scroll_factor_x = 0.2, autoscroll_x = 15.0, z = 0 }))
        set:addLayer(lurek.parallax.newLayer({ texture = img, scroll_factor_x = 0.6, autoscroll_x = 40.0, z = 1 }))

        local cam = lurek.camera.new(800, 600)
        local dt = 1.0 / 60.0

        for i = 1, 20 do
            set:update(dt)
            cam:setPosition(i * 12.0, 0.0)
            local cx, cy = cam:getPosition()
            set:render(cx, cy)
        end

        set:setVisible(false)
        expect_false(set:isVisible(), "set can be hidden after camera-driven updates")
        set:update(dt)
        set:setVisible(true)
        expect_true(set:isVisible(), "set can be shown again before render")

        cam:setPosition(0.0, 0.0)
        local cx, cy = cam:getPosition()
        set:render(cx, cy)
    end)
end)
test_summary()
