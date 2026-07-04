local M = {}

local R = lurek.render

local MM_GRID_W = 180
local MM_GRID_H = 81
local PIXEL_SIZE = 8

local minimap = nil
local minimap_key = nil
local minimap_colors = nil
local next_minimap_color = 1
local army_object_type = 1

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

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

local function selected_army(state)
    for _, army in ipairs(state.armies) do
        if army.id == state.selected_army_id then
            return army
        end
    end
    return nil
end

local function draw_panel(x, y, w, h, alpha)
    R.setColor(0.08, 0.055, 0.035, alpha or 0.88)
    R.rectangle("fill", x, y, w, h)
    R.setColor(0.56, 0.39, 0.20, 0.95)
    R.rectangle("line", x, y, w, h)
    R.setColor(0.86, 0.68, 0.38, 0.35)
    R.rectangle("line", x + 2, y + 2, math.max(0, w - 4), math.max(0, h - 4))
end

local function draw_paper_panel(x, y, w, h)
    R.setColor(0.82, 0.70, 0.50, 0.94)
    R.rectangle("fill", x, y, w, h)
    R.setColor(0.30, 0.19, 0.10, 0.95)
    R.rectangle("line", x, y, w, h)
    R.setColor(0.98, 0.89, 0.67, 0.32)
    R.rectangle("line", x + 3, y + 3, math.max(0, w - 6), math.max(0, h - 6))
end

local function draw_text(text, x, y, scale, color)
    local c = color or { 0.95, 0.90, 0.78, 1 }
    R.setColor(c[1], c[2], c[3], c[4] or 1)
    R.print(tostring(text or ""), x, y, scale or 1)
end

local function draw_button(x, y, w, h, text, active)
    if active then
        R.setColor(0.48, 0.17, 0.13, 0.94)
    else
        R.setColor(0.19, 0.15, 0.10, 0.92)
    end
    R.rectangle("fill", x, y, w, h)
    R.setColor(0.77, 0.58, 0.32, 0.92)
    R.rectangle("line", x, y, w, h)
    draw_text(text, x + 5, y + 4, 0.92, { 0.98, 0.89, 0.68, 1 })
end

local function color_key(c)
    return string.format("%d:%d:%d:%d",
        math.floor(clamp(c[1] or 0, 0, 1) * 255 + 0.5),
        math.floor(clamp(c[2] or 0, 0, 1) * 255 + 0.5),
        math.floor(clamp(c[3] or 0, 0, 1) * 255 + 0.5),
        math.floor(clamp(c[4] or 1, 0, 1) * 255 + 0.5))
end

local function terrain_type_for_color(c)
    local key = color_key(c)
    local idx = minimap_colors[key]
    if idx then
        return idx
    end
    idx = next_minimap_color
    next_minimap_color = next_minimap_color + 1
    minimap_colors[key] = idx
    minimap:setTerrainColor(idx, c[1], c[2], c[3], c[4] or 1)
    return idx
end

local function province_color(state, province, mode, map_modes)
    if map_modes and map_modes.province_color then
        return map_modes.province_color(state, province, mode)
    end
    local country = province and state.countries[province.owner] or state.countries.SEA
    return (country and country.color) or { 0.18, 0.38, 0.60, 1 }
end

local function build_minimap(state, view, map_modes, display_w, display_h)
    local map_w = state.reg:getWidth()
    local map_h = state.reg:getHeight()
    local key = table.concat({
        tostring(view.map_mode),
        tostring(state.revision or 0),
        tostring(state.style_revision or 0),
        tostring(display_w),
        tostring(display_h),
    }, ":")
    if minimap and minimap_key == key then
        return map_w, map_h
    end

    minimap = lurek.minimap.newMinimap(MM_GRID_W, MM_GRID_H, display_w, display_h)
    minimap:setColorMode("terrain")
    minimap_colors = {}
    next_minimap_color = 1
    army_object_type = minimap:addObjectType("army", 1.0, 0.86, 0.26, 1.0)

    for y = 1, MM_GRID_H do
        for x = 1, MM_GRID_W do
            local map_x = math.floor((x - 0.5) * map_w / MM_GRID_W)
            local map_y = math.floor((y - 0.5) * map_h / MM_GRID_H)
            local gid = state.reg:getAt(map_x, map_y)
            local province = state.provinces[gid]
            minimap:setTerrain(x, y, terrain_type_for_color(province_color(state, province, view.map_mode, map_modes)))
        end
    end
    minimap_key = key
    return map_w, map_h
