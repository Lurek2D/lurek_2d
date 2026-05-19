--- Procgen Module Part 1: BiomeClassifier, generateNames, noiseMapParallelSeeded, simplex3d

--@api-stub: BiomeClassifier:classify
--@api-stub: BiomeClassifier:classifyMap
--@api-stub: BiomeClassifier:type
--@api-stub: BiomeClassifier:typeOf
-- Biome classification by environmental parameters.
do
    local bc = lurek.procgen.newBiomeClassifier({
        biomes = {
            { name = "ocean",    h_max = 0.3, m_min = 0.0, t_min = 0.0 },
            { name = "desert",   h_min = 0.3, m_max = 0.3, t_min = 0.5 },
            { name = "forest",   h_min = 0.3, m_min = 0.3, t_min = 0.0 },
        }
    })
    local biome = bc:classify(0.5, 0.6, 0.4)
    print("biome=" .. biome)
    print("type=" .. bc:type())
    print("typeOf=" .. tostring(bc:typeOf("BiomeClassifier")))

    local w, h = 4, 4
    local heights = {}
    local moisture = {}
    local temps = {}
    for i = 1, w * h do
        heights[i] = 0.5
        moisture[i] = 0.5
        temps[i] = 0.4
    end
    local map = bc:classifyMap(w, h, heights, moisture, temps)
    print("map_size=" .. #map)
end

--@api-stub: lurek.procgen.generateNames
-- Procedural name generation from samples.
do
    local samples = { "Alon", "Beren", "Caran", "Doran", "Elan" }
    local names = lurek.procgen.generateNames(samples, 5, 3, 8, 42)
    print("names_count=" .. #names)
    for i, n in ipairs(names) do
        print("name_" .. i .. "=" .. n)
    end
end

--@api-stub: lurek.procgen.noiseMapParallelSeeded
-- Parallel seeded noise map generation.
do
    local map = lurek.procgen.noiseMapParallelSeeded(16, 16, {
        scale = 0.1,
        octaves = 4,
        seed = 12345,
    })
    print("map_len=" .. #map)
end

--@api-stub: lurek.procgen.simplex3d
-- 3D simplex noise sample.
do
    local v = lurek.procgen.simplex3d(0.1, 0.5, 0.9)
    print("simplex3d=" .. v)
end

print("procgen_01.lua")
