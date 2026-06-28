-- content/examples/procgen.lua
-- Auto-generated from content/examples2/procgen_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/procgen.lua

--- Procgen Module: noise, dungeons, heightmaps, caves, L-systems, Voronoi, WFC, biomes, names



--@api: lurek.procgen.simplex2d
do

    local value = lurek.procgen.simplex2d(1.5, 2.3)
    local mirrored = lurek.procgen.simplex2d(2.3, 1.5)
    local ridge = lurek.procgen.simplex2d(1.75, 2.55)
    lurek.log.info(string.format("simplex2d hillside=%.4f", value))
    lurek.log.info(string.format("simplex2d mirrored hillside=%.4f", mirrored))
    lurek.log.info(string.format("simplex2d ridge sample=%.4f", ridge))
end

--@api: lurek.procgen.perlinNoise
do

    local first = lurek.procgen.perlinNoise(0.5, 0.5, 4.0, 4.0)
    local tiled = lurek.procgen.perlinNoise(4.5, 0.5, 4.0, 4.0)
    local downstream = lurek.procgen.perlinNoise(0.5, 2.5, 4.0, 4.0)
    lurek.log.info(string.format("perlinNoise first=%.4f", first))
    lurek.log.info(string.format("perlinNoise tiled=%.4f", tiled))
    lurek.log.info(string.format("perlinNoise downstream=%.4f", downstream))
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

    lurek.log.info("noiseMap cells=" .. #map)
    lurek.log.info(string.format("noiseMap first=%.4f", map[1]))
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

    lurek.log.info("noiseMapParallel cells=" .. #map)
    lurek.log.info(string.format("noiseMapParallel midpoint=%.4f", map[4096]))
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

    lurek.log.info("heightmap size=" .. hm.width .. "x" .. hm.height)
    lurek.log.info("heightmap cells=" .. #hm.cells)
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

    lurek.log.info("cellularAutomata cells=" .. #cave)
    lurek.log.info("cellularAutomata first=" .. tostring(cave[1]))
end

--@api: lurek.procgen.heightmapFromCellular
do

    local cells = lurek.procgen.cellularAutomata(64, 64, {
        fill = 0.4,
        iterations = 4,
        seed = 100,
    })
    local hm = lurek.procgen.heightmapFromCellular(64, 64, cells, 0)

    lurek.log.info("heightmapFromCellular size=" .. hm.width .. "x" .. hm.height)
    lurek.log.info(string.format("heightmapFromCellular first=%.4f", hm.cells[1]))
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

    lurek.log.info("floodFill cells=" .. #filled)
    lurek.log.info("floodFill first=" .. tostring(filled[1]))
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

    lurek.log.info("bspDungeon rooms=" .. #dungeon.rooms)
    lurek.log.info("bspDungeon corridors=" .. #dungeon.corridors)
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

    lurek.log.info("roomsDungeon rooms=" .. #dungeon.rooms)
    lurek.log.info("roomsDungeon grid=" .. #dungeon.grid)
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

    lurek.log.info("bspDungeonWithPrefabs rooms=" .. #dungeon.rooms)
    lurek.log.info("bspDungeonWithPrefabs placed=" .. #placed)
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

    lurek.log.info("roomsDungeonWithPrefabs size=" .. dungeon.width .. "x" .. dungeon.height)
    lurek.log.info("roomsDungeonWithPrefabs placed=" .. #placed)
end

--@api: lurek.procgen.poissonDisk
do

    local points = lurek.procgen.poissonDisk(200, 200, 15, 30, 42)
    local first = points[1]
    local second = points[2] or first
    lurek.log.info("poissonDisk spawn points=" .. #points)
    lurek.log.info(string.format("poissonDisk first=(%.2f, %.2f)", first.x, first.y))
    lurek.log.info(string.format("poissonDisk second=(%.2f, %.2f)", second.x, second.y))
end

--@api: lurek.procgen.voronoi
do

    local regions, dist1, dist2 = lurek.procgen.voronoi(100, 100, {
        { x = 20, y = 20 },
        { x = 80, y = 80 },
        { x = 50, y = 30 },
    })

    lurek.log.info("voronoi regions=" .. #regions)
    lurek.log.info(string.format("voronoi first distances=%.2f / %.2f", dist1[1], dist2[1]))
    lurek.log.info("voronoi first region=" .. tostring(regions[1]))
end

--@api: lurek.procgen.lsystem
do

    local result = lurek.procgen.lsystem({
        axiom = "F",
        iterations = 3,
        rules = { F = "F[+F]F[-F]F" },
    })

    lurek.log.info("lsystem length=" .. #result)
    lurek.log.info("lsystem preview=" .. result:sub(1, 40))
end

--@api: lurek.procgen.lsystemSegments
do

    local segments = lurek.procgen.lsystemSegments({
        axiom = "F",
        iterations = 4,
        rules = { F = "FF+[+F-F-F]-[-F+F+F]" },
    }, 25, 5.0)

    lurek.log.info("lsystemSegments count=" .. #segments)
    lurek.log.info("lsystemSegments firstExists=" .. tostring(segments[1] ~= nil))
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

    lurek.log.info("wfcGenerate size=" .. result.width .. "x" .. result.height)
    lurek.log.info("wfcGenerate cells=" .. #result.cells)
end

--@api: lurek.procgen.generateName
do

    local samples = { "Aldric", "Baldric", "Cedric", "Eldric", "Godric", "Fredric" }
    local name = lurek.procgen.generateName(samples, 4, 8, 1)
    local fallback = lurek.procgen.generateName(samples, 4, 8, 2)
    lurek.log.info("generateName result=" .. name)
    lurek.log.info("generateName fallback=" .. fallback)
    lurek.log.info("generateName sample count=" .. #samples)
end

--@api: lurek.procgen.newBiomeClassifier
do

    local classifier = lurek.procgen.newBiomeClassifier({
        ocean_threshold = 0.3,
        coast_threshold = 0.35,
        mountain_threshold = 0.8,
    })
    local biome = classifier:classify(0.5, 0.6, 0.5)

    lurek.log.info("newBiomeClassifier biome=" .. biome)
    lurek.log.info("newBiomeClassifier type=" .. classifier:type())
end

--@api: lurek.procgen.biomeColor
do

    local r, g, b, a = lurek.procgen.biomeColor("ocean")
    local brightness = r + g + b
    lurek.log.info("biomeColor ocean=" .. r .. "," .. g .. "," .. b .. "," .. a)
    lurek.log.info("biomeColor ocean brightness=" .. tostring(brightness))
    lurek.log.info("biomeColor alpha=" .. tostring(a))
end

--@api: lurek.procgen.worldGraph
do

    local world = lurek.procgen.worldGraph(500, 500, 12, 42)
    local first_region = world.regions[1]
    local first_edge = world.edges[1]
    lurek.log.info("worldGraph regions=" .. #world.regions)
    lurek.log.info("worldGraph edges=" .. #world.edges)
    lurek.log.info("worldGraph first region=" .. tostring(first_region and first_region.name or "nil") .. " first edge cost=" .. tostring(first_edge and first_edge.cost or "nil"))
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

    lurek.log.info("LBiomeClassifier:classify=" .. biome)
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

    lurek.log.info("LBiomeClassifier:classifyMap size=" .. #map)
    lurek.log.info("LBiomeClassifier:classifyMap last=" .. map[#map])
end

--@api: LBiomeClassifier:type
do

    local classifier = lurek.procgen.newBiomeClassifier()
    local type_name = classifier:type()
    local sample = classifier:classify(0.82, 0.35, 0.2)
    lurek.log.info("LBiomeClassifier:type=" .. type_name)
    lurek.log.info("LBiomeClassifier sample biome=" .. sample)
    lurek.log.info("LBiomeClassifier type captured for climate debug")
end

--@api: LBiomeClassifier:typeOf
do

    local classifier = lurek.procgen.newBiomeClassifier()
    local matches = classifier:typeOf("LBiomeClassifier")
    local object_match = classifier:typeOf("LObject")
    local sample = classifier:classify(0.12, 0.85, 0.5)
    lurek.log.info("LBiomeClassifier:typeOf self=" .. tostring(matches))
    lurek.log.info("LBiomeClassifier:typeOf object=" .. tostring(object_match))
    lurek.log.info("LBiomeClassifier swamp sample=" .. sample)
end

--@api: lurek.procgen.generateNames
do

    local samples = { "Alon", "Beren", "Caran", "Doran", "Elan" }
    local names = lurek.procgen.generateNames(samples, 5, 3, 8, 42)
    local last = names[#names]
    lurek.log.info("generateNames count=" .. #names)
    lurek.log.info("generateNames first=" .. names[1])
    lurek.log.info("generateNames last=" .. tostring(last))
end

--@api: lurek.procgen.noiseMapParallelSeeded
do

    local map = lurek.procgen.noiseMapParallelSeeded(16, 16, {
        scale_x = 0.1,
        scale_y = 0.1,
        octaves = 4,
        seed = 12345,
    })

    lurek.log.info("noiseMapParallelSeeded cells=" .. #map)
    lurek.log.info(string.format("noiseMapParallelSeeded first=%.4f", map[1]))
end

--@api: lurek.procgen.simplex3d
do

    local value = lurek.procgen.simplex3d(0.1, 0.5, 0.9)
    local shifted = lurek.procgen.simplex3d(0.1, 0.5, 1.1)
    local animated = lurek.procgen.simplex3d(0.1, 0.5, 1.3)
    lurek.log.info(string.format("simplex3d base=%.4f", value))
    lurek.log.info(string.format("simplex3d shifted=%.4f", shifted))
    lurek.log.info(string.format("simplex3d animated=%.4f", animated))
end

--@api: lurek.procgen.perlin4d
do

    local value = lurek.procgen.perlin4d(0.1, 0.2, 0.3, 0.4)
    local seeded = lurek.procgen.perlin4d(0.1, 0.2, 0.3, 0.4, 17)
    local alternate = lurek.procgen.perlin4d(0.2, 0.3, 0.4, 0.5, 17)
    lurek.log.info(string.format("perlin4d=%.4f", value))
    lurek.log.info(string.format("perlin4d seeded=%.4f", seeded))
    lurek.log.info(string.format("perlin4d alternate=%.4f", alternate))
end

--@api: LNoiseGenerator:fbm
do

    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:fbm(0.5, 0.5, 4, 2.0, 0.5)
    local valley = generator:fbm(0.25, 0.75, 4, 2.0, 0.5)
    lurek.log.info(string.format("LNoiseGenerator:fbm ridge=%.4f", value))
    lurek.log.info(string.format("LNoiseGenerator:fbm valley=%.4f", valley))
    lurek.log.info("LNoiseGenerator seed=" .. generator:getSeed())
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

    lurek.log.info("LNoiseGenerator:generateMap cells=" .. #map)
    lurek.log.info(string.format("LNoiseGenerator:generateMap first=%.4f", map[1]))
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

    lurek.log.info("LNoiseGenerator:generateMapCompute cells=" .. #map)
    lurek.log.info(string.format("LNoiseGenerator:generateMapCompute first=%.4f", map[1]))
end

--@api: LNoiseGenerator:getSeed
do

    local generator = lurek.procgen.newNoiseGenerator(12345)
    local seed = generator:getSeed()
    local height_a = generator:perlin2d(0.2, 0.2)
    local height_b = generator:perlin2d(0.4, 0.4)
    lurek.log.info("LNoiseGenerator:getSeed=" .. seed)
    lurek.log.info(string.format("LNoiseGenerator sample a=%.4f", height_a))
    lurek.log.info(string.format("LNoiseGenerator sample b=%.4f", height_b))
end

--@api: LNoiseGenerator:perlin1d
do

    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:perlin1d(0.5)
    local next_value = generator:perlin1d(0.75)
    lurek.log.info(string.format("LNoiseGenerator:perlin1d=%.4f", value))
    lurek.log.info(string.format("LNoiseGenerator:perlin1d next=%.4f", next_value))
    lurek.log.info("LNoiseGenerator seed=" .. generator:getSeed())
end

--@api: LNoiseGenerator:perlin2d
do

    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:perlin2d(0.3, 0.7)
    local nearby = generator:perlin2d(0.35, 0.75)
    lurek.log.info(string.format("LNoiseGenerator:perlin2d=%.4f", value))
    lurek.log.info(string.format("LNoiseGenerator:perlin2d nearby=%.4f", nearby))
    lurek.log.info("LNoiseGenerator seed=" .. generator:getSeed())
end

--@api: LNoiseGenerator:perlin3d
do

    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:perlin3d(0.2, 0.4, 0.8)
    local layered = generator:perlin3d(0.2, 0.4, 1.0)
    lurek.log.info(string.format("LNoiseGenerator:perlin3d=%.4f", value))
    lurek.log.info(string.format("LNoiseGenerator:perlin3d layered=%.4f", layered))
    lurek.log.info("LNoiseGenerator seed=" .. generator:getSeed())
end

--@api: LNoiseGenerator:perlin4d
do

    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:perlin4d(0.1, 0.2, 0.3, 0.6)
    local shifted = generator:perlin4d(0.1, 0.2, 0.3, 0.8)
    lurek.log.info(string.format("LNoiseGenerator:perlin4d=%.4f", value))
    lurek.log.info(string.format("LNoiseGenerator:perlin4d shifted=%.4f", shifted))
    lurek.log.info("LNoiseGenerator seed=" .. generator:getSeed())
end

--@api: LNoiseGenerator:ridged
do

    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:ridged(0.4, 0.6)
    local adjacent = generator:ridged(0.45, 0.65)
    lurek.log.info(string.format("LNoiseGenerator:ridged=%.4f", value))
    lurek.log.info(string.format("LNoiseGenerator:ridged adjacent=%.4f", adjacent))
    lurek.log.info("LNoiseGenerator seed=" .. generator:getSeed())
end

--@api: LNoiseGenerator:setSeed
do

    local generator = lurek.procgen.newNoiseGenerator(1)
    local before = generator:getSeed()
    generator:setSeed(99999)
    local after = generator:getSeed()
    local sample = generator:simplex2d(0.2, 0.8)
    lurek.log.info("LNoiseGenerator:setSeed before=" .. before)
    lurek.log.info("LNoiseGenerator:setSeed after=" .. after)
    lurek.log.info(string.format("LNoiseGenerator sample after reseed=%.4f", sample))
end

--@api: LNoiseGenerator:simplex1d
do

    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:simplex1d(0.5)
    local next_value = generator:simplex1d(0.75)
    lurek.log.info(string.format("LNoiseGenerator:simplex1d=%.4f", value))
    lurek.log.info(string.format("LNoiseGenerator:simplex1d next=%.4f", next_value))
    lurek.log.info("LNoiseGenerator seed=" .. generator:getSeed())
end

--@api: LNoiseGenerator:simplex2d
do

    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:simplex2d(0.3, 0.8)
    local nearby = generator:simplex2d(0.35, 0.85)
    lurek.log.info(string.format("LNoiseGenerator:simplex2d=%.4f", value))
    lurek.log.info(string.format("LNoiseGenerator:simplex2d nearby=%.4f", nearby))
    lurek.log.info("LNoiseGenerator seed=" .. generator:getSeed())
end

--@api: LNoiseGenerator:simplex3d
do

    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:simplex3d(0.1, 0.5, 0.9)
    local layered = generator:simplex3d(0.1, 0.5, 1.1)
    lurek.log.info(string.format("LNoiseGenerator:simplex3d=%.4f", value))
    lurek.log.info(string.format("LNoiseGenerator:simplex3d layered=%.4f", layered))
    lurek.log.info("LNoiseGenerator seed=" .. generator:getSeed())
end

--@api: LNoiseGenerator:turbulence
do

    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:turbulence(0.5, 0.5, 4)
    local border = generator:turbulence(0.2, 0.8, 4)
    lurek.log.info(string.format("LNoiseGenerator:turbulence=%.4f", value))
    lurek.log.info(string.format("LNoiseGenerator:turbulence border=%.4f", border))
    lurek.log.info("LNoiseGenerator seed=" .. generator:getSeed())
end

--@api: LNoiseGenerator:type
do

    local generator = lurek.procgen.newNoiseGenerator(42)
    local type_name = generator:type()
    local sample = generator:perlin2d(0.1, 0.1)
    lurek.log.info("LNoiseGenerator:type=" .. type_name)
    lurek.log.info(string.format("LNoiseGenerator sample=%.4f", sample))
    lurek.log.info("LNoiseGenerator seed=" .. generator:getSeed())
end

--@api: LNoiseGenerator:typeOf
do

    local generator = lurek.procgen.newNoiseGenerator(42)
    local matches = generator:typeOf("LNoiseGenerator")
    local object_match = generator:typeOf("LObject")
    local sample = generator:simplex2d(0.4, 0.4)
    lurek.log.info("LNoiseGenerator:typeOf self=" .. tostring(matches))
    lurek.log.info("LNoiseGenerator:typeOf object=" .. tostring(object_match))
    lurek.log.info(string.format("LNoiseGenerator type sample=%.4f", sample))
end

--@api: LNoiseGenerator:warpDomain
do

    local generator = lurek.procgen.newNoiseGenerator(42)
    local warped_x, warped_y = generator:warpDomain(0.3, 0.7, 0.1)
    local noise_after_warp = generator:perlin2d(warped_x, warped_y)
    lurek.log.info(string.format("LNoiseGenerator:warpDomain x=%.4f", warped_x))
    lurek.log.info(string.format("LNoiseGenerator:warpDomain y=%.4f", warped_y))
    lurek.log.info(string.format("LNoiseGenerator warped sample=%.4f", noise_after_warp))
end

--@api: LNoiseGenerator:worley2d
do

    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:worley2d(0.5, 0.5)
    local second = generator:worley2d(0.6, 0.5)
    lurek.log.info(string.format("LNoiseGenerator:worley2d=%.4f", value))
    lurek.log.info(string.format("LNoiseGenerator:worley2d second=%.4f", second))
    lurek.log.info("LNoiseGenerator seed=" .. generator:getSeed())
end

--@api: LNoiseGenerator:worley3d
do

    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:worley3d(0.5, 0.5, 0.5)
    local layer = generator:worley3d(0.5, 0.5, 0.7)
    lurek.log.info(string.format("LNoiseGenerator:worley3d=%.4f", value))
    lurek.log.info(string.format("LNoiseGenerator:worley3d layer=%.4f", layer))
    lurek.log.info("LNoiseGenerator seed=" .. generator:getSeed())
end

--@api: lurek.procgen.fbm
do

    local value = lurek.procgen.fbm(0.5, 0.5, 7, 4, 2.0, 0.5)
    local other = lurek.procgen.fbm(0.75, 0.25, 7, 4, 2.0, 0.5)
    local ridge = lurek.procgen.fbm(0.25, 0.75, 7, 4, 2.0, 0.5)
    lurek.log.info(string.format("lurek.procgen.fbm=%.4f", value))
    lurek.log.info(string.format("lurek.procgen.fbm other=%.4f", other))
    lurek.log.info(string.format("lurek.procgen.fbm ridge=%.4f", ridge))
end

--@api: lurek.procgen.newNoiseGenerator
do

    local generator = lurek.procgen.newNoiseGenerator(777)
    local sample = generator:simplex2d(0.2, 0.2)
    lurek.log.info("lurek.procgen.newNoiseGenerator type=" .. generator:type())
    lurek.log.info("lurek.procgen.newNoiseGenerator seed=" .. generator:getSeed())
    lurek.log.info(string.format("lurek.procgen.newNoiseGenerator sample=%.4f", sample))
end

--@api: lurek.procgen.perlin2d
do

    local value = lurek.procgen.perlin2d(0.2, 0.6)
    local seeded = lurek.procgen.perlin2d(0.2, 0.6, 9)
    local nearby = lurek.procgen.perlin2d(0.25, 0.65, 9)
    lurek.log.info(string.format("lurek.procgen.perlin2d=%.4f", value))
    lurek.log.info(string.format("lurek.procgen.perlin2d seeded=%.4f", seeded))
    lurek.log.info(string.format("lurek.procgen.perlin2d nearby=%.4f", nearby))
end

--@api: lurek.procgen.perlin3d
do

    local value = lurek.procgen.perlin3d(0.1, 0.3, 0.7)
    local seeded = lurek.procgen.perlin3d(0.1, 0.3, 0.7, 11)
    local layered = lurek.procgen.perlin3d(0.1, 0.3, 0.9, 11)
    lurek.log.info(string.format("lurek.procgen.perlin3d=%.4f", value))
    lurek.log.info(string.format("lurek.procgen.perlin3d seeded=%.4f", seeded))
    lurek.log.info(string.format("lurek.procgen.perlin3d layered=%.4f", layered))
end

--@api: lurek.procgen.simplexNoise
do

    local value2d = lurek.procgen.simplexNoise(0.4, 0.9)
    local value3d = lurek.procgen.simplexNoise(0.4, 0.9, 1.2)
    local animated = lurek.procgen.simplexNoise(0.4, 0.9, 1.4)
    lurek.log.info(string.format("lurek.procgen.simplexNoise2d=%.4f", value2d))
    lurek.log.info(string.format("lurek.procgen.simplexNoise3d=%.4f", value3d))
    lurek.log.info(string.format("lurek.procgen.simplexNoise animated=%.4f", animated))
end

--@api: lurek.procgen.setConstraintsFromLLM
do

    -- LLM may be offline in CI; result is always a table (empty on error)
    local constraints = lurek.procgen.setConstraintsFromLLM("2 tiles: grass and water. Grass can be next to grass or water. Water can only be next to water.")
    local next_key = next(constraints)
    lurek.log.info("setConstraintsFromLLM type=" .. type(constraints))
    lurek.log.info("setConstraintsFromLLM has_entries=" .. tostring(next_key ~= nil))
    lurek.log.info("setConstraintsFromLLM first_key=" .. tostring(next_key))
end

--@api: lurek.procgen.wfcFromPrompt
do

    -- LLM may be offline in CI; result always has the required shape fields
    local grid = lurek.procgen.wfcFromPrompt(
        "small dungeon with stone floor and walls",
        { width = 4, height = 4, seed = 1, max_attempts = 5 }
    )
    lurek.log.info("wfcFromPrompt width=" .. grid.width .. " height=" .. grid.height)
    lurek.log.info("wfcFromPrompt cells_type=" .. type(grid.cells))
    lurek.log.info("wfcFromPrompt failed_type=" .. type(grid.failed_cells))
end

--@api: lurek.procgen.newCellular
do

    local ca = lurek.procgen.newCellular(32, 32)
    ca:setCell(5, 5, lurek.procgen.CELL_SAND)
    ca:step()
    local cell = ca:getCell(5, 5)
    lurek.log.info("cellular type = " .. ca:type())
    lurek.log.info("cellular sand count = " .. ca:countCells(lurek.procgen.CELL_SAND))
    lurek.log.info("cellular sample cell = " .. tostring(cell))
end

--@api: LCellular:countCells
do

    local ca = lurek.procgen.newCellular(16, 16)
    ca:setCell(0, 0, lurek.procgen.CELL_ROCK)
    ca:setCell(1, 0, lurek.procgen.CELL_ROCK)
    local rocks = ca:countCells(lurek.procgen.CELL_ROCK)
    local sand = ca:countCells(lurek.procgen.CELL_SAND)
    lurek.log.info("rock count = " .. rocks)
    lurek.log.info("sand count = " .. sand)
    lurek.log.info("cellular type = " .. ca:type())
end

--@api: LCellular:fillCircle
do

    local ca = lurek.procgen.newCellular(32, 32)
    ca:fillCircle(16, 16, 5, lurek.procgen.CELL_WATER)
    local water = ca:countCells(lurek.procgen.CELL_WATER)
    local center = ca:getCell(16, 16)
    lurek.log.info("fillCircle water count = " .. water)
    lurek.log.info("fillCircle center cell = " .. tostring(center))
    lurek.log.info("fillCircle image bytes = " .. #ca:toImageDataRegion(8, 8, 16, 16))
end

--@api: LCellular:fillRect
do

    local ca = lurek.procgen.newCellular(32, 32)
    ca:fillRect(0, 0, 8, 8, lurek.procgen.CELL_ROCK)
    local rocks = ca:countCells(lurek.procgen.CELL_ROCK)
    local corner = ca:getCell(0, 0)
    lurek.log.info("fillRect rock count = " .. rocks)
    lurek.log.info("fillRect corner cell = " .. tostring(corner))
    lurek.log.info("fillRect bytes = " .. #ca:toBytes())
end

--@api: LCellular:findCells
do

    local ca = lurek.procgen.newCellular(16, 16)
    ca:setCell(3, 7, lurek.procgen.CELL_WATER)
    local found = ca:findCells(lurek.procgen.CELL_WATER)
    local first = found[1]
    lurek.log.info("found count = " .. #found)
    lurek.log.info("first water cell = " .. tostring(first and first.x or "nil") .. "," .. tostring(first and first.y or "nil"))
    lurek.log.info("water count = " .. ca:countCells(lurek.procgen.CELL_WATER))
end

--@api: LCellular:getCell
do

    local ca = lurek.procgen.newCellular(16, 16)
    ca:setCell(0, 0, lurek.procgen.CELL_FIRE)
    local v = ca:getCell(0, 0)
    local neighbor = ca:getCell(1, 0)
    lurek.log.info("cell = " .. v)
    lurek.log.info("neighbor = " .. neighbor)
    lurek.log.info("fire count = " .. ca:countCells(lurek.procgen.CELL_FIRE))
end

--@api: LCellular:loadFromBytes
do

    local ca = lurek.procgen.newCellular(8, 8)
    local bytes = ca:toBytes()
    local ca2 = lurek.procgen.newCellular(8, 8)
    ca2:loadFromBytes(bytes)
    lurek.log.info("loadFromBytes done")
end

--@api: LCellular:setCell
do

    local ca = lurek.procgen.newCellular(16, 16)
    ca:setCell(3, 3, lurek.procgen.CELL_SAND)
    local cell = ca:getCell(3, 3)
    local sand = ca:countCells(lurek.procgen.CELL_SAND)
    lurek.log.info("setCell value = " .. tostring(cell))
    lurek.log.info("setCell sand count = " .. sand)
    lurek.log.info("cellular type = " .. ca:type())
end

--@api: LCellular:step
do

    local ca = lurek.procgen.newCellular(16, 16)
    ca:setCell(4, 4, lurek.procgen.CELL_SAND)
    ca:step()
    local sample = ca:getCell(4, 4)
    local sand = ca:countCells(lurek.procgen.CELL_SAND)
    lurek.log.info("step sample cell = " .. tostring(sample))
    lurek.log.info("step sand count = " .. sand)
    lurek.log.info("step bytes = " .. #ca:toBytes())
end

--@api: LCellular:stepN
do

    local ca = lurek.procgen.newCellular(16, 16)
    ca:setCell(4, 4, lurek.procgen.CELL_SAND)
    ca:stepN(5)
    local sample = ca:getCell(4, 4)
    local sand = ca:countCells(lurek.procgen.CELL_SAND)
    lurek.log.info("stepN sample cell = " .. tostring(sample))
    lurek.log.info("stepN sand count = " .. sand)
    lurek.log.info("stepN bytes = " .. #ca:toBytes())
end

--@api: LCellular:toBytes
do

    local ca = lurek.procgen.newCellular(8, 8)
    ca:setCell(2, 2, lurek.procgen.CELL_ROCK)
    local bytes = ca:toBytes()
    lurek.log.info("toBytes length = " .. #bytes)
    lurek.log.info("toBytes rock count = " .. ca:countCells(lurek.procgen.CELL_ROCK))
    lurek.log.info("toBytes type = " .. ca:type())
end

--@api: LCellular:toImageData
do

    local ca = lurek.procgen.newCellular(16, 16)
    ca:fillRect(0, 0, 4, 4, lurek.procgen.CELL_WATER)
    local img = ca:toImageData()
    lurek.log.info("toImageData bytes = " .. #img)
    lurek.log.info("toImageData water count = " .. ca:countCells(lurek.procgen.CELL_WATER))
    lurek.log.info("toImageData type = " .. ca:type())
end

--@api: LCellular:toImageDataRegion
do

    local ca = lurek.procgen.newCellular(32, 32)
    ca:fillCircle(16, 16, 6, lurek.procgen.CELL_FIRE)
    local img = ca:toImageDataRegion(0, 0, 16, 16)
    lurek.log.info("toImageDataRegion bytes = " .. #img)
    lurek.log.info("toImageDataRegion fire count = " .. ca:countCells(lurek.procgen.CELL_FIRE))
    lurek.log.info("toImageDataRegion type = " .. ca:type())
end

--@api: LCellular:type
do

    local ca = lurek.procgen.newCellular(8, 8)
    ca:setCell(1, 1, lurek.procgen.CELL_GAS)
    lurek.log.info("type = " .. ca:type())
    lurek.log.info("gas count = " .. ca:countCells(lurek.procgen.CELL_GAS))
    lurek.log.info("sample cell = " .. tostring(ca:getCell(1, 1)))
end

--@api: LCellular:typeOf
do

    local ca = lurek.procgen.newCellular(8, 8)
    ca:setCell(1, 1, lurek.procgen.CELL_GAS)
    lurek.log.info("typeOf LCellular = " .. tostring(ca:typeOf("LCellular")))
    lurek.log.info("typeOf LObject = " .. tostring(ca:typeOf("LObject")))
    lurek.log.info("gas count = " .. ca:countCells(lurek.procgen.CELL_GAS))
end

--- Added coverage examples for newer API owners.

--@api: LNoiseGenerator:generateMapComputeGrid
do
    local gen = lurek.procgen.newNoiseGenerator(4)
    local ok, value = pcall(function()
        local grid = gen:generateMapComputeGrid(3, 2, { scaleX = 4, scaleY = 4, octaves = 1 })
        return grid:getKind()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LNoiseGenerator:generateMapGrid
do
    local gen = lurek.procgen.newNoiseGenerator(4)
    local ok, value = pcall(function()
        local grid = gen:generateMapGrid(3, 2, { scaleX = 4, scaleY = 4, octaves = 1 })
        return grid:getKind()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LProcgenGrid:getCell
do
    local grid = lurek.procgen.newGridResult(2, 2, { 1, 2, 3, 4 }, { kind = "manual_grid" })
    local ok, value = pcall(function()
        return grid:getCell(1, 2)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LProcgenGrid:getHeight
do
    local grid = lurek.procgen.newGridResult(2, 2, { 1, 2, 3, 4 }, { kind = "manual_grid" })
    local ok, value = pcall(function()
        return grid:getHeight()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LProcgenGrid:getKind
do
    local grid = lurek.procgen.newGridResult(2, 2, { 1, 2, 3, 4 }, { kind = "manual_grid" })
    local ok, value = pcall(function()
        return grid:getKind()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LProcgenGrid:getSize
do
    local grid = lurek.procgen.newGridResult(2, 2, { 1, 2, 3, 4 }, { kind = "manual_grid" })
    local ok, value = pcall(function()
        local w, h = grid:getSize()
        return w + h
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LProcgenGrid:getWidth
do
    local grid = lurek.procgen.newGridResult(2, 2, { 1, 2, 3, 4 }, { kind = "manual_grid" })
    local ok, value = pcall(function()
        return grid:getWidth()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LProcgenGrid:toTable
do
    local grid = lurek.procgen.newGridResult(2, 2, { 1, 2, 3, 4 }, { kind = "manual_grid" })
    local ok, value = pcall(function()
        return #grid:toTable().cells
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LProcgenGrid:toTileField
do
    local grid = lurek.procgen.newGridResult(2, 2, { 1, 2, 3, 4 }, { kind = "manual_grid" })
    local ok, value = pcall(function()
        local field = grid:toTileField({ slot = "terrain" })
        return field:getRef(2, 2, 1, "terrain")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LProcgenGrid:type
do
    local grid = lurek.procgen.newGridResult(2, 2, { 1, 2, 3, 4 }, { kind = "manual_grid" })
    local ok, value = pcall(function()
        return grid:type()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LProcgenGrid:typeOf
do
    local grid = lurek.procgen.newGridResult(2, 2, { 1, 2, 3, 4 }, { kind = "manual_grid" })
    local ok, value = pcall(function()
        return grid:typeOf("LProcgenGrid")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LProcgenGrid:writeTileField
do
    local grid = lurek.procgen.newGridResult(2, 2, { 1, 2, 3, 4 }, { kind = "manual_grid" })
    local ok, value = pcall(function()
        local field = lurek.tilefield.new({ width = 2, height = 2 })
        grid:writeTileField(field, { slot = "terrain" })
        return field:getRef(2, 1, 1, "terrain")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LProcgenScalarGrid:getCell
do
    local grid = lurek.procgen.newScalarGridResult(2, 2, { 0.1, 0.6, 0.2, 0.9 }, { kind = "manual_scalar" })
    local ok, value = pcall(function()
        return grid:getCell(1, 2)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LProcgenScalarGrid:getHeight
do
    local grid = lurek.procgen.newScalarGridResult(2, 2, { 0.1, 0.6, 0.2, 0.9 }, { kind = "manual_scalar" })
    local ok, value = pcall(function()
        return grid:getHeight()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LProcgenScalarGrid:getKind
do
    local grid = lurek.procgen.newScalarGridResult(2, 2, { 0.1, 0.6, 0.2, 0.9 }, { kind = "manual_scalar" })
    local ok, value = pcall(function()
        return grid:getKind()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LProcgenScalarGrid:getSize
do
    local grid = lurek.procgen.newScalarGridResult(2, 2, { 0.1, 0.6, 0.2, 0.9 }, { kind = "manual_scalar" })
    local ok, value = pcall(function()
        local w, h = grid:getSize()
        return w + h
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LProcgenScalarGrid:getWidth
do
    local grid = lurek.procgen.newScalarGridResult(2, 2, { 0.1, 0.6, 0.2, 0.9 }, { kind = "manual_scalar" })
    local ok, value = pcall(function()
        return grid:getWidth()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LProcgenScalarGrid:toTable
do
    local grid = lurek.procgen.newScalarGridResult(2, 2, { 0.1, 0.6, 0.2, 0.9 }, { kind = "manual_scalar" })
    local ok, value = pcall(function()
        return #grid:toTable().cells
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LProcgenScalarGrid:toTileField
do
    local grid = lurek.procgen.newScalarGridResult(2, 2, { 0.1, 0.6, 0.2, 0.9 }, { kind = "manual_scalar" })
    local ok, value = pcall(function()
        local field = grid:toTileField({ target = "block", channel = "move", threshold = 0.5 })
        return field:blocks(2, 1, 1, "move")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LProcgenScalarGrid:type
do
    local grid = lurek.procgen.newScalarGridResult(2, 2, { 0.1, 0.6, 0.2, 0.9 }, { kind = "manual_scalar" })
    local ok, value = pcall(function()
        return grid:type()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LProcgenScalarGrid:typeOf
do
    local grid = lurek.procgen.newScalarGridResult(2, 2, { 0.1, 0.6, 0.2, 0.9 }, { kind = "manual_scalar" })
    local ok, value = pcall(function()
        return grid:typeOf("LProcgenScalarGrid")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: LProcgenScalarGrid:writeTileField
do
    local grid = lurek.procgen.newScalarGridResult(2, 2, { 0.1, 0.6, 0.2, 0.9 }, { kind = "manual_scalar" })
    local ok, value = pcall(function()
        local field = lurek.tilefield.new({ width = 2, height = 2 })
        grid:writeTileField(field, { target = "cost", channel = "move", scale = 10 })
        return field:getCost(2, 2, 1, "move")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: lurek.procgen.cellularAutomataGrid
do
    local opts = { width = 4, height = 3, seed = 8, fill_probability = 0.45, steps = 1 }
    local ok, value = pcall(function()
        local grid = lurek.procgen.cellularAutomataGrid(opts)
        return grid:getKind()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: lurek.procgen.heightmapFromCellularGrid
do
    local cells = { 0, 1, 0, 1, 0, 1 }
    local ok, value = pcall(function()
        local grid = lurek.procgen.heightmapFromCellularGrid(3, 2, cells, 0)
        return grid:getHeight()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: lurek.procgen.heightmapGrid
do
    local opts = { width = 4, height = 3, seed = 7, erosion_passes = 0 }
    local ok, value = pcall(function()
        local grid = lurek.procgen.heightmapGrid(opts)
        return grid:getKind()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: lurek.procgen.newGridResult
do
    local cells = { 1, 2, 3, 4 }
    local ok, value = pcall(function()
        local grid = lurek.procgen.newGridResult(2, 2, cells, { kind = "manual_grid" })
        return grid:type()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: lurek.procgen.newScalarGridResult
do
    local cells = { 0.1, 0.6, 0.2, 0.9 }
    local ok, value = pcall(function()
        local grid = lurek.procgen.newScalarGridResult(2, 2, cells, { kind = "manual_scalar" })
        return grid:type()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: lurek.procgen.noiseMapGrid
do
    local opts = { seed = 5, scale_x = 4, scale_y = 4, octaves = 1 }
    local ok, value = pcall(function()
        local grid = lurek.procgen.noiseMapGrid(3, 2, opts)
        return #grid:toTable().cells
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: lurek.procgen.noiseMapParallelGrid
do
    local opts = { scale_x = 4, scale_y = 4, octaves = 1 }
    local ok, value = pcall(function()
        local grid = lurek.procgen.noiseMapParallelGrid(3, 2, opts)
        return grid:getHeight()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: lurek.procgen.noiseMapParallelSeededGrid
do
    local opts = { seed = 9, scale_x = 4, scale_y = 4, octaves = 1 }
    local ok, value = pcall(function()
        local grid = lurek.procgen.noiseMapParallelSeededGrid(3, 2, opts)
        return grid:getWidth()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: lurek.procgen.roomsDungeonGrid
do
    local opts = { width = 8, height = 6, max_rooms = 3, min_room_size = 2, max_room_size = 3, seed = 11 }
    local ok, value = pcall(function()
        local grid = lurek.procgen.roomsDungeonGrid(opts)
        return grid:getWidth()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: lurek.procgen.roomsDungeonWithPrefabsGrid
do
    local opts = { width = 8, height = 6, max_rooms = 3, min_room_size = 2, max_room_size = 3, seed = 11 }
    local ok, value = pcall(function()
        local grid = lurek.procgen.roomsDungeonWithPrefabsGrid(opts, { { name = "chest", width = 1, height = 1 } }, 3)
        return grid:getWidth()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end

--@api: lurek.procgen.wfcGenerateGrid
do
    local tiles = { { id = 1, weight = 1 }, { id = 2, weight = 1 } }
    local ok, value = pcall(function()
        local grid = lurek.procgen.wfcGenerateGrid({ width = 3, height = 2, tiles = tiles, seed = 4 })
        return grid:getWidth()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
