---
inclusion: manual
---

# build-system

## Mission
Own local build commands, Cargo profiles, feature flags, and packaging scripts.

## When To Use
- Build or run the engine locally.
- Choose between dev, release, and dist builds.
- Package or install the engine.
- Switch Lua backends.

## When To Skip
- CI/CD setup, Rust code changes.

## Rules

### Three Profiles
- `dev` — fast compile, debug assertions, no optimization. Never benchmark in dev.
- `release` — opt-level 3, LTO=thin.
- `dist` — opt-level 3, LTO=fat, UPX compression, strip symbols. Never ship from release — use dist.

### Commands
- Dev build: `python tools/dev/parallel_cargo.py build rust`
- Release: `cargo build --release`
- Dist: `cargo build --profile dist`
- Packaging: `powershell -File tools/dist/dist.ps1`
- Install: `powershell -File tools/dist/install.ps1`

### Output Locations
- Dev → `target/debug/lurek2d.exe`
- Release → `target/release/lurek2d.exe`
- Final artifacts → `build/debug/` and `build/release/` (copied by build scripts). Packaging scripts read from `build/`, not `target/`.

### Lua Backend
- LuaJIT is the default Cargo feature. `lua54` via `cargo build --no-default-features --features lua54`. Never swap the default without explicit authorization.

### build.rs
- If `build.rs` is changed, run `cargo clean` before the next build — incremental cache does not always detect `build.rs` changes.

### Toolchain
- `rust-toolchain.toml` pins the Rust version. Never override it with `+nightly` or `+stable` — the toolchain file is part of the contract.

### UPX
- UPX in `dist.ps1` reduces binary from ~20 MB to ~5 MB. Must be on PATH. Install via `scoop install upx` on Windows.

### parallel_cargo.py
- Use for clippy, fmt, test, and doc commands — it handles Cargo target threading and output formatting. Do not use raw `cargo` for repo-level commands.

### After Cargo.toml Changes
- After modifying `Cargo.toml`, run the full Quality Gate task to confirm no test regressions.

## References
- `Cargo.toml`
- `rust-toolchain.toml`
- `build/`
- `tools/dev/parallel_cargo.py`
- `tools/dist/`
