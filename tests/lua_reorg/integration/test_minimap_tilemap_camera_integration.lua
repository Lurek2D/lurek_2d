-- Integration: minimap reflects logical tilemap coordinates and camera movement.
-- @describe integration: minimap + tilemap + camera
describe("integration: minimap + tilemap + camera", function()
    -- @integration LCamera:getPosition
    -- @integration LCamera:setPosition
    -- @integration LTileMap:addLayer
    -- @integration LTileMap:getTile
    -- @integration LTileMap:setTile
    -- @integration LMinimap:gridToScreen
    -- @integration LMinimap:screenToGrid
    -- @integration lurek.camera.newCamera
    -- @integration lurek.minimap.newMinimap
    -- @integration lurek.tilemap.newTileMap
    it("maps camera world position to minimap space on populated tilemap", function()
        local map = lurek.tilemap.newTileMap(20, 20, 16)
        map:addLayer("base", 20, 20)
        map:setTile(1, 5, 5, 2)

        local mini = lurek.minimap.newMinimap(20, 20, 200, 200)
        local cam = lurek.camera.newCamera()

        cam:setPosition(80, 64)
        local wx, wy = cam:getPosition()
        local gx = wx / 16
        local gy = wy / 16
        local mx, my = mini:gridToScreen(gx, gy, 0, 0)
        local back_gx, back_gy = mini:screenToGrid(mx, my, 0, 0)

        expect_equal(2, map:getTile(1, 5, 5), "tilemap keeps populated tile under tracked area")
        expect_near(5, gx, 0.001, "camera x converts to expected grid column")
        expect_near(4, gy, 0.001, "camera y converts to expected grid row")
        expect_type("number", mx, "mini x must be numeric")
        expect_type("number", my, "mini y must be numeric")
        expect_true(mx >= 0 and my >= 0, "mini coordinates should be non-negative")
        expect_near(gx, back_gx, 0.6, "screen position converts back to the same minimap column")
        expect_near(gy, back_gy, 0.6, "screen position converts back to the same minimap row")
    end)
end)
test_summary()
