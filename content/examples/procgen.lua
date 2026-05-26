-- content/examples/procgen.lua
-- Auto-generated from content/examples2/procgen_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/procgen.lua

--- Procgen Module: noise, dungeons, heightmaps, caves, L-systems, Voronoi, WFC, biomes, names

--@api-stub: lurek.procgen.simplex2d
do
    local value = lurek.procgen.simplex2d(1.5, 2.3)
    local mirrored = lurek.procgen.simplex2d(2.3, 1.5)

    print(string.format("simplex2d=%.4f", value))
    print(string.format("simplex2d mirrored=%.4f", mirrored))
end

--@api-stub: lurek.procgen.perlinNoise
do
    local first = lurek.procgen.perlinNoise(0.5, 0.5, 4.0, 4.0)
    local tiled = lurek.procgen.perlinNoise(4.5, 0.5, 4.0, 4.0)

    print(string.format("perlinNoise first=%.4f", first))
    print(string.format("perlinNoise tiled=%.4f", tiled))
end

--@api-stub: lurek.procgen.noiseMap
do
    local map = lurek.procgen.noiseMap(64, 64, {
        scale_x = 0.05,
        scale_y = 0.05,
        octaves = 4,
        lacunarity = 2.0,
        persistence = 0.5,
        seed = 42,
    })

    print("noiseMap cells=" .. #map)
    print(string.format("noiseMap first=%.4f", map[1]))
end

--@api-stub: lurek.procgen.noiseMapParallel
do
    local map = lurek.procgen.noiseMapParallel(128, 128, {
        scale_x = 0.02,
        scale_y = 0.02,
        octaves = 6,
        lacunarity = 2.0,
        persistence = 0.5,
    })

    print("noiseMapParallel cells=" .. #map)
    print(string.format("noiseMapParallel midpoint=%.4f", map[4096]))
end

--@api-stub: lurek.procgen.heightmap
do
    local hm = lurek.procgen.heightmap({
        width = 128,
        height = 128,
        scale = 0.01,
        octaves = 6,
        lacunarity = 2.0,
        persistence = 0.5,
        seed = 99,
        erosion_passes = 3,
    })

    print("heightmap size=" .. hm.width .. "x" .. hm.height)
    print("heightmap cells=" .. #hm.cells)
end

--@api-stub: lurek.procgen.cellularAutomata
do
    local cave = lurek.procgen.cellularAutomata(80, 60, {
        fill = 0.45,
        iterations = 5,
        birth = 5,
        survive = 4,
        seed = 777,
    })

    print("cellularAutomata cells=" .. #cave)
    print("cellularAutomata first=" .. tostring(cave[1]))
end

--@api-stub: lurek.procgen.heightmapFromCellular
do
    local cells = lurek.procgen.cellularAutomata(64, 64, {
        fill = 0.4,
        iterations = 4,
        seed = 100,
    })
    local hm = lurek.procgen.heightmapFromCellular(64, 64, cells, 0)

    print("heightmapFromCellular size=" .. hm.width .. "x" .. hm.height)
    print(string.format("heightmapFromCellular first=%.4f", hm.cells[1]))
end

--@api-stub: lurek.procgen.floodFill
do
    local cells = {
        200, 200, 0, 0,
        200, 200, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, 0,
    }
    local filled = lurek.procgen.floodFill(cells, 4, 4, 0, 0, 128, true)

    print("floodFill cells=" .. #filled)
    print("floodFill first=" .. tostring(filled[1]))
end

--@api-stub: lurek.procgen.bspDungeon
do
    local dungeon = lurek.procgen.bspDungeon({
        width = 80,
        height = 60,
        min_size = 8,
        max_depth = 5,
        seed = 42,
        padding = 1,
    })

    print("bspDungeon rooms=" .. #dungeon.rooms)
    print("bspDungeon corridors=" .. #dungeon.corridors)
end

--@api-stub: lurek.procgen.roomsDungeon
do
    local dungeon = lurek.procgen.roomsDungeon({
        width = 60,
        height = 40,
        max_rooms = 10,
        min_room_size = 5,
        max_room_size = 12,
        seed = 123,
    })

    print("roomsDungeon rooms=" .. #dungeon.rooms)
    print("roomsDungeon grid=" .. #dungeon.grid)
end

--@api-stub: lurek.procgen.bspDungeonWithPrefabs
do
    local prefabs = {
        { name = "boss_room", width = 10, height = 10 },
    }
    local dungeon, placed = lurek.procgen.bspDungeonWithPrefabs({
        width = 80,
        height = 60,
        min_size = 10,
        max_depth = 4,
        seed = 55,
    }, prefabs)

    print("bspDungeonWithPrefabs rooms=" .. #dungeon.rooms)
    print("bspDungeonWithPrefabs placed=" .. #placed)
end

--@api-stub: lurek.procgen.roomsDungeonWithPrefabs
do
    local prefabs = {
        { name = "shop", width = 5, height = 5 },
    }
    local dungeon, placed = lurek.procgen.roomsDungeonWithPrefabs({
        width = 50,
        height = 40,
        max_rooms = 8,
        seed = 200,
    }, prefabs, 3)

    print("roomsDungeonWithPrefabs size=" .. dungeon.width .. "x" .. dungeon.height)
    print("roomsDungeonWithPrefabs placed=" .. #placed)
end

--@api-stub: lurek.procgen.poissonDisk
do
    local points = lurek.procgen.poissonDisk(200, 200, 15, 30, 42)
    local first = points[1]

    print("poissonDisk points=" .. #points)
    print(string.format("poissonDisk first=(%.2f, %.2f)", first.x, first.y))
end

--@api-stub: lurek.procgen.voronoi
do
    local regions, dist1, dist2 = lurek.procgen.voronoi(100, 100, {
        { x = 20, y = 20 },
        { x = 80, y = 80 },
        { x = 50, y = 30 },
    })

    print("voronoi regions=" .. #regions)
    print(string.format("voronoi first distances=%.2f / %.2f", dist1[1], dist2[1]))
    print("voronoi first region=" .. tostring(regions[1]))
end

--@api-stub: lurek.procgen.lsystem
do
    local result = lurek.procgen.lsystem({
        axiom = "F",
        iterations = 3,
        rules = { F = "F[+F]F[-F]F" },
    })

    print("lsystem length=" .. #result)
    print("lsystem preview=" .. result:sub(1, 40))
end

--@api-stub: lurek.procgen.lsystemSegments
do
    local segments = lurek.procgen.lsystemSegments({
        axiom = "F",
        iterations = 4,
        rules = { F = "FF+[+F-F-F]-[-F+F+F]" },
    }, 25, 5.0)

    print("lsystemSegments count=" .. #segments)
    print("lsystemSegments firstExists=" .. tostring(segments[1] ~= nil))
end

--@api-stub: lurek.procgen.wfcGenerate
do
    local result = lurek.procgen.wfcGenerate({
        width = 4,
        height = 4,
        seed = 42,
        max_attempts = 100,
        tiles = {
            { id = 1, weight = 1.0 },
            { id = 2, weight = 1.0 },
        },
        adjacencies = {
            [1] = { 1, 2 },
            [2] = { 1, 2 },
        },
    })

    print("wfcGenerate size=" .. result.width .. "x" .. result.height)
    print("wfcGenerate cells=" .. #result.cells)
end

--@api-stub: lurek.procgen.generateName
do
    local samples = { "Aldric", "Baldric", "Cedric", "Eldric", "Godric", "Fredric" }
    local name = lurek.procgen.generateName(samples, 4, 8, 1)

    print("generateName result=" .. name)
end

--@api-stub: lurek.procgen.newBiomeClassifier
do
    local classifier = lurek.procgen.newBiomeClassifier({
        ocean_threshold = 0.3,
        coast_threshold = 0.35,
        mountain_threshold = 0.8,
    })
    local biome = classifier:classify(0.5, 0.6, 0.5)

    print("newBiomeClassifier biome=" .. biome)
    print("newBiomeClassifier type=" .. classifier:type())
end

--@api-stub: lurek.procgen.biomeColor
do
    local r, g, b, a = lurek.procgen.biomeColor("ocean")

    print("biomeColor ocean=" .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api-stub: lurek.procgen.worldGraph
do
    local world = lurek.procgen.worldGraph(500, 500, 12, 42)

    print("worldGraph regions=" .. #world.regions)
    print("worldGraph edges=" .. #world.edges)
end

--- Procgen Module Part 1: BiomeClassifier, generateNames, noiseMapParallelSeeded, simplex3d

--@api-stub: LBiomeClassifier:classify
do
    local classifier = lurek.procgen.newBiomeClassifier({
        ocean_threshold = 0.28,
        coast_threshold = 0.34,
        warm_temperature = 0.65,
        wet_moisture = 0.7,
    })
    local biome = classifier:classify(0.5, 0.6, 0.4)

    print("LBiomeClassifier:classify=" .. biome)
end

--@api-stub: LBiomeClassifier:classifyMap
do
    local classifier = lurek.procgen.newBiomeClassifier({
        ocean_threshold = 0.3,
        coast_threshold = 0.35,
        mountain_threshold = 0.8,
    })
    local map = classifier:classifyMap(
        2,
        2,
        { 0.1, 0.2, 0.6, 0.85 },
        { 0.8, 0.7, 0.5, 0.3 },
        { 0.4, 0.4, 0.4, 0.2 }
    )

    print("LBiomeClassifier:classifyMap size=" .. #map)
    print("LBiomeClassifier:classifyMap last=" .. map[#map])
end

--@api-stub: LBiomeClassifier:type
do
    local classifier = lurek.procgen.newBiomeClassifier()
    local type_name = classifier:type()

    print("LBiomeClassifier:type=" .. type_name)
end

--@api-stub: LBiomeClassifier:typeOf
do
    local classifier = lurek.procgen.newBiomeClassifier()
    local matches = classifier:typeOf("LBiomeClassifier")

    print("LBiomeClassifier:typeOf=" .. tostring(matches))
end

--@api-stub: lurek.procgen.generateNames
do
    local samples = { "Alon", "Beren", "Caran", "Doran", "Elan" }
    local names = lurek.procgen.generateNames(samples, 5, 3, 8, 42)

    print("generateNames count=" .. #names)
    print("generateNames first=" .. names[1])
end

--@api-stub: lurek.procgen.noiseMapParallelSeeded
do
    local map = lurek.procgen.noiseMapParallelSeeded(16, 16, {
        scale_x = 0.1,
        scale_y = 0.1,
        octaves = 4,
        seed = 12345,
    })

    print("noiseMapParallelSeeded cells=" .. #map)
    print(string.format("noiseMapParallelSeeded first=%.4f", map[1]))
end

--@api-stub: lurek.procgen.simplex3d
do
    local value = lurek.procgen.simplex3d(0.1, 0.5, 0.9)
    local shifted = lurek.procgen.simplex3d(0.1, 0.5, 1.1)

    print(string.format("simplex3d=%.4f", value))
    print(string.format("simplex3d shifted=%.4f", shifted))
end

--@api-stub: lurek.procgen.perlin4d
do
    local value = lurek.procgen.perlin4d(0.1, 0.2, 0.3, 0.4)
    local seeded = lurek.procgen.perlin4d(0.1, 0.2, 0.3, 0.4, 17)

    print(string.format("perlin4d=%.4f", value))
    print(string.format("perlin4d seeded=%.4f", seeded))
end

--@api-stub: LNoiseGenerator:fbm
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:fbm(0.5, 0.5, 4, 2.0, 0.5)

    print(string.format("LNoiseGenerator:fbm=%.4f", value))
end

--@api-stub: LNoiseGenerator:generateMap
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local map = generator:generateMap(16, 16, {
        scaleX = 0.08,
        scaleY = 0.08,
        octaves = 4,
        lacunarity = 2.0,
        persistence = 0.5,
        kind = "perlin",
        fractal = "fbm",
    })

    print("LNoiseGenerator:generateMap cells=" .. #map)
    print(string.format("LNoiseGenerator:generateMap first=%.4f", map[1]))
end

--@api-stub: LNoiseGenerator:generateMapCompute
do
    local generator = lurek.procgen.newNoiseGenerator(99)
    local map = generator:generateMapCompute(32, 32, {
        scaleX = 0.05,
        scaleY = 0.05,
        octaves = 3,
        lacunarity = 2.0,
        persistence = 0.5,
        kind = "simplex",
        fractal = "turbulence",
    })

    print("LNoiseGenerator:generateMapCompute cells=" .. #map)
    print(string.format("LNoiseGenerator:generateMapCompute first=%.4f", map[1]))
end

--@api-stub: LNoiseGenerator:getSeed
do
    local generator = lurek.procgen.newNoiseGenerator(12345)
    local seed = generator:getSeed()

    print("LNoiseGenerator:getSeed=" .. seed)
end

--@api-stub: LNoiseGenerator:perlin1d
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:perlin1d(0.5)

    print(string.format("LNoiseGenerator:perlin1d=%.4f", value))
end

--@api-stub: LNoiseGenerator:perlin2d
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:perlin2d(0.3, 0.7)

    print(string.format("LNoiseGenerator:perlin2d=%.4f", value))
end

--@api-stub: LNoiseGenerator:perlin3d
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:perlin3d(0.2, 0.4, 0.8)

    print(string.format("LNoiseGenerator:perlin3d=%.4f", value))
end

--@api-stub: LNoiseGenerator:perlin4d
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:perlin4d(0.1, 0.2, 0.3, 0.6)

    print(string.format("LNoiseGenerator:perlin4d=%.4f", value))
end

--@api-stub: LNoiseGenerator:ridged
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:ridged(0.4, 0.6)

    print(string.format("LNoiseGenerator:ridged=%.4f", value))
end

--@api-stub: LNoiseGenerator:setSeed
do
    local generator = lurek.procgen.newNoiseGenerator(1)

    generator:setSeed(99999)

    print("LNoiseGenerator:setSeed=" .. generator:getSeed())
end

--@api-stub: LNoiseGenerator:simplex1d
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:simplex1d(0.5)

    print(string.format("LNoiseGenerator:simplex1d=%.4f", value))
end

--@api-stub: LNoiseGenerator:simplex2d
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:simplex2d(0.3, 0.8)

    print(string.format("LNoiseGenerator:simplex2d=%.4f", value))
end

--@api-stub: LNoiseGenerator:simplex3d
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:simplex3d(0.1, 0.5, 0.9)

    print(string.format("LNoiseGenerator:simplex3d=%.4f", value))
end

--@api-stub: LNoiseGenerator:turbulence
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:turbulence(0.5, 0.5, 4)

    print(string.format("LNoiseGenerator:turbulence=%.4f", value))
end

--@api-stub: LNoiseGenerator:type
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local type_name = generator:type()

    print("LNoiseGenerator:type=" .. type_name)
end

--@api-stub: LNoiseGenerator:typeOf
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local matches = generator:typeOf("LNoiseGenerator")

    print("LNoiseGenerator:typeOf=" .. tostring(matches))
end

--@api-stub: LNoiseGenerator:warpDomain
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local warped_x, warped_y = generator:warpDomain(0.3, 0.7, 0.1)

    print(string.format("LNoiseGenerator:warpDomain x=%.4f", warped_x))
    print(string.format("LNoiseGenerator:warpDomain y=%.4f", warped_y))
end

--@api-stub: LNoiseGenerator:worley2d
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:worley2d(0.5, 0.5)

    print(string.format("LNoiseGenerator:worley2d=%.4f", value))
end

--@api-stub: LNoiseGenerator:worley3d
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:worley3d(0.5, 0.5, 0.5)

    print(string.format("LNoiseGenerator:worley3d=%.4f", value))
end

--@api-stub: lurek.procgen.fbm
do
    local value = lurek.procgen.fbm(0.5, 0.5, 7, 4, 2.0, 0.5)
    local other = lurek.procgen.fbm(0.75, 0.25, 7, 4, 2.0, 0.5)

    print(string.format("lurek.procgen.fbm=%.4f", value))
    print(string.format("lurek.procgen.fbm other=%.4f", other))
end

--@api-stub: lurek.procgen.newNoiseGenerator
do
    local generator = lurek.procgen.newNoiseGenerator(777)

    print("lurek.procgen.newNoiseGenerator type=" .. generator:type())
    print("lurek.procgen.newNoiseGenerator seed=" .. generator:getSeed())
end

--@api-stub: lurek.procgen.perlin2d
do
    local value = lurek.procgen.perlin2d(0.2, 0.6)
    local seeded = lurek.procgen.perlin2d(0.2, 0.6, 9)

    print(string.format("lurek.procgen.perlin2d=%.4f", value))
    print(string.format("lurek.procgen.perlin2d seeded=%.4f", seeded))
end

--@api-stub: lurek.procgen.perlin3d
do
    local value = lurek.procgen.perlin3d(0.1, 0.3, 0.7)
    local seeded = lurek.procgen.perlin3d(0.1, 0.3, 0.7, 11)

    print(string.format("lurek.procgen.perlin3d=%.4f", value))
    print(string.format("lurek.procgen.perlin3d seeded=%.4f", seeded))
end

--@api-stub: lurek.procgen.simplexNoise
do
    local value2d = lurek.procgen.simplexNoise(0.4, 0.9)
    local value3d = lurek.procgen.simplexNoise(0.4, 0.9, 1.2)

    print(string.format("lurek.procgen.simplexNoise2d=%.4f", value2d))
    print(string.format("lurek.procgen.simplexNoise3d=%.4f", value3d))
end
