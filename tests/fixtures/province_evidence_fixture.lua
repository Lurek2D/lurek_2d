local Fixture = {}

local ROOT = "save/province_evidence_fixture"

local COLORS = {
    sea = { 18, 44, 96 },
    north = { 200, 92, 88 },
    west = { 106, 166, 96 },
    heart = { 216, 186, 110 },
    east = { 120, 124, 200 },
    south = { 146, 102, 64 },
    delta = { 84, 182, 176 },
}

Fixture.capitals = {
    [11] = { x = 18, y = 14 },
    [12] = { x = 18, y = 34 },
    [13] = { x = 42, y = 26 },
    [14] = { x = 68, y = 16 },
    [15] = { x = 62, y = 42 },
    [16] = { x = 82, y = 30 },
}

Fixture.label_lines = {
    [11] = { { 8, 8 }, { 22, 8 }, { 28, 10 } },
    [12] = { { 8, 38 }, { 24, 38 }, { 30, 40 } },
    [13] = { { 30, 24 }, { 48, 24 }, { 54, 26 } },
    [14] = { { 56, 10 }, { 78, 10 }, { 86, 14 } },
    [15] = { { 46, 46 }, { 64, 46 }, { 72, 48 } },
    [16] = { { 72, 28 }, { 88, 28 }, { 92, 30 } },
}

Fixture.route = { 12, 13, 14, 16 }

local function ensure_dir(path)
    pcall(function()
        lurek.filesystem.createDirectory(path)
    end)
end

local function fill_rect(img, x, y, w, h, color)
    for yy = y, y + h - 1 do
        for xx = x, x + w - 1 do
            img:setPixel(xx, yy, color[1], color[2], color[3], 255)
        end
    end
end

local function draw_label_pixels(img)
    for _, points in pairs(Fixture.label_lines) do
        for _, point in ipairs(points) do
            img:setPixel(point[1], point[2], 255, 0, 255, 255)
        end
    end
end

local function base_color_map()
    local img = lurek.image.newImageData(96, 64)
    fill_rect(img, 0, 0, 96, 64, COLORS.sea)

    fill_rect(img, 4, 4, 28, 18, COLORS.north)
    fill_rect(img, 4, 22, 28, 26, COLORS.west)
    fill_rect(img, 32, 12, 24, 22, COLORS.heart)
    fill_rect(img, 56, 4, 22, 22, COLORS.east)
    fill_rect(img, 40, 34, 28, 18, COLORS.south)
    fill_rect(img, 68, 20, 20, 22, COLORS.delta)

    return img
end

local function marker_map()
    local img = base_color_map()
    for _, point in pairs(Fixture.capitals) do
        img:setPixel(point.x, point.y, 255, 255, 255, 255)
    end
    draw_label_pixels(img)
    return img
end

local function csv_text()
    return table.concat({
        "ID,R,G,B,hex,count",
        "11,200,92,88,#c85c58,1",
        "12,106,166,96,#6aa660,1",
        "13,216,186,110,#d8ba6e,1",
        "14,120,124,200,#787cc8,1",
        "15,146,102,64,#926640,1",
        "16,84,182,176,#54b6b0,1",
        "90,18,44,96,#122c60,1",
    }, "\n") .. "\n"
end

local function toml_text()
    return table.concat({
        "[11]",
        'name = "North March"',
        'terrain = "plains"',
        "",
        "[12]",
        'name = "Green Hollow"',
        'terrain = "forest"',
        "",
        "[13]",
        'name = "Sun Keep"',
        'terrain = "farmland"',
        "",
        "[14]",
        'name = "Azure Reach"',
        'terrain = "hills"',
        "",
        "[15]",
        'name = "Copper Gate"',
        'terrain = "mountain"',
        "",
        "[16]",
        'name = "Delta Port"',
        'terrain = "marsh"',
        "",
        "[90]",
        'name = "Outer Sea"',
        'terrain = "sea"',
        "",
    }, "\n")
end

function Fixture.ensure()
    ensure_dir("save")
    ensure_dir(ROOT)

    local color_map = ROOT .. "/province_color_map.png"
    local marker_png = ROOT .. "/province_marked_map.png"
    local csv_path = ROOT .. "/province_colors.csv"
    local toml_path = ROOT .. "/province_data.toml"

    lurek.image.savePNG(base_color_map(), color_map)
    lurek.image.savePNG(marker_map(), marker_png)
    lurek.filesystem.write(csv_path, csv_text())
    lurek.filesystem.write(toml_path, toml_text())

    return {
        root = ROOT,
        color_map_png = color_map,
        marker_png = marker_png,
        color_csv = csv_path,
        province_toml = toml_path,
    }
end

local function base_canvas(sanitized_path)
    local base = lurek.image.newImageData(sanitized_path):resize(480, 320, "bilinear")
    local canvas = lurek.image.newImageData(560, 360)
    canvas:fill(10, 14, 20, 255)
    canvas:paste(base, 20, 20)
    canvas:drawRect(18, 18, 484, 324, 230, 236, 246, 255)
    return canvas
end

function Fixture.render_border_segments(registry, sanitized_path)
    local canvas = base_canvas(sanitized_path)

    local scale = 5
    for _, segment in ipairs(registry:borderSegments()) do
        canvas:drawLine(
            20 + segment.x0 * scale,
            20 + segment.y0 * scale,
            20 + segment.x1 * scale,
            20 + segment.y1 * scale,
            12,
            18,
            24,
            255
        )
    end
    return canvas
end

function Fixture.render_capitals_centroids(registry, sanitized_path)
    local canvas = base_canvas(sanitized_path)
    local scale = 5

    for id, capital in pairs(Fixture.capitals) do
        local province = registry:getProvince(id)
        if province then
            local c = province.centroid
            canvas:drawCircle(20 + capital.x * scale, 20 + capital.y * scale, 5, 255, 255, 255, 255)
            canvas:drawCircle(20 + math.floor(c.x * scale), 20 + math.floor(c.y * scale), 4, 255, 208, 96, 255)
        end
    end
    return canvas
end

function Fixture.render_route_trace(registry, sanitized_path)
    local canvas = base_canvas(sanitized_path)
    local scale = 5

    for _, path_id in ipairs(Fixture.route) do
        local province = registry:getProvince(path_id)
        if province and province.centroid then
            province._draw_x = 20 + math.floor(province.centroid.x * scale)
            province._draw_y = 20 + math.floor(province.centroid.y * scale)
        end
    end

    for i = 1, #Fixture.route - 1 do
        local a = registry:getProvince(Fixture.route[i])
        local b = registry:getProvince(Fixture.route[i + 1])
        if a and b and a.centroid and b.centroid then
            canvas:drawLine(
                20 + math.floor(a.centroid.x * scale),
                20 + math.floor(a.centroid.y * scale),
                20 + math.floor(b.centroid.x * scale),
                20 + math.floor(b.centroid.y * scale),
                255,
                214,
                92,
                255
            )
        end
    end
    return canvas
end

return Fixture
