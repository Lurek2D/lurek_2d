local M = {}

local MM_GRID_W = 120
local MM_GRID_H = 54
local MM_W = 184
local MM_H = 86
local MAP_W = 1000
local MAP_H = 450
local PIXEL_SIZE = 8

local widgets = nil
local minimap = nil
local minimap_revision = -1
local owner_terrain_types = {}
local army_object_type = 1

local function country_name(state, tag)
    local c = state.countries[tag]
    return c and c.name or tostring(tag or "-")
end

local function speed_label(state)
    if state.paused then
        return "Paused"
    end
    local speeds = { 0, 1, 2, 4 }
    return tostring(speeds[state.speed_index] or 1) .. "x"
end

local function province_line(state, province)
    if not province then
        return "No province selected"
    end
    return string.format("%s | %s | income:%s | unrest:%.1f",
        province.name,
        country_name(state, province.owner),
        tostring(province.income or 0),
        province.unrest or 0)
end

local function selected_army(state)
    for _, army in ipairs(state.armies) do
        if army.id == state.selected_army_id then
            return army
        end
    end
    return nil
end

local function call(widget, method, ...)
    if widget and widget[method] then
        widget[method](widget, ...)
    end
end

local function label(text, color)
    local w = lurek.ui.newLabel(text or "")
    call(w, "setColor", color[1], color[2], color[3], color[4] or 1)
    call(w, "setTextEllipsis", true)
    return w
end

local function panel(alpha)
    local w = lurek.ui.newPanel()
    call(w, "setAlpha", alpha or 0.82)
    return w
end

local function place(w, x, y, width, height, text)
    call(w, "setPosition", x, y)
    call(w, "setSize", width, height)
    if text ~= nil then
        call(w, "setText", text)
    end
end

local function ensure_widgets()
    if widgets then
        return
    end
    if lurek.ui.clear then
        lurek.ui.clear()
    end
    if lurek.ui.setDefaultTheme then
        lurek.ui.setDefaultTheme()
    end
    widgets = {
        top_panel = panel(0.88),
        side_panel = panel(0.84),
        log_panel = panel(0.84),
        minimap_panel = panel(0.84),
        title = label("Europa Universalis 2 Lite", { 0.95, 0.90, 0.78, 1 }),
        status = label("", { 0.80, 0.84, 0.88, 1 }),
        controls = label("", { 0.72, 0.76, 0.78, 1 }),
        mode = label("", { 0.95, 0.84, 0.42, 1 }),
        province_title = label("Province", { 0.95, 0.86, 0.58, 1 }),
        province_line = label("", { 0.88, 0.90, 0.92, 1 }),
        province_stats = label("", { 0.84, 0.86, 0.88, 1 }),
        province_neighbors = label("", { 0.84, 0.86, 0.88, 1 }),
        hover_title = label("Hover", { 0.55, 0.70, 0.95, 1 }),
        hover_line = label("", { 0.80, 0.82, 0.84, 1 }),
        army_title = label("Selected army", { 0.95, 0.86, 0.58, 1 }),
        army_line = label("", { 0.88, 0.90, 0.92, 1 }),
        army_pos = label("", { 0.88, 0.90, 0.92, 1 }),
        log_title = label("Campaign log", { 0.95, 0.86, 0.58, 1 }),
        log_lines = {},
    }
    for i = 1, 4 do
        widgets.log_lines[i] = label("", { 0.82, 0.84, 0.86, 1 })
    end
    local root = lurek.ui.getRoot and lurek.ui.getRoot()
    if root and root.addChild then
        local ordered = {
            widgets.top_panel,
            widgets.side_panel,
            widgets.log_panel,
            widgets.minimap_panel,
            widgets.title,
            widgets.status,
            widgets.controls,
            widgets.mode,
            widgets.province_title,
            widgets.province_line,
            widgets.province_stats,
            widgets.province_neighbors,
            widgets.hover_title,
            widgets.hover_line,
            widgets.army_title,
            widgets.army_line,
            widgets.army_pos,
            widgets.log_title,
        }
        for _, w in ipairs(ordered) do
            root:addChild(w)
        end
        for _, w in ipairs(widgets.log_lines) do
            root:addChild(w)
        end
    end
end

local function terrain_type_for_owner(state, owner)
    owner = owner or "SEA"
    local idx = owner_terrain_types[owner]
    if idx then
        return idx
    end
    idx = 1
    for _ in pairs(owner_terrain_types) do
        idx = idx + 1
    end
    owner_terrain_types[owner] = idx
    local country = state.countries[owner] or state.countries.NEU or { color = { 0.45, 0.45, 0.45, 1 } }
    local c = country.color or { 0.45, 0.45, 0.45, 1 }
    if owner == "SEA" then
        c = { 0.16, 0.36, 0.58, 1 }
    end
    minimap:setTerrainColor(idx, c[1], c[2], c[3], c[4] or 1)
    return idx
end

local function build_minimap(state)
    if minimap and minimap_revision == state.style_revision then
        return
    end
    minimap = lurek.minimap.newMinimap(MM_GRID_W, MM_GRID_H, MM_W, MM_H)
    minimap:setColorMode("terrain")
    owner_terrain_types = {}
    army_object_type = minimap:addObjectType("army", 1.0, 0.88, 0.28, 1.0)

    for y = 1, MM_GRID_H do
        for x = 1, MM_GRID_W do
            local map_x = math.floor((x - 0.5) * MAP_W / MM_GRID_W)
            local map_y = math.floor((y - 0.5) * MAP_H / MM_GRID_H)
            local gid = state.reg:getAt(map_x, map_y)
            local province = state.provinces[gid]
            local owner = province and province.owner or "SEA"
            minimap:setTerrain(x, y, terrain_type_for_owner(state, owner))
        end
    end
    minimap_revision = state.style_revision
