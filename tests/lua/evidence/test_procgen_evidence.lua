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

local function draw_outline(img, x, y, w, h, r, g, b, a)
    img:drawLine(x, y, x + w - 1, y, r, g, b, a or 255)
    img:drawLine(x + w - 1, y, x + w - 1, y + h - 1, r, g, b, a or 255)
    img:drawLine(x + w - 1, y + h - 1, x, y + h - 1, r, g, b, a or 255)
    img:drawLine(x, y + h - 1, x, y, r, g, b, a or 255)
end

local function save_binary_map_png(data, w, h, path)
    local scale = 4
    local img = lurek.image.newImageData(w * scale, h * scale)
    for y = 0, h - 1 do
        for x = 0, w - 1 do
            local v = data[y * w + x + 1] or 0
            local r, g, b
            if v == 1 then
                r, g, b = 24, 24, 26
            else
                r, g, b = 205, 205, 198
            end
            img:drawRect(x * scale, y * scale, scale, scale, r, g, b, 255)
            img:setPixel(x * scale, y * scale, clamp255(r - 18), clamp255(g - 18), clamp255(b - 18), 255)
        end
    end
    draw_outline(img, 0, 0, w * scale, h * scale, 232, 236, 244, 255)
    save_png(img, path)
end

-- @describe Evidence: lurek.procgen visual and sampled outputs
describe("Evidence: lurek.procgen visual and sampled outputs", function()
    -- Does: Runs "cellular automata with flood fill overlay" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.procgen.floodFill and lurek.procgen.cellularAutomata without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/procgen/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from lurek.procgen.floodFill and lurek.procgen.cellularAutomata; export helpers are just the container.

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
    -- Does: Runs "poisson disk points with voronoi regions" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.procgen.voronoi and lurek.procgen.poissonDisk without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/procgen/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from lurek.procgen.voronoi and lurek.procgen.poissonDisk; export helpers are just the container.

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
    -- Does: Runs "noise map vs parallel noise with perlin/simplex strips" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.procgen.simplex3d, lurek.procgen.simplex2d, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/procgen/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from lurek.procgen.simplex3d, lurek.procgen.simplex2d, and related owner calls; export helpers are just the container.

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
    -- Does: Runs "BSP and rooms dungeons side by side" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.procgen.roomsDungeon and lurek.procgen.bspDungeon without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/procgen/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from lurek.procgen.roomsDungeon and lurek.procgen.bspDungeon; export helpers are just the container.

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
    -- Does: Runs "heightmap + world graph overlay" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.procgen.worldGraph and lurek.procgen.heightmap without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/procgen/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from lurek.procgen.worldGraph and lurek.procgen.heightmap; export helpers are just the container.

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
    -- Does: Runs "WFC tiles + L-system segments + generated names" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.procgen.wfcGenerate, lurek.procgen.lsystemSegments, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/procgen/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from lurek.procgen.wfcGenerate, lurek.procgen.lsystemSegments, and related owner calls; export helpers are just the container.

    it("PNG: WFC tiles + L-system segments + generated names", function()
        local W, H = 420, 260
        local img = lurek.image.newImageData(W, H)
        img:drawRect(0, 0, W, H, 16, 18, 24, 255)
        img:drawRect(12, 12, 206, 182, 24, 28, 36, 255)
        img:drawRect(234, 12, 174, 128, 24, 28, 36, 255)
        img:drawRect(234, 152, 174, 96, 24, 28, 36, 255)
        draw_outline(img, 12, 12, 206, 182, 232, 236, 244, 255)
        draw_outline(img, 234, 12, 174, 128, 232, 236, 244, 255)
        draw_outline(img, 234, 152, 174, 96, 232, 236, 244, 255)

        local grid = lurek.procgen.wfcGenerate({
            width = 26,
            height = 20,
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
                local px = 20 + x * 7
                local py = 20 + y * 7
                if t == 0 then
                    img:drawRect(px, py, 7, 7, 80, 95, 130, 255)
                elseif t == 1 then
                    img:drawRect(px, py, 7, 7, 110, 160, 120, 255)
                else
                    img:drawRect(px, py, 7, 7, 180, 140, 100, 255)
                end
            end
        end

        local segs = lurek.procgen.lsystemSegments(
            {
                axiom = "F",
                iterations = 4,
                rules = { F = "FF+[+F-F-F]-[-F+F+F]" },
            },
            25,
            5.0
        )
        local min_x, min_y = math.huge, math.huge
        local max_x, max_y = -math.huge, -math.huge
        for _, s in ipairs(segs) do
            min_x = math.min(min_x, s.x1, s.x2)
            min_y = math.min(min_y, s.y1, s.y2)
            max_x = math.max(max_x, s.x1, s.x2)
            max_y = math.max(max_y, s.y1, s.y2)
        end
        local span_x = math.max(1, max_x - min_x)
        local span_y = math.max(1, max_y - min_y)
        local scale = math.min(132 / span_x, 92 / span_y)
        for _, s in ipairs(segs) do
            local x1 = 248 + math.floor((s.x1 - min_x) * scale + 0.5)
            local y1 = 128 - math.floor((s.y1 - min_y) * scale + 0.5)
            local x2 = 248 + math.floor((s.x2 - min_x) * scale + 0.5)
            local y2 = 128 - math.floor((s.y2 - min_y) * scale + 0.5)
            img:drawLine(x1, y1, x2, y2, 240, 230, 160, 255)
        end

        local names = lurek.procgen.generateNames({ "Aldor", "Brenna", "Caelis", "Davor" }, 4, 4, 9, 99)
        for i, n in ipairs(names) do
            local y = 166 + (i - 1) * 18
            local c = clamp255(80 + i * 34)
            img:drawRect(248, y, 132, 12, 36, 40, 52, 255)
            for j = 1, #n do
                local ch = string.byte(n, j) or 65
                local h = 4 + (ch % 7)
                local x = 252 + (j - 1) * 12
                img:drawRect(x, y + 6 - h, 8, h, c, 200, 240, 255)
            end
        end

        save_png(img, OUT .. "procgen_wfc_lsystem_names.png")
    end)
end)

-- @describe Evidence: lurek.procgen sampled data exports
describe("Evidence: lurek.procgen sampled data exports", function()
    before_each(function()
        ensure_evidence_dir("procgen")
    end)
    -- Does: Runs "procgen_perlin_grid.json -- direct perlin grid samples" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.procgen.perlin2d without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/procgen/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from lurek.procgen.perlin2d; export helpers are just the container.

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
    -- Does: Runs "procgen_simplex_grid.json -- direct simplex grid samples" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.procgen.simplex2d without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/procgen/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from lurek.procgen.simplex2d; export helpers are just the container.

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
    -- Does: Runs "procgen_seeded_noise_grid.json -- seeded perlin generator samples" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.procgen.newNoiseGenerator and LNoiseGenerator:perlin2d without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/procgen/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from lurek.procgen.newNoiseGenerator and LNoiseGenerator:perlin2d; export helpers are just the container.

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
    -- Does: Runs "procgen_cellular_cave_map.png -- cave map plus statistics report" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.procgen.cellularAutomata without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/procgen/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from lurek.procgen.cellularAutomata; export helpers are just the container.

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
    -- Does: Runs "procgen_cellular_dense_map.png -- dense cave variation" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.procgen.cellularAutomata without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/procgen/procgen_cellular_dense_map.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.procgen.cellularAutomata; export helpers are just the container.

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
    -- Does: Runs "procgen_noise_heightmap_colored.png -- octave noise terrain palette" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.procgen.newNoiseGenerator and lurek.procgen.simplexNoise without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/procgen/<artifact>
    -- Why: This is meaningful only if the visible/text output comes from lurek.procgen.newNoiseGenerator and lurek.procgen.simplexNoise; export helpers are just the container.

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
    -- Does: Assembles previously generated procgen artifacts into one sheet for fast visual review.
    -- Shows: The contact sheet should let the reader compare the main procgen visual outputs without opening each file separately.
    -- Artifact: tests/artifacts/current/procgen/procgen_contact_sheet.png
    -- Why: This is meaningful because it summarizes multiple procgen artifact types in one durable review surface.

    it("PNG: procgen contact sheet", function()
        local files = {
            "procgen_cellular_flood.png",
            "procgen_poisson_voronoi.png",
            "procgen_height_worldgraph.png",
            "procgen_wfc_lsystem_names.png",
        }
        local canvas = lurek.image.newImageData(620, 452)
        canvas:fill(12, 14, 20, 255)
        local positions = {
            { 16, 16 }, { 318, 16 }, { 16, 234 }, { 318, 234 },
        }
        for i, name in ipairs(files) do
            local src = lurek.image.newImageData(OUT .. name)
            local thumb = src:resize(286, 202, "bilinear")
            local x, y = positions[i][1], positions[i][2]
            canvas:paste(thumb, x, y)
            draw_outline(canvas, x, y, 286, 202, 232, 236, 244, 255)
        end
        save_png(canvas, OUT .. "procgen_contact_sheet.png")
    end)
    -- Does: Runs "procgen extended API trace" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.procgen.lsystem, lurek.procgen.generateName, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/procgen/procgen_extended_api_trace.txt
    -- Why: This is meaningful only if the visible/text output comes from lurek.procgen.lsystem, lurek.procgen.generateName, and related owner calls; export helpers are just the container.

    it("TXT: procgen extended API trace", function()
        local lsys = lurek.procgen.lsystem({ axiom = "F", rules = { F = "F+F-F" }, iterations = 2 })
        local name = lurek.procgen.generateName({ "Kara", "Rune", "Zenith" }, 3, 8, 7)
        local biome = lurek.procgen.newBiomeClassifier()
        local br, bg, bb = lurek.procgen.biomeColor("forest")
        local prefabs = {
            { name = "altar", width = 3, height = 3 },
            { name = "vault", width = 4, height = 4 },
        }
        local bsp = lurek.procgen.bspDungeonWithPrefabs({ width = 24, height = 18, seed = 4 }, prefabs)
        local rooms = lurek.procgen.roomsDungeonWithPrefabs({ width = 24, height = 18, seed = 5 }, prefabs)
        local cell = lurek.procgen.newCellular(16, 16, { fill = 0.45, seed = 11 })
        local cell_map = lurek.procgen.cellularAutomata(16, 16, { fill = 0.45, seed = 11 })
        local hm = lurek.procgen.heightmapFromCellular(16, 16, cell_map)
        local noise_seeded = lurek.procgen.noiseMapParallelSeeded(16, 16, { seed = 21, scale_x = 0.08, scale_y = 0.08 })
        local noise_gen = lurek.procgen.newNoiseGenerator(9)
        local lines = {
            "lsystem_len=" .. tostring(#lsys),
            "name=" .. tostring(name),
            "biome_classifier=" .. tostring(biome ~= nil),
            string.format("forest_color=%.3f,%.3f,%.3f", br or 0, bg or 0, bb or 0),
            "bsp_prefab_rooms=" .. tostring(#(bsp.rooms or {})),
            "rooms_prefab_width=" .. tostring(rooms.width or 0),
            "heightmap_from_cellular=" .. tostring(hm ~= nil),
            "noise_seeded_len=" .. tostring(#noise_seeded),
            "fbm=" .. tostring(lurek.procgen.fbm(0.25, 0.5, 9, 4, 2.0, 0.5)),
            "perlin2d=" .. tostring(lurek.procgen.perlin2d(0.1, 0.2, 9)),
            "perlin3d=" .. tostring(lurek.procgen.perlin3d(0.1, 0.2, 0.3, 11)),
            "perlin4d=" .. tostring(lurek.procgen.perlin4d(0.1, 0.2, 0.3, 0.4, 17)),
            "simplex_noise=" .. tostring(lurek.procgen.simplexNoise(0.15, 0.35)),
            "noise_generator=" .. tostring(noise_gen ~= nil),
        }
        write_text(OUT .. "procgen_extended_api_trace.txt", table.concat(lines, "\n") .. "\n")
    end)
end)
test_summary()
