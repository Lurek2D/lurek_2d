---
inclusion: manual
---

# demo-creation

## Mission
Own demo folder structure, files, and registration flow.

## When To Use
- Create a new demo.
- Update demo setup files or README.

## When To Skip
- Single example files, test writing, engine Rust code.

## Rules

### Mandatory Folder Structure
`content/games/<category>/<name>/conf.toml`, `main.lua`, `README.md`. Optional but recommended: `ui.toml`, `screen.png` (240×135), `assets/`. A demo missing config will fail runtime expectations.

### conf.toml
Must define at least `[window] title/width/height`. Recommended: `vsync`, plus a stable FPS target block. Check `src/runtime/config.rs` and nearby content templates before writing config.

### Registration
After creating a demo:
1. `tests/games_load_test.rs` auto-discovers `content/games/**/main.lua`.
2. `tests/lua/harness.rs` auto-discovers `content/games/**/test.lua`.
3. `tests/demo_smoke_tests.rs` needs an explicit `#[ignore]` smoke test entry when screenshot coverage is required.

### Smoke Tests
Run with `#[ignore]` and require a window. Do not make a smoke test part of the default `cargo test` run.

### README.md Structure
One-line description, feature list (3-5 bullets), "How to run" section (one command), "What to look for" section. Keep under 30 lines.

### Asset Budget
Use only assets already in `assets/` (shared fonts, test images) or tiny purpose-specific assets in `content/games/<name>/assets/`. Do not add large binary assets to prove a small point.

### Demo Size Rule
A demo that proves one capability cluster is more useful than one that proves many. If `main.lua` grows beyond ~200 lines, consider splitting or promoting to a full game.

### Category Choices
- `demos/` — engine feature showcase.
- `tests/` — Lua-test-adjacent.
- `games/` — playable content.
Do not place engine feature demos in `games/` or playable content in `demos/`.

### main.lua Structure
Start with `function lurek.load()` for one-time setup, `function lurek.update(dt)` for per-frame logic, `function lurek.draw()` for all draw calls. Demo must not use `require` on library modules unless demonstrating that specific library.

### Lurek API First
Prefer `lurek.scene`, `lurek.render`, `lurek.ecs`, and `lurek.ui` over local custom wrappers whenever an equivalent API exists.

## References
- `content/games/`
- `tests/lua/demos/`
- `tests/demo_smoke_tests.rs`
- `tests/games_load_test.rs`
