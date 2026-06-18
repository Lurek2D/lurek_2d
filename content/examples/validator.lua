-- ==========================================================================
-- Lurek2D Example: Validator
-- ==========================================================================
-- Demonstrates content validation engine for game assets, Lua scripts,
-- and mod compliance with built-in and custom rules.
--
-- Topics: validation engine, rules, reports, pattern rules, TOML rules.
-- ==========================================================================

-- Quick validation (simplest usage)
local function example_print_log(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    lurek.log.info(table.concat(parts, " "))
end

--@api: lurek.validator.newEngine
do
    local eng = lurek.validator.newEngine("content/examples")
    local before = eng:ruleCount()
    eng:addApiRule()
    example_print_log("lurek.validator.newEngine type=" .. type(eng))
    example_print_log("rule count before=" .. before)
    example_print_log("rule count after=" .. eng:ruleCount())
end

--@api: lurek.validator.validate
do
    local report = lurek.validator.validate("content/examples")
    example_print_log("lurek.validator.validate files_checked=" .. report.files_checked)
    example_print_log("errors=" .. report.error_count)
    example_print_log("warnings=" .. report.warning_count)
    example_print_log("is_clean=" .. tostring(report.is_clean))
end

--@api: lurek.validator.validateFile
do
    local report = lurek.validator.validateFile("content/examples/math.lua")
    example_print_log("lurek.validator.validateFile files_checked=" .. report.files_checked)
    example_print_log("warnings=" .. report.warning_count)
    example_print_log("errors=" .. report.error_count)
    example_print_log("violations=" .. #report.violations)
end

--@api: LValidationEngine:addAssetRule
do
    local eng = lurek.validator.newEngine("content/examples")
    local before = eng:ruleCount()
    eng:addAssetRule("assets")
    eng:addApiRule()
    example_print_log("LValidationEngine:addAssetRule rules before=" .. before)
    example_print_log("LValidationEngine:addAssetRule rules after=" .. eng:ruleCount())
end

--@api: LValidationEngine:addImportRule
do
    local eng = lurek.validator.newEngine("content/examples")
    local before = eng:ruleCount()
    eng:addImportRule({ "content/examples", "library" })
    eng:addApiRule()
    example_print_log("LValidationEngine:addImportRule rules before=" .. before)
    example_print_log("LValidationEngine:addImportRule rules after=" .. eng:ruleCount())
end

--@api: LValidationEngine:addApiRule
do
    local eng = lurek.validator.newEngine("content/examples")
    local before = eng:ruleCount()
    eng:addApiRule()
    local report = eng:runFile("content/examples/math.lua")
    example_print_log("LValidationEngine:addApiRule rules before=" .. before)
    example_print_log("LValidationEngine:addApiRule rules after=" .. eng:ruleCount())
    example_print_log("runFile warnings=" .. report.warning_count)
end

--@api: LValidationEngine:addPatternRule
do
    local eng = lurek.validator.newEngine("content/examples")
    eng:addPatternRule("no_print", "print\\(", "Use lurek.log instead of print()", "warning")
    local report = eng:runFile("content/examples/math.lua")
    example_print_log("LValidationEngine:addPatternRule rules=" .. eng:ruleCount())
    example_print_log("warnings=" .. report.warning_count)
    example_print_log("violations=" .. #report.violations)
end

--@api: LValidationEngine:addRequiredRule
do
    local eng = lurek.validator.newEngine("content/examples")
    eng:addRequiredRule("must_use_lurek", "lurek\\.", "Expected at least one lurek.* call")
    local report = eng:runFile("content/examples/math.lua")
    example_print_log("LValidationEngine:addRequiredRule rules=" .. eng:ruleCount())
    example_print_log("warnings=" .. report.warning_count)
    example_print_log("violations=" .. #report.violations)
end

--@api: LValidationEngine:loadTomlRules
do
    local eng = lurek.validator.newEngine("content/examples")
    eng:loadTomlRules("docs/templates/validator_rules.toml")
    local report = eng:runFile("content/examples/math.lua")
    example_print_log("LValidationEngine:loadTomlRules rules=" .. eng:ruleCount())
    example_print_log("warnings=" .. report.warning_count)
    example_print_log("violations=" .. #report.violations)
end

--@api: LValidationEngine:run
do
    local eng = lurek.validator.newEngine("content/examples")
    eng:addApiRule()
    local report = eng:run()
    example_print_log("LValidationEngine:run files_checked=" .. report.files_checked)
    example_print_log("violations=" .. #report.violations)
end

--@api: LValidationEngine:runFile
do
    local eng = lurek.validator.newEngine("content/examples")
    eng:addApiRule()
    local report = eng:runFile("content/examples/math.lua")
    example_print_log("LValidationEngine:runFile files_checked=" .. report.files_checked)
    example_print_log("violations=" .. #report.violations)
end

--@api: LValidationEngine:ruleCount
do
    local eng = lurek.validator.newEngine("content/examples")
    eng:addApiRule()
    eng:addAssetRule("assets")
    eng:addImportRule({ "content/examples", "library" })
    example_print_log("LValidationEngine:ruleCount=" .. eng:ruleCount())
    example_print_log("has multiple rules=" .. tostring(eng:ruleCount() >= 3))
end
