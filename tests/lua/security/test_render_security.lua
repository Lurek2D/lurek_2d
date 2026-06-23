-- test_render.lua
-- Canonical file. Merged from multiple sources.

-- Lurek2D Security Test: API Fuzz / Nil Spam
-- Tests that core APIs handle nil, wrong types, and edge cases gracefully

-- Typed-any locals used to pass intentionally wrong values without triggering LuaLS.
local NIL = nil ---@type any
local BAD_STR_A = "hello" ---@type any
local BAD_STR_B = "world" ---@type any
local BAD_STR_DT = "not_a_number" ---@type any
local BAD_STR_LOUD = "loud" ---@type any
local BAD_TABLE = { a = 1 } ---@type any

local function new_universe()
    return lurek.ecs.newUniverse()
end

local function new_fsm()
    return lurek.ai.newStateMachine()
end

local function with_physics_world(fn)
    local world_id = lurek.physics.newWorld(0, 100)
    local ok, err = pcall(fn, world_id)
    lurek.physics.destroyWorld(world_id)
    if not ok then
        error(err, 0)
    end
end

local function step_world_once(world_id, dt)
    lurek.physics.step(world_id, dt)
end

local function new_dataframe_with_column(name, default_value, row)
    local df = lurek.dataframe.newDataFrame()
    df:addColumn(name, default_value)
    if row then
        df:addRow(row)
    end
    return df
end

local function new_graph_with_single_node()
    local g = lurek.graph.newGraph()
    local n1 = g:addNode("processor", 100)
    return g, n1
end

local function new_dynamic_body(world_id)
    return lurek.physics.newBody(world_id, 0, 0, "dynamic")
end

local function destroyed_world_id()
    local world_id = lurek.physics.newWorld(0, 100)
    lurek.physics.destroyWorld(world_id)
    return world_id
end

local function new_dataframe_with_real_column()
    return new_dataframe_with_column("real", 0)
end

local function new_graph()
    return lurek.graph.newGraph()
end

local function new_basic_tilemap()
    local map = lurek.tilemap.newTileMap(32, 32, 16)
    local ts = lurek.tilemap.newTileSet(1, 16, 4, 32, 32, 0, 0)
    map:addTileSet(ts)
    map:addLayer("ground", 10, 10)
    return map
end

-- @describe fuzz: nil arguments to core APIs
describe("fuzz: nil arguments to core APIs", function()
    -- @security lurek.render.setColor
    it("lurek.render.setColor handles nil gracefully", function()
        expect_error(function()
            lurek.render.setColor(NIL, NIL, NIL)
        end)
    end)

    -- @security lurek.render.rectangle
    it("lurek.render.rectangle handles nil gracefully", function()
        expect_error(function()
            lurek.render.rectangle(NIL, NIL, NIL, NIL, NIL)
        end)
    end)

    -- @security lurek.render.circle
    it("lurek.render.circle handles nil gracefully", function()
        expect_error(function()
            lurek.render.circle(NIL, NIL, NIL, NIL)
        end)
    end)

    -- @security lurek.render.line
    it("lurek.render.line with nil args is silently ignored", function()
        -- Should not error; nil coords are filtered out and draw call is skipped.
        lurek.render.line(NIL, NIL, NIL, NIL)
    end)
end)

-- @describe fuzz: wrong types to physics
describe("fuzz: wrong types to physics", function()
    -- @security lurek.physics.newWorld
    it("lurek.physics.newWorld rejects string gravity", function()
        expect_error(function()
            lurek.physics.newWorld(BAD_STR_A, BAD_STR_B)
        end)
    end)

    -- @security lurek.physics.newBody
    it("lurek.physics.newBody validates world and unusual inputs without crashing", function()
        expect_error(function()
            lurek.physics.newBody(NIL, 0, 0, "dynamic")
        end)

        with_physics_world(function(world_id)
            expect_error(function()
                local invalid_bt = "invalid_type"
                lurek.physics.newBody(world_id, 0, 0, invalid_bt)
            end)
            expect_error(function()
                lurek.physics.newBody(world_id, 0/0, 0/0, "dynamic")
            end, "NaN position should be rejected")
        end)
    end)

    -- @security lurek.physics.step
    it("lurek.physics.step validates world and dt boundaries", function()
        expect_error(function()
            lurek.physics.step(NIL, 0.016)
        end)

        with_physics_world(function(world_id)
            expect_error(function()
                lurek.physics.step(world_id, BAD_STR_DT)
            end)
            expect_error(function()
                lurek.physics.step(world_id, -1.0)
            end, "negative dt should be rejected")
        end)
    end)
end)

