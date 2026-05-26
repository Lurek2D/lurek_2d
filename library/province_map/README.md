# province_map

A province-map data model with adjacency graphs, routing, faction ownership, and map-mode rendering helpers. Stores provinces as nodes in a graph, computes shortest paths, flood-fill territories, and exposes a MapMode API for coloring provinces by any numeric property.

## Usage

```lua
local province_map = require("library/province_map")

local map = province_map.ProvinceMap.new()
local p1  = map:addProvince(province_map.Province.new({ id = 1, name = "Ironhollow" }))
local p2  = map:addProvince(province_map.Province.new({ id = 2, name = "Ashfield"   }))
map:addEdge(province_map.AdjacencyEdge.new({ from = 1, to = 2, passable = true }))

local route = map:route(1, 2)
print("Hops:", #route)

map:setFaction(1, "player")
local territory = map:floodFaction("player")
```

## Dependencies

- `lurek.image.newProvinceGrid` (optional), `lurek.graph.newGraph` (optional)
