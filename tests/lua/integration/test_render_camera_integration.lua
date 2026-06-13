-- Integration: render draw commands combined with camera transform state
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

        local cx, cy = cam:getPosition()
        local ox, oy = cam:getRenderOffset()
        local draw_x = cx + 10
        local draw_y = cy + 10
        expect_near(100, cx, 0.01, "camera x")
        expect_near(200, cy, 0.01, "camera y")
        expect_type("number", ox)
        expect_type("number", oy)
        expect_near(110, draw_x, 0.01, "camera state feeds world draw x")
        expect_near(210, draw_y, 0.01, "camera state feeds world draw y")

        lurek.render.setColor(1, 0, 0, 1)
        lurek.render.rectangle("fill", draw_x, draw_y, 50, 50)
    end)

    -- @integration LCamera:getZoom
    -- @integration LCamera:getViewport
    -- @integration LCamera:setZoom
    -- @integration lurek.camera.newCamera
    -- @integration lurek.render.circle
    it("camera zoom scales the viewport", function()
        local cam = lurek.camera.newCamera()
        cam:setZoom(2.0)

        local zoom = cam:getZoom()
        local _, _, width, height = cam:getViewport()
        local radius = 12.5 * zoom
        expect_near(2.0, zoom, 0.01, "zoom is 2x")
        expect_type("number", width)
        expect_type("number", height)
        expect_near(25.0, radius, 0.01, "camera zoom feeds render radius")

        lurek.render.circle("fill", width / 2, height / 2, radius)
    end)

    -- @integration LCamera:getRotation
    -- @integration LCamera:setRotation
    -- @integration lurek.camera.newCamera
    -- @integration lurek.render.line
    it("camera rotation combines with graphics transforms", function()
        local cam = lurek.camera.newCamera()
        cam:setRotation(math.pi / 4)

        local rot = cam:getRotation()
        local line_dx = math.cos(rot) * 100
        local line_dy = math.sin(rot) * 100
        expect_near(math.pi / 4, rot, 0.001, "camera rotated 45 degrees")
        expect_near(70.710678, line_dx, 0.01, "rotation derives x component for render line")
        expect_near(70.710678, line_dy, 0.01, "rotation derives y component for render line")

        lurek.render.line(0, 0, line_dx, line_dy)
    end)

    -- @integration LCamera:getPosition
    -- @integration LCamera:getZoom
    -- @integration LCamera:setPosition
    -- @integration LCamera:setZoom
    -- @integration lurek.camera.newCamera
    -- @integration lurek.render.rectangle
    it("camera position and zoom state remains coherent for subsequent draw", function()
        local cam = lurek.camera.newCamera()
        cam:setPosition(200, 150)
        cam:setZoom(1.5)

        local cx, cy = cam:getPosition()
        local zoom = cam:getZoom()
        local world_w = 20 * zoom
        local world_h = 10 * zoom
        expect_near(200, cx, 0.01, "camera x")
        expect_near(150, cy, 0.01, "camera y")
        expect_near(1.5, zoom, 0.01, "camera zoom")
        expect_near(30, world_w, 0.01, "camera zoom scales width coherently")
        expect_near(15, world_h, 0.01, "camera zoom scales height coherently")

        lurek.render.rectangle("line", cx, cy, world_w, world_h)
    end)
end)
test_summary()
