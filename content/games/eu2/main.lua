local R = lurek.render

local PIXEL_SIZE = 8
local TACTICAL_ZOOM_THRESHOLD = 0.12
local SANITIZED_MAP_PATH = "save/eu2/map2.png"
local START_VIEW = { map_x = 470, map_y = 95, zoom = 1.0 }
local PROVINCE_GPU_STYLE = {
    terrain_texture_scale = 18.0,
    terrain_texture_strength = 0.09,
    edge_gradient_radius = 20.0,
    edge_gradient_strength = 0.42,
    edge_gradient_color = { 0.11, 0.09, 0.05, 1.0 },
    border_palette = {
        province_color = { 0.34, 0.28, 0.16, 0.56 },
        coast_color = { 0.90, 0.78, 0.54, 1.0 },
        country_color = { 1.0, 0.16, 0.10, 1.0 },
        sea_darken = 0.22,
    },
}

local modules = {}
local reg = nil
local game = nil
local map_font = nil
local ui_font = nil

local view = {
    cam = { x = 0, y = 0, zoom = 1.0 },
    drag = { active = false, sx = 0, sy = 0, cx = 0, cy = 0 },
    hovered_gid = nil,
    selected_gid = nil,
    map_mode = "political",
    render_mode = "political",
    province_tints = nil,
    draw_labels = true,
    show_overlay = true,
    debug_mode = false,
    map_dirty = true,
    color_dirty = true,
    style_revision = -1,
}

local logged_reg_errors = {}
local function log_warn(message)
    if lurek.log and lurek.log.warn then
        lurek.log.warn(message, "eu2")
    end
end

local function load_module(path)
    local chunk = lurek.filesystem.load(path)
    assert(type(chunk) == "function", "cannot load " .. path)
    local ok, result = pcall(chunk)
    assert(ok, tostring(result))
    return result
end

local function reg_call(method, ...)
    if not reg then
        return nil
    end
    local fn = reg[method]
    if type(fn) ~= "function" then
        return nil
    end
    local ok, a, b, c, d, e = pcall(fn, reg, ...)
    if not ok then
        if not logged_reg_errors[method] then
            logged_reg_errors[method] = true
            log_warn("province." .. method .. " failed: " .. tostring(a))
        end
        return nil
    end
    return a, b, c, d, e
end

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function mark_map_dirty()
    view.map_dirty = true
end

local function mark_color_dirty()
    view.map_dirty = true
    view.color_dirty = true
end

local function snapped_camera()
    local scale = PIXEL_SIZE * view.cam.zoom
    if scale <= 0 then
        return view.cam.x, view.cam.y
    end
    return math.floor(view.cam.x / scale + 0.5) * scale,
        math.floor(view.cam.y / scale + 0.5) * scale
end

local function map_needs_sanitize()
    if not lurek.filesystem.exists(SANITIZED_MAP_PATH) then
        return true
    end
    if not lurek.filesystem.getInfo then
        return false
    end
    local src = lurek.filesystem.getInfo("map.png")
    local out = lurek.filesystem.getInfo(SANITIZED_MAP_PATH)
    if type(src) == "table" and type(out) == "table" and src.modtime and out.modtime then
        return src.modtime > out.modtime
    end
    return false
end

local function fit_camera()
    local ww, hh = lurek.window.getDimensions()
    view.cam.zoom = START_VIEW.zoom
    view.cam.x = ww * 0.5 - START_VIEW.map_x * PIXEL_SIZE * view.cam.zoom
    view.cam.y = hh * 0.5 - START_VIEW.map_y * PIXEL_SIZE * view.cam.zoom
    mark_map_dirty()
end

local function update_hover()
    local mx, my = lurek.input.mouse.getPosition()
    if reg and reg.screenToProvince then
        local cam_x, cam_y = snapped_camera()
        view.hovered_gid = reg:screenToProvince(mx, my, cam_x, cam_y, view.cam.zoom, PIXEL_SIZE)
    else
        view.hovered_gid = nil
    end
end

local function screen_from_province(pid)
    local province = game and game.provinces[pid]
    if not province or not province.cx or not province.cy then
        return nil, nil
    end
    local cam_x, cam_y = snapped_camera()
    return cam_x + province.cx * PIXEL_SIZE * view.cam.zoom,
        cam_y + province.cy * PIXEL_SIZE * view.cam.zoom
end

