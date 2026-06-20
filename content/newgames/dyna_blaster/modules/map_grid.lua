local M = {}
M.__index = M

local function first_step_from_path(path, sx, sy)
    if not path then
        return nil
    end
    for i = 1, #path do
        local p = path[i]
        if p and not (p.x == sx and p.y == sy) then
            return p
        end
    end
    return nil
end

function M.new(cfg)
    return setmetatable({
        cfg = cfg,
        tilemap = nil,
        layer = 0,
        navgrid = nil,
        pathfinder = nil,
    }, M)
end

function M:gid_at(gx, gy)
    if (not self.tilemap) or (not self.cfg.in_bounds(gx, gy)) then
        return self.cfg.GID_WALL
    end
    return self.tilemap:getTile(self.layer, gx, gy)
end

function M:set_gid(gx, gy, gid)
    if self.tilemap and self.cfg.in_bounds(gx, gy) then
        self.tilemap:setTile(self.layer, gx, gy, gid)
    end
end

function M:clear_gid(gx, gy)
    if self.tilemap and self.cfg.in_bounds(gx, gy) then
        self.tilemap:clearTile(self.layer, gx, gy)
    end
end

function M:is_solid(gx, gy)
    return self:gid_at(gx, gy) ~= self.cfg.GID_EMPTY
end

function M:reset()
    local cfg = self.cfg
    self.tilemap = lurek.tilemap.newTileMap(cfg.TILE, cfg.TILE)
    self.layer = self.tilemap:addLayer("collision", cfg.GRID_W, cfg.GRID_H)
    -- Keep tilemap as data/collision source only; world tiles are drawn manually.
    self.tilemap:setLayerVisible(self.layer, false)

    local tileset = lurek.tilemap.newTileSet(1, 4, 2, cfg.TILE, cfg.TILE)
    tileset:setSolid(cfg.GID_WALL, true)
    tileset:setSolid(cfg.GID_CRATE, true)
    self.tilemap:addTileSet(tileset)
    self.tilemap:fill(self.layer, cfg.GID_EMPTY)

    for y = 1, cfg.GRID_H do
        for x = 1, cfg.GRID_W do
            local border = (x == 1 or y == 1 or x == cfg.GRID_W or y == cfg.GRID_H)
            local pillar = (x % 2 == 0 and y % 2 == 0)
            if border or pillar then
                self:set_gid(x, y, cfg.GID_WALL)
            end
        end
    end

    for y = 2, cfg.GRID_H - 1 do
        for x = 2, cfg.GRID_W - 1 do
            local spawn_safe = (x <= 3 and y <= 3) or (x >= cfg.GRID_W - 2 and y >= cfg.GRID_H - 2)
            if self:gid_at(x, y) == cfg.GID_EMPTY and (not spawn_safe) and math.random() < 0.42 then
                self:set_gid(x, y, cfg.GID_CRATE)
            end
        end
    end

    self:rebuild_navigation()
end

function M:rebuild_navigation()
    if not self.tilemap then
        self.navgrid = nil
        self.pathfinder = nil
        return
    end
    self.navgrid = lurek.pathfind.newNavGridFromTileMap(self.tilemap, self.layer, {
        self.cfg.GID_WALL,
        self.cfg.GID_CRATE,
    })
    self.pathfinder = lurek.pathfind.newPathfinder(self.navgrid)
end

function M:first_path_step(sx, sy, gx, gy)
    if not self.pathfinder then
        return nil
    end
    local path = self.pathfinder:findPath(sx, sy, gx, gy, 1)
    return first_step_from_path(path, sx, sy)
end

function M:draw_world_tiles()
    local cfg = self.cfg
    for y = 1, cfg.GRID_H do
        for x = 1, cfg.GRID_W do
            local sx, sy = cfg.grid_to_screen(x, y)
            local gid = self:gid_at(x, y)
            if gid == cfg.GID_WALL then
                lurek.render.setColor(0.25, 0.27, 0.34, 1)
            elseif gid == cfg.GID_CRATE then
                lurek.render.setColor(0.62, 0.44, 0.20, 1)
            else
                lurek.render.setColor(0.14, 0.15, 0.19, 1)
            end
            lurek.render.rectangle("fill", sx, sy, cfg.TILE - 2, cfg.TILE - 2)
        end
    end
end

return M
