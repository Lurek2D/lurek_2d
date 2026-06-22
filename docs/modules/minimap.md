# Minimap

## Purpose

Runs grid-based HUD minimaps with fog-of-war, custom markers, raycaster overlays, and camera tracking.

## When To Use

- Core minimap state, render helpers, and adapters from province or raycaster data work together so the same module can represent several kinds of world information in one small map display.
- Fog, owner colors, overlays, tracked objects, and camera-aware view markers matter because a minimap is not only a tiny texture: it is a summarized navigation and awareness tool for the player.
- The module is useful wherever a project needs strategic orientation, local awareness, or debug-style map inspection without switching to a full map screen.

## Minimal Example

Example block: `lurek.minimap.newMinimap`

```lua
do
    local mm = lurek.minimap.newMinimap(64, 64, 200, 200)
    mm:setCenter(32, 24)
    mm:setZoom(1.25)
    local dw, dh = mm:getDisplaySize()
    minimap_log("command view " .. mm:getGridWidth() .. "x" .. mm:getGridHeight() .. " -> " .. dw .. "x" .. dh)
end
```

## Common Patterns

- Start with `lurek.minimap.newMinimap` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- The `minimap` module is the HUD-scale map surface for users who want world state, fog, markers, and view tracking to become a compact readable overlay.
- Core minimap state, render helpers, and adapters from province or raycaster data work together so the same module can represent several kinds of world information in one small map display.
- Fog, owner colors, overlays, tracked objects, and camera-aware view markers matter because a minimap is not only a tiny texture: it is a summarized navigation and awareness tool for the player.
- The module is useful wherever a project needs strategic orientation, local awareness, or debug-style map inspection without switching to a full map screen.
- Marker and layer support are especially important because a minimap often needs to combine several categories of information at once: player position, objectives, faction territory, danger, or discovered landmarks.
- In tool and strategy-heavy contexts, the minimap can also become a compact interaction surface or diagnostic lens rather than only a passive HUD element, which is why adapters and styling control matter.
- Rotation, zoom, clipping, and icon policy matter too, because a compact map has to stay legible while world state and camera framing keep changing.
- A minimap is therefore not only a tiny render, but a compact policy layer for world awareness.
- Read it as the owner of compact map presentation.

