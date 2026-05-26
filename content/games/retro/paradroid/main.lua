-- ============================================================================
-- Paradroid — Lurek2D
-- Category: retro
-- Top-down droid shooter inspired by Andrew Braybrook's 1985 C-64 masterpiece
-- Controls: Arrow keys = move, Space = fire, E = transfer, Escape = quit
-- ============================================================================

local signal = lurek.event
local input  = lurek.input

local tween  = lurek.tween
local particle = lurek.particle

-- Constants
local PLAY_X, PLAY_Y = 60, 40
local PLAY_W, PLAY_H = 680, 520
local CELL = 40
local COLS, ROWS = 17, 13
local BULLET_SPEED = 320
local TRANSFER_RANGE = 50
local ENERGY_DRAIN_BASE = 2
local TRANSFER_BAR_MAX = 100

-- States
local STATE_TITLE      = "PLAYING"
local STATE_PLAYING    = "PLAYING"
local STATE_TRANSFER   = "TRANSFER"
local STATE_LEVEL_CLEAR = "LEVEL_CLEAR"
local STATE_GAME_OVER  = "GAME_OVER"

-- Game state
local state = STATE_PLAYING
local score = 0
local level = 1
local dt = 0
local title_blink = 0

-- Player
local player = {
    x = 0, y = 0, dir = "right",
    droid_class = 1, droid_num = "001",
    hp = 1, max_hp = 1, energy = 100, max_energy = 100,
    fire_cooldown = 0, speed = 120
}

local app_ui = {}

-- Enemies, bullets, particles, room
local enemies = {}
local bullets = {}
local emitters = {}
local room_walls = {}

-- Transfer mini-game state
local transfer = {
    target = nil,
    player_bar = 0, enemy_bar = 0,
    timer = 0, duration = 3.0,
    result = nil, result_timer = 0
}

-- Level definitions: {droid_count, classes_available}
local LEVELS = {
    { count = 5,  classes = {100, 100, 100, 200, 200} },
    { count = 7,  classes = {100, 200, 200, 200, 500, 500, 100} },
    { count = 9,  classes = {200, 200, 500, 500, 500, 900, 200, 100, 100} },
    { count = 11, classes = {200, 500, 500, 500, 900, 900, 900, 200, 200, 500, 100} },
}

-- Droid class stats: {hp, damage, speed, color, energy_drain_mult}
local DROID_STATS = {
    [1]   = { hp = 1, dmg = 1, spd = 120, color = {0.3, 0.8, 1.0},  drain = 0.5 },
    [100] = { hp = 1, dmg = 1, spd = 80,  color = {0.4, 0.7, 0.3},  drain = 1.0 },
    [200] = { hp = 2, dmg = 1, spd = 90,  color = {0.9, 0.7, 0.2},  drain = 1.5 },
    [500] = { hp = 3, dmg = 2, spd = 100, color = {0.9, 0.3, 0.2},  drain = 2.5 },
    [900] = { hp = 5, dmg = 3, spd = 110, color = {0.9, 0.2, 0.9},  drain = 4.0 },
}

-- Room generation
local function generate_room()
    room_walls = {}
    for r = 0, ROWS - 1 do
        room_walls[r] = {}
        for c = 0, COLS - 1 do
            if r == 0 or r == ROWS - 1 or c == 0 or c == COLS - 1 then
                room_walls[r][c] = true
            else
                room_walls[r][c] = false
            end
        end
    end
    -- Add internal walls for corridors
    math.randomseed(level * 42 + 7)
    local wall_count = 12 + level * 4
    for _ = 1, wall_count do
        local r = math.random(2, ROWS - 3)
        local c = math.random(2, COLS - 3)
        room_walls[r][c] = true
    end
    -- Ensure player start area is clear
    for r = 1, 3 do
        for c = 1, 3 do
            room_walls[r][c] = false
        end
    end
end

local function cell_to_world(c, r)
    return PLAY_X + c * CELL + CELL / 2, PLAY_Y + r * CELL + CELL / 2
end

