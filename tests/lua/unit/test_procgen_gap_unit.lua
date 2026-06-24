-- Gap coverage for typed procgen grid APIs.

local procgen = lurek.procgen

local function int_grid()
    return procgen.newGridResult(2, 2, { 1, 2, 3, 4 }, { kind = "manual_grid" })
end

local function scalar_grid()
    return procgen.newScalarGridResult(2, 2, { 0.1, 0.6, 0.2, 0.9 }, { kind = "manual_scalar" })
end

local function small_opts()
    return { width = 8, height = 6, max_rooms = 3, min_room_size = 2, max_room_size = 3, seed = 11 }
end

-- @describe procgen typed constructors
describe("procgen typed constructors", function()
    -- @covers lurek.procgen.roomsDungeonWithPrefabsGrid
    it("returns rooms dungeon prefab grids", function()
        local grid = procgen.roomsDungeonWithPrefabsGrid(small_opts(), {
            { name = "chest", width = 1, height = 1 },
        }, 3)
        expect_equal("LProcgenGrid", grid:type())
        expect_equal(8, grid:getWidth())
    end)

    -- @covers lurek.procgen.heightmapGrid
    it("returns typed heightmap grids", function()
        local grid = procgen.heightmapGrid({ width = 4, height = 3, seed = 7, erosion_passes = 0 })
        expect_equal("heightmap", grid:getKind())
        expect_equal(4, grid:getWidth())
    end)

    -- @covers lurek.procgen.heightmapFromCellularGrid
    it("returns typed heightmaps from cellular grids", function()
        local grid = procgen.heightmapFromCellularGrid(3, 2, { 0, 1, 0, 1, 0, 1 }, 0)
        expect_equal("heightmap_from_cellular", grid:getKind())
        expect_equal(3, grid:getWidth())
    end)

    -- @covers lurek.procgen.noiseMapGrid
    it("returns typed noise grids", function()
        local grid = procgen.noiseMapGrid(3, 2, { seed = 5, scale_x = 4, scale_y = 4, octaves = 1 })
        expect_equal("noise_map", grid:getKind())
        expect_equal(6, #grid:toTable().cells)
    end)

    -- @covers lurek.procgen.noiseMapParallelGrid
    it("returns typed parallel noise grids", function()
        local grid = procgen.noiseMapParallelGrid(3, 2, { scale_x = 4, scale_y = 4, octaves = 1 })
        expect_equal("noise_map_parallel", grid:getKind())
        expect_equal(2, grid:getHeight())
    end)

    -- @covers lurek.procgen.noiseMapParallelSeededGrid
    it("returns typed seeded parallel noise grids", function()
        local grid = procgen.noiseMapParallelSeededGrid(3, 2, { seed = 9, scale_x = 4, scale_y = 4, octaves = 1 })
        expect_equal("noise_map_parallel_seeded", grid:getKind())
        expect_equal(3, grid:getWidth())
    end)

    -- @covers LNoiseGenerator:generateMapGrid
    it("returns generator scalar grids", function()
        local grid = procgen.newNoiseGenerator(3):generateMapGrid(3, 2, { scaleX = 4, scaleY = 4, octaves = 1 })
        expect_equal("noise_map", grid:getKind())
        expect_equal(3, grid:getWidth())
    end)

    -- @covers LNoiseGenerator:generateMapComputeGrid
    it("returns generator compute scalar grids", function()
        local grid = procgen.newNoiseGenerator(4):generateMapComputeGrid(3, 2, { scaleX = 4, scaleY = 4, octaves = 1 })
        expect_equal("noise_map", grid:getKind())
        expect_equal(2, grid:getHeight())
    end)
end)

-- @describe LProcgenGrid methods
describe("LProcgenGrid methods", function()
    -- @covers LProcgenGrid:getSize
    it("returns integer grid size", function()
        local w, h = int_grid():getSize()
        expect_equal(2, w)
        expect_equal(2, h)
    end)

    -- @covers LProcgenGrid:getWidth
    it("returns integer grid width", function()
        expect_equal(2, int_grid():getWidth())
    end)

    -- @covers LProcgenGrid:getHeight
    it("returns integer grid height", function()
        expect_equal(2, int_grid():getHeight())
    end)

    -- @covers LProcgenGrid:getKind
    it("returns integer grid kind", function()
        expect_equal("manual_grid", int_grid():getKind())
    end)

    -- @covers LProcgenGrid:getCell
    it("returns integer grid cells", function()
        expect_equal(3, int_grid():getCell(1, 2))
    end)

    -- @covers LProcgenGrid:toTable
    it("serializes integer grid tables", function()
        local table_result = int_grid():toTable()
        expect_equal("manual_grid", table_result.kind)
        expect_equal(4, #table_result.cells)
    end)

    -- @covers LProcgenGrid:toTileField
    it("converts integer grid to tilefield refs", function()
        local field = int_grid():toTileField({ slot = "terrain" })
        expect_equal(4, field:getRef(2, 2, 1, "terrain"))
    end)

    -- @covers LProcgenGrid:writeTileField
    it("writes integer grid into tilefield refs", function()
        local field = lurek.tilefield.new({ width = 2, height = 2 })
        int_grid():writeTileField(field, { slot = "terrain" })
        expect_equal(2, field:getRef(2, 1, 1, "terrain"))
    end)

    -- @covers LProcgenGrid:type
    it("reports integer grid type", function()
        expect_equal("LProcgenGrid", int_grid():type())
    end)

    -- @covers LProcgenGrid:typeOf
    it("matches integer grid type", function()
        expect_true(int_grid():typeOf("LProcgenGrid"))
    end)
end)

-- @describe LProcgenScalarGrid methods
describe("LProcgenScalarGrid methods", function()
    -- @covers LProcgenScalarGrid:getSize
    it("returns scalar grid size", function()
        local w, h = scalar_grid():getSize()
        expect_equal(2, w)
        expect_equal(2, h)
    end)

    -- @covers LProcgenScalarGrid:getWidth
    it("returns scalar grid width", function()
        expect_equal(2, scalar_grid():getWidth())
    end)

    -- @covers LProcgenScalarGrid:getHeight
    it("returns scalar grid height", function()
        expect_equal(2, scalar_grid():getHeight())
    end)

    -- @covers LProcgenScalarGrid:getKind
    it("returns scalar grid kind", function()
        expect_equal("manual_scalar", scalar_grid():getKind())
    end)

    -- @covers LProcgenScalarGrid:getCell
    it("returns scalar grid cells", function()
        expect_near(0.2, scalar_grid():getCell(1, 2), 0.00001)
    end)

    -- @covers LProcgenScalarGrid:toTable
    it("serializes scalar grid tables", function()
        local table_result = scalar_grid():toTable()
        expect_equal("manual_scalar", table_result.kind)
        expect_equal(4, #table_result.cells)
    end)

    -- @covers LProcgenScalarGrid:toTileField
    it("converts scalar grid to tilefield blocks", function()
        local field = scalar_grid():toTileField({ target = "block", channel = "move", threshold = 0.5 })
        expect_false(field:blocks(1, 1, 1, "move"))
        expect_true(field:blocks(2, 1, 1, "move"))
    end)

    -- @covers LProcgenScalarGrid:writeTileField
    it("writes scalar grid into tilefield costs", function()
        local field = lurek.tilefield.new({ width = 2, height = 2 })
        scalar_grid():writeTileField(field, { target = "cost", channel = "move", scale = 10 })
        expect_near(9.0, field:getCost(2, 2, 1, "move"), 0.00001)
    end)

    -- @covers LProcgenScalarGrid:type
    it("reports scalar grid type", function()
        expect_equal("LProcgenScalarGrid", scalar_grid():type())
    end)

    -- @covers LProcgenScalarGrid:typeOf
    it("matches scalar grid type", function()
        expect_true(scalar_grid():typeOf("LProcgenScalarGrid"))
    end)
end)

test_summary()
