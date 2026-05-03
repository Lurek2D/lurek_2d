-- Lurek2D Integration Test: Scene + Camera
-- Tests camera viewport transformations over a scene.

-- @describe integration: scene camera viewport operations
describe("integration: scene camera viewport operations", function()
    -- @integration LCamera:getPosition
    -- @integration LCamera:setPosition
    -- @integration lurek.camera.newCamera
    it("camera position changes are stored correctly", function()
        local cam = lurek.camera.newCamera()

        cam:setPosition(0, 0)
        local x0, y0 = cam:getPosition()
        expect_near(0, x0, 0.001, "camera x at origin")
        expect_near(0, y0, 0.001, "camera y at origin")

        cam:setPosition(320, 240)
        local x1, y1 = cam:getPosition()
        expect_near(320, x1, 0.001, "camera x after move")
        expect_near(240, y1, 0.001, "camera y after move")
    end)

    -- @integration LCamera:getZoom
    -- @integration LCamera:setZoom
    -- @integration lurek.camera.newCamera
    it("camera zoom alters the visible scale", function()
        local cam = lurek.camera.newCamera()

        cam:setZoom(1.0)
        expect_near(1.0, cam:getZoom(), 0.001, "default zoom")

        cam:setZoom(2.0)
        expect_near(2.0, cam:getZoom(), 0.001, "zoom 2x")

        cam:setZoom(0.5)
        expect_near(0.5, cam:getZoom(), 0.001, "zoom 0.5x")
    end)

    -- @integration LCamera:getPosition
    -- @integration LCamera:setPosition
    -- @integration LUniverse:get
    -- @integration LUniverse:set
    -- @integration LUniverse:spawn
    -- @integration lurek.camera.newCamera
    -- @integration lurek.ecs.newUniverse
    it("camera follows tracked entity position", function()
        local universe = lurek.ecs.newUniverse()
        local cam = lurek.camera.newCamera()

        local player = universe:spawn()
        universe:set(player, "x", 128.0)
        universe:set(player, "y", 64.0)

        -- Simulate camera following entity
        local raw_px = universe:get(player, "x")
        local raw_py = universe:get(player, "y")
        local px = 0
        local py = 0
        if type(raw_px) == "number" then
            px = raw_px
        elseif type(raw_px) == "table" then
            local px_from_table = raw_px.x or raw_px[1]
            if type(px_from_table) == "number" then
                px = px_from_table
            end
        end
        if type(raw_py) == "number" then
            py = raw_py
        elseif type(raw_py) == "table" then
            local py_from_table = raw_py.y or raw_py[2]
            if type(py_from_table) == "number" then
                py = py_from_table
            end
        end
        cam:setPosition(px, py)

        local cx, cy = cam:getPosition()
        expect_near(128, cx, 0.001, "camera follows entity x")
        expect_near(64,  cy, 0.001, "camera follows entity y")
    end)

    -- @integration LCamera:getRotation
    -- @integration LCamera:setRotation
    -- @integration lurek.camera.newCamera
    it("camera rotation is retrievable", function()
        local cam = lurek.camera.newCamera()
        cam:setRotation(0.5)
        local r = cam:getRotation()
        expect_near(0.5, r, 0.001, "camera rotation stored")
    end)
end)
test_summary()
