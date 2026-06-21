local DEMO_PATH = "content/games/hex_logistics/main.lua"

local function load_demo(seed)
    assert(type(dofile) == "function", "dofile helper must be available in the Lua test VM")
    HEX_LOGISTICS_TEST_SEED = seed or 41
    dofile(DEMO_PATH)
    lurek.init()
    lurek.process(0.016)
end

local function debug_state()
    return hex_logistics_debug()
end

local function screen_from_hex(q, r, state)
    local wx, wy = lurek.tilemap.toScreenHex(q, r, 34)
    return wx - state.camera.x, wy - state.camera.y
end

local function run_for(seconds, dt)
    local elapsed = 0
    while elapsed < seconds do
        lurek.process(dt)
        elapsed = elapsed + dt
    end
end

describe("hex_logistics demo", function()
    it("responds to automated keyboard and mouse input through the normal engine path", function()
        load_demo(41)

        lurek.automation.load("hex_logistics_playable", {
            steps = {
                { action = "keypress", key = "1", scancode = "1", time = 0.0 },
                { action = "keyrelease", key = "1", scancode = "1", time = 0.01 },
            }
        })
        lurek.automation.start("hex_logistics_playable")

        run_for(2.4, 0.05)

        local mid = debug_state()
        expect_true(lurek.automation.isComplete())
        expect_not_nil(mid.hq)
        expect_equal("ACTIVE", mid.hq.state)
        expect_equal(3, mid.drone_count)
        expect_not_nil(mid.nearby_empty_hex)

        local target = mid.nearby_empty_hex
        local sx, sy = screen_from_hex(target.q, target.r, mid)
        lurek.wheelmoved(0, 1)
        lurek.wheelmoved(0, 1)
        lurek.wheelmoved(0, 1)

        local after_wheel = debug_state()
        expect_equal("GENERATOR", after_wheel.active_build)

        lurek.mousemoved(sx, sy, 0, 0)
        lurek.mousepressed(sx, sy, 1)
        local after_build = debug_state()
        expect_true(after_build.building_count >= 2)
        expect_not_nil(after_build.selected_building)
        expect_equal("GENERATOR", after_build.selected_building.type)
        lurek.mousepressed(sx, sy, 2)
        run_for(0.8, 0.05)

        local state = debug_state()
        expect_true(math.abs(state.player.x) > 1 or math.abs(state.player.y) > 1)
    end)
end)

test_summary()
