# Procgen

- The `procgen` module is a versatile Feature Systems tier library dedicated to procedural content generation in Lurek2D.

It offers a rich suite of deterministic, headless-testable algorithms for creating diverse game worlds, terrains, and structures. Central to the module is a robust `NoiseGenerator` built on an internal seeded Linear Congruential Generator (LCG). It supports 2D/3D/4D Perlin and Simplex noise, as well as 2D/3D Worley (cellular) noise with various distance metrics. These base noises can be combined using fractal combinators like Fractal Brownian Motion (FBM), ridged multifractal, and turbulence, and deformed via domain warping. For map generation, `procgen` provides sequential and parallel (`rayon`-powered) heightmap generation with options for hydraulic erosion, which can then be classified into dynamic biomes (e.g., ocean, desert, forest) via the `BiomeClassifier`.

The module also excels at dungeon and interior generation. The `BspDungeon` generator uses Binary Space Partitioning to recursively divide space and carve rooms connected by L-shaped corridors. Alternatively, the `rooms_dungeon` generator places random non-overlapping rooms. Both systems support a prefab stamping feature that cleanly pastes named template shapes into qualifying rooms in a round-robin fashion. For organic caves, the `cellular_automata` generator applies birth/survival rules to a grid to form natural-looking caverns.

For advanced world-building, `procgen` includes a `world_graph` subsystem for generating overworld node topologies, complete with A* pathfinding and Kruskal's minimum spanning tree algorithms. It also features a Wave Function Collapse (`wfc`) solver for constraint-based tile placement, Voronoi tessellation for regional partitioning, and Poisson-disk sampling for natural, evenly-spaced object distribution. L-systems provide string-rewriting and turtle-graphics interpretation for generating fractal trees or road networks. Finally, a Markov-chain `NameGen` creates plausible, random names trained on input word corpora. All these algorithms are thoroughly exposed to Lua via the `lurek.procgen.*` API, enabling script developers to construct infinitely varied, reproducible game content on the fly.

## Functions

### `lurek.procgen.biomeColor`

Get the default RGBA display color for a biome type name. Useful for minimap or debug visualization.

