-- ============================================================================
-- Globe Demo — Lurek2D
-- ============================================================================
-- Category : showcase
-- Source   : content/games/showcase/globe_demo/main.lua
-- Run with : cargo run -- content/games/showcase/globe_demo
-- ============================================================================
-- Interactive world globe: ~200 procedurally generated provinces, drag-pan,
-- scroll zoom, capital markers, continent labels, political colour layer,
-- day/night cycle, hover highlight, and click-select with popup label.
-- ============================================================================

-- Universal render helpers (handles all legacy and current call signatures)
local _gfx = lurek.render
local _unpack = table.unpack or unpack
local function _sc(c)
    if type(c) == "table" then
        local col = c.color or c
        if type(col) == "table" then
            _gfx.setColor(col[1] or 1, col[2] or 1, col[3] or 1, col[4] or 1)
        end
    end
end
local function rect(a, b, c, d, e, f, g, h)
    if type(a) == "string" then
        _gfx.rectangle(a, b, c, d, e)
    elseif type(e) == "table" then
        _sc(e); _gfx.rectangle(e.mode or "fill", a, b, c, d)
    elseif type(e) == "number" then
        _gfx.setColor(e or 1, f or 1, g or 1, h or 1); _gfx.rectangle("fill", a, b, c, d)
    else
        _gfx.rectangle("fill", a, b, c, d)
    end
end
local function circ(a, b, c, d, e, f, g, h)
    if type(a) == "string" then
        if type(e) == "table" then _sc(e)
        elseif type(e) == "number" then _gfx.setColor(e or 1, f or 1, g or 1, h or 1) end
        _gfx.circle(a, b, c, d)
    elseif type(d) == "table" then
        _sc(d); _gfx.circle("fill", a, b, c)
    elseif type(d) == "number" then
        _gfx.setColor(d or 1, e or 1, f or 1, g or 1); _gfx.circle("fill", a, b, c)
    else
        _gfx.circle("fill", a, b, c)
    end
end
local function text_(a, b, c, d, e, f, g, h)
    if type(d) == "table" then
        _sc(d)
    elseif type(d) == "number" and type(e) == "number" then
        _gfx.setColor(e or 1, f or 1, g or 1, h or 1)
    end
    _gfx.print(tostring(a), b, c)
end
local function ln(x1, y1, x2, y2, c)
    if type(c) == "table" then _sc(c) end
    _gfx.line(x1, y1, x2, y2)
end

-- Capture the render API namespace BEFORE defining function lurek.draw()
-- (defining that callback overwrites lurek.render with the function itself).

local SCREEN_W   = 1280
local SCREEN_H   = 720
local GLOBE_CX   = SCREEN_W / 2    -- globe centre X on screen
local GLOBE_CY   = SCREEN_H / 2    -- globe centre Y on screen
local GLOBE_R    = 290.0           -- display radius (screen units)
local DAY_SPEED  = 120.0           -- seconds of real time per 1 simulated hour
local ZOOM_MIN   = 0.5
local ZOOM_MAX   = 12.0
local PAN_SCALE  = 0.12            -- degrees per pixel at zoom 1.0
local PAD_PAN_SPEED = 90.0         -- degrees per second at zoom 1.0
local PICK_RADIUS   = 28.0

-- ---------------------------------------------------------------------------
-- Globe state
-- ---------------------------------------------------------------------------
local g              -- Globe handle (lurek.globe userdata)
local cam_lat  = 20.0
local cam_lon  = 0.0
local cam_zoom = 1.5

local time_of_day    = 12.0        -- hours 0–24
local sim_seconds    = 0.0         -- accumulated real seconds for day/night

local hovered_id     = nil         -- province id under cursor (nil = none)
local selected_id    = nil         -- clicked province id
local prev_hovered   = nil         -- to track when highlight changes
local flight_arc_id  = nil         -- temporary arc drawn on click

