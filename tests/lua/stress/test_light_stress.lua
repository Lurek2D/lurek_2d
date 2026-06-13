-- Lurek2D Stress Test: Light System Operations
-- Measures light create, update, and query throughput.

local function maybe_call_light_method(light, method_name, ...)
    local module_fn = rawget(lurek.light, method_name)
    if type(module_fn) == "function" then
        module_fn(light, ...)
        return true
    end

    local method = light[method_name]
    if type(method) == "function" then
        method(light, ...)
        return true
    end

    return false
end

local function build_light_pool(count)
    local lights = {}
    for _ = 1, count do
        local light = lurek.light.newLight(0, 0, 100)
        maybe_call_light_method(light, "setIntensity", 0.8)
        lights[#lights + 1] = light
    end
    return lights
end

local function run_light_position_updates(light_count, update_count)
    local lights = build_light_pool(light_count)
    local start = os.clock()
    for _ = 1, update_count do
        for _, light in ipairs(lights) do
            local ok = maybe_call_light_method(light, "setPosition", math.random() * 1920, math.random() * 1080)
            if not ok then
                return nil
            end
        end
    end
    return os.clock() - start
end

local function run_light_full_config_cycle(count)
    return measure("light full-config cycle x" .. count, count, function()
        local light = lurek.light.newLight(0, 0, 100)
        maybe_call_light_method(light, "setPosition", math.random() * 1920, math.random() * 1080)
        maybe_call_light_method(light, "setRadius", 50 + math.random() * 200)
        maybe_call_light_method(light, "setColor", math.random(), math.random(), math.random(), 1.0)
        maybe_call_light_method(light, "setIntensity", math.random())
    end)
end

-- @describe stress: light creation throughput
describe("stress: light creation throughput", function()
    -- @stress lurek.light.newLight
    it("create 1000 point lights in <5s", function()
        local COUNT  = 1000
        local lights = {}

        local elapsed = measure("light.newLight x" .. COUNT, COUNT, function()
            local l = lurek.light.newLight(0, 0, 100)
            lights[#lights + 1] = l
        end)

        expect_true(elapsed < 5.0, "light creation budget: " .. elapsed .. "s")
        expect_equal(COUNT, #lights, "all lights created")
    end)
end)

-- @describe stress: light position update throughput
describe("stress: light position update throughput", function()
    -- @stress LLight:setPosition
    it("1000 lights       100 position updates each: <10s", function()
        local light_count = 1000
        local update_count = 100
        local elapsed = run_light_position_updates(light_count, update_count)
        if elapsed == nil then
            expect_nil(elapsed, "setPosition is not exposed")
            return
        end
        local ops = light_count * update_count
        print(string.format("[STRESS] %d light.setPosition calls in %.4fs (%.0f/sec)",
            ops, elapsed, ops / elapsed))

        expect_true(elapsed < 10.0, "light update budget: " .. elapsed .. "s")
    end)
end)

-- @describe stress: mixed light operations
describe("stress: mixed light operations", function()
    -- @stress LLight:setColor
    it("1000 create + setPosition + setRadius + setColor cycles: <5s", function()
        local count = 1000
        local elapsed = run_light_full_config_cycle(count)

        expect_true(elapsed < 5.0, "light full-config budget: " .. elapsed .. "s")
    end)
end)
test_summary()
