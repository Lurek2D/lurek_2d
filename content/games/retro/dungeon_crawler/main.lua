------------------------------------------------------------------------
-- Dungeon Crawler — Lurek2D
-- Category: retro
-- First-person grid-based dungeon crawler with raycasting pseudo-3D,
-- collectible orbs, torches, minimap, compass, and weather overlays.
------------------------------------------------------------------------

-- Action input bindings:
-- forward(w), back(s), turn_left(a), turn_right(d)
-- weather1(f1), weather2(f2), weather3(f3), quit(escape)

local STATE = { PLAYING = 1, COMPLETE = 2 }

------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------
local VP_X, VP_Y = 10, 60
local VP_W, VP_H = 500, 480
local NUM_RAYS   = 200
local STRIP_W    = VP_W / NUM_RAYS
local FOV        = math.pi / 2
local HALF_FOV   = FOV / 2
local MAP_W, MAP_H = 12, 12
local MOVE_SPEED = 9.0

-- Wall colors: stone(1), brick(2), mossy(3), magic(4), wood(5), steel(6)
local WALL_COLORS = {
    { 0.55, 0.55, 0.55 },
    { 0.65, 0.30, 0.18 },
    { 0.28, 0.52, 0.30 },
    { 0.55, 0.20, 0.65 },
    { 0.62, 0.45, 0.30 },
    { 0.40, 0.50, 0.60 },
}

-- Direction tables (indexed dir+1: 1=N, 2=E, 3=S, 4=W)
local DIR_DX    = {  0,  1, 0, -1 }
local DIR_DY    = { -1,  0, 1,  0 }
local DIR_ANGLE = { -math.pi / 2, 0, math.pi / 2, math.pi }
local DIR_NAMES = { "N", "E", "S", "W" }

------------------------------------------------------------------------
-- Dungeon map 12x12 — 0=floor, 1=stone, 2=brick, 3=mossy, 4=magic
------------------------------------------------------------------------
local dungeon = {
    { 1,1,1,1,1,1,1,1,1,1,1,1 },
    { 1,0,0,0,2,0,0,0,0,0,0,1 },
    { 1,0,3,0,2,0,4,4,0,3,0,1 },
    { 1,0,3,0,0,0,0,4,0,3,0,1 },
    { 1,0,0,0,5,5,0,0,0,0,0,1 },
    { 1,2,2,0,0,1,0,3,3,0,2,1 },
    { 1,0,0,0,0,0,0,0,6,0,0,1 },
    { 1,0,4,0,1,0,1,0,0,0,0,1 },
    { 1,0,4,0,1,0,1,0,4,6,0,1 },
    { 1,0,0,0,0,0,0,0,0,4,0,1 },
    { 1,0,2,2,0,0,0,2,0,5,0,1 },
    { 1,1,1,1,1,1,1,1,1,1,1,1 },
}

------------------------------------------------------------------------
-- Torches and collectible orbs
------------------------------------------------------------------------
local torches = {
    { x = 2, y = 2 },  { x = 5, y = 2 },  { x = 9, y = 2 },
    { x = 2, y = 6 },  { x = 6, y = 6 },  { x = 10, y = 6 },
    { x = 2, y = 10 }, { x = 6, y = 10 }, { x = 10, y = 10 },
}

local orbs = {
    { x = 5,  y = 3,  collected = false },
    { x = 8,  y = 2,  collected = false },
    { x = 3,  y = 5,  collected = false },
    { x = 10, y = 5,  collected = false },
    { x = 4,  y = 7,  collected = false },
    { x = 8,  y = 9,  collected = false },
    { x = 3,  y = 10, collected = false },
    { x = 10, y = 10, collected = false },
}

------------------------------------------------------------------------
-- Player state
------------------------------------------------------------------------
local player = {
    gx = 2, gy = 2,
    vx = 1.5, vy = 1.5,
    dir = 2,
    va  = 0,
    moving  = false,
    turning = false,
}

