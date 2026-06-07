# Sprite

## Summary

This module turns raw textures into reusable sprites, sheets, and UI panels. It supports named texture atlases parsed from TexturePacker and Aseprite JSON data, mapping semantic names to specific regions while handling rotation and flip flags. This allows scripts to query packed sprites by name instead of raw coordinates.

Atlas parsing now shares the engine's common Aseprite loader with the animation module. This keeps frame-shape validation and malformed-export error behavior aligned across sprite-atlas import and Aseprite animation ingest, instead of maintaining separate parsers for the same source format.

For animations and interfaces, the system offers grid sheets and scalable panels. The sprite-sheet engine divides textures into grids, precomputing frame UVs for fast index lookup and character animations. A nine-slice engine splits frames into corners and edges, letting panels stretch to any size while keeping border dimensions crisp and distortion-free.

Row and column extraction on `SpriteSheet` are implemented with allocation-light internal paths (row slices and column iterators), while Lua still receives the same table-shaped frame arrays via `LSpriteSheet:getRow` and `LSpriteSheet:getColumn`.

To optimize drawing, the module provides lightweight sprite records and instanced batching. Sprite batches group quads sharing a single texture into one draw command, bypassing call overhead. Developers can configure batch capacities to keep render loops efficient.

Individual sprites can also carry optional normal-map texture state and a strength scalar for lit-sprite workflows. This extends the sprite data model without changing atlas, sheet, or batch APIs for unlit content.

The Lua API also provides a runtime atlas packer for dynamic content. `lurek.sprite.newAtlasPacker(width, height, padding)` builds an in-memory allocator that can pack named regions, query packed rectangles, and attach optional nine-slice insets for UI scaling workflows.

Clip playback is now available as a Rust-backed animator userdata. `lurek.sprite.newAnimator(clips)` creates `LSpriteAnimator`, which handles named clip playback (`play`, `pause`, `resume`, `stop`), frame stepping (`update`, `currentFrame`), clip editing (`addClip`), timing helpers, and loop/end/frame callbacks.

## Functions

### `lurek.sprite.newAnimator`

Creates a stateful sprite clip animator from an optional clip definition table.

```lua
lurek.sprite.newAnimator(clips)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `clips?` | table | Map `{ clip_name = { row, from, to, fps, loop? } }`. |

**Returns**

| Type | Description |
|------|-------------|
| [LSpriteAnimator](#lspriteanimator) | A new clip animator object. |

**Example**

```lua
do
    local anim = lurek.sprite.newAnimator({
        idle = { row = 1, from = 1, to = 3, fps = 10, loop = true }
    })
    print("animator type = " .. anim:type())
end
```

---

### `lurek.sprite.newAtlasPacker`

Creates a runtime atlas packer for dynamically allocating named sprite regions.

```lua
lurek.sprite.newAtlasPacker(width, height, padding)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `width` | number | Atlas width in pixels. |
| `height` | number | Atlas height in pixels. |
| `padding` | number | Padding in pixels inserted around each packed region. |

**Returns**

