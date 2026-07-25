-- test_procgen_evidence.lua
-- Canonical evidence file for lurek.procgen data and visual outputs.
-- @covers lurek.filesystem.write
-- @covers lurek.image.newImageData
-- @covers lurek.image.saveGIF
-- @covers lurek.image.savePNG
-- @covers lurek.procgen.CELL_FIRE
-- @covers lurek.procgen.CELL_GAS
-- @covers lurek.procgen.CELL_ROCK
-- @covers lurek.procgen.CELL_SAND
-- @covers lurek.procgen.CELL_WATER
-- @covers lurek.procgen.biomeColor
-- @covers lurek.procgen.bspDungeon
-- @covers lurek.procgen.bspDungeonWithPrefabs
-- @covers lurek.procgen.cellularAutomata
-- @covers lurek.procgen.fbm
-- @covers lurek.procgen.floodFill
-- @covers lurek.procgen.generateName
-- @covers lurek.procgen.generateNames
-- @covers lurek.procgen.heightmap
-- @covers lurek.procgen.heightmapFromCellular
-- @covers lurek.procgen.lsystem
-- @covers lurek.procgen.lsystemSegments
-- @covers lurek.procgen.newBiomeClassifier
-- @covers lurek.procgen.newCellular
-- @covers lurek.procgen.newNoiseGenerator
-- @covers lurek.procgen.noiseMap
-- @covers lurek.procgen.noiseMapParallel
-- @covers lurek.procgen.noiseMapParallelSeeded
-- @covers lurek.procgen.perlin2d
-- @covers lurek.procgen.perlin3d
-- @covers lurek.procgen.perlin4d
-- @covers lurek.procgen.perlinNoise
-- @covers lurek.procgen.poissonDisk
-- @covers lurek.procgen.roomsDungeon
-- @covers lurek.procgen.roomsDungeonWithPrefabs
-- @covers lurek.procgen.simplex2d
-- @covers lurek.procgen.simplex3d
-- @covers lurek.procgen.simplexNoise
-- @covers lurek.procgen.voronoi
-- @covers lurek.procgen.wfcGenerate
-- @covers lurek.procgen.worldGraph



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

local function save_gif(frames, path)
    lurek.image.saveGIF(frames, path, { delayMs = 120, speed = 10, loop = true })
    expect_evidence_created(path)
end

local function draw_outline(img, x, y, w, h, r, g, b, a)
    img:drawLine(x, y, x + w - 1, y, r, g, b, a or 255)
    img:drawLine(x + w - 1, y, x + w - 1, y + h - 1, r, g, b, a or 255)
    img:drawLine(x + w - 1, y + h - 1, x, y + h - 1, r, g, b, a or 255)
    img:drawLine(x, y + h - 1, x, y, r, g, b, a or 255)
end

local function draw_cross(img, x, y, radius, r, g, b, a)
    img:drawLine(x - radius, y, x + radius, y, r, g, b, a or 255)
    img:drawLine(x, y - radius, x, y + radius, r, g, b, a or 255)
end

local function biome_rgba(name)
    local r, g, b, a = lurek.procgen.biomeColor(name)
    return clamp255(r or 0), clamp255(g or 0), clamp255(b or 0), clamp255(a or 255)
end

local function cell_color(v)
    if v == lurek.procgen.CELL_SAND then
        return 218, 186, 104
    elseif v == lurek.procgen.CELL_WATER then
        return 62, 126, 206
    elseif v == lurek.procgen.CELL_ROCK then
        return 84, 88, 96
    elseif v == lurek.procgen.CELL_FIRE then
        return 235, 86, 58
    elseif v == lurek.procgen.CELL_GAS then
        return 156, 120, 214
    end
    return 18, 22, 30
end

