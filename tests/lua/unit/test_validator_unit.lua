-- Canonical unit coverage for lurek.validator.

local VALIDATOR_ROOT = "content/examples"
local VALIDATOR_FILE = "tests/fixtures/validator_subject.lua"
local TOML_RULES = "tests/fixtures/validator_rules_unit.toml"
local CUSTOM_API_ROOT = "work/validator_unit"
local CUSTOM_API_FILE = CUSTOM_API_ROOT .. "/custom_api.lua"
local CUSTOM_API_SOURCE = "game.quest.start()\ngame.missing.call()\n"

local function new_engine()
    return lurek.validator.newEngine(VALIDATOR_ROOT)
end

-- @describe lurek.validator module
describe("lurek.validator module", function()
    -- @covers lurek.validator.newEngine
    it("newEngine creates an empty validation engine", function()
        local engine = new_engine()
        expect_equal("userdata", type(engine))
        expect_equal(0, engine:ruleCount())
    end)

    -- @covers lurek.validator.validate
    it("validate accepts explicit custom API prefixes", function()
        write_file(CUSTOM_API_FILE, CUSTOM_API_SOURCE)
        local default_report = lurek.validator.validate(CUSTOM_API_ROOT)
        local report = lurek.validator.validate(CUSTOM_API_ROOT, {
            api = { "game.quest" },
        })
        expect_equal(0, default_report.warning_count)
        expect_type("table", report)
        expect_equal(1, report.files_checked)
        expect_type("number", report.duration_ms)
        expect_equal(0, report.error_count)
        expect_equal(1, report.warning_count)
        expect_equal(false, report.is_clean)
        expect_equal("api-compliance", report.violations[1].rule)
        expect_contains(report.violations[1].message, "game.missing")
    end)

    -- @covers lurek.validator.validateFile
    it("validateFile accepts explicit custom API prefixes", function()
        write_file(CUSTOM_API_FILE, CUSTOM_API_SOURCE)
        local default_report = lurek.validator.validateFile(CUSTOM_API_FILE)
        local report = lurek.validator.validateFile(CUSTOM_API_FILE, {
            api = { "game.quest" },
        })
        expect_equal(0, default_report.warning_count)
        expect_type("table", report)
        expect_equal(1, report.files_checked)
        expect_equal(1, report.warning_count)
        expect_equal("api-compliance", report.violations[1].rule)
        expect_contains(report.violations[1].message, "game.missing")
    end)
end)

-- @describe validator engine methods
describe("validator engine methods", function()
    -- @covers LValidationEngine:addAssetRule
    it("addAssetRule registers one additional rule", function()
        local engine = new_engine()
        engine:addAssetRule("content/examples/assets")
        expect_equal(1, engine:ruleCount())
    end)

    -- @covers LValidationEngine:addImportRule
    it("addImportRule registers one additional rule", function()
        local engine = new_engine()
        engine:addImportRule({ "content/examples", "library" })
        expect_equal(1, engine:ruleCount())
    end)

    -- @covers LValidationEngine:addApiRule
    it("addApiRule accepts custom API prefix lists", function()
        write_file(CUSTOM_API_FILE, CUSTOM_API_SOURCE)
        local default_engine = lurek.validator.newEngine(CUSTOM_API_ROOT)
        default_engine:addApiRule()
        local default_report = default_engine:runFile(CUSTOM_API_FILE)
        local engine = lurek.validator.newEngine(CUSTOM_API_ROOT)
        engine:addApiRule({ "game.quest" })
        local report = engine:runFile(CUSTOM_API_FILE)
        expect_equal(0, default_report.warning_count)
        expect_equal(1, engine:ruleCount())
        expect_equal(1, report.warning_count)
        expect_equal("api-compliance", report.violations[1].rule)
        expect_contains(report.violations[1].message, "game.missing")
    end)

    -- @covers LValidationEngine:addPatternRule
    it("addPatternRule emits violations for matching lines", function()
        local engine = new_engine()
        engine:addPatternRule("no-print", "print(", "Use lurek.log", "warning")
        local report = engine:runFile(VALIDATOR_FILE)
        expect_true(#report.violations > 0)
        expect_equal("no-print", report.violations[1].rule)
        expect_equal("warning", report.violations[1].severity)
    end)

    -- @covers LValidationEngine:addRequiredRule
    it("addRequiredRule emits a violation when the pattern is absent", function()
        local engine = new_engine()
        engine:addRequiredRule("need-absent-text", "this text is absent", "missing text")
        local report = engine:runFile(VALIDATOR_FILE)
        expect_equal(1, #report.violations)
        expect_equal("need-absent-text", report.violations[1].rule)
        expect_equal("warning", report.violations[1].severity)
    end)

    -- @covers LValidationEngine:loadTomlRules
    it("loadTomlRules imports pattern rules from a toml file", function()
        local engine = new_engine()
        engine:loadTomlRules(TOML_RULES)
        local report = engine:runFile(VALIDATOR_FILE)
        expect_equal(1, engine:ruleCount())
        expect_true(#report.violations > 0)
        expect_equal("toml-no-print", report.violations[1].rule)
    end)

    -- @covers LValidationEngine:run
    it("run validates every lua file under the engine root", function()
        local engine = new_engine()
        engine:addPatternRule("no-print", "print(", "Use lurek.log", "warning")
        local report = engine:run()
        expect_true(report.files_checked > 1)
        expect_true(#report.violations > 0)
        expect_equal("warning", report.violations[1].severity)
    end)

    -- @covers LValidationEngine:runFile
    it("runFile returns violations tied to the requested file", function()
        local engine = new_engine()
        engine:addPatternRule("no-print", "print(", "Use lurek.log", "warning")
        local report = engine:runFile(VALIDATOR_FILE)
        expect_equal(1, report.files_checked)
        expect_true(#report.violations > 0)
        expect_contains(report.violations[1].file, "tests/fixtures/validator_subject.lua")
    end)

    -- @covers LValidationEngine:ruleCount
    it("ruleCount reflects all loaded rules", function()
        local engine = new_engine()
        engine:addApiRule()
        engine:addPatternRule("no-print", "print(", "Use lurek.log", "warning")
        expect_equal(2, engine:ruleCount())
    end)
end)

test_summary()
