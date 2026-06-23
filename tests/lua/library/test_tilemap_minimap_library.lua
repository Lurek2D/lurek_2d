-- Lurek2D Library Tilemap Minimap Tests
-- @testCategory library

local TilemapMinimap = require("library.tilemap_minimap")

local function build_map()
    local map = {
        tw = 32,
        th = 32,
        solids = {
            ["2:1"] = true,
            ["3:2"] = true,
        },
    }

    function map:isSolid(_, x, y)
        return self.solids[x .. ":" .. y] == true
    end

    function map:worldToTile(wx, wy)
        return math.floor(wx / self.tw) + 1, math.floor(wy / self.th) + 1
    end

    return map
end

-- @describe tilemap_minimap library
describe("tilemap_minimap library", function()
    -- @library lurek.library_tilemap_minimap
    it("syncs solidity into minimap terrain values", function()
        local map = build_map()
        local helper = TilemapMinimap.new({
            map = map,
            layer = 1,
            width = 4,
            height = 3,
            solid_terrain = 9,
            empty_terrain = 1,
        })

        local mm = helper:getMinimap()
        expect_equal(mm:getTerrain(2, 1), 9, "solid cell must map to solid terrain id")
        expect_equal(mm:getTerrain(1, 1), 1, "empty cell must map to empty terrain id")
    end)

    -- @library lurek.library_tilemap_minimap
    it("centers minimap from world coordinates", function()
        local map = build_map()
        local helper = TilemapMinimap.new({ map = map, layer = 1, width = 4, height = 3 })

        local tx, ty = helper:setCenterFromWorld(48, 16)
        expect_equal(tx, 2, "world x should map to tile x")
        expect_equal(ty, 1, "world y should map to tile y")

        local cx, cy = helper:getMinimap():getCenter()
        expect_equal(cx, 2, "minimap center x should be updated")
        expect_equal(cy, 1, "minimap center y should be updated")
    end)

    -- @library lurek.library_tilemap_minimap
    it("applies and clears viewport overlay without error", function()
        local map = build_map()
        local helper = TilemapMinimap.new({ map = map, layer = 1, width = 4, height = 3 })

        local ok_set = pcall(function()
            helper:setViewportFromWorld(0, 0, 64, 64)
        end)
        local ok_clear = pcall(function()
            helper:clearViewport()
        end)

        expect_true(ok_set, "setViewportFromWorld should not fail")
        expect_true(ok_clear, "clearViewport should not fail")
        if helper:getMinimap().getViewportRect then
            expect_nil(helper:getMinimap():getViewportRect(), "viewport rect should clear on real LMinimap")
        end
    end)
end)
test_summary()
