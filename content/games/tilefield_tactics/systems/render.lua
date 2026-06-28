local M = {}

local CELL = 34
local ORIGIN_X = 34
local ORIGIN_Y = 86

local COLORS = {
    empty = { 0.16, 0.19, 0.22 },
    wall = { 0.34, 0.34, 0.39 },
    window = { 0.22, 0.40, 0.52 },
    door_closed = { 0.47, 0.27, 0.20 },
    door_open = { 0.22, 0.34, 0.25 },
    half_wall = { 0.39, 0.38, 0.30 },
}

local function layer_index(model, x, y)
    return (y - 1) * model.width + x
end

local function profile_at(model, x, y, z)
    local layer = model.field:exportProfileLayer(z)
    return layer[layer_index(model, x, y)] or "empty"
end

local function in_range(model, id, x, y)
    local range = model.ranges and model.ranges[id]
    return range and range[layer_index(model, x, y)] ~= nil
end

local function draw_grid(model, selected)
    local z = model.active_level
    for y = 1, model.height do
        for x = 1, model.width do
            local profile = profile_at(model, x, y, z)
            local light = model.light and model.light[layer_index(model, x, y)] or { luma = 0 }
            local color = COLORS[profile] or COLORS.empty
            local boost = 0.5 + math.min(0.5, light.luma or 0)
            local px = ORIGIN_X + (x - 1) * CELL
            local py = ORIGIN_Y + (y - 1) * CELL
            lurek.render.setColor(color[1] * boost, color[2] * boost, color[3] * boost, 1)
            lurek.render.rectangle("fill", px, py, CELL - 2, CELL - 2)
            if in_range(model, selected, x, y) then
                lurek.render.setColor(0.22, 0.78, 0.52, 0.34)
                lurek.render.rectangle("fill", px + 4, py + 4, CELL - 10, CELL - 10)
            end
            if model.visibility and model.visibility:canActOn(selected, x, y, z) then
                lurek.render.setColor(0.95, 0.75, 0.20, 0.42)
                lurek.render.rectangle("line", px + 6, py + 6, CELL - 14, CELL - 14)
            end
            lurek.render.setColor(0.06, 0.07, 0.09, 1)
            lurek.render.rectangle("line", px, py, CELL - 2, CELL - 2)
        end
    end
end

local function draw_units(model, selected)
    for id, unit in pairs(model.units) do
        if unit.z == model.active_level then
            local px = ORIGIN_X + (unit.x - 0.5) * CELL
            local py = ORIGIN_Y + (unit.y - 0.5) * CELL
            if id == "p1" then
                lurek.render.setColor(0.25, 0.62, 1.0, 1)
            else
                lurek.render.setColor(1.0, 0.34, 0.34, 1)
            end
            lurek.render.circle("fill", px, py, selected == id and 12 or 9)
            lurek.render.setColor(1, 1, 1, 0.9)
            lurek.render.circle("line", px, py, selected == id and 15 or 12)
        end
    end
end

local function build_minimap(model, selected)
    local mm = lurek.minimap.newMinimap(model.width, model.height, 144, 144)
    mm:setTerrainColor(0, 0.12, 0.15, 0.18, 1)
    mm:setTerrainColor(1, 0.40, 0.39, 0.43, 1)
    mm:setTerrainColor(2, 0.18, 0.34, 0.45, 1)
    mm:setTerrainColor(3, 0.42, 0.28, 0.18, 1)
    local terrain = {}
    local fog = {}
    local light = {}
    local profiles = model.field:exportProfileLayer(model.active_level)
    local light_layer = model.light or {}
    for i = 1, model.width * model.height do
        local profile = profiles[i] or "empty"
        terrain[i] = profile == "wall" and 1 or profile == "window" and 2 or profile:find("door") and 3 or 0
        local x = ((i - 1) % model.width) + 1
        local y = math.floor((i - 1) / model.width) + 1
        fog[i] = model.visibility and model.visibility:isVisible(selected, x, y, model.active_level) and 2 or 0
        light[i] = math.floor(((light_layer[i] and light_layer[i].luma) or 0) * 9 + 0.5)
    end
    mm:setFogEnabled(true)
    mm:setTerrainData(terrain)
    mm:setFogData(fog)
    mm:setLayerData(1, light)
    return mm
end

function M.prepare(model)
    local ok, quads = pcall(function()
        return lurek.raycaster.buildMultiLevelSceneFromField({
            px = 3.5, py = 3.5, angle = 0, fov = 1.0, rays = 64,
            max_dist = 12, screen_w = 180, screen_h = 110, active_level = model.active_level - 1,
        }, model.field, { wallChannel = "vision", levelRange = { 1, model.levels } })
    end)
    model.raycaster_quads = ok and quads or 0
end

function M.draw(model, selected, message)
    lurek.render.setColor(0.035, 0.04, 0.052, 1)
    lurek.render.rectangle("fill", 0, 0, 960, 600)
    draw_grid(model, selected)
    draw_units(model, selected)

    local mm = build_minimap(model, selected)
    local mini_image = lurek.render.newImage(mm:drawToImage(8))
    lurek.render.draw(mini_image, 510, 92, 0, 1, 1)

    lurek.render.setColor(0.10, 0.12, 0.15, 1)
    lurek.render.rectangle("fill", 510, 260, 310, 110)
    lurek.render.setColor(0.78, 0.84, 0.90, 1)
    lurek.render.print("Raycaster input quads: " .. tostring(model.raycaster_quads), 526, 282)
    lurek.render.print("Door: " .. model.door_profile, 526, 308)
    lurek.render.print(message or "", 526, 334)
end

function M.draw_ui(model, selected)
    lurek.render.setColor(0.92, 0.95, 0.98, 1)
    lurek.render.print("Tilefield Tactics", 34, 26)
    lurek.render.print("WASD move  Tab player  Space door  Q/E level  R reset", 34, 50)
    lurek.render.print("Selected: " .. selected .. "  Level: " .. tostring(model.active_level), 510, 50)
end

return M