local function world_to_cell(x, y)
    return math.floor((x - PLAY_X) / CELL), math.floor((y - PLAY_Y) / CELL)
end

local function is_wall(x, y)
    local c, r = world_to_cell(x, y)
    if r < 0 or r >= ROWS or c < 0 or c >= COLS then return true end
    return room_walls[r] and room_walls[r][c]
end

local function get_droid_stats(class)
    return DROID_STATS[class] or DROID_STATS[100]
end

-- Spawn enemies for current level
local function spawn_enemies()
    enemies = {}
    local lvl = LEVELS[level] or LEVELS[#LEVELS]
    for i = 1, lvl.count do
        local class = lvl.classes[i] or 100
        local stats = get_droid_stats(class)
        local placed = false
        for _ = 1, 50 do
            local c = math.random(4, COLS - 3)
            local r = math.random(4, ROWS - 3)
            if not room_walls[r][c] then
                local wx, wy = cell_to_world(c, r)
                local num = class + math.random(0, 99)
                enemies[#enemies + 1] = {
                    x = wx, y = wy, hp = stats.hp, max_hp = stats.hp,
                    class = class, num = string.format("%03d", num),
                    speed = stats.spd, dmg = stats.dmg,
                    dir = "down", move_timer = math.random() * 3,
                    color = stats.color, alive = true,
                    fire_cooldown = 0
                }
                placed = true
                break
            end
        end
    end
end

local function spawn_particle(x, y, r, g, b, count, speed, life)
    local e = particle.newSystem()
    e:setPosition(x, y)
    e:setColors({{r, g, b, 1.0}})
    e:setSpeed(speed or 60, speed or 60)
    e:setParticleLifetime(life or 0.5, life or 0.5)
    e:setSizes(3, 1)
    e:emit(count or 8)
    emitters[#emitters + 1] = { em = e, timer = (life or 0.5) + 0.2 }
end

local function init_level()
    generate_room()
    local px, py = cell_to_world(2, 2)
    player.x, player.y = px, py
    player.dir = "right"
    player.fire_cooldown = 0
    bullets = {}
    emitters = {}
    spawn_enemies()
end

local function reset_game()
    score = 0
    level = 1
    player.droid_class = 1
    player.droid_num = "001"
    local stats = get_droid_stats(1)
    player.hp = stats.hp
    player.max_hp = stats.hp
    player.energy = 100
    player.max_energy = 100
    player.speed = stats.spd
    init_level()
end

local function set_player_droid(class, num)
    player.droid_class = class
    player.droid_num = num
    local stats = get_droid_stats(class)
    player.hp = stats.hp
    player.max_hp = stats.hp
    player.energy = 100
    player.max_energy = 100
    player.speed = stats.spd
end

-- Direction vectors
local DIR_VEC = {
    up    = { dx = 0, dy = -1 },
    down  = { dx = 0, dy = 1 },
    left  = { dx = -1, dy = 0 },
    right = { dx = 1, dy = 0 },
}

local function fire_bullet(x, y, dir, dmg, owner)
    local v = DIR_VEC[dir]
    if not v then return end
    bullets[#bullets + 1] = {
        x = x, y = y, dx = v.dx * BULLET_SPEED, dy = v.dy * BULLET_SPEED,
        dmg = dmg, owner = owner, alive = true
    }
end

local function dist(x1, y1, x2, y2)
    local dx, dy = x2 - x1, y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

-- Update
local function update_playing()
    -- Player movement
    local mx, my = 0, 0
    if input.isActionDown("up")    then my = -1; player.dir = "up" end
    if input.isActionDown("down")  then my = 1;  player.dir = "down" end
    if input.isActionDown("left")  then mx = -1; player.dir = "left" end
    if input.isActionDown("right") then mx = 1;  player.dir = "right" end

    if mx ~= 0 or my ~= 0 then
        local len = math.sqrt(mx * mx + my * my)
        mx, my = mx / len, my / len
        local nx = player.x + mx * player.speed * dt
        local ny = player.y + my * player.speed * dt
        if not is_wall(nx, player.y) then player.x = nx end
        if not is_wall(player.x, ny) then player.y = ny end
        -- Clamp to play area
        player.x = math.max(PLAY_X + 12, math.min(PLAY_X + PLAY_W - 12, player.x))
        player.y = math.max(PLAY_Y + 12, math.min(PLAY_Y + PLAY_H - 12, player.y))
    end

    -- Fire
    player.fire_cooldown = math.max(0, player.fire_cooldown - dt)
    if input.isActionDown("fire") and player.fire_cooldown <= 0 then
        local stats = get_droid_stats(player.droid_class)
        fire_bullet(player.x, player.y, player.dir, stats.dmg, "player")
        player.fire_cooldown = 0.25
        local pc = stats.color or {0.5, 0.8, 1.0}
        spawn_particle(player.x, player.y, pc[1], pc[2], pc[3], 4, 80, 0.2)
    end

    -- Transfer initiate
    if input.wasActionPressed("interact") then
        for _, e in ipairs(enemies) do
            if e.alive and dist(player.x, player.y, e.x, e.y) < TRANSFER_RANGE then
                state = STATE_TRANSFER
                transfer.target = e
                transfer.player_bar = 0
                transfer.enemy_bar = 0
                transfer.timer = 0
                transfer.duration = 2.5 + (e.class / 500)
                transfer.result = nil
                transfer.result_timer = 0
                return
            end
        end
    end

    -- Energy drain
    local drain = ENERGY_DRAIN_BASE * (get_droid_stats(player.droid_class).drain or 1)
    player.energy = player.energy - drain * dt
    if player.energy <= 10 then
        spawn_particle(player.x, player.y, 1, 0.3, 0.1, 1, 20, 0.3)
    end
    if player.energy <= 0 then
        player.energy = 0
        player.hp = player.hp - 1
        if player.hp <= 0 then
            spawn_particle(player.x, player.y, 1, 0.5, 0.1, 20, 120, 0.8)
            state = STATE_GAME_OVER
            return
        end
        player.energy = 20
    end

    -- Enemy AI
    for _, e in ipairs(enemies) do
        if e.alive then
            e.move_timer = e.move_timer - dt
            if e.move_timer <= 0 then
                local dirs = {"up", "down", "left", "right"}
                e.dir = dirs[math.random(#dirs)]
                e.move_timer = 1.5 + math.random() * 2
            end
            local v = DIR_VEC[e.dir]
            if v then
                local nx = e.x + v.dx * e.speed * 0.5 * dt
                local ny = e.y + v.dy * e.speed * 0.5 * dt
                if not is_wall(nx, e.y) then e.x = nx end
                if not is_wall(e.x, ny) then e.y = ny end
                e.x = math.max(PLAY_X + 12, math.min(PLAY_X + PLAY_W - 12, e.x))
                e.y = math.max(PLAY_Y + 12, math.min(PLAY_Y + PLAY_H - 12, e.y))
            end
            -- Enemy fire
            e.fire_cooldown = e.fire_cooldown - dt
            if e.fire_cooldown <= 0 and dist(player.x, player.y, e.x, e.y) < 200 then
                fire_bullet(e.x, e.y, e.dir, e.dmg, "enemy")
                e.fire_cooldown = 1.5 + math.random() * 2
            end
        end
    end

    -- Update bullets
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        b.x = b.x + b.dx * dt
        b.y = b.y + b.dy * dt
        -- Wall collision
        if is_wall(b.x, b.y) or b.x < PLAY_X or b.x > PLAY_X + PLAY_W or
           b.y < PLAY_Y or b.y > PLAY_Y + PLAY_H then
            spawn_particle(b.x, b.y, 1, 0.8, 0.3, 5, 60, 0.3)
            table.remove(bullets, i)
        else
            -- Hit detection
            if b.owner == "player" then
                for _, e in ipairs(enemies) do
                    if e.alive and dist(b.x, b.y, e.x, e.y) < 14 then
                        e.hp = e.hp - b.dmg
                        spawn_particle(e.x, e.y, 1, 0.6, 0.2, 6, 80, 0.3)
                        if e.hp <= 0 then
                            e.alive = false
                            score = score + e.class
                            spawn_particle(e.x, e.y, e.color[1], e.color[2], e.color[3], 16, 120, 0.7)
                        end
                        b.alive = false
                        break
                    end
                end
            elseif b.owner == "enemy" then
                if dist(b.x, b.y, player.x, player.y) < 14 then
                    player.hp = player.hp - b.dmg
                    spawn_particle(player.x, player.y, 1, 0.3, 0.3, 8, 80, 0.4)
                    if player.hp <= 0 then
                        spawn_particle(player.x, player.y, 1, 0.5, 0.1, 24, 140, 1.0)
                        state = STATE_GAME_OVER
                        return
                    end
                    b.alive = false
                end
            end
            if not b.alive then
                table.remove(bullets, i)
            end
        end
    end

    -- Update emitters
    for i = #emitters, 1, -1 do
        local em = emitters[i]
        em.timer = em.timer - dt
        em.em:update(dt)
        if em.timer <= 0 then
            table.remove(emitters, i)
        end
    end

    -- Check level clear
    local all_dead = true
    for _, e in ipairs(enemies) do
        if e.alive then all_dead = false; break end
    end
    if all_dead then
        state = STATE_LEVEL_CLEAR
    end
end

local function update_transfer()
    if not transfer.target then return end
    local target = assert(transfer.target)
    transfer.timer = transfer.timer + dt

    -- Player boosts with WASD
    if input.wasActionPressed("boost") then
        transfer.player_bar = transfer.player_bar + 4 + math.random() * 3
    end
    -- Enemy bar auto-advances based on class
    local enemy_rate = 8 + (target.class / 100) * 3
    transfer.enemy_bar = transfer.enemy_bar + enemy_rate * dt
    -- Player bar also auto-advances slowly
    transfer.player_bar = transfer.player_bar + 5 * dt

    -- Electricity particles
    if math.random() < 0.3 then
        spawn_particle(
            (player.x + target.x) / 2 + math.random(-20, 20),
            (player.y + target.y) / 2 + math.random(-20, 20),
            0.4, 0.7, 1.0, 3, 100, 0.2
        )
    end

    -- Time up — determine winner
    if transfer.timer >= transfer.duration then
        if transfer.player_bar >= transfer.enemy_bar then
            -- Win: take over enemy droid
            transfer.result = "WIN"
            score = score + target.class
            set_player_droid(target.class, target.num)
            player.x, player.y = target.x, target.y
            target.alive = false
            spawn_particle(player.x, player.y, 0.3, 0.8, 1.0, 20, 100, 0.6)
        else
            -- Lose: player droid destroyed
            transfer.result = "LOSE"
            spawn_particle(player.x, player.y, 1, 0.3, 0.1, 20, 120, 0.8)
        end
        transfer.result_timer = 0
    end

    -- Show result briefly then return
    if transfer.result then
        transfer.result_timer = transfer.result_timer + dt
        if transfer.result_timer > 1.5 then
            if transfer.result == "LOSE" then
                state = STATE_GAME_OVER
            else
                state = STATE_PLAYING
            end
        end
    end
end

-- Callbacks

-- Universal render helpers (handles all legacy and current call signatures)
local _gfx = lurek.render
local function _sc(c)
    if type(c) == "table" then
        local col = c.color or c
        if type(col) == "table" then
            _gfx.setColor(col[1] or 1, col[2] or 1, col[3] or 1, col[4] or 1)
        end
    end
end
local function rect(a, b, c, d, e, f, g, h, i)
    if type(a) == "string" then
        if type(f) == "number" then _gfx.setColor(f, g or 1, h or 1, i or 1) end
        _gfx.rectangle(a, b, c, d, e)
    elseif type(e) == "table" then
        _sc(e); _gfx.rectangle(e.mode or "fill", a, b, c, d)
    elseif type(e) == "number" then
        _gfx.setColor(e or 1, f or 1, g or 1, h or 1); _gfx.rectangle("fill", a, b, c, d)
    else
        _gfx.rectangle("fill", a, b, c, d)
    end
end
local function circ(a, b, c, d, e, f, g, h)
    if type(a) == "string" then
        if type(e) == "table" then _sc(e)
        elseif type(e) == "number" then _gfx.setColor(e or 1, f or 1, g or 1, h or 1) end
        _gfx.circle(a, b, c, d)
    elseif type(d) == "table" then
        _sc(d); _gfx.circle("fill", a, b, c)
    elseif type(d) == "number" then
        _gfx.setColor(d or 1, e or 1, f or 1, g or 1); _gfx.circle("fill", a, b, c)
    else
        _gfx.circle("fill", a, b, c)
    end
end
local function text_(a, b, c, d, e, f, g, h)
    if type(d) == "table" then
        _sc(d)
    elseif type(d) == "number" and type(e) == "number" then
        _gfx.setColor(e or 1, f or 1, g or 1, h or 1)
    end
    _gfx.print(tostring(a), b, c)
end
local function ln(x1, y1, x2, y2, c)
    if type(c) == "table" then _sc(c) end
    _gfx.line(x1, y1, x2, y2)
end

function lurek.init()
    lurek.window.setTitle("Paradroid — Lurek2D")
    lurek.render.setBackgroundColor(0.03, 0.03, 0.08)
    input.bind("up",       {"up"})
    input.bind("down",     {"down"})
    input.bind("left",     {"left"})
    input.bind("right",    {"right"})
    input.bind("fire",     {"space"})
    input.bind("quit",     {"escape"})
    input.bind("confirm",  {"return"})
    input.bind("interact", {"e"})
    input.bind("boost",    {"w", "a", "s", "d"})
    
    lurek.ui.loadLayoutFile("content/games/retro/paradroid/ui.toml")
    local ui_root = lurek.ui.getRoot()
    app_ui = {}
    app_ui.title_screen = ui_root:findById("title_screen")
    app_ui.title_press_start = ui_root:findById("title_press_start")
    
    app_ui.game_over_screen = ui_root:findById("game_over_screen")
    app_ui.go_score = ui_root:findById("go_score")
    app_ui.go_level = ui_root:findById("go_level")
    app_ui.go_press_start = ui_root:findById("go_press_start")
    
    app_ui.level_clear_screen = ui_root:findById("level_clear_screen")
    app_ui.lc_title = ui_root:findById("lc_title")
    app_ui.lc_score = ui_root:findById("lc_score")
    app_ui.lc_press_start = ui_root:findById("lc_press_start")
    
    app_ui.transfer_screen = ui_root:findById("transfer_screen")
    app_ui.transfer_player_label = ui_root:findById("transfer_player_label")
    app_ui.transfer_player_bar = ui_root:findById("transfer_player_bar")
    app_ui.transfer_enemy_label = ui_root:findById("transfer_enemy_label")
    app_ui.transfer_enemy_bar = ui_root:findById("transfer_enemy_bar")
    app_ui.transfer_time_bar = ui_root:findById("transfer_time_bar")
    app_ui.transfer_result = ui_root:findById("transfer_result")
    
    app_ui.hud_screen = ui_root:findById("hud_screen")
    app_ui.hud_droid = ui_root:findById("hud_droid")
    app_ui.hud_hp_bar = ui_root:findById("hud_hp_bar")
    app_ui.hud_en_bar = ui_root:findById("hud_en_bar")
    app_ui.hud_score = ui_root:findById("hud_score")
    app_ui.hud_level = ui_root:findById("hud_level")
    app_ui.fps_label = ui_root:findById("fps_label")
end

local function _ready_setup() end

function lurek.process(delta)
    if lurek.automation then lurek.automation.update(delta) end
    dt = delta
    title_blink = title_blink + dt

    if input.wasActionPressed("quit") then
        signal.quit()
        return
    end

    if state == STATE_TITLE then
        if input.wasActionPressed("fire") or input.wasActionPressed("confirm") then
            reset_game()
            state = STATE_PLAYING
        end
    elseif state == STATE_PLAYING then
        update_playing()
    elseif state == STATE_TRANSFER then
        update_transfer()
    elseif state == STATE_LEVEL_CLEAR then
        if input.wasActionPressed("fire") or input.wasActionPressed("confirm") then
            level = level + 1
            if level > #LEVELS then
                state = STATE_GAME_OVER
            else
                init_level()
                state = STATE_PLAYING
            end
        end
    elseif state == STATE_GAME_OVER then
        if input.wasActionPressed("fire") or input.wasActionPressed("confirm") then
            state = STATE_TITLE
        end
    end
    
    -- Sync UI
    local blink = math.floor(title_blink * 2) % 2 == 0
    app_ui.title_screen.visible = (state == STATE_TITLE)
    if state == STATE_TITLE then
        app_ui.title_press_start.visible = blink
    end
    
    app_ui.game_over_screen.visible = (state == STATE_GAME_OVER)
    if state == STATE_GAME_OVER then
        app_ui.go_score.text = "Score: " .. score
        app_ui.go_level.text = "Level: " .. level
        app_ui.go_press_start.visible = blink
    end
    
    app_ui.level_clear_screen.visible = (state == STATE_LEVEL_CLEAR)
    if state == STATE_LEVEL_CLEAR then
        app_ui.lc_title.text = "LEVEL " .. level .. " CLEAR"
        app_ui.lc_score.text = "Score: " .. score
        app_ui.lc_press_start.visible = blink
    end
    
    app_ui.transfer_screen.visible = (state == STATE_TRANSFER)
    if state == STATE_TRANSFER then
        app_ui.transfer_player_label.text = "YOU [" .. player.droid_num .. "]"
        
        local p_frac = math.min(transfer.player_bar / TRANSFER_BAR_MAX, 1.0)
        app_ui.transfer_player_bar.width = 300 * p_frac
        
        local te = transfer.target
        if te then
            local tc = te.color
            app_ui.transfer_enemy_label.text = "ENEMY [" .. te.num .. "]"
            app_ui.transfer_enemy_label.color = {tc[1], tc[2], tc[3], 1}
            local e_frac = math.min(transfer.enemy_bar / TRANSFER_BAR_MAX, 1.0)
            app_ui.transfer_enemy_bar.width = 300 * e_frac
            app_ui.transfer_enemy_bar.bg_color = {tc[1], tc[2], tc[3], 1}
        end
        
        local time_frac = math.min(transfer.timer / transfer.duration, 1.0)
        app_ui.transfer_time_bar.width = 300 * time_frac
        
        if transfer.result == "WIN" then
            app_ui.transfer_result.text = "TRANSFER COMPLETE!"
            app_ui.transfer_result.color = {0.3, 1.0, 0.4, 1}
        elseif transfer.result == "LOSE" then
            app_ui.transfer_result.text = "TRANSFER FAILED!"
            app_ui.transfer_result.color = {1.0, 0.3, 0.2, 1}
        else
            app_ui.transfer_result.text = ""
        end
    end
    
    app_ui.hud_screen.visible = (state == STATE_PLAYING or state == STATE_TRANSFER)
    if state == STATE_PLAYING or state == STATE_TRANSFER then
        local ps = get_droid_stats(player.droid_class)
        local pc = ps.color
        app_ui.hud_droid.text = "DROID " .. player.droid_num
        app_ui.hud_droid.color = {pc[1], pc[2], pc[3], 1}
        
        local hp_frac = player.hp / player.max_hp
        app_ui.hud_hp_bar.width = 120 * hp_frac
        
        local en_frac = player.energy / player.max_energy
        app_ui.hud_en_bar.width = 120 * en_frac
        if en_frac < 0.25 then
            app_ui.hud_en_bar.bg_color = {1.0, 0.3, 0.1, 1}
        else
            app_ui.hud_en_bar.bg_color = {0.3, 0.6, 1.0, 1}
        end
        
        app_ui.hud_score.text = "SCORE " .. score
        app_ui.hud_level.text = "LEVEL " .. level
        
        if dt > 0 then
            app_ui.fps_label.text = string.format("FPS %d", math.floor(1 / dt + 0.5))
        end
    end
end

function lurek.draw_ui()
end
