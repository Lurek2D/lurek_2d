-- Lurek2D Stress Test: Savegame Collect/Restore Cycles
-- Measures serialization throughput for large game state.

local function new_save_manager()
    return lurek.save.newSaveManager()
end

local function measure_save_summary_set(count)
    local save_manager = new_save_manager()
    return measure("savegame:setSummary x" .. count, count, function()
        save_manager:setSummary(tostring(math.random()))
    end)
end

local function measure_save_summary_get(count, summary)
    local save_manager = new_save_manager()
    save_manager:setSummary(summary)

    local elapsed = measure("savegame:getSummary x" .. count, count, function()
        local _ = save_manager:getSummary()
    end)

    return elapsed, save_manager:getSummary()
end

-- @describe stress: savegame collect cycles
describe("stress: savegame collect cycles", function()
    local function __audit_stress_1()
        local COUNT = 100
        local sm    = lurek.save.newSaveManager()

        -- Register a handler that serializes 100 values
        local game_state = {}
        for i = 1, 100 do
            game_state["key_" .. i] = i * math.pi
        end

        sm:register("data", function()
            local snapshot = {}
            for k, v in pairs(game_state) do
                snapshot[k] = v
            end
            return snapshot
        end, function(data)
            if data then
                for k, v in pairs(data) do
                    game_state[k] = v
                end
            end
        end)

        local elapsed = measure("savegame:collect x" .. COUNT, COUNT, function()
            sm:collect()
        end)

        expect_true(elapsed < 10.0, "savegame collect budget: " .. elapsed .. "s")
    end

    -- @stress LSaveManager:collect
    it("100 savegame collect cycles in <10s", function()
        __audit_stress_1()
    end)

    -- @stress LSaveManager:setSummary
    it("summary set 1000 times in <5s", function()
        local count = 1000
        local elapsed = measure_save_summary_set(count)

        expect_true(elapsed < 5.0, "summary set budget: " .. elapsed .. "s")
    end)

    -- @stress LSaveManager:getSummary
    it("summary get 1000 times in <5s", function()
        local count = 1000
        local elapsed, summary = measure_save_summary_get(count, "stress-summary")
        expect_equal("stress-summary", summary, "summary remains readable after repeated access")
        expect_true(elapsed < 5.0, "summary get budget: " .. elapsed .. "s")
    end)
end)
test_summary()
