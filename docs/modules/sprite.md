# Sprite

## Summary

It provides the essential building blocks for 2D game visuals, encompassing sprite sheets, texture atlases, scalable UI panels, and high-performance batch rendering. At its most basic level, the `Sprite` struct defines a single textured unit with properties for position, scale, rotation, and color tint. To manage animation frames, the `SpriteSheet` divides a single texture into a uniform grid. It supports precomputed frame rectangles, named frame groups for animation sequences, and specific layouts for directional character sprites (such as the standard RPG Maker 3x4 layout). 

For more complex texture packing, the module features a comprehensive `SpriteAtlas` system. It parses standard texture atlas formats, specifically supporting JSON exports from popular tools like TexturePacker and Aseprite. The atlas stores named regions (`AtlasEntry`) complete with pixel rectangles and flags for rotation or flipping, allowing for O(1) name lookups and seamless integration with existing art pipelines. The module also includes `NineSlice`, a specialized struct that generates 9-patch geometry. This enables the creation of scalable UI elements—such as dialog boxes, health bars, or menu panels—that preserve their corner and edge pixel ratios while stretching to fit target dimensions.

To ensure optimal rendering performance, the module provides the `SpriteBatch` mechanism. A `SpriteBatch` acts as a deferred draw-call collector bound to a single texture atlas. Instead of submitting individual sprites to the GPU one by one, developers can accumulate hundreds of positioned, rotated, and scaled sprite entries into a single batch. This approach drastically reduces state changes and GPU draw calls, making it highly efficient for rendering dense tile layers, complex UI screens, or large swarms of characters. Fully accessible via the `lurek.sprite.*` Lua API, this module is indispensable for performant 2D game development in Lurek2D.

## Spec File Descriptions

_Poniższe opisy plików pochodzą bezpośrednio ze specyfikacji modułu (`docs/specs/<module>.md`)._

### atlas.rs

- This file handles named texture-atlas regions so packed art can be addressed by semantic names instead of raw pixel rectangles.
- It stores atlas entries with the orientation and flip metadata needed to interpret packing-tool output correctly.
- Parsers for common atlas JSON formats live here because importing packed textures is a content-pipeline concern rather than a render concern.
- Lookup is structured for fast name access while still retaining ordered iteration when tools or UIs need to inspect atlas contents.
- Conversion from runtime-built atlas data is also supported so authored and generated atlases can share one representation.
- The file is the naming and region-mapping layer for packed sprite content.

### mod.rs

- This module provides the engine's core 2D sprite asset and batching helpers around individual sprites, sheets, atlases, and scalable panels.
- It covers both how textured regions are described and how many of them are organized for animation, UI, or efficient drawing.
- At the highest level this is the feature layer that turns textures into reusable 2D presentation pieces.

### nine_slice.rs

- This file defines nine-slice scaling logic for UI panels and framed elements that must resize without destroying border fidelity.
- It splits one source region into corners, edges, and center pieces whose destination layout can adapt to arbitrary target sizes.
- Corner preservation and controlled edge stretching are the core visual promises of this file.
- It is the geometry helper behind scalable textured panels in the engine.

### sprite.rs

- This file defines the lightweight single-sprite record used when one textured image instance needs position, transform, and tint data.
- It is intentionally small because many systems want sprite-like draw data without carrying atlas, animation, or batching machinery.
- The type is the simplest textured presentation unit in the sprite subsystem.

### sprite_batch.rs

- This file implements sprite batching for cases where many textured quads share one source texture and should travel together through rendering.
- It accumulates per-instance transform and source-region data so callers can build dense draw groups without issuing one command per sprite.
- Capacity limits are part of the design because some workloads want explicit control over how much batch data is retained per frame.
- The file is the performance-oriented collection layer of the sprite subsystem.

### sprite_sheet.rs

- This file turns a texture divided into repeated cells into a navigable sprite-sheet structure for frame-based animation and lookup.
- Frame rectangles are precomputed so callers can move through rows, columns, ranges, and named groups without recalculating geometry each time.
- Directional layout helpers matter here because many character sheets encode facing and animation state as a regular grid convention.
- Preset constructors keep common authoring patterns, such as RPG-style character sheets, easy to adopt without custom math in game code.
- Debug visualization is included because sheet layout mistakes are easier to catch when the frame grid can be rendered and inspected directly.
- The file is the animation-frame organization layer of the sprite module.