------------------------------------------------------------------------
-- Game state
------------------------------------------------------------------------
local state       = STATE.PLAYING
local score       = 0
local total_orbs  = #orbs
local explored    = {}
local weather     = "clear"
local torch_time  = 0
local cam         = nil
local raycaster   = nil
local view_tex    = nil
local view_dirty  = true
local last_vx, last_vy, last_va = 0, 0, 0
local PANEL_X, PANEL_Y = 530, 30

for y = 1, MAP_H do explored[y] = {} end

------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------
local function wrap_angle(a)
    while a >  math.pi do a = a - 2 * math.pi end
    while a < -math.pi do a = a + 2 * math.pi end
    return a
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function reveal_around(gx, gy)
    for dy = -1, 1 do
        for dx = -1, 1 do
            local nx, ny = gx + dx, gy + dy
            if nx >= 1 and nx <= MAP_W and ny >= 1 and ny <= MAP_H then
                explored[ny][nx] = true
            end
        end
    end
end

local function try_move(step)
    local di = player.dir + 1
    local nx = player.gx + DIR_DX[di] * step
    local ny = player.gy + DIR_DY[di] * step
    if nx >= 1 and nx <= MAP_W and ny >= 1 and ny <= MAP_H
       and dungeon[ny][nx] == 0 then
        player.gx = nx
        player.gy = ny
        player.moving = true
        reveal_around(nx, ny)
    end
end

local function try_turn(dir_step)
    player.dir = (player.dir + dir_step) % 4
    player.turning = true
end

local function refresh_view_texture()
    if not raycaster or not raycaster.drawView or not view_dirty then
        return
    end
    local view_img = raycaster:drawView(player.vx, player.vy, player.va, FOV, VP_W, VP_H, 16)
    if view_tex and view_tex.release then
        view_tex:release()
    end
    view_tex = lurek.render.newImage(view_img)
    view_dirty = false
end

------------------------------------------------------------------------
-- lurek.init
------------------------------------------------------------------------

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
    lurek.window.setTitle("Dungeon Crawler — Lurek2D")
    lurek.render.setBackgroundColor(0.02, 0.02, 0.05)

    lurek.input.bind("forward",    { "w" })
    lurek.input.bind("back",       { "s" })
    lurek.input.bind("turn_left",  { "a" })
    lurek.input.bind("turn_right", { "d" })
    lurek.input.bind("weather1",   { "f1" })
    lurek.input.bind("weather2",   { "f2" })
    lurek.input.bind("weather3",   { "f3" })
    lurek.input.bind("quit",       { "escape" })

    cam = lurek.camera.new(800, 600)
    player.vx = player.gx - 0.5
    player.vy = player.gy - 0.5
    player.va = DIR_ANGLE[player.dir + 1]
    reveal_around(player.gx, player.gy)

    if lurek.raycaster and lurek.raycaster.new then
        raycaster = lurek.raycaster.new(MAP_W, MAP_H)
        for y = 1, MAP_H do
            for x = 1, MAP_W do
                raycaster:setCell(x - 1, y - 1, dungeon[y][x])
            end
        end
    end
end

local function _ready_setup() end

