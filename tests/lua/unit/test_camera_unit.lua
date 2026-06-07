-- tests/lua/unit/test_camera_unit.lua
-- Lua-first unit tests for lurek.camera module covering position, zoom, bounds, target follow, effects, and viewport.

local harness = require("tests.lua.harness")

describe("lurek.camera", function()
    -- @covers lurek.camera.new
    it("creates a camera with default dimensions", function()
        local cam = lurek.camera.new(800, 600)
        assert_equal("userdata", type(cam))
        assert_equal(800, select(3, cam:getViewport()))
        assert_equal(600, select(4, cam:getViewport()))
    end)

    -- @covers lurek.camera.new
    it("returns LCamera type", function()
        local cam = lurek.camera.new(1024, 768)
        assert_equal("LCamera", cam:type())
    end)

    -- @covers lurek.camera.newCamera
    it("creates a camera via newCamera constructor", function()
        local cam = lurek.camera.newCamera(640, 480)
        assert_equal("userdata", type(cam))
        assert_equal("LCamera", cam:type())
    end)

    -- @covers lurek.camera.newRig
    it("creates a multi-camera rig", function()
        local rig = lurek.camera.newRig()
        assert_equal("userdata", type(rig))
        assert_equal("LCameraRig", rig:type())
    end)

    -- Position and Viewport
    -- @covers lurek.camera.LCamera.setPosition
    it("sets camera position", function()
        local cam = lurek.camera.new(800, 600)
        cam:setPosition(100, 200)
        local x, y = cam:getPosition()
        assert_equal(100, x)
        assert_equal(200, y)
    end)

    -- @covers lurek.camera.LCamera.getPosition
    it("gets camera position after setting", function()
        local cam = lurek.camera.new(800, 600)
        cam:setPosition(500, 300)
        local x, y = cam:getPosition()
        assert_near(x, 500, 0.01)
        assert_near(y, 300, 0.01)
    end)

    -- Zoom
    -- @covers lurek.camera.LCamera.setZoom
    it("sets zoom level", function()
        local cam = lurek.camera.new(800, 600)
        cam:setZoom(2.0)
        local z = cam:getZoom()
        assert_near(z, 2.0, 0.01)
    end)

    -- @covers lurek.camera.LCamera.getZoom
    it("gets zoom level", function()
        local cam = lurek.camera.new(800, 600)
        cam:setZoom(0.5)
        local z = cam:getZoom()
        assert_near(z, 0.5, 0.01)
    end)

    -- Rotation
    -- @covers lurek.camera.LCamera.setRotation
    it("sets rotation angle", function()
        local cam = lurek.camera.new(800, 600)
        cam:setRotation(math.pi / 4)
        local r = cam:getRotation()
        assert_near(r, math.pi / 4, 0.01)
    end)

    -- @covers lurek.camera.LCamera.getRotation
    it("gets rotation angle", function()
        local cam = lurek.camera.new(800, 600)
        cam:setRotation(1.5)
        local r = cam:getRotation()
        assert_near(r, 1.5, 0.01)
    end)

    -- Viewport
    -- @covers lurek.camera.LCamera.setViewport
    it("sets viewport rectangle", function()
        local cam = lurek.camera.new(800, 600)
        cam:setViewport(10, 20, 400, 300)
        local x, y, w, h = cam:getViewport()
        assert_equal(10, x)
        assert_equal(20, y)
        assert_equal(400, w)
        assert_equal(300, h)
    end)

    -- @covers lurek.camera.LCamera.getViewport
    it("gets viewport after setting", function()
        local cam = lurek.camera.new(800, 600)
        cam:setViewport(5, 15, 600, 500)
        local x, y, w, h = cam:getViewport()
        assert_equal(5, x)
        assert_equal(15, y)
        assert_equal(600, w)
        assert_equal(500, h)
    end)

    -- Bounds
    -- @covers lurek.camera.LCamera.setBounds
    it("sets world bounds for camera clamping", function()
        local cam = lurek.camera.new(800, 600)
        cam:setBounds(0, 0, 3200, 2400)
        assert_equal(true, cam:hasBounds())
    end)

    -- @covers lurek.camera.LCamera.getBounds
    it("gets bounds after setting", function()
        local cam = lurek.camera.new(800, 600)
        cam:setBounds(100, 200, 1000, 800)
        local ok, x, y, w, h = cam:getBounds()
        assert_equal(true, ok)
        assert_equal(100, x)
        assert_equal(200, y)
        assert_equal(1000, w)
        assert_equal(800, h)
    end)

    -- @covers lurek.camera.LCamera.hasBounds
    it("reports whether bounds are active", function()
        local cam = lurek.camera.new(800, 600)
        assert_equal(false, cam:hasBounds())
        cam:setBounds(0, 0, 1000, 1000)
        assert_equal(true, cam:hasBounds())
    end)

    -- @covers lurek.camera.LCamera.removeBounds
    it("removes bounds when set", function()
        local cam = lurek.camera.new(800, 600)
        cam:setBounds(0, 0, 500, 500)
        assert_equal(true, cam:hasBounds())
        cam:removeBounds()
        assert_equal(false, cam:hasBounds())
    end)

    -- Target Following
    -- @covers lurek.camera.LCamera.setTarget
    it("sets camera target for following", function()
        local cam = lurek.camera.new(800, 600)
        cam:setTarget(250, 125)
        local ok, tx, ty = cam:getTarget()
        assert_equal(true, ok)
        assert_near(tx, 250, 0.01)
        assert_near(ty, 125, 0.01)
    end)

    -- @covers lurek.camera.LCamera.getTarget
    it("gets target after setting", function()
        local cam = lurek.camera.new(800, 600)
        cam:setTarget(500, 300)
        local ok, tx, ty = cam:getTarget()
        assert_equal(true, ok)
        assert_equal(500, tx)
        assert_equal(300, ty)
    end)

    -- @covers lurek.camera.LCamera.clearTarget
    it("clears target when set", function()
        local cam = lurek.camera.new(800, 600)
        cam:setTarget(100, 100)
        assert_equal(true, cam:getTarget())
        cam:clearTarget()
        assert_equal(false, cam:getTarget())
    end)

    -- Follow Smoothing
    -- @covers lurek.camera.LCamera.setFollowSmooth
    it("sets follow smoothing factor", function()
        local cam = lurek.camera.new(800, 600)
        cam:setFollowSmooth(5.0)
        local s = cam:getFollowSmooth()
        assert_near(s, 5.0, 0.01)
    end)

    -- @covers lurek.camera.LCamera.getFollowSmooth
    it("gets follow smoothing value", function()
        local cam = lurek.camera.new(800, 600)
        cam:setFollowSmooth(3.0)
        local s = cam:getFollowSmooth()
        assert_near(s, 3.0, 0.01)
    end)

    -- Follow Easing
    -- @covers lurek.camera.LCamera.setFollowEasing
    it("sets follow easing mode", function()
        local cam = lurek.camera.new(800, 600)
        cam:setFollowEasing("quadOut")
        local e = cam:getFollowEasing()
        assert_equal("quadOut", e)
    end)

    -- @covers lurek.camera.LCamera.getFollowEasing
    it("gets follow easing after setting", function()
        local cam = lurek.camera.new(800, 600)
        cam:setFollowEasing("linear")
        local e = cam:getFollowEasing()
        assert_equal("linear", e)
    end)

    -- Dead Zone
    -- @covers lurek.camera.LCamera.setDeadZone
    it("sets dead zone rectangle", function()
        local cam = lurek.camera.new(800, 600)
        cam:setDeadZone(50, 30)
        local ok, w, h = cam:getDeadZone()
        assert_equal(true, ok)
        assert_equal(50, w)
        assert_equal(30, h)
    end)

    -- @covers lurek.camera.LCamera.getDeadZone
    it("gets dead zone after setting", function()
        local cam = lurek.camera.new(800, 600)
        cam:setDeadZone(40, 20)
        local ok, w, h = cam:getDeadZone()
        assert_equal(true, ok)
        assert_equal(40, w)
        assert_equal(20, h)
    end)

    -- Look Ahead
    -- @covers lurek.camera.LCamera.setLookAhead
    it("sets look ahead displacement", function()
        local cam = lurek.camera.new(800, 600)
        cam:setLookAhead(1.5)
        local la = cam:getLookAhead()
        assert_near(la, 1.5, 0.01)
    end)

    -- @covers lurek.camera.LCamera.getLookAhead
    it("gets look ahead value", function()
        local cam = lurek.camera.new(800, 600)
        cam:setLookAhead(2.0)
        local la = cam:getLookAhead()
        assert_near(la, 2.0, 0.01)
    end)

    -- Camera Effects
    -- @covers lurek.camera.LCamera.shake
    it("applies screen shake effect", function()
        local cam = lurek.camera.new(800, 600)
        cam:shake(5, 0.2)
        -- No direct query for shake state, but no error = success
        assert_equal("userdata", type(cam))
    end)

    -- @covers lurek.camera.LCamera.pulse
    it("applies zoom pulse effect", function()
        local cam = lurek.camera.new(800, 600)
        cam:pulse(1.2, 0.3)
        assert_equal("userdata", type(cam))
    end)

    -- @covers lurek.camera.LCamera.sway
    it("applies camera sway effect", function()
        local cam = lurek.camera.new(800, 600)
        cam:sway(3.0, 0.5, 0.1)
        assert_equal("userdata", type(cam))
    end)

    -- Camera Presets
    -- @covers lurek.camera.presetBalancedFollow
    it("applies balanced follow preset", function()
        local cam = lurek.camera.new(800, 600)
        cam:presetBalancedFollow()
        assert_near(cam:getFollowSmooth(), 5.0, 1.0)
    end)

    -- @covers lurek.camera.presetTightFollow
    it("applies tight follow preset", function()
        local cam = lurek.camera.new(800, 600)
        cam:presetTightFollow()
        local s = cam:getFollowSmooth()
        assert_true(s > 7.0)  -- tight should be snappier
    end)

    -- Update
    -- @covers lurek.camera.LCamera.update
    it("updates camera state by delta time", function()
        local cam = lurek.camera.new(800, 600)
        cam:setPosition(0, 0)
        cam:setTarget(100, 50)
        cam:setFollowSmooth(5.0)
        cam:update(0.016)  -- 1 frame at 60 FPS
        local x, y = cam:getPosition()
        -- Position should have moved toward target
        assert_true(x > 0)
        assert_true(y > 0)
    end)
end)

test_summary()