## Functions

### `lurek.sprite.newAtlasSheet`

Creates a sprite sheet from an existing atlas, treating each atlas entry as a frame within the given sheet dimensions.

```lua
lurek.sprite.newAtlasSheet(atlas, sw, sh)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `atlas` | [LSpriteAtlas](#lspriteatlas-handle) | A previously parsed sprite atlas. |
| `sw` | number | Sheet texture width in pixels. |
| `sh` | number | Sheet texture height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| [LSpriteSheet](#lspritesheet-handle) | A new sprite sheet derived from the atlas entries. |

**Example**

```lua
do
    local atlas = lurek.sprite.parseAtlas(lurek.serial.toJson({ frames = { { filename = "f0", frame = { x = 0, y = 0, w = 32, h = 32 }, rotated = false } }, meta = { size = { w = 32, h = 32 } } }))
    local sheet = lurek.sprite.newAtlasSheet(atlas, 128, 32)
    print("frame count = " .. sheet:getFrameCount())
    print("atlas sheet type = " .. sheet:type())
end
```

---

### `lurek.sprite.newRPGMakerSheet`

Creates a sprite sheet using RPG Maker's standard character layout (4 columns Ă— 4 rows per character block).

```lua
lurek.sprite.newRPGMakerSheet(tw, th)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tw` | number | Full texture width in pixels. |
| `th` | number | Full texture height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| [LSpriteSheet](#lspritesheet-handle) | A new sprite sheet configured for RPG Maker character sprites. |

**Example**

```lua
do
    local rpg = lurek.sprite.newRPGMakerSheet(384, 256)
    print("frame count = " .. rpg:getFrameCount())
    local fw, fh = rpg:getFrameSize()
    local cols, rows = rpg:getGridSize()
    print("frame size = " .. fw .. "x" .. fh .. " grid = " .. cols .. "x" .. rows)
end
```

---

### `lurek.sprite.newSheet`

Creates a new sprite sheet by dividing a texture of the given pixel size into a grid of equal-sized frames.

```lua
lurek.sprite.newSheet(tw, th, fw, fh)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tw` | number | Full texture width in pixels. |
| `th` | number | Full texture height in pixels. |
| `fw` | number | Single frame width in pixels. |
| `fh` | number | Single frame height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| [LSpriteSheet](#lspritesheet-handle) | A new sprite sheet object. |

**Example**

```lua
do
    ---@type LSpriteSheet
    local sheet = lurek.sprite.newSheet(512, 512, 64, 64)
    print("type = " .. sheet:type())
    print("frame count = " .. sheet:getFrameCount())
end
```

---

### `lurek.sprite.parseAsepriteAtlas`

Parses an Aseprite JSON atlas string and returns a sprite atlas object.

```lua
lurek.sprite.parseAsepriteAtlas(json_str)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `json_str` | string | Raw JSON content of the Aseprite export atlas file. |

**Returns**

