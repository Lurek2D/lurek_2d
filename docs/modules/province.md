# Province

- Province is a GENERIC rendering/property system. Economy logic lives in `library/province_economy/`.

The `province` module is an advanced Edge/Integration tier subsystem that provides a complete, engine-native province map runtime, tailor-made for grand strategy and map-painting games in Lurek2D. Operating independently of tilemaps, it manages irregular, pixel-perfect regions using a `ProvinceRegistry`. This registry acts as the central source of truth, storing metadata for each province—including ownership, terrain type, border styles, capital coordinates, label anchors, and arbitrary string attributes. At its core, the registry maintains a `ProvinceGraph` that tracks undirected adjacencies, allowing for rapid topological queries (e.g., neighbor enumeration) and game-defined border types registered from Lua (e.g., land, coast, river — defined per-game rather than hardcoded).

A standout feature of the module is its highly optimized rendering pipeline. To avoid the overhead of per-pixel evaluation at runtime, a `ProvinceGeometryCache` pre-computes horizontal cell spans, bounding boxes, and border line segments. These structures are packed into a `ProvinceGpuRecord` (a std430-friendly 32-byte payload) for direct GPU upload. Rendering is driven by customizable `ProvinceMapMode`s (such as Political, Terrain, or Visibility), mapping a `ProvinceStyle` to specific fill colors. The module handles viewport culling, screen-to-map transformations, and zoom-to-anchor logic, seamlessly generating render commands for solid fills, border strokes, capital icons, and shadowed text labels.

Border rendering also supports per-adjacency overrides through `setBorderPairStyle(a, b, style)`. A style can define an optional RGBA override color, a custom line thickness, and semantic flags (`country`, `alliance`, `war`, `truce`). Strategic view can filter to coastlines and country-marked borders, while tactical view draws full detail. Tactical mode can also emit road segments between capitals of visible adjacent provinces.

The import pipeline is equally robust, automatically converting color-coded PNG maps and RGB CSV metadata into structured registry data. It includes a marker sanitization step that strips out capital (near-white) and label (magenta) pixels, reassigning them to the correct province while computing optimal label line vectors via expanding-ring neighbor searches. To support game logic, the registry employs a monotonic revision counter and change-stream (`get_changes_since`), emitting fine-grained deltas whenever a province's color, terrain, or fog state mutates. Exposed entirely through the `lurek.province.*` API, this module provides the complex topological, visual, and event-driven infrastructure required for high-performance interactive cartography.

### Visibility Rendering Contract

- `visibility_state = 0`: hidden. The renderer skips province fill, border, capital marker, and label.
- `visibility_state = 1`: discovered. The renderer emits only a gray fill (no border, capital, or label).
- `visibility_state >= 2`: fully visible. The renderer emits normal map-mode fill and full details.
- Border segments render only when both adjacent provinces are fully visible (`>= 2`).

## Functions

### `lurek.province.clearProperties`

Removes all properties, attributes, and flags for a province.

```lua
-- signature
lurek.province.clearProperties(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Province ID. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("prop_clear", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setProperty(province_id, "temp_val", 42)
        lurek.province.clearProperties(province_id)
    end

    print("province_id = " .. tostring(province_id))
    print("temp_val = " .. tostring(province_id and lurek.province.getProperty(province_id, "temp_val")))
end
```

---

### `lurek.province.exists`

Checks whether a province registry with the given name exists.

```lua
-- signature
lurek.province.exists(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Registry name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the registry exists. |

**Example**

```lua
do
    lurek.province.newFromPng("check_reg_exists", "assets/textures/province_map.png")

    print("exists = " .. tostring(lurek.province.exists("check_reg_exists")))
