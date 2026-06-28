-- ==========================================================================
-- Lurek2D Example: Validator
-- ==========================================================================
-- Demonstrates content validation engine for game assets, Lua scripts,
-- and mod compliance with built-in and custom rules.
--
-- Topics: validation engine, rules, reports, pattern rules, TOML rules.
-- ==========================================================================

-- Quick validation (simplest usage)

--@api: lurek.validator.newEngine
do

    local eng = lurek.validator.newEngine("content/examples")
    local before = eng:ruleCount()
    eng:addApiRule()
    lurek.log.info(tostring("lurek.validator.newEngine type=" .. type(eng)))
    lurek.log.info(tostring("rule count before=" .. before))
    lurek.log.info(tostring("rule count after=" .. eng:ruleCount()))
end

--@api: lurek.validator.validate
do

    local report = lurek.validator.validate("content/examples")
    lurek.log.info(tostring("lurek.validator.validate files_checked=" .. report.files_checked))
    lurek.log.info(tostring("errors=" .. report.error_count))
    lurek.log.info(tostring("warnings=" .. report.warning_count))
    lurek.log.info(tostring("is_clean=" .. tostring(report.is_clean)))
end

--@api: lurek.validator.validateFile
do

    local report = lurek.validator.validateFile("content/examples/math.lua")
    lurek.log.info(tostring("lurek.validator.validateFile files_checked=" .. report.files_checked))
    lurek.log.info(tostring("warnings=" .. report.warning_count))
    lurek.log.info(tostring("errors=" .. report.error_count))
    lurek.log.info(tostring("violations=" .. #report.violations))
end

--@api: LValidationEngine:addAssetRule
do

    local eng = lurek.validator.newEngine("content/examples")
    local before = eng:ruleCount()
    eng:addAssetRule("assets")
    eng:addApiRule()
    lurek.log.info(tostring("LValidationEngine:addAssetRule rules before=" .. before))
    lurek.log.info(tostring("LValidationEngine:addAssetRule rules after=" .. eng:ruleCount()))
end

--@api: LValidationEngine:addImportRule
do

    local eng = lurek.validator.newEngine("content/examples")
    local before = eng:ruleCount()
    eng:addImportRule({ "content/examples", "library" })
    eng:addApiRule()
    lurek.log.info(tostring("LValidationEngine:addImportRule rules before=" .. before))
    lurek.log.info(tostring("LValidationEngine:addImportRule rules after=" .. eng:ruleCount()))
end

--@api: LValidationEngine:addApiRule
do

    local eng = lurek.validator.newEngine("content/examples")
    local before = eng:ruleCount()
    eng:addApiRule()
    local report = eng:runFile("content/examples/math.lua")
    lurek.log.info(tostring("LValidationEngine:addApiRule rules before=" .. before))
    lurek.log.info(tostring("LValidationEngine:addApiRule rules after=" .. eng:ruleCount()))
    lurek.log.info(tostring("runFile warnings=" .. report.warning_count))
end

--@api: LValidationEngine:addPatternRule
do

    local eng = lurek.validator.newEngine("content/examples")
    eng:addPatternRule("no_print", "print\\(", "Use lurek.log instead of print()", "warning")
    local report = eng:runFile("content/examples/math.lua")
    lurek.log.info(tostring("LValidationEngine:addPatternRule rules=" .. eng:ruleCount()))
    lurek.log.info(tostring("warnings=" .. report.warning_count))
    lurek.log.info(tostring("violations=" .. #report.violations))
end

--@api: LValidationEngine:addRequiredRule
do

    local eng = lurek.validator.newEngine("content/examples")
    eng:addRequiredRule("must_use_lurek", "lurek\\.", "Expected at least one lurek.* call")
    local report = eng:runFile("content/examples/math.lua")
    lurek.log.info(tostring("LValidationEngine:addRequiredRule rules=" .. eng:ruleCount()))
    lurek.log.info(tostring("warnings=" .. report.warning_count))
    lurek.log.info(tostring("violations=" .. #report.violations))
end

--@api: LValidationEngine:loadTomlRules
do

    local eng = lurek.validator.newEngine("content/examples")
    eng:loadTomlRules("docs/templates/validator_rules.toml")
    local report = eng:runFile("content/examples/math.lua")
    lurek.log.info(tostring("LValidationEngine:loadTomlRules rules=" .. eng:ruleCount()))
    lurek.log.info(tostring("warnings=" .. report.warning_count))
    lurek.log.info(tostring("violations=" .. #report.violations))
end

--@api: LValidationEngine:run
do

    local eng = lurek.validator.newEngine("content/examples")
    eng:addApiRule()
    local report = eng:run()
    lurek.log.info(tostring("LValidationEngine:run files_checked=" .. report.files_checked))
    lurek.log.info(tostring("violations=" .. #report.violations))
end

--@api: LValidationEngine:runFile
do

    local eng = lurek.validator.newEngine("content/examples")
    eng:addApiRule()
    local report = eng:runFile("content/examples/math.lua")
    lurek.log.info(tostring("LValidationEngine:runFile files_checked=" .. report.files_checked))
    lurek.log.info(tostring("violations=" .. #report.violations))
end

--@api: LValidationEngine:ruleCount
do

    local eng = lurek.validator.newEngine("content/examples")
    eng:addApiRule()
    eng:addAssetRule("assets")
    eng:addImportRule({ "content/examples", "library" })
    lurek.log.info(tostring("LValidationEngine:ruleCount=" .. eng:ruleCount()))
    lurek.log.info(tostring("has multiple rules=" .. tostring(eng:ruleCount() >= 3)))
end
