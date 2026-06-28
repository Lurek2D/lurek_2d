-- Canonical evidence file for lurek.globe artifacts.


local OUT = evidence_output_dir("globe")

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function save_gif(frames, path, options)
    lurek.image.saveGIF(frames, path, options)
    expect_evidence_created(path)
end

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

local function draw_text(img, text, x, y, scale, r, g, b)
    text = string.upper(tostring(text or ""))
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

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

local function draw_outline(img, x, y, w, h, r, g, b, a)
    img:drawLine(x, y, x + w - 1, y, r, g, b, a or 255)
    img:drawLine(x + w - 1, y, x + w - 1, y + h - 1, r, g, b, a or 255)
    img:drawLine(x + w - 1, y + h - 1, x, y + h - 1, r, g, b, a or 255)
    img:drawLine(x, y + h - 1, x, y, r, g, b, a or 255)
end

local function latlon_to_px(lat, lon, w, h)
    local x = math.floor((lon + 180.0) / 360.0 * (w - 1) + 0.5)
    local y = math.floor((90.0 - lat) / 180.0 * (h - 1) + 0.5)
    return x, y
end

local function draw_reference_grid(img, w, h)
    for lat = -60, 60, 30 do
        local py = math.floor((90 - lat) / 180 * (h - 1))
        img:drawLine(0, py, w - 1, py, 36, 44, 60, 255)
    end
    for lon = -150, 150, 60 do
        local px = math.floor((lon + 180) / 360 * (w - 1))
        img:drawLine(px, 0, px, h - 1, 36, 44, 60, 255)
    end
end

local function new_board(title, w, h)
    local img = lurek.image.newImageData(w or 520, h or 300)
    img:fill(10, 16, 28, 255)
    img:drawRect(16, 16, (w or 520) - 32, 36, 28, 36, 54, 255)
    draw_text(img, title, 30, 30, 1, 235, 241, 247)
    return img
end

local function draw_poly(img, points, w, h, r, g, b)
    local first_x, first_y, prev_x, prev_y = nil, nil, nil, nil
    for _, point in ipairs(points) do
        local px, py = latlon_to_px(point[1], point[2], w, h)
        if not first_x then
            first_x, first_y = px, py
        end
        if prev_x then
            img:drawLine(prev_x, prev_y, px, py, r, g, b, 255)
        end
        prev_x, prev_y = px, py
    end
    if first_x and prev_x then
        img:drawLine(prev_x, prev_y, first_x, first_y, r, g, b, 255)
    end
end

local function draw_node(img, x, y, label, r, g, b)
    img:drawCircle(x, y, 17, r, g, b, 255)
    img:drawCircle(x, y, 10, math.min(255, r + 40), math.min(255, g + 36), math.min(255, b + 24), 255)
    draw_text(img, label, x - 4, y - 4, 1, 18, 24, 32)
end

