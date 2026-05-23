-- Dyna Blaster — arcade bomber demo built with Lurek API first.

local SCREEN_W, SCREEN_H = 960, 640
local TILE = 40
local GRID_W, GRID_H = 15, 13
local ORIGIN_X, ORIGIN_Y = 180, 60

---@type any
local universe = nil
local walls = {}
local crates = {}

local app = {
    player_id = nil,
    lives = 3,
    score = 0,
    respawn_timer = 0,
    game_over_reason = "",
}

local ui = {}

---@type any
local menu_scene = nil
---@type any
local game_scene = nil
---@type any
local game_over_scene = nil

local function cell_key(gx, gy)
    return gx .. ":" .. gy
end

local function grid_to_screen(gx, gy)
    return ORIGIN_X + (gx - 1) * TILE, ORIGIN_Y + (gy - 1) * TILE
end

local function in_bounds(gx, gy)
    return gx >= 1 and gx <= GRID_W and gy >= 1 and gy <= GRID_H
end

local function reset_map()
    walls = {}
    crates = {}

    for y = 1, GRID_H do
        for x = 1, GRID_W do
            local border = (x == 1 or y == 1 or x == GRID_W or y == GRID_H)
            local pillar = (x % 2 == 0 and y % 2 == 0)
            if border or pillar then
                walls[cell_key(x, y)] = true
            end
        end
    end

    for y = 2, GRID_H - 1 do
        for x = 2, GRID_W - 1 do
            local k = cell_key(x, y)
            local spawn_safe = (x <= 3 and y <= 3) or (x >= GRID_W - 2 and y >= GRID_H - 2)
            if (not walls[k]) and (not spawn_safe) and math.random() < 0.42 then
                crates[k] = true
            end
        end
    end
end

local function find_entity_at(component_name, gx, gy)
    if not universe then return nil end
    for _, id in ipairs(universe:query(component_name, "transform")) do
        local tr = universe:get(id, "transform")
        if tr and tr.gx == gx and tr.gy == gy then
            return id
        end
    end
    return nil
end

local function is_blocked(gx, gy)
    if not in_bounds(gx, gy) then
        return true
    end

    local k = cell_key(gx, gy)
    if walls[k] or crates[k] then
        return true
    end

    if find_entity_at("bomb", gx, gy) then
        return true
    end

    return false
end

local function spawn_player(gx, gy)
    local id = universe:spawn()
    universe:set(id, "transform", { gx = gx, gy = gy })
    universe:set(id, "player", { bomb_cooldown = 0, range = 2 })
    app.player_id = id
end

local function spawn_enemy(gx, gy)
    local id = universe:spawn()
    universe:set(id, "transform", { gx = gx, gy = gy })
    universe:set(id, "enemy", { step_timer = 0.25 })
end

local function spawn_flame(gx, gy)
    local id = universe:spawn()
    universe:set(id, "transform", { gx = gx, gy = gy })
    universe:set(id, "flame", { ttl = 0.45 })
end

local function spawn_bomb(gx, gy, range)
    local id = universe:spawn()
    universe:set(id, "transform", { gx = gx, gy = gy })
    universe:set(id, "bomb", { timer = 1.5, range = range })
end

local function respawn_player()
    local tr = universe:get(app.player_id, "transform")
    if tr then
        tr.gx = 2
        tr.gy = 2
        universe:set(app.player_id, "transform", tr)
    end
    app.respawn_timer = 1.0
end

local function lose_life(reason)
    app.lives = app.lives - 1
    app.game_over_reason = reason or "Out of lives"
    if app.lives <= 0 then
        lurek.scene.setData("final_score", app.score)
        lurek.scene.switchTo(game_over_scene, "fade", 0.2, "linear")
        return
    end
    respawn_player()
end

