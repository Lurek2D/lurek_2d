---
name: examples-management
description: "Load this skill when adding, modifying, or reviewing content in the content/examples/ or content/games/ directories: game example scripts, demo folder structure, conf.lua, or README files. Use for ensuring examples are self-contained, well-commented, and demonstrate one API concept. Skip it for engine Rust code, tests, documentation under docs/, or CAG work."
---
# examples-management

## Mission

Own the content/examples/ and content/games/ directories: file structure, naming, quality standards, smoke test support, and API documentation pipeline integration.

## When To Load

- Adding a new Lua example to content/examples/ or demo to content/games/
- Reviewing an existing example for correctness or code quality
- Understanding the difference between content/examples/ and content/games/
- Linking an example to the API documentation pipeline

## When To Skip

- Engine Rust code, tests, documentation under docs/, or CAG work

## Domain Knowledge

**Two-folder model:**

| Folder | Purpose | Format |
|--------|---------|--------|
| content/examples/ | Minimal single-file API demonstrations | One .lua file per API area, 30-100 lines, no conf.lua |
| content/games/ | Larger showcase games/feature demos | Full directory: conf.toml + main.lua + assets, 100-500+ lines |

**What makes a good example:** scenario-driven (name sections by game task, not function name); self-contained (runs without extra setup); answers WHY (reader understands when to use each function); uses realistic game values (hp=100, "hero_walk.png", not 0 or nil); example_coverage.py passing is the floor, not the ceiling.

**Forbidden patterns:** function-name scenarios (e.g. "test_newTimer" instead of "schedule bullet despawn"); lone constructors with nil/zero args; examples that require external assets not shipped with the engine.

**Canonical types:** colors are 0.0-1.0 floats (not 0-255); keys are lowercase strings ("space", "escape"); draw modes are "fill" or "line".

**content/examples/ file structure:** top comment block (file path, one-line purpose, run command), small section comments before load/update/draw, no conf.lua, self-contained with no external assets.

**Smoke test support:** every example should support: if lurek.runtime.getArgs()["--smoke"] then lurek.event.quit() end for CI validation.

**Coverage tools:** tools/audit/example_coverage.py (check gaps), tools/audit/example_add_missing.py (append stubs for uncovered API). Run example_coverage.py first, then add_missing with --dry-run, then flesh out stubs with real scenario-driven code.

**Adding a new example checklist:** (1) check gaps with example_coverage.py, (2) write scenario-driven .lua file, (3) verify it runs standalone, (4) update content/examples/README.md if needed, (5) run example_coverage.py again to confirm coverage.

## Companion File Index

None — all guidance is inline.

## References

- content/examples/ — existing examples (reference for patterns)
- content/games/ — existing demo projects
- tools/audit/example_coverage.py — coverage gap checker
- tools/audit/example_add_missing.py — stub generator for missing API coverage
