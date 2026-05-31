-- @module library.camera_follow_walker
--- @status full
--- Helper that combines tilemap collision probing with camera_follow smoothing.
---
--- The walker keeps a world-space center point and uses
--- `LTileMap:rectOverlapsSolid` as a tile collision pre-check.

local CameraFollow = require("library.camera_follow")

local camera_follow_walker = {}

local WalkerCamera = {}
WalkerCamera.__index = WalkerCamera

local function resolve_tile_size(map)
    if map and map.getTileDimensions then
        local tw, th = map:getTileDimensions()
        if tw and th then
            return tw, th
        end
    end

    if map and map.getTileWidth and map.getTileHeight then
        return map:getTileWidth(), map:getTileHeight()
    end

    return 32, 32
end

local function rect_overlaps_solid(map, layer, x, y, w, h)
    if map and map.rectOverlapsSolid then
        return map:rectOverlapsSolid(layer, x, y, w, h)
    end
    return false
end

--- Create a walker+camera helper.
--- @param opts table
--- @return table
function camera_follow_walker.new(opts)
    opts = opts or {}

    local map = opts.map
    if not map then
        error("camera_follow_walker.new requires opts.map")
    end

    local tw, th = resolve_tile_size(map)

    local self = setmetatable({}, WalkerCamera)
    self.map = map
    self.layer = opts.layer or 1
    self.tile_w = tw
    self.tile_h = th
    self.body_w = opts.body_w or (tw * 0.8)
    self.body_h = opts.body_h or (th * 0.8)
    self.speed = opts.speed or tw
    self.x = opts.x or (tw * 0.5)
    self.y = opts.y or (th * 0.5)
    self.camera = CameraFollow.new(opts.camera or {})

    self.camera:setTarget(self.x, self.y)
    self.camera:update(1 / 60)

    return self
end

--- Set walker world-space center position.
--- @param x number
--- @param y number
function WalkerCamera:setPosition(x, y)
    self.x = x
    self.y = y
    self.camera:setTarget(self.x, self.y)
end

--- Get walker world-space center position.
--- @return number, number
function WalkerCamera:getPosition()
    return self.x, self.y
end

--- Place walker using 1-based tile coordinates.
--- @param tx integer
--- @param ty integer
function WalkerCamera:setTilePosition(tx, ty)
    local wx, wy = self.map:tileToWorld(tx, ty)
    self:setPosition(wx + self.tile_w * 0.5, wy + self.tile_h * 0.5)
end

--- Get current walker tile coordinates (1-based).
--- @return integer, integer
function WalkerCamera:getTilePosition()
    return self.map:worldToTile(self.x, self.y)
end

function WalkerCamera:_would_overlap(next_x, next_y)
    local left = next_x - self.body_w * 0.5
    local top = next_y - self.body_h * 0.5
    return rect_overlaps_solid(self.map, self.layer, left, top, self.body_w, self.body_h)
end

--- Attempt movement in world space.
--- Returns true if any axis moved.
--- @param dx number
--- @param dy number
--- @param dt number?
--- @return boolean
function WalkerCamera:move(dx, dy, dt)
    dt = dt or (1 / 60)

    local moved = false
    local step_x = (dx or 0) * self.speed * dt
    local step_y = (dy or 0) * self.speed * dt

    if step_x ~= 0 then
        local nx = self.x + step_x
        if not self:_would_overlap(nx, self.y) then
            self.x = nx
            moved = true
        end
    end

    if step_y ~= 0 then
        local ny = self.y + step_y
        if not self:_would_overlap(self.x, ny) then
            self.y = ny
            moved = true
        end
    end

    self.camera:setTarget(self.x, self.y)
    return moved
end

--- Update internal camera controller and optionally apply to lurek.camera.
--- @param dt number?
--- @param apply_camera boolean?
function WalkerCamera:update(dt, apply_camera)
    self.camera:setTarget(self.x, self.y)
    self.camera:update(dt or (1 / 60))
    if apply_camera then
        self.camera:apply()
    end
end

--- Return current camera position from camera_follow.
--- @return number, number
function WalkerCamera:getCameraPosition()
    return self.camera:getPosition()
end

--- Expose underlying camera_follow controller.
--- @return table
function WalkerCamera:getCameraController()
    return self.camera
end

return camera_follow_walker
