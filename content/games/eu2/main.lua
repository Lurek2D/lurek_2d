--- EU2 game entry point.
--- Owns engine callbacks, module loading, camera/input state, province rendering,
--- and the frame-level orchestration between state, map modes, and UI.
local R = lurek.render

-- One source-map pixel is deliberately enlarged to a 16px game cell.
--- Authored map pixels are rendered as this many game pixels.
local PIXEL_SIZE = 16
--- Zoom below this threshold uses the tactical GPU path.
local TACTICAL_ZOOM_THRESHOLD = 0.12
--- Processed province-color map consumed by the registry.
local SANITIZED_MAP_PATH = "save/eu2/map2.png"
--- Processed marker map used to recover province centers.
local SANITIZED_MARKER_PATH = "save/eu2/map2_markers.png"
--- Initial camera center and zoom.
local START_VIEW = { map_x = 500, map_y = 112, zoom = 0.82 }
--- GPU border, terrain texture, and visual-effect defaults.
local PROVINCE_GPU_STYLE = {
    terrain_texture_scale = 16.0,
    terrain_texture_strength = 0.30,
    edge_gradient_radius = 12.0,
    edge_gradient_strength = 0.28,
    edge_gradient_softness = 0.65,
    edge_gradient_color = { 0.16, 0.13, 0.11, 0.72 },
    border_palette = {
        province_color = { 0.20, 0.17, 0.12, 0.92 },
        coast_color = { 1.0, 1.0, 0.0, 1.0 },
        country_color = { 1.0, 0.0, 0.0, 1.0 },
        sea_darken = 0.24,
    },
    visual_effects = {
        enabled = true,
        border_noise = {
            enabled = true,
            frequency = 0.11,
            amplitude_px = 0.8,
            softness_px = 0.55,
            seed = 271828,
        },
        water = {
            enabled = true,
            strength = 0.04,
            speed = 0.06,
            scale = 52.0,
        },
    },
}

--- Runtime module table loaded from `scripts/`.
local modules = {}
--- Province registry and campaign model created during `lurek.init`.
local reg = nil
local game = nil
local map_font = nil
local ui_font = nil
local ui_small_font = nil
local ui_title_font = nil
local terrain_pattern_texture = nil

--- Per-window camera, selection, dirty flags, and font slots.
local view = {
    cam = { x = 0, y = 0, zoom = 1.0 },
    drag = { active = false, sx = 0, sy = 0, cx = 0, cy = 0 },
    hovered_gid = nil,
    selected_gid = nil,
    map_mode = "political",
    render_mode = "political",
    province_tints = nil,
    show_overlay = true,
    debug_mode = false,
    map_dirty = true,
    color_dirty = true,
    style_revision = -1,
    fonts = nil,
}

local logged_reg_errors = {}
---@param message string Warning message.
local function log_warn(message)
    if lurek.log and lurek.log.warn then
        lurek.log.warn(message, "eu2")
    end
end

---@param path_or_size string|number Font asset path or direct size.
---@param size number|nil Font size when the first argument is a path.
---@return userdata|nil font Loaded font, or nil when loading fails.
local function new_font(path_or_size, size)
    local ok, font
    if size == nil then
        ok, font = pcall(R.newFont, path_or_size)
    else
        ok, font = pcall(R.newFont, path_or_size, size)
    end
    if ok and font then
        return font
    end
    return nil
end

---@param path string Relative Lua module path.
---@return table module Loaded module return value.
local function load_module(path)
    local chunk = lurek.filesystem.load(path)
    assert(type(chunk) == "function", "cannot load " .. path)
    local ok, result = pcall(chunk)
    assert(ok, tostring(result))
    return result
end

---@param method string Registry method name.
---@return any result First successful registry return value, or nil.
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

---@param v number Value to clamp.
---@param lo number Minimum.
---@param hi number Maximum.
---@return number value Clamped value.
local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

--- Mark geometry/overlay rendering for refresh.
local function mark_map_dirty()
    view.map_dirty = true
end

--- Mark map colors and geometry for refresh.
local function mark_color_dirty()
    view.map_dirty = true
    view.color_dirty = true
end

---@return number x Camera x snapped to source-cell boundaries.
---@return number y Camera y snapped to source-cell boundaries.
local function snapped_camera()
    local scale = PIXEL_SIZE * view.cam.zoom
    if scale <= 0 then
        return view.cam.x, view.cam.y
    end
    return math.floor(view.cam.x / scale + 0.5) * scale,
        math.floor(view.cam.y / scale + 0.5) * scale
