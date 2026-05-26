-- ============================================================================
--  Snake — Eat, grow, avoid yourself
-- ----------------------------------------------------------------------------
--  Category : arcade
--  Source   : ../../../../content/demos/arcade/snake   (original demo)
--  Run with : cargo run -- content/games/arcade/snake
--
--  Controls (bound as input actions — see lurek.init):
--    up/down/left/right : W/A/S/D or ←↑↓→
--    confirm            : Enter          (start / restart)
--    quit               : Escape
--
--  lurek.* namespaces used:
--    window, render, input, signal, time, camera, particles, tween
-- ============================================================================

-- ── Constants ─────────────────────────────────────────────────────────────

local CELL       = 20
local COLS, ROWS = 32, 28
local GRID_W     = COLS * CELL        -- 640
local GRID_H     = ROWS * CELL        -- 560
local HUD_H      = 40
local SCREEN_W   = GRID_W             -- 640
local SCREEN_H   = GRID_H + HUD_H    -- 600
local BASE_SPEED = 8                  -- cells / second
local FOOD_COUNT = 3

-- ── Scene state enum ──────────────────────────────────────────────────────
local STATE = { TITLE = 1, PLAYING = 2, DEAD = 3 }
local state = STATE.PLAYING

-- ── Mutable game state ───────────────────────────────────────────────────
local snake      = {}
local dir        = { 1, 0 }
local next_dir   = { 1, 0 }
local food       = {}
local score      = 0
local display_score = { value = 0 }  -- tweened display value
local high_score = 0
local move_timer = 0
local speed      = BASE_SPEED
local cam                            -- Camera2D
local food_particles                 -- particle system for eat bursts
local score_tween                    -- active score tween (or nil)
local app_ui = {}

-- ── Helpers ───────────────────────────────────────────────────────────────

--- Check if a cell is occupied by snake or food.
local function is_occupied(cx, cy)
    for _, seg in ipairs(snake) do
        if seg[1] == cx and seg[2] == cy then return true end
    end
    for _, f in ipairs(food) do
        if f[1] == cx and f[2] == cy then return true end
    end
    return false
end

