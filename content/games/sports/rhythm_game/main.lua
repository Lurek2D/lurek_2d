-- Rhythm Game — Lurek2D
-- Category: sports
-- A 4-lane rhythm game with scrolling notes, timing windows, combos, and hold notes.

-- Constants
local W, H = 800, 600
local LANE_W = 150
local LANE_GAP = 40
local LANE_COUNT = 4
local TOTAL_LANE_W = LANE_COUNT * LANE_W + (LANE_COUNT - 1) * LANE_GAP
local LANE_START_X = (W - TOTAL_LANE_W) / 2
local HIT_ZONE_Y = 520
local HIT_ZONE_H = 8
local NOTE_W = 20
local NOTE_H = 40
local PERFECT_WINDOW = 2   -- pixels (±30ms at 60fps ≈ ±2px)
local GOOD_WINDOW = 4      -- pixels (±60ms)
local PERFECT_PTS = 300
local GOOD_PTS = 100
local HOLD_PTS_PER_FRAME = 10
local LIFE_MAX = 100
local MISS_PENALTY = 10
local PERFECT_HEAL = 2

-- States
local STATE_TITLE = 1
local STATE_SONG_SELECT = 2
local STATE_PLAYING = 3
local STATE_RESULTS = 4
local current_state = STATE_TITLE

-- Lane colors
local LANE_COLORS = {
    { 0.9, 0.2, 0.2 },  -- red
    { 0.2, 0.4, 0.9 },  -- blue
    { 0.2, 0.8, 0.3 },  -- green
    { 0.9, 0.8, 0.2 },  -- yellow
}

-- Lane key names (mapped via lurek.input.bind)
local LANE_KEYS = { "lane1", "lane2", "lane3", "lane4" }

