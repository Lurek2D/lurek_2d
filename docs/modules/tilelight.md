# Tilelight

## Purpose

Tile-based environment lighting computed from a shared LTileField.

## Summary

- The `tilelight` module owns light propagation over tile cells. It reads blockers, transmission costs, topology, and sun occlusion from `tilefield`, then produces computed RGB/luma layers.
- It is environment-level data, not player-specific knowledge. Fog-of-war, action masks, and remembered exploration belong to `awareness`.
- It is tile-level gameplay/light data, not the screen/world render-light system. Render-facing lights and occluders remain in `lurek.light`.
- Point lights, ambient light, and global top light live on `LTileLightMap` so `LTileField` can remain a reusable source of gameplay data for many independent systems.

This module primarily collaborates with `tilefield`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## API Reference

- This page is the generated API reference for this module.

## Functions

### `lurek.tilelight.compute`

Creates and computes a tile light map for a shared tilefield or Lua tilefield provider table.

```lua
lurek.tilelight.compute(field, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `field` | [LTileField](tilefield.md#ltilefield)|table | Source tilefield handle or provider table. |
| `opts?` | table | Optional includePointLights, includeLineLights, includeSunLight, ambient, and time settings. |

**Returns**

| Type | Description |
|------|-------------|
| [LTileLightMap](#ltilelightmap) | Computed tile light map handle. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local made = lurek.tilelight.compute(field, { ambient = { r = 0.1, g = 0.1, b = 0.12 } })
        local _, _, _, luma = made:getLight(1, 1, 1)
        return luma
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

### `lurek.tilelight.new`

Creates a tile light map attached to a shared tilefield or copied from a Lua tilefield provider table.

```lua
lurek.tilelight.new(field)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `field` | [LTileField](tilefield.md#ltilefield)|table | Source tilefield handle or provider table. |

**Returns**

| Type | Description |
|------|-------------|
| [LTileLightMap](#ltilelightmap) | New tile light map handle. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local made = lurek.tilelight.new(field)
        return made:type()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LTileLightMap](#ltilelightmap)

## LTileLightMap

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTileLightMap:addAreaLight`

Adds a rectangular area light and returns its stable id.

```lua
LTileLightMap:addAreaLight(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | h,radius,intensity?,color?,flicker?,colorCycle?}`. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        return light:addAreaLight({ x = 2, y = 2, z = 1, width = 2, height = 2, radius = 2 })
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:addLineLight`

Adds a tile line light and returns its stable id.

```lua
LTileLightMap:addLineLight(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | `{x1,y1,z1?,x2,y2,z2?,radius,intensity?,color?,flicker?,colorCycle?}`. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        return light:addLineLight({ x1 = 1, y1 = 2, x2 = 6, y2 = 2, z1 = 1, z2 = 1, radius = 1.5 })
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:addPointLight`

Adds a point light and returns its stable id.

```lua
LTileLightMap:addPointLight(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | `{x, y, z?, radius, intensity?, color?, flicker?, colorCycle?}` light definition. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        return light:addPointLight({ x = 2, y = 2, z = 1, radius = 3, intensity = 1 })
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:addRectLight`

Alias for `addAreaLight`.

```lua
LTileLightMap:addRectLight(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | h,radius,intensity?,color?,flicker?,colorCycle?}`. |

**Returns**

| Type | Description |
|------|-------------|
| number | Stable rectangular light id. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        return light:addRectLight({ x = 2, y = 2, z = 1, w = 2, h = 2, radius = 2 })
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:clearAreaLights`

Removes all rectangular area lights currently stored on this tile light map.

```lua
LTileLightMap:clearAreaLights()
```

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:addAreaLight({ x = 2, y = 2, z = 1, width = 2, height = 2, radius = 2 })
        light:clearAreaLights()
        return light:type()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:clearLineLights`

Removes all line lights currently stored on this tile light map.

```lua
LTileLightMap:clearLineLights()
```

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:addLineLight({ x1 = 1, y1 = 2, x2 = 6, y2 = 2, z1 = 1, z2 = 1, radius = 1.5 })
        light:clearLineLights()
        return light:type()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:clearPointLights`

Removes all point lights currently stored on this tile light map.

```lua
LTileLightMap:clearPointLights()
```

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:addPointLight({ x = 2, y = 2, z = 1, radius = 2 })
        light:clearPointLights()
        return light:type()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:clearRectLights`

Alias for `clearAreaLights`.

```lua
LTileLightMap:clearRectLights()
```

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:addRectLight({ x = 2, y = 2, z = 1, w = 2, h = 2, radius = 2 })
        light:clearRectLights()
        return light:type()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:compute`

Computes tile light from ambient, point lights, line lights, and sun light.

```lua
LTileLightMap:compute(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | table | Optional includePointLights, includeLineLights, includeAreaLights, includeSunLight, ambient, and time settings. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:addPointLight({ x = 2, y = 2, z = 1, radius = 3, intensity = 1 })
        light:compute({ includePointLights = true, includeSunLight = false })
        return light:getLight(2, 2, 1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:exportLayer`

Exports one level of computed light as row-major `{r,g,b,luma}` tables.

```lua
LTileLightMap:exportLayer(z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| table | Row-major array of light color tables for the requested level. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:setAmbient({ r = 0.1, g = 0.1, b = 0.1 })
        light:compute({ includeSunLight = false })
        return #light:exportLayer(1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:exportVolume`

Exports all computed light levels as nested row-major tables.

```lua
LTileLightMap:exportVolume()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of exported light layers, one table per level. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:setAmbient({ r = 0.1, g = 0.1, b = 0.1 })
        light:compute({ includeSunLight = false })
        return #light:exportVolume()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:getLight`

Returns r, g, b, and luma for one cell.

```lua
LTileLightMap:getLight(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based cell x coordinate. |
| `y` | number | One-based cell y coordinate. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| number | Red; green; blue; and luma values for the cell. (value 1). |
| number | Red; green; blue; and luma values for the cell. (value 2). |
| number | Red; green; blue; and luma values for the cell. (value 3). |
| number | Red; green; blue; and luma values for the cell. (value 4). |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:setAmbient({ r = 0.1, g = 0.1, b = 0.1 })
        light:compute({ includeSunLight = false })
        return light:getLight(1, 1, 1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:getSize`

Returns light-map width, height, and level count.

```lua
LTileLightMap:getSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Width; height; and level count. (value 1). |
| number | Width; height; and level count. (value 2). |
| number | Width; height; and level count. (value 3). |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local w, h, levels = light:getSize()
        return w + h + levels
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:removeAreaLight`

Removes a rectangular area light by id and returns whether it existed.

```lua
LTileLightMap:removeAreaLight(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Stable area-light id returned by `addAreaLight`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when an area light was removed. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local id = light:addAreaLight({ x = 2, y = 2, z = 1, width = 2, height = 2, radius = 2 })
        return light:removeAreaLight(id)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:removeLineLight`

Removes a line light by id and returns whether it existed.

```lua
LTileLightMap:removeLineLight(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Stable line-light id returned by `addLineLight`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a line light was removed. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local id = light:addLineLight({ x1 = 1, y1 = 2, x2 = 6, y2 = 2, z1 = 1, z2 = 1, radius = 1.5 })
        return light:removeLineLight(id)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:removePointLight`

Removes a point light by id and returns whether it existed.

```lua
LTileLightMap:removePointLight(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Stable point light id returned by `addPointLight`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a point light was removed. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local id = light:addPointLight({ x = 1, y = 1, z = 1, radius = 2 })
        return light:removePointLight(id)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:removeRectLight`

Alias for `removeAreaLight`.

```lua
LTileLightMap:removeRectLight(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Stable rectangular light id returned by `addRectLight`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a rectangular light was removed. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local id = light:addRectLight({ x = 2, y = 2, z = 1, w = 2, h = 2, radius = 2 })
        return light:removeRectLight(id)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:setAmbient`

Sets ambient tile light stored on this light map.

```lua
LTileLightMap:setAmbient(color)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `color` | table | `{r,g,b}` ambient color. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:setAmbient({ r = 0.1, g = 0.2, b = 0.3 })
        light:compute({ includeSunLight = false })
        return light:getLight(1, 1, 1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:setGlobalLight`

Compatibility alias for top sun light parameters used during light computation.

```lua
LTileLightMap:setGlobalLight(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | `{intensity?, color?}` top-light settings. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:setGlobalLight({ intensity = 0.4, color = { r = 1, g = 0.85, b = 0.55 } })
        light:compute({ includeGlobalLight = true })
        return light:getLight(1, 1, 1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:setSunLight`

Sets tile sun light parameters used during light computation.

```lua
LTileLightMap:setSunLight(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | 'directional', intensity?, color?, direction?}`. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        light:setSunLight({ kind = "directional", intensity = 0.8, direction = { x = 1, y = 0 } })
        light:compute({ includeSunLight = true })
        return light:getLight(1, 1, 1)
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:type`

Returns the Lua-visible type name for this tile light map handle.

```lua
LTileLightMap:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LTileLightMap](#ltilelightmap)`. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        return light:type()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:typeOf`

Returns whether this handle matches a supported type name.

```lua
LTileLightMap:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True for `[LTileLightMap](#ltilelightmap)` or `LObject`. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        return light:typeOf("LTileLightMap")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:updateAreaLight`

Updates an existing rectangular area light by id.

```lua
LTileLightMap:updateAreaLight(id, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Stable area-light id returned by `addAreaLight`. |
| `opts` | table | Area-light fields to update. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local id = light:addAreaLight({ x = 2, y = 2, z = 1, width = 2, height = 2, radius = 2 })
        light:updateAreaLight(id, { x = 3, y = 3, w = 1, h = 1 })
        return id
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:updateLineLight`

Updates an existing tile line light by id.

```lua
LTileLightMap:updateLineLight(id, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Stable line light id returned by `addLineLight`. |
| `opts` | table | Partial line light update. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local id = light:addLineLight({ x1 = 1, y1 = 2, x2 = 6, y2 = 2, z1 = 1, z2 = 1, radius = 1.5 })
        light:updateLineLight(id, { x1 = 2, y1 = 2, x2 = 5, y2 = 2, radius = 2 })
        return id
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:updatePointLight`

Updates an existing point light by id.

```lua
LTileLightMap:updatePointLight(id, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Stable point light id returned by `addPointLight`. |
| `opts` | table | Partial light update table with x, y, z, radius, intensity, or color. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local id = light:addPointLight({ x = 1, y = 1, z = 1, radius = 2 })
        light:updatePointLight(id, { x = 3, y = 3, radius = 3 })
        return id
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileLightMap:updateRectLight`

Alias for `updateAreaLight`.

```lua
LTileLightMap:updateRectLight(id, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Stable rectangular light id returned by `addRectLight`. |
| `opts` | table | Rectangular-light fields to update. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 4, levels = 2 })
    local light = lurek.tilelight.new(field)
    local ok, value = pcall(function()
        local id = light:addRectLight({ x = 2, y = 2, z = 1, w = 2, h = 2, radius = 2 })
        light:updateRectLight(id, { x = 3, y = 3, w = 1, h = 1 })
        return id
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---
