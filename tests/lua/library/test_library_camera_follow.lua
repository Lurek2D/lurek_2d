-- Lurek2D Library Camera Follow Tests
-- @testCategory library

local CameraFollow = require("library.camera_follow")

-- @describe camera_follow library     new
describe("camera_follow library     new", function()
    -- @library lurek.library_camera_follow
    it("returns controller with defaults", function()
        local cam = CameraFollow.new()
        expect_not_nil(cam, "new() must return non-nil controller")
        expect_equal(cam:getZoom(), 1.0, "default zoom must be 1.0")
    end)

    -- @library lurek.library_camera_follow
    it("accepts opts overrides", function()
        local cam = CameraFollow.new({ smoothing = 10, zoom = 2.0 })
        expect_equal(cam:getZoom(), 2.0, "zoom must respect opts")
    end)
end)

-- @describe camera_follow library     setTarget getPosition
describe("camera_follow library     setTarget getPosition", function()
    -- @library lurek.library_camera_follow
    it("setTarget and getPosition basic flow", function()
        local cam = CameraFollow.new()
        cam:setTarget(100, 200)
        -- First update snaps to target on first frame
        cam:update(0.016)
        local x, y = cam:getPosition()
        expect_true(x ~= nil, "x must be non-nil")
        expect_true(y ~= nil, "y must be non-nil")
    end)
end)

-- @describe camera_follow library     snap
describe("camera_follow library     snap", function()
    -- @library lurek.library_camera_follow
    it("immediately moves to target", function()
        local cam = CameraFollow.new()
        cam:setTarget(300, 400)
        cam:snap()
        local x, y = cam:getPosition()
        expect_equal(x, 300, "snap must set x to target x")
        expect_equal(y, 400, "snap must set y to target y")
    end)
end)

-- @describe camera_follow library     shake
describe("camera_follow library     shake", function()
    -- @library lurek.library_camera_follow
    it("sets shake state", function()
        local cam = CameraFollow.new()
        cam:setTarget(0, 0)
        cam:snap()
        cam:shake(10, 0.5)
        -- After a small update the shake offsets position
        cam:update(0.01)
        local x, y = cam:getPosition()
        -- Position should potentially differ from 0,0 due to shake
        -- (random, so just verify no error and position returned)
        expect_true(x ~= nil, "x must be non-nil during shake")
        expect_true(y ~= nil, "y must be non-nil during shake")
    end)
end)

-- @describe camera_follow library     zoom
describe("camera_follow library     zoom", function()
    -- @library lurek.library_camera_follow
    it("setZoom and getZoom work", function()
        local cam = CameraFollow.new()
        cam:setZoom(2.5)
        expect_equal(cam:getZoom(), 2.5, "zoom must be 2.5 after setZoom")
    end)
end)

-- @describe camera_follow library     bounds
describe("camera_follow library     bounds", function()
    -- @library lurek.library_camera_follow
    it("setBounds and getBounds work", function()
        local cam = CameraFollow.new()
        cam:setBounds(0, 0, 800, 600)
        local b = cam:getBounds()
        expect_not_nil(b, "getBounds must return non-nil after setBounds")
        expect_equal(b.minX, 0, "minX must be 0")
        expect_equal(b.minY, 0, "minY must be 0")
        expect_equal(b.maxX, 800, "maxX must be 800")
        expect_equal(b.maxY, 600, "maxY must be 600")
    end)

    -- @library lurek.library_camera_follow
    it("getBounds returns nil when unbounded", function()
        local cam = CameraFollow.new()
        local b = cam:getBounds()
        expect_true(b == nil, "getBounds must return nil when no bounds set")
    end)
end)

-- @describe camera_follow library     override clearOverride
describe("camera_follow library     override clearOverride", function()
    -- @library lurek.library_camera_follow
    it("override and clearOverride lifecycle", function()
        local cam = CameraFollow.new()
        cam:setTarget(100, 100)
        cam:snap()
        cam:override(500, 500, 1.0)
        -- Update to progress override
        cam:update(1.0)
        local x, y = cam:getPosition()
        expect_equal(x, 500, "override must move to target x after full duration")
        expect_equal(y, 500, "override must move to target y after full duration")
        cam:clearOverride()
        -- After clearing, next update resumes normal follow
        local ok = pcall(function() cam:update(0.016) end)
        expect_true(ok, "clearOverride must allow normal update to proceed")
    end)
end)

-- @describe camera_follow library     update movement
describe("camera_follow library     update movement", function()
    -- @library lurek.library_camera_follow
    it("moves toward target over time", function()
        local cam = CameraFollow.new({ smoothing = 5.0 })
        cam:setTarget(0, 0)
        cam:snap()
        cam:setTarget(100, 0)
        cam:update(0.1)
        local x, _ = cam:getPosition()
        expect_true(x > 0, "camera must move toward target after update")
        expect_true(x < 100, "camera must not overshoot target in one step")
    end)
end)

test_summary()