end
```

---

### `lurek.province.get`

Retrieves an existing province registry by name. Returns nil if no registry with that name has been created.

```lua
-- signature
lurek.province.get(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Registry name to look up. |

**Returns**

| Type | Description |
|------|-------------|
| `LProvinceRegistry` | The registry handle, or nil if not found. |

**Example**

```lua
do
    lurek.province.newFromPng("check_reg_get", "assets/textures/province_map.png")
    local reg = lurek.province.get("check_reg_get")

    print("found = " .. tostring(reg ~= nil))
    print("name = " .. tostring(reg and reg:getName()))
end
```

---

### `lurek.province.getActive`

Returns the currently active province registry, or nil if none is set.

```lua
-- signature
lurek.province.getActive()
```

**Returns**

| Type | Description |
|------|-------------|
| `LProvinceRegistry` | The active registry handle, or nil. |

**Example**

```lua
do
    lurek.province.newFromPng("check_reg_active", "assets/textures/province_map.png")
    lurek.province.setActive("check_reg_active")

    local reg = lurek.province.getActive()

    print("active exists = " .. tostring(reg ~= nil))
    print("active name = " .. tostring(reg and reg:getName()))
end
```

---

### `lurek.province.getAttr`

Gets a string attribute from a province. Returns nil if not set.

```lua
-- signature
lurek.province.getAttr(id, key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Province ID. |
| `key` | `string` | Attribute name. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | The stored value, or nil. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("attr_get", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setAttr(province_id, "climate", "temperate")
    end

    print("province_id = " .. tostring(province_id))
    print("climate = " .. tostring(province_id and lurek.province.getAttr(province_id, "climate")))
end
```

---

### `lurek.province.getProperty`

Gets a numeric property from a province. Returns nil if not set.

```lua
-- signature
lurek.province.getProperty(id, key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Province ID. |
| `key` | `string` | Property name. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The stored value, or nil. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("prop_get", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setProperty(province_id, "population", 50000)
    end

    print("province_id = " .. tostring(province_id))
    print("population = " .. tostring(province_id and lurek.province.getProperty(province_id, "population")))
end
```

---

### `lurek.province.hasFlag`

Checks whether a flag bit is set on a province.

```lua
-- signature
lurek.province.hasFlag(id, bit)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Province ID. |
| `bit` | `number` | Flag bit index (0–63). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the flag bit is set. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("flag_get", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setFlag(province_id, 2, true)
    end

    print("province_id = " .. tostring(province_id))
    print("flag 2 = " .. tostring(province_id and lurek.province.hasFlag(province_id, 2)))
end
```

---

### `lurek.province.newFromPng`

Creates a new province registry by loading a color-coded PNG where each unique color represents a distinct province. The PNG is parsed into a grid and adjacencies are computed automatically.

```lua
-- signature
lurek.province.newFromPng(name, png_path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Unique registry name for later retrieval. |
| `png_path` | `string` | Path to the province map PNG (relative to game directory or absolute). |

**Returns**

| Type | Description |
|------|-------------|
| `LProvinceRegistry` | The newly created registry handle. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("world", "assets/textures/province_map.png")
    local ids = reg:provinceIds()

    print("registry = " .. reg:getName())
    print("province count = " .. tostring(#ids))
end
```

---

### `lurek.province.remove`

Removes a province registry by name and clears the active registry if it was the one removed. Returns true if a registry was actually removed.

```lua
-- signature
lurek.province.remove(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Registry name to remove. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the registry existed and was removed. |

**Example**

```lua
do
    lurek.province.newFromPng("check_reg_remove", "assets/textures/province_map.png")
    local removed = lurek.province.remove("check_reg_remove")

    print("removed = " .. tostring(removed))
    print("exists after = " .. tostring(lurek.province.exists("check_reg_remove")))
end
```

---

### `lurek.province.sanitizeMarkedPng`

Pre-processes a marker PNG by replacing capital and label marker pixels with the surrounding province color. Outputs a cleaned PNG suitable for `newFromPng`. Returns a summary of pixel replacements.

```lua
-- signature
lurek.province.sanitizeMarkedPng(input_png, output_png, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input_png` | `string` | Path to the source marker PNG. |
| `output_png` | `string` | Path to write the sanitized output PNG. |
| `opts?` | `table` | Marker detection thresholds: capital_min (number?), label_r_min (number?), label_g_max (number?), label_b_min (number?), search_radius (number?). |

**Returns**

| Type | Description |
|------|-------------|
| `ProvinceSanitizeMarkedPngResult` | Summary with fields: replaced_pixels (number), unresolved_pixels (number). |

**Example**

```lua
do
    local summary = lurek.province.sanitizeMarkedPng(
        "content/examples/assets/images/sample_texture.png",
        "save/province_sanitized.png",
        {}
    )

    print("replaced pixels = " .. tostring(summary.replaced_pixels))
    print("unresolved pixels = " .. tostring(summary.unresolved_pixels))
end
```

---

### `lurek.province.setActive`

Sets the named registry as the active province registry. Returns false if no registry with that name exists.

```lua
-- signature
lurek.province.setActive(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Registry name to activate. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the registry was found and activated. |

**Example**

```lua
do
    lurek.province.newFromPng("map_a", "assets/textures/province_map.png")
    lurek.province.newFromPng("map_b", "assets/textures/province_map.png")

    local set_a = lurek.province.setActive("map_a")
    local active_a = lurek.province.getActive()
    local set_b = lurek.province.setActive("map_b")
    local active_b = lurek.province.getActive()

    print("set map_a = " .. tostring(set_a) .. " -> " .. tostring(active_a and active_a:getName()))
    print("set map_b = " .. tostring(set_b) .. " -> " .. tostring(active_b and active_b:getName()))
end
```

---

### `lurek.province.setAttr`

Sets a string attribute on a province.

```lua
-- signature
lurek.province.setAttr(id, key, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Province ID. |
| `key` | `string` | Attribute name. |
| `value` | `string` | String value to store. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("attr_set", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setAttr(province_id, "terrain", "forest")
    end

    print("province_id = " .. tostring(province_id))
    print("terrain = " .. tostring(province_id and lurek.province.getAttr(province_id, "terrain")))
end
```

---

### `lurek.province.setFlag`

Sets a single flag bit (0–63) on a province.

```lua
-- signature
lurek.province.setFlag(id, bit, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Province ID. |
| `bit` | `number` | Flag bit index (0–63). |
| `value` | `boolean` | True to set, false to clear. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("flag_set", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setFlag(province_id, 1, true)
    end

    print("province_id = " .. tostring(province_id))
    print("flag 1 = " .. tostring(province_id and lurek.province.hasFlag(province_id, 1)))
end
```

---

### `lurek.province.setProperty`

Sets a numeric property on a province. Game logic defines the semantics of each key.

```lua
-- signature
lurek.province.setProperty(id, key, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Province ID. |
| `key` | `string` | Property name. |
| `value` | `number` | Numeric value to store. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("prop_set", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setProperty(province_id, "tax_rate", 0.15)
    end

    print("province_id = " .. tostring(province_id))
    print("tax_rate = " .. tostring(province_id and lurek.province.getProperty(province_id, "tax_rate")))
end
```

---

### `lurek.province.zoomCameraAt`

Computes new camera position after zooming centered on an anchor point. Keeps the anchor point visually stationary on screen while the zoom level changes.

```lua
-- signature
lurek.province.zoomCameraAt(anchor_x, anchor_y, cam_x, cam_y, old_zoom, new_zoom)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `anchor_x` | `number` | Anchor x in screen space. |
| `anchor_y` | `number` | Anchor y in screen space. |
| `cam_x` | `number` | Current camera x. |
| `cam_y` | `number` | Current camera y. |
| `old_zoom` | `number` | Previous zoom level. |
| `new_zoom` | `number` | Target zoom level. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a New camera x and y after zoom adjustment. |
| `number` | b New camera x and y after zoom adjustment. |

**Example**

```lua
do
    local cam_x = 100
    local cam_y = 80
    local new_cam_x, new_cam_y = lurek.province.zoomCameraAt(400, 300, cam_x, cam_y, 1.0, 2.0)

    print("old camera = " .. tostring(cam_x) .. ", " .. tostring(cam_y))
    print("new camera = " .. tostring(new_cam_x) .. ", " .. tostring(new_cam_y))
end
```

---

## LProvinceRegistry

### `LProvinceRegistry:adjacencies`

Returns all adjacency pairs in the registry. Each entry has `province_a` and `province_b` fields representing two neighboring provinces.

```lua
-- signature
LProvinceRegistry:adjacencies()
```

**Returns**

| Type | Description |
|------|-------------|
| `LProvinceRegistryAdjacenciesResult` | Array of tables with fields: province_a (number), province_b (number). |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("pairs", "assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]

    print("adjacency pairs = " .. tostring(#pairs))
    print("first pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
end
```

---

### `LProvinceRegistry:borderSegments`

Returns all border line segments between adjacent provinces. Each segment is a line from (x0,y0) to (x1,y1) separating province_a from province_b.

```lua
-- signature
LProvinceRegistry:borderSegments()
```

**Returns**

| Type | Description |
|------|-------------|
| `LProvinceRegistryBorderSegmentsResult` | Array of tables with fields: province_a (number), province_b (number), x0 (number), y0 (number), x1 (number), y1 (number). |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("geo_segments", "assets/textures/province_map.png")
    local segments = reg:borderSegments()
    local first = segments[1]

    print("segment count = " .. tostring(#segments))
    print("first pair = " .. tostring(first and first.province_a) .. ", " .. tostring(first and first.province_b))
end
```

---

### `LProvinceRegistry:fitCamera`

Computes camera position and zoom so the entire province map fits within the given screen dimensions.

```lua
-- signature
LProvinceRegistry:fitCamera(screen_w, screen_h, pixel_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `screen_w` | `number` | Screen width in pixels. |
| `screen_h` | `number` | Screen height in pixels. |
| `pixel_size?` | `number` | Size of one map cell in screen pixels (default 1.0). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Camera x, camera y, and zoom factor. |
| `number` | b Camera x, camera y, and zoom factor. |
| `number` | c Camera x, camera y, and zoom factor. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("cam_fit", "assets/textures/province_map.png")
    local cam_x, cam_y, zoom = reg:fitCamera(800, 600, 1.0)

    print("camera x = " .. tostring(cam_x))
    print("camera y = " .. tostring(cam_y))
    print("zoom = " .. tostring(zoom))
end
```

---

### `LProvinceRegistry:getAt`

Returns the province ID at the given grid cell coordinates. Returns 0 if the cell is unowned (sea, wasteland, etc.).

```lua
-- signature
LProvinceRegistry:getAt(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | `number` | Zero-based column index. |
| `y` | `number` | Zero-based row index. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Province ID at (x, y), or 0 for unowned cells. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("spatial", "assets/textures/province_map.png")
    local province_id = reg:getAt(50, 50)

    print("province at 50,50 = " .. tostring(province_id))
    print("province at 0,0 = " .. tostring(reg:getAt(0, 0)))
end
```

---

### `LProvinceRegistry:getBorderClass`

Backward-compatible alias for getBorderType. Returns the border type ID.

```lua
-- signature
LProvinceRegistry:getBorderClass(a, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | `number` | First province ID. |
| `b` | `number` | Second province ID. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Border type ID, or nil. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("border_class_get", "assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]

    reg:registerBorderType(3, { name = "sea", color = { 30, 80, 180, 255 }, thickness = 2.0 })
    if pair then
        reg:setBorderClass(pair.province_a, pair.province_b, 3)
    end

    print("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    print("border class = " .. tostring(pair and reg:getBorderClass(pair.province_a, pair.province_b)))
end
```

---

### `LProvinceRegistry:getBorderPairStyle`

Returns the style override for a specific adjacency pair, or nil when unset.

```lua
-- signature
LProvinceRegistry:getBorderPairStyle(a, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | `number` | First province ID. |
| `b` | `number` | Second province ID. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Style table or nil. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("border_pair_get", "assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]
    local style = nil

    if pair then
        reg:setBorderPairStyle(pair.province_a, pair.province_b, {
            color = { 0.2, 0.8, 0.4, 1.0 },
            thickness = 2.5,
            flags = { "alliance" },
        })
        style = reg:getBorderPairStyle(pair.province_a, pair.province_b)
    end

    print("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    print("thickness = " .. tostring(style and style.thickness))
    print("flag count = " .. tostring(style and style.flags and #style.flags or 0))
end
```

---

### `LProvinceRegistry:getBorderType`

Returns the border type ID (0-255) between two adjacent provinces, or nil if not set.

```lua
-- signature
LProvinceRegistry:getBorderType(a, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | `number` | First province ID. |
| `b` | `number` | Second province ID. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Border type ID, or nil. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("borders_get", "assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]

    reg:registerBorderType(2, { name = "river", color = { 50, 140, 220, 255 }, thickness = 1.5 })
    if pair then
        reg:setBorderType(pair.province_a, pair.province_b, 2)
    end

    print("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    print("border type = " .. tostring(pair and reg:getBorderType(pair.province_a, pair.province_b)))
end
```

---

### `LProvinceRegistry:getChangesSince`

Returns all province changes that occurred after the given revision. Each entry contains the revision number and a change record describing what was modified (political_color, terrain_type, border_style, fog_state, visibility_state, or border_class).

```lua
-- signature
LProvinceRegistry:getChangesSince(revision)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `revision` | `number` | The revision to query from (exclusive). Pass the last known revision to get only new changes. |

**Returns**

| Type | Description |
|------|-------------|
| `LProvinceRegistryGetChangesSinceResult` | Array of change tables, each with a `revision` field and change-specific fields (kind, province_id, etc.). |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("changes_since", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local revision = reg:getRevision()

    if province_id then
        reg:setPoliticalColor(province_id, 1.0, 0.0, 0.0, 1.0)
    end

    local changes = reg:getChangesSince(revision)
    local first_change = changes[1]

    print("change count = " .. tostring(#changes))
    print("first kind = " .. tostring(first_change and first_change.kind))
end
```

---

### `LProvinceRegistry:getHeight`

Returns the height of the province grid in cells (pixels of the source PNG).

```lua
-- signature
LProvinceRegistry:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Grid height in cells. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("info_height", "assets/textures/province_map.png")
    local height = reg:getHeight()

    print("height = " .. tostring(height))
    print("name = " .. reg:getName())
end
```

---

### `LProvinceRegistry:getMapMode`

Returns the name of the currently active map mode.

```lua
-- signature
LProvinceRegistry:getMapMode()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Active mode name. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("map_mode_get", "assets/textures/province_map.png")

    reg:registerMapMode("political_plus", {
        show_labels = true,
        show_borders = true,
        show_roads = true,
        show_capitals = true,
    })
    reg:setMapMode("political_plus")

    print("mode = " .. reg:getMapMode())
end
```

---

### `LProvinceRegistry:getName`

Returns the string name used to identify this registry in the province system.

```lua
-- signature
LProvinceRegistry:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The registry name passed to `newFromPng`. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("test_reg", "assets/textures/province_map.png")

    print("name = " .. reg:getName())
end
```

---

### `LProvinceRegistry:getNeighbors`

Returns a table of province IDs that share a border with the given province.

```lua
-- signature
LProvinceRegistry:getNeighbors(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Province ID to query. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array of neighboring province IDs. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("adj", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local neighbors = province_id and reg:getNeighbors(province_id) or {}

    print("province id = " .. tostring(province_id))
    print("neighbor count = " .. tostring(#neighbors))
end
```

---

### `LProvinceRegistry:getProvince`

Returns a snapshot table describing a single province: its ID, revision, style (political_color, terrain_type, border_style, fog_state, visibility_state), centroid, and custom attributes.

```lua
-- signature
LProvinceRegistry:getProvince(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Province ID to query. |

**Returns**

| Type | Description |
|------|-------------|
| `LProvinceRegistryGetProvinceResult` | Province snapshot table, or nil if the ID does not exist. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("snap", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local snap = province_id and reg:getProvince(province_id) or nil

    print("province_id = " .. tostring(snap and snap.province_id))
    print("revision = " .. tostring(snap and snap.revision))
    print("terrain type = " .. tostring(snap and snap.style and snap.style.terrain_type))
end
```

---

### `LProvinceRegistry:getRevision`

Returns the current change revision counter. Incremented on every mutation (color, terrain, border, fog changes). Use with `getChangesSince` for incremental updates.

```lua
-- signature
LProvinceRegistry:getRevision()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current revision number. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("changes_revision", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local before = reg:getRevision()

    if province_id then
        reg:setPoliticalColor(province_id, 1.0, 0.0, 0.0, 1.0)
    end

    print("revision before = " .. tostring(before))
    print("revision after = " .. tostring(reg:getRevision()))
end
```

---

### `LProvinceRegistry:getWidth`

Returns the width of the province grid in cells (pixels of the source PNG).

```lua
-- signature
LProvinceRegistry:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Grid width in cells. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("info_width", "assets/textures/province_map.png")
    local width = reg:getWidth()

    print("width = " .. tostring(width))
    print("name = " .. reg:getName())
end
```

---

### `LProvinceRegistry:importMetadataFromFiles`

Bulk-imports province metadata (colors, capitals, labels, terrain) from external files (PNG color map, CSV color table, TOML province definitions, marker PNG). Returns a summary of how many provinces were mapped.

```lua
-- signature
LProvinceRegistry:importMetadataFromFiles(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | `table` | Options table with fields: color_map_png (string, required), color_csv (string, required), marker_png (string?), province_toml (string?), water_terrain_tokens (table?), water_terrain_type (number?), land_terrain_type (number?), set_political_colors (boolean?), set_label_text (boolean?), set_capitals (boolean?), set_label_lines (boolean?), marker_options (table?). |

**Returns**

| Type | Description |
|------|-------------|
| `LProvinceRegistryImportMetadataFromFilesResult` | Summary with fields: mapped_provinces (number), capitals_set (number), label_lines_set (number), labels_set (number). |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("meta_import", "content/games/strategy/eu2/map.png")
    local summary = reg:importMetadataFromFiles({
        color_map_png = "content/games/strategy/eu2/map.png",
        marker_png = "content/games/strategy/eu2/map.png",
        color_csv = "content/games/strategy/eu2/prov_cols.csv",
        province_toml = "content/games/strategy/eu2/province.toml",
    })

    print("mapped provinces = " .. tostring(summary.mapped_provinces))
    print("capitals set = " .. tostring(summary.capitals_set))
    print("labels set = " .. tostring(summary.labels_set))
end
```

---

### `LProvinceRegistry:provinceCount`

Returns the total number of distinct provinces in this registry (excluding ID 0).

```lua
-- signature
LProvinceRegistry:provinceCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Count of provinces. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("info_count", "assets/textures/province_map.png")
    local count = reg:provinceCount()

    print("province count = " .. tostring(count))
end
```

---

### `LProvinceRegistry:provinceIds`

Returns a sequential table of all province IDs in this registry.

```lua
-- signature
LProvinceRegistry:provinceIds()
```

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Province ID numbers. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("info_ids", "assets/textures/province_map.png")
    local ids = reg:provinceIds()

    print("id count = " .. tostring(#ids))
    print("first id = " .. tostring(ids[1]))
    print("last id = " .. tostring(ids[#ids]))
end
```

---

### `LProvinceRegistry:provinceSpans`

Returns the raw span data for all provinces. Each span is a horizontal run of cells belonging to one province, useful for custom rendering or spatial analysis.

```lua
-- signature
LProvinceRegistry:provinceSpans()
```

**Returns**

| Type | Description |
|------|-------------|
| `LProvinceRegistryProvinceSpansResult` | Array of tables with fields: province_id (number), y (number), x0 (number), x1 (number). |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("geo_spans", "assets/textures/province_map.png")
    local spans = reg:provinceSpans()
    local first = spans[1]

    print("span count = " .. tostring(#spans))
    print("first span province = " .. tostring(first and first.province_id))
end
```

---

### `LProvinceRegistry:registerBorderType`

Registers a border type config by ID. Defines visual appearance for borders of this type.

```lua
-- signature
LProvinceRegistry:registerBorderType(type_id, config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_id` | `number` | Border type ID (0-255). |
| `config` | `table` | Config table: name (string), color ({r,g,b,a} numbers 0-255), thickness (number), draw_priority (integer?). |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("border_type_register", "assets/textures/province_map.png")
    local pairs = reg:adjacencies()

    reg:registerBorderType(5, { name = "river", color = { 40, 120, 210, 255 }, thickness = 2.0, draw_priority = 1 })

    print("registered type = 5")
    print("adjacency pairs = " .. tostring(#pairs))
end
```

---

### `LProvinceRegistry:registerMapMode`

Registers a named map mode with display configuration. Overwrites if name exists.

```lua
-- signature
LProvinceRegistry:registerMapMode(name, config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Map mode identifier (e.g. "political", "religion", "economy"). |
| `config` | `table` | Config: show_labels (bool?), show_borders (bool?), show_roads (bool?), show_capitals (bool?), show_values (bool?), value_property (string?), color_property (string?), fog_intensity (number?), border_filter (integer[]?). |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("map_mode_register", "assets/textures/province_map.png")

    reg:registerMapMode("economy", {
        show_labels = true,
        show_borders = true,
        show_roads = false,
        show_capitals = true,
        show_values = true,
        value_property = "income",
        color_property = "income_color",
        fog_intensity = 0.25,
        border_filter = { 1, 2 },
    })

    print("registered mode = economy")
    print("current mode = " .. reg:getMapMode())
end
```

---

### `LProvinceRegistry:render`

Renders the province map to the screen using the current camera and style settings. Generates draw commands for fills, borders, labels, and capitals based on the provided options.

```lua
-- signature
LProvinceRegistry:render(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | `table?|Render` | options: map_mode(string?),x/y/zoom/pixel_size/screen_w/screen_h(number?),draw_fills/draw_borders/draw_labels/draw_capitals/draw_roads(boolean?),border_width(number?),zoom_mode("auto"|"strategic" "tactical"), tactical_zoom_threshold (number?), hovered_id/selected_id (integer?). |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("render", "assets/textures/province_map.png")
    local cam_x, cam_y, zoom = reg:fitCamera(800, 600, 1.0)

    reg:render({
        map_mode = "political",
        x = cam_x,
        y = cam_y,
        zoom = zoom,
        pixel_size = 1.0,
        screen_w = 800,
        screen_h = 600,
        draw_fills = true,
        draw_borders = true,
        draw_labels = true,
        draw_capitals = true,
        border_width = 1.5,
        hovered_id = 0,
        selected_id = 0,
    })

    print("rendered registry = " .. reg:getName())
    print("zoom = " .. tostring(zoom))
end
```

---

### `LProvinceRegistry:screenToMap`

Converts screen-space pixel coordinates to map-space floating-point coordinates using the current camera transform.

```lua
-- signature
LProvinceRegistry:screenToMap(screen_x, screen_y, cam_x, cam_y, zoom, pixel_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `screen_x` | `number` | Screen x in pixels. |
| `screen_y` | `number` | Screen y in pixels. |
| `cam_x` | `number` | Camera center x in map space. |
| `cam_y` | `number` | Camera center y in map space. |
| `zoom` | `number` | Current zoom factor. |
| `pixel_size?` | `number` | Cell size in screen pixels (default 1.0). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Map-space x and y. |
| `number` | b Map-space x and y. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("cam_map", "assets/textures/province_map.png")
    local cam_x, cam_y, zoom = reg:fitCamera(800, 600, 1.0)
    local map_x, map_y = reg:screenToMap(400, 300, cam_x, cam_y, zoom, 1.0)

    print("map x = " .. tostring(map_x))
    print("map y = " .. tostring(map_y))
end
```

---

### `LProvinceRegistry:screenToProvince`

Converts screen-space coordinates directly to a province ID. Returns nil if the cursor is outside the map or over an unowned cell.

```lua
-- signature
LProvinceRegistry:screenToProvince(screen_x, screen_y, cam_x, cam_y, zoom, pixel_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `screen_x` | `number` | Screen x in pixels. |
| `screen_y` | `number` | Screen y in pixels. |
| `cam_x` | `number` | Camera center x in map space. |
| `cam_y` | `number` | Camera center y in map space. |
| `zoom` | `number` | Current zoom factor. |
| `pixel_size?` | `number` | Cell size in screen pixels (default 1.0). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Province ID under the cursor, or nil if none. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("cam_province", "assets/textures/province_map.png")
    local cam_x, cam_y, zoom = reg:fitCamera(800, 600, 1.0)
    local province_id = reg:screenToProvince(400, 300, cam_x, cam_y, zoom, 1.0)

    print("province at center = " .. tostring(province_id))
end
```

---

### `LProvinceRegistry:setAttr`

Sets a custom string attribute on a province. Attributes are returned in the `attrs` table of `getProvince` and can store arbitrary game metadata.

```lua
-- signature
LProvinceRegistry:setAttr(id, key, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Province ID. |
| `key` | `string` | Attribute name. |
| `value` | `string` | Attribute value. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the province ID exists. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("attrs", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setAttr(province_id, "owner", "player1")
    end

    print("province_id = " .. tostring(province_id))
    print("applied = " .. tostring(ok))
end
```

---

### `LProvinceRegistry:setBorderClass`

Backward-compatible alias for setBorderType. Sets the border type ID.

```lua
-- signature
LProvinceRegistry:setBorderClass(a, b, border_type)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | `number` | First province ID. |
| `b` | `number` | Second province ID. |
| `border_type` | `number` | Border type ID (0-255). |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("border_class_set", "assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]
    local ok = false

    reg:registerBorderType(4, { name = "contested", color = { 220, 90, 60, 255 }, thickness = 2.5 })
    if pair then
        reg:setBorderClass(pair.province_a, pair.province_b, 4)
        ok = true
    end

    print("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    print("applied = " .. tostring(ok))
end
```

---

### `LProvinceRegistry:setBorderPairStyle`

Sets the style override for a specific adjacency pair, including optional color, thickness, and semantic flags.

```lua
-- signature
LProvinceRegistry:setBorderPairStyle(a, b, style)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | `number` | First province ID. |
| `b` | `number` | Second province ID. |
| `style` | `table|Style` | table with optional fields: color={r,g,b,a},thickness=number,flags=string string[]. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when style was applied. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("border_pair_set", "assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]
    local ok = false

    if pair then
        ok = reg:setBorderPairStyle(pair.province_a, pair.province_b, {
            color = { 1.0, 0.2, 0.2, 1.0 },
            thickness = 3.0,
            flags = { "war", "country" },
        })
    end

    print("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    print("applied = " .. tostring(ok))
end
```

---

### `LProvinceRegistry:setBorderStyle`

Sets the border rendering style index for a province. Controls line thickness, color, or pattern when borders are drawn.

```lua
-- signature
LProvinceRegistry:setBorderStyle(id, border_style)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Province ID. |
| `border_style` | `number` | Border style index (game-defined meaning). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the province ID exists. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("style_border", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setBorderStyle(province_id, 2)
    end

    print("province_id = " .. tostring(province_id))
    print("applied = " .. tostring(ok))
end
```

---

### `LProvinceRegistry:setBorderType`

Sets the border type ID between two adjacent provinces. Register types first with registerBorderType.

```lua
-- signature
LProvinceRegistry:setBorderType(a, b, border_type)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | `number` | First province ID. |
| `b` | `number` | Second province ID. |
| `border_type` | `number` | Border type ID (0-255). |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("borders_set", "assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]

    reg:registerBorderType(1, { name = "coast", color = { 60, 120, 180, 255 }, thickness = 2.0 })
    if pair then
        reg:setBorderType(pair.province_a, pair.province_b, 1)
    end

    print("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    print("border type = " .. tostring(pair and reg:getBorderType(pair.province_a, pair.province_b)))
end
```

---

### `LProvinceRegistry:setCapital`

Sets the capital marker position for a province. The capital is drawn as a small icon during `render` when `draw_capitals` is enabled.

```lua
-- signature
LProvinceRegistry:setCapital(id, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Province ID. |
| `x` | `number` | Capital x position in map space. |
| `y` | `number` | Capital y position in map space. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the province ID exists. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("labels_capital", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setCapital(province_id, 30, 25)
    end

    print("province_id = " .. tostring(province_id))
    print("applied = " .. tostring(ok))
end
```

---

### `LProvinceRegistry:setFogState`

Sets a fog-of-war byte for a province. This value is game-defined metadata and can be used by scripts/map modes.

```lua
-- signature
LProvinceRegistry:setFogState(id, fog_state)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Province ID. |
| `fog_state` | `number` | Fog state value (game-defined meaning). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the province ID exists. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("style_fog", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setFogState(province_id, 1)
    end

    print("province_id = " .. tostring(province_id))
    print("applied = " .. tostring(ok))
end
```

---

### `LProvinceRegistry:setLabelLine`

Sets the label baseline for a province. The label text is rendered along the line from (ax,ay) to (bx,by), allowing curved or angled province names.

```lua
-- signature
LProvinceRegistry:setLabelLine(id, ax, ay, bx, by)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Province ID. |
| `ax` | `number` | Start x of the label line in map space. |
| `ay` | `number` | Start y of the label line in map space. |
| `bx` | `number` | End x of the label line in map space. |
| `by` | `number` | End y of the label line in map space. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the province ID exists. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("labels_line", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setLabelLine(province_id, 10, 20, 50, 20)
    end

    print("province_id = " .. tostring(province_id))
    print("applied = " .. tostring(ok))
end
```

---

### `LProvinceRegistry:setLabelText`

Sets the display name text for a province. Rendered on the map when `draw_labels` is enabled in `render` options.

```lua
-- signature
LProvinceRegistry:setLabelText(id, text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Province ID. |
| `text` | `string` | Province display name. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the province ID exists. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("labels_text", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setLabelText(province_id, "Nordland")
    end

    print("province_id = " .. tostring(province_id))
    print("applied = " .. tostring(ok))
end
```

---

### `LProvinceRegistry:setMapMode`

Switches the active map mode to a previously registered mode name.

```lua
-- signature
LProvinceRegistry:setMapMode(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Mode name to activate. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if mode exists and was activated. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("map_mode_set", "assets/textures/province_map.png")

    reg:registerMapMode("terrain_view", {
        show_labels = true,
        show_borders = true,
        show_roads = false,
        show_capitals = true,
        fog_intensity = 0.4,
    })

    local ok = reg:setMapMode("terrain_view")

    print("applied = " .. tostring(ok))
    print("mode = " .. reg:getMapMode())
end
```

---

### `LProvinceRegistry:setPoliticalColor`

Sets the political map color for a province. Used in political map mode rendering and change tracking.

```lua
-- signature
LProvinceRegistry:setPoliticalColor(id, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Province ID. |
| `r` | `number` | Red component (0.0–1.0). |
| `g` | `number` | Green component (0.0–1.0). |
| `b` | `number` | Blue component (0.0–1.0). |
| `a?` | `number` | Alpha component (default 1.0). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the province ID exists. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("colors", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setPoliticalColor(province_id, 0.8, 0.2, 0.2, 1.0)
    end

    print("province_id = " .. tostring(province_id))
    print("applied = " .. tostring(ok))
end
```

---

### `LProvinceRegistry:setTerrainType`

Sets the terrain type index for a province. Terrain type controls which fill color or texture is used in terrain map mode.

```lua
-- signature
LProvinceRegistry:setTerrainType(id, terrain_type)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Province ID. |
| `terrain_type` | `number` | Terrain type index (game-defined meaning). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the province ID exists. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("style_terrain", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setTerrainType(province_id, 1)
    end

    print("province_id = " .. tostring(province_id))
    print("applied = " .. tostring(ok))
end
```

---

### `LProvinceRegistry:setVisibilityState`

Sets the render visibility state for a province. `0` = hidden (no fill/border/capital/label), `1` = discovered (gray fill only), `2+` = fully visible.

```lua
-- signature
LProvinceRegistry:setVisibilityState(id, visibility_state)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Province ID. |
| `visibility_state` | `number` | Visibility state byte. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the province ID exists. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("style_visibility", "assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setVisibilityState(province_id, 2)
    end

    print("province_id = " .. tostring(province_id))
    print("applied = " .. tostring(ok))
end
```

---

### `LProvinceRegistry:type`

Returns the type name string for this userdata object.

```lua
-- signature
LProvinceRegistry:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Always "LProvinceRegistry". |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("typed_name", "assets/textures/province_map.png")

    print("type = " .. reg:type())
end
```

---

### `LProvinceRegistry:typeOf`

Checks whether this object matches the given type name. Returns true for "LProvinceRegistry" and "Object".

```lua
-- signature
LProvinceRegistry:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True if the name matches. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("typed_check", "assets/textures/province_map.png")

    print("is registry = " .. tostring(reg:typeOf("LProvinceRegistry")))
    print("is object = " .. tostring(reg:typeOf("LObject")))
end
```

---
