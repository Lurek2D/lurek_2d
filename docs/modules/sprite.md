# Sprite

## Purpose

Manages 2D sprites, JSON atlases, animation sheets, nine-slice panels, and lit-sprite normal-map state.

## When To Use

- It unifies several common 2D visual patterns that often become fragmented in smaller engines: stand-alone images, atlas regions, sheet-based animation helpers, batched draws, and resizable textured panels all belong to the same family here.
- Atlas support matters because production assets are frequently packed, and a sprite system that does not understand regions and packing semantics quickly forces users into repetitive coordinate plumbing.
- Sheet-oriented helpers broaden the feature into frame-driven presentation while still staying lighter-weight than the more general animation module.

## Minimal Example

Example block: `lurek.sprite.newSheet`

```lua
do
    local sheet = lurek.sprite.newSheet(128, 64, 32, 32)
    local frames = sheet:getFrameCount()
    local cols, rows = sheet:getGridSize()
    local fw, fh = sheet:getFrameSize()
    sprite_log("newSheet type=" .. sheet:type() .. " frames=" .. frames .. " grid=" .. cols .. "x" .. rows .. " frame=" .. fw .. "x" .. fh)
end
```

## Common Patterns

- Start with `lurek.sprite.newAnimator` when exploring this module.
- Start with `lurek.sprite.newAtlasPacker` when exploring this module.
- Start with `lurek.sprite.newAtlasSheet` when exploring this module.
- Start with `lurek.sprite.newRPGMakerSheet` when exploring this module.
- Start with `lurek.sprite.newSheet` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- The `sprite` module is the engine's textured-2D surface for users who want single sprites, sheets, atlases, scalable panels, and batched instances to share one coherent runtime model.
- It unifies several common 2D visual patterns that often become fragmented in smaller engines: stand-alone images, atlas regions, sheet-based animation helpers, batched draws, and resizable textured panels all belong to the same family here.
- Atlas support matters because production assets are frequently packed, and a sprite system that does not understand regions and packing semantics quickly forces users into repetitive coordinate plumbing.
- Sheet-oriented helpers broaden the feature into frame-driven presentation while still staying lighter-weight than the more general `animation` module.
- Nine-slice and panel-oriented support matter because many projects mix game objects with UI-like scalable textured elements and still want one shared textured-visual layer.
- Batching support gives the module practical performance value while keeping atlas, panel, and instance behavior inside one shared textured-2D model.
- That shared model is especially useful when gameplay visuals and UI-adjacent textured elements overlap, because one subsystem can describe ordinary sprites, atlas regions, simple frame sequences, and scalable panels without forcing users to jump between unrelated feature surfaces.
- `image` owns raw pixel assets and `render` performs final drawing, while `sprite` owns the runtime model for textured 2D instances, atlases, sheets, and related presentation helpers.

This module primarily collaborates with `animation`, `color`, `image`, `math`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

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
    local animator = lurek.sprite.newAnimator(make_clips())
    local kind = animator:type()
    local clip = animator:currentClip()
    local playing = animator:isPlaying()
    sprite_log("newAnimator type=" .. kind .. " clip=" .. tostring(clip) .. " playing=" .. tostring(playing))
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
    local width, height = packer:getDimensions()
    local count = packer:regionCount()
    local kind = packer:type()
    sprite_log("newAtlasPacker type=" .. kind .. " size=" .. width .. "x" .. height .. " regions=" .. count)
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
    local atlas = lurek.sprite.parseAtlas(make_texturepacker_json())
    local sheet = lurek.sprite.newAtlasSheet(atlas, 64, 64)
    local count = sheet:getFrameCount()
    local first = sheet:getFrame(0)
    local fw, fh = sheet:getFrameSize()
    sprite_log("newAtlasSheet type=" .. sheet:type() .. " frames=" .. count .. " frame=" .. fw .. "x" .. fh .. " first=" .. first.x .. "," .. first.y)
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
    local sheet = lurek.sprite.newRPGMakerSheet(144, 192)
    local count = sheet:getFrameCount()
    local fw, fh = sheet:getFrameSize()
    local names = sheet:getGroupNames()
    sprite_log("newRPGMakerSheet frames=" .. count .. " frame=" .. fw .. "x" .. fh .. " first_group=" .. tostring(names[1]))
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
    local sheet = lurek.sprite.newSheet(128, 64, 32, 32)
    local frames = sheet:getFrameCount()
    local cols, rows = sheet:getGridSize()
    local fw, fh = sheet:getFrameSize()
    sprite_log("newSheet type=" .. sheet:type() .. " frames=" .. frames .. " grid=" .. cols .. "x" .. rows .. " frame=" .. fw .. "x" .. fh)
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
    local x, y = sprite:getPosition()
    local has_normal = sprite:hasNormalMap()
    local kind = sprite:type()
    sprite_log("newSprite type=" .. kind .. " pos=" .. x .. "," .. y .. " has_normal=" .. tostring(has_normal))
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
    local atlas = lurek.sprite.parseAsepriteAtlas(make_aseprite_json())
    local entry = atlas:getEntry("hero_walk_0001.png")
    local names = atlas:entryNames()
    local count = atlas:entryCount()
    sprite_log("parseAsepriteAtlas count=" .. count .. " first=" .. tostring(names[1]) .. " hero=" .. entry.w .. "x" .. entry.h)
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
    local atlas = lurek.sprite.parseAtlas(make_texturepacker_json())
    local entry = atlas:getEntry("hero_idle_0")
    local count = atlas:entryCount()
    local names = atlas:entryNames()
    sprite_log("parseAtlas count=" .. count .. " first=" .. tostring(names[1]) .. " hero=" .. entry.w .. "x" .. entry.h)
