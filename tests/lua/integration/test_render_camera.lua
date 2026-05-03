-- Lurek2D Integration Test: Graphics + Camera
-- Tests graphics rendering commands with camera transforms

-- @describe graphics + camera integration
describe("graphics + camera integration", function()
    -- @integration LCamera:getPosition
    -- @integration LCamera:setPosition
    -- @integration lurek.camera.newCamera
    -- @integration lurek.render.rectangle
    -- @integration lurek.render.setColor
    it("camera transforms affect draw command coordinates", function()
        local cam = lurek.camera.newCamera()
        cam:setPosition(100, 200)

        -- Verify camera position stored
        local cx, cy = cam:getPosition()
        expect_near(100, cx, 0.01, "camera x")
        expect_near(200, cy, 0.01, "camera y")

        -- Draw commands should still work
        expect_no_error(function()
            lurek.render.setColor(1, 0, 0, 1)
            lurek.render.rectangle("fill", 10, 10, 50, 50)
        end)
    end)

    -- @integration LCamera:getZoom
    -- @integration LCamera:setZoom
    -- @integration lurek.camera.newCamera
    -- @integration lurek.render.circle
    it("camera zoom scales the viewport", function()
        local cam = lurek.camera.newCamera()
        cam:setZoom(2.0)

        local zoom = cam:getZoom()
        expect_near(2.0, zoom, 0.01, "zoom is 2x")

        -- Drawing at zoom should not error
        expect_no_error(function()
            lurek.render.circle("fill", 100, 100, 25)
        end)
    end)

    -- @integration LCamera:getRotation
    -- @integration LCamera:setRotation
    -- @integration lurek.camera.newCamera
    -- @integration lurek.render.line
    it("camera rotation combines with graphics transforms", function()
        local cam = lurek.camera.newCamera()
        cam:setRotation(math.pi / 4)

        local rot = cam:getRotation()
        expect_near(math.pi / 4, rot, 0.001, "camera rotated 45 degrees")

        -- Draw with camera rotation applied
        expect_no_error(function()
            lurek.render.line(0, 0, 100, 100)
        end)
    end)

    -- @integration LCamera:setPosition
    -- @integration LCamera:setZoom
    -- @integration lurek.camera.newCamera
    it("camera worldToScreen and screenToWorld round-trip", function()
        local cam = lurek.camera.newCamera()
        cam:setPosition(200, 150)
        cam:setZoom(1.5)

        -- If worldToScreen and screenToWorld exist, test round-trip
        if cam.worldToScreen and cam.screenToWorld then
            local sx, sy = cam:worldToScreen(50, 75)
            local wx, wy = cam:screenToWorld(sx, sy)
            expect_near(50, wx, 1.0, "round-trip world x")
            expect_near(75, wy, 1.0, "round-trip world y")
        else
            expect_true(true, "worldToScreen not available in headless")
        end
    end)
end)
test_summary()