-- Mouse drag state
local is_dragging    = false
local drag_mx        = 0
local drag_my        = 0
local drag_lat       = 0.0
local drag_lon       = 0.0
local lmb_prev       = false       -- previous frame left-button state

-- HUD state
local hud_province   = ""          -- province name shown in HUD
local hud_lod        = ""
local hud_status     = "Lua fallback renderer active"

local province_cache = {}
local projected_cache = {}
local projected_order = {}
local REGION_COLORS = {}

-- ---------------------------------------------------------------------------
-- Province generation helpers
-- ---------------------------------------------------------------------------
-- Clamp to sane color range
local function clamp(v, lo, hi) return v < lo and lo or (v > hi and hi or v) end

-- Slightly vary a base color component for visual diversity
local function jitter(v)
    -- deterministic tiny offset using a cheap pseudo-random trick
    return clamp(v + (((v * 31337) % 7) - 3) * 0.03, 0.05, 0.95)
end

-- Generate grid provinces for one continental region.
-- Returns the list of assigned province IDs.
-- Neighbors are the four grid-adjacent cells (N/S/E/W), clipped at edges.
local next_pid = 1    -- global province ID counter

local function wrap_lon(v)
    while v > 180.0 do v = v - 360.0 end
    while v < -180.0 do v = v + 360.0 end
    return v
end

local function deg2rad(v)
    return v * math.pi / 180.0
end

local function mix(a, b, t)
    return a + (b - a) * t
end

local function orthographic_project(lat, lon)
    local lat_r = deg2rad(lat)
    local lon_r = deg2rad(lon)
    local cam_lat_r = deg2rad(cam_lat)
    local cam_lon_r = deg2rad(cam_lon)
    local dlon = lon_r - cam_lon_r

    local cos_lat = math.cos(lat_r)
    local sin_lat = math.sin(lat_r)
    local cos_cam = math.cos(cam_lat_r)
    local sin_cam = math.sin(cam_lat_r)
    local cos_dlon = math.cos(dlon)
    local sin_dlon = math.sin(dlon)

    local z = sin_cam * sin_lat + cos_cam * cos_lat * cos_dlon
    if z <= 0.0 then
        return nil
    end

    local px = cos_lat * sin_dlon
    local py = cos_cam * sin_lat - sin_cam * cos_lat * cos_dlon
    local scale = GLOBE_R * cam_zoom
    return GLOBE_CX + px * scale, GLOBE_CY - py * scale, z
end

local function sunlight_for(lat, lon)
    local lat_r = deg2rad(lat)
    local lon_r = deg2rad(lon)
    local sun_lon = ((time_of_day / 24.0) * 360.0) - 180.0
    local sun_lon_r = deg2rad(sun_lon)
    local sun_x = math.cos(sun_lon_r)
    local sun_y = 0.0
    local sun_z = math.sin(sun_lon_r)
    local nx = math.cos(lat_r) * math.cos(lon_r)
    local ny = math.sin(lat_r)
    local nz = math.cos(lat_r) * math.sin(lon_r)
    local lit = nx * sun_x + ny * sun_y + nz * sun_z
    return clamp(0.25 + math.max(0.0, lit) * 0.85, 0.25, 1.0)
end

local function province_color(meta, pid)
    local region_color = REGION_COLORS[meta.region]
    local base = region_color or meta.base_color or {0.4, 0.55, 0.75, 1.0}
    local shade = sunlight_for(meta.centroid[1], meta.centroid[2])
    local r = clamp(base[1] * shade, 0.0, 1.0)
    local g2 = clamp(base[2] * shade, 0.0, 1.0)
    local b = clamp(base[3] * shade, 0.0, 1.0)

    if pid == selected_id then
        r = mix(r, 1.0, 0.45)
        g2 = mix(g2, 0.85, 0.55)
        b = mix(b, 0.15, 0.80)
    elseif pid == hovered_id then
        r = mix(r, 1.0, 0.30)
        g2 = mix(g2, 1.0, 0.30)
        b = mix(b, 1.0, 0.18)
    end

    return r, g2, b