end
```

---

## Module Fields

*No module-level fields documented.*

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
    packer:pack("coin", 16, 16)
    local before = packer:regionCount()
    packer:clear()
    sprite_log("clear before=" .. before .. " after=" .. packer:regionCount() .. " hero_exists=" .. tostring(packer:getRegion("hero") ~= nil))
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
    local width, height = packer:getDimensions()
    local kind = packer:type()
    local count = packer:regionCount()
    sprite_log("getDimensions type=" .. kind .. " size=" .. width .. "x" .. height .. " regions=" .. count)
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
    local width, height = packer:getDimensions()
    sprite_log("getRegion hero=" .. region.name .. " at " .. region.x .. "," .. region.y .. " atlas=" .. width .. "x" .. height)
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
    local region = packer:getRegion("hero")
    local count = packer:regionCount()
    sprite_log("pack ok=" .. tostring(ok) .. " count=" .. count .. " hero=" .. region.x .. "," .. region.y .. "," .. region.w .. "x" .. region.h)
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
    packer:pack("coin", 16, 16)
    local count = packer:regionCount()
    sprite_log("regionCount count=" .. count .. " has_coin=" .. tostring(packer:getRegion("coin") ~= nil))
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
    packer:pack("panel", 24, 24)
    local ok = packer:setNineSlice("panel", 4, 4, 4, 4)
    local region = packer:getRegion("panel")
    sprite_log("setNineSlice ok=" .. tostring(ok) .. " region=" .. region.name .. " has_nine_slice=" .. tostring(region.nine_slice ~= nil))
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
    local width, height = packer:getDimensions()
    local kind = packer:type()
    local count = packer:regionCount()
    sprite_log("type kind=" .. kind .. " size=" .. width .. "x" .. height .. " regions=" .. count)
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
    local is_packer = packer:typeOf("LAtlasPacker")
    local is_object = packer:typeOf("LObject")
    local width, height = packer:getDimensions()
    sprite_log("typeOf packer=" .. tostring(is_packer) .. " object=" .. tostring(is_object) .. " size=" .. width .. "x" .. height)
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
    local before = sprite:hasNormalMap()
    sprite:clearNormalMap()
    sprite_log("clearNormalMap before=" .. tostring(before) .. " after=" .. tostring(sprite:hasNormalMap()))
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
    local intensity = sprite:getNormalIntensity()
    local x, y = sprite:getPosition()
    sprite_log("getNormalIntensity intensity=" .. tostring(intensity) .. " pos=" .. x .. "," .. y)
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
    local texture = sprite:getNormalMap()
    local intensity = sprite:getNormalIntensity()
    sprite_log("getNormalMap texture=" .. tostring(texture) .. " intensity=" .. tostring(intensity))
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
    local has_normal = sprite:hasNormalMap()
    local kind = sprite:type()
    sprite_log("getPosition type=" .. kind .. " pos=" .. x .. "," .. y .. " has_normal=" .. tostring(has_normal))
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
    local before = sprite:hasNormalMap()
    sprite:setNormalMap(3)
    local after = sprite:hasNormalMap()
    sprite_log("hasNormalMap before=" .. tostring(before) .. " after=" .. tostring(after))
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
    sprite:setNormalMap(11)
    sprite:setNormalIntensity(2.5)
    local intensity = sprite:getNormalIntensity()
    sprite_log("setNormalIntensity intensity=" .. tostring(intensity) .. " texture=" .. tostring(sprite:getNormalMap()))
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
    local texture = sprite:getNormalMap()
    local has_normal = sprite:hasNormalMap()
    sprite_log("setNormalMap texture=" .. tostring(texture) .. " has_normal=" .. tostring(has_normal))
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
    local kind = sprite:type()
    sprite_log("setPosition type=" .. kind .. " pos=" .. x .. "," .. y)
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
    local kind = sprite:type()
    local x, y = sprite:getPosition()
    local has_normal = sprite:hasNormalMap()
    sprite_log("sprite type=" .. kind .. " pos=" .. x .. "," .. y .. " has_normal=" .. tostring(has_normal))
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
    local is_sprite = sprite:typeOf("LSprite")
    local is_object = sprite:typeOf("LObject")
    local x, y = sprite:getPosition()
    sprite_log("sprite typeOf sprite=" .. tostring(is_sprite) .. " object=" .. tostring(is_object) .. " pos=" .. x .. "," .. y)
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
    local animator = lurek.sprite.newAnimator(make_clips())
    animator:addClip("run", { row = 3, from = 1, to = 4, fps = 12, loop = true })
    animator:play("run")
    local row, col = animator:currentFrame()
    sprite_log("addClip clip=" .. tostring(animator:currentClip()) .. " frame=" .. row .. "," .. col)
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
    local animator = lurek.sprite.newAnimator(make_clips())
    animator:play("jump")
    local clip_duration = animator:clipDuration()
    local frame_duration = animator:frameDuration()
    sprite_log("clipDuration clip=" .. tostring(clip_duration) .. " frame=" .. tostring(frame_duration))
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
    local animator = lurek.sprite.newAnimator(make_clips())
    local before = animator:currentClip()
    animator:play("idle")
    local after = animator:currentClip()
    sprite_log("currentClip before=" .. tostring(before) .. " after=" .. tostring(after))
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
    local animator = lurek.sprite.newAnimator(make_clips())
    animator:play("idle")
    local row1, col1 = animator:currentFrame()
    animator:update(0.11)
    local row2, col2 = animator:currentFrame()
    sprite_log("currentFrame before=" .. row1 .. "," .. col1 .. " after=" .. row2 .. "," .. col2)
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
    local animator = lurek.sprite.newAnimator(make_clips())
    animator:play("idle")
    local frame_duration = animator:frameDuration()
    local clip_duration = animator:clipDuration()
    sprite_log("frameDuration frame=" .. tostring(frame_duration) .. " clip=" .. tostring(clip_duration))
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
    local animator = lurek.sprite.newAnimator(make_clips())
    local before = animator:isPlaying()
    animator:play("idle")
    local after = animator:isPlaying()
    sprite_log("isPlaying before=" .. tostring(before) .. " after=" .. tostring(after))
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
    local animator = lurek.sprite.newAnimator(make_clips())
    local ended = 0
    animator:onEnd(function() ended = ended + 1 end)
    animator:play("jump")
    animator:update(1.0)
    sprite_log("onEnd callbacks=" .. ended .. " clip=" .. tostring(animator:currentClip()))
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
    local animator = lurek.sprite.newAnimator(make_clips())
    local received = 0
    animator:onFrame(function() received = received + 1 end)
    animator:play("idle")
    animator:update(0.21)
    sprite_log("onFrame callbacks=" .. received .. " clip=" .. tostring(animator:currentClip()))
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
    local animator = lurek.sprite.newAnimator(make_clips())
    local loops = 0
    animator:onLoop(function() loops = loops + 1 end)
    animator:play("idle")
    animator:update(0.31)
    sprite_log("onLoop callbacks=" .. loops .. " clip=" .. tostring(animator:currentClip()))
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
    local animator = lurek.sprite.newAnimator(make_clips())
    animator:play("idle")
    animator:pause()
    local clip = animator:currentClip()
    local playing = animator:isPlaying()
    sprite_log("pause clip=" .. tostring(clip) .. " playing=" .. tostring(playing))
end
```