end

local function update_minimap(state, view, map_modes, display_w, display_h)
    local map_w, map_h = build_minimap(state, view, map_modes, display_w, display_h)
    minimap:clearObjects()
    for _, army in ipairs(state.armies) do
        local province = state.provinces[army.province_id]
        if province and province.cx and province.cy then
            local x = 1 + province.cx / map_w * MM_GRID_W
            local y = 1 + province.cy / map_h * MM_GRID_H
            minimap:setObject(army.id, x, y, army_object_type)
        end
    end

    local ww, hh = lurek.window.getDimensions()
    if state.reg.viewportRect then
        local rect = state.reg:viewportRect({
            x = view.cam.x,
            y = view.cam.y,
            zoom = view.cam.zoom,
            pixel_size = PIXEL_SIZE,
            screen_w = ww,
            screen_h = hh,
        })
        minimap:setViewportRect(
            1 + rect.x / map_w * MM_GRID_W,
            1 + rect.y / map_h * MM_GRID_H,
            rect.w / map_w * MM_GRID_W,
            rect.h / map_h * MM_GRID_H)
    end
end

local function minimap_size(ww, hh)
    local w = math.floor(clamp(ww * 0.15, 142, 190))
    if hh < 560 then
        w = math.floor(clamp(ww * 0.13, 124, 160))
    end
    return w, math.floor(w * 0.47)
end

local function draw_top_bar(state, view, ww)
    local player = state.countries[state.player_tag]
    draw_panel(6, 6, math.min(410, ww - 18), 48, 0.94)
    R.setColor(0.68, 0.10, 0.12, 1)
    R.rectangle("fill", 14, 12, 34, 34)
    R.setColor(0.96, 0.92, 0.82, 1)
    R.rectangle("line", 14, 12, 34, 34)
    draw_text("KINGDOM OF POLAND", 58, 13, 1.0, { 1.0, 0.92, 0.74, 1 })
    draw_text("Poland | " .. tostring(country_name(state, state.player_tag)), 58, 33, 0.82, { 0.78, 0.84, 0.90, 1 })

    local date_w = 218
    local date_x = math.max(430, math.floor((ww - date_w) * 0.5))
    if date_x + date_w < ww - 250 then
        draw_panel(date_x, 8, date_w, 48, 0.94)
        draw_text(state:date_string(), date_x + 68, 14, 0.98, { 1.0, 0.92, 0.74, 1 })
        draw_text("Treasury: " .. tostring(player and player.treasury or 0) .. "   Manpower: " .. tostring(player and player.manpower or 0),
            date_x + 16, 34, 0.78, { 0.88, 0.86, 0.76, 1 })
    end

    local stat_w = math.min(314, math.max(220, ww - 742))
    local stat_x = ww - stat_w - 8
    if stat_x > 650 then
        draw_panel(stat_x, 8, stat_w, 48, 0.94)
        draw_text("Stability: " .. tostring(player and player.stability or 0), stat_x + 12, 16, 0.84, { 0.74, 1.0, 0.64, 1 })
        draw_text("Speed: " .. speed_label(state) .. "   Map: " .. tostring(view.map_mode), stat_x + 12, 34, 0.78, { 0.96, 0.86, 0.64, 1 })
    end
end