```lua
-- signature
lurek.procgen.biomeColor(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Biome name (e.g. "ocean", "desert", "taiga"). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Red component (0–255). |
| `number` | b Green component (0–255). |
| `number` | c Blue component (0–255). |
| `number` | d Alpha component (0–255). |

**Example**

```lua
do
    local r, g, b, a = lurek.procgen.biomeColor("ocean")

    print("biomeColor ocean=" .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

### `lurek.procgen.bspDungeon`

Generate a dungeon layout using Binary Space Partitioning. Produces non-overlapping rooms connected by corridors.

```lua
-- signature
lurek.procgen.bspDungeon(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | `table` | Options: width, height, min_size (minimum leaf size), max_depth (BSP tree depth), seed, padding. |

**Returns**

| Type | Description |
|------|-------------|
| `ProcgenBspDungeonResult` | Table with .rooms (array of {x,y,w,h}) and .corridors (array of {x1,y1,x2,y2}). |

**Example**

```lua
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
```

---

### `lurek.procgen.bspDungeonWithPrefabs`

Generate a BSP dungeon and stamp named prefab rooms into suitable leaves. Returns dungeon layout plus prefab placement info.

```lua
-- signature
lurek.procgen.bspDungeonWithPrefabs(opts, prefabs)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | `table` | BSP options: width, height, min_size, max_depth, seed, padding. |
| `prefabs` | `table` | Array of prefab definitions: {name, width, height}. |

**Returns**

| Type | Description |
|------|-------------|
| `ProcgenBspDungeonWithPrefabsResult` | a Dungeon table with .rooms and .corridors. |
| `ProcgenBspDungeonWithPrefabsResult` | b Array of placed prefabs: {name, x, y, width, height}. |

**Example**

```lua
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
```

---

### `lurek.procgen.cellularAutomata`

Generate a cave or organic map using cellular automata rules.

```lua
-- signature
lurek.procgen.cellularAutomata(width, height, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | `number` | Grid width in cells. |
| `height` | `number` | Grid height in cells. |
| `opts?` | `table` | Options: fill (0.0–1.0 initial fill ratio), iterations, birth threshold, survive threshold, seed. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Flat array of cell values (0=empty, 1=wall) with length width×height. |

**Example**

```lua
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
```

---

### `lurek.procgen.fbm`

Samples stateless fractal Brownian motion noise.

```lua
-- signature
lurek.procgen.fbm(x, y, seed, octaves, lac, gain)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X coordinate. |
| `y` | `number` | Y coordinate. |
| `seed?` | `number` | Seed value (default 0). |
| `octaves?` | `number` | Octave count (default 4). |
| `lac?` | `number` | Lacunarity (default 2.0). |
| `gain?` | `number` | Gain (default 0.5). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Noise value. |

**Example**

```lua
do
    local value = lurek.procgen.fbm(0.5, 0.5, 7, 4, 2.0, 0.5)
    local other = lurek.procgen.fbm(0.75, 0.25, 7, 4, 2.0, 0.5)

    print(string.format("lurek.procgen.fbm=%.4f", value))
    print(string.format("lurek.procgen.fbm other=%.4f", other))
end
```

---

### `lurek.procgen.floodFill`

Flood-fill a grid from a starting cell, marking all connected cells that pass a threshold test.

```lua
-- signature
lurek.procgen.floodFill(data, width, height, startX, startY, threshold, above)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | `table` | Flat array of u8 cell values (length = width*height). |
| `width` | `number` | Grid width. |
| `height` | `number` | Grid height. |
| `startX` | `number` | Start column (0-based). |
| `startY` | `number` | Start row (0-based). |
| `threshold?` | `number` | Value threshold (default 128). |
| `above?` | `boolean` | If true, fill cells >= threshold; if false (default), fill cells < threshold. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Flat array of fill values (1=filled, 0=not filled) with length width×height. |

**Example**

```lua
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
```

---

### `lurek.procgen.generateName`

Generate a single random name based on a Markov chain trained from sample names. Great for NPC names, place names, or item names.

```lua
-- signature
lurek.procgen.generateName(samples, minLen, maxLen, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `samples` | `table` | Array of example name strings to learn from. |
| `minLen?` | `number` | Minimum output length in characters (default 3). |
| `maxLen?` | `number` | Maximum output length in characters (default 10). |
| `seed?` | `number` | RNG seed (default 0). |

**Returns**

| Type | Description |
|------|-------------|
| `string` | A generated name. |

**Example**

```lua
do
    local samples = { "Aldric", "Baldric", "Cedric", "Eldric", "Godric", "Fredric" }
    local name = lurek.procgen.generateName(samples, 4, 8, 1)

    print("generateName result=" .. name)
end
```

---

### `lurek.procgen.generateNames`

Generate multiple random names in one call using Markov chains trained from sample data.

```lua
-- signature
lurek.procgen.generateNames(samples, count, minLen, maxLen, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `samples` | `table` | Array of example name strings to learn from. |
| `count` | `number` | Number of names to generate. |
| `minLen?` | `number` | Minimum output length (default 3). |
| `maxLen?` | `number` | Maximum output length (default 10). |
| `seed?` | `number` | RNG seed (default 0). |

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Generated name strings. |

**Example**

```lua
do
    local samples = { "Alon", "Beren", "Caran", "Doran", "Elan" }
    local names = lurek.procgen.generateNames(samples, 5, 3, 8, 42)

    print("generateNames count=" .. #names)
    print("generateNames first=" .. names[1])
end
```

---

### `lurek.procgen.heightmap`

Generate a fractal heightmap using multi-octave noise with optional hydraulic erosion.

```lua
-- signature
lurek.procgen.heightmap(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | `table` | Options: width, height, scale, octaves, lacunarity, persistence, seed, erosion_passes. |

**Returns**

| Type | Description |
|------|-------------|
| `ProcgenHeightmapResult` | Table with .cells (flat f32 array 0.0–1.0), .width, .height. |

**Example**

```lua
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
```

---

### `lurek.procgen.heightmapFromCellular`

Convert a cellular automata grid into a heightmap by distance-transforming the floor cells.

```lua
-- signature
lurek.procgen.heightmapFromCellular(width, height, cells, floorValue)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | `number` | Grid width. |
| `height` | `number` | Grid height. |
| `cells` | `table` | Flat u8 array from cellularAutomata. |
| `floorValue?` | `number` | Cell value treated as open floor (default 0). |

**Returns**

| Type | Description |
|------|-------------|
| `ProcgenHeightmapFromCellularResult` | Table with .cells (flat f32 array), .width, .height. |

**Example**

```lua
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
```

---

### `lurek.procgen.lsystem`

Expand an L-system grammar and return the resulting string. Useful for generating branching structures like trees, rivers, or cave networks.

```lua
-- signature
lurek.procgen.lsystem(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | `table` | Options: axiom (starting string), iterations (expansion count), rules (table mapping single-char keys to replacement strings). |

**Returns**

| Type | Description |
|------|-------------|
| `string` | The fully expanded L-system string. |

**Example**

```lua
do
    local result = lurek.procgen.lsystem({
        axiom = "F",
        iterations = 3,
        rules = { F = "F[+F]F[-F]F" },
    })

    print("lsystem length=" .. #result)
    print("lsystem preview=" .. result:sub(1, 40))
end
```

---

### `lurek.procgen.lsystemSegments`

Expand an L-system and interpret the result as turtle-graphics commands, returning line segments.

```lua
-- signature
lurek.procgen.lsystemSegments(opts, angle, step)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | `table` | L-system options: axiom, iterations, rules. |
| `angle?` | `number` | Turn angle in degrees (default 25). |
| `step?` | `number` | Forward step length (default 1.0). |

**Returns**

| Type | Description |
|------|-------------|
| `ProcgenLsystemSegmentsResult` | Array of segment tables {x1, y1, x2, y2}. |

**Example**

```lua
do
    local segments = lurek.procgen.lsystemSegments({
        axiom = "F",
        iterations = 4,
        rules = { F = "FF+[+F-F-F]-[-F+F+F]" },
    }, 25, 5.0)

    print("lsystemSegments count=" .. #segments)
    print("lsystemSegments firstExists=" .. tostring(segments[1] ~= nil))
end
```

---

### `lurek.procgen.newBiomeClassifier`

Create a BiomeClassifier object with custom threshold rules for mapping height/moisture/temperature to biome types.

```lua
-- signature
lurek.procgen.newBiomeClassifier(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | `table` | Optional rules: ocean_threshold, coast_threshold, mountain_threshold, ice_cap_threshold, cold_temperature, warm_temperature, dry_moisture, wet_moisture. |

**Returns**

| Type | Description |
|------|-------------|
| `LBiomeClassifier` | A classifier object with :classify() and :classifyMap() methods. |

**Example**

```lua
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
```

---

### `lurek.procgen.newCellular`

Performs the 'procgen' operation.

```lua
-- signature
lurek.procgen.newCellular(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | `number` | Grid width in cells. |
| `height` | `number` | Grid height in cells. |

**Returns**

| Type | Description |
|------|-------------|
| `LCellular` | The cellular simulation object. |

---

### `lurek.procgen.newNoiseGenerator`

Creates a procedural noise generator with an optional seed.

```lua
-- signature
lurek.procgen.newNoiseGenerator(seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seed?` | `number` | Seed value (default 0). |

**Returns**

| Type | Description |
|------|-------------|
| `LNoiseGenerator` | New noise generator handle. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(777)

    print("lurek.procgen.newNoiseGenerator type=" .. generator:type())
    print("lurek.procgen.newNoiseGenerator seed=" .. generator:getSeed())
end
```

---

### `lurek.procgen.noiseMap`

Generate a 2D noise map with configurable scale, octaves, and offsets. Runs on a single thread.

```lua
-- signature
lurek.procgen.noiseMap(width, height, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | `number` | Map width in cells. |
| `height` | `number` | Map height in cells. |
| `opts?` | `table` | Options: scale_x, scale_y, octaves, lacunarity, persistence, offset_x, offset_y, seed. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | F64 noise values (length = width*height). |

**Example**

```lua
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
```

---

### `lurek.procgen.noiseMapParallel`

Generate a 2D noise map using multiple threads for faster computation on large maps. Uses seed 0.

```lua
-- signature
lurek.procgen.noiseMapParallel(width, height, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | `number` | Map width in cells. |
| `height` | `number` | Map height in cells. |
| `opts?` | `table` | Options: scale_x, scale_y, octaves, lacunarity, persistence, offset_x, offset_y. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | F64 noise values (length = width*height). |

**Example**

```lua
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
```

---

### `lurek.procgen.noiseMapParallelSeeded`

Generate a 2D noise map using multiple threads with a specific seed for reproducible results.

```lua
-- signature
lurek.procgen.noiseMapParallelSeeded(width, height, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | `number` | Map width in cells. |
| `height` | `number` | Map height in cells. |
| `opts?` | `table` | Options: scale_x, scale_y, octaves, lacunarity, persistence, offset_x, offset_y, seed. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | F64 noise values (length = width*height). |

**Example**

```lua
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
```

---

### `lurek.procgen.perlin2d`

Samples stateless 2D Perlin noise.

```lua
-- signature
lurek.procgen.perlin2d(x, y, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X coordinate. |
| `y` | `number` | Y coordinate. |
| `seed?` | `number` | Seed value (default 0). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Noise value. |

**Example**

```lua
do
    local value = lurek.procgen.perlin2d(0.2, 0.6)
    local seeded = lurek.procgen.perlin2d(0.2, 0.6, 9)

    print(string.format("lurek.procgen.perlin2d=%.4f", value))
    print(string.format("lurek.procgen.perlin2d seeded=%.4f", seeded))
end
```

---

### `lurek.procgen.perlin3d`

Samples stateless 3D Perlin noise.

```lua
-- signature
lurek.procgen.perlin3d(x, y, z, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X coordinate. |
| `y` | `number` | Y coordinate. |
| `z` | `number` | Z coordinate. |
| `seed?` | `number` | Seed value (default 0). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Noise value. |

**Example**

```lua
do
    local value = lurek.procgen.perlin3d(0.1, 0.3, 0.7)
    local seeded = lurek.procgen.perlin3d(0.1, 0.3, 0.7, 11)

    print(string.format("lurek.procgen.perlin3d=%.4f", value))
    print(string.format("lurek.procgen.perlin3d seeded=%.4f", seeded))
end
```

---

### `lurek.procgen.perlin4d`

Samples stateless 4D Perlin noise.

```lua
-- signature
lurek.procgen.perlin4d(x, y, z, w, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X coordinate. |
| `y` | `number` | Y coordinate. |
| `z` | `number` | Z coordinate. |
| `w` | `number` | W coordinate. |
| `seed?` | `number` | Seed value (default 0). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Noise value. |

**Example**

```lua
do
    local value = lurek.procgen.perlin4d(0.1, 0.2, 0.3, 0.4)
    local seeded = lurek.procgen.perlin4d(0.1, 0.2, 0.3, 0.4, 17)

    print(string.format("perlin4d=%.4f", value))
    print(string.format("perlin4d seeded=%.4f", seeded))
end
```

---

### `lurek.procgen.perlinNoise`

Sample periodic 2D Perlin noise at a given coordinate.

```lua
-- signature
lurek.procgen.perlinNoise(x, y, periodX, periodY)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X coordinate to sample. |
| `y` | `number` | Y coordinate to sample. |
| `periodX` | `number` | Horizontal period for tiling. |
| `periodY` | `number` | Vertical period for tiling. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Noise value in the range [-1, 1]. |

**Example**

```lua
do
    local first = lurek.procgen.perlinNoise(0.5, 0.5, 4.0, 4.0)
    local tiled = lurek.procgen.perlinNoise(4.5, 0.5, 4.0, 4.0)

    print(string.format("perlinNoise first=%.4f", first))
    print(string.format("perlinNoise tiled=%.4f", tiled))
end
```

---

### `lurek.procgen.poissonDisk`

Generate evenly-spaced random points using Poisson disk sampling. Useful for placing trees, NPCs, or loot without clustering.

```lua
-- signature
lurek.procgen.poissonDisk(width, height, minDist, maxAttempts, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | `number` | Area width. |
| `height` | `number` | Area height. |
| `minDist` | `number` | Minimum distance between any two points. |
| `maxAttempts?` | `number` | Rejection attempts per active point (default 30). Higher = denser fill. |
| `seed?` | `number` | RNG seed (default 0). |

**Returns**

| Type | Description |
|------|-------------|
| `ProcgenPoissonDiskResult` | Array of {x, y} tables representing generated points. |

**Example**

```lua
do
    local points = lurek.procgen.poissonDisk(200, 200, 15, 30, 42)
    local first = points[1]

    print("poissonDisk points=" .. #points)
    print(string.format("poissonDisk first=(%.2f, %.2f)", first.x, first.y))
end
```

---

### `lurek.procgen.roomsDungeon`

Generate a dungeon by placing random non-overlapping rooms and connecting them with corridors. Also returns a full tile grid.

```lua
-- signature
lurek.procgen.roomsDungeon(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | `table` | Options: width, height, max_rooms, min_room_size, max_room_size, seed. |

**Returns**

| Type | Description |
|------|-------------|
| `ProcgenRoomsDungeonResult` | Table with .rooms ({x,y,w,h}[]), .corridors ({x1,y1,x2,y2}[]), .grid (flat u8[]), .width, .height. |

**Example**

```lua
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
```

---

### `lurek.procgen.roomsDungeonWithPrefabs`

Generate a rooms-based dungeon and place named prefabs into qualifying rooms. Prefabs can have custom shape masks.

```lua
-- signature
lurek.procgen.roomsDungeonWithPrefabs(opts, prefabs, stampValue)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | `table` | Room generation options: width, height, max_rooms, min_room_size, max_room_size, seed. |
| `prefabs` | `table` | Array of prefab definitions: {name, width, height, mask (optional flat u8[])}. |
| `stampValue?` | `number` | Tile value written for prefab cells in the grid (default 3). |

**Returns**

| Type | Description |
|------|-------------|
| `ProcgenRoomsDungeonWithPrefabsResult` | a Dungeon table with .rooms, .corridors, .grid, .width, .height. |
| `ProcgenRoomsDungeonWithPrefabsResult` | b Array of placed prefabs: {name, x, y, width, height}. |

**Example**

```lua
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
```

---

### `lurek.procgen.simplex2d`

Sample 2D simplex noise at a point. Returns a value roughly in [-1, 1].

```lua
-- signature
lurek.procgen.simplex2d(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X coordinate. |
| `y` | `number` | Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Simplex noise value. |

**Example**

```lua
do
    local value = lurek.procgen.simplex2d(1.5, 2.3)
    local mirrored = lurek.procgen.simplex2d(2.3, 1.5)

    print(string.format("simplex2d=%.4f", value))
    print(string.format("simplex2d mirrored=%.4f", mirrored))
end
```

---

### `lurek.procgen.simplex3d`

Sample 3D simplex noise at a point. The third axis can be used for animation or layering.

```lua
-- signature
lurek.procgen.simplex3d(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X coordinate. |
| `y` | `number` | Y coordinate. |
| `z` | `number` | Z coordinate (often time or layer index). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Simplex noise value. |

**Example**

```lua
do
    local value = lurek.procgen.simplex3d(0.1, 0.5, 0.9)
    local shifted = lurek.procgen.simplex3d(0.1, 0.5, 1.1)

    print(string.format("simplex3d=%.4f", value))
    print(string.format("simplex3d shifted=%.4f", shifted))
end
```

---

### `lurek.procgen.simplexNoise`

Sample a 2D or 3D simplex noise value at a given point.

```lua
-- signature
lurek.procgen.simplexNoise(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X coordinate. |
| `y` | `number` | Y coordinate. |
| `z?` | `number` | Z coordinate for 3D noise. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Noise value. |

**Example**

```lua
do
    local value2d = lurek.procgen.simplexNoise(0.4, 0.9)
    local value3d = lurek.procgen.simplexNoise(0.4, 0.9, 1.2)

    print(string.format("lurek.procgen.simplexNoise2d=%.4f", value2d))
    print(string.format("lurek.procgen.simplexNoise3d=%.4f", value3d))
end
```

---

### `lurek.procgen.voronoi`

Compute a Voronoi diagram from a set of seed points. Returns region ownership, distance-to-nearest, and distance-to-second-nearest for each cell.

```lua
-- signature
lurek.procgen.voronoi(width, height, points, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | `number` | Grid width. |
| `height` | `number` | Grid height. |
| `points` | `table` | Array of {x, y} seed points. |
| `opts?` | `table` | Options: warp_scale, warp_strength, seed for domain warping. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | a 1-based region indices (length = width*height). |
| `number[]` | b Flat array of distances to nearest seed. |
| `number[]` | c Flat array of distances to second-nearest seed. |

**Example**

```lua
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
```

---

### `lurek.procgen.wfcGenerate`

Run Wave Function Collapse to generate a grid of tile IDs satisfying adjacency constraints.

```lua
-- signature
lurek.procgen.wfcGenerate(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | `table` | Options: width, height, seed, max_attempts, tiles (array of {id, weight}), adjacencies (map of tile_id -> allowed neighbor IDs[]). |

**Returns**

| Type | Description |
|------|-------------|
| `ProcgenWfcGenerateResult` | Table with .cells (flat array of tile IDs, 0 if unsolved), .width, .height. |

**Example**

```lua
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
```

---

### `lurek.procgen.worldGraph`

Generate a connected world graph with named regions and weighted edges. Useful for overworld maps, trade routes, or quest connectivity.

```lua
-- signature
lurek.procgen.worldGraph(width, height, regionCount, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | `number` | World area width. |
| `height` | `number` | World area height. |
| `regionCount` | `number` | Number of regions to place. |
| `seed?` | `number` | RNG seed (default 0). |

**Returns**

| Type | Description |
|------|-------------|
| `ProcgenWorldGraphResult` | Table with regions and edges arrays. |

**Example**

```lua
do
    local world = lurek.procgen.worldGraph(500, 500, 12, 42)

    print("worldGraph regions=" .. #world.regions)
    print("worldGraph edges=" .. #world.edges)
end
```

---

## LBiomeClassifier

### `LBiomeClassifier:classify`

Classify a single point into a biome type based on its environmental parameters.

```lua
-- signature
LBiomeClassifier:classify(height, moisture, temperature)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `height` | `number` | Elevation value (0.0–1.0) of the terrain point. |
| `moisture` | `number` | Moisture level (0.0–1.0) at the point. |
| `temperature` | `number` | Temperature value (0.0–1.0) at the point. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Biome name such as "ocean", "desert", "grassland", "taiga", etc. |

**Example**

```lua
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
```

---

### `LBiomeClassifier:classifyMap`

Classify an entire grid of points into biome types in bulk.

```lua
-- signature
LBiomeClassifier:classifyMap(width, height, heights, moisture, temperature)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | `number` | Grid width in cells. |
| `height` | `number` | Grid height in cells. |
| `heights` | `table` | Flat array of height values (length = width*height). |
| `moisture` | `table` | Flat array of moisture values (length = width*height). |
| `temperature?` | `table` | Optional flat array of temperature values. If omitted, temperature is ignored. |

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Biome name strings (length = width*height). |

**Example**

```lua
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
```

---

### `LBiomeClassifier:type`

Returns the type name of this object.

```lua
-- signature
LBiomeClassifier:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always returns "LBiomeClassifier". |

**Example**

```lua
do
    local classifier = lurek.procgen.newBiomeClassifier()
    local type_name = classifier:type()

    print("LBiomeClassifier:type=" .. type_name)
end
```

---

### `LBiomeClassifier:typeOf`

Check whether this object matches a given type name.

```lua
-- signature
LBiomeClassifier:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to test (e.g. "LBiomeClassifier" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the object is of the specified type. |

**Example**

```lua
do
    local classifier = lurek.procgen.newBiomeClassifier()
    local matches = classifier:typeOf("LBiomeClassifier")

    print("LBiomeClassifier:typeOf=" .. tostring(matches))
end
```

---

## LNoiseGenerator

### `LNoiseGenerator:fbm`

Samples fractal Brownian motion noise.

```lua
-- signature
LNoiseGenerator:fbm(x, y, octaves, lac, pers, kind)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X coordinate. |
| `y` | `number` | Y coordinate. |
| `octaves?` | `number` | Octave count (default 4). |
| `lac?` | `number` | Lacunarity (default 2.0). |
| `pers?` | `number` | Persistence (default 0.5). |
| `kind?` | `string` | Noise kind name (default `"perlin"`). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Noise value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:fbm(0.5, 0.5, 4, 2.0, 0.5)

    print(string.format("LNoiseGenerator:fbm=%.4f", value))
end
```

---

### `LNoiseGenerator:generateMap`

Generates a noise map and returns it as a flat array table.

```lua
-- signature
LNoiseGenerator:generateMap(w, h, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Map width. |
| `h` | `number` | Map height. |
| `opts?` | `table` | Generation options including scale, octaves, kind, fractal, offset, and backend. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Noise values. |

**Example**

```lua
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
```

---

### `LNoiseGenerator:generateMapCompute`

Generates a noise map through the compute backend and returns it as a flat array table.

```lua
-- signature
LNoiseGenerator:generateMapCompute(w, h, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | `number` | Map width. |
| `h` | `number` | Map height. |
| `opts?` | `table` | Generation options including scale, octaves, kind, fractal, and offset. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Noise values. |

**Example**

```lua
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
```

---

### `LNoiseGenerator:getSeed`

Returns this noise generator seed.

```lua
-- signature
LNoiseGenerator:getSeed()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Seed value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(12345)
    local seed = generator:getSeed()

    print("LNoiseGenerator:getSeed=" .. seed)
end
```

---

### `LNoiseGenerator:perlin1d`

Samples 1D Perlin noise. This method is available to Lua scripts.

```lua
-- signature
LNoiseGenerator:perlin1d(x)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Noise value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:perlin1d(0.5)

    print(string.format("LNoiseGenerator:perlin1d=%.4f", value))
end
```

---

### `LNoiseGenerator:perlin2d`

Samples 2D Perlin noise. This method is available to Lua scripts.

```lua
-- signature
LNoiseGenerator:perlin2d(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X coordinate. |
| `y` | `number` | Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Noise value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:perlin2d(0.3, 0.7)

    print(string.format("LNoiseGenerator:perlin2d=%.4f", value))
end
```

---

### `LNoiseGenerator:perlin3d`

Samples 3D Perlin noise. This method is available to Lua scripts.

```lua
-- signature
LNoiseGenerator:perlin3d(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X coordinate. |
| `y` | `number` | Y coordinate. |
| `z` | `number` | Z coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Noise value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:perlin3d(0.2, 0.4, 0.8)

    print(string.format("LNoiseGenerator:perlin3d=%.4f", value))
end
```

---

### `LNoiseGenerator:perlin4d`

Samples 4D Perlin noise. This method is available to Lua scripts.

```lua
-- signature
LNoiseGenerator:perlin4d(x, y, z, w)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X coordinate. |
| `y` | `number` | Y coordinate. |
| `z` | `number` | Z coordinate. |
| `w` | `number` | W coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Noise value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:perlin4d(0.1, 0.2, 0.3, 0.6)

    print(string.format("LNoiseGenerator:perlin4d=%.4f", value))
end
```

---

### `LNoiseGenerator:ridged`

Samples ridged fractal noise. This method is available to Lua scripts.

```lua
-- signature
LNoiseGenerator:ridged(x, y, octaves, lac, pers, kind)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X coordinate. |
| `y` | `number` | Y coordinate. |
| `octaves?` | `number` | Octave count (default 4). |
| `lac?` | `number` | Lacunarity (default 2.0). |
| `pers?` | `number` | Persistence (default 0.5). |
| `kind?` | `string` | Noise kind name (default `"perlin"`). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Noise value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:ridged(0.4, 0.6)

    print(string.format("LNoiseGenerator:ridged=%.4f", value))
end
```

---

### `LNoiseGenerator:setSeed`

Sets this noise generator seed. This method is available to Lua scripts.

```lua
-- signature
LNoiseGenerator:setSeed(seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seed` | `number` | Seed value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(1)

    generator:setSeed(99999)

    print("LNoiseGenerator:setSeed=" .. generator:getSeed())
end
```

---

### `LNoiseGenerator:simplex1d`

Samples 1D simplex noise. This method is available to Lua scripts.

```lua
-- signature
LNoiseGenerator:simplex1d(x)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Noise value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:simplex1d(0.5)

    print(string.format("LNoiseGenerator:simplex1d=%.4f", value))
end
```

---

### `LNoiseGenerator:simplex2d`

Samples 2D simplex noise. This method is available to Lua scripts.

```lua
-- signature
LNoiseGenerator:simplex2d(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X coordinate. |
| `y` | `number` | Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Noise value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:simplex2d(0.3, 0.8)

    print(string.format("LNoiseGenerator:simplex2d=%.4f", value))
end
```

---

### `LNoiseGenerator:simplex3d`

Samples 3D simplex noise. This method is available to Lua scripts.

```lua
-- signature
LNoiseGenerator:simplex3d(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X coordinate. |
| `y` | `number` | Y coordinate. |
| `z` | `number` | Z coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Noise value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:simplex3d(0.1, 0.5, 0.9)

    print(string.format("LNoiseGenerator:simplex3d=%.4f", value))
end
```

---

### `LNoiseGenerator:turbulence`

Samples turbulence fractal noise.

```lua
-- signature
LNoiseGenerator:turbulence(x, y, octaves, lac, pers, kind)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X coordinate. |
| `y` | `number` | Y coordinate. |
| `octaves?` | `number` | Octave count (default 4). |
| `lac?` | `number` | Lacunarity (default 2.0). |
| `pers?` | `number` | Persistence (default 0.5). |
| `kind?` | `string` | Noise kind name (default `"perlin"`). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Noise value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:turbulence(0.5, 0.5, 4)

    print(string.format("LNoiseGenerator:turbulence=%.4f", value))
end
```

---

### `LNoiseGenerator:type`

Returns the Lua-visible type name for this noise generator handle.

```lua
-- signature
LNoiseGenerator:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LNoiseGenerator`. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local type_name = generator:type()

    print("LNoiseGenerator:type=" .. type_name)
end
```

---

### `LNoiseGenerator:typeOf`

Returns whether this noise generator handle matches a supported type name.

```lua
-- signature
LNoiseGenerator:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LNoiseGenerator` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local matches = generator:typeOf("LNoiseGenerator")

    print("LNoiseGenerator:typeOf=" .. tostring(matches))
end
```

---

### `LNoiseGenerator:warpDomain`

Samples domain-warped noise coordinates.

```lua
-- signature
LNoiseGenerator:warpDomain(x, y, strength)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X coordinate. |
| `y` | `number` | Y coordinate. |
| `strength` | `number` | Warp strength. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Warped noise value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local warped_x, warped_y = generator:warpDomain(0.3, 0.7, 0.1)

    print(string.format("LNoiseGenerator:warpDomain x=%.4f", warped_x))
    print(string.format("LNoiseGenerator:warpDomain y=%.4f", warped_y))
end
```

---

### `LNoiseGenerator:worley2d`

Samples 2D Worley noise. This method is available to Lua scripts.

```lua
-- signature
LNoiseGenerator:worley2d(x, y, dist_name, f2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X coordinate. |
| `y` | `number` | Y coordinate. |
| `dist_name?` | `string` | Distance type name (default `"euclidean"`). |
| `f2?` | `boolean` | Second-feature flag (default false). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Noise value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:worley2d(0.5, 0.5)

    print(string.format("LNoiseGenerator:worley2d=%.4f", value))
end
```

---

### `LNoiseGenerator:worley3d`

Samples 3D Worley noise. This method is available to Lua scripts.

```lua
-- signature
LNoiseGenerator:worley3d(x, y, z, dist_name, f2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | X coordinate. |
| `y` | `number` | Y coordinate. |
| `z` | `number` | Z coordinate. |
| `dist_name?` | `string` | Distance type name (default `"euclidean"`). |
| `f2?` | `boolean` | Second-feature flag (default false). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Noise value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:worley3d(0.5, 0.5, 0.5)

    print(string.format("LNoiseGenerator:worley3d=%.4f", value))
end
```

---
