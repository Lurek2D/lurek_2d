---
name: create-build
description: "Load this skill when creating or modifying Cargo profiles, release/debug/dist settings, packaging scripts, or build automation. Skip it for runtime feature work, docs-only changes, or pure test authoring."
---

# create-build

## Mission
- Create or modify build, release, debug, dist, and packaging behavior while preserving local Windows-first tooling.

## Domain Knowledge
- `Cargo.toml` owns compiler profiles and explicit test targets; `tools/dist/` owns installers and packaging orchestration, while `dist/` is output rather than build policy.
- Lurek2D ships as one Rust binary with an embedded Lua runtime, so release changes can affect executable size, native runtime expectations, bundled assets, and packaged games together.
- LTO, codegen units, debug symbols, panic strategy, stripping, and incremental compilation trade build latency against binary size, diagnosability, and runtime speed; measure the dimension the request targets.
- Packaging must be tested from its staged artifact because a developer-tree launch can conceal missing assets or implicit repository-relative dependencies.
- Cargo profile inheritance and command selection matter: a flag placed in `[profile.release]` does not affect an explicitly named profile unless it inherits as expected, and packaging scripts must invoke the same profile whose artifact they stage.
- Native dependency delivery is part of package correctness. LuaJIT, audio, graphics, and Windows runtime requirements must be evaluated from the built artifact and installer layout rather than inferred from a successful developer build.
- Reproducible packaging requires stable file ordering, explicit inclusion/exclusion rules, and normalized relative paths; timestamps or workspace-absolute paths should not leak into archives when they are not part of the format.

## Workflow
- Classify the change as compiler profile, developer build wrapper, distribution staging, installer, or game packaging; trace the active entry point through `Cargo.toml` and `tools/dist/` so one concern is not implemented in several scripts.
- Capture a reproducible baseline with the exact profile and artifact: command, wall time, executable/package size, staged contents, and launch result. Change only the owning flags or stage list, preserving unrelated debug/release behavior.
- Validate from a freshly staged artifact: build the selected profile, inspect package contents, launch without repository-relative files, and exercise `package_games.py` or the installer only when that layer changed.
- Compare the result to the baseline and record the intended trade-off; then run Cargo/clippy checks for shared profile changes and smoke the packaged executable before accepting archive or installer creation as success.
- Inspect the command graph for duplicated release logic across `dist.ps1`, `pack.ps1`, `release.ps1`, `pack.py`, and installer configuration; keep version, artifact name, and staging-root decisions at the narrowest existing shared owner.
- Test both a successful package and one representative missing-input failure, confirming non-zero exit status, actionable path diagnostics, and no half-published archive or installer at the final destination.

## References
- `contracts: AGENTS.md, tools/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "build profiles Cargo.toml dist tools" --profile engine --limit 10, cargo build --profile <profile>, cargo clippy -- -D warnings, tools/python.cmd tools/validate/cag_validate.py`
- `agent: builder`
- RAG: Use when finding current build owners before editing; `build profiles Cargo.toml dist tools`; `release profile packaging cargo config`; `python.cmd build audit validate cargo`; `Cargo.toml`; `tools/dist/`; `tools/dev/`; `tools/validate/`
