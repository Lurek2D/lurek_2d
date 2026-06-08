---
name: demo-creation
description: "Load this skill when creating demo projects in content/games/, including conf.toml, main.lua, README.md, and registration. Skip it for single examples, tests, or engine Rust code."
---
# demo-creation

## Use when
- Create a new demo.
- Create many demos from a list.
- Update demo setup files or README.

## Avoid when
- Single example files.
- Test writing.
- Engine Rust code.

## Repo rules
- Demo folder structure is mandatory: `content/games/<category>/<name>/conf.toml`, `main.lua`, `README.md`. Optional but recommended: `ui.toml`, `screen.png`, `assets/`.
- `conf.toml` should define at least `[window] title/width/height`; recommended: `vsync`, plus a stable FPS target block used by neighboring demos. Check `src/runtime/config.rs` and nearby content templates before writing config.
- After creating a demo, keep registration aligned with current discovery flow: `tests/games_load_test.rs` auto-discovers `content/games/**/main.lua`, `tests/lua/harness.rs` auto-discovers `content/games/**/test.lua`, `tests/demo_smoke_tests.rs` needs an explicit `#[ignore]` smoke test entry when screenshot coverage is required.
- Smoke tests in `tests/demo_smoke_tests.rs` run with `#[ignore]` and require a window. They are run manually or in dedicated CI jobs with a display.
- README.md structure: one-line description, feature list, "How to run" section, and "What to look for" section explaining the expected behavior. Keep it under 30 lines.
- Asset budget: demos should use only assets already in `assets/` or tiny purpose-specific assets in `content/games/<name>/assets/`. Do not add large binary assets to prove a small point.
- A demo that proves one capability cluster is more useful than a demo that proves many. If a demo grows beyond ~200 lines in `main.lua`, consider splitting it or promoting it to a full game.
- `content/games/<name>/` category choices: `demos/`, `tests/`, `games/`. Do not place engine feature demos in `games/` or playable content in `demos/`.
- How to write `main.lua` for a demo: start with `function lurek.load()` for one-time setup, `function lurek.update(dt)` for per-frame logic, and `function lurek.draw()` for all draw calls. The demo must not use `require` on library modules unless demonstrating that specific library â€” bare `lurek.*` calls only.
- Lurek API first rule: prefer `lurek.scene`, `lurek.render`, `lurek.ecs`, and `lurek.ui` over local custom wrappers or ad-hoc subsystems whenever an equivalent API exists.
- Avoid local render helper shims and primitive-only fallback flows unless a required capability is truly missing from current `lurek.*` APIs.

## Checks
- `Run the narrowest relevant validation for the touched files or workflow.`

## References
- `content/games/`
- `tests/lua/demos/`
- `tests/demo_smoke_tests.rs`
- `tests/games_load_test.rs`

