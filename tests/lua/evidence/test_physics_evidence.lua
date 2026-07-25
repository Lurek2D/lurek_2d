-- test_physics_evidence.lua
-- Canonical evidence file for lurek.physics visual outputs.
-- @covers lurek.image.newImageData
-- @covers lurek.image.saveGIF
-- @covers lurek.image.savePNG
-- @covers lurek.physics.attachShape
-- @covers lurek.physics.destroyWorld
-- @covers lurek.physics.getBody
-- @covers lurek.physics.getCollisions
-- @covers lurek.physics.isSleepingAllowed
-- @covers lurek.physics.newBody
-- @covers lurek.physics.newCircleShape
-- @covers lurek.physics.newRectangleShape
-- @covers lurek.physics.newTerrain
-- @covers lurek.physics.newWorld
-- @covers lurek.physics.setBodyVelocity
-- @covers lurek.physics.setSleepingAllowed
-- @covers lurek.physics.step
-- @covers lurek.physics.testAABB
-- @covers lurek.physics.testCircleAABB
-- @covers lurek.physics.testCircles
-- @covers lurek.physics.testPoint



local OUT = evidence_output_dir("physics")

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function save_gif(frames, path, options)
    lurek.image.saveGIF(frames, path, options or { delayMs = 120, speed = 20 })
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

local function clamp255(v)
    if v < 0 then return 0 end
    if v > 255 then return 255 end
    return math.floor(v)
end

local function draw_circle(img, cx, cy, radius, r, g, b, a)
    img:drawCircle(cx, cy, radius, r, g, b, a or 255)
    if radius > 2 then
        img:drawCircle(cx, cy, math.max(1, radius - 3), clamp255(r + 26), clamp255(g + 22), clamp255(b + 12), a or 255)
    end
end

local function draw_box(img, x, y, size, r, g, b, a)
    local half = size / 2
    img:drawRect(x - half, y - half, size, size, r, g, b, a or 255)
    img:drawRect(x - half + 2, y - half + 2, size - 4, size - 4, clamp255(r + 24), clamp255(g + 18), clamp255(b + 10), a or 255)
end

local function draw_body_dot(img, world, body, r, g, b)
    local x, y = lurek.physics.getBody(world, body)
    if not x or not y then
        return
    end
    local ix = math.floor(x + 0.5)
    local iy = math.floor(y + 0.5)
    for dy = -3, 3 do
        for dx = -3, 3 do
            local px = ix + dx
            local py = iy + dy
            if px >= 0 and py >= 0 and px < 320 and py < 200 then
                img:setPixel(px, py, r, g, b, 255)
            end
        end
    end
end

local function new_board(title, w, h)
    local img = lurek.image.newImageData(w or 420, h or 260)
    img:fill(14, 17, 24, 255)
    img:drawRect(14, 14, (w or 420) - 28, 34, 30, 36, 50, 255)
    draw_text(img, title, 26, 26, 1, 235, 241, 247)
    return img
end

local function draw_ground_scene(img)
    img:fill(16, 20, 28, 255)
    img:drawRect(0, 0, 320, 120, 22, 28, 40, 255)
    img:drawRect(0, 120, 320, 80, 28, 30, 36, 255)
    img:drawRect(20, 174, 280, 16, 180, 182, 188, 255)
    img:drawRect(20, 190, 280, 6, 92, 96, 108, 255)
end

local function render_drop_scene(ball_trace, box_trace, ball_now, box_now)
    local img = lurek.image.newImageData(320, 200)
    draw_ground_scene(img)

    if ball_trace then
        for i = 2, #ball_trace do
            local a = ball_trace[i - 1]
            local b = ball_trace[i]
            img:drawLine(a.x, a.y, b.x, b.y, 224, 184, 74, 120)
        end
    end
    if box_trace then
        for i = 2, #box_trace do
            local a = box_trace[i - 1]
            local b = box_trace[i]
            img:drawLine(a.x, a.y, b.x, b.y, 86, 188, 246, 120)
        end
    end

    if ball_now then
        draw_circle(img, ball_now.x, ball_now.y, 10, 255, 198, 62)
        img:drawCircle(ball_now.x + 3, ball_now.y - 3, 2, 255, 246, 190, 255)
    end
    if box_now then
        draw_box(img, box_now.x, box_now.y, 18, 74, 196, 255)
        img:drawLine(box_now.x - 7, box_now.y - 7, box_now.x + 7, box_now.y + 7, 210, 244, 255, 255)
    end

    return img
end

