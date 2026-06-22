# Province

## Purpose

Simulates region maps decoded from color-coded PNG cartographic assets.

## When To Use

- Topology, registries, imports, labels, caches, route helpers, property layers, render bridges, and view transforms matter because a province map is more than a color fill; it is a structured graph of regions with state and presentation rules.
- Province identity is central from the user perspective. Scripts need to ask which region an area belongs to, how regions connect, what properties they carry, and how those answers change over time.
- Ownership, labels, borders, and view helpers make the module useful for strategy maps, campaign layers, regional simulations, and UI-heavy territory systems where territory data must be both playable and readable.

## Minimal Example

Example block: `lurek.province.newFromPng`

```lua
do
    local reg = province_registry("new_from_png")
    local width = reg:getWidth()
    local height = reg:getHeight()
    local ids = reg:provinceIds()
    local first_id = ids[1]
    local first_neighbors = first_id and #reg:getNeighbors(first_id) or 0
    province_log("campaign map loaded name=" .. reg:getName() .. " size=" .. tostring(width) .. "x" .. tostring(height) .. " provinces=" .. tostring(#ids) .. " frontier_neighbors=" .. tostring(first_neighbors))
end
```

## Common Patterns

- Start with `lurek.province.clearProperties` when exploring this module.
- Start with `lurek.province.exists` when exploring this module.
- Start with `lurek.province.get` when exploring this module.
- Start with `lurek.province.getActive` when exploring this module.
- Start with `lurek.province.getAttr` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- The `province` module is the engine's territory-region system for users who want named areas, borders, ownership, routing, and province-like gameplay state to behave as one native feature.
- Topology, registries, imports, labels, caches, route helpers, property layers, render bridges, and view transforms matter because a province map is more than a color fill; it is a structured graph of regions with state and presentation rules.
- Province identity is central from the user perspective. Scripts need to ask which region an area belongs to, how regions connect, what properties they carry, and how those answers change over time.
- Ownership, labels, borders, and view helpers make the module useful for strategy maps, campaign layers, regional simulations, and UI-heavy territory systems where territory data must be both playable and readable.
- Routing and adjacency behavior extend the feature from passive map metadata into active game logic, because movement, logistics, diplomacy, and campaign progression often depend on region-to-region relationships.
- Property layers, events, and interaction helpers make the module useful both as a gameplay authority for territory logic and as a map-facing surface for highlighting, picking, overlays, and editor-style inspection.
- Import and cache support matter because province-heavy projects often operate on large authored maps where region definitions, border relationships, and property tables must be reused efficiently at runtime instead of reparsed or recomputed ad hoc.
- Region properties broaden the feature beyond simple ownership maps. Provinces often carry economy, culture, terrain, danger, visibility, supply, or event flags, and the module gives those layers one shared place to live and change over time.
- That shared province identity is what keeps strategy logic, labels, overlays, and player interaction pointed at the same region model instead of drifting apart.
- Picking and view-transform helpers are especially important for strategy interfaces and editors, where the province system must translate user interaction into stable region identity rather than acting as a query-by-id database hidden behind other UI layers.
- This is why `province` works well for campaign maps, strategy regions, and territory editors.
- It also gives simulation and map UI one shared authority for ownership and adjacency.
- Read `province` as the territory authority of the engine. Other systems may navigate, draw, or summarize provinces, but this module decides how provinces are represented, connected, labeled, updated, and queried with one stable region model.

