# Globe

- The `globe` module, situated in the Feature Systems tier, provides a comprehensive framework for rendering and interacting with an XCOM-style Geoscape.

At its core is the `Globe` structure, which oversees a highly optimized, region-based spherical map. It utilizes an orbit camera with latitude and longitude positioning, supporting smooth interpolation, variable zoom levels, and automatic Level-of-Detail (LOD) adjustments. A key architectural decision is that all rendering output consists of 2D draw commands (such as convex fans, polylines, and circles) projected from spherical coordinates, intentionally avoiding the complexity of a full 3D pipeline.

The module manages complex geographical topologies via the `RegionGraph` (aliased as `ProvinceGraph` for backward compatibility), which caches adjacency data and enables rapid pathfinding and reachability queries. Region geometry can be constructed in multiple ways: parsed from TOML descriptions, extracted from color-indexed PNG maps, or generated dynamically from Voronoi seed points. For visual presentation, the module implements advanced lighting models, including a day/night terminator band, per-region diffuse intensity, and atmospheric halos.

To support gameplay mechanics, the `globe` module features a robust `FogMask` system for fog-of-war. This system uses compact bit-packed representations to track hidden, explored, and visible states per region, per viewer, allowing for efficient serialization and multi-faction scenarios. Data visualization is handled through `MarkerStore` and `LabelStore`, which manage the placement of animated icons and text annotations directly onto the sphere's surface. Additionally, `LayerStore` allows for color-coded data overlays (heat maps), and arcs can be drawn to visualize great-circle routes. Screen-space region picking is implemented via ray-polygon intersection, ensuring precise user interaction. The entire suite of features, including multi-globe support via the `GlobeRegistry`, is fully scriptable via the `lurek.globe.*` Lua API.

> **Note on naming:** Globe internally uses "Region" as the primary type name (e.g., `Region`, `RegionId`, `RegionGraph`) to avoid confusion with the separate `crate::province` 2D province-map module. Backward-compatible aliases (`Province`, `ProvinceId`, `ProvinceGraph`) are provided. The Lua API exposes both `addProvince`/`addRegion` etc. for scripts.

## Functions

### `lurek.globe.generateVoronoi`

Creates a globe and populates provinces from latitude-longitude seed points.

```lua
-- signature
lurek.globe.generateVoronoi(name, seeds_tbl, spec_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Globe registry name. |
| `seeds_tbl` | `table` | Array table of `{lat, lon}` seed pairs. |
| `spec_tbl?` | `table` | Globe specification table. |

**Returns**

| Type | Description |
|------|-------------|
| `LGlobe` | New generated globe handle. |

**Example**

```lua
do
    local g = lurek.globe.generateVoronoi("voronoi_globe", { { 0, 0 }, { 30, 45 }, { -20, 90 }, { 60, -30 } }, {})
    print("voronoi provinces = " .. g:provinceCount())