end

local function update_minimap(state, view, ww, hh)
    build_minimap(state)
    minimap:clearObjects()
    for _, army in ipairs(state.armies) do
        local province = state.provinces[army.province_id]
        if province and province.cx and province.cy then
            local x = 1 + province.cx / MAP_W * MM_GRID_W
            local y = 1 + province.cy / MAP_H * MM_GRID_H
            minimap:setObject(army.id, x, y, army_object_type)
        end
    end

    local visible_w = ww / math.max(0.001, PIXEL_SIZE * view.cam.zoom)
    local visible_h = hh / math.max(0.001, PIXEL_SIZE * view.cam.zoom)
    local map_x = -view.cam.x / math.max(0.001, PIXEL_SIZE * view.cam.zoom)
    local map_y = -view.cam.y / math.max(0.001, PIXEL_SIZE * view.cam.zoom)
    minimap:setViewportRect(
        1 + map_x / MAP_W * MM_GRID_W,
        1 + map_y / MAP_H * MM_GRID_H,
        visible_w / MAP_W * MM_GRID_W,
        visible_h / MAP_H * MM_GRID_H)
end

local function update_layout(state, view, hovered_gid, selected_gid)
    local ww, hh = lurek.window.getDimensions()
    if lurek.ui.setViewport then
        lurek.ui.setViewport(ww, hh)
    end
    if lurek.ui.updateResolution then
        lurek.ui.updateResolution(ww, hh)
    end

    local player = state.countries[state.player_tag]
    local side_x = math.max(ww - 326, 320)
    local side_h = math.max(320, hh - 142)
    local log_w = math.max(320, ww - 350)
    local mini_x = ww - MM_W - 24
    local mini_y = hh - MM_H - 20

    place(widgets.top_panel, 0, 0, ww, 54)
    place(widgets.title, 12, 8, 360, 18, "Europa Universalis 2 Lite - playable province slice")
    place(widgets.status, 12, 28, 480, 18, string.format("%s   %s   Treasury:%d   Manpower:%d   Stability:%d",
        state:date_string(),
        speed_label(state),
        player and player.treasury or 0,
        player and player.manpower or 0,
        player and player.stability or 0))
    place(widgets.controls, 520, 28, math.max(260, ww - 540), 18, "1 Political  2 Terrain  3 Economy  4 Diplomacy  5 Unrest   Space pause   RMB move   F12 debug")
    place(widgets.mode, 520, 8, 220, 18, "Map: " .. tostring(view.map_mode) .. (view.debug_mode and " | Debug" or ""))

    place(widgets.side_panel, side_x, 62, 318, side_h)
    place(widgets.province_title, side_x + 12, 74, 280, 18, "Province")
    local selected = state.provinces[selected_gid or state.selected_province_id]
    local hovered = state.provinces[hovered_gid]
    place(widgets.province_line, side_x + 12, 96, 290, 18, province_line(state, selected))
    if selected then
        place(widgets.province_stats, side_x + 12, 118, 290, 18,
            "Terrain: " .. tostring(selected.terrain) .. " | Goods: " .. tostring(selected.goods))
        place(widgets.province_neighbors, side_x + 12, 140, 290, 18,
            "Manpower: " .. tostring(selected.manpower) .. " | Fort: " .. tostring(selected.fort) .. " | Neighbors: " .. tostring(#(selected.neighbors or {})))
    else
        place(widgets.province_stats, side_x + 12, 118, 290, 18, "")
        place(widgets.province_neighbors, side_x + 12, 140, 290, 18, "")
    end
    place(widgets.hover_title, side_x + 12, 190, 280, 18, "Hover")
    place(widgets.hover_line, side_x + 12, 212, 290, 18, province_line(state, hovered))

    local army = selected_army(state)
    place(widgets.army_title, side_x + 12, 252, 280, 18, "Selected army")
    if army then
        local here = state.provinces[army.province_id]
        local target = state.provinces[army.target_id]
        place(widgets.army_line, side_x + 12, 274, 290, 18, army.name .. " (" .. country_name(state, army.tag) .. ")")
        if target then
            place(widgets.army_pos, side_x + 12, 296, 290, 18,
                string.format("Size:%d | At:%s | ETA %.1f to %s", army.size, here and here.name or "-", math.max(0, army.eta), target.name))
        else
            place(widgets.army_pos, side_x + 12, 296, 290, 18,
                "Size:" .. tostring(army.size) .. " | At:" .. (here and here.name or "-"))
        end
    else
        place(widgets.army_line, side_x + 12, 274, 290, 18, "No player army selected.")
        place(widgets.army_pos, side_x + 12, 296, 290, 18, "")
    end

    place(widgets.log_panel, 8, hh - 104, log_w, 96)
    place(widgets.log_title, 18, hh - 96, 260, 18, "Campaign log")
    for i = 1, 4 do
        place(widgets.log_lines[i], 18, hh - 96 + i * 18, log_w - 20, 18, state.log[i] or "")
    end
    place(widgets.minimap_panel, mini_x - 6, mini_y - 8, MM_W + 12, MM_H + 16)

    update_minimap(state, view, ww, hh)
    return mini_x, mini_y
end

function M.draw(state, view, hovered_gid, selected_gid)
    ensure_widgets()
    local mini_x, mini_y = update_layout(state, view, hovered_gid, selected_gid)
    if lurek.ui.update then
        lurek.ui.update(0)
    end
    lurek.ui.draw()
    minimap:render(mini_x, mini_y)
end

return M
