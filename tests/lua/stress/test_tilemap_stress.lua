-- Lurek2D Stress Test: Large Tilemap Operations
-- Tests creating and manipulating large tilemaps at scale

local function new_tilemap_with_tileset(tile_size)
    local map = lurek.tilemap.newTileMap(32, 32, tile_size or 16)
    local ts = lurek.tilemap.newTileSet(1, 256, 16, 32, 32, 0, 0)
    map:addTileSet(ts)
    return map
end

local function fill_map_layer(map, layer_index, width, height, gid)
    for y = 1, height do
        for x = 1, width do
            map:setTile(layer_index, x, y, gid)
        end
    end
end

local function new_filled_tilemap(width, height, gid)
    local map = new_tilemap_with_tileset(16)
    map:addLayer("ground", width, height)
    fill_map_layer(map, 1, width, height, gid)
    return map
end

local function new_pattern_tilemap(width, height)
    local map = new_tilemap_with_tileset(16)
    map:addLayer("ground", width, height)
    for y = 1, height do
        for x = 1, width do
            local gid = ((x + y) % 255) + 1
            map:setTile(1, x, y, gid)
        end
    end
    return map
end

local function filled_map_with_layer(width, height, gid)
    local map = new_tilemap_with_tileset(16)
    map:addLayer("ground", width, height)
    map:fill(1, gid)
    return map
end

local function new_multilayer_tilemap(layer_count, width, height)
    local map = new_tilemap_with_tileset(16)
    for i = 1, layer_count do
        map:addLayer("layer_" .. i, width, height)
    end
    return map
end

local function chunkmap_roundtrip(chunk_size, x, y, gid)
    local cm = lurek.tilemap.newChunkMap(chunk_size)
    cm:setTile(x, y, gid)
    return cm, cm:getTile(x, y)
end

local function sparse_negative_view()
    local cm = lurek.tilemap.newChunkMap(32)
    cm:setTile(-1000, -1000, 3)
    cm:setTile(1000000, 1000000, 4)
    return cm:getChunksInView(-17000, -17000, 4096, 4096, 16, 16)
end

local function assert_renderer_snapshot(renderer, expected)
    local width, height = renderer:getMapSize()
    expect_equal(128, width, "renderer snapshot width")
    expect_equal(128, height, "renderer snapshot height")
    expect_equal(expected, renderer:getTile(127, 127), "snapshot last tile")
end

local function new_snapshot_renderer()
    return lurek.tilemap.newLargeMapRenderer(16, 16)
end

-- @describe tilemap stress: large map creation
describe("tilemap stress: large map creation", function()
    -- @stress lurek.tilemap.newTileMap
    it("creates a 500x500 tilemap and fills it", function()
        local map = new_filled_tilemap(500, 500, 1)
        expect_type("userdata", map)
        expect_equal(1, map:getTile(1, 1, 1), "top-left tile")
        expect_equal(1, map:getTile(1, 500, 500), "bottom-right tile")
        expect_equal(1, map:getTile(1, 250, 250), "center tile")
    end)

    -- @stress LTileMap:getTile
    it("reads back all tiles from a 200x200 map", function()
        local map = new_pattern_tilemap(200, 200)
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

    -- @stress LTileMap:addLayer
    it("handles multiple layers on a 100x100 map", function()
        local map = new_multilayer_tilemap(5, 100, 100)
        for layer = 1, 5 do
            for y = 1, 100 do
                for x = 1, 100 do
                    map:setTile(layer, x, y, layer)
                end
            end
        end

        for layer = 1, 5 do
            expect_equal(layer, map:getTile(layer, 50, 50), "layer " .. layer .. " center tile")
        end
    end)
end)

-- @describe tilemap stress: fill operations
describe("tilemap stress: fill operations", function()
    -- @stress LTileMap:fill
    it("fills entire layer with one GID", function()
        local map = new_tilemap_with_tileset(16)
        map:addLayer("ground", 100, 100)
        map:fill(1, 42)

        expect_equal(42, map:getTile(1, 1, 1), "fill top-left")
        expect_equal(42, map:getTile(1, 100, 100), "fill bottom-right")
        expect_equal(42, map:getTile(1, 50, 50), "fill center")
    end)

    -- @stress LTileMap:setTile
    it("setTile overwrites filled area", function()
        local map = new_tilemap_with_tileset(16)
        map:addLayer("ground", 100, 100)
        map:fill(1, 42)
        map:setTile(1, 50, 50, 99)
        expect_equal(99, map:getTile(1, 50, 50), "overwritten tile")
        expect_equal(42, map:getTile(1, 49, 49), "untouched tile")
    end)

    -- @stress lurek.tilemap.newChunkMap
    it("ChunkMap setTile/getTile roundtrip", function()
        local cm, value = chunkmap_roundtrip(16, 5, 5, 42)
        expect_type("userdata", cm)
        expect_equal(42, value, "chunk tile preserved")
    end)
end)

-- @describe tilemap stress: bounded indexes, culling, and renderer snapshots
describe("tilemap stress: bounded indexes, culling, and renderer snapshots", function()
    -- @stress LTileMap:tileTypeIndex
    it("rebuilds a dense reverse index after a large fill", function()
        local map = filled_map_with_layer(1024, 1024, 7)
        local index = map:tileTypeIndex(1)
        expect_type("table", index)
        expect_equal(1024 * 1024, #index[7], "reverse index cell count")
    end)

    -- @stress LChunkMap:getChunksInView
    it("culls a view spanning negative sparse chunk coordinates", function()
        local visible = sparse_negative_view()
        expect_type("table", visible)
        expect_true(#visible > 0, "negative-coordinate view has chunks")
    end)

    -- @stress LLargeMapRenderer:setMapData
    it("updates a bounded dense renderer snapshot without rebuilding a map owner", function()
        local renderer = new_snapshot_renderer()
        local data = {}
        for i = 1, 128 * 128 do
            data[i] = (i % 31) + 1
        end
        renderer:setMapData(data, 128, 128)
        assert_renderer_snapshot(renderer, data[128 * 128])
    end)

    -- @stress LTileMap:getDiagnostics
    it("keeps guarded query diagnostics observable after bulk work", function()
        local map = filled_map_with_layer(128, 128, 5)
        local diagnostics = map:getDiagnostics()
        expect_type("table", diagnostics)
        expect_true(diagnostics.invalidQueries >= 0, "diagnostics counter is observable")
    end)

    -- @stress lurek.tilemap.loadTMX
    it("keeps bounded importer work finite for a decoded map", function()
        local xml = [[
            <map width="64" height="64" tilewidth="16" tileheight="16" orientation="orthogonal"></map>
        ]]
        local parsed, err = lurek.tilemap.loadTMX(xml, {
            maxImportBytes = 4096,
            maxDecodedBytes = 8192,
            maxTiles = 4096,
        })
        expect_nil(err)
        expect_type("table", parsed)
    end)
end)
test_summary()
