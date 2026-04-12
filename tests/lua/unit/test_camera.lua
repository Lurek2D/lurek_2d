-- Lurek2D Lua BDD tests for lurek.camera
-- Headless: no GPU, no audio, no window.

-- @description Covers suite: lurek.camera.
describe("lurek.camera", function()
    -- @description Covers suite: module interface.
    describe("module interface", function()
        -- @covers lurek.camera.new
        -- @description Verifies the camera namespace exposes the constructor entry point.
        it("exposes new factory", function()
            expect_type("function", lurek.camera.new)
        end)
    end)

    -- @description Covers suite: new(w, h).
    describe("new(w, h)", function()
        -- @covers lurek.camera.new
        -- @description Verifies constructing a camera with viewport dimensions returns userdata.
        it("returns a userdata object", function()
            local cam = lurek.camera.new(800, 600)
            expect_type("userdata", cam)
        end)
    end)

    -- @description Covers suite: position.
    describe("position", function()
        -- @covers Camera.getPosition
        -- @description Verifies a fresh camera starts at the world origin.
        it("getPosition returns 0,0 by default", function()
            local cam = lurek.camera.new(320, 240)
            local x, y = cam:getPosition()
            expect_near(0.0, x, 0.001)
            expect_near(0.0, y, 0.001)
        end)

        -- @covers Camera.setPosition
        -- @covers Camera.getPosition
        -- @description Verifies explicit camera position updates round-trip through the accessor pair.
        it("setPosition/getPosition round-trip", function()
            local cam = lurek.camera.new(320, 240)
            cam:setPosition(50, 75)
            local x, y = cam:getPosition()
            expect_near(50.0, x, 0.001)
            expect_near(75.0, y, 0.001)
        end)

        -- @covers Camera.lookAt
        -- @covers Camera.getPosition
        -- @description Verifies lookAt snaps the camera center to the requested target coordinates.
        it("lookAt moves the camera to the target", function()
            local cam = lurek.camera.new(320, 240)
            cam:lookAt(100, 200)
            local x, y = cam:getPosition()
            expect_near(100.0, x, 0.001)
            expect_near(200.0, y, 0.001)
        end)

        -- @covers Camera.move
        -- @covers Camera.getPosition
        -- @description Verifies relative movement adds a delta to the current camera position instead of replacing it.
        it("move shifts the position additively", function()
            local cam = lurek.camera.new(320, 240)
            cam:setPosition(10, 20)
            cam:move(5, -5)
            local x, y = cam:getPosition()
            expect_near(15.0, x, 0.001)
            expect_near(15.0, y, 0.001)
        end)
    end)

    -- @description Covers suite: zoom.
    describe("zoom", function()
        -- @covers Camera.getZoom
        -- @description Verifies new cameras start with unit zoom.
        it("getZoom returns 1.0 by default", function()
            local cam = lurek.camera.new(320, 240)
            expect_near(1.0, cam:getZoom(), 0.001)
        end)

        -- @covers Camera.setZoom
        -- @covers Camera.getZoom
        -- @description Verifies zoom values persist through the setter/getter pair.
        it("setZoom/getZoom round-trip", function()
            local cam = lurek.camera.new(320, 240)
            cam:setZoom(2.5)
            expect_near(2.5, cam:getZoom(), 0.001)
        end)
    end)

    -- @description Covers suite: rotation.
    describe("rotation", function()
        -- @covers Camera.getRotation
        -- @description Verifies new cameras start with zero rotation.
        it("getRotation returns 0.0 by default", function()
            local cam = lurek.camera.new(320, 240)
            expect_near(0.0, cam:getRotation(), 0.001)
        end)

        -- @covers Camera.setRotation
        -- @covers Camera.getRotation
        -- @description Verifies rotation values round-trip without normalization surprises for a simple radian input.
        it("setRotation/getRotation round-trip", function()
            local cam = lurek.camera.new(320, 240)
            cam:setRotation(1.57)
            expect_near(1.57, cam:getRotation(), 0.001)
        end)
    end)

    -- @description Covers suite: viewport.
    describe("viewport", function()
        -- @covers Camera.getViewport
        -- @description Verifies the constructor seeds the viewport width and height from the input dimensions.
        it("getViewport returns initial size", function()
            local cam = lurek.camera.new(800, 600)
            local x, y, w, h = cam:getViewport()
            expect_near(800.0, w, 0.001)
            expect_near(600.0, h, 0.001)
        end)

        -- @covers Camera.setViewport
        -- @covers Camera.getViewport
        -- @description Verifies viewport origin and size round-trip together after an explicit update.
        it("setViewport/getViewport round-trip", function()
            local cam = lurek.camera.new(800, 600)
            cam:setViewport(10, 5, 400, 300)
            local x, y, w, h = cam:getViewport()
            expect_near(10.0, x, 0.001)
            expect_near(5.0, y, 0.001)
            expect_near(400.0, w, 0.001)
            expect_near(300.0, h, 0.001)
        end)
    end)

    -- @description Covers suite: coordinate transforms.
    describe("coordinate transforms", function()
        -- @covers Camera.toScreen
        -- @covers Camera.toWorld
        -- @covers Camera.setPosition
        -- @description Verifies world-to-screen and screen-to-world transforms approximately invert each other for the same camera state.
        it("toScreen then toWorld round-trips the position", function()
            local cam = lurek.camera.new(800, 600)
            cam:setPosition(100, 50)
            local sx, sy = cam:toScreen(150, 120)
            local wx, wy = cam:toWorld(sx, sy)
            expect_near(150.0, wx, 0.5)
            expect_near(120.0, wy, 0.5)
        end)
    end)

    -- @description Covers suite: getVisibleArea().
    describe("getVisibleArea()", function()
        -- @covers Camera.getVisibleArea
        -- @description Verifies getVisibleArea returns the expected four-number rectangle shape.
        it("returns four numbers x, y, w, h", function()
            local cam = lurek.camera.new(640, 480)
            local x, y, w, h = cam:getVisibleArea()
            expect_type("number", x)
            expect_type("number", y)
            expect_type("number", w)
            expect_type("number", h)
        end)
    end)

    -- @description Covers suite: shake().
    describe("shake()", function()
        -- @covers Camera.shake
        -- @description Verifies shake accepts a valid amplitude and duration without rejecting the request.
        it("does not error on valid params", function()
            local cam = lurek.camera.new(320, 240)
            cam:shake(5.0, 0.5)
        end)
    end)

    -- @description Covers suite: update().
    describe("update()", function()
        -- @covers Camera.update
        -- @description Verifies update handles a zero-delta frame without requiring accumulated motion state.
        it("does not error when called with zero dt", function()
            local cam = lurek.camera.new(320, 240)
            cam:update(0.0)
        end)
    end)

    -- @description Covers suite: setBounds / removeBounds.
    describe("setBounds / removeBounds", function()
        -- @covers Camera.setBounds
        -- @description Verifies bounds can be applied to the camera without raising validation errors.
        it("setBounds does not error", function()
            local cam = lurek.camera.new(800, 600)
            cam:setBounds(0, 0, 1600, 1200)
        end)

        -- @covers Camera.setBounds
        -- @covers Camera.removeBounds
        -- @description Verifies bounds can be removed after previously enabling them.
        it("removeBounds does not error after setBounds", function()
            local cam = lurek.camera.new(800, 600)
            cam:setBounds(0, 0, 2000, 2000)
            cam:removeBounds()
        end)

        -- @covers Camera.removeBounds
        -- @description Verifies removing bounds is idempotent when no bounds were set.
        it("removeBounds does not error when no bounds are set", function()
            local cam = lurek.camera.new(800, 600)
            cam:removeBounds()
        end)
    end)

    -- @description Covers suite: setTarget / clearTarget.
    describe("setTarget / clearTarget", function()
        -- @covers Camera.setTarget
        -- @description Verifies target-follow coordinates can be assigned without immediate motion.
        it("setTarget does not error", function()
            local cam = lurek.camera.new(320, 240)
            cam:setTarget(100.0, 200.0)
        end)

        -- @covers Camera.setTarget
        -- @covers Camera.clearTarget
        -- @description Verifies an existing follow target can be cleared cleanly.
        it("clearTarget does not error", function()
            local cam = lurek.camera.new(320, 240)
            cam:setTarget(50.0, 75.0)
            cam:clearTarget()
        end)

        -- @covers Camera.clearTarget
        -- @description Verifies clearTarget is safe to call when the camera has no active target.
        it("clearTarget does not error when no target is set", function()
            local cam = lurek.camera.new(320, 240)
            cam:clearTarget()
        end)
    end)

    -- @description Covers suite: setFollowSmooth.
    describe("setFollowSmooth", function()
        -- @covers Camera.setFollowSmooth
        -- @description Verifies positive smoothing speeds are accepted for follow behavior.
        it("does not error for positive speed", function()
            local cam = lurek.camera.new(320, 240)
            cam:setFollowSmooth(5.0)
        end)

        -- @covers Camera.setFollowSmooth
        -- @description Verifies a zero smoothing factor is treated as a valid snap mode.
        it("does not error for speed 0 (snap)", function()
            local cam = lurek.camera.new(320, 240)
            cam:setFollowSmooth(0.0)
        end)
    end)

    -- @description Covers suite: setDeadZone.
    describe("setDeadZone", function()
        -- @covers Camera.setDeadZone
        -- @description Verifies a positive dead-zone rectangle can be configured.
        it("does not error for valid size", function()
            local cam = lurek.camera.new(800, 600)
            cam:setDeadZone(40.0, 30.0)
        end)

        -- @covers Camera.setDeadZone
        -- @description Verifies the dead zone can be disabled by setting both dimensions to zero.
        it("does not error for zero dead zone", function()
            local cam = lurek.camera.new(800, 600)
            cam:setDeadZone(0.0, 0.0)
        end)
    end)

    -- @description Covers suite: setLookAhead.
    describe("setLookAhead", function()
        -- @covers Camera.setLookAhead
        -- @description Verifies look-ahead multipliers accept a normal enabled value.
        it("does not error for multiplier 1.0", function()
            local cam = lurek.camera.new(320, 240)
            cam:setLookAhead(1.0)
        end)

        -- @covers Camera.setLookAhead
        -- @description Verifies look-ahead can be turned off with a zero multiplier.
        it("does not error for multiplier 0.0 (off)", function()
            local cam = lurek.camera.new(320, 240)
            cam:setLookAhead(0.0)
        end)
    end)
end)
test_summary()
