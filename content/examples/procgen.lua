-- content/examples/procgen.lua
-- love2d-style usage snippets for the lurek.procgen API (29 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/procgen.lua

-- ── lurek.procgen.* functions ──

--@api-stub: lurek.procgen.cellularAutomata
-- Generates a cave-like map using cellular automata.
-- See the module spec for detailed semantics.
local result = lurek.procgen.cellularAutomata(64, 64, { x = 0, y = 0 })
print("cellularAutomata:", result)
return result

--@api-stub: lurek.procgen.floodFill
-- BFS flood fill on a flat grid of bytes.
-- See the module spec for detailed semantics.
local result = lurek.procgen.floodFill()
print("floodFill:", result)
return result

--@api-stub: lurek.procgen.perlinNoise
-- Evaluates periodic Perlin noise at a point.
-- See the module spec for detailed semantics.
local result = lurek.procgen.perlinNoise(100, 100, px, py)
print("perlinNoise:", result)
return result

--@api-stub: lurek.procgen.poissonDisk
-- Generates Poisson disk sample points using Bridson's algorithm.
-- See the module spec for detailed semantics.
local result = lurek.procgen.poissonDisk(64, 64, min_dist, max_attempts, seed)
print("poissonDisk:", result)
return result

--@api-stub: lurek.procgen.voronoi
-- Generates a Voronoi diagram for a set of seed points.
-- See the module spec for detailed semantics.
local result = lurek.procgen.voronoi(64, 64, pts_tbl, { x = 0, y = 0 })
print("voronoi:", result)
return result

--@api-stub: lurek.procgen.bspDungeon
-- Generates a dungeon using Binary Space Partitioning.
-- See the module spec for detailed semantics.
local result = lurek.procgen.bspDungeon({ x = 0, y = 0 })
print("bspDungeon:", result)
return result

--@api-stub: lurek.procgen.roomsDungeon
-- Generates a rooms-and-corridors dungeon.
-- See the module spec for detailed semantics.
local result = lurek.procgen.roomsDungeon({ x = 0, y = 0 })
print("roomsDungeon:", result)
return result

--@api-stub: lurek.procgen.heightmap
-- Generates a heightmap using fractal noise.
-- See the module spec for detailed semantics.
local result = lurek.procgen.heightmap({ x = 0, y = 0 })
print("heightmap:", result)
return result

--@api-stub: lurek.procgen.wfcGenerate
-- Generates a tile grid using Wave Function Collapse.
-- See the module spec for detailed semantics.
local result = lurek.procgen.wfcGenerate({ x = 0, y = 0 })
print("wfcGenerate:", result)
return result

--@api-stub: lurek.procgen.lsystem
-- Generates an L-system string.
-- See the module spec for detailed semantics.
local result = lurek.procgen.lsystem({ x = 0, y = 0 })
print("lsystem:", result)
return result

--@api-stub: lurek.procgen.lsystemSegments
-- Generates L-system line segments for rendering.
-- See the module spec for detailed semantics.
local result = lurek.procgen.lsystemSegments({ x = 0, y = 0 }, angle_deg, step)
print("lsystemSegments:", result)
return result

--@api-stub: lurek.procgen.generateName
-- Generates a single procedural name using a Markov chain.
-- See the module spec for detailed semantics.
local result = lurek.procgen.generateName()
print("generateName:", result)
return result

--@api-stub: lurek.procgen.generateNames
-- Generates N procedural names using a Markov chain.
-- See the module spec for detailed semantics.
local result = lurek.procgen.generateNames()
print("generateNames:", result)
return result

--@api-stub: lurek.procgen.worldGraph
-- Generates a world graph with scattered regions and edges.
-- See the module spec for detailed semantics.
local result = lurek.procgen.worldGraph(64, 64, 10, seed)
print("worldGraph:", result)
return result

--@api-stub: lurek.procgen.noiseMap
-- Generates a noise map using the configurable NoiseGenerator.
-- See the module spec for detailed semantics.
local result = lurek.procgen.noiseMap(64, 64, { x = 0, y = 0 })
print("noiseMap:", result)
return result

--@api-stub: lurek.procgen.noiseMapParallel
-- Generates a noise map using rayon parallel processing.
-- See the module spec for detailed semantics.
local result = lurek.procgen.noiseMapParallel(64, 64, { x = 0, y = 0 })
print("noiseMapParallel:", result)
return result

--@api-stub: lurek.procgen.bspDungeon
-- Generates a dungeon using Binary Space Partitioning.
-- See the module spec for detailed semantics.
local result = lurek.procgen.bspDungeon({ x = 0, y = 0 })
print("bspDungeon:", result)
return result

--@api-stub: lurek.procgen.roomsDungeon
-- Generates a rooms-and-corridors dungeon.
-- See the module spec for detailed semantics.
local result = lurek.procgen.roomsDungeon({ x = 0, y = 0 })
print("roomsDungeon:", result)
return result

--@api-stub: lurek.procgen.heightmap
-- Generates a heightmap using fractal noise.
-- See the module spec for detailed semantics.
local result = lurek.procgen.heightmap({ x = 0, y = 0 })
print("heightmap:", result)
return result

--@api-stub: lurek.procgen.wfcGenerate
-- Generates a tile grid using Wave Function Collapse.
-- See the module spec for detailed semantics.
local result = lurek.procgen.wfcGenerate({ x = 0, y = 0 })
print("wfcGenerate:", result)
return result

--@api-stub: lurek.procgen.lsystem
-- Generates an L-system string.
-- See the module spec for detailed semantics.
local result = lurek.procgen.lsystem({ x = 0, y = 0 })
print("lsystem:", result)
return result

--@api-stub: lurek.procgen.lsystemSegments
-- Generates L-system line segments for rendering.
-- See the module spec for detailed semantics.
local result = lurek.procgen.lsystemSegments({ x = 0, y = 0 }, angle_deg, step)
print("lsystemSegments:", result)
return result

--@api-stub: lurek.procgen.generateName
-- Generates a single procedural name using a Markov chain.
-- See the module spec for detailed semantics.
local result = lurek.procgen.generateName()
print("generateName:", result)
return result

--@api-stub: lurek.procgen.generateNames
-- Generates N procedural names using a Markov chain.
-- See the module spec for detailed semantics.
local result = lurek.procgen.generateNames()
print("generateNames:", result)
return result

--@api-stub: lurek.procgen.worldGraph
-- Generates a world graph with scattered regions and edges.
-- See the module spec for detailed semantics.
local result = lurek.procgen.worldGraph(64, 64, 10, seed)
print("worldGraph:", result)
return result

--@api-stub: lurek.procgen.noiseMap
-- Generates a noise map using the configurable NoiseGenerator.
-- See the module spec for detailed semantics.
local result = lurek.procgen.noiseMap(64, 64, { x = 0, y = 0 })
print("noiseMap:", result)
return result

--@api-stub: lurek.procgen.noiseMapParallel
-- Generates a noise map using rayon parallel processing.
-- See the module spec for detailed semantics.
local result = lurek.procgen.noiseMapParallel(64, 64, { x = 0, y = 0 })
print("noiseMapParallel:", result)
return result

--@api-stub: lurek.procgen.simplex2d
-- Returns a single Simplex noise value at the given 2-D coordinate.
-- See the module spec for detailed semantics.
local result = lurek.procgen.simplex2d(100, 100)
print("simplex2d:", result)
return result

--@api-stub: lurek.procgen.simplex3d
-- Returns a single Simplex noise value at the given 3-D coordinate.
-- See the module spec for detailed semantics.
local result = lurek.procgen.simplex3d(100, 100, 0)
print("simplex3d:", result)
return result

