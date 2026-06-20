local cfg = require("content.games.arcade.galaga.modules.config")

local M = {}

local STATE = cfg.STATE

local current_state = STATE.TITLE
local score = 0
local high_score = 0
local lives = 3
local wave = 1
local dual_fire = false

local is_challenge = false
local challenge_kills = 0
local challenge_total = 0
local challenge_msg_timer = 0

---@type LCamera
local cam = nil
local ui_controller = nil

---@type LUniverse
local universe = nil
---@type LAIWorld
local ai_world = nil

---@type table<number, LAgent>
local enemy_agents = {}
local player_entity = nil

local star_layers = {}
local formation_sway_timer = 0
local formation_offset_x = 0

---@type LParticleSystem|nil
local ps_enemy_hit = nil
---@type LParticleSystem|nil
local ps_player_hit = nil
---@type LParticleSystem|nil
local ps_bonus = nil

local function clamp(v, lo, hi)
    return math.max(lo, math.min(hi, v))
end

local function rects_overlap(ax, ay, aw, ah, bx, by, bw, bh)
    return ax < bx + bw and ax + aw > bx and ay < by + bh and ay + ah > by
end

local function formation_x(col)
    local grid_w = cfg.FORM_COLS * (cfg.ENEMY_W + cfg.FORM_GAP_X) - cfg.FORM_GAP_X
    local start_x = (cfg.SCREEN_W - grid_w) / 2
    return start_x + col * (cfg.ENEMY_W + cfg.FORM_GAP_X) + formation_offset_x
end

local function formation_y(row)
    return cfg.FORM_START_Y + row * (cfg.ENEMY_H + cfg.FORM_GAP_Y)
end

local function create_stars()
    star_layers = {}
    for layer = 1, cfg.STAR_LAYER_COUNT do
        local stars = {}
        for _ = 1, cfg.STARS_PER_LAYER[layer] do
            stars[#stars + 1] = {
                x = math.random() * cfg.SCREEN_W,
                y = math.random() * cfg.SCREEN_H,
            }
        end
        star_layers[layer] = stars
    end
end

local function update_stars(dt)
    for layer = 1, cfg.STAR_LAYER_COUNT do
        for _, s in ipairs(star_layers[layer]) do
            s.y = s.y + cfg.STAR_SPEEDS[layer] * dt
            if s.y > cfg.SCREEN_H then
                s.y = -2
                s.x = math.random() * cfg.SCREEN_W
            end
        end
    end
end

local function draw_stars()
    for layer = 1, cfg.STAR_LAYER_COUNT do
        lurek.render.setColor(1, 1, 1, cfg.STAR_ALPHAS[layer])
        local size = cfg.STAR_SIZES[layer]
        for _, s in ipairs(star_layers[layer]) do
            lurek.render.rectangle("fill", s.x, s.y, size, size)
        end
    end
end

local function init_particles()
    ps_enemy_hit = lurek.particle.newSystem()
    ps_enemy_hit:setBufferSize(800)
    ps_enemy_hit:setParticleLifetime(0.15, 0.35)
    ps_enemy_hit:setSpeed(60, 220)
    ps_enemy_hit:setDirection(-math.pi / 2)
    ps_enemy_hit:setSpread(math.pi * 2)
    ps_enemy_hit:setSizes(3, 2, 1)

    ps_player_hit = lurek.particle.newSystem()
    ps_player_hit:setBufferSize(800)
    ps_player_hit:setParticleLifetime(0.2, 0.55)
    ps_player_hit:setSpeed(80, 260)
    ps_player_hit:setSpread(math.pi * 2)
    ps_player_hit:setSizes(4, 2, 1)

    ps_bonus = lurek.particle.newSystem()
    ps_bonus:setBufferSize(500)
    ps_bonus:setParticleLifetime(0.25, 0.75)
    ps_bonus:setSpeed(30, 140)
    ps_bonus:setSpread(math.pi * 2)
    ps_bonus:setSizes(3, 2, 1)
end

