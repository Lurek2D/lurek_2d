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
local MODE_BUTTONS = {
    { key = "1", mode = "political", label = "POL" },
    { key = "2", mode = "terrain", label = "TER" },
    { key = "3", mode = "economy", label = "ECO" },
    { key = "4", mode = "diplomacy", label = "DIP" },
    { key = "5", mode = "unrest", label = "UNR" },
}

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

local function font_for(view, key)
    return view and view.fonts and view.fonts[key] or nil
end

local function set_font(view, key)
    local font = font_for(view, key)
    if font then
        R.setFont(font)
    end
    return font
end

local function text_width(view, key, text, scale)
    local font = font_for(view, key)
    local factor = scale or 1
    if font and font.getWidth then
        return font:getWidth(tostring(text or "")) * factor
    end
    return #tostring(text or "") * 6 * factor
end

local function draw_text(view, key, text, x, y, scale, color, shadow_color)
    set_font(view, key)
    local s = scale or 1
    local value = tostring(text or "")
    local shadow = shadow_color
    if shadow == nil then
        shadow = { 0.05, 0.04, 0.03, 0.85 }
    end
    if shadow ~= false then
        R.setColor(shadow[1], shadow[2], shadow[3], shadow[4] or 1)
        R.print(value, x + 1, y + 1, s)
    end
    local c = color or { 0.95, 0.90, 0.78, 1 }
    R.setColor(c[1], c[2], c[3], c[4] or 1)
    R.print(value, x, y, s)
end

local function draw_panel(x, y, w, h, alpha)
    R.setColor(0.12, 0.10, 0.07, alpha or 0.90)
    R.rectangle("fill", x + 2, y + 3, w, h)
    R.setColor(0.29, 0.24, 0.19, 0.92)
    R.rectangle("fill", x, y, w, h)
    R.setColor(0.70, 0.56, 0.32, 0.94)
    R.rectangle("line", x, y, w, h)
    R.setColor(0.88, 0.75, 0.48, 0.25)
    R.rectangle("line", x + 2, y + 2, math.max(0, w - 4), math.max(0, h - 4))
end

local function draw_paper_panel(x, y, w, h)
    R.setColor(0.16, 0.12, 0.08, 0.26)
    R.rectangle("fill", x + 3, y + 4, w, h)
    R.setColor(0.88, 0.82, 0.69, 0.96)
    R.rectangle("fill", x, y, w, h)
    R.setColor(0.34, 0.25, 0.14, 0.96)
    R.rectangle("line", x, y, w, h)
    R.setColor(0.96, 0.91, 0.79, 0.33)
    R.rectangle("line", x + 3, y + 3, math.max(0, w - 6), math.max(0, h - 6))
end

local function draw_divider(x, y, w, dark)
    local c = dark and { 0.32, 0.24, 0.14, 0.78 } or { 0.74, 0.63, 0.40, 0.42 }
    R.setColor(c[1], c[2], c[3], c[4])
    R.rectangle("fill", x, y, w, 1)
end