local function explode_bomb(id)
    local bomb = universe:get(id, "bomb")
    local tr = universe:get(id, "transform")
    if not bomb or not tr then
        universe:kill(id)
        return
    end

    spawn_flame(tr.gx, tr.gy)

    local dirs = {
        { 1, 0 },
        { -1, 0 },
        { 0, 1 },
        { 0, -1 },
    }

    for _, d in ipairs(dirs) do
        for step = 1, bomb.range do
            local nx = tr.gx + d[1] * step
            local ny = tr.gy + d[2] * step
            local k = cell_key(nx, ny)
            if walls[k] then
                break
            end
            spawn_flame(nx, ny)
            if crates[k] then
                crates[k] = nil
                app.score = app.score + 10
                break
            end
        end
    end

    universe:kill(id)
end

local function reset_run()
    universe = lurek.ecs.newUniverse()
    app.score = 0
    app.lives = 3
    app.respawn_timer = 0
    app.game_over_reason = ""

    reset_map()
    spawn_player(2, 2)
    spawn_enemy(GRID_W - 2, 2)
    spawn_enemy(GRID_W - 2, GRID_H - 2)
    spawn_enemy(2, GRID_H - 2)

    lurek.scene.setData("score", app.score)
end

local function update_player(dt)
    local player = universe:get(app.player_id, "player")
    local tr = universe:get(app.player_id, "transform")
    if not player or not tr then
        return
    end

    player.bomb_cooldown = math.max(0, player.bomb_cooldown - dt)

    local move_dx, move_dy = 0, 0
    if lurek.input.wasActionPressed("move_left") then move_dx = -1 end
    if lurek.input.wasActionPressed("move_right") then move_dx = 1 end
    if lurek.input.wasActionPressed("move_up") then move_dy = -1 end
    if lurek.input.wasActionPressed("move_down") then move_dy = 1 end

    if move_dx ~= 0 or move_dy ~= 0 then
        local nx = tr.gx + move_dx
        local ny = tr.gy + move_dy
        if not is_blocked(nx, ny) then
            tr.gx = nx
            tr.gy = ny
            universe:set(app.player_id, "transform", tr)
        end
    end

    if lurek.input.wasActionPressed("place_bomb") and player.bomb_cooldown <= 0 then
        if not find_entity_at("bomb", tr.gx, tr.gy) then
            spawn_bomb(tr.gx, tr.gy, player.range)
            player.bomb_cooldown = 0.35
        end
    end

    universe:set(app.player_id, "player", player)
end