-- @describe fuzz: wrong types to entity system
describe("fuzz: wrong types to entity system", function()
    -- @security LUniverse:get
    it("universe:get with nil entity id", function()
        local universe = new_universe()
        expect_error(function()
            universe:get(NIL, "key")
        end)
    end)
end)

-- @describe fuzz: wrong types to data module
describe("fuzz: wrong types to data module", function()
    -- @security lurek.binary.encode
    it("lurek.binary.encode rejects nil format", function()
        expect_error(function()
            lurek.binary.encode(NIL, BAD_TABLE)
        end)
    end)

    -- @security lurek.binary.decode
    it("lurek.binary.decode rejects invalid format and payload", function()
        expect_error(function()
            lurek.binary.decode(NIL, "{}")
        end)
        expect_error(function()
            lurek.binary.decode("json", "{{{{not json!!!")
        end)
    end)

    -- @security lurek.binary.compress
    it("lurek.binary.compress rejects nil", function()
        expect_error(function()
            lurek.binary.compress("deflate", NIL)
        end)
    end)

    -- @security lurek.binary.decompress
    it("lurek.binary.decompress rejects garbage", function()
        expect_error(function()
            lurek.binary.decompress("deflate", "not compressed data at all!!")
        end)
    end)
end)

-- @describe fuzz: wrong types to AI module
describe("fuzz: wrong types to AI module", function()
    -- @security LStateMachine:addState
    it("fsm:addState with nil name", function()
        local fsm = new_fsm()
        expect_error(function()
            fsm:addState(NIL, { onUpdate = function() end })
        end)
    end)

    -- @security LStateMachine:forceState
    it("fsm:forceState with non-existent state does not error", function()
        local fsm = new_fsm()
        fsm:addState("idle", { onUpdate = function() end })
        -- forceState does not validate the name against registered states
        expect_no_error(function()
            fsm:forceState("nonexistent_state_xyz")
        end)
    end)
end)

-- @describe fuzz: wrong types to math module
describe("fuzz: wrong types to math module", function()
    -- @security lurek.math.Vec2
    it("Vec2 validates invalid and extreme numeric inputs", function()
        expect_error(function()
            lurek.math.Vec2(BAD_STR_A, BAD_STR_B)
        end)
        expect_no_error(function()
            lurek.math.Vec2(1/0, 0)
        end)
    end)

    -- @security lurek.math.sin
    it("sin rejects nil", function()
        expect_error(function()
            lurek.math.sin(NIL)
        end)
    end)

    -- @security lurek.math.lerp
    it("lerp rejects nil", function()
        expect_error(function()
            lurek.math.lerp(NIL, NIL, NIL)
        end)
    end)
end)

-- @describe fuzz: wrong types to audio module
describe("fuzz: wrong types to audio module", function()
    -- @security lurek.audio.setMasterVolume
    it("setMasterVolume rejects invalid scalar inputs", function()
        expect_error(function()
            lurek.audio.setMasterVolume(BAD_STR_LOUD)
        end)
        expect_error(function()
            lurek.audio.setMasterVolume(NIL)
        end)
    end)
end)

-- @describe fuzz: edge case numbers
describe("fuzz: edge case numbers", function()
    -- @security lurek.math.cos
    it("cos handles extreme magnitudes without crashing", function()
        expect_no_error(function()
            lurek.math.cos(1e15)
            lurek.math.cos(1e-15)
        end)
    end)

    -- @security lurek.math.sqrt
    it("math handles negative zero", function()
        expect_no_error(function()
            lurek.math.sqrt(0.0)
        end)
    end)

end)



-- ================================================================
-- Merged from: test_fuzz_boundary.lua
-- ================================================================

-- Lurek2D Fuzz Tests (Sandbox Boundary)

-- ================================================================
-- Merged from: test_invalid_args.lua
-- ================================================================

-- Lurek2D Validation Test: Invalid API Arguments
-- Tests that API functions handle bad inputs without crashing

-- @describe validation: physics invalid args
describe("validation: physics invalid args", function()
    -- @security lurek.physics.setBodyVelocity
    it("handles huge velocity without crash", function()
        with_physics_world(function(world_id)
            local body = new_dynamic_body(world_id)
            expect_no_error(function()
                lurek.physics.setBodyVelocity(world_id, body, 1e10, 1e10)
                step_world_once(world_id, 0.016)
            end, "huge velocity should not crash")
        end)
    end)

    -- @security lurek.physics.destroyWorld
    it("handles destroyed world gracefully", function()
        local world_id = destroyed_world_id()
        expect_no_error(function()
            step_world_once(world_id, 0.016)
        end, "step on destroyed world should not crash")
    end)
end)

