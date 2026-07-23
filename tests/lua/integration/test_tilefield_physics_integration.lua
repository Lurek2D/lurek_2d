-- Integration: tilefield collision metadata is consumed by the canonical physics adapter.

-- @describe tilefield + physics collision integration
describe("tilefield + physics collision integration", function()
    -- @integration LTileField:setRef
    -- @integration LWorld:getBodyCount
    -- @integration lurek.physics.createBodiesFromTilefield
    -- @integration lurek.physics.newWorld
    -- @integration lurek.tilefield.new
    -- @integration lurek.tileset.fromProvider
    it("converts referenced tileset collision metadata into world bodies", function()
        local tileset = lurek.tileset.fromProvider({
            firstGid = 10,
            tileCount = 2,
            columns = 2,
            tileWidth = 16,
            tileHeight = 16,
            objects = { wall = { physics = { shape = "diamond", bodyType = "static" } } },
            tileObjects = { [2] = "wall" },
        })
        local field = lurek.tilefield.new({ width = 2, height = 2 })
        field:setRef(1, 1, 1, "tiles", 11)
        local world = lurek.physics.newWorld(0, 0)
        local bodies = lurek.physics.createBodiesFromTilefield(
            field, "tiles", tileset, world, { refIsGid = true }
        )

        expect_equal(1, #bodies)
        expect_equal(1, world:getBodyCount())
    end)
end)

test_summary()
