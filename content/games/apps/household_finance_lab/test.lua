local ROOT = "content/games/apps/household_finance_lab/"

local function load_app_module(path)
    local chunk = lurek.filesystem.load(ROOT .. path)
    return chunk()
end

local Config = load_app_module("app/config.lua")
local C = Config.load(ROOT .. "app/config.toml")
local DataGeneration = load_app_module("app/data_generation.lua")
local Pipeline = load_app_module("app/data_pipeline.lua")
local Controls = load_app_module("app/ui_controls.lua")
local Tests = load_app_module("app/tests.lua")

local ctx = Tests.make_context(ROOT, C, DataGeneration, Pipeline, Controls)

describe("household_finance_lab", function()
    it("loads TOML config and generates deterministic CSV data", function()
        expect_true(Tests.check_config(ROOT, C), "config loaded through parseToml")
        local _csv, row_count, deterministic = Tests.generate_csv(C, DataGeneration)
        expect_true(deterministic, "deterministic CSV")
        expect_greater(row_count, 200, "row count")
    end)

    it("uses dataframe/database/UI public APIs and writes app report", function()
        local results = Tests.run_report(ctx)
        for _, result in ipairs(results) do
            expect_true(result.ok, result.name .. " failed: " .. tostring(result.detail))
        end
        expect_true(lurek.filesystem.exists(C.TEST_REPORT_PATH), "test report written")
    end)
end)

test_summary()
