local UI = require("content.games.arcade.dyna_blaster.modules.ui_overlay")
local MapGrid = require("content.games.arcade.dyna_blaster.modules.map_grid")
local EnemyBrain = require("content.games.arcade.dyna_blaster.modules.enemy_brain")

local M = {}
M.__index = M

function M.new(cfg)
    return setmetatable({
        cfg = cfg,
        universe = nil,
        grid = MapGrid.new(cfg),
        brain = EnemyBrain.new(cfg),
        app = {
            player_id = nil,
            lives = 3,
            score = 0,
            respawn_timer = 0,
            move_repeat_timer = 0,
            game_over_reason = "",
        },
    }, M)
end

function M:get_app()
    return self.app
end

function M:key_down(...)
    local keys = { ... }
    for i = 1, #keys do
        if lurek.input.keyboard.isDown(keys[i]) then
            return true
        end
    end
    return false
end

function M:find_entity_at(component_name, gx, gy)
    if not self.universe then return nil end
    for _, id in ipairs(self.universe:query(component_name, "transform")) do
        local tr = self.universe:get(id, "transform")
        if tr and tr.gx == gx and tr.gy == gy then
            return id
        end
    end
    return nil
end

function M:is_blocked(gx, gy)
    if not self.cfg.in_bounds(gx, gy) then
        return true
    end
    if self.grid:is_solid(gx, gy) then
        return true
    end
    if self:find_entity_at("bomb", gx, gy) then
        return true
    end
    return false
end

function M:is_player_spawn_allowed(gx, gy)
    if not self.cfg.in_bounds(gx, gy) then
        return false
    end
    if self.grid:is_solid(gx, gy) then
        return false
    end
    if self:find_entity_at("enemy", gx, gy) then
        return false
    end
    if self:find_entity_at("bomb", gx, gy) then
        return false
    end
    if self:find_entity_at("flame", gx, gy) then
        return false
    end
    return true
end

function M:pick_spawn_cell(prefer_x, prefer_y)
    if self:is_player_spawn_allowed(prefer_x, prefer_y) then
        return prefer_x, prefer_y
    end

    local best_x, best_y = nil, nil
    local best_dist = 99999
    for y = 1, self.cfg.GRID_H do
        for x = 1, self.cfg.GRID_W do
            if self:is_player_spawn_allowed(x, y) then
                local d = math.abs(x - prefer_x) + math.abs(y - prefer_y)
                if d < best_dist then
                    best_dist = d
                    best_x, best_y = x, y
                end
            end
        end
    end

    if best_x then
        return best_x, best_y
    end

    return 2, 2
end

function M:spawn_player(gx, gy)
    gx, gy = self:pick_spawn_cell(gx, gy)
    local id = self.universe:spawn()
    self.universe:set(id, "transform", { gx = gx, gy = gy })
    self.universe:set(id, "player", { bomb_cooldown = 0, range = 2 })
    self.app.player_id = id
end

function M:spawn_enemy(gx, gy)
    local id = self.universe:spawn()
    self.universe:set(id, "transform", { gx = gx, gy = gy })
    self.universe:set(id, "enemy", { step_timer = 0.25 })
    self.brain:add_enemy(id, gx, gy)
end

function M:spawn_flame(gx, gy)
    local id = self.universe:spawn()
    self.universe:set(id, "transform", { gx = gx, gy = gy })
    self.universe:set(id, "flame", { ttl = 0.45 })
end

function M:spawn_bomb(gx, gy, range)
    local id = self.universe:spawn()
    self.universe:set(id, "transform", { gx = gx, gy = gy })
    self.universe:set(id, "bomb", { timer = 1.5, range = range })
end

function M:respawn_player()
    local tr = self.universe:get(self.app.player_id, "transform")
    if tr then
        local gx, gy = self:pick_spawn_cell(2, 2)
        tr.gx = gx
        tr.gy = gy
        self.universe:set(self.app.player_id, "transform", tr)
    end
    self.app.respawn_timer = 1.0
