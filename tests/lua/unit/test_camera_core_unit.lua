-- Lurek2D camera API unit tests
-- One owner test per public camera symbol used by the core suite.

local function new_camera()
    return lurek.camera.new(320, 240)
end

local function new_rig()
    return lurek.camera.newRig()
end

-- @describe lurek.camera
describe("lurek.camera", function()
    -- @covers lurek.camera.new
    it("creates a camera with default position and zoom", function()
        local cam = new_camera()
        expect_type("userdata", cam)
        local x, y = cam:getPosition()
        expect_near(0.0, x, 0.001)
        expect_near(0.0, y, 0.001)
        expect_near(1.0, cam:getZoom(), 0.001)
    end)

    -- @covers LCamera:getPosition
    it("returns the current camera position", function()
        local cam = new_camera()
        cam:setPosition(12, 34)
        local x, y = cam:getPosition()
        expect_near(12, x, 0.001)
        expect_near(34, y, 0.001)
    end)

    -- @covers LCamera:setPosition
    it("updates the camera position", function()
        local cam = new_camera()
        cam:setPosition(10, 20)
        local x, y = cam:getPosition()
        expect_near(10, x, 0.001)
        expect_near(20, y, 0.001)
    end)

    -- @covers LCamera:lookAt
    it("repositions the camera to look at a point", function()
        local cam = new_camera()
        cam:lookAt(50, 60)
        local x, y = cam:getPosition()
        expect_type("number", x)
        expect_type("number", y)
    end)

    -- @covers LCamera:move
    it("applies relative movement offsets", function()
        local cam = new_camera()
        cam:setPosition(5, 6)
        cam:move(3, 4)
        local x, y = cam:getPosition()
        expect_near(8, x, 0.001)
        expect_near(10, y, 0.001)
    end)

    -- @covers LCamera:getZoom
    it("returns the current zoom factor", function()
        local cam = new_camera()
        cam:setZoom(2.5)
        expect_near(2.5, cam:getZoom(), 0.001)
    end)

    -- @covers LCamera:setZoom
    it("updates the base zoom factor", function()
        local cam = new_camera()
        cam:setZoom(1.75)
        expect_near(1.75, cam:getZoom(), 0.001)
    end)

    -- @covers LCamera:getRotation
    it("returns the current rotation", function()
        local cam = new_camera()
        cam:setRotation(0.5)
        expect_near(0.5, cam:getRotation(), 0.001)
    end)

    -- @covers LCamera:setRotation
    it("updates the camera rotation", function()
        local cam = new_camera()
        cam:setRotation(1.2)
        expect_near(1.2, cam:getRotation(), 0.001)
    end)

    -- @covers LCamera:getViewport
    it("returns the current viewport rectangle", function()
        local cam = new_camera()
        local x, y, w, h = cam:getViewport()
        expect_type("number", x)
        expect_type("number", y)
        expect_type("number", w)
        expect_type("number", h)
    end)

    -- @covers LCamera:setViewport
    it("updates the viewport rectangle", function()
        local cam = new_camera()
        cam:setViewport(1, 2, 640, 480)
        local x, y, w, h = cam:getViewport()
        expect_near(1, x, 0.001)
        expect_near(2, y, 0.001)
        expect_near(640, w, 0.001)
        expect_near(480, h, 0.001)
    end)

    -- @covers LCamera:toWorld
    it("converts screen coordinates to world coordinates", function()
        local cam = new_camera()
        local x, y = cam:toWorld(160, 120)
        expect_type("number", x)
        expect_type("number", y)
    end)

    -- @covers LCamera:getVisibleArea
    it("returns a visible area rectangle", function()
        local cam = new_camera()
        local x, y, w, h = cam:getVisibleArea()
        expect_type("number", x)
        expect_type("number", y)
        expect_type("number", w)
        expect_type("number", h)
    end)

    -- @covers LCamera:shake
    it("starts a shake effect that changes offset after update", function()
        local cam = new_camera()
        cam:shake(5.0, 0.4)
        cam:update(0.1)
        local sx, sy = cam:getShakeOffset()
        expect_type("number", sx)
        expect_type("number", sy)
    end)

    -- @covers LCamera:update
    it("applies effect updates and bounds clamping", function()
        local cam = new_camera()
        cam:setBounds(0, 0, 100, 100)
        cam:setPosition(999, 999)
        cam:update(0.016)
        local x, y = cam:getPosition()
        expect_true(x <= 100 and y <= 100)
    end)

    -- @covers LCamera:setBounds
    it("stores camera bounds", function()
        local cam = new_camera()
        cam:setBounds(1, 2, 3, 4)
        local ok, x, y, w, h = cam:getBounds()
        expect_true(ok)
        expect_near(1, x, 0.001)
        expect_near(2, y, 0.001)
        expect_near(3, w, 0.001)
        expect_near(4, h, 0.001)
    end)

    -- @covers LCamera:removeBounds
    it("clears previously set bounds", function()
        local cam = new_camera()
        cam:setBounds(1, 2, 3, 4)
        cam:removeBounds()
        expect_false(cam:hasBounds())
    end)

    -- @covers LCamera:setTarget
    it("stores a follow target", function()
        local cam = new_camera()
        cam:setTarget(11, 22)
        local ok, x, y = cam:getTarget()
        expect_true(ok)
        expect_near(11, x, 0.001)
        expect_near(22, y, 0.001)
    end)

    -- @covers LCamera:clearTarget
    it("clears the follow target", function()
        local cam = new_camera()
        cam:setTarget(11, 22)
        cam:clearTarget()
        expect_false(cam:getTarget())
    end)

    -- @covers LCamera:setFollowSmooth
    it("updates follow smoothing", function()
        local cam = new_camera()
        cam:setFollowSmooth(3.5)
        expect_near(3.5, cam:getFollowSmooth(), 0.001)
    end)

    -- @covers LCamera:setDeadZone
    it("stores a dead-zone rectangle", function()
        local cam = new_camera()
        cam:setDeadZone(50, 30)
        local ok, w, h = cam:getDeadZone()
        expect_true(ok)
        expect_near(50, w, 0.001)
        expect_near(30, h, 0.001)
    end)

    -- @covers LCamera:setLookAhead
    it("updates look-ahead multiplier", function()
        local cam = new_camera()
        cam:setLookAhead(0.75)
        expect_near(0.75, cam:getLookAhead(), 0.001)
    end)

    -- @covers LCamera:zoomPulse
    it("temporarily modifies effective zoom", function()
        local cam = new_camera()
        cam:setZoom(1.0)
        cam:zoomPulse(0.5, 0.5)
        cam:update(0.1)
        expect_true(cam:getEffectiveZoom() >= 1.0)
    end)

    -- @covers LCamera:startSway
    it("starts sway and marks the camera as swaying", function()
        local cam = new_camera()
        cam:startSway(2.0, 1.0, 3.0, 0.0)
        expect_true(cam:isSway())
    end)

    -- @covers LCamera:stopSway
    it("stops sway", function()
        local cam = new_camera()
        cam:startSway(2.0, 1.0, 3.0, 0.0)
        cam:stopSway()
        expect_false(cam:isSway())
    end)

    -- @covers LCamera:isSway
    it("reports sway state", function()
        expect_false(new_camera():isSway())
    end)

    -- @covers LCamera:startBreathing
    it("starts breathing zoom modulation", function()
        local cam = new_camera()
        cam:startBreathing(0.2, 1.0)
        expect_true(cam:isBreathing())
    end)

    -- @covers LCamera:stopBreathing
    it("stops breathing modulation", function()
        local cam = new_camera()
        cam:startBreathing(0.2, 1.0)
        cam:stopBreathing()
        expect_false(cam:isBreathing())
    end)

    -- @covers LCamera:isBreathing
    it("reports breathing state", function()
        expect_false(new_camera():isBreathing())
    end)

    -- @covers LCamera:getEffectiveZoom
    it("returns zoom after camera effects", function()
        local cam = new_camera()
        cam:setZoom(2.0)
        expect_true(cam:getEffectiveZoom() > 0.0)
    end)

    -- @covers LCamera:getEffectOffset
    it("returns combined effect offset", function()
        local cam = new_camera()
        local ox, oy = cam:getEffectOffset()
        expect_type("number", ox)
        expect_type("number", oy)
    end)

    -- @covers LCamera:followPath
    it("starts camera movement along a waypoint path", function()
        local cam = new_camera()
        cam:followPath({ { 0, 0 }, { 100, 0 }, { 100, 100 } }, 2.0)
        expect_true(cam:updatePath(1.0))
    end)

    -- @covers LCamera:stopPath
    it("stops an active camera path", function()
        local cam = new_camera()
        cam:followPath({ { 0, 0 }, { 100, 0 } }, 1.0)
        cam:stopPath()
        expect_false(cam:updatePath(0.1))
    end)

    -- @covers LCamera:updatePath
    it("advances active camera path progress", function()
        local cam = new_camera()
        cam:followPath({ { 0, 0 }, { 100, 0 } }, 1.0)
        expect_true(cam:updatePath(0.5))
        local x, _ = cam:getPosition()
        expect_true(x > 0.0)
    end)

    -- @covers LCamera:stopZoom
    it("stops an active zoom tween", function()
        local cam = new_camera()
        cam:setZoom(1.0)
        cam:zoomTo(2.0, 1.0)
        expect_true(cam:updateZoom(0.5))
        local mid = cam:getZoom()
        cam:stopZoom()
        expect_false(cam:updateZoom(0.1))
        expect_near(mid, cam:getZoom(), 0.01)
    end)

    -- @covers LCamera:updateZoom
    it("advances a zoom tween to its target", function()
        local cam = new_camera()
        cam:setZoom(1.0)
        cam:zoomTo(3.0, 0.5)
        expect_true(cam:updateZoom(1.0))
        expect_near(3.0, cam:getZoom(), 0.01)
    end)

    -- @covers LCamera:clearParallaxFactors
    it("clears stored parallax factor overrides", function()
        local cam = new_camera()
        cam:setParallaxFactor("bg", 0.25)
        expect_near(0.25, cam:getParallaxFactor("bg"), 0.001)
        cam:clearParallaxFactors()
        expect_near(1.0, cam:getParallaxFactor("bg"), 0.001)
    end)

    -- @covers lurek.camera.newCamera
    it("creates a camera through the alias constructor", function()
        local cam = lurek.camera.newCamera(800, 600)
        expect_true(cam ~= nil)
    end)

    -- @covers LCamera:type
    it("reports the camera type name", function()
        expect_type("string", lurek.camera.newCamera(800, 600):type())
    end)

    -- @covers LCamera:apply
    it("applies camera commands without error", function()
        expect_no_error(function()
            lurek.camera.newCamera(800, 600):apply()
        end)
    end)

    -- @covers LCamera:reset
    it("resets camera state without error", function()
        expect_no_error(function()
            lurek.camera.newCamera(800, 600):reset()
        end)
    end)

    -- @covers LCamera:attach
    it("attaches camera commands without error", function()
        expect_no_error(function()
            lurek.camera.newCamera(800, 600):attach()
        end)
    end)

    -- @covers LCamera:setZoomConstraints
    it("stores zoom constraints and clamps zoom", function()
        local cam = new_camera()
        cam:setZoomConstraints(0.5, 2.0)
        local has_min, minz, has_max, maxz = cam:getZoomConstraints()
        expect_true(has_min)
        expect_true(has_max)
        expect_near(0.5, minz, 0.001)
        expect_near(2.0, maxz, 0.001)
    end)

    -- @covers LCamera:setFollowEasing
    it("stores follow easing mode", function()
        local cam = new_camera()
        cam:setFollowEasing("smoothstep")
        expect_equal("smoothstep", cam:getFollowEasing())
    end)

    -- @covers LCamera:onWindowResize
    it("expands viewport to the provided window size", function()
        local cam = new_camera()
        cam:onWindowResize(1920, 1080)
        local x, y, w, h = cam:getViewport()
        expect_near(0.0, x, 0.001)
        expect_near(0.0, y, 0.001)
        expect_near(1920.0, w, 0.001)
        expect_near(1080.0, h, 0.001)
    end)

    -- @covers LCamera:onWindowResizeScaled
    it("applies scaled viewport letterboxing", function()
        local cam = new_camera()
        cam:onWindowResizeScaled(800, 600, 1200, 600, "letterbox")
        local x, y, w, h = cam:getViewport()
        expect_near(200.0, x, 0.001)
        expect_near(0.0, y, 0.001)
        expect_near(800.0, w, 0.001)
        expect_near(600.0, h, 0.001)
    end)

    -- @covers LCamera:presetTightFollow
    it("applies the tight follow profile", function()
        local cam = new_camera()
        cam:presetTightFollow()
        expect_near(0.9, cam:getFollowSmooth(), 0.001)
    end)

    -- @covers LCamera:presetCinematicFollow
    it("applies the cinematic follow profile", function()
        local cam = new_camera()
        cam:presetCinematicFollow()
        expect_near(0.3, cam:getFollowSmooth(), 0.001)
    end)

    -- @covers LCamera:presetBalancedFollow
    it("applies the balanced follow profile", function()
        local cam = new_camera()
        cam:presetBalancedFollow()
        expect_near(0.6, cam:getFollowSmooth(), 0.001)
    end)

    -- @covers LCamera:presetAggressiveFollow
    it("applies the aggressive follow profile", function()
        local cam = new_camera()
        cam:presetAggressiveFollow()
        expect_near(0.99, cam:getFollowSmooth(), 0.01)
    end)

    -- @covers lurek.camera.newRig
    it("creates a camera rig handle", function()
        local rig = new_rig()
        expect_type("userdata", rig)
        expect_true(rig:typeOf("LCameraRig"))
    end)

    -- @covers LCameraRig:splitScreen
    it("creates left and right split-screen cameras", function()
        local rig = new_rig()
        rig:splitScreen(1280, 720)
        expect_true(rig:has("left"))
        expect_true(rig:has("right"))
    end)

    -- @covers LCameraRig:minimap
    it("applies a minimap layout", function()
        local rig = new_rig()
        rig:setPosition("main", 0, 0)
        rig:minimap(1280, 720, 0.2)
        expect_true(#rig:names() >= 1)
    end)

    -- @covers LCameraRig:updateAll
    it("updates all cameras in the rig", function()
        local rig = new_rig()
        rig:splitScreen(1280, 720)
        expect_no_error(function()
            rig:updateAll(0.016)
        end)
    end)

    -- @covers LCameraRig:remove
    it("removes named rig cameras", function()
        local rig = new_rig()
        rig:setPosition("temp", 0, 0)
        expect_true(rig:remove("temp"))
        expect_false(rig:has("temp"))
    end)

    -- @covers LCamera:getBounds
    it("returns bound rectangles with availability flag", function()
        local cam = new_camera()
        cam:setBounds(1, 2, 3, 4)
        local ok, x, y, w, h = cam:getBounds()
        expect_true(ok)
        expect_near(1, x, 0.001)
        expect_near(2, y, 0.001)
        expect_near(3, w, 0.001)
        expect_near(4, h, 0.001)
    end)

    -- @covers LCamera:getTarget
    it("returns target coordinates with availability flag", function()
        local cam = new_camera()
        cam:setTarget(11, 22)
        local ok, x, y = cam:getTarget()
        expect_true(ok)
        expect_near(11, x, 0.001)
        expect_near(22, y, 0.001)
    end)

    -- @covers LCamera:getDeadZone
    it("returns dead-zone dimensions with availability flag", function()
        local cam = new_camera()
        cam:setDeadZone(50, 30)
        local ok, w, h = cam:getDeadZone()
        expect_true(ok)
        expect_near(50, w, 0.001)
        expect_near(30, h, 0.001)
    end)

    -- @covers LCamera:getFollowSmooth
    it("returns current follow smoothing", function()
        local cam = new_camera()
        cam:setFollowSmooth(2.25)
        expect_near(2.25, cam:getFollowSmooth(), 0.001)
    end)

    -- @covers LCamera:getShakeOffset
    it("returns current shake offset pair", function()
        local x, y = new_camera():getShakeOffset()
        expect_type("number", x)
        expect_type("number", y)
    end)

    -- @covers LCamera:setZoomDamping
    it("stores zoom damping", function()
        local cam = new_camera()
        cam:setZoomDamping(0.3)
        expect_near(0.3, cam:getZoomDamping(), 0.001)
    end)

    -- @covers LCamera:setRotationConstraints
    it("stores rotation constraints", function()
        local cam = new_camera()
        cam:setRotationConstraints(-0.5, 0.5)
        local has_min, min_r, has_max, max_r = cam:getRotationConstraints()
        expect_true(has_min)
        expect_true(has_max)
        expect_near(-0.5, min_r, 0.001)
        expect_near(0.5, max_r, 0.001)
    end)

    -- @covers LCamera:setParallaxFactor
    it("stores parallax factor overrides by layer name", function()
        local cam = new_camera()
        cam:setParallaxFactor("bg", 0.5)
        expect_near(0.5, cam:getParallaxFactor("bg"), 0.001)
    end)
end)

test_summary()
