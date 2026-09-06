local Fixture = {}

local EU2 = {
    map = "lurek_2d_content/games/eu2/map.png",
    colors = "lurek_2d_content/games/eu2/prov_cols.csv",
    provinces = "lurek_2d_content/games/eu2/province.toml",
    scenario = "lurek_2d_content/games/eu2/scripts/scenario.lua",
    state = "lurek_2d_content/games/eu2/scripts/state.lua",
}

local FONT = {
    [" "] = { "000", "000", "000", "000", "000", "000", "000" },
    ["-"] = { "00000", "00000", "00000", "11110", "00000", "00000", "00000" },
    [":"] = { "000", "010", "000", "000", "010", "000", "000" },
    ["/"] = { "00001", "00010", "00010", "00100", "01000", "01000", "10000" },
    ["."] = { "000", "000", "000", "000", "000", "010", "000" },
    ["0"] = { "01110", "10001", "10011", "10101", "11001", "10001", "01110" },
    ["1"] = { "00100", "01100", "00100", "00100", "00100", "00100", "01110" },
    ["2"] = { "01110", "10001", "00001", "00010", "00100", "01000", "11111" },
    ["3"] = { "11110", "00001", "00001", "01110", "00001", "00001", "11110" },
    ["4"] = { "00010", "00110", "01010", "10010", "11111", "00010", "00010" },
    ["5"] = { "11111", "10000", "10000", "11110", "00001", "00001", "11110" },
    ["6"] = { "01110", "10000", "10000", "11110", "10001", "10001", "01110" },
    ["7"] = { "11111", "00001", "00010", "00100", "01000", "01000", "01000" },
    ["8"] = { "01110", "10001", "10001", "01110", "10001", "10001", "01110" },
    ["9"] = { "01110", "10001", "10001", "01111", "00001", "00001", "01110" },
    A = { "01110", "10001", "10001", "11111", "10001", "10001", "10001" },
    B = { "11110", "10001", "10001", "11110", "10001", "10001", "11110" },
    C = { "01111", "10000", "10000", "10000", "10000", "10000", "01111" },
    D = { "11110", "10001", "10001", "10001", "10001", "10001", "11110" },
    E = { "11111", "10000", "10000", "11110", "10000", "10000", "11111" },
    F = { "11111", "10000", "10000", "11110", "10000", "10000", "10000" },
    G = { "01111", "10000", "10000", "10011", "10001", "10001", "01111" },
    H = { "10001", "10001", "10001", "11111", "10001", "10001", "10001" },
    I = { "11111", "00100", "00100", "00100", "00100", "00100", "11111" },
    J = { "00111", "00010", "00010", "00010", "00010", "10010", "01100" },
    K = { "10001", "10010", "10100", "11000", "10100", "10010", "10001" },
    L = { "10000", "10000", "10000", "10000", "10000", "10000", "11111" },
    M = { "10001", "11011", "10101", "10101", "10001", "10001", "10001" },
    N = { "10001", "11001", "10101", "10011", "10001", "10001", "10001" },
    O = { "01110", "10001", "10001", "10001", "10001", "10001", "01110" },
    P = { "11110", "10001", "10001", "11110", "10000", "10000", "10000" },
    Q = { "01110", "10001", "10001", "10001", "10101", "10010", "01101" },
    R = { "11110", "10001", "10001", "11110", "10100", "10010", "10001" },
    S = { "01111", "10000", "10000", "01110", "00001", "00001", "11110" },
    T = { "11111", "00100", "00100", "00100", "00100", "00100", "00100" },
    U = { "10001", "10001", "10001", "10001", "10001", "10001", "01110" },
    V = { "10001", "10001", "10001", "10001", "10001", "01010", "00100" },
    W = { "10001", "10001", "10001", "10101", "10101", "10101", "01010" },
    X = { "10001", "10001", "01010", "00100", "01010", "10001", "10001" },
    Y = { "10001", "10001", "01010", "00100", "00100", "00100", "00100" },
    Z = { "11111", "00001", "00010", "00100", "01000", "10000", "11111" },
}

