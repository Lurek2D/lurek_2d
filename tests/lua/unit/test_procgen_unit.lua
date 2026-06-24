-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_procgen_core_unit.lua
do
-- Lurek2D procgen unit tests
-- One owner test per public lurek.procgen function.

local procgen = lurek.procgen

local function expect_numeric_table(values, expected_len)
    expect_type("table", values)
    expect_equal(expected_len, #values)
    for _, value in ipairs(values) do
        expect_type("number", value)
    end
end

local function expect_same_values(a, b, epsilon)
    expect_equal(#a, #b)
    for i = 1, #a do
        expect_near(a[i], b[i], epsilon or 0.00001)
    end
end

local function new_noise(seed)
    return procgen.newNoiseGenerator(seed or 42)
end

local function new_cellular(width, height)
    return procgen.newCellular(width or 16, height or 16)
end

-- @describe lurek.procgen
describe("lurek.procgen", function()
    -- @covers lurek.procgen.cellularAutomata
    it("generates a deterministic binary cave grid", function()
        local a = procgen.cellularAutomata(8, 6, { fill = 0.45, iterations = 2, seed = 42 })
        local b = procgen.cellularAutomata(8, 6, { fill = 0.45, iterations = 2, seed = 42 })
        expect_type("table", a)
        expect_equal(48, #a)
        expect_equal(#a, #b)
        for i = 1, #a do
            expect_true(a[i] == 0 or a[i] == 1, "cell should be 0 or 1")
            expect_equal(a[i], b[i])
        end
    end)

    -- @covers lurek.procgen.cellularAutomataGrid
    it("returns typed cellular grids that convert to tilefield refs", function()
        local grid = procgen.cellularAutomataGrid(4, 3, { fill = 1.0, iterations = 0, seed = 7 })
        expect_equal("userdata", type(grid))
        expect_equal("LProcgenGrid", grid:type())
        expect_true(grid:typeOf("LProcgenGrid"))
        expect_true(grid:typeOf("LObject"))
        expect_equal("cellular_automata", grid:getKind())
        local width, height = grid:getSize()
        expect_equal(4, width)
        expect_equal(3, height)
        expect_true(grid:getCell(1, 1) == 0 or grid:getCell(1, 1) == 1)
        local table_result = grid:toTable()
        expect_equal(12, #table_result.cells)
        local field = grid:toTileField({ slot = "terrain", topology = "square4" })
        expect_equal(grid:getCell(1, 1), field:getRef(1, 1, nil, "terrain"))
        expect_equal("square4", field:getTopology())
    end)

    -- @covers lurek.procgen.newGridResult
    it("wraps flat tables as typed procgen grid results", function()
        local grid = procgen.newGridResult(2, 2, { 4, 5, 6, 7 }, { kind = "manual" })
        expect_equal("manual", grid:getKind())
        expect_equal(6, grid:getCell(1, 2))
    end)

    -- @covers lurek.procgen.newScalarGridResult
    it("wraps scalar fields and writes them into tilefield channels", function()
        local grid = procgen.newScalarGridResult(2, 2, { 0.1, 0.6, 0.2, 0.9 }, { kind = "manual_scalar" })
        expect_equal("userdata", type(grid))
        expect_equal("LProcgenScalarGrid", grid:type())
        expect_true(grid:typeOf("LProcgenScalarGrid"))
        expect_true(grid:typeOf("LObject"))
        expect_equal("manual_scalar", grid:getKind())
        local width, height = grid:getSize()
        expect_equal(2, width)
        expect_equal(2, height)
        expect_near(0.2, grid:getCell(1, 2), 0.00001)
        local table_result = grid:toTable()
        expect_equal(4, #table_result.cells)

        local field = grid:toTileField({ target = "block", channel = "vision", threshold = 0.5 })
        expect_false(field:blocks(1, 1, nil, "vision"))
        expect_true(field:blocks(2, 1, nil, "vision"))

        local target = lurek.tilefield.new({ width = 2, height = 2 })
        grid:writeTileField(target, { target = "cost", channel = "move", scale = 10.0 })
        expect_near(1.0, target:getCost(1, 1, nil, "move"), 0.00001)
        expect_near(9.0, target:getCost(2, 2, nil, "move"), 0.00001)
    end)

    -- @covers lurek.procgen.floodFill
    it("fills only the connected cells that satisfy the threshold rule", function()
        local data = {
            1, 1, 0, 0,
            1, 1, 0, 0,
            0, 0, 0, 0,
            0, 0, 0, 1,
        }
        local result = procgen.floodFill(data, 4, 4, 0, 0, 1, true)
        expect_type("table", result)
        expect_equal(16, #result)
        expect_equal(1, result[1])
        expect_equal(1, result[2])
        expect_equal(1, result[5])
        expect_equal(1, result[6])
        expect_equal(0, result[3])
        expect_equal(0, result[16])
    end)

    -- @covers lurek.procgen.perlinNoise
    it("returns periodic values in range", function()
        local px, py = 8.0, 8.0
        local v1 = procgen.perlinNoise(0.0, 3.0, px, py)
        local v2 = procgen.perlinNoise(px, 3.0, px, py)
        expect_type("number", v1)
        expect_in_range(v1, -1.0, 1.0)
        expect_near(v1, v2, 0.001)
    end)

    -- @covers lurek.procgen.poissonDisk
    it("returns bounded points separated by the requested minimum distance", function()
        local width, height, min_dist = 80, 80, 10
        local points = procgen.poissonDisk(width, height, min_dist, 30, 42)
        expect_type("table", points)
        expect_true(#points > 0, "expected at least one point")
        for i = 1, #points do
            local p = points[i]
            expect_type("number", p.x)
            expect_type("number", p.y)
            expect_true(p.x >= 0 and p.x < width)
            expect_true(p.y >= 0 and p.y < height)
            for j = i + 1, #points do
                local dx = p.x - points[j].x
                local dy = p.y - points[j].y
                expect_true((dx * dx + dy * dy) >= (min_dist * min_dist) - 0.0001)
            end
        end
    end)

    -- @covers lurek.procgen.voronoi
    it("returns valid ownership and distance buffers", function()
        local seeds = { { x = 5, y = 5 }, { x = 15, y = 10 } }
        local regions, dist1, dist2 = procgen.voronoi(20, 20, seeds)
        expect_type("table", regions)
        expect_type("table", dist1)
        expect_type("table", dist2)
        expect_equal(400, #regions)
        expect_equal(400, #dist1)
        expect_equal(400, #dist2)
        for _, region in ipairs(regions) do
            expect_true(region >= 1 and region <= #seeds)
        end
    end)

    -- @covers lurek.procgen.bspDungeon
    it("returns deterministic rooms and corridors inside bounds", function()
        local dungeon = procgen.bspDungeon({ width = 40, height = 30, seed = 7 })
        local again = procgen.bspDungeon({ width = 40, height = 30, seed = 7 })
        expect_type("table", dungeon.rooms)
        expect_type("table", dungeon.corridors)
        expect_true(#dungeon.rooms > 0, "expected at least one room")
        expect_equal(#dungeon.rooms, #again.rooms)
        for _, room in ipairs(dungeon.rooms) do
            expect_true(room.x + room.w <= 40)
            expect_true(room.y + room.h <= 30)
        end
    end)

    -- @covers lurek.procgen.roomsDungeon
    it("returns a dungeon grid matching the requested dimensions", function()
        local dungeon = procgen.roomsDungeon({ width = 24, height = 16, max_rooms = 6, seed = 11 })
        expect_type("table", dungeon.rooms)
        expect_type("table", dungeon.grid)
        expect_equal(24, dungeon.width)
        expect_equal(16, dungeon.height)
        expect_equal(24 * 16, #dungeon.grid)
    end)

    -- @covers lurek.procgen.roomsDungeonGrid
    it("writes typed room dungeon grids into an existing tilefield", function()
        local grid = procgen.roomsDungeonGrid({ width = 12, height = 10, max_rooms = 3, seed = 11 })
        expect_equal("rooms_dungeon", grid:getKind())
        local width, height = grid:getSize()
        expect_equal(12, width)
        expect_equal(10, height)
        local field = lurek.tilefield.new({ width = 12, height = 10 })
        grid:writeTileField(field, { slot = "terrain" })
        expect_equal(grid:getCell(1, 1), field:getRef(1, 1, nil, "terrain"))
    end)

    -- @covers lurek.procgen.heightmap
    it("returns deterministic normalized height data", function()
        local a = procgen.heightmap({ width = 8, height = 8, seed = 77 })
        local b = procgen.heightmap({ width = 8, height = 8, seed = 77 })
        expect_type("table", a.cells)
        expect_equal(8, a.width)
        expect_equal(8, a.height)
        expect_equal(64, #a.cells)
        expect_same_values(a.cells, b.cells, 0.00001)
        for _, value in ipairs(a.cells) do
            expect_true(value >= 0.0 and value <= 1.0)
        end
    end)

    -- @covers lurek.procgen.lsystem
    it("expands rewrite rules for the requested iteration count", function()
        local result = procgen.lsystem({ axiom = "F", rules = { F = "FF" }, iterations = 3 })
        expect_equal("FFFFFFFF", result)
    end)

    -- @covers lurek.procgen.lsystemSegments
    it("converts turtle commands into line segments", function()
        local segments = procgen.lsystemSegments({ axiom = "F+F+F+F", rules = {}, iterations = 0 }, 90, 1.0)
        expect_type("table", segments)
        expect_true(#segments > 0, "expected at least one segment")
        local first = segments[1]
        expect_type("number", first.x1)
        expect_type("number", first.y1)
        expect_type("number", first.x2)
        expect_type("number", first.y2)
    end)

    -- @covers lurek.procgen.generateName
    it("generates a seeded name within the requested length bounds", function()
        local samples = { "Aria", "Lyra", "Mira", "Elara", "Kira", "Tara" }
        local name = procgen.generateName(samples, 3, 8, 1)
        expect_type("string", name)
        expect_true(#name >= 3 and #name <= 8)
    end)

    -- @covers lurek.procgen.generateNames
    it("generates the requested number of names", function()
        local samples = { "Aria", "Lyra", "Mira", "Elara", "Kira", "Tara" }
        local names = procgen.generateNames(samples, 5, 3, 8, 42)
        expect_type("table", names)
        expect_equal(5, #names)
        for _, name in ipairs(names) do
            expect_type("string", name)
        end
    end)

    -- @covers lurek.procgen.worldGraph
    it("returns deterministic regions and valid edges", function()
        local a = procgen.worldGraph(200, 150, 6, 5)
        local b = procgen.worldGraph(200, 150, 6, 5)
        expect_type("table", a.regions)
        expect_type("table", a.edges)
        expect_equal(6, #a.regions)
        expect_equal(#a.regions, #b.regions)
        for _, region in ipairs(a.regions) do
            expect_type("number", region.id)
            expect_type("string", region.name)
            expect_true(region.x >= 0 and region.x <= 200)
            expect_true(region.y >= 0 and region.y <= 150)
        end
        local ids = {}
        for _, region in ipairs(a.regions) do
            ids[region.id] = true
        end
        for _, edge in ipairs(a.edges) do
            expect_true(ids[edge.from] == true)
            expect_true(ids[edge.to] == true)
            expect_true(edge.cost > 0)
        end
    end)

    -- @covers lurek.procgen.noiseMap
    it("returns a deterministic flat noise buffer", function()
        local a = procgen.noiseMap(8, 8, { seed = 42, scale_x = 0.1, scale_y = 0.1 })
        local b = procgen.noiseMap(8, 8, { seed = 42, scale_x = 0.1, scale_y = 0.1 })
        expect_numeric_table(a, 64)
        expect_same_values(a, b, 0.00001)
    end)

    -- @covers lurek.procgen.noiseMapParallel
    it("returns a flat numeric buffer for parallel generation", function()
        local values = procgen.noiseMapParallel(8, 8, { octaves = 2, scale_x = 0.2, scale_y = 0.2 })
        expect_numeric_table(values, 64)
    end)

    -- @covers lurek.procgen.wfcGenerate
    it("fully collapses a trivial single-tile ruleset", function()
        local grid = procgen.wfcGenerate({
            width = 4,
            height = 3,
            seed = 7,
            tiles = {
                { id = 1, weight = 1.0 },
            },
            adjacencies = {
                [1] = { 1 },
            },
        })
        expect_equal(4, grid.width)
        expect_equal(3, grid.height)
        expect_equal(12, #grid.cells)
        for _, cell in ipairs(grid.cells) do
            expect_equal(1, cell)
        end
    end)

    -- @covers lurek.procgen.wfcGenerateGrid
    it("fully collapses a trivial single-tile ruleset into a typed grid", function()
        local grid = procgen.wfcGenerateGrid({
            width = 2,
            height = 2,
            seed = 7,
            tiles = {
                { id = 9, weight = 1.0 },
            },
            adjacencies = {
                [9] = { 9 },
            },
        })
        expect_equal("userdata", type(grid))
        expect_equal("wfc", grid:getKind())
        expect_equal(9, grid:getCell(1, 1))
        local field = grid:toTileField({ slot = "floor" })
        expect_equal(9, field:getRef(1, 1, nil, "floor"))
    end)

    -- @covers lurek.procgen.simplex2d
    it("samples deterministic 2D simplex noise", function()
        local a = procgen.simplex2d(0.25, 0.5)
        local b = procgen.simplex2d(0.25, 0.5)
        expect_type("number", a)
        expect_near(a, b, 0.000001)
    end)

    -- @covers lurek.procgen.simplex3d
    it("samples deterministic 3D simplex noise", function()
        local a = procgen.simplex3d(0.25, 0.5, 0.75)
        local b = procgen.simplex3d(0.25, 0.5, 0.75)
        expect_type("number", a)
        expect_near(a, b, 0.000001)
    end)

    -- @covers lurek.procgen.biomeColor
    it("returns an rgba tuple for a biome name", function()
        local r, g, b, a = procgen.biomeColor("desert")
        expect_type("number", r)
        expect_type("number", g)
        expect_type("number", b)
        expect_type("number", a)
    end)

    -- @covers lurek.procgen.newBiomeClassifier
    it("creates a classifier that can classify single samples and maps", function()
        local classifier = procgen.newBiomeClassifier()
        expect_type("userdata", classifier)
        expect_equal("LBiomeClassifier", classifier:type())
        expect_true(classifier:typeOf("LBiomeClassifier"))
        expect_type("string", classifier:classify(0.6, 0.3, 0.7))
        local out = classifier:classifyMap(2, 2, { 0.1, 0.3, 0.7, 0.9 }, { 0.8, 0.2, 0.4, 0.1 }, { 0.5, 0.7, 0.6, 0.2 })
        expect_type("table", out)
        expect_equal(4, #out)
    end)

    -- @covers LBiomeClassifier:classify
    it("classify returns a biome name for a single sample", function()
        local classifier = procgen.newBiomeClassifier()
        local biome = classifier:classify(0.6, 0.3, 0.7)
        expect_type("string", biome)
    end)

    -- @covers LBiomeClassifier:classifyMap
    it("classifyMap returns one biome label per cell", function()
        local classifier = procgen.newBiomeClassifier()
        local out = classifier:classifyMap(2, 2, {0.1, 0.3, 0.7, 0.9}, {0.8, 0.2, 0.4, 0.1}, {0.5, 0.7, 0.6, 0.2})
        expect_type("table", out)
        expect_equal(4, #out)
        expect_type("string", out[1])
    end)

    -- @covers LBiomeClassifier:type
    it("type returns LBiomeClassifier", function()
        local classifier = procgen.newBiomeClassifier()
        expect_equal("LBiomeClassifier", classifier:type())
    end)

    -- @covers LBiomeClassifier:typeOf
    it("typeOf recognizes biome classifiers and objects", function()
        local classifier = procgen.newBiomeClassifier()
        expect_true(classifier:typeOf("LBiomeClassifier"))
        expect_true(classifier:typeOf("LObject"))
        expect_false(classifier:typeOf("LNoiseGenerator"))
    end)

    -- @covers lurek.procgen.bspDungeonWithPrefabs
    it("returns dungeon layout and prefab placements", function()
        local prefabs = { { name = "boss", width = 4, height = 4 } }
        local dungeon, placed = procgen.bspDungeonWithPrefabs({ width = 40, height = 30, seed = 1 }, prefabs)
        expect_type("table", dungeon.rooms)
        expect_type("table", dungeon.corridors)
        expect_type("table", placed)
        if #placed > 0 then
            expect_type("string", placed[1].name)
        end
    end)

    -- @covers lurek.procgen.roomsDungeonWithPrefabs
    it("returns a room dungeon plus prefab placements", function()
        local prefabs = { { name = "altar", width = 3, height = 3 } }
        local dungeon, placed = procgen.roomsDungeonWithPrefabs({ width = 30, height = 20, seed = 5 }, prefabs)
        expect_type("table", dungeon.rooms)
        expect_type("table", dungeon.grid)
        expect_equal(30 * 20, #dungeon.grid)
        expect_type("table", placed)
    end)

    -- @covers lurek.procgen.heightmapFromCellular
    it("derives a deterministic heightmap from cellular data", function()
        local cells = procgen.cellularAutomata(8, 6, { seed = 10 })
        local a = procgen.heightmapFromCellular(8, 6, cells)
        local b = procgen.heightmapFromCellular(8, 6, cells)
        expect_equal(8, a.width)
        expect_equal(6, a.height)
        expect_equal(48, #a.cells)
        expect_same_values(a.cells, b.cells, 0.00001)
    end)

    -- @covers lurek.procgen.noiseMapParallelSeeded
    it("returns deterministic seeded parallel noise", function()
        local a = procgen.noiseMapParallelSeeded(8, 8, { seed = 99, scale_x = 0.3, scale_y = 0.3 })
        local b = procgen.noiseMapParallelSeeded(8, 8, { seed = 99, scale_x = 0.3, scale_y = 0.3 })
        expect_numeric_table(a, 64)
        expect_same_values(a, b, 0.00001)
    end)

    -- @covers lurek.procgen.setConstraintsFromLLM
    it("returns a table even when the LLM path is unavailable", function()
        local constraints = procgen.setConstraintsFromLLM("2 tiles: grass and water.")
        expect_type("table", constraints)
    end)

    -- @covers lurek.procgen.wfcFromPrompt
    it("returns a grid-shaped result for prompt-driven generation", function()
        local result = procgen.wfcFromPrompt("test", { width = 3, height = 7 })
        expect_type("table", result)
        expect_equal(3, result.width)
        expect_equal(7, result.height)
        expect_type("table", result.cells)
        expect_type("table", result.failed_cells)
    end)

    -- @covers lurek.procgen.fbm
    it("samples deterministic fractal noise", function()
        local a = procgen.fbm(0.5, 0.5, 7, 4, 2.0, 0.5)
        local b = procgen.fbm(0.5, 0.5, 7, 4, 2.0, 0.5)
        expect_type("number", a)
        expect_near(a, b, 0.000001)
    end)

    -- @covers lurek.procgen.newCellular
    it("creates a cellular simulation object", function()
        local ca = procgen.newCellular(16, 16)
        expect_type("userdata", ca)
        expect_equal("LCellular", ca:type())
        expect_true(ca:typeOf("LCellular"))
        ca:setCell(3, 3, procgen.CELL_SAND)
        expect_equal(procgen.CELL_SAND, ca:getCell(3, 3))
    end)

    -- @covers lurek.procgen.newNoiseGenerator
    it("creates a noise generator with a stable seed", function()
        local generator = procgen.newNoiseGenerator(777)
        expect_type("userdata", generator)
        expect_equal("LNoiseGenerator", generator:type())
        expect_true(generator:typeOf("LNoiseGenerator"))
        expect_equal(777, generator:getSeed())
    end)

    -- @covers lurek.procgen.perlin2d
    it("samples deterministic 2D Perlin noise", function()
        local a = procgen.perlin2d(0.2, 0.6, 9)
        local b = procgen.perlin2d(0.2, 0.6, 9)
        expect_type("number", a)
        expect_near(a, b, 0.000001)
    end)

    -- @covers lurek.procgen.perlin3d
    it("samples deterministic 3D Perlin noise", function()
        local a = procgen.perlin3d(0.1, 0.3, 0.7, 11)
        local b = procgen.perlin3d(0.1, 0.3, 0.7, 11)
        expect_type("number", a)
        expect_near(a, b, 0.000001)
    end)

    -- @covers lurek.procgen.perlin4d
    it("samples deterministic 4D Perlin noise", function()
        local a = procgen.perlin4d(0.1, 0.2, 0.3, 0.4, 17)
        local b = procgen.perlin4d(0.1, 0.2, 0.3, 0.4, 17)
        expect_type("number", a)
        expect_near(a, b, 0.000001)
    end)

    -- @covers lurek.procgen.simplexNoise
    it("supports both 2D and 3D simplex noise entrypoints", function()
        local value2d = procgen.simplexNoise(0.4, 0.9)
        local value3d = procgen.simplexNoise(0.4, 0.9, 1.2)
        expect_type("number", value2d)
        expect_type("number", value3d)
    end)

    -- @covers LNoiseGenerator:perlin1d
    it("perlin1d samples deterministic 1D noise", function()
        local generator = new_noise(42)
        local a = generator:perlin1d(0.5)
        local b = generator:perlin1d(0.5)
        expect_type("number", a)
        expect_near(a, b, 0.000001)
    end)

    -- @covers LNoiseGenerator:perlin2d
    it("perlin2d samples deterministic 2D noise", function()
        local generator = new_noise(42)
        local a = generator:perlin2d(0.3, 0.7)
        local b = generator:perlin2d(0.3, 0.7)
        expect_near(a, b, 0.000001)
    end)

    -- @covers LNoiseGenerator:perlin3d
    it("perlin3d samples deterministic 3D noise", function()
        local generator = new_noise(42)
        local a = generator:perlin3d(0.2, 0.4, 0.8)
        local b = generator:perlin3d(0.2, 0.4, 0.8)
        expect_near(a, b, 0.000001)
    end)

    -- @covers LNoiseGenerator:perlin4d
    it("perlin4d samples deterministic 4D noise", function()
        local generator = new_noise(42)
        local a = generator:perlin4d(0.1, 0.2, 0.3, 0.6)
        local b = generator:perlin4d(0.1, 0.2, 0.3, 0.6)
        expect_near(a, b, 0.000001)
    end)

    -- @covers LNoiseGenerator:simplex1d
    it("simplex1d samples deterministic 1D simplex noise", function()
        local generator = new_noise(42)
        local a = generator:simplex1d(0.5)
        local b = generator:simplex1d(0.5)
        expect_near(a, b, 0.000001)
    end)

    -- @covers LNoiseGenerator:simplex2d
    it("simplex2d samples deterministic 2D simplex noise", function()
        local generator = new_noise(42)
        local a = generator:simplex2d(0.3, 0.8)
        local b = generator:simplex2d(0.3, 0.8)
        expect_near(a, b, 0.000001)
    end)

    -- @covers LNoiseGenerator:simplex3d
    it("simplex3d samples deterministic 3D simplex noise", function()
        local generator = new_noise(42)
        local a = generator:simplex3d(0.1, 0.5, 0.9)
        local b = generator:simplex3d(0.1, 0.5, 0.9)
        expect_near(a, b, 0.000001)
    end)

    -- @covers LNoiseGenerator:worley2d
    it("worley2d samples deterministic cellular noise", function()
        local generator = new_noise(42)
        local a = generator:worley2d(0.5, 0.5)
        local b = generator:worley2d(0.5, 0.5)
        expect_near(a, b, 0.000001)
    end)

    -- @covers LNoiseGenerator:worley3d
    it("worley3d samples deterministic 3D cellular noise", function()
        local generator = new_noise(42)
        local a = generator:worley3d(0.5, 0.5, 0.5)
        local b = generator:worley3d(0.5, 0.5, 0.5)
        expect_near(a, b, 0.000001)
    end)

    -- @covers LNoiseGenerator:fbm
    it("fbm samples deterministic fractal noise", function()
        local generator = new_noise(42)
        local a = generator:fbm(0.5, 0.5, 4, 2.0, 0.5)
        local b = generator:fbm(0.5, 0.5, 4, 2.0, 0.5)
        expect_near(a, b, 0.000001)
    end)

    -- @covers LNoiseGenerator:ridged
    it("ridged samples deterministic ridged noise", function()
        local generator = new_noise(42)
        local a = generator:ridged(0.4, 0.6)
        local b = generator:ridged(0.4, 0.6)
        expect_near(a, b, 0.000001)
    end)

    -- @covers LNoiseGenerator:turbulence
    it("turbulence samples deterministic turbulence noise", function()
        local generator = new_noise(42)
        local a = generator:turbulence(0.5, 0.5, 4)
        local b = generator:turbulence(0.5, 0.5, 4)
        expect_near(a, b, 0.000001)
    end)

    -- @covers LNoiseGenerator:warpDomain
    it("warpDomain returns warped coordinates", function()
        local generator = new_noise(42)
        local x, y = generator:warpDomain(0.3, 0.7, 0.1)
        expect_type("number", x)
        expect_type("number", y)
    end)

    -- @covers LNoiseGenerator:generateMap
    it("generateMap returns a flat buffer of the requested size", function()
        local generator = new_noise(42)
        local map = generator:generateMap(8, 8, { scale_x = 0.1, scale_y = 0.1 })
        expect_type("table", map)
        expect_equal(64, #map)
    end)

    -- @covers LNoiseGenerator:generateMapCompute
    it("generateMapCompute returns a flat buffer of the requested size", function()
        local generator = new_noise(42)
        local map = generator:generateMapCompute(8, 8, { scale_x = 0.1, scale_y = 0.1 })
        expect_type("table", map)
        expect_equal(64, #map)
    end)

    -- @covers LNoiseGenerator:getSeed
    it("getSeed returns the configured generator seed", function()
        local generator = new_noise(12345)
        expect_equal(12345, generator:getSeed())
    end)

    -- @covers LNoiseGenerator:setSeed
    it("setSeed updates the generator seed", function()
        local generator = new_noise(1)
        generator:setSeed(99999)
        expect_equal(99999, generator:getSeed())
    end)

    -- @covers LNoiseGenerator:type
    it("type returns LNoiseGenerator", function()
        local generator = new_noise(42)
        expect_equal("LNoiseGenerator", generator:type())
    end)

    -- @covers LNoiseGenerator:typeOf
    it("typeOf recognizes noise generators and objects", function()
        local generator = new_noise(42)
        expect_true(generator:typeOf("LNoiseGenerator"))
        expect_true(generator:typeOf("LObject"))
        expect_false(generator:typeOf("LCellular"))
    end)

    -- @covers LCellular:setCell
    it("setCell writes a cell value", function()
        local ca = new_cellular(16, 16)
        ca:setCell(3, 3, procgen.CELL_SAND)
        expect_equal(procgen.CELL_SAND, ca:getCell(3, 3))
    end)

    -- @covers LCellular:getCell
    it("getCell reads a cell value", function()
        local ca = new_cellular(16, 16)
        ca:setCell(4, 5, procgen.CELL_WATER)
        expect_equal(procgen.CELL_WATER, ca:getCell(4, 5))
    end)

    -- @covers LCellular:fillRect
    it("fillRect fills a rectangular region", function()
        local ca = new_cellular(16, 16)
        ca:fillRect(0, 0, 4, 4, procgen.CELL_ROCK)
        expect_equal(procgen.CELL_ROCK, ca:getCell(0, 0))
        expect_equal(procgen.CELL_ROCK, ca:getCell(3, 3))
    end)

    -- @covers LCellular:step
    it("step advances the simulation without error", function()
        local ca = new_cellular(16, 16)
        expect_no_error(function()
            ca:step()
        end)
    end)

    -- @covers LCellular:countCells
    it("countCells returns the number of matching cells", function()
        local ca = new_cellular(16, 16)
        ca:setCell(0, 0, procgen.CELL_ROCK)
        expect_equal(1, ca:countCells(procgen.CELL_ROCK))
    end)

    -- @covers LCellular:findCells
    it("findCells returns matching positions", function()
        local ca = new_cellular(16, 16)
        ca:setCell(3, 7, procgen.CELL_WATER)
        local found = ca:findCells(procgen.CELL_WATER)
        expect_type("table", found)
        expect_equal(1, #found)
        expect_equal(3, found[1].x)
        expect_equal(7, found[1].y)
    end)

    -- @covers LCellular:toBytes
    it("toBytes serializes the grid to a byte string", function()
        local ca = new_cellular(8, 8)
        local bytes = ca:toBytes()
        expect_type("string", bytes)
        expect_true(#bytes > 0)
    end)

    -- @covers LCellular:type
    it("type returns LCellular", function()
        local ca = new_cellular(8, 8)
        expect_equal("LCellular", ca:type())
    end)

    -- @covers LCellular:typeOf
    it("typeOf recognizes cellular automata and objects", function()
        local ca = new_cellular(8, 8)
        expect_true(ca:typeOf("LCellular"))
        expect_true(ca:typeOf("LObject"))
        expect_false(ca:typeOf("LNoiseGenerator"))
    end)
end)
end
-- END test_procgen_core_unit.lua

test_summary()