---

#### `LSpriteAnimator:play`

Plays or restarts a named animation clip.

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
    local animator = lurek.sprite.newAnimator(make_clips())
    animator:play("idle")
    local clip = animator:currentClip()
    local row, col = animator:currentFrame()
    sprite_log("play clip=" .. tostring(clip) .. " frame=" .. row .. "," .. col)
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
    local animator = lurek.sprite.newAnimator(make_clips())
    animator:play("idle")
    animator:pause()
    animator:resume()
    sprite_log("resume clip=" .. tostring(animator:currentClip()) .. " playing=" .. tostring(animator:isPlaying()))
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
    local animator = lurek.sprite.newAnimator(make_clips())
    animator:play("idle")
    animator:update(0.2)
    animator:stop()
    local row, col = animator:currentFrame()
    sprite_log("stop frame_reset=" .. row .. "," .. col .. " playing=" .. tostring(animator:isPlaying()))
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
    local animator = lurek.sprite.newAnimator(make_clips())
    local kind = animator:type()
    local clip = animator:currentClip()
    local playing = animator:isPlaying()
    sprite_log("animator type=" .. kind .. " clip=" .. tostring(clip) .. " playing=" .. tostring(playing))
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
    local animator = lurek.sprite.newAnimator(make_clips())
    local is_animator = animator:typeOf("LSpriteAnimator")
    local is_object = animator:typeOf("LObject")
    local kind = animator:type()
    sprite_log("animator typeOf animator=" .. tostring(is_animator) .. " object=" .. tostring(is_object) .. " type=" .. kind)
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
    local animator = lurek.sprite.newAnimator(make_clips())
    animator:play("idle")
    animator:update(0.11)
    local row, col = animator:currentFrame()
    local frame_duration = animator:frameDuration()
    sprite_log("update frame=" .. row .. "," .. col .. " frame_duration=" .. tostring(frame_duration))
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
    local atlas = lurek.sprite.parseAsepriteAtlas(make_aseprite_json())
    local count = atlas:entryCount()
    local names = atlas:entryNames()
    local entry = atlas:getEntry(names[1])
    sprite_log("entryCount count=" .. count .. " first=" .. tostring(names[1]) .. " size=" .. entry.w .. "x" .. entry.h)
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
    local atlas = lurek.sprite.parseAsepriteAtlas(make_aseprite_json())
    local names = atlas:entryNames()
    local count = atlas:entryCount()
    local second = names[2] or "none"
    sprite_log("entryNames count=" .. count .. " first=" .. tostring(names[1]) .. " second=" .. tostring(second))
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
    local atlas = lurek.sprite.parseAtlas(make_texturepacker_json())
    local first = atlas:getByIndex(1)
    local second = atlas:getByIndex(2)
    local count = atlas:entryCount()
    sprite_log("getByIndex count=" .. count .. " first=" .. first.name .. " second=" .. second.name)
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
    local atlas = lurek.sprite.parseAtlas(make_texturepacker_json())
    local entry = atlas:getEntry("hero_idle_1")
    local count = atlas:entryCount()
    local names = atlas:entryNames()
    sprite_log("getEntry names=" .. #names .. " count=" .. count .. " hero_idle_1=" .. entry.x .. "," .. entry.y .. "," .. entry.w .. "x" .. entry.h)
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
    local atlas = lurek.sprite.parseAtlas(make_texturepacker_json())
    local flipped = atlas:getFlipped("arrow_right", true, false)
    local base = atlas:getEntry("arrow_right")
    local same_size = flipped.w == base.w and flipped.h == base.h
    sprite_log("getFlipped flip_x=" .. tostring(flipped.flip_x) .. " flip_y=" .. tostring(flipped.flip_y) .. " same_size=" .. tostring(same_size))
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
    local atlas = lurek.sprite.parseAsepriteAtlas(make_aseprite_json())
    local kind = atlas:type()
    local count = atlas:entryCount()
    local names = atlas:entryNames()
    sprite_log("atlas type=" .. kind .. " count=" .. count .. " first=" .. tostring(names[1]))
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
    local atlas = lurek.sprite.parseAsepriteAtlas(make_aseprite_json())
    local is_atlas = atlas:typeOf("LSpriteAtlas")
    local is_object = atlas:typeOf("LObject")
    local count = atlas:entryCount()
    sprite_log("atlas typeOf atlas=" .. tostring(is_atlas) .. " object=" .. tostring(is_object) .. " count=" .. count)
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
    local sheet = lurek.sprite.newSheet(64, 64, 16, 16)
    sheet:nameGroup("idle", 0, 2)
    local image = sheet:drawToImage(64, 64)
    local width = image:getWidth()
    local height = image:getHeight()
    sprite_log("drawToImage preview=" .. width .. "x" .. height .. " groups=" .. #sheet:getGroupNames())
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
    local sheet = lurek.sprite.newSheet(64, 64, 16, 16)
    local column = sheet:getColumn(1)
    local first = column[1]
    local last = column[#column]
    sprite_log("getColumn size=" .. #column .. " first=" .. first.x .. "," .. first.y .. " last=" .. last.x .. "," .. last.y)
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
    local sheet = lurek.sprite.newSheet(64, 64, 16, 16)
    local first = sheet:getFrame(0)
    local second = sheet:getFrame(1)
    local count = sheet:getFrameCount()
    sprite_log("getFrame count=" .. count .. " first=" .. first.x .. "," .. first.y .. " second=" .. second.x .. "," .. second.y)
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
    local count = sheet:getFrameCount()
    local cols, rows = sheet:getGridSize()
    local fw, fh = sheet:getFrameSize()
    sprite_log("getFrameCount count=" .. count .. " grid=" .. cols .. "x" .. rows .. " frame=" .. fw .. "x" .. fh)
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
    local cols, rows = sheet:getGridSize()
    local count = sheet:getFrameCount()
    sprite_log("getFrameSize frame=" .. fw .. "x" .. fh .. " grid=" .. cols .. "x" .. rows .. " count=" .. count)
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
    local cols, rows = sheet:getGridSize()
    local count = sheet:getFrameCount()
    local fw, fh = sheet:getFrameSize()
    sprite_log("getGridSize grid=" .. cols .. "x" .. rows .. " count=" .. count .. " frame=" .. fw .. "x" .. fh)
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
    local sheet = lurek.sprite.newSheet(64, 64, 16, 16)
    sheet:nameGroup("idle", 0, 2)
    sheet:nameGroup("walk", 2, 4)
    local walk = sheet:getGroupFrames("walk")
    sprite_log("getGroupFrames walk_size=" .. #walk .. " first=" .. walk[1].x .. "," .. walk[1].y .. " last=" .. walk[#walk].x .. "," .. walk[#walk].y)
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
    local sheet = lurek.sprite.newRPGMakerSheet(144, 192)
    local names = sheet:getGroupNames()
    local count = sheet:getFrameCount()
    local cols, rows = sheet:getGridSize()
    sprite_log("getGroupNames count=" .. #names .. " first=" .. tostring(names[1]) .. " frames=" .. count .. " grid=" .. cols .. "x" .. rows)
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
    local sheet = lurek.sprite.newSheet(64, 64, 16, 16)
    local row = sheet:getRow(0)
    local first = row[1]
    local last = row[#row]
    sprite_log("getRow size=" .. #row .. " first=" .. first.x .. "," .. first.y .. " last=" .. last.x .. "," .. last.y)
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
    local sheet = lurek.sprite.newSheet(64, 64, 16, 16)
    sheet:nameGroup("run", 0, 4)
    local names = sheet:getGroupNames()
    local frames = sheet:getGroupFrames("run")
    sprite_log("nameGroup groups=" .. #names .. " run_frames=" .. #frames .. " first_group=" .. tostring(names[1]))
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
    local kind = sheet:type()
    local count = sheet:getFrameCount()
    local cols, rows = sheet:getGridSize()
    sprite_log("sheet type=" .. kind .. " frames=" .. count .. " grid=" .. cols .. "x" .. rows)
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
    local is_sheet = sheet:typeOf("LSpriteSheet")
    local is_object = sheet:typeOf("LObject")
    local count = sheet:getFrameCount()
    sprite_log("sheet typeOf sheet=" .. tostring(is_sheet) .. " object=" .. tostring(is_object) .. " frames=" .. count)
end
```

---