--- Spawn food items until the board has FOOD_COUNT pieces.
local function spawn_food()
    local attempts = 0
    while #food < FOOD_COUNT and attempts < 1000 do
        local fx = math.random(0, COLS - 1)
        local fy = math.random(0, ROWS - 1)
        if not is_occupied(fx, fy) then
            food[#food + 1] = { fx, fy }
        end
        attempts = attempts + 1
    end
end

--- Reset state to start a fresh round.
local function reset()
    local mid_x = math.floor(COLS / 2)
    local mid_y = math.floor(ROWS / 2)
    snake = {}
    for i = 4, 1, -1 do
        snake[#snake + 1] = { mid_x - i + 1, mid_y }
    end
    dir      = { 1, 0 }
    next_dir = { 1, 0 }
    score    = 0
    display_score.value = 0
    speed    = BASE_SPEED
    move_timer = 0
    food     = {}
    spawn_food()
    state = STATE.PLAYING
end

-- ── lurek.init ────────────────────────────────────────────────────────────
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
local function rect(a, b, c, d, e, f, g, h)
    if type(a) == "string" then
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
    lurek.window.setTitle("Snake — Lurek2D")
    lurek.render.setBackgroundColor(0.04, 0.06, 0.04)

    -- Action-based input
    lurek.input.bind("up",      "w");
	lurek.input.bind("up",      "up")
    lurek.input.bind("down",    "s");
	lurek.input.bind("down",    "down")
    lurek.input.bind("left",    "a");
	lurek.input.bind("left",    "left")
    lurek.input.bind("right",   "d");
	lurek.input.bind("right",   "right")
    lurek.input.bind("confirm", "return");
	lurek.input.bind("confirm", "kp_enter")
    lurek.input.bind("quit",    "escape")

    -- Camera (static, but good practice)
    cam = lurek.camera.new(SCREEN_W, SCREEN_H)

    -- Particle system — burst when eating food
    food_particles = lurek.particle.newSystem({
        maxParticles = 120,
        emissionRate = 0,
        lifetimeMin  = 0.2,  lifetimeMax = 0.55,
        speedMin     = 80,   speedMax    = 200,
        direction    = 0,    spread      = math.pi * 2,
        gravityY     = 60,
        sizes        = { 4, 3, 1.5, 0 },
        colors = {
            { 1.0, 0.4, 0.2 },
            { 1.0, 0.8, 0.1 },
            { 0.2, 1.0, 0.2, 0.0 },
        },
    })
    
    lurek.ui.loadLayoutFile("content/games/arcade/snake/ui.toml")
    local ui_root = lurek.ui.getRoot()
    app_ui.hud = ui_root:findById("hud")
    app_ui.title_screen = ui_root:findById("title_screen")
    app_ui.game_over_screen = ui_root:findById("game_over_screen")
    app_ui.score_label = ui_root:findById("score_label")
    app_ui.high_score_label = ui_root:findById("high_score_label")
    app_ui.fps_label = ui_root:findById("fps_label")
    app_ui.final_score = ui_root:findById("final_score")
    app_ui.new_best = ui_root:findById("new_best")
    app_ui.press_start = ui_root:findById("press_start")
    app_ui.press_restart = ui_root:findById("press_restart")
    
    local function handle_start_click()
        if state == STATE.TITLE or state == STATE.DEAD then
            reset()
        end
    end
    
    if app_ui.press_start then app_ui.press_start:setOnClick(handle_start_click) end
    if app_ui.press_restart then app_ui.press_restart:setOnClick(handle_start_click) end
end

-- ── lurek.ready ───────────────────────────────────────────────────────────
local function _ready_setup()
    -- nothing extra needed
end

-- ── Input: direction changes via keypressed callback ──────────────────────
-- Using keypressed avoids frame-skip issues with buffered direction input.
function lurek.keypressed(key)
    if state ~= STATE.PLAYING then return end

    -- Map raw key to direction, preventing 180-degree reversal
    if (key == "w" or key == "up")    and dir[2] ~=  1 then next_dir = {  0, -1 } end
    if (key == "s" or key == "down")  and dir[2] ~= -1 then next_dir = {  0,  1 } end
    if (key == "a" or key == "left")  and dir[1] ~=  1 then next_dir = { -1,  0 } end
    if (key == "d" or key == "right") and dir[1] ~= -1 then next_dir = {  1,  0 } end
end

-- ── lurek.process(dt) ─────────────────────────────────────────────────────
function lurek.process(dt)
    if lurek.automation then lurek.automation.update(dt) end
    -- Quit action (all states)
    if lurek.input.wasActionPressed("quit") then
        lurek.event.quit()
        return
    end

    -- Title screen
    if state == STATE.TITLE then
        if lurek.input.wasActionPressed("confirm") then
            reset()
        end
    end

    -- Death screen
    if state == STATE.DEAD then
        if lurek.input.wasActionPressed("confirm") then
            reset()
        end
    end

    -- UI sync
    app_ui.title_screen.visible = (state == STATE.TITLE)
    app_ui.game_over_screen.visible = (state == STATE.DEAD)
    app_ui.hud.visible = true
    
    app_ui.fps_label.text = "FPS: " .. math.floor(lurek.timer.getFPS())
    app_ui.score_label.text = "Score: " .. math.floor(display_score.value)
    app_ui.high_score_label.text = "Best: " .. high_score
    
    if state == STATE.DEAD then
        app_ui.final_score.text = "Score: " .. score
        app_ui.new_best.visible = (score >= high_score and score > 0)
    end
    
    if state ~= STATE.PLAYING then return end

    -- ── Playing ───────────────────────────────────────────────────────────

    -- Drive tweens and particles
    lurek.tween.update(dt)
    food_particles:update(dt)
    cam:update(dt)

    -- Tick-based movement
    move_timer = move_timer + dt
    if move_timer < 1 / speed then return end
    move_timer = move_timer - 1 / speed

    -- Apply buffered direction
    dir[1] = next_dir[1]
    dir[2] = next_dir[2]

    -- Compute next head position (wrapping)
    local head = snake[#snake]
    local nx = (head[1] + dir[1]) % COLS
    local ny = (head[2] + dir[2]) % ROWS

    -- Self-collision (ignore tail tip — it will move)
    for i = 1, #snake - 1 do
        if snake[i][1] == nx and snake[i][2] == ny then
            state = STATE.DEAD
            high_score = math.max(high_score, score)
            return
        end
    end

    -- Advance snake
    snake[#snake + 1] = { nx, ny }

    -- Eat food?
    local ate = false
    for i, f in ipairs(food) do
        if f[1] == nx and f[2] == ny then
            score = score + 1
            speed = BASE_SPEED + math.floor(score / 5) * 1.5

            -- Particle burst at food location (screen coords)
            local px = f[1] * CELL + CELL / 2
            local py = f[2] * CELL + HUD_H + CELL / 2
            food_particles:moveTo(px, py)
            food_particles:emit(18)

            -- Tween score display
            local target = score
            score_tween = lurek.tween.to(display_score, { value = target }, 0.25, "outQuad")

            -- Replace eaten food item
            table.remove(food, i)
            spawn_food()
            ate = true
            break
        end
    end

    if not ate then
        table.remove(snake, 1)
    end

    -- Update tweened display score from tween target
    display_score.value = score  -- fallback; tween drives smooth transitions visually
end

-- ── lurek.render — world / game grid ──────────────────────────────────────
function lurek.draw()
    cam:apply()

    -- Grid background
    lurek.render.setColor(0.06, 0.08, 0.06)
    rect("fill", 0, HUD_H, GRID_W, GRID_H)

    -- Subtle grid lines
    lurek.render.setColor(0.09, 0.12, 0.09)
    for gx = 0, COLS do
        ln(gx * CELL, HUD_H, gx * CELL, HUD_H + GRID_H)
    end
    for gy = 0, ROWS do
        ln(0, HUD_H + gy * CELL, GRID_W, HUD_H + gy * CELL)
    end

    -- Food: red circle with green stem
    for _, f in ipairs(food) do
        local cx = f[1] * CELL + CELL / 2
        local cy = f[2] * CELL + HUD_H + CELL / 2
        -- Body
        lurek.render.setColor(1, 0.2, 0.2)
        circ("fill", cx, cy, CELL / 2 - 3)
        -- Stem
        lurek.render.setColor(0.2, 0.8, 0.2)
        rect("fill", cx - 1, f[2] * CELL + HUD_H + 2, 3, 5)
    end

    -- Snake body: gradient coloring (darker tail → brighter head)
    for i, seg in ipairs(snake) do
        local t  = i / #snake
        local sx = seg[1] * CELL
        local sy = seg[2] * CELL + HUD_H

        if i == #snake then
            -- Head — brightest green
            lurek.render.setColor(0.4, 1.0, 0.4)
            rect("fill", sx + 1, sy + 1, CELL - 2, CELL - 2)

            -- Eyes: two black dots that follow direction
            lurek.render.setColor(0, 0, 0)
            local ex, ey
            if dir[1] == 1 then         -- right
                ex = sx + CELL - 5;  ey = sy + CELL / 2 - 3
            elseif dir[1] == -1 then    -- left
                ex = sx + 3;         ey = sy + CELL / 2 - 3
            elseif dir[2] == 1 then     -- down
                ex = sx + CELL / 2 - 3;  ey = sy + CELL - 5
            else                        -- up
                ex = sx + CELL / 2 - 3;  ey = sy + 3
            end
            circ("fill", ex, ey, 2)
            -- Second eye (offset perpendicular to direction)
            if dir[1] ~= 0 then
                circ("fill", ex, ey + 6, 2)
            else
                circ("fill", ex + 6, ey, 2)
            end
        else
            -- Body segment — gradient
            local gr = 0.3 + t * 0.5
            local gg = 0.7 + t * 0.3
            local gb = 0.3 + t * 0.2
            lurek.render.setColor(gr, gg, gb)
            rect("fill", sx + 2, sy + 2, CELL - 4, CELL - 4)
        end
    end

    -- Particles (food burst) — drawn in world space
    food_particles:render()

    cam:reset()
end

-- ── lurek.render_ui — HUD / overlays ──────────────────────────────────────
function lurek.draw_ui()
end
