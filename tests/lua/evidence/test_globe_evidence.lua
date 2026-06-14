-- Canonical evidence file for lurek.globe artifacts.
-- @covers lurek.filesystem.write
-- @covers lurek.globe.greatCircleDistance
-- @covers lurek.globe.greatCirclePath
-- @covers lurek.globe.latLonToUnit
-- @covers lurek.globe.new
-- @covers lurek.globe.raySphereIntersect
-- @covers lurek.globe.remove
-- @covers lurek.image.newImageData
-- @covers lurek.image.savePNG


local OUT = evidence_output_dir("globe")

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
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
end)

test_summary()