local function emit_enemy_hit(x, y, count)
    if ps_enemy_hit then
        ps_enemy_hit:moveTo(x, y)
        ps_enemy_hit:emit(count or 10)
    end
end

local function emit_player_hit(x, y, count)
    if ps_player_hit then
        ps_player_hit:moveTo(x, y)
        ps_player_hit:emit(count or 14)
    end
end

local function emit_bonus(x, y, count)
    if ps_bonus then
        ps_bonus:moveTo(x, y)
        ps_bonus:emit(count or 20)
    end
end

local function update_particles(dt)
    if ps_enemy_hit then ps_enemy_hit:update(dt) end
    if ps_player_hit then ps_player_hit:update(dt) end
    if ps_bonus then ps_bonus:update(dt) end
end

local function draw_particles()
    if ps_enemy_hit then ps_enemy_hit:render() end
    if ps_player_hit then ps_player_hit:render() end
    if ps_bonus then ps_bonus:render() end
end

local function rebuild_world()
    universe = lurek.ecs.newUniverse()
    ai_world = lurek.ai.newWorld()
    enemy_agents = {}
    player_entity = nil
end

local function spawn_player()
    local id = universe:spawn()
    universe:set(id, "transform", {
        x = cfg.SCREEN_W / 2 - cfg.PLAYER_W / 2,
        y = cfg.PLAYER_Y,
        w = cfg.PLAYER_W,
        h = cfg.PLAYER_H,
    })
    universe:set(id, "velocity", { x = 0, y = 0 })
    universe:set(id, "player", { alive = true })
    player_entity = id
end

local function spawn_player_bullet(x, y, vx)
    local id = universe:spawn()
    universe:set(id, "transform", { x = x, y = y, w = cfg.BULLET_W, h = cfg.BULLET_H })
    universe:set(id, "velocity", { x = vx or 0, y = -cfg.BULLET_SPEED })
    universe:set(id, "player_bullet", { active = true })
end

local function spawn_enemy_bullet(x, y, vx, vy)
    local id = universe:spawn()
    universe:set(id, "transform", { x = x, y = y, w = cfg.BULLET_W, h = cfg.BULLET_H })
    universe:set(id, "velocity", { x = vx, y = vy })
    universe:set(id, "enemy_bullet", { active = true })
end

local function add_enemy_agent(entity_id)
    local agent = ai_world:addAgent("enemy_" .. tostring(entity_id))
    agent:setDecisionModel("custom")
    agent:setCustomModel(function(a, bb, _)
        local mode = bb:getString("mode", "formation")
        local ex, ey = a:getPosition()
        local px = bb:getNumber("player_x", ex)
        local py = bb:getNumber("player_y", ey)

        if mode == "dive" then
            local dx = px - ex
            local dy = (py + 120) - ey
            local d = math.sqrt(dx * dx + dy * dy)
            if d > 0.001 then
                a:setVelocity(dx / d * cfg.ENEMY_BULLET_SPEED * 0.65, dy / d * cfg.ENEMY_BULLET_SPEED * 0.65)
            else
                a:setVelocity(0, cfg.ENEMY_BULLET_SPEED * 0.65)
            end
        else
            a:setVelocity(0, 0)
        end
    end)
    enemy_agents[entity_id] = agent
end

local function spawn_enemy(col, row, row_cfg)
    local id = universe:spawn()
    universe:set(id, "transform", {
        x = formation_x(col),
        y = formation_y(row),
        w = cfg.ENEMY_W,
        h = cfg.ENEMY_H,
    })
    universe:set(id, "enemy", {
        home_col = col,
        home_row = row,
        hp = row_cfg.hp,
        max_hp = row_cfg.hp,
        in_formation = true,
        diving = false,
        dive_cooldown = 0.2 + math.random() * 1.3,
        is_boss = row_cfg.is_boss,
        pts = row_cfg.pts,
        color = { row_cfg.color[1], row_cfg.color[2], row_cfg.color[3] },
        base_color = { row_cfg.color[1], row_cfg.color[2], row_cfg.color[3] },
    })
    universe:set(id, "velocity", { x = 0, y = 0 })
    add_enemy_agent(id)
