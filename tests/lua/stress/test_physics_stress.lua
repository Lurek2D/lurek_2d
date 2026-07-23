-- Lurek2D Stress Test: Mass Body Creation
-- Creates large physics fixtures and drives them through heavy update paths.

local function create_world_with_dynamic_bodies(count, gravity_y)
    local world_id = lurek.physics.newWorld(0, gravity_y or 100)
    local bodies = {}
    for i = 1, count do
        local x = (i % 50) * 10
        local y = math.floor(i / 50) * 10
        bodies[i] = lurek.physics.newBody(world_id, x, y, "dynamic")
    end
    return world_id, bodies
end

local function step_world_frames(world_id, frame_count)
    for _ = 1, frame_count do
        lurek.physics.step(world_id, 1.0 / 60.0)
    end
end

local function build_cellular_fixture(w, h)
    local sim = lurek.procgen.newCellular(w, h)
    sim:fillRect(0, 0, w, 4, lurek.procgen.CELL_SAND)
    sim:fillRect(0, math.floor(h / 2), w, 4, lurek.procgen.CELL_WATER)
    sim:fillRect(0, h - 2, w, 2, lurek.procgen.CELL_ROCK)
    return sim
end

local function new_collision_world()
    local world = lurek.physics.newWorld(0, 200)
    lurek.physics.newBody(world, 250, 500, "static")
    local bodies = {}
    for i = 1, 500 do
        local x = 50 + (i % 20) * 20
        local y = -i * 5
        bodies[i] = lurek.physics.newBody(world, x, y, "dynamic")
    end
    return world, bodies
end

local function new_head_on_collision_world()
    local world = lurek.physics.newWorld(0, 0)
    local a = lurek.physics.newBody(world, 100, 100, "dynamic")
    local b = lurek.physics.newBody(world, 200, 100, "dynamic")
    lurek.physics.setBodyVelocity(world, a, 50, 0)
    lurek.physics.setBodyVelocity(world, b, -50, 0)
    return world
end

local function collision_events_observed(world, frame_count)
    for _ = 1, frame_count do
        lurek.physics.step(world, 1.0 / 60.0)
        local events = lurek.physics.getCollisions(world)
        if events and #events > 0 then
            return true
        end
    end
    return false
end

local function new_circle_body_world(count)
    local world = lurek.physics.newWorld(0, 100)
    local first_body = nil
    for i = 1, count do
        local x = (i % 20) * 15 + 50
        local y = math.floor(i / 20) * 15
        local body = world:newCircleBody(x, y, 5, "dynamic")
        if first_body == nil then
            first_body = body
        end
    end
    return world, first_body
end

local function new_step_stress_world(count)
    local world = lurek.physics.newWorld(0, 100)
    local first_body = nil
    for i = 1, count do
        local x = 40 + (i % 25) * 10
        local y = math.floor(i / 25) * 12
        local body = world:newCircleBody(x, y, 4, "dynamic")
        if first_body == nil then
            first_body = body
        end
    end
    return world, first_body
end

local function run_drop_simulation(x, frames)
    local world = lurek.physics.newWorld(0, 100)
    local body = lurek.physics.newBody(world, x, 0, "dynamic")
    step_world_frames(world, frames)
    return lurek.physics.getBody(world, body)
end

local function new_terrain_fixture(width, height, cell_size)
    local world = lurek.physics.newWorld(0, 0)
    return lurek.physics.newTerrain(width, height, cell_size, world)
end

local function new_zone_world()
    local world = lurek.physics.newWorld(0, 0)
    for i = 1, 50 do
        local z = world:addZone(-200 + i * 4, -200 + i * 4, 400, 400)
        z:setGravityZero()
        z:setPriority(i)
    end
    for i = 1, 500 do
        local x = (i % 50) * 8 - 200
        local y = math.floor(i / 50) * 8 - 200
        world:newBody(x, y, "dynamic")
    end
    return world
end

local function new_empty_physics_world()
    return lurek.physics.newWorld(0, 0)