-- @describe Evidence: lurek.physics visual scenarios
describe("Evidence: lurek.physics visual scenarios", function()
    before_each(function()
        ensure_evidence_dir("physics")
    end)
    -- Does: Runs "physics_gravity_drop.png -- dynamic bodies falling onto static ground" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.physics.step, lurek.physics.newWorld, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/physics/physics_gravity_drop.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.physics.step, lurek.physics.newWorld, and related owner calls; export helpers are just the container.

    it("PNG: physics_gravity_drop.png -- dynamic bodies falling onto static ground", function()
        local world = lurek.physics.newWorld(0, 90)
        local ground = lurek.physics.newBody(world, 160, 182, "static")
        lurek.physics.attachShape(ground, lurek.physics.newRectangleShape(280, 16))

        local ball = lurek.physics.newBody(world, 110, 24, "dynamic")
        lurek.physics.attachShape(ball, lurek.physics.newCircleShape(10))

        local box = lurek.physics.newBody(world, 200, 28, "dynamic")
        lurek.physics.attachShape(box, lurek.physics.newRectangleShape(18, 18))

        local ball_trace = {}
        local box_trace = {}
        for _ = 1, 120 do
            lurek.physics.step(world, 1 / 120)
            local ball_x, ball_y = lurek.physics.getBody(world, ball)
            local box_x, box_y = lurek.physics.getBody(world, box)
            if #ball_trace < 18 and (#ball_trace == 0 or _ % 8 == 0) then
                ball_trace[#ball_trace + 1] = { x = ball_x, y = ball_y }
            end
            if #box_trace < 18 and (#box_trace == 0 or _ % 8 == 0) then
                box_trace[#box_trace + 1] = { x = box_x, y = box_y }
            end
        end

        local ball_x, ball_y = lurek.physics.getBody(world, ball)
        local box_x, box_y = lurek.physics.getBody(world, box)
        local img = render_drop_scene(
            ball_trace,
            box_trace,
            { x = ball_x, y = ball_y },
            { x = box_x, y = box_y }
        )

        local path = OUT .. "physics_gravity_drop.png"
        save_png(img, path)
        lurek.physics.destroyWorld(world)
    end)
    -- Does: Runs "falling body motion over five seconds" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.physics.newWorld, lurek.physics.step, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/physics/physics_gravity_drop_timeline_5s.gif
    -- Why: This is meaningful only if the visible/text output comes from lurek.physics.newWorld, lurek.physics.step, and related owner calls; export helpers are just the container.

    it("GIF: falling body motion over five seconds", function()
        local world = lurek.physics.newWorld(0, 90)
        local ground = lurek.physics.newBody(world, 160, 182, "static")
        lurek.physics.attachShape(ground, lurek.physics.newRectangleShape(280, 16))

        local ball = lurek.physics.newBody(world, 120, 24, "dynamic")
        lurek.physics.attachShape(ball, lurek.physics.newCircleShape(10))

        local box = lurek.physics.newBody(world, 212, 28, "dynamic")
        lurek.physics.attachShape(box, lurek.physics.newRectangleShape(18, 18))

        local frames = {}
        for frame_index = 1, 13 do
            local ball_trace = {}
            local box_trace = {}
            for _ = 1, 48 do
                lurek.physics.step(world, 1 / 120)
                if _ % 8 == 0 then
                    local ball_x, ball_y = lurek.physics.getBody(world, ball)
                    local box_x, box_y = lurek.physics.getBody(world, box)
                    ball_trace[#ball_trace + 1] = { x = ball_x, y = ball_y }
                    box_trace[#box_trace + 1] = { x = box_x, y = box_y }
                end
            end

            local ball_x, ball_y = lurek.physics.getBody(world, ball)
            local box_x, box_y = lurek.physics.getBody(world, box)
            frames[frame_index] = render_drop_scene(
                ball_trace,
                box_trace,
                { x = ball_x, y = ball_y },
                { x = box_x, y = box_y }
            )
        end

        local path = OUT .. "physics_gravity_drop_timeline_5s.gif"
        lurek.image.saveGIF(frames, path, { delayMs = 400, speed = 10 })
        expect_evidence_created(path)
        lurek.physics.destroyWorld(world)
    end)
    -- Does: Runs "physics_velocity_tracks.png -- velocity vectors sampled over time" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.physics.setBodyVelocity and lurek.physics.getBody without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/physics/physics_velocity_tracks.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.physics.setBodyVelocity and lurek.physics.getBody; export helpers are just the container.

    it("PNG: physics_velocity_tracks.png -- velocity vectors sampled over time", function()
        local world = lurek.physics.newWorld(0, 0)
        local body = lurek.physics.newBody(world, 36, 44, "dynamic")
        lurek.physics.attachShape(body, lurek.physics.newRectangleShape(14, 14))
        lurek.physics.setBodyVelocity(world, body, 70, 25)

        local points = {}
        for i = 1, 80 do
            lurek.physics.step(world, 1 / 120)
            if i % 8 == 0 then
                local x, y, vx, vy = lurek.physics.getBody(world, body)
                points[#points + 1] = { x = x, y = y, vx = vx, vy = vy }
            end
        end

        local img = lurek.image.newImageData(320, 200)
        img:fill(20, 20, 28, 255)
        for i = 2, #points do
            local a = points[i - 1]
            local b = points[i]
            img:drawLine(a.x, a.y, b.x, b.y, 160, 180, 255, 255)
        end
        for _, p in ipairs(points) do
            img:drawRect(p.x - 2, p.y - 2, 4, 4, 255, 230, 120, 255)
            img:drawLine(p.x, p.y, p.x + p.vx * 0.2, p.y + p.vy * 0.2, 120, 255, 150, 255)
        end

        local path = OUT .. "physics_velocity_tracks.png"
        save_png(img, path)
        lurek.physics.destroyWorld(world)
    end)
    -- Does: Runs "physics_collision_bands.png -- collision event intensity over simulation" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.physics.getCollisions without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/physics/physics_collision_bands.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.physics.getCollisions; export helpers are just the container.

    it("PNG: physics_collision_bands.png -- collision event intensity over simulation", function()
        local world = lurek.physics.newWorld(0, 0)

        local a = lurek.physics.newBody(world, 60, 100, "dynamic")
        lurek.physics.attachShape(a, lurek.physics.newRectangleShape(16, 16))
        lurek.physics.setBodyVelocity(world, a, 48, 0)

        local b = lurek.physics.newBody(world, 260, 100, "dynamic")
        lurek.physics.attachShape(b, lurek.physics.newRectangleShape(16, 16))
        lurek.physics.setBodyVelocity(world, b, -48, 0)

        local collision_counts = {}
        for i = 1, 140 do
            lurek.physics.step(world, 1 / 120)
            local events = lurek.physics.getCollisions(world)
            collision_counts[#collision_counts + 1] = #events
        end

        local img = lurek.image.newImageData(320, 200)
        img:fill(14, 16, 24, 255)
        for i = 1, #collision_counts do
            local x = math.floor((i - 1) * 320 / #collision_counts)
            local h = math.min(90, collision_counts[i] * 16 + 2)
            img:drawRect(x, 180 - h, 2, h, 255, 120, 120, 255)
        end
        draw_body_dot(img, world, a, 250, 220, 80)
        draw_body_dot(img, world, b, 120, 220, 255)

        local path = OUT .. "physics_collision_bands.png"
        save_png(img, path)
        lurek.physics.destroyWorld(world)
    end)
    -- Does: Runs "physics_query_map.png -- AABB, circle and point query map" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.physics.testPoint, lurek.physics.testCircles, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/physics/physics_query_map.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.physics.testPoint, lurek.physics.testCircles, and related owner calls; export helpers are just the container.

    it("PNG: physics_query_map.png -- AABB, circle and point query map", function()
        local img = lurek.image.newImageData(320, 200)
        img:fill(24, 24, 28, 255)

        local ax, ay, aw, ah = 90, 50, 120, 80
        local bx, by, bw, bh = 150, 86, 80, 60
        local cx, cy, cr = 118, 110, 36

        img:drawRect(ax, ay, aw, ah, 70, 100, 220, 120)
        img:drawRect(bx, by, bw, bh, 220, 130, 80, 120)

        for y = 0, 199, 4 do
            for x = 0, 319, 4 do
                local inside_a = lurek.physics.testPoint(x, y, ax, ay, aw, ah)
                local hit_c = lurek.physics.testCircleAABB(cx, cy, cr, x, y, 3, 3)
                if inside_a then
                    img:drawRect(x, y, 3, 3, 120, 160, 255, 220)
                end
                if hit_c then
                    img:drawRect(x + 1, y + 1, 2, 2, 140, 255, 160, 220)
                end
            end
        end

        local overlap = lurek.physics.testAABB(ax, ay, aw, ah, bx, by, bw, bh)
        local circles = lurek.physics.testCircles(cx, cy, cr, 220, 90, 28)

        img:drawCircle(cx, cy, cr, 90, 230, 120, 255)
        img:drawCircle(220, 90, 28, 255, 190, 60, 255)
        img:drawRect(8, 8, overlap and 44 or 10, 8, 110, 200, 255, 255)
        img:drawRect(8, 20, circles and 44 or 10, 8, 255, 190, 100, 255)

        local path = OUT .. "physics_query_map.png"
        save_png(img, path)
    end)
    -- Does: Runs "physics_sleep_flags.png -- sleeping permission states visualized" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.physics.setSleepingAllowed and lurek.physics.isSleepingAllowed without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/physics/physics_sleep_flags.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.physics.setSleepingAllowed and lurek.physics.isSleepingAllowed; export helpers are just the container.

    it("PNG: physics_sleep_flags.png -- sleeping permission states visualized", function()
        local world = lurek.physics.newWorld(0, 20)
        local a = lurek.physics.newBody(world, 90, 80, "dynamic")
        local b = lurek.physics.newBody(world, 230, 80, "dynamic")
        lurek.physics.attachShape(a, lurek.physics.newRectangleShape(20, 20))
        lurek.physics.attachShape(b, lurek.physics.newRectangleShape(20, 20))

        lurek.physics.setSleepingAllowed(world, a, true)
        lurek.physics.setSleepingAllowed(world, b, false)

        for _ = 1, 90 do
            lurek.physics.step(world, 1 / 120)
        end

        local allow_a = lurek.physics.isSleepingAllowed(world, a)
        local allow_b = lurek.physics.isSleepingAllowed(world, b)

        local img = lurek.image.newImageData(320, 200)
        img:fill(16, 20, 26, 255)
        draw_body_dot(img, world, a, 255, 205, 100)
        draw_body_dot(img, world, b, 120, 200, 255)
        img:drawRect(40, 20, allow_a and 70 or 14, 10, 240, 170, 90, 255)
        img:drawRect(180, 20, allow_b and 70 or 14, 10, 120, 200, 255, 255)

        local path = OUT .. "physics_sleep_flags.png"
        save_png(img, path)
        lurek.physics.destroyWorld(world)
    end)
    -- Does: Runs "terrain crater occupancy raster" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.physics.newTerrain and lurek.physics.newWorld without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/physics/physics_terrain_crater_raster.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.physics.newTerrain and lurek.physics.newWorld; export helpers are just the container.

    it("PNG: terrain crater occupancy raster", function()
        local path = OUT .. "physics_terrain_crater_raster.png"
        local world = lurek.physics.newWorld(0, 0)
        local terrain = lurek.physics.newTerrain(64, 64, 4, world)

        terrain:fillAll(true)
        terrain:fillCircle(128, 128, 64, false)

        local raw = terrain:toImageData(139, 90, 43, 30, 30, 60)
        expect_equal(64 * 64 * 4, #raw)

        local img = lurek.image.newImageData(64, 64)
        img:setRawData(raw)
        save_png(img, path)
        lurek.physics.destroyWorld(world)
    end)
    -- Does: Runs "physics broadphase and ray query trace" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LWorld:queryAABB, LWorld:raycastClosest, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/physics/physics_query_trace.txt
    -- Why: This is meaningful only if the visible/text output comes from LWorld:queryAABB, LWorld:raycastClosest, and related owner calls; export helpers are just the container.

    it("TXT: physics broadphase and ray query trace", function()
        local world = lurek.physics.newWorld(0, 0)
        local a = world:newCircleBody(100, 100, 12, "static")
        local b = world:newCircleBody(180, 100, 12, "static")
        local c = world:newCircleBody(260, 100, 12, "static")
        a:setLayer(0x2)
        b:setLayer(0x2)
        c:setLayer(0x2)

        local overlap_a = world:newCircleBody(80, 150, 12, "dynamic")
        local overlap_b = world:newCircleBody(80, 150, 12, "dynamic")
        world:step(1 / 60)

        local aabb = world:queryAABB(70, 80, 140, 40, { layer = 0x1, mask = 0x2 })
        local closest = world:raycastClosest(40, 100, 1, 0, 280, { layer = 0x1, mask = 0x2 })
        local all = world:raycastAll(40, 100, 1, 0, 280, { layer = 0x1, mask = 0x2 })
        local at = world:getBodyAtPoint(100, 100, { layer = 0x1, mask = 0x2 })
        local contacts = world:getContacts()
        local path = OUT .. "physics_query_trace.txt"
        local lines = {
            "queryAABB_hits=" .. tostring(#aabb),
            "raycastClosest_distance=" .. tostring(closest and closest.distance or "nil"),
            "raycastAll_hits=" .. tostring(#all),
            "bodyAtPoint=" .. tostring(at),
            "contacts=" .. tostring(#contacts),
            "overlap_a=" .. tostring(overlap_a:getId()),
            "overlap_b=" .. tostring(overlap_b:getId()),
        }

        write_file(path, table.concat(lines, "\n") .. "\n")
        expect_evidence_created(path)
        lurek.physics.destroyWorld(world)
    end)
    -- Does: Runs isolated joint debug captures and turns each owner-module result into its own inspectable artifact.
    -- Shows: Each PNG should expose one joint family instead of combining revolute, distance, and wheel joints into one gallery.
    -- Artifact: tests/artifacts/current/physics/physics_joint_revolute_debug.png, physics_joint_distance_debug.png, physics_joint_wheel_debug.png
    -- Why: This is meaningful only if the visible/text output comes from the underlying joint APIs rather than a helper-built gallery.

    it("PNG: isolated joint debug captures", function()
        local function step_and_save(path, build_fn)
            local world = lurek.physics.newWorld(0, 50)
            build_fn(world)
            for _ = 1, 90 do
                world:step(1 / 120)
            end
            local img = lurek.image.newImageData(260, 220)
            img:fill(16, 18, 24, 255)
            img:drawRect(0, 182, 260, 38, 28, 32, 40, 255)
            img:drawLine(0, 182, 259, 182, 86, 92, 110, 255)
            world:drawDebug(img, 120, 226, 255, 220)
            save_png(img, path)
            lurek.physics.destroyWorld(world)
        end

        step_and_save(OUT .. "physics_joint_revolute_debug.png", function(world)
            local pivot = world:newBody(90, 28, "static")
            local pendulum = world:newCircleBody(90, 92, 14, "dynamic")
            world:addRevoluteJoint(pivot:getId(), pendulum:getId(), 90, 60)
        end)

        step_and_save(OUT .. "physics_joint_distance_debug.png", function(world)
            local left = world:newCircleBody(90, 78, 12, "dynamic")
            local right = world:newCircleBody(174, 78, 12, "dynamic")
            world:addDistanceJoint(left:getId(), right:getId(), 90, 78, 174, 78, 84)
        end)

        step_and_save(OUT .. "physics_joint_wheel_debug.png", function(world)
            local chassis = world:newBody(130, 120, "static")
            local wheel = world:newCircleBody(130, 168, 18, "dynamic")
            world:addWheelJoint(chassis:getId(), wheel:getId(), 130, 120, 0, 1)
        end)
    end)

    -- Does: Builds overlapping gravity zones with different priorities, traces dynamic body motion through them, and overlays the live debug draw.
    -- Shows: The PNG makes area-based physics rules visible: directional, point, and repulsor zones bend trajectories without being collision bodies.
    -- Artifact: tests/artifacts/current/physics/physics_zone_priority_fields.png
    -- Why: Zones are a physics-owned gameplay feature; this evidence proves LWorld:addZone and LZone gravity/priority APIs affect simulated motion.
    it("PNG: zone priority gravity fields", function()
        local world = lurek.physics.newWorld(0, 0)
        local point_zone = world:addZone(34, 82, 150, 120)
        point_zone:setGravityPoint(110, 144, 1200)
        point_zone:setPriority(4)
        local repulse_zone = world:addZone(150, 82, 148, 120)
        repulse_zone:setGravityRepulsor(224, 144, 900)
        repulse_zone:setPriority(8)
        local directional = world:addZone(92, 58, 178, 44)
        directional:setGravityDirectional(42, 16)
        directional:setPriority(12)

        local bodies = {
            world:newCircleBody(58, 120, 8, "dynamic"),
            world:newCircleBody(82, 172, 8, "dynamic"),
            world:newCircleBody(246, 120, 8, "dynamic"),
        }
        bodies[1]:setVelocity(44, 8)
        bodies[2]:setVelocity(70, -32)
        bodies[3]:setVelocity(-42, 18)

        local traces = { {}, {}, {} }
        for step = 1, 120 do
            world:step(1 / 120)
            if step % 8 == 0 then
                for i, body in ipairs(bodies) do
                    local x, y = body:getPosition()
                    traces[i][#traces[i] + 1] = { x = x, y = y }
                end
            end
        end

        local img = new_board("PHYSICS ZONE PRIORITY", 420, 260)
        img:drawRect(34, 82, 150, 120, 80, 160, 230, 48)
        img:drawRect(150, 82, 148, 120, 230, 104, 84, 48)
        img:drawRect(92, 58, 178, 44, 124, 232, 150, 48)
        draw_text(img, "POINT", 48, 90, 1, 120, 210, 255)
        draw_text(img, "REPULSE", 184, 90, 1, 255, 145, 112)
        draw_text(img, "DIRECTION", 118, 66, 1, 152, 245, 176)
        local colors = {
            { 255, 208, 92 },
            { 118, 214, 255 },
            { 190, 255, 150 },
        }
        for i, trace in ipairs(traces) do
            local c = colors[i]
            for p = 2, #trace do
                img:drawLine(trace[p - 1].x, trace[p - 1].y, trace[p].x, trace[p].y, c[1], c[2], c[3], 210)
            end
        end
        world:drawDebug(img, 210, 232, 255, 190)
        draw_text(img, "PRIORITY 4 8 12", 230, 222, 1, 235, 241, 247)
        save_png(img, OUT .. "physics_zone_priority_fields.png")
        lurek.physics.destroyWorld(world)
    end)

    -- Does: Builds additive world gravity vectors, an additive point-gravity zone with falloff limits, and a drag zone, then traces separate probe bodies.
    -- Shows: The PNG separates composed gravity and air resistance: one probe follows summed vectors, one curves toward the bounded well, and one slows inside drag.
    -- Artifact: tests/artifacts/current/physics/physics_additive_gravity_drag_fields.png
    -- Why: Additive fields and drag are gameplay physics behavior; the artifact makes the new LWorld gravity-vector APIs and LZone falloff/drag APIs visible.
    it("PNG: additive gravity vectors and drag fields", function()
        local world = lurek.physics.newWorld(0, 0)
        world:addGravityVector(28, 0)
        world:addGravityVector(0, 16)

        local well = world:addZone(70, 54, 150, 132)
        well:setGravityPoint(145, 120, 420)
        well:setGravityAdditive(true)
        well:setGravityFalloff("linear")
        well:setGravityRadius(12, 120)
        well:setGravityLimits(nil, 70)

        local drag = world:addZone(236, 62, 118, 126)
        drag:setLinearDrag(2.6)
        drag:setQuadraticDrag(0.015)

        local vector_probe = world:newCircleBody(28, 38, 6, "dynamic")
        local well_probe = world:newCircleBody(208, 176, 6, "dynamic")
        local drag_probe = world:newCircleBody(250, 96, 6, "dynamic")
        drag_probe:setVelocity(120, 0)

        local traces = { {}, {}, {} }
        local bodies = { vector_probe, well_probe, drag_probe }
        for step = 1, 150 do
            world:step(1 / 120)
            if step % 5 == 0 then
                for i, body in ipairs(bodies) do
                    local x, y = body:getPosition()
                    traces[i][#traces[i] + 1] = { x = x, y = y }
                end
            end
        end

        local img = new_board("ADDITIVE GRAVITY DRAG", 420, 250)
        img:drawRect(70, 54, 150, 132, 56, 92, 190, 70)
        img:drawCircle(145, 120, 12, 112, 184, 255, 180)
        img:drawCircle(145, 120, 120, 76, 116, 220, 90)
        img:drawRect(236, 62, 118, 126, 70, 168, 128, 80)
        img:drawLine(30, 208, 90, 208, 255, 210, 112, 230)
        img:drawLine(90, 208, 78, 202, 255, 210, 112, 230)
        img:drawLine(90, 208, 78, 214, 255, 210, 112, 230)
        img:drawLine(34, 214, 34, 236, 255, 210, 112, 230)
        local colors = {
            { 255, 210, 112 },
            { 130, 190, 255 },
            { 130, 255, 178 },
        }
        for i, trace in ipairs(traces) do
            local c = colors[i]
            for p = 2, #trace do
                img:drawLine(trace[p - 1].x, trace[p - 1].y, trace[p].x, trace[p].y, c[1], c[2], c[3], 210)
            end
        end
        draw_text(img, "SUMMED", 24, 222, 1, 255, 210, 112)
        draw_text(img, "FALLOFF WELL", 94, 222, 1, 130, 190, 255)
        draw_text(img, "DRAG", 270, 222, 1, 130, 255, 178)
        save_png(img, OUT .. "physics_additive_gravity_drag_fields.png")
        lurek.physics.destroyWorld(world)
    end)

    -- Does: Places bodies on different collision layers, then visualizes raycastClosest, raycastAll, getBodyAtPoint, and queryAABB results.
    -- Shows: The PNG separates spatial query lanes so a reviewer can see how filters include or exclude bodies from the same physics world.
    -- Artifact: tests/artifacts/current/physics/physics_raycast_filter_lanes.png
    -- Why: Query APIs are part of physics as spatial authority; this evidence shows ray/query answers tied to live bodies and layer masks.
    it("PNG: raycast filter lanes", function()
        local world = lurek.physics.newWorld(0, 0)
        local ids = {}
        for i, spec in ipairs({
            { 88, 86, 0x2 },
            { 164, 86, 0x4 },
            { 240, 86, 0x2 },
            { 164, 150, 0x8 },
        }) do
            local body = world:newCircleBody(spec[1], spec[2], 14, "static")
            body:setLayer(spec[3])
            ids[i] = body:getId()
        end
        world:step(1 / 60)

        local all = world:raycastAll(36, 86, 1, 0, 280, { layer = 0x1, mask = 0x2 })
        local closest = world:raycastClosest(36, 86, 1, 0, 280, { layer = 0x1, mask = 0x4 })
        local point = world:getBodyAtPoint(164, 150, { layer = 0x1, mask = 0x8 })
        local aabb = world:queryAABB(58, 58, 220, 56, { layer = 0x1, mask = 0x2 })
        expect_true(#all >= 2)
        expect_true(closest ~= nil)
        expect_true(point ~= nil)
        expect_true(#aabb >= 2)

        local img = new_board("PHYSICS QUERY FILTERS", 420, 240)
        img:drawLine(36, 86, 316, 86, 255, 220, 112, 255)
        img:drawRect(58, 58, 220, 56, 96, 160, 255, 50)
        img:drawLine(164, 124, 164, 176, 152, 255, 170, 220)
        world:drawDebug(img, 120, 210, 255, 220)
        for _, hit in ipairs(all) do
            img:drawCircle(hit.x, hit.y, 5, 255, 220, 112, 255)
        end
        if closest then
            img:drawCircle(closest.x, closest.y, 7, 255, 126, 126, 255)
        end
        draw_text(img, "MASK 2 HITS " .. tostring(#all), 30, 194, 1, 255, 220, 112)
        draw_text(img, "MASK 4 CLOSEST " .. tostring(closest and closest.bodyId or 0), 30, 212, 1, 255, 126, 126)
        draw_text(img, "POINT " .. tostring(point or 0), 238, 194, 1, 152, 255, 170)
        draw_text(img, "AABB " .. tostring(#aabb), 238, 212, 1, 130, 190, 255)
        save_png(img, OUT .. "physics_raycast_filter_lanes.png")
        lurek.physics.destroyWorld(world)
    end)

    -- Does: Edits a terrain grid, flushes it into the world, collapses unsupported columns, and spawns debris from solid cells.
    -- Shows: The PNG combines the terrain raster, carved crater, debris spawn positions, and live debug bodies from the same terrain state.
    -- Artifact: tests/artifacts/current/physics/physics_terrain_debris_crater.png
    -- Why: Destructible terrain is physics-owned because terrain edits become colliders and debris bodies inside the same world.
    it("PNG: destructible terrain debris crater", function()
        local world = lurek.physics.newWorld(0, 80)
        local terrain = lurek.physics.newTerrain(48, 28, 5, world)
        terrain:fillAll(false)
        terrain:fillRect(20, 70, 200, 54, true)
        terrain:fillCircle(114, 82, 34, false)
        terrain:flush()
        local solids = terrain:solidPositions()
        local debris_specs = {}
        for i = 1, math.min(#solids, 12) do
            debris_specs[i] = { x = solids[i].x * 5 + 2, y = solids[i].y * 5 + 2 }
        end
        local debris = terrain:spawnDebris(debris_specs, 1.0, 0.35)
        for _ = 1, 80 do
            world:step(1 / 120)
        end

        local raw = terrain:toImageData(150, 96, 52, 18, 20, 32)
        local raster = lurek.image.newImageData(48, 28)
        raster:setRawData(raw)
        local img = new_board("PHYSICS TERRAIN DEBRIS", 420, 250)
        img:paste(raster:resize(288, 168, "bilinear"), 24, 58)
        for _, p in ipairs(debris_specs) do
            img:drawCircle(24 + p.x * 6 / 5, 58 + p.y * 6 / 5, 3, 255, 210, 112, 255)
        end
        world:drawDebug(img, 92, 210, 255, 160)
        draw_text(img, "SOLIDS " .. tostring(#solids), 324, 78, 1, 235, 241, 247)
        draw_text(img, "DEBRIS " .. tostring(#debris), 324, 102, 1, 255, 210, 112)
        save_png(img, OUT .. "physics_terrain_debris_crater.png")
        lurek.physics.destroyWorld(world)
    end)

    -- Does: Runs a falling actor through a one-way platform and a sensor fixture, recording contact and overlap state as an animation.
    -- Shows: The GIF distinguishes blocking platform behavior from sensor-only detection while both remain in one physics world.
    -- Artifact: tests/artifacts/current/physics/physics_one_way_sensor_timeline.gif
    -- Why: One-way platforms and sensors are high-value gameplay physics semantics; motion evidence is clearer as one GIF than as separate stills.
    it("GIF: one-way platform and sensor timeline", function()
        local world = lurek.physics.newWorld(0, 150)
        local platform = world:newBody(160, 152, "static")
        world:addFixture(platform:getId(), "rectangle", 1.0, 0.8, 0.0, false, 260, 12)
        world:setBodyOneWay(platform:getId(), 0, -1)

        local sensor = world:newBody(160, 96, "static")
        world:addFixture(sensor:getId(), "circle", 1.0, 0.0, 0.0, true, 34)

        local actor = world:newCircleBody(118, 24, 10, "dynamic")
        actor:setVelocity(42, 0)
        local frames = {}
        for frame = 1, 12 do
            for _ = 1, 18 do
                world:step(1 / 120)
            end
            local img = new_board("ONE WAY SENSOR", 320, 210)
            img:drawRect(30, 90, 260, 12, 60, 120, 220, 70)
            img:drawCircle(160, 96, 34, 120, 255, 170, 64)
            world:drawDebug(img, 120, 210, 255, 220)
            img:drawRect(14, 14, 292, 34, 30, 36, 50, 255)
            draw_text(img, "ONE WAY SENSOR", 26, 26, 1, 235, 241, 247)
            local contacts = world:getBodyContacts(actor:getId())
            img:drawRect(238, 60, math.min(60, #contacts * 18 + 4), 9, 255, 132, 112, 255)
            draw_text(img, "CONTACTS " .. tostring(#contacts), 178, 176, 1, 255, 132, 112)
            draw_text(img, "FRAME " .. tostring(frame), 28, 176, 1, 235, 241, 247)
            frames[frame] = img
        end
        save_gif(frames, OUT .. "physics_one_way_sensor_timeline.gif", { delayMs = 120, speed = 20 })
        lurek.physics.destroyWorld(world)
    end)

    -- Does: Drives a mouse joint target across a scene containing a prismatic slider and rope-limited payload, then records the mechanism over time.
    -- Shows: The GIF makes coupled constraints inspectable: the mouse joint target moves, the slider stays on axis, and the rope limits separation.
    -- Artifact: tests/artifacts/current/physics/physics_constraint_mouse_slider.gif
    -- Why: Constraints are a distinct physics responsibility; an animated artifact proves joints remain connected through solver steps.
    it("GIF: constraint mouse slider timeline", function()
        local world = lurek.physics.newWorld(0, 60)
        local rail = world:newBody(80, 82, "static")
        local slider = world:newCircleBody(118, 82, 12, "dynamic")
        local payload = world:newCircleBody(206, 126, 13, "dynamic")
        local mouse = world:addMouseJoint(slider:getId(), 118, 82, 650)
        local prism = world:addPrismaticJoint(rail:getId(), slider:getId(), 80, 82, 1, 0)
        world:setJointLimits(prism, -42, 88)
        world:setJointLimitsEnabled(prism, true)
        local rope = world:addRopeJoint(slider:getId(), payload:getId(), 118, 82, 206, 126, 96)
        world:setJointBreakForce(rope, 500)

        local frames = {}
        for frame = 1, 14 do
            local target_x = 94 + frame * 12
            world:setMouseJointTarget(mouse, target_x, 82)
            for _ = 1, 16 do
                world:step(1 / 120)
            end
            local img = new_board("CONSTRAINT SOLVER", 340, 220)
            img:drawLine(76, 82, 246, 82, 96, 110, 140, 255)
            img:drawCircle(target_x, 82, 5, 255, 210, 112, 255)
            world:drawDebug(img, 130, 220, 255, 220)
            img:drawRect(14, 14, 312, 34, 30, 36, 50, 255)
            draw_text(img, "CONSTRAINT SOLVER", 26, 26, 1, 235, 241, 247)
            draw_text(img, "MOUSE", 24, 174, 1, 255, 210, 112)
            draw_text(img, "PRISMATIC", 102, 174, 1, 130, 220, 255)
            local break_force = world:hasJoint(rope) and world:getJointBreakForce(rope) or 0
            draw_text(img, "ROPE " .. tostring(math.floor(break_force)), 222, 174, 1, 170, 255, 160)
            frames[frame] = img
        end
        save_gif(frames, OUT .. "physics_constraint_mouse_slider.gif", { delayMs = 100, speed = 20 })
        lurek.physics.destroyWorld(world)
    end)
end)
test_summary()