local function draw_button(view, x, y, w, h, text, active)
    if active then
        R.setColor(0.62, 0.38, 0.20, 0.98)
    else
        R.setColor(0.34, 0.27, 0.18, 0.96)
    end
    R.rectangle("fill", x, y, w, h)
    R.setColor(0.82, 0.66, 0.39, 0.92)
    R.rectangle("line", x, y, w, h)
    local label_w = text_width(view, "small", text, 1.0)
    draw_text(view, "small", text, x + (w - label_w) * 0.5, y + 4, 1.0, { 0.98, 0.92, 0.78, 1 })
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
    if not province then
        return { 0.0, 0.0, 0.0, 1.0 }
    end
    if map_modes and map_modes.province_color then
        return map_modes.province_color(state, province, mode)
    end
    local country = state.countries[province.owner] or state.countries.SEA
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
    army_object_type = minimap:addObjectType("army", 0.98, 0.84, 0.28, 1.0)

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

    draw_panel(8, 8, math.min(360, ww - 20), 56, 0.94)
    R.setColor(0.66, 0.19, 0.18, 0.98)
    R.rectangle("fill", 16, 14, 32, 38)
    R.setColor(0.96, 0.88, 0.68, 0.92)
    R.rectangle("line", 16, 14, 32, 38)
    draw_text(view, "small", string.upper(player and player.name or "STATE"), 58, 12, 1.03, { 0.98, 0.94, 0.82, 1 })
    draw_text(view, "small", player and player.ruler or country_name(state, state.player_tag), 58, 34, 1.0, { 0.84, 0.84, 0.82, 1 })

    local date_w = 248
    local date_x = math.max(358, math.floor((ww - date_w) * 0.5))
    if date_x + date_w < ww - 276 then
        draw_panel(date_x, 8, date_w, 56, 0.94)
        local date_label = state.date_string and state:date_string() or "Jan 1419"
        local date_w_label = text_width(view, "ui", date_label, 1.0)
        draw_text(view, "ui", date_label, date_x + (date_w - date_w_label) * 0.5, 11, 1.02, { 0.98, 0.94, 0.82, 1 })
        draw_text(view, "small",
            "Gold: " .. tostring(player and player.treasury or 0) .. "   Manpower: " .. tostring(player and player.manpower or 0),
            date_x + 14, 36, 0.98, { 0.87, 0.86, 0.79, 1 })
    end

    local stat_w = math.min(290, math.max(230, ww - 768))
    local stat_x = ww - stat_w - 10
    if stat_x > 670 then
        draw_panel(stat_x, 8, stat_w, 56, 0.94)
        draw_text(view, "small",
            "Stability: " .. tostring(player and player.stability or 0) .. "   Speed: " .. speed_label(state),
            stat_x + 12, 12, 0.98, { 0.88, 0.94, 0.74, 1 })
        draw_text(view, "small",
            "Map Mode: " .. tostring(view.map_mode),
            stat_x + 12, 36, 0.98, { 0.94, 0.88, 0.70, 1 })
    end
end

