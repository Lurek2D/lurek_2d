-- @module library.tilemap_minimap
--- @status full
--- Helper for syncing tilemap solidity into a minimap terrain grid.

local tilemap_minimap = {}

local TilemapMinimap = {}
TilemapMinimap.__index = TilemapMinimap

local function new_fallback_minimap(grid_w, grid_h, display_w, display_h)
    local mm = {
        _grid_w = grid_w,
        _grid_h = grid_h,
        _display_w = display_w or grid_w,
        _display_h = display_h or grid_h,
        _terrain = {},
        _center_x = 1,
        _center_y = 1,
        _viewport = nil,
    }

    function mm:setTerrain(x, y, value)
        local idx = (y - 1) * self._grid_w + x
        self._terrain[idx] = value
    end

    function mm:getTerrain(x, y)
        local idx = (y - 1) * self._grid_w + x
        return self._terrain[idx] or 0
    end

    function mm:setCenter(x, y)
        self._center_x = x
        self._center_y = y
    end

    function mm:getCenter()
        return self._center_x, self._center_y
    end

    function mm:setViewport(x, y, w, h)
        self._viewport = { x = x, y = y, w = w, h = h }
    end

    function mm:clearViewport()
        self._viewport = nil
    end

    return mm
end

local function create_minimap(grid_w, grid_h, display_w, display_h)
    if lurek and lurek.minimap and lurek.minimap.newMinimap then
        return lurek.minimap.newMinimap(grid_w, grid_h, display_w, display_h)
    end

    return new_fallback_minimap(grid_w, grid_h, display_w, display_h)
end

--- Create a tilemap->minimap sync helper.
--- @param opts table
--- @return table
function tilemap_minimap.new(opts)
    opts = opts or {}

    local map = opts.map
    if not map then
        error("tilemap_minimap.new requires opts.map")
    end

    local width = opts.width
    local height = opts.height
    if not width or not height then
        error("tilemap_minimap.new requires opts.width and opts.height")
    end

    local self = setmetatable({}, TilemapMinimap)
    self.map = map
    self.layer = opts.layer or 1
    self.width = width
    self.height = height
    self.solid_terrain = opts.solid_terrain or 2
    self.empty_terrain = opts.empty_terrain or 1
    self.minimap = opts.minimap or create_minimap(width, height, opts.display_w, opts.display_h)

    if opts.auto_sync ~= false then
        self:syncTerrain()
    end

    return self
end

--- Sync tile solidity from tilemap layer into minimap terrain.
function TilemapMinimap:syncTerrain()
    for y = 1, self.height do
        for x = 1, self.width do
            local value = self.empty_terrain
            if self.map:isSolid(self.layer, x, y) then
                value = self.solid_terrain
            end
            self.minimap:setTerrain(x, y, value)
        end
    end
end

--- Center minimap from world-space coordinates.
--- @param wx number
--- @param wy number
--- @return integer, integer
function TilemapMinimap:setCenterFromWorld(wx, wy)
    local tx, ty = self.map:worldToTile(wx, wy)
    self.minimap:setCenter(tx, ty)
    return tx, ty
end

--- Set minimap viewport from a world-space rectangle.
--- @param vx number
--- @param vy number
--- @param vw number
--- @param vh number
function TilemapMinimap:setViewportFromWorld(vx, vy, vw, vh)
    if not self.minimap.setViewport then
        return
    end

    local tx1, ty1 = self.map:worldToTile(vx, vy)
    local tx2, ty2 = self.map:worldToTile(vx + vw, vy + vh)

    local tw = math.max(1, (tx2 - tx1) + 1)
    local th = math.max(1, (ty2 - ty1) + 1)

    self.minimap:setViewport(tx1, ty1, tw, th)
end

--- Clear minimap viewport overlay if supported.
function TilemapMinimap:clearViewport()
    if self.minimap.clearViewport then
        self.minimap:clearViewport()
    end
end

--- Expose underlying minimap handle.
--- @return table
function TilemapMinimap:getMinimap()
    return self.minimap
end

return tilemap_minimap