end

function M:mark_game_over(reason)
    self.app.game_over_reason = reason or "Game Over"
    lurek.scene.setData("final_score", self.app.score)
end

function M:lose_life(reason)
    self.app.lives = self.app.lives - 1
    if self.app.lives <= 0 then
        self:mark_game_over(reason or "Out of lives")
        return true
    end
    self.app.game_over_reason = reason or "Hit"
    self:respawn_player()
    return false
end

function M:list_bombs()
    local out = {}
    if not self.universe then return out end
    for _, id in ipairs(self.universe:query("bomb", "transform")) do
        local tr = self.universe:get(id, "transform")
        if tr then
            out[#out + 1] = { gx = tr.gx, gy = tr.gy }
        end
    end
    return out
end

function M:explode_bomb(id)
    local bomb = self.universe:get(id, "bomb")
    local tr = self.universe:get(id, "transform")
    if not bomb or not tr then
        self.universe:kill(id)
        return
    end

    self:spawn_flame(tr.gx, tr.gy)

    local dirs = {
        { 1, 0 },
        { -1, 0 },
        { 0, 1 },
        { 0, -1 },
    }

    local nav_dirty = false
    for _, d in ipairs(dirs) do
        for step = 1, bomb.range do
            local nx = tr.gx + d[1] * step
            local ny = tr.gy + d[2] * step
            local gid = self.grid:gid_at(nx, ny)
            if gid == self.cfg.GID_WALL then
                break
            end
            self:spawn_flame(nx, ny)
            if gid == self.cfg.GID_CRATE then
                self.grid:clear_gid(nx, ny)
                self.app.score = self.app.score + 10
                nav_dirty = true
                break
            end
        end
    end

    if nav_dirty then
        self.grid:rebuild_navigation()
    end

    self.universe:kill(id)
end

function M:reset_run()
    self.universe = lurek.ecs.newUniverse()
    self.app.score = 0
    self.app.lives = 3
    self.app.respawn_timer = 0
    self.app.move_repeat_timer = 0
    self.app.game_over_reason = ""

    self.grid:reset()
    self.brain:reset(self.grid)

    self:spawn_player(2, 2)
    self:spawn_enemy(self.cfg.GRID_W - 2, 2)
    self:spawn_enemy(self.cfg.GRID_W - 2, self.cfg.GRID_H - 2)
    self:spawn_enemy(2, self.cfg.GRID_H - 2)

    lurek.scene.setData("score", self.app.score)
end

function M:update_player(dt)
    local player = self.universe:get(self.app.player_id, "player")
    local tr = self.universe:get(self.app.player_id, "transform")
    if not player or not tr then
        return
    end

    player.bomb_cooldown = math.max(0, player.bomb_cooldown - dt)

    self.app.move_repeat_timer = math.max(0, self.app.move_repeat_timer - dt)
    local move_dx, move_dy = 0, 0
    local left = lurek.input.isActionDown("move_left") or self:key_down("a", "left")
    local right = lurek.input.isActionDown("move_right") or self:key_down("d", "right")
    local up = lurek.input.isActionDown("move_up") or self:key_down("w", "up")
    local down = lurek.input.isActionDown("move_down") or self:key_down("s", "down")

    if self.app.move_repeat_timer <= 0 then
        if left and not right then move_dx = -1 end
        if right and not left then move_dx = 1 end
        if up and not down then move_dy = -1 end
        if down and not up then move_dy = 1 end
    end

    if move_dx ~= 0 or move_dy ~= 0 then
        local nx = tr.gx + move_dx
        local ny = tr.gy + move_dy
        if not self:is_blocked(nx, ny) then
            tr.gx = nx
            tr.gy = ny
            self.universe:set(self.app.player_id, "transform", tr)
        end
        self.app.move_repeat_timer = 0.12
    end

    if (lurek.input.wasActionPressed("place_bomb") or self:key_down("space")) and player.bomb_cooldown <= 0 then
        if not self:find_entity_at("bomb", tr.gx, tr.gy) then
            self:spawn_bomb(tr.gx, tr.gy, player.range)
            player.bomb_cooldown = 0.35
        end
    end

    self.universe:set(self.app.player_id, "player", player)
end

function M:update_enemies(dt)
    local p_tr = self.universe:get(self.app.player_id, "transform")
    if not p_tr then
        return
    end

    for _, id in ipairs(self.universe:query("enemy", "transform")) do
        local tr = self.universe:get(id, "transform")
        if tr then
            self.brain:sync_enemy_position(id, tr.gx, tr.gy)
        end
    end

    self.brain:update(dt, { gx = p_tr.gx, gy = p_tr.gy }, self:list_bombs())

    local fallback_dirs = {
        { 1, 0 },
        { -1, 0 },
        { 0, 1 },
        { 0, -1 },
    }

    for _, id in ipairs(self.universe:query("enemy", "transform")) do
        local enemy = self.universe:get(id, "enemy")
        local tr = self.universe:get(id, "transform")
        if enemy and tr then
            enemy.step_timer = enemy.step_timer - dt
            if enemy.step_timer <= 0 then
                local dx, dy = self.brain:get_desired_step(id)
                local nx = tr.gx + dx
                local ny = tr.gy + dy

                local moved = false
                if (dx ~= 0 or dy ~= 0) and (not self:is_blocked(nx, ny)) and (not self:find_entity_at("enemy", nx, ny)) then
                    tr.gx = nx
                    tr.gy = ny
                    moved = true
                end

                if not moved then
                    for _ = 1, #fallback_dirs do
                        local pick = fallback_dirs[math.random(1, #fallback_dirs)]
                        nx = tr.gx + pick[1]
                        ny = tr.gy + pick[2]
                        if not self:is_blocked(nx, ny) and not self:find_entity_at("enemy", nx, ny) then
                            tr.gx = nx
                            tr.gy = ny
                            moved = true
                            break
                        end
                    end
                end

                enemy.step_timer = 0.22 + math.random() * 0.20
                self.universe:set(id, "enemy", enemy)
                self.universe:set(id, "transform", tr)
                self.brain:sync_enemy_position(id, tr.gx, tr.gy)
            end
        end
    end
end

function M:update_bombs_and_flames(dt)
    for _, id in ipairs(self.universe:query("bomb", "transform")) do
        local bomb = self.universe:get(id, "bomb")
        if bomb then
            bomb.timer = bomb.timer - dt
            if bomb.timer <= 0 then
                self:explode_bomb(id)
            else
                self.universe:set(id, "bomb", bomb)
            end
        end
    end

    for _, id in ipairs(self.universe:query("flame", "transform")) do
        local flame = self.universe:get(id, "flame")
        if flame then
            flame.ttl = flame.ttl - dt
            if flame.ttl <= 0 then
                self.universe:kill(id)
            else
                self.universe:set(id, "flame", flame)
            end
        end
    end
end

function M:apply_hits()
    local p_tr = self.universe:get(self.app.player_id, "transform")
    if not p_tr then return false end

    local player_hit = false
    for _, fid in ipairs(self.universe:query("flame", "transform")) do
        local f_tr = self.universe:get(fid, "transform")
        if f_tr and p_tr.gx == f_tr.gx and p_tr.gy == f_tr.gy then
            player_hit = true
            break
        end
    end

    if player_hit and self.app.respawn_timer <= 0 then
        local ended = self:lose_life("Burned by explosion")
        if ended then return true end
    end

    local kills = {}
    for _, eid in ipairs(self.universe:query("enemy", "transform")) do
        local e_tr = self.universe:get(eid, "transform")
        if e_tr then
            local hit = false
            for _, fid in ipairs(self.universe:query("flame", "transform")) do
                local f_tr = self.universe:get(fid, "transform")
                if f_tr and e_tr.gx == f_tr.gx and e_tr.gy == f_tr.gy then
                    hit = true
                    break
                end
            end
            if hit then
                kills[#kills + 1] = eid
            end

            if self.app.respawn_timer <= 0 and p_tr.gx == e_tr.gx and p_tr.gy == e_tr.gy then
                local ended = self:lose_life("Caught by enemy")
                if ended then return true end
            end
        end
    end

    for _, eid in ipairs(kills) do
        self.brain:remove_enemy(eid)
        self.universe:kill(eid)
        self.app.score = self.app.score + 25
    end

    if #self.universe:query("enemy", "transform") == 0 then
        self:mark_game_over("Stage cleared")
        return true
    end

    return false
end

function M:update(dt)
    if self.app.respawn_timer > 0 then
        self.app.respawn_timer = math.max(0, self.app.respawn_timer - dt)
    end

    self:update_player(dt)
    self:update_enemies(dt)
    self:update_bombs_and_flames(dt)
    local ended = self:apply_hits()
    lurek.scene.setData("score", self.app.score)
    return ended
end

function M:draw_world()
    lurek.render.setColor(0.08, 0.08, 0.1, 1)
    lurek.render.rectangle("fill", self.cfg.ORIGIN_X - 6, self.cfg.ORIGIN_Y - 6, self.cfg.GRID_W * self.cfg.TILE + 12, self.cfg.GRID_H * self.cfg.TILE + 12)
    self.grid:draw_world_tiles()

    if not self.universe then
        return
    end

    for _, id in ipairs(self.universe:query("bomb", "transform")) do
        local tr = self.universe:get(id, "transform")
        if tr then
            local sx, sy = self.cfg.grid_to_screen(tr.gx, tr.gy)
            lurek.render.setColor(0.08, 0.08, 0.08, 1)
            lurek.render.circle("fill", sx + self.cfg.TILE * 0.5, sy + self.cfg.TILE * 0.5, self.cfg.TILE * 0.28)
        end
    end

    for _, id in ipairs(self.universe:query("flame", "transform")) do
        local tr = self.universe:get(id, "transform")
        if tr then
            local sx, sy = self.cfg.grid_to_screen(tr.gx, tr.gy)
            lurek.render.setColor(1.0, 0.72, 0.22, 0.95)
            lurek.render.rectangle("fill", sx + 4, sy + 4, self.cfg.TILE - 10, self.cfg.TILE - 10)
        end
    end

    for _, id in ipairs(self.universe:query("enemy", "transform")) do
        local tr = self.universe:get(id, "transform")
        if tr then
            local sx, sy = self.cfg.grid_to_screen(tr.gx, tr.gy)
            lurek.render.setColor(0.9, 0.2, 0.2, 1)
            lurek.render.rectangle("fill", sx + 8, sy + 8, self.cfg.TILE - 18, self.cfg.TILE - 18)
        end
    end

    local tr = self.universe:get(self.app.player_id, "transform")
    if tr then
        local sx, sy = self.cfg.grid_to_screen(tr.gx, tr.gy)
        local a = 1
        if self.app.respawn_timer > 0 then
            a = (math.floor(self.app.respawn_timer * 12) % 2 == 0) and 0.4 or 1
        end
        lurek.render.setColor(0.2, 0.72, 1.0, a)
        lurek.render.rectangle("fill", sx + 6, sy + 6, self.cfg.TILE - 14, self.cfg.TILE - 14)
    end
end

function M:draw_game_scene()
    self:draw_world()
    UI.draw_hud(self.app, self.cfg)
end

function M:draw_game_over_scene()
    self:draw_world()
    UI.draw_hud(self.app, self.cfg)
    UI.draw_game_over_overlay(self.app, self.cfg)
end

return M