local function draw_side_panel(state, view, hovered_gid, selected_gid, ww, hh)
    if ww < 720 or hh < 500 then
        return
    end
    local selected = state.provinces[selected_gid or state.selected_province_id]
    local hovered = state.provinces[hovered_gid]
    local panel_w = math.floor(clamp(ww * 0.22, 240, 280))
    local panel_h = math.floor(clamp(hh * 0.36, 228, 292))
    local x = 8
    local y = 72

    draw_paper_panel(x, y, panel_w, panel_h)
    draw_text(view, "ui", selected and string.upper(selected.name) or "NO PROVINCE", x + 16, y + 12, 1.08, { 0.14, 0.10, 0.06, 1 }, false)
    draw_text(view, "small",
        selected and (country_name(state, selected.owner) .. " (Province)") or "Unclaimed province",
        x + 16, y + 38, 0.92, { 0.20, 0.13, 0.08, 1 }, false)
    draw_divider(x + 12, y + 58, panel_w - 24, true)

    if selected then
        draw_text(view, "small", "Terrain: " .. tostring(selected.terrain) .. " | Goods: " .. tostring(selected.goods), x + 16, y + 70, 1.0, { 0.17, 0.12, 0.08, 1 }, false)
        draw_text(view, "small", "Income: " .. tostring(selected.income or 0) .. " | Fort: " .. tostring(selected.fort or 0), x + 16, y + 92, 1.0, { 0.17, 0.12, 0.08, 1 }, false)
        draw_text(view, "small", "Manpower: " .. tostring(selected.manpower or 0) .. " | Unrest: " .. string.format("%.1f", selected.unrest or 0), x + 16, y + 114, 1.0, { 0.17, 0.12, 0.08, 1 }, false)
        draw_text(view, "small", "Neighbors: " .. tostring(#(selected.neighbors or {})), x + 16, y + 136, 1.0, { 0.17, 0.12, 0.08, 1 }, false)
    end

    draw_divider(x + 12, y + 146, panel_w - 24, true)
    draw_text(view, "small", "SELECTED ARMY", x + 16, y + 156, 0.95, { 0.14, 0.10, 0.06, 1 }, false)

    local army = selected_army(state)
    if army then
        local here = state.provinces[army.province_id]
        local target = state.provinces[army.target_id]
        draw_text(view, "small", army.name .. " (" .. tostring(math.floor(army.size / 1000)) .. ",000 men)", x + 16, y + 178, 0.98, { 0.17, 0.12, 0.08, 1 }, false)
        draw_text(view, "small", "Current: " .. (here and here.name or "-"), x + 16, y + 200, 0.98, { 0.17, 0.12, 0.08, 1 }, false)
        draw_text(view, "small", "Orders: " .. (target and ("Marching to " .. target.name) or "Holding position"), x + 16, y + 222, 0.98, { 0.17, 0.12, 0.08, 1 }, false)
    else
        draw_text(view, "small", "No player army selected", x + 16, y + 178, 0.98, { 0.17, 0.12, 0.08, 1 }, false)
    end

    draw_divider(x + 12, y + panel_h - 36, panel_w - 24, true)
    draw_text(view, "small", "Hover: " .. (hovered and hovered.name or "-"), x + 16, y + panel_h - 28, 0.98, { 0.17, 0.12, 0.08, 1 }, false)
end

local function draw_mode_panel(view, ww)
    if ww < 760 then
        return
    end
    local x = ww - 330
    local y = 68
    draw_panel(x, y, 320, 128, 0.92)
    draw_text(view, "small", "MAP MODES", x + 14, y + 10, 1.0, { 0.99, 0.93, 0.78, 1 })
    for i, mode in ipairs(MODE_BUTTONS) do
        draw_button(view, x + 14 + (i - 1) * 53, y + 34, 42, 28, mode.key, view.map_mode == mode.mode)
    end
    draw_text(view, "small", "L labels   Space pause", x + 14, y + 72, 1.0, { 0.82, 0.84, 0.80, 1 })
    draw_text(view, "small", "RMB move   F12 roads", x + 14, y + 90, 1.0, { 0.82, 0.84, 0.80, 1 })
    draw_text(view, "small", "X stripes   R reset   Tab army", x + 14, y + 108, 1.0, { 0.82, 0.84, 0.80, 1 })
end

local function map_mode_at(x, y)
    local ww = lurek.window.getWidth and lurek.window.getWidth() or select(1, lurek.window.getDimensions())
    if ww < 760 then
        return nil
    end
    local panel_x = ww - 330
    local panel_y = 68
    for i, mode in ipairs(MODE_BUTTONS) do
        local bx = panel_x + 14 + (i - 1) * 53
        local by = panel_y + 34
        if x >= bx and x <= bx + 42 and y >= by and y <= by + 28 then
            return mode.mode
        end
    end
    return nil
end

local function draw_log_panel(state, view, ww, hh, mini_x, mini_y)
    local log_h = 104
    local log_w = math.max(300, mini_x - 22)
    local x = 8
    local y = hh - log_h - 8
    if log_w < 320 then
        log_w = ww - 16
        y = math.max(62, mini_y - log_h - 10)
    end
    draw_panel(x, y, log_w, log_h, 0.80)
    draw_text(view, "small", "CAMPAIGN LOG", x + 12, y + 8, 1.0, { 0.99, 0.90, 0.66, 1 })
    for i = 1, 3 do
        draw_text(view, "small", state.log[i] or "", x + 14, y + 18 + i * 22, 0.98, { 0.88, 0.90, 0.86, 1 })
    end
end

function M.draw(state, view, hovered_gid, selected_gid, map_modes)
    local ww, hh = lurek.window.getDimensions()
    local mini_w, mini_h = minimap_size(ww, hh)
    local mini_x = ww - mini_w - 16
    local mini_y = hh - mini_h - 18

    if R.setLineWidth then
        R.setLineWidth(1)
    end

    draw_top_bar(state, view, ww)
    draw_side_panel(state, view, hovered_gid, selected_gid, ww, hh)
    draw_mode_panel(view, ww)
    draw_log_panel(state, view, ww, hh, mini_x, mini_y)

    draw_panel(mini_x - 8, mini_y - 26, mini_w + 16, mini_h + 34, 0.90)
    draw_text(view, "small", "WORLD OVERVIEW", mini_x + 8, mini_y - 20, 0.92, { 0.99, 0.93, 0.78, 1 })
    update_minimap(state, view, map_modes, mini_w, mini_h)
    minimap:render(mini_x, mini_y)
    R.setColor(1, 1, 1, 1)
end

function M.mousepressed(state, view, x, y, button)
    if button ~= 1 then
        return false
    end
    local mode = map_mode_at(x, y)
    if not mode then
        return false
    end
    view.map_mode = mode
    return true
end

return M
