# validator

## Overview

Content validation engine for game assets, Lua scripts, and mod compliance. Provides asset existence checking, import resolution, API compliance, and custom pattern rules.

## Tier

Feature Systems

## Dependencies

- None (standalone, pure Rust)

## Public API (`lurek.validator`)

### Constructors
- `newEngine(root)` — Create validation engine for a directory.

### Quick Functions
- `validate(path)` — Quick validate with all built-in rules.
- `validateFile(path)` — Validate a single file with API rules.

### Engine Methods
- `engine:addAssetRule(asset_root)` — Add asset existence checking.
- `engine:addImportRule(paths)` — Add require() resolution checking.
- `engine:addApiRule()` — Add lurek.* API compliance checking.
- `engine:addPatternRule(id, pattern, message, severity)` — Add custom forbidden pattern.
- `engine:addRequiredRule(id, pattern, message)` — Add required pattern (violation if missing).
- `engine:loadTomlRules(path)` — Load rules from TOML file.
- `engine:run()` — Run all rules against Lua files under root.
- `engine:runFile(path)` — Run against a single file.
- `engine:ruleCount()` — Get loaded rule count.

### TOML Rules Format
```toml
[[rule]]
id = "no-print"
pattern = "print("
message = "Use lurek.log instead of print()"
severity = "warning"
invert = false
```

### Report Format
```lua
{
    files_checked = 10,
    duration_ms = 5,
    error_count = 2,
    warning_count = 1,
    is_clean = false,
    violations = {
        { rule = "asset-exists", severity = "error", file = "game.lua",
          line = 15, message = "Asset not found: sprites/hero.png",
          suggestion = "Create or fix path: assets/sprites/hero.png" },
    }
}
```

## Invariants

- Severity levels: hint < warning < error < critical.
- Asset rule checks lurek.sprite.load, lurek.audio.load, lurek.font.load, lurek.image.load.
- Import rule skips lurek.* requires (engine-provided).
- API compliance validates against known module list.
- Parallel validation uses std::thread::scope.
- Pattern rules: invert=false → violation on match; invert=true → violation if pattern NOT found.
