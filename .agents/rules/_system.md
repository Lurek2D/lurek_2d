---
trigger: always_on
description: "Lurek2D System Prompt for copilot-instructions.md"
---
# Lurek2D System Prompt

## Communication
- Use simple English. No slang. Be direct.
- Ask questions if instructions unclear. Do not guess.
- Do user request. Done is priority.
- Test and compile code before done. No guess.
- Talk Polish if user talks Polish.

## Engine Identity
- Lurek2D is 1 Rust binary for Lua game scripts.
- Stack is Rust 1.78+, LuaJIT (mlua 0.9), wgpu 22, winit 0.30, rapier2d 0.32, rodio 0.17, fontdue 0.9.
- MIT license. Target EngDev, GameDev, Modder, GameTest, EngTest.

## Binding Constraints
- T-01 Five module groups: Foundations, Core, Platform, Feature, Edge.
- T-02 No cyclic dependencies.
- A-01 Runtime only. No editor. VS Code is optional.
- A-02 Desktop only. No mobile, no WASM.
- A-03 2D graphics only. No 3D.
- A-04 No Steam/Epic SDKs.
- B-01 LuaJIT main. Lua54 for fallback.
- B-02 wgpu 22 only. No OpenGL.
- B-03 60 FPS, 1080p on integrated GPU.
- B-04 Rust threads. LuaJIT VMs isolated. MPMC Channel for data.
- B-05 TOML for config. JSON for tools. No YAML.
- C-01 Use `lurek.*` only. No other globals.
- TST-01 `lurek.*` tests in `tests/lua/`.
- TST-02 No `#[cfg(test)]` in `src/`. Rust tests in `tests/rust/unit/`.
- TST-03 `src/lua_api/` is bindings. Logic in `src/`.
- TST-04 `mod.rs` only has pub mods. No logic inside.
- TST-05 Demos in `tests/lua/demos/`. Screenshot in `tests/demo_smoke_tests.rs`.
- TST-06 One test file per module per layer: `test_<module>_<layer>.lua`.
- Never edit `docs/api/lurek.lua` directly. Edit `src/lua_api/` and run `python tools/gen_all_docs.py`.
- No warning suppress in `.vscode/settings.json`.
- No `---@diagnostic disable` in Lua. Fix `src/lua_api/`.
- No Lua type casts. Use `any` in rust bindings if needed.

## Cross-Artifact Sync
Change one, update all:
- `src/<module>/*.rs` -> `docs/specs/<module>.md`.
- `src/lua_api/*_api.rs` -> `docs/specs/` and run `python tools/gen_all_docs.py`.
- API change -> `content/examples/`, `content/games/`, `library/`.
- New module -> `docs/specs/<module>.md` and `docs/specs/README.md`.
- `library/<name>/init.lua` -> example, tests, docs.
- Setup change -> `docs/architecture/developer-workflow.md` and `CONTRIBUTING.md`.

## Discovery
- `docs/architecture/philosophy.md` is design truth.
- `docs/architecture/cag-system.md` has system details.
- `docs/architecture/developer-ecosystem.md` is ecosystem.
- Agents: `WHY` in `.github/agents/*.agent.md`.
- Skills: `HOW` in `.github/skills/*/SKILL.md`.
- Prompts: `WHAT` in `.github/prompts/*.prompt.md`.
- Agents are autonomous. Work until done or blocked or out of scope. Then manager.

## Quality Gates
Do before commit:
- `cargo test` and `cargo clippy -- -D warnings`.
- `python tools/validate/cag_validate.py`.
- `python tools/audit/cag_link_check.py --strict`.

## Repository Layout
- `src/` has Rust code.
- `tests/` has Rust/Lua tests.
- `docs/` has Specs and API.
- `content/` has Games, examples.
- `library/` has Lua modules.
- `.github/` has Agents, skills, prompts.
- `work/` has Flat temp files.
