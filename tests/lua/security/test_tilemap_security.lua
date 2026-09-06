-- Adversarial coverage for bounded tilemap storage, imports, numeric inputs, and chunk bytes.

local function tilemap_with_layer()
    local map = lurek.tilemap.newTileMap(16, 16, 8)
    map:addLayer("ground", 2, 2)
    return map
end

local function large_renderer()
    return lurek.tilemap.newLargeMapRenderer(16, 16)
end

local function chunk_bytes()
    local map = lurek.tilemap.newChunkMap(2)
    map:loadChunk(0, 0)
    return map:chunkToBytes(0, 0)
end

local function chunk_map(chunk_size, opts)
    return lurek.tilemap.newChunkMap(chunk_size, opts)
end

-- @describe tilemap hostile inputs
describe("tilemap hostile inputs", function()
    -- @security lurek.tilemap.newChunkMap
    it("rejects oversized chunks before allocation", function()
        expect_error(function()
            lurek.tilemap.newChunkMap(64, { maxChunkCells = 16 })
        end)
    end)

    -- @security LChunkMap:loadChunk
    it("rejects loaded-chunk growth", function()
        local map = chunk_map(2, { maxChunks = 1 })
        map:loadChunk(0, 0)
        expect_error(function()
            map:loadChunk(1, 0)
        end)
    end)
    local function __audit_security_1()
        local renderer = lurek.tilemap.newLargeMapRenderer(16, 16)
        expect_error(function()
            renderer:setMapData({ 1, 2, 3 }, 2, 2)
        end)
    end


    -- @security LLargeMapRenderer:setMapData
    it("rejects mismatched dense renderer payloads", function()
        __audit_security_1()
    end)

    -- @security lurek.tilemap.loadTMX
    it("rejects oversized layers and unsafe external paths", function()
        local oversized = [[
            <map width="100" height="100" tilewidth="16" tileheight="16" orientation="orthogonal"></map>
        ]]
        local map, err = lurek.tilemap.loadTMX(oversized, { maxTiles = 64 })
        expect_nil(map)
        expect_true(err ~= nil)
        local traversal = [[
            <map width="1" height="1" tilewidth="16" tileheight="16" orientation="orthogonal">
              <tileset firstgid="1" source="../escape.tsx" />
            </map>
        ]]
        local parsed, path_err = lurek.tilemap.loadTMX(traversal, {
            allowExternalTilesets = true,
            safePaths = true,
        })
        expect_nil(parsed)
        expect_true(path_err ~= nil)
    end)

    -- @security LTileMap:setViewport
    it("rejects non-finite viewport values", function()
        local map = tilemap_with_layer()
        expect_error(function()
            map:setViewport(0, 0, 0 / 0, 32)
        end)
    end)

    -- @security LLargeMapRenderer:setLodThresholds
    it("rejects non-finite and non-positive LOD thresholds", function()
        local renderer = large_renderer()
        expect_error(function()
            renderer:setLodThresholds({ 1, 0 / 0 })
        end)
        expect_error(function()
            renderer:setLodThresholds({ 0 })
        end)
    end)

    -- @security LChunkMap:loadChunkFromBytes
    it("rejects truncated and version-corrupt chunk bytes", function()
        local bytes = chunk_bytes()
        local clone = chunk_map(2)
        expect_error(function()
            clone:loadChunkFromBytes(0, 0, string.sub(bytes, 1, #bytes - 1))
        end)
        expect_error(function()
            clone:loadChunkFromBytes(0, 0, "LCM1" .. string.sub(bytes, 5))
        end)
    end)
end)

test_summary()