end

---@return boolean needed True when the processed map is absent or stale.
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

---@return string path Existing marker-map path, or source map fallback.
local function marker_map_path()
    if not lurek.filesystem.exists(SANITIZED_MARKER_PATH) then
        return "map.png"
    end
    if not lurek.filesystem.getInfo then
        return SANITIZED_MARKER_PATH
    end
    local src = lurek.filesystem.getInfo("map.png")
    local out = lurek.filesystem.getInfo(SANITIZED_MARKER_PATH)
    if type(src) == "table" and type(out) == "table" and src.modtime and out.modtime then
        if out.modtime >= src.modtime then
            return SANITIZED_MARKER_PATH
        end
        return "map.png"
    end
    return SANITIZED_MARKER_PATH
end

--- Center the camera on the registry map bounds.
local function fit_camera()
    local ww, hh = lurek.window.getDimensions()
    view.cam.zoom = START_VIEW.zoom
    view.cam.x = ww * 0.5 - START_VIEW.map_x * PIXEL_SIZE * view.cam.zoom
    view.cam.y = hh * 0.5 - START_VIEW.map_y * PIXEL_SIZE * view.cam.zoom
    mark_map_dirty()
end

--- Update the hovered province from the current mouse position.
local function update_hover()
    local mx, my = lurek.input.mouse.getPosition()
    if reg and reg.screenToProvince then
        local cam_x, cam_y = snapped_camera()
        view.hovered_gid = reg:screenToProvince(mx, my, cam_x, cam_y, view.cam.zoom, PIXEL_SIZE)
    else
        view.hovered_gid = nil
    end
end

---@param pid number Province id.
---@return number|nil x Screen x coordinate.
---@return number|nil y Screen y coordinate.
local function screen_from_province(pid)
    local province = game and game.provinces[pid]
    if not province or not province.cx or not province.cy then
        return nil, nil
    end
    local cam_x, cam_y = snapped_camera()
    return cam_x + province.cx * PIXEL_SIZE * view.cam.zoom,
        cam_y + province.cy * PIXEL_SIZE * view.cam.zoom
end

