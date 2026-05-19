--- Procgen Module: noise, dungeons, heightmaps, caves, L-systems, Voronoi, WFC, biomes, names

--@api-stub: lurek.procgen.simplex2d
-- Simplex noise sampling.
do
    local val = lurek.procgen.simplex2d(1.5, 2.3)
    print("simplex2d = " .. val)
    local val3 = lurek.procgen.simplex3d(1.0, 2.0, 0.5)
    print("simplex3d = " .. val3)
end

--@api-stub: lurek.procgen.perlinNoise
-- Periodic Perlin noise (tileable).
do
    local n = lurek.procgen.perlinNoise(0.5, 0.5, 4.0, 4.0)
    print("perlin = " .. n)
    local n2 = lurek.procgen.perlinNoise(4.5, 0.5, 4.0, 4.0)
    print("tiled same = " .. n2)
end

--@api-stub: lurek.procgen.noiseMap
-- Generate a full 2D noise map.
do
    local map = lurek.procgen.noiseMap(64, 64, {
        scale_x = 0.05,
        scale_y = 0.05,
        octaves = 4,
        lacunarity = 2.0,
        persistence = 0.5,
        seed = 42
    })
    print("noise map length = " .. #map)
    print("sample [1] = " .. map[1])
    print("sample [100] = " .. map[100])
end

--@api-stub: lurek.procgen.noiseMapParallel
-- Parallel noise generation for large maps.
do
    local map = lurek.procgen.noiseMapParallel(256, 256, {
        scale_x = 0.02,
        scale_y = 0.02,
        octaves = 6
    })
    print("parallel map length = " .. #map)
    local seeded = lurek.procgen.noiseMapParallelSeeded(128, 128, {
        scale_x = 0.03,
        scale_y = 0.03,
        octaves = 4,
        seed = 12345
    })
    print("seeded map length = " .. #seeded)
end

--@api-stub: lurek.procgen.heightmap
-- Fractal heightmap with optional erosion.
do
    local hm = lurek.procgen.heightmap({
        width = 128,
        height = 128,
        scale = 0.01,
        octaves = 6,
        lacunarity = 2.0,
        persistence = 0.5,
        seed = 99,
        erosion_passes = 3
    })
    print("heightmap: " .. hm.width .. "x" .. hm.height)
    print("cells count = " .. #hm.cells)
    local minH, maxH = 1, 0
    for _, v in ipairs(hm.cells) do
        if v < minH then minH = v end
        if v > maxH then maxH = v end
    end
    print("range = " .. minH .. " to " .. maxH)
end

--@api-stub: lurek.procgen.cellularAutomata
-- Cave generation using cellular automata.
do
    local cave = lurek.procgen.cellularAutomata(80, 60, {
        fill = 0.45,
        iterations = 5,
        birth = 5,
        survive = 4,
        seed = 777
    })
    print("cave cells = " .. #cave)
    local walls = 0
    for _, v in ipairs(cave) do
        if v == 1 then walls = walls + 1 end
    end
    print("walls = " .. walls .. " empty = " .. (#cave - walls))
end

--@api-stub: lurek.procgen.heightmapFromCellular
-- Convert cellular automata into a distance-based heightmap.
do
    local cells = lurek.procgen.cellularAutomata(64, 64, {
        fill = 0.4,
        iterations = 4,
        seed = 100
    })
    local hm = lurek.procgen.heightmapFromCellular(64, 64, cells, 0)
    print("cave heightmap: " .. hm.width .. "x" .. hm.height)
    print("sample = " .. hm.cells[1])
end

--@api-stub: lurek.procgen.floodFill
-- Flood fill on a grid.
do
    local grid = {}
    for i = 1, 100 do grid[i] = 0 end
    grid[1] = 200
    grid[2] = 200
    grid[11] = 200
    grid[12] = 200
    local filled = lurek.procgen.floodFill(grid, 10, 10, 0, 0, 128, true)
    local count = 0
    for _, v in ipairs(filled) do
        if v == 1 then count = count + 1 end
    end
    print("flood filled cells = " .. count)
end

--@api-stub: lurek.procgen.bspDungeon
-- BSP dungeon generation.
do
    local dungeon = lurek.procgen.bspDungeon({
        width = 80,
        height = 60,
        min_size = 8,
        max_depth = 5,
        seed = 42,
        padding = 1
    })
    print("rooms = " .. #dungeon.rooms)
    print("corridors = " .. #dungeon.corridors)
    for i, room in ipairs(dungeon.rooms) do
        if i <= 3 then
            print("  room " .. i .. ": " .. room.x .. "," .. room.y ..
                " size=" .. room.w .. "x" .. room.h)
        end
    end
end

--@api-stub: lurek.procgen.roomsDungeon
-- Room-based dungeon with tile grid.
do
    local dungeon = lurek.procgen.roomsDungeon({
        width = 60,
        height = 40,
        max_rooms = 10,
        min_room_size = 5,
        max_room_size = 12,
        seed = 123
    })
    print("rooms = " .. #dungeon.rooms)
    print("corridors = " .. #dungeon.corridors)
    print("grid = " .. dungeon.width .. "x" .. dungeon.height)
    print("grid cells = " .. #dungeon.grid)
end

--@api-stub: lurek.procgen.bspDungeonWithPrefabs
-- BSP dungeon with prefab rooms.
do
    local prefabs = {
        { name = "boss_room", width = 10, height = 10 },
        { name = "treasure_vault", width = 6, height = 6 },
        { name = "library", width = 8, height = 5 },
    }
    local dungeon, placed = lurek.procgen.bspDungeonWithPrefabs({
        width = 80,
        height = 60,
        min_size = 10,
        max_depth = 4,
        seed = 55
    }, prefabs)
    print("placed prefabs = " .. #placed)
    for _, p in ipairs(placed) do
        print("  " .. p.name .. " at " .. p.x .. "," .. p.y ..
            " size=" .. p.width .. "x" .. p.height)
    end
end

--@api-stub: lurek.procgen.roomsDungeonWithPrefabs
-- Room dungeon with prefabs and custom stamp.
do
    local prefabs = {
        { name = "shop", width = 5, height = 5 },
        { name = "shrine", width = 4, height = 4 },
    }
    local dungeon, placed = lurek.procgen.roomsDungeonWithPrefabs({
        width = 50,
        height = 40,
        max_rooms = 8,
        seed = 200
    }, prefabs, 3)
    print("dungeon grid = " .. dungeon.width .. "x" .. dungeon.height)
    print("placed = " .. #placed)
end

--@api-stub: lurek.procgen.poissonDisk
-- Poisson disk sampling for even point distribution.
do
    local points = lurek.procgen.poissonDisk(200, 200, 15, 30, 42)
    print("poisson points = " .. #points)
    for i = 1, math.min(5, #points) do
        print("  point " .. i .. ": " .. points[i].x .. ", " .. points[i].y)
    end
end

--@api-stub: lurek.procgen.voronoi
-- Voronoi diagram from seed points.
do
    local seeds = {}
    for i = 1, 10 do
        seeds[i] = { x = math.random(0, 99), y = math.random(0, 99) }
    end
    local regions, dist1, dist2 = lurek.procgen.voronoi(100, 100, seeds)
    print("region cells = " .. #regions)
    print("dist1 cells = " .. #dist1)
    print("sample region = " .. regions[50])
    print("sample dist = " .. dist1[50])
end

-- Voronoi with domain warping.
--@api-stub: lurek.procgen.voronoi
do
    local seeds = {}
    for i = 1, 8 do
        seeds[i] = { x = i * 15, y = i * 12 }
    end
    local regions = lurek.procgen.voronoi(128, 128, seeds, {
        warp_scale = 0.05,
        warp_strength = 10.0,
        seed = 42
    })
    print("warped voronoi cells = " .. #regions)
end

--@api-stub: lurek.procgen.lsystem
-- L-system string expansion.
do
    local result = lurek.procgen.lsystem({
        axiom = "F",
        iterations = 3,
        rules = {
            F = "F[+F]F[-F]F"
        }
    })
    print("lsystem length = " .. #result)
    print("first 40 chars = " .. result:sub(1, 40))
end

--@api-stub: lurek.procgen.lsystemSegments
-- L-system as drawable line segments (turtle graphics).
do
    local segments = lurek.procgen.lsystemSegments({
        axiom = "F",
        iterations = 4,
        rules = {
            F = "FF+[+F-F-F]-[-F+F+F]"
        }
    }, 25, 5.0)
    print("tree segments = " .. #segments)
    if #segments > 0 then
        local s = segments[1]
        print("first: " .. s.x1 .. "," .. s.y1 .. " -> " .. s.x2 .. "," .. s.y2)
    end
end

--@api-stub: lurek.procgen.wfcGenerate
-- Wave Function Collapse.
do
    local result = lurek.procgen.wfcGenerate({
        width = 10,
        height = 10,
        seed = 42,
        max_attempts = 100,
        tiles = {
            { id = 1, weight = 1.0 },
            { id = 2, weight = 1.0 },
            { id = 3, weight = 0.5 },
        },
        adjacencies = {
            [1] = { 1, 2 },
            [2] = { 1, 2, 3 },
            [3] = { 2, 3 },
        }
    })
    print("wfc: " .. result.width .. "x" .. result.height)
    print("cells = " .. #result.cells)
    local line = ""
    for i = 1, 10 do
        line = line .. result.cells[i] .. " "
    end
    print("row 1: " .. line)
end

--@api-stub: lurek.procgen.generateName
-- Markov chain name generation.
do
    local samples = { "Aldric", "Baldric", "Cedric", "Eldric", "Godric", "Fredric" }
    local name = lurek.procgen.generateName(samples, 4, 8, 1)
    print("generated name = " .. name)
    local names = lurek.procgen.generateNames(samples, 5, 4, 8, 2)
    print("batch names:")
    for _, n in ipairs(names) do
        print("  " .. n)
    end
end

--@api-stub: lurek.procgen.newBiomeClassifier
-- Biome classification.
do
    ---@type BiomeClassifier
    local bc = lurek.procgen.newBiomeClassifier({
        ocean_threshold = 0.3,
        coast_threshold = 0.35,
        mountain_threshold = 0.8
    })
    local biome = bc:classify(0.5, 0.6, 0.5)
    print("point biome = " .. biome)
    local heights = { 0.1, 0.4, 0.6, 0.9 }
    local moisture = { 0.8, 0.5, 0.3, 0.2 }
    local biomes = bc:classifyMap(2, 2, heights, moisture)
    for i, b in ipairs(biomes) do
        print("  cell " .. i .. " = " .. b)
    end
end

--@api-stub: lurek.procgen.biomeColor
-- Biome display colors.
do
    local r, g, b, a = lurek.procgen.biomeColor("ocean")
    print("ocean color = " .. r .. "," .. g .. "," .. b .. "," .. a)
    r, g, b, a = lurek.procgen.biomeColor("desert")
    print("desert color = " .. r .. "," .. g .. "," .. b .. "," .. a)
    r, g, b, a = lurek.procgen.biomeColor("taiga")
    print("taiga color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: lurek.procgen.worldGraph
-- World graph generation (overworld).
do
    local world = lurek.procgen.worldGraph(500, 500, 12, 42)
    print("regions = " .. #world.regions)
    print("edges = " .. #world.edges)
    for i = 1, math.min(3, #world.regions) do
        local r = world.regions[i]
        print("  region " .. r.id .. ": " .. r.name ..
            " at " .. r.x .. "," .. r.y)
    end
    for i = 1, math.min(3, #world.edges) do
        local e = world.edges[i]
        print("  edge " .. e.from .. " -> " .. e.to .. " cost=" .. e.cost)
    end
end

print("procgen_00.lua")