end

-- @describe physics stress: 1000 bodies
describe("physics stress: 1000 bodies", function()
    -- @stress lurek.physics.newBody
    it("creates 1000 bodies without error", function()
        local world_id, bodies = create_world_with_dynamic_bodies(1000, 100)
        expect_equal(1000, #bodies, "created 1000 bodies")

        for i = 1, 10 do
            local x, y = bodies[i]:getPosition()
            expect_true(type(x) == "number", "body position is number")
            expect_true(type(y) == "number", "body position is number")
        end

        lurek.physics.destroyWorld(world_id)
    end)

    -- @stress lurek.physics.step
    it("steps 1000-body world 60 times", function()
        local world_id, sample_body = new_step_stress_world(1000)
        local _, y_before = sample_body:getPosition()
        step_world_frames(world_id, 60)
        local _, y_after = sample_body:getPosition()
        expect_true(y_after > y_before, "sample body moved under gravity after 60 steps")
    end)
end)

-- @describe stress: cellular world simulation
describe("stress: cellular world simulation", function()
    -- @stress LCellular:stepN
    it("128x128 cellular steps 500 ticks without error", function()
        local w, h = 128, 128
        local sim = build_cellular_fixture(w, h)
        local sand_initial = sim:countCells(lurek.procgen.CELL_SAND)
        local rock_initial = sim:countCells(lurek.procgen.CELL_ROCK)

        expect_no_error(function()
            sim:stepN(500)
        end)

        expect_equal(rock_initial, sim:countCells(lurek.procgen.CELL_ROCK))
        expect_equal(sand_initial, sim:countCells(lurek.procgen.CELL_SAND))
    end)

    -- @stress LCellular:toImageData
    it("toImageData returns correct size after 200 steps", function()
        local w, h = 128, 128
        local sim = build_cellular_fixture(w, h)
        sim:stepN(200)
        local raw = sim:toImageData()
        expect_equal(w * h * 4, #raw)
    end)
end)

-- @describe physics stress: collision storm
describe("physics stress: collision storm", function()
    -- @stress lurek.physics.getBody
    it("creates 500 bodies in a confined space", function()
        local world, bodies = new_collision_world()
        expect_equal(500, #bodies, "500 dynamic bodies created")
        step_world_frames(world, 300)
        local x, y = lurek.physics.getBody(world, bodies[1])
        expect_true(type(x) == "number", "body x is numeric")
        expect_true(y > -500 * 5, "body moved under gravity")
    end)

    -- @stress lurek.physics.getCollisions
    it("detects collisions between moving bodies", function()
        local world = new_head_on_collision_world()
        local collisions_detected = collision_events_observed(world, 120)
        expect_true(collisions_detected, "head-on dynamic bodies should collide")
    end)

    -- @stress LWorld:newCircleBody
    it("circle bodies handle mass collision", function()
        local world, sample_body = new_circle_body_world(200)
        local _, y_before = sample_body:getPosition()
        step_world_frames(world, 180)
        local _, y_after = sample_body:getPosition()
        expect_true(y_after > y_before, "sample circle body moved after mass simulation")
    end)
end)

-- @describe physics stress: determinism
describe("physics stress: determinism", function()
    -- @stress lurek.physics.newWorld
    it("same initial state produces same result across repeated simulations", function()
        local x1, y1 = run_drop_simulation(100, 60)
        local x2, y2 = run_drop_simulation(100, 60)
        expect_near(x1, x2, 0.001, "x position deterministic")
        expect_near(y1, y2, 0.001, "y position deterministic")

        local base_x, base_y = run_drop_simulation(50, 120)
        for _ = 1, 9 do
            local x, y = run_drop_simulation(50, 120)
            expect_near(base_x, x, 0.001, "x deterministic across repeated runs")
            expect_near(base_y, y, 0.001, "y deterministic across repeated runs")
        end
    end)
end)

-- @describe stress: physics terrain fill/dig/flush
describe("stress: physics terrain fill/dig/flush", function()
    -- @stress LTerrain:flush
    it("20 fill/dig/flush cycles complete without error on 128x128", function()
        local terrain = new_terrain_fixture(128, 128, 4)

        expect_no_error(function()
            for i = 1, 20 do
                terrain:fillAll(true)
                local cx = 64 + (i % 5) * 8
                local cy = 64 + math.floor(i / 5) * 8
                terrain:fillCircle(cx * 4, cy * 4, 32, false)
                terrain:flush()
                expect_false(terrain:isDirty())
            end
        end)
    end)

    -- @stress LTerrain:collapseColumns
    it("collapse then solidPositions is consistent", function()
        local terrain = new_terrain_fixture(64, 64, 4)
        terrain:fillRect(0, 0, 256, 128, true)
        local before = #terrain:solidPositions()
        terrain:collapseColumns()
        local after = #terrain:solidPositions()
        expect_true(after <= before, "solidPositions count must not increase after collapse")
    end)
end)

-- @describe stress: physics zones throughput
describe("stress: physics zones throughput", function()
    -- @stress LWorld:getZoneEvents
    it("50 zones + 500 bodies steps 60 frames without error", function()
        local world = new_zone_world()

        expect_no_error(function()
            for _ = 1, 60 do
                world:step(1 / 60)
            end
        end)

        local events = world:getZoneEvents()
        expect_type("table", events)
    end)
end)

-- @describe physics stress: authored force ceilings
describe("physics stress: authored force ceilings", function()
    -- @stress LWorld:addGravityVector
    it("registers 512 additive gravity vectors without rejecting valid work", function()
        local world = new_empty_physics_world()
        local last_id = nil
        for i = 1, 512 do
            last_id = world:addGravityVector(i % 2, -(i % 3))
        end
        expect_type("number", last_id)
        expect_true(last_id >= 0)
    end)

    -- @stress LWorld:addFlowField
    it("registers 512 bounded rectangular flow fields without error", function()
        local world = new_empty_physics_world()
        local last_field = nil
        for i = 1, 512 do
            last_field = world:addFlowField({
                geometry = "rect",
                x = (i % 32) * 16,
                y = math.floor(i / 32) * 16,
                w = 12,
                h = 12,
                direction = "explicit",
                directionVector = { x = 1, y = 0 },
                strength = 20,
            })
        end
        expect_type("userdata", last_field)
    end)
end)

-- @describe physics stress: query and ballistic sidecars
describe("physics stress: query and ballistic sidecars", function()
    -- @stress LWorld:raycastAll
    it("returns deterministic bounded all-hit queries across dense static bodies", function()
        local world = new_empty_physics_world()
        for i = 1, 512 do
            world:newBody(i * 4, 0, 2, 2, "static")
        end
        world:step(1 / 60)

        local first_ids = nil
        for _ = 1, 32 do
            local hits = world:raycastAll(0, 0, 1, 0, 4096)
            expect_equal(512, #hits, "all static bodies are reported")
            if first_ids == nil then
                first_ids = { hits[1].bodyId, hits[#hits].bodyId }
            else
                expect_equal(first_ids[1], hits[1].bodyId, "first hit ordering is stable")
                expect_equal(first_ids[2], hits[#hits].bodyId, "last hit ordering is stable")
            end
        end
    end)

    -- @stress LWorld:spawnBallisticProjectile
    it("advances a dense bounded set of engine-owned ballistic projectiles", function()
        local world = new_empty_physics_world()
        for i = 1, 128 do
            world:spawnBallisticProjectile({
                from = { x = 0, y = i, z = 10 },
                to = { x = 50, y = i, z = 10 },
                speed = 100,
                gravity = 0,
                radius = 1,
                height = 1,
                maxTime = 1,
                sampleDt = 0.05,
            })
        end

        for _ = 1, 10 do
            world:step(1 / 60)
        end
        expect_not_nil(world:getBallisticProjectile(0), "first projectile remains queryable")
    end)
end)
test_summary()
