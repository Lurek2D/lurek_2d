-- Lurek2D Validator API Tests
-- Covers lurek.validator module: engine, rules, reports, and validation.

-- =========================================================================
-- Module existence
-- =========================================================================

-- @describe lurek.validator module exists
describe("lurek.validator module exists", function()
    -- @covers lurek.validator
    it("lurek.validator is a table", function()
        expect_type("table", lurek.validator)
    end)

    -- @covers lurek.validator.newEngine
    -- @covers lurek.validator.validate
    -- @covers lurek.validator.validateFile
    it("exposes factory and quick functions", function()
        expect_type("function", lurek.validator.newEngine)
        expect_type("function", lurek.validator.validate)
        expect_type("function", lurek.validator.validateFile)
    end)
end)

-- =========================================================================
-- ValidationEngine
-- =========================================================================

-- @describe ValidationEngine
describe("ValidationEngine", function()
    -- @covers lurek.validator.newEngine
    it("newEngine creates engine with root path", function()
        local engine = lurek.validator.newEngine("content/examples")
        expect_type("userdata", engine)
    end)

    -- @covers lurek.validator.newEngine
    it("ruleCount starts at zero", function()
        local engine = lurek.validator.newEngine("content/examples")
        assert_equal(0, engine:ruleCount())
    end)

    -- @covers lurek.validator.newEngine
    it("addAssetRule increases rule count", function()
        local engine = lurek.validator.newEngine("content/examples")
        engine:addAssetRule("assets")
        assert_equal(1, engine:ruleCount())
    end)

    -- @covers lurek.validator.newEngine
    it("addImportRule adds require resolution", function()
        local engine = lurek.validator.newEngine("content/examples")
        engine:addImportRule({ "content/examples", "library" })
        assert_equal(1, engine:ruleCount())
    end)

    -- @covers lurek.validator.newEngine
    it("addApiRule adds API compliance", function()
        local engine = lurek.validator.newEngine("content/examples")
        engine:addApiRule()
        assert_equal(1, engine:ruleCount())
    end)

    -- @covers lurek.validator.newEngine
    it("addPatternRule adds custom pattern", function()
        local engine = lurek.validator.newEngine("content/examples")
        engine:addPatternRule("no-print", "print%(", "Use lurek.log instead", "warning")
        assert_equal(1, engine:ruleCount())
    end)

    -- @covers lurek.validator.newEngine
    it("addRequiredRule adds required pattern", function()
        local engine = lurek.validator.newEngine("content/examples")
        engine:addRequiredRule("has-license", "-- License:", "Missing license header")
        assert_equal(1, engine:ruleCount())
    end)

    -- @covers lurek.validator.newEngine
    it("multiple rules accumulate", function()
        local engine = lurek.validator.newEngine("content/examples")
        engine:addAssetRule("assets")
        engine:addApiRule()
        engine:addPatternRule("no-print", "print%(", "Use lurek.log", "warning")
        assert_equal(3, engine:ruleCount())
    end)
end)

-- =========================================================================
-- Run validation
-- =========================================================================

-- @describe Running validation
describe("Running validation", function()
    -- @covers lurek.validator.newEngine
    it("run returns report table", function()
        local engine = lurek.validator.newEngine("content/examples")
        engine:addPatternRule("no-os-exit", "os.exit", "Avoid os.exit", "warning")
        local report = engine:run()
        expect_type("table", report)
        expect_type("number", report.files_checked)
        expect_type("number", report.duration_ms)
        expect_type("number", report.error_count)
        expect_type("number", report.warning_count)
        expect_type("boolean", report.is_clean)
        expect_type("table", report.violations)
    end)

    -- @covers lurek.validator.newEngine
    it("runFile validates single file", function()
        local engine = lurek.validator.newEngine("content/examples")
        engine:addPatternRule("has-local", "local", "Found local", "hint")
        local report = engine:runFile("content/examples/sprite.lua")
        expect_type("table", report)
        assert_equal(1, report.files_checked)
    end)
end)

-- =========================================================================
-- Report structure
-- =========================================================================

-- @describe Report violation structure
describe("Report violation structure", function()
    -- @covers lurek.validator.newEngine
    it("violations have expected fields", function()
        local engine = lurek.validator.newEngine("content/examples")
        engine:addPatternRule("no-print", "print%(", "Use lurek.log", "warning")
        local report = engine:run()
        if #report.violations > 0 then
            local v = report.violations[1]
            expect_type("string", v.rule)
            expect_type("string", v.severity)
            expect_type("string", v.file)
            expect_type("number", v.line)
            expect_type("string", v.message)
        end
        assert_true(true)
    end)
end)

-- =========================================================================
-- Quick functions
-- =========================================================================

-- @describe Quick validation functions
describe("Quick validation functions", function()
    -- @covers lurek.validator.validate
    it("validate returns report for directory", function()
        local report = lurek.validator.validate("content/examples")
        expect_type("table", report)
        expect_type("number", report.files_checked)
        expect_type("boolean", report.is_clean)
    end)

    -- @covers lurek.validator.validateFile
    it("validateFile returns report for single file", function()
        local report = lurek.validator.validateFile("content/examples/sprite.lua")
        expect_type("table", report)
        assert_equal(1, report.files_checked)
    end)
end)

-- =========================================================================
-- ValidationEngine loadTomlRules
-- =========================================================================

-- @describe ValidationEngine loadTomlRules
describe("ValidationEngine loadTomlRules", function()
    -- @covers LValidationEngine:loadTomlRules
    it("loadTomlRules accepts a path without crash", function()
        local engine = lurek.validator.newEngine("content/examples")
        engine:loadTomlRules("content/nonexistent_rules.toml")
        assert_true(true)
    end)
end)

-- =========================================================================
-- ValidationEngine:run
-- =========================================================================

-- @describe ValidationEngine:run
describe("ValidationEngine:run", function()
    -- @covers LValidationEngine:run
    it("run returns a report table with required fields", function()
        local engine = lurek.validator.newEngine("content/examples")
        engine:addPatternRule("no-os", "os%.exit", "Avoid os.exit", "warning")
        local report = engine:run()
        expect_type("table", report)
        expect_type("number", report.files_checked)
        expect_type("number", report.error_count)
        expect_type("number", report.warning_count)
        expect_type("boolean", report.is_clean)
        expect_type("table", report.violations)
    end)
end)

test_summary()