end

local function create_enemies()
    for row = 0, cfg.FORM_ROWS - 1 do
        local row_cfg = cfg.ROW_CFG[row + 1]
        for col = 0, cfg.FORM_COLS - 1 do
            spawn_enemy(col, row, row_cfg)
        end
    end

    challenge_total = #universe:query("enemy", "transform")
    challenge_kills = 0
end

local function set_enemy_mode(entity_id, mode)
    local agent = enemy_agents[entity_id]
    if not agent then
        return
    end
    local bb = agent:getBlackboard()
    bb:setString("mode", mode)
end

local function player_transform()
    if not player_entity or not universe:isAlive(player_entity) then
        return nil
    end
    return universe:get(player_entity, "transform")
end

local function reset_game()
    rebuild_world()
    spawn_player()

    lives = 3
    wave = 1
    score = 0
    dual_fire = false

    is_challenge = false
    challenge_msg_timer = 0
    formation_sway_timer = 0
    formation_offset_x = 0

    create_stars()
    create_enemies()
end

local function next_wave()
    wave = wave + 1
    is_challenge = (wave % cfg.CHALLENGE_INTERVAL == 0)
    if is_challenge then
        challenge_msg_timer = 2.0
    end

    for _, eid in ipairs(universe:query("player_bullet")) do
        universe:kill(eid)
    end
    for _, eid in ipairs(universe:query("enemy_bullet")) do
        universe:kill(eid)
    end

    for eid, agent in pairs(enemy_agents) do
        if agent and ai_world and universe:isAlive(eid) then
            ai_world:removeAgent(agent)
        end
    end
    enemy_agents = {}

    for _, eid in ipairs(universe:query("enemy")) do
        universe:kill(eid)
    end

    create_enemies()
end

local function sync_ui()
    if not ui_controller then
        return
    end

    ui_controller:sync({
        STATE = STATE,
        current_state = current_state,
        score = score,
        high_score = high_score,
        lives = lives,
        wave = wave,
        dual_fire = dual_fire,
        is_challenge = is_challenge,
        challenge_msg_timer = challenge_msg_timer,
        challenge_msg_alpha = clamp(challenge_msg_timer / 0.5, 0, 1),
        challenge_kills = challenge_kills,
        challenge_total = challenge_total,
    })
end

local function remove_enemy(entity_id)
    local agent = enemy_agents[entity_id]
    if ai_world and agent then
        ai_world:removeAgent(agent)
    end
    enemy_agents[entity_id] = nil
    universe:kill(entity_id)
end

