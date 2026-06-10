# Procgen

## Summary

- The procgen module provides deterministic synthesis of maps, structures, names, and procedural data fields.
- Seeded randomness is centralized so outputs are reproducible across runs and test pipelines.
- Noise primitives include Perlin, Simplex, and Worley generation.
- Fractal combinations support richer terrain and texture-like scalar fields.
- Domain warping and tileable variants support seamless looping and stylized maps.
- Parallel generation paths support large grid workloads.
- Heightmap generation converts sampled fields into usable elevation surfaces.
- Optional erosion passes add terrain smoothing and channel-like shaping.
- Biome classification maps elevation, moisture, and temperature into discrete categories.
- Biome outputs include visual-friendly color mapping.
- BSP dungeon generation creates partitioned room-and-corridor structures.
- Room-scatter generation provides alternative stochastic dungeon layouts.
- Prefab stamping blends authored motifs into procedural results.
- Cellular automata generation supports cave-like map structures.
- Cellular worlds support emergent sand/liquid/gas/fire style simulations.
- Flood-fill helpers support region extraction and connectivity tooling.
- Poisson disk sampling supports evenly spaced placement patterns.
- Voronoi support partitions space into nearest-seed regions.
- L-systems support grammar-based branching structures and turtle output.
- Wave Function Collapse supports adjacency-constrained tile synthesis.
- WFC includes weighted tile selection and contradiction retry behavior.
- World graph generation supports region topology and route analysis.
- Graph tools include shortest-path and spanning-tree utilities.
- Markov name generation supports synthetic naming from sample corpora.
- The module exposes both low-level primitives and high-level generators.
- It is designed for both rapid prototyping and production content pipelines.
- The module owns generation logic, not gameplay interpretation.
- It does not own renderer policy, but supports preview-oriented outputs.
- Determinism and parameterization are core quality goals.
- APIs are script-friendly and suitable for automated regression checks.
- The module remains in Foundations for broad reuse across genres.
- Overall, procgen is the data-synthesis backbone for procedural world workflows.
- It lets teams scale content variety without proportional authoring cost.

This module is mostly self-contained inside the Foundations group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Functions

### `lurek.procgen.biomeColor`

Get the default RGBA display color for a biome type name. Useful for minimap or debug visualization.

