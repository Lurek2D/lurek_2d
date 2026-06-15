-- Hex Logistics - Lurek2D
-- Strategy prototype converted from a Gemini React canvas game.

local HEX_SIZE = 34
local HEX_WIDTH = math.sqrt(3) * HEX_SIZE
local HEX_HEIGHT = 2 * HEX_SIZE
local MAP_RADIUS = 18
local PLAYER_SPEED = 230
local BUILD_RADIUS = 230
local DRONE_SPEED = 170

local TILE_EMPTY = 0
local TILE_METAL = 1
local TILE_GOLD = 2

local BUILD_HQ = "HQ"
local BUILD_MINE_METAL = "MINE_METAL"
local BUILD_MINE_GOLD = "MINE_GOLD"
local BUILD_GENERATOR = "GENERATOR"
local BUILD_DRONE_FACTORY = "DRONE_FACTORY"
local BUILD_TURRET = "TURRET"

local map = {}
local tiles = {}
local buildings = {}
local drones = {}
local resources = { metal = 10, energy = 10, gold = 0 }
local player = { x = 0, y = 0, vx = 0, vy = 0 }
local camera = { x = 0, y = 0 }
local selected_hex = nil
local message = "Build HQ first. It releases three logistics drones."
local message_timer = 5
local fps = 0

local function key(q, r)
    return tostring(q) .. "," .. tostring(r)
end

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function hex_to_pixel(q, r)
    return HEX_SIZE * math.sqrt(3) * (q + r / 2), HEX_SIZE * 1.5 * r
end

local function hex_round(q, r, s)
    local rq = math.floor(q + 0.5)
    local rr = math.floor(r + 0.5)
    local rs = math.floor(s + 0.5)
    local qd = math.abs(rq - q)
    local rd = math.abs(rr - r)
    local sd = math.abs(rs - s)
    if qd > rd and qd > sd then
        rq = -rr - rs
    elseif rd > sd then
        rr = -rq - rs
    end
    return rq, rr
end

local function pixel_to_hex(x, y)
    local q = (math.sqrt(3) / 3 * x - y / 3) / HEX_SIZE
    local r = (2 / 3 * y) / HEX_SIZE
    return hex_round(q, r, -q - r)
end

local function distance(ax, ay, bx, by)
    return lurek.math.distance(ax, ay, bx, by)
end

local function set_color(c)
    lurek.render.setColor(c[1], c[2], c[3], c[4] or 1)
end

local function draw_text(text, x, y, color)
    if color then set_color(color) end
    lurek.render.print(tostring(text), x, y)
end

local function show_message(text)
    message = text
    message_timer = 3.5
end