local function update_enemy_ai(dt)
    local pt = player_transform()
    if not pt then
        return
    end

    local pxc = pt.x + pt.w / 2
    local pyc = pt.y + pt.h / 2

    formation_sway_timer = formation_sway_timer + dt
    formation_offset_x = math.sin(formation_sway_timer * 0.5) * 30

    for _, eid in ipairs(universe:query("enemy", "transform", "velocity")) do
        local e = universe:get(eid, "enemy")
        local t = universe:get(eid, "transform")

        local agent = enemy_agents[eid]
        if agent then
            agent:setPosition(t.x + t.w / 2, t.y + t.h / 2)
            local bb = agent:getBlackboard()
            bb:setNumber("player_x", pxc)
            bb:setNumber("player_y", pyc)
        end

        e.dive_cooldown = e.dive_cooldown - dt

        if e.in_formation then
            t.x = formation_x(e.home_col)
            t.y = formation_y(e.home_row)

            if e.dive_cooldown <= 0 then
                local dive_chance = is_challenge and 0.55 or (0.15 + math.min(0.35, wave * 0.03))
                if math.random() < dive_chance then
                    e.in_formation = false
                    e.diving = true
                    e.dive_cooldown = 1.1 + math.random() * 1.8
                    set_enemy_mode(eid, "dive")
                else
                    e.dive_cooldown = 0.6 + math.random() * 1.5
                end
            else
                set_enemy_mode(eid, "formation")
            end
        else
            set_enemy_mode(eid, "dive")
        end

        universe:set(eid, "enemy", e)
        universe:set(eid, "transform", t)
    end

    ai_world:update(dt)

    for _, eid in ipairs(universe:query("enemy", "transform", "velocity")) do
        local e = universe:get(eid, "enemy")
        local t = universe:get(eid, "transform")
        local v = universe:get(eid, "velocity")
        local agent = enemy_agents[eid]

        if not e.in_formation and agent then
            local vx, vy = agent:getVelocity()
            v.x = vx
            v.y = vy
            t.x = t.x + v.x * dt
            t.y = t.y + v.y * dt

            if t.y > cfg.SCREEN_H + 60 then
                e.in_formation = true
                e.diving = false
                t.y = -40
                t.x = formation_x(e.home_col)
                set_enemy_mode(eid, "formation")
            end

            if math.random() < 0.012 then
                local bx = t.x + t.w / 2 - cfg.BULLET_W / 2
                local by = t.y + t.h
                local dx = pxc - (t.x + t.w / 2)
                local dy = pyc - (t.y + t.h)
                local d = math.sqrt(dx * dx + dy * dy)
                if d > 0.001 then
                    spawn_enemy_bullet(bx, by, dx / d * cfg.ENEMY_BULLET_SPEED, dy / d * cfg.ENEMY_BULLET_SPEED)
                else
                    spawn_enemy_bullet(bx, by, 0, cfg.ENEMY_BULLET_SPEED)
                end
            end
        else
            v.x = 0
            v.y = 0
        end

        universe:set(eid, "enemy", e)
        universe:set(eid, "transform", t)
        universe:set(eid, "velocity", v)
    end
end

local function update_player(dt)
    local pt = player_transform()
    if not pt then
        return
    end

    local vx = 0
    if lurek.input.isActionDown("left") then
        vx = vx - cfg.PLAYER_SPEED
    end
    if lurek.input.isActionDown("right") then
        vx = vx + cfg.PLAYER_SPEED
    end

    pt.x = clamp(pt.x + vx * dt, 0, cfg.SCREEN_W - pt.w)
    local pid = player_entity
    if pid then
        universe:set(pid, "transform", pt)
    end

    local bullet_count = #universe:query("player_bullet")
    if lurek.input.wasActionPressed("fire") and bullet_count < cfg.MAX_PLAYER_BULLETS then
        local cx = pt.x + pt.w / 2
        if dual_fire then
            spawn_player_bullet(cx - 12 - cfg.BULLET_W / 2, pt.y - cfg.BULLET_H, 0)
            spawn_player_bullet(cx + 12 - cfg.BULLET_W / 2, pt.y - cfg.BULLET_H, 0)
        else
            spawn_player_bullet(cx - cfg.BULLET_W / 2, pt.y - cfg.BULLET_H, 0)
        end
    end
end

local function update_bullets(dt)
    for _, eid in ipairs(universe:query("player_bullet", "transform", "velocity")) do
        local t = universe:get(eid, "transform")
        local v = universe:get(eid, "velocity")
        t.x = t.x + v.x * dt
        t.y = t.y + v.y * dt
        if t.y + t.h < 0 then
            universe:kill(eid)
        else
            universe:set(eid, "transform", t)
        end
    end

    for _, eid in ipairs(universe:query("enemy_bullet", "transform", "velocity")) do
        local t = universe:get(eid, "transform")
        local v = universe:get(eid, "velocity")
        t.x = t.x + v.x * dt
        t.y = t.y + v.y * dt
        if t.y > cfg.SCREEN_H + 20 or t.y < -20 or t.x < -20 or t.x > cfg.SCREEN_W + 20 then
            universe:kill(eid)
        else
            universe:set(eid, "transform", t)
        end
    end
end