local COUNTRY_COLORS = {
    POL = { 198, 42, 52 },
    LIT = { 118, 80, 172 },
    TEU = { 210, 210, 190 },
    MOS = { 116, 190, 120 },
    OTT = { 60, 150, 95 },
    FRA = { 70, 95, 200 },
    ENG = { 185, 65, 65 },
    CAS = { 230, 198, 58 },
    NEU = { 126, 126, 118 },
    SEA = { 56, 110, 172 },
}

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function draw_text(img, text, x, y, scale, r, g, b)
    text = string.upper(tostring(text or "")):gsub("[^A-Z0-9 :%-%./]", " ")
    scale = scale or 1
    local cursor = math.floor(x)
    for i = 1, #text do
        local glyph = FONT[string.sub(text, i, i)] or FONT[" "]
        for gy = 1, #glyph do
            local row = glyph[gy]
            for gx = 1, #row do
                if string.sub(row, gx, gx) == "1" then
                    img:drawRect(cursor + (gx - 1) * scale, y + (gy - 1) * scale, scale, scale, r, g, b, 255)
                end
            end
        end
        cursor = cursor + (#glyph[1] + 1) * scale
    end
end

local function draw_title(img, title, subtitle)
    img:drawRect(18, 16, img:getWidth() - 36, 42, 26, 32, 46, 255)
    draw_text(img, title, 34, 30, 1, 238, 242, 248)
    if subtitle then
        draw_text(img, subtitle, 34, 46, 1, 168, 184, 206)
    end
end

local function owner_color(owner)
    return COUNTRY_COLORS[owner or "NEU"] or COUNTRY_COLORS.NEU
end

local function terrain_color(terrain)
    terrain = tostring(terrain or ""):lower()
    if terrain == "sea" or terrain == "river" or terrain == "ocean" then return { 42, 91, 148 } end
    if terrain == "forest" then return { 74, 142, 88 } end
    if terrain == "mountain" then return { 128, 120, 112 } end
    if terrain == "desert" then return { 202, 176, 112 } end
    if terrain == "marsh" then return { 88, 142, 132 } end
    return { 96, 154, 90 }
end

local function economy_color(income)
    local t = clamp((tonumber(income) or 0) / 10, 0, 1)
    return {
        math.floor(70 + 170 * t),
        math.floor(60 + 145 * t),
        math.floor(42 + 24 * t),
    }
end

local function unrest_color(unrest)
    local t = clamp((tonumber(unrest) or 0) / 10, 0, 1)
    return {
        math.floor(58 + 176 * t),
        math.floor(126 - 88 * t),
        math.floor(74 - 40 * t),
    }
end

local function province_centroid(province)
    local c = province and province.centroid
    if type(c) == "table" then
        return c.x or c[1], c.y or c[2]
    end
    return nil, nil
end

local function state_province(loaded, id)
    return loaded.state and loaded.state.provinces and loaded.state.provinces[id]
end

local function image_canvas(w, h, title, subtitle)
    local img = lurek.image.newImageData(w, h)
    img:fill(9, 13, 22, 255)
    draw_title(img, title, subtitle)
    return img
end

local function load_module(path)
    local chunk = lurek.filesystem.load(path)
    expect_type("function", chunk)
    local ok, module = pcall(chunk)
    expect_true(ok)
    return module
end

local function import_state(registry)
    local scenario_module = load_module(EU2.scenario)
    local state_module = load_module(EU2.state)
    local scenario = scenario_module.build(registry)
    return state_module.new(registry, scenario)
end

local function decorate_labels_and_capitals(registry, state)
    local decorated = 0
    local ids = registry:provinceIds()
    table.sort(ids)
    for _, id in ipairs(ids) do
        local province = state and state.provinces and state.provinces[id]
        if province and province.owner ~= "SEA" and province.cx and province.cy then
            registry:setCapital(id, province.cx, province.cy)
            registry:setLabelText(id, province.name or ("Province " .. tostring(id)))
            registry:setLabelLine(id, province.cx - 18, province.cy - 5, province.cx + 18, province.cy + 5)
            decorated = decorated + 1
            if decorated >= 40 then
                break
            end
        end
    end
    return decorated
end

function Fixture.load_registry(name, sanitized_path)
    local out_path = sanitized_path or "tests/artifacts/current/province/province_sanitized_map.png"
    local summary = lurek.province.sanitizeMarkedPng(EU2.map, out_path)
    local registry = lurek.province.newFromPng(name, out_path)
    local imported = registry:importMetadataFromFiles({
        color_map_png = out_path,
        marker_png = EU2.map,
        color_csv = EU2.colors,
        province_toml = EU2.provinces,
        water_terrain_tokens = { "sea", "river" },
        water_terrain_type = 0,
        land_terrain_type = 1,
        set_political_colors = true,
        set_label_text = true,
        set_capitals = true,
        set_label_lines = true,
    })
    local state = import_state(registry)
    local decorated_labels = decorate_labels_and_capitals(registry, state)
    return {
        sanitized_path = out_path,
        summary = summary,
        registry = registry,
        imported = imported,
        state = state,
        decorated_labels = decorated_labels,
    }
end

local function scaled_source(path, w, h)
    return lurek.image.newImageData(path):resize(w, h, "bilinear")
end

local function draw_span_map(canvas, loaded, x, y, scale, mode)
    local registry = loaded.registry
    local state = loaded.state
    local row_h = math.max(1, math.floor(scale + 0.5))
    for _, span in ipairs(registry:provinceSpans()) do
        local id = span.province_id
        local gp = state and state.provinces[id]
        local snap = registry:getProvince(id)
        local color
        if mode == "terrain" then
            color = terrain_color(gp and gp.terrain or snap and snap.attrs and snap.attrs.terrain)
        elseif mode == "economy" then
            color = economy_color(gp and gp.income)
        elseif mode == "fog" then
            local visibility = snap and snap.style and snap.style.visibility_state or 2
            if visibility == 0 then
                color = { 18, 22, 30 }
            elseif visibility == 1 then
                color = { 96, 102, 112 }
            else
                color = owner_color(gp and gp.owner)
            end
        elseif mode == "unrest" then
            color = unrest_color(gp and gp.unrest)
        else
            color = owner_color(gp and gp.owner)
        end
        local px = x + math.floor(span.x0 * scale)
        local py = y + math.floor(span.y * scale)
        local pw = math.max(1, math.floor((span.x1 - span.x0 + 1) * scale + 0.5))
        canvas:drawRect(px, py, pw, row_h, color[1], color[2], color[3], 255)
    end
end

local function draw_border_overlay(canvas, loaded, x, y, scale, all_alpha, country_alpha)
    for _, segment in ipairs(loaded.registry:borderSegments()) do
        local a = state_province(loaded, segment.province_a)
        local b = state_province(loaded, segment.province_b)
        local sea_edge = a and b and ((a.owner == "SEA") ~= (b.owner == "SEA"))
        local country_edge = a and b and a.owner ~= b.owner and a.owner ~= "SEA" and b.owner ~= "SEA"
        local r, g, bl, alpha = 64, 64, 60, all_alpha or 130
        if sea_edge then
            r, g, bl, alpha = 224, 196, 128, country_alpha or 230
        elseif country_edge then
            r, g, bl, alpha = 240, 78, 72, country_alpha or 230
        end
        canvas:drawLine(
            x + math.floor(segment.x0 * scale),
            y + math.floor(segment.y0 * scale),
            x + math.floor(segment.x1 * scale),
            y + math.floor(segment.y1 * scale),
            r,
            g,
            bl,
            alpha
        )
    end
end

local function sorted_ids(registry)
    local ids = registry:provinceIds()
    table.sort(ids)
    return ids
end

local function interesting_land_ids(loaded, limit)
    local picked = {}
    for _, id in ipairs(sorted_ids(loaded.registry)) do
        local p = state_province(loaded, id)
        if p and p.owner ~= "SEA" and p.cx and p.cy then
            picked[#picked + 1] = id
            if limit and #picked >= limit then
                break
            end
        end
    end
    return picked
end

local function draw_centroid_marker(canvas, cx, cy, r, g, b)
    canvas:drawCircle(cx, cy, 5, 8, 10, 16, 255)
    canvas:drawCircle(cx, cy, 3, r, g, b, 255)
end

function Fixture.render_span_runs(loaded)
    local scale = 0.72
    local registry = loaded.registry
    local canvas = image_canvas(790, 420, "PROVINCE SPAN GEOMETRY", "EU2 source map -> provinceSpans scanline cache")
    canvas:paste(scaled_source(loaded.sanitized_path, math.floor(registry:getWidth() * scale), math.floor(registry:getHeight() * scale)), 28, 72)
    for _, span in ipairs(registry:provinceSpans()) do
        if span.province_id ~= 0 and span.y % 4 == 0 then
            local y = 72 + math.floor(span.y * scale)
            canvas:drawLine(
                28 + math.floor(span.x0 * scale),
                y,
                28 + math.floor(span.x1 * scale),
                y,
                248,
                252,
                255,
                118
            )
        end
    end
    draw_text(canvas, "SPANS " .. tostring(#registry:provinceSpans()), 626, 96, 1, 238, 242, 248)
    draw_text(canvas, "IDS " .. tostring(registry:provinceCount()), 626, 120, 1, 238, 242, 248)
    return canvas
end

function Fixture.render_border_segments(loaded)
    local registry = loaded.registry
    local scale = 0.72
    local canvas = image_canvas(790, 420, "PROVINCE BORDERS", "internal borders, country borders, and coast/sea borders")
    canvas:paste(scaled_source(loaded.sanitized_path, math.floor(registry:getWidth() * scale), math.floor(registry:getHeight() * scale)), 28, 72)
    draw_border_overlay(canvas, loaded, 28, 72, scale, 128, 245)
    draw_text(canvas, "DARK GRAY LOCAL", 626, 96, 1, 204, 214, 228)
    draw_text(canvas, "RED COUNTRY", 626, 120, 1, 240, 78, 72)
    draw_text(canvas, "SAND COAST", 626, 144, 1, 224, 196, 128)
    draw_text(canvas, "SEG " .. tostring(#registry:borderSegments()), 626, 190, 1, 238, 242, 248)
    return canvas
end

local function route_between_army_and_target(loaded)
    local state = loaded.state
    local registry = loaded.registry
    local army = state and state.armies and state.armies[1]
    if not army then
        return {}, nil, nil
    end
    local start_snap = registry:getProvince(army.province_id)
    local sx, sy = province_centroid(start_snap)
    local best_route, best_target, best_score = nil, nil, nil
    local target = nil
    for _, id in ipairs(sorted_ids(registry)) do
        local province = state.provinces[id]
        if province and province.owner ~= "SEA" and province.owner ~= army.tag then
            local route = registry:findRoute(army.province_id, id)
            if route and #route >= 4 and #route <= 14 then
                local snap = registry:getProvince(id)
                local tx, ty = province_centroid(snap)
                if sx and sy and tx and ty then
                    local dx, dy = tx - sx, ty - sy
                    local distance = math.sqrt(dx * dx + dy * dy)
                    if distance < 280 then
                        local score = distance + #route * 12
                        if best_score == nil or score < best_score then
                            best_route, best_target, best_score = route, id, score
                        end
                    end
                end
            end
        end
    end
    if best_route then
        return best_route, army, best_target
    end
    return registry:findRoute(army.province_id, army.province_id) or { army.province_id }, army, army.province_id
end

local function draw_route(canvas, loaded, route, x, y, scale, progress)
    progress = progress or #route
    for i = 1, #route - 1 do
        local a = loaded.registry:getProvince(route[i])
        local b = loaded.registry:getProvince(route[i + 1])
        local ax, ay = province_centroid(a)
        local bx, by = province_centroid(b)
        if ax and bx then
            canvas:drawLine(x + math.floor(ax * scale), y + math.floor(ay * scale), x + math.floor(bx * scale), y + math.floor(by * scale), 255, 220, 82, 255)
            canvas:drawLine(x + math.floor(ax * scale), y + math.floor(ay * scale) + 2, x + math.floor(bx * scale), y + math.floor(by * scale) + 2, 255, 220, 82, 160)
        end
    end
    for i, id in ipairs(route) do
        local snap = loaded.registry:getProvince(id)
        local cx, cy = province_centroid(snap)
        if cx and cy then
            local r, g, b = 255, 220, 82
            if i <= progress then
                r, g, b = 120, 230, 150
            end
            draw_centroid_marker(canvas, x + math.floor(cx * scale), y + math.floor(cy * scale), r, g, b)
        end
    end
end

local function draw_outline_rect(canvas, x, y, w, h, r, g, b, a)
    canvas:drawLine(x, y, x + w, y, r, g, b, a)
    canvas:drawLine(x + w, y, x + w, y + h, r, g, b, a)
    canvas:drawLine(x + w, y + h, x, y + h, r, g, b, a)
    canvas:drawLine(x, y + h, x, y, r, g, b, a)
end

local function draw_thick_line(canvas, x0, y0, x1, y1, r, g, b, a, thickness)
    local radius = math.max(0, math.floor((thickness or 1) / 2))
    for offset = -radius, radius do
        canvas:drawLine(x0 + offset, y0, x1 + offset, y1, r, g, b, a)
        if offset ~= 0 then
            canvas:drawLine(x0, y0 + offset, x1, y1 + offset, r, g, b, a)
        end
    end
end

local function pair_key(a, b)
    if a > b then
        a, b = b, a
    end
    return tostring(a) .. ":" .. tostring(b)
end

local function draw_curved_route(canvas, loaded, route, x, y, scale, visual_scale)
    visual_scale = visual_scale or 1
    for i = 1, #route - 1 do
        local a = loaded.registry:getProvince(route[i])
        local b = loaded.registry:getProvince(route[i + 1])
        local ax, ay = province_centroid(a)
        local bx, by = province_centroid(b)
        if ax and ay and bx and by then
            local dx, dy = bx - ax, by - ay
            local len = math.max(1, math.sqrt(dx * dx + dy * dy))
            local cx = (ax + bx) * 0.5 + (-dy / len) * 18
            local cy = (ay + by) * 0.5 + (dx / len) * 18
            local last_x = x + math.floor(ax * scale)
            local last_y = y + math.floor(ay * scale)
            for step = 1, 12 do
                local t = step / 12
                local mt = 1 - t
                local qx = mt * mt * ax + 2 * mt * t * cx + t * t * bx
                local qy = mt * mt * ay + 2 * mt * t * cy + t * t * by
                local px = x + math.floor(qx * scale)
                local py = y + math.floor(qy * scale)
                draw_thick_line(canvas, last_x, last_y, px, py, 255, 222, 88, 230, 3 * visual_scale)
                last_x, last_y = px, py
            end
        end
    end
    for _, id in ipairs(route) do
        local snap = loaded.registry:getProvince(id)
        local cx, cy = province_centroid(snap)
        if cx and cy then
            draw_centroid_marker(canvas, x + math.floor(cx * scale), y + math.floor(cy * scale), 255, 222, 88)
        end
    end
end

function Fixture.render_route_trace(loaded)
    local route, army, target = route_between_army_and_target(loaded)
    local scale = 0.72
    local canvas = image_canvas(790, 420, "PROVINCE ARMY ROUTE", "route adapter path from campaign army to neighboring territory")
    draw_span_map(canvas, loaded, 28, 72, scale, "political")
    draw_border_overlay(canvas, loaded, 28, 72, scale, 90, 220)
    draw_route(canvas, loaded, route, 28, 72, scale)
    if army then
        local start = loaded.registry:getProvince(army.province_id)
        local sx, sy = province_centroid(start)
        if sx and sy then
            canvas:drawRect(28 + math.floor(sx * scale) - 9, 72 + math.floor(sy * scale) - 7, 18, 14, 255, 238, 178, 255)
            canvas:drawRect(28 + math.floor(sx * scale) - 6, 72 + math.floor(sy * scale) - 4, 12, 8, 198, 42, 52, 255)
        end
    end
    draw_text(canvas, "ROUTE NODES " .. tostring(#route), 616, 100, 1, 255, 220, 82)
    draw_text(canvas, "ARMY " .. tostring(army and army.tag or "-"), 616, 126, 1, 238, 242, 248)
    draw_text(canvas, "TARGET " .. tostring(target or "-"), 616, 150, 1, 238, 242, 248)
    return canvas
end

function Fixture.render_capitals_centroids(loaded)
    local registry = loaded.registry
    local crop_x, crop_y, crop_w, crop_h = 350, 28, 330, 210
    local scale = 2.0
    local canvas = image_canvas(790, 540, "PROVINCE CAPITALS LABELS", "zoomed EU2 region: imported names, campaign capitals, centroids")
    local crop = lurek.image.newImageData(loaded.sanitized_path):crop(crop_x, crop_y, crop_w, crop_h):resize(crop_w * scale, crop_h * scale, "bilinear")
    canvas:paste(crop, 36, 82)
    for _, segment in ipairs(registry:borderSegments()) do
        if segment.x0 >= crop_x and segment.x0 <= crop_x + crop_w and segment.y0 >= crop_y and segment.y0 <= crop_y + crop_h then
            local a = state_province(loaded, segment.province_a)
            local b = state_province(loaded, segment.province_b)
            local country_edge = a and b and a.owner ~= b.owner and a.owner ~= "SEA" and b.owner ~= "SEA"
            local r, g, bl = 28, 32, 42
            if country_edge then
                r, g, bl = 240, 78, 72
            end
            canvas:drawLine(
                36 + math.floor((segment.x0 - crop_x) * scale),
                82 + math.floor((segment.y0 - crop_y) * scale),
                36 + math.floor((segment.x1 - crop_x) * scale),
                82 + math.floor((segment.y1 - crop_y) * scale),
                r,
                g,
                bl,
                country_edge and 230 or 130
            )
        end
    end

    local ids = {}
    local seen = {}
    for _, army in ipairs(loaded.state.armies or {}) do
        if army.province_id and not seen[army.province_id] then
            ids[#ids + 1] = army.province_id
            seen[army.province_id] = true
        end
        if #ids >= 10 then
            break
        end
    end
    if #ids < 8 then
        for _, id in ipairs(interesting_land_ids(loaded, 24)) do
            if not seen[id] then
                ids[#ids + 1] = id
                seen[id] = true
                if #ids >= 10 then
                    break
                end
            end
        end
    end
    local offsets = {
        { 12, -24 },
        { 14, 12 },
        { -66, -22 },
        { -62, 14 },
        { 14, -10 },
        { -70, -8 },
        { 10, 24 },
        { -62, 26 },
        { 16, -34 },
        { -72, -32 },
    }
    for index, id in ipairs(ids) do
        local snap = registry:getProvince(id)
        local province = state_province(loaded, id)
        local cx, cy = province_centroid(snap)
        if cx and cy and cx >= crop_x and cx <= crop_x + crop_w and cy >= crop_y and cy <= crop_y + crop_h then
            local px = 36 + math.floor((cx - crop_x) * scale)
            local py = 82 + math.floor((cy - crop_y) * scale)
            draw_centroid_marker(canvas, px, py, 255, 210, 96)
            local name = province and province.name or tostring(id)
            local offset = offsets[((index - 1) % #offsets) + 1]
            canvas:drawLine(px, py, px + offset[1], py + offset[2], 255, 210, 96, 180)
            draw_text(canvas, string.sub(name, 1, 12), px + offset[1], py + offset[2], 1, 238, 242, 248)
        end
    end

    for _, army in ipairs(loaded.state.armies or {}) do
        local province = loaded.state.provinces[army.province_id]
        if province and province.cx and province.cx >= crop_x and province.cx <= crop_x + crop_w and province.cy >= crop_y and province.cy <= crop_y + crop_h then
            local px = 36 + math.floor((province.cx - crop_x) * scale)
            local py = 82 + math.floor((province.cy - crop_y) * scale)
            canvas:drawRect(px - 5, py - 5, 10, 10, 8, 10, 16, 255)
            canvas:drawRect(px - 3, py - 3, 6, 6, 255, 224, 88, 255)
        end
    end

    draw_text(canvas, "DOT CENTROID", 710, 120, 1, 255, 210, 96)
    draw_text(canvas, "SQUARE CAPITAL", 710, 144, 1, 255, 224, 88)
    draw_text(canvas, "RED COUNTRY", 710, 168, 1, 240, 78, 72)
    draw_text(canvas, "LABELS", 710, 192, 1, 238, 242, 248)
    return canvas
end

local function prepare_strategy_state(loaded)
    local registry = loaded.registry
    for _, id in ipairs(sorted_ids(registry)) do
        local p = state_province(loaded, id)
        if p then
            registry:setAttr(id, "owner", p.owner)
            registry:setAttr(id, "income", tostring(p.income or 0))
            registry:setAttr(id, "unrest", tostring(p.unrest or 0))
            registry:setTerrainType(id, p.owner == "SEA" and 0 or 1)
            registry:setVisibilityState(id, 2)
            registry:setFogState(id, 0)
        end
    end
end

local function select_land_adjacencies(loaded, limit)
    local picked = {}
    for _, pair in ipairs(loaded.registry:adjacencies()) do
        local a = state_province(loaded, pair.province_a)
        local b = state_province(loaded, pair.province_b)
        if a and b and a.owner ~= "SEA" and b.owner ~= "SEA" then
            picked[#picked + 1] = pair
            if limit and #picked >= limit then
                break
            end
        end
    end
    return picked
end

local function prepare_render_plan_state(loaded)
    prepare_strategy_state(loaded)
    local registry = loaded.registry
    local palette = {
        { 0.74, 0.19, 0.22, 1.0 },
        { 0.16, 0.43, 0.78, 1.0 },
        { 0.88, 0.74, 0.20, 1.0 },
        { 0.36, 0.64, 0.34, 1.0 },
        { 0.70, 0.38, 0.82, 1.0 },
    }
    for i, id in ipairs(interesting_land_ids(loaded, 70)) do
        local color = palette[((i - 1) % #palette) + 1]
        registry:setPoliticalColor(id, color[1], color[2], color[3], color[4])
        registry:setTerrainType(id, 2 + (i % 3))
    end

    local styled = select_land_adjacencies(loaded, 2)
    local highlighted = {}
    if styled[1] then
        registry:setBorderPairStyle(styled[1].province_a, styled[1].province_b, {
            color = { 1.0, 0.18, 0.12, 1.0 },
            thickness = 5.0,
            flags = { "country" },
        })
        highlighted[pair_key(styled[1].province_a, styled[1].province_b)] = { 255, 72, 48, 255, 5 }
    end
    if styled[2] then
        registry:registerBorderType(7, {
            name = "evidence wide frontier",
            color = { 44, 132, 255, 255 },
            thickness = 4.0,
            draw_priority = 2,
        })
        registry:setBorderType(styled[2].province_a, styled[2].province_b, 7)
        highlighted[pair_key(styled[2].province_a, styled[2].province_b)] = { 44, 132, 255, 245, 4 }
    end
    return highlighted
end

local function draw_runtime_tinted_span_map(canvas, loaded, x, y, scale, tint)
    tint = tint or { 1, 1, 1 }
    local row_h = math.max(1, math.floor(scale + 0.5))
    for _, span in ipairs(loaded.registry:provinceSpans()) do
        local snap = loaded.registry:getProvince(span.province_id)
        local color
        if snap and snap.style and snap.style.political_color then
            local pc = snap.style.political_color
            color = {
                math.floor(clamp(pc[1] * tint[1], 0, 1) * 255),
                math.floor(clamp(pc[2] * tint[2], 0, 1) * 255),
                math.floor(clamp(pc[3] * tint[3], 0, 1) * 255),
            }
        else
            local gp = state_province(loaded, span.province_id)
            color = owner_color(gp and gp.owner)
        end
        canvas:drawRect(
            x + math.floor(span.x0 * scale),
            y + math.floor(span.y * scale),
            math.max(1, math.floor((span.x1 - span.x0 + 1) * scale + 0.5)),
            row_h,
            color[1],
            color[2],
            color[3],
            255
        )
    end
end

local function draw_terrain_watermark(canvas, loaded, x, y, scale, visual_scale)
    visual_scale = visual_scale or 1
    for _, span in ipairs(loaded.registry:provinceSpans()) do
        local snap = loaded.registry:getProvince(span.province_id)
        local terrain_type = snap and snap.style and snap.style.terrain_type or 0
        if terrain_type >= 2 and span.y % 8 == terrain_type % 8 then
            local px0 = x + math.floor(span.x0 * scale)
            local px1 = x + math.floor(span.x1 * scale)
            local py = y + math.floor(span.y * scale)
            local step = math.max(1, math.floor((terrain_type == 2 and 13 or 17) * visual_scale))
            for px = px0, px1, step do
                if terrain_type == 2 then
                    canvas:drawLine(px, py, px + 4 * visual_scale, py - 4 * visual_scale, 232, 236, 226, 18)
                    canvas:drawLine(px + 4 * visual_scale, py - 4 * visual_scale, px + 8 * visual_scale, py, 232, 236, 226, 18)
                elseif terrain_type == 3 then
                    canvas:drawLine(px, py - 2 * visual_scale, px + 7 * visual_scale, py + 3 * visual_scale, 236, 236, 236, 16)
                else
                    canvas:drawRect(px, py, 5 * visual_scale, math.max(1, visual_scale), 232, 236, 226, 14)
                end
            end
        end
    end
end

local function draw_styled_runtime_borders(canvas, loaded, x, y, scale, highlighted, visual_scale)
    visual_scale = visual_scale or 1
    for _, segment in ipairs(loaded.registry:borderSegments()) do
        local a = state_province(loaded, segment.province_a)
        local b = state_province(loaded, segment.province_b)
        local sea_edge = a and b and ((a.owner == "SEA") ~= (b.owner == "SEA"))
        local country_edge = a and b and a.owner ~= b.owner and a.owner ~= "SEA" and b.owner ~= "SEA"
        local r, g, bl, alpha, width = 64, 64, 60, 210, math.max(1, visual_scale)
        if sea_edge then
            r, g, bl, alpha, width = 224, 196, 128, 238, math.max(2, visual_scale * 1.4)
        elseif country_edge then
            r, g, bl, alpha, width = 230, 48, 44, 245, math.max(2, visual_scale * 1.6)
        end
        draw_thick_line(
            canvas,
            x + math.floor(segment.x0 * scale),
            y + math.floor(segment.y0 * scale),
            x + math.floor(segment.x1 * scale),
            y + math.floor(segment.y1 * scale),
            r,
            g,
            bl,
            alpha,
            width
        )
    end
    for _, segment in ipairs(loaded.registry:borderSegments()) do
        local style = highlighted[pair_key(segment.province_a, segment.province_b)]
        if style then
            local x0 = x + math.floor(segment.x0 * scale)
            local y0 = y + math.floor(segment.y0 * scale)
            local x1 = x + math.floor(segment.x1 * scale)
            local y1 = y + math.floor(segment.y1 * scale)
            draw_thick_line(canvas, x0, y0, x1, y1, 12, 14, 20, 135, (style[5] + 2) * visual_scale)
            draw_thick_line(canvas, x0, y0, x1, y1, style[1], style[2], style[3], style[4], style[5] * visual_scale)
        end
    end
end

function Fixture.render_render_plan_overlay(loaded, scale_factor, opts)
    scale_factor = scale_factor or 1
    opts = opts or {}
    local highlighted = prepare_render_plan_state(loaded)
    local registry = loaded.registry
    local route = route_between_army_and_target(loaded)
    loaded.render_plan_path_primitives = registry:drawCapitalPath(route, {
        mode = "bezier",
        color = { 1.0, 0.86, 0.22, 1.0 },
        width = 3.0,
        curve_offset = 18.0,
        segments = 12,
    })

    local canvas = image_canvas(1040 * scale_factor, 620 * scale_factor, "PROVINCE RENDER PLAN", "runtime tint, terrain watermark, styled borders, route, viewport rect")
    local scale = 0.62 * scale_factor
    local map_x, map_y = 28 * scale_factor, 80 * scale_factor
    local text_scale = math.max(1, math.floor(scale_factor + 0.5))
    draw_runtime_tinted_span_map(canvas, loaded, map_x, map_y, scale, { 0.92, 0.98, 1.02 })
    local show_watermark = opts.show_watermark
    if show_watermark == nil then
        show_watermark = scale_factor <= 1
    end
    if show_watermark then
        draw_terrain_watermark(canvas, loaded, map_x, map_y, scale, scale_factor)
    end
    draw_styled_runtime_borders(canvas, loaded, map_x, map_y, scale, highlighted, scale_factor)
    local show_route = opts.show_route
    if show_route == nil then
        show_route = scale_factor <= 1
    end
    if show_route then
        draw_curved_route(canvas, loaded, route, map_x, map_y, scale, scale_factor)
    end

    local viewport = registry:viewportRect({
        x = -118,
        y = -76,
        zoom = 1.85,
        pixel_size = 1.0,
        screen_w = 430,
        screen_h = 240,
    })
    local vx = map_x + math.floor(viewport.x * scale)
    local vy = map_y + math.floor(viewport.y * scale)
    local vw = math.floor(viewport.w * scale)
    local vh = math.floor(viewport.h * scale)
    local show_viewport = opts.show_viewport
    if show_viewport == nil then
        show_viewport = scale_factor <= 1
    end
    if show_viewport then
        draw_outline_rect(canvas, vx - 1, vy - 1, vw + 2, vh + 2, 8, 12, 18, 230)
        draw_outline_rect(canvas, vx, vy, vw, vh, 84, 232, 255, 255)
    end

    local inset_x, inset_y, inset_scale = 690 * scale_factor, 104 * scale_factor, 0.30 * scale_factor
    canvas:drawRect(inset_x - 6 * scale_factor, inset_y - 6 * scale_factor, 284 * scale_factor, 164 * scale_factor, 26, 32, 46, 255)
    draw_runtime_tinted_span_map(canvas, loaded, inset_x, inset_y, inset_scale, { 0.82, 0.88, 0.92 })
    draw_styled_runtime_borders(canvas, loaded, inset_x, inset_y, inset_scale, highlighted, scale_factor)
    draw_outline_rect(
        canvas,
        inset_x + math.floor(viewport.x * inset_scale),
        inset_y + math.floor(viewport.y * inset_scale),
        math.floor(viewport.w * inset_scale),
        math.floor(viewport.h * inset_scale),
        84,
        232,
        255,
        255
    )

    draw_text(canvas, "UNIFORM TINT", 704 * scale_factor, 304 * scale_factor, text_scale, 238, 242, 248)
    draw_text(canvas, "8X8 WATERMARK", 704 * scale_factor, 328 * scale_factor, text_scale, 232, 236, 226)
    draw_text(canvas, "PAIR STYLE RED", 704 * scale_factor, 352 * scale_factor, text_scale, 255, 72, 48)
    draw_text(canvas, "TYPE WIDTH BLUE", 704 * scale_factor, 376 * scale_factor, text_scale, 44, 132, 255)
    draw_text(canvas, "CAPITAL BEZIER " .. tostring(loaded.render_plan_path_primitives or 0), 704 * scale_factor, 400 * scale_factor, text_scale, 255, 222, 88)
    draw_text(canvas, "VIEWPORT " .. tostring(math.floor(viewport.w)) .. "X" .. tostring(math.floor(viewport.h)), 704 * scale_factor, 424 * scale_factor, text_scale, 84, 232, 255)
    return canvas
end

function Fixture.render_strategy_modes(loaded)
    prepare_strategy_state(loaded)
    local registry = loaded.registry
    local ids = interesting_land_ids(loaded, 80)
    for i, id in ipairs(ids) do
        if i % 5 == 0 then
            registry:setVisibilityState(id, 1)
            registry:setFogState(id, 160)
        elseif i % 9 == 0 then
            registry:setVisibilityState(id, 0)
        end
    end

    local canvas = image_canvas(980, 600, "PROVINCE MAP MODES", "political, terrain, economy, and fog-of-war from the same registry")
    local panels = {
        { "POLITICAL", "political", 28, 78 },
        { "TERRAIN", "terrain", 498, 78 },
        { "ECONOMY", "economy", 28, 336 },
        { "FOG", "fog", 498, 336 },
    }
    local scale = 0.43
    for _, panel in ipairs(panels) do
        canvas:drawRect(panel[3] - 3, panel[4] - 3, 436, 206, 32, 38, 54, 255)
        draw_span_map(canvas, loaded, panel[3], panel[4], scale, panel[2])
        draw_border_overlay(canvas, loaded, panel[3], panel[4], scale, 70, 180)
        draw_text(canvas, panel[1], panel[3] + 10, panel[4] + 176, 1, 238, 242, 248)
    end
    draw_text(canvas, "DISCOVERED GRAY", 744, 542, 1, 170, 180, 194)
    draw_text(canvas, "HIDDEN BLACK", 744, 566, 1, 112, 122, 138)
    return canvas
end

function Fixture.render_zoom_pick_view(loaded)
    local registry = loaded.registry
    local pick_target = interesting_land_ids(loaded, 1)[1]
    local pick_snap = registry:getProvince(pick_target)
    local target_x, target_y = province_centroid(pick_snap)
    expect_true(target_x ~= nil and target_y ~= nil)
    local fit_x, fit_y, fit_zoom = registry:fitCamera(900, 470, 1.0)
    local anchor_x = fit_x + target_x * fit_zoom
    local anchor_y = fit_y + target_y * fit_zoom
    local zoom_x, zoom_y = lurek.province.zoomCameraAt(anchor_x, anchor_y, fit_x, fit_y, fit_zoom, fit_zoom * 2.8)
    local pick_id = registry:screenToProvince(anchor_x, anchor_y, zoom_x, zoom_y, fit_zoom * 2.8, 1.0)
    local map_x, map_y = registry:screenToMap(anchor_x, anchor_y, zoom_x, zoom_y, fit_zoom * 2.8, 1.0)
    expect_equal(pick_target, pick_id)

    local canvas = image_canvas(930, 520, "PROVINCE ZOOM PICK", "camera fit/zoom adapter, screenToMap, and screenToProvince")
    local full = scaled_source(loaded.sanitized_path, 430, 194)
    canvas:paste(full, 36, 86)
    draw_border_overlay(canvas, loaded, 36, 86, 0.43, 80, 190)
    canvas:drawLine(36 + math.floor(map_x * 0.43) - 12, 86 + math.floor(map_y * 0.43), 36 + math.floor(map_x * 0.43) + 12, 86 + math.floor(map_y * 0.43), 255, 220, 90, 255)
    canvas:drawLine(36 + math.floor(map_x * 0.43), 86 + math.floor(map_y * 0.43) - 12, 36 + math.floor(map_x * 0.43), 86 + math.floor(map_y * 0.43) + 12, 255, 220, 90, 255)

    local crop_x = clamp(math.floor(map_x - 120), 0, registry:getWidth() - 240)
    local crop_y = clamp(math.floor(map_y - 80), 0, registry:getHeight() - 160)
    local zoom = lurek.image.newImageData(loaded.sanitized_path):crop(crop_x, crop_y, 240, 160):resize(480, 320, "bilinear")
    canvas:paste(zoom, 410, 86)

    for _, segment in ipairs(registry:borderSegments()) do
        if segment.x0 >= crop_x and segment.x0 <= crop_x + 240 and segment.y0 >= crop_y and segment.y0 <= crop_y + 160 then
            canvas:drawLine(
                410 + math.floor((segment.x0 - crop_x) * 2),
                86 + math.floor((segment.y0 - crop_y) * 2),
                410 + math.floor((segment.x1 - crop_x) * 2),
                86 + math.floor((segment.y1 - crop_y) * 2),
                20,
                24,
                34,
                190
            )
        end
    end
    local snap = registry:getProvince(pick_id)
    local cx, cy = province_centroid(snap)
    if cx and cy then
        draw_centroid_marker(canvas, 410 + math.floor((cx - crop_x) * 2), 86 + math.floor((cy - crop_y) * 2), 255, 220, 90)
    end
    draw_text(canvas, "FIT Z " .. tostring(math.floor(fit_zoom * 100)), 50, 312, 1, 238, 242, 248)
    draw_text(canvas, "PICK ID " .. tostring(pick_id), 410, 424, 1, 255, 220, 90)
    draw_text(canvas, "MAP " .. tostring(math.floor(map_x)) .. "/" .. tostring(math.floor(map_y)), 410, 448, 1, 238, 242, 248)
    return canvas
end

function Fixture.render_revision_timeline_frames(loaded)
    prepare_strategy_state(loaded)
    local route, army = route_between_army_and_target(loaded)
    local frames = {}
    local scale = 0.43
    local modes = { "political", "economy", "fog", "terrain", "political" }
    for frame = 1, #modes do
        if modes[frame] == "fog" then
            for i, id in ipairs(interesting_land_ids(loaded, 100)) do
                if i % 4 == 0 then
                    loaded.registry:setVisibilityState(id, 1)
                    loaded.registry:setFogState(id, 180)
                elseif i % 11 == 0 then
                    loaded.registry:setVisibilityState(id, 0)
                end
            end
        elseif modes[frame] == "political" then
            for _, id in ipairs(interesting_land_ids(loaded, 120)) do
                loaded.registry:setVisibilityState(id, 2)
            end
        end
        local canvas = image_canvas(520, 300, "PROVINCE CAMPAIGN TIMELINE", "mode " .. modes[frame] .. " / army movement")
        draw_span_map(canvas, loaded, 28, 72, scale, modes[frame])
        draw_border_overlay(canvas, loaded, 28, 72, scale, 60, 170)
        draw_route(canvas, loaded, route, 28, 72, scale, math.min(frame, #route))
        if army and route[math.min(frame, #route)] then
            local snap = loaded.registry:getProvince(route[math.min(frame, #route)])
            local cx, cy = province_centroid(snap)
            if cx and cy then
                canvas:drawRect(28 + math.floor(cx * scale) - 7, 72 + math.floor(cy * scale) - 5, 14, 10, 255, 238, 178, 255)
                canvas:drawRect(28 + math.floor(cx * scale) - 5, 72 + math.floor(cy * scale) - 3, 10, 6, 198, 42, 52, 255)
            end
        end
        draw_text(canvas, "FRAME " .. tostring(frame), 374, 252, 1, 238, 242, 248)
        frames[#frames + 1] = canvas
    end
    return frames
end

local function tiled_polygon_color(id)
    local colors = {
        [1] = { 190, 70, 70 },
        [2] = { 70, 115, 205 },
        [3] = { 80, 170, 105 },
    }
    return colors[id] or { 110, 120, 135 }
end

local function tiled_registry(backend)
    local registry = lurek.province.newFromTiled(
        "province_evidence_tiled_" .. backend,
        "tests/fixtures/province_polygon.tmj"
    )
    registry:render({
        backend = backend,
        selected_id = 1,
        hovered_id = 1,
        draw_labels = false,
        draw_capitals = false,
        draw_roads = false,
    })
    return registry
end

local function draw_tiled_polygon_map(canvas, registry, x, y, scale)
    for map_y = 0, registry:getHeight() - 1 do
        for map_x = 0, registry:getWidth() - 1 do
            local id = registry:pickProvince(map_x + 0.5, map_y + 0.5)
            if id then
                local color = tiled_polygon_color(id)
                canvas:drawRect(
                    x + map_x * scale,
                    y + map_y * scale,
                    scale + 1,
                    scale + 1,
                    color[1],
                    color[2],
                    color[3],
                    255
                )
            end
        end
    end
    for _, segment in ipairs(registry:borderSegments()) do
        canvas:drawLine(
            x + segment.x0 * scale,
            y + segment.y0 * scale,
            x + segment.x1 * scale,
            y + segment.y1 * scale,
            26,
            30,
            42,
            255
        )
    end
    for _, id in ipairs(registry:provinceIds()) do
        local snapshot = registry:getProvince(id)
        local capital = snapshot and snapshot.capital
        if capital then
            canvas:drawCircle(
                x + capital.x * scale,
                y + capital.y * scale,
                5,
                255,
                238,
                120,
                255
            )
            canvas:drawCircle(
                x + capital.x * scale,
                y + capital.y * scale,
                2,
                32,
                36,
                50,
                255
            )
        end
    end
    for _, polygon in ipairs(registry:getProvincePolygons(1)) do
        local vertices = polygon.vertices
        for index = 1, #vertices, 2 do
            local next_index = (index + 2 - 1) % #vertices + 1
            canvas:drawLine(
                x + vertices[index] * scale,
                y + vertices[index + 1] * scale,
                x + vertices[next_index] * scale,
                y + vertices[next_index + 1] * scale,
                255,
                225,
                55,
                255
            )
        end
    end
end

function Fixture.render_tiled_polygon(backend)
    local registry = tiled_registry(backend)
    local canvas = image_canvas(
        520,
        390,
        "TILED POLYGON " .. string.upper(backend),
        "concave components / islands / exact shared borders / explicit capitals"
    )
    draw_tiled_polygon_map(canvas, registry, 54, 94, 24)
    draw_text(canvas, "KIND " .. registry:getGeometryKind(), 360, 104, 1, 238, 242, 248)
    draw_text(canvas, "COMPONENTS " .. registry:getPolygonCount(), 360, 128, 1, 238, 242, 248)
    draw_text(canvas, "PROVINCE 1 " .. registry:getPolygonCount(1) .. " PARTS", 360, 152, 1, 238, 242, 248)
    draw_text(canvas, "GAP (11,9) " .. tostring(registry:pickProvince(11.5, 9.5)), 360, 176, 1, 238, 242, 248)
    draw_text(canvas, "YELLOW = SELECTED ISLANDS", 360, 222, 1, 255, 225, 55)
    draw_text(canvas, "GOLD DOT = CAPITAL", 360, 246, 1, 255, 238, 120)
    return canvas
end

function Fixture.tiled_polygon_topology()
    local registry = lurek.province.newFromTiled(
        "province_evidence_tiled_topology",
        "tests/fixtures/province_polygon.tmj"
    )
    local lines = {
        "Tiled polygon province topology",
        "geometry_kind=" .. registry:getGeometryKind(),
        "map_extent=" .. registry:getWidth() .. "x" .. registry:getHeight(),
        "polygon_count=" .. registry:getPolygonCount(),
    }
    for _, id in ipairs(registry:provinceIds()) do
        local snapshot = registry:getProvince(id)
        local capital = snapshot and snapshot.capital
        local capital_text = capital and string.format("%.3f,%.3f", capital.x, capital.y) or "nil"
        lines[#lines + 1] = string.format(
            "province=%d components=%d capital=%s",
            id,
            registry:getPolygonCount(id),
            capital_text
        )
    end
    for _, pair in ipairs(registry:adjacencies()) do
        lines[#lines + 1] = string.format("adjacency=%d-%d", pair.province_a, pair.province_b)
    end
    for _, segment in ipairs(registry:borderSegments()) do
        lines[#lines + 1] = string.format(
            "border=%d-%d %.3f,%.3f -> %.3f,%.3f",
            segment.province_a,
            segment.province_b,
            segment.x0,
            segment.y0,
            segment.x1,
            segment.y1
        )
    end
    return table.concat(lines, "\n") .. "\n"
end

return Fixture