-- ---------------------------------------------------------------------------
-- Song chart builder helpers
-- ---------------------------------------------------------------------------
local function gen_easy_chart()
    local chart = {}
    local t = 1.0
    for i = 1, 60 do
        chart[#chart + 1] = { lane = ((i - 1) % 4) + 1, time = t, hold = (i % 12 == 0) and 0.5 or nil }
        t = t + 0.5
    end
    return chart
end

local function gen_medium_chart()
    local chart = {}
    local t = 0.8
    local patterns = { 1, 3, 2, 4, 1, 2, 3, 4, 2, 1 }
    for i = 1, 100 do
        local lane = patterns[((i - 1) % #patterns) + 1]
        chart[#chart + 1] = { lane = lane, time = t, hold = (i % 8 == 0) and 0.4 or nil }
        t = t + 0.35
    end
    return chart
end

local function gen_hard_chart()
    local chart = {}
    local t = 0.5
    for i = 1, 150 do
        local lane = ((i * 3 + i % 7) % 4) + 1
        chart[#chart + 1] = { lane = lane, time = t, hold = (i % 6 == 0) and 0.35 or nil }
        t = t + 0.22
    end
    return chart
end

local SONGS = {
    { name = "Easy Beat",     speed = 200, chart_fn = gen_easy_chart },
    { name = "Medium Groove", speed = 300, chart_fn = gen_medium_chart },
    { name = "Hard Rush",     speed = 400, chart_fn = gen_hard_chart },
}

-- ---------------------------------------------------------------------------
-- Game state
-- ---------------------------------------------------------------------------
local camera = nil  ---@type LCamera
local title_timer = 1
local selected_song = 1
local song_speed = 200
local notes = {}          -- active notes: { lane, y, hold_len, hold_rem, hit, held }
local next_note_idx = 1   -- index into current chart
local chart = {}
local song_time = 0
local score = 0
local display_score = 0
local _score_tbl   = { val = 0 }
local combo = 0
local max_combo = 0
local life = LIFE_MAX
local display_life = LIFE_MAX
local _life_tbl    = { val = LIFE_MAX }
local perfects = 0
local goods = 0
local misses = 0
local total_notes_in_song = 0
local lane_glow = { 0, 0, 0, 0 }    -- glow alpha per lane
local hit_flash = { 0, 0, 0, 0 }    -- flash timer per lane
local bg_pulse = 0
local result_grade = "F"

-- Particles
---@type LParticleSystem
local hit_particles = nil
---@type LParticleSystem
local combo_particles = nil

-- Tweens
local score_tween = nil  ---@type any  -- kept for nil-guard; tweens driven via _score_tbl
local life_tween  = nil  ---@type any  -- kept for nil-guard; tweens driven via _life_tbl
local hit_zone_pulse = 0

-- Lane press state (for hold notes)
local lane_held = { false, false, false, false }
local lane_just_pressed = { false, false, false, false }

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------
local function clamp(v, lo, hi) return v < lo and lo or (v > hi and hi or v) end

local function get_multiplier()
    if combo >= 50 then return 4
    elseif combo >= 25 then return 3
    elseif combo >= 10 then return 2
    else return 1 end
end

local function lane_center_x(lane)
    return LANE_START_X + (lane - 1) * (LANE_W + LANE_GAP) + LANE_W / 2
end

local function calc_grade()
    local total = perfects + goods + misses
    if total == 0 then return "F" end
    local pct = (perfects * PERFECT_PTS + goods * GOOD_PTS) / (total * PERFECT_PTS) * 100
    if pct > 95 then return "S"
    elseif pct > 85 then return "A"
    elseif pct > 75 then return "B"
    elseif pct > 60 then return "C"
    else return "F" end
end

-- ---------------------------------------------------------------------------
-- Start a song
-- ---------------------------------------------------------------------------
local function start_song(idx)
    local song = SONGS[idx]
    song_speed = song.speed
    chart = song.chart_fn()
    total_notes_in_song = #chart
    notes = {}
    next_note_idx = 1
    song_time = 0
    score = 0
    display_score = 0
    _score_tbl.val = 0
    combo = 0
    max_combo = 0
    life = LIFE_MAX
    display_life = LIFE_MAX
    _life_tbl.val = LIFE_MAX
    perfects = 0
    goods = 0
    misses = 0
    lane_glow = { 0, 0, 0, 0 }
    hit_flash = { 0, 0, 0, 0 }
    bg_pulse = 0
    lane_held = { false, false, false, false }
    current_state = STATE_PLAYING
end

-- ---------------------------------------------------------------------------
-- Process a hit on a lane
-- ---------------------------------------------------------------------------
local function process_hit(lane)
    local best_note = nil
    local best_dist = 999999
    for i, n in ipairs(notes) do
        if n.lane == lane and not n.hit then
            local dist = math.abs(n.y - HIT_ZONE_Y)
            if dist < best_dist then
                best_dist = dist
                best_note = n
            end
        end
    end

    if best_note and best_dist <= GOOD_WINDOW * (song_speed / 60) then
        local mult = get_multiplier()
        if best_dist <= PERFECT_WINDOW * (song_speed / 60) then
            -- Perfect
            score = score + PERFECT_PTS * mult
            perfects = perfects + 1
            combo = combo + 1
            life = clamp(life + PERFECT_HEAL, 0, LIFE_MAX)
            hit_flash[lane] = 0.4
            if hit_particles then
                hit_particles:moveTo(lane_center_x(lane), HIT_ZONE_Y)
                hit_particles:emit(20)
            end
        else
            -- Good
            score = score + GOOD_PTS * mult
            goods = goods + 1
            combo = combo + 1
            hit_flash[lane] = 0.25
        end
        if best_note.hold_rem and best_note.hold_rem > 0 then
            best_note.held = true
        else
            best_note.hit = true
        end
        if combo > max_combo then max_combo = combo end
        lane_glow[lane] = 1.0

        -- Combo milestone particles
        if combo > 0 and combo % 10 == 0 and combo_particles then
            combo_particles:setPosition(W / 2, H / 2)
            combo_particles:emit(40)
        end

        -- Tweens
        if lurek.tween then
            score_tween = lurek.tween.to(_score_tbl, { val = score }, 0.3, "outQuad")
            life_tween  = lurek.tween.to(_life_tbl,  { val = life  }, 0.3, "outQuad")
        end
        hit_zone_pulse = 1.0
    else
        -- Miss (pressed but no note nearby)
        misses = misses + 1
        combo = 0
        life = clamp(life - MISS_PENALTY, 0, LIFE_MAX)
        if lurek.tween then
            life_tween = lurek.tween.to(_life_tbl, { val = life }, 0.3, "outQuad")
        end
    end
end

-- ---------------------------------------------------------------------------
-- Engine callbacks
-- ---------------------------------------------------------------------------

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
    lurek.window.setTitle("Rhythm Game — Lurek2D")
    lurek.render.setBackgroundColor(0.05, 0.02, 0.08)

    camera = lurek.camera.new()
    camera:setPosition(0, 0)

    -- Input bindings
    lurek.input.bind("lane1", { "d", "gamepad:0:2" })
    lurek.input.bind("lane2", { "f", "gamepad:0:3" })
    lurek.input.bind("lane3", { "j", "gamepad:0:0" })
    lurek.input.bind("lane4", { "k", "gamepad:0:1" })
    lurek.input.bind("quit", { "escape", "gamepad:0:8" })
    lurek.input.bind("confirm", { "return", "gamepad:0:9" })
    lurek.input.bind("nav_up", { "up", "gamepad:0:10" })
    lurek.input.bind("nav_down", { "down", "gamepad:0:11" })

    -- Particles: hit burst
    if lurek.particle then
        hit_particles = lurek.particle.newSystem({maxParticles=500})
        hit_particles:setColors({ 1, 0.85, 0.2, 1 }, { 1, 0.5, 0.1, 0 })
        hit_particles:setSpeed(80, 200)
        hit_particles:setParticleLifetime(0.3, 0.6)
        hit_particles:setSizes(4, 1)
        hit_particles:setSpread(math.pi * 2)

        combo_particles = lurek.particle.newSystem({maxParticles=500})
        combo_particles:setColors({ 1, 1, 1, 1 }, { 0.5, 0.8, 1, 0 })
        combo_particles:setSpeed(100, 300)
        combo_particles:setParticleLifetime(0.5, 1.0)
        combo_particles:setSizes(6, 2)
        combo_particles:setSpread(math.pi * 2)
    end
    
    local ui_root = lurek.ui.loadLayoutFile("content/games/sports/rhythm_game/ui.toml")
    app_ui = {}
    app_ui.title_screen = ui_root:findById("title_screen")
    app_ui.title_feel = ui_root:findById("title_feel")
    app_ui.song_select_screen = ui_root:findById("song_select_screen")
    app_ui.results_screen = ui_root:findById("results_screen")
    app_ui.hud = ui_root:findById("hud")
    
    app_ui.song_labels = {
        ui_root:findById("song_1"),
        ui_root:findById("song_2"),
        ui_root:findById("song_3")
    }
    app_ui.song_stats = {
        ui_root:findById("song_1_stats"),
        ui_root:findById("song_2_stats"),
        ui_root:findById("song_3_stats")
    }
    
    app_ui.grade_label = ui_root:findById("grade_label")
    app_ui.score_result_label = ui_root:findById("score_result_label")
    app_ui.max_combo_label = ui_root:findById("max_combo_label")
    app_ui.hits_label = ui_root:findById("hits_label")
    app_ui.best_mult_label = ui_root:findById("best_mult_label")
    
    app_ui.score_label = ui_root:findById("score_label")
    app_ui.combo_label = ui_root:findById("combo_label")
    app_ui.combo_mult_label = ui_root:findById("combo_mult_label")
    app_ui.life_fill = ui_root:findById("life_fill")
    app_ui.progress_fill = ui_root:findById("progress_fill")
    app_ui.fps_label = ui_root:findById("fps_label")
    
    app_ui.press_start = ui_root:findById("press_start")
    app_ui.press_select = ui_root:findById("press_select")
    app_ui.press_results = ui_root:findById("press_results")
    
    local function handle_action_click()
        if current_state == STATE_TITLE then
            current_state = STATE_SONG_SELECT
        elseif current_state == STATE_SONG_SELECT then
            start_song(selected_song)
        elseif current_state == STATE_RESULTS then
            current_state = STATE_SONG_SELECT
        end
    end
    
    if app_ui.press_start then app_ui.press_start:setOnClick(handle_action_click) end
    if app_ui.press_select then app_ui.press_select:setOnClick(handle_action_click) end
    if app_ui.press_results then app_ui.press_results:setOnClick(handle_action_click) end

    start_song(selected_song)
end

local function _ready_setup()
    lurek.window.setTitle("Rhythm Game — Lurek2D")
end

function lurek.process(dt)
    if lurek.automation then lurek.automation.update(dt) end
    local fps = lurek.timer.getFPS()
    title_timer = title_timer + dt

    -- Quit
    if lurek.input.wasActionPressed("quit") then
        if current_state == STATE_PLAYING then
            current_state = STATE_RESULTS
            result_grade = calc_grade()
        elseif current_state == STATE_SONG_SELECT then
            current_state = STATE_TITLE
        elseif current_state == STATE_RESULTS then
            current_state = STATE_SONG_SELECT
        else
            lurek.event.push("quit")
        end
        return
    end

    -- -----------------------------------------------------------------------
    -- TITLE
    -- -----------------------------------------------------------------------
    if current_state == STATE_TITLE then
        if lurek.input.wasActionPressed("confirm") then
            current_state = STATE_SONG_SELECT
        end
    end

    -- -----------------------------------------------------------------------
    -- SONG SELECT
    -- -----------------------------------------------------------------------
    if current_state == STATE_SONG_SELECT then
        if lurek.input.wasActionPressed("nav_up") then
            selected_song = selected_song - 1
            if selected_song < 1 then selected_song = #SONGS end
        end
        if lurek.input.wasActionPressed("nav_down") then
            selected_song = selected_song + 1
            if selected_song > #SONGS then selected_song = 1 end
        end
        if lurek.input.wasActionPressed("confirm") then
            start_song(selected_song)
        end
    end

    -- -----------------------------------------------------------------------
    -- RESULTS
    -- -----------------------------------------------------------------------
    if current_state == STATE_RESULTS then
        if lurek.input.wasActionPressed("confirm") then
            current_state = STATE_SONG_SELECT
        end
    end

    -- UI Sync
    app_ui.title_screen.visible = (current_state == STATE_TITLE)
    app_ui.song_select_screen.visible = (current_state == STATE_SONG_SELECT)
    app_ui.results_screen.visible = (current_state == STATE_RESULTS)
    app_ui.hud.visible = (current_state == STATE_PLAYING)
    
    if current_state == STATE_TITLE then
        local alpha = clamp(math.sin(title_timer * 1.5) * 0.3 + 0.7, 0.4, 1)
        app_ui.title_feel.color = {0.7, 0.5, 0.9, alpha}
    elseif current_state == STATE_SONG_SELECT then
        for i, song in ipairs(SONGS) do
            local sel = (i == selected_song)
            local r, g, b = 0.5, 0.5, 0.5
            if sel then r, g, b = 1, 0.85, 0.2 end
            local arrow = sel and "> " or "  "
            app_ui.song_labels[i].text = arrow .. song.name
            app_ui.song_labels[i].color = {r, g, b, 1}
            app_ui.song_stats[i].text = string.format("  %d notes  |  %dpx/s", #song.chart_fn(), song.speed)
        end
    elseif current_state == STATE_RESULTS then
        local grade_colors = {
            S = { 1, 0.85, 0.2 }, A = { 0.3, 0.9, 0.3 }, B = { 0.3, 0.6, 1 },
            C = { 0.7, 0.5, 0.2 }, F = { 0.8, 0.2, 0.2 },
        }
        local gc = grade_colors[result_grade] or { 1, 1, 1 }
        app_ui.grade_label.text = result_grade
        app_ui.grade_label.color = {gc[1], gc[2], gc[3], 1}
        
        app_ui.score_result_label.text = string.format("Score: %d", score)
        app_ui.max_combo_label.text = string.format("Max Combo: %d", max_combo)
        app_ui.hits_label.text = string.format("Perfect: %d  Good: %d  Miss: %d", perfects, goods, misses)
        
        local mult_text = string.format("Best Multiplier: %dx", (max_combo >= 50 and 4) or (max_combo >= 25 and 3) or (max_combo >= 10 and 2) or 1)
        app_ui.best_mult_label.text = mult_text
    elseif current_state == STATE_PLAYING then
        app_ui.score_label.text = string.format("SCORE: %d", math.floor(display_score))
        
        if combo > 0 then
            local mult = get_multiplier()
            local combo_alpha = clamp(0.6 + combo * 0.01, 0.6, 1)
            local cr, cg, cb = 1, 1, 1
            if mult >= 4 then cr, cg, cb = 1, 0.85, 0.2
            elseif mult >= 3 then cr, cg, cb = 0.9, 0.5, 1
            elseif mult >= 2 then cr, cg, cb = 0.3, 0.9, 1 end
            
            app_ui.combo_label.visible = true
            app_ui.combo_label.text = string.format("%d COMBO", combo)
            app_ui.combo_label.color = {cr, cg, cb, combo_alpha}
            
            if mult > 1 then
                app_ui.combo_mult_label.visible = true
                app_ui.combo_mult_label.text = string.format("%dx", mult)
                app_ui.combo_mult_label.color = {cr, cg, cb, 0.8}
            else
                app_ui.combo_mult_label.visible = false
            end
        else
            app_ui.combo_label.visible = false
            app_ui.combo_mult_label.visible = false
        end
        
        local life_pct = clamp(display_life / LIFE_MAX, 0, 1)
        local lr, lg, lb = 0.2, 0.8, 0.3
        if life_pct < 0.3 then lr, lg, lb = 0.9, 0.2, 0.2
        elseif life_pct < 0.6 then lr, lg, lb = 0.9, 0.7, 0.2 end
        app_ui.life_fill.width = 200 * life_pct
        app_ui.life_fill.bg_color = {lr, lg, lb, 0.9}
        
        local progress = 0
        if total_notes_in_song > 0 then
            progress = clamp((perfects + goods + misses) / total_notes_in_song, 0, 1)
        end
        app_ui.progress_fill.width = 780 * progress
        app_ui.fps_label.text = string.format("FPS: %d", fps)
    end

    if current_state ~= STATE_PLAYING then return end

    -- -----------------------------------------------------------------------
    -- PLAYING
    -- -----------------------------------------------------------------------
    song_time = song_time + dt

    -- Update lane input state
    for i = 1, LANE_COUNT do
        local was_held = lane_held[i]
        lane_held[i] = lurek.input.isActionDown("lane" .. i)
        lane_just_pressed[i] = lane_held[i] and not was_held
    end

    -- Spawn notes from chart
    while next_note_idx <= #chart do
        local cn = chart[next_note_idx]
        if cn.time <= song_time + (HIT_ZONE_Y / song_speed) then
            local hold_len = cn.hold and (cn.hold * song_speed) or nil
            notes[#notes + 1] = {
                lane = cn.lane,
                y = -NOTE_H,
                hold_len = hold_len,
                hold_rem = hold_len,
                hit = false,
                held = false,
            }
            next_note_idx = next_note_idx + 1
        else
            break
        end
    end

    -- Move notes downward
    for i = #notes, 1, -1 do
        local n = notes[i]
        if not n.hit then
            n.y = n.y + song_speed * dt
        end

        -- Hold note: if being held, consume tail
        if n.held and n.hold_rem and n.hold_rem > 0 then
            if lane_held[n.lane] then
                n.hold_rem = n.hold_rem - song_speed * dt
                score = score + HOLD_PTS_PER_FRAME * get_multiplier()
                if n.hold_rem <= 0 then
                    n.hit = true
                    n.hold_rem = 0
                end
            else
                -- Released early: miss
                n.hit = true
                n.held = false
                misses = misses + 1
                combo = 0
                life = clamp(life - MISS_PENALTY / 2, 0, LIFE_MAX)
            end
        end

        -- Passed hit zone without being hit → miss
        if not n.hit and not n.held and n.y > HIT_ZONE_Y + GOOD_WINDOW * (song_speed / 60) + NOTE_H then
            n.hit = true
            misses = misses + 1
            combo = 0
            life = clamp(life - MISS_PENALTY, 0, LIFE_MAX)
            if lurek.tween then
                life_tween = lurek.tween.to(_life_tbl, { val = life }, 0.3, "outQuad")
            end
        end

        -- Remove notes well below screen
        if n.hit and n.y > H + 100 then
            table.remove(notes, i)
        end
    end

    -- Process key presses
    for i = 1, LANE_COUNT do
        if lane_just_pressed[i] then
            process_hit(i)
        end
    end

    -- Decay visual effects
    for i = 1, LANE_COUNT do
        lane_glow[i] = lane_glow[i] * (1 - 5 * dt)
        hit_flash[i] = math.max(0, hit_flash[i] - dt)
    end
    hit_zone_pulse = hit_zone_pulse * (1 - 4 * dt)
    bg_pulse = bg_pulse * (1 - 3 * dt)

    -- Pulse background with note hits
    if combo > 0 then
        bg_pulse = clamp(bg_pulse + dt * 0.5, 0, 0.3)
    end

    -- Update tweens (engine-driven; read directly from target tables)
    display_score = _score_tbl.val
    display_life  = _life_tbl.val

    -- Update particles
    if hit_particles then hit_particles:update(dt) end
    if combo_particles then combo_particles:update(dt) end

    -- Life check
    if life <= 0 then
        current_state = STATE_RESULTS
        result_grade = calc_grade()
    end

    -- Song end check
    if next_note_idx > #chart and #notes == 0 then
        current_state = STATE_RESULTS
        result_grade = calc_grade()
    end
end

-- ---------------------------------------------------------------------------
-- Render: lanes, notes, effects
-- ---------------------------------------------------------------------------
function lurek.draw()
    if current_state == STATE_TITLE then
        -- Pulsing background
        local pulse = math.sin(title_timer * 2) * 0.05 + 0.1
        lurek.render.setBackgroundColor(0.05 + pulse, 0.02, 0.08 + pulse * 0.5)
        return
    end

    if current_state == STATE_SONG_SELECT then
        return
    end

    if current_state == STATE_RESULTS then
        return  -- results drawn in render_ui
    end

    -- PLAYING state
    -- Pulsing background
    local bgr = 0.05 + bg_pulse * 0.3
    local bgb = 0.08 + bg_pulse * 0.2
    lurek.render.setBackgroundColor(bgr, 0.02, bgb)

    -- Draw lane backgrounds
    for i = 1, LANE_COUNT do
        local lx = LANE_START_X + (i - 1) * (LANE_W + LANE_GAP)
        local c = LANE_COLORS[i]
        -- Lane background (dark)
        rect("fill", lx, 0, LANE_W, H, c[1] * 0.1, c[2] * 0.1, c[3] * 0.1, 0.5)
        -- Lane glow
        if lane_glow[i] > 0.01 then
            rect("fill", lx, 0, LANE_W, H, c[1], c[2], c[3], lane_glow[i] * 0.15)
        end
    end

    -- Draw hit zone
    local hz_alpha = 0.6 + hit_zone_pulse * 0.4
    rect("fill", LANE_START_X - 10, HIT_ZONE_Y - HIT_ZONE_H / 2, TOTAL_LANE_W + 20, HIT_ZONE_H, 1, 1, 1, hz_alpha * 0.3)
    -- Per-lane hit zone highlights
    for i = 1, LANE_COUNT do
        local lx = LANE_START_X + (i - 1) * (LANE_W + LANE_GAP)
        local c = LANE_COLORS[i]
        if lane_held[i] then
            rect("fill", lx, HIT_ZONE_Y - 20, LANE_W, 40, c[1], c[2], c[3], 0.4)
        end
        if hit_flash[i] > 0 then
            rect("fill", lx, HIT_ZONE_Y - 30, LANE_W, 60, 1, 1, 1, hit_flash[i])
        end
    end

    -- Draw notes
    for _, n in ipairs(notes) do
        if not n.hit or n.held then
            local c = LANE_COLORS[n.lane]
            local nx = lane_center_x(n.lane) - NOTE_W / 2
            -- Hold tail
            if n.hold_rem and n.hold_rem > 0 then
                local tail_h = n.hold_rem
                rect("fill", nx + 4, n.y - tail_h, NOTE_W - 8, tail_h, c[1] * 0.7, c[2] * 0.7, c[3] * 0.7, 0.6)
            end
            -- Note head
            local bright = 1.0
            if n.held then bright = 1.2 end
            rect("fill", nx, n.y - NOTE_H, NOTE_W, NOTE_H, c[1] * bright, c[2] * bright, c[3] * bright, 0.95)
            -- Note border
            rect("line", nx, n.y - NOTE_H, NOTE_W, NOTE_H, 1, 1, 1, 0.3)
        end
    end

    -- Particle draw is intentionally disabled here because this demo's
    -- particle handles are not accepted by lurek.render.draw on all builds.
end

-- ---------------------------------------------------------------------------
-- Render UI: score, combo, life, grade
-- ---------------------------------------------------------------------------
function lurek.draw_ui()
end