local function process_collisions()
    local pt = player_transform()
    if not pt then
        return
    end

    local killed_this_wave = 0

    for _, bid in ipairs(universe:query("player_bullet", "transform")) do
        if not universe:isAlive(bid) then
            goto continue_pb
        end

        local bt = universe:get(bid, "transform")
        local hit = false

        for _, eid in ipairs(universe:query("enemy", "transform")) do
            if not universe:isAlive(eid) then
                goto continue_enemy
            end

            local et = universe:get(eid, "transform")
            local e = universe:get(eid, "enemy")

            if rects_overlap(bt.x, bt.y, bt.w, bt.h, et.x, et.y, et.w, et.h) then
                e.hp = e.hp - 1
                if e.hp <= 0 then
                    local pts = e.pts
                    if e.is_boss then
                        pts = pts + 200
                        dual_fire = true
                    end

                    score = score + pts
                    if score > high_score then
                        high_score = score
                    end

                    emit_enemy_hit(et.x + et.w / 2, et.y + et.h / 2, 14)
                    remove_enemy(eid)
                    killed_this_wave = killed_this_wave + 1
                else
                    e.color = { cfg.BOSS_HIT_COLOR[1], cfg.BOSS_HIT_COLOR[2], cfg.BOSS_HIT_COLOR[3] }
                    universe:set(eid, "enemy", e)
                    emit_enemy_hit(et.x + et.w / 2, et.y + et.h / 2, 5)
                end

                universe:kill(bid)
                hit = true
                break
            end

            ::continue_enemy::
        end

        if not hit and universe:isAlive(bid) then
            universe:set(bid, "transform", bt)
        end

        ::continue_pb::
    end

    if is_challenge and killed_this_wave > 0 then
        challenge_kills = challenge_kills + killed_this_wave
    end

    for _, bid in ipairs(universe:query("enemy_bullet", "transform")) do
        if not universe:isAlive(bid) then
            goto continue_eb
        end
        local bt = universe:get(bid, "transform")
        if rects_overlap(bt.x, bt.y, bt.w, bt.h, pt.x, pt.y, pt.w, pt.h) then
            universe:kill(bid)
            lives = lives - 1
            emit_player_hit(pt.x + pt.w / 2, pt.y + pt.h / 2, 12)
            dual_fire = false
            if lives <= 0 then
                current_state = STATE.GAME_OVER
                sync_ui()
                return
            end
        end
        ::continue_eb::
    end

    for _, eid in ipairs(universe:query("enemy", "transform")) do
        local et = universe:get(eid, "transform")
        local e = universe:get(eid, "enemy")
        if e.diving and rects_overlap(et.x, et.y, et.w, et.h, pt.x, pt.y, pt.w, pt.h) then
            remove_enemy(eid)
            lives = lives - 1
            emit_player_hit(pt.x + pt.w / 2, pt.y + pt.h / 2, 16)
            dual_fire = false
            if lives <= 0 then
                current_state = STATE.GAME_OVER
                sync_ui()
                return
            end
        end
    end

    if #universe:query("enemy") == 0 then
        if is_challenge and challenge_kills >= challenge_total and challenge_total > 0 then
            local bonus = challenge_total * 100
            score = score + bonus
            if score > high_score then
                high_score = score
            end
            emit_bonus(cfg.SCREEN_W / 2, cfg.SCREEN_H / 2, 30)
        end
        next_wave()
    end
end

function M.bind_ui(ui)
    ui_controller = ui
end

function M.get_state()
    return current_state
end

function M.on_ui_primary_action()
    if current_state == STATE.TITLE then
        reset_game()
        current_state = STATE.PLAYING
    elseif current_state == STATE.GAME_OVER then
        reset_game()
        current_state = STATE.TITLE
    end
    sync_ui()
end

function M.on_ui_quit_action()
    if current_state == STATE.GAME_OVER then
        current_state = STATE.TITLE
        sync_ui()
        return
    end
    lurek.event.quit()
end