```lua
lurek.procgen.biomeColor(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Biome name (e.g. "ocean", "desert", "taiga"). |

**Returns**

| Type | Description |
|------|-------------|
| number | Red component (0â€“255). |
| number | Green component (0â€“255). |
| number | Blue component (0â€“255). |
| number | Alpha component (0â€“255). |

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
lurek.procgen.bspDungeon(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | table | Options: width, height, min_size (minimum leaf size), max_depth (BSP tree depth), seed, padding. |

**Returns**

| Type | Description |
|------|-------------|
| LProcgenBspDungeonResult | Table with .rooms (array of {x,y,w,h}) and .corridors (array of {x1,y1,x2,y2}). |

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
lurek.procgen.bspDungeonWithPrefabs(opts, prefabs)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | table | BSP options: width, height, min_size, max_depth, seed, padding. |
| `prefabs` | table | Array of prefab definitions: {name, width, height}. |

**Returns**

| Type | Description |
|------|-------------|
| LProcgenBspDungeonWithPrefabsResult | Dungeon table with .rooms and .corridors. |
| LProcgenBspDungeonWithPrefabsResult | Array of placed prefabs: {name; x; y; width; height}. |

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
lurek.procgen.cellularAutomata(width, height, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Grid width in cells. |
| `height` | number | Grid height in cells. |
| `opts?` | table | Options: fill (0.0â€“1.0 initial fill ratio), iterations, birth threshold, survive threshold, seed. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Flat array of cell values (0=empty, 1=wall) with length widthĂ—height. |

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
lurek.procgen.fbm(x, y, seed, octaves, lac, gain)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |
| `seed?` | number | Seed value (default 0). |
| `octaves?` | number | Octave count (default 4). |
| `lac?` | number | Lacunarity (default 2.0). |
| `gain?` | number | Gain (default 0.5). |

**Returns**

| Type | Description |
|------|-------------|
| number | Noise value. |

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
lurek.procgen.floodFill(data, width, height, startX, startY, threshold, above)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | table | Flat array of u8 cell values (length = width*height). |
| `width` | number | Grid width. |
| `height` | number | Grid height. |
| `startX` | number | Start column (0-based). |
| `startY` | number | Start row (0-based). |
| `threshold?` | number | Value threshold (default 128). |
| `above?` | boolean | If true, fill cells >= threshold; if false (default), fill cells < threshold. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Flat array of fill values (1=filled, 0=not filled) with length widthĂ—height. |

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
lurek.procgen.generateName(samples, minLen, maxLen, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `samples` | table | Array of example name strings to learn from. |
| `minLen?` | number | Minimum output length in characters (default 3). |
| `maxLen?` | number | Maximum output length in characters (default 10). |
| `seed?` | number | RNG seed (default 0). |

**Returns**

| Type | Description |
|------|-------------|
| string | A generated name. |

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
lurek.procgen.generateNames(samples, count, minLen, maxLen, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `samples` | table | Array of example name strings to learn from. |
| `count` | number | Number of names to generate. |
| `minLen?` | number | Minimum output length (default 3). |
| `maxLen?` | number | Maximum output length (default 10). |
| `seed?` | number | RNG seed (default 0). |

**Returns**

| Type | Description |
|------|-------------|
| string[] | Generated name strings. |

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
lurek.procgen.heightmap(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | table | Options: width, height, scale, octaves, lacunarity, persistence, seed, erosion_passes. |

**Returns**

| Type | Description |
|------|-------------|
| LProcgenHeightmapResult | Table with .cells (flat f32 array 0.0â€“1.0), .width, .height. |

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
lurek.procgen.heightmapFromCellular(width, height, cells, floorValue)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Grid width. |
| `height` | number | Grid height. |
| `cells` | table | Flat u8 array from cellularAutomata. |
| `floorValue?` | number | Cell value treated as open floor (default 0). |

**Returns**

| Type | Description |
|------|-------------|
| LProcgenHeightmapFromCellularResult | Table with .cells (flat f32 array), .width, .height. |

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
lurek.procgen.lsystem(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | Options: axiom (starting string), iterations (expansion count), rules (table mapping single-char keys to replacement strings). |

**Returns**

| Type | Description |
|------|-------------|
| string | The fully expanded L-system string. |

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
lurek.procgen.lsystemSegments(opts, angle, step)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | L-system options: axiom, iterations, rules. |
| `angle?` | number | Turn angle in degrees (default 25). |
| `step?` | number | Forward step length (default 1.0). |

**Returns**

| Type | Description |
|------|-------------|
| LProcgenLsystemSegmentsResult | Array of segment tables {x1, y1, x2, y2}. |

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
lurek.procgen.newBiomeClassifier(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | table | Optional rules: ocean_threshold, coast_threshold, mountain_threshold, ice_cap_threshold, cold_temperature, warm_temperature, dry_moisture, wet_moisture. |

**Returns**

| Type | Description |
|------|-------------|
| [LBiomeClassifier](#lbiomeclassifier) | A classifier object with :classify() and :classifyMap() methods. |

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
lurek.procgen.newCellular(width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Grid width in cells. |
| `height` | number | Grid height in cells. |

**Returns**

| Type | Description |
|------|-------------|
| [LCellular](#lcellular) | The cellular simulation object. |

**Example**

```lua
do
    local ca = lurek.procgen.newCellular(32, 32)
    ca:setCell(5, 5, lurek.procgen.CELL_SAND)
    ca:step()
    print("cellular type = " .. ca:type())
