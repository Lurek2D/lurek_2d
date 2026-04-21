-- Lurek2D Stress Test: Large Tilemap Operations
-- Tests creating and manipulating large tilemaps at scale

-- @description Covers suite: tilemap stress: large map creation.
describe("tilemap stress: large map creation", function()
    -- @covers lurek.tilemap.newTileMap
    -- @covers lurek.tilemap.newTileSet
    -- @covers TileMap:addTileSet
    -- @covers TileMap:addLayer
    -- @covers TileMap:setTile
    -- @covers TileMap:getTile
    -- @stress Fills a 500x500 layer cell by cell after constructing one tilemap, tileset, and layer.
    -- @description Stresses large-map write throughput by materializing a quarter-million tiles and then spot-checking key positions.
    it("creates a 500x500 tilemap and fills it", function()
        local map = lurek.tilemap.newTileMap(32, 32, 16)
        local ts = lurek.tilemap.newTileSet(1, 256, 16, 32, 32, 0, 0)
        map:addTileSet(ts)
        map:addLayer("ground", 500, 500)

        -- TileMap coords are 1-based
        for y = 1, 500 do
            for x = 1, 500 do
                map:setTile(1, x, y, 1)
            end
        end

        -- Verify corners (1-based)
        expect_equal(1, map:getTile(1, 1, 1), "top-left tile")
        expect_equal(1, map:getTile(1, 500, 500), "bottom-right tile")
        expect_equal(1, map:getTile(1, 250, 250), "center tile")
    end)

    -- @covers lurek.tilemap.newTileMap
    -- @covers lurek.tilemap.newTileSet
    -- @covers TileMap:setTile
    -- @covers TileMap:getTile
    -- @stress Writes and validates every cell of a 200x200 patterned tile layer.
    -- @description Stresses round-trip tile storage by filling a medium map with a computed GID pattern and checking every tile for mismatches.
    it("reads back all tiles from a 200x200 map", function()
        local map = lurek.tilemap.newTileMap(32, 32, 16)
        local ts = lurek.tilemap.newTileSet(1, 256, 16, 32, 32, 0, 0)
        map:addTileSet(ts)
        map:addLayer("ground", 200, 200)

        -- Fill with pattern: tile ID = ((x + y) % 255) + 1 (1-based coords)
        for y = 1, 200 do
            for x = 1, 200 do
                local gid = ((x + y) % 255) + 1
                map:setTile(1, x, y, gid)
            end
        end

        -- Verify pattern
        local mismatches = 0
        for y = 1, 200 do
            for x = 1, 200 do
                local expected = ((x + y) % 255) + 1
                if map:getTile(1, x, y) ~= expected then
                    mismatches = mismatches + 1
                end
            end
        end
        expect_equal(0, mismatches, "all tiles match expected pattern")
    end)

    -- @covers lurek.tilemap.newTileMap
    -- @covers TileMap:addLayer
    -- @covers TileMap:setTile
    -- @covers TileMap:getTile
    -- @stress Populates five separate 100x100 layers and samples each one independently.
    -- @description Stresses multilayer bookkeeping by filling multiple layers with layer-specific values and verifying no cross-layer contamination.
    it("handles multiple layers on a 100x100 map", function()
        local map = lurek.tilemap.newTileMap(32, 32, 16)
        local ts = lurek.tilemap.newTileSet(1, 256, 16, 32, 32, 0, 0)
        map:addTileSet(ts)

        -- Create 5 layers (1-based indices)
        for i = 1, 5 do
            map:addLayer("layer_" .. i, 100, 100)
        end

        -- Fill each layer (1-based layer and coords)
        for layer = 1, 5 do
            for y = 1, 100 do
                for x = 1, 100 do
                    map:setTile(layer, x, y, layer)
                end
            end
        end

        -- Verify each layer independently
        for layer = 1, 5 do
            expect_equal(layer, map:getTile(layer, 50, 50), "layer " .. layer .. " center tile")
        end
    end)
end)

-- @description Covers suite: tilemap stress: fill operations.
describe("tilemap stress: fill operations", function()
    -- @covers lurek.tilemap.newTileMap
    -- @covers TileMap:fill
    -- @covers TileMap:getTile
    -- @stress Fills an entire 100x100 layer with one GID and samples multiple cells.
    -- @description Stresses bulk fill-path throughput by replacing all tiles in one layer with a constant value and verifying representative positions.
    it("fills entire layer with one GID", function()
        local map = lurek.tilemap.newTileMap(32, 32, 16)
        local ts = lurek.tilemap.newTileSet(1, 256, 16, 32, 32, 0, 0)
        map:addTileSet(ts)
        map:addLayer("ground", 100, 100)

        map:fill(1, 42)

        expect_equal(42, map:getTile(1, 1, 1), "fill top-left")
        expect_equal(42, map:getTile(1, 100, 100), "fill bottom-right")
        expect_equal(42, map:getTile(1, 50, 50), "fill center")
    end)

    -- @covers lurek.tilemap.newTileMap
    -- @covers TileMap:fill
    -- @covers TileMap:setTile
    -- @covers TileMap:getTile
    -- @stress Fills a 100x100 layer once, then overwrites and verifies one hot cell.
    -- @description Stresses interaction between bulk fill and single-cell mutation by validating that a targeted write wins over the filled background.
    it("setTile overwrites filled area", function()
        local map = lurek.tilemap.newTileMap(32, 32, 16)
        local ts = lurek.tilemap.newTileSet(1, 256, 16, 32, 32, 0, 0)
        map:addTileSet(ts)
        map:addLayer("ground", 100, 100)

        map:fill(1, 42)
        map:setTile(1, 50, 50, 99)
        expect_equal(99, map:getTile(1, 50, 50), "overwritten tile")
        expect_equal(42, map:getTile(1, 49, 49), "untouched tile")
    end)

    -- @covers lurek.tilemap.newChunkMap
    -- @covers ChunkMap:setTile
    -- @covers ChunkMap:getTile
    -- @stress Performs one set/get round trip on a chunk map to validate chunk-backed tile storage.
    -- @description Exercises the chunk map path separately from full TileMap storage by writing and reading a single chunked cell.
    it("ChunkMap setTile/getTile roundtrip", function()
        -- ChunkMap: no layer param, 0-based coords
        local cm = lurek.tilemap.newChunkMap(16)
        cm:setTile(5, 5, 42)
        expect_equal(42, cm:getTile(5, 5), "chunk tile preserved")
    end)
end)

test_summary()
