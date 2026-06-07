# Validator

## Summary

This module provides a static analysis engine designed to inspect Lua projects before runtime. By scanning source files statically, it identifies API compliance issues, broken module imports, and missing asset references early. The validation orchestrator lets teams enforce clean code standards by combining built-in checks with customizable rules.

To handle large projects, the system runs checks across parallel threads and aggregates findings into structured diagnostic reports. These reports capture the location, severity, and context of each violation, feeding directly into local workflows and automated quality pipelines. Extensible rules can be loaded from TOML files or custom scripts.

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
    print("lurek.validator.newEngine type=" .. type(eng))
    print("rule count=" .. eng:ruleCount())
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
    print("lurek.validator.validate files_checked=" .. report.files_checked)
    print("is_clean=" .. tostring(report.is_clean))
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
    print("lurek.validator.validateFile files_checked=" .. report.files_checked)
    print("errors=" .. report.error_count)
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

*No callback parameters documented in this module.*

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
    eng:addApiRule()
    print("LValidationEngine:addApiRule rules=" .. eng:ruleCount())
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
    eng:addAssetRule("assets")
    print("LValidationEngine:addAssetRule rules=" .. eng:ruleCount())
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
    eng:addImportRule({ "content/examples", "library" })
    print("LValidationEngine:addImportRule rules=" .. eng:ruleCount())
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
    print("LValidationEngine:addPatternRule rules=" .. eng:ruleCount())
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
    print("LValidationEngine:addRequiredRule rules=" .. eng:ruleCount())
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
    print("LValidationEngine:loadTomlRules rules=" .. eng:ruleCount())
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
    print("LValidationEngine:ruleCount=" .. eng:ruleCount())
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
    print("LValidationEngine:run files_checked=" .. report.files_checked)
    print("violations=" .. #report.violations)
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
    print("LValidationEngine:runFile files_checked=" .. report.files_checked)
    print("violations=" .. #report.violations)
end
```

---
