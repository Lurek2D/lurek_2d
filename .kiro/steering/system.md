---
inclusion: always
---

# Lurek2D — System Rules

## Communication
- Use simple English. No slang, idioms, or metaphors. Be direct and literal.
- When instructions are ambiguous, ask clarifying questions instead of guessing.
- Always complete user requests. Responsiveness > token cost.
- Validate with tools before returning: run tests, compile, check files. Don't guess.
- Define jargon when needed. Respond in Polish if user writes in Polish.

## Engine Identity
- Lurek2D is a single-binary 2D Rust runtime for Lua game scripts.
- Core stack: Rust stable 1.78+, LuaJIT via mlua 0.9, wgpu 22, winit 0.30, rapier2d 0.32, rodio 0.17, fontdue 0.9.
- License: MIT. Target personas: EngDev, GameDev, Modder, GameTest, EngTest.

## Binding Constraints
- T-01: Five module groups (Foundations → Core Runtime → Platform Services → Feature Systems → Edge/Integration). Imports flow downward only.
- T-02: No cycles, ever.
- A-01: Runtime only. No embedded editor. VS Code extension is opt-in, not part of the engine binary.
- A-02: Desktop only. No mobile. No WASM.
- A-03: 2D graphics only. No 3D pipeline.
- A-04: No platform SDKs (Steam, Epic) in the core binary.
- B-01: LuaJIT is the main runtime. lua54 is a non-shipping CI fallback only.
- B-02: wgpu 22 is the only renderer backend. No OpenGL path.
- B-03: Target 60 FPS at 1080p on integrated GPUs.
- B-04: Use Rust threads for concurrency. LuaJIT VMs do not share state. Use typed MPMC Channel for cross-VM communication.
- B-05: Use TOML for human config. JSON for external interop only. No YAML.
- C-01: Use `lurek.*` only. No bare globals, no engine-prefixed names, no alternative top-level tables.
- TST-01: `lurek.*` behavior → tested in `tests/lua/`. Rust tests must not duplicate Lua-reachable coverage.
- TST-02: No `#[cfg(test)]` in `src/`. Rust unit tests → `tests/rust/unit/<module>_tests.rs`.
- TST-03: `src/lua_api/<module>_api.rs`: bindings only. Business logic stays in `src/<module>/`.
- TST-04: Every `mod.rs`: only `pub mod`, `pub use`, attributes, and doc comments.
- TST-05: Demo tests → `tests/lua/demos/test_<name>.lua`. Screenshot demos → `tests/demo_smoke_tests.rs` with `#[ignore]`.
- TST-06: One test file per module per layer: `test_<module>_<layer>.lua`.

## Never Do
- Edit `docs/api/lurek.lua` — auto-generated. Fix at source, then regenerate with `python tools/gen_all_docs.py`.
- Add warning suppressions to `.vscode/settings.json`.
- Add `---@diagnostic disable` or `---@diagnostic disable-next-line` to Lua files.
- Add Lua-side type workarounds (`---@cast`, `--[[@as ...]]`) for `lurek.*` APIs.

## Cross-Artifact Sync
Update all linked artifacts in the same commit:
- Change `src/<module>/*.rs` → update `docs/specs/<module>.md`.
- Change `src/lua_api/<module>_api.rs` → update `docs/specs/<module>.md`; regenerate with `python tools/gen_all_docs.py`.
- Add/rename/remove `lurek.*` API → update `content/examples/`, affected `content/games/`, and dependent `library/` modules.
- Create a new module → add `docs/specs/<module>.md` and update `docs/specs/README.md`.
- Any change → update `docs/CHANGELOG.md`.

## Quality Gates (run before every commit)
- `cargo test` and `cargo clippy -- -D warnings` — zero failures, zero warnings.
- `python tools/validate/cag_validate.py` — for any `.github/` changes.
- `python tools/audit/cag_link_check.py --strict` — when CAG links or file paths change.

## Git Hygiene
- Confirm branch with `git rev-parse --abbrev-ref HEAD` before staging.
- Stage only touched files. Never `git add .`.
- Commit format: `type(scope): description`. Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`.
- Every commit must update `docs/CHANGELOG.md`. MAJOR/MINOR also update `Cargo.toml`.

## Work Sessions
- Every session uses `work/<session-name>/` as a temporary workspace.
- Layout: `plans/`, `briefs/`, `reports/`, `logs/` (agent_log.jsonl).
- Append one JSONL line per completed phase to `logs/agent_log.jsonl`.
- Move finished sessions to `work/archive/`.

## Repository Layout
- `src/` — Rust engine; `src/lua_api/` = bindings only.
- `tests/` — Rust test targets and Lua test harness.
- `docs/` — specs, architecture, API references; `docs/api/` is generated — never edit by hand.
- `content/` — examples, game demos, UI layouts. `library/` — reusable Lua modules.
- `tools/` — generators, validators, audit scripts.
- `work/` — session workspaces (temp). `logs/` — runtime logs.