-- @describe validation: compute invalid args
describe("validation: compute invalid args", function()
    -- @security lurek.compute.zeros
    it("zeros validates dimensions and dtype boundaries", function()
        expect_error(function()
            lurek.compute.zeros({0}, "float32")
        end, "zero dimension should error")
        expect_error(function()
            lurek.compute.zeros({-5}, "float32")
        end, "negative dimension should error")
        expect_error(function()
            lurek.compute.zeros({10}, "invalid_type")
        end, "invalid dtype should error")
        local arr = lurek.compute.zeros({2, 3, 4, 5}, "float32")
        expect_not_nil(arr)
    end)
end)

-- @describe validation: dataframe invalid ops
describe("validation: dataframe invalid ops", function()
    -- @security LDataFrame:removeColumn
    it("rejects removing nonexistent column", function()
        local df = new_dataframe_with_real_column()
        expect_error(function()
            df:removeColumn("nonexistent")
        end, "remove nonexistent column should error")
    end)

    -- @security LDataFrame:getValue
    it("rejects out-of-range row access", function()
        local df = new_dataframe_with_column("val", 0, { val = 1 })
        expect_error(function()
            df:getValue(999, "val")
        end, "out of range row should error")
    end)

    -- @security LDataFrame:addColumn
    it("rejects duplicate column names", function()
        local df = new_dataframe_with_column("name", "")
        expect_error(function()
            df:addColumn("name", "")
        end, "duplicate column should error")
    end)
end)

-- @describe validation: graph invalid operations
describe("validation: graph invalid operations", function()
    -- @security LGraph:addEdge
    it("rejects edge with invalid node", function()
        local g, n1 = new_graph_with_single_node()
        -- Passing a number instead of node userdata should error
        local bad_node ---@type any
        bad_node = 999
        expect_error(function()
            g:addEdge(n1, bad_node)
        end, "edge to invalid node should error")
    end)

    -- @security LGraph:addNode
    it("accepts negative capacity", function()
        local g = new_graph()
        expect_no_error(function()
            g:addNode("processor", -1)
        end)
    end)
end)

-- @describe validation: entity invalid operations
describe("validation: entity invalid operations", function()
    -- @security LUniverse:kill
    it("handles nil and nonexistent entity ids in kill", function()
        local universe = new_universe()
        expect_error(function()
            universe:kill(NIL)
        end)
        expect_no_error(function()
            universe:kill(99999)
        end, "kill nonexistent should not crash")
    end)

    -- @security LUniverse:isAlive
    it("handles nil and dead entity ids in isAlive", function()
        local universe = new_universe()
        expect_error(function()
            universe:isAlive(NIL)
        end)
        local id = universe:spawn()
        universe:kill(id)
        expect_false(universe:isAlive(id), "dead entity is not alive")
    end)

    -- @security LUniverse:set
    it("handles nil and dead entity writes", function()
        local universe = new_universe()
        expect_error(function()
            universe:set(NIL, "key", "value")
        end)
        local id = universe:spawn()
        universe:kill(id)
        expect_error(function()
            universe:set(id, "comp", 42)
        end, "set on dead entity should error")
    end)
end)

-- @describe validation: image invalid operations
describe("validation: image invalid operations", function()
    -- @security lurek.image.newImageData
    it("newImageData handles invalid image sources safely", function()
        -- Engine may accept zero-size image without error
        expect_no_error(function()
            lurek.image.newImageData(0, 0)
        end, "zero size image should not crash")
        expect_error(function()
            lurek.image.newImageData("nonexistent_file.png")
        end, "nonexistent file should error")
    end)
end)

-- @describe validation: tilemap invalid operations
describe("validation: tilemap invalid operations", function()
    -- @security LTileMap:getTile
    it("handles out-of-bounds tile access", function()
        local map = new_basic_tilemap()
        -- Out of bounds should return 0 or error, not crash
        expect_no_error(function()
            local tile = map:getTile(1, 999, 999)
        end, "out of bounds tile access should not crash")
    end)
end)

-- @describe fuzz: P0 modules nil type extreme
describe("fuzz: P0 modules nil type extreme", function()
    -- @security lurek.serialize.fromJson
    it("serial.fromJson rejects hostile payloads without panic", function()
        expect_error(function()
            lurek.serialize.fromJson(string.rep("{", 2048))
        end)
    end)
end)
test_summary()
