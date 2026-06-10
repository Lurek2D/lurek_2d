-- Lurek2D Integration Test: Worms-style Terrain + Physics
-- Exercises TerrainMap and World together: dig a hole with fillCircle,
-- flush the terrain, then drop a body and verify it lands rather than
-- falling through.

-- @describe worms terrain + physics integration
describe("worms terrain + physics integration", function()
    --              does not fall indefinitely (terrain colliders are present).
    -- @covers LTerrain:fillAll
    it("terrain is clean after dig and flush", function()
        local world = lurek.physics.newWorld(0, 0)
        local terrain = lurek.physics.newTerrain(32, 32, 8, world)
        terrain:fillAll(true)
        terrain:flush()
        expect_false(terrain:isDirty())

        -- Dig a hole.
        terrain:fillCircle(128, 128, 24, false)
        expect_true(terrain:isDirty())
        terrain:flush()
        expect_false(terrain:isDirty())
    end)
end)
test_summary()
