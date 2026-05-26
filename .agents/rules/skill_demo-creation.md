---
trigger: model_decision
description: "Load this skill when creating demo projects in content/games/, including conf.toml, main.lua, README.md, and registration. Skip it for single examples, tests, or engine Rust code."
---

# demo-creation

## Mission
- Own demo folder structure, files, and registration flow.

## When To Load
- Create a new demo.
- Create many demos from a list.
- Update demo setup files or README.

## When To Skip
- Single example files.
- Test writing.
- Engine Rust code.

## Domain Knowledge
- Demo folder structure is mandatory: `content/games/<category>/<name>/conf.toml`, `main.lua`, `README.md`. Optional but recommended: `ui.toml`, `screen.png` (240×135), `assets/`. A demo folder missing config will fail runtime expectations and may fail validation.
- `conf.toml` should define at least `[window] title/width/height`; recommended: `vsync`, plus a stable FPS target block used by neighboring demos. Check `src/runtime/config.rs` and nearby content templates before writing config.
- After creating a demo, keep registration aligned with current discovery flow: (1) `tests/games_load_test.rs` auto-discovers `content/games/**/main.lua`, (2) `tests/lua/harness.rs` auto-discovers `content/games/**/test.lua`, (3) `tests/demo_smoke_tests.rs` needs an explicit `#[ignore]` smoke test entry when screenshot coverage is required.
- Smoke tests in `tests/demo_smoke_tests.rs` run with `#[ignore]` and require a window. They are run manually or in dedicated CI jobs with a display. Do not make a smoke test part of the default `cargo test` run.
- README.md structure: one-line description, feature list (3-5 bullets), "How to run" section (one cargo command or task label), and "What to look for" section explaining the expected behavior. Keep it under 30 lines.
- Asset budget: demos should use only assets already in `assets/` (shared fonts, test images) or tiny purpose-specific assets in `content/games/<name>/assets/`. Do not add large binary assets to prove a small point.
- A demo that proves one capability cluster (e.g., particle systems, tilemap rendering, dialog flow) is more useful than a demo that proves many. If a demo grows beyond ~200 lines in `main.lua`, consider splitting it or promoting it to a full game.
- `content/games/<name>/` category choices: `demos/` (engine feature showcase), `tests/` (Lua-test-adjacent), `games/` (playable content). Do not place engine feature demos in `games/` or playable content in `demos/`.
- How to write `main.lua` for a demo: start with `function lurek.load()` for one-time setup (load assets, create physics world, initialize state), `function lurek.update(dt)` for per-frame logic, and `function lurek.draw()` for all draw calls. The demo must not use `require` on library modules unless demonstrating that specific library — bare `lurek.*` calls only.
- Lurek API first rule: prefer `lurek.scene`, `lurek.render`, `lurek.ecs`, and `lurek.ui` (with `ui.toml`) over local custom wrappers or ad-hoc subsystems whenever an equivalent API exists.
- Avoid local render helper shims and primitive-only fallback flows unless a required capability is truly missing from current `lurek.*` APIs.
## Companion File Index
- None.


## Gemini Tips (Antigravity Optimization)
- **Token Efficiency**: Load this skill selectively. Do not copy long code snippets when reference paths or outline will suffice.
- **Tool Usage**: Prefer specific IDE tools (`view_file`, `grep_search`, `multi_replace_file_content`) over bash commands where possible for faster, structured execution.
- **Context Limit**: Focus strictly on the required modules specified in constraints. Do not read unrelated codebase parts.

## References
- content/games/
- tests/lua/demos/
- tests/demo_smoke_tests.rs
- tests/games_load_test.rs