local function draw_side_panel(state, hovered_gid, selected_gid, ww, hh)
    if ww < 720 or hh < 480 then
        return
    end
    local selected = state.provinces[selected_gid or state.selected_province_id]
    local hovered = state.provinces[hovered_gid]
    local panel_w = math.floor(clamp(ww * 0.23, 250, 306))
    local panel_h = math.floor(clamp(hh * 0.34, 210, 278))
    draw_paper_panel(8, 68, panel_w, panel_h)
    draw_text(selected and string.upper(selected.name) or "NO PROVINCE", 22, 84, 0.96, { 0.08, 0.06, 0.04, 1 })
    if selected then
        draw_text(country_name(state, selected.owner) .. " | " .. tostring(selected.terrain), 22, 106, 0.78, { 0.10, 0.07, 0.04, 1 })
        draw_text("Goods: " .. tostring(selected.goods) .. "   Income: " .. tostring(selected.income or 0), 22, 124, 0.78, { 0.10, 0.07, 0.04, 1 })
        draw_text("Manpower: " .. tostring(selected.manpower or 0) .. "   Fort: " .. tostring(selected.fort or 0), 22, 142, 0.78, { 0.10, 0.07, 0.04, 1 })
        draw_text("Unrest: " .. string.format("%.1f", selected.unrest or 0) .. "   Neighbors: " .. tostring(#(selected.neighbors or {})), 22, 160, 0.78, { 0.10, 0.07, 0.04, 1 })
    end
    R.setColor(0.28, 0.19, 0.10, 0.70)
    R.rectangle("fill", 18, 184, panel_w - 20, 1)
    draw_text("Hover: " .. (hovered and hovered.name or "-"), 22, 198, 0.76, { 0.10, 0.07, 0.04, 1 })

    local army = selected_army(state)
    draw_text("Selected army", 22, 226, 0.88, { 0.10, 0.07, 0.04, 1 })
    if army then
        local here = state.provinces[army.province_id]
        local target = state.provinces[army.target_id]
        draw_text(army.name .. " | " .. tostring(math.floor(army.size / 1000)) .. "k", 22, 246, 0.76, { 0.10, 0.07, 0.04, 1 })
        draw_text((here and here.name or "-") .. (target and (" -> " .. target.name) or ""), 22, 264, 0.72, { 0.10, 0.07, 0.04, 1 })
    else
        draw_text("No player army selected", 22, 246, 0.76, { 0.10, 0.07, 0.04, 1 })
    end
end

local function draw_mode_panel(view, ww)
    if ww < 760 then
        return
    end
    local x = ww - 244
    local y = 66
    draw_panel(x, y, 236, 86, 0.92)
    local modes = {
        { "1", "political" },
        { "2", "terrain" },
        { "3", "economy" },
        { "4", "diplomacy" },
        { "5", "unrest" },
    }
    for i, mode in ipairs(modes) do
        draw_button(x + 10 + (i - 1) * 43, y + 12, 34, 28, mode[1], view.map_mode == mode[2])
    end
    draw_text("L labels  Space pause  RMB move", x + 12, y + 54, 0.72, { 0.82, 0.83, 0.78, 1 })
    draw_text("F12 roads  R reset  Tab armies", x + 12, y + 70, 0.72, { 0.82, 0.83, 0.78, 1 })
end

local function draw_log_panel(state, ww, hh, mini_x, mini_y)
    local log_h = 92
    local log_w = math.max(280, mini_x - 22)
    local x = 8
    local y = hh - log_h - 8
    if log_w < 300 then
        log_w = ww - 16
        y = math.max(62, mini_y - log_h - 10)
    end
    draw_panel(x, y, log_w, log_h, 0.78)
    draw_text("Campaign log", x + 12, y + 8, 0.82, { 1.0, 0.89, 0.62, 1 })
    for i = 1, 4 do
        draw_text(state.log[i] or "", x + 14, y + 10 + i * 17, 0.70, { 0.88, 0.90, 0.86, 1 })
    end
end

function M.draw(state, view, hovered_gid, selected_gid, map_modes)
    local ww, hh = lurek.window.getDimensions()
    local mini_w, mini_h = minimap_size(ww, hh)
    local mini_x = ww - mini_w - 16
    local mini_y = hh - mini_h - 18

    draw_top_bar(state, view, ww)
    draw_side_panel(state, hovered_gid, selected_gid, ww, hh)
    draw_mode_panel(view, ww)
    draw_log_panel(state, ww, hh, mini_x, mini_y)

    draw_panel(mini_x - 6, mini_y - 8, mini_w + 12, mini_h + 16, 0.88)
    update_minimap(state, view, map_modes, mini_w, mini_h)
    minimap:render(mini_x, mini_y)
    R.setColor(1, 1, 1, 1)
end

return M
