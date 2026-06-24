-- Canonical unit coverage for lurek.tileset v2 catalog APIs.

-- @describe lurek.tileset v2 catalog
describe("lurek.tileset v2 catalog", function()
    -- @covers lurek.tileset.fromProvider
    -- @covers LTileSet:getObject
    it("stores object category semantics and visuals", function()
        local tileset = lurek.tileset.fromProvider({
            tileCount = 4,
            columns = 2,
            tileWidth = 16,
            tileHeight = 16,
            objects = {
                tree = {
                    slot = "object",
                    tileId = 2,
                    visual = { atlas = "terrain", sprite = "tree", order = 5 },
                    categoryBlocks = { sight = true },
                    categoryCosts = { tank = 9 },
                    transmission = { light = 0.25 },
                    filters = { light = { 0.5, 0.75, 1.0 } },
                    footprint = { w = 2, h = 3 },
                },
            },
        })

        local object = tileset:getObject("tree")
        expect_equal("object", object.slot)
        expect_equal("terrain", object.visual.atlas)
        expect_true(object.categoryBlocks.sight)
        expect_near(9.0, object.categoryCosts.tank, 0.001)
        expect_near(0.25, object.transmission.light, 0.001)
        expect_near(0.75, object.filters.light[2], 0.001)
        expect_equal(2, object.footprint.w)
        expect_equal(3, object.footprint.h)
    end)

    -- @covers lurek.tileset.newCatalog
    -- @covers LTileCatalog:getIds
    -- @covers LTileCatalog:getObject
    -- @covers LTileCatalog:getVisual
    -- @covers LTileCatalog:getTileset
    it("resolves typed tile refs across named tilesets", function()
        local tileset = lurek.tileset.fromProvider({
            tileCount = 4,
            columns = 2,
            tileWidth = 16,
            tileHeight = 16,
            objects = {
                crate = {
                    slot = "object",
                    visual = { image = "crate.png", order = 2 },
                },
            },
            tileObjects = {
                [3] = "crate",
            },
        })
        local catalog = lurek.tileset.newCatalog({ objects = tileset })

        expect_equal("objects", catalog:getIds()[1])
        expect_type("userdata", catalog:getTileset("objects"))
        expect_equal("crate", catalog:getObject({ tileset = "objects", tile = 3 }).name)
        expect_equal("crate.png", catalog:getVisual({ tileset = "objects", object = "crate" }).image)
    end)
end)

test_summary()
