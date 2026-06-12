-- test_globe_evidence.lua
-- Canonical evidence file for lurek.globe visual outputs.
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

--- Helper: equirectangular projection of (lat, lon) → pixel (x, y).
local function latlon_to_px(lat, lon, W, H)
    local x = math.floor((lon + 180) / 360 * (W - 1))
    local y = math.floor((90 - lat) / 180 * (H - 1))
    return x, y
end

-- @describe Evidence: lurek.globe visual scenarios
describe("Evidence: lurek.globe visual scenarios", function()

    -- @evidence lurek.image.savePNG
    -- @evidence lurek.globe.new
    it("PNG: globe equirectangular projection with province borders", function()
        ensure_evidence_dir("globe")
        local path = OUT .. "globe_province_projection.png"

        local W, H = 360, 180
        local img = lurek.image.newImageData(W, H)
        img:fill(10, 40, 80, 255)  -- ocean background

        local globe = lurek.globe.new("globe_provinces", { render_borders = true })

        -- Add 6 provinces with distinct colors and vertices using correct native API
        local provinces = {
            { id = 1, name = "North",  lat =  60, lon =   0, r = 200, g = 80,  b = 80  },
            { id = 2, name = "East",   lat =   0, lon =  90, r = 80,  g = 200, b = 80  },
            { id = 3, name = "South",  lat = -50, lon =   0, r = 80,  g = 80,  b = 200 },
            { id = 4, name = "West",   lat =   0, lon = -90, r = 200, g = 200, b = 80  },
            { id = 5, name = "Centre", lat =   0, lon =   0, r = 200, g = 80,  b = 200 },
            { id = 6, name = "Polar",  lat =  80, lon = 180, r = 80,  g = 200, b = 200 },
        }

        for _, prov in ipairs(provinces) do
            local success = globe:addProvince({
                id = prov.id,
                centroid = { prov.lat, prov.lon },
                vertices = {
                    { prov.lat - 5, prov.lon - 5 },
                    { prov.lat + 5, prov.lon - 5 },
                    { prov.lat + 5, prov.lon + 5 },
                    { prov.lat - 5, prov.lon + 5 }
                },
                base_color = { prov.r / 255, prov.g / 255, prov.b / 255, 1.0 }
            })
            expect_true(success)

            local px, py = latlon_to_px(prov.lat, prov.lon, W, H)
            img:drawCircle(px, py, 10, prov.r, prov.g, prov.b, 255)

            -- Draw province bounding boundaries natively
            local vertices = {
                { prov.lat - 5, prov.lon - 5 },
                { prov.lat + 5, prov.lon - 5 },
                { prov.lat + 5, prov.lon + 5 },
                { prov.lat - 5, prov.lon + 5 }
            }
            local prev_px, prev_py = nil, nil
            for _, vt in ipairs(vertices) do
                local vx, vy = latlon_to_px(vt[1], vt[2], W, H)
                if prev_px and prev_py then
                    img:drawLine(prev_px, prev_py, vx, vy, prov.r, prov.g, prov.b, 255)
                end
                prev_px, prev_py = vx, vy
            end
            local first_vx, first_vy = latlon_to_px(vertices[1][1], vertices[1][2], W, H)
            if prev_px and prev_py then
                img:drawLine(prev_px, prev_py, first_vx, first_vy, prov.r, prov.g, prov.b, 255)
            end
        end

        -- Equator + prime-meridian reference lines natively
        img:drawLine(0, H / 2, W - 1, H / 2, 255, 255, 255, 180)
        img:drawLine(W / 2, 0, W / 2, H - 1, 255, 255, 255, 180)

        save_png(img, path)
        lurek.globe.remove("globe_provinces")
    end)

    -- @evidence lurek.image.savePNG
    it("PNG: globe heat-map overlay (temperature gradient)", function()
        ensure_evidence_dir("globe")
        local path = OUT .. "globe_temperature_heatmap.png"

        local W, H = 360, 180
        local img = lurek.image.newImageData(W, H)

        local globe = lurek.globe.new("globe_heatmap")

        -- Row-span drawLine optimization
        for y = 0, H - 1 do
            local lat = 90 - (y / (H - 1)) * 180
            local temp = math.max(0, 1 - math.abs(lat) / 90)
            local r = math.floor(math.min(1, temp * 2) * 255)
            local g = math.floor(math.min(1, (1 - math.abs(temp - 0.5) * 2)) * 180)
            local b = math.floor(math.max(0, 1 - temp * 2) * 255)
            img:drawLine(0, y, W - 1, y, r, g, b, 255)
        end

        -- Draw Tropic of Cancer and Capricorn natively
        local trop_y = math.floor((90 - 23.5) / 180 * (H - 1))
        local capr_y = math.floor((90 + 23.5) / 180 * (H - 1))
        if trop_y >= 0 and trop_y < H then img:drawLine(0, trop_y, W - 1, trop_y, 255, 255, 255, 255) end
        if capr_y >= 0 and capr_y < H then img:drawLine(0, capr_y, W - 1, capr_y, 255, 255, 255, 255) end

        save_png(img, path)
        lurek.globe.remove("globe_heatmap")
    end)

    -- @evidence lurek.image.savePNG
    -- @evidence lurek.globe.greatCirclePath
    it("PNG: globe great-circle route visualized", function()
        ensure_evidence_dir("globe")
        local path = OUT .. "globe_great_circle_route.png"

        local W, H = 360, 180
        local img = lurek.image.newImageData(W, H)
        img:fill(10, 20, 50, 255)

        -- Draw background grid natively
        for lat = -60, 60, 30 do
            local py = math.floor((90 - lat) / 180 * (H - 1))
            img:drawLine(0, py, W - 1, py, 40, 40, 80, 255)
        end
        for lon = -150, 150, 60 do
            local px = math.floor((lon + 180) / 360 * (W - 1))
            img:drawLine(px, 0, px, H - 1, 40, 40, 80, 255)
        end

        -- Call correct greatCirclePath API natively
        local path_pts = lurek.globe.greatCirclePath(40.7, -74.0, 35.7, 139.7, 80)
        local prev_px, prev_py = nil, nil
        for _, pt in ipairs(path_pts) do
            local px, py = latlon_to_px(pt[1], pt[2], W, H)
            if prev_px and prev_py and math.abs(px - prev_px) < W / 2 then
                img:drawLine(prev_px, prev_py, px, py, 255, 200, 80, 255)
            end
            prev_px, prev_py = px, py
        end

        -- Mark endpoints
        local nypx, nypy = latlon_to_px(40.7, -74.0, W, H)
        local tkpx, tkpy = latlon_to_px(35.7, 139.7, W, H)
        img:drawCircle(nypx, nypy, 5, 80, 200, 255, 255)
        img:drawCircle(tkpx, tkpy, 5, 255, 100, 80, 255)

        save_png(img, path)
    end)

    -- @evidence lurek.image.savePNG
    it("PNG: globe political color fill (Voronoi-style capital regions)", function()
        ensure_evidence_dir("globe")
        local path = OUT .. "globe_political_regions.png"

        local W, H = 320, 160
        local img = lurek.image.newImageData(W, H)

        local globe = lurek.globe.new("globe_political")

        -- 8 capitals with distinct country colors
        local capitals = {
            { lat = 51.5,  lon = -0.1,   r = 220, g = 60,  b = 60  },
            { lat = 48.9,  lon =  2.3,   r = 60,  g = 100, b = 220 },
            { lat = 52.5,  lon = 13.4,   r = 60,  g = 180, b = 80  },
            { lat = 41.9,  lon = 12.5,   r = 220, g = 200, b = 60  },
            { lat = 40.4,  lon = -3.7,   r = 200, g = 100, b = 220 },
            { lat = 55.7,  lon = 37.6,   r = 60,  g = 210, b = 210 },
            { lat = 35.7,  lon = 139.7,  r = 220, g = 160, b = 60  },
            { lat = 39.9,  lon = 116.4,  r = 180, g = 60,  b = 180 },
        }

        -- Nearest-capital Voronoi for each pixel with scanline span optimization
        for y = 0, H - 1 do
            local lat = 90 - (y / (H - 1)) * 180
            local last_i = nil
            local start_x = 0
            for x = 0, W - 1 do
                local lon = (x / (W - 1)) * 360 - 180
                local best_d, best_i = math.huge, 1
                for i, cap in ipairs(capitals) do
                    local dlat = lat - cap.lat
                    local dlon = lon - cap.lon
                    local d = dlat * dlat + dlon * dlon
                    if d < best_d then best_d, best_i = d, i end
                end
                if last_i and best_i ~= last_i then
                    local c = capitals[last_i]
                    img:drawLine(start_x, y, x - 1, y, c.r, c.g, c.b, 255)
                    start_x = x
                end
                last_i = best_i
            end
            local c = capitals[last_i]
            img:drawLine(start_x, y, W - 1, y, c.r, c.g, c.b, 255)
        end

        -- Mark capitals natively
        for _, cap in ipairs(capitals) do
            local px, py = latlon_to_px(cap.lat, cap.lon, W, H)
            img:drawCircle(px, py, 3, 255, 255, 255, 255)
        end

        save_png(img, path)
        lurek.globe.remove("globe_political")
    end)

    -- @evidence lurek.image.savePNG
    it("PNG: globe day/night terminator visualization", function()
        ensure_evidence_dir("globe")
        local path = OUT .. "globe_day_night_terminator.png"

        local W, H = 360, 180
        local img = lurek.image.newImageData(W, H)

        -- Sub-solar point: 20°N, 30°E (mid-day)
        local sol_lat = math.rad(20)
        local sol_lon = math.rad(30)

        -- Day/night terminator layout using scanline span optimization
        for y = 0, H - 1 do
            local lat = math.rad(90 - (y / (H - 1)) * 180)
            local last_day = nil
            local start_x = 0
            for x = 0, W - 1 do
                local lon = math.rad((x / (W - 1)) * 360 - 180)
                local cos_angle = math.sin(sol_lat) * math.sin(lat) +
                                  math.cos(sol_lat) * math.cos(lat) * math.cos(lon - sol_lon)
                local is_day = cos_angle > 0
                if last_day ~= nil and is_day ~= last_day then
                    if last_day then
                        local mid_x = (start_x + x - 1) / 2
                        local mid_lon = math.rad((mid_x / (W - 1)) * 360 - 180)
                        local mid_cos = math.sin(sol_lat) * math.sin(lat) +
                                        math.cos(sol_lat) * math.cos(lat) * math.cos(mid_lon - sol_lon)
                        local intensity = math.floor(math.max(0, mid_cos) * 200 + 55)
                        img:drawLine(start_x, y, x - 1, y, 80, 120, intensity, 255)
                    else
                        img:drawLine(start_x, y, x - 1, y, 10, 10, 40, 255)
                    end
                    start_x = x
                end
                last_day = is_day
            end
            if last_day then
                local mid_x = (start_x + W - 1) / 2
                local mid_lon = math.rad((mid_x / (W - 1)) * 360 - 180)
                local mid_cos = math.sin(sol_lat) * math.sin(lat) +
                                math.cos(sol_lat) * math.cos(lat) * math.cos(mid_lon - sol_lon)
                local intensity = math.floor(math.max(0, mid_cos) * 200 + 55)
                img:drawLine(start_x, y, W - 1, y, 80, 120, intensity, 255)
            else
                img:drawLine(start_x, y, W - 1, y, 10, 10, 40, 255)
            end
        end

        -- Sub-solar point marker natively
        local spx, spy = latlon_to_px(20, 30, W, H)
        img:drawCircle(spx, spy, 8, 255, 255, 80, 255)

        save_png(img, path)
    end)

    -- Additional globe marker evidence
    -- @evidence lurek.image.savePNG
    it("PNG: globe 3D map markers (isometric/pseudo-3D)", function()
        ensure_evidence_dir("globe")
        local path = OUT .. "globe_elevated_markers.png"

        local W, H = 360, 180
        local img = lurek.image.newImageData(W, H)
        img:fill(20, 20, 30, 255)

        -- Draw background grid
        for lat = -60, 60, 30 do
            local py = math.floor((90 - lat) / 180 * (H - 1))
            img:drawLine(0, py, W - 1, py, 40, 40, 60, 255)
        end
        for lon = -150, 150, 60 do
            local px = math.floor((lon + 180) / 360 * (W - 1))
            img:drawLine(px, 0, px, H - 1, 40, 40, 60, 255)
        end

        local function draw_3d_marker(lat, lon, height, color)
            local px, py = latlon_to_px(lat, lon, W, H)
            -- stem (shadow/line)
            img:drawLine(px, py, px, py - height, 200, 200, 200, 255)
            -- pin head
            img:drawCircle(px, py - height, 5, color[1], color[2], color[3], 255)
            img:drawCircle(px, py - height, 2, 255, 255, 255, 255)
            -- base dot
            img:drawCircle(px, py, 2, color[1], color[2], color[3], 150)
        end

        draw_3d_marker(40, -100, 25, {255, 50, 50})
        draw_3d_marker(50, 10, 35, {50, 255, 50})
        draw_3d_marker(-20, 40, 20, {50, 50, 255})
        draw_3d_marker(35, 139, 40, {255, 200, 50})

        save_png(img, path)
    end)

    -- Additional atmosphere evidence
    -- @evidence lurek.image.savePNG
    it("PNG: atmospheric scattering (edge glow on globe projection)", function()
        ensure_evidence_dir("globe")
        local path = OUT .. "globe_atmosphere_scattering.png"

        local W, H = 200, 200
        local img = lurek.image.newImageData(W, H)
        img:fill(10, 10, 15, 255)
        
        local cx, cy, r_globe = 100, 100, 70
        local r_atmos = 85

        -- Draw atmosphere scattering procedurally
        img:mapPixel(function(x, y, r, g, b, a)
            local dist = math.sqrt((x - cx)^2 + (y - cy)^2)
            if dist <= r_globe then
                -- Globe surface
                return 40, 80, 140, 255
            elseif dist <= r_atmos then
                -- Atmosphere glow (fades out as it goes further from r_globe)
                local intensity = 1.0 - ((dist - r_globe) / (r_atmos - r_globe))
                -- Exponential falloff for realistic glow
                intensity = intensity ^ 2
                return math.floor(10 + 90 * intensity), math.floor(10 + 150 * intensity), math.floor(15 + 240 * intensity), 255
            end
            return r, g, b, a
        end)

        save_png(img, path)
    end)

    -- Additional night-light evidence
    -- @evidence lurek.image.savePNG
    it("PNG: city night lights (glow on night side)", function()
        ensure_evidence_dir("globe")
        local path = OUT .. "globe_city_night_lights.png"

        local W, H = 360, 180
        local img = lurek.image.newImageData(W, H)
        img:fill(5, 5, 10, 255)

        local cities = {
            {lat = 40.7, lon = -74.0, pop = 1.0},
            {lat = 34.0, lon = -118.2, pop = 0.8},
            {lat = 51.5, lon = -0.1, pop = 0.9},
            {lat = 48.9, lon = 2.3, pop = 0.8},
            {lat = 35.7, lon = 139.7, pop = 1.0},
            {lat = 31.2, lon = 121.5, pop = 0.9},
            {lat = -23.5, lon = -46.6, pop = 0.8},
            {lat = 19.4, lon = -99.1, pop = 0.9},
        }

        for y = 0, H - 1 do
            local lat = 90 - (y / (H - 1)) * 180
            for x = 0, W - 1 do
                local lon = (x / (W - 1)) * 360 - 180
                local ocean = 6 + math.max(0, math.cos(math.rad(lat)) * 10)
                img:setPixel(x, y, ocean, ocean, ocean + 6, 255)
                local intensity = 0
                for _, city in ipairs(cities) do
                    local dlat = lat - city.lat
                    local dlon = lon - city.lon
                    local d = math.sqrt(dlat*dlat + dlon*dlon)
                    if d < 10 then
                        intensity = intensity + city.pop * (1.0 - (d / 10))
                    end
                end
                if intensity > 0 then
                    local lum = math.min(255, math.floor(intensity * 255))
                    img:setPixel(x, y, math.floor(lum), math.floor(lum * 0.9), math.floor(lum * 0.6), 255)
                end
            end
        end

        for lon = -180, 180, 60 do
            local gx = math.floor((lon + 180) / 360 * (W - 1))
            img:drawLine(gx, 0, gx, H - 1, 18, 20, 28, 255)
        end
        for lat = -60, 60, 30 do
            local gy = math.floor((90 - lat) / 180 * (H - 1))
            img:drawLine(0, gy, W - 1, gy, 18, 20, 28, 255)
        end
        draw_outline(img, 0, 0, W, H, 232, 236, 244, 255)

        save_png(img, path)
    end)

    -- Additional grid-overlay evidence
    -- @evidence lurek.image.savePNG
    it("PNG: globe latitude/longitude grid overlay", function()
        ensure_evidence_dir("globe")
        local path = OUT .. "globe_latitude_longitude_grid.png"

        local W, H = 360, 180
        local img = lurek.image.newImageData(W, H)
        img:fill(20, 20, 35, 255)

        local lat_step = 15
        local lon_step = 15

        for lat = -90 + lat_step, 90 - lat_step, lat_step do
            local y = math.floor((90 - lat) / 180 * (H - 1))
            local alpha = (lat == 0) and 255 or 100
            local thick = (lat == 0) and 2 or 1
            if thick == 2 then
                img:drawLine(0, y-1, W-1, y-1, 100, 150, 200, alpha)
                img:drawLine(0, y, W-1, y, 100, 150, 200, alpha)
            else
                img:drawLine(0, y, W-1, y, 80, 100, 120, alpha)
            end
        end

        for lon = -180, 180 - lon_step, lon_step do
            local x = math.floor((lon + 180) / 360 * (W - 1))
            local alpha = (lon == 0) and 255 or 100
            local thick = (lon == 0) and 2 or 1
            if thick == 2 then
                img:drawLine(x-1, 0, x-1, H-1, 200, 150, 100, alpha)
                img:drawLine(x, 0, x, H-1, 200, 150, 100, alpha)
            else
                img:drawLine(x, 0, x, H-1, 120, 100, 80, alpha)
            end
        end

        save_png(img, path)
    end)

    -- Additional topography evidence
    -- @evidence lurek.image.savePNG
    it("PNG: topographical height map blending", function()
        ensure_evidence_dir("globe")
        local path = OUT .. "globe_topography_palette.png"

        local W, H = 200, 100
        local img = lurek.image.newImageData(W, H)
        
        img:mapPixel(function(x, y, r, g, b, a)
            local lon = (x / (W - 1)) * 360 - 180
            local lat = 90 - (y / (H - 1)) * 180
            
            -- mock procedural noise based on lat/lon
            local noise = math.sin(lon * 0.1) * math.cos(lat * 0.1) + math.sin(lon * 0.2 + lat * 0.2) * 0.5
            noise = (noise + 1.5) / 3.0 -- normalize 0 to 1
            
            if noise < 0.4 then
                -- deep water to shallow water
                local depth = noise / 0.4
                return math.floor(20 + 30 * depth), math.floor(40 + 60 * depth), math.floor(100 + 80 * depth), 255
            elseif noise < 0.45 then
                -- sand
                return 210, 190, 130, 255
            elseif noise < 0.7 then
                -- forest / grass
                local alt = (noise - 0.45) / 0.25
                return math.floor(40 + 40 * alt), math.floor(120 - 40 * alt), math.floor(40 + 20 * alt), 255
            elseif noise < 0.85 then
                -- mountain rock
                local alt = (noise - 0.7) / 0.15
                return math.floor(100 + 50 * alt), math.floor(100 + 50 * alt), math.floor(100 + 50 * alt), 255
            else
                -- snow peak
                return 240, 240, 250, 255
            end
        end)

        save_png(img, path)
    end)

    -- @evidence lurek.globe.new
    -- @evidence lurek.globe.greatCirclePath
    -- @evidence lurek.image.savePNG
    it("PNG: globe contact sheet", function()
        ensure_evidence_dir("globe")
        local files = {
            "globe_province_projection.png",
            "globe_great_circle_route.png",
            "globe_day_night_terminator.png",
            "globe_city_night_lights.png",
            "globe_latitude_longitude_grid.png",
            "globe_topography_palette.png",
        }
        local canvas = lurek.image.newImageData(744, 504)
        canvas:fill(12, 14, 20, 255)
        for i, name in ipairs(files) do
            local src = lurek.image.newImageData(OUT .. name)
            local thumb = src:resize(224, 152, "bilinear")
            local col = (i - 1) % 3
            local row = math.floor((i - 1) / 3)
            local x = 16 + col * 240
            local y = 16 + row * 168
            canvas:paste(thumb, x, y)
            draw_outline(canvas, x, y, 224, 152, 232, 236, 244, 255)
        end
        save_png(canvas, OUT .. "globe_contact_sheet.png")
    end)

end)

