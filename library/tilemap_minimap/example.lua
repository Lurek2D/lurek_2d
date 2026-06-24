--- Example usage for library.tilemap_minimap.

local TilemapMinimap = require("library.tilemap_minimap")

local map = {
    tw = 32,
    th = 32,
    solids = {
        ["2:2"] = true,
        ["3:2"] = true,
        ["3:3"] = true,
    },
}

function map:getTile(_, x, y)
    return self.solids[x .. ":" .. y] and 2 or 0
end

function map:worldToTile(wx, wy)
    return math.floor(wx / self.tw) + 1, math.floor(wy / self.th) + 1
end

local helper = TilemapMinimap.new({
    map = map,
    layer = 1,
    width = 6,
    height = 4,
    blocked_gids = { [2] = true },
    solid_terrain = 9,
    empty_terrain = 1,
})

helper:syncTerrain()
local mm = helper:getMinimap()

print("[tilemap_minimap] solid(2,2) terrain = " .. tostring(mm:getTerrain(2, 2)))
print("[tilemap_minimap] empty(1,1) terrain = " .. tostring(mm:getTerrain(1, 1)))

local tx, ty = helper:setCenterFromWorld(64, 32)
print(string.format("[tilemap_minimap] center tile = %d,%d", tx, ty))

helper:setViewportFromWorld(32, 32, 96, 64)
helper:clearViewport()
print("[tilemap_minimap] viewport update complete")