end

local function rebuild_projection_cache()
    projected_cache = {}
    projected_order = {}

    for pid, meta in pairs(province_cache) do
        local cx, cy, cz = orthographic_project(meta.centroid[1], meta.centroid[2])
        if cx then
            local pts = {}
            local complete = true
            for _, v in ipairs(meta.vertices) do
                local vx, vy = orthographic_project(v[1], v[2])
                if not vx then
                    complete = false
                    break
                end
                pts[#pts + 1] = vx
                pts[#pts + 1] = vy
            end
            if complete and #pts >= 6 then
                projected_cache[pid] = {
                    x = cx,
                    y = cy,
                    z = cz,
                    points = pts,
                    meta = meta,
                }
                projected_order[#projected_order + 1] = pid
            end
        end
    end

    table.sort(projected_order, function(a, b)
        return projected_cache[a].z < projected_cache[b].z
    end)
end

local function pick_projected_province(x, y)
    local best_id = nil
    local best_dist = PICK_RADIUS * PICK_RADIUS
    for _, pid in ipairs(projected_order) do
        local item = projected_cache[pid]
        local dx = item.x - x
        local dy = item.y - y
        local dist = dx * dx + dy * dy
        if dist < best_dist then
            best_dist = dist
            best_id = pid
        end
    end
    return best_id
end

local function generate_grid_provinces(
    region, lat_min, lat_max, lon_min, lon_max,
    rows, cols, base_r, base_g, base_b, extra_attrs)

    local ids    = {}   -- ids[r][c] = province_id  (1-indexed)
    local lat_step = (lat_max - lat_min) / rows
    local lon_step = (lon_max - lon_min) / cols

    -- First pass: assign IDs and create province tables (no neighbors yet)
    for r = 1, rows do
        ids[r] = {}
        for c = 1, cols do
            ids[r][c] = next_pid
            next_pid = next_pid + 1
        end
    end

    -- Second pass: add provinces with computed neighbors
    for r = 1, rows do
        for c = 1, cols do
            local pid   = ids[r][c]
            local lat0  = lat_min + (r - 1) * lat_step
            local lon0  = lon_min + (c - 1) * lon_step
            local lat1  = lat0 + lat_step
            local lon1  = lon0 + lon_step
            local clat  = (lat0 + lat1) * 0.5
            local clon  = (lon0 + lon1) * 0.5

            -- Neighbor IDs (grid adjacency, within this region)
            local nbrs = {}
            if r > 1    then table.insert(nbrs, ids[r-1][c]) end
            if r < rows then table.insert(nbrs, ids[r+1][c]) end
            if c > 1    then table.insert(nbrs, ids[r][c-1]) end
            if c < cols then table.insert(nbrs, ids[r][c+1]) end

            -- Per-province color variation (deterministic jitter)
            local cr = clamp(base_r + (pid % 5 - 2) * 0.04, 0.05, 0.95)
            local cg = clamp(base_g + (pid % 7 - 3) * 0.03, 0.05, 0.95)
            local cb = clamp(base_b + (pid % 3 - 1) * 0.05, 0.05, 0.95)

            g:addProvince({
                id        = pid,
                centroid  = {clat, clon},
                vertices  = {
                    {lat0, lon0}, {lat0, lon1},
                    {lat1, lon1}, {lat1, lon0},
                },
                neighbors  = nbrs,
                base_color = {cr, cg, cb, 1.0},
            })

            province_cache[pid] = {
                id = pid,
                region = region,
                centroid = {clat, clon},
                vertices = {
                    {lat0, lon0}, {lat0, lon1},
                    {lat1, lon1}, {lat1, lon0},
                },
                base_color = {cr, cg, cb, 1.0},
            }

            g:setProvinceAttr(pid, "region", region)
            if extra_attrs then
                for k, v in pairs(extra_attrs) do
                    g:setProvinceAttr(pid, k, v)
                end
            end
        end
    end

    return ids
end

-- ---------------------------------------------------------------------------
-- Capital city markers
-- ---------------------------------------------------------------------------
local CAPITALS = {
    -- {lat, lon, name}
    {38.9,  -77.0, "Washington DC"},
    {51.5,   -0.1, "London"},
    {48.8,    2.3, "Paris"},
    {52.5,   13.4, "Berlin"},
    {41.9,   12.5, "Rome"},
    {55.8,   37.6, "Moscow"},
    {35.7,  139.7, "Tokyo"},
    {39.9,  116.4, "Beijing"},
    {28.6,   77.2, "New Delhi"},
    {-15.8, -47.9, "Brasilia"},
    {-34.6, -58.4, "Buenos Aires"},
    {-33.9,  18.4, "Cape Town"},
    {30.0,   31.2, "Cairo"},
    {-25.3,  131.0,"Canberra"},
    {-90.0,    0.0,"Amundsen-Scott (South Pole)"},
}

-- ---------------------------------------------------------------------------
-- Continent labels
-- ---------------------------------------------------------------------------
local CONTINENT_LABELS = {
    {45.0,  -100.0, "North America"},
    {-15.0,  -55.0, "South America"},
    {50.0,    15.0, "Europe"},
    {5.0,     20.0, "Africa"},
    {40.0,    90.0, "Asia"},
    {-25.0,  135.0, "Oceania"},
    {-75.0,    0.0, "Antarctica"},
}

-- ---------------------------------------------------------------------------
-- Political layer colors per region
-- ---------------------------------------------------------------------------
REGION_COLORS = {
    ["North America"] = {0.25, 0.50, 0.85, 0.55},
    ["South America"] = {0.30, 0.75, 0.40, 0.55},
    ["Europe"]        = {0.85, 0.75, 0.25, 0.55},
    ["Africa"]        = {0.85, 0.45, 0.20, 0.55},
    ["Asia"]          = {0.70, 0.25, 0.70, 0.55},
    ["Oceania"]       = {0.20, 0.70, 0.75, 0.55},
    ["Antarctica"]    = {0.80, 0.90, 1.00, 0.55},
}

-- ---------------------------------------------------------------------------
-- Init callback
-- ---------------------------------------------------------------------------
function lurek.init()
    -- Verify the API is reachable and print the province cap
    assert(lurek.globe ~= nil, "lurek.globe module not loaded")
    print("Globe API ready. MAX_PROVINCES =", lurek.globe.MAX_PROVINCES)
    print("LOD tiers:", lurek.globe.LOD_FAR, lurek.globe.LOD_MID, lurek.globe.LOD_NEAR)

    -- Create the globe
    g = lurek.globe.new("earth", {
        radius         = GLOBE_R,
        axial_tilt_deg = 23.5,
        time_of_day    = time_of_day,
        render_borders = true,
        border_width   = 1.0,
        ambient        = 0.18,
    })

    -- Confirm retrieval by name works
    local g_check = lurek.globe.get("earth")
    assert(g_check ~= nil, "globe.get('earth') failed immediately after creation")
    print("Globe name via get():", g_check:getName())

    -- Generate ~200 provinces across 7 continental regions
    -- Regions: rows × cols  => total provinces
    generate_grid_provinces("North America",  15, 75, -170, -50, 7,  5, 0.22, 0.45, 0.80)  -- 35
    generate_grid_provinces("South America", -55, 15,  -85, -35, 6,  5, 0.25, 0.72, 0.38)  -- 30
    generate_grid_provinces("Europe",         35, 72,  -15,  50, 5,  7, 0.82, 0.72, 0.22)  -- 35
    generate_grid_provinces("Africa",        -35, 37,  -18,  52, 5,  6, 0.82, 0.42, 0.18)  -- 30
    generate_grid_provinces("Asia",            5, 75,   26, 145, 5,  9, 0.68, 0.22, 0.68)  -- 45
    generate_grid_provinces("Oceania",       -47,  5,  110, 180, 3,  5, 0.18, 0.68, 0.72)  -- 15
    generate_grid_provinces("Antarctica",    -90,-60, -180, 180, 1, 10, 0.78, 0.88, 0.98)  -- 10

    local total = g:provinceCount()
    print(string.format("Provinces generated: %d", total))
    assert(total == 200, string.format("expected 200 provinces, got %d", total))

    -- Thematic layer: political overlay (one color per region)
    g:addLayer("political", 1)
    g:setLayerAlpha("political", 0.55)
    for pid = 1, total do
        local region = g:getProvinceAttr(pid, "region") or ""
        local col    = REGION_COLORS[region]
        if col then
            g:setLayerColor("political", pid, col[1], col[2], col[3], col[4])
        end
    end

    -- Highlight layer: used for hover and selection feedback
    g:addLayer("highlight", 5)

    -- Fog of war: reveal all for the single human viewer
    g:setActiveViewer("player")
    g:revealAll("player")

    -- Capital city markers
    for _, cap in ipairs(CAPITALS) do
        local mid = g:addMarker("capital", cap[1], cap[2], cap[3])
        g:setMarkerAttr(mid, "type", "capital")
    end

    -- Continent labels
    for _, lbl in ipairs(CONTINENT_LABELS) do
        g:addLabel("continent", lbl[1], lbl[2], lbl[3])
    end

    -- Initial camera: centered on the Atlantic, zoom 1.5×
    g:setCamera(cam_lat, cam_lon, cam_zoom)

    -- Start at midday
    g:setTimeOfDay(time_of_day)

    -- Borders on by default
    g:setBorders(true)

    -- Input bindings
    lurek.input.bind("drag",  {"mouse1"})
    lurek.input.bind("quit",  {"escape"})
    lurek.input.bind("pan_left",  {"left", "a", "gamepad:0:dpad_left"})
    lurek.input.bind("pan_right", {"right", "d", "gamepad:0:dpad_right"})
    lurek.input.bind("pan_up",    {"up", "w", "gamepad:0:dpad_up"})
    lurek.input.bind("pan_down",  {"down", "s", "gamepad:0:dpad_down"})
    lurek.input.bind("zoom_in",   {"pageup", "equals", "gamepad:0:rightshoulder", "gamepad:0:y"})
    lurek.input.bind("zoom_out",  {"pagedown", "minus", "gamepad:0:leftshoulder", "gamepad:0:x"})
    lurek.input.bind("select",    {"return", "space", "gamepad:0:a"})

    -- Set space-background color (fills screen automatically each frame)
    lurek.render.setBackgroundColor(0.02, 0.02, 0.08)

    rebuild_projection_cache()

    print("Globe demo loaded successfully.")
end

-- ---------------------------------------------------------------------------
-- Update callback
-- ---------------------------------------------------------------------------
function lurek.process(dt)
    if lurek.automation then lurek.automation.update(dt) end
    local mx, my = lurek.input.mouse.getPosition()
    local lmb    = lurek.input.isActionDown("drag")
    local _, wdy = lurek.input.mouse.getWheelDelta()
    local pad_left = lurek.input.isActionDown("pan_left")
    local pad_right = lurek.input.isActionDown("pan_right")
    local pad_up = lurek.input.isActionDown("pan_up")
    local pad_down = lurek.input.isActionDown("pan_down")
    local pad_zoom_in = lurek.input.isActionDown("zoom_in")
    local pad_zoom_out = lurek.input.isActionDown("zoom_out")
    local controller_active = pad_left or pad_right or pad_up or pad_down or pad_zoom_in or pad_zoom_out
    local was_dragging = is_dragging

    -- ── Mouse wheel zoom ──────────────────────────────────────────────────
    if wdy and wdy ~= 0 then
        local factor = wdy > 0 and 1.20 or (1.0 / 1.20)
        cam_zoom     = clamp(cam_zoom * factor, ZOOM_MIN, ZOOM_MAX)
        g:setCamera(cam_lat, cam_lon, cam_zoom)
    end

    if pad_zoom_in then
        cam_zoom = clamp(cam_zoom * (1.0 + dt * 1.6), ZOOM_MIN, ZOOM_MAX)
        g:setCamera(cam_lat, cam_lon, cam_zoom)
    elseif pad_zoom_out then
        cam_zoom = clamp(cam_zoom / (1.0 + dt * 1.6), ZOOM_MIN, ZOOM_MAX)
        g:setCamera(cam_lat, cam_lon, cam_zoom)
    end

    -- ── Left-drag pan ────────────────────────────────────────────────────
    if lmb then
        if not is_dragging then
            -- Start drag: record anchor
            is_dragging = true
            drag_mx, drag_my = mx, my
            drag_lat, drag_lon = cam_lat, cam_lon
        else
            -- Continue drag: accumulate delta
            local ddeg = PAN_SCALE / cam_zoom
            local dlat = -(my - drag_my) * ddeg
            local dlon = -(mx - drag_mx) * ddeg
            cam_lat = clamp(drag_lat + dlat, -85.0, 85.0)
            cam_lon = drag_lon + dlon
            g:setCamera(cam_lat, cam_lon, cam_zoom)
        end
    else
        is_dragging = false
    end

    if controller_active and not lmb then
        local pan_speed = PAD_PAN_SPEED * dt / math.max(cam_zoom, 0.75)
        if pad_left then cam_lon = wrap_lon(cam_lon - pan_speed) end
        if pad_right then cam_lon = wrap_lon(cam_lon + pan_speed) end
        if pad_up then cam_lat = clamp(cam_lat + pan_speed, -85.0, 85.0) end
        if pad_down then cam_lat = clamp(cam_lat - pan_speed, -85.0, 85.0) end
        g:setCamera(cam_lat, cam_lon, cam_zoom)
    end

    rebuild_projection_cache()

    -- ── Click to select province ──────────────────────────────────────────
    local lmb_just_released = lmb_prev and not lmb and not was_dragging
    lmb_prev = lmb
    local target_x = controller_active and GLOBE_CX or mx
    local target_y = controller_active and GLOBE_CY or my
    hovered_id = pick_projected_province(target_x, target_y)

    local select_pressed = lurek.input.wasActionPressed("select")
    if lmb_just_released or select_pressed then
        local clicked = hovered_id
        if clicked and clicked ~= selected_id then
            selected_id = clicked

            -- Show a popup label with province info
            local meta = province_cache[selected_id]
            local region = meta and meta.region or "Unknown"
            local lat = meta and meta.centroid[1] or 0.0
            local lon = meta and meta.centroid[2] or 0.0
            hud_province = string.format("Province %d — %s (%.1f deg, %.1f deg)",
                selected_id, region, lat, lon)
        end
    end
    prev_hovered = hovered_id

    -- Update HUD LOD string
    hud_lod = g:getLod()

    -- ── Day/night simulation ──────────────────────────────────────────────
    sim_seconds  = sim_seconds + dt
    if sim_seconds >= DAY_SPEED then
        sim_seconds  = sim_seconds - DAY_SPEED
        time_of_day  = (time_of_day + 1.0) % 24.0
        g:setTimeOfDay(time_of_day)
    end

    -- Advance globe simulation (updates lighting, any internal state)
    g:update(dt)

    -- Escape to quit
    if lurek.input.wasActionPressed("quit") then
        lurek.event.quit()
    end
end

-- ---------------------------------------------------------------------------
-- Render callback
-- ---------------------------------------------------------------------------
function lurek.draw()
    -- (background filled automatically via setBackgroundColor set in init)
    rebuild_projection_cache()

    lurek.render.setColor(0.05, 0.08, 0.16, 1.0)
    circ("fill", GLOBE_CX, GLOBE_CY, GLOBE_R * cam_zoom)
    lurek.render.setColor(0.12, 0.18, 0.28, 1.0)
    circ("line", GLOBE_CX, GLOBE_CY, GLOBE_R * cam_zoom)

    for _, pid in ipairs(projected_order) do
        local item = projected_cache[pid]
        local r, g2, b = province_color(item.meta, pid)
        lurek.render.setColor(r, g2, b, 0.95)
        lurek.render.polygon("fill", _unpack(item.points))
        lurek.render.setColor(0.02, 0.04, 0.08, 0.45)
        lurek.render.polygon("line", _unpack(item.points))
    end

    for _, cap in ipairs(CAPITALS) do
        local sx, sy = orthographic_project(cap[1], cap[2])
        if sx then
            lurek.render.setColor(1.0, 0.92, 0.55, 0.95)
            circ("fill", sx, sy, 3 + cam_zoom * 0.5)
        end
    end

    for _, lbl in ipairs(CONTINENT_LABELS) do
        local sx, sy = orthographic_project(lbl[1], lbl[2])
        if sx then
            lurek.render.setColor(0.92, 0.96, 1.0, 0.72)
            text_(lbl[3], sx - 38, sy, 12)
        end
    end

    local cmd_count = #projected_order

    -- ── HUD strip ─────────────────────────────────────────────────────────
    lurek.render.setColor(0.0, 0.0, 0.0, 0.65)
    rect("fill", 0, 0, SCREEN_W, 32)

    local clat, clon, czoom = g:getCamera()
    local tod = g:getTimeOfDay()
    local hud_cam = string.format(
        "Camera  lat=%.1f°  lon=%.1f°  zoom=%.2f×  LOD=%s",
        clat, clon, czoom, hud_lod)
    local tod_h = math.floor(tod)
    local tod_m = math.floor((tod - tod_h) * 60)
    local hud_time = string.format("Time %02d:%02d  Provinces=%d  visible=%d",
        tod_h, tod_m, g:provinceCount(), cmd_count)

    lurek.render.setColor(0.9, 0.9, 0.9)
    text_(hud_cam,  10, 8, 14)
    lurek.render.setColor(0.7, 0.9, 1.0)
    text_(hud_time, SCREEN_W - 380, 8, 14)

    -- ── Province hover info ───────────────────────────────────────────────
    if hovered_id then
        local region = g:getProvinceAttr(hovered_id, "region") or "?"
        local hover_text = string.format("Province %d — %s", hovered_id, region)
        lurek.render.setColor(0.0, 0.0, 0.0, 0.55)
        rect("fill", 0, SCREEN_H - 32, 400, 32)
        lurek.render.setColor(1.0, 0.9, 0.5)
        text_(hover_text, 10, SCREEN_H - 24, 14)
    end

    -- ── Selected province popup ───────────────────────────────────────────
    if selected_id and hud_province ~= "" then
        local txt_w = 500
        lurek.render.setColor(0.0, 0.0, 0.0, 0.72)
        rect("fill", SCREEN_W/2 - txt_w/2, SCREEN_H - 60, txt_w, 28)
        lurek.render.setColor(1.0, 0.85, 0.1)
        text_(hud_province, SCREEN_W/2 - txt_w/2 + 8, SCREEN_H - 54, 14)
        local sel = projected_cache[selected_id]
        if sel then
            lurek.render.setColor(1.0, 0.85, 0.1, 0.65)
            ln(GLOBE_CX, GLOBE_CY, sel.x, sel.y)
            circ("line", sel.x, sel.y, 10)
        end
    end

    -- ── Controls reminder (bottom-right) ─────────────────────────────────
    lurek.render.setColor(0.5, 0.5, 0.5, 0.8)
    text_("Drag/mouse: pan+pick   D-pad/WASD: pan   Shoulder/PgUpPgDn: zoom   A/Enter: select   Esc: quit",
        SCREEN_W - 760, SCREEN_H - 20, 13)

    lurek.render.setColor(0.7, 0.85, 1.0, 0.85)
    text_(hud_status, 12, SCREEN_H - 22, 13)
end