end
```

---

### `lurek.procgen.newNoiseGenerator`

Creates a procedural noise generator with an optional seed.

```lua
lurek.procgen.newNoiseGenerator(seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seed?` | number | Seed value (default 0). |

**Returns**

| Type | Description |
|------|-------------|
| [LNoiseGenerator](#lnoisegenerator) | New noise generator handle. |

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
lurek.procgen.noiseMap(width, height, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Map width in cells. |
| `height` | number | Map height in cells. |
| `opts?` | table | Options: scale_x, scale_y, octaves, lacunarity, persistence, offset_x, offset_y, seed. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | F64 noise values (length = width*height). |

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
lurek.procgen.noiseMapParallel(width, height, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Map width in cells. |
| `height` | number | Map height in cells. |
| `opts?` | table | Options: scale_x, scale_y, octaves, lacunarity, persistence, offset_x, offset_y. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | F64 noise values (length = width*height). |

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
lurek.procgen.noiseMapParallelSeeded(width, height, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Map width in cells. |
| `height` | number | Map height in cells. |
| `opts?` | table | Options: scale_x, scale_y, octaves, lacunarity, persistence, offset_x, offset_y, seed. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | F64 noise values (length = width*height). |

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
lurek.procgen.perlin2d(x, y, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |
| `seed?` | number | Seed value (default 0). |

**Returns**

| Type | Description |
|------|-------------|
| number | Noise value. |

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
lurek.procgen.perlin3d(x, y, z, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |
| `z` | number | Z coordinate. |
| `seed?` | number | Seed value (default 0). |

**Returns**

| Type | Description |
|------|-------------|
| number | Noise value. |

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
lurek.procgen.perlin4d(x, y, z, w, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |
| `z` | number | Z coordinate. |
| `w` | number | W coordinate. |
| `seed?` | number | Seed value (default 0). |

**Returns**

| Type | Description |
|------|-------------|
| number | Noise value. |

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
lurek.procgen.perlinNoise(x, y, periodX, periodY)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate to sample. |
| `y` | number | Y coordinate to sample. |
| `periodX` | number | Horizontal period for tiling. |
| `periodY` | number | Vertical period for tiling. |

**Returns**

| Type | Description |
|------|-------------|
| number | Noise value in the range [-1, 1]. |

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
lurek.procgen.poissonDisk(width, height, minDist, maxAttempts, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Area width. |
| `height` | number | Area height. |
| `minDist` | number | Minimum distance between any two points. |
| `maxAttempts?` | number | Rejection attempts per active point (default 30). Higher = denser fill. |
| `seed?` | number | RNG seed (default 0). |

**Returns**

| Type | Description |
|------|-------------|
| LProcgenPoissonDiskResult | Array of {x, y} tables representing generated points. |

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
lurek.procgen.roomsDungeon(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | table | Options: width, height, max_rooms, min_room_size, max_room_size, seed. |

**Returns**

| Type | Description |
|------|-------------|
| LProcgenRoomsDungeonResult | Table with .rooms ({x,y,w,h}[]), .corridors ({x1,y1,x2,y2}[]), .grid (flat u8[]), .width, .height. |

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
lurek.procgen.roomsDungeonWithPrefabs(opts, prefabs, stampValue)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | table | Room generation options: width, height, max_rooms, min_room_size, max_room_size, seed. |
| `prefabs` | table | Array of prefab definitions: {name, width, height, mask (optional flat u8[])}. |
| `stampValue?` | number | Tile value written for prefab cells in the grid (default 3). |

**Returns**

| Type | Description |
|------|-------------|
| LProcgenRoomsDungeonWithPrefabsResult | Dungeon table with .rooms; .corridors; .grid; .width; .height. |
| LProcgenRoomsDungeonWithPrefabsResult | Array of placed prefabs: {name; x; y; width; height}. |

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

### `lurek.procgen.setConstraintsFromLLM`

Sends a natural-language prompt to the global LLM and returns WFC adjacency constraints as a Lua table.

```lua
lurek.procgen.setConstraintsFromLLM(prompt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `prompt` | string | Natural-language description of the desired tile adjacency rules. |

**Returns**

| Type | Description |
|------|-------------|
| table | Map from tile ID (integer key) to array of allowed neighbour IDs. Empty table on error. |

**Example**

```lua
do
    -- LLM may be offline in CI; result is always a table (empty on error)
    local constraints = lurek.procgen.setConstraintsFromLLM("2 tiles: grass and water. Grass can be next to grass or water. Water can only be next to water.")
    print("setConstraintsFromLLM type=" .. type(constraints))
end
```

---

### `lurek.procgen.simplex2d`

Sample 2D simplex noise at a point. Returns a value roughly in [-1, 1].

```lua
lurek.procgen.simplex2d(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Simplex noise value. |

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
lurek.procgen.simplex3d(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |
| `z` | number | Z coordinate (often time or layer index). |

**Returns**

| Type | Description |
|------|-------------|
| number | Simplex noise value. |

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
lurek.procgen.simplexNoise(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |
| `z?` | number | Z coordinate for 3D noise. |

**Returns**

| Type | Description |
|------|-------------|
| number | Noise value. |

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
lurek.procgen.voronoi(width, height, points, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Grid width. |
| `height` | number | Grid height. |
| `points` | table | Array of {x, y} seed points. |
| `opts?` | table | Options: warp_scale, warp_strength, seed for domain warping. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | 1-based region indices (length = width*height). |
| number[] | Flat array of distances to nearest seed. |
| number[] | Flat array of distances to second-nearest seed. |

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

### `lurek.procgen.wfcFromPrompt`

Asks the global LLM for WFC tile definitions and adjacency rules, then runs WFC generation.

```lua
lurek.procgen.wfcFromPrompt(prompt, config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `prompt` | string | Description of the desired tile map (e.g. "dungeon with stone corridors"). |
| `config` | table | WFC config: width (integer), height (integer), seed (integer?), max_attempts (integer?). |

**Returns**

| Type | Description |
|------|-------------|
| LProcgenWfcFromPromptResult | WFC grid table with .width, .height, .cells ([{x,y,tile},...]), .failed_cells ([{x,y},...]). |

**Example**

```lua
do
    -- LLM may be offline in CI; result always has the required shape fields
    local grid = lurek.procgen.wfcFromPrompt(
        "small dungeon with stone floor and walls",
        { width = 4, height = 4, seed = 1, max_attempts = 5 }
    )
    print("wfcFromPrompt width=" .. grid.width .. " height=" .. grid.height)
    print("wfcFromPrompt cells_type=" .. type(grid.cells))
    print("wfcFromPrompt failed_type=" .. type(grid.failed_cells))
end
```

---

### `lurek.procgen.wfcGenerate`

Run Wave Function Collapse to generate a grid of tile IDs satisfying adjacency constraints.

```lua
lurek.procgen.wfcGenerate(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | Options: width, height, seed, max_attempts, tiles (array of {id, weight}), adjacencies (map of tile_id -> allowed neighbor IDs[]). |

**Returns**

| Type | Description |
|------|-------------|
| LProcgenWfcGenerateResult | Table with .cells (flat array of tile IDs, 0 if unsolved), .width, .height. |

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
lurek.procgen.worldGraph(width, height, regionCount, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | World area width. |
| `height` | number | World area height. |
| `regionCount` | number | Number of regions to place. |
| `seed?` | number | RNG seed (default 0). |

**Returns**

| Type | Description |
|------|-------------|
| LProcgenWorldGraphResult | Table with regions and edges arrays. |

**Example**

```lua
do
    local world = lurek.procgen.worldGraph(500, 500, 12, 42)

    print("worldGraph regions=" .. #world.regions)
    print("worldGraph edges=" .. #world.edges)
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## Types

- [LBiomeClassifier](#lbiomeclassifier)
- [LCellular](#lcellular)
- [LNoiseGenerator](#lnoisegenerator)

## LBiomeClassifier

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LBiomeClassifier:classify`

Classify a single point into a biome type based on its environmental parameters.

```lua
LBiomeClassifier:classify(height, moisture, temperature)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `height` | number | Elevation value (0.0â€“1.0) of the terrain point. |
| `moisture` | number | Moisture level (0.0â€“1.0) at the point. |
| `temperature` | number | Temperature value (0.0â€“1.0) at the point. |

**Returns**

| Type | Description |
|------|-------------|
| string | Biome name such as "ocean", "desert", "grassland", "taiga", etc. |

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

#### `LBiomeClassifier:classifyMap`

Classify an entire grid of points into biome types in bulk.

```lua
LBiomeClassifier:classifyMap(width, height, heights, moisture, temperature)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Grid width in cells. |
| `height` | number | Grid height in cells. |
| `heights` | table | Flat array of height values (length = width*height). |
| `moisture` | table | Flat array of moisture values (length = width*height). |
| `temperature?` | table | Optional flat array of temperature values. If omitted, temperature is ignored. |

**Returns**

| Type | Description |
|------|-------------|
| string[] | Biome name strings (length = width*height). |

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

#### `LBiomeClassifier:type`

Returns the type name of this object.

```lua
LBiomeClassifier:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always returns "[LBiomeClassifier](#lbiomeclassifier)". |

**Example**

```lua
do
    local classifier = lurek.procgen.newBiomeClassifier()
    local type_name = classifier:type()

    print("LBiomeClassifier:type=" .. type_name)
end
```

---

#### `LBiomeClassifier:typeOf`

Check whether this object matches a given type name.

```lua
LBiomeClassifier:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to test (e.g. "[LBiomeClassifier](#lbiomeclassifier)" or "Object"). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the object is of the specified type. |

**Example**

```lua
do
    local classifier = lurek.procgen.newBiomeClassifier()
    local matches = classifier:typeOf("LBiomeClassifier")

    print("LBiomeClassifier:typeOf=" .. tostring(matches))
end
```

---

## LCellular

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LCellular:countCells`

Counts how many cells of a given material type exist in the grid.

```lua
LCellular:countCells(cellType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cellType` | number | Material type constant to count. |

**Returns**

| Type | Description |
|------|-------------|
| number | Cell count. |

**Example**

```lua
do
    local ca = lurek.procgen.newCellular(16, 16)
    ca:setCell(0, 0, lurek.procgen.CELL_ROCK)
    print("rock count = " .. ca:countCells(lurek.procgen.CELL_ROCK))
end
```

---

#### `LCellular:fillCircle`

Fills a circular region of cells with a material type.

```lua
LCellular:fillCircle(cx, cy, r, cellType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Center cell column. |
| `cy` | number | Center cell row. |
| `r` | number | Radius in cells. |
| `cellType` | number | Material type constant. |

**Example**

```lua
do
    local ca = lurek.procgen.newCellular(32, 32)
    ca:fillCircle(16, 16, 5, lurek.procgen.CELL_WATER)
    print("fillCircle done")
end
```

---

#### `LCellular:fillRect`

Fills a rectangular region of cells with a material type.

```lua
LCellular:fillRect(cx0, cy0, cw, ch, cellType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx0` | number | Top-left cell column. |
| `cy0` | number | Top-left cell row. |
| `cw` | number | Width in cells. |
| `ch` | number | Height in cells. |
| `cellType` | number | Material type constant. |

**Example**

```lua
do
    local ca = lurek.procgen.newCellular(32, 32)
    ca:fillRect(0, 0, 8, 8, lurek.procgen.CELL_ROCK)
    print("fillRect done")
end
```

---

#### `LCellular:findCells`

Returns positions of all cells matching a material type.

```lua
LCellular:findCells(cellType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cellType` | number | Material type constant to find. |

**Returns**

| Type | Description |
|------|-------------|
| LCellularFindCellsResult | Array of {x, y} tables with cell coordinates. |

**Example**

```lua
do
    local ca = lurek.procgen.newCellular(16, 16)
    ca:setCell(3, 7, lurek.procgen.CELL_WATER)
    local found = ca:findCells(lurek.procgen.CELL_WATER)
    print("found count = " .. #found)
end
```

---

#### `LCellular:getCell`

Returns the material type of a cell at the given grid position.

```lua
LCellular:getCell(cx, cy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Cell column. |
| `cy` | number | Cell row. |

**Returns**

| Type | Description |
|------|-------------|
| number | Material type constant. |

**Example**

```lua
do
    local ca = lurek.procgen.newCellular(16, 16)
    local v = ca:getCell(0, 0)
    print("cell = " .. v)
end
```

---

#### `LCellular:loadFromBytes`

Restores cellular grid state from binary data previously produced by toBytes.

```lua
LCellular:loadFromBytes(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | string | Binary cellular data. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if loading succeeded, false if data was invalid. |

**Example**

```lua
do
    local ca = lurek.procgen.newCellular(8, 8)
    local bytes = ca:toBytes()
    local ca2 = lurek.procgen.newCellular(8, 8)
    ca2:loadFromBytes(bytes)
    print("loadFromBytes done")
end
```

---

#### `LCellular:setCell`

Sets a single cell in the cellular grid to a specific material type.

```lua
LCellular:setCell(cx, cy, cellType)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Cell column (0-based). |
| `cy` | number | Cell row (0-based). |
| `cellType` | number | Material type constant (CELL_AIR, CELL_SAND, etc.). |

**Example**

```lua
do
    local ca = lurek.procgen.newCellular(16, 16)
    ca:setCell(3, 3, lurek.procgen.CELL_SAND)
    print("setCell done")
end
```

---

#### `LCellular:step`

Advances the cellular simulation by one tick (particles fall, flow, burn, etc.).

```lua
LCellular:step()
```

**Example**

```lua
do
    local ca = lurek.procgen.newCellular(16, 16)
    ca:step()
    print("step done")
end
```

---

#### `LCellular:stepN`

Advances the cellular simulation by N ticks in a single call.

```lua
LCellular:stepN(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Number of simulation ticks to run. |

**Example**

```lua
do
    local ca = lurek.procgen.newCellular(16, 16)
    ca:stepN(5)
    print("stepN done")
end
```

---

#### `LCellular:toBytes`

Serializes the cellular grid to a compact binary format for saving.

```lua
LCellular:toBytes()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Binary cellular data. |

**Example**

```lua
do
    local ca = lurek.procgen.newCellular(8, 8)
    local bytes = ca:toBytes()
    print("toBytes length = " .. #bytes)
end
```

---

#### `LCellular:toImageData`

Renders the entire cellular grid to raw RGBA pixel data using the default material palette.

```lua
LCellular:toImageData()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Raw RGBA pixel bytes (width * height * 4). |

**Example**

```lua
do
    local ca = lurek.procgen.newCellular(16, 16)
    local img = ca:toImageData()
    print("toImageData bytes = " .. #img)
end
```

---

#### `LCellular:toImageDataRegion`

Renders a rectangular sub-region of the cellular grid to raw RGBA pixel data.

```lua
LCellular:toImageDataRegion(cx0, cy0, cw, ch)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx0` | number | Top-left cell column. |
| `cy0` | number | Top-left cell row. |
| `cw` | number | Width in cells. |
| `ch` | number | Height in cells. |

**Returns**

| Type | Description |
|------|-------------|
| string | Raw RGBA pixel bytes (cw * ch * 4). |

**Example**

```lua
do
    local ca = lurek.procgen.newCellular(32, 32)
    local img = ca:toImageDataRegion(0, 0, 16, 16)
    print("toImageDataRegion bytes = " .. #img)
end
```

---

#### `LCellular:type`

Returns the type name of this object ("[LCellular](#lcellular)").

```lua
LCellular:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | "[LCellular](#lcellular)". |

**Example**

```lua
do
    local ca = lurek.procgen.newCellular(8, 8)
    print("type = " .. ca:type())
end
```

---

#### `LCellular:typeOf`

Checks if this object is of a given type name.

```lua
LCellular:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the object matches. |

**Example**

```lua
do
    local ca = lurek.procgen.newCellular(8, 8)
    print("typeOf LCellular = " .. tostring(ca:typeOf("LCellular")))
end
```

---

## LNoiseGenerator

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LNoiseGenerator:fbm`

Samples fractal Brownian motion noise.

```lua
LNoiseGenerator:fbm(x, y, octaves, lac, pers, kind)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |
| `octaves?` | number | Octave count (default 4). |
| `lac?` | number | Lacunarity (default 2.0). |
| `pers?` | number | Persistence (default 0.5). |
| `kind?` | string | Noise kind name (default `"perlin"`). |

**Returns**

| Type | Description |
|------|-------------|
| number | Noise value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:fbm(0.5, 0.5, 4, 2.0, 0.5)

    print(string.format("LNoiseGenerator:fbm=%.4f", value))
end
```

---

#### `LNoiseGenerator:generateMap`

Generates a noise map and returns it as a flat array table.

```lua
LNoiseGenerator:generateMap(w, h, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Map width. |
| `h` | number | Map height. |
| `opts?` | table | Generation options including scale, octaves, kind, fractal, offset, and backend. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Noise values. |

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

#### `LNoiseGenerator:generateMapCompute`

Generates a noise map through the compute backend and returns it as a flat array table.

```lua
LNoiseGenerator:generateMapCompute(w, h, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Map width. |
| `h` | number | Map height. |
| `opts?` | table | Generation options including scale, octaves, kind, fractal, and offset. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Noise values. |

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

#### `LNoiseGenerator:getSeed`

Returns this noise generator seed.

```lua
LNoiseGenerator:getSeed()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Seed value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(12345)
    local seed = generator:getSeed()

    print("LNoiseGenerator:getSeed=" .. seed)
end
```

---

#### `LNoiseGenerator:perlin1d`

Samples 1D Perlin noise. This method is available to Lua scripts.

```lua
LNoiseGenerator:perlin1d(x)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Noise value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:perlin1d(0.5)

    print(string.format("LNoiseGenerator:perlin1d=%.4f", value))
end
```

---

#### `LNoiseGenerator:perlin2d`

Samples 2D Perlin noise. This method is available to Lua scripts.

```lua
LNoiseGenerator:perlin2d(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Noise value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:perlin2d(0.3, 0.7)

    print(string.format("LNoiseGenerator:perlin2d=%.4f", value))
end
```

---

#### `LNoiseGenerator:perlin3d`

Samples 3D Perlin noise. This method is available to Lua scripts.

```lua
LNoiseGenerator:perlin3d(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |
| `z` | number | Z coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Noise value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:perlin3d(0.2, 0.4, 0.8)

    print(string.format("LNoiseGenerator:perlin3d=%.4f", value))
end
```

---

#### `LNoiseGenerator:perlin4d`

Samples 4D Perlin noise. This method is available to Lua scripts.

```lua
LNoiseGenerator:perlin4d(x, y, z, w)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |
| `z` | number | Z coordinate. |
| `w` | number | W coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Noise value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:perlin4d(0.1, 0.2, 0.3, 0.6)

    print(string.format("LNoiseGenerator:perlin4d=%.4f", value))
end
```

---

#### `LNoiseGenerator:ridged`

Samples ridged fractal noise. This method is available to Lua scripts.

```lua
LNoiseGenerator:ridged(x, y, octaves, lac, pers, kind)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |
| `octaves?` | number | Octave count (default 4). |
| `lac?` | number | Lacunarity (default 2.0). |
| `pers?` | number | Persistence (default 0.5). |
| `kind?` | string | Noise kind name (default `"perlin"`). |

**Returns**

| Type | Description |
|------|-------------|
| number | Noise value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:ridged(0.4, 0.6)

    print(string.format("LNoiseGenerator:ridged=%.4f", value))
end
```

---

#### `LNoiseGenerator:setSeed`

Sets this noise generator seed. This method is available to Lua scripts.

```lua
LNoiseGenerator:setSeed(seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `seed` | number | Seed value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(1)

    generator:setSeed(99999)

    print("LNoiseGenerator:setSeed=" .. generator:getSeed())
end
```

---

#### `LNoiseGenerator:simplex1d`

Samples 1D simplex noise. This method is available to Lua scripts.

```lua
LNoiseGenerator:simplex1d(x)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Noise value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:simplex1d(0.5)

    print(string.format("LNoiseGenerator:simplex1d=%.4f", value))
end
```

---

#### `LNoiseGenerator:simplex2d`

Samples 2D simplex noise. This method is available to Lua scripts.

```lua
LNoiseGenerator:simplex2d(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Noise value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:simplex2d(0.3, 0.8)

    print(string.format("LNoiseGenerator:simplex2d=%.4f", value))
end
```

---

#### `LNoiseGenerator:simplex3d`

Samples 3D simplex noise. This method is available to Lua scripts.

```lua
LNoiseGenerator:simplex3d(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |
| `z` | number | Z coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Noise value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:simplex3d(0.1, 0.5, 0.9)

    print(string.format("LNoiseGenerator:simplex3d=%.4f", value))
end
```

---

#### `LNoiseGenerator:turbulence`

Samples turbulence fractal noise.

```lua
LNoiseGenerator:turbulence(x, y, octaves, lac, pers, kind)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |
| `octaves?` | number | Octave count (default 4). |
| `lac?` | number | Lacunarity (default 2.0). |
| `pers?` | number | Persistence (default 0.5). |
| `kind?` | string | Noise kind name (default `"perlin"`). |

**Returns**

| Type | Description |
|------|-------------|
| number | Noise value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:turbulence(0.5, 0.5, 4)

    print(string.format("LNoiseGenerator:turbulence=%.4f", value))
end
```

---

#### `LNoiseGenerator:type`

Returns the Lua-visible type name for this noise generator handle.

```lua
LNoiseGenerator:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LNoiseGenerator](#lnoisegenerator)`. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local type_name = generator:type()

    print("LNoiseGenerator:type=" .. type_name)
end
```

---

#### `LNoiseGenerator:typeOf`

Returns whether this noise generator handle matches a supported type name.

```lua
LNoiseGenerator:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LNoiseGenerator](#lnoisegenerator)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local matches = generator:typeOf("LNoiseGenerator")

    print("LNoiseGenerator:typeOf=" .. tostring(matches))
end
```

---

#### `LNoiseGenerator:warpDomain`

Samples domain-warped noise coordinates.

```lua
LNoiseGenerator:warpDomain(x, y, strength)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |
| `strength` | number | Warp strength. |

**Returns**

| Type | Description |
|------|-------------|
| number | Warped noise value. |

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

#### `LNoiseGenerator:worley2d`

Samples 2D Worley noise. This method is available to Lua scripts.

```lua
LNoiseGenerator:worley2d(x, y, dist_name, f2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |
| `dist_name?` | string | Distance type name (default `"euclidean"`). |
| `f2?` | boolean | Second-feature flag (default false). |

**Returns**

| Type | Description |
|------|-------------|
| number | Noise value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:worley2d(0.5, 0.5)

    print(string.format("LNoiseGenerator:worley2d=%.4f", value))
end
```

---

#### `LNoiseGenerator:worley3d`

Samples 3D Worley noise. This method is available to Lua scripts.

```lua
LNoiseGenerator:worley3d(x, y, z, dist_name, f2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | X coordinate. |
| `y` | number | Y coordinate. |
| `z` | number | Z coordinate. |
| `dist_name?` | string | Distance type name (default `"euclidean"`). |
| `f2?` | boolean | Second-feature flag (default false). |

**Returns**

| Type | Description |
|------|-------------|
| number | Noise value. |

**Example**

```lua
do
    local generator = lurek.procgen.newNoiseGenerator(42)
    local value = generator:worley3d(0.5, 0.5, 0.5)

    print(string.format("LNoiseGenerator:worley3d=%.4f", value))
end
```

---
