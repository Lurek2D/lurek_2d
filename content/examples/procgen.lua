-- content/examples/procgen.lua
-- Auto-generated from content/examples2/procgen_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/procgen.lua

--- Procgen Module: noise, dungeons, heightmaps, caves, L-systems, Voronoi, WFC, biomes, names


--@api-stub: lurek.procgen.simplex2d
do
    local val = lurek.procgen.simplex2d(1.5, 2.3)
    print("simplex2d = " .. val)
end

--@api-stub: lurek.procgen.perlinNoise
do
    local n = lurek.procgen.perlinNoise(0.5, 0.5, 4.0, 4.0)
    print("perlin = " .. n)
    local n2 = lurek.procgen.perlinNoise(4.5, 0.5, 4.0, 4.0)
    print("tiled same = " .. n2)
end

--@api-stub: lurek.procgen.noiseMap
do
    local map = lurek.procgen.noiseMap(64, 64, { scale_x = 0.05, scale_y = 0.05, octaves = 4, lacunarity = 2.0, persistence = 0.5, seed = 42 })
    print("noise map length = " .. #map)
    print("sample [1] = " .. map[1])
end

--@api-stub: lurek.procgen.noiseMapParallel
do
    local map = lurek.procgen.noiseMapParallel(256, 256, { scale_x = 0.02, scale_y = 0.02, octaves = 6 })
    print("parallel map length = " .. #map)
end

--@api-stub: lurek.procgen.heightmap
do
    local hm = lurek.procgen.heightmap({ width = 128, height = 128, scale = 0.01, octaves = 6, lacunarity = 2.0, persistence = 0.5, seed = 99, erosion_passes = 3 })
    print("heightmap: " .. hm.width .. "x" .. hm.height)
    print("cells count = " .. #hm.cells)
end

--@api-stub: lurek.procgen.cellularAutomata
do
    local cave = lurek.procgen.cellularAutomata(80, 60, { fill = 0.45, iterations = 5, birth = 5, survive = 4, seed = 777 })
    print("cave cells = " .. #cave)
    print("sample cell = " .. tostring(cave[1]))
end

--@api-stub: lurek.procgen.heightmapFromCellular
do
    local cells = lurek.procgen.cellularAutomata(64, 64, { fill = 0.4, iterations = 4, seed = 100 })
    local hm = lurek.procgen.heightmapFromCellular(64, 64, cells, 0)
    print("cave heightmap: " .. hm.width .. "x" .. hm.height)
    print("sample = " .. hm.cells[1])
end

--@api-stub: lurek.procgen.floodFill
do
    local filled = lurek.procgen.floodFill({ 200, 200, 0, 0, 200, 200, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, 4, 4, 0, 0, 128, true)
    print("flood filled sample = " .. tostring(filled[1]))
end

--@api-stub: lurek.procgen.bspDungeon
do
    local dungeon = lurek.procgen.bspDungeon({ width = 80, height = 60, min_size = 8, max_depth = 5, seed = 42, padding = 1 })
    print("rooms = " .. #dungeon.rooms)
    print("corridors = " .. #dungeon.corridors)
end

--@api-stub: lurek.procgen.roomsDungeon
do
    local dungeon = lurek.procgen.roomsDungeon({ width = 60, height = 40, max_rooms = 10, min_room_size = 5, max_room_size = 12, seed = 123 })
    print("rooms = " .. #dungeon.rooms)
    print("grid cells = " .. #dungeon.grid)
end

--@api-stub: lurek.procgen.bspDungeonWithPrefabs
do
    local prefabs = { { name = "boss_room", width = 10, height = 10 } }
    local _, placed = lurek.procgen.bspDungeonWithPrefabs({ width = 80, height = 60, min_size = 10, max_depth = 4, seed = 55 }, prefabs)
    print("placed prefabs = " .. #placed)
end

--@api-stub: lurek.procgen.roomsDungeonWithPrefabs
do
    local prefabs = { { name = "shop", width = 5, height = 5 } }
    local dungeon, placed = lurek.procgen.roomsDungeonWithPrefabs({ width = 50, height = 40, max_rooms = 8, seed = 200 }, prefabs, 3)
    print("dungeon grid = " .. dungeon.width .. "x" .. dungeon.height)
    print("placed = " .. #placed)
end

--@api-stub: lurek.procgen.poissonDisk
do
    local points = lurek.procgen.poissonDisk(200, 200, 15, 30, 42)
    print("poisson points = " .. #points)
    for i = 1, math.min(5, #points) do
        print("  point " .. i .. ": " .. points[i].x .. ", " .. points[i].y)
    end
end

--@api-stub: lurek.procgen.voronoi
do
    local regions, dist1 = lurek.procgen.voronoi(100, 100, { { x = 20, y = 20 }, { x = 80, y = 80 } })
    print("region cells = " .. #regions)
    print("dist1 cells = " .. #dist1)
    print("sample region = " .. tostring(regions[50]))
end

--@api-stub: lurek.procgen.lsystem
do
    local result = lurek.procgen.lsystem({ axiom = "F", iterations = 3, rules = { F = "F[+F]F[-F]F" } })
    print("lsystem length = " .. #result)
    print("first 40 chars = " .. result:sub(1, 40))
end

--@api-stub: lurek.procgen.lsystemSegments
do
    local segments = lurek.procgen.lsystemSegments({ axiom = "F", iterations = 4, rules = { F = "FF+[+F-F-F]-[-F+F+F]" } }, 25, 5.0)
    print("tree segments = " .. #segments)
    print("first segment = " .. tostring(segments[1] ~= nil))
end

--@api-stub: lurek.procgen.wfcGenerate
do
    local result = lurek.procgen.wfcGenerate({ width = 4, height = 4, seed = 42, max_attempts = 100, tiles = { { id = 1, weight = 1.0 }, { id = 2, weight = 1.0 } }, adjacencies = { [1] = { 1, 2 }, [2] = { 1, 2 } } })
    print("wfc: " .. result.width .. "x" .. result.height)
    print("cells = " .. #result.cells)
end

--@api-stub: lurek.procgen.generateName
do
    local samples = { "Aldric", "Baldric", "Cedric", "Eldric", "Godric", "Fredric" }
    print("generated name = " .. lurek.procgen.generateName(samples, 4, 8, 1))
end

--@api-stub: lurek.procgen.newBiomeClassifier
do
    local bc = lurek.procgen.newBiomeClassifier({ ocean_threshold = 0.3, coast_threshold = 0.35, mountain_threshold = 0.8 })
    print("point biome = " .. bc:classify(0.5, 0.6, 0.5))
end

--@api-stub: lurek.procgen.biomeColor
do
    local r, g, b, a = lurek.procgen.biomeColor("ocean")
    print("ocean color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: lurek.procgen.worldGraph
do
    local world = lurek.procgen.worldGraph(500, 500, 12, 42)
    print("regions = " .. #world.regions)
    print("edges = " .. #world.edges)
end

--- Procgen Module Part 1: BiomeClassifier, generateNames, noiseMapParallelSeeded, simplex3d


--@api-stub: LBiomeClassifier:classify
do
    local bc = lurek.procgen.newBiomeClassifier({ biomes = { { name = "ocean", h_max = 0.3, m_min = 0.0, t_min = 0.0 }, { name = "forest", h_min = 0.3, m_min = 0.3, t_min = 0.0 } } })
    print("biome=" .. bc:classify(0.5, 0.6, 0.4))
end

--@api-stub: LBiomeClassifier:classifyMap
do
    local bc = lurek.procgen.newBiomeClassifier({ biomes = { { name = "ocean", h_max = 0.3, m_min = 0.0, t_min = 0.0 }, { name = "forest", h_min = 0.3, m_min = 0.3, t_min = 0.0 } } })
    local map = bc:classifyMap(2, 2, { 0.1, 0.2, 0.6, 0.7 }, { 0.8, 0.7, 0.5, 0.4 }, { 0.4, 0.4, 0.4, 0.4 })
    print("map_size=" .. #map)
end

--@api-stub: LBiomeClassifier:type
do
    local bc = lurek.procgen.newBiomeClassifier({ biomes = { { name = "ocean", h_max = 1.0, m_min = 0.0, t_min = 0.0 } } })
    print("type=" .. bc:type())
end

--@api-stub: LBiomeClassifier:typeOf
do
    local bc = lurek.procgen.newBiomeClassifier({ biomes = { { name = "ocean", h_max = 1.0, m_min = 0.0, t_min = 0.0 } } })
    print("typeOf=" .. tostring(bc:typeOf("LBiomeClassifier")))
end

--@api-stub: lurek.procgen.generateNames
do
    local samples = { "Alon", "Beren", "Caran", "Doran", "Elan" }
    local names = lurek.procgen.generateNames(samples, 5, 3, 8, 42)
    print("names_count=" .. #names)
end

--@api-stub: lurek.procgen.noiseMapParallelSeeded
do
    local map = lurek.procgen.noiseMapParallelSeeded(16, 16, { scale = 0.1, octaves = 4, seed = 12345 })
    print("map_len=" .. #map)
end

--@api-stub: lurek.procgen.simplex3d
do
    local v = lurek.procgen.simplex3d(0.1, 0.5, 0.9)
    print("simplex3d=" .. v)
end

print("content/examples/procgen.lua")