This module primarily collaborates with `image`, `render`, `runtime`. Its responsibility should stay inside the `Edge/Integration` group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.province.clearProperties`

Removes all properties, attributes, and flags for a province.

```lua
lurek.province.clearProperties(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Province ID. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("prop_clear", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setProperty(province_id, "temp_val", 42)
        lurek.province.clearProperties(province_id)
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("temp_val = " .. tostring(province_id and lurek.province.getProperty(province_id, "temp_val")))
end
```

---

### `lurek.province.exists`

Checks whether a province registry with the given name exists.

```lua
lurek.province.exists(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Registry name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the registry exists. |

**Example**

```lua
do
    local reg = province_registry("exists")
    local name = reg:getName()
    local exists_now = lurek.province.exists(name)
    local fetched = lurek.province.get(name)
    local missing = lurek.province.exists(name .. "_missing")
    province_log("registry lookup exists=" .. tostring(exists_now) .. " fetched=" .. tostring(fetched ~= nil) .. " missing_variant=" .. tostring(missing) .. " name=" .. tostring(name))
end
```

---

### `lurek.province.get`

Retrieves an existing province registry by name. Returns nil if no registry with that name has been created.

```lua
lurek.province.get(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Registry name to look up. |

**Returns**

| Type | Description |
|------|-------------|
| [LProvinceRegistry](#lprovinceregistry) | The registry handle, or nil if not found. |

**Example**

```lua
do
    local created = province_registry("get")
    local name = created:getName()
    local reg = lurek.province.get(name)
    local province_total = reg and reg:provinceCount() or 0
    local width = reg and reg:getWidth() or 0
    province_log("registry fetch by name found=" .. tostring(reg ~= nil) .. " requested=" .. tostring(name) .. " fetched_name=" .. tostring(reg and reg:getName()) .. " provinces=" .. tostring(province_total) .. " width=" .. tostring(width))
end
```

---

### `lurek.province.getActive`

Returns the currently active province registry, or nil if none is set.

```lua
lurek.province.getActive()
```

**Returns**

| Type | Description |
|------|-------------|
| [LProvinceRegistry](#lprovinceregistry) | The active registry handle, or nil. |

**Example**

```lua
do
    lurek.province.newFromPng("check_reg_active", "content/examples/assets/textures/province_map.png")
    lurek.province.setActive("check_reg_active")

    local reg = lurek.province.getActive()

    province_log("active exists = " .. tostring(reg ~= nil))
    province_log("active name = " .. tostring(reg and reg:getName()))
end
```

---

### `lurek.province.getAttr`

Gets a string attribute from a province. Returns nil if not set.

```lua
lurek.province.getAttr(id, key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Province ID. |
| `key` | string | Attribute name. |

**Returns**

| Type | Description |
|------|-------------|
| string | The stored value, or nil. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("attr_get", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setAttr(province_id, "climate", "temperate")
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("climate = " .. tostring(province_id and lurek.province.getAttr(province_id, "climate")))
end
```

---

### `lurek.province.getProperty`

Gets a numeric property from a province. Returns nil if not set.

```lua
lurek.province.getProperty(id, key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Province ID. |
| `key` | string | Property name. |

**Returns**

| Type | Description |
|------|-------------|
| number | The stored value, or nil. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("prop_get", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setProperty(province_id, "population", 50000)
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("population = " .. tostring(province_id and lurek.province.getProperty(province_id, "population")))
end
```

---

### `lurek.province.hasFlag`

Checks whether a flag bit is set on a province.

```lua
lurek.province.hasFlag(id, bit)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Province ID. |
| `bit` | number | Flag bit index (0-63). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the flag bit is set. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("flag_get", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setFlag(province_id, 2, true)
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("flag 2 = " .. tostring(province_id and lurek.province.hasFlag(province_id, 2)))
end
```

---

### `lurek.province.newFromPng`

Creates a new province registry by loading a color-coded PNG where each unique color represents a distinct province. The PNG is parsed into a grid and adjacencies are computed automatically.

```lua
lurek.province.newFromPng(name, png_path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Unique registry name for later retrieval. |
| `png_path` | string | Path to the province map PNG (relative to game directory or absolute). |

**Returns**

| Type | Description |
|------|-------------|
| [LProvinceRegistry](#lprovinceregistry) | The newly created registry handle. |

**Example**

```lua
do
    local reg = province_registry("new_from_png")
    local width = reg:getWidth()
    local height = reg:getHeight()
    local ids = reg:provinceIds()
    local first_id = ids[1]
    local first_neighbors = first_id and #reg:getNeighbors(first_id) or 0
    province_log("campaign map loaded name=" .. reg:getName() .. " size=" .. tostring(width) .. "x" .. tostring(height) .. " provinces=" .. tostring(#ids) .. " frontier_neighbors=" .. tostring(first_neighbors))
end
```

---

### `lurek.province.remove`

Removes a province registry by name and clears the active registry if it was the one removed. Returns true if a registry was actually removed.

```lua
lurek.province.remove(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Registry name to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the registry existed and was removed. |

**Example**

```lua
do
    local reg = province_registry("remove")
    local name = reg:getName()
    local existed_before = lurek.province.exists(name)
    local removed = lurek.province.remove(name)
    local exists_after = lurek.province.exists(name)
    province_log("registry teardown existed_before=" .. tostring(existed_before) .. " removed=" .. tostring(removed) .. " exists_after=" .. tostring(exists_after) .. " name=" .. tostring(name))
end
```

---

### `lurek.province.sanitizeMarkedPng`

Pre-processes a marker PNG by replacing capital and label marker pixels with the surrounding province color. Outputs a cleaned PNG suitable for `newFromPng`. Returns a summary of pixel replacements.

```lua
lurek.province.sanitizeMarkedPng(input_png, output_png, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input_png` | string | Path to the source marker PNG. |
| `output_png` | string | Path to write the sanitized output PNG. |
| `opts?` | table | Marker detection thresholds: capital_min (number?), label_r_min (number?), label_g_max (number?), label_b_min (number?), search_radius (number?). |

**Returns**

| Type | Description |
|------|-------------|
| LProvinceSanitizeMarkedPngResult | Summary with fields: replaced_pixels (number), unresolved_pixels (number). |

**Example**

```lua
do
    local summary = lurek.province.sanitizeMarkedPng(
        "content/examples/assets/images/sample_texture.png",
        "save/province_sanitized.png",
        {}
    )

    province_log("replaced pixels = " .. tostring(summary.replaced_pixels))
    province_log("unresolved pixels = " .. tostring(summary.unresolved_pixels))
end
```

---

### `lurek.province.setActive`

Sets the named registry as the active province registry. Returns false if no registry with that name exists.

```lua
lurek.province.setActive(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Registry name to activate. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the registry was found and activated. |

**Example**

```lua
do
    lurek.province.newFromPng("map_a", "content/examples/assets/textures/province_map.png")
    lurek.province.newFromPng("map_b", "content/examples/assets/textures/province_map.png")

    local set_a = lurek.province.setActive("map_a")
    local active_a = lurek.province.getActive()
    local set_b = lurek.province.setActive("map_b")
    local active_b = lurek.province.getActive()

    province_log("set map_a = " .. tostring(set_a) .. " -> " .. tostring(active_a and active_a:getName()))
    province_log("set map_b = " .. tostring(set_b) .. " -> " .. tostring(active_b and active_b:getName()))
end
```

---

### `lurek.province.setAttr`

Sets a string attribute on a province.

```lua
lurek.province.setAttr(id, key, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Province ID. |
| `key` | string | Attribute name. |
| `value` | string | String value to store. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("attr_set", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setAttr(province_id, "terrain", "forest")
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("terrain = " .. tostring(province_id and lurek.province.getAttr(province_id, "terrain")))
end
```

---

### `lurek.province.setFlag`

Sets a single flag bit (0-63) on a province.

```lua
lurek.province.setFlag(id, bit, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Province ID. |
| `bit` | number | Flag bit index (0-63). |
| `value` | boolean | True to set, false to clear. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("flag_set", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setFlag(province_id, 1, true)
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("flag 1 = " .. tostring(province_id and lurek.province.hasFlag(province_id, 1)))
end
```

---

### `lurek.province.setProperty`

Sets a numeric property on a province. Game logic defines the semantics of each key.

```lua
lurek.province.setProperty(id, key, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Province ID. |
| `key` | string | Property name. |
| `value` | number | Numeric value to store. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("prop_set", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]

    if province_id then
        lurek.province.setProperty(province_id, "tax_rate", 0.15)
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("tax_rate = " .. tostring(province_id and lurek.province.getProperty(province_id, "tax_rate")))
end
```

---

### `lurek.province.zoomCameraAt`

Computes new camera position after zooming centered on an anchor point. Keeps the anchor point visually stationary on screen while the zoom level changes.

```lua
lurek.province.zoomCameraAt(anchor_x, anchor_y, cam_x, cam_y, old_zoom, new_zoom)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `anchor_x` | number | Anchor x in screen space. |
| `anchor_y` | number | Anchor y in screen space. |
| `cam_x` | number | Current camera x. |
| `cam_y` | number | Current camera y. |
| `old_zoom` | number | Previous zoom level. |
| `new_zoom` | number | Target zoom level. |

**Returns**

| Type | Description |
|------|-------------|
| number | New camera x and y after zoom adjustment. (value 1). |
| number | New camera x and y after zoom adjustment. (value 2). |

**Example**

```lua
do
    local cam_x = 100
    local cam_y = 80
    local new_cam_x, new_cam_y = lurek.province.zoomCameraAt(400, 300, cam_x, cam_y, 1.0, 2.0)

    province_log("old camera = " .. tostring(cam_x) .. ", " .. tostring(cam_y))
    province_log("new camera = " .. tostring(new_cam_x) .. ", " .. tostring(new_cam_y))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LProvinceRegistry](#lprovinceregistry)

## LProvinceRegistry

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LProvinceRegistry:adjacencies`

Returns all adjacency pairs in the registry. Each entry has `province_a` and `province_b` fields representing two neighboring provinces.

```lua
LProvinceRegistry:adjacencies()
```

**Returns**

| Type | Description |
|------|-------------|
| LProvinceRegistryAdjacenciesResult | Array of tables with fields: province_a (number), province_b (number). |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("pairs", "content/examples/assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]

    province_log("adjacency pairs = " .. tostring(#pairs))
    province_log("first pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
end
```

---

#### `LProvinceRegistry:borderSegments`

Returns all border line segments between adjacent provinces. Each segment is a line from (x0,y0) to (x1,y1) separating province_a from province_b.

```lua
LProvinceRegistry:borderSegments()
```

**Returns**

| Type | Description |
|------|-------------|
| LProvinceRegistryBorderSegmentsResult | Array of tables with fields: province_a (number), province_b (number), x0 (number), y0 (number), x1 (number), y1 (number). |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("geo_segments", "content/examples/assets/textures/province_map.png")
    local segments = reg:borderSegments()
    local first = segments[1]

    province_log("segment count = " .. tostring(#segments))
    province_log("first pair = " .. tostring(first and first.province_a) .. ", " .. tostring(first and first.province_b))
end
```

---

#### `LProvinceRegistry:findIsolatedProvinces`

Returns provinces that have no adjacent province with the same owner attribute.

```lua
LProvinceRegistry:findIsolatedProvinces(owner_attr)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `owner_attr` | string | Attribute key (for example `faction`). |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array of isolated province ids. |

**Example**

```lua
do
    local reg = province_registry("isolated", "content/examples/assets/province/map.png")
    local ids = reg:provinceIds()
    local a = ids[1]
    local b = ids[2] or a
    local c = ids[3] or b
    if a then reg:setAttr(a, "faction", "player") end
    if b then reg:setAttr(b, "faction", "enemy") end
    if c then reg:setAttr(c, "faction", "player") end
    local isolated = reg:findIsolatedProvinces("faction")
    province_log("faction isolation isolated=" .. tostring(isolated and #isolated or 0) .. " seeded_ids=" .. tostring(a) .. "," .. tostring(b) .. "," .. tostring(c))
end
```

---

#### `LProvinceRegistry:findRoute`

Finds a route between two provinces using BFS or Dijkstra when `cost_fn` is supplied.

```lua
LProvinceRegistry:findRoute(from_id, to_id, cost_fn)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_id` | number | Start province id. |
| `to_id` | number | Target province id. |
| `cost_fn?` | function | Optional cost callback `fn(from_id, to_id) -> number`. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of province ids from start to target; nil when unreachable. |

**Example**

```lua
do
    local reg = province_registry("find_route", "content/examples/assets/province/map.png")
    local ids = reg:provinceIds()
    local from_id = ids[1]
    local to_id = ids[#ids] or from_id
    local route = (from_id and to_id) and reg:findRoute(from_id, to_id, function(a, b) return a == b and 0.5 or 1.0 end) or nil
    local hop_count = route and #route or 0
    province_log("supply route search from=" .. tostring(from_id) .. " to=" .. tostring(to_id) .. " hops=" .. tostring(hop_count) .. " reachable=" .. tostring(route ~= nil))
end
```

---

#### `LProvinceRegistry:findRoutes`

Finds routes for a batch of `{from, to}` pairs.

```lua
LProvinceRegistry:findRoutes(pairs, cost_fn)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pairs` | table | Array of `{from=integer, to=integer}` tables. |
| `cost_fn?` | function | Optional cost callback `fn(from_id, to_id) -> number?`. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of route arrays (or nil for unreachable entries). |

**Example**

```lua
do
    local reg = province_registry("find_routes", "content/examples/assets/province/map.png")
    local ids = reg:provinceIds()
    local pairs = { { from = ids[1], to = ids[2] or ids[1] }, { from = ids[1], to = ids[#ids] or ids[1] } }
    local routes = reg:findRoutes(pairs, function(a, b) return a == b and 0.5 or 1.0 end)
    local first_route = routes and routes[1] or nil
    province_log("batch route plan requests=" .. tostring(#pairs) .. " result_rows=" .. tostring(routes and #routes or 0) .. " first_hops=" .. tostring(first_route and #first_route or 0))
end
```

---

#### `LProvinceRegistry:fitCamera`

Computes camera position and zoom so the entire province map fits within the given screen dimensions.

```lua
LProvinceRegistry:fitCamera(screen_w, screen_h, pixel_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `screen_w` | number | Screen width in pixels. |
| `screen_h` | number | Screen height in pixels. |
| `pixel_size?` | number | Size of one map cell in screen pixels (default 1.0). |

**Returns**

| Type | Description |
|------|-------------|
| number | Camera x; camera y; and zoom factor. (value 1). |
| number | Camera x; camera y; and zoom factor. (value 2). |
| number | Camera x; camera y; and zoom factor. (value 3). |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("cam_fit", "content/examples/assets/textures/province_map.png")
    local cam_x, cam_y, zoom = reg:fitCamera(800, 600, 1.0)

    province_log("camera x = " .. tostring(cam_x))
    province_log("camera y = " .. tostring(cam_y))
    province_log("zoom = " .. tostring(zoom))
end
```

---

#### `LProvinceRegistry:getAt`

Returns the province ID at the given grid cell coordinates. Returns 0 if the cell is unowned (sea, wasteland, etc.).

```lua
LProvinceRegistry:getAt(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Zero-based column index. |
| `y` | number | Zero-based row index. |

**Returns**

| Type | Description |
|------|-------------|
| number | Province ID at (x, y), or 0 for unowned cells. |

**Example**

```lua
do
    local reg = province_registry("get_at")
    local scout_x = 50
    local scout_y = 50
    local hovered_id = reg:getAt(scout_x, scout_y)
    local coast_id = reg:getAt(0, 0)
    local hovered_snap = hovered_id and hovered_id ~= 0 and reg:getProvince(hovered_id) or nil
    province_log("cell probe scout_x=" .. tostring(scout_x) .. " scout_y=" .. tostring(scout_y) .. " hovered_id=" .. tostring(hovered_id) .. " hovered_revision=" .. tostring(hovered_snap and hovered_snap.revision) .. " origin_id=" .. tostring(coast_id))
end
```

---

#### `LProvinceRegistry:getBorderClass`

Backward-compatible alias for getBorderType. Returns the border type ID.

```lua
LProvinceRegistry:getBorderClass(a, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | First province ID. |
| `b` | number | Second province ID. |

**Returns**

| Type | Description |
|------|-------------|
| number | Border type ID, or nil. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("border_class_get", "content/examples/assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]

    reg:registerBorderType(3, { name = "sea", color = { 30, 80, 180, 255 }, thickness = 2.0 })
    if pair then
        reg:setBorderClass(pair.province_a, pair.province_b, 3)
    end

    province_log("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    province_log("border class = " .. tostring(pair and reg:getBorderClass(pair.province_a, pair.province_b)))
end
```

---

#### `LProvinceRegistry:getBorderPairStyle`

Returns the style override for a specific adjacency pair, or nil when unset.

```lua
LProvinceRegistry:getBorderPairStyle(a, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | First province ID. |
| `b` | number | Second province ID. |

**Returns**

| Type | Description |
|------|-------------|
| table | Style table or nil. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("border_pair_get", "content/examples/assets/textures/province_map.png")
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

    province_log("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    province_log("thickness = " .. tostring(style and style.thickness))
    province_log("flag count = " .. tostring(style and style.flags and #style.flags or 0))
end
```

---

#### `LProvinceRegistry:getBorderType`

Returns the border type ID (0-255) between two adjacent provinces, or nil if not set.

```lua
LProvinceRegistry:getBorderType(a, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | First province ID. |
| `b` | number | Second province ID. |

**Returns**

| Type | Description |
|------|-------------|
| number | Border type ID, or nil. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("borders_get", "content/examples/assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]

    reg:registerBorderType(2, { name = "river", color = { 50, 140, 220, 255 }, thickness = 1.5 })
    if pair then
        reg:setBorderType(pair.province_a, pair.province_b, 2)
    end

    province_log("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    province_log("border type = " .. tostring(pair and reg:getBorderType(pair.province_a, pair.province_b)))
end
```

---

#### `LProvinceRegistry:getChangesSince`

Returns all province changes that occurred after the given revision. Each entry contains the revision number and a change record describing what was modified (political_color, terrain_type, border_style, fog_state, visibility_state, or border_class).

```lua
LProvinceRegistry:getChangesSince(revision)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `revision` | number | The revision to query from (exclusive). Pass the last known revision to get only new changes. |

**Returns**

| Type | Description |
|------|-------------|
| LProvinceRegistryGetChangesSinceResult | Array of change tables, each with a `revision` field and change-specific fields (kind, province_id, etc.). |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("changes_since", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local revision = reg:getRevision()

    if province_id then
        reg:setPoliticalColor(province_id, 1.0, 0.0, 0.0, 1.0)
    end

    local changes = reg:getChangesSince(revision)
    local first_change = changes[1]

    province_log("change count = " .. tostring(#changes))
    province_log("first kind = " .. tostring(first_change and first_change.kind))
end
```

---

#### `LProvinceRegistry:getConnectedComponents`

Returns connected components in the province adjacency graph.

```lua
LProvinceRegistry:getConnectedComponents()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of arrays of province ids. |

**Example**

```lua
do
    local reg = province_registry("components", "content/examples/assets/province/map.png")
    local components = reg:getConnectedComponents()
    local first_component = components[1] or {}
    local province_total = reg:provinceCount()
    local first_size = #first_component
    local covers_all = first_size <= province_total
    province_log("graph components groups=" .. tostring(#components) .. " first_group_size=" .. tostring(first_size) .. " province_total=" .. tostring(province_total) .. " sane=" .. tostring(covers_all))
end
```

---

#### `LProvinceRegistry:getHeight`

Returns the height of the province grid in cells (pixels of the source PNG).

```lua
LProvinceRegistry:getHeight()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Grid height in cells. |

**Example**

```lua
do
    local reg = province_registry("get_height")
    local height = reg:getHeight()
    local width = reg:getWidth()
    local screen_h = 600
    local row_scale = height > 0 and screen_h / height or 0
    local ids = reg:provinceIds()
    province_log("atlas height for viewport height=" .. tostring(height) .. " width=" .. tostring(width) .. " provinces=" .. tostring(#ids) .. " screen_rows_per_map_row=" .. tostring(row_scale))
end
```

---

#### `LProvinceRegistry:getMapMode`

Returns the name of the currently active map mode.

```lua
LProvinceRegistry:getMapMode()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Active mode name. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("map_mode_get", "content/examples/assets/textures/province_map.png")

    reg:registerMapMode("political_plus", {
        show_labels = true,
        show_borders = true,
        show_roads = true,
        show_capitals = true,
    })
    reg:setMapMode("political_plus")

    province_log("mode = " .. reg:getMapMode())
end
```

---

#### `LProvinceRegistry:getName`

Returns the string name used to identify this registry in the province system.

```lua
LProvinceRegistry:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The registry name passed to `newFromPng`. |

**Example**

```lua
do
    local reg = province_registry("get_name")
    local name = reg:getName()
    local set_active = lurek.province.setActive(name)
    local active = lurek.province.getActive()
    local provinces = reg:provinceCount()
    province_log("registry naming active_set=" .. tostring(set_active) .. " name=" .. tostring(name) .. " active_name=" .. tostring(active and active:getName()) .. " provinces=" .. tostring(provinces))
end
```

---

#### `LProvinceRegistry:getNeighbors`

Returns a table of province IDs that share a border with the given province.

```lua
LProvinceRegistry:getNeighbors(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Province ID to query. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array of neighboring province IDs. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("adj", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local neighbors = province_id and reg:getNeighbors(province_id) or {}

    province_log("province id = " .. tostring(province_id))
    province_log("neighbor count = " .. tostring(#neighbors))
end
```

---

#### `LProvinceRegistry:getProvince`

Returns a snapshot table describing a single province: its ID, revision, style (political_color, terrain_type, border_style, fog_state, visibility_state), centroid, and custom attributes.

```lua
LProvinceRegistry:getProvince(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Province ID to query. |

**Returns**

| Type | Description |
|------|-------------|
| LProvinceRegistryGetProvinceResult | Province snapshot table, or nil if the ID does not exist. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("snap", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local snap = province_id and reg:getProvince(province_id) or nil

    province_log("province_id = " .. tostring(snap and snap.province_id))
    province_log("revision = " .. tostring(snap and snap.revision))
    province_log("terrain type = " .. tostring(snap and snap.style and snap.style.terrain_type))
end
```

---

#### `LProvinceRegistry:getRevision`

Returns the current change revision counter. Incremented on every mutation (color, terrain, border, fog changes). Use with `getChangesSince` for incremental updates.

```lua
LProvinceRegistry:getRevision()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current revision number. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("changes_revision", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local before = reg:getRevision()

    if province_id then
        reg:setPoliticalColor(province_id, 1.0, 0.0, 0.0, 1.0)
    end

    province_log("revision before = " .. tostring(before))
    province_log("revision after = " .. tostring(reg:getRevision()))
end
```

---

#### `LProvinceRegistry:getWidth`

Returns the width of the province grid in cells (pixels of the source PNG).

```lua
LProvinceRegistry:getWidth()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Grid width in cells. |

**Example**

```lua
do
    local reg = province_registry("get_width")
    local width = reg:getWidth()
    local height = reg:getHeight()
    local pixel_area = width * height
    local provinces = reg:provinceCount()
    local density = provinces > 0 and pixel_area / provinces or 0
    province_log("atlas width for campaign layout width=" .. tostring(width) .. " height=" .. tostring(height) .. " avg_pixels_per_province=" .. tostring(density))
end
```

---

#### `LProvinceRegistry:importMetadataFromFiles`

Bulk-imports province metadata (colors, capitals, labels, terrain) from external files (PNG color map, CSV color table, TOML province definitions, marker PNG). Returns a summary of how many provinces were mapped.

```lua
LProvinceRegistry:importMetadataFromFiles(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | Options table with fields: color_map_png (string, required), color_csv (string, required), marker_png (string?), province_toml (string?), water_terrain_tokens (table?), water_terrain_type (number?), land_terrain_type (number?), set_political_colors (boolean?), set_label_text (boolean?), set_capitals (boolean?), set_label_lines (boolean?), marker_options (table?). |

**Returns**

| Type | Description |
|------|-------------|
| LProvinceRegistryImportMetadataFromFilesResult | Summary with fields: mapped_provinces (number), capitals_set (number), label_lines_set (number), labels_set (number). |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("meta_import", "content/examples/assets/province/map.png")
    local summary = reg:importMetadataFromFiles({
        color_map_png = "content/examples/assets/province/map.png",
        marker_png = "content/examples/assets/province/map.png",
        color_csv = "content/examples/assets/province/prov_cols.csv",
        province_toml = "content/examples/assets/province/province.toml",
    })

    province_log("mapped provinces = " .. tostring(summary.mapped_provinces))
    province_log("capitals set = " .. tostring(summary.capitals_set))
    province_log("labels set = " .. tostring(summary.labels_set))
end
```

---

#### `LProvinceRegistry:isConnected`

Returns true when there is at least one route between two provinces.

```lua
LProvinceRegistry:isConnected(from_id, to_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_id` | number | Start province id. |
| `to_id` | number | Target province id. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when connected. |

**Example**

```lua
do
    local reg = province_registry("is_connected", "content/examples/assets/province/map.png")
    local ids = reg:provinceIds()
    local from_id = ids[1]
    local to_id = ids[2] or from_id
    local connected = (from_id and to_id) and reg:isConnected(from_id, to_id) or false
    local route = connected and reg:findRoute(from_id, to_id) or nil
    province_log("frontline connectivity from=" .. tostring(from_id) .. " to=" .. tostring(to_id) .. " connected=" .. tostring(connected) .. " route_hops=" .. tostring(route and #route or 0))
end
```

---

#### `LProvinceRegistry:provinceCount`

Returns the total number of distinct provinces in this registry (excluding ID 0).

```lua
LProvinceRegistry:provinceCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Count of provinces. |

**Example**

```lua
do
    local reg = province_registry("province_count")
    local ids = reg:provinceIds()
    local count = reg:provinceCount()
    local first_id = ids[1]
    local first_neighbors = first_id and reg:getNeighbors(first_id) or {}
    local matches_id_list = count == #ids
    province_log("campaign summary provinces=" .. tostring(count) .. " ids_listed=" .. tostring(#ids) .. " first_frontier_size=" .. tostring(#first_neighbors) .. " counts_match=" .. tostring(matches_id_list))
end
```

---

#### `LProvinceRegistry:provinceIds`

Returns a sequential table of all province IDs in this registry.

```lua
LProvinceRegistry:provinceIds()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Province ID numbers. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("info_ids", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()

    province_log("id count = " .. tostring(#ids))
    province_log("first id = " .. tostring(ids[1]))
    province_log("last id = " .. tostring(ids[#ids]))
end
```

---

#### `LProvinceRegistry:provinceSpans`

Returns the raw span data for all provinces. Each span is a horizontal run of cells belonging to one province, useful for custom rendering or spatial analysis.

```lua
LProvinceRegistry:provinceSpans()
```

**Returns**

| Type | Description |
|------|-------------|
| LProvinceRegistryProvinceSpansResult | Array of tables with fields: province_id (number), y (number), x0 (number), x1 (number). |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("geo_spans", "content/examples/assets/textures/province_map.png")
    local spans = reg:provinceSpans()
    local first = spans[1]

    province_log("span count = " .. tostring(#spans))
    province_log("first span province = " .. tostring(first and first.province_id))
end
```

---

#### `LProvinceRegistry:registerBorderType`

Registers a border type config by ID. Defines visual appearance for borders of this type.

```lua
LProvinceRegistry:registerBorderType(type_id, config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_id` | number | Border type ID (0-255). |
| `config` | table | Config table: name (string), color ({r,g,b,a} numbers 0-255), thickness (number), draw_priority (integer?). |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("border_type_register", "content/examples/assets/textures/province_map.png")
    local pairs = reg:adjacencies()

    reg:registerBorderType(5, { name = "river", color = { 40, 120, 210, 255 }, thickness = 2.0, draw_priority = 1 })

    province_log("registered type = 5")
    province_log("adjacency pairs = " .. tostring(#pairs))
end
```

---

#### `LProvinceRegistry:registerMapMode`

Registers a named map mode with display configuration. Overwrites if name exists.

```lua
LProvinceRegistry:registerMapMode(name, config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Map mode identifier (e.g. "political", "religion", "economy"). |
| `config` | table | Config: show_labels (bool?), show_borders (bool?), show_roads (bool?), show_capitals (bool?), show_values (bool?), value_property (string?), color_property (string?), fog_intensity (number?), border_filter (integer[]?). |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("map_mode_register", "content/examples/assets/textures/province_map.png")

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

    province_log("registered mode = economy")
    province_log("current mode = " .. reg:getMapMode())
end
```

---

#### `LProvinceRegistry:render`

Renders the province map to the screen using the current camera and style settings. Generates draw commands for fills, borders, labels, and capitals based on the provided options. Optional `tint` multiplies all province fill colours for this render only, while `province_tints` supplies render-time fill colour overrides keyed by province id without mutating the registry.

```lua
LProvinceRegistry:render(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | table?|Render | "tactical"), tactical_zoom_threshold (number?), hovered_id/selected_id (integer?). |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("render", "content/examples/assets/textures/province_map.png")
    local cam_x, cam_y, zoom = reg:fitCamera(800, 600, 1.0)
    local ids = reg:provinceIds()
    local tints = {}
    if ids[1] then
        tints[ids[1]] = { 0.2, 0.6, 1.0, 1.0 }
    end
    if ids[2] then
        tints[ids[2]] = { 0.9, 0.35, 0.2, 1.0 }
    end

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
        tint = { 0.92, 0.95, 1.0, 1.0 },
        province_tints = tints,
        border_width = 1.5,
        hovered_id = 0,
        selected_id = 0,
    })

    province_log("rendered registry = " .. reg:getName())
    province_log("zoom = " .. tostring(zoom))
end
```

---

#### `LProvinceRegistry:screenToMap`

Converts screen-space pixel coordinates to map-space floating-point coordinates using the current camera transform.

```lua
LProvinceRegistry:screenToMap(screen_x, screen_y, cam_x, cam_y, zoom, pixel_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `screen_x` | number | Screen x in pixels. |
| `screen_y` | number | Screen y in pixels. |
| `cam_x` | number | Camera center x in map space. |
| `cam_y` | number | Camera center y in map space. |
| `zoom` | number | Current zoom factor. |
| `pixel_size?` | number | Cell size in screen pixels (default 1.0). |

**Returns**

| Type | Description |
|------|-------------|
| number | Map-space x and y. (value 1). |
| number | Map-space x and y. (value 2). |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("cam_map", "content/examples/assets/textures/province_map.png")
    local cam_x, cam_y, zoom = reg:fitCamera(800, 600, 1.0)
    local map_x, map_y = reg:screenToMap(400, 300, cam_x, cam_y, zoom, 1.0)

    province_log("map x = " .. tostring(map_x))
    province_log("map y = " .. tostring(map_y))
end
```

---

#### `LProvinceRegistry:screenToProvince`

Converts screen-space coordinates directly to a province ID. Returns nil if the cursor is outside the map or over an unowned cell.

```lua
LProvinceRegistry:screenToProvince(screen_x, screen_y, cam_x, cam_y, zoom, pixel_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `screen_x` | number | Screen x in pixels. |
| `screen_y` | number | Screen y in pixels. |
| `cam_x` | number | Camera center x in map space. |
| `cam_y` | number | Camera center y in map space. |
| `zoom` | number | Current zoom factor. |
| `pixel_size?` | number | Cell size in screen pixels (default 1.0). |

**Returns**

| Type | Description |
|------|-------------|
| number | Province ID under the cursor, or nil if none. |

**Example**

```lua
do
    local reg = province_registry("screen_to_province")
    local cam_x, cam_y, zoom = reg:fitCamera(800, 600, 1.0)
    local map_x, map_y = reg:screenToMap(400, 300, cam_x, cam_y, zoom, 1.0)
    local province_id = reg:screenToProvince(400, 300, cam_x, cam_y, zoom, 1.0)
    local province = province_id and reg:getProvince(province_id) or nil
    province_log("screen pick center province=" .. tostring(province_id) .. " map_x=" .. tostring(map_x) .. " map_y=" .. tostring(map_y) .. " visible_terrain=" .. tostring(province and province.style and province.style.terrain_type))
end
```

---

#### `LProvinceRegistry:setAttr`

Sets a custom string attribute on a province. Attributes are returned in the `attrs` table of `getProvince` and can store arbitrary game metadata.

```lua
LProvinceRegistry:setAttr(id, key, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Province ID. |
| `key` | string | Attribute name. |
| `value` | string | Attribute value. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the province ID exists. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("attrs", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setAttr(province_id, "owner", "player1")
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("applied = " .. tostring(ok))
end
```

---

#### `LProvinceRegistry:setBorderClass`

Backward-compatible alias for setBorderType. Sets the border type ID.

```lua
LProvinceRegistry:setBorderClass(a, b, border_type)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | First province ID. |
| `b` | number | Second province ID. |
| `border_type` | number | Border type ID (0-255). |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("border_class_set", "content/examples/assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]
    local ok = false

    reg:registerBorderType(4, { name = "contested", color = { 220, 90, 60, 255 }, thickness = 2.5 })
    if pair then
        reg:setBorderClass(pair.province_a, pair.province_b, 4)
        ok = true
    end

    province_log("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    province_log("applied = " .. tostring(ok))
end
```

---

#### `LProvinceRegistry:setBorderPairStyle`

Sets the style override for a specific adjacency pair, including optional color, thickness, and semantic flags.

```lua
LProvinceRegistry:setBorderPairStyle(a, b, style)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | First province ID. |
| `b` | number | Second province ID. |
| `style` | table | Style table with optional fields: color={r,g,b,a}, thickness=number, flags accepts a single string or an array of strings. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when style was applied. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("border_pair_set", "content/examples/assets/textures/province_map.png")
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

    province_log("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    province_log("applied = " .. tostring(ok))
end
```

---

#### `LProvinceRegistry:setBorderStyle`

Sets the border rendering style index for a province. Controls line thickness, color, or pattern when borders are drawn.

```lua
LProvinceRegistry:setBorderStyle(id, border_style)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Province ID. |
| `border_style` | number | Border style index (game-defined meaning). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the province ID exists. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("style_border", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setBorderStyle(province_id, 2)
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("applied = " .. tostring(ok))
end
```

---

#### `LProvinceRegistry:setBorderType`

Sets the border type ID between two adjacent provinces. Register types first with registerBorderType.

```lua
LProvinceRegistry:setBorderType(a, b, border_type)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | First province ID. |
| `b` | number | Second province ID. |
| `border_type` | number | Border type ID (0-255). |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("borders_set", "content/examples/assets/textures/province_map.png")
    local pairs = reg:adjacencies()
    local pair = pairs[1]

    reg:registerBorderType(1, { name = "coast", color = { 60, 120, 180, 255 }, thickness = 2.0 })
    if pair then
        reg:setBorderType(pair.province_a, pair.province_b, 1)
    end

    province_log("pair = " .. tostring(pair and pair.province_a) .. ", " .. tostring(pair and pair.province_b))
    province_log("border type = " .. tostring(pair and reg:getBorderType(pair.province_a, pair.province_b)))
end
```

---

#### `LProvinceRegistry:setCapital`

Sets the capital marker position for a province. The capital is drawn as a small icon during `render` when `draw_capitals` is enabled.

```lua
LProvinceRegistry:setCapital(id, x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Province ID. |
| `x` | number | Capital x position in map space. |
| `y` | number | Capital y position in map space. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the province ID exists. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("labels_capital", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setCapital(province_id, 30, 25)
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("applied = " .. tostring(ok))
end
```

---

#### `LProvinceRegistry:setFogState`

Sets a fog-of-war byte for a province. This value is game-defined metadata and can be used by scripts/map modes.

```lua
LProvinceRegistry:setFogState(id, fog_state)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Province ID. |
| `fog_state` | number | Fog state value (game-defined meaning). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the province ID exists. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("style_fog", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setFogState(province_id, 1)
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("applied = " .. tostring(ok))
end
```

---

#### `LProvinceRegistry:setLabelLine`

Sets the label baseline for a province. The label text is rendered along the line from (ax,ay) to (bx,by), allowing curved or angled province names.

```lua
LProvinceRegistry:setLabelLine(id, ax, ay, bx, by)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Province ID. |
| `ax` | number | Start x of the label line in map space. |
| `ay` | number | Start y of the label line in map space. |
| `bx` | number | End x of the label line in map space. |
| `by` | number | End y of the label line in map space. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the province ID exists. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("labels_line", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setLabelLine(province_id, 10, 20, 50, 20)
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("applied = " .. tostring(ok))
end
```

---

#### `LProvinceRegistry:setLabelText`

Sets the display name text for a province. Rendered on the map when `draw_labels` is enabled in `render` options.

```lua
LProvinceRegistry:setLabelText(id, text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Province ID. |
| `text` | string | Province display name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the province ID exists. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("labels_text", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setLabelText(province_id, "Nordland")
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("applied = " .. tostring(ok))
end
```

---

#### `LProvinceRegistry:setMapMode`

Switches the active map mode to a previously registered mode name.

```lua
LProvinceRegistry:setMapMode(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Mode name to activate. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if mode exists and was activated. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("map_mode_set", "content/examples/assets/textures/province_map.png")

    reg:registerMapMode("terrain_view", {
        show_labels = true,
        show_borders = true,
        show_roads = false,
        show_capitals = true,
        fog_intensity = 0.4,
    })

    local ok = reg:setMapMode("terrain_view")

    province_log("applied = " .. tostring(ok))
    province_log("mode = " .. reg:getMapMode())
end
```

---

#### `LProvinceRegistry:setPoliticalColor`

Sets the political map color for a province. Used in political map mode rendering and change tracking.

```lua
LProvinceRegistry:setPoliticalColor(id, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Province ID. |
| `r` | number | Red component (0.0-1.0). |
| `g` | number | Green component (0.0-1.0). |
| `b` | number | Blue component (0.0-1.0). |
| `a?` | number | Alpha component (default 1.0). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the province ID exists. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("colors", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setPoliticalColor(province_id, 0.8, 0.2, 0.2, 1.0)
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("applied = " .. tostring(ok))
end
```

---

#### `LProvinceRegistry:setTerrainType`

Sets the terrain type index for a province. Terrain type controls which fill color or texture is used in terrain map mode.

```lua
LProvinceRegistry:setTerrainType(id, terrain_type)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Province ID. |
| `terrain_type` | number | Terrain type index (game-defined meaning). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the province ID exists. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("style_terrain", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setTerrainType(province_id, 1)
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("applied = " .. tostring(ok))
end
```

---

#### `LProvinceRegistry:setVisibilityState`

Sets the render visibility state for a province. `0` = hidden (no fill/border/capital/label), `1` = discovered (gray fill only), `2+` = fully visible.

```lua
LProvinceRegistry:setVisibilityState(id, visibility_state)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Province ID. |
| `visibility_state` | number | Visibility state byte. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the province ID exists. |

**Example**

```lua
do
    local reg = lurek.province.newFromPng("style_visibility", "content/examples/assets/textures/province_map.png")
    local ids = reg:provinceIds()
    local province_id = ids[1]
    local ok = false

    if province_id then
        ok = reg:setVisibilityState(province_id, 2)
    end

    province_log("province_id = " .. tostring(province_id))
    province_log("applied = " .. tostring(ok))
end
```

---

#### `LProvinceRegistry:totalAttrForOwner`

Sums a numeric attribute for all provinces with matching owner value.

```lua
LProvinceRegistry:totalAttrForOwner(owner_attr, owner_val, sum_attr)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `owner_attr` | string | Owner attribute key. |
| `owner_val` | string | Owner attribute value to filter by. |
| `sum_attr` | string | Numeric attribute key to sum. |

**Returns**

| Type | Description |
|------|-------------|
| number | Total numeric sum. |

**Example**

```lua
do
    local reg = province_registry("total_attr", "content/examples/assets/province/map.png")
    local ids = reg:provinceIds()
    local a = ids[1]
    local b = ids[2] or a
    local c = ids[3] or b
    if a then reg:setAttr(a, "faction", "player") reg:setAttr(a, "iron", "10") end
    if b then reg:setAttr(b, "faction", "enemy") reg:setAttr(b, "iron", "7") end
    if c then reg:setAttr(c, "faction", "player") reg:setAttr(c, "iron", "2.5") end
    local total = reg:totalAttrForOwner("faction", "player", "iron")
    province_log("owner resource total owner=player iron=" .. tostring(total) .. " seeded_ids=" .. tostring(a) .. "," .. tostring(b) .. "," .. tostring(c))
end
```

---

#### `LProvinceRegistry:type`

Returns the type name string for this userdata object.

```lua
LProvinceRegistry:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Always "[LProvinceRegistry](#lprovinceregistry)". |

**Example**

```lua
do
    local reg = province_registry("type")
    local type_name = reg:type()
    local matches_registry = reg:typeOf("LProvinceRegistry")
    local name = reg:getName()
    local provinces = reg:provinceCount()
    province_log("registry type inspection type=" .. tostring(type_name) .. " matches_registry=" .. tostring(matches_registry) .. " name=" .. tostring(name) .. " provinces=" .. tostring(provinces))
end
```

---

#### `LProvinceRegistry:typeOf`

Checks whether this object matches the given type name. Returns true for "[LProvinceRegistry](#lprovinceregistry)" and "Object".

```lua
LProvinceRegistry:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True if the name matches. |

**Example**

```lua
do
    local reg = province_registry("type_of")
    local is_registry = reg:typeOf("LProvinceRegistry")
    local is_object = reg:typeOf("Object")
    local is_camera = reg:typeOf("LCamera")
    local width = reg:getWidth()
    province_log("type guard registry=" .. tostring(is_registry) .. " object=" .. tostring(is_object) .. " camera=" .. tostring(is_camera) .. " width=" .. tostring(width))
end
```

---