This module primarily collaborates with `camera`, `image`, `province`, `raycaster`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.minimap.newMinimap`

Creates a minimap with grid dimensions and optional display size.

```lua
lurek.minimap.newMinimap(grid_w, grid_h, display_w, display_h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `grid_w` | number | Grid width in cells. |
| `grid_h` | number | Grid height in cells. |
| `display_w?` | number | Display width in pixels, defaults to 200. |
| `display_h?` | number | Display height in pixels, defaults to 200. |

**Returns**

| Type | Description |
|------|-------------|
| [LMinimap](#lminimap) | New minimap handle. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(64, 64, 200, 200)
    mm:setCenter(32, 24)
    mm:setZoom(1.25)
    local dw, dh = mm:getDisplaySize()
    minimap_log("command view " .. mm:getGridWidth() .. "x" .. mm:getGridHeight() .. " -> " .. dw .. "x" .. dh)
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LMinimap](#lminimap)

## LMinimap

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LMinimap:addMarker`

Adds a world-space marker and returns its unique id.

```lua
LMinimap:addMarker(x, y, desc, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Marker x coordinate. |
| `y` | number | Marker y coordinate. |
| `desc?` | string | Marker description. |
| `r?` | number | Red channel override, defaults to 1.0. |
| `g?` | number | Green channel override, defaults to 0.0. |
| `b?` | number | Blue channel override, defaults to 0.0. |
| `a?` | number | Alpha channel override, defaults to 1.0. |

**Returns**

| Type | Description |
|------|-------------|
| number | Marker id. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(32, 32)
    local id1 = mm:addMarker(10, 10, "Base", 0, 1, 0, 1)

    mm:addMarker(20, 5, "Enemy", 1, 0, 0, 1)
    example_print_log("marker id = " .. id1)
    example_print_log("marker count = " .. mm:getMarkerCount())
end
```

---

#### `LMinimap:addObjectType`

Adds an object type and returns its one-based index.

```lua
LMinimap:addObjectType(name, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Object type name. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a?` | number | Alpha channel, defaults to 1.0. |

**Returns**

| Type | Description |
|------|-------------|
| number | One-based object type index. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local unit = mm:addObjectType("unit", 0, 0, 1, 1)
    local building = mm:addObjectType("building", 1, 1, 0, 0.8)

    example_print_log("types = " .. mm:getObjectTypeCount())
    example_print_log("unit = " .. unit .. " building = " .. building)
end
```

---

#### `LMinimap:addPing`

Adds a timed ping effect at a minimap world position.

```lua
LMinimap:addPing(x, y, duration, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | World x coordinate of the ping. |
| `y` | number | World y coordinate of the ping. |
| `duration` | number | Duration in seconds before the ping fades out. |
| `r?` | number | Red channel, defaults to 1.0. |
| `g?` | number | Green channel, defaults to 1.0. |
| `b?` | number | Blue channel, defaults to 0.0. |
| `a?` | number | Alpha channel, defaults to 1.0. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:addPing(8, 8, 2.0, 1, 1, 0, 1)
    mm:addPing(4, 4, 1.0)
    example_print_log("pings before = " .. mm:getPingCount())
    mm:update(2.5)
    example_print_log("pings after = " .. mm:getPingCount())
end
```

---

#### `LMinimap:clearMarkerAnimation`

Clears the animation assigned to a marker by id.

```lua
LMinimap:clearMarkerAnimation(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Marker id. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local id = mm:addMarker(8, 8, "Blink")

    mm:setMarkerAnimation(id, "blink", 4.0)
    mm:clearMarkerAnimation(id)
    mm:update(0.25)
    example_print_log("marker exists = " .. tostring(mm:hasMarker(id)))
end
```

---

#### `LMinimap:clearMarkerTexture`

Clears image texture from a marker.

```lua
LMinimap:clearMarkerTexture(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Marker id. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(32, 32, 256, 256)
    local id = mm:addMarker(16, 16, "Hero")
    local img = lurek.render.newImage("content/examples/assets/images/sample_icon.png")

    mm:setMarkerTexture(id, img, 24, 24)
    mm:clearMarkerTexture(id)
    example_print_log("marker exists = " .. tostring(mm:hasMarker(id)))
end
```

---

#### `LMinimap:clearObjectTypeTexture`

Clears image texture for an object type.

```lua
LMinimap:clearObjectTypeTexture(type_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_idx` | number | One-based object type index. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(32, 32, 256, 256)
    local type_idx = mm:addObjectType("unit", 0, 1, 0, 1)
    local img = lurek.render.newImage("content/examples/assets/images/sample_icon.png")

    mm:setObjectTypeTexture(type_idx, img, 16, 16)
    mm:clearObjectTypeTexture(type_idx)
    example_print_log("object types = " .. mm:getObjectTypeCount())
end
```

---

#### `LMinimap:clearObjects`

Clears all objects from the minimap.

```lua
LMinimap:clearObjects()
```

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local npc = mm:addObjectType("npc", 0, 1, 0, 1)

    mm:setObject(1, 4, 4, npc, 0)
    mm:setObject(2, 8, 8, npc, 1)
    example_print_log("before = " .. mm:getObjectCount())
    mm:clearObjects()
    example_print_log("after = " .. mm:getObjectCount())
end
```

---

#### `LMinimap:clearOverlay`

Clears all minimap overlay shapes.

```lua
LMinimap:clearOverlay()
```

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:drawLine(0, 0, 15, 15, { 255, 255, 255, 255 })
    mm:drawRect(2, 2, 4, 4, { 0, 255, 0, 200 })
    example_print_log("before = " .. mm:getOverlayShapeCount())
    mm:clearOverlay()
    example_print_log("after = " .. mm:getOverlayShapeCount())
end
```

---

#### `LMinimap:clearPath`

Clears one path by id or all paths when no id is provided.

```lua
LMinimap:clearPath(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id?` | number | Path id to clear. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local pts = {
        { 2, 2 },
        { 4, 4 },
        { 6, 2 },
    }
    local pid = mm:showPath(pts, { 255, 255, 255, 255 })

    example_print_log("before = " .. mm:getPathCount())
    mm:clearPath(pid)
    example_print_log("after = " .. mm:getPathCount())
end
```

---

#### `LMinimap:clearViewportRect`

Clears the minimap viewport rectangle overlay.

```lua
LMinimap:clearViewportRect()
```

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setViewportRect(4, 4, 12, 12)
    mm:clearViewportRect()
    local x = select(1, mm:getViewportRect())
    example_print_log("viewport cleared = " .. tostring(x == nil))
end
```

---

#### `LMinimap:drawLine`

Adds an overlay line between two world-space points.

```lua
LMinimap:drawLine(x1, y1, x2, y2, color_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x1` | number | Start x coordinate. |
| `y1` | number | Start y coordinate. |
| `x2` | number | End x coordinate. |
| `y2` | number | End y coordinate. |
| `color_tbl` | table | RGBA byte color table. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setCenter(8, 8)
    mm:drawLine(0, 0, 15, 15, { 255, 255, 255, 255 })
    local shapes = mm:getOverlayShapeCount()
    local sx, sy = mm:gridToScreen(15, 15, 0, 0)
    minimap_log("retreat route overlay count " .. shapes .. " ends near " .. sx .. "," .. sy)
end
```

---

#### `LMinimap:drawRect`

Adds an overlay rectangle at a world-space position.

```lua
LMinimap:drawRect(x, y, w, h, color_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Rectangle x coordinate. |
| `y` | number | Rectangle y coordinate. |
| `w` | number | Rectangle width. |
| `h` | number | Rectangle height. |
| `color_tbl` | table | RGBA byte color table. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setCenter(8, 8)
    mm:drawRect(2, 2, 4, 4, { 0, 255, 0, 200 })
    local shapes = mm:getOverlayShapeCount()
    local hover = mm:getHoverInfo(20, 20, 0, 0)
    minimap_log("safe zone overlay count " .. shapes .. " hover " .. tostring(hover))
end
```

---

#### `LMinimap:drawToImage`

Draws the minimap into image data at a pixel size.

```lua
LMinimap:drawToImage(pixel_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pixel_size` | number | Pixel size scale. |

**Returns**

| Type | Description |
|------|-------------|
| [LImageData](render.md#limagedata) | Image data containing the rendered minimap. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setTerrainColor(0, 0.5, 0.5, 0.5, 1.0)
    local img = mm:drawToImage(2)

    example_print_log("image type = " .. img:type())
    example_print_log("image size = " .. img:getWidth() .. "x" .. img:getHeight())
end
```

---

#### `LMinimap:getCellCount`

Returns the total number of grid cells.

```lua
LMinimap:getCellCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Cell count. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(10, 20)
    mm:setDisplaySize(200, 120)
    mm:setCenter(5, 10)
    local cells = mm:getCellCount()
    local gw, gh = mm:getGridSize()
    minimap_log("grid " .. gw .. "x" .. gh .. " exposes " .. cells .. " cells")
end
```

---

#### `LMinimap:getCenter`

Returns the current minimap world-space center position.

```lua
LMinimap:getCenter()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Center x coordinate. |
| number | Center y coordinate. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setViewportRect(6, 14, 8, 8)
    mm:setCenter(10, 20)
    local cx, cy = mm:getCenter()
    local vw, vh = select(3, mm:getViewportRect()), select(4, mm:getViewportRect())
    minimap_log("tracked center " .. cx .. "," .. cy .. " with viewport " .. tostring(vw) .. "x" .. tostring(vh))
end
```

---

#### `LMinimap:getCenterX`

Returns minimap world center x coordinate.

```lua
LMinimap:getCenterX()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Center x coordinate. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setCenter(14, 9)
    mm:setZoom(2.0)
    local cx = mm:getCenterX()
    local sx = select(1, mm:gridToScreen(cx, mm:getCenterY(), 0, 0))
    minimap_log("center x " .. cx .. " projects to " .. sx)
end
```

---

#### `LMinimap:getCenterY`

Returns minimap world center y coordinate.

```lua
LMinimap:getCenterY()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Center y coordinate. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setCenter(14, 9)
    mm:setZoom(2.0)
    local cy = mm:getCenterY()
    local sy = select(2, mm:gridToScreen(mm:getCenterX(), cy, 0, 0))
    minimap_log("center y " .. cy .. " projects to " .. sy)
end
```

---

#### `LMinimap:getColorMode`

Returns the current minimap color mode.

```lua
LMinimap:getColorMode()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Color mode name. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setTerrainColor(1, 0.1, 0.5, 0.1, 1.0)
    mm:setColorMode("terrain")
    local mode = mm:getColorMode()
    local cells = mm:getCellCount()
    minimap_log("terrain palette active across " .. cells .. " cells: " .. mode)
end
```

---

#### `LMinimap:getDisplayHeight`

Returns the minimap display height.

```lua
LMinimap:getDisplayHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Display height in pixels. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16, 100, 100)
    mm:setDisplaySize(300, 250)
    mm:setViewportRect(2, 2, 6, 6)
    local height = mm:getDisplayHeight()
    local viewport_h = select(4, mm:getViewportRect())
    minimap_log("display height " .. height .. " tracks viewport height " .. tostring(viewport_h))
end
```

---

#### `LMinimap:getDisplaySize`

Returns the minimap display width and height in pixels.

```lua
LMinimap:getDisplaySize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Display width in pixels. |
| number | Display height in pixels. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(32, 32, 200, 200)
    mm:setDisplaySize(240, 180)
    mm:setViewportRect(4, 4, 10, 10)
    local dw, dh = mm:getDisplaySize()
    local visible = mm:isViewportVisible()
    minimap_log("display size = " .. dw .. "x" .. dh .. " viewport visible " .. tostring(visible))
end
```

---

#### `LMinimap:getDisplayWidth`

Returns the minimap display width.

```lua
LMinimap:getDisplayWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Display width in pixels. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16, 100, 100)
    mm:setDisplaySize(300, 250)
    mm:setViewportRect(2, 2, 6, 6)
    local width = mm:getDisplayWidth()
    local viewport_w = select(3, mm:getViewportRect())
    minimap_log("display width " .. width .. " tracks viewport width " .. tostring(viewport_w))
end
```

---

#### `LMinimap:getFogColor`

Returns the current RGBA fog overlay color.

```lua
LMinimap:getFogColor()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Red channel. |
| number | Green channel. |
| number | Blue channel. |
| number | Alpha channel. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setFogEnabled(true)
    mm:setFogColor(0.1, 0.2, 0.3, 0.6)
    local r, g, b, a = mm:getFogColor()
    mm:setFogLevel(5, 5, 1)
    minimap_log("exploration fog tint = " .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LMinimap:getFogLevel`

Returns fog level for a one-based grid cell.

```lua
LMinimap:getFogLevel(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based grid x coordinate. |
| `y` | number | One-based grid y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Fog level byte. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setFogEnabled(true)
    mm:setTerrain(2, 2, 1)
    mm:setFogLevel(2, 2, 1)
    local fog = mm:getFogLevel(2, 2)
    local terrain = mm:getTerrain(2, 2)
    minimap_log("tile 2,2 terrain " .. terrain .. " has fog " .. fog)
end
```

---

#### `LMinimap:getGridHeight`

Returns the height of the minimap grid in cells.

```lua
LMinimap:getGridHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Grid height in cells. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(10, 20)
    mm:setDisplaySize(160, 160)
    mm:setCenter(5, 10)
    local height = mm:getGridHeight()
    local cells = mm:getCellCount()
    minimap_log("grid height " .. height .. " within " .. cells .. " total cells")
end
```

---

#### `LMinimap:getGridSize`

Returns the minimap grid width and height in cells.

```lua
LMinimap:getGridSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Grid width in cells. |
| number | Grid height in cells. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(32, 32, 200, 200)
    mm:setCenter(16, 16)
    mm:setZoom(1.1)
    local gw, gh = mm:getGridSize()
    local cells = mm:getCellCount()
    minimap_log("grid size = " .. gw .. "x" .. gh .. " cells " .. cells)
end
```

---

#### `LMinimap:getGridWidth`

Returns the width of the minimap grid in cells.

```lua
LMinimap:getGridWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Grid width in cells. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(10, 20)
    mm:setDisplaySize(160, 160)
    mm:setCenter(5, 10)
    local width = mm:getGridWidth()
    local cells = mm:getCellCount()
    minimap_log("grid width " .. width .. " within " .. cells .. " total cells")
end
```

---

#### `LMinimap:getHoverInfo`

Returns hover text for a screen position when available.

```lua
LMinimap:getHoverInfo(sx, sy, mx, my)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | Screen x coordinate. |
| `sy` | number | Screen y coordinate. |
| `mx` | number | Minimap x position. |
| `my` | number | Minimap y position. |

**Returns**

| Type | Description |
|------|-------------|
| string | Hover info text, or nil when unavailable. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(8, 8, 80, 80)
    mm:setTileDescription(1, "Plains")
    mm:setTerrain(1, 1, 1)
    local sx, sy = mm:gridToScreen(1, 1, 0, 0)
    local hover = mm:getHoverInfo(sx, sy, 0, 0)
    minimap_log("hover at " .. sx .. "," .. sy .. " => " .. tostring(hover))
end
```

---

#### `LMinimap:getLayer`

Returns the active minimap display layer index.

```lua
LMinimap:getLayer()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Layer index. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(4, 4)
    mm:setLayerData(2, { 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0, 3, 3, 3, 3 })
    mm:setLayer(2)
    local layer_data = mm:getLayerData(2)
    local layer = mm:getLayer()
    minimap_log("active terrain layer " .. layer .. " sample " .. tostring(layer_data and layer_data[1]))
end
```

---

#### `LMinimap:getLayerCount`

Returns the number of minimap layers.

```lua
LMinimap:getLayerCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Layer count. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(4, 4)
    local data = {}

    for i = 1, 16 do
        data[i] = i % 4
    end

    mm:setLayerData(1, data)
    example_print_log("layer count = " .. mm:getLayerCount())
end
```

---

#### `LMinimap:getLayerData`

Returns raw cell data for a minimap layer.

```lua
LMinimap:getLayerData(layer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of cell bytes, or nil when missing. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(4, 4)
    local data = {}

    for i = 1, 16 do
        data[i] = i % 5
    end

    mm:setLayerData(1, data)
    local out = mm:getLayerData(1)
    example_print_log("layer 1 size = " .. #(out or {}))
    example_print_log("layer 1 last = " .. (out and out[#out] or -1))
end
```

---

#### `LMinimap:getMarkerCount`

Returns the total number of minimap markers.

```lua
LMinimap:getMarkerCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Marker count. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:addMarker(10, 10, "Base")
    local enemy_id = mm:addMarker(20, 5, "Enemy")
    local count = mm:getMarkerCount()
    local enemy = mm:getMarkerDescription(enemy_id)
    minimap_log("markers tracked = " .. count .. " including " .. tostring(enemy))
end
```

---

#### `LMinimap:getMarkerDescription`

Returns a marker description by id.

```lua
LMinimap:getMarkerDescription(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Marker id. |

**Returns**

| Type | Description |
|------|-------------|
| string | Marker description, or nil when missing. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(32, 32)
    local id = mm:addMarker(10, 10, "Quest")
    mm:setMarkerAnimation(id, "pulse", 1.5)
    local desc = mm:getMarkerDescription(id)
    local count = mm:getMarkerCount()
    minimap_log("marker " .. id .. " => " .. tostring(desc) .. " of " .. count)
end
```

---

#### `LMinimap:getObjectCount`

Returns the number of objects on the minimap.

```lua
LMinimap:getObjectCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Object count. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local npc = mm:addObjectType("npc", 0, 1, 0, 1)

    mm:setObject(1, 4, 4, npc, 0)
    mm:setObject(2, 8, 8, npc, 1)
    example_print_log("object count = " .. mm:getObjectCount())
end
```

---

#### `LMinimap:getObjectTypeCount`

Returns the number of object types.

```lua
LMinimap:getObjectTypeCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Object type count. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local scout = mm:addObjectType("unit", 0, 0, 1, 1)
    local base = mm:addObjectType("building", 1, 1, 0, 0.8)
    mm:setObject(1, 5, 5, scout, 1)
    local count = mm:getObjectTypeCount()
    minimap_log("registered types " .. scout .. "," .. base .. " => " .. count)
end
```

---

#### `LMinimap:getOverlayShapeCount`

Returns the number of overlay shapes.

```lua
LMinimap:getOverlayShapeCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Overlay shape count. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:drawLine(0, 0, 15, 15, { 255, 255, 255, 255 })
    mm:drawRect(2, 2, 4, 4, { 0, 255, 0, 200 })
    local shapes = mm:getOverlayShapeCount()
    local dw, dh = mm:getDisplaySize()
    minimap_log("overlay shapes = " .. shapes .. " on " .. dw .. "x" .. dh)
end
```

---

#### `LMinimap:getOwnerColor`

Returns the current RGBA color for an owner id.

```lua
LMinimap:getOwnerColor(owner)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `owner` | number | Owner id. |

**Returns**

| Type | Description |
|------|-------------|
| number | Red channel. |
| number | Green channel. |
| number | Blue channel. |
| number | Alpha channel. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local base = mm:addObjectType("base", 0.6, 0.6, 0.6, 1.0)
    mm:setOwnerColor(2, 1, 0, 0, 1)
    mm:setObject(2, 12, 4, base, 2)
    local r, g, b, a = mm:getOwnerColor(2)
    minimap_log("enemy owner tint = " .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LMinimap:getPathCount`

Returns the number of active path overlays.

```lua
LMinimap:getPathCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Path count. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local pts = {
        { 1, 1 },
        { 3, 3 },
        { 5, 2 },
    }

    mm:showPath(pts, { 0, 255, 0, 255 })
    example_print_log("path count = " .. mm:getPathCount())
end
```

---

#### `LMinimap:getPingCount`

Returns the number of active pings.

```lua
LMinimap:getPingCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Ping count. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:addPing(8, 8, 2.0)
    mm:update(0.25)
    mm:addPing(4, 4, 1.0)
    local count = mm:getPingCount()
    minimap_log("active alert pings = " .. count)
end
```

---

#### `LMinimap:getTerrain`

Returns terrain type for a one-based grid cell.

```lua
LMinimap:getTerrain(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based grid x coordinate. |
| `y` | number | One-based grid y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Terrain type id. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setTileDescription(7, "Mountain")
    mm:setTerrain(2, 3, 7)
    local terrain = mm:getTerrain(2, 3)
    local desc = mm:getTileDescription(terrain)
    minimap_log("scouted tile 2,3 = " .. tostring(desc))
end
```

---

#### `LMinimap:getTerrainColor`

Returns RGBA color for a terrain type.

```lua
LMinimap:getTerrainColor(terrain_type)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terrain_type` | number | Terrain type id. |

**Returns**

| Type | Description |
|------|-------------|
| number | Red channel. |
| number | Green channel. |
| number | Blue channel. |
| number | Alpha channel. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setTerrain(8, 2, 3)
    mm:setTerrainColor(3, 0.7, 0.4, 0.2, 1.0)
    local r, g, b, a = mm:getTerrainColor(3)
    local terrain = mm:getTerrain(8, 2)
    minimap_log("desert terrain " .. terrain .. " uses " .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LMinimap:getTileDescription`

Returns text description for a tile type.

```lua
LMinimap:getTileDescription(type_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_id` | number | Tile type id. |

**Returns**

| Type | Description |
|------|-------------|
| string | Description text, or nil when missing. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setTerrain(3, 4, 3)
    mm:setTileDescription(3, "Mountain")
    local terrain = mm:getTerrain(3, 4)
    local desc = mm:getTileDescription(terrain)
    minimap_log("hover label for ridge tile = " .. tostring(desc))
end
```

---

#### `LMinimap:getViewportColor`

Returns the viewport rectangle color.

```lua
LMinimap:getViewportColor()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Red channel. |
| number | Green channel. |
| number | Blue channel. |
| number | Alpha channel. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setViewportRect(3, 3, 5, 5)
    mm:setViewportColor(0.2, 0.4, 1.0, 0.75)
    local r, g, b, a = mm:getViewportColor()
    local rect_w = select(3, mm:getViewportRect())
    minimap_log("viewport width " .. tostring(rect_w) .. " uses tint " .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LMinimap:getViewportRect`

Returns the viewport rectangle when one is set.

```lua
LMinimap:getViewportRect()
```

**Returns**

| Type | Description |
|------|-------------|
| number | X coordinate; or nil when unset. |
| number | Y coordinate; or nil when unset. |
| number | Width; or nil when unset. |
| number | Height; or nil when unset. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setViewportVisible(true)
    mm:setViewportRect(6, 8, 10, 14)
    local x, y, w, h = mm:getViewportRect()
    local visible = mm:isViewportVisible()
    minimap_log("viewport " .. tostring(visible) .. " => " .. tostring(x) .. "," .. tostring(y) .. " " .. tostring(w) .. "x" .. tostring(h))
end
```

---

#### `LMinimap:getZoom`

Returns the current minimap zoom magnification level.

```lua
LMinimap:getZoom()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Zoom value. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setCenter(8, 8)
    mm:setZoom(1.5)
    local zoom = mm:getZoom()
    local gx, gy = mm:screenToGrid(100, 100, 0, 0)
    minimap_log("zoom readback " .. zoom .. " around screen sample " .. tostring(gx) .. "," .. tostring(gy))
end
```

---

#### `LMinimap:gridToScreen`

Converts grid coordinates to screen coordinates.

```lua
LMinimap:gridToScreen(gx, gy, mx, my)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `gx` | number | Grid x coordinate. |
| `gy` | number | Grid y coordinate. |
| `mx` | number | Minimap x position. |
| `my` | number | Minimap y position. |

**Returns**

| Type | Description |
|------|-------------|
| number | Screen x coordinate; or nil when the transform state is invalid. |
| number | Screen y coordinate; or nil when the transform state is invalid. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16, 160, 160)
    mm:setCenter(8, 8)
    mm:setZoom(2.0)
    local sx, sy = mm:gridToScreen(8, 8, 0, 0)
    local gx, gy = mm:screenToGrid(sx, sy, 0, 0)
    minimap_log("grid 8,8 => screen " .. sx .. "," .. sy .. " => " .. tostring(gx) .. "," .. tostring(gy))
end
```

---

#### `LMinimap:hasMarker`

Returns whether a marker id exists.

```lua
LMinimap:hasMarker(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Marker id. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the marker exists. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(32, 32)
    local id = mm:addMarker(10, 10, "Outpost")
    mm:setCenter(10, 10)
    local present = mm:hasMarker(id)
    local count = mm:getMarkerCount()
    minimap_log("outpost marker present = " .. tostring(present) .. " count " .. count)
end
```

---

#### `LMinimap:isAntiAlias`

Returns whether anti-aliasing is enabled.

```lua
LMinimap:isAntiAlias()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when enabled. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setDisplaySize(96, 96)
    mm:setAntiAlias(false)
    local enabled = mm:isAntiAlias()
    local cells = mm:getCellCount()
    minimap_log("anti alias " .. tostring(enabled) .. " for " .. cells .. " tactical cells")
end
```

---

#### `LMinimap:isClickable`

Returns whether minimap click handling is enabled.

```lua
LMinimap:isClickable()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when clickable. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setDisplaySize(160, 160)
    mm:setClickable(true)
    local clickable = mm:isClickable()
    local dh = mm:getDisplayHeight()
    minimap_log("map clicking = " .. tostring(clickable) .. " on height " .. dh)
end
```

---

#### `LMinimap:isFogEnabled`

Returns whether fog display is enabled.

```lua
LMinimap:isFogEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when fog is enabled. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setFogLevel(4, 4, 2)
    mm:setFogEnabled(false)
    local enabled = mm:isFogEnabled()
    local fog = mm:getFogLevel(4, 4)
    minimap_log("fog visible? " .. tostring(enabled) .. " while cell keeps state " .. fog)
end
```

---

#### `LMinimap:isObjectTypeVisible`

Returns visibility for an object type by one-based index.

```lua
LMinimap:isObjectTypeVisible(type_idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_idx` | number | One-based object type index. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the object type is visible. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local t = mm:addObjectType("scout", 0, 1, 1, 1)
    mm:setObject(7, 9, 3, t, 1)
    mm:setObjectTypeVisible(t, true)
    local visible = mm:isObjectTypeVisible(t)
    local types = mm:getObjectTypeCount()
    minimap_log("scout visibility = " .. tostring(visible) .. " for " .. types .. " type(s)")
end
```

---

#### `LMinimap:isViewportVisible`

Returns whether the viewport rectangle is visible.

```lua
LMinimap:isViewportVisible()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when visible. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setViewportRect(1, 1, 6, 6)
    mm:setViewportVisible(false)
    local visible = mm:isViewportVisible()
    local rect_h = select(4, mm:getViewportRect())
    minimap_log("viewport visibility = " .. tostring(visible) .. " height " .. tostring(rect_h))
end
```

---

#### `LMinimap:removeMarker`

Removes a minimap marker by its unique id.

```lua
LMinimap:removeMarker(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Marker id. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a marker was removed. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local id = mm:addMarker(5, 5, "Temp")

    example_print_log("before = " .. mm:getMarkerCount())
    example_print_log("removed = " .. tostring(mm:removeMarker(id)))
    example_print_log("after = " .. mm:getMarkerCount())
end
```

---

#### `LMinimap:removeObject`

Removes a minimap object by its unique id.

```lua
LMinimap:removeObject(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Object id. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when an object was removed. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local npc = mm:addObjectType("npc", 0, 1, 0, 1)

    mm:setObject(1, 4, 4, npc, 0)
    mm:setObject(2, 8, 8, npc, 1)
    example_print_log("before = " .. mm:getObjectCount())
    example_print_log("removed = " .. tostring(mm:removeObject(2)))
    example_print_log("after = " .. mm:getObjectCount())
end
```

---

#### `LMinimap:render`

Enqueues minimap render commands at an optional screen position.

```lua
LMinimap:render(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x?` | number | Screen x coordinate, defaults to 0. |
| `y?` | number | Screen y coordinate, defaults to 0. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(8, 8, 96, 96)
    mm:setTerrain(1, 1, 1)
    mm:render(10, 10)
    example_print_log("render queued at = 10,10")
    example_print_log("type = " .. mm:type())
end
```

---

#### `LMinimap:revealRadius`

Reveals fog inside a world-space radius.

```lua
LMinimap:revealRadius(cx, cy, radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `cx` | number | Center x coordinate. |
| `cy` | number | Center y coordinate. |
| `radius` | number | Reveal radius. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(32, 32)
    local fog = {}

    mm:setFogEnabled(true)

    for i = 1, 32 * 32 do
        fog[i] = 0
    end

    mm:setFogData(fog)
    mm:revealRadius(16, 16, 5)
    example_print_log("center fog = " .. mm:getFogLevel(16, 16))
    example_print_log("corner fog = " .. mm:getFogLevel(1, 1))
end
```

---

#### `LMinimap:screenToGrid`

Converts a screen position to grid coordinates.

```lua
LMinimap:screenToGrid(sx, sy, mx, my)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | Screen x coordinate. |
| `sy` | number | Screen y coordinate. |
| `mx` | number | Minimap x position. |
| `my` | number | Minimap y position. |

**Returns**

| Type | Description |
|------|-------------|
| number | Grid x coordinate; or nil when the transform state is invalid. |
| number | Grid y coordinate; or nil when the transform state is invalid. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16, 160, 160)
    mm:setCenter(8, 8)
    local sx, sy = mm:gridToScreen(8, 8, 0, 0)
    local gx, gy = mm:screenToGrid(sx, sy, 0, 0)
    local hover = mm:getHoverInfo(sx, sy, 0, 0)
    minimap_log("screen " .. sx .. "," .. sy .. " resolves to " .. gx .. "," .. gy .. " hover " .. tostring(hover))
end
```

---

#### `LMinimap:setAntiAlias`

Enables or disables minimap anti-aliasing.

```lua
LMinimap:setAntiAlias(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | Anti-alias flag. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setDisplaySize(128, 128)
    mm:setAntiAlias(true)
    local enabled = mm:isAntiAlias()
    local dw, dh = mm:getDisplaySize()
    minimap_log("anti alias " .. tostring(enabled) .. " on " .. dw .. "x" .. dh)
end
```

---

#### `LMinimap:setCenter`

Sets the minimap world-space center position.

```lua
LMinimap:setCenter(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Center x coordinate. |
| `y` | number | Center y coordinate. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setZoom(1.5)
    mm:setCenter(16, 12)
    local cx, cy = mm:getCenter()
    local sx, sy = mm:gridToScreen(cx, cy, 0, 0)
    minimap_log("camera focus moved to " .. cx .. "," .. cy .. " => " .. sx .. "," .. sy)
end
```

---

#### `LMinimap:setClickable`

Enables or disables minimap click handling.

```lua
LMinimap:setClickable(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | Clickable flag. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setDisplaySize(160, 160)
    mm:setClickable(false)
    local clickable = mm:isClickable()
    local dw = mm:getDisplayWidth()
    minimap_log("map clicking = " .. tostring(clickable) .. " on width " .. dw)
end
```

---

#### `LMinimap:setColorMode`

Sets the minimap color mode to terrain or political.

```lua
LMinimap:setColorMode(mode)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mode` | string | Color mode name, expected `terrain` or `political`. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setOwnerColor(1, 0.9, 0.2, 0.2, 1.0)
    mm:setTerrain(4, 4, 1)
    mm:setColorMode("political")
    local mode = mm:getColorMode()
    minimap_log("campaign view mode = " .. mode)
end
```

---

#### `LMinimap:setDisplaySize`

Sets the minimap display width and height in pixels.

```lua
LMinimap:setDisplaySize(w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `w` | number | Display width in pixels. |
| `h` | number | Display height in pixels. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16, 100, 100)
    mm:setCenter(8, 8)
    mm:setDisplaySize(300, 250)
    local dw, dh = mm:getDisplaySize()
    local zoom = mm:getZoom()
    minimap_log("resized hud panel to " .. dw .. "x" .. dh .. " at zoom " .. zoom)
end
```

---

#### `LMinimap:setFogColor`

Sets the RGBA fog overlay color for covered cells.

```lua
LMinimap:setFogColor(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a?` | number | Alpha channel, defaults to 0.8. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setFogEnabled(true)
    mm:setFogColor(0.0, 0.0, 0.0, 0.7)
    local r, g, b, a = mm:getFogColor()
    mm:setFogLevel(3, 3, 2)
    minimap_log("night raid fog color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LMinimap:setFogData`

Replaces fog data from a flat array table.

```lua
LMinimap:setFogData(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | table | Array table of fog level bytes. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(4, 4)
    local fog = {}

    mm:setFogEnabled(true)

    for i = 1, 16 do
        fog[i] = (i - 1) % 3
    end

    mm:setFogData(fog)
    example_print_log("fog(1,1) = " .. mm:getFogLevel(1, 1))
    example_print_log("fog(4,4) = " .. mm:getFogLevel(4, 4))
end
```

---

#### `LMinimap:setFogEnabled`

Enables or disables the minimap fog display.

```lua
LMinimap:setFogEnabled(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | Fog enabled flag. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setFogColor(0.0, 0.0, 0.0, 0.75)
    mm:setFogEnabled(true)
    mm:setFogLevel(8, 8, 0)
    local enabled = mm:isFogEnabled()
    minimap_log("fog toggle for unexplored map = " .. tostring(enabled))
end
```

---

#### `LMinimap:setFogLevel`

Sets fog level for a one-based grid cell.

```lua
LMinimap:setFogLevel(x, y, level)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based grid x coordinate. |
| `y` | number | One-based grid y coordinate. |
| `level` | number | Fog level byte. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setFogEnabled(true)
    mm:setFogColor(0.0, 0.0, 0.0, 0.6)
    mm:setFogLevel(1, 1, 2)
    local fog = mm:getFogLevel(1, 1)
    minimap_log("spawn tile fog level now " .. fog)
end
```

---

#### `LMinimap:setLayer`

Sets the active minimap display layer index.

```lua
LMinimap:setLayer(layer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(4, 4)
    mm:setLayerData(1, { 1, 1, 1, 1, 0, 0, 0, 0, 2, 2, 2, 2, 3, 3, 3, 3 })
    mm:setLayer(1)
    local layer = mm:getLayer()
    local layer_cells = mm:getLayerData(layer)
    minimap_log("switched to layer " .. layer .. " with " .. #(layer_cells or {}) .. " cells")
end
```

---

#### `LMinimap:setLayerData`

Sets raw cell data for a minimap layer.

```lua
LMinimap:setLayerData(layer, data_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | number | Layer index. |
| `data_tbl` | table | Array table of cell bytes. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(4, 4)
    local data = {}

    for i = 1, 16 do
        data[i] = i
    end

    mm:setLayerData(0, data)
    local out = mm:getLayerData(0)
    example_print_log("layer 0 size = " .. #(out or {}))
    example_print_log("layer 0 first = " .. (out and out[1] or -1))
end
```

---

#### `LMinimap:setMarkerAnimation`

Sets marker animation by type name.

```lua
LMinimap:setMarkerAnimation(id, anim_type, speed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Marker id. |
| `anim_type` | string | Animation type: `blink`, `pulse`, or `rotate`. |
| `speed` | number | Animation speed. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local id = mm:addMarker(8, 8, "Pulse")

    mm:setMarkerAnimation(id, "pulse", 2.0)
    mm:update(0.5)
    example_print_log("marker exists = " .. tostring(mm:hasMarker(id)))
    example_print_log("marker count = " .. mm:getMarkerCount())
end
```

---

#### `LMinimap:setMarkerTexture`

Assigns an image texture to a marker.

```lua
LMinimap:setMarkerTexture(id, image_ud, width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Marker id. |
| `image_ud` | [LImage](render.md#limage) | Image handle from `lurek.render.newImage`. |
| `width?` | number | Display width override. |
| `height?` | number | Display height override. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(32, 32, 256, 256)
    local id = mm:addMarker(16, 16, "Hero")
    local img = lurek.render.newImage("content/examples/assets/images/sample_icon.png")

    mm:setMarkerTexture(id, img, 24, 24)
    example_print_log("marker count = " .. mm:getMarkerCount())
end
```

---

#### `LMinimap:setObject`

Adds or updates an object on the minimap.

```lua
LMinimap:setObject(id, x, y, type_idx, owner)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Object id. |
| `x` | number | Object x coordinate. |
| `y` | number | Object y coordinate. |
| `type_idx` | number | One-based object type index. |
| `owner?` | number | Owner id, defaults to 0. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local npc = mm:addObjectType("npc", 0, 1, 0, 1)
    mm:setOwnerColor(2, 0.9, 0.8, 0.2, 1.0)
    mm:setObject(1, 4, 4, npc, 2)
    local count = mm:getObjectCount()
    local owner_r = select(1, mm:getOwnerColor(2))
    minimap_log("placed object count " .. count .. " with owner tint " .. tostring(owner_r))
end
```

---

#### `LMinimap:setObjectTypeTexture`

Assigns an image texture to an object type.

```lua
LMinimap:setObjectTypeTexture(type_idx, image_ud, width, height)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_idx` | number | One-based object type index. |
| `image_ud` | [LImage](render.md#limage) | Image handle from `lurek.render.newImage`. |
| `width?` | number | Display width override. |
| `height?` | number | Display height override. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(32, 32, 256, 256)
    local type_idx = mm:addObjectType("unit", 0, 1, 0, 1)
    local img = lurek.render.newImage("content/examples/assets/images/sample_icon.png")

    mm:setObjectTypeTexture(type_idx, img, 16, 16)
    example_print_log("object types = " .. mm:getObjectTypeCount())
end
```

---

#### `LMinimap:setObjectTypeVisible`

Sets visibility for an object type by one-based index.

```lua
LMinimap:setObjectTypeVisible(type_idx, visible)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_idx` | number | One-based object type index. |
| `visible` | boolean | Visibility flag. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local t = mm:addObjectType("hidden", 1, 0, 0, 1)
    mm:setObject(1, 6, 6, t, 0)
    mm:setObjectTypeVisible(t, false)
    local visible = mm:isObjectTypeVisible(t)
    local count = mm:getObjectCount()
    minimap_log("ambush icon visible = " .. tostring(visible) .. " across " .. count .. " objects")
end
```

---

#### `LMinimap:setOwnerColor`

Sets the RGBA display color for an owner id.

```lua
LMinimap:setOwnerColor(owner, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `owner` | number | Owner id. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a?` | number | Alpha channel, defaults to 1.0. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local scout = mm:addObjectType("scout", 0.1, 0.9, 0.2, 1.0)
    mm:setOwnerColor(1, 0, 0, 1, 1)
    mm:setObject(1, 8, 8, scout, 1)
    local r, g, b, a = mm:getOwnerColor(1)
    minimap_log("owner 1 faction tint = " .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LMinimap:setTerrain`

Sets terrain type for a one-based grid cell.

```lua
LMinimap:setTerrain(x, y, terrain_type)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based grid x coordinate. |
| `y` | number | One-based grid y coordinate. |
| `terrain_type` | number | Terrain type id. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setTileDescription(2, "Forest")
    mm:setTerrain(6, 5, 2)
    local terrain = mm:getTerrain(6, 5)
    local desc = mm:getTileDescription(terrain)
    minimap_log("sector 6,5 became " .. tostring(desc))
end
```

---

#### `LMinimap:setTerrainColor`

Sets the RGBA display color for a terrain type.

```lua
LMinimap:setTerrainColor(terrain_type, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `terrain_type` | number | Terrain type id. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a?` | number | Alpha channel, defaults to 1.0. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setTerrain(4, 4, 1)
    mm:setTerrainColor(1, 0.2, 0.6, 0.1, 0.9)
    local r, g, b, a = mm:getTerrainColor(1)
    local terrain = mm:getTerrain(4, 4)
    minimap_log("terrain " .. terrain .. " palette = " .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LMinimap:setTerrainData`

Replaces terrain data from a flat array table.

```lua
LMinimap:setTerrainData(data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | table | Array table of terrain type ids. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(4, 4)
    local data = {}

    for i = 1, 16 do
        data[i] = ((i - 1) % 3) + 1
    end

    mm:setTerrainData(data)
    example_print_log("terrain(1,1) = " .. mm:getTerrain(1, 1))
    example_print_log("terrain(4,4) = " .. mm:getTerrain(4, 4))
end
```

---

#### `LMinimap:setTileDescription`

Sets text description for a tile type.

```lua
LMinimap:setTileDescription(type_id, desc)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_id` | number | Tile type id. |
| `desc` | string | Description text. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:setTileDescription(1, "Grass")
    mm:setTileDescription(2, "Water")
    example_print_log("tile 1 = " .. tostring(mm:getTileDescription(1)))
    example_print_log("tile 2 = " .. tostring(mm:getTileDescription(2)))
end
```

---

#### `LMinimap:setViewportColor`

Sets the viewport rectangle color.

```lua
LMinimap:setViewportColor(r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a?` | number | Alpha channel, defaults to 0.8. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setViewportRect(2, 2, 6, 6)
    mm:setViewportColor(1, 1, 0, 0.5)
    local r, g, b, a = mm:getViewportColor()
    mm:setViewportVisible(true)
    minimap_log("viewport tint = " .. r .. "," .. g .. "," .. b .. "," .. a)
end
```

---

#### `LMinimap:setViewportRect`

Sets the visible viewport rectangle shown on the minimap.

```lua
LMinimap:setViewportRect(x, y, w, h)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Viewport x coordinate. |
| `y` | number | Viewport y coordinate. |
| `w` | number | Viewport width. |
| `h` | number | Viewport height. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setCenter(16, 16)
    mm:setViewportRect(4, 4, 12, 12)
    local x, y, w, h = mm:getViewportRect()
    minimap_log("camera frame = " .. tostring(x) .. "," .. tostring(y) .. " " .. tostring(w) .. "x" .. tostring(h))
end
```

---

#### `LMinimap:setViewportVisible`

Sets whether the viewport rectangle is visible.

```lua
LMinimap:setViewportVisible(visible)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `visible` | boolean | Visibility flag. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setViewportRect(1, 1, 6, 6)
    mm:setViewportVisible(true)
    local visible = mm:isViewportVisible()
    local rect_w = select(3, mm:getViewportRect())
    minimap_log("viewport visibility = " .. tostring(visible) .. " width " .. tostring(rect_w))
end
```

---

#### `LMinimap:setZoom`

Sets the minimap zoom magnification level.

```lua
LMinimap:setZoom(zoom)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `zoom` | number | Zoom value. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(32, 32)
    mm:setCenter(16, 16)
    mm:setZoom(2.0)
    local zoom = mm:getZoom()
    local sx, sy = mm:gridToScreen(20, 20, 0, 0)
    minimap_log("zoom " .. zoom .. " pushes scout ping to " .. sx .. "," .. sy)
end
```

---

#### `LMinimap:showPath`

Adds a colored path overlay and returns its id.

```lua
LMinimap:showPath(points_tbl, color_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `points_tbl` | table | Array table of point arrays `{x, y}`. |
| `color_tbl` | table | RGBA byte color table. |

**Returns**

| Type | Description |
|------|-------------|
| number | Path id. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    local pts = {
        { 2, 2 },
        { 4, 4 },
        { 6, 2 },
        { 8, 4 },
    }
    local pid = mm:showPath(pts, { 255, 0, 0, 255 })

    example_print_log("path id = " .. pid)
    example_print_log("path count = " .. mm:getPathCount())
end
```

---

#### `LMinimap:trackCamera`

Centers the minimap and viewport rectangle from a camera handle.

```lua
LMinimap:trackCamera(camera_ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `camera_ud` | [LCamera](camera.md#lcamera) | Camera handle from `lurek.camera.newCamera`. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(32, 32, 256, 256)
    local cam = lurek.camera.newCamera(1280, 720)

    cam:setPosition(320, 240)
    mm:trackCamera(cam)

    local cx, cy = mm:getCenter()
    local _, _, vw, vh = mm:getViewportRect()
    example_print_log("center = " .. cx .. "," .. cy)
    example_print_log("viewport size = " .. tostring(vw) .. "x" .. tostring(vh))
end
```

---

#### `LMinimap:type`

Returns the Lua-visible type name for this minimap handle.

```lua
LMinimap:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LMinimap](#lminimap)`. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setTerrain(8, 8, 1)
    mm:setCenter(8, 8)
    local type_name = mm:type()
    local cells = mm:getCellCount()
    minimap_log("handle type " .. type_name .. " owns " .. cells .. " cells")
end
```

---

#### `LMinimap:typeOf`

Returns whether this minimap handle matches a supported type name.

```lua
LMinimap:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LMinimap](#lminimap)`, `Minimap`, and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16)
    mm:setTerrain(4, 4, 2)
    local is_minimap = mm:typeOf("LMinimap")
    local is_object = mm:typeOf("LObject")
    local type_name = mm:type()
    minimap_log(type_name .. " -> LMinimap=" .. tostring(is_minimap) .. " LObject=" .. tostring(is_object))
end
```

---

#### `LMinimap:update`

Advances minimap animations and timers.

```lua
LMinimap:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(8, 8)
    mm:addPing(4, 4, 0.25)
    example_print_log("pings before = " .. mm:getPingCount())
    mm:update(0.5)
    example_print_log("pings after = " .. mm:getPingCount())
end
```

---
