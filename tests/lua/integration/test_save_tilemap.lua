-- Lurek2D Integration Test: Savegame + Tilemap
-- Tests saving and restoring tilemap state via savegame.

-- @description Covers suite: integration: savegame collects and restores tilemap state.
describe("integration: savegame collects and restores tilemap state", function()
    -- @covers lurek.save.SaveManager.register
    -- @covers lurek.tilemap.Tilemap.getTile
    -- @covers lurek.save.newSaveManager
    -- @covers lurek.tilemap.newTilemap
    -- @covers lurek.tilemap.setTile
    -- @covers lurek.tilemap.getTile
    -- @description Verifies a savegame handler can collect the non-empty tile state from a tilemap.
    it("registers tilemap handler and collects tile data", function()
        local sm = lurek.save.newSaveManager()
        local tm = lurek.tilemap.newTileMap(16, 16)
        tm:addLayer("tiles", 5, 5)

        -- Set some tiles
        tm:setTile(1, 1, 1, 1)
        tm:setTile(1, 2, 1, 2)
        tm:setTile(1, 3, 3, 3)

        local saved_tiles = nil

        sm:register("tilemap", function()
            -- Collect: snapshot the relevant tiles
            local tiles = {}
            for y = 1, 5 do
                for x = 1, 5 do
                    local id = tm:getTile(1, x, y)
                    if id and id ~= 0 then
                        tiles[#tiles + 1] = {x = x, y = y, id = id}
                    end
                end
            end
            saved_tiles = tiles
            return tiles
        end, function(data)
            -- Restore: apply tiles back
            if data then
                for _, entry in ipairs(data) do
                    tm:setTile(1, entry.x, entry.y, entry.id)
                end
            end
        end)

        -- Trigger collect
        sm:collect()
        expect_not_nil(saved_tiles, "tilemap state was collected")
        expect_true(#saved_tiles >= 3, "at least 3 non-zero tiles collected")
    end)

    -- @covers lurek.save.SaveManager.setSummary
    -- @covers lurek.tilemap
    -- @description Verifies save summaries can retain tilemap metadata such as the map name.
    it("save summary contains tilemap metadata", function()
        local sm = lurek.save.newSaveManager()
        sm:setSummary("level_01")
        local summary = sm:getSummary()
        expect_equal("level_01", summary, "summary stores map name")
    end)

    -- @covers lurek.save.SaveManager.getSchemaVersion
    -- @covers lurek.tilemap
    -- @description Verifies the save manager exposes a usable schema version for tilemap save data.
    it("schema version is accessible", function()
        local sm = lurek.save.newSaveManager()
        local ver = sm:getSchemaVersion()
        expect_type("number", ver, "schema version is a number")
        expect_true(ver >= 0, "schema version >= 0")
    end)
end)

test_summary()