function M.init()
    lurek.window.setTitle("Galaga - Lurek2D")
    lurek.window.windowConfig({
        width = cfg.SCREEN_W,
        height = cfg.SCREEN_H,
        scaleMode = "none",
        vsync = 1,
    })
    lurek.render.setBackgroundColor(0, 0, 0.02)

    if lurek.render and type(lurek.render.setDefaultFont) == "function" then
        local ui_font = lurek.render.setDefaultFont(16, true)
        if ui_font and lurek.ui and type(lurek.ui.setFont) == "function" then
            lurek.ui.setFont(ui_font)
        end
    end

    lurek.input.bind("left", { "a", "left", "gamepad:0:12" })
    lurek.input.bind("right", { "d", "right", "gamepad:0:13" })
    lurek.input.bind("fire", { "space", "gamepad:0:2" })
    lurek.input.bind("quit", { "escape", "gamepad:0:8" })
    lurek.input.bind("start", { "return", "gamepad:0:0", "gamepad:0:9" })
    lurek.input.bind("confirm", { "return", "kp_enter", "gamepad:0:0", "gamepad:0:9" })
    lurek.input.bind("restart", { "r", "gamepad:0:3" })

    cam = lurek.camera.new(cfg.SCREEN_W, cfg.SCREEN_H)

    math.randomseed(os.time())
    init_particles()
    reset_game()
    current_state = STATE.TITLE
    sync_ui()
end

function M.process(dt)
    if lurek.input.wasActionPressed("quit") then
        lurek.event.quit()
        return
    end

    update_stars(dt)
    update_particles(dt)

    if current_state == STATE.TITLE then
        if lurek.input.wasActionPressed("start") then
            reset_game()
            current_state = STATE.PLAYING
        end
        sync_ui()
        return
    end

    if current_state == STATE.GAME_OVER then
        if lurek.input.wasActionPressed("restart") or lurek.input.wasActionPressed("start") then
            reset_game()
            current_state = STATE.PLAYING
        end
        sync_ui()
        return
    end

    if challenge_msg_timer > 0 then
        challenge_msg_timer = challenge_msg_timer - dt
    end

    update_player(dt)
    update_enemy_ai(dt)
    update_bullets(dt)
    process_collisions()

    sync_ui()
end

function M.draw()
    if not cam then
        return
    end

    cam:apply()
    draw_stars()

    if current_state == STATE.TITLE then
        cam:reset()
        return
    end

    for _, eid in ipairs(universe:query("enemy", "transform")) do
        local e = universe:get(eid, "enemy")
        local t = universe:get(eid, "transform")
        lurek.render.setColor(e.color[1], e.color[2], e.color[3], 1)
        lurek.render.rectangle("fill", t.x, t.y, t.w, t.h)
        if e.is_boss then
            lurek.render.setColor(1, 1, 1, 0.25)
            lurek.render.rectangle("fill", t.x + 4, t.y + 4, t.w - 8, t.h - 8)
        end
    end

    local pt = player_transform()
    if pt and (current_state ~= STATE.GAME_OVER or lives > 0) then
        lurek.render.setColor(0.2, 0.6, 1.0, 1)
        if dual_fire then
            lurek.render.rectangle("fill", pt.x - 10, pt.y, cfg.PLAYER_W, cfg.PLAYER_H)
            lurek.render.rectangle("fill", pt.x + 10, pt.y, cfg.PLAYER_W, cfg.PLAYER_H)
        else
            lurek.render.rectangle("fill", pt.x, pt.y, cfg.PLAYER_W, cfg.PLAYER_H)
        end
        lurek.render.rectangle("fill", pt.x + cfg.PLAYER_W / 2 - cfg.PLAYER_TURRET_W / 2, pt.y - cfg.PLAYER_TURRET_H, cfg.PLAYER_TURRET_W, cfg.PLAYER_TURRET_H)
    end

    lurek.render.setColor(1, 1, 0.3, 1)
    for _, eid in ipairs(universe:query("player_bullet", "transform")) do
        local t = universe:get(eid, "transform")
        lurek.render.rectangle("fill", t.x, t.y, t.w, t.h)
    end

    lurek.render.setColor(1, 0.3, 0.3, 1)
    for _, eid in ipairs(universe:query("enemy_bullet", "transform")) do
        local t = universe:get(eid, "transform")
        lurek.render.rectangle("fill", t.x, t.y, t.w, t.h)
    end

    draw_particles()

    cam:reset()
end

return M