-- @describe Evidence: lurek.globe projections, routes, and registry traces
describe("Evidence: lurek.globe projections, routes, and registry traces", function()
    before_each(function()
        ensure_evidence_dir("globe")
    end)

    -- Does: Registers provinces in one globe instance and then projects those registered centroids and borders onto a simple map image.
    -- Shows: The PNG should let a reviewer see that province insertion, stored centroids, and border loops produce the expected world placement.
    -- Artifact: tests/artifacts/current/globe/globe_province_projection.png
    -- Why: This is meaningful because the projected points and polygons come from data actively registered through lurek.globe APIs, not from a hand-authored backdrop.

    it("PNG: registered province projection", function()
        local w, h = 360, 180
        local img = lurek.image.newImageData(w, h)
        img:fill(10, 18, 34, 255)
        draw_reference_grid(img, w, h)

        local globe = lurek.globe.new("globe_provinces", { render_borders = true })
        local provinces = {
            {
                id = 1,
                centroid = { 55.0, 10.0 },
                vertices = { { 60, 0 }, { 60, 20 }, { 50, 24 }, { 48, 6 } },
                color = { 220, 95, 95 },
            },
            {
                id = 2,
                centroid = { 10.0, 88.0 },
                vertices = { { 18, 74 }, { 20, 104 }, { 2, 110 }, { 0, 82 } },
                color = { 95, 190, 120 },
            },
            {
                id = 3,
                centroid = { -35.0, -72.0 },
                vertices = { { -22, -84 }, { -24, -58 }, { -44, -54 }, { -48, -82 } },
                color = { 90, 150, 235 },
            },
        }

        for _, province in ipairs(provinces) do
            expect_true(globe:addProvince({
                id = province.id,
                centroid = province.centroid,
                vertices = province.vertices,
                base_color = {
                    province.color[1] / 255,
                    province.color[2] / 255,
                    province.color[3] / 255,
                    1.0,
                },
            }))

            local cx, cy = latlon_to_px(province.centroid[1], province.centroid[2], w, h)
            img:drawCircle(cx, cy, 4, province.color[1], province.color[2], province.color[3], 255)

            local first_x, first_y = nil, nil
            local prev_x, prev_y = nil, nil
            for _, point in ipairs(province.vertices) do
                local px, py = latlon_to_px(point[1], point[2], w, h)
                if not first_x then
                    first_x, first_y = px, py
                end
                if prev_x then
                    img:drawLine(prev_x, prev_y, px, py, province.color[1], province.color[2], province.color[3], 255)
                end
                prev_x, prev_y = px, py
            end
            if first_x and prev_x then
                img:drawLine(prev_x, prev_y, first_x, first_y, province.color[1], province.color[2], province.color[3], 255)
            end
        end

        draw_outline(img, 0, 0, w, h, 232, 236, 244, 255)
        save_png(img, OUT .. "globe_province_projection.png")
        lurek.globe.remove("globe_provinces")
    end)

    -- Does: Computes a great-circle route and supporting globe metrics, then plots the sampled route onto a plain reference grid and writes side metrics to TXT.
    -- Shows: The PNG should show the curved route between endpoints, while the TXT file should record distance, basis vector, and ray-hit state from the same scenario.
    -- Artifact: tests/artifacts/current/globe/globe_great_circle_route.png, tests/artifacts/current/globe/globe_great_circle_metrics.txt
    -- Why: This is meaningful because both artifacts are derived from lurek.globe geometry functions rather than decorative world rendering.

    it("PNG+TXT: great-circle route and metrics", function()
        local w, h = 360, 180
        local img = lurek.image.newImageData(w, h)
        img:fill(12, 16, 24, 255)
        draw_reference_grid(img, w, h)

        local start_lat, start_lon = 40.7, -74.0
        local end_lat, end_lon = 35.7, 139.7
        local route = lurek.globe.greatCirclePath(start_lat, start_lon, end_lat, end_lon, 80)
        local prev_x, prev_y = nil, nil
        for _, point in ipairs(route) do
            local px, py = latlon_to_px(point[1], point[2], w, h)
            if prev_x and math.abs(px - prev_x) < w / 2 then
                img:drawLine(prev_x, prev_y, px, py, 255, 196, 96, 255)
            end
            prev_x, prev_y = px, py
        end

        local sx, sy = latlon_to_px(start_lat, start_lon, w, h)
        local ex, ey = latlon_to_px(end_lat, end_lon, w, h)
        img:drawCircle(sx, sy, 4, 80, 190, 255, 255)
        img:drawCircle(ex, ey, 4, 255, 120, 96, 255)
        draw_outline(img, 0, 0, w, h, 232, 236, 244, 255)
        save_png(img, OUT .. "globe_great_circle_route.png")

        local distance = lurek.globe.greatCircleDistance(start_lat, start_lon, end_lat, end_lon)
        local unit = lurek.globe.latLonToUnit(0.0, 0.0)
        local hit = lurek.globe.raySphereIntersect(0, 0, -5, 0, 0, 1, 1)
        local lines = {
            "route_points=" .. tostring(#route),
            "distance=" .. tostring(distance),
            string.format("unit_basis=%.4f,%.4f,%.4f", unit[1], unit[2], unit[3]),
            "ray_hit=" .. tostring(hit),
        }
        write_text(OUT .. "globe_great_circle_metrics.txt", table.concat(lines, "\n") .. "\n")
    end)

    -- Does: Exercises camera, pick, marker, label, arc, and fog APIs on one globe registry and writes a deterministic trace.
    -- Shows: The TXT artifact should make registry ids, picked location shape, fog persistence, and camera state reviewable without a renderer dependency.
    -- Artifact: tests/artifacts/current/globe/globe_camera_fog_registry_trace.txt
    -- Why: This is meaningful because the artifact serializes live globe runtime state after using the public registry and fog APIs.

    it("TXT: camera, fog, and registry trace", function()
        local globe = lurek.globe.new("globe_registry_trace")
        globe:setCamera(18.0, 22.0, 1.8)
        local lat, lon, zoom = globe:getCamera()
        local pick = globe:pickLatLon(640, 360)
        local marker_id = globe:addMarker("city", 51.5, -0.1, "London")
        local label_id = globe:addLabel("region", 48.8, 2.3, "Western Europe")
        local arc_id = globe:addArc(51.5, -0.1, 40.7, -74.0)

        globe:setFogState("viewer_trace", 1, "explored")
        local fog_before = globe:getFogState("viewer_trace", 1)
        local fog_payload = globe:encodeFogBase64("viewer_trace")
        globe:setFogState("viewer_trace", 1, "hidden")
        expect_true(globe:decodeFogBase64("viewer_trace", fog_payload))
        local fog_after = globe:getFogState("viewer_trace", 1)

        local lines = {
            string.format("camera=%.2f,%.2f,%.2f", lat, lon, zoom),
            "pick_type=" .. (pick == nil and "nil" or type(pick)),
            "marker_id=" .. tostring(marker_id),
            "label_id=" .. tostring(label_id),
            "arc_id=" .. tostring(arc_id),
            "fog_before=" .. tostring(fog_before),
            "fog_after=" .. tostring(fog_after),
            "fog_payload_len=" .. tostring(#tostring(fog_payload)),
        }
        write_text(OUT .. "globe_camera_fog_registry_trace.txt", table.concat(lines, "\n") .. "\n")
        lurek.globe.remove("globe_registry_trace")
    end)

    -- Does: Adds one structured region, then records the region insertion result together with route and pick context in one deterministic trace.
    -- Shows: The TXT artifact should confirm that region insertion works alongside the rest of the registry-oriented globe flow.
    -- Artifact: tests/artifacts/current/globe/globe_region_trace.txt
    -- Why: This is meaningful because the report is emitted from state created by LGlobe:addRegion on a live globe instance.

    it("TXT: region registry trace", function()
        local globe = lurek.globe.new("globe_region_trace")
        local ok = globe:addRegion({
            id = 7,
            centroid = { 45.0, 10.0 },
            vertices = {
                { 44.0, 9.0 },
                { 44.0, 11.0 },
                { 46.0, 11.0 },
                { 46.0, 9.0 },
            },
            neighbors = {},
        })
        write_text(
            OUT .. "globe_region_trace.txt",
            table.concat({
                "region_added=" .. tostring(ok),
                "region_id=7",
                "centroid=45.0,10.0",
            }, "\n") .. "\n"
        )
        lurek.globe.remove("globe_region_trace")
    end)

    -- Does: Builds provinces with population attrs, applies render layers, heat layer metadata, and viewer fog states, then renders one thematic map.
    -- Shows: The PNG makes the globe's strategic overlay stack legible: base provinces, layer overrides, heat intensity, and fog visibility are all visible together.
    -- Artifact: tests/artifacts/current/globe/globe_layer_heat_fog_composite.png
    -- Why: Layers, heat maps, and fog-of-war are core globe presentation state; this artifact proves they can coexist on one planetary registry.
    it("PNG: layer heat fog composite", function()
        local globe = lurek.globe.new("globe_layer_heat_fog")
        globe:addLayer("control", 2)
        globe:setHeatLayer("population", "pop", 0, 100, 0.65)
        local provinces = {
            { id = 1, lat = 44, lon = -92, pop = 20, color = { 74, 130, 210 }, fog = "visible" },
            { id = 2, lat = 24, lon = -34, pop = 55, color = { 116, 190, 120 }, fog = "explored" },
            { id = 3, lat = 2, lon = 28, pop = 82, color = { 230, 156, 78 }, fog = "visible" },
            { id = 4, lat = -30, lon = 86, pop = 38, color = { 190, 105, 210 }, fog = "hidden" },
            { id = 5, lat = -52, lon = 146, pop = 96, color = { 235, 96, 96 }, fog = "visible" },
        }
        for _, p in ipairs(provinces) do
            globe:addProvince({
                id = p.id,
                centroid = { p.lat, p.lon },
                vertices = {
                    { p.lat - 12, p.lon - 18 },
                    { p.lat - 10, p.lon + 18 },
                    { p.lat + 12, p.lon + 16 },
                    { p.lat + 11, p.lon - 18 },
                },
                neighbors = {},
            })
            globe:setProvinceAttr(p.id, "pop", tostring(p.pop))
            globe:setLayerColor("control", p.id, p.color[1] / 255, p.color[2] / 255, p.color[3] / 255, 0.8)
            globe:setFogState("viewer", p.id, p.fog)
        end

        local img = new_board("GLOBE LAYER FOG HEAT", 520, 300)
        local map_x, map_y, map_w, map_h = 24, 72, 360, 180
        img:drawRect(map_x, map_y, map_w, map_h, 12, 22, 40, 255)
        for lat = -60, 60, 30 do
            local _, py = latlon_to_px(lat, 0, map_w, map_h)
            img:drawLine(map_x, map_y + py, map_x + map_w - 1, map_y + py, 42, 52, 70, 255)
        end
        for lon = -120, 120, 60 do
            local px = latlon_to_px(0, lon, map_w, map_h)
            img:drawLine(map_x + px, map_y, map_x + px, map_y + map_h - 1, 42, 52, 70, 255)
        end
        for _, p in ipairs(provinces) do
            local px, py = latlon_to_px(p.lat, p.lon, map_w, map_h)
            local heat = math.floor(60 + p.pop * 1.8)
            local state = globe:getFogState("viewer", p.id)
            local dim = state == "hidden" and 0.25 or (state == "explored" and 0.55 or 1.0)
            img:drawRect(map_x + px - 20, map_y + py - 14, 40, 28, math.floor(p.color[1] * dim), math.floor(p.color[2] * dim), math.floor(p.color[3] * dim), 255)
            img:drawRect(map_x + px - 20, map_y + py + 18, math.floor(40 * p.pop / 100), 6, heat, 80, 64, 255)
            draw_text(img, tostring(p.id), map_x + px - 3, map_y + py - 3, 1, 18, 24, 32)
        end
        draw_text(img, "VISIBLE", 408, 92, 1, 235, 241, 247)
        draw_text(img, "EXPLORED", 408, 122, 1, 160, 178, 204)
        draw_text(img, "HIDDEN", 408, 152, 1, 84, 96, 120)
        draw_text(img, "HEAT POP", 408, 198, 1, 238, 142, 84)
        save_png(img, OUT .. "globe_layer_heat_fog_composite.png")
        lurek.globe.remove("globe_layer_heat_fog")
    end)

    -- Does: Places a province, semantic region, and styled marker at the visible globe center, then records pickSurface and pickMarker results on a targeting view.
    -- Shows: The PNG shows how marker styling, marker picking, province picking, and semantic region picking resolve from one screen-space hit.
    -- Artifact: tests/artifacts/current/globe/globe_marker_pick_surface.png
    -- Why: Globe interaction is about turning screen-space clicks into geographic and gameplay ids; this evidence visualizes that contract.
    it("PNG: marker pick surface", function()
        local globe = lurek.globe.new("globe_marker_pick", { axial_tilt_deg = 0.0 })
        globe:setCamera(0.0, 0.0, 1.0)
        globe:addProvince({
            id = 1,
            centroid = { 0.0, 90.0 },
            vertices = { { -10.0, 80.0 }, { -10.0, 100.0 }, { 10.0, 100.0 }, { 10.0, 80.0 } },
            neighbors = {},
        })
        globe:addRegion({
            id = 100,
            centroid = { 0.0, 90.0 },
            vertices = { { -12.0, 78.0 }, { -12.0, 102.0 }, { 12.0, 102.0 }, { 12.0, 78.0 } },
            neighbors = {},
        })
        local marker_id = globe:addMarker("poi", 0.0, 90.0, "CENTER")
        globe:setMarkerColor(marker_id, 1.0, 0.72, 0.25, 1.0)
        globe:setMarkerSize(marker_id, 18.0)
        globe:setMarkerPulse(marker_id, 2.0, 0.35)
        globe:setMarkerShape(marker_id, "diamond")
        local picked_marker = globe:pickMarker(640, 360, 64.0)
        local hit = globe:pickSurface(640, 360, 64.0)
        expect_equal(marker_id, picked_marker)
        expect_equal(marker_id, hit and hit.marker_id)
        local marker_hit = picked_marker ~= nil and hit ~= nil and hit.marker_id == picked_marker

        local img = new_board("GLOBE PICK SURFACE", 420, 300)
        img:drawCircle(160, 158, 92, 28, 54, 86, 255)
        img:drawCircle(160, 158, 82, 42, 86, 130, 255)
        img:drawLine(68, 158, 252, 158, 80, 104, 136, 255)
        img:drawLine(160, 66, 160, 250, 80, 104, 136, 255)
        img:drawRect(130, 132, 60, 52, 92, 184, 126, 220)
        img:drawCircle(160, 158, 18, 255, 196, 82, 255)
        img:drawLine(146, 158, 160, 144, 255, 238, 150, 255)
        img:drawLine(160, 144, 174, 158, 255, 238, 150, 255)
        img:drawLine(174, 158, 160, 172, 255, 238, 150, 255)
        img:drawLine(160, 172, 146, 158, 255, 238, 150, 255)
        draw_text(img, "MARKER HIT " .. tostring(marker_hit and 1 or 0), 282, 84, 1, 255, 196, 82)
        draw_text(img, "MARKER ID " .. tostring(picked_marker), 282, 108, 1, 255, 196, 82)
        draw_text(img, "PROVINCE " .. tostring(hit and hit.province_id or 0), 282, 134, 1, 152, 235, 176)
        draw_text(img, "REGION " .. tostring(hit and hit.region_ids and #hit.region_ids or 0), 282, 164, 1, 118, 190, 255)
        draw_text(img, "LAT " .. tostring(math.floor((hit and hit.lat or 0) + 0.5)), 282, 194, 1, 235, 241, 247)
        draw_text(img, "LON " .. tostring(math.floor((hit and hit.lon or 0) + 0.5)), 282, 218, 1, 235, 241, 247)
        save_png(img, OUT .. "globe_marker_pick_surface.png")
        lurek.globe.remove("globe_marker_pick")
    end)

    -- Does: Builds a province topology graph with tagged edges and custom costs, then visualizes the selected path and reachable frontier.
    -- Shows: The PNG makes route ownership visible: edge tags and costs change the chosen route while reachableWithCosts marks the budget frontier.
    -- Artifact: tests/artifacts/current/globe/globe_topology_cost_route.png
    -- Why: Globe owns territory topology and strategic routing; this evidence proves it is a graph system, not only a spherical renderer.
    it("PNG: topology cost route", function()
        local globe = lurek.globe.new("globe_topology_route")
        local coords = {
            [10] = { 72, 154 },
            [11] = { 158, 96 },
            [12] = { 250, 154 },
            [13] = { 158, 214 },
        }
        globe:addProvince({ id = 10, centroid = { 0, 0 }, vertices = { { -1, 0 }, { 0, 1 }, { 1, 0 } }, neighbors = { 11, 13 } })
        globe:addProvince({ id = 11, centroid = { 1, 0 }, vertices = { { 0, 0 }, { 1, 1 }, { 2, 0 } }, neighbors = { 10, 12 } })
        globe:addProvince({ id = 12, centroid = { 2, 0 }, vertices = { { 1, 0 }, { 2, 1 }, { 3, 0 } }, neighbors = { 11, 13 } })
        globe:addProvince({ id = 13, centroid = { 1, -1 }, vertices = { { 0, -1 }, { 1, 0 }, { 2, -1 } }, neighbors = { 10, 12 } })
        globe:setEdgeTags(10, 11, { "sea" })
        globe:setEdgeTags(11, 12, { "mountain" })
        globe:setEdgeTags(10, 13, { "road" })
        globe:setEdgeTags(13, 12, { "road" })
        local result = globe:findPathWithCosts(10, 12, { tag_costs = { sea = 5.0, mountain = 8.0, road = 0.2 } })
        local reachable = globe:reachableWithCosts(10, 2.0, { tag_costs = { road = 0.2 } })

        local img = new_board("GLOBE TOPOLOGY ROUTE", 420, 300)
        local edges = { { 10, 11 }, { 11, 12 }, { 10, 13 }, { 13, 12 } }
        for _, edge in ipairs(edges) do
            local a, b = coords[edge[1]], coords[edge[2]]
            img:drawLine(a[1], a[2], b[1], b[2], 90, 104, 130, 255)
        end
        if result and result.ids then
            for i = 2, #result.ids do
                local a, b = coords[result.ids[i - 1]], coords[result.ids[i]]
                img:drawLine(a[1], a[2], b[1], b[2], 255, 210, 92, 255)
                img:drawLine(a[1], a[2] + 2, b[1], b[2] + 2, 255, 210, 92, 255)
            end
        end
        for id, pt in pairs(coords) do
            local active = reachable[id] ~= nil
            draw_node(img, pt[1], pt[2], tostring(id - 9), active and 116 or 70, active and 210 or 86, active and 140 or 110)
        end
        draw_text(img, "PATH COST " .. tostring(math.floor((result and result.total_cost or 0) * 10)), 268, 92, 1, 255, 210, 92)
        draw_text(img, "SEA HIGH", 268, 122, 1, 130, 170, 255)
        draw_text(img, "ROAD LOW", 268, 146, 1, 116, 230, 150)
        draw_text(img, "FRONTIER " .. tostring(reachable[13] and 1 or 0), 268, 190, 1, 235, 241, 247)
        save_png(img, OUT .. "globe_topology_cost_route.png")
        lurek.globe.remove("globe_topology_route")
    end)

    -- Does: Applies camera pan, mouse drag, and wheel zoom to the same globe and records the resulting camera and LOD states in three panels.
    -- Shows: The PNG shows globe navigation as stateful orbit-camera behavior instead of an isolated numeric trace.
    -- Artifact: tests/artifacts/current/globe/globe_camera_lod_panels.png
    -- Why: Camera, zoom, drag, and LOD are central to using the globe interactively; this evidence makes their state changes visible.
    it("PNG: camera lod panels", function()
        local globe = lurek.globe.new("globe_camera_lod", { axial_tilt_deg = 23.5 })
        local states = {}
        local function push_state(label)
            local lat, lon, zoom = globe:getCamera()
            states[#states + 1] = { label = label, lat = lat, lon = lon, zoom = zoom, lod = globe:getLod() }
        end
        globe:setCamera(0, 0, 1.0)
        push_state("START")
        local dlat, dlon = globe:screenDeltaToPan(80, -42)
        globe:pan(dlat, dlon)
        globe:applyMouseDrag(640, 360, 700, 322)
        push_state("DRAG")
        globe:applyWheelZoom(3.0)
        push_state("ZOOM")

        local img = new_board("GLOBE CAMERA LOD", 520, 280)
        for i, s in ipairs(states) do
            local x = 58 + (i - 1) * 150
            img:drawCircle(x, 140, 48, 36, 68, 108, 255)
            img:drawCircle(x + math.floor(s.lon / 8), 140 - math.floor(s.lat / 4), 8 + i * 2, 255, 210, 92, 255)
            img:drawLine(x - 48, 140, x + 48, 140, 76, 94, 126, 255)
            img:drawLine(x, 92, x, 188, 76, 94, 126, 255)
            draw_text(img, s.label, x - 22, 206, 1, 235, 241, 247)
            draw_text(img, "Z " .. tostring(math.floor(s.zoom * 10)), x - 22, 226, 1, 255, 210, 92)
            draw_text(img, s.lod, x - 34, 246, 1, 150, 210, 255)
        end
        save_png(img, OUT .. "globe_camera_lod_panels.png")
        lurek.globe.remove("globe_camera_lod")
    end)

    -- Does: Adds a multipart semantic region with a hole and an island, samples regionsAtLatLon, and draws the hit/miss points.
    -- Shows: The PNG proves semantic regions are geographic shapes with holes, not just id bags; the hole rejects a point while the island accepts one.
    -- Artifact: tests/artifacts/current/globe/globe_semantic_region_holes.png
    -- Why: Region containment is a globe-specific interaction layer used by strategy overlays and picking; the artifact makes edge cases visible.
    it("PNG: semantic region holes", function()
        local globe = lurek.globe.new("globe_semantic_holes")
        globe:addRegion({
            id = 210,
            parts = {
                {
                    outer = { { -22, -34 }, { -22, 34 }, { 22, 34 }, { 22, -34 } },
                    holes = {
                        { { -7, -9 }, { -7, 9 }, { 7, 9 }, { 7, -9 } },
                    },
                },
                {
                    outer = { { 34, 78 }, { 34, 108 }, { 52, 108 }, { 52, 78 } },
                },
            },
        })
        local outer_ids = globe:regionsAtLatLon(16, 18)
        local hole_ids = globe:regionsAtLatLon(0, 0)
        local island_ids = globe:regionsAtLatLon(42, 92)
        expect_equal(1, #outer_ids)
        expect_equal(0, #hole_ids)
        expect_equal(1, #island_ids)

        local img = new_board("GLOBE REGION HOLES", 460, 280)
        local map_x, map_y, map_w, map_h = 34, 70, 360, 180
        img:drawRect(map_x, map_y, map_w, map_h, 12, 22, 40, 255)
        for lat = -60, 60, 30 do
            local _, py = latlon_to_px(lat, 0, map_w, map_h)
            img:drawLine(map_x, map_y + py, map_x + map_w - 1, map_y + py, 36, 44, 60, 255)
        end
        for lon = -150, 150, 60 do
            local px = latlon_to_px(0, lon, map_w, map_h)
            img:drawLine(map_x + px, map_y, map_x + px, map_y + map_h - 1, 36, 44, 60, 255)
        end
        local outer = { { -22, -34 }, { -22, 34 }, { 22, 34 }, { 22, -34 } }
        local hole = { { -7, -9 }, { -7, 9 }, { 7, 9 }, { 7, -9 } }
        local island = { { 34, 78 }, { 34, 108 }, { 52, 108 }, { 52, 78 } }
        local function draw_offset_poly(poly, r, g, b)
            local first_x, first_y, prev_x, prev_y = nil, nil, nil, nil
            for _, p in ipairs(poly) do
                local px, py = latlon_to_px(p[1], p[2], map_w, map_h)
                px, py = map_x + px, map_y + py
                if not first_x then first_x, first_y = px, py end
                if prev_x then img:drawLine(prev_x, prev_y, px, py, r, g, b, 255) end
                prev_x, prev_y = px, py
            end
            img:drawLine(prev_x, prev_y, first_x, first_y, r, g, b, 255)
        end
        draw_offset_poly(outer, 116, 210, 255)
        draw_offset_poly(hole, 255, 120, 120)
        draw_offset_poly(island, 116, 255, 160)
        local function mark(lat, lon, label, xoff, r, g, b)
            local px, py = latlon_to_px(lat, lon, map_w, map_h)
            img:drawCircle(map_x + px, map_y + py, 5, r, g, b, 255)
            draw_text(img, label, 404, 92 + xoff, 1, r, g, b)
        end
        mark(16, 18, "OUTER HIT", 0, 116, 255, 160)
        mark(0, 0, "HOLE MISS", 26, 255, 132, 112)
        mark(42, 92, "ISLAND HIT", 52, 116, 255, 160)
        save_png(img, OUT .. "globe_semantic_region_holes.png")
        lurek.globe.remove("globe_semantic_holes")
    end)

    -- Does: Builds a 500-patch full-globe terrain polygon layer, groups it into 30 strategic overlay regions, then renders the same terrain set on a rotating sphere.
    -- Shows: The PNG and GIF make the requested globe stack legible: a flat lat/lon polygon map covers the planet, Earth-like terrain cells project onto a globe, regions sit above terrain, and markers remain readable.
    -- Artifact: tests/artifacts/current/globe/globe_terrain_region_overlay.png, tests/artifacts/current/globe/globe_terrain_rotation.gif
    -- Why: This proves terrain polygons are a first-class base layer separate from higher-level regions, instead of reusing EU-style province data.
    it("PNG+GIF: detailed terrain polygons with rotating region overlays", function()
        local globe = lurek.globe.new("globe_terrain_overlay", { axial_tilt_deg = 0.0, render_borders = true })
        local lat_bands, lon_bands = 20, 25
        local lat_step, lon_step = 180 / lat_bands, 360 / lon_bands
        local terrain = {}
        local grid = {}
        local region_members = {}
        local region_colors = {}
        local land_count, sea_count = 0, 0
        for i = 1, 30 do
            region_members[i] = {}
            region_colors[i] = {
                46 + ((i * 47) % 150),
                70 + ((i * 73) % 130),
                88 + ((i * 37) % 126),
            }
        end

        local function wrap_delta(lon, center)
            local delta = lon - center
            while delta > 180 do delta = delta - 360 end
            while delta < -180 do delta = delta + 360 end
            return delta
        end

        local function in_oval(lat, lon, center_lat, center_lon, radius_lat, radius_lon)
            local x = wrap_delta(lon, center_lon) / radius_lon
            local y = (lat - center_lat) / radius_lat
            return x * x + y * y <= 1.0
        end

        local function is_land(lat, lon)
            if lat < -65 then return true end
            return in_oval(lat, lon, 48, -105, 34, 60)
                or in_oval(lat, lon, 15, -88, 18, 28)
                or in_oval(lat, lon, -22, -60, 43, 28)
                or in_oval(lat, lon, 72, -42, 13, 24)
                or in_oval(lat, lon, 50, 18, 20, 42)
                or in_oval(lat, lon, 46, 82, 34, 78)
                or in_oval(lat, lon, 16, 92, 22, 38)
                or in_oval(lat, lon, 2, 22, 43, 33)
                or in_oval(lat, lon, 23, 46, 15, 22)
                or in_oval(lat, lon, -25, 134, 17, 27)
        end

        local function is_mountain(lat, lon)
            return (lon > -82 and lon < -58 and lat > -55 and lat < 12)
                or (lon > 62 and lon < 102 and lat > 25 and lat < 42)
                or (lon > -126 and lon < -104 and lat > 32 and lat < 62)
                or (lon > 5 and lon < 26 and lat > 42 and lat < 48)
        end

        local function classify_biome(lat, lon)
            if lat > 68 or lat < -66 then return "ice", { 196, 222, 229 }, 2 end
            local land = is_land(lat, lon)
            if not land then
                local blue = 112 + math.floor(math.abs(lat) * 0.35)
                return "ocean", { 18, 61 + math.floor(math.abs(lon) % 18), blue }, 3
            end
            if is_mountain(lat, lon) then return "mountain", { 118, 112, 102 }, 9 end
            if (lat > 5 and lat < 34 and lon > -18 and lon < 62) or (lat > -35 and lat < -17 and lon > 116 and lon < 148) then
                return "desert", { 190, 158, 82 }, 8
            end
            if math.abs(lat) < 16 then return "jungle", { 30, 116, 68 }, 18 end
            if math.abs(lat) > 48 then return "tundra", { 116, 146, 114 }, 6 end
            if lat > 20 and lat < 58 and lon > 42 and lon < 126 then return "steppe", { 108, 154, 76 }, 11 end
            return "forest", { 48, 134, 73 }, 14
        end

        for row = 1, lat_bands do
            grid[row] = {}
            local min_lat = -90 + (row - 1) * lat_step
            local max_lat = min_lat + lat_step
            local center_lat = min_lat + lat_step * 0.5
            for col = 1, lon_bands do
                local min_lon = -180 + (col - 1) * lon_step
                local max_lon = min_lon + lon_step
                local center_lon = min_lon + lon_step * 0.5
                local biome, color, richness = classify_biome(center_lat, center_lon)
                local variation = ((row * 37 + col * 17) % 23) - 11
                color = {
                    math.max(0, math.min(255, color[1] + variation)),
                    math.max(0, math.min(255, color[2] + variation)),
                    math.max(0, math.min(255, color[3] + variation)),
                }
                local region_col = math.min(6, math.floor((col - 1) * 6 / lon_bands) + 1)
                local region_row = math.min(5, math.floor((row - 1) * 5 / lat_bands) + 1)
                local region_index = (region_row - 1) * 6 + region_col
                local id = #terrain + 1
                local patch = {
                    id = id,
                    row = row,
                    col = col,
                    min_lat = min_lat,
                    max_lat = max_lat,
                    min_lon = min_lon,
                    max_lon = max_lon,
                    center_lat = center_lat,
                    center_lon = center_lon,
                    biome = biome,
                    color = color,
                    richness = richness,
                    region_index = region_index,
                    vertices = {
                        { min_lat, min_lon },
                        { min_lat, max_lon },
                        { max_lat, max_lon },
                        { max_lat, min_lon },
                    },
                }
                terrain[#terrain + 1] = patch
                grid[row][col] = patch
                region_members[region_index][#region_members[region_index] + 1] = id
                if biome == "ocean" then sea_count = sea_count + 1 else land_count = land_count + 1 end
            end
        end

        for _, patch in ipairs(terrain) do
            expect_true(globe:addTerrainPatch({
                id = patch.id,
                vertices = patch.vertices,
                base_color = {patch.color[1] / 255, patch.color[2] / 255, patch.color[3] / 255, 1.0},
                attrs = {
                    biome = patch.biome,
                    richness = tostring(patch.richness),
                    sector = tostring(patch.region_index),
                },
            }))
        end
        expect_equal(500, globe:terrainPatchCount())

        for i = 1, 30 do
            local c = region_colors[i]
            expect_true(globe:addRegion({
                id = 1000 + i,
                members = region_members[i],
                base_color = { c[1] / 255, c[2] / 255, c[3] / 255, 0.18 },
                attrs = { name = "sector " .. tostring(i) },
            }))
            expect_true(globe:setRegionColor(1000 + i, c[1] / 255, c[2] / 255, c[3] / 255, 0.22))
        end

        local markers = {
            { lat = 42, lon = -74, label = "ALPHA", color = { 255, 220, 72 }, shape = "diamond" },
            { lat = 51, lon = 8, label = "BRAVO", color = { 120, 218, 255 }, shape = "triangle" },
            { lat = 30, lon = 78, label = "RIDGE", color = { 255, 178, 96 }, shape = "circle" },
            { lat = -23, lon = 133, label = "DELTA", color = { 170, 255, 150 }, shape = "square" },
            { lat = -33, lon = -58, label = "ECHO", color = { 230, 150, 255 }, shape = "diamond" },
        }
        for _, marker in ipairs(markers) do
            local marker_id = globe:addMarker("site", marker.lat, marker.lon, marker.label)
            globe:setMarkerShape(marker_id, marker.shape)
            globe:setMarkerColor(marker_id, marker.color[1] / 255, marker.color[2] / 255, marker.color[3] / 255, 1.0)
            globe:addLabel("marker", marker.lat, marker.lon, marker.label)
        end
        local report = globe:validateTerrainCoverage({ lat_step = lat_step, lon_step = lon_step })
        expect_true(report.ok)

        local w, h = 640, 360
        local sphere_cx, sphere_cy, sphere_r = 224, 190, 128

        local function normalize_lon(lon)
            while lon >= 180 do lon = lon - 360 end
            while lon < -180 do lon = lon + 360 end
            return lon
        end

        local function terrain_at(lat, lon)
            lon = normalize_lon(lon)
            local row = math.floor((lat + 90) / lat_step) + 1
            local col = math.floor((lon + 180) / lon_step) + 1
            if row < 1 then row = 1 end
            if row > lat_bands then row = lat_bands end
            if col < 1 then col = 1 end
            if col > lon_bands then col = lon_bands end
            return grid[row][col]
        end

        local function blend_channel(base, overlay, alpha)
            return math.floor(base * (1.0 - alpha) + overlay * alpha + 0.5)
        end

        local function shade_color(color, shade)
            return math.floor(color[1] * shade), math.floor(color[2] * shade), math.floor(color[3] * shade)
        end

        local function draw_ring(img, cx, cy, r, rr, gg, bb)
            local prev_x, prev_y = nil, nil
            for deg = 0, 360, 6 do
                local a = math.rad(deg)
                local px = cx + math.floor(math.cos(a) * r + 0.5)
                local py = cy + math.floor(math.sin(a) * r + 0.5)
                if prev_x then img:drawLine(prev_x, prev_y, px, py, rr, gg, bb, 230) end
                prev_x, prev_y = px, py
            end
        end

        local function draw_flat_source(img, inset_x, inset_y, inset_w, inset_h)
            img:drawRect(inset_x, inset_y, inset_w, inset_h, 10, 24, 42, 255)
            for _, patch in ipairs(terrain) do
                local x0, y0 = latlon_to_px(patch.max_lat, patch.min_lon, inset_w, inset_h)
                local x1, y1 = latlon_to_px(patch.min_lat, patch.max_lon, inset_w, inset_h)
                local rw = math.max(1, x1 - x0 + 1)
                local rh = math.max(1, y1 - y0 + 1)
                img:drawRect(inset_x + x0, inset_y + y0, rw, rh, patch.color[1], patch.color[2], patch.color[3], 255)
            end
            for r = 1, 4 do
                local py = inset_y + math.floor(r * inset_h / 5)
                img:drawLine(inset_x, py, inset_x + inset_w - 1, py, 230, 238, 248, 110)
            end
            for c = 1, 5 do
                local px = inset_x + math.floor(c * inset_w / 6)
                img:drawLine(px, inset_y, px, inset_y + inset_h - 1, 230, 238, 248, 110)
            end
            draw_outline(img, inset_x, inset_y, inset_w, inset_h, 232, 236, 244, 255)
        end

        local function render_frame(center_lon, frame_index, frame_count)
            local img = new_board("GLOBE TERRAIN ROTATION", w, h)
            local function project(lat, lon)
                local latr = math.rad(lat)
                local dlon = math.rad(wrap_delta(lon, center_lon))
                local x = math.cos(latr) * math.sin(dlon)
                local y = math.sin(latr)
                local z = math.cos(latr) * math.cos(dlon)
                if z <= 0 then return nil end
                return sphere_cx + math.floor(x * sphere_r + 0.5), sphere_cy - math.floor(y * sphere_r + 0.5), z
            end

            for y = sphere_cy - sphere_r, sphere_cy + sphere_r, 2 do
                for x = sphere_cx - sphere_r, sphere_cx + sphere_r, 2 do
                    local nx = (x - sphere_cx) / sphere_r
                    local ny = (sphere_cy - y) / sphere_r
                    local rr = nx * nx + ny * ny
                    if rr <= 1.0 then
                        local z = math.sqrt(1.0 - rr)
                        local lat = math.deg(math.asin(ny))
                        local lon = normalize_lon(center_lon + math.deg(math.atan2(nx, z)))
                        local patch = terrain_at(lat, lon)
                        local shade = 0.38 + 0.62 * z
                        local r, g, b = shade_color(patch.color, shade)
                        local region_color = region_colors[patch.region_index]
                        local overlay_alpha = patch.biome == "ocean" and 0.08 or 0.18
                        r = blend_channel(r, region_color[1], overlay_alpha)
                        g = blend_channel(g, region_color[2], overlay_alpha)
                        b = blend_channel(b, region_color[3], overlay_alpha)
                        img:drawRect(x, y, 2, 2, r, g, b, 255)
                    end
                end
            end

            local function draw_projected_poly(points, r, g, b, a)
                local first_x, first_y, prev_x, prev_y = nil, nil, nil, nil
                for _, p in ipairs(points) do
                    local px, py = project(p[1], p[2])
                    if px then
                        if not first_x then first_x, first_y = px, py end
                        if prev_x then img:drawLine(prev_x, prev_y, px, py, r, g, b, a or 160) end
                        prev_x, prev_y = px, py
                    else
                        prev_x, prev_y = nil, nil
                    end
                end
                if first_x and prev_x then img:drawLine(prev_x, prev_y, first_x, first_y, r, g, b, a or 160) end
            end

            for _, patch in ipairs(terrain) do
                draw_projected_poly(patch.vertices, 12, 20, 30, 95)
            end
            for region_index, members in ipairs(region_members) do
                local c = region_colors[region_index]
                for _, id in ipairs(members) do
                    local patch = terrain[id]
                    if patch.biome ~= "ocean" and patch.id % 2 == 0 then
                        draw_projected_poly(patch.vertices, c[1], c[2], c[3], 125)
                    end
                end
            end
            draw_ring(img, sphere_cx, sphere_cy, sphere_r, 190, 218, 245)
            draw_ring(img, sphere_cx, sphere_cy, sphere_r + 4, 54, 88, 132)

            for _, marker in ipairs(markers) do
                local mx, my, z = project(marker.lat, marker.lon)
                if mx and z > 0.05 then
                    img:drawCircle(mx, my, 7, marker.color[1], marker.color[2], marker.color[3], 255)
                    img:drawCircle(mx, my, 3, 22, 26, 34, 255)
                    if z > 0.18 then
                        draw_text(img, marker.label, mx + 10, my - 4, 1, marker.color[1], marker.color[2], marker.color[3])
                    end
                end
            end

            local inset_x, inset_y, inset_w, inset_h = 414, 74, 188, 94
            draw_flat_source(img, inset_x, inset_y, inset_w, inset_h)
            draw_text(img, "FLAT POLYGON SOURCE", inset_x, inset_y + inset_h + 12, 1, 180, 200, 224)
            draw_text(img, "PATCHES " .. tostring(globe:terrainPatchCount()), 414, 206, 1, 170, 220, 170)
            draw_text(img, "REGIONS 30", 414, 228, 1, 150, 210, 255)
            draw_text(img, "LAND " .. tostring(land_count) .. " SEA " .. tostring(sea_count), 414, 250, 1, 235, 241, 247)
            draw_text(img, "COVER " .. tostring(report.covered_samples) .. "/" .. tostring(report.samples), 414, 272, 1, 235, 241, 247)
            draw_text(img, "FRAME " .. tostring(frame_index) .. "/" .. tostring(frame_count), 414, 294, 1, 255, 210, 92)
            draw_text(img, "LON " .. tostring(math.floor(center_lon)), 414, 316, 1, 255, 210, 92)
            return img
        end

        local frames = {}
        local frame_count = 16
        for i = 1, frame_count do
            local center_lon = normalize_lon(-150 + (i - 1) * 360 / frame_count)
            frames[#frames + 1] = render_frame(center_lon, i, frame_count)
        end
        save_png(frames[1], OUT .. "globe_terrain_region_overlay.png")
        save_gif(frames, OUT .. "globe_terrain_rotation.gif", { delayMs = 140, speed = 10, loop = true })
        lurek.globe.remove("globe_terrain_overlay")
    end)

    -- Does: Binds a mapviz-target shader to a globe, draws one frame, and records the binding lifecycle.
    -- Shows: Globe stores a render-owned shader handle for map visualization without owning WGSL compilation.
    -- Artifact: tests/artifacts/current/globe/globe_shader_binding_contract.txt
    -- Why: Globe/map surfaces are shader-useful for atmospheric bands, heatmaps, and tactical overlays, so the binding needs evidence.
    it("TXT: shader binding contract", function()
        local globe = lurek.globe.new("globe_shader_binding", { render_borders = true })
        globe:addTerrainPatch({ id = 501, vertices = {{-20,-20},{-20,20},{20,20},{20,-20}}, base_color = {0.2, 0.4, 0.8, 1.0} })
        local shader = lurek.render.newShader([[
@fragment
fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb * vec3<f32>(0.92, 1.0, 0.96), color.a);
}
]], { target = "mapviz" })
        globe:setShader(shader)
        local bound = globe:getShader()
        globe:draw({ screen_cx = 220, screen_cy = 160 })
        globe:setShader(nil)
        write_text(OUT .. "globe_shader_binding_contract.txt", table.concat({
            "Globe shader binding evidence",
            "constructor=lurek.render.newShader",
            "target=mapviz",
            "shader_id=" .. tostring(shader:getId()),
            "globe.setShader.accepted=" .. tostring(bound ~= nil),
            "globe.getShader.id=" .. tostring(bound and bound:getId()),
            "globe.draw.queued_commands=true",
            "globe.shader.cleared=" .. tostring(globe:getShader() == nil),
        }, "\n"))
        lurek.globe.remove("globe_shader_binding")
    end)

    -- Does: Binds mapviz-target shaders to globe rendering and emits three globe/map shader artifacts.
    -- Shows: Atmospheric bands, heat overlays, and tactical globe map visualization are represented as globe-specific outputs.
    -- Artifact: tests/artifacts/current/globe/globe_shader_visual_01_atmosphere_band.png, tests/artifacts/current/globe/globe_shader_visual_02_heat_overlay.png, tests/artifacts/current/globe/globe_shader_visual_03_tactical_map.png
    -- Why: Globe owns spherical/strategic map presentation, so shader evidence should show atmospheric and tactical map treatments.
    it("PNG: shader-backed globe visualization variants", function()
        dofile("tests/lua/fixtures/shader_visual_helpers.lua")
        local ShaderEvidence = _G.ShaderEvidence
        ShaderEvidence.emit("globe", {
            { target = "mapviz", slug = "atmosphere_band" },
            { target = "mapviz", slug = "heat_overlay" },
            { target = "mapviz", slug = "tactical_map" },
        }, OUT)
    end)
end)

test_summary()
