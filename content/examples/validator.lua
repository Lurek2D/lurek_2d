-- ==========================================================================
-- Lurek2D Example: Validator
-- ==========================================================================
-- Demonstrates content validation engine for game assets, Lua scripts,
-- and mod compliance with built-in and custom rules.
--
-- Topics: validation engine, rules, reports, pattern rules, TOML rules.
-- ==========================================================================

-- Quick validation (simplest usage)
--@api-stub: lurek.validator.newEngine
do
    local eng = lurek.validator.newEngine("content/examples")
    print("lurek.validator.newEngine type=" .. eng:type())
    print("rule count=" .. eng:ruleCount())
end

--@api-stub: lurek.validator.validate
do
    local report = lurek.validator.validate("content/examples")
    print("lurek.validator.validate files_checked=" .. report.files_checked)
    print("is_clean=" .. tostring(report.is_clean))
end

--@api-stub: lurek.validator.validateFile
do
    local report = lurek.validator.validateFile("content/examples/math.lua")
    print("lurek.validator.validateFile files_checked=" .. report.files_checked)
    print("errors=" .. report.error_count)
end

--@api-stub: LValidationEngine:addAssetRule
do
    local eng = lurek.validator.newEngine("content/examples")
    eng:addAssetRule("assets")
    print("LValidationEngine:addAssetRule rules=" .. eng:ruleCount())
end

--@api-stub: LValidationEngine:addImportRule
do
    local eng = lurek.validator.newEngine("content/examples")
    eng:addImportRule({ "content/examples", "library" })
    print("LValidationEngine:addImportRule rules=" .. eng:ruleCount())
end

--@api-stub: LValidationEngine:addApiRule
do
    local eng = lurek.validator.newEngine("content/examples")
    eng:addApiRule()
    print("LValidationEngine:addApiRule rules=" .. eng:ruleCount())
end

--@api-stub: LValidationEngine:addPatternRule
do
    local eng = lurek.validator.newEngine("content/examples")
    eng:addPatternRule("no_print", "print\\(", "Use lurek.log instead of print()", "warning")
    print("LValidationEngine:addPatternRule rules=" .. eng:ruleCount())
end

--@api-stub: LValidationEngine:addRequiredRule
do
    local eng = lurek.validator.newEngine("content/examples")
    eng:addRequiredRule("must_use_lurek", "lurek\\.", "Expected at least one lurek.* call")
    print("LValidationEngine:addRequiredRule rules=" .. eng:ruleCount())
end

--@api-stub: LValidationEngine:loadTomlRules
do
    local eng = lurek.validator.newEngine("content/examples")
    eng:loadTomlRules("docs/templates/validator_rules.toml")
    print("LValidationEngine:loadTomlRules rules=" .. eng:ruleCount())
end

--@api-stub: LValidationEngine:run
do
    local eng = lurek.validator.newEngine("content/examples")
    eng:addApiRule()
    local report = eng:run()
    print("LValidationEngine:run files_checked=" .. report.files_checked)
    print("violations=" .. #report.violations)
end

--@api-stub: LValidationEngine:runFile
do
    local eng = lurek.validator.newEngine("content/examples")
    eng:addApiRule()
    local report = eng:runFile("content/examples/math.lua")
    print("LValidationEngine:runFile files_checked=" .. report.files_checked)
    print("violations=" .. #report.violations)
end

--@api-stub: LValidationEngine:ruleCount
do
    local eng = lurek.validator.newEngine("content/examples")
    eng:addApiRule()
    eng:addAssetRule("assets")
    print("LValidationEngine:ruleCount=" .. eng:ruleCount())
end