local function draw_armies()
    if not game then
        return
    end
    if view.cam.zoom * PIXEL_SIZE < 3.0 then
        return
    end
    local ww, hh = lurek.window.getDimensions()
    for _, army in ipairs(game.armies) do
        local x, y = screen_from_province(army.province_id)
        if x and x > -16 and y > -16 and x < ww + 16 and y < hh + 16 then
            local country = game.countries[army.tag] or game.countries.NEU
            local c = country.color or { 0.8, 0.8, 0.8, 1.0 }
            local scale = view.cam.zoom * 1.7
            local width = 22 * scale
            local height = 13 * scale
            local x0 = x - width * 0.5
            local y0 = y - height * 0.5
            R.setColor(0, 0, 0, army.selected and 0.9 or 0.7)
            R.rectangle("fill", x0 - 2, y0 - 2, width + 4, height + 4)
            R.setColor(c[1], c[2], c[3], 1)
            R.rectangle("fill", x0, y0, width, height)
            R.setColor(1, 1, 1, 0.18)
            R.rectangle("fill", x0, y0, width, math.max(2, height * 0.28))
            if army.selected then
                R.setColor(1.0, 0.84, 0.24, 1)
                R.rectangle("line", x0 - 3, y0 - 3, width + 6, height + 6)
            end
            local text = tostring(math.floor(army.size / 1000))
            local text_scale = scale * 0.9
            local tw = ui_font and ui_font.getWidth and ui_font:getWidth(text) or (#text * 5)
            local th = ui_font and ui_font.getHeight and ui_font:getHeight() or 7
            R.setColor(1, 1, 1, 1)
            R.print(text, x0 + (width - tw * text_scale) * 0.5, y0 + (height - th * text_scale) * 0.5, text_scale)
            if army.target_id then
                local tx, ty = screen_from_province(army.target_id)
                if tx and ty then
                    R.setColor(1, 0.9, 0.35, 0.75)
                    R.line(x, y, tx, ty)
                end
            end
        end
    end
end

local function draw_city_markers()
    if not game then
        return
    end
    if view.cam.zoom * PIXEL_SIZE < 3.0 then
        return
    end
    local ww, hh = lurek.window.getDimensions()
    if view.cam.zoom * PIXEL_SIZE >= 3.0 then
        local r = 4 * view.cam.zoom
        local outline = view.cam.zoom
        for _, province in pairs(game.provinces) do
            if province.owner ~= "SEA" and province.cx and province.cy then
                local x, y = screen_from_province(province.id)
                if x and x > -8 and y > -8 and x < ww + 8 and y < hh + 8 then
                    R.setColor(0.08, 0.06, 0.04, 0.75)
                    R.circle("fill", x, y, r + outline)
                    R.setColor(1.0, 0.82, 0.28, 0.95)
                    R.circle("fill", x, y, r)
                end
            end
        end
    end
    for tag, country in pairs(game.countries) do
        local pid = country.capital_province_id
        local province = pid and game.provinces[pid]
        if tag ~= "SEA" and province and province.owner ~= "SEA" then
            local x, y = screen_from_province(pid)
            if x and x > -16 and y > -16 and x < ww + 16 and y < hh + 16 then
                local size = 6 * view.cam.zoom
                local outline = view.cam.zoom * 1.5
                R.setColor(0, 0, 0, 0.75)
                R.rectangle("fill", x - size - outline, y - size - outline, size * 2 + outline * 2, size * 2 + outline * 2)
                R.setColor(1.0, 0.86, 0.28, 1)
                R.rectangle("fill", x - size, y - size, size * 2, size * 2)
                R.setColor(0.2, 0.12, 0.02, 1)
                R.rectangle("line", x - size, y - size, size * 2, size * 2)
            end
        end
    end
end

local function apply_map_mode_if_needed()
    if not game or not modules.map_modes then
        return
    end
    if game.map_mode ~= view.map_mode then
        game.map_mode = view.map_mode
        mark_color_dirty()
    end
    if game.style_revision ~= view.style_revision then
        view.style_revision = game.style_revision
        mark_color_dirty()
    end
end

function lurek.resize(w, h)
    mark_map_dirty()
end

function lurek.init()
    modules.scenario = load_module("scripts/scenario.lua")
    modules.state = load_module("scripts/state.lua")
    modules.map_modes = load_module("scripts/map_modes.lua")
    modules.ui = load_module("scripts/ui.lua")
    modules.input = load_module("scripts/input.lua")

    map_font = lurek.render.newFont(7)
    ui_font = lurek.render.newFont(10)
    R.setFont(ui_font)

    if map_needs_sanitize() then
        log_warn("sanitizing province map cache")
        lurek.province.sanitizeMarkedPng("map.png", SANITIZED_MAP_PATH)
    end

    reg = lurek.province.newFromPng("eu2", SANITIZED_MAP_PATH)
    lurek.province.setActive("eu2")
    reg:importMetadataFromFiles({
        color_map_png = SANITIZED_MAP_PATH,
        marker_png = "map.png",
        color_csv = "prov_cols.csv",
        province_toml = "province.toml",
        water_terrain_tokens = { "sea", "river" },
        water_terrain_type = 0,
        land_terrain_type = 1,
        set_political_colors = true,
        set_label_text = true,
        set_capitals = true,
        set_label_lines = true,
    })
    local scenario = modules.scenario.build(reg)
    game = modules.state.new(reg, scenario)
    game.map_mode = view.map_mode
    view.selected_gid = game.selected_province_id
    if not view.selected_gid and game.armies and game.armies[1] then
        view.selected_gid = game.armies[1].province_id
        modules.state.select_province(game, view.selected_gid)
    end
    fit_camera()
    apply_map_mode_if_needed()
end

function lurek.update(dt)
    if not game then
        return
    end
    local mx, my = lurek.input.mouse.getPosition()
    if view.drag.active then
        view.cam.x = view.drag.cx + (mx - view.drag.sx)
        view.cam.y = view.drag.cy + (my - view.drag.sy)
        mark_map_dirty()
    end
    modules.state.update(game, dt)
    update_hover()
    apply_map_mode_if_needed()
end

function lurek.process(dt)
    if lurek.automation then lurek.automation.update(dt) end
    lurek.update(dt)
end

function lurek.mousepressed(x, y, button)
    if button == 1 then
        view.drag.active = true
        view.drag.sx, view.drag.sy = x, y
        view.drag.cx, view.drag.cy = view.cam.x, view.cam.y
    elseif button == 2 and game and view.hovered_gid then
        modules.state.order_move(game, game.selected_army_id, view.hovered_gid)
        view.map_dirty = true
    end
end

function lurek.mousereleased(x, y, button)
    if button ~= 1 then return end
    local dx = x - view.drag.sx
    local dy = y - view.drag.sy
    view.drag.active = false
    if dx * dx + dy * dy <= 16 and game then
        view.selected_gid = view.hovered_gid
        modules.state.select_province(game, view.selected_gid)
    end
end

function lurek.wheelmoved(dx, dy)
    if dy == 0 then return end
    local mx, my = lurek.input.mouse.getPosition()
    local old = view.cam.zoom
    view.cam.zoom = clamp(view.cam.zoom * (dy > 0 and 1.12 or (1.0 / 1.12)), 0.02, 12.0)
    if lurek.province and lurek.province.zoomCameraAt then
        view.cam.x, view.cam.y = lurek.province.zoomCameraAt(mx, my, view.cam.x, view.cam.y, old, view.cam.zoom)
    else
        local s = view.cam.zoom / old
        view.cam.x = mx - (mx - view.cam.x) * s
        view.cam.y = my - (my - view.cam.y) * s
    end
    mark_map_dirty()
end

function lurek.keypressed(key)
    if key == "escape" then
        lurek.event.quit()
        return
    end
    if key == "r" then
        fit_camera()
        return
    end
    if key == "h" then
        view.show_overlay = not view.show_overlay
        return
    end
    if game and modules.input.handle_key(game, view, key) then
        if game.map_mode ~= view.map_mode then
            view.color_dirty = true
        end
        game.map_mode = view.map_mode
        apply_map_mode_if_needed()
        mark_map_dirty()
    end
end

local function render_map()
    local ww, hh = lurek.window.getDimensions()
    local cam_x, cam_y = snapped_camera()
    local refresh_colors = view.color_dirty
    if refresh_colors then
        view.render_mode, view.province_tints = modules.map_modes.apply(reg, game, view.map_mode)
    end
    if map_font then
        R.setFont(map_font)
    end
    reg_call("render", {
        backend = "gpu",
        x = cam_x,
        y = cam_y,
        zoom = view.cam.zoom,
        pixel_size = PIXEL_SIZE,
        screen_w = ww,
        screen_h = hh,
        map_mode = view.render_mode,
        province_tints = view.province_tints,
        zoom_mode = view.debug_mode and "tactical" or "auto",
        tactical_zoom_threshold = TACTICAL_ZOOM_THRESHOLD,
        draw_fills = true,
        draw_borders = true,
        draw_labels = view.draw_labels,
        draw_capitals = false,
        draw_roads = view.debug_mode,
        border_width = 1.0,
        terrain_texture_scale = PROVINCE_GPU_STYLE.terrain_texture_scale,
        terrain_texture_strength = PROVINCE_GPU_STYLE.terrain_texture_strength,
        edge_gradient_radius = PROVINCE_GPU_STYLE.edge_gradient_radius,
        edge_gradient_strength = PROVINCE_GPU_STYLE.edge_gradient_strength,
        edge_gradient_color = PROVINCE_GPU_STYLE.edge_gradient_color,
        border_palette = PROVINCE_GPU_STYLE.border_palette,
        hovered_id = view.show_overlay and view.hovered_gid or nil,
        selected_id = view.show_overlay and view.selected_gid or nil,
    })
    view.map_dirty = false
    view.color_dirty = false
end

function lurek.draw()
    if not reg or not game then
        return
    end
    render_map()
    if view.show_overlay then
        if map_font then
            R.setFont(map_font)
        end
        draw_city_markers()
        draw_armies()
        if ui_font then
            R.setFont(ui_font)
        end
        modules.ui.draw(game, view, view.hovered_gid, view.selected_gid, modules.map_modes)
    end
end
