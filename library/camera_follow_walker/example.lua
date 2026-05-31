--- Example usage for library.camera_follow_walker.

local CameraFollowWalker = require("library.camera_follow_walker")

local map = {
    tw = 32,
    th = 32,
    solids = { ["3:2"] = true },
}

function map:getTileDimensions()
    return self.tw, self.th
end

function map:tileToWorld(tx, ty)
    return (tx - 1) * self.tw, (ty - 1) * self.th
end

function map:worldToTile(wx, wy)
    return math.floor(wx / self.tw) + 1, math.floor(wy / self.th) + 1
end

function map:rectOverlapsSolid(_, x, y, w, h)
    local tx1 = math.floor(x / self.tw) + 1
    local ty1 = math.floor(y / self.th) + 1
    local tx2 = math.floor((x + w - 0.001) / self.tw) + 1
    local ty2 = math.floor((y + h - 0.001) / self.th) + 1

    for ty = ty1, ty2 do
        for tx = tx1, tx2 do
            if self.solids[tx .. ":" .. ty] then
                return true
            end
        end
    end

    return false
end

local helper = CameraFollowWalker.new({ map = map, layer = 1, speed = 32 })
helper:setTilePosition(2, 2)

local moved_right = helper:move(1, 0, 1.0)
print("[camera_follow_walker] move right blocked = " .. tostring(not moved_right))

local moved_down = helper:move(0, 1, 1.0)
print("[camera_follow_walker] move down ok = " .. tostring(moved_down))

helper:update(0.016, false)
local wx, wy = helper:getPosition()
local cx, cy = helper:getCameraPosition()
local tx, ty = helper:getTilePosition()

print(string.format("[camera_follow_walker] world=%.1f,%.1f tile=%d,%d", wx, wy, tx, ty))
print(string.format("[camera_follow_walker] camera=%.1f,%.1f", cx, cy))
