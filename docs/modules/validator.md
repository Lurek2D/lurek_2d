# Validator

- The `validator` module is a parallel, rule-based static analysis engine for Lua game scripts with built-in checks for asset existence, import resolution, and API compliance.

The `validator` module equips developers and CI pipelines with a structured static analysis engine for Lua game scripts. The central `ValidationEngine` is configured via `ValidatorConfig` (deserialized from a `[validator]` TOML block) and orchestrates a set of `ValidationRule` implementations over a file tree in parallel using a Rayon worker pool. Thread count defaults to the configured value; 0 forces synchronous single-threaded mode.

Three built-in rule types cover the most common correctness checks. The `ApiComplianceRule` inspects each `lurek.*` call site against an `ApiRegistry` loaded at startup, flagging unknown function names as `Severity::Error` and wrong argument counts as `Severity::Warning`. The `AssetExistenceRule` pattern-matches `lurek.asset.load("path")` calls and verifies each path via `GameFS::exists` without decoding the asset — missing files produce errors, likely typos produce warnings. The `ImportResolutionRule` scans for `require("path")` calls via regex, resolving each against the game's configured `lua_paths` to catch missing module files before runtime.

Beyond built-in rules, the engine supports extensibility in two directions. TOML rule files (loaded via `load_rules_from_file`) specify `[[rule]]` arrays with pattern, severity, message, and optional file-extension filter — ideal for project-specific naming conventions or forbidden API patterns. Lua callbacks registered via `lurek.validator.add_rule` inject `LuaPatternRule` adapters, letting game teams write script-side rules without recompiling. Results are collected into a `ValidationReport` containing `Vec<Violation>` with file path, line number, severity, and an optional suggestion string. The `lurek.validator.*` API exposes engine creation, rule registration, single-file and tree-wide validation runs, and report display.

## Functions

### `lurek.validator.newEngine`

Creates a new validation engine rooted at the given filesystem path.

```lua
-- signature
lurek.validator.newEngine(root)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `root` | `string` | Root directory path for the validation engine. |

**Returns**

| Type | Description |
|------|-------------|
| `LValidationEngine` | A new validation engine instance. |

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
-- signature
lurek.validator.validate(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Root directory path of the project to validate. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Table with fields: errors (table), warnings (table), passed (boolean). |

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
-- signature
lurek.validator.validateFile(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Absolute or relative path to the Lua file to validate. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Table with fields: errors (table), warnings (table), passed (boolean). |

**Example**

```lua
do
    local report = lurek.validator.validateFile("content/examples/math.lua")
    print("lurek.validator.validateFile files_checked=" .. report.files_checked)
    print("errors=" .. report.error_count)
end
```

---

## LValidationEngine

### `LValidationEngine:addApiRule`

Add the built-in API compliance rule.

```lua
-- signature
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

### `LValidationEngine:addAssetRule`

Add the built-in asset existence rule.

```lua
-- signature
LValidationEngine:addAssetRule(asset_root)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `asset_root` | `string` | Root directory for asset files. |

**Example**

```lua
do
    local eng = lurek.validator.newEngine("content/examples")
    eng:addAssetRule("assets")
    print("LValidationEngine:addAssetRule rules=" .. eng:ruleCount())
end
```

---

### `LValidationEngine:addImportRule`

Add the built-in import resolution rule.

```lua
-- signature
LValidationEngine:addImportRule(paths)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `paths` | `table` | Array of Lua search paths. |

**Example**

```lua
do
    local eng = lurek.validator.newEngine("content/examples")
    eng:addImportRule({ "content/examples", "library" })
    print("LValidationEngine:addImportRule rules=" .. eng:ruleCount())
end
```

---

### `LValidationEngine:addPatternRule`

Add a custom regex pattern rule to the validation engine.

```lua
-- signature
LValidationEngine:addPatternRule(id, pattern, message, severity)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `string` | Rule identifier. |
| `pattern` | `string` | Text pattern to match. |
| `message` | `string` | Violation message. |
| `severity` | `string` | Severity: hint, warning, error, critical. |

**Example**

```lua
do
    local eng = lurek.validator.newEngine("content/examples")
    eng:addPatternRule("no_print", "print\\(", "Use lurek.log instead of print()", "warning")
    print("LValidationEngine:addPatternRule rules=" .. eng:ruleCount())
end
```

---

### `LValidationEngine:addRequiredRule`

Add a required pattern rule (violation if pattern NOT found).

```lua
-- signature
LValidationEngine:addRequiredRule(id, pattern, message)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `id` | `string` | Rule identifier. |
| `pattern` | `string` | Required text pattern. |
| `message` | `string` | Violation message. |

**Example**

```lua
do
    local eng = lurek.validator.newEngine("content/examples")
    eng:addRequiredRule("must_use_lurek", "lurek\\.", "Expected at least one lurek.* call")
    print("LValidationEngine:addRequiredRule rules=" .. eng:ruleCount())
end
```

---

### `LValidationEngine:loadTomlRules`

Load validation rules from a TOML-formatted rule file.

```lua
-- signature
LValidationEngine:loadTomlRules(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Path to .toml rules file. |

**Example**

```lua
do
    local eng = lurek.validator.newEngine("content/examples")
    eng:loadTomlRules("docs/templates/validator_rules.toml")
    print("LValidationEngine:loadTomlRules rules=" .. eng:ruleCount())
end
```

---

### `LValidationEngine:ruleCount`

Get number of loaded rules for this object.

```lua
-- signature
LValidationEngine:ruleCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Rule count. |

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

### `LValidationEngine:run`

Run validation against all Lua files under root.

```lua
-- signature
LValidationEngine:run()
```

**Returns**

| Type | Description |
|------|-------------|
| `table` | Report with violations, files_checked, duration_ms, error_count, warning_count. |

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

### `LValidationEngine:runFile`

Run validation against a single file.

```lua
-- signature
LValidationEngine:runFile(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | File path to validate. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Report. |

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