| Type | Description |
|------|-------------|
| [LSpriteAtlas](#lspriteatlas-handle) | A new atlas with named sprite regions from Aseprite frames. |

**Example**

```lua
do
    ---@type LSpriteAtlas
    local atlas = lurek.sprite.parseAsepriteAtlas(lurek.serial.toJson({ frames = { ["hero_idle_0.png"] = { frame = { x = 0, y = 0, w = 48, h = 48 }, rotated = false, sourceSize = { w = 48, h = 48 } } }, meta = { image = "hero.png", size = { w = 48, h = 48 }, scale = "1" } }))
    local entry = atlas:getEntry("hero_idle_0.png")
    print("aseprite atlas entries = " .. atlas:entryCount())
    print("hero_idle_0.png = " .. entry.w .. "x" .. entry.h)
end
```

---

### `lurek.sprite.parseAtlas`

Parses a TexturePacker JSON atlas string and returns a sprite atlas object.

```lua
lurek.sprite.parseAtlas(json_str)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `json_str` | string | Raw JSON content of the TexturePacker atlas file. |

**Returns**

| Type | Description |
|------|-------------|
| [LSpriteAtlas](#lspriteatlas-handle) | A new atlas with named sprite regions. |

**Example**

```lua
do
    ---@type LSpriteAtlas
    local atlas = lurek.sprite.parseAtlas(lurek.serial.toJson({ frames = { { filename = "player_idle_0", frame = { x = 0, y = 0, w = 64, h = 64 }, rotated = false } }, meta = { size = { w = 64, h = 64 } } }))
    local entry = atlas:getEntry("player_idle_0")
    print("entry count = " .. atlas:entryCount())
    print("player_idle_0 = " .. entry.w .. "x" .. entry.h)
end
```

---

## Module Fields

*No module-level fields documented.*

## Types

- [LSpriteAtlas Handle](#lspriteatlas-handle)
- [LSpriteSheet Handle](#lspritesheet-handle)

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## LSpriteAtlas Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LSpriteAtlas:entryCount`

Returns the total number of entries (sprite regions) in the atlas.

```lua
LSpriteAtlas:entryCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Entry count. |

**Example**

```lua
do
    local json = [[{"frames":[{"filename":"hero_walk_0001.png","frame":{"x":0,"y":0,"w":16,"h":16},"duration":100},{"filename":"hero_walk_0002.png","frame":{"x":16,"y":0,"w":16,"h":16},"duration":100}],"meta":{"size":{"w":32,"h":16}}}]]
    local atlas = lurek.sprite.parseAsepriteAtlas(json)
    print("aseprite_count = " .. atlas:entryCount())
end
```

---

#### `LSpriteAtlas:entryNames`

Returns an array of all entry names in the atlas.

```lua
LSpriteAtlas:entryNames()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Name strings. |

**Example**

```lua
do
    local json = [[{"frames":[{"filename":"hero_walk_0001.png","frame":{"x":0,"y":0,"w":16,"h":16},"duration":100},{"filename":"hero_walk_0002.png","frame":{"x":16,"y":0,"w":16,"h":16},"duration":100}],"meta":{"size":{"w":32,"h":16}}}]]
    local atlas = lurek.sprite.parseAsepriteAtlas(json)
    local names = atlas:entryNames()
    print("aseprite_names = " .. #names)
    print("first name = " .. tostring(names[1]))
end
```

---

#### `LSpriteAtlas:getByIndex`

Returns a sprite region by its 1-based index in the atlas.

```lua
LSpriteAtlas:getByIndex(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | 1-based entry index. |

**Returns**

| Type | Description |
|------|-------------|
| LSpriteAtlasGetByIndexResult | Entry table `{name, x, y, w, h, rotated}`, or nil if the index is out of range. |

**Example**

```lua
do
    ---@type LSpriteAtlas
    local atlas = lurek.sprite.parseAtlas(lurek.serial.toJson({ frames = { { filename = "coin_0", frame = { x = 0, y = 0, w = 16, h = 16 }, rotated = false } }, meta = { size = { w = 16, h = 16 } } }))
    local byIdx = atlas:getByIndex(1)
    print("index 1 name = " .. byIdx.name)
end
```

---

#### `LSpriteAtlas:getEntry`

Looks up a named sprite region in the atlas by its original filename or tag.

```lua
LSpriteAtlas:getEntry(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Entry name (e.g. `"player_idle_0"`). |

**Returns**

| Type | Description |
|------|-------------|
| LSpriteAtlasGetEntryResult | Entry table `{name, x, y, w, h, rotated}`, or nil if the entry is not found. |

**Example**

```lua
do
    ---@type LSpriteAtlas
    local atlas = lurek.sprite.parseAtlas(lurek.serial.toJson({ frames = { { filename = "coin_0", frame = { x = 0, y = 0, w = 16, h = 16 }, rotated = false } }, meta = { size = { w = 16, h = 16 } } }))
    local coin = atlas:getEntry("coin_0")
    print("coin_0: x=" .. coin.x .. " y=" .. coin.y .. " w=" .. coin.w .. " h=" .. coin.h)
    print("rotated = " .. tostring(coin.rotated))
end
```

---

#### `LSpriteAtlas:getFlipped`

Returns a copy of a named atlas entry with the specified flip flags applied.

```lua
LSpriteAtlas:getFlipped(name, flip_x, flip_y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Entry name to look up. |
| `flip_x` | boolean | Mirror horizontally. |
| `flip_y` | boolean | Mirror vertically. |

**Returns**

| Type | Description |
|------|-------------|
| LSpriteAtlasGetFlippedResult | Entry table with added `flip_x` and `flip_y` fields, or nil if the entry is not found. |

**Example**

```lua
do
    ---@type LSpriteAtlas
    local atlas = lurek.sprite.parseAtlas(lurek.serial.toJson({ frames = { { filename = "arrow_right", frame = { x = 0, y = 0, w = 32, h = 16 }, rotated = false } }, meta = { size = { w = 32, h = 16 } } }))
    local flippedH = atlas:getFlipped("arrow_right", true, false)
    print("flip_x = " .. tostring(flippedH.flip_x) .. " flip_y = " .. tostring(flippedH.flip_y))
    print("still same coords: x=" .. flippedH.x .. " w=" .. flippedH.w)
end
```

---

#### `LSpriteAtlas:type`

Returns the type name of this object.

```lua
LSpriteAtlas:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `"[LSpriteAtlas](#lspriteatlas-handle)"`. |

**Example**

```lua
do
    local json = [[{"frames":[{"filename":"hero_walk_0001.png","frame":{"x":0,"y":0,"w":16,"h":16},"duration":100},{"filename":"hero_walk_0002.png","frame":{"x":16,"y":0,"w":16,"h":16},"duration":100}],"meta":{"size":{"w":32,"h":16}}}]]
    local atlas = lurek.sprite.parseAsepriteAtlas(json)
    print("type = " .. atlas:type())
end
```

---

#### `LSpriteAtlas:typeOf`

Checks whether this object matches the given type name.

```lua
LSpriteAtlas:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check (e.g. `"[LSpriteAtlas](#lspriteatlas-handle)"` or `"Object"`). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the object is the given type. |

**Example**

```lua
do
    local json = [[{"frames":[{"filename":"hero_walk_0001.png","frame":{"x":0,"y":0,"w":16,"h":16},"duration":100},{"filename":"hero_walk_0002.png","frame":{"x":16,"y":0,"w":16,"h":16},"duration":100}],"meta":{"size":{"w":32,"h":16}}}]]
    local atlas = lurek.sprite.parseAsepriteAtlas(json)
    print("typeOf = " .. tostring(atlas:typeOf("LSpriteAtlas")))
end
```

---

## LSpriteSheet Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LSpriteSheet:drawToImage`

Renders the sprite sheet grid into an LImage of the given size for debugging or previews.

```lua
LSpriteSheet:drawToImage(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Output image width in pixels. |
| `h` | number | Output image height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| LImage | A new image containing the rendered sprite sheet. |

**Example**

```lua
do
    ---@type LSpriteSheet
    local sheet = lurek.sprite.newSheet(256, 256, 32, 32)
    local img = sheet:drawToImage(256, 256)
    print("preview image width = " .. img:getWidth())
    print("preview image height = " .. img:getHeight())
end
```

---

#### `LSpriteSheet:getColumn`

Returns all frame quads in the given column of the sprite sheet grid.

```lua
LSpriteSheet:getColumn(col)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `col` | number | 0-based column index. |

**Returns**

| Type | Description |
|------|-------------|
| LSpriteSheetGetColumnResult | Array of quad tables `{x, y, w, h}`. |

**Example**

```lua
do
    ---@type LSpriteSheet
    local sheet = lurek.sprite.newSheet(192, 192, 64, 64)
    local col0 = sheet:getColumn(0)
    print("col 0 frames = " .. #col0)
end
```

---

#### `LSpriteSheet:getFrame`

Returns the UV quad for a single frame by its 1-based index.

```lua
LSpriteSheet:getFrame(index)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `index` | number | 1-based frame index in the sprite sheet. |

**Returns**

| Type | Description |
|------|-------------|
| LSpriteSheetGetFrameResult | Quad table `{x, y, w, h}` with normalized UV coordinates, or nil if the index is out of range. |

**Example**

```lua
do
    ---@type LSpriteSheet
    local sheet = lurek.sprite.newSheet(256, 128, 32, 32)
    local frame1 = sheet:getFrame(1)
    print("frame 1: x=" .. frame1.x .. " y=" .. frame1.y .. " w=" .. frame1.w .. " h=" .. frame1.h)
end
```

---

#### `LSpriteSheet:getFrameCount`

Returns the total number of frames in this sprite sheet.

```lua
LSpriteSheet:getFrameCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total frame count (columns Ă— rows). |

**Example**

```lua
do
    local sheet = lurek.sprite.newSheet(128, 64, 32, 32)
    print("frame_count = " .. sheet:getFrameCount())
end
```

---

#### `LSpriteSheet:getFrameSize`

Returns the pixel dimensions of a single frame cell.

```lua
LSpriteSheet:getFrameSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Frame width in pixels. |
| number | Frame height in pixels. |

**Example**

```lua
do
    local sheet = lurek.sprite.newSheet(128, 64, 32, 32)
    local fw, fh = sheet:getFrameSize()
    print("frame_size = " .. fw .. "x" .. fh)
end
```

---

#### `LSpriteSheet:getGridSize`

Returns the number of columns and rows in the sprite sheet grid.

```lua
LSpriteSheet:getGridSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Number of columns. |
| number | Number of rows. |

**Example**

```lua
do
    local sheet = lurek.sprite.newSheet(128, 64, 32, 32)
    local gw, gh = sheet:getGridSize()
    print("grid = " .. gw .. "x" .. gh)
end
```

---

#### `LSpriteSheet:getGroupFrames`

Returns the frame quads for a named animation group.

```lua
LSpriteSheet:getGroupFrames(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Name of the animation group (e.g. "walk", "idle"). |

**Returns**

| Type | Description |
|------|-------------|
| LSpriteSheetGetGroupFramesResult | Array of quad tables for the group, or nil if the group does not exist. |

**Example**

```lua
do
    ---@type LSpriteSheet
    local sheet = lurek.sprite.newSheet(512, 256, 64, 64)
    sheet:nameGroup("walk", 5, 8)
    local walkFrames = sheet:getGroupFrames("walk")
    print("walk frames = " .. #walkFrames)
end
```

---

#### `LSpriteSheet:getGroupNames`

Returns an array of all named animation group names defined on this sheet.

```lua
LSpriteSheet:getGroupNames()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Group name strings. |

**Example**

```lua
do
    ---@type LSpriteSheet
    local sheet = lurek.sprite.newSheet(512, 256, 64, 64)
    sheet:nameGroup("idle", 1, 4)
    local names = sheet:getGroupNames()
    print("groups = " .. #names)
    print("first group = " .. tostring(names[1]))
end
```

---

#### `LSpriteSheet:getRow`

Returns all frame quads in the given row of the sprite sheet grid.

```lua
LSpriteSheet:getRow(row)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row` | number | 0-based row index. |

**Returns**

| Type | Description |
|------|-------------|
| LSpriteSheetGetRowResult | Array of quad tables `{x, y, w, h}`. |

**Example**

```lua
do
    ---@type LSpriteSheet
    local sheet = lurek.sprite.newSheet(192, 192, 64, 64)
    local row0 = sheet:getRow(0)
    print("row 0 frames = " .. #row0)
end
```

---

#### `LSpriteSheet:nameGroup`

Defines a named animation group as a contiguous range of frames.

```lua
LSpriteSheet:nameGroup(name, start, count)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Name for the group (e.g. "attack"). |
| `start` | number | 1-based start frame index. |
| `count` | number | Number of frames in the group. |

**Example**

```lua
do
    ---@type LSpriteSheet
    local sheet = lurek.sprite.newSheet(512, 256, 64, 64)
    sheet:nameGroup("idle", 1, 4)
    print("group named = idle")
end
```

---

#### `LSpriteSheet:type`

Returns the type name of this object.

```lua
LSpriteSheet:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `"[LSpriteSheet](#lspritesheet-handle)"`. |

**Example**

```lua
do
    local sheet = lurek.sprite.newSheet(128, 64, 32, 32)
    print("type = " .. sheet:type())
end
```

---

#### `LSpriteSheet:typeOf`

Checks whether this object matches the given type name.

```lua
LSpriteSheet:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check (e.g. `"[LSpriteSheet](#lspritesheet-handle)"` or `"Object"`). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the object is the given type. |

**Example**

```lua
do
    local sheet = lurek.sprite.newSheet(128, 64, 32, 32)
    print("typeOf = " .. tostring(sheet:typeOf("LSpriteSheet")))
end
```

---