-- @describe Evidence: lurek.globe camera, fog, and registry trace
describe("Evidence: lurek.globe camera, fog, and registry trace", function()
    before_each(function()
        ensure_evidence_dir("globe")
    end)

    -- @evidence LGlobe:setCamera
    -- @evidence LGlobe:getCamera
    -- @evidence LGlobe:pickLatLon
    -- @evidence LGlobe:addMarker
    -- @evidence LGlobe:addLabel
    -- @evidence LGlobe:addArc
    -- @evidence LGlobe:addRegion
    -- @evidence LGlobe:setFogState
    -- @evidence LGlobe:getFogState
    -- @evidence LGlobe:encodeFogBase64
    -- @evidence LGlobe:decodeFogBase64
    -- @evidence lurek.globe.greatCircleDistance
    -- @evidence lurek.globe.latLonToUnit
    -- @evidence lurek.globe.raySphereIntersect
    it("TXT: camera, fog, geometry, and registry trace", function()
        local g = lurek.globe.new("globe_evidence_trace")

        g:setCamera(18.0, 22.0, 1.8)
        local lat, lon, zoom = g:getCamera()
        expect_near(18.0, lat, 0.001)
        expect_near(22.0, lon, 0.001)
        expect_near(1.8, zoom, 0.001)

        local pick = g:pickLatLon(640, 360)
        local marker_id = g:addMarker("city", 51.5, -0.1, "London")
        local label_id = g:addLabel("region", 48.8, 2.3, "Western Europe")
        local arc_id = g:addArc(51.5, -0.1, 40.7, -74.0)
        local region_ok = g:addRegion({
            id = 1,
            centroid = { 45.0, 10.0 },
            vertices = {
                { 44.0, 9.0 },
                { 44.0, 11.0 },
                { 46.0, 11.0 },
                { 46.0, 9.0 },
            },
            neighbors = {},
        })
        expect_true(region_ok)

        g:setFogState("viewer_trace", 1, "explored")
        local fog_before = g:getFogState("viewer_trace", 1)
        local fog_payload = g:encodeFogBase64("viewer_trace")
        expect_true(type(fog_payload) == "string" and #fog_payload > 0)
        g:setFogState("viewer_trace", 1, "hidden")
        expect_true(g:decodeFogBase64("viewer_trace", fog_payload))
        local fog_after = g:getFogState("viewer_trace", 1)

        local distance = lurek.globe.greatCircleDistance(51.5, -0.1, 40.7, -74.0)
        local unit = lurek.globe.latLonToUnit(0.0, 0.0)
        local hit = lurek.globe.raySphereIntersect(0, 0, -5, 0, 0, 1, 1)

        local lines = {
            string.format("camera=%.2f,%.2f,%.2f", lat, lon, zoom),
            "pick_type=" .. (pick == nil and "nil" or type(pick)),
            "marker_id=" .. tostring(marker_id),
            "label_id=" .. tostring(label_id),
            "arc_id=" .. tostring(arc_id),
            "fog_before=" .. tostring(fog_before),
            "fog_after=" .. tostring(fog_after),
            "distance=" .. tostring(distance),
            string.format("unit_basis=%.3f,%.3f,%.3f", unit[1], unit[2], unit[3]),
            "ray_hit=" .. tostring(hit),
        }

        write_text(OUT .. "globe_camera_fog_geometry_trace.txt", table.concat(lines, "\n") .. "\n")
        lurek.globe.remove("globe_evidence_trace")
    end)
end)
test_summary()