------------------------------------------------------------------------
-- lurek.process
------------------------------------------------------------------------
function lurek.process(dt)
    if lurek.input.wasActionPressed("quit") then
        lurek.event.quit()
        return
    end

    -- COMPLETE state
    if state == STATE.COMPLETE then return end

    -- === PLAYING ===
    torch_time = torch_time + dt

    -- Weather switching
    if lurek.input.wasActionPressed("weather1") then weather = "clear" end
    if lurek.input.wasActionPressed("weather2") then weather = "rain"  end
    if lurek.input.wasActionPressed("weather3") then weather = "snow"  end

    -- Grid movement (blocked during animation)
    if not player.moving and not player.turning then
        local forward_down = lurek.input.wasActionPressed("forward") or lurek.input.isActionDown("forward")
        local back_down = lurek.input.wasActionPressed("back") or lurek.input.isActionDown("back")
        local left_down = lurek.input.wasActionPressed("turn_left") or lurek.input.isActionDown("turn_left")
        local right_down = lurek.input.wasActionPressed("turn_right") or lurek.input.isActionDown("turn_right")

        if forward_down then
            try_move(1)
        elseif back_down then
            try_move(-1)
        elseif left_down then
            try_turn(-1)
        elseif right_down then
            try_turn(1)
        end
    end

    -- Smooth lerp toward target
    local tgt_x = player.gx - 0.5
    local tgt_y = player.gy - 0.5
    local tgt_a = DIR_ANGLE[player.dir + 1]
    local da    = wrap_angle(tgt_a - player.va)
    local spd   = math.min(1, MOVE_SPEED * dt)

    player.vx = lerp(player.vx, tgt_x, spd)
    player.vy = lerp(player.vy, tgt_y, spd)
    player.va = player.va + da * spd

    if math.abs(player.vx - last_vx) > 0.0005
       or math.abs(player.vy - last_vy) > 0.0005
       or math.abs(wrap_angle(player.va - last_va)) > 0.0005 then
        view_dirty = true
        last_vx, last_vy, last_va = player.vx, player.vy, player.va
    end

    if math.abs(player.vx - tgt_x) < 0.01 and math.abs(player.vy - tgt_y) < 0.01 then
        player.vx = tgt_x
        player.vy = tgt_y
        player.moving = false
    end
    if math.abs(wrap_angle(player.va - tgt_a)) < 0.02 then
        player.va = tgt_a
        player.turning = false
    end

    -- Orb collection
    for _, orb in ipairs(orbs) do
        if not orb.collected and orb.x == player.gx and orb.y == player.gy then
            orb.collected = true
            score = score + 100
        end
    end

    -- Check win condition
    local all_collected = true
    for _, orb in ipairs(orbs) do
        if not orb.collected then all_collected = false; break end
    end
    if all_collected then state = STATE.COMPLETE end

    if cam and cam.update then
        cam:update(dt)
    end
end

-- lurek.render — 3D viewport from built-in raycaster module
------------------------------------------------------------------------
function lurek.draw()
    if cam and cam.apply then
        cam:apply()
    end

    lurek.render.setColor(0.05, 0.06, 0.09, 1)
    rect("fill", VP_X, VP_Y, VP_W, VP_H)

    refresh_view_texture()
    if view_tex then
        lurek.render.setColor(1, 1, 1, 1)
        lurek.render.draw(view_tex, VP_X, VP_Y)
    end

    -- Viewport border
    lurek.render.setColor(0.3, 0.3, 0.4, 1)
    rect("line", VP_X, VP_Y, VP_W, VP_H)

    if cam and cam.reset then
        cam:reset()
    end
end

