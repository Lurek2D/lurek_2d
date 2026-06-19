# Globe

## Summary

- The `globe` module is the planetary-map surface for users who want a world-scale spherical view to behave as a full gameplay and tooling system instead of a decorative background.
- It combines region topology, spherical navigation, camera movement, picking, overlays, labels, markers, fog, lighting, and style control so the globe can serve as a strategic layer, simulation view, or inspectable data surface.
- The module owns both interaction and presentation: users can navigate the sphere, click into it, convert screen interactions into geographic meaning, and layer game-specific information on top.
- Region adjacency and route helpers matter because many globe-driven games treat the world as a graph of territories, paths, logistics, or influence rather than as a sphere to admire.
- Layer support keeps ownership, heatmaps, tactical overlays, visibility, and markers in one annotation surface, while lighting and atmosphere improve readability as well as mood.
- Province and world-state adapters keep the globe synchronized with larger simulation systems, and import or generation helpers make it practical across authored, procedural, and tool-facing workflows.
- Region topology is equally central. The globe often acts as a graph of territories, travel arcs, or influence zones, so adjacency, routing, and territory-aware lookup must remain queryable rather than being flattened away into generic mesh behavior.
- Overlay and marker support keep several kinds of information visible at once: ownership, danger, weather, heat, logistics, missions, visibility, faction presence, or educational annotation can coexist without each feature reinventing map decoration rules.
- Province adapters and world-state synchronization keep the planetary view grounded in the rest of the simulation. A campaign map is only useful when ownership, events, region metadata, and larger systems can flow into the same world representation.
- Spherical picking and camera movement remain especially important because a globe becomes strategically useful only when users can navigate it, inspect regions, and turn screen-space interaction into stable geographic meaning.
- The result is a world-view layer that supports strategy, geoscape-style play, simulation inspection, and data-driven presentation without forcing projects to collapse planetary logic into a flat approximation too early.
- Read `globe` as the owner of planetary interaction, topology, and visualization. Rendering shows the result, but this module decides how a spherical world is represented, navigated, annotated, and synchronized.

