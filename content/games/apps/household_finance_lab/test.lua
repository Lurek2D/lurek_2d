local ROOT = "content/games/apps/household_finance_lab/"

local function load_app_module(path)
    local chunk = lurek.filesystem.load(ROOT .. path)
    return chunk()
end

local C = load_app_module("app/constants.lua")
local DataGeneration = load_app_module("app/data_generation.lua")
local SQLRunner = load_app_module("app/sql_runner.lua")
local Pipeline = load_app_module("app/data_pipeline.lua")
local Analytics = load_app_module("app/analytics.lua")
local UIState = load_app_module("app/ui_state.lua")
local Controls = load_app_module("app/ui_controls.lua")
local Tests = load_app_module("app/tests.lua")

local ctx = Tests.make_context(ROOT, C, DataGeneration, SQLRunner, Pipeline, Analytics, UIState, Controls)

describe("household_finance_lab", function()
    it("generates deterministic CSV data", function()
        local _csv, row_count, deterministic = Tests.generate_csv(C, DataGeneration)
        expect_true(deterministic, "deterministic CSV")
        expect_greater(row_count, 200, "row count")
    end)

    it("parses CSV, builds SQL views, caches frames, and refreshes analytics", function()
        local results = Tests.run_report(ctx)
        for _, result in ipairs(results) do
            expect_true(result.ok, result.name .. " failed: " .. tostring(result.detail))
        end
        expect_true(lurek.filesystem.exists(C.TEST_REPORT_PATH), "test report written")
    end)
end)

test_summary()