local function generate_map()
    map = {}
    tiles = {}
    for q = -MAP_RADIUS, MAP_RADIUS do
        local r1 = math.max(-MAP_RADIUS, -q - MAP_RADIUS)
        local r2 = math.min(MAP_RADIUS, -q + MAP_RADIUS)
        for r = r1, r2 do
            local roll = math.random()
            local tile_type = TILE_EMPTY
            if roll < 0.24 then
                tile_type = TILE_METAL
            elseif roll < 0.34 then
                tile_type = TILE_GOLD
            end
            local tile = { q = q, r = r, type = tile_type }
            map[key(q, r)] = tile
            tiles[#tiles + 1] = tile
        end
    end
    map["0,0"].type = TILE_EMPTY
end

local function hex_points(q, r)
    local cx, cy = hex_to_pixel(q, r)
    local pts = {}
    for i = 0, 5 do
        local angle = math.pi / 3 * (i - 0.5)
        pts[#pts + 1] = cx + HEX_SIZE * math.cos(angle)
        pts[#pts + 1] = cy + HEX_SIZE * math.sin(angle)
    end
    return pts
end

local function draw_hex(q, r, fill, line)
    local pts = hex_points(q, r)
    for i = 1, #pts, 2 do
        pts[i] = pts[i] - camera.x
        pts[i + 1] = pts[i + 1] - camera.y
    end
    set_color(fill)
    lurek.render.polygon("fill", pts[1], pts[2], pts[3], pts[4], pts[5], pts[6], pts[7], pts[8], pts[9], pts[10], pts[11], pts[12])
    set_color(line or {0.20, 0.25, 0.32, 1})
    lurek.render.polygon("line", pts[1], pts[2], pts[3], pts[4], pts[5], pts[6], pts[7], pts[8], pts[9], pts[10], pts[11], pts[12])
end

local function find_building(q, r)
    for _, b in ipairs(buildings) do
        if b.q == q and b.r == r then
            return b
        end
    end
    return nil
end

local function find_hq()
    for _, b in ipairs(buildings) do
        if b.type == BUILD_HQ then
            return b
        end
    end
    return nil
end

local function spawn_drone(q, r)
    local x, y = hex_to_pixel(q, r)
    drones[#drones + 1] = {
        x = x + math.random(-16, 16),
        y = y + math.random(-16, 16),
        state = "IDLE",
        task = nil,
        payload = nil,
        drift = math.random() * 6.28,
    }
end

local function build(type_name)
    local q, r = pixel_to_hex(player.x, player.y)
    local tile = map[key(q, r)]
    if not tile then
        show_message("Out of mapped sector.")
        return
    end
    if find_building(q, r) then
        show_message("Hex already occupied.")
        return
    end

    if type_name == BUILD_HQ then
        if find_hq() then
            show_message("Only one HQ is allowed.")
            return
        end
        buildings[#buildings + 1] = { type = BUILD_HQ, q = q, r = r }
        for _ = 1, 3 do spawn_drone(q, r) end
        show_message("HQ online. Three drones launched.")
    elseif type_name == BUILD_MINE_METAL then
        if tile.type ~= TILE_METAL then
            show_message("Metal mine needs a metal vein.")
            return
        end
        buildings[#buildings + 1] = { type = type_name, q = q, r = r, timer = 0, local_metal = 0, max_metal = 10 }
        show_message("Metal mine built.")
    elseif type_name == BUILD_MINE_GOLD then
        if tile.type ~= TILE_GOLD then
            show_message("Gold mine needs a gold vein.")
            return
        end
        buildings[#buildings + 1] = { type = type_name, q = q, r = r, timer = 0, local_gold = 0, max_gold = 5 }
        show_message("Gold mine built.")
    elseif type_name == BUILD_GENERATOR then
        buildings[#buildings + 1] = { type = type_name, q = q, r = r, timer = 0, local_energy = 0, max_energy = 20 }
        show_message("Energy generator built.")
    elseif type_name == BUILD_DRONE_FACTORY then
        buildings[#buildings + 1] = {
            type = type_name,
            q = q,
            r = r,
            timer = 0,
            local_metal = 0,
            max_metal = 10,
            local_energy = 0,
            max_energy = 10,
        }
        show_message("Drone factory waiting for metal and energy.")
    elseif type_name == BUILD_TURRET then
        buildings[#buildings + 1] = { type = type_name, q = q, r = r, timer = 0, local_metal = 0, max_metal = 50 }
        show_message("Defense turret built. Drones will deliver metal ammo.")
    end
end

local function incoming(q, r, stage, resource)
    local count = 0
    for _, d in ipairs(drones) do
        if d.task and d.task.stage == stage then
            local target = stage == "FETCHING" and d.task.source or d.task.dest
            if target.q == q and target.r == r and (not resource or d.task.resource == resource) then
                count = count + 1
            end
        end
    end
    return count
end

local function assign_task(idle, index, source, dest, resource)
    if index > #idle then return index, false end
    local d = idle[index]
    d.state = "BUSY"
    d.task = { source = source, dest = dest, resource = resource, stage = "FETCHING" }
    d.payload = nil
    return index + 1, true
end

local function manage_logistics()
    local hq = find_hq()
    if not hq then return end

    local idle = {}
    for _, d in ipairs(drones) do
        if d.state == "IDLE" then idle[#idle + 1] = d end
    end
    if #idle == 0 then return end

    local idx = 1
    for _, b in ipairs(buildings) do
        if b.type == BUILD_MINE_METAL and b.local_metal > incoming(b.q, b.r, "FETCHING", "METAL") then
            idx = select(1, assign_task(idle, idx, { q = b.q, r = b.r }, { q = hq.q, r = hq.r }, "METAL"))
            if idx > #idle then return end
        elseif b.type == BUILD_MINE_GOLD and b.local_gold > incoming(b.q, b.r, "FETCHING", "GOLD") then
            idx = select(1, assign_task(idle, idx, { q = b.q, r = b.r }, { q = hq.q, r = hq.r }, "GOLD"))
            if idx > #idle then return end
        elseif b.type == BUILD_GENERATOR and b.local_energy > incoming(b.q, b.r, "FETCHING", "ENERGY") then
            idx = select(1, assign_task(idle, idx, { q = b.q, r = b.r }, { q = hq.q, r = hq.r }, "ENERGY"))
            if idx > #idle then return end
        end
    end

    for _, b in ipairs(buildings) do
        if b.type == BUILD_TURRET then
            local deficit = b.max_metal - b.local_metal - incoming(b.q, b.r, "DELIVERING", "METAL")
            local hq_avail = resources.metal - incoming(hq.q, hq.r, "FETCHING", "METAL")
            if deficit > 0 and hq_avail > 0 then
                idx = select(1, assign_task(idle, idx, { q = hq.q, r = hq.r }, { q = b.q, r = b.r }, "METAL"))
                if idx > #idle then return end
            end
        elseif b.type == BUILD_DRONE_FACTORY then
            local metal_deficit = b.max_metal - b.local_metal - incoming(b.q, b.r, "DELIVERING", "METAL")
            local metal_avail = resources.metal - incoming(hq.q, hq.r, "FETCHING", "METAL")
            if metal_deficit > 0 and metal_avail > 0 then
                idx = select(1, assign_task(idle, idx, { q = hq.q, r = hq.r }, { q = b.q, r = b.r }, "METAL"))
                if idx > #idle then return end
            end
            local energy_deficit = b.max_energy - b.local_energy - incoming(b.q, b.r, "DELIVERING", "ENERGY")
            local energy_avail = resources.energy - incoming(hq.q, hq.r, "FETCHING", "ENERGY")
            if energy_deficit > 0 and energy_avail > 0 then
                idx = select(1, assign_task(idle, idx, { q = hq.q, r = hq.r }, { q = b.q, r = b.r }, "ENERGY"))
                if idx > #idle then return end
            end
        end
    end
end

local function update_buildings(dt)
    for _, b in ipairs(buildings) do
        b.timer = (b.timer or 0) + dt
        if b.type == BUILD_MINE_METAL and b.timer >= 1.0 then
            if b.local_metal < b.max_metal then b.local_metal = b.local_metal + 1 end
            b.timer = 0
        elseif b.type == BUILD_MINE_GOLD and b.timer >= 2.0 then
            if b.local_gold < b.max_gold then b.local_gold = b.local_gold + 1 end
            b.timer = 0
        elseif b.type == BUILD_GENERATOR and b.timer >= 0.5 then
            if b.local_energy < b.max_energy then b.local_energy = b.local_energy + 1 end
            b.timer = 0
        elseif b.type == BUILD_TURRET and b.timer >= 2.0 then
            if b.local_metal > 0 then b.local_metal = b.local_metal - 1 end
            b.timer = 0
        elseif b.type == BUILD_DRONE_FACTORY and b.timer >= 2.0 then
            if b.local_metal >= 5 and b.local_energy >= 5 and #drones < 50 then
                b.local_metal = b.local_metal - 5
                b.local_energy = b.local_energy - 5
                spawn_drone(b.q, b.r)
                show_message("Factory launched a new drone.")
            end
            b.timer = 0
        end
    end
end

local function fetch_payload(building, resource)
    if not building then return false end
    if building.type == BUILD_MINE_METAL and resource == "METAL" and building.local_metal > 0 then
        building.local_metal = building.local_metal - 1
        return true
    elseif building.type == BUILD_MINE_GOLD and resource == "GOLD" and building.local_gold > 0 then
        building.local_gold = building.local_gold - 1
        return true
    elseif building.type == BUILD_GENERATOR and resource == "ENERGY" and building.local_energy > 0 then
        building.local_energy = building.local_energy - 1
        return true
    elseif building.type == BUILD_HQ then
        if resource == "METAL" and resources.metal > 0 then
            resources.metal = resources.metal - 1
            return true
        elseif resource == "ENERGY" and resources.energy > 0 then
            resources.energy = resources.energy - 1
            return true
        end
    end
    return false
end

local function deliver_payload(building, payload)
    if not building or not payload then return end
    if building.type == BUILD_HQ then
        if payload == "METAL" then resources.metal = resources.metal + 1 end
        if payload == "GOLD" then resources.gold = resources.gold + 1 end
        if payload == "ENERGY" then resources.energy = resources.energy + 1 end
    elseif building.type == BUILD_TURRET and payload == "METAL" then
        building.local_metal = math.min(building.max_metal, building.local_metal + 1)
    elseif building.type == BUILD_DRONE_FACTORY then
        if payload == "METAL" then building.local_metal = math.min(building.max_metal, building.local_metal + 1) end
        if payload == "ENERGY" then building.local_energy = math.min(building.max_energy, building.local_energy + 1) end
    end
end

local function update_drones(dt)
    for _, d in ipairs(drones) do
        if d.state == "IDLE" then
            d.drift = d.drift + dt
            d.x = d.x + math.cos(d.drift * 1.7) * 4 * dt
            d.y = d.y + math.sin(d.drift * 1.3) * 4 * dt
        elseif d.task then
            local target_hex = d.task.stage == "FETCHING" and d.task.source or d.task.dest
            local tx, ty = hex_to_pixel(target_hex.q, target_hex.r)
            local dist = distance(d.x, d.y, tx, ty)
            if dist < 5 then
                local building = find_building(target_hex.q, target_hex.r)
                if d.task.stage == "FETCHING" then
                    if fetch_payload(building, d.task.resource) then
                        d.payload = d.task.resource
                        d.task.stage = "DELIVERING"
                    else
                        d.state = "IDLE"
                        d.task = nil
                        d.payload = nil
                    end
                else
                    deliver_payload(building, d.payload)
                    d.state = "IDLE"
                    d.task = nil
                    d.payload = nil
                end
            else
                local step = math.min(DRONE_SPEED * dt, dist)
                d.x = d.x + (tx - d.x) / dist * step
                d.y = d.y + (ty - d.y) / dist * step
            end
        end
    end
end

local function update_player(dt)
    local ax, ay = 0, 0
    if lurek.input.isActionDown("move_up") then ay = ay - 1 end
    if lurek.input.isActionDown("move_down") then ay = ay + 1 end
    if lurek.input.isActionDown("move_left") then ax = ax - 1 end
    if lurek.input.isActionDown("move_right") then ax = ax + 1 end
    if ax ~= 0 or ay ~= 0 then
        local len = math.sqrt(ax * ax + ay * ay)
        ax, ay = ax / len, ay / len
        player.vx = player.vx + ax * 900 * dt
        player.vy = player.vy + ay * 900 * dt
    end
    player.vx = player.vx * math.pow(0.08, dt)
    player.vy = player.vy * math.pow(0.08, dt)
    local speed = math.sqrt(player.vx * player.vx + player.vy * player.vy)
    if speed > PLAYER_SPEED then
        player.vx = player.vx / speed * PLAYER_SPEED
        player.vy = player.vy / speed * PLAYER_SPEED
    end
    player.x = player.x + player.vx * dt
    player.y = player.y + player.vy * dt
end

local function update_selection()
    local mx, my = lurek.input.mouse.getPosition()
    local q, r = pixel_to_hex(mx + camera.x, my + camera.y)
    if map[key(q, r)] then
        selected_hex = { q = q, r = r }
    else
        selected_hex = nil
    end
end

local function bind_input()
    lurek.input.bind("move_up", { "w", "up" })
    lurek.input.bind("move_down", { "s", "down" })
    lurek.input.bind("move_left", { "a", "left" })
    lurek.input.bind("move_right", { "d", "right" })
    lurek.input.bind("build_hq", "1")
    lurek.input.bind("build_metal", "2")
    lurek.input.bind("build_gold", "3")
    lurek.input.bind("build_generator", "4")
    lurek.input.bind("build_factory", "5")
    lurek.input.bind("build_turret", "6")
    lurek.input.bind("quit", "escape")
end

function lurek.init()
    lurek.window.setTitle("Hex Logistics - Lurek2D")
    lurek.render.setBackgroundColor(0.05, 0.07, 0.11)
    math.randomseed(os.time())
    bind_input()
    generate_map()
end

function lurek.process(dt)
    if lurek.automation then lurek.automation.update(dt) end
    if lurek.input.wasActionPressed("quit") then lurek.event.quit() return end

    if lurek.input.wasActionPressed("build_hq") then build(BUILD_HQ) end
    if lurek.input.wasActionPressed("build_metal") then build(BUILD_MINE_METAL) end
    if lurek.input.wasActionPressed("build_gold") then build(BUILD_MINE_GOLD) end
    if lurek.input.wasActionPressed("build_generator") then build(BUILD_GENERATOR) end
    if lurek.input.wasActionPressed("build_factory") then build(BUILD_DRONE_FACTORY) end
    if lurek.input.wasActionPressed("build_turret") then build(BUILD_TURRET) end

    update_player(dt)
    local w, h = lurek.window.getDimensions()
    camera.x = player.x - w / 2
    camera.y = player.y - h / 2
    update_selection()
    update_buildings(dt)
    manage_logistics()
    update_drones(dt)

    fps = lurek.timer.getFPS()
    if message_timer > 0 then message_timer = message_timer - dt end
end

local function tile_color(tile)
    if tile.type == TILE_METAL then return {0.31, 0.36, 0.43, 1} end
    if tile.type == TILE_GOLD then return {0.44, 0.29, 0.08, 1} end
    return {0.11, 0.16, 0.24, 1}
end

local function draw_world_text(text, wx, wy, color)
    draw_text(text, wx - camera.x, wy - camera.y, color)
end

local function draw_tile(tile)
    local wx, wy = hex_to_pixel(tile.q, tile.r)
    local sx, sy = wx - camera.x, wy - camera.y
    local w, h = lurek.window.getDimensions()
    if sx < -HEX_WIDTH or sx > w + HEX_WIDTH or sy < -HEX_HEIGHT or sy > h + HEX_HEIGHT then
        return
    end
    draw_hex(tile.q, tile.r, tile_color(tile), {0.19, 0.24, 0.31, 1})
    if tile.type == TILE_METAL then
        draw_world_text("Fe", wx - 7, wy - 6, {0.68, 0.74, 0.82, 1})
    elseif tile.type == TILE_GOLD then
        draw_world_text("Au", wx - 7, wy - 6, {0.98, 0.82, 0.18, 1})
    end
end

local function draw_building_label(text, wx, wy, color)
    draw_world_text(text, wx - 28, wy - 8, color or {1, 1, 1, 1})
end

local function draw_building(b)
    local wx, wy = hex_to_pixel(b.q, b.r)
    if b.type == BUILD_HQ then
        draw_hex(b.q, b.r, {0.12, 0.36, 0.78, 1}, {0.58, 0.75, 1, 1})
        draw_building_label("HQ", wx, wy, {1, 1, 1, 1})
    elseif b.type == BUILD_MINE_METAL then
        draw_hex(b.q, b.r, {0.80, 0.30, 0.08, 1}, {1, 0.63, 0.32, 1})
        draw_building_label("Mine", wx, wy - 7, {1, 1, 1, 1})
        draw_building_label("M:" .. b.local_metal .. "/" .. b.max_metal, wx, wy + 10, {1, 0.80, 0.32, 1})
    elseif b.type == BUILD_MINE_GOLD then
        draw_hex(b.q, b.r, {0.75, 0.54, 0.05, 1}, {1, 0.90, 0.38, 1})
        draw_building_label("Gold", wx, wy - 7, {1, 1, 1, 1})
        draw_building_label("G:" .. b.local_gold .. "/" .. b.max_gold, wx, wy + 10, {1, 0.96, 0.55, 1})
    elseif b.type == BUILD_GENERATOR then
        draw_hex(b.q, b.r, {0.04, 0.53, 0.62, 1}, {0.40, 0.91, 1, 1})
        draw_building_label("Gen", wx, wy - 7, {1, 1, 1, 1})
        draw_building_label("E:" .. b.local_energy .. "/" .. b.max_energy, wx, wy + 10, {0.50, 0.93, 1, 1})
    elseif b.type == BUILD_DRONE_FACTORY then
        draw_hex(b.q, b.r, {0.40, 0.22, 0.72, 1}, {0.78, 0.62, 1, 1})
        draw_building_label("Drones", wx, wy - 7, {1, 1, 1, 1})
        draw_building_label("M" .. b.local_metal .. " E" .. b.local_energy, wx, wy + 10, {0.85, 0.74, 1, 1})
    elseif b.type == BUILD_TURRET then
        draw_hex(b.q, b.r, {0.72, 0.16, 0.16, 1}, {1, 0.50, 0.50, 1})
        draw_building_label("Turret", wx, wy - 7, {1, 1, 1, 1})
        local sx, sy = wx - camera.x, wy - camera.y
        set_color({0.20, 0.03, 0.03, 1})
        lurek.render.rectangle("fill", sx - 20, sy + 12, 40, 5)
        set_color({0.30, 0.92, 0.42, 1})
        lurek.render.rectangle("fill", sx - 20, sy + 12, 40 * b.local_metal / b.max_metal, 5)
    end
end

local function draw_drones()
    for _, d in ipairs(drones) do
        local sx, sy = d.x - camera.x, d.y - camera.y
        set_color({0.22, 0.74, 0.96, 1})
        lurek.render.rectangle("fill", sx - 4, sy - 4, 8, 8)
        if d.payload then
            if d.payload == "METAL" then set_color({0.96, 0.77, 0.29, 1}) end
            if d.payload == "GOLD" then set_color({1.00, 0.96, 0.55, 1}) end
            if d.payload == "ENERGY" then set_color({0.50, 0.93, 1.00, 1}) end
            lurek.render.rectangle("fill", sx - 2, sy - 2, 4, 4)
        end
    end
end

local function draw_player()
    local sx, sy = player.x - camera.x, player.y - camera.y
    local angle = math.atan2(player.vy, player.vx) + math.pi / 2
    if math.abs(player.vx) + math.abs(player.vy) < 1 then angle = 0 end
    local c = math.cos(angle)
    local s = math.sin(angle)
    local points = { 0, -15, 10, 14, -10, 14 }
    local out = {}
    for i = 1, #points, 2 do
        local x, y = points[i], points[i + 1]
        out[#out + 1] = sx + x * c - y * s
        out[#out + 1] = sy + x * s + y * c
    end
    set_color({0.18, 0.78, 0.36, 1})
    lurek.render.polygon("fill", out[1], out[2], out[3], out[4], out[5], out[6])
    set_color({0.08, 0.37, 0.20, 1})
    lurek.render.polygon("line", out[1], out[2], out[3], out[4], out[5], out[6])
end

function lurek.draw()
    local w, h = lurek.window.getDimensions()
    set_color({0.05, 0.07, 0.11, 1})
    lurek.render.rectangle("fill", 0, 0, w, h)

    set_color({0.92, 0.70, 0.12, 0.08})
    lurek.render.circle("fill", player.x - camera.x, player.y - camera.y, BUILD_RADIUS)
    set_color({0.92, 0.70, 0.12, 0.30})
    lurek.render.setLineWidth(2)
    lurek.render.circle("line", player.x - camera.x, player.y - camera.y, BUILD_RADIUS)
    lurek.render.setLineWidth(1)

    for _, tile in ipairs(tiles) do
        draw_tile(tile)
    end

    if selected_hex then
        draw_hex(selected_hex.q, selected_hex.r, {1, 1, 1, 0.10}, {1, 1, 1, 0.75})
    end
    local pq, pr = pixel_to_hex(player.x, player.y)
    draw_hex(pq, pr, {0.10, 0.80, 0.33, 0.20}, {0.20, 0.92, 0.42, 1})

    for _, b in ipairs(buildings) do
        draw_building(b)
    end
    draw_drones()
    draw_player()
end

local function current_tile_label()
    local q, r = pixel_to_hex(player.x, player.y)
    local tile = map[key(q, r)]
    if not tile then return "outside" end
    if tile.type == TILE_METAL then return "metal vein" end
    if tile.type == TILE_GOLD then return "gold vein" end
    return "empty"
end

function lurek.draw_ui()
    local w, h = lurek.window.getDimensions()
    set_color({0.04, 0.06, 0.10, 0.92})
    lurek.render.rectangle("fill", 0, 0, w, 58)
    set_color({0.12, 0.17, 0.24, 1})
    lurek.render.rectangle("fill", 0, 57, w, 1)

    draw_text("HEX LOGISTICS", 14, 10, {0.86, 0.91, 0.98, 1})
    draw_text("Drones: " .. #drones, 150, 10, {0.76, 0.62, 1, 1})
    draw_text("Metal: " .. resources.metal, 250, 10, {0.88, 0.91, 0.95, 1})
    draw_text("Gold: " .. resources.gold, 350, 10, {1.00, 0.84, 0.25, 1})
    draw_text("Energy: " .. resources.energy, 450, 10, {0.40, 0.91, 1.00, 1})
    draw_text("FPS: " .. tostring(math.floor(fps)), w - 88, 10, {0.48, 0.55, 0.65, 1})
    draw_text("WASD move | 1 HQ | 2 metal mine | 3 gold mine | 4 generator | 5 factory | 6 turret | ESC quit", 14, 34, {0.57, 0.65, 0.76, 1})

    set_color({0.04, 0.06, 0.10, 0.88})
    lurek.render.rectangle("fill", 12, h - 48, 430, 34)
    local q, r = pixel_to_hex(player.x, player.y)
    draw_text("Ship hex: " .. q .. "," .. r .. "   tile: " .. current_tile_label(), 22, h - 38, {0.78, 0.86, 0.95, 1})
    if message_timer > 0 then
        local pulse = 0.7 + 0.3 * math.sin(lurek.timer.getTime() * 6)
        draw_text(message, 22, h - 22, {1, 0.95, 0.62, pulse})
    end
end
