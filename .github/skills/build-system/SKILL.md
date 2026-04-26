---
name: build-system
description: "Load this skill when working with the Lurek2D build system: Cargo profiles, debug vs release builds, binary size and speed optimisation, the build/ output directory override, feature flags (lua-jit / lua54), or packaging for distribution via installer scripts. Use for: cargo build, cargo check, cargo run, profile tuning, dist.ps1/dist.sh, NSIS installer. Skip it for CI/CD pipeline setup (use ci-cd-pipeline skill) or writing Rust code."
---
# build-system

## Mission

Own Cargo profile definitions, output directory override, feature flags, development loop commands, and distribution packaging scripts.

## When To Load

- Building or running the engine locally for the first time
- Choosing between cargo build, cargo check, cargo build --release, or cargo build --profile dist
- Tuning binary size or runtime speed via Cargo profile settings
- Packaging a distribution release or installing locally
- Switching between the LuaJIT and Lua 5.4 scripting backends

## When To Skip

- CI/CD pipeline setup → use ci-cd-pipeline skill
- Writing Rust code → use rust-coding skill

## Domain Knowledge

**Output directory:** Lurek2D redirects Cargo output from target/ to build/ via .cargo/config.toml. Binaries at build/debug/, build/release/, build/dist/. Never reference target/.

**Cargo profiles:**

| Profile | Command | Use when |
|---------|---------|----------|
| dev | cargo build | Active development — fast incremental, debuggable |
| release | cargo build --release | Performance testing, running demos at full speed |
| dist | cargo build --profile dist | Packaging — smallest binary, fat LTO, longer build |

- dev: opt-level 0 for engine, opt-level 3 for deps (wgpu/rapier/rodio run fast). Add debug=true locally for debugger.
- release: small fast binary, symbols stripped. Do NOT use for debugging panics.
- dist: fat LTO, single codegen unit, strip=true. Use for installer/ZIP packages only.

**Feature flags — Lua backend:**

| Feature | Backend | Notes |
|---------|---------|-------|
| lua-jit (default) | LuaJIT vendored | Ship this. Windows/Linux/macOS x86_64+ARM |
| lua54 | Lua 5.4 vendored | CI fallback only. cargo build --no-default-features --features lua54 |

Never ship lua54 builds. Use lua54 only for cross-backend CI checks.

**Development loop:** cargo check (2-5s, type-check only) → cargo build (5-15s) → cargo run. Use cargo check for rapid iteration; full build only when running.

**Distribution packaging:** see tools/dist/ for all scripts — dist.ps1 (Windows ZIP+folder), dist.sh (Linux/macOS tar.gz), installer.nsi (NSIS Windows installer), install.ps1/install.sh (local install to user bin), pack.ps1/pack.py (game folder to .lurek archive).

**Common issues:** Missing lua.h → ensure vendored feature; LINK error → clean rebuild (cargo clean); binaries not in target/ → they are in build/ per .cargo/config.toml.

## Companion File Index

None — all guidance is inline.

## References

- .cargo/config.toml — output directory override
- Cargo.toml — profile definitions and feature flags
- tools/dist/ — distribution scripts (dist.ps1, dist.sh, installer.nsi, install.ps1, install.sh, pack.py)
