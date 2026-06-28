# Validator

## Purpose

Static validator verifying APIs, assets, and imports.

## Summary

- The `validator` module is the content-checking surface for users who want assets, imports, and API usage to be verified as a structured workflow instead of informal manual review.
- Rule types, execution policy, engine orchestration, and report structures work together so several validation checks can be run through one reusable framework.
- That matters because a project often needs to catch different classes of mistakes, such as missing assets or invalid `lurek.*` usage, before those problems become runtime failures.
- It is therefore useful for CI, local authoring passes, and package or mod checks.
- Read it as the engine's validation coordinator. Individual rules know what they are checking, but `validator` owns how those rules are configured, executed, and reported.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## API Reference

- This page is the generated API reference for this module.

## Functions

### `lurek.validator.newEngine`

Creates a new validation engine rooted at the given filesystem path.

```lua
lurek.validator.newEngine(root)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `root` | string | Root directory path for the validation engine. |

**Returns**

| Type | Description |
|------|-------------|
| [LValidationEngine](#lvalidationengine) | A new validation engine instance. |

**Example**

```lua
do

    local eng = lurek.validator.newEngine("content/examples")
    local before = eng:ruleCount()
    eng:addApiRule()
    lurek.log.info(tostring("lurek.validator.newEngine type=" .. type(eng)))
    lurek.log.info(tostring("rule count before=" .. before))
    lurek.log.info(tostring("rule count after=" .. eng:ruleCount()))
