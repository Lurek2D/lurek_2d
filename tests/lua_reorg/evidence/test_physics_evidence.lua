-- test_physics_evidence.lua
-- Canonical evidence file for lurek.physics visual outputs.



local OUT = evidence_output_dir("physics")

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
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

    -- @evidence lurek.image.savePNG
    -- @evidence lurek.physics.step
    -- @evidence lurek.physics.newWorld
    -- @evidence lurek.physics.newRectangleShape
    -- @evidence lurek.physics.newCircleShape
    -- @evidence lurek.physics.newBody
    -- @evidence lurek.physics.attachShape
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

    -- @evidence lurek.physics.newWorld
    -- @evidence lurek.physics.step
    -- @evidence lurek.physics.getBody
    -- @evidence lurek.image.saveGIF
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

    -- @evidence lurek.image.savePNG
    -- @evidence lurek.physics.setBodyVelocity
    -- @evidence lurek.physics.getBody
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

    -- @evidence lurek.image.savePNG
    -- @evidence lurek.physics.getCollisions
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

    -- @evidence lurek.image.savePNG
    -- @evidence lurek.physics.testPoint
    -- @evidence lurek.physics.testCircles
    -- @evidence lurek.physics.testCircleAABB
    -- @evidence lurek.physics.testAABB
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

    -- @evidence lurek.image.savePNG
    -- @evidence lurek.physics.setSleepingAllowed
    -- @evidence lurek.physics.isSleepingAllowed
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

    -- @evidence lurek.physics.newTerrain
    -- @evidence lurek.physics.newWorld
    -- @evidence lurek.image.savePNG
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

    -- @evidence LWorld:queryAABB
    -- @evidence LWorld:raycastClosest
    -- @evidence LWorld:raycastAll
    -- @evidence LWorld:getBodyAtPoint
    -- @evidence LWorld:getContacts
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

    -- @evidence LWorld:addRevoluteJoint
    -- @evidence LWorld:addDistanceJoint
    -- @evidence LWorld:addWheelJoint
    -- @evidence LWorld:jointCount
    -- @evidence LWorld:drawDebug
    -- @evidence lurek.image.savePNG
    it("PNG: physics joint gallery debug view", function()
        local world = lurek.physics.newWorld(0, 50)

        local pivot = world:newBody(90, 28, "static")
        local pendulum = world:newCircleBody(90, 92, 14, "dynamic")
        world:addRevoluteJoint(pivot:getId(), pendulum:getId(), 90, 60)

        local left = world:newCircleBody(220, 78, 12, "dynamic")
        local right = world:newCircleBody(304, 78, 12, "dynamic")
        world:addDistanceJoint(left:getId(), right:getId(), 220, 78, 304, 78, 84)

        local chassis = world:newBody(470, 120, "static")
        local wheel = world:newCircleBody(470, 168, 18, "dynamic")
        world:addWheelJoint(chassis:getId(), wheel:getId(), 470, 120, 0, 1)

        for _ = 1, 90 do
            world:step(1 / 120)
        end

        local img = lurek.image.newImageData(640, 240)
        img:fill(16, 18, 24, 255)
        img:drawRect(0, 182, 640, 58, 28, 32, 40, 255)
        img:drawLine(0, 182, 639, 182, 86, 92, 110, 255)
        world:drawDebug(img, 120, 226, 255, 220)

        local path = OUT .. "physics_joint_gallery_debug.png"
        expect_true(world:jointCount() >= 3)
        save_png(img, path)
        lurek.physics.destroyWorld(world)
    end)
end)
test_summary()