------------------------------------------------------------------------
-- lurek.render_ui — minimap, compass, score, weather, particles
------------------------------------------------------------------------
function lurek.draw_ui()
    -- === COMPLETE SCREEN ===
    if state == STATE.COMPLETE then
        lurek.render.setColor(1, 0.85, 0.2, 1)
        text_("DUNGEON COMPLETE!", 240, 220, 32)
        lurek.render.setColor(0.9, 0.9, 1, 1)
        text_("All orbs collected!   Score: " .. score, 255, 290, 18)
        lurek.render.setColor(0.6, 0.6, 0.7, 1)
        text_("Press ESCAPE to exit", 300, 350, 16)
        return
    end

    -- === RIGHT PANEL ===
    local PX = PANEL_X
    local PY = PANEL_Y

    lurek.render.setColor(0.8, 0.7, 1, 1)
    text_("DUNGEON CRAWLER", PX, PY, 16)

    -- Score
    lurek.render.setColor(1, 0.85, 0.2, 1)
    text_("Score: " .. score, PX, PY + 28, 14)

    -- Orbs remaining
    local remaining = 0
    for _, o in ipairs(orbs) do if not o.collected then remaining = remaining + 1 end end
    lurek.render.setColor(0.5, 0.9, 1, 1)
    text_("Orbs: " .. (total_orbs - remaining) .. "/" .. total_orbs, PX, PY + 48, 14)

    -- Compass
    lurek.render.setColor(0.6, 0.6, 0.7, 1)
    text_("Facing: " .. DIR_NAMES[player.dir + 1], PX, PY + 72, 14)
    local comp_cx = PX + 130
    local comp_cy = PY + 86
    local comp_r  = 18
    lurek.render.setColor(0.2, 0.2, 0.3, 0.8)
    circ("fill", comp_cx, comp_cy, comp_r)
    lurek.render.setColor(0.5, 0.5, 0.6, 1)
    circ("line", comp_cx, comp_cy, comp_r)
    local needle_a = DIR_ANGLE[player.dir + 1]
    local nx = comp_cx + math.cos(needle_a) * (comp_r - 4)
    local ny = comp_cy + math.sin(needle_a) * (comp_r - 4)
    lurek.render.setColor(1, 0.3, 0.3, 1)
    ln(comp_cx, comp_cy, nx, ny)

    -- Weather indicator
    lurek.render.setColor(0.5, 0.5, 0.6, 1)
    text_("Weather: " .. weather, PX, PY + 115, 12)
    text_("F1=Clear  F2=Rain  F3=Snow", PX, PY + 132, 10)

    -- === MINIMAP ===
    local MM_X    = PX + 5
    local MM_Y    = PY + 160
    local MM_CELL = 18

    lurek.render.setColor(0.05, 0.05, 0.1, 0.9)
    rect("fill", MM_X - 2, MM_Y - 2,
        MAP_W * MM_CELL + 4, MAP_H * MM_CELL + 4)

    for y = 1, MAP_H do
        for x = 1, MAP_W do
            local cx = MM_X + (x - 1) * MM_CELL
            local cy = MM_Y + (y - 1) * MM_CELL
            if explored[y] and explored[y][x] then
                if dungeon[y][x] > 0 then
                    local wc = WALL_COLORS[dungeon[y][x]]
                    lurek.render.setColor(wc[1] * 0.6, wc[2] * 0.6, wc[3] * 0.6, 1)
                else
                    lurek.render.setColor(0.15, 0.15, 0.2, 1)
                end
                rect("fill", cx, cy, MM_CELL - 1, MM_CELL - 1)

                -- Orbs on minimap
                for _, o in ipairs(orbs) do
                    if o.x == x and o.y == y and not o.collected then
                        lurek.render.setColor(1, 0.85, 0.2, 0.8)
                        circ("fill", cx + MM_CELL / 2, cy + MM_CELL / 2, 3)
                    end
                end
                -- Torches on minimap
                for _, t in ipairs(torches) do
                    if t.x == x and t.y == y then
                        lurek.render.setColor(1, 0.5, 0.1, 0.6)
                        circ("fill", cx + MM_CELL / 2, cy + MM_CELL / 2, 2)
                    end
                end
            else
                lurek.render.setColor(0.08, 0.08, 0.08, 1)
                rect("fill", cx, cy, MM_CELL - 1, MM_CELL - 1)
            end
        end
    end

    -- Player marker on minimap
    local pmx = MM_X + player.vx * MM_CELL
    local pmy = MM_Y + player.vy * MM_CELL
    lurek.render.setColor(0.2, 1, 0.3, 1)
    circ("fill", pmx, pmy, 4)
    local di = player.dir + 1
    ln(pmx, pmy, pmx + DIR_DX[di] * 8, pmy + DIR_DY[di] * 8)

    -- Minimap border and label
    lurek.render.setColor(0.4, 0.4, 0.5, 1)
    rect("line", MM_X - 2, MM_Y - 2,
        MAP_W * MM_CELL + 4, MAP_H * MM_CELL + 4)
    lurek.render.setColor(0.5, 0.5, 0.6, 1)
    text_("MINIMAP", MM_X + MAP_W * MM_CELL / 2 - 25,
        MM_Y + MAP_H * MM_CELL + 6, 11)

    -- FPS
    lurek.render.setColor(0.4, 0.4, 0.5, 1)
    text_("FPS: " .. lurek.timer.getFPS(), PX, 575, 11)
end