end
```

---

### `lurek.globe.get`

Returns a globe from the module registry by name.

```lua
-- signature
lurek.globe.get(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Globe registry name. |

**Returns**

| Type | Description |
|------|-------------|
| `LGlobe` | Globe handle, or nil when no globe exists with that name. |

**Example**

```lua
do
    lurek.globe.new("my_globe")
    local g = lurek.globe.get("my_globe")
    if g then
        print("got globe: " .. g:getName())
    end
end
```

---

### `lurek.globe.greatCircleDistance`

Computes great-circle distance between two latitude-longitude points.

```lua
-- signature
lurek.globe.greatCircleDistance(la, lo, lb, lo2)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `la` | `number` | Start latitude in degrees. |
| `lo` | `number` | Start longitude in degrees. |
| `lb` | `number` | End latitude in degrees. |
| `lo2` | `number` | End longitude in degrees. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Great-circle distance on the unit sphere. |

**Example**

```lua
do
    local d = lurek.globe.greatCircleDistance(0, 0, 90, 0)
    print("distance 0,0 -> 90,0 = " .. d)
end
```

---

### `lurek.globe.greatCirclePath`

Computes sampled latitude-longitude points along a great-circle path.

```lua
-- signature
lurek.globe.greatCirclePath(la, lo, lb, lo2, n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `la` | `number` | Start latitude in degrees. |
| `lo` | `number` | Start longitude in degrees. |
| `lb` | `number` | End latitude in degrees. |
| `lo2` | `number` | End longitude in degrees. |
| `n` | `number` | Number of samples. |

**Returns**

| Type | Description |
|------|-------------|
| `GlobeGreatCirclePathResult` | Array table of `{lat, lon}` point tables. |

**Example**

```lua
do
    local points = lurek.globe.greatCirclePath(0, 0, 45, 90, 5)
    print("path has " .. #points .. " points")
    for _, p in ipairs(points) do
        print("  lat=" .. p[1] .. " lon=" .. p[2])
    end
end
```

---

### `lurek.globe.latLonToUnit`

Converts latitude and longitude to a unit-sphere 3D vector table.

```lua
-- signature
lurek.globe.latLonToUnit(lat, lon)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `lat` | `number` | Latitude in degrees. |
| `lon` | `number` | Longitude in degrees. |

**Returns**

| Type | Description |
|------|-------------|
| `GlobeLatLonToUnitResult` | Array table `{x, y, z}` on the unit sphere. |

**Example**

```lua
do
    local v = lurek.globe.latLonToUnit(0, 0)
    print("unit vec = " .. v[1] .. "," .. v[2] .. "," .. v[3])
end
```

---

### `lurek.globe.loadFromPNG`

Creates a globe and populates provinces from a PNG file.

```lua
-- signature
lurek.globe.loadFromPNG(name, png_path, spec_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Globe registry name. |
| `png_path` | `string` | PNG file path to load. |
| `spec_tbl?` | `table` | Globe specification table. |

**Returns**

| Type | Description |
|------|-------------|
| `LGlobe` | New populated globe handle. |

**Example**

```lua
do
    local g = lurek.globe.loadFromPNG("png_globe", "assets/textures/province_map.png")
    print("png globe provinces = " .. g:provinceCount())
end
```

---

### `lurek.globe.loadFromTOML`

Creates a globe and populates provinces from TOML source text.

```lua
-- signature
lurek.globe.loadFromTOML(name, toml_src, spec_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Globe registry name. |
| `toml_src` | `string` | TOML province document source. |
| `spec_tbl?` | `table` | Globe specification table. |

**Returns**

| Type | Description |
|------|-------------|
| `LGlobe` | New populated globe handle. |

**Example**

```lua
do
    local toml = '[[province]]\nid = 1\ncentroid = [10.0, 20.0]\nvertices = [[10.0, 19.0], [11.0, 20.0], [10.0, 21.0], [9.0, 20.0]]'
    local g = lurek.globe.loadFromTOML("toml_globe", toml)
    print("toml globe provinces = " .. g:provinceCount())
end
```

---

### `lurek.globe.loadFromTOMLFile`

Creates a globe and populates provinces from a TOML file path.

```lua
-- signature
lurek.globe.loadFromTOMLFile(name, path, spec_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Globe registry name. |
| `path` | `string` | TOML file path to load. |
| `spec_tbl?` | `table` | Globe specification table. |

**Returns**

| Type | Description |
|------|-------------|
| `LGlobe` | New populated globe handle. |

**Example**

```lua
do
    local path = "logs/globe_example.toml"
    lurek.filesystem.write(path, "[[province]]\nid = 1\ncentroid = [10.0, 20.0]\nvertices = [[10.0, 19.0], [11.0, 20.0], [10.0, 21.0], [9.0, 20.0]]\n")

    local g = lurek.globe.loadFromTOMLFile("toml_file_globe", path, {})
    print("toml file globe provinces = " .. g:provinceCount())
end
```

---

### `lurek.globe.new`

Creates a named globe with optional specification fields in the module registry.

```lua
-- signature
lurek.globe.new(name, spec_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Globe registry name. |
| `spec_tbl?` | `table` | Globe specification table. |

**Returns**

| Type | Description |
|------|-------------|
| `LGlobe` | New globe handle. |

**Example**

```lua
do
    local g = lurek.globe.new("test_globe")
    print("globe type = " .. g:type())
end
```

---

### `lurek.globe.raySphereIntersect`

Intersects a 3D ray with a sphere and returns the nearest positive hit distance.

```lua
-- signature
lurek.globe.raySphereIntersect(ox, oy, oz, dx, dy, dz, radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ox` | `number` | Ray origin x. |
| `oy` | `number` | Ray origin y. |
| `oz` | `number` | Ray origin z. |
| `dx` | `number` | Ray direction x. |
| `dy` | `number` | Ray direction y. |
| `dz` | `number` | Ray direction z. |
| `radius` | `number` | Sphere radius. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Hit distance `t`, or nil when the ray misses. |

**Example**

```lua
do
    local t = lurek.globe.raySphereIntersect(0.0, 0.0, -2.0, 0.0, 0.0, 1.0, 1.0)
    print("hit distance = " .. tostring(t))
    print("ray hits sphere = " .. tostring(t ~= nil))
end
```

---

### `lurek.globe.remove`

Removes a globe from the registry by name.

```lua
-- signature
lurek.globe.remove(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Globe registry name. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when a globe was removed. |

**Example**

```lua
do
    local g = lurek.globe.new("tmp_remove")
    local ok = lurek.globe.remove("tmp_remove")
    print("removed=" .. tostring(ok))
end
```

---

## LGlobe

### `LGlobe:addArc`

Adds a visible route arc between two latitude and longitude points.

```lua
-- signature
LGlobe:addArc(lat1, lon1, lat2, lon2, steps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `lat1` | `number` | Start latitude in degrees. |
| `lon1` | `number` | Start longitude in degrees. |
| `lat2` | `number` | End latitude in degrees. |
| `lon2` | `number` | End longitude in degrees. |
| `steps?` | `number` | Point count for the arc, defaulting to 24. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | New arc id. |

**Example**

```lua
do
    local g = lurek.globe.new("arc_globe")
    local id = g:addArc(0, 0, 45, 90, 12)
    print("arc id = " .. id)
end
```

---

### `LGlobe:addLabel`

Adds a text label at latitude and longitude.

```lua
-- signature
LGlobe:addLabel(ltype, lat, lon, text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ltype` | `string` | Label type name. |
| `lat` | `number` | Latitude in degrees. |
| `lon` | `number` | Longitude in degrees. |
| `text` | `string` | Label text. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | New label id. |

**Example**

```lua
do
    local g = lurek.globe.new("lbl_globe")
    local id = g:addLabel("region", 40, -74, "New York")
    print("label id = " .. id)
end
```

---

### `LGlobe:addLayer`

Adds a render layer with optional z-order.

```lua
-- signature
LGlobe:addLayer(name, z_order)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Layer name. |
| `z_order?` | `number` | Layer z-order, defaulting to zero. |

**Example**

```lua
do
    local g = lurek.globe.new("layer_globe")
    g:addLayer("terrain", 0)
    g:addLayer("borders", 1)
    print("layers added")
end
```

---

### `LGlobe:addMarker`

Adds a marker at latitude and longitude with an optional label.

```lua
-- signature
LGlobe:addMarker(mtype, lat, lon, label)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mtype` | `string` | Marker type name. |
| `lat` | `number` | Latitude in degrees. |
| `lon` | `number` | Longitude in degrees. |
| `label?` | `string` | Marker label. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | New marker id. |

**Example**

```lua
do
    local g = lurek.globe.new("mark_globe")
    local id = g:addMarker("city", 51.5, -0.12, "London")
    print("marker id = " .. id)
end
```

---

### `LGlobe:addProvince`

Adds a province described by id, centroid, vertices, neighbors, and optional base color.

```lua
-- signature
LGlobe:addProvince(p)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `p` | `table` | Province table with `id`, `centroid`, `vertices`, optional `neighbors`, and optional `base_color`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the province was accepted by the globe. |

**Example**

```lua
do
    local g = lurek.globe.new("prov_globe")
    local ok = g:addProvince({ id = 1, centroid = { 10.0, 20.0 }, vertices = { { 9, 19 }, { 11, 19 }, { 11, 21 }, { 9, 21 } } })
    print("added = " .. tostring(ok))
end
```

---

### `LGlobe:addRegion`

Adds a region described by id, centroid, vertices, neighbors, and optional base color.

```lua
-- signature
LGlobe:addRegion(p)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `p` | `table` | Region table with `id`, `centroid`, `vertices`, optional `neighbors`, and optional `base_color`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the region was accepted by the globe. |

**Example**

```lua
do
    local g = lurek.globe.new("region_globe")
    local ok = g:addRegion({
        id = 1,
        centroid = { 50, 15 },
        vertices = { { 49, 14 }, { 51, 14 }, { 51, 16 }, { 49, 16 } },
    })
    print("added region = " .. tostring(ok))
    print("region count = " .. g:regionCount())
end
```

---

### `LGlobe:cacheReachability`

Caches default-cost reachability for a named faction.

```lua
-- signature
LGlobe:cacheReachability(faction, start_id, max_cost)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `faction` | `string` | Faction cache key. |
| `start_id` | `number` | Start province id. |
| `max_cost` | `number` | Maximum traversal cost. |

**Example**

```lua
do
    local g = lurek.globe.new("cache_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:cacheReachability("faction_a", 1, 5.0)
    print("reachability cached")
end
```

---

### `LGlobe:clearProvinceTexture`

Removes texture metadata from a province.

```lua
-- signature
LGlobe:clearProvinceTexture(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Province id. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the province exists. |

**Example**

```lua
do
    local g = lurek.globe.new("ctex_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceTexture(1, 42, 0, 0, 1, 1)
    g:clearProvinceTexture(1)
    print("texture cleared")
end
```

---

### `LGlobe:decodeFogBase64`

Loads one viewer's fog state from a base64 string.

```lua
-- signature
LGlobe:decodeFogBase64(viewer, payload)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `viewer` | `string` | Viewer name. |
| `payload` | `string` | Base64-encoded fog state. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the payload was decoded. |

**Example**

```lua
do
    local g = lurek.globe.new("dec_globe")
    local b64 = g:encodeFogBase64("p1")
    local ok = g:decodeFogBase64("p1", b64)
    print("decoded = " .. tostring(ok))
end
```

---

### `LGlobe:encodeFogBase64`

Serializes one viewer's fog state to a base64 string.

```lua
-- signature
LGlobe:encodeFogBase64(viewer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `viewer` | `string` | Viewer name. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Base64-encoded fog state, or an empty string on encode failure. |

**Example**

```lua
do
    local g = lurek.globe.new("enc_globe")
    local b64 = g:encodeFogBase64("p1")
    print("encoded fog length = " .. #b64)
end
```

---

### `LGlobe:exportProvinceMeshOBJ`

Exports province geometry as Wavefront OBJ text.

```lua
-- signature
LGlobe:exportProvinceMeshOBJ()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | OBJ mesh text for the current provinces. |

**Example**

```lua
do
    local g = lurek.globe.new("obj_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local obj = g:exportProvinceMeshOBJ()
    print("OBJ length = " .. #obj)
end
```

---

### `LGlobe:findPath`

Finds a default-cost province path between two province ids.

```lua
-- signature
LGlobe:findPath(from_id, to_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_id` | `number` | Start province id. |
| `to_id` | `number` | Target province id. |

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Province ids, or nil when no path exists. |

**Example**

```lua
do
    local g = lurek.globe.new("path_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}, neighbors = {2}})
    g:addProvince({id = 2, centroid = {5, 0}, vertices = {{4, -1}, {6, -1}, {6, 1}, {4, 1}}, neighbors = {1}})
    print("path length = " .. #(g:findPath(1, 2) or {}))
end
```

---

### `LGlobe:getCachedReachability`

Returns cached reachability costs for a faction.

```lua
-- signature
LGlobe:getCachedReachability(faction)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `faction` | `string` | Faction cache key. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Map table from province id (integer key) to accumulated traversal cost (number), empty when missing. |

**Example**

```lua
do
    local g = lurek.globe.new("gcache_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:cacheReachability("faction_b", 1, 5.0)
    local costs = g:getCachedReachability("faction_b")
    print("cached costs type = " .. type(costs))
    print("cached cost to 1 = " .. tostring(costs[1]))
end
```

---

### `LGlobe:getCamera`

Returns camera latitude, longitude, and zoom.

```lua
-- signature
LGlobe:getCamera()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Camera latitude in degrees. |
| `number` | b Camera longitude in degrees. |
| `number` | c Camera zoom. |

**Example**

```lua
do
    local g = lurek.globe.new("gcam_globe")
    g:setCamera(30, 60, 1.5)
    local lat, lon, z = g:getCamera()
    print("camera: " .. lat .. "," .. lon .. " z=" .. z)
end
```

---

### `LGlobe:getFogState`

Returns fog-of-war state for one viewer and province.

```lua
-- signature
LGlobe:getFogState(viewer, id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `viewer` | `string` | Viewer name. |
| `id` | `number` | Province id. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | `visible`, `explored`, or `hidden`. |

**Example**

```lua
do
    local g = lurek.globe.new("gfs_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setFogState("p1", 1, "visible")
    local state = g:getFogState("p1", 1)
    print("fog = " .. state)
end
```

---

### `LGlobe:getLod`

Returns the camera-derived level-of-detail tier name.

```lua
-- signature
LGlobe:getLod()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | One of `far`, `mid`, or `near`. |

**Example**

```lua
do
    local g = lurek.globe.new("lod_globe")
    g:setCamera(0, 0, 0.5)
    print("lod = " .. g:getLod())
end
```

---

### `LGlobe:getMarkerAttr`

Reads a string attribute from a marker.

```lua
-- signature
LGlobe:getMarkerAttr(id, key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Marker id. |
| `key` | `string` | Attribute key. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Attribute string, or nil when missing. |

**Example**

```lua
do
    local g = lurek.globe.new("ga_globe")
    local id = g:addMarker("city", 48.8, 2.3, "Paris")
    g:setMarkerAttr(id, "country", "France")
    local val = g:getMarkerAttr(id, "country")
    print("country = " .. tostring(val))
end
```

---

### `LGlobe:getName`

Returns the registry name of this globe.

```lua
-- signature
LGlobe:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Globe registry name. |

**Example**

```lua
do
    local g = lurek.globe.new("named_globe")
    print("name = " .. g:getName())
end
```

---

### `LGlobe:getNeighbors`

Returns neighboring province ids for a province.

```lua
-- signature
LGlobe:getNeighbors(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Province id. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array table of neighboring province ids. |

**Example**

```lua
do
    local g = lurek.globe.new("neigh_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}, neighbors = {2}})
    local n = g:getNeighbors(1)
    print("neighbors of 1: " .. #n)
end
```

---

### `LGlobe:getProvinceAttr`

Reads a string attribute from a province.

```lua
-- signature
LGlobe:getProvinceAttr(id, key)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Province id. |
| `key` | `string` | Attribute key. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Attribute string, or nil when the province or key is missing. |

**Example**

```lua
do
    local g = lurek.globe.new("rattr_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceAttr(1, "terrain", "forest")
    local val = g:getProvinceAttr(1, "terrain")
    print("terrain = " .. tostring(val))
end
```

---

### `LGlobe:getProvinceSector`

Returns the sector name assigned to a province.

```lua
-- signature
LGlobe:getProvinceSector(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Province id. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Sector string, or nil when absent. |

**Example**

```lua
do
    local g = lurek.globe.new("gsec_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceSector(1, "eastern")
    local s = g:getProvinceSector(1)
    print("sector = " .. tostring(s))
end
```

---

### `LGlobe:getSectorProvinces`

Returns province ids assigned to a sector.

```lua
-- signature
LGlobe:getSectorProvinces(sector)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sector` | `string` | Sector name. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array table of province ids. |

**Example**

```lua
do
    local g = lurek.globe.new("sp_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceSector(1, "west")
    local ids = g:getSectorProvinces("west")
    print("west has " .. #ids .. " provinces")
end
```

---

### `LGlobe:getTimeOfDay`

Returns globe time of day. This method is available to Lua scripts.

```lua
-- signature
LGlobe:getTimeOfDay()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Time of day in hours. |

**Example**

```lua
do
    local g = lurek.globe.new("gtod_globe")
    g:setTimeOfDay(8.0)
    local t = g:getTimeOfDay()
    print("time of day = " .. t)
end
```

---

### `LGlobe:hideProvince`

Hides a province for one fog-of-war viewer.

```lua
-- signature
LGlobe:hideProvince(viewer, id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `viewer` | `string` | Viewer name. |
| `id` | `number` | Province id. |

**Example**

```lua
do
    local g = lurek.globe.new("hide_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:hideProvince("player1", 1)
    print("province 1 hidden")
end
```

---

### `LGlobe:isVisible`

Returns whether a province is visible for one fog-of-war viewer.

```lua
-- signature
LGlobe:isVisible(viewer, id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `viewer` | `string` | Viewer name. |
| `id` | `number` | Province id. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the province is visible. |

**Example**

```lua
do
    local g = lurek.globe.new("isv_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:revealProvince("p1", 1)
    print("visible = " .. tostring(g:isVisible("p1", 1)))
end
```

---

### `LGlobe:moveMarker`

Moves a marker to latitude and longitude coordinates.

```lua
-- signature
LGlobe:moveMarker(id, lat, lon)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Marker id. |
| `lat` | `number` | Latitude in degrees. |
| `lon` | `number` | Longitude in degrees. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the marker exists. |

**Example**

```lua
do
    local g = lurek.globe.new("mv_globe")
    local id = g:addMarker("pin", 0, 0)
    g:moveMarker(id, 10, 20)
    print("marker moved")
end
```

---

### `LGlobe:pan`

Pans the globe camera by latitude and longitude deltas.

```lua
-- signature
LGlobe:pan(dlat, dlon)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dlat` | `number` | Latitude delta in degrees. |
| `dlon` | `number` | Longitude delta in degrees. |

**Example**

```lua
do
    local g = lurek.globe.new("pan_globe")
    g:setCamera(0, 0, 1.0)
    g:pan(10, 20)
    local lat, lon, z = g:getCamera()
    print("after pan: " .. lat .. "," .. lon)
end
```

---

### `LGlobe:pick`

Picks a province at screen coordinates.

```lua
-- signature
LGlobe:pick(sx, sy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | `number` | Screen x coordinate. |
| `sy` | `number` | Screen y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Province id, or nil when nothing is hit. |

**Example**

```lua
do
    local g = lurek.globe.new("pick_globe")
    local id = g:pick(400, 300)
    print("picked province = " .. tostring(id))
end
```

---

### `LGlobe:pickLatLon`

Picks at screen coordinates and returns the hit province centroid screen coordinates.

```lua
-- signature
LGlobe:pickLatLon(sx, sy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | `number` | Screen x coordinate. |
| `sy` | `number` | Screen y coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | a Centroid x coordinate, or nil when nothing is hit. |
| `number` | b Centroid y coordinate, or nil when nothing is hit. |

**Example**

```lua
do
    local g = lurek.globe.new("pll_globe")
    local cx, cy = g:pickLatLon(400, 300)
    print("centroid = " .. tostring(cx) .. "," .. tostring(cy))
end
```

---

### `LGlobe:pickRaycast`

Samples along a screen ray from the camera center and returns the first hit province.

```lua
-- signature
LGlobe:pickRaycast(sx, sy, steps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sx` | `number` | Target screen x coordinate. |
| `sy` | `number` | Target screen y coordinate. |
| `steps?` | `number` | Number of samples along the ray, defaulting to 24. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Province id, or nil when no sample hits. |

**Example**

```lua
do
    local g = lurek.globe.new("pray_globe")
    local id = g:pickRaycast(400, 300, 32)
    print("raycast pick = " .. tostring(id))
end
```

---

### `LGlobe:provinceCount`

Returns the number of regions in this globe.

```lua
-- signature
LGlobe:provinceCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Region count. |

**Example**

```lua
do
    local g = lurek.globe.new("count_globe")
    print("provinces = " .. g:provinceCount())
end
```

---

### `LGlobe:reachable`

Returns provinces reachable from a start province within a cost budget.

```lua
-- signature
LGlobe:reachable(start_id, max_cost)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `start_id` | `number` | Start province id. |
| `max_cost` | `number` | Maximum traversal cost. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Map table from province id (integer key) to accumulated traversal cost (number). |

**Example**

```lua
do
    local g = lurek.globe.new("reach_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}, neighbors = {2}})
    g:addProvince({id = 2, centroid = {5, 0}, vertices = {{4, -1}, {6, -1}, {6, 1}, {4, 1}}, neighbors = {1}})
    local costs = g:reachable(1, 10.0)
    print("cost to 1 = " .. tostring(costs[1]))
    print("cost to 2 = " .. tostring(costs[2]))
end
```

---

### `LGlobe:regionCount`

Returns the number of regions in this globe.

```lua
-- signature
LGlobe:regionCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Region count. |

**Example**

```lua
do
    local g = lurek.globe.new("count_region_globe")
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
    print("region count = " .. g:regionCount())
end
```

---

### `LGlobe:removeArc`

Removes an arc by id. This method is available to Lua scripts.

```lua
-- signature
LGlobe:removeArc(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Arc id. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when an arc was removed. |

**Example**

```lua
do
    local g = lurek.globe.new("rarc_globe")
    local id = g:addArc(0, 0, 30, 60)
    local ok = g:removeArc(id)
    print("arc removed = " .. tostring(ok))
end
```

---

### `LGlobe:removeHeatLayer`

Removes a heat layer by name. This method is available to Lua scripts.

```lua
-- signature
LGlobe:removeHeatLayer(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Heat layer name. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when a layer was removed. |

**Example**

```lua
do
    local g = lurek.globe.new("rheat_globe")
    g:setHeatLayer("income", "gdp", 0, 50000, 0.5)
    local ok = g:removeHeatLayer("income")
    print("heat removed = " .. tostring(ok))
end
```

---

### `LGlobe:removeLabel`

Removes a label by id. This method is available to Lua scripts.

```lua
-- signature
LGlobe:removeLabel(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Label id. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when a label was removed. |

**Example**

```lua
do
    local g = lurek.globe.new("rlbl_globe")
    local id = g:addLabel("tmp", 0, 0, "temp")
    local ok = g:removeLabel(id)
    print("label removed = " .. tostring(ok))
end
```

---

### `LGlobe:removeLayer`

Removes a render layer by name. This method is available to Lua scripts.

```lua
-- signature
LGlobe:removeLayer(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Layer name. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when a layer was removed. |

**Example**

```lua
do
    local g = lurek.globe.new("rl_globe")
    g:addLayer("temp_layer")
    local ok = g:removeLayer("temp_layer")
    print("layer removed = " .. tostring(ok))
end
```

---

### `LGlobe:removeMarker`

Removes a marker by id. This method is available to Lua scripts.

```lua
-- signature
LGlobe:removeMarker(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Marker id. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when a marker was removed. |

**Example**

```lua
do
    local g = lurek.globe.new("rm_globe")
    local id = g:addMarker("pin", 0, 0)
    local ok = g:removeMarker(id)
    print("removed marker = " .. tostring(ok))
end
```

---

### `LGlobe:removeProvince`

Removes a region by id. This method is available to Lua scripts.

```lua
-- signature
LGlobe:removeProvince(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Region id to remove. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when a region was removed. |

**Example**

```lua
do
    local g = lurek.globe.new("rem_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    local ok = g:removeProvince(1)
    print("removed = " .. tostring(ok))
end
```

---

### `LGlobe:removeRegion`

Removes a region by id. This method is available to Lua scripts.

```lua
-- signature
LGlobe:removeRegion(id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Region id to remove. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when a region was removed. |

**Example**

```lua
do
    local g = lurek.globe.new("remove_region_globe")
    g:addRegion({
        id = 1,
        centroid = { 40, -90 },
        vertices = { { 39, -91 }, { 41, -91 }, { 41, -89 }, { 39, -89 } },
    })
    local ok = g:removeRegion(1)
    print("removed region = " .. tostring(ok))
    print("region count = " .. g:regionCount())
end
```

---

### `LGlobe:revealAll`

Reveals every province for one fog-of-war viewer.

```lua
-- signature
LGlobe:revealAll(viewer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `viewer` | `string` | Viewer name. |

**Example**

```lua
do
    local g = lurek.globe.new("rall_globe")
    g:revealAll("player1")
    print("all revealed for player1")
end
```

---

### `LGlobe:revealProvince`

Reveals a province for one fog-of-war viewer.

```lua
-- signature
LGlobe:revealProvince(viewer, id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `viewer` | `string` | Viewer name. |
| `id` | `number` | Province id. |

**Example**

```lua
do
    local g = lurek.globe.new("rev_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:revealProvince("player1", 1)
    print("province 1 revealed")
end
```

---

### `LGlobe:setActiveViewer`

Sets the active fog-of-war viewer name or clears it.

```lua
-- signature
LGlobe:setActiveViewer(viewer)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `viewer?` | `string` | Viewer name. |

**Example**

```lua
do
    local g = lurek.globe.new("fow_globe")
    g:setActiveViewer("player1")
    print("active viewer = player1")
end
```

---

### `LGlobe:setAutoRotationSpeed`

Sets automatic globe rotation speed.

```lua
-- signature
LGlobe:setAutoRotationSpeed(dps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dps` | `number` | Rotation speed in degrees per second. |

**Example**

```lua
do
    local g = lurek.globe.new("arot_globe")
    g:setAutoRotationSpeed(10)
    print("auto rotation = 10 dps")
end
```

---

### `LGlobe:setBorders`

Enables or disables province border rendering.

```lua
-- signature
LGlobe:setBorders(show)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `show` | `boolean` | New border visibility flag. |

**Example**

```lua
do
    local g = lurek.globe.new("bord_globe")
    g:setBorders(true)
    print("borders enabled")
end
```

---

### `LGlobe:setCamera`

Sets camera latitude, longitude, and zoom.

```lua
-- signature
LGlobe:setCamera(lat, lon, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `lat` | `number` | Camera latitude in degrees. |
| `lon` | `number` | Camera longitude in degrees. |
| `z` | `number` | Camera zoom, clamped to at least 0.1. |

**Example**

```lua
do
    local g = lurek.globe.new("cam_globe")
    g:setCamera(45, 90, 2.0)
    print("camera set")
end
```

---

### `LGlobe:setFogState`

Sets fog-of-war state for one viewer and province.

```lua
-- signature
LGlobe:setFogState(viewer, id, state)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `viewer` | `string` | Viewer name. |
| `id` | `number` | Province id. |
| `state` | `string` | `visible`, `explored`, or any other value for hidden. |

**Example**

```lua
do
    local g = lurek.globe.new("fs_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setFogState("p1", 1, "explored")
    print("fog state set to explored")
end
```

---

### `LGlobe:setHeatLayer`

Creates or replaces a heat layer that maps province attributes into colors.

```lua
-- signature
LGlobe:setHeatLayer(name, attr_key, min, max, alpha)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Heat layer name. |
| `attr_key` | `string` | Province attribute key read as a numeric value. |
| `min` | `number` | Attribute value mapped to cold color. |
| `max` | `number` | Attribute value mapped to hot color. |
| `alpha` | `number` | Layer alpha clamped to 0.0 through 1.0. |

**Example**

```lua
do
    local g = lurek.globe.new("heat_globe")
    g:setHeatLayer("population", "pop", 0, 1000000, 0.7)
    print("heat layer set")
end
```

---

### `LGlobe:setLabelText`

Changes text for an existing label.

```lua
-- signature
LGlobe:setLabelText(id, text)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Label id. |
| `text` | `string` | New label text. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the label exists. |

**Example**

```lua
do
    local g = lurek.globe.new("ltxt_globe")
    local id = g:addLabel("city", 0, 0, "old")
    g:setLabelText(id, "new")
    print("label updated")
end
```

---

### `LGlobe:setLabelVisible`

Shows or hides a label. This method is available to Lua scripts.

```lua
-- signature
LGlobe:setLabelVisible(id, vis)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Label id. |
| `vis` | `boolean` | New visibility flag. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the label exists. |

**Example**

```lua
do
    local g = lurek.globe.new("lvis_globe")
    local id = g:addLabel("info", 0, 0, "text")
    g:setLabelVisible(id, false)
    print("label hidden")
end
```

---

### `LGlobe:setLayerAlpha`

Sets render layer alpha. This method is available to Lua scripts.

```lua
-- signature
LGlobe:setLayerAlpha(name, alpha)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Layer name. |
| `alpha` | `number` | Layer alpha. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the layer exists. |

**Example**

```lua
do
    local g = lurek.globe.new("la_globe")
    g:addLayer("fog_layer")
    g:setLayerAlpha("fog_layer", 0.5)
    print("layer alpha = 0.5")
end
```

---

### `LGlobe:setLayerColor`

Sets a province color override inside a render layer.

```lua
-- signature
LGlobe:setLayerColor(layer, id, r, g, b, a)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer` | `string` | Layer name. |
| `id` | `number` | Province id. |
| `r` | `number` | Red channel. |
| `g` | `number` | Green channel. |
| `b` | `number` | Blue channel. |
| `a` | `number` | Alpha channel. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the layer exists. |

**Example**

```lua
do
    local g = lurek.globe.new("lc_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:addLayer("highlight")
    g:setLayerColor("highlight", 1, 1.0, 0.0, 0.0, 1.0)
    print("province 1 colored red in highlight layer")
end
```

---

### `LGlobe:setLayerVisible`

Shows or hides a render layer. This method is available to Lua scripts.

```lua
-- signature
LGlobe:setLayerVisible(name, vis)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Layer name. |
| `vis` | `boolean` | New visibility flag. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the layer exists. |

**Example**

```lua
do
    local g = lurek.globe.new("lv_globe")
    g:addLayer("overlay")
    g:setLayerVisible("overlay", false)
    print("overlay hidden")
end
```

---

### `LGlobe:setMarkerAttr`

Sets a string attribute on a marker.

```lua
-- signature
LGlobe:setMarkerAttr(id, key, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Marker id. |
| `key` | `string` | Attribute key. |
| `val` | `string` | Attribute value. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the marker exists. |

**Example**

```lua
do
    local g = lurek.globe.new("ma_globe")
    local id = g:addMarker("city", 48.8, 2.3, "Paris")
    g:setMarkerAttr(id, "population", "2M")
    print("marker attr set")
end
```

---

### `LGlobe:setMarkerPulse`

Sets marker pulse frequency and amplitude.

```lua
-- signature
LGlobe:setMarkerPulse(id, hz, amp)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Marker id. |
| `hz` | `number` | Pulse frequency in hertz, clamped to at least zero. |
| `amp` | `number` | Pulse amplitude clamped to 0.0 through 1.0. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the marker exists. |

**Example**

```lua
do
    local g = lurek.globe.new("pulse_globe")
    local id = g:addMarker("alert", 0, 0, "!")
    g:setMarkerPulse(id, 2.0, 0.5)
    print("pulse set")
end
```

---

### `LGlobe:setMarkerRotation`

Sets marker rotation speed. This method is available to Lua scripts.

```lua
-- signature
LGlobe:setMarkerRotation(id, dps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Marker id. |
| `dps` | `number` | Rotation speed in degrees per second. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the marker exists. |

**Example**

```lua
do
    local g = lurek.globe.new("rot_globe")
    local id = g:addMarker("spin", 0, 0)
    g:setMarkerRotation(id, 90)
    print("rotation = 90 dps")
end
```

---

### `LGlobe:setMarkerVisible`

Shows or hides a marker. This method is available to Lua scripts.

```lua
-- signature
LGlobe:setMarkerVisible(id, vis)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Marker id. |
| `vis` | `boolean` | New visibility flag. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the marker exists. |

**Example**

```lua
do
    local g = lurek.globe.new("vis_globe")
    local id = g:addMarker("pin", 0, 0)
    g:setMarkerVisible(id, false)
    print("marker hidden")
end
```

---

### `LGlobe:setProvinceAttr`

Sets a string attribute on a province.

```lua
-- signature
LGlobe:setProvinceAttr(id, key, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Province id. |
| `key` | `string` | Attribute key. |
| `val` | `string` | Attribute value. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the province exists. |

**Example**

```lua
do
    local g = lurek.globe.new("attr_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceAttr(1, "owner", "player1")
    print("set attr owner")
end
```

---

### `LGlobe:setProvinceSector`

Assigns a province to a named sector.

```lua
-- signature
LGlobe:setProvinceSector(id, sector)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Province id. |
| `sector` | `string` | Sector name. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the province sector was set. |

**Example**

```lua
do
    local g = lurek.globe.new("sec_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceSector(1, "northern")
    print("sector set")
end
```

---

### `LGlobe:setProvinceTexture`

Assigns a raw texture handle and UV rectangle to a province.

```lua
-- signature
LGlobe:setProvinceTexture(id, tex_raw, u0, v0, u1, v1)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `number` | Province id. |
| `tex_raw` | `number` | Raw texture identifier stored in province attributes. |
| `u0` | `number` | Left UV coordinate. |
| `v0` | `number` | Top UV coordinate. |
| `u1` | `number` | Right UV coordinate. |
| `v1` | `number` | Bottom UV coordinate. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the province exists. |

**Example**

```lua
do
    local g = lurek.globe.new("tex_globe")
    g:addProvince({id = 1, centroid = {0, 0}, vertices = {{-1, -1}, {1, -1}, {1, 1}, {-1, 1}}})
    g:setProvinceTexture(1, 42, 0.0, 0.0, 1.0, 1.0)
    print("province texture set")
end
```

---

### `LGlobe:setRotation`

Sets globe rotation angle. This method is available to Lua scripts.

```lua
-- signature
LGlobe:setRotation(deg)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `deg` | `number` | Rotation in degrees. |

**Example**

```lua
do
    local g = lurek.globe.new("srot_globe")
    g:setRotation(45)
    print("rotation = 45 deg")
end
```

---

### `LGlobe:setTimeOfDay`

Sets globe time of day modulo 24 hours.

```lua
-- signature
LGlobe:setTimeOfDay(t)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `t` | `number` | Time of day in hours. |

**Example**

```lua
do
    local g = lurek.globe.new("tod_globe")
    g:setTimeOfDay(14.5)
    print("time = 14:30")
end
```

---

### `LGlobe:type`

Returns the Lua-visible type name for this globe handle.

```lua
-- signature
LGlobe:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LGlobe`. |

**Example**

```lua
do
    local g = lurek.globe.new("type_globe")
    print("type = " .. g:type())
end
```

---

### `LGlobe:typeOf`

Returns whether this globe handle matches a supported type name.

```lua
-- signature
LGlobe:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LGlobe` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local g = lurek.globe.new("typeof_globe")
    print("is Globe = " .. tostring(g:typeOf("LGlobe")))
end
```

---

### `LGlobe:update`

Advances globe simulation timers and animated state.

```lua
-- signature
LGlobe:update(dt)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `dt` | `number` | Delta time in seconds. |

**Example**

```lua
do
    local g = lurek.globe.new("upd_globe")
    g:update(0.016)
    print("globe updated")
end
```

---

### `LGlobe:zoom`

Multiplies the globe camera zoom by a factor.

```lua
-- signature
LGlobe:zoom(factor)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `factor` | `number` | Zoom factor. |

**Example**

```lua
do
    local g = lurek.globe.new("zoom_globe")
    g:setCamera(0, 0, 1.0)
    g:zoom(2.0)
    local _, _, z = g:getCamera()
    print("zoom = " .. z)
end
```

---

## LGlobeRegistry

### `LGlobeRegistry:get`

Returns a globe handle by registry name.

```lua
-- signature
LGlobeRegistry:get(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Globe registry name. |

**Returns**

| Type | Description |
|------|-------------|
| `LGlobe` | Globe handle, or nil when no globe exists with that name. |

**Example**

```lua
do
    local reg = nil
    print("registry handle available = " .. tostring(reg ~= nil))
    print("registry get = " .. tostring(reg and reg:get("earth") or nil))
end
```

---

### `LGlobeRegistry:names`

Returns all globe names currently stored in this registry.

```lua
-- signature
LGlobeRegistry:names()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Globe names. |

**Example**

```lua
do
    local reg = nil
    print("registry handle available = " .. tostring(reg ~= nil))
    print("registry names = " .. tostring(reg and reg:names() or nil))
end
```

---

### `LGlobeRegistry:new`

Creates a named globe with optional specification fields.

```lua
-- signature
LGlobeRegistry:new(name, spec_tbl)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Globe registry name. |
| `spec_tbl?` | `table` | Globe specification table. |

**Returns**

| Type | Description |
|------|-------------|
| `LGlobe` | New globe handle. |

**Example**

```lua
do
    local reg = nil
    print("registry handle available = " .. tostring(reg ~= nil))
    print("registry new = " .. tostring(reg and reg:new("mars", { radius = 1.0 }) or nil))
end
```

---

### `LGlobeRegistry:remove`

Removes a globe from the registry by name.

```lua
-- signature
LGlobeRegistry:remove(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Globe registry name. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when a globe was removed. |

**Example**

```lua
do
    local reg = nil
    print("registry handle available = " .. tostring(reg ~= nil))
    print("registry remove = " .. tostring(reg and reg:remove("mars") or nil))
end
```

---

### `LGlobeRegistry:type`

Returns the Lua-visible type name for this globe registry handle.

```lua
-- signature
LGlobeRegistry:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LGlobeRegistry`. |

**Example**

```lua
do
    local reg = nil
    print("registry handle available = " .. tostring(reg ~= nil))
    print("registry type = " .. tostring(reg and reg:type() or nil))
end
```

---

### `LGlobeRegistry:typeOf`

Returns whether this registry handle matches a supported type name.

```lua
-- signature
LGlobeRegistry:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LGlobeRegistry` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local reg = nil
    print("registry handle available = " .. tostring(reg ~= nil))
    print("registry typeOf = " .. tostring(reg and reg:typeOf("LGlobeRegistry") or nil))
end
```

---
