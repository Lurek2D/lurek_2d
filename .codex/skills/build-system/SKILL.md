---
name: build-system
description: "Load this skill when changing Cargo profiles, debug or release builds, feature flags, build output, or packaging. Skip it for CI/CD setup or Rust code changes."
---
# build-system

## Use when
- Build or run the engine locally.
- Choose between dev, release, and dist builds.
- Tune build size or speed.
- Package or install the engine.
- Switch Lua backends.

## Avoid when
- CI/CD setup.
- Rust code changes.

## Repo rules
- Three profiles: `dev`, `release`, `dist`. Never benchmark in `dev`.
- Commands: `python tools/dev/parallel_cargo.py build rust`, `cargo build --release`, `cargo build --profile dist`. For packaging: `powershell -File tools/dist/dist.ps1`.
- Output locations: `dev` â†’ `target/debug/lurek2d.exe`, `release` â†’ `target/release/lurek2d.exe`, final artifacts â†’ `build/debug/` and `build/release/`. Packaging scripts read from `build/`, not `target/`.
- LuaJIT is the default Cargo feature for all local and dist builds. Enabling `lua54` is done via `cargo build --no-default-features --features lua54`.
- `build.rs` handles asset embedding and generated code. If `build.rs` is changed, run `cargo clean` before the next build â€” incremental build cache does not always detect `build.rs` changes.
- `rust-toolchain.toml` pins the Rust version. Never override it with `+nightly` or `+stable` locally to "fix" a build error â€” the toolchain file is part of the contract and overrides hide real problems.
- UPX compression in `dist.ps1` reduces the binary from ~20 MB to ~5 MB. UPX must be on PATH.
- `tools/dev/parallel_cargo.py` wraps cargo for the workspace. Use it for clippy, fmt, test, and doc commands â€” it handles Cargo target threading and output formatting.
- The workspace `.vscode/tasks.json` exposes all standard build flows as tasks. When documenting a build step for a contributor, refer to the task label, not a raw command â€” task labels stay stable as command details change.
- After modifying `Cargo.toml`, run the full Quality Gate task to confirm no test regressions from the change.

## Checks
- `python tools/dev/parallel_cargo.py build rust`
- `lua54`
- `cargo clean`
- `Cargo.toml`

## References
- `Cargo.toml`
- `rust-toolchain.toml`
- `build/`
- `tools/dev/parallel_cargo.py`
- `tools/dist/`