--- Draw army badges at their current province centers.
local function draw_armies()
    if not game then
        return
    end
    if view.cam.zoom * PIXEL_SIZE < 3.0 then
        return
    end
    local ww, hh = lurek.window.getDimensions()
    if ui_small_font then
        R.setFont(ui_small_font)
    end
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
            local font = ui_small_font or ui_font
            local tw = font and font.getWidth and font:getWidth(text) or (#text * 5)
            local th = font and font.getHeight and font:getHeight() or 7
            local tx = x0 + (width - tw) * 0.5
            local ty = y0 + (height - th) * 0.5
            R.setColor(0.08, 0.07, 0.05, 0.95)
            R.print(text, tx + 1, ty + 1)
            R.setColor(0.99, 0.96, 0.84, 1)
            R.print(text, tx, ty)
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

--- Draw capital/city markers for initialized countries.
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
                    R.setColor(0.10, 0.08, 0.05, 0.72)
                    R.circle("fill", x, y, r + outline)
                    R.setColor(0.96, 0.82, 0.39, 0.94)
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
                R.setColor(0.08, 0.06, 0.04, 0.78)
                R.rectangle("fill", x - size - outline, y - size - outline, size * 2 + outline * 2, size * 2 + outline * 2)
                R.setColor(0.97, 0.84, 0.33, 1)
                R.rectangle("fill", x - size, y - size, size * 2, size * 2)
                R.setColor(0.22, 0.13, 0.03, 1)
                R.rectangle("line", x - size, y - size, size * 2, size * 2)
            end
        end
    end
end

--- Upload map-mode colors and visual state when dirty.
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

--- Engine resize callback; refreshes camera-dependent overlays.
---@param w number New window width.
---@param h number New window height.
function lurek.resize(w, h)
    mark_map_dirty()
end

--- Engine initialization callback; load assets, registry, scenario, and state.
function lurek.init()
    modules.scenario = load_module("scripts/scenario.lua")
    modules.state = load_module("scripts/state.lua")
    modules.map_modes = load_module("scripts/map_modes.lua")
    modules.ui = load_module("scripts/ui.lua")
    modules.input = load_module("scripts/input.lua")

    map_font = new_font(10)
    ui_small_font = map_font
    ui_font = map_font
    ui_title_font = map_font
    terrain_pattern_texture = R.newImage("assets/terrain_patterns.png")
    assert(terrain_pattern_texture, "cannot load assets/terrain_patterns.png")
    view.fonts = {
        map = map_font,
        ui = ui_font,
        small = ui_small_font,
        title = ui_title_font,
    }
    R.setFont(ui_font or map_font)

    if map_needs_sanitize() then
        log_warn("sanitizing province map cache")
        lurek.province.sanitizeMarkedPng("map.png", SANITIZED_MAP_PATH)
    end

    reg = lurek.province.newFromPng("eu2", SANITIZED_MAP_PATH)
    lurek.province.setActive("eu2")
    reg:importMetadataFromFiles({
        color_map_png = SANITIZED_MAP_PATH,
        marker_png = marker_map_path(),
        color_csv = "prov_cols.csv",
        province_toml = "province.toml",
        water_terrain_tokens = { "sea", "river" },
        water_terrain_type = 0,
        land_terrain_type = 1,
        set_political_colors = true,
        set_capitals = true,
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

--- Per-frame update callback for hover, UI, and campaign simulation.
---@param dt number Frame delta in seconds.
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

--- Optional engine process callback; EU2 keeps simulation in `update`.
---@param dt number Frame delta in seconds.
function lurek.process(dt)
    if lurek.automation then lurek.automation.update(dt) end
    lurek.update(dt)
end

--- Mouse-down callback for map selection, drag start, and UI controls.
---@param x number Mouse x coordinate.
---@param y number Mouse y coordinate.
---@param button number Mouse button id.
function lurek.mousepressed(x, y, button)
    if game and modules.ui and modules.ui.mousepressed and modules.ui.mousepressed(game, view, x, y, button) then
        if game.map_mode ~= view.map_mode then
            view.color_dirty = true
        end
        game.map_mode = view.map_mode
        apply_map_mode_if_needed()
        mark_map_dirty()
        return
    end
    if button == 1 then
        view.drag.active = true
        view.drag.sx, view.drag.sy = x, y
        view.drag.cx, view.drag.cy = view.cam.x, view.cam.y
    elseif button == 2 and game and view.hovered_gid then
        modules.state.order_move(game, game.selected_army_id, view.hovered_gid)
        view.map_dirty = true
    end
end

--- Mouse-up callback; converts a drag into a province move order when appropriate.
---@param x number Mouse x coordinate.
---@param y number Mouse y coordinate.
---@param button number Mouse button id.
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

--- Mouse-wheel callback for zooming around the pointer.
---@param dx number Horizontal wheel delta.
---@param dy number Vertical wheel delta.
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

--- Keyboard callback routed to EU2 input commands.
---@param key string Engine key name.
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

--- Render the province map and its transient overlays.
local function render_map()
    local ww, hh = lurek.window.getDimensions()
    local cam_x, cam_y = snapped_camera()
    local refresh_colors = view.color_dirty
    if refresh_colors then
        view.render_mode, view.province_tints = modules.map_modes.apply(reg, game, view.map_mode)
    end
    local highlight_tints = modules.map_modes.highlight_tints(
        game,
        view.map_mode,
        view.hovered_gid,
        view.selected_gid
    )
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
        province_tints = highlight_tints or view.province_tints,
        zoom_mode = "tactical",
        tactical_zoom_threshold = TACTICAL_ZOOM_THRESHOLD,
        draw_fills = true,
        draw_borders = true,
        draw_labels = false,
        draw_capitals = false,
        draw_roads = view.debug_mode,
        -- The GPU border shader resolves one 16px source cell as a 12px line.
        border_width = 12.0,
        terrain_texture_scale = PROVINCE_GPU_STYLE.terrain_texture_scale,
        terrain_texture_strength = PROVINCE_GPU_STYLE.terrain_texture_strength,
        terrain_texture = terrain_pattern_texture,
        edge_gradient_radius = PROVINCE_GPU_STYLE.edge_gradient_radius,
        edge_gradient_strength = PROVINCE_GPU_STYLE.edge_gradient_strength,
        edge_gradient_softness = PROVINCE_GPU_STYLE.edge_gradient_softness,
        edge_gradient_color = PROVINCE_GPU_STYLE.edge_gradient_color,
        border_palette = PROVINCE_GPU_STYLE.border_palette,
        visual_effects = PROVINCE_GPU_STYLE.visual_effects,
        -- EU2 supplies exact fill tints below instead of the renderer's generic outline.
        hovered_id = nil,
        selected_id = nil,
    })
    view.map_dirty = false
    view.color_dirty = false
end

--- Engine draw callback for map, armies, cities, and UI.
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
