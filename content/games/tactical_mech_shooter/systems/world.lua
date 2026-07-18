local M = {}

local function map_value(content, key, fallback)
    return tonumber(content.map and content.map[key]) or tonumber(content.game and content.game.map and content.game.map[key]) or fallback
end

local function is_ground(kind)
    return kind == "floor" or kind == "grass" or kind == "sand" or kind == "water" or kind == "door_open"
end

function M.create(state)
    local content = state.content
    local map = content.active_map or content.map or {}
    local width, height = tonumber(map.width) or map_value(content, "map_width", 125), tonumber(map.height) or map_value(content, "map_height", 125)
    local tile_size = tonumber(map.tile_size) or map_value(content, "tile_size", 32)
    local field = lurek.tilefield.new({width = width, height = height, levels = 1, topology = "square"})
    local model = {
        width = width, height = height, tile_size = tile_size, field = field,
        tile_defs = content.content.tiles,
        tiles = {}, lights_dirty = true, smoke = {}, explosions = {}, projectiles = {}, actors = {},
        physics_walls = {},
        rng = lurek.math.newRandomGenerator(tonumber(map.seed) or 424242),
    }
    local world_w, world_h = width * tile_size, height * tile_size
    model.physics_walls = {
        {x = world_w * 0.5, y = tile_size * 0.5, w = world_w, h = tile_size},
        {x = world_w * 0.5, y = world_h - tile_size * 0.5, w = world_w, h = tile_size},
        {x = tile_size * 0.5, y = world_h * 0.5, w = tile_size, h = world_h},
        {x = world_w - tile_size * 0.5, y = world_h * 0.5, w = tile_size, h = world_h},
    }
    for y = 1, height do
        for x = 1, width do
            local kind = (x == 1 or y == 1 or x == width or y == height) and "wall" or "floor"
            model.tiles[(y - 1) * width + x] = kind
            if kind ~= "floor" then pcall(field.applyProfile, field, x, y, 1, kind == "door_closed" and "door_closed" or "wall") end
        end
    end
    for _, terrain in ipairs(map.terrain or {}) do
        local kind = tostring(terrain.kind or "floor")
        for y = terrain.y, terrain.y + terrain.h - 1 do
            for x = terrain.x, terrain.x + terrain.w - 1 do
                if x > 1 and y > 1 and x < width and y < height and model.tile_defs[kind] then
                    model.tiles[(y - 1) * width + x] = kind
                end
            end
        end
    end
    for _, wall in ipairs(map.wall or {}) do
        for y = wall.y, wall.y + wall.h - 1 do
            for x = wall.x, wall.x + wall.w - 1 do
                if x >= 1 and y >= 1 and x <= width and y <= height then
                    model.tiles[(y - 1) * width + x] = "wall"
                    pcall(field.applyProfile, field, x, y, 1, "wall")
                end
            end
        end
        model.physics_walls[#model.physics_walls + 1] = {
            x = (wall.x - 1 + wall.w * 0.5) * tile_size,
            y = (wall.y - 1 + wall.h * 0.5) * tile_size,
            w = wall.w * tile_size,
            h = wall.h * tile_size,
        }
    end
    for _, door in ipairs(map.door or {}) do
        for y = door.y, door.y + door.h - 1 do
            for x = door.x, door.x + door.w - 1 do
                if x >= 1 and y >= 1 and x <= width and y <= height then
                    model.tiles[(y - 1) * width + x] = "door_closed"
                    pcall(field.applyProfile, field, x, y, 1, "door_closed")
                end
            end
        end
        model.physics_walls[#model.physics_walls + 1] = {
            x = (door.x - 1 + door.w * 0.5) * tile_size,
            y = (door.y - 1 + door.h * 0.5) * tile_size,
            w = door.w * tile_size,
            h = door.h * tile_size,
        }
    end
    local obstacle_count = tonumber(map.obstacle_count) or 0
    local spawn_margin = tonumber(content.map and content.map.spawn_margin) or 8
    for _ = 1, obstacle_count do
        local x, y = model.rng:randomInt(2, width - 1), model.rng:randomInt(2, height - 1)
        local near_spawn = false
        for _, spawn in ipairs(map.spawn or {}) do
            local dx, dy = x - spawn.x, y - spawn.y
            if dx * dx + dy * dy <= (spawn.radius + spawn_margin) ^ 2 then near_spawn = true end
        end
        local tile = model.tiles[(y - 1) * width + x]
        if not near_spawn and is_ground(tile) and tile ~= "water" then
            model.tiles[(y - 1) * width + x] = "wall"
            pcall(field.applyProfile, field, x, y, 1, "wall")
            model.physics_walls[#model.physics_walls + 1] = {
                x = (x - 0.5) * tile_size, y = (y - 0.5) * tile_size, w = tile_size, h = tile_size,
            }
        end
    end
    model.tilemap = nil
    if lurek.tilemap and lurek.tilemap.fromProvider then
        local provider = {
            width = width, height = height, layers = {{name = "ground", width = width, height = height, tiles = {}}},
        }
        for i, kind in ipairs(model.tiles) do provider.layers[1].tiles[i] = is_ground(kind) and 1 or (kind == "door_closed" and 3 or 2) end
        local ok, tilemap = pcall(lurek.tilemap.fromProvider, provider)
        if ok then model.tilemap = tilemap end
    end
    model.bases, model.team_colors = {}, {}
    for _, spawn in ipairs(map.spawn or {}) do
        local team = "team" .. tostring(tonumber(spawn.team) or 1)
        local bx, by = M.center(model, spawn.x, spawn.y)
        local base = {team = team, name = spawn.name or team, x = bx, y = by, radius = (spawn.radius or 8) * tile_size, color = spawn.color or {1, 1, 1, 1}}
        model.bases[#model.bases + 1] = base
        model.team_colors[team] = base.color
    end
    model.tilelight = lurek.tilelight.new(field)
    model.tilelight:setAmbient({r = 0.018, g = 0.022, b = 0.032})
    for _, light in ipairs(map.light or {}) do
        local c = light.color or {1, 1, 1}
        model.tilelight:addPointLight({
            x = light.x, y = light.y, z = 1, radius = light.radius,
            intensity = light.intensity,
            color = {r = c[1] or c.r or 1, g = c[2] or c.g or 1, b = c[3] or c.b or 1},
        })
    end
    model.tilelight:compute({includePointLights = true, includeGlobalLight = false})
    model.light_layer = model.tilelight:exportLayer(1)
    model.walls = model.physics_walls
    return model
end

function M.cell(model, x, y)
    return math.floor(x / model.tile_size) + 1, math.floor(y / model.tile_size) + 1
end

function M.center(model, cx, cy)
    return (cx - 0.5) * model.tile_size, (cy - 0.5) * model.tile_size
end

function M.tile(model, cx, cy)
    if cx < 1 or cy < 1 or cx > model.width or cy > model.height then return "wall" end
    return model.tiles[(cy - 1) * model.width + cx]
end

function M.is_blocked(model, x, y)
    local cx, cy = M.cell(model, x, y)
    local tile = M.tile(model, cx, cy)
    return tile == "wall" or tile == "door_closed"
end

function M.move_multiplier(model, x, y)
    local cx, cy = M.cell(model, x, y)
    local def = model.tile_defs[M.tile(model, cx, cy)] or {}
    return tonumber(def.move_multiplier) or 1
end

function M.toggle_doors(model)
    for i, tile in ipairs(model.tiles) do
        if tile == "door_closed" then
            model.tiles[i] = "door_open"
        elseif tile == "door_open" then
            model.tiles[i] = "door_closed"
        end
    end
    model.lights_dirty = true
end

function M.update_smoke(model, dt)
    for i = #model.smoke, 1, -1 do
        model.smoke[i].left = model.smoke[i].left - dt
        if model.smoke[i].left <= 0 then table.remove(model.smoke, i) end
    end
end

return M
