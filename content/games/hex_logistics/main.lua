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
local BUILD_ORDER = {
    BUILD_HQ,
    BUILD_MINE_METAL,
    BUILD_MINE_GOLD,
    BUILD_GENERATOR,
    BUILD_DRONE_FACTORY,
    BUILD_TURRET,
}

local DRONE_LIMIT = 50
local PRIORITY_DISABLED = "DISABLED"
local PRIORITY_NORMAL = "NORMAL"
local PRIORITY_HIGH = "HIGH"

local BUILD_COSTS = {
    [BUILD_HQ] = { metal = 0, time = 2.0, label = "HQ" },
    [BUILD_MINE_METAL] = { metal = 10, time = 10.0, label = "Metal mine" },
    [BUILD_MINE_GOLD] = { metal = 20, time = 10.0, label = "Gold mine" },
    [BUILD_GENERATOR] = { metal = 15, time = 5.0, label = "Generator" },
    [BUILD_DRONE_FACTORY] = { metal = 50, time = 12.0, label = "Drone factory" },
    [BUILD_TURRET] = { metal = 30, time = 8.0, label = "Turret" },
}

local map = {}
local tiles = {}
local buildings = {}
local drones = {}
local resources = { metal = 150, energy = 0, gold = 0 }
local player = { x = 0, y = 0, vx = 0, vy = 0 }
local camera = { x = 0, y = 0 }
local selected_hex = nil
local active_build_type = BUILD_HQ
local move_target = nil
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
    return lurek.tilemap.toScreenHex(q, r, HEX_SIZE)
end

local function pixel_to_hex(x, y)
    return lurek.tilemap.fromScreenHex(x, y, HEX_SIZE)
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

local function build_label(type_name)
    local cost = BUILD_COSTS[type_name]
    if cost then return cost.label end
    return tostring(type_name)
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

local function draw_hex(q, r, fill, line)
    local wx, wy = hex_to_pixel(q, r)
    local sx, sy = wx - camera.x, wy - camera.y
    set_color(fill)
    lurek.render.drawHexTile(sx, sy, HEX_SIZE, "pointyTop", "fill")
    set_color(line or {0.20, 0.25, 0.32, 1})
    lurek.render.drawHexTile(sx, sy, HEX_SIZE, "pointyTop", "line")
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

local function find_active_hq()
    local hq = find_hq()
    if hq and hq.state == "ACTIVE" then return hq end
    return nil
end

local function summarize_building(b)
    if not b then return nil end
    return {
        type = b.type,
        q = b.q,
        r = b.r,
        state = b.state,
        priority = b.priority,
        queue = b.queue or 0,
    }
end

local function building_under_player()
    local q, r = pixel_to_hex(player.x, player.y)
    return find_building(q, r)
end

local function set_active_build(type_name)
    if BUILD_COSTS[type_name] then
        active_build_type = type_name
        show_message("Build tool: " .. build_label(type_name) .. ".")
    end
end

local function cycle_build_selection(direction)
    local index = 1
    for i = 1, #BUILD_ORDER do
        if BUILD_ORDER[i] == active_build_type then
            index = i
            break
        end
    end
    local count = #BUILD_ORDER
    local next_index = ((index - 1 + direction) % count) + 1
    set_active_build(BUILD_ORDER[next_index])
end

local function select_hex_from_screen(x, y)
    local q, r = pixel_to_hex(x + camera.x, y + camera.y)
    if map[key(q, r)] then
        selected_hex = { q = q, r = r }
        return q, r
    end
    selected_hex = nil
    return nil, nil
end

local function nearest_buildable_hex(tile_type)
    local best = nil
    local best_dist = math.huge
    for _, tile in ipairs(tiles) do
        if (not tile_type or tile.type == tile_type) and not find_building(tile.q, tile.r) then
            local wx, wy = hex_to_pixel(tile.q, tile.r)
            local dist = distance(player.x, player.y, wx, wy)
            if dist > 1 and dist <= BUILD_RADIUS and dist < best_dist then
                best = tile
                best_dist = dist
            end
        end
    end
    return best
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

