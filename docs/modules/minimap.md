# Minimap

## Summary

This module provides a grid-based tactical minimap subsystem for HUD views. It maintains a map model tracking cells, terrain types, and display layers. These layers can be stacked to combine different map representations (like terrain and political views) or show varied vertical elevations, offering highly customizable tactical HUD feedback.

To represent gameplay, the module displays dynamic indicators on the map. It supports pins, markers, and colored path overlays. Markers are managed by type and can carry custom textures or timed animations, while temporary pings alert players to events. Viewport rectangles show camera bounds, keeping overlay rendering highly organized.

Visibility is managed via fog-of-war systems, tracking explored cells and revealing sections inside a radius. A specialized raycaster overlay builds visibility grids from wall, floor, and light layouts, using Bresenham line traversal to compute line-of-sight profiles and render player indicators in real-time.

For user interfaces, the system tracks active cameras, keeping the minimap centered on targets. Grid-to-screen and screen-to-grid coordinate conversions support pointer hover checks and click targeting. Finally, completed map states can be rendered as HUD overlays or exported directly into CPU image buffers.

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
    local dw, dh = mm:getDisplaySize()
    print("grid = " .. mm:getGridWidth() .. "x" .. mm:getGridHeight())
    print("display = " .. dw .. "x" .. dh)
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
    print("marker id = " .. id1)
    print("marker count = " .. mm:getMarkerCount())
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

    print("types = " .. mm:getObjectTypeCount())
    print("unit = " .. unit .. " building = " .. building)
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
    print("pings before = " .. mm:getPingCount())
    mm:update(2.5)
    print("pings after = " .. mm:getPingCount())
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
    print("marker exists = " .. tostring(mm:hasMarker(id)))
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
    print("marker exists = " .. tostring(mm:hasMarker(id)))
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
    print("object types = " .. mm:getObjectTypeCount())
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
    print("before = " .. mm:getObjectCount())
    mm:clearObjects()
    print("after = " .. mm:getObjectCount())
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
    print("before = " .. mm:getOverlayShapeCount())
    mm:clearOverlay()
    print("after = " .. mm:getOverlayShapeCount())
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

    print("before = " .. mm:getPathCount())
    mm:clearPath(pid)
    print("after = " .. mm:getPathCount())
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
    print("viewport cleared = " .. tostring(x == nil))
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
    mm:drawLine(0, 0, 15, 15, { 255, 255, 255, 255 })
    print("overlay shapes = " .. mm:getOverlayShapeCount())
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
    mm:drawRect(2, 2, 4, 4, { 0, 255, 0, 200 })
    print("overlay shapes = " .. mm:getOverlayShapeCount())
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

    print("image type = " .. img:type())
    print("image size = " .. img:getWidth() .. "x" .. img:getHeight())
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
    print("cell count = " .. mm:getCellCount())
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
    mm:setCenter(10, 20)
    local cx, cy = mm:getCenter()
    print("center = " .. cx .. "," .. cy)
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
    print("center x = " .. mm:getCenterX())
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
    print("center y = " .. mm:getCenterY())
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
    mm:setColorMode("terrain")
    print("mode = " .. mm:getColorMode())
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
    print("display height = " .. mm:getDisplayHeight())
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
    local dw, dh = mm:getDisplaySize()

    print("display = " .. dw .. "x" .. dh)
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
    print("display width = " .. mm:getDisplayWidth())
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
    mm:setFogColor(0.1, 0.2, 0.3, 0.6)
    local r, g, b, a = mm:getFogColor()
    print("fog color = " .. r .. "," .. g .. "," .. b .. "," .. a)
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
    mm:setFogLevel(2, 2, 1)
    print("fog(2,2) = " .. mm:getFogLevel(2, 2))
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
    print("grid height = " .. mm:getGridHeight())
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
    local gw, gh = mm:getGridSize()

    print("grid = " .. gw .. "x" .. gh)
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
    print("grid width = " .. mm:getGridWidth())
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
    print("hover = " .. tostring(mm:getHoverInfo(1, 1, 0, 0)))
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
    mm:setLayer(1)
    print("layer = " .. mm:getLayer())
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
    print("layer count = " .. mm:getLayerCount())
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
    print("layer 1 size = " .. #(out or {}))
    print("layer 1 last = " .. (out and out[#out] or -1))
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
    mm:addMarker(20, 5, "Enemy")
    print("marker count = " .. mm:getMarkerCount())
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

    print("marker desc = " .. tostring(mm:getMarkerDescription(id)))
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
    print("object count = " .. mm:getObjectCount())
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
    mm:addObjectType("unit", 0, 0, 1, 1)
    mm:addObjectType("building", 1, 1, 0, 0.8)
    print("object type count = " .. mm:getObjectTypeCount())
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
    print("overlay shape count = " .. mm:getOverlayShapeCount())
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
    mm:setOwnerColor(2, 1, 0, 0, 1)
    local r, g, b, a = mm:getOwnerColor(2)
    print("owner 2 = " .. r .. "," .. g .. "," .. b .. "," .. a)
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
    print("path count = " .. mm:getPathCount())
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
    mm:addPing(4, 4, 1.0)
    print("ping count = " .. mm:getPingCount())
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
    mm:setTerrain(2, 3, 7)
    print("terrain(2,3) = " .. mm:getTerrain(2, 3))
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
    mm:setTerrainColor(3, 0.7, 0.4, 0.2, 1.0)
    local r, g, b, a = mm:getTerrainColor(3)
    print("terrain 3 color = " .. r .. "," .. g .. "," .. b .. "," .. a)
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
    mm:setTileDescription(3, "Mountain")
    print("tile 3 = " .. tostring(mm:getTileDescription(3)))
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
    mm:setViewportColor(0.2, 0.4, 1.0, 0.75)
    local r, g, b, a = mm:getViewportColor()
    print("viewport color = " .. r .. "," .. g .. "," .. b .. "," .. a)
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
    mm:setViewportRect(6, 8, 10, 14)
    local x, y, w, h = mm:getViewportRect()
    print("viewport = " .. tostring(x) .. "," .. tostring(y) .. " " .. tostring(w) .. "x" .. tostring(h))
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
    mm:setZoom(1.5)
    print("zoom = " .. mm:getZoom())
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
| number | Screen x coordinate. |
| number | Screen y coordinate. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16, 160, 160)
    local sx, sy = mm:gridToScreen(8, 8, 0, 0)

    print("screen = " .. sx .. "," .. sy)
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

    print("has marker = " .. tostring(mm:hasMarker(id)))
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
    mm:setAntiAlias(false)
    print("anti alias = " .. tostring(mm:isAntiAlias()))
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
    mm:setClickable(true)
    print("clickable = " .. tostring(mm:isClickable()))
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
    mm:setFogEnabled(false)
    print("fog enabled = " .. tostring(mm:isFogEnabled()))
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

    mm:setObjectTypeVisible(t, true)
    print("visible = " .. tostring(mm:isObjectTypeVisible(t)))
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
    mm:setViewportVisible(false)
    print("viewport visible = " .. tostring(mm:isViewportVisible()))
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

    print("before = " .. mm:getMarkerCount())
    print("removed = " .. tostring(mm:removeMarker(id)))
    print("after = " .. mm:getMarkerCount())
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
    print("before = " .. mm:getObjectCount())
    print("removed = " .. tostring(mm:removeObject(2)))
    print("after = " .. mm:getObjectCount())
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
    print("render queued at = 10,10")
    print("type = " .. mm:type())
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
    print("center fog = " .. mm:getFogLevel(16, 16))
    print("corner fog = " .. mm:getFogLevel(1, 1))
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
| number | Grid x coordinate. |
| number | Grid y coordinate. |

**Example**

```lua
do
    local mm = lurek.minimap.newMinimap(16, 16, 160, 160)
    local sx, sy = mm:gridToScreen(8, 8, 0, 0)
    local gx, gy = mm:screenToGrid(sx, sy, 0, 0)

    print("grid = " .. gx .. "," .. gy)
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
    mm:setAntiAlias(true)
    print("anti alias = " .. tostring(mm:isAntiAlias()))
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
    mm:setCenter(16, 12)
    local cx, cy = mm:getCenter()
    print("center = " .. cx .. "," .. cy)
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
    mm:setClickable(false)
    print("clickable = " .. tostring(mm:isClickable()))
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
    mm:setColorMode("political")
    print("mode = " .. mm:getColorMode())
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
    mm:setDisplaySize(300, 250)
    print("display = " .. mm:getDisplayWidth() .. "x" .. mm:getDisplayHeight())
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
    mm:setFogColor(0.0, 0.0, 0.0, 0.7)
    local r, g, b, a = mm:getFogColor()
    print("fog color = " .. r .. "," .. g .. "," .. b .. "," .. a)
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
    print("fog(1,1) = " .. mm:getFogLevel(1, 1))
    print("fog(4,4) = " .. mm:getFogLevel(4, 4))
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
    mm:setFogEnabled(true)
    print("fog enabled = " .. tostring(mm:isFogEnabled()))
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
    mm:setFogLevel(1, 1, 2)
    print("fog(1,1) = " .. mm:getFogLevel(1, 1))
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
    mm:setLayer(2)
    print("layer = " .. mm:getLayer())
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
    print("layer 0 size = " .. #(out or {}))
    print("layer 0 first = " .. (out and out[1] or -1))
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
    print("marker exists = " .. tostring(mm:hasMarker(id)))
    print("marker count = " .. mm:getMarkerCount())
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
    print("marker count = " .. mm:getMarkerCount())
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

    mm:setObject(1, 4, 4, npc, 2)
    print("object count = " .. mm:getObjectCount())
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
    print("object types = " .. mm:getObjectTypeCount())
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

    mm:setObjectTypeVisible(t, false)
    print("visible = " .. tostring(mm:isObjectTypeVisible(t)))
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
    mm:setOwnerColor(1, 0, 0, 1, 1)
    local r, g, b, a = mm:getOwnerColor(1)
    print("owner 1 = " .. r .. "," .. g .. "," .. b .. "," .. a)
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
    mm:setTerrain(1, 1, 2)
    print("terrain(1,1) = " .. mm:getTerrain(1, 1))
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
    mm:setTerrainColor(1, 0.2, 0.6, 0.1, 0.9)
    local r, g, b, a = mm:getTerrainColor(1)
    print("terrain 1 color = " .. r .. "," .. g .. "," .. b .. "," .. a)
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
    print("terrain(1,1) = " .. mm:getTerrain(1, 1))
    print("terrain(4,4) = " .. mm:getTerrain(4, 4))
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
    print("tile 1 = " .. tostring(mm:getTileDescription(1)))
    print("tile 2 = " .. tostring(mm:getTileDescription(2)))
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
    mm:setViewportColor(1, 1, 0, 0.5)
    local r, g, b, a = mm:getViewportColor()
    print("viewport color = " .. r .. "," .. g .. "," .. b .. "," .. a)
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
    mm:setViewportRect(4, 4, 12, 12)
    local x, y, w, h = mm:getViewportRect()
    print("viewport = " .. tostring(x) .. "," .. tostring(y) .. " " .. tostring(w) .. "x" .. tostring(h))
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
    mm:setViewportVisible(true)
    print("viewport visible = " .. tostring(mm:isViewportVisible()))
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
    mm:setZoom(2.0)
    print("zoom = " .. mm:getZoom())
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

    print("path id = " .. pid)
    print("path count = " .. mm:getPathCount())
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
    print("center = " .. cx .. "," .. cy)
    print("viewport size = " .. tostring(vw) .. "x" .. tostring(vh))
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
    print("type = " .. mm:type())
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
    print("is LMinimap = " .. tostring(mm:typeOf("LMinimap")))
    print("is LObject = " .. tostring(mm:typeOf("LObject")))
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
    print("pings before = " .. mm:getPingCount())
    mm:update(0.5)
    print("pings after = " .. mm:getPingCount())
end
```

---