| Type | Description |
|------|-------------|
| [LAtlasPacker](#latlaspacker) | A new runtime atlas packer. |

**Example**

```lua
do
    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    print("atlas packer type = " .. packer:type())
end
```

---

### `lurek.sprite.newAtlasSheet`

Creates a sprite sheet from an existing atlas, treating each atlas entry as a frame within the given sheet dimensions.

```lua
lurek.sprite.newAtlasSheet(atlas, sw, sh)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `atlas` | [LSpriteAtlas](#lspriteatlas) | A previously parsed sprite atlas. |
| `sw` | number | Sheet texture width in pixels. |
| `sh` | number | Sheet texture height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| [LSpriteSheet](#lspritesheet) | A new sprite sheet derived from the atlas entries. |

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
| [LSpriteSheet](#lspritesheet) | A new sprite sheet configured for RPG Maker character sprites. |

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
| [LSpriteSheet](#lspritesheet) | A new sprite sheet object. |

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

### `lurek.sprite.newSprite`

Creates a lightweight sprite record with transform and optional normal-map metadata.

```lua
lurek.sprite.newSprite(texture_id, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `texture_id` | number | Texture handle used by the sprite. |
| `x` | number | Initial world X position. |
| `y` | number | Initial world Y position. |

**Returns**

| Type | Description |
|------|-------------|
| [LSprite](#lsprite) | A new sprite object. |

**Example**

```lua
do
    local sprite = lurek.sprite.newSprite(7, 10, 20)
    print("sprite created = " .. tostring(sprite ~= nil))
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
| [LSpriteAtlas](#lspriteatlas) | A new atlas with named sprite regions from Aseprite frames. |

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
| [LSpriteAtlas](#lspriteatlas) | A new atlas with named sprite regions. |

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

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## Types

- [LAtlasPacker](#latlaspacker)
- [LSprite](#lsprite)
- [LSpriteAnimator](#lspriteanimator)
- [LSpriteAtlas](#lspriteatlas)
- [LSpriteSheet](#lspritesheet)

## LAtlasPacker

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAtlasPacker:clear`

Removes all packed regions and resets packing shelves.

```lua
LAtlasPacker:clear()
```

**Example**

```lua
do
    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    packer:pack("hero", 24, 24)
    if packer:getRegion("hero") ~= nil and packer:getRegion("hero").nine_slice ~= nil then
        print("hero nine-slice left = " .. packer:getRegion("hero").nine_slice.left)
    end
    packer:clear()
    print("after clear count = " .. packer:regionCount())
end
```

---

#### `LAtlasPacker:getDimensions`

Returns the current width and height of this atlas packer.

```lua
LAtlasPacker:getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Atlas width in pixels. |
| number | Atlas height in pixels. |

**Example**

```lua
do
    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    local w, h = packer:getDimensions()
    print("dimensions = " .. w .. "x" .. h)
end
```

---

#### `LAtlasPacker:getRegion`

Returns the named packed atlas region, or nil if not found.

```lua
LAtlasPacker:getRegion(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Region key to fetch. |

**Returns**

| Type | Description |
|------|-------------|
| LAtlasPackerGetRegionResult | Region table `{name, x, y, w, h, nine_slice}` or nil when missing. |

**Example**

```lua
do
    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    packer:pack("hero", 24, 24)
    local region = packer:getRegion("hero")
    print("region x = " .. (region and region.x or -1))
end
```

---

#### `LAtlasPacker:pack`

Packs a named region into this atlas and returns whether allocation succeeded.

```lua
LAtlasPacker:pack(name, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Region key used for later lookups. |
| `w` | number | Region width in pixels. |
| `h` | number | Region height in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the region was packed. |

**Example**

```lua
do
    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    local ok = packer:pack("hero", 24, 24)
    print("packed hero = " .. tostring(ok))
end
```

---

#### `LAtlasPacker:regionCount`

Returns the number of currently packed regions.

```lua
LAtlasPacker:regionCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Region count. |

**Example**

```lua
do
    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    packer:pack("hero", 24, 24)
    print("region count = " .. packer:regionCount())
end
```

---

#### `LAtlasPacker:setNineSlice`

Sets nine-slice insets for a previously packed region.

```lua
LAtlasPacker:setNineSlice(name, left, right, top, bottom)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Packed region key. |
| `left` | number | Left inset in pixels. |
| `right` | number | Right inset in pixels. |
| `top` | number | Top inset in pixels. |
| `bottom` | number | Bottom inset in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when insets were applied. |

**Example**

```lua
do
    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    packer:pack("hero", 24, 24)
    local ok = packer:setNineSlice("hero", 4, 4, 4, 4)
    print("set nine-slice = " .. tostring(ok))
end
```

---

#### `LAtlasPacker:type`

Returns the type name of this object.

```lua
LAtlasPacker:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `"[LAtlasPacker](#latlaspacker)"`. |

**Example**

```lua
do
    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    print("type = " .. packer:type())
end
```

---

#### `LAtlasPacker:typeOf`

Checks whether this object matches the given type name.

```lua
LAtlasPacker:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check (e.g. `"[LAtlasPacker](#latlaspacker)"` or `"Object"`). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the object is the given type. |

**Example**

```lua
do
    local packer = lurek.sprite.newAtlasPacker(128, 64, 1)
    print("typeOf LAtlasPacker = " .. tostring(packer:typeOf("LAtlasPacker")))
end
```

---

## LSprite

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSprite:clearNormalMap`

Removes the assigned normal map from this sprite.

```lua
LSprite:clearNormalMap()
```

**Example**

```lua
do
    local sprite = lurek.sprite.newSprite(7, 10, 20)
    sprite:setNormalMap(3)
    sprite:clearNormalMap()
    print("has normal after clear = " .. tostring(sprite:hasNormalMap()))
end
```

---

#### `LSprite:getNormalIntensity`

Returns the normal-map intensity multiplier.

```lua
LSprite:getNormalIntensity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current non-negative intensity multiplier. |

**Example**

```lua
do
    local sprite = lurek.sprite.newSprite(7, 10, 20)
    sprite:setNormalIntensity(2.5)
    print("normal intensity = " .. tostring(sprite:getNormalIntensity()))
end
```

---

#### `LSprite:getNormalMap`

Returns the assigned normal-map texture handle, or nil when absent.

```lua
LSprite:getNormalMap()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Texture handle for the normal map. |

**Example**

```lua
do
    local sprite = lurek.sprite.newSprite(7, 10, 20)
    sprite:setNormalMap(11)
    print("normal map = " .. tostring(sprite:getNormalMap()))
end
```

---

#### `LSprite:getPosition`

Returns the sprite anchor position in pixels.

```lua
LSprite:getPosition()
```

**Returns**

| Type | Description |
|------|-------------|
| number | World X position. |
| number | World Y position. |

**Example**

```lua
do
    local sprite = lurek.sprite.newSprite(7, 10, 20)
    local x, y = sprite:getPosition()
    print("position = " .. x .. "," .. y)
end
```

---

#### `LSprite:hasNormalMap`

Returns whether the sprite currently has a normal map.

```lua
LSprite:hasNormalMap()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a normal map is assigned. |

**Example**

```lua
do
    local sprite = lurek.sprite.newSprite(7, 10, 20)
    print("has normal before = " .. tostring(sprite:hasNormalMap()))
    sprite:setNormalMap(3)
    print("has normal after = " .. tostring(sprite:hasNormalMap()))
end
```

---

#### `LSprite:setNormalIntensity`

Sets the normal-map intensity used by lit sprite workflows.

```lua
LSprite:setNormalIntensity(intensity)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `intensity` | number | Non-negative intensity multiplier. |

**Example**

```lua
do
    local sprite = lurek.sprite.newSprite(7, 10, 20)
    sprite:setNormalIntensity(2.5)
    print("normal intensity set")
end
```

---

#### `LSprite:setNormalMap`

Assigns the texture used as this sprite's normal map for lit sprite workflows.

```lua
LSprite:setNormalMap(texture_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `texture_id` | number | Texture handle used as the normal-map source. |

**Example**

```lua
do
    local sprite = lurek.sprite.newSprite(7, 10, 20)
    sprite:setNormalMap(11)
    print("normal map set = " .. tostring(sprite:getNormalMap() == 11))
end
```

---

#### `LSprite:setPosition`

Sets the sprite anchor position in pixels.

```lua
LSprite:setPosition(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | World X position. |
| `y` | number | World Y position. |

**Example**

```lua
do
    local sprite = lurek.sprite.newSprite(7, 10, 20)
    sprite:setPosition(32, 48)
    local x, y = sprite:getPosition()
    print("position = " .. x .. "," .. y)
end
```

---

#### `LSprite:type`

Returns the type name of this object.

```lua
LSprite:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `"[LSprite](#lsprite)"`. |

**Example**

```lua
do
    local sprite = lurek.sprite.newSprite(7, 10, 20)
    print("type = " .. sprite:type())
end
```

---

#### `LSprite:typeOf`

Checks whether this object matches the given type name.

```lua
LSprite:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the object is the given type. |

**Example**

```lua
do
    local sprite = lurek.sprite.newSprite(7, 10, 20)
    print("typeOf LSprite = " .. tostring(sprite:typeOf("LSprite")))
end
```

---

## LSpriteAnimator

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSpriteAnimator:addClip`

Add or replace a named clip definition.

```lua
LSpriteAnimator:addClip(name, def)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Clip name. |
| `def` | table | Clip definition table with `row`, `from`, `to`, `fps`, and optional `loop`. |

**Example**

```lua
do
    local anim = lurek.sprite.newAnimator()
    anim:addClip("run", { row = 3, from = 1, to = 4, fps = 12, loop = true })
    anim:play("run")
    print("current clip after add = " .. tostring(anim:currentClip()))
end
```

---

#### `LSpriteAnimator:clipDuration`

Return full one-pass duration for the current clip.

```lua
LSpriteAnimator:clipDuration()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total clip duration in seconds. |

**Example**

```lua
do
    local anim = lurek.sprite.newAnimator({ idle = { row = 1, from = 1, to = 3, fps = 6, loop = true } })
    anim:play("idle")
    print("clip duration = " .. tostring(anim:clipDuration()))
end
```

---

#### `LSpriteAnimator:currentClip`

Return the currently selected clip name.

```lua
LSpriteAnimator:currentClip()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Active clip name, or nil if none. |

**Example**

```lua
do
    local anim = lurek.sprite.newAnimator({ idle = { row = 1, from = 1, to = 3, fps = 10, loop = true } })
    anim:play("idle")
    print("current clip = " .. tostring(anim:currentClip()))
end
```

---

#### `LSpriteAnimator:currentFrame`

Return current draw frame as sprite-sheet row and column.

```lua
LSpriteAnimator:currentFrame()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Sprite-sheet row. |
| number | Sprite-sheet column (frame index). |

**Example**

```lua
do
    local anim = lurek.sprite.newAnimator({ idle = { row = 2, from = 3, to = 4, fps = 10, loop = true } })
    anim:play("idle")
    local row, col = anim:currentFrame()
    print("frame = " .. row .. "," .. col)
end
```

---

#### `LSpriteAnimator:frameDuration`

Return frame duration for the current clip.

```lua
LSpriteAnimator:frameDuration()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Seconds per frame. |

**Example**

```lua
do
    local anim = lurek.sprite.newAnimator({ idle = { row = 1, from = 1, to = 3, fps = 20, loop = true } })
    anim:play("idle")
    print("frame duration = " .. tostring(anim:frameDuration()))
end
```

---

#### `LSpriteAnimator:isPlaying`

Return whether the animator is currently playing.

```lua
LSpriteAnimator:isPlaying()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when playing. |

**Example**

```lua
do
    local anim = lurek.sprite.newAnimator({ idle = { row = 1, from = 1, to = 3, fps = 10, loop = true } })
    anim:play("idle")
    print("is playing = " .. tostring(anim:isPlaying()))
end
```

---

#### `LSpriteAnimator:onEnd`

Set callback fired when a non-looping clip reaches its end.

```lua
LSpriteAnimator:onEnd(fn)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fn` | function | Callback signature `(clip_name)`. |

**Example**

```lua
do
    local anim = lurek.sprite.newAnimator({ jump = { row = 1, from = 1, to = 2, fps = 10, loop = false } })
    anim:onEnd(function(clip)
        print("onEnd " .. clip)
    end)
    anim:play("jump")
    anim:update(0.5)
end
```

---

#### `LSpriteAnimator:onFrame`

Set callback fired on each frame advance.

```lua
LSpriteAnimator:onFrame(fn)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fn` | function | Callback signature `(row, col, clip_name)`. |

**Example**

```lua
do
    local anim = lurek.sprite.newAnimator({ idle = { row = 1, from = 1, to = 3, fps = 10, loop = true } })
    anim:onFrame(function(row, col, clip)
        print("onFrame " .. clip .. " " .. row .. ":" .. col)
    end)
    anim:play("idle")
    anim:update(0.11)
end
```

---

#### `LSpriteAnimator:onLoop`

Set callback fired when a looping clip wraps.

```lua
LSpriteAnimator:onLoop(fn)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fn` | function | Callback signature `(clip_name)`. |

**Example**

```lua
do
    local anim = lurek.sprite.newAnimator({ idle = { row = 1, from = 1, to = 2, fps = 10, loop = true } })
    anim:onLoop(function(clip)
        print("onLoop " .. clip)
    end)
    anim:play("idle")
    anim:update(0.25)
end
```

---

#### `LSpriteAnimator:pause`

Pause playback without resetting frame state.

```lua
LSpriteAnimator:pause()
```

**Example**

```lua
do
    local anim = lurek.sprite.newAnimator({ idle = { row = 1, from = 1, to = 3, fps = 10, loop = true } })
    anim:play("idle")
    anim:pause()
    print("is playing after pause = " .. tostring(anim:isPlaying()))
end
```

---

#### `LSpriteAnimator:play`

Play or restart a named clip.

```lua
LSpriteAnimator:play(name, restart)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Clip name. |
| `restart?` | boolean | Whether to restart when already playing this clip. Defaults to true. |

**Example**

```lua
do
    local anim = lurek.sprite.newAnimator({ idle = { row = 1, from = 1, to = 3, fps = 10, loop = true } })
    anim:play("idle")
    print("clip after play = " .. tostring(anim:currentClip()))
end
```

---

#### `LSpriteAnimator:resume`

Resume playback from current frame when a clip is selected.

```lua
LSpriteAnimator:resume()
```

**Example**

```lua
do
    local anim = lurek.sprite.newAnimator({ idle = { row = 1, from = 1, to = 3, fps = 10, loop = true } })
    anim:play("idle")
    anim:pause()
    anim:resume()
    print("is playing after resume = " .. tostring(anim:isPlaying()))
end
```

---

#### `LSpriteAnimator:stop`

Stop playback and reset to the first frame of the current clip.

```lua
LSpriteAnimator:stop()
```

**Example**

```lua
do
    local anim = lurek.sprite.newAnimator({ idle = { row = 1, from = 1, to = 3, fps = 10, loop = true } })
    anim:play("idle")
    anim:update(0.2)
    anim:stop()
    local _, col = anim:currentFrame()
    print("frame after stop = " .. tostring(col))
end
```

---

#### `LSpriteAnimator:type`

Returns the type name of this object.

```lua
LSpriteAnimator:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always `"[LSpriteAnimator](#lspriteanimator)"`. |

**Example**

```lua
do
    local anim = lurek.sprite.newAnimator()
    print("type = " .. anim:type())
end
```

---

#### `LSpriteAnimator:typeOf`

Checks whether this object matches the given type name.

```lua
LSpriteAnimator:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the object is the given type. |

**Example**

```lua
do
    local anim = lurek.sprite.newAnimator()
    print("typeOf LSpriteAnimator = " .. tostring(anim:typeOf("LSpriteAnimator")))
end
```

---

#### `LSpriteAnimator:update`

Advance playback by delta time and dispatch callback events.

```lua
LSpriteAnimator:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

**Example**

```lua
do
    local anim = lurek.sprite.newAnimator({ idle = { row = 1, from = 1, to = 3, fps = 10, loop = true } })
    anim:play("idle")
    anim:update(0.11)
    local _, col = anim:currentFrame()
    print("frame after update = " .. tostring(col))
end
```

---

## LSpriteAtlas

### Type Fields

*No documented fields for this handle.*

### Type Methods

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
| string | Always `"[LSpriteAtlas](#lspriteatlas)"`. |

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
| `name` | string | Type name to check (e.g. `"[LSpriteAtlas](#lspriteatlas)"` or `"Object"`). |

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

## LSpriteSheet

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LSpriteSheet:drawToImage`

Renders the sprite sheet grid into an [LImage](render.md#limage) of the given size for debugging or previews.

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
| [LImage](render.md#limage) | A new image containing the rendered sprite sheet. |

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
    print("col 0 second frame = " .. col0[2].x .. "," .. col0[2].y)
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
    print("row 0 first frame = " .. row0[1].x .. "," .. row0[1].y)
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
| string | Always `"[LSpriteSheet](#lspritesheet)"`. |

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
| `name` | string | Type name to check (e.g. `"[LSpriteSheet](#lspritesheet)"` or `"Object"`). |

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
