-- lurek.tilemap.newLargeMapRenderer unit tests
-- Headless-safe (no window / GPU / audio required).
-- Covers: LargeMapRenderer creation and method surface.

-- @description Covers suite: newLargeMapRenderer factory.
describe("newLargeMapRenderer factory", function()
    -- @covers lurek.tilemap.newLargeMapRenderer
    -- @description Verifies newLargeMapRenderer is a function.
    it("newLargeMapRenderer is a function", function()
        expect_type("function", lurek.tilemap.newLargeMapRenderer)
    end)

    -- @covers lurek.tilemap.newLargeMapRenderer
    -- @description Verifies newLargeMapRenderer returns a non-nil object.
    it("returns a non-nil object", function()
        local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
        expect_not_nil(lmr)
    end)

    -- @covers lurek.tilemap.newLargeMapRenderer
    -- @description Verifies invalid tile sizes produce an error.
    it("errors on zero tile width", function()
        expect_error(function()
            lurek.tilemap.newLargeMapRenderer(0, 16)
        end)
    end)

    -- @covers lurek.tilemap.newLargeMapRenderer
    -- @description Verifies invalid tile sizes produce an error.
    it("errors on zero tile height", function()
        expect_error(function()
            lurek.tilemap.newLargeMapRenderer(16, 0)
        end)
    end)
end)

-- @description Covers suite: LargeMapRenderer map data.
describe("LargeMapRenderer map data", function()
    -- @covers lurek.tilemap.LargeMapRenderer.setMapData
    -- @covers lurek.tilemap.LargeMapRenderer.getMapSize
    -- @description Verifies setMapData stores and getMapSize reflects width/height.
    it("setMapData + getMapSize round-trip", function()
        local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
        lmr:setMapData({0, 1, 0, 1}, 2, 2)
        local w, h = lmr:getMapSize()
        expect_equal(2, w)
        expect_equal(2, h)
    end)

    -- @covers lurek.tilemap.LargeMapRenderer.setTile
    -- @covers lurek.tilemap.LargeMapRenderer.getTile
    -- @description Verifies setTile and getTile round-trip a tile ID.
    it("setTile/getTile round-trip a tile ID", function()
        local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
        lmr:setMapData({0, 0, 0, 0}, 2, 2)
        lmr:setTile(0, 0, 42)
        expect_equal(42, lmr:getTile(0, 0))
    end)

    -- @covers lurek.tilemap.LargeMapRenderer.getTile
    -- @description Verifies getTile returns nil when out-of-bounds.
    it("getTile returns nil out-of-bounds", function()
        local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
        lmr:setMapData({0}, 1, 1)
        local v = lmr:getTile(99, 99)
        expect_equal(nil, v)
    end)
end)

-- @description Covers suite: LargeMapRenderer chunk settings.
describe("LargeMapRenderer chunk settings", function()
    -- @covers lurek.tilemap.LargeMapRenderer.setChunkSize
    -- @covers lurek.tilemap.LargeMapRenderer.getChunkSize
    -- @description Verifies setChunkSize and getChunkSize round-trip.
    it("setChunkSize/getChunkSize round-trip", function()
        local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
        lmr:setChunkSize(8)
        expect_equal(8, lmr:getChunkSize())
    end)

    -- @covers lurek.tilemap.LargeMapRenderer.setTilesetColumns
    -- @covers lurek.tilemap.LargeMapRenderer.getTilesetColumns
    -- @description Verifies setTilesetColumns and getTilesetColumns round-trip.
    it("setTilesetColumns/getTilesetColumns round-trip", function()
        local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
        lmr:setTilesetColumns(12)
        expect_equal(12, lmr:getTilesetColumns())
    end)
end)

-- @description Covers suite: LargeMapRenderer camera and viewport.
describe("LargeMapRenderer camera and viewport", function()
    -- @covers lurek.tilemap.LargeMapRenderer.setCamera
    -- @covers lurek.tilemap.LargeMapRenderer.getVisibleChunks
    -- @description Verifies setCamera + setViewport allow getVisibleChunks to run without error.
    it("setCamera and setViewport do not error", function()
        local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
        lmr:setViewport(640, 480)
        lmr:setCamera(0, 0, 1.0)
        local v = lmr:getVisibleChunks()
        expect_true(v >= 0)
    end)

    -- @covers lurek.tilemap.LargeMapRenderer.getTotalChunks
    -- @description Verifies getTotalChunks returns a non-negative integer.
    it("getTotalChunks returns non-negative", function()
        local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
        expect_true(lmr:getTotalChunks() >= 0)
    end)
end)

-- @description Covers suite: LargeMapRenderer LOD settings.
describe("LargeMapRenderer LOD settings", function()
    -- @covers lurek.tilemap.LargeMapRenderer.setLodEnabled
    -- @covers lurek.tilemap.LargeMapRenderer.isLodEnabled
    -- @description Verifies setLodEnabled/isLodEnabled round-trip.
    it("setLodEnabled true / isLodEnabled returns true", function()
        local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
        lmr:setLodEnabled(true)
        expect_true(lmr:isLodEnabled())
    end)

    -- @covers lurek.tilemap.LargeMapRenderer.setLodEnabled
    -- @covers lurek.tilemap.LargeMapRenderer.isLodEnabled
    -- @description Verifies LOD can be disabled again.
    it("setLodEnabled false / isLodEnabled returns false", function()
        local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
        lmr:setLodEnabled(true)
        lmr:setLodEnabled(false)
        expect_false(lmr:isLodEnabled())
    end)

    -- @covers lurek.tilemap.LargeMapRenderer.setLodThresholds
    -- @description Verifies setLodThresholds does not error.
    it("setLodThresholds accepts a table of thresholds", function()
        local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
        lmr:setLodThresholds({100, 200, 400})
    end)
end)

-- @description Covers suite: LargeMapRenderer invalidation.
describe("LargeMapRenderer invalidation", function()
    -- @covers lurek.tilemap.LargeMapRenderer.invalidateAll
    -- @description Verifies invalidateAll does not error.
    it("invalidateAll does not error", function()
        local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
        lmr:invalidateAll()
    end)

    -- @covers lurek.tilemap.LargeMapRenderer.invalidateChunk
    -- @description Verifies invalidateChunk does not error.
    it("invalidateChunk does not error", function()
        local lmr = lurek.tilemap.newLargeMapRenderer(16, 16)
        lmr:invalidateChunk(0, 0)
    end)
end)

test_summary()
