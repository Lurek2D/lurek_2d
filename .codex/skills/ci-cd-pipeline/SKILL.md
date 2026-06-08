---
name: ci-cd-pipeline
description: "Load this skill when setting up or maintaining CI/CD, GitHub Actions, test pipelines, or release automation. Skip it for local dev work or code changes."
---
# ci-cd-pipeline

## Use when
- Add or update GitHub Actions workflows.
- Change CI quality gates.
- Add release automation.
- Review pipeline structure or caching.

## Avoid when
- Local development workflow.
- Rust or Lua code changes.

## Repo rules
- There is currently no GitHub Actions workflows directory in this repo. Any CI setup work must create it from scratch.
- Required CI stages in this order: `fmt check`, `clippy --deny-warnings`, `cargo test --all-targets` for Rust tests, Lua harness test, docs validation. Only after all 5 pass should an artifact build be attempted.
- Platform matrix minimum: Windows x86_64, Linux x86_64. macOS ARM is a stretch goal.
- LuaJIT CI note: LuaJIT requires a C compiler and a specific build step that can fail on some CI runners. The `lua54` fallback feature exists exactly for this reason.
- Pin all tool versions: Rust toolchain via `rust-toolchain.toml`, Python version explicitly in CI config, UPX version for dist jobs. Never use `latest` for build tools.
- Cargo dependency caching: cache `~/.cargo/registry`, `~/.cargo/git`, and `target/` by hashing `Cargo.lock`. Invalidate on any `Cargo.lock` change.
- Artifact naming convention: `lurek2d-{os}-{arch}-{git-sha-short}.zip`. Artifacts produced during CI must match the layout that `tools/dist/dist.ps1` produces, so local and CI packaging outputs are structurally identical.
- Release triggers: tag matching `v*.*.*` on the `main` branch. Pre-release triggers: tag matching `v*.*.*-rc.*`.
- Docs generation in CI: run `python tools/gen_all_docs.py` and fail the job if generated files differ from committed files. This enforces that contributors do not commit stale generated docs.
- CI YAML should remain readably staged â€” each logical step is a named step in the YAML, not a long inline shell block. Prefer checked-in scripts over inline YAML logic.

## Checks
- `lua54`
- `python tools/gen_all_docs.py`

## References
- `.github/`
- `Cargo.toml`
- `rust-toolchain.toml`
- `tools/dev/parallel_cargo.py`
- `tools/dist/`

