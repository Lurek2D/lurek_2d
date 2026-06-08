-- Lurek2D Integration Test: Worms-style Terrain + Physics
-- Exercises TerrainMap and World together: dig a hole with fillCircle,
-- flush the terrain, then drop a body and verify it lands rather than
-- falling through.

-- @describe worms terrain + physics integration
describe("worms terrain + physics integration", function()
    --              does not fall indefinitely (terrain colliders are present).
    -- @covers LTerrain:fillCircle
    -- @covers LTerrain:fillRect
    -- @covers LTerrain:flush
    -- @covers LWorld:newBody
    -- @covers LWorld:step
    -- @covers lurek.physics.getBody
    -- @covers lurek.physics.newTerrain
    -- @covers lurek.physics.newWorld
    it("rigid body rests on terrain after dig and flush", function()
        local world = lurek.physics.newWorld(0, 300)
        local terrain = lurek.physics.newTerrain(64, 64, 8, world)

        -- Fill solid ground from row 32 down.
        terrain:fillRect(0, 256, 512, 512, true) -- world y 256     cell row 32
        terrain:fillCircle(96, 256, 24, false) -- dig a nearby hole without removing the landing area
        terrain:flush()

        -- Drop a body from above the solid region.
        local body = world:newBody(256, 0, "dynamic")

        -- Step enough for the body to fall and settle.
        for _ = 1, 120 do
            world:step(1/60)
        end

        local x, y, vx, vy = lurek.physics.getBody(world, body)

        expect_true(y >= 200, "body should fall toward the terrain band")
        expect_true(y <= 360, "body should settle near terrain instead of falling through it")
        expect_true(math.abs(vy) < 200, "body vertical speed should be bounded after settling on terrain")
        expect_near(256, x, 1.0)
    end)

    -- @covers LTerrain:fillAll
    -- @covers LTerrain:fillCircle
    -- @covers LTerrain:flush
    -- @covers LTerrain:isDirty
    -- @covers lurek.physics.newTerrain
    -- @covers lurek.physics.newWorld
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