local function render_cellular_world(ca, w, h, scale)
    local img = lurek.image.newImageData(w * scale, h * scale)
    img:fill(12, 16, 22, 255)
    for y = 0, h - 1 do
        for x = 0, w - 1 do
            local r, g, b = cell_color(ca:getCell(x, y))
            img:drawRect(x * scale, y * scale, scale, scale, r, g, b, 255)
        end
    end
    return img
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
    before_each(function()
        ensure_evidence_dir("procgen")
    end)

    -- Does: Builds a climate world from height, moisture, and temperature fields, then classifies every cell through LBiomeClassifier:classifyMap.
    -- Shows: The PNG separates the source scalar fields from the final biome map colored with lurek.procgen.biomeColor.
    -- Artifact: tests/artifacts/current/procgen/procgen_climate_biome_world.png
    -- Why: This is meaningful because biome generation is a higher-level procgen workflow, not just a raw noise preview.
    it("PNG: climate biome world from classified fields", function()
        local w, h = 96, 64
        local height = lurek.procgen.heightmap({ width = w, height = h, seed = 140, octaves = 5, persistence = 0.52 })
        local moisture = lurek.procgen.noiseMapParallelSeeded(w, h, { seed = 141, scale_x = 0.055, scale_y = 0.055, octaves = 4 })
        local temperature = lurek.procgen.noiseMap(w, h, { seed = 142, scale_x = 0.045, scale_y = 0.045, octaves = 3 })
        local classifier = lurek.procgen.newBiomeClassifier({
            ocean_threshold = 0.30,
            coast_threshold = 0.38,
            mountain_threshold = 0.78,
            ice_cap_threshold = 0.92,
            cold_temperature = 0.22,
            warm_temperature = 0.62,
            dry_moisture = 0.28,
            wet_moisture = 0.66,
        })

        local moisture_norm = {}
        local temperature_norm = {}
        for i = 1, w * h do
            moisture_norm[i] = (moisture[i] or 0) * 0.5 + 0.5
            local ty = math.floor((i - 1) / w) / math.max(1, h - 1)
            temperature_norm[i] = math.max(0, math.min(1, ((temperature[i] or 0) * 0.5 + 0.5) * 0.65 + (1.0 - ty) * 0.35))
        end
        local biomes = classifier:classifyMap(w, h, height.cells, moisture_norm, temperature_norm)
        expect_equal(w * h, #biomes)

        local scale = 3
        local gap = 10
        local img = lurek.image.newImageData(w * scale * 2 + gap, h * scale * 2 + gap)
        img:fill(12, 16, 22, 255)
        local panels = {
            { 0, 0, height.cells, "height" },
            { w * scale + gap, 0, moisture_norm, "moisture" },
            { 0, h * scale + gap, temperature_norm, "temperature" },
            { w * scale + gap, h * scale + gap, biomes, "biome" },
        }
        for _, panel in ipairs(panels) do
            for y = 0, h - 1 do
                for x = 0, w - 1 do
                    local idx = y * w + x + 1
                    local r, g, b
                    if panel[4] == "biome" then
                        r, g, b = biome_rgba(panel[3][idx] or "plains")
                    else
                        local v = panel[3][idx] or 0
                        if panel[4] == "height" then
                            r, g, b = clamp255(30 + v * 210), clamp255(50 + v * 190), clamp255(80 + v * 120)
                        elseif panel[4] == "moisture" then
                            r, g, b = clamp255(34 + v * 70), clamp255(72 + v * 130), clamp255(120 + v * 120)
                        else
                            r, g, b = clamp255(64 + v * 170), clamp255(60 + v * 110), clamp255(100 - v * 70)
                        end
                    end
                    img:drawRect(panel[1] + x * scale, panel[2] + y * scale, scale, scale, r, g, b, 255)
                end
            end
            draw_outline(img, panel[1], panel[2], w * scale, h * scale, 232, 238, 246, 255)
        end
        save_png(img, OUT .. "procgen_climate_biome_world.png")
    end)

    -- Does: Generates BSP and scattered-room dungeons with prefab stamps.
    -- Shows: The PNG highlights authored prefab placements inside two different constructive dungeon algorithms.
    -- Artifact: tests/artifacts/current/procgen/procgen_prefab_dungeon_stamps.png
    -- Why: This is meaningful because procgen owns both room generation and prefab fit/stamp metadata used by dungeon authoring tools.
    it("PNG: prefab stamps in BSP and rooms dungeons", function()
        local prefabs = {
            { name = "vault", width = 4, height = 4 },
            { name = "altar", width = 3, height = 3 },
            { name = "camp", width = 5, height = 3 },
        }
        local bsp, bsp_placed = lurek.procgen.bspDungeonWithPrefabs({ width = 48, height = 34, seed = 64, min_room = 5 }, prefabs)
        local rooms, room_placed = lurek.procgen.roomsDungeonWithPrefabs({ width = 48, height = 34, seed = 65, max_rooms = 14 }, prefabs, 7)
        expect_true(#bsp.rooms > 0)
        expect_true(#rooms.rooms > 0)

        local scale = 5
        local gap = 20
        local img = lurek.image.newImageData(48 * scale * 2 + gap + 32, 34 * scale + 32)
        img:fill(12, 16, 22, 255)
        local function draw_rooms(panel_x, dungeon, placed)
            img:drawRect(panel_x, 16, 48 * scale, 34 * scale, 22, 24, 32, 255)
            for _, room in ipairs(dungeon.rooms or {}) do
                img:drawRect(panel_x + room.x * scale, 16 + room.y * scale, room.w * scale, room.h * scale, 96, 126, 112, 255)
                draw_outline(img, panel_x + room.x * scale, 16 + room.y * scale, room.w * scale, room.h * scale, 30, 34, 42, 210)
            end
            for _, c in ipairs(dungeon.corridors or {}) do
                img:drawLine(panel_x + c.x1 * scale, 16 + c.y1 * scale, panel_x + c.x2 * scale, 16 + c.y2 * scale, 198, 170, 106, 255)
            end
            for _, p in ipairs(placed or {}) do
                local color = p.name == "vault" and { 220, 110, 92 } or (p.name == "altar" and { 236, 206, 112 } or { 120, 178, 218 })
                img:drawRect(panel_x + p.x * scale, 16 + p.y * scale, p.width * scale, p.height * scale, color[1], color[2], color[3], 255)
                draw_cross(img, panel_x + math.floor((p.x + p.width * 0.5) * scale), 16 + math.floor((p.y + p.height * 0.5) * scale), 7, 248, 250, 255, 255)
            end
            draw_outline(img, panel_x, 16, 48 * scale, 34 * scale, 232, 238, 246, 255)
        end
        draw_rooms(16, bsp, bsp_placed)
        draw_rooms(16 + 48 * scale + gap, rooms, room_placed)
        save_png(img, OUT .. "procgen_prefab_dungeon_stamps.png")
    end)

    -- Does: Runs WFC with terrain-like adjacency constraints for water, shore, grass, forest, hill, and mountain tiles.
    -- Shows: The PNG makes the collapsed tile world and its local compatibility bands visible as one coherent coastline/biome map.
    -- Artifact: tests/artifacts/current/procgen/procgen_wfc_constraint_world.png
    -- Why: This is meaningful because WFC is procgen's constraint-driven authored tile generator rather than unconstrained random sampling.
    it("PNG: WFC constrained coastline world", function()
        local grid = lurek.procgen.wfcGenerate({
            width = 54,
            height = 36,
            seed = 188,
            max_attempts = 12,
            tiles = {
                { id = 0, weight = 1.4 },
                { id = 1, weight = 0.9 },
                { id = 2, weight = 1.7 },
                { id = 3, weight = 1.1 },
                { id = 4, weight = 0.7 },
                { id = 5, weight = 0.45 },
            },
            adjacencies = {
                [0] = { 0, 1 },
                [1] = { 0, 1, 2 },
                [2] = { 1, 2, 3, 4 },
                [3] = { 2, 3, 4 },
                [4] = { 2, 3, 4, 5 },
                [5] = { 4, 5 },
            },
        })
        expect_equal(54 * 36, #grid.cells)
        local scale = 8
        local img = lurek.image.newImageData(grid.width * scale, grid.height * scale)
        local palette = {
            [0] = { 32, 84, 156 },
            [1] = { 214, 198, 128 },
            [2] = { 86, 162, 94 },
            [3] = { 44, 120, 72 },
            [4] = { 128, 120, 96 },
            [5] = { 214, 218, 224 },
        }
        for y = 0, grid.height - 1 do
            for x = 0, grid.width - 1 do
                local t = grid.cells[y * grid.width + x + 1] or 0
                local c = palette[t] or { 200, 80, 120 }
                img:drawRect(x * scale, y * scale, scale, scale, c[1], c[2], c[3], 255)
                if x > 0 and (grid.cells[y * grid.width + x] or t) ~= t then
                    img:drawLine(x * scale, y * scale, x * scale, y * scale + scale - 1, 20, 24, 30, 95)
                end
                if y > 0 and (grid.cells[(y - 1) * grid.width + x + 1] or t) ~= t then
                    img:drawLine(x * scale, y * scale, x * scale + scale - 1, y * scale, 20, 24, 30, 95)
                end
            end
        end
        save_png(img, OUT .. "procgen_wfc_constraint_world.png")
    end)

    -- Does: Simulates a falling-material cellular sandbox with rock, sand, water, fire, and gas over multiple ticks.
    -- Shows: The GIF shows materials moving, flowing, burning, and rising through LCellular:stepN rather than a static cave mask.
    -- Artifact: tests/artifacts/current/procgen/procgen_cellular_material_sandbox.gif
    -- Why: This is meaningful because newCellular owns runtime procedural worlds, not only one-shot cellular automata maps.
    it("GIF: cellular material sandbox evolution", function()
        local w, h = 72, 48
        local ca = lurek.procgen.newCellular(w, h)
        ca:fillRect(0, h - 4, w, 4, lurek.procgen.CELL_ROCK)
        ca:fillRect(8, 10, 20, 5, lurek.procgen.CELL_SAND)
        ca:fillCircle(48, 14, 8, lurek.procgen.CELL_WATER)
        ca:fillRect(34, 32, 6, 4, lurek.procgen.CELL_FIRE)
        ca:fillCircle(58, 34, 5, lurek.procgen.CELL_GAS)
        local frames = {}
        for i = 1, 8 do
            frames[#frames + 1] = render_cellular_world(ca, w, h, 5)
            ca:stepN(4)
        end
        expect_true(#frames >= 8)
        save_gif(frames, OUT .. "procgen_cellular_material_sandbox.gif")
    end)

    -- Does: Combines L-system segments, Poisson disk settlement sites, and a heightmap into a generated river-valley world.
    -- Shows: The PNG overlays branching generated paths and separated settlement points on terrain derived from heightmap noise.
    -- Artifact: tests/artifacts/current/procgen/procgen_lsystem_river_settlement.png
    -- Why: This is meaningful because procgen is meant to compose constructive algorithms into usable world structure.
    it("PNG: L-system river and Poisson settlements", function()
        local W, H = 360, 240
        local img = lurek.image.newImageData(W, H)
        local hm = lurek.procgen.heightmap({ width = 90, height = 60, seed = 205, octaves = 5, persistence = 0.5 })
        for y = 0, hm.height - 1 do
            for x = 0, hm.width - 1 do
                local v = hm.cells[y * hm.width + x + 1] or 0
                local r, g, b
                if v < 0.34 then
                    r, g, b = 38, 84, 140
                elseif v < 0.44 then
                    r, g, b = 190, 178, 112
                elseif v < 0.72 then
                    r, g, b = 76, 142, 86
                else
                    r, g, b = 118, 118, 112
                end
                img:drawRect(x * 4, y * 4, 4, 4, r, g, b, 255)
            end
        end

        local segs = lurek.procgen.lsystemSegments({
            axiom = "F",
            iterations = 4,
            rules = { F = "F[+F]F[-F]F" },
        }, 22, 8.0)
        local min_x, min_y = math.huge, math.huge
        local max_x, max_y = -math.huge, -math.huge
        for _, s in ipairs(segs) do
            min_x = math.min(min_x, s.x1, s.x2)
            min_y = math.min(min_y, s.y1, s.y2)
            max_x = math.max(max_x, s.x1, s.x2)
            max_y = math.max(max_y, s.y1, s.y2)
        end
        local sx = 280 / math.max(1, max_x - min_x)
        local sy = 180 / math.max(1, max_y - min_y)
        local scale = math.min(sx, sy)
        local ox, oy = 42, 212
        for _, s in ipairs(segs) do
            local x1 = ox + math.floor((s.x1 - min_x) * scale)
            local y1 = oy - math.floor((s.y1 - min_y) * scale)
            local x2 = ox + math.floor((s.x2 - min_x) * scale)
            local y2 = oy - math.floor((s.y2 - min_y) * scale)
            img:drawLine(x1, y1, x2, y2, 54, 122, 210, 230)
            img:drawLine(x1 + 1, y1, x2 + 1, y2, 112, 196, 240, 180)
        end

        local sites = lurek.procgen.poissonDisk(W, H, 34, 30, 206)
        local placed = 0
        for _, p in ipairs(sites) do
            if placed >= 18 then
                break
            end
            local x = math.floor(p.x)
            local y = math.floor(p.y)
            if x > 24 and x < W - 24 and y > 24 and y < H - 24 then
                img:drawCircle(x, y, 5, 246, 218, 118, 255)
                img:drawCircle(x, y, 2, 82, 54, 42, 255)
                placed = placed + 1
            end
        end
        expect_true(placed >= 8)
        save_png(img, OUT .. "procgen_lsystem_river_settlement.png")
    end)

    -- Does: Generates a cellular cave and flood-fills the center-connected floor region.
    -- Shows: The PNG distinguishes solid cave walls, open floor, and the reachable component returned by floodFill.
    -- Artifact: tests/artifacts/current/procgen/procgen_cellular_flood.png
    -- Why: This is meaningful because cave playability depends on whether a generated floor mass is actually connected.

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
    -- Does: Places separated Poisson points and builds a Voronoi ownership field from those points.
    -- Shows: The PNG makes region cells, distance shading, and accepted site points visible together.
    -- Artifact: tests/artifacts/current/procgen/procgen_poisson_voronoi.png
    -- Why: This is meaningful because procedural region maps often start from sparse sites and nearest-region assignment.

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
    -- Does: Samples sequential noise, parallel noise, periodic Perlin, 2D simplex, and 3D simplex into separate previews.
    -- Shows: The PNG set lets a reviewer compare full fields against one-dimensional sampler strips without mixing algorithms in one image.
    -- Artifact: tests/artifacts/current/procgen/procgen_noise_map.png, tests/artifacts/current/procgen/procgen_noise_map_parallel.png, tests/artifacts/current/procgen/procgen_perlin_strip.png, tests/artifacts/current/procgen/procgen_simplex2d_strip.png, tests/artifacts/current/procgen/procgen_simplex3d_strip.png
    -- Why: This is meaningful because procgen exposes both map-wide generators and direct sampler APIs, and their outputs serve different authoring tasks.

    it("PNG: noise map and procedural strips", function()
        local w2, h2 = 64, 48
        local a = lurek.procgen.noiseMap(w2, h2, { seed = 77, scale_x = 0.08, scale_y = 0.08, octaves = 4 })
        local b = lurek.procgen.noiseMapParallel(w2, h2, { seed = 77, scale_x = 0.08, scale_y = 0.08, octaves = 4 })

        local noise_map = lurek.image.newImageData(w2 * 2, h2 * 2)
        local noise_parallel = lurek.image.newImageData(w2 * 2, h2 * 2)
        for y = 0, h2 - 1 do
            for x = 0, w2 - 1 do
                local idx = y * w2 + x + 1
                local av = a[idx] or 0
                local bv = b[idx] or 0
                local ac = clamp255((av * 0.5 + 0.5) * 255)
                local bc = clamp255((bv * 0.5 + 0.5) * 255)
                noise_map:drawRect(x * 2, y * 2, 2, 2, ac, ac, ac, 255)
                noise_parallel:drawRect(x * 2, y * 2, 2, 2, bc, bc, bc, 255)
            end
        end
        save_png(noise_map, OUT .. "procgen_noise_map.png")
        save_png(noise_parallel, OUT .. "procgen_noise_map_parallel.png")

        local function save_strip(path, sample_fn, base_r, base_g, base_b)
            local W = 256
            local img = lurek.image.newImageData(W, 32)
            img:fill(14, 16, 20, 255)
            for x = 0, W - 1 do
                local v = sample_fn(x)
                local c = clamp255((v * 0.5 + 0.5) * 255)
                img:drawRect(x, 6, 1, 20, base_r == "sample" and c or base_r, base_g == "sample" and c or base_g, base_b == "sample" and c or base_b, 255)
            end
            save_png(img, path)
        end

        save_strip(OUT .. "procgen_perlin_strip.png", function(x)
            return lurek.procgen.perlinNoise(x * 0.03, 0.42, 7.0, 7.0)
        end, "sample", 80, 100)
        save_strip(OUT .. "procgen_simplex2d_strip.png", function(x)
            return lurek.procgen.simplex2d(x * 0.03, 0.25)
        end, 80, "sample", 120)
        save_strip(OUT .. "procgen_simplex3d_strip.png", function(x)
            return lurek.procgen.simplex3d(x * 0.03, 0.25, 0.75)
        end, 100, 120, "sample")
    end)
    -- Does: Generates one BSP dungeon and one random-room dungeon from deterministic seeds.
    -- Shows: The PNGs show the different construction styles: recursive partition rooms versus scattered rooms and carved corridors.
    -- Artifact: tests/artifacts/current/procgen/procgen_bsp_dungeon.png, tests/artifacts/current/procgen/procgen_rooms_dungeon.png
    -- Why: This is meaningful because both dungeon APIs solve different layout problems and should remain visually distinguishable.

    it("PNG: BSP and rooms dungeons", function()
        local bsp = lurek.procgen.bspDungeon({ width = 40, height = 28, seed = 9 })
        local rooms = lurek.procgen.roomsDungeon({ width = 40, height = 28, max_rooms = 12, seed = 19 })

        local bsp_img = lurek.image.newImageData(160, 120)
        bsp_img:drawRect(0, 0, 160, 120, 24, 25, 32, 255)
        for _, r in ipairs(bsp.rooms) do
            bsp_img:drawRect(8 + r.x * 3, 8 + r.y * 3, math.max(1, r.w * 3), math.max(1, r.h * 3), 120, 190, 145, 255)
        end
        save_png(bsp_img, OUT .. "procgen_bsp_dungeon.png")

        local rooms_img = lurek.image.newImageData(160, 120)
        rooms_img:drawRect(0, 0, 160, 120, 24, 25, 32, 255)
        for y = 0, rooms.height - 1 do
            for x = 0, rooms.width - 1 do
                local idx = y * rooms.width + x + 1
                local v = rooms.grid[idx] or 0
                if v == 1 then
                    rooms_img:drawRect(8 + x * 3, 8 + y * 3, 3, 3, 180, 165, 110, 255)
                else
                    rooms_img:drawRect(8 + x * 3, 8 + y * 3, 3, 3, 52, 50, 58, 255)
                end
            end
        end
        save_png(rooms_img, OUT .. "procgen_rooms_dungeon.png")
    end)
    -- Does: Generates terrain height and overlays a connected world graph of regions and travel edges.
    -- Shows: The PNG shows procedural terrain as the background and graph-owned region nodes/edges as strategic structure on top.
    -- Artifact: tests/artifacts/current/procgen/procgen_height_worldgraph.png
    -- Why: This is meaningful because procgen owns both scalar terrain generation and high-level world connectivity data.

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
    -- Does: Builds a compact suite image from WFC tiles, L-system turtle segments, and generated name glyph bars.
    -- Shows: The PNG proves that constraint tiling, grammar expansion, and Markov-style naming all produce inspectable content from one deterministic suite.
    -- Artifact: tests/artifacts/current/procgen/procgen_wfc_lsystem_names.png
    -- Why: This is meaningful as a broad smoke artifact for mixed procedural content, while the newer focused artifacts cover each use case in more depth.

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
    -- Does: Writes a deterministic grid of direct perlin2d samples.
    -- Shows: The JSON makes exact scalar values reviewable for numeric drift, independent of color palettes.
    -- Artifact: tests/artifacts/current/procgen/procgen_perlin_grid.json
    -- Why: This is meaningful because visual noise evidence cannot reveal small sampler regressions by itself.

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
    -- Does: Writes a deterministic grid of direct simplex2d samples.
    -- Shows: The JSON exposes the scalar field values that drive the simplex strip and terrain-style artifacts.
    -- Artifact: tests/artifacts/current/procgen/procgen_simplex_grid.json
    -- Why: This is meaningful because simplex is a separate sampler family from Perlin and needs its own numeric evidence.

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
    -- Does: Writes a deterministic grid sampled through a seeded LNoiseGenerator object.
    -- Shows: The JSON proves object-owned seed state affects the generated scalar values predictably.
    -- Artifact: tests/artifacts/current/procgen/procgen_seeded_noise_grid.json
    -- Why: This is meaningful because object generators are used for reproducible worlds where a seed must travel with the sampler.

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
    -- Does: Generates a standard cellular cave and writes both its map image and wall/floor counts.
    -- Shows: The PNG shows cave texture while the stats file records the generated density.
    -- Artifact: tests/artifacts/current/procgen/procgen_cellular_cave_map.png, tests/artifacts/current/procgen/procgen_cellular_cave_map_stats.txt
    -- Why: This is meaningful because cave generation quality depends on both visible structure and aggregate density.

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
    -- Does: Generates a denser cellular cave variant with different fill and rule thresholds.
    -- Shows: The PNG contrasts a wall-heavy cave texture against the standard cave and flood-fill artifacts.
    -- Artifact: tests/artifacts/current/procgen/procgen_cellular_dense_map.png
    -- Why: This is meaningful because cellularAutomata is parameter-driven and evidence should show that rule changes visibly alter map character.

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
    -- Does: Builds an octave simplex terrain map and colors water, beach, grass, rock, and snow thresholds.
    -- Shows: The PNG turns scalar terrain into a readable game-world preview instead of a grayscale field.
    -- Artifact: tests/artifacts/current/procgen/procgen_noise_heightmap_colored.png
    -- Why: This is meaningful because terrain procgen is usually consumed as classified world regions, not raw noise.

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
    -- Does: Writes a compact text trace of broad procgen API calls that are not all naturally visual.
    -- Shows: The TXT records deterministic sizes, generated text, prefab counts, and sampler values for mixed API smoke coverage.
    -- Artifact: tests/artifacts/current/procgen/procgen_extended_api_trace.txt
    -- Why: This is meaningful as secondary evidence for nonvisual return shapes while visual artifacts cover the main world-building workflows.

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