This module primarily collaborates with `math`, `pathfind`, `province`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.globe.generateVoronoi`

Creates a globe and populates provinces from latitude-longitude seed points.

```lua
lurek.globe.generateVoronoi(name, seeds_tbl, spec_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Globe registry name. |
| `seeds_tbl` | table | Array table of `{lat, lon}` seed pairs. |
| `spec_tbl?` | table | Globe specification table. |

**Returns**

| Type | Description |
|------|-------------|
| [LGlobe](#lglobe) | New generated globe handle. |

**Example**

```lua
do
    local g = lurek.globe.generateVoronoi("voronoi_globe", { { 0, 0 }, { 30, 45 }, { -20, 90 }, { 60, -30 } }, {})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    local globe_type = g:type()
    example_print_log("voronoi provinces = " .. g:provinceCount())
end
```

---

### `lurek.globe.get`

Returns a globe from the module registry by name.

```lua
lurek.globe.get(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Globe registry name. |

**Returns**

| Type | Description |
|------|-------------|
| [LGlobe](#lglobe) | Globe handle, or nil when no globe exists with that name. |

**Example**

```lua
do
    lurek.globe.new("my_globe")
    local g = lurek.globe.get("my_globe")
    if g then
        example_print_log("got globe: " .. g:getName())
    end
end
```

---

### `lurek.globe.greatCircleDistance`

Computes great-circle distance between two latitude-longitude points.

```lua
lurek.globe.greatCircleDistance(la, lo, lb, lo2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `la` | number | Start latitude in degrees. |
| `lo` | number | Start longitude in degrees. |
| `lb` | number | End latitude in degrees. |
| `lo2` | number | End longitude in degrees. |

**Returns**

| Type | Description |
|------|-------------|
| number | Great-circle distance on the unit sphere. |

**Example**

```lua
do
    local d = lurek.globe.greatCircleDistance(0, 0, 90, 0)
    local reverse = lurek.globe.greatCircleDistance(90, 0, 0, 0)
    local quarter = lurek.globe.greatCircleDistance(0, 0, 0, 90)
    local unit = lurek.globe.latLonToUnit(0, 0)
    example_print_log("distance 0,0 -> 90,0 = " .. d)
end
```

---

### `lurek.globe.greatCirclePath`

Computes sampled latitude-longitude points along a great-circle path.

```lua
lurek.globe.greatCirclePath(la, lo, lb, lo2, n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `la` | number | Start latitude in degrees. |
| `lo` | number | Start longitude in degrees. |
| `lb` | number | End latitude in degrees. |
| `lo2` | number | End longitude in degrees. |
| `n` | number | Number of samples. |

**Returns**

| Type | Description |
|------|-------------|
| LGlobeGreatCirclePathResult | Array table of `{lat, lon}` point tables. |

**Example**

```lua
do
    local points = lurek.globe.greatCirclePath(0, 0, 45, 90, 5)
    example_print_log("path has " .. #points .. " points")
    for _, p in ipairs(points) do
        example_print_log("  lat=" .. p[1] .. " lon=" .. p[2])
    end
end
```

---

### `lurek.globe.latLonToUnit`

Converts latitude and longitude to a unit-sphere 3D vector table.

```lua
lurek.globe.latLonToUnit(lat, lon)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `lat` | number | Latitude in degrees. |
| `lon` | number | Longitude in degrees. |

**Returns**

| Type | Description |
|------|-------------|
| LGlobeLatLonToUnitResult | Array table `{x, y, z}` on the unit sphere. |

**Example**

```lua
do
    local v = lurek.globe.latLonToUnit(0, 0)
    local north = lurek.globe.latLonToUnit(90, 0)
    local east = lurek.globe.latLonToUnit(0, 90)
    local distance = lurek.globe.greatCircleDistance(0, 0, 0, 90)
    example_print_log("unit vec = " .. v[1] .. "," .. v[2] .. "," .. v[3])
end
```

---

### `lurek.globe.loadFromPNG`

Creates a globe and populates provinces from a PNG file.

```lua
lurek.globe.loadFromPNG(name, png_path, spec_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Globe registry name. |
| `png_path` | string | PNG file path to load. |
| `spec_tbl?` | table | Globe specification table. |

**Returns**

| Type | Description |
|------|-------------|
| [LGlobe](#lglobe) | New populated globe handle. |

**Example**

```lua
do
    local g = lurek.globe.loadFromPNG("png_globe", "assets/textures/province_map.png")
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    local globe_type = g:type()
    example_print_log("png globe provinces = " .. g:provinceCount())
end
```

---

### `lurek.globe.loadFromTOML`

Creates a globe and populates provinces from TOML source text.

```lua
lurek.globe.loadFromTOML(name, toml_src, spec_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Globe registry name. |
| `toml_src` | string | TOML province document source supporting either `vertices` or multipart `parts = [{ outer = ..., holes = ... }]`. |
| `spec_tbl?` | table | Globe specification table. |

**Returns**

| Type | Description |
|------|-------------|
| [LGlobe](#lglobe) | New populated globe handle. |

**Example**

```lua
do
    local toml = '[[province]]\nid = 1\ncentroid = [10.0, 20.0]\nvertices = [[10.0, 19.0], [11.0, 20.0], [10.0, 21.0], [9.0, 20.0]]'
    local g = lurek.globe.loadFromTOML("toml_globe", toml)
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    example_print_log("toml globe provinces = " .. g:provinceCount())
end
```

---

### `lurek.globe.loadFromTOMLFile`

Creates a globe and populates provinces from a TOML file path.

```lua
lurek.globe.loadFromTOMLFile(name, path, spec_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Globe registry name. |
| `path` | string | TOML file path to load. Provinces may use either `vertices` or multipart `parts = [{ outer = ..., holes = ... }]`. |
| `spec_tbl?` | table | Globe specification table. |

**Returns**

| Type | Description |
|------|-------------|
| [LGlobe](#lglobe) | New populated globe handle. |

**Example**

```lua
do
    local path = "save/globe_example.toml"
    lurek.filesystem.write(path, "[[province]]\nid = 1\ncentroid = [10.0, 20.0]\nvertices = [[10.0, 19.0], [11.0, 20.0], [10.0, 21.0], [9.0, 20.0]]\n")

    local g = lurek.globe.loadFromTOMLFile("toml_file_globe", path, {})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    example_print_log("toml file globe provinces = " .. g:provinceCount())
end
```

---

### `lurek.globe.new`

Creates a named globe with optional specification fields in the module registry.

```lua
lurek.globe.new(name, spec_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Globe registry name. |
| `spec_tbl?` | table | Globe specification table. |

**Returns**

| Type | Description |
|------|-------------|
| [LGlobe](#lglobe) | New globe handle. |

**Example**

```lua
do
    local g = lurek.globe.new("test_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    example_print_log("globe type = " .. g:type())
end
```

---

### `lurek.globe.newRegistry`

Creates an empty globe registry handle independent from the module registry.

```lua
lurek.globe.newRegistry()
```

**Returns**

| Type | Description |
|------|-------------|
| [LGlobeRegistry](#lgloberegistry) | New globe registry handle. |

**Example**

```lua
do
    local reg = lurek.globe.newRegistry()
    local registry_type = reg:type()
    local registry_names = reg:names()
    example_print_log("registry created = " .. tostring(reg ~= nil))
    example_print_log("registry type = " .. reg:type())
end
```

---

### `lurek.globe.raySphereIntersect`

Intersects a 3D ray with a sphere and returns the nearest positive hit distance.

```lua
lurek.globe.raySphereIntersect(ox, oy, oz, dx, dy, dz, radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ox` | number | Ray origin x. |
| `oy` | number | Ray origin y. |
| `oz` | number | Ray origin z. |
| `dx` | number | Ray direction x. |
| `dy` | number | Ray direction y. |
| `dz` | number | Ray direction z. |
| `radius` | number | Sphere radius. |

**Returns**

| Type | Description |
|------|-------------|
| number | Hit distance `t`, or nil when the ray misses. |

**Example**

```lua
do
    local t = lurek.globe.raySphereIntersect(0.0, 0.0, -2.0, 0.0, 0.0, 1.0, 1.0)
    local miss = lurek.globe.raySphereIntersect(0.0, 0.0, -2.0, 1.0, 0.0, 0.0, 1.0)
    local unit = lurek.globe.latLonToUnit(0, 0)
    example_print_log("hit distance = " .. tostring(t))
    example_print_log("ray hits sphere = " .. tostring(t ~= nil))
end
```

---

### `lurek.globe.remove`

Removes a globe from the registry by name.

```lua
lurek.globe.remove(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Globe registry name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a globe was removed. |

**Example**

```lua
do
    local g = lurek.globe.new("tmp_remove")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    local ok = lurek.globe.remove("tmp_remove")
    example_print_log("removed=" .. tostring(ok))
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

- [LGlobe](#lglobe)
- [LGlobeRegistry](#lgloberegistry)

## LGlobe

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LGlobe:addArc`

Adds a visible route arc between two latitude and longitude points.

```lua
LGlobe:addArc(lat1, lon1, lat2, lon2, steps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `lat1` | number | Start latitude in degrees. |
| `lon1` | number | Start longitude in degrees. |
| `lat2` | number | End latitude in degrees. |
| `lon2` | number | End longitude in degrees. |
| `steps?` | number | Point count for the arc, defaulting to 24. |

**Returns**

| Type | Description |
|------|-------------|
| number | New arc id. |

**Example**

```lua
do
    local g = lurek.globe.new("arc_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    local id = g:addArc(0, 0, 45, 90, 12)
    example_print_log("arc id = " .. id)
end
```

---

#### `LGlobe:addLabel`

Adds a text label at latitude and longitude.

```lua
LGlobe:addLabel(ltype, lat, lon, text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ltype` | string | Label type name. |
| `lat` | number | Latitude in degrees. |
| `lon` | number | Longitude in degrees. |
| `text` | string | Label text. |

**Returns**

| Type | Description |
|------|-------------|
| number | New label id. |

**Example**

```lua
do
    local g = lurek.globe.new("lbl_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    local id = g:addLabel("region", 40, -74, "New York")
    example_print_log("label id = " .. id)
end
```

---

#### `LGlobe:addLayer`

Adds a render layer with optional z-order.

```lua
LGlobe:addLayer(name, z_order)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Layer name. |
| `z_order?` | number | Layer z-order, defaulting to zero. |

**Example**

```lua
do
    local g = lurek.globe.new("layer_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:addLayer("terrain", 0)
    g:addLayer("borders", 1)
    example_print_log("layers added")
end
```

---

#### `LGlobe:addMarker`

Adds a marker at latitude and longitude with an optional label.

```lua
LGlobe:addMarker(mtype, lat, lon, label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mtype` | string | Marker type name. |
| `lat` | number | Latitude in degrees. |
| `lon` | number | Longitude in degrees. |
| `label?` | string | Marker label. |

**Returns**

| Type | Description |
|------|-------------|
| number | New marker id. |

**Example**

```lua
do
    local g = lurek.globe.new("mark_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    local id = g:addMarker("city", 51.5, -0.12, "London")
    example_print_log("marker id = " .. id)
end
```

---

#### `LGlobe:addProvince`

Adds a province described by id, centroid, polygon vertices or multipart geometry, neighbors, and optional base color.

```lua
LGlobe:addProvince(p)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `p` | table | Province table with `id`, optional `centroid`, either `vertices` or `parts`, optional `neighbors`, and optional `base_color`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the province was accepted by the globe. |

**Example**

```lua
do
    local g = lurek.globe.new("prov_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    local ok = g:addProvince({ id = 1, centroid = { 10.0, 20.0 }, vertices = { { 9, 19 }, { 11, 19 }, { 11, 21 }, { 9, 21 } } })
    example_print_log("added = " .. tostring(ok))
end
```

---

#### `LGlobe:addRegion`

Adds a region described by id, centroid, polygon vertices or multipart geometry, neighbors, and optional base color.

```lua
LGlobe:addRegion(p)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `p` | table | Region table with `id`, optional `centroid`, either `vertices` or `parts`, optional `neighbors`, and optional `base_color`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the region was accepted by the globe. |

**Example**

```lua
do
    local g = lurek.globe.new("region_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    local ok = g:addRegion({
        id = 1,
        centroid = { 50, 15 },
        vertices = { { 49, 14 }, { 51, 14 }, { 51, 16 }, { 49, 16 } },
    })
    example_print_log("added region = " .. tostring(ok))
    example_print_log("region count = " .. g:regionCount())
end
```

---

#### `LGlobe:applyMouseDrag`

Applies a pointer drag to the globe camera using screen-space deltas.

```lua
LGlobe:applyMouseDrag(start_x, start_y, end_x, end_y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `start_x` | number | Drag start x. |
| `start_y` | number | Drag start y. |
| `end_x` | number | Drag end x. |
| `end_y` | number | Drag end y. |

**Example**

```lua
do
    local g = build_demo_globe("mouse_drag_globe")
    g:applyMouseDrag(320, 180, 360, 210)
    local lat, lon, zoom = g:getCamera()
    local lod = g:getLod()
    example_print_log("camera after drag = " .. lat .. "," .. lon .. "," .. zoom)
end
```

---

#### `LGlobe:applyWheelZoom`

Applies a wheel delta using an exponential zoom scale.

```lua
LGlobe:applyWheelZoom(delta)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `delta` | number | Wheel delta where positive zooms in and negative zooms out. |

**Example**

```lua
do
    local g = build_demo_globe("wheel_zoom_globe")
    g:applyWheelZoom(-1.0)
    local _, _, zoom = g:getCamera()
    local lod = g:getLod()
    example_print_log("camera zoom = " .. zoom)
end
```

---

#### `LGlobe:cacheReachability`

Caches default-cost reachability for a named faction.

```lua
LGlobe:cacheReachability(faction, start_id, max_cost)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `faction` | string | Faction cache key. |
| `start_id` | number | Start province id. |
| `max_cost` | number | Maximum traversal cost. |

**Example**

```lua
do
    local g = lurek.globe.new("cache_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:cacheReachability("faction_a", 1, 5.0)
    example_print_log("reachability cached")
end
```

---

#### `LGlobe:clearProvinceTexture`

Removes texture metadata from a province.

```lua
LGlobe:clearProvinceTexture(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Province id. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the province exists. |

**Example**

```lua
do
    local g = lurek.globe.new("ctex_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceTexture(1, 42, 0, 0, 1, 1)
    g:clearProvinceTexture(1)
    example_print_log("texture cleared")
end
```

---

#### `LGlobe:decodeFogBase64`

Loads one viewer's fog state from a base64 string.

```lua
LGlobe:decodeFogBase64(viewer, payload)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `viewer` | string | Viewer name. |
| `payload` | string | Base64-encoded fog state. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the payload was decoded. |

**Example**

```lua
do
    local g = lurek.globe.new("dec_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    local b64 = g:encodeFogBase64("p1")
    local ok = g:decodeFogBase64("p1", b64)
    example_print_log("decoded = " .. tostring(ok))
end
```

---

#### `LGlobe:distanceBetweenMarkers`

Computes great-circle distance between two markers on the unit sphere.

```lua
LGlobe:distanceBetweenMarkers(a, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | First marker id. |
| `b` | number | Second marker id. |

**Returns**

| Type | Description |
|------|-------------|
| number | Great-circle distance, or nil when either marker is missing. |

**Example**

```lua
do
    local g, a, b = build_demo_globe("marker_distance_globe")
    local d = g:distanceBetweenMarkers(a, b)
    local path = g:findPath(1, 3)
    local surface = g:pickSurface(320, 180, 24)
    example_print_log("marker distance = " .. tostring(d))
end
```

---

#### `LGlobe:draw`

Emits the globe's render commands into the shared renderer command queue.

```lua
LGlobe:draw(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts?` | table | Optional draw settings with `screen_cx` and `screen_cy`. |

**Example**

```lua
do
    local g = build_demo_globe("draw_globe")
    g:draw()
    local lod = g:getLod()
    example_print_log("draw issued")
    example_print_log("type = " .. g:type())
end
```

---

#### `LGlobe:encodeFogBase64`

Serializes one viewer's fog state to a base64 string.

```lua
LGlobe:encodeFogBase64(viewer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `viewer` | string | Viewer name. |

**Returns**

| Type | Description |
|------|-------------|
| string | Base64-encoded fog state, or an empty string on encode failure. |

**Example**

```lua
do
    local g = lurek.globe.new("enc_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    local b64 = g:encodeFogBase64("p1")
    example_print_log("encoded fog length = " .. #b64)
end
```

---

#### `LGlobe:exportProvinceMeshOBJ`

Exports province geometry as Wavefront OBJ text, preserving multipart boundaries and hole loops.

```lua
LGlobe:exportProvinceMeshOBJ()
```

**Returns**

| Type | Description |
|------|-------------|
| string | OBJ text for the current provinces, including grouped boundary loops and any available fill geometry. |

**Example**

```lua
do
    local g = lurek.globe.new("obj_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local obj = g:exportProvinceMeshOBJ()
    example_print_log("OBJ length = " .. #obj)
end
```

---

#### `LGlobe:findPath`

Finds a default-cost province path between two province ids.

```lua
LGlobe:findPath(from_id, to_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_id` | number | Start province id. |
| `to_id` | number | Target province id. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Province ids, or nil when no path exists. |

**Example**

```lua
do
    local g = lurek.globe.new("path_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}, neighbors = {2}})
    g:addProvince({id = 2, centroid = {5, 0}, vertices = {{4, -1}, {6, -1}, {6, 1}, {4, 1}}, neighbors = {1}})
    example_print_log("path length = " .. #(g:findPath(1, 2) or {}))
end
```

---

#### `LGlobe:findPathWithCosts`

Finds a province path using caller-supplied traversal costs, blocked ids, and edge-tag surcharges.

```lua
LGlobe:findPathWithCosts(from_id, to_id, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_id` | number | Start province id. |
| `to_id` | number | Target province id. |
| `opts?` | table | Optional cost table with `default_cost`, `province_costs`, `tag_costs`, and `blocked_ids`. |

**Returns**

| Type | Description |
|------|-------------|
| table | Result table with `ids` and `total_cost`, or nil when no path exists. |

**Example**

```lua
do
    local g = build_demo_globe("find_costs_globe")
    local path = g:findPathWithCosts(1, 3)
    local reachable = g:reachableWithCosts(1, 10.0)
    example_print_log("path table = " .. type(path))
    example_print_log("path first = " .. tostring(path and path[1]))
end
```

---

#### `LGlobe:getCachedReachability`

Returns cached reachability costs for a faction.

```lua
LGlobe:getCachedReachability(faction)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `faction` | string | Faction cache key. |

**Returns**

| Type | Description |
|------|-------------|
| table | Map table from province id (integer key) to accumulated traversal cost (number), empty when missing. |

**Example**

```lua
do
    local g = lurek.globe.new("gcache_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:cacheReachability("faction_b", 1, 5.0)
    local costs = g:getCachedReachability("faction_b")
    example_print_log("cached costs type = " .. type(costs))
    example_print_log("cached cost to 1 = " .. tostring(costs[1]))
end
```

---

#### `LGlobe:getCamera`

Returns camera latitude, longitude, and zoom.

```lua
LGlobe:getCamera()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Camera latitude in degrees. |
| number | Camera longitude in degrees. |
| number | Camera zoom. |

**Example**

```lua
do
    local g = lurek.globe.new("gcam_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:setCamera(30, 60, 1.5)
    local lat, lon, z = g:getCamera()
    example_print_log("camera: " .. lat .. "," .. lon .. " z=" .. z)
end
```

---

#### `LGlobe:getEdgeTags`

Returns the sorted tag strings stored on a province edge.

```lua
LGlobe:getEdgeTags(a, b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | First province id. |
| `b` | number | Second province id. |

**Returns**

| Type | Description |
|------|-------------|
| string[] | Sequential table of edge tag strings, empty when none are set. |

**Example**

```lua
do
    local g = build_demo_globe("get_edge_tags_globe")
    g:setEdgeTags(1, 2, { "road", "trade" })
    local tags = g:getEdgeTags(1, 2)
    local path = g:findPath(1, 3)
    example_print_log("edge tags = " .. table.concat(tags, ","))
end
```

---

#### `LGlobe:getFogState`

Returns fog-of-war state for one viewer and province.

```lua
LGlobe:getFogState(viewer, id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `viewer` | string | Viewer name. |
| `id` | number | Province id. |

**Returns**

| Type | Description |
|------|-------------|
| string | `visible`, `explored`, or `hidden`. |

**Example**

```lua
do
    local g = lurek.globe.new("gfs_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setFogState("p1", 1, "visible")
    local state = g:getFogState("p1", 1)
    example_print_log("fog = " .. state)
end
```

---

#### `LGlobe:getLod`

Returns the camera-derived level-of-detail tier name.

```lua
LGlobe:getLod()
```

**Returns**

| Type | Description |
|------|-------------|
| string | One of `far`, `mid`, or `near`. |

**Example**

```lua
do
    local g = lurek.globe.new("lod_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:setCamera(0, 0, 0.5)
    example_print_log("lod = " .. g:getLod())
end
```

---

#### `LGlobe:getMarkerAttr`

Reads a string attribute from a marker.

```lua
LGlobe:getMarkerAttr(id, key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Marker id. |
| `key` | string | Attribute key. |

**Returns**

| Type | Description |
|------|-------------|
| string | Attribute string, or nil when missing. |

**Example**

```lua
do
    local g = lurek.globe.new("ga_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    local id = g:addMarker("city", 48.8, 2.3, "Paris")
    g:setMarkerAttr(id, "country", "France")
    local val = g:getMarkerAttr(id, "country")
    example_print_log("country = " .. tostring(val))
end
```

---

#### `LGlobe:getName`

Returns the registry name of this globe.

```lua
LGlobe:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Globe registry name. |

**Example**

```lua
do
    local g = lurek.globe.new("named_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    example_print_log("name = " .. g:getName())
end
```

---

#### `LGlobe:getNeighbors`

Returns neighboring province ids for a province.

```lua
LGlobe:getNeighbors(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Province id. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of neighboring province ids. |

**Example**

```lua
do
    local g = lurek.globe.new("neigh_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}, neighbors = {2}})
    local n = g:getNeighbors(1)
    example_print_log("neighbors of 1: " .. #n)
end
```

---

#### `LGlobe:getProvinceAttr`

Reads a string attribute from a province.

```lua
LGlobe:getProvinceAttr(id, key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Province id. |
| `key` | string | Attribute key. |

**Returns**

| Type | Description |
|------|-------------|
| string | Attribute string, or nil when the province or key is missing. |

**Example**

```lua
do
    local g = lurek.globe.new("rattr_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceAttr(1, "terrain", "forest")
    local val = g:getProvinceAttr(1, "terrain")
    example_print_log("terrain = " .. tostring(val))
end
```

---

#### `LGlobe:getProvinceSector`

Returns the sector name assigned to a province.

```lua
LGlobe:getProvinceSector(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Province id. |

**Returns**

| Type | Description |
|------|-------------|
| string | Sector string, or nil when absent. |

**Example**

```lua
do
    local g = lurek.globe.new("gsec_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceSector(1, "eastern")
    local s = g:getProvinceSector(1)
    example_print_log("sector = " .. tostring(s))
end
```

---

#### `LGlobe:getRegionAttr`

Reads a string attribute from a semantic region.

```lua
LGlobe:getRegionAttr(id, key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Region id. |
| `key` | string | Attribute key. |

**Returns**

| Type | Description |
|------|-------------|
| string | Attribute string, or nil when the region or key is missing. |

**Example**

```lua
do
    local g = build_demo_globe("get_region_attr_globe")
    g:setRegionAttr(11, "owner", "faction_b")
    local count = g:regionCount()
    local tags = g:getEdgeTags(1, 2)
    example_print_log("owner = " .. tostring(g:getRegionAttr(11, "owner")))
end
```

---

#### `LGlobe:getSectorProvinces`

Returns province ids assigned to a sector.

```lua
LGlobe:getSectorProvinces(sector)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sector` | string | Sector name. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of province ids. |

**Example**

```lua
do
    local g = lurek.globe.new("sp_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceSector(1, "west")
    local ids = g:getSectorProvinces("west")
    example_print_log("west has " .. #ids .. " provinces")
end
```

---

#### `LGlobe:getTimeOfDay`

Returns globe time of day. This method is available to Lua scripts.

```lua
LGlobe:getTimeOfDay()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Time of day in hours. |

**Example**

```lua
do
    local g = lurek.globe.new("gtod_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:setTimeOfDay(8.0)
    local t = g:getTimeOfDay()
    example_print_log("time of day = " .. t)
end
```

---

#### `LGlobe:hideProvince`

Hides a province for one fog-of-war viewer.

```lua
LGlobe:hideProvince(viewer, id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `viewer` | string | Viewer name. |
| `id` | number | Province id. |

**Example**

```lua
do
    local g = lurek.globe.new("hide_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:hideProvince("player1", 1)
    example_print_log("province 1 hidden")
end
```

---

#### `LGlobe:isVisible`

Returns whether a province is visible for one fog-of-war viewer.

```lua
LGlobe:isVisible(viewer, id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `viewer` | string | Viewer name. |
| `id` | number | Province id. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the province is visible. |

**Example**

```lua
do
    local g = lurek.globe.new("isv_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:revealProvince("p1", 1)
    example_print_log("visible = " .. tostring(g:isVisible("p1", 1)))
end
```

---

#### `LGlobe:moveMarker`

Moves a marker to latitude and longitude coordinates.

```lua
LGlobe:moveMarker(id, lat, lon)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Marker id. |
| `lat` | number | Latitude in degrees. |
| `lon` | number | Longitude in degrees. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the marker exists. |

**Example**

```lua
do
    local g = lurek.globe.new("mv_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    local id = g:addMarker("pin", 0, 0)
    g:moveMarker(id, 10, 20)
    example_print_log("marker moved")
end
```

---

#### `LGlobe:pan`

Pans the globe camera by latitude and longitude deltas.

```lua
LGlobe:pan(dlat, dlon)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dlat` | number | Latitude delta in degrees. |
| `dlon` | number | Longitude delta in degrees. |

**Example**

```lua
do
    local g = lurek.globe.new("pan_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:setCamera(0, 0, 1.0)
    g:pan(10, 20)
    local lat, lon, z = g:getCamera()
    example_print_log("after pan: " .. lat .. "," .. lon)
end
```

---

#### `LGlobe:pick`

Picks a province at screen coordinates.

```lua
LGlobe:pick(sx, sy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | Screen x coordinate. |
| `sy` | number | Screen y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Province id, or nil when nothing is hit. |

**Example**

```lua
do
    local g = lurek.globe.new("pick_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    local id = g:pick(400, 300)
    example_print_log("picked province = " .. tostring(id))
end
```

---

#### `LGlobe:pickLatLon`

Picks at screen coordinates and returns the hit surface latitude and longitude.

```lua
LGlobe:pickLatLon(sx, sy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | Screen x coordinate. |
| `sy` | number | Screen y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Latitude in degrees; or nil when nothing is hit. |
| number | Longitude in degrees; or nil when nothing is hit. |

**Example**

```lua
do
    local g = lurek.globe.new("pll_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    local cx, cy = g:pickLatLon(400, 300)
    example_print_log("centroid = " .. tostring(cx) .. "," .. tostring(cy))
end
```

---

#### `LGlobe:pickMarker`

Returns the nearest visible marker at a screen position within an optional pixel radius.

```lua
LGlobe:pickMarker(sx, sy, radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | Screen x coordinate. |
| `sy` | number | Screen y coordinate. |
| `radius?` | number | Maximum marker distance in pixels, default 12. |

**Returns**

| Type | Description |
|------|-------------|
| number | Marker id, or nil when no visible marker is within range. |

**Example**

```lua
do
    local g = build_demo_globe("pick_marker_globe")
    local id = g:pickMarker(320, 180, 24)
    local lat, lon = g:screenToLatLon(320, 180)
    local surface = g:pickSurface(320, 180, 24)
    example_print_log("picked marker = " .. tostring(id))
end
```

---

#### `LGlobe:pickRaycast`

Samples along the screen-space line from the globe center to the target and returns the first hit province.

```lua
LGlobe:pickRaycast(sx, sy, steps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | Target screen x coordinate. |
| `sy` | number | Target screen y coordinate. |
| `steps?` | number | Number of screen-space samples along the line, defaulting to 24. |

**Returns**

| Type | Description |
|------|-------------|
| number | Province id, or nil when no sample hits. |

**Example**

```lua
do
    local g = lurek.globe.new("pray_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    local id = g:pickRaycast(400, 300, 32)
    example_print_log("raycast pick = " .. tostring(id))
end
```

---

#### `LGlobe:pickRegions`

Returns semantic region ids under a screen-space hit.

```lua
LGlobe:pickRegions(sx, sy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | Screen x coordinate. |
| `sy` | number | Screen y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of semantic region ids. |

**Example**

```lua
do
    local g = build_demo_globe("pick_regions_globe")
    local ids = g:pickRegions(320, 180)
    local lat, lon = g:screenToLatLon(320, 180)
    local lod = g:getLod()
    example_print_log("picked regions = " .. #ids)
end
```

---

#### `LGlobe:pickSurface`

Resolves a screen-space hit into globe surface data plus province, marker, and semantic-region hits.

```lua
LGlobe:pickSurface(sx, sy, marker_radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | Screen x coordinate. |
| `sy` | number | Screen y coordinate. |
| `marker_radius?` | number | Maximum marker distance in pixels when testing marker hits. |

**Returns**

| Type | Description |
|------|-------------|
| table | Pick result table, or nil when the screen point is off the globe. |

**Example**

```lua
do
    local g = build_demo_globe("pick_surface_globe")
    local hit = g:pickSurface(320, 180, 24)
    local lat, lon = g:screenToLatLon(320, 180)
    local ids = g:pickRegions(320, 180)
    example_print_log("picked surface table = " .. tostring(hit ~= nil))
end
```

---

#### `LGlobe:provinceCount`

Returns the number of rendered provinces in this globe.

```lua
LGlobe:provinceCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Province count. |

**Example**

```lua
do
    local g = lurek.globe.new("count_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    example_print_log("provinces = " .. g:provinceCount())
end
```

---

#### `LGlobe:reachable`

Returns provinces reachable from a start province within a cost budget.

```lua
LGlobe:reachable(start_id, max_cost)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `start_id` | number | Start province id. |
| `max_cost` | number | Maximum traversal cost. |

**Returns**

| Type | Description |
|------|-------------|
| table | Map table from province id (integer key) to accumulated traversal cost (number). |

**Example**

```lua
do
    local g = lurek.globe.new("reach_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}, neighbors = {2}})
    g:addProvince({id = 2, centroid = {5, 0}, vertices = {{4, -1}, {6, -1}, {6, 1}, {4, 1}}, neighbors = {1}})
    local costs = g:reachable(1, 10.0)
    example_print_log("cost to 1 = " .. tostring(costs[1]))
    example_print_log("cost to 2 = " .. tostring(costs[2]))
end
```

---

#### `LGlobe:reachableWithCosts`

Returns provinces reachable under caller-supplied traversal costs, blocked ids, and edge-tag surcharges.

```lua
LGlobe:reachableWithCosts(start_id, max_cost, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `start_id` | number | Start province id. |
| `max_cost` | number | Maximum traversal cost. |
| `opts?` | table | Optional cost table with `default_cost`, `province_costs`, `tag_costs`, and `blocked_ids`. |

**Returns**

| Type | Description |
|------|-------------|
| table | Map table from province id (integer key) to accumulated traversal cost (number). |

**Example**

```lua
do
    local g = build_demo_globe("reachable_costs_globe")
    local costs = g:reachableWithCosts(1, 10.0)
    local path = g:findPathWithCosts(1, 3)
    example_print_log("cost table = " .. type(costs))
    example_print_log("cost to 2 = " .. tostring(costs[2]))
end
```

---

#### `LGlobe:regionCount`

Returns the number of stored semantic regions in this globe.

```lua
LGlobe:regionCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Semantic region count. |

**Example**

```lua
do
    local g = lurek.globe.new("count_region_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:addRegion({
        id = 1,
        centroid = { 35, 80 },
        vertices = { { 34, 79 }, { 36, 79 }, { 36, 81 }, { 34, 81 } },
    })
    g:addRegion({
        id = 2,
        centroid = { -10, 20 },
        vertices = { { -11, 19 }, { -9, 19 }, { -9, 21 }, { -11, 21 } },
    })
    example_print_log("region count = " .. g:regionCount())
end
```

---

#### `LGlobe:regionsAtLatLon`

Returns semantic region ids containing a latitude-longitude point.

```lua
LGlobe:regionsAtLatLon(lat, lon)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `lat` | number | Latitude in degrees. |
| `lon` | number | Longitude in degrees. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of semantic region ids. |

**Example**

```lua
do
    local g = build_demo_globe("regions_at_latlon_globe")
    local ids = g:regionsAtLatLon(0, 0)
    local picked = g:pickRegions(320, 180)
    local lod = g:getLod()
    example_print_log("regions at latlon = " .. #ids)
end
```

---

#### `LGlobe:removeArc`

Removes an arc by id. This method is available to Lua scripts.

```lua
LGlobe:removeArc(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Arc id. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when an arc was removed. |

**Example**

```lua
do
    local g = lurek.globe.new("rarc_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    local id = g:addArc(0, 0, 30, 60)
    local ok = g:removeArc(id)
    example_print_log("arc removed = " .. tostring(ok))
end
```

---

#### `LGlobe:removeHeatLayer`

Removes a heat layer by name. This method is available to Lua scripts.

```lua
LGlobe:removeHeatLayer(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Heat layer name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a layer was removed. |

**Example**

```lua
do
    local g = lurek.globe.new("rheat_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:setHeatLayer("income", "gdp", 0, 50000, 0.5)
    local ok = g:removeHeatLayer("income")
    example_print_log("heat removed = " .. tostring(ok))
end
```

---

#### `LGlobe:removeLabel`

Removes a label by id. This method is available to Lua scripts.

```lua
LGlobe:removeLabel(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Label id. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a label was removed. |

**Example**

```lua
do
    local g = lurek.globe.new("rlbl_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    local id = g:addLabel("tmp", 0, 0, "temp")
    local ok = g:removeLabel(id)
    example_print_log("label removed = " .. tostring(ok))
end
```

---

#### `LGlobe:removeLayer`

Removes a render layer by name. This method is available to Lua scripts.

```lua
LGlobe:removeLayer(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Layer name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a layer was removed. |

**Example**

```lua
do
    local g = lurek.globe.new("rl_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:addLayer("temp_layer")
    local ok = g:removeLayer("temp_layer")
    example_print_log("layer removed = " .. tostring(ok))
end
```

---

#### `LGlobe:removeMarker`

Removes a marker by id. This method is available to Lua scripts.

```lua
LGlobe:removeMarker(id)
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
    local g = lurek.globe.new("rm_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    local id = g:addMarker("pin", 0, 0)
    local ok = g:removeMarker(id)
    example_print_log("removed marker = " .. tostring(ok))
end
```

---

#### `LGlobe:removeProvince`

Removes a region by id. This method is available to Lua scripts.

```lua
LGlobe:removeProvince(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Region id to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a region was removed. |

**Example**

```lua
do
    local g = lurek.globe.new("rem_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local ok = g:removeProvince(1)
    example_print_log("removed = " .. tostring(ok))
end
```

---

#### `LGlobe:removeRegion`

Removes a region by id. This method is available to Lua scripts.

```lua
LGlobe:removeRegion(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Region id to remove. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a region was removed. |

**Example**

```lua
do
    local g = lurek.globe.new("remove_region_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:addRegion({
        id = 1,
        centroid = { 40, -90 },
        vertices = { { 39, -91 }, { 41, -91 }, { 41, -89 }, { 39, -89 } },
    })
    local ok = g:removeRegion(1)
    example_print_log("removed region = " .. tostring(ok))
    example_print_log("region count = " .. g:regionCount())
end
```

---

#### `LGlobe:revealAll`

Reveals every province for one fog-of-war viewer.

```lua
LGlobe:revealAll(viewer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `viewer` | string | Viewer name. |

**Example**

```lua
do
    local g = lurek.globe.new("rall_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:revealAll("player1")
    example_print_log("all revealed for player1")
end
```

---

#### `LGlobe:revealProvince`

Reveals a province for one fog-of-war viewer.

```lua
LGlobe:revealProvince(viewer, id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `viewer` | string | Viewer name. |
| `id` | number | Province id. |

**Example**

```lua
do
    local g = lurek.globe.new("rev_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:revealProvince("player1", 1)
    example_print_log("province 1 revealed")
end
```

---

#### `LGlobe:screenDeltaToPan`

Converts a screen-space drag delta into latitude and longitude pan deltas.

```lua
LGlobe:screenDeltaToPan(dx, dy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dx` | number | Screen-space x delta in pixels. |
| `dy` | number | Screen-space y delta in pixels. |

**Returns**

| Type | Description |
|------|-------------|
| number | Latitude delta in degrees. |
| number | Longitude delta in degrees. |

**Example**

```lua
do
    local g = build_demo_globe("screen_delta_globe")
    local dlat, dlon = g:screenDeltaToPan(32, -16)
    local lat, lon, zoom = g:getCamera()
    local lod = g:getLod()
    example_print_log("pan delta = " .. tostring(dlat) .. "," .. tostring(dlon))
end
```

---

#### `LGlobe:screenToLatLon`

Converts a visible screen position into globe latitude, longitude, and unit-sphere coordinates.

```lua
LGlobe:screenToLatLon(sx, sy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | number | Screen x coordinate. |
| `sy` | number | Screen y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| number | Latitude in degrees; or nil when the point is off the globe. |
| number | Longitude in degrees; or nil when the point is off the globe. |
| number | Unit-sphere x coordinate; or nil when the point is off the globe. |
| number | Unit-sphere y coordinate; or nil when the point is off the globe. |
| number | Unit-sphere z coordinate; or nil when the point is off the globe. |

**Example**

```lua
do
    local g = build_demo_globe("screen_latlon_globe")
    local lat, lon = g:screenToLatLon(320, 180)
    local picked = g:pickSurface(320, 180, 24)
    local lod = g:getLod()
    example_print_log("latlon = " .. tostring(lat) .. "," .. tostring(lon))
end
```

---

#### `LGlobe:setActiveViewer`

Sets the active fog-of-war viewer name or clears it.

```lua
LGlobe:setActiveViewer(viewer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `viewer?` | string | Viewer name. |

**Example**

```lua
do
    local g = lurek.globe.new("fow_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:setActiveViewer("player1")
    example_print_log("active viewer = player1")
end
```

---

#### `LGlobe:setAutoRotationSpeed`

Sets automatic globe rotation speed.

```lua
LGlobe:setAutoRotationSpeed(dps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dps` | number | Rotation speed in degrees per second. |

**Example**

```lua
do
    local g = lurek.globe.new("arot_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:setAutoRotationSpeed(10)
    example_print_log("auto rotation = 10 dps")
end
```

---

#### `LGlobe:setBorders`

Enables or disables province border rendering.

```lua
LGlobe:setBorders(show)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `show` | boolean | New border visibility flag. |

**Example**

```lua
do
    local g = lurek.globe.new("bord_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:setBorders(true)
    example_print_log("borders enabled")
end
```

---

#### `LGlobe:setCamera`

Sets camera latitude, longitude, and zoom.

```lua
LGlobe:setCamera(lat, lon, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `lat` | number | Camera latitude in degrees. |
| `lon` | number | Camera longitude in degrees. |
| `z` | number | Camera zoom, clamped to at least 0.1. |

**Example**

```lua
do
    local g = lurek.globe.new("cam_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:setCamera(45, 90, 2.0)
    example_print_log("camera set")
end
```

---

#### `LGlobe:setEdgeTags`

Replaces the tag set stored on an existing province edge.

```lua
LGlobe:setEdgeTags(a, b, tags)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `a` | number | First province id. |
| `b` | number | Second province id. |
| `tags` | string[] | Sequential table of edge tag strings. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the edge exists and the tags were stored. |

**Example**

```lua
do
    local g = build_demo_globe("edge_tags_globe")
    local ok = g:setEdgeTags(1, 2, { "road", "river" })
    local path = g:findPath(1, 3)
    example_print_log("set edge tags = " .. tostring(ok))
    example_print_log("tags count = " .. #(g:getEdgeTags(1, 2) or {}))
end
```

---

#### `LGlobe:setFogState`

Sets fog-of-war state for one viewer and province.

```lua
LGlobe:setFogState(viewer, id, state)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `viewer` | string | Viewer name. |
| `id` | number | Province id. |
| `state` | string | `visible`, `explored`, or any other value for hidden. |

**Example**

```lua
do
    local g = lurek.globe.new("fs_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setFogState("p1", 1, "explored")
    example_print_log("fog state set to explored")
end
```

---

#### `LGlobe:setHeatLayer`

Creates or replaces a heat layer that maps province attributes into colors.

```lua
LGlobe:setHeatLayer(name, attr_key, min, max, alpha)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Heat layer name. |
| `attr_key` | string | Province attribute key read as a numeric value. |
| `min` | number | Attribute value mapped to cold color. |
| `max` | number | Attribute value mapped to hot color. |
| `alpha` | number | Layer alpha clamped to 0.0 through 1.0. |

**Example**

```lua
do
    local g = lurek.globe.new("heat_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:setHeatLayer("population", "pop", 0, 1000000, 0.7)
    example_print_log("heat layer set")
end
```

---

#### `LGlobe:setLabelText`

Changes text for an existing label.

```lua
LGlobe:setLabelText(id, text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Label id. |
| `text` | string | New label text. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the label exists. |

**Example**

```lua
do
    local g = lurek.globe.new("ltxt_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    local id = g:addLabel("city", 0, 0, "old")
    g:setLabelText(id, "new")
    example_print_log("label updated")
end
```

---

#### `LGlobe:setLabelVisible`

Shows or hides a label. This method is available to Lua scripts.

```lua
LGlobe:setLabelVisible(id, vis)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Label id. |
| `vis` | boolean | New visibility flag. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the label exists. |

**Example**

```lua
do
    local g = lurek.globe.new("lvis_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    local id = g:addLabel("info", 0, 0, "text")
    g:setLabelVisible(id, false)
    example_print_log("label hidden")
end
```

---

#### `LGlobe:setLayerAlpha`

Sets render layer alpha. This method is available to Lua scripts.

```lua
LGlobe:setLayerAlpha(name, alpha)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Layer name. |
| `alpha` | number | Layer alpha. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the layer exists. |

**Example**

```lua
do
    local g = lurek.globe.new("la_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:addLayer("fog_layer")
    g:setLayerAlpha("fog_layer", 0.5)
    example_print_log("layer alpha = 0.5")
end
```

---

#### `LGlobe:setLayerColor`

Sets a province color override inside a render layer.

```lua
LGlobe:setLayerColor(layer, id, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | string | Layer name. |
| `id` | number | Province id. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a` | number | Alpha channel. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the layer exists. |

**Example**

```lua
do
    local g = lurek.globe.new("lc_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:addLayer("highlight")
    g:setLayerColor("highlight", 1, 1.0, 0.0, 0.0, 1.0)
    example_print_log("province 1 colored red in highlight layer")
end
```

---

#### `LGlobe:setLayerVisible`

Shows or hides a render layer. This method is available to Lua scripts.

```lua
LGlobe:setLayerVisible(name, vis)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Layer name. |
| `vis` | boolean | New visibility flag. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the layer exists. |

**Example**

```lua
do
    local g = lurek.globe.new("lv_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:addLayer("overlay")
    g:setLayerVisible("overlay", false)
    example_print_log("overlay hidden")
end
```

---

#### `LGlobe:setMarkerAttr`

Sets a string attribute on a marker.

```lua
LGlobe:setMarkerAttr(id, key, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Marker id. |
| `key` | string | Attribute key. |
| `val` | string | Attribute value. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the marker exists. |

**Example**

```lua
do
    local g = lurek.globe.new("ma_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    local id = g:addMarker("city", 48.8, 2.3, "Paris")
    g:setMarkerAttr(id, "population", "2M")
    example_print_log("marker attr set")
end
```

---

#### `LGlobe:setMarkerColor`

Sets marker tint color.

```lua
LGlobe:setMarkerColor(id, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Marker id. |
| `r` | number | Red channel. |
| `g` | number | Green channel. |
| `b` | number | Blue channel. |
| `a?` | number | Alpha channel, defaulting to 1.0. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the marker exists. |

**Example**

```lua
do
    local g, a = build_demo_globe("marker_color_globe")
    local ok = g:setMarkerColor(a, 1.0, 0.3, 0.2, 0.9)
    local id = g:pickMarker(320, 180, 24)
    local surface = g:pickSurface(320, 180, 24)
    example_print_log("set marker color = " .. tostring(ok))
end
```

---

#### `LGlobe:setMarkerIconTexture`

Assigns or clears a raw texture handle for a marker icon.

```lua
LGlobe:setMarkerIconTexture(id, tex_raw)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Marker id. |
| `tex_raw?` | number | Raw texture handle, or nil to clear the icon. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the marker exists. |

**Example**

```lua
do
    local g, a = build_demo_globe("marker_icon_globe")
    local ok = g:setMarkerIconTexture(a, 7)
    local id = g:pickMarker(320, 180, 24)
    local surface = g:pickSurface(320, 180, 24)
    example_print_log("set marker icon texture = " .. tostring(ok))
end
```

---

#### `LGlobe:setMarkerPulse`

Sets marker pulse frequency and amplitude.

```lua
LGlobe:setMarkerPulse(id, hz, amp)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Marker id. |
| `hz` | number | Pulse frequency in hertz, clamped to at least zero. |
| `amp` | number | Pulse amplitude clamped to 0.0 through 1.0. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the marker exists. |

**Example**

```lua
do
    local g = lurek.globe.new("pulse_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    local id = g:addMarker("alert", 0, 0, "!")
    g:setMarkerPulse(id, 2.0, 0.5)
    example_print_log("pulse set")
end
```

---

#### `LGlobe:setMarkerRotation`

Sets marker rotation speed. This method is available to Lua scripts.

```lua
LGlobe:setMarkerRotation(id, dps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Marker id. |
| `dps` | number | Rotation speed in degrees per second. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the marker exists. |

**Example**

```lua
do
    local g = lurek.globe.new("rot_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    local id = g:addMarker("spin", 0, 0)
    g:setMarkerRotation(id, 90)
    example_print_log("rotation = 90 dps")
end
```

---

#### `LGlobe:setMarkerShape`

Sets the vector fallback shape used by a marker.

```lua
LGlobe:setMarkerShape(id, shape)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Marker id. |
| `shape` | string | One of `circle`, `square`, `diamond`, `triangle`, or `cross`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the marker exists. |

**Example**

```lua
do
    local g, a = build_demo_globe("marker_shape_globe")
    local ok = g:setMarkerShape(a, "diamond")
    local id = g:pickMarker(320, 180, 24)
    local surface = g:pickSurface(320, 180, 24)
    example_print_log("set marker shape = " .. tostring(ok))
end
```

---

#### `LGlobe:setMarkerSize`

Sets marker size in screen units.

```lua
LGlobe:setMarkerSize(id, size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Marker id. |
| `size` | number | Marker size, clamped to at least 1.0. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the marker exists. |

**Example**

```lua
do
    local g, a = build_demo_globe("marker_size_globe")
    local ok = g:setMarkerSize(a, 18)
    local id = g:pickMarker(320, 180, 24)
    local surface = g:pickSurface(320, 180, 24)
    example_print_log("set marker size = " .. tostring(ok))
end
```

---

#### `LGlobe:setMarkerVisible`

Shows or hides a marker. This method is available to Lua scripts.

```lua
LGlobe:setMarkerVisible(id, vis)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Marker id. |
| `vis` | boolean | New visibility flag. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the marker exists. |

**Example**

```lua
do
    local g = lurek.globe.new("vis_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    local id = g:addMarker("pin", 0, 0)
    g:setMarkerVisible(id, false)
    example_print_log("marker hidden")
end
```

---

#### `LGlobe:setProvinceAttr`

Sets a string attribute on a province.

```lua
LGlobe:setProvinceAttr(id, key, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Province id. |
| `key` | string | Attribute key. |
| `val` | string | Attribute value. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the province exists. |

**Example**

```lua
do
    local g = lurek.globe.new("attr_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceAttr(1, "owner", "player1")
    example_print_log("set attr owner")
end
```

---

#### `LGlobe:setProvinceSector`

Assigns a province to a named sector.

```lua
LGlobe:setProvinceSector(id, sector)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Province id. |
| `sector` | string | Sector name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the province sector was set. |

**Example**

```lua
do
    local g = lurek.globe.new("sec_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceSector(1, "northern")
    example_print_log("sector set")
end
```

---

#### `LGlobe:setProvinceTexture`

Assigns a raw texture handle and UV rectangle to a province.

```lua
LGlobe:setProvinceTexture(id, tex_raw, u0, v0, u1, v1)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Province id. |
| `tex_raw` | number | Raw texture identifier stored in province attributes. |
| `u0` | number | Left UV coordinate. |
| `v0` | number | Top UV coordinate. |
| `u1` | number | Right UV coordinate. |
| `v1` | number | Bottom UV coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the province exists. |

**Example**

```lua
do
    local g = lurek.globe.new("tex_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceTexture(1, 42, 0.0, 0.0, 1.0, 1.0)
    example_print_log("province texture set")
end
```

---

#### `LGlobe:setRegionAttr`

Sets a string attribute on a semantic region.

```lua
LGlobe:setRegionAttr(id, key, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | number | Region id. |
| `key` | string | Attribute key. |
| `val` | string | Attribute value. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the region exists. |

**Example**

```lua
do
    local g = build_demo_globe("region_attr_globe")
    local ok = g:setRegionAttr(10, "climate", "temperate")
    local count = g:regionCount()
    example_print_log("set region attr = " .. tostring(ok))
    example_print_log("value = " .. tostring(g:getRegionAttr(10, "climate")))
end
```

---

#### `LGlobe:setRotation`

Sets globe rotation angle. This method is available to Lua scripts.

```lua
LGlobe:setRotation(deg)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `deg` | number | Rotation in degrees. |

**Example**

```lua
do
    local g = lurek.globe.new("srot_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:setRotation(45)
    example_print_log("rotation = 45 deg")
end
```

---

#### `LGlobe:setTimeOfDay`

Sets globe time of day modulo 24 hours.

```lua
LGlobe:setTimeOfDay(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | number | Time of day in hours. |

**Example**

```lua
do
    local g = lurek.globe.new("tod_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:setTimeOfDay(14.5)
    example_print_log("time = 14:30")
end
```

---

#### `LGlobe:type`

Returns the Lua-visible type name for this globe handle.

```lua
LGlobe:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LGlobe](#lglobe)`. |

**Example**

```lua
do
    local g = lurek.globe.new("type_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    example_print_log("type = " .. g:type())
end
```

---

#### `LGlobe:typeOf`

Returns whether this globe handle matches a supported type name.

```lua
LGlobe:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LGlobe](#lglobe)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local g = lurek.globe.new("typeof_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    example_print_log("is Globe = " .. tostring(g:typeOf("LGlobe")))
end
```

---

#### `LGlobe:update`

Advances globe simulation timers and animated state.

```lua
LGlobe:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | number | Delta time in seconds. |

**Example**

```lua
do
    local g = lurek.globe.new("upd_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:update(0.016)
    example_print_log("globe updated")
end
```

---

#### `LGlobe:zoom`

Multiplies the globe camera zoom by a factor.

```lua
LGlobe:zoom(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | number | Zoom factor. |

**Example**

```lua
do
    local g = lurek.globe.new("zoom_globe")
    g:addProvince({id = 99, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local globe_name = g:getName()
    local province_count = g:provinceCount()
    g:setCamera(0, 0, 1.0)
    g:zoom(2.0)
    local _, _, z = g:getCamera()
    example_print_log("zoom = " .. z)
end
```

---

## LGlobeRegistry

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LGlobeRegistry:get`

Returns a globe handle by registry name.

```lua
LGlobeRegistry:get(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Globe registry name. |

**Returns**

| Type | Description |
|------|-------------|
| [LGlobe](#lglobe) | Globe handle, or nil when no globe exists with that name. |

**Example**

```lua
do
    local reg = lurek.globe.newRegistry()
    local registry_type = reg:type()
    local registry_names = reg:names()
    reg:new("earth")
    example_print_log("registry get = " .. tostring(reg:get("earth")))
end
```

---

#### `LGlobeRegistry:names`

Returns all globe names currently stored in this registry.

```lua
LGlobeRegistry:names()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Globe names. |

**Example**

```lua
do
    local reg = lurek.globe.newRegistry()
    local registry_type = reg:type()
    local registry_names = reg:names()
    reg:new("earth")
    reg:new("mars")
    example_print_log("registry names count = " .. #reg:names())
end
```

---

#### `LGlobeRegistry:new`

Creates a named globe with optional specification fields.

```lua
LGlobeRegistry:new(name, spec_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Globe registry name. |
| `spec_tbl?` | table | Globe specification table. |

**Returns**

| Type | Description |
|------|-------------|
| [LGlobe](#lglobe) | New globe handle. |

**Example**

```lua
do
    local reg = lurek.globe.newRegistry()
    local registry_type = reg:type()
    local registry_names = reg:names()
    local created = reg:new("venus", { radius = 0.9 })
    example_print_log("registry new = " .. tostring(reg:new("mars", { radius = 1.0 })))
end
```

---

#### `LGlobeRegistry:remove`

Removes a globe from the registry by name.

```lua
LGlobeRegistry:remove(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Globe registry name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a globe was removed. |

**Example**

```lua
do
    local reg = lurek.globe.newRegistry()
    local registry_type = reg:type()
    local registry_names = reg:names()
    reg:new("mars")
    example_print_log("registry remove = " .. tostring(reg:remove("mars")))
end
```

---

#### `LGlobeRegistry:type`

Returns the Lua-visible type name for this globe registry handle.

```lua
LGlobeRegistry:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LGlobeRegistry](#lgloberegistry)`. |

**Example**

```lua
do
    local reg = lurek.globe.newRegistry()
    local registry_type = reg:type()
    local registry_names = reg:names()
    local created = reg:new("earth", { radius = 1.0 })
    example_print_log("registry type = " .. tostring(reg:type()))
end
```

---

#### `LGlobeRegistry:typeOf`

Returns whether this registry handle matches a supported type name.

```lua
LGlobeRegistry:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LGlobeRegistry](#lgloberegistry)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local reg = lurek.globe.newRegistry()
    local registry_type = reg:type()
    local registry_names = reg:names()
    local created = reg:new("earth", { radius = 1.0 })
    example_print_log("registry typeOf = " .. tostring(reg:typeOf("LGlobeRegistry")))
end
```

---
