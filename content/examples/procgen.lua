-- content/examples/procgen.lua
-- Auto-generated from content/examples2/procgen_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/procgen.lua

--- Procgen Module: noise, dungeons, heightmaps, caves, L-systems, Voronoi, WFC, biomes, names

local function procgen_log(message)
    lurek.log.info("[procgen.example] " .. tostring(message))
end

local function example_print_log(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    lurek.log.info(table.concat(parts, " "))
end

--@api: lurek.procgen.simplex2d
do
    local value = lurek.procgen.simplex2d(1.5, 2.3)
    local mirrored = lurek.procgen.simplex2d(2.3, 1.5)
    local ridge = lurek.procgen.simplex2d(1.75, 2.55)
    procgen_log(string.format("simplex2d hillside=%.4f", value))
    procgen_log(string.format("simplex2d mirrored hillside=%.4f", mirrored))
    procgen_log(string.format("simplex2d ridge sample=%.4f", ridge))
end

--@api: lurek.procgen.perlinNoise
do
    local first = lurek.procgen.perlinNoise(0.5, 0.5, 4.0, 4.0)
    local tiled = lurek.procgen.perlinNoise(4.5, 0.5, 4.0, 4.0)
    local downstream = lurek.procgen.perlinNoise(0.5, 2.5, 4.0, 4.0)
    procgen_log(string.format("perlinNoise first=%.4f", first))
    procgen_log(string.format("perlinNoise tiled=%.4f", tiled))
    procgen_log(string.format("perlinNoise downstream=%.4f", downstream))
end

--@api: lurek.procgen.noiseMap
do
    local map = lurek.procgen.noiseMap(64, 64, {
        scale_x = 0.05,
        scale_y = 0.05,
        octaves = 4,
        lacunarity = 2.0,
        persistence = 0.5,
        seed = 42,
    })

    example_print_log("noiseMap cells=" .. #map)
    example_print_log(string.format("noiseMap first=%.4f", map[1]))
end

--@api: lurek.procgen.noiseMapParallel
do
    local map = lurek.procgen.noiseMapParallel(128, 128, {
        scale_x = 0.02,
        scale_y = 0.02,
        octaves = 6,
        lacunarity = 2.0,
        persistence = 0.5,
    })

    example_print_log("noiseMapParallel cells=" .. #map)
    example_print_log(string.format("noiseMapParallel midpoint=%.4f", map[4096]))
end

--@api: lurek.procgen.heightmap
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

    example_print_log("heightmap size=" .. hm.width .. "x" .. hm.height)
    example_print_log("heightmap cells=" .. #hm.cells)
end

--@api: lurek.procgen.cellularAutomata
do
    local cave = lurek.procgen.cellularAutomata(80, 60, {
        fill = 0.45,
        iterations = 5,
        birth = 5,
        survive = 4,
        seed = 777,
    })

    example_print_log("cellularAutomata cells=" .. #cave)
    example_print_log("cellularAutomata first=" .. tostring(cave[1]))
end

--@api: lurek.procgen.heightmapFromCellular
do
    local cells = lurek.procgen.cellularAutomata(64, 64, {
        fill = 0.4,
        iterations = 4,
        seed = 100,
    })
    local hm = lurek.procgen.heightmapFromCellular(64, 64, cells, 0)

    example_print_log("heightmapFromCellular size=" .. hm.width .. "x" .. hm.height)
    example_print_log(string.format("heightmapFromCellular first=%.4f", hm.cells[1]))
end

--@api: lurek.procgen.floodFill
do
    local cells = {
        200, 200, 0, 0,
        200, 200, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, 0,
    }
    local filled = lurek.procgen.floodFill(cells, 4, 4, 0, 0, 128, true)

    example_print_log("floodFill cells=" .. #filled)
    example_print_log("floodFill first=" .. tostring(filled[1]))
end

--@api: lurek.procgen.bspDungeon
do
    local dungeon = lurek.procgen.bspDungeon({
        width = 80,
        height = 60,
        min_size = 8,
        max_depth = 5,
        seed = 42,
        padding = 1,
    })

    example_print_log("bspDungeon rooms=" .. #dungeon.rooms)
    example_print_log("bspDungeon corridors=" .. #dungeon.corridors)
end

--@api: lurek.procgen.roomsDungeon
do
    local dungeon = lurek.procgen.roomsDungeon({
        width = 60,
        height = 40,
        max_rooms = 10,
        min_room_size = 5,
        max_room_size = 12,
        seed = 123,
    })

    example_print_log("roomsDungeon rooms=" .. #dungeon.rooms)
    example_print_log("roomsDungeon grid=" .. #dungeon.grid)
end

--@api: lurek.procgen.bspDungeonWithPrefabs
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

    example_print_log("bspDungeonWithPrefabs rooms=" .. #dungeon.rooms)
    example_print_log("bspDungeonWithPrefabs placed=" .. #placed)
end

--@api: lurek.procgen.roomsDungeonWithPrefabs
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

    example_print_log("roomsDungeonWithPrefabs size=" .. dungeon.width .. "x" .. dungeon.height)
    example_print_log("roomsDungeonWithPrefabs placed=" .. #placed)
end

--@api: lurek.procgen.poissonDisk
do
    local points = lurek.procgen.poissonDisk(200, 200, 15, 30, 42)
    local first = points[1]
    local second = points[2] or first
    procgen_log("poissonDisk spawn points=" .. #points)
    procgen_log(string.format("poissonDisk first=(%.2f, %.2f)", first.x, first.y))
    procgen_log(string.format("poissonDisk second=(%.2f, %.2f)", second.x, second.y))
end

--@api: lurek.procgen.voronoi
do
    local regions, dist1, dist2 = lurek.procgen.voronoi(100, 100, {
        { x = 20, y = 20 },
        { x = 80, y = 80 },
        { x = 50, y = 30 },
    })

    example_print_log("voronoi regions=" .. #regions)
    example_print_log(string.format("voronoi first distances=%.2f / %.2f", dist1[1], dist2[1]))
    example_print_log("voronoi first region=" .. tostring(regions[1]))
end

--@api: lurek.procgen.lsystem
do
    local result = lurek.procgen.lsystem({
        axiom = "F",
        iterations = 3,
        rules = { F = "F[+F]F[-F]F" },
    })

    example_print_log("lsystem length=" .. #result)
    example_print_log("lsystem preview=" .. result:sub(1, 40))
end

--@api: lurek.procgen.lsystemSegments
do
    local segments = lurek.procgen.lsystemSegments({
        axiom = "F",
        iterations = 4,
        rules = { F = "FF+[+F-F-F]-[-F+F+F]" },
    }, 25, 5.0)

    example_print_log("lsystemSegments count=" .. #segments)
    example_print_log("lsystemSegments firstExists=" .. tostring(segments[1] ~= nil))
end

--@api: lurek.procgen.wfcGenerate
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

    example_print_log("wfcGenerate size=" .. result.width .. "x" .. result.height)
    example_print_log("wfcGenerate cells=" .. #result.cells)
end

--@api: lurek.procgen.generateName
do
    local samples = { "Aldric", "Baldric", "Cedric", "Eldric", "Godric", "Fredric" }
    local name = lurek.procgen.generateName(samples, 4, 8, 1)
    local fallback = lurek.procgen.generateName(samples, 4, 8, 2)
    procgen_log("generateName result=" .. name)
    procgen_log("generateName fallback=" .. fallback)
    procgen_log("generateName sample count=" .. #samples)
end

--@api: lurek.procgen.newBiomeClassifier
do
    local classifier = lurek.procgen.newBiomeClassifier({
        ocean_threshold = 0.3,
        coast_threshold = 0.35,
        mountain_threshold = 0.8,
    })
    local biome = classifier:classify(0.5, 0.6, 0.5)

    example_print_log("newBiomeClassifier biome=" .. biome)
    example_print_log("newBiomeClassifier type=" .. classifier:type())
end

--@api: lurek.procgen.biomeColor
do
    local r, g, b, a = lurek.procgen.biomeColor("ocean")
    local brightness = r + g + b
    procgen_log("biomeColor ocean=" .. r .. "," .. g .. "," .. b .. "," .. a)
    procgen_log("biomeColor ocean brightness=" .. tostring(brightness))
    procgen_log("biomeColor alpha=" .. tostring(a))
end

--@api: lurek.procgen.worldGraph
do
    local world = lurek.procgen.worldGraph(500, 500, 12, 42)
    local first_region = world.regions[1]
    local first_edge = world.edges[1]
    procgen_log("worldGraph regions=" .. #world.regions)
    procgen_log("worldGraph edges=" .. #world.edges)
    procgen_log("worldGraph first region=" .. tostring(first_region and first_region.name or "nil") .. " first edge cost=" .. tostring(first_edge and first_edge.cost or "nil"))
end

--- Procgen Module Part 1: BiomeClassifier, generateNames, noiseMapParallelSeeded, simplex3d

--@api: LBiomeClassifier:classify
do
    local classifier = lurek.procgen.newBiomeClassifier({
        ocean_threshold = 0.28,
        coast_threshold = 0.34,
        warm_temperature = 0.65,
        wet_moisture = 0.7,
    })
    local biome = classifier:classify(0.5, 0.6, 0.4)

    example_print_log("LBiomeClassifier:classify=" .. biome)
end

--@api: LBiomeClassifier:classifyMap
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

    example_print_log("LBiomeClassifier:classifyMap size=" .. #map)
    example_print_log("LBiomeClassifier:classifyMap last=" .. map[#map])
end

--@api: LBiomeClassifier:type
do
    local classifier = lurek.procgen.newBiomeClassifier()
    local type_name = classifier:type()
    local sample = classifier:classify(0.82, 0.35, 0.2)
    procgen_log("LBiomeClassifier:type=" .. type_name)
    procgen_log("LBiomeClassifier sample biome=" .. sample)
    procgen_log("LBiomeClassifier type captured for climate debug")
end

--@api: LBiomeClassifier:typeOf
do
    local classifier = lurek.procgen.newBiomeClassifier()
    local matches = classifier:typeOf("LBiomeClassifier")
    local object_match = classifier:typeOf("LObject")
    local sample = classifier:classify(0.12, 0.85, 0.5)
    procgen_log("LBiomeClassifier:typeOf self=" .. tostring(matches))
    procgen_log("LBiomeClassifier:typeOf object=" .. tostring(object_match))
    procgen_log("LBiomeClassifier swamp sample=" .. sample)
end

--@api: lurek.procgen.generateNames
do
    local samples = { "Alon", "Beren", "Caran", "Doran", "Elan" }
    local names = lurek.procgen.generateNames(samples, 5, 3, 8, 42)
    local last = names[#names]
    procgen_log("generateNames count=" .. #names)
    procgen_log("generateNames first=" .. names[1])
    procgen_log("generateNames last=" .. tostring(last))
end

--@api: lurek.procgen.noiseMapParallelSeeded
do
    local map = lurek.procgen.noiseMapParallelSeeded(16, 16, {
        scale_x = 0.1,
        scale_y = 0.1,
        octaves = 4,
        seed = 12345,
    })

    example_print_log("noiseMapParallelSeeded cells=" .. #map)
    example_print_log(string.format("noiseMapParallelSeeded first=%.4f", map[1]))
end

--@api: lurek.procgen.simplex3d
do
    local value = lurek.procgen.simplex3d(0.1, 0.5, 0.9)
    local shifted = lurek.procgen.simplex3d(0.1, 0.5, 1.1)
    local animated = lurek.procgen.simplex3d(0.1, 0.5, 1.3)
    procgen_log(string.format("simplex3d base=%.4f", value))
    procgen_log(string.format("simplex3d shifted=%.4f", shifted))
    procgen_log(string.format("simplex3d animated=%.4f", animated))
end

--@api: lurek.procgen.perlin4d
do
    local value = lurek.procgen.perlin4d(0.1, 0.2, 0.3, 0.4)
    local seeded = lurek.procgen.perlin4d(0.1, 0.2, 0.3, 0.4, 17)
    local alternate = lurek.procgen.perlin4d(0.2, 0.3, 0.4, 0.5, 17)
    procgen_log(string.format("perlin4d=%.4f", value))
    procgen_log(string.format("perlin4d seeded=%.4f", seeded))
    procgen_log(string.format("perlin4d alternate=%.4f", alternate))
end

--@api: LNoiseGenerator:fbm
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:fbm(0.5, 0.5, 4, 2.0, 0.5)
    local valley = generator:fbm(0.25, 0.75, 4, 2.0, 0.5)
    procgen_log(string.format("LNoiseGenerator:fbm ridge=%.4f", value))
    procgen_log(string.format("LNoiseGenerator:fbm valley=%.4f", valley))
    procgen_log("LNoiseGenerator seed=" .. generator:getSeed())
end

--@api: LNoiseGenerator:generateMap
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

    example_print_log("LNoiseGenerator:generateMap cells=" .. #map)
    example_print_log(string.format("LNoiseGenerator:generateMap first=%.4f", map[1]))
end

--@api: LNoiseGenerator:generateMapCompute
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

    example_print_log("LNoiseGenerator:generateMapCompute cells=" .. #map)
    example_print_log(string.format("LNoiseGenerator:generateMapCompute first=%.4f", map[1]))
end

--@api: LNoiseGenerator:getSeed
do
    local generator = lurek.procgen.newNoiseGenerator(12345)
    local seed = generator:getSeed()
    local height_a = generator:perlin2d(0.2, 0.2)
    local height_b = generator:perlin2d(0.4, 0.4)
    procgen_log("LNoiseGenerator:getSeed=" .. seed)
    procgen_log(string.format("LNoiseGenerator sample a=%.4f", height_a))
    procgen_log(string.format("LNoiseGenerator sample b=%.4f", height_b))
end

--@api: LNoiseGenerator:perlin1d
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:perlin1d(0.5)
    local next_value = generator:perlin1d(0.75)
    procgen_log(string.format("LNoiseGenerator:perlin1d=%.4f", value))
    procgen_log(string.format("LNoiseGenerator:perlin1d next=%.4f", next_value))
    procgen_log("LNoiseGenerator seed=" .. generator:getSeed())
end

--@api: LNoiseGenerator:perlin2d
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:perlin2d(0.3, 0.7)
    local nearby = generator:perlin2d(0.35, 0.75)
    procgen_log(string.format("LNoiseGenerator:perlin2d=%.4f", value))
    procgen_log(string.format("LNoiseGenerator:perlin2d nearby=%.4f", nearby))
    procgen_log("LNoiseGenerator seed=" .. generator:getSeed())
end

--@api: LNoiseGenerator:perlin3d
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:perlin3d(0.2, 0.4, 0.8)
    local layered = generator:perlin3d(0.2, 0.4, 1.0)
    procgen_log(string.format("LNoiseGenerator:perlin3d=%.4f", value))
    procgen_log(string.format("LNoiseGenerator:perlin3d layered=%.4f", layered))
    procgen_log("LNoiseGenerator seed=" .. generator:getSeed())
end

--@api: LNoiseGenerator:perlin4d
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:perlin4d(0.1, 0.2, 0.3, 0.6)
    local shifted = generator:perlin4d(0.1, 0.2, 0.3, 0.8)
    procgen_log(string.format("LNoiseGenerator:perlin4d=%.4f", value))
    procgen_log(string.format("LNoiseGenerator:perlin4d shifted=%.4f", shifted))
    procgen_log("LNoiseGenerator seed=" .. generator:getSeed())
end

--@api: LNoiseGenerator:ridged
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:ridged(0.4, 0.6)
    local adjacent = generator:ridged(0.45, 0.65)
    procgen_log(string.format("LNoiseGenerator:ridged=%.4f", value))
    procgen_log(string.format("LNoiseGenerator:ridged adjacent=%.4f", adjacent))
    procgen_log("LNoiseGenerator seed=" .. generator:getSeed())
end

--@api: LNoiseGenerator:setSeed
do
    local generator = lurek.procgen.newNoiseGenerator(1)
    local before = generator:getSeed()
    generator:setSeed(99999)
    local after = generator:getSeed()
    local sample = generator:simplex2d(0.2, 0.8)
    procgen_log("LNoiseGenerator:setSeed before=" .. before)
    procgen_log("LNoiseGenerator:setSeed after=" .. after)
    procgen_log(string.format("LNoiseGenerator sample after reseed=%.4f", sample))
end

--@api: LNoiseGenerator:simplex1d
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:simplex1d(0.5)
    local next_value = generator:simplex1d(0.75)
    procgen_log(string.format("LNoiseGenerator:simplex1d=%.4f", value))
    procgen_log(string.format("LNoiseGenerator:simplex1d next=%.4f", next_value))
    procgen_log("LNoiseGenerator seed=" .. generator:getSeed())
end

--@api: LNoiseGenerator:simplex2d
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:simplex2d(0.3, 0.8)
    local nearby = generator:simplex2d(0.35, 0.85)
    procgen_log(string.format("LNoiseGenerator:simplex2d=%.4f", value))
    procgen_log(string.format("LNoiseGenerator:simplex2d nearby=%.4f", nearby))
    procgen_log("LNoiseGenerator seed=" .. generator:getSeed())
end

--@api: LNoiseGenerator:simplex3d
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:simplex3d(0.1, 0.5, 0.9)
    local layered = generator:simplex3d(0.1, 0.5, 1.1)
    procgen_log(string.format("LNoiseGenerator:simplex3d=%.4f", value))
    procgen_log(string.format("LNoiseGenerator:simplex3d layered=%.4f", layered))
    procgen_log("LNoiseGenerator seed=" .. generator:getSeed())
end

--@api: LNoiseGenerator:turbulence
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:turbulence(0.5, 0.5, 4)
    local border = generator:turbulence(0.2, 0.8, 4)
    procgen_log(string.format("LNoiseGenerator:turbulence=%.4f", value))
    procgen_log(string.format("LNoiseGenerator:turbulence border=%.4f", border))
    procgen_log("LNoiseGenerator seed=" .. generator:getSeed())
end

--@api: LNoiseGenerator:type
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local type_name = generator:type()
    local sample = generator:perlin2d(0.1, 0.1)
    procgen_log("LNoiseGenerator:type=" .. type_name)
    procgen_log(string.format("LNoiseGenerator sample=%.4f", sample))
    procgen_log("LNoiseGenerator seed=" .. generator:getSeed())
end

--@api: LNoiseGenerator:typeOf
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local matches = generator:typeOf("LNoiseGenerator")
    local object_match = generator:typeOf("LObject")
    local sample = generator:simplex2d(0.4, 0.4)
    procgen_log("LNoiseGenerator:typeOf self=" .. tostring(matches))
    procgen_log("LNoiseGenerator:typeOf object=" .. tostring(object_match))
    procgen_log(string.format("LNoiseGenerator type sample=%.4f", sample))
end

--@api: LNoiseGenerator:warpDomain
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local warped_x, warped_y = generator:warpDomain(0.3, 0.7, 0.1)
    local noise_after_warp = generator:perlin2d(warped_x, warped_y)
    procgen_log(string.format("LNoiseGenerator:warpDomain x=%.4f", warped_x))
    procgen_log(string.format("LNoiseGenerator:warpDomain y=%.4f", warped_y))
    procgen_log(string.format("LNoiseGenerator warped sample=%.4f", noise_after_warp))
end

--@api: LNoiseGenerator:worley2d
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:worley2d(0.5, 0.5)
    local second = generator:worley2d(0.6, 0.5)
    procgen_log(string.format("LNoiseGenerator:worley2d=%.4f", value))
    procgen_log(string.format("LNoiseGenerator:worley2d second=%.4f", second))
    procgen_log("LNoiseGenerator seed=" .. generator:getSeed())
end

--@api: LNoiseGenerator:worley3d
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:worley3d(0.5, 0.5, 0.5)
    local layer = generator:worley3d(0.5, 0.5, 0.7)
    procgen_log(string.format("LNoiseGenerator:worley3d=%.4f", value))
    procgen_log(string.format("LNoiseGenerator:worley3d layer=%.4f", layer))
    procgen_log("LNoiseGenerator seed=" .. generator:getSeed())
end

--@api: lurek.procgen.fbm
do
    local value = lurek.procgen.fbm(0.5, 0.5, 7, 4, 2.0, 0.5)
    local other = lurek.procgen.fbm(0.75, 0.25, 7, 4, 2.0, 0.5)
    local ridge = lurek.procgen.fbm(0.25, 0.75, 7, 4, 2.0, 0.5)
    procgen_log(string.format("lurek.procgen.fbm=%.4f", value))
    procgen_log(string.format("lurek.procgen.fbm other=%.4f", other))
    procgen_log(string.format("lurek.procgen.fbm ridge=%.4f", ridge))
end

--@api: lurek.procgen.newNoiseGenerator
do
    local generator = lurek.procgen.newNoiseGenerator(777)
    local sample = generator:simplex2d(0.2, 0.2)
    procgen_log("lurek.procgen.newNoiseGenerator type=" .. generator:type())
    procgen_log("lurek.procgen.newNoiseGenerator seed=" .. generator:getSeed())
    procgen_log(string.format("lurek.procgen.newNoiseGenerator sample=%.4f", sample))
end

--@api: lurek.procgen.perlin2d
do
    local value = lurek.procgen.perlin2d(0.2, 0.6)
    local seeded = lurek.procgen.perlin2d(0.2, 0.6, 9)
    local nearby = lurek.procgen.perlin2d(0.25, 0.65, 9)
    procgen_log(string.format("lurek.procgen.perlin2d=%.4f", value))
    procgen_log(string.format("lurek.procgen.perlin2d seeded=%.4f", seeded))
    procgen_log(string.format("lurek.procgen.perlin2d nearby=%.4f", nearby))
end

--@api: lurek.procgen.perlin3d
do
    local value = lurek.procgen.perlin3d(0.1, 0.3, 0.7)
    local seeded = lurek.procgen.perlin3d(0.1, 0.3, 0.7, 11)
    local layered = lurek.procgen.perlin3d(0.1, 0.3, 0.9, 11)
    procgen_log(string.format("lurek.procgen.perlin3d=%.4f", value))
    procgen_log(string.format("lurek.procgen.perlin3d seeded=%.4f", seeded))
    procgen_log(string.format("lurek.procgen.perlin3d layered=%.4f", layered))
end

--@api: lurek.procgen.simplexNoise
do
    local value2d = lurek.procgen.simplexNoise(0.4, 0.9)
    local value3d = lurek.procgen.simplexNoise(0.4, 0.9, 1.2)
    local animated = lurek.procgen.simplexNoise(0.4, 0.9, 1.4)
    procgen_log(string.format("lurek.procgen.simplexNoise2d=%.4f", value2d))
    procgen_log(string.format("lurek.procgen.simplexNoise3d=%.4f", value3d))
    procgen_log(string.format("lurek.procgen.simplexNoise animated=%.4f", animated))
end

--@api: lurek.procgen.setConstraintsFromLLM
do
    -- LLM may be offline in CI; result is always a table (empty on error)
    local constraints = lurek.procgen.setConstraintsFromLLM("2 tiles: grass and water. Grass can be next to grass or water. Water can only be next to water.")
    local next_key = next(constraints)
    procgen_log("setConstraintsFromLLM type=" .. type(constraints))
    procgen_log("setConstraintsFromLLM has_entries=" .. tostring(next_key ~= nil))
    procgen_log("setConstraintsFromLLM first_key=" .. tostring(next_key))
end

--@api: lurek.procgen.wfcFromPrompt
do
    -- LLM may be offline in CI; result always has the required shape fields
    local grid = lurek.procgen.wfcFromPrompt(
        "small dungeon with stone floor and walls",
        { width = 4, height = 4, seed = 1, max_attempts = 5 }
    )
    example_print_log("wfcFromPrompt width=" .. grid.width .. " height=" .. grid.height)
    example_print_log("wfcFromPrompt cells_type=" .. type(grid.cells))
    example_print_log("wfcFromPrompt failed_type=" .. type(grid.failed_cells))
end

--@api: lurek.procgen.newCellular
do
    local ca = lurek.procgen.newCellular(32, 32)
    ca:setCell(5, 5, lurek.procgen.CELL_SAND)
    ca:step()
    local cell = ca:getCell(5, 5)
    procgen_log("cellular type = " .. ca:type())
    procgen_log("cellular sand count = " .. ca:countCells(lurek.procgen.CELL_SAND))
    procgen_log("cellular sample cell = " .. tostring(cell))
end

--@api: LCellular:countCells
do
    local ca = lurek.procgen.newCellular(16, 16)
    ca:setCell(0, 0, lurek.procgen.CELL_ROCK)
    ca:setCell(1, 0, lurek.procgen.CELL_ROCK)
    local rocks = ca:countCells(lurek.procgen.CELL_ROCK)
    local sand = ca:countCells(lurek.procgen.CELL_SAND)
    procgen_log("rock count = " .. rocks)
    procgen_log("sand count = " .. sand)
    procgen_log("cellular type = " .. ca:type())
end

--@api: LCellular:fillCircle
do
    local ca = lurek.procgen.newCellular(32, 32)
    ca:fillCircle(16, 16, 5, lurek.procgen.CELL_WATER)
    local water = ca:countCells(lurek.procgen.CELL_WATER)
    local center = ca:getCell(16, 16)
    procgen_log("fillCircle water count = " .. water)
    procgen_log("fillCircle center cell = " .. tostring(center))
    procgen_log("fillCircle image bytes = " .. #ca:toImageDataRegion(8, 8, 16, 16))
end

--@api: LCellular:fillRect
do
    local ca = lurek.procgen.newCellular(32, 32)
    ca:fillRect(0, 0, 8, 8, lurek.procgen.CELL_ROCK)
    local rocks = ca:countCells(lurek.procgen.CELL_ROCK)
    local corner = ca:getCell(0, 0)
    procgen_log("fillRect rock count = " .. rocks)
    procgen_log("fillRect corner cell = " .. tostring(corner))
    procgen_log("fillRect bytes = " .. #ca:toBytes())
end

--@api: LCellular:findCells
do
    local ca = lurek.procgen.newCellular(16, 16)
    ca:setCell(3, 7, lurek.procgen.CELL_WATER)
    local found = ca:findCells(lurek.procgen.CELL_WATER)
    local first = found[1]
    procgen_log("found count = " .. #found)
    procgen_log("first water cell = " .. tostring(first and first.x or "nil") .. "," .. tostring(first and first.y or "nil"))
    procgen_log("water count = " .. ca:countCells(lurek.procgen.CELL_WATER))
end

--@api: LCellular:getCell
do
    local ca = lurek.procgen.newCellular(16, 16)
    ca:setCell(0, 0, lurek.procgen.CELL_FIRE)
    local v = ca:getCell(0, 0)
    local neighbor = ca:getCell(1, 0)
    procgen_log("cell = " .. v)
    procgen_log("neighbor = " .. neighbor)
    procgen_log("fire count = " .. ca:countCells(lurek.procgen.CELL_FIRE))
end

--@api: LCellular:loadFromBytes
do
    local ca = lurek.procgen.newCellular(8, 8)
    local bytes = ca:toBytes()
    local ca2 = lurek.procgen.newCellular(8, 8)
    ca2:loadFromBytes(bytes)
    example_print_log("loadFromBytes done")
end

--@api: LCellular:setCell
do
    local ca = lurek.procgen.newCellular(16, 16)
    ca:setCell(3, 3, lurek.procgen.CELL_SAND)
    local cell = ca:getCell(3, 3)
    local sand = ca:countCells(lurek.procgen.CELL_SAND)
    procgen_log("setCell value = " .. tostring(cell))
    procgen_log("setCell sand count = " .. sand)
    procgen_log("cellular type = " .. ca:type())
end

--@api: LCellular:step
do
    local ca = lurek.procgen.newCellular(16, 16)
    ca:setCell(4, 4, lurek.procgen.CELL_SAND)
    ca:step()
    local sample = ca:getCell(4, 4)
    local sand = ca:countCells(lurek.procgen.CELL_SAND)
    procgen_log("step sample cell = " .. tostring(sample))
    procgen_log("step sand count = " .. sand)
    procgen_log("step bytes = " .. #ca:toBytes())
end

--@api: LCellular:stepN
do
    local ca = lurek.procgen.newCellular(16, 16)
    ca:setCell(4, 4, lurek.procgen.CELL_SAND)
    ca:stepN(5)
    local sample = ca:getCell(4, 4)
    local sand = ca:countCells(lurek.procgen.CELL_SAND)
    procgen_log("stepN sample cell = " .. tostring(sample))
    procgen_log("stepN sand count = " .. sand)
    procgen_log("stepN bytes = " .. #ca:toBytes())
end

--@api: LCellular:toBytes
do
    local ca = lurek.procgen.newCellular(8, 8)
    ca:setCell(2, 2, lurek.procgen.CELL_ROCK)
    local bytes = ca:toBytes()
    procgen_log("toBytes length = " .. #bytes)
    procgen_log("toBytes rock count = " .. ca:countCells(lurek.procgen.CELL_ROCK))
    procgen_log("toBytes type = " .. ca:type())
end

--@api: LCellular:toImageData
do
    local ca = lurek.procgen.newCellular(16, 16)
    ca:fillRect(0, 0, 4, 4, lurek.procgen.CELL_WATER)
    local img = ca:toImageData()
    procgen_log("toImageData bytes = " .. #img)
    procgen_log("toImageData water count = " .. ca:countCells(lurek.procgen.CELL_WATER))
    procgen_log("toImageData type = " .. ca:type())
end

--@api: LCellular:toImageDataRegion
do
    local ca = lurek.procgen.newCellular(32, 32)
    ca:fillCircle(16, 16, 6, lurek.procgen.CELL_FIRE)
    local img = ca:toImageDataRegion(0, 0, 16, 16)
    procgen_log("toImageDataRegion bytes = " .. #img)
    procgen_log("toImageDataRegion fire count = " .. ca:countCells(lurek.procgen.CELL_FIRE))
    procgen_log("toImageDataRegion type = " .. ca:type())
end

--@api: LCellular:type
do
    local ca = lurek.procgen.newCellular(8, 8)
    ca:setCell(1, 1, lurek.procgen.CELL_GAS)
    procgen_log("type = " .. ca:type())
    procgen_log("gas count = " .. ca:countCells(lurek.procgen.CELL_GAS))
    procgen_log("sample cell = " .. tostring(ca:getCell(1, 1)))
end

--@api: LCellular:typeOf
do
    local ca = lurek.procgen.newCellular(8, 8)
    ca:setCell(1, 1, lurek.procgen.CELL_GAS)
    procgen_log("typeOf LCellular = " .. tostring(ca:typeOf("LCellular")))
    procgen_log("cells width = " .. tostring(ca:getWidth()))
    procgen_log("gas count = " .. ca:countCells(lurek.procgen.CELL_GAS))
end