end
```

---

### `lurek.validator.validate`

Runs all validation rules against a project root directory and returns a report table.

```lua
lurek.validator.validate(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Root directory path of the project to validate. |

**Returns**

| Type | Description |
|------|-------------|
| table | Table with fields: errors (table), warnings (table), passed (boolean). |

**Example**

```lua
do

    local report = lurek.validator.validate("content/examples")
    lurek.log.info(tostring("lurek.validator.validate files_checked=" .. report.files_checked))
    lurek.log.info(tostring("errors=" .. report.error_count))
    lurek.log.info(tostring("warnings=" .. report.warning_count))
    lurek.log.info(tostring("is_clean=" .. tostring(report.is_clean)))
end
```

---

### `lurek.validator.validateFile`

Runs API validation rules against a single Lua file and returns a report table.

```lua
lurek.validator.validateFile(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Absolute or relative path to the Lua file to validate. |

**Returns**

| Type | Description |
|------|-------------|
| table | Table with fields: errors (table), warnings (table), passed (boolean). |

**Example**

```lua
do

    local report = lurek.validator.validateFile("content/examples/math.lua")
    lurek.log.info(tostring("lurek.validator.validateFile files_checked=" .. report.files_checked))
    lurek.log.info(tostring("warnings=" .. report.warning_count))
    lurek.log.info(tostring("errors=" .. report.error_count))
    lurek.log.info(tostring("violations=" .. #report.violations))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LValidationEngine](#lvalidationengine)

## LValidationEngine

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LValidationEngine:addApiRule`

Add the built-in API compliance rule.

```lua
LValidationEngine:addApiRule()
```

**Example**

```lua
do

    local eng = lurek.validator.newEngine("content/examples")
    local before = eng:ruleCount()
    eng:addApiRule()
    local report = eng:runFile("content/examples/math.lua")
    lurek.log.info(tostring("LValidationEngine:addApiRule rules before=" .. before))
    lurek.log.info(tostring("LValidationEngine:addApiRule rules after=" .. eng:ruleCount()))
    lurek.log.info(tostring("runFile warnings=" .. report.warning_count))
end
```

---

#### `LValidationEngine:addAssetRule`

Add the built-in asset existence rule.

```lua
LValidationEngine:addAssetRule(asset_root)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `asset_root` | string | Root directory for asset files. |

**Example**

```lua
do

    local eng = lurek.validator.newEngine("content/examples")
    local before = eng:ruleCount()
    eng:addAssetRule("assets")
    eng:addApiRule()
    lurek.log.info(tostring("LValidationEngine:addAssetRule rules before=" .. before))
    lurek.log.info(tostring("LValidationEngine:addAssetRule rules after=" .. eng:ruleCount()))
end
```

---

#### `LValidationEngine:addImportRule`

Add the built-in import resolution rule.

```lua
LValidationEngine:addImportRule(paths)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `paths` | table | Array of Lua search paths. |

**Example**

```lua
do

    local eng = lurek.validator.newEngine("content/examples")
    local before = eng:ruleCount()
    eng:addImportRule({ "content/examples", "library" })
    eng:addApiRule()
    lurek.log.info(tostring("LValidationEngine:addImportRule rules before=" .. before))
    lurek.log.info(tostring("LValidationEngine:addImportRule rules after=" .. eng:ruleCount()))
end
```

---

#### `LValidationEngine:addPatternRule`

Add a custom regex pattern rule to the validation engine.

```lua
LValidationEngine:addPatternRule(id, pattern, message, severity)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Rule identifier. |
| `pattern` | string | Text pattern to match. |
| `message` | string | Violation message. |
| `severity` | string | Severity: hint, warning, error, critical. |

**Example**

```lua
do

    local eng = lurek.validator.newEngine("content/examples")
    eng:addPatternRule("no_print", "print\\(", "Use lurek.log instead of print()", "warning")
    local report = eng:runFile("content/examples/math.lua")
    lurek.log.info(tostring("LValidationEngine:addPatternRule rules=" .. eng:ruleCount()))
    lurek.log.info(tostring("warnings=" .. report.warning_count))
    lurek.log.info(tostring("violations=" .. #report.violations))
end
```

---

#### `LValidationEngine:addRequiredRule`

Add a required pattern rule (violation if pattern NOT found).

```lua
LValidationEngine:addRequiredRule(id, pattern, message)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | string | Rule identifier. |
| `pattern` | string | Required text pattern. |
| `message` | string | Violation message. |

**Example**

```lua
do

    local eng = lurek.validator.newEngine("content/examples")
    eng:addRequiredRule("must_use_lurek", "lurek\\.", "Expected at least one lurek.* call")
    local report = eng:runFile("content/examples/math.lua")
    lurek.log.info(tostring("LValidationEngine:addRequiredRule rules=" .. eng:ruleCount()))
    lurek.log.info(tostring("warnings=" .. report.warning_count))
    lurek.log.info(tostring("violations=" .. #report.violations))
end
```

---

#### `LValidationEngine:loadTomlRules`

Load validation rules from a TOML-formatted rule file.

```lua
LValidationEngine:loadTomlRules(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Path to .toml rules file. |

**Example**

```lua
do

    local eng = lurek.validator.newEngine("content/examples")
    eng:loadTomlRules("docs/templates/validator_rules.toml")
    local report = eng:runFile("content/examples/math.lua")
    lurek.log.info(tostring("LValidationEngine:loadTomlRules rules=" .. eng:ruleCount()))
    lurek.log.info(tostring("warnings=" .. report.warning_count))
    lurek.log.info(tostring("violations=" .. #report.violations))
end
```

---

#### `LValidationEngine:ruleCount`

Get number of loaded rules for this object.

```lua
LValidationEngine:ruleCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Rule count. |

**Example**

```lua
do

    local eng = lurek.validator.newEngine("content/examples")
    eng:addApiRule()
    eng:addAssetRule("assets")
    eng:addImportRule({ "content/examples", "library" })
    lurek.log.info(tostring("LValidationEngine:ruleCount=" .. eng:ruleCount()))
    lurek.log.info(tostring("has multiple rules=" .. tostring(eng:ruleCount() >= 3)))
end
```

---

#### `LValidationEngine:run`

Run validation against all Lua files under root.

```lua
LValidationEngine:run()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Report with violations, files_checked, duration_ms, error_count, warning_count. |

**Example**

```lua
do

    local eng = lurek.validator.newEngine("content/examples")
    eng:addApiRule()
    local report = eng:run()
    lurek.log.info(tostring("LValidationEngine:run files_checked=" .. report.files_checked))
    lurek.log.info(tostring("violations=" .. #report.violations))
end
```

---

#### `LValidationEngine:runFile`

Run validation against a single file.

```lua
LValidationEngine:runFile(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | File path to validate. |

**Returns**

| Type | Description |
|------|-------------|
| table | Report. |

**Example**

```lua
do

    local eng = lurek.validator.newEngine("content/examples")
    eng:addApiRule()
    local report = eng:runFile("content/examples/math.lua")
    lurek.log.info(tostring("LValidationEngine:runFile files_checked=" .. report.files_checked))
    lurek.log.info(tostring("violations=" .. #report.violations))
end
```

---
