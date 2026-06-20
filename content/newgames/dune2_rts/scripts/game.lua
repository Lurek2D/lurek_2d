-- ============================================================
-- Dune2-like RTS Demo
-- Category: strategy
-- Engine: Lurek2D
-- Run with: cargo run -- content/newgames/dune2_rts
-- ============================================================

local W, H = 960, 640
local MAP_W, MAP_H = 1800, 1200

local UNIT = "unit"
local BUILDING = "building"

local state = "play"
local cam = { x = 0, y = 0, speed = 240 }
local resources = { spice = 150, water = 80, credits = 100 }
local entities = {}
local selected = {}
local next_id = 1
local wave = 0
local wave_timer = 18.0

local resource_nodes = {
    { x = 320, y = 260, spice = 90, water = 0 },
    { x = 760, y = 420, spice = 120, water = 0 },
    { x = 1220, y = 640, spice = 50, water = 40 },
    { x = 1510, y = 300, spice = 80, water = 0 },
}

local function new_id()
    local id = next_id
    next_id = next_id + 1
    return id
end

local function dist(ax, ay, bx, by)
    local dx, dy = ax - bx, ay - by
    return math.sqrt(dx * dx + dy * dy)
end

local function spawn_unit(x, y, team)
    local e = {
        id = new_id(),
        kind = UNIT,
        team = team,
        x = x,
        y = y,
        tx = x,
        ty = y,
        hp = team == "player" and 28 or 18,
        max_hp = team == "player" and 28 or 18,
        speed = team == "player" and 90 or 65,
        atk = team == "player" and 5 or 4,
        atk_cd = 0,
        state = "idle",
        target = nil,
    }
    entities[#entities + 1] = e
    return e
end

local function spawn_building(x, y, btype)
    local e = {
        id = new_id(),
        kind = BUILDING,
        team = "player",
        btype = btype,
        x = x,
        y = y,
        hp = btype == "base" and 220 or 70,
        max_hp = btype == "base" and 220 or 70,
        train_cd = 0,
    }
    entities[#entities + 1] = e
    return e
end

local function find_entity(id)
    for _, e in ipairs(entities) do
        if e.id == id then
            return e
        end
    end
end

local function find_nearest_enemy(e)
    local best, best_d = nil, 1e9
    for _, other in ipairs(entities) do
        if other.team ~= e.team and other.hp > 0 then
            local d = dist(e.x, e.y, other.x, other.y)
            if d < best_d then
                best = other
                best_d = d
            end
        end
    end
    return best, best_d
end

local function spawn_wave(n)
    for i = 1, n do
        local e = spawn_unit(MAP_W - 120 + math.random(-60, 60), 70 + i * 42, "enemy")
        e.tx = 160
        e.ty = 540
        e.state = "move"
    end
end

local function init_game()
    entities = {}
    selected = {}
    resources = { spice = 150, water = 80, credits = 100 }
    wave = 0
    wave_timer = 18.0
    state = "play"
    cam = { x = 0, y = 0, speed = 240 }

    spawn_building(180, 540, "base")
    spawn_building(310, 500, "refinery")
    spawn_unit(160, 430, "player")
    spawn_unit(230, 430, "player")
end

lurek.input.bind("select", "mouse1")
lurek.input.bind("order", "mouse2")
lurek.input.bind("train", "t")
lurek.input.bind("build", "b")
lurek.input.bind("cam_up", "w")
lurek.input.bind("cam_down", "s")
lurek.input.bind("cam_left", "a")
lurek.input.bind("cam_right", "d")
lurek.input.bind("quit", "escape")

function lurek.init()
    lurek.window.setTitle("Dune2-like RTS Demo")
    lurek.render.setBackgroundColor(0.12, 0.10, 0.05)
    math.randomseed(os.time())
    init_game()
end

function lurek.process(dt)
    if lurek.input.wasActionPressed("quit") then
        lurek.event.quit()
        return
    end

    if state ~= "play" then
        return
    end

    if lurek.input.isActionDown("cam_up") then cam.y = cam.y - cam.speed * dt end
    if lurek.input.isActionDown("cam_down") then cam.y = cam.y + cam.speed * dt end
    if lurek.input.isActionDown("cam_left") then cam.x = cam.x - cam.speed * dt end
    if lurek.input.isActionDown("cam_right") then cam.x = cam.x + cam.speed * dt end
    cam.x = math.max(0, math.min(MAP_W - W, cam.x))
    cam.y = math.max(0, math.min(MAP_H - H, cam.y))

    local mx, my = lurek.input.mouse.getPosition()
    local wx, wy = mx + cam.x, my + cam.y

    if lurek.input.wasActionPressed("select") then
        selected = {}
        for _, e in ipairs(entities) do
            if e.kind == UNIT and e.team == "player" and e.hp > 0 then
                if math.abs(e.x - wx) < 18 and math.abs(e.y - wy) < 18 then
                    selected[#selected + 1] = e.id
                end
            end
        end
    end

    if lurek.input.wasActionPressed("order") then
        for _, id in ipairs(selected) do
            local e = find_entity(id)
            if e and e.hp > 0 then
                e.tx = wx + math.random(-12, 12)
                e.ty = wy + math.random(-12, 12)
                e.state = "move"
            end
        end
    end

    if lurek.input.wasActionPressed("train") then
        for _, e in ipairs(entities) do
            if e.kind == BUILDING and e.btype == "refinery" and e.train_cd <= 0 then
                if resources.spice >= 40 then
                    resources.spice = resources.spice - 40
                    spawn_unit(e.x + 30, e.y - 38, "player")
                    e.train_cd = 4.0
                end
                break
            end
        end
    end

    if lurek.input.wasActionPressed("build") then
        if resources.spice >= 70 then
            resources.spice = resources.spice - 70
            spawn_building(wx, wy, "refinery")
        end
    end

    wave_timer = wave_timer - dt
    if wave_timer <= 0 then
        wave = wave + 1
        wave_timer = 16.0 - math.min(6, wave)
        spawn_wave(2 + wave)
    end

    for _, e in ipairs(entities) do
        if e.kind == BUILDING and e.train_cd and e.train_cd > 0 then
            e.train_cd = e.train_cd - dt
        end
    end

    for _, e in ipairs(entities) do
        if e.hp <= 0 then
            goto continue
        end

        if e.kind == UNIT then
            local enemy, d = find_nearest_enemy(e)
            if enemy and d < 60 then
                e.state = "attack"
                e.atk_cd = e.atk_cd - dt
                if e.atk_cd <= 0 then
                    e.atk_cd = 1.0
                    enemy.hp = enemy.hp - e.atk
                end
            else
                e.state = "move"
                if e.team == "enemy" then
                    local base = nil
                    for _, b in ipairs(entities) do
                        if b.kind == BUILDING and b.team == "player" and b.hp > 0 then
                            base = b
                            break
                        end
                    end
                    if base then
                        e.tx = base.x + math.random(-30, 30)
                        e.ty = base.y + math.random(-30, 30)
                    end
                end
            end

            if e.state == "move" then
                local dx, dy = e.tx - e.x, e.ty - e.y
                local d2 = math.sqrt(dx * dx + dy * dy)
                if d2 > 3 then
                    e.x = e.x + (dx / d2) * e.speed * dt
                    e.y = e.y + (dy / d2) * e.speed * dt
                end
            end
        end

        if e.kind == BUILDING and e.team == "player" and e.btype == "base" and e.hp <= 0 then
            state = "gameover"
        end

        ::continue::
    end

    for _, node in ipairs(resource_nodes) do
        if node.spice > 0 or node.water > 0 then
            for _, e in ipairs(entities) do
                if e.kind == UNIT and e.team == "player" and e.hp > 0 then
                    if dist(e.x, e.y, node.x, node.y) < 58 then
                        if node.spice > 0 then
                            local take = math.min(1.5, node.spice) * dt * 6
                            resources.spice = resources.spice + take
                            node.spice = math.max(0, node.spice - take)
                        end
                        if node.water > 0 then
                            local take = math.min(1.0, node.water) * dt * 4
                            resources.water = resources.water + take
                            node.water = math.max(0, node.water - take)
                        end
                    end
                end
            end
        end
    end

    for i = #entities, 1, -1 do
        if entities[i].hp <= 0 and entities[i].kind == UNIT then
            table.remove(entities, i)
        end
    end

    local enemy_alive = 0
    for _, e in ipairs(entities) do
        if e.team == "enemy" and e.hp > 0 then
            enemy_alive = enemy_alive + 1
        end
    end
    if wave >= 6 and enemy_alive == 0 then
        state = "victory"
    end
end

local function rect(x, y, w, h, color)
    lurek.render.setColor(color[1], color[2], color[3], color[4] or 1)
    lurek.render.rectangle("fill", x, y, w, h)
end

local function circle(x, y, r, color)
    lurek.render.setColor(color[1], color[2], color[3], color[4] or 1)
    lurek.render.circle("fill", x, y, r)
end

local function text(s, x, y, color)
    lurek.render.setColor(color[1], color[2], color[3], color[4] or 1)
    lurek.render.print(s, x, y)
end

function lurek.draw()
    rect(0, 0, W, H, { 0.12, 0.09, 0.04, 1 })

    for _, node in ipairs(resource_nodes) do
        local sx, sy = node.x - cam.x, node.y - cam.y
        if sx > -40 and sx < W + 40 and sy > -40 and sy < H + 40 then
            if node.spice > 0 then
                circle(sx, sy, 18, { 0.95, 0.82, 0.15, 1 })
            end
            if node.water > 0 then
                circle(sx, sy, 10, { 0.35, 0.65, 0.95, 1 })
            end
        end
    end

    for _, e in ipairs(entities) do
        if e.hp <= 0 then
            goto continue
        end
        local sx, sy = e.x - cam.x, e.y - cam.y
        if sx < -40 or sx > W + 40 or sy < -40 or sy > H + 40 then
            goto continue
        end

        if e.kind == BUILDING then
            local c = e.btype == "base" and { 0.25, 0.45, 0.9, 1 } or { 0.55, 0.72, 0.25, 1 }
            rect(sx - 28, sy - 28, 56, 56, c)
        else
            local c = e.team == "player" and { 0.45, 0.8, 1, 1 } or { 0.9, 0.25, 0.15, 1 }
            circle(sx, sy, 10, c)
            rect(sx - 12, sy - 18, 24, 4, { 0.15, 0.10, 0.08, 1 })
            rect(sx - 12, sy - 18, math.floor(24 * e.hp / e.max_hp), 4, { 0.2, 0.9, 0.25, 1 })
        end

        for _, id in ipairs(selected) do
            if id == e.id then
                circle(sx, sy, 16, { 0.35, 0.95, 1.0, 0.35 })
            end
        end

        ::continue::
    end
end

function lurek.draw_ui()
    rect(0, H - 96, W, 96, { 0.08, 0.08, 0.08, 0.92 })
    text("Spice: " .. math.floor(resources.spice), 12, H - 78, { 1, 0.88, 0.18, 1 })
    text("Water: " .. math.floor(resources.water), 140, H - 78, { 0.45, 0.75, 1, 1 })
    text("Credits: " .. math.floor(resources.credits), 270, H - 78, { 0.9, 0.95, 1, 1 })
    text("Wave: " .. wave .. "  Next: " .. math.max(0, math.floor(wave_timer)) .. "s", 420, H - 78, { 0.92, 0.66, 0.42, 1 })
    text("LMB select  RMB move  T train  B build refinery", 12, H - 48, { 0.75, 0.75, 0.75, 1 })

    if state == "gameover" then
        rect(260, 180, 440, 130, { 0, 0, 0, 0.88 })
        text("BASE DESTROYED", 340, 220, { 1, 0.25, 0.25, 1 })
    elseif state == "victory" then
        rect(260, 180, 440, 130, { 0, 0, 0, 0.88 })
        text("DESERT HOLDING SECURED", 320, 220, { 0.95, 0.95, 0.3, 1 })
    end
end