local function new_building(type_name, q, r)
    local cost = BUILD_COSTS[type_name]
    local b = {
        type = type_name,
        q = q,
        r = r,
        state = "CONSTRUCTING",
        progress = 0,
        build_time = cost.time,
        priority = PRIORITY_NORMAL,
        timer = 0,
    }

    if type_name == BUILD_MINE_METAL then
        b.local_metal = 0
        b.max_metal = 15
        b.local_energy = 0
        b.max_energy = 5
    elseif type_name == BUILD_MINE_GOLD then
        b.local_gold = 0
        b.max_gold = 10
        b.local_energy = 0
        b.max_energy = 5
    elseif type_name == BUILD_GENERATOR then
        b.local_energy = 0
        b.max_energy = 20
    elseif type_name == BUILD_DRONE_FACTORY then
        b.local_metal = 0
        b.max_metal = 50
        b.local_energy = 0
        b.max_energy = 20
        b.queue = 0
    elseif type_name == BUILD_TURRET then
        b.local_metal = 0
        b.max_metal = 50
    end

    return b
end

local function build_at(type_name, q, r)
    local tile = map[key(q, r)]
    local cost = BUILD_COSTS[type_name]
    if not tile then
        show_message("Out of mapped sector.")
        return false
    end
    if not cost then
        show_message("Unknown build order.")
        return false
    end
    if find_building(q, r) then
        show_message("Hex already occupied.")
        return false
    end
    local wx, wy = hex_to_pixel(q, r)
    if distance(player.x, player.y, wx, wy) > BUILD_RADIUS then
        show_message("Target hex is outside construction range.")
        return false
    end
    if resources.metal < cost.metal then
        show_message(cost.label .. " needs " .. cost.metal .. " metal.")
        return false
    end

    if type_name == BUILD_HQ then
        if find_hq() then
            show_message("Only one HQ is allowed.")
            return false
        end
    elseif type_name == BUILD_MINE_METAL then
        if tile.type ~= TILE_METAL then
            show_message("Metal mine needs a metal vein.")
            return false
        end
    elseif type_name == BUILD_MINE_GOLD then
        if tile.type ~= TILE_GOLD then
            show_message("Gold mine needs a gold vein.")
            return false
        end
    end

    resources.metal = resources.metal - cost.metal
    buildings[#buildings + 1] = new_building(type_name, q, r)
    show_message(cost.label .. " construction started.")
    return true
end

local function build(type_name)
    local q, r = pixel_to_hex(player.x, player.y)
    return build_at(type_name, q, r)
end

local function queue_drone_production_at(q, r)
    local b = find_building(q, r)
    if b and b.type == BUILD_DRONE_FACTORY and b.state == "ACTIVE" then
        b.queue = b.queue + 1
        show_message("Drone order queued.")
        return true
    else
        show_message("Select an active drone factory to queue drones.")
        return false
    end
end

local function queue_drone_production()
    local q, r = pixel_to_hex(player.x, player.y)
    return queue_drone_production_at(q, r)
end

local function set_building_priority_at(q, r, priority)
    local b = find_building(q, r)
    if b and b.type ~= BUILD_HQ then
        b.priority = priority
        show_message("Priority set to " .. string.lower(priority) .. ".")
        return true
    else
        show_message("Select a non-HQ building to set priority.")
        return false
    end
end

local function set_building_priority(priority)
    local q, r = pixel_to_hex(player.x, player.y)
    return set_building_priority_at(q, r, priority)
end

local function cycle_building_priority_at(q, r)
    local b = find_building(q, r)
    if not b or b.type == BUILD_HQ then
        show_message("Select a non-HQ building to cycle priority.")
        return false
    end
    local next_priority = PRIORITY_DISABLED
    if b.priority == PRIORITY_DISABLED then
        next_priority = PRIORITY_NORMAL
    elseif b.priority == PRIORITY_NORMAL then
        next_priority = PRIORITY_HIGH
    end
    b.priority = next_priority
    show_message("Priority set to " .. string.lower(next_priority) .. ".")
    return true
end

local function set_move_target(q, r)
    local tile = map[key(q, r)]
    if not tile then
        show_message("Out of mapped sector.")
        return false
    end
    local wx, wy = hex_to_pixel(q, r)
    move_target = { q = q, r = r, x = wx, y = wy }
    show_message("Course plotted to hex " .. q .. "," .. r .. ".")
    return true
end

local function mouse_interact(q, r)
    local b = find_building(q, r)
    if b then
        if b.type == BUILD_DRONE_FACTORY and b.state == "ACTIVE" then
            return queue_drone_production_at(q, r)
        end
        return cycle_building_priority_at(q, r)
    end
    return build_at(active_build_type, q, r)
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
    local hq = find_active_hq()
    if not hq then return end

    local idle = {}
    for _, d in ipairs(drones) do
        if d.state == "IDLE" then idle[#idle + 1] = d end
    end
    if #idle == 0 then return end

    local tasks = {}

    local function add_tasks(amount, source, dest, resource, score)
        local count = math.max(0, math.floor(amount))
        for _ = 1, count do
            tasks[#tasks + 1] = { source = source, dest = dest, resource = resource, score = score }
        end
    end

    local function priority_bonus(b)
        if b.priority == PRIORITY_HIGH then return 10000 end
        return 0
    end

    for _, b in ipairs(buildings) do
        if b.state == "ACTIVE" and b.type ~= BUILD_HQ and b.priority ~= PRIORITY_DISABLED then
            local bonus = priority_bonus(b)
            if b.type == BUILD_DRONE_FACTORY then
                if b.queue > 0 then
                    add_tasks(b.max_metal - b.local_metal - incoming(b.q, b.r, "DELIVERING", "METAL"), hq, b, "METAL", 500 + bonus)
                    add_tasks(b.max_energy - b.local_energy - incoming(b.q, b.r, "DELIVERING", "ENERGY"), hq, b, "ENERGY", 500 + bonus)
                end
            elseif b.type == BUILD_MINE_METAL then
                add_tasks(b.local_metal - incoming(b.q, b.r, "FETCHING", "METAL"), b, hq, "METAL", 300 + bonus)
                add_tasks(b.max_energy - b.local_energy - incoming(b.q, b.r, "DELIVERING", "ENERGY"), hq, b, "ENERGY", 300 + bonus)
            elseif b.type == BUILD_MINE_GOLD then
                add_tasks(b.local_gold - incoming(b.q, b.r, "FETCHING", "GOLD"), b, hq, "GOLD", 300 + bonus)
                add_tasks(b.max_energy - b.local_energy - incoming(b.q, b.r, "DELIVERING", "ENERGY"), hq, b, "ENERGY", 300 + bonus)
            elseif b.type == BUILD_TURRET then
                add_tasks(b.max_metal - b.local_metal - incoming(b.q, b.r, "DELIVERING", "METAL"), hq, b, "METAL", 200 + bonus)
            elseif b.type == BUILD_GENERATOR then
                add_tasks(b.local_energy - incoming(b.q, b.r, "FETCHING", "ENERGY"), b, hq, "ENERGY", 100 + bonus)
            end
        end
    end

    table.sort(tasks, function(a, b) return a.score > b.score end)

    local virtual = {
        METAL = resources.metal - incoming(hq.q, hq.r, "FETCHING", "METAL"),
        GOLD = resources.gold - incoming(hq.q, hq.r, "FETCHING", "GOLD"),
        ENERGY = resources.energy - incoming(hq.q, hq.r, "FETCHING", "ENERGY"),
    }

    local task_index = 1
    for idle_index = 1, #idle do
        while task_index <= #tasks do
            local task = tasks[task_index]
            task_index = task_index + 1
            if task.source.type ~= BUILD_HQ or virtual[task.resource] > 0 then
                if task.source.type == BUILD_HQ then
                    virtual[task.resource] = virtual[task.resource] - 1
                end
                assign_task(idle, idle_index, { q = task.source.q, r = task.source.r }, { q = task.dest.q, r = task.dest.r }, task.resource)
                break
            end
        end
        if task_index > #tasks then return end
    end
end

local function update_buildings(dt)
    for _, b in ipairs(buildings) do
        if b.state == "CONSTRUCTING" then
            b.progress = b.progress + dt
            if b.progress >= b.build_time then
                b.state = "ACTIVE"
                b.progress = b.build_time
                b.timer = 0
                if b.type == BUILD_HQ then
                    for _ = 1, 3 do spawn_drone(b.q, b.r) end
                    show_message("HQ online. Three drones launched.")
                else
                    show_message(BUILD_COSTS[b.type].label .. " online.")
                end
            end
            goto continue
        end

        b.timer = (b.timer or 0) + dt
        if b.type == BUILD_MINE_METAL and b.timer >= 2.0 then
            if b.local_metal < b.max_metal and b.local_energy >= 1 then
                b.local_energy = b.local_energy - 1
                b.local_metal = math.min(b.max_metal, b.local_metal + 3)
            end
            b.timer = 0
        elseif b.type == BUILD_MINE_GOLD and b.timer >= 3.0 then
            if b.local_gold < b.max_gold and b.local_energy >= 1 then
                b.local_energy = b.local_energy - 1
                b.local_gold = math.min(b.max_gold, b.local_gold + 1)
            end
            b.timer = 0
        elseif b.type == BUILD_GENERATOR and b.timer >= 1.0 then
            if b.local_energy < b.max_energy then b.local_energy = b.local_energy + 1 end
            b.timer = 0
        elseif b.type == BUILD_TURRET and b.timer >= 2.0 then
            if b.local_metal > 0 then b.local_metal = b.local_metal - 1 end
            b.timer = 0
        elseif b.type == BUILD_DRONE_FACTORY then
            if b.queue > 0 and b.timer >= 1.0 then
                if b.local_metal >= 25 and b.local_energy >= 5 and #drones < DRONE_LIMIT then
                    b.local_metal = b.local_metal - 25
                    b.local_energy = b.local_energy - 5
                    b.queue = b.queue - 1
                    spawn_drone(b.q, b.r)
                    show_message("Factory launched a new drone.")
                end
                b.timer = 0
            elseif b.queue == 0 then
                b.timer = 0
            end
        end
        ::continue::
    end
end

local function fetch_payload(building, resource)
    if not building then return false end
    if building.state ~= "ACTIVE" then return false end
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
    if building.state ~= "ACTIVE" then return end
    if building.type == BUILD_HQ then
        if payload == "METAL" then resources.metal = resources.metal + 1 end
        if payload == "GOLD" then resources.gold = resources.gold + 1 end
        if payload == "ENERGY" then resources.energy = resources.energy + 1 end
    elseif building.type == BUILD_TURRET and payload == "METAL" then
        building.local_metal = math.min(building.max_metal, building.local_metal + 1)
    elseif building.type == BUILD_DRONE_FACTORY then
        if payload == "METAL" then building.local_metal = math.min(building.max_metal, building.local_metal + 1) end
        if payload == "ENERGY" then building.local_energy = math.min(building.max_energy, building.local_energy + 1) end
    elseif (building.type == BUILD_MINE_METAL or building.type == BUILD_MINE_GOLD) and payload == "ENERGY" then
        building.local_energy = math.min(building.max_energy, building.local_energy + 1)
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
        move_target = nil
    elseif move_target then
        local dx = move_target.x - player.x
        local dy = move_target.y - player.y
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist <= 8 then
            move_target = nil
        else
            ax = dx / dist
            ay = dy / dist
            player.vx = player.vx + ax * 900 * dt
            player.vy = player.vy + ay * 900 * dt
        end
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
    select_hex_from_screen(mx, my)
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
    lurek.input.bind("queue_drone", "q")
    lurek.input.bind("priority_disabled", "z")
    lurek.input.bind("priority_normal", "x")
    lurek.input.bind("priority_high", "c")
    lurek.input.bind("quit", "escape")
end

function lurek.init()
    lurek.window.setTitle("Hex Logistics - Lurek2D")
    lurek.render.setBackgroundColor(0.05, 0.07, 0.11)
    map = {}
    tiles = {}
    buildings = {}
    drones = {}
    resources = { metal = 150, energy = 0, gold = 0 }
    player = { x = 0, y = 0, vx = 0, vy = 0 }
    camera = { x = 0, y = 0 }
    selected_hex = nil
    active_build_type = BUILD_HQ
    move_target = nil
    message = "Build HQ first. It releases three logistics drones."
    message_timer = 5
    fps = 0
    math.randomseed(rawget(_G, "HEX_LOGISTICS_TEST_SEED") or os.time())
    bind_input()
    generate_map()
end

function lurek.process(dt)
    if lurek.automation then lurek.automation.update(dt) end
    if lurek.input.wasActionPressed("quit") then lurek.event.quit() return end

    if lurek.input.wasActionPressed("build_hq") then set_active_build(BUILD_HQ); build(BUILD_HQ) end
    if lurek.input.wasActionPressed("build_metal") then set_active_build(BUILD_MINE_METAL); build(BUILD_MINE_METAL) end
    if lurek.input.wasActionPressed("build_gold") then set_active_build(BUILD_MINE_GOLD); build(BUILD_MINE_GOLD) end
    if lurek.input.wasActionPressed("build_generator") then set_active_build(BUILD_GENERATOR); build(BUILD_GENERATOR) end
    if lurek.input.wasActionPressed("build_factory") then set_active_build(BUILD_DRONE_FACTORY); build(BUILD_DRONE_FACTORY) end
    if lurek.input.wasActionPressed("build_turret") then set_active_build(BUILD_TURRET); build(BUILD_TURRET) end
    if lurek.input.wasActionPressed("queue_drone") then queue_drone_production() end
    if lurek.input.wasActionPressed("priority_disabled") then set_building_priority(PRIORITY_DISABLED) end
    if lurek.input.wasActionPressed("priority_normal") then set_building_priority(PRIORITY_NORMAL) end
    if lurek.input.wasActionPressed("priority_high") then set_building_priority(PRIORITY_HIGH) end

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

function lurek.mousemoved(x, y, dx, dy)
    select_hex_from_screen(x, y)
end

function lurek.mousepressed(x, y, button)
    local q, r = select_hex_from_screen(x, y)
    if not q then return end
    if button == 1 then
        mouse_interact(q, r)
    elseif button == 2 then
        set_move_target(q, r)
    end
end

function lurek.wheelmoved(dx, dy)
    if dy > 0 then
        cycle_build_selection(1)
    elseif dy < 0 then
        cycle_build_selection(-1)
    end
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
    if b.state == "CONSTRUCTING" then
        draw_hex(b.q, b.r, {0.18, 0.19, 0.22, 0.90}, {0.96, 0.62, 0.12, 1})
        draw_building_label("Build", wx, wy - 8, {1.00, 0.76, 0.28, 1})
        local sx, sy = wx - camera.x, wy - camera.y
        local progress = clamp(b.progress / b.build_time, 0, 1)
        set_color({0.25, 0.27, 0.31, 1})
        lurek.render.rectangle("fill", sx - 22, sy + 10, 44, 5)
        set_color({0.96, 0.62, 0.12, 1})
        lurek.render.rectangle("fill", sx - 22, sy + 10, 44 * progress, 5)
        return
    end

    if b.type ~= BUILD_HQ then
        if b.priority == PRIORITY_HIGH then
            draw_building_label("HIGH", wx, wy - 26, {1.00, 0.76, 0.28, 1})
        elseif b.priority == PRIORITY_DISABLED then
            draw_building_label("OFF", wx, wy - 26, {1.00, 0.36, 0.36, 1})
        end
    end

    if b.type == BUILD_HQ then
        draw_hex(b.q, b.r, {0.12, 0.36, 0.78, 1}, {0.58, 0.75, 1, 1})
        draw_building_label("HQ", wx, wy, {1, 1, 1, 1})
    elseif b.type == BUILD_MINE_METAL then
        draw_hex(b.q, b.r, {0.80, 0.30, 0.08, 1}, {1, 0.63, 0.32, 1})
        draw_building_label("Metal", wx, wy - 14, {1, 1, 1, 1})
        draw_building_label("M:" .. b.local_metal .. "/" .. b.max_metal, wx, wy + 2, {1, 0.80, 0.32, 1})
        draw_building_label("E:" .. b.local_energy .. "/" .. b.max_energy, wx, wy + 16, {0.50, 0.93, 1, 1})
    elseif b.type == BUILD_MINE_GOLD then
        draw_hex(b.q, b.r, {0.75, 0.54, 0.05, 1}, {1, 0.90, 0.38, 1})
        draw_building_label("Gold", wx, wy - 14, {1, 1, 1, 1})
        draw_building_label("G:" .. b.local_gold .. "/" .. b.max_gold, wx, wy + 2, {1, 0.96, 0.55, 1})
        draw_building_label("E:" .. b.local_energy .. "/" .. b.max_energy, wx, wy + 16, {0.50, 0.93, 1, 1})
    elseif b.type == BUILD_GENERATOR then
        draw_hex(b.q, b.r, {0.04, 0.53, 0.62, 1}, {0.40, 0.91, 1, 1})
        draw_building_label("Gen", wx, wy - 7, {1, 1, 1, 1})
        draw_building_label("E:" .. b.local_energy .. "/" .. b.max_energy, wx, wy + 10, {0.50, 0.93, 1, 1})
    elseif b.type == BUILD_DRONE_FACTORY then
        draw_hex(b.q, b.r, {0.40, 0.22, 0.72, 1}, {0.78, 0.62, 1, 1})
        draw_building_label("Drones", wx, wy - 14, {1, 1, 1, 1})
        draw_building_label("M" .. b.local_metal .. " E" .. b.local_energy, wx, wy + 2, {0.85, 0.74, 1, 1})
        draw_building_label("Q:" .. b.queue, wx, wy + 16, {1.00, 0.80, 0.92, 1})
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

local function building_status_label(b)
    if not b then return "none" end
    local label = BUILD_COSTS[b.type] and BUILD_COSTS[b.type].label or b.type
    if b.state == "CONSTRUCTING" then
        return label .. " building " .. math.floor(clamp(b.progress / b.build_time, 0, 1) * 100) .. "%"
    end
    if b.type == BUILD_HQ then return label .. " active" end
    return label .. " " .. string.lower(b.priority)
end

function lurek.draw_ui()
    local w, h = lurek.window.getDimensions()
    set_color({0.04, 0.06, 0.10, 0.92})
    lurek.render.rectangle("fill", 0, 0, w, 74)
    set_color({0.12, 0.17, 0.24, 1})
    lurek.render.rectangle("fill", 0, 73, w, 1)

    draw_text("HEX LOGISTICS", 14, 10, {0.86, 0.91, 0.98, 1})
    draw_text("Drones: " .. #drones .. "/" .. DRONE_LIMIT, 150, 10, {0.76, 0.62, 1, 1})
    draw_text("Metal: " .. resources.metal, 270, 10, {0.88, 0.91, 0.95, 1})
    draw_text("Gold: " .. resources.gold, 370, 10, {1.00, 0.84, 0.25, 1})
    draw_text("Energy: " .. resources.energy, 470, 10, {0.40, 0.91, 1.00, 1})
    draw_text("FPS: " .. tostring(math.floor(fps)), w - 88, 10, {0.48, 0.55, 0.65, 1})
    draw_text("Tool: " .. build_label(active_build_type), 640, 10, {1.00, 0.78, 0.30, 1})
    draw_text("WASD move | 1 HQ 0M | 2 metal 10M | 3 gold 20M | 4 gen 15M | 5 factory 50M | 6 turret 30M", 14, 34, {0.57, 0.65, 0.76, 1})
    draw_text("Mouse wheel tool | LMB build/queue/cycle | RMB move ship | Q queue | Z/X/C priority | ESC quit", 14, 54, {0.57, 0.65, 0.76, 1})

    set_color({0.04, 0.06, 0.10, 0.88})
    lurek.render.rectangle("fill", 12, h - 64, 560, 50)
    local q, r = pixel_to_hex(player.x, player.y)
    local b = find_building(q, r)
    draw_text("Ship hex: " .. q .. "," .. r .. "   tile: " .. current_tile_label(), 22, h - 54, {0.78, 0.86, 0.95, 1})
    draw_text("Building: " .. building_status_label(b), 22, h - 38, {0.78, 0.86, 0.95, 1})
    if message_timer > 0 then
        local pulse = 0.7 + 0.3 * math.sin(lurek.timer.getTime() * 6)
        draw_text(message, 22, h - 22, {1, 0.95, 0.62, pulse})
    end
end

function hex_logistics_debug()
    local nearby_empty = nearest_buildable_hex(TILE_EMPTY)
    local nearby_metal = nearest_buildable_hex(TILE_METAL)
    local nearby_gold = nearest_buildable_hex(TILE_GOLD)
    local selected_building = nil
    if selected_hex then
        selected_building = find_building(selected_hex.q, selected_hex.r)
    end
    return {
        active_build = active_build_type,
        building_count = #buildings,
        drone_count = #drones,
        fps = fps,
        message = message,
        resources = {
            metal = resources.metal,
            energy = resources.energy,
            gold = resources.gold,
        },
        player = {
            x = player.x,
            y = player.y,
            vx = player.vx,
            vy = player.vy,
        },
        camera = {
            x = camera.x,
            y = camera.y,
        },
        move_target = move_target and {
            q = move_target.q,
            r = move_target.r,
            x = move_target.x,
            y = move_target.y,
        } or nil,
        selected_hex = selected_hex and {
            q = selected_hex.q,
            r = selected_hex.r,
        } or nil,
        selected_building = summarize_building(selected_building),
        hq = summarize_building(find_hq()),
        nearby_empty_hex = nearby_empty and {
            q = nearby_empty.q,
            r = nearby_empty.r,
        } or nil,
        nearby_metal_hex = nearby_metal and {
            q = nearby_metal.q,
            r = nearby_metal.r,
        } or nil,
        nearby_gold_hex = nearby_gold and {
            q = nearby_gold.q,
            r = nearby_gold.r,
        } or nil,
    }
end