local function update_enemies(dt)
    for _, id in ipairs(universe:query("enemy", "transform")) do
        local enemy = universe:get(id, "enemy")
        local tr = universe:get(id, "transform")
        if enemy and tr then
            enemy.step_timer = enemy.step_timer - dt
            if enemy.step_timer <= 0 then
                local dirs = {
                    { 1, 0 },
                    { -1, 0 },
                    { 0, 1 },
                    { 0, -1 },
                }
                local tries = 0
                while tries < #dirs do
                    local pick = dirs[math.random(1, #dirs)]
                    local nx = tr.gx + pick[1]
                    local ny = tr.gy + pick[2]
                    if not is_blocked(nx, ny) and not find_entity_at("enemy", nx, ny) then
                        tr.gx = nx
                        tr.gy = ny
                        break
                    end
                    tries = tries + 1
                end
                enemy.step_timer = 0.25 + math.random() * 0.25
                universe:set(id, "enemy", enemy)
                universe:set(id, "transform", tr)
            end
        end
    end
end

local function update_bombs_and_flames(dt)
    for _, id in ipairs(universe:query("bomb", "transform")) do
        local bomb = universe:get(id, "bomb")
        if bomb then
            bomb.timer = bomb.timer - dt
            if bomb.timer <= 0 then
                explode_bomb(id)
            else
                universe:set(id, "bomb", bomb)
            end
        end
    end

    for _, id in ipairs(universe:query("flame", "transform")) do
        local flame = universe:get(id, "flame")
        if flame then
            flame.ttl = flame.ttl - dt
            if flame.ttl <= 0 then
                universe:kill(id)
            else
                universe:set(id, "flame", flame)
            end
        end
    end
end

local function apply_hits()
    local p_tr = universe:get(app.player_id, "transform")
    if not p_tr then return end

    local player_hit = false
    for _, fid in ipairs(universe:query("flame", "transform")) do
        local f_tr = universe:get(fid, "transform")
        if f_tr and p_tr.gx == f_tr.gx and p_tr.gy == f_tr.gy then
            player_hit = true
            break
        end
    end

    if player_hit and app.respawn_timer <= 0 then
        lose_life("Burned by explosion")
    end

    local kills = {}
    for _, eid in ipairs(universe:query("enemy", "transform")) do
        local e_tr = universe:get(eid, "transform")
        if e_tr then
            local hit = false
            for _, fid in ipairs(universe:query("flame", "transform")) do
                local f_tr = universe:get(fid, "transform")
                if f_tr and e_tr.gx == f_tr.gx and e_tr.gy == f_tr.gy then
                    hit = true
                    break
                end
            end
            if hit then
                kills[#kills + 1] = eid
            end

            if app.respawn_timer <= 0 and p_tr.gx == e_tr.gx and p_tr.gy == e_tr.gy then
                lose_life("Caught by enemy")
            end
        end
    end

    for _, eid in ipairs(kills) do
        universe:kill(eid)
        app.score = app.score + 25
    end

    if #universe:query("enemy", "transform") == 0 then
        lurek.scene.setData("final_score", app.score)
        app.game_over_reason = "Stage cleared"
        lurek.scene.switchTo(game_over_scene, "fade", 0.2, "linear")
    end
end

local function draw_world()
    lurek.render.setColor(0.08, 0.08, 0.1, 1)
    lurek.render.rectangle("fill", ORIGIN_X - 6, ORIGIN_Y - 6, GRID_W * TILE + 12, GRID_H * TILE + 12)

    for y = 1, GRID_H do
        for x = 1, GRID_W do
            local sx, sy = grid_to_screen(x, y)
            local k = cell_key(x, y)
            if walls[k] then
                lurek.render.setColor(0.25, 0.27, 0.34, 1)
            elseif crates[k] then
                lurek.render.setColor(0.62, 0.44, 0.20, 1)
            else
                lurek.render.setColor(0.14, 0.15, 0.19, 1)
            end
            lurek.render.rectangle("fill", sx, sy, TILE - 2, TILE - 2)
        end
    end

    for _, id in ipairs(universe:query("bomb", "transform")) do
        local tr = universe:get(id, "transform")
        if tr then
            local sx, sy = grid_to_screen(tr.gx, tr.gy)
            lurek.render.setColor(0.08, 0.08, 0.08, 1)
            lurek.render.circle("fill", sx + TILE * 0.5, sy + TILE * 0.5, TILE * 0.28)
        end
    end

    for _, id in ipairs(universe:query("flame", "transform")) do
        local tr = universe:get(id, "transform")
        if tr then
            local sx, sy = grid_to_screen(tr.gx, tr.gy)
            lurek.render.setColor(1.0, 0.72, 0.22, 0.95)
            lurek.render.rectangle("fill", sx + 4, sy + 4, TILE - 10, TILE - 10)
        end
    end

    for _, id in ipairs(universe:query("enemy", "transform")) do
        local tr = universe:get(id, "transform")
        if tr then
            local sx, sy = grid_to_screen(tr.gx, tr.gy)
            lurek.render.setColor(0.9, 0.2, 0.2, 1)
            lurek.render.rectangle("fill", sx + 8, sy + 8, TILE - 18, TILE - 18)
        end
    end

    local tr = universe:get(app.player_id, "transform")
    if tr then
        local sx, sy = grid_to_screen(tr.gx, tr.gy)
        local a = 1
        if app.respawn_timer > 0 then
            a = (math.floor(app.respawn_timer * 12) % 2 == 0) and 0.4 or 1
        end
        lurek.render.setColor(0.2, 0.72, 1.0, a)
        lurek.render.rectangle("fill", sx + 6, sy + 6, TILE - 14, TILE - 14)
    end
end

local function sync_ui(scene_name)
    if not ui.menu_panel then return end

    ui.menu_panel:setVisible(scene_name == "menu")
    ui.hud_panel:setVisible(scene_name == "game")
    ui.game_over_panel:setVisible(scene_name == "game_over")

    if ui.score_label then ui.score_label:setText("Score: " .. app.score) end
    if ui.lives_label then ui.lives_label:setText("Lives: " .. app.lives) end
    if ui.status_label then
        ui.status_label:setText("Arrows/WASD move, Space bombs, Esc quit")
    end

    if ui.game_over_title then ui.game_over_title:setText(app.game_over_reason ~= "" and app.game_over_reason or "GAME OVER") end
    if ui.game_over_score then
        local final_score = lurek.scene.getData("final_score") or app.score
        ui.game_over_score:setText("Final score: " .. tostring(final_score))
    end
end

function lurek.init()
    math.randomseed(1337)

    lurek.window.setTitle("Dyna Blaster — Lurek2D")
    lurek.render.setBackgroundColor(0.06, 0.06, 0.08)

    lurek.input.bind("move_up", { "w", "up" })
    lurek.input.bind("move_down", { "s", "down" })
    lurek.input.bind("move_left", { "a", "left" })
    lurek.input.bind("move_right", { "d", "right" })
    lurek.input.bind("place_bomb", { "space" })
    lurek.input.bind("confirm", { "return", "kp_enter" })
    lurek.input.bind("quit", { "escape" })

    lurek.ui.loadLayoutFile("content/games/arcade/dyna_blaster/ui.toml")
    local root = lurek.ui.getRoot()
    ui.menu_panel = root:findById("menu_panel")
    ui.hud_panel = root:findById("hud_panel")
    ui.game_over_panel = root:findById("game_over_panel")
    ui.score_label = root:findById("score_label")
    ui.lives_label = root:findById("lives_label")
    ui.status_label = root:findById("status_label")
    ui.game_over_title = root:findById("game_over_title")
    ui.game_over_score = root:findById("game_over_score")

    menu_scene = lurek.scene.new({
        name = "menu",
        process = function()
            if lurek.input.wasActionPressed("confirm") then
                reset_run()
                lurek.scene.switchTo(game_scene, "fade", 0.2, "linear")
            end
        end,
        draw = function()
            lurek.render.setColor(0.16, 0.18, 0.24, 1)
            lurek.render.rectangle("line", ORIGIN_X - 20, ORIGIN_Y - 20, GRID_W * TILE + 40, GRID_H * TILE + 40)
        end,
    })

    game_scene = lurek.scene.new({
        name = "game",
        process = function(dt)
            if app.respawn_timer > 0 then
                app.respawn_timer = math.max(0, app.respawn_timer - dt)
            end

            update_player(dt)
            update_enemies(dt)
            update_bombs_and_flames(dt)
            apply_hits()
            lurek.scene.setData("score", app.score)
        end,
        draw = function()
            draw_world()
        end,
    })

    game_over_scene = lurek.scene.new({
        name = "game_over",
        process = function()
            if lurek.input.wasActionPressed("confirm") then
                reset_run()
                lurek.scene.switchTo(game_scene, "fade", 0.2, "linear")
            end
        end,
        draw = function()
            draw_world()
        end,
    })

    lurek.scene.clear()
    lurek.scene.push(menu_scene)
    sync_ui("menu")
end

function lurek.process(dt)
    if lurek.automation then
        lurek.automation.update(dt)
    end

    if lurek.input.wasActionPressed("quit") then
        lurek.event.quit()
        return
    end

    lurek.scene.process(dt)

    local current = lurek.scene.getCurrent()
    local scene_name = (current and current.name) or "menu"
    sync_ui(scene_name)
end

function lurek.draw()
    lurek.scene.draw()
end
