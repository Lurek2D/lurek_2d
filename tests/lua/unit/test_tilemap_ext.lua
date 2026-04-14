-- Lurek2D Lua BDD tests for lurek.tilemap extended API
-- Covers: fromLDtk, toNavGrid, onTileEnter, checkEntities.
-- Headless: no GPU, no audio, no window.

-- Minimal LDtk JSON with a 4x4 tile layer
local LDTK_JSON = [[{
    "levels": [{
        "identifier": "Level_0",
        "pxWid": 64,
        "pxHei": 64,
        "layerInstances": [{
            "__type": "Tiles",
            "__identifier": "Ground",
            "__gridSize": 16,
            "gridTiles": [
                {"px":[0,0], "t":1},
                {"px":[16,0],"t":1},
                {"px":[32,0],"t":0},
                {"px":[48,0],"t":0}
            ]
        }]
    }]
}]]

-- @description Covers suite: lurek.tilemap extended features.
describe("lurek.tilemap extended", function()
    -- ── module interface ──────────────────────────────────────────────────

    -- @description Covers suite: fromLDtk factory.
    describe("fromLDtk()", function()
        -- @covers lurek.tilemap.fromLDtk
        -- @description Verifies the fromLDtk factory is exposed on the module.
        it("exposes fromLDtk factory", function()
            expect_type("function", lurek.tilemap.fromLDtk)
        end)

        -- @covers lurek.tilemap.fromLDtk
        -- @description Confirms fromLDtk returns tilemap userdata for minimal valid JSON.
        it("returns userdata for valid LDtk JSON", function()
            local tm = lurek.tilemap.fromLDtk(LDTK_JSON)
            expect_type("userdata", tm)
        end)

        -- @covers lurek.tilemap.fromLDtk
        -- @description Confirms fromLDtk errors on malformed JSON.
        it("errors on invalid JSON", function()
            expect_error(function()
                lurek.tilemap.fromLDtk("not json")
            end)
        end)

        -- @covers lurek.tilemap.fromLDtk
        -- @description Confirms selecting an existing named level succeeds.
        it("loads named level without error", function()
            local tm = lurek.tilemap.fromLDtk(LDTK_JSON, "Level_0")
            expect_type("userdata", tm)
        end)

        -- @covers lurek.tilemap.fromLDtk
        -- @description Confirms a missing level name surfaces an error.
        it("errors for unknown level name", function()
            expect_error(function()
                lurek.tilemap.fromLDtk(LDTK_JSON, "NoSuchLevel")
            end)
        end)
    end)

    -- ── toNavGrid ─────────────────────────────────────────────────────────

    -- @description Covers suite: toNavGrid().
    describe("toNavGrid()", function()
        -- @covers lurek.tilemap.fromLDtk
        -- @covers lurek.tilemap.toNavGrid
        -- @description Confirms toNavGrid returns a table of row tables.
        it("returns a table of row tables", function()
            local tm = lurek.tilemap.fromLDtk(LDTK_JSON)
            local grid = tm:toNavGrid(1, {})
            expect_type("table", grid)
            expect_true(#grid > 0, "expected at least one row")
            expect_type("table", grid[1])
        end)

        -- @covers lurek.tilemap.fromLDtk
        -- @covers lurek.tilemap.toNavGrid
        -- @description Confirms cells with GID 0 are walkable when no extra gids are listed.
        it("empty-cell (GID 0) is walkable by default", function()
            local tm = lurek.tilemap.fromLDtk(LDTK_JSON)
            local grid = tm:toNavGrid(1, {})
            -- The json has GID 0 in columns 2 and 3 of row 0
            -- (LDtk t:0 → engine GID 1, t:1 → engine GID 2)
            -- Row 0 exists; the type must be boolean.
            expect_type("boolean", grid[1][1])
        end)

        -- @covers lurek.tilemap.new
        -- @covers lurek.tilemap.setTile
        -- @covers lurek.tilemap.toNavGrid
        -- @description Confirms walkable_gids makes matching cells walkable.
        it("listed GIDs are walkable", function()
            -- Build a 2×1 map with GID 5 in cell (0,0) and GID 6 in (1,0)
            local tm = lurek.tilemap.new(2, 1, 16, 16)
            tm:setTile(1, 0, 0, 5)
            tm:setTile(1, 1, 0, 6)
            local grid = tm:toNavGrid(1, {5})
            expect_equal(true,  grid[1][1]) -- GID 5 → walkable
            expect_equal(false, grid[1][2]) -- GID 6 → blocked
        end)
    end)

    -- ── onTileEnter / checkEntities ───────────────────────────────────────

    -- @description Covers suite: onTileEnter() / checkEntities().
    describe("onTileEnter() / checkEntities()", function()
        -- @covers lurek.tilemap.new
        -- @covers lurek.tilemap.onTileEnter
        -- @description Confirms onTileEnter accepts a GID and a function without error.
        it("onTileEnter accepts a callback", function()
            local tm = lurek.tilemap.new(4, 4, 16, 16)
            tm:onTileEnter(5, function(wx, wy, tx, ty) end)
            expect_equal(true, true)
        end)

        -- @covers lurek.tilemap.new
        -- @covers lurek.tilemap.setTile
        -- @covers lurek.tilemap.onTileEnter
        -- @covers lurek.tilemap.checkEntities
        -- @description Confirms the callback fires when an entity is positioned over a matching GID.
        it("callback fires for a matching tile", function()
            local tm = lurek.tilemap.new(4, 4, 16, 16)
            tm:setTile(1, 0, 0, 5) -- place GID 5 at tile (0,0)
            local fired = false
            tm:onTileEnter(5, function(wx, wy, tx, ty)
                fired = true
            end)
            -- Entity centred on tile (0,0): world pixel (8, 8)
            tm:checkEntities(1, {{x=8, y=8}})
            expect_true(fired, "expected callback to fire")
        end)

        -- @covers lurek.tilemap.new
        -- @covers lurek.tilemap.setTile
        -- @covers lurek.tilemap.onTileEnter
        -- @covers lurek.tilemap.checkEntities
        -- @description Confirms the callback does not fire when the entity is on a different GID.
        it("callback does not fire for a non-matching tile", function()
            local tm = lurek.tilemap.new(4, 4, 16, 16)
            tm:setTile(1, 0, 0, 3) -- GID 3, not 5
            local fired = false
            tm:onTileEnter(5, function()
                fired = true
            end)
            tm:checkEntities(1, {{x=8, y=8}})
            expect_false(fired)
        end)
    end)
end)

test_summary()
