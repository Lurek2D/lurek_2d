-- test_procgen_evidence.lua
-- Canonical evidence file for lurek.procgen data and visual outputs.



local OUT = evidence_output_dir("procgen")

local function clamp255(v)
    if v < 0 then return 0 end
    if v > 255 then return 255 end
    return math.floor(v)
end

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function save_binary_map_png(data, w, h, path)
    local img = lurek.image.newImageData(w, h)
    for y = 0, h - 1 do
        for x = 0, w - 1 do
            local v = data[y * w + x + 1] or 0
            if v == 1 then
                img:setPixel(x, y, 24, 24, 26, 255)
            else
                img:setPixel(x, y, 205, 205, 198, 255)
            end
        end
    end
    save_png(img, path)
end

-- @describe Evidence: lurek.procgen visual and sampled outputs
describe("Evidence: lurek.procgen visual and sampled outputs", function()
    -- @evidence lurek.image.savePNG
    -- @evidence lurek.procgen.floodFill
    -- @evidence lurek.procgen.cellularAutomata
    it("PNG: cellular automata with flood fill overlay", function()
        local gw, gh = 64, 64
        local scale = 4
        local img = lurek.image.newImageData(gw * scale, gh * scale)

        local cave = lurek.procgen.cellularAutomata(gw, gh, { fill = 0.46, iterations = 5, seed = 17 })
        local flooded = lurek.procgen.floodFill(cave, gw, gh, math.floor(gw / 2), math.floor(gh / 2), 0, false)

        for gy = 0, gh - 1 do
            for gx = 0, gw - 1 do
                local idx = gy * gw + gx + 1
                local px, py = gx * scale, gy * scale
                if cave[idx] == 1 then
                    img:drawRect(px, py, scale, scale, 52, 48, 58, 255)
                else
                    img:drawRect(px, py, scale, scale, 150, 165, 140, 255)
                end
                if flooded[idx] == 1 then
                    img:drawRect(px + 1, py + 1, scale - 2, scale - 2, 80, 170, 230, 210)
                end
            end
        end

        save_png(img, OUT .. "procgen_cellular_flood.png")
    end)

    -- @evidence lurek.image.savePNG
    -- @evidence lurek.procgen.voronoi
    -- @evidence lurek.procgen.poissonDisk
    it("PNG: poisson disk points with voronoi regions", function()
        local W, H = 300, 220
        local img = lurek.image.newImageData(W, H)
        img:drawRect(0, 0, W, H, 18, 20, 28, 255)

        local points = lurek.procgen.poissonDisk(W, H, 18, 30, 42)
        local regions, dist, dist2 = lurek.procgen.voronoi(W, H, points, { metric = "euclidean" })

        for y = 0, H - 1 do
            for x = 0, W - 1 do
                local idx = y * W + x + 1
                local rid = regions[idx] or 0
                local d = dist[idx] or 0
                local shade = clamp255(40 + d * 35)
                local r = (rid * 47) % 180 + 50
                local g = (rid * 67) % 180 + 50
                local b = (rid * 83) % 180 + 50
                img:setPixel(x, y, clamp255((r + shade) * 0.5), clamp255((g + shade) * 0.5), clamp255((b + shade) * 0.5), 255)
            end
        end

        for _, pt in ipairs(points) do
            img:drawCircle(math.floor(pt.x), math.floor(pt.y), 2, 235, 245, 255, 255)
        end

        -- use dist2 just to ensure this output path touches all 3 voronoi return tables
        if #dist2 > 0 then
            img:drawRect(4, 4, 10, 4, 255, 210, 120, 255)
        end

        save_png(img, OUT .. "procgen_poisson_voronoi.png")
    end)

    -- @evidence lurek.image.savePNG
    -- @evidence lurek.procgen.simplex3d
    -- @evidence lurek.procgen.simplex2d
    -- @evidence lurek.procgen.perlinNoise
    -- @evidence lurek.procgen.noiseMapParallel
    -- @evidence lurek.procgen.noiseMap
    it("PNG: noise map vs parallel noise with perlin/simplex strips", function()
        local W, H = 256, 192
        local img = lurek.image.newImageData(W, H)

        local w2, h2 = 64, 48
        local a = lurek.procgen.noiseMap(w2, h2, { seed = 77, scale_x = 0.08, scale_y = 0.08, octaves = 4 })
        local b = lurek.procgen.noiseMapParallel(w2, h2, { seed = 77, scale_x = 0.08, scale_y = 0.08, octaves = 4 })

        -- left: noiseMap
        for y = 0, h2 - 1 do
            for x = 0, w2 - 1 do
                local idx = y * w2 + x + 1
                local v = a[idx] or 0
                local c = clamp255((v * 0.5 + 0.5) * 255)
                img:drawRect(x * 2, y * 2, 2, 2, c, c, c, 255)
            end
        end

        -- right: noiseMapParallel
        for y = 0, h2 - 1 do
            for x = 0, w2 - 1 do
                local idx = y * w2 + x + 1
                local v = b[idx] or 0
                local c = clamp255((v * 0.5 + 0.5) * 255)
                img:drawRect(128 + x * 2, y * 2, 2, 2, c, c, c, 255)
            end
        end

        -- bottom strips: perlin + simplex2d + simplex3d samples
        for x = 0, W - 1 do
            local p = lurek.procgen.perlinNoise(x * 0.03, 0.42, 7.0, 7.0)
            local s2 = lurek.procgen.simplex2d(x * 0.03, 0.25)
            local s3 = lurek.procgen.simplex3d(x * 0.03, 0.25, 0.75)
            img:drawRect(x, 110, 1, 18, clamp255((p * 0.5 + 0.5) * 255), 80, 100, 255)
            img:drawRect(x, 132, 1, 18, 80, clamp255((s2 * 0.5 + 0.5) * 255), 120, 255)
            img:drawRect(x, 154, 1, 18, 100, 120, clamp255((s3 * 0.5 + 0.5) * 255), 255)
        end

        save_png(img, OUT .. "procgen_noise_suite.png")
    end)

    -- @evidence lurek.image.savePNG
    -- @evidence lurek.procgen.roomsDungeon
    -- @evidence lurek.procgen.bspDungeon
    it("PNG: BSP and rooms dungeons side by side", function()
        local W, H = 360, 200
        local img = lurek.image.newImageData(W, H)
        img:drawRect(0, 0, W, H, 24, 25, 32, 255)

        local bsp = lurek.procgen.bspDungeon({ width = 40, height = 28, seed = 9 })
        local rooms = lurek.procgen.roomsDungeon({ width = 40, height = 28, max_rooms = 12, seed = 19 })

        -- BSP rooms (left)
        for _, r in ipairs(bsp.rooms) do
            img:drawRect(8 + r.x * 3, 8 + r.y * 3, math.max(1, r.w * 3), math.max(1, r.h * 3), 120, 190, 145, 255)
        end

        -- roomsDungeon grid (right)
        for y = 0, rooms.height - 1 do
            for x = 0, rooms.width - 1 do
                local idx = y * rooms.width + x + 1
                local v = rooms.grid[idx] or 0
                if v == 1 then
                    img:drawRect(184 + x * 3, 8 + y * 3, 3, 3, 180, 165, 110, 255)
                else
                    img:drawRect(184 + x * 3, 8 + y * 3, 3, 3, 52, 50, 58, 255)
                end
            end
        end

        save_png(img, OUT .. "procgen_dungeons.png")
    end)

    -- @evidence lurek.image.savePNG
    -- @evidence lurek.procgen.worldGraph
    -- @evidence lurek.procgen.heightmap
    it("PNG: heightmap + world graph overlay", function()
        local W, H = 320, 240
        local img = lurek.image.newImageData(W, H)

        local hm = lurek.procgen.heightmap({ width = 80, height = 60, seed = 33, octaves = 4, persistence = 0.5 })
        local wg = lurek.procgen.worldGraph(W, H, 14, 8)

        for y = 0, hm.height - 1 do
            for x = 0, hm.width - 1 do
                local idx = y * hm.width + x + 1
                local v = hm.cells[idx] or 0
                local r = clamp255(v * 220)
                local g = clamp255(v * 255)
                local b = clamp255(90 + v * 120)
                img:drawRect(x * 4, y * 4, 4, 4, r, g, b, 255)
            end
        end

        for _, e in ipairs(wg.edges) do
            local from_region, to_region = nil, nil
            for _, r in ipairs(wg.regions) do
                if r.id == e.from then from_region = r end
                if r.id == e.to then to_region = r end
            end
            if from_region and to_region then
                img:drawLine(from_region.x, from_region.y, to_region.x, to_region.y, 30, 30, 40, 180)
            end
        end
        for _, r in ipairs(wg.regions) do
            img:drawCircle(math.floor(r.x), math.floor(r.y), 3, 245, 245, 255, 255)
        end

        save_png(img, OUT .. "procgen_height_worldgraph.png")
    end)

    -- @evidence lurek.image.savePNG
    -- @evidence lurek.procgen.wfcGenerate
    -- @evidence lurek.procgen.lsystemSegments
    -- @evidence lurek.procgen.generateNames
    it("PNG: WFC tiles + L-system segments + generated names", function()
        local W, H = 320, 220
        local img = lurek.image.newImageData(W, H)
        img:drawRect(0, 0, W, H, 16, 18, 24, 255)

        local grid = lurek.procgen.wfcGenerate({
            width = 20,
            height = 14,
            seed = 12,
            max_attempts = 4,
            tiles = {
                { id = 0, weight = 1.0 },
                { id = 1, weight = 1.2 },
                { id = 2, weight = 0.8 },
            },
            adjacencies = {
                [0] = { 0, 1 },
                [1] = { 0, 1, 2 },
                [2] = { 1, 2 },
            },
        })

        for y = 0, grid.height - 1 do
            for x = 0, grid.width - 1 do
                local idx = y * grid.width + x + 1
                local t = grid.cells[idx] or 0
                if t == 0 then
                    img:drawRect(8 + x * 6, 8 + y * 6, 6, 6, 80, 95, 130, 255)
                elseif t == 1 then
                    img:drawRect(8 + x * 6, 8 + y * 6, 6, 6, 110, 160, 120, 255)
                else
                    img:drawRect(8 + x * 6, 8 + y * 6, 6, 6, 180, 140, 100, 255)
                end
            end
        end

        local segs = lurek.procgen.lsystemSegments(
            { axiom = "F+F+F+F", rules = {}, iterations = 0 },
            90,
            8.0
        )
        for _, s in ipairs(segs) do
            img:drawLine(220 + s.x1, 40 + s.y1, 220 + s.x2, 40 + s.y2, 240, 230, 160, 255)
        end

        local names = lurek.procgen.generateNames({ "Aldor", "Brenna", "Caelis", "Davor" }, 4, 4, 9, 99)
        for i, n in ipairs(names) do
            local c = clamp255(70 + i * 40)
            img:drawRect(210, 140 + (i - 1) * 16, math.min(100, #n * 8), 10, c, 200, 240, 255)
        end

        save_png(img, OUT .. "procgen_wfc_lsystem_names.png")
    end)
end)

-- @describe Evidence: lurek.procgen sampled data exports
describe("Evidence: lurek.procgen sampled data exports", function()
    before_each(function()
        ensure_evidence_dir("procgen")
    end)

    -- @evidence lurek.procgen.perlin2d
    it("TXT: procgen_perlin_grid.json -- direct perlin grid samples", function()
        local rows = {}
        for y = 0, 15 do
            local cols = {}
            for x = 0, 15 do
                cols[#cols + 1] = string.format("%.5f", tonumber(lurek.procgen.perlin2d(x * 0.08, y * 0.08)) or 0)
            end
            rows[#rows + 1] = "[" .. table.concat(cols, ",") .. "]"
        end
        local path = OUT .. "procgen_perlin_grid.json"
        write_text(path, "[" .. table.concat(rows, ",") .. "]")
        expect_evidence_created(path)
    end)

    -- @evidence lurek.procgen.simplex2d
    it("TXT: procgen_simplex_grid.json -- direct simplex grid samples", function()
        local rows = {}
        for y = 0, 15 do
            local cols = {}
            for x = 0, 15 do
                cols[#cols + 1] = string.format("%.5f", tonumber(lurek.procgen.simplex2d(x * 0.10, y * 0.10)) or 0)
            end
            rows[#rows + 1] = "[" .. table.concat(cols, ",") .. "]"
        end
        local path = OUT .. "procgen_simplex_grid.json"
        write_text(path, "[" .. table.concat(rows, ",") .. "]")
        expect_evidence_created(path)
    end)

    -- @evidence lurek.procgen.newNoiseGenerator
    -- @evidence LNoiseGenerator:perlin2d
    it("TXT: procgen_seeded_noise_grid.json -- seeded perlin generator samples", function()
        local ng = lurek.procgen.newNoiseGenerator(42)
        local rows = {}
        for y = 0, 15 do
            local cols = {}
            for x = 0, 15 do
                cols[#cols + 1] = string.format("%.5f", tonumber(ng:perlin2d(x * 0.12, y * 0.12)) or 0)
            end
            rows[#rows + 1] = "[" .. table.concat(cols, ",") .. "]"
        end
        local path = OUT .. "procgen_seeded_noise_grid.json"
        write_text(path, "[" .. table.concat(rows, ",") .. "]")
        expect_evidence_created(path)
    end)

    -- @evidence lurek.procgen.cellularAutomata
    -- @evidence lurek.image.savePNG
    it("PNG: procgen_cellular_cave_map.png -- cave map plus statistics report", function()
        local w, h = 64, 64
        local data = lurek.procgen.cellularAutomata(w, h, {
            wall_chance = 0.45,
            birth_limit = 5,
            survival_limit = 4,
            iterations = 5,
        })

        expect_true(type(data) == "table")
        expect_equal(w * h, #data)

        local walls = 0
        for i = 1, #data do
            if data[i] == 1 then
                walls = walls + 1
            end
        end

        local png = OUT .. "procgen_cellular_cave_map.png"
        save_binary_map_png(data, w, h, png)

        local txt = OUT .. "procgen_cellular_cave_map_stats.txt"
        local lines = {
            "width=" .. tostring(w),
            "height=" .. tostring(h),
            "walls=" .. tostring(walls),
            "floors=" .. tostring((w * h) - walls),
        }
        write_text(txt, table.concat(lines, "\n") .. "\n")
        expect_evidence_created(txt)
    end)

    -- @evidence lurek.procgen.cellularAutomata
    -- @evidence lurek.image.savePNG
    it("PNG: procgen_cellular_dense_map.png -- dense cave variation", function()
        local w, h = 96, 64
        local data = lurek.procgen.cellularAutomata(w, h, {
            wall_chance = 0.62,
            birth_limit = 4,
            survival_limit = 3,
            iterations = 3,
        })

        expect_equal(w * h, #data)
        save_binary_map_png(data, w, h, OUT .. "procgen_cellular_dense_map.png")
    end)

    -- @evidence lurek.procgen.newNoiseGenerator
    -- @evidence lurek.procgen.simplexNoise
    -- @evidence lurek.image.savePNG
    it("PNG: procgen_noise_heightmap_colored.png -- octave noise terrain palette", function()
        local generator = lurek.procgen.newNoiseGenerator(7777)
        expect_not_nil(generator)

        local size = 256
        local img = lurek.image.newImageData(size, size)
        for y = 0, size - 1 do
            for x = 0, size - 1 do
                local scale = 0.01
                local amp = 1.0
                local freq = 1.0
                local max_amp = 0.0
                local v = 0.0
                for _ = 1, 5 do
                    local sample = lurek.procgen.simplexNoise(x * scale * freq, y * scale * freq)
                    v = v + sample * amp
                    max_amp = max_amp + amp
                    amp = amp * 0.5
                    freq = freq * 2.0
                end
                v = v / max_amp
                local nv = (v + 1.0) / 2.0
                local r, g, b = 255, 255, 255
                if nv < 0.40 then
                    r, g, b = 0, 100, 200
                elseif nv < 0.45 then
                    r, g, b = 200, 200, 100
                elseif nv < 0.70 then
                    r, g, b = 34, 139, 34
                elseif nv < 0.90 then
                    r, g, b = 100, 100, 100
                end
                img:setPixel(x, y, r, g, b, 255)
            end
        end

        local path = OUT .. "procgen_noise_heightmap_colored.png"
        save_png(img, path)
    end)
end)
test_summary()
