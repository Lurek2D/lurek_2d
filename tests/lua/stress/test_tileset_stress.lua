-- Deterministic bounded stress coverage for tileset catalogs, rules, and provider parsing.

local function build_provider()
    local animations = {}
    local properties = {}
    for tile = 1, 256 do
        animations[tile] = {
            { tileid = tile, duration = 20 + (tile % 5) },
            { tileid = ((tile + 1) % 256) + 1, duration = 30 },
        }
        properties[tile] = { biome = "stress", index = tile }
    end
    return lurek.tileset.fromProvider({
        firstGid = 1,
        tileCount = 256,
        columns = 16,
        tileWidth = 16,
        tileHeight = 16,
        animations = animations,
        properties = properties,
        objects = {
            a = { tileId = 1, visual = { image = "a.png" } },
            b = { tileId = 2, visual = { image = "b.png" } },
        },
        tileObjects = { [1] = "a", [2] = "b" },
    })
end

-- @describe tileset bounded stress
describe("tileset bounded stress", function()
    -- @stress lurek.tileset.fromProvider
    it("parses 256 tiles with animations and properties", function()
        local tileset = build_provider()
        expect_equal(256, tileset:getTileCount())
        expect_equal(2, #tileset:getAnimation(1))
        expect_equal("stress", tileset:getProperty(256, "biome"))
    end)

    -- @stress LTileSet:setAutoTileRule
    it("keeps four-way rule lookup deterministic across a bounded table", function()
        local tileset = lurek.tileset.newTileSet(1, 1024, 32, 16, 16)
        for mask = 0, 255 do
            tileset:setAutoTileRule("stress", mask, (mask % 1024) + 1)
        end
        for mask = 0, 255 do
            expect_equal((mask % 1024) + 1, tileset:getAutoTileId("stress", mask))
        end
    end)

    -- @stress lurek.tileset.newCatalog
    it("resolves sorted snapshot catalog entries", function()
        local first = build_provider()
        local second = lurek.tileset.newTileSet(1, 16, 4, 16, 16)
        local catalog = lurek.tileset.newCatalog({ zed = first, alpha = second })
        expect_equal("alpha", catalog:getIds()[1])
        expect_equal("LTileSet", catalog:getTileset("zed"):type())
        expect_equal("a.png", catalog:getVisual({ tileset = "zed", object = "a" }).image)
    end)
end)

test_summary()
