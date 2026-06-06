---
inclusion: manual
---

# ci-cd-pipeline

## Mission
Own CI workflow design, job scope, and release automation rules.

## When To Use
- Add or update GitHub Actions workflows.
- Change CI quality gates.
- Add release automation.
- Review pipeline structure or caching.

## When To Skip
- Local development workflow, Rust or Lua code changes.

## Rules

### Starting Point
No GitHub Actions workflows directory exists yet. Any CI setup must create it from scratch. Mirror existing local quality gates from `tools/dev/parallel_cargo.py` and `.vscode/tasks.json` — CI commands must match local developer experience exactly.

### Required CI Stages (in order)
1. `fmt check`
2. `clippy --deny-warnings`
3. `cargo test --all-targets` for Rust tests
4. Lua harness test via `python tools/dev/parallel_cargo.py test lua`
5. Docs validation via `python tools/validate/validate_generated_lua_stubs.py`

Only after all 5 pass should an artifact build be attempted.

### Platform Matrix
- Windows x86_64 (mandatory), Linux x86_64 (mandatory). macOS ARM is a stretch goal.
- No mobile, no WASM.

### LuaJIT Note
If a runner cannot build LuaJIT, run with `--no-default-features --features lua54` and label the job clearly.

### Pin All Tool Versions
Rust toolchain via `rust-toolchain.toml`, Python version explicitly in CI config, UPX version for dist jobs. Never use `latest` for build tools.

### Cargo Caching
Cache `~/.cargo/registry`, `~/.cargo/git`, and `target/` by hashing `Cargo.lock`. Invalidate on any `Cargo.lock` change. Do not cache `build/` or `dist/`.

### Artifact Naming
`lurek2d-{os}-{arch}-{git-sha-short}.zip`. Must match the layout that `tools/dist/dist.ps1` produces.

### Release Triggers
Tag matching `v*.*.*` on the `main` branch only. Pre-release: tag matching `v*.*.*-rc.*`. Never trigger a release from a non-main branch automatically.

### Docs in CI
Run `python tools/gen_all_docs.py` and fail if generated files differ from committed files. This enforces that contributors do not commit stale generated docs.

### CI YAML Style
Each logical step is a named step in the YAML, not a long inline shell block. Prefer checked-in scripts over inline YAML logic.

## References
- `.github/`
- `Cargo.toml`
- `rust-toolchain.toml`
- `tools/dev/parallel_cargo.py`
- `tools/dist/`
