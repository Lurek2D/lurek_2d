---
name: create-build
description: "Load this skill when changing Cargo profiles, Windows build scripts, package staging, installers, or game packaging. Skip it for engine runtime behavior, documentation-only work, or test code."
---

# create-build

## Mission
- Change the build or packaging pipeline and prove that the produced artifact works outside the source tree.

## Domain Knowledge
- `Cargo.toml` defines Cargo profiles and Rust test targets.
- `tools/dist/` owns release, staging, archive, installer, and game-package scripts.
- `tools/dev/` owns developer build helpers.
- `dist/` is generated output. It is not a policy owner.
- Lurek2D ships as one Rust executable with a Lua runtime.
- A package may also contain games, assets, Lua files, and native runtime files.
- `tools/dist/dist.ps1` is the distribution entry point.
- `tools/dist/pack.ps1` and `tools/dist/pack.py` build package layouts.
- `tools/dist/package_games.py` packages game content.
- A named Cargo profile can inherit from another profile.
- The packaging script must use the same profile whose artifact it stages.
- LTO, codegen units, stripping, panic mode, and debug symbols change size, speed, build time, or diagnostics.
- A successful developer-tree launch does not prove package correctness.
- Package paths must be relative and stable.
- Archive ordering must be deterministic.
- A failed package run must not publish a partial final archive.
- Windows is the primary local automation platform for this repo.
- A `.lurek` game package is a standard ZIP archive with no top-level directory.
- A packaged game must contain root-level `main.lua`; `conf.toml`, `README.md`, and `screen.png` are included when present.
- Recognized package subfolders include `assets`, `fonts`, `sounds`, `music`, `images`, `sprites`, `maps`, `data`, `shaders`, `levels`, `lib`, and `modules`.
- Release output includes a portable Windows ZIP and may include an NSIS installer and VSIX.
- `tools/dist/release.ps1` assembles publishable files under `dist/github-release/`.
- Release artifacts are accompanied by lowercase SHA-256 entries in `checksums-sha256.txt`.

## Workflow
1. Read `AGENTS.md` and `tools/AGENTS.md`.
2. Query RAG for the profile, script, or package type.
3. Identify the owning entry point in `Cargo.toml`, `tools/dist/`, or `tools/dev/`.
4. Record the exact current command.
5. Record build time, executable size, package size, and staged files when relevant.
6. Change only the owning profile or script.
7. Build with the exact target profile.
8. Stage a fresh package from that build.
9. Check required executable, game, asset, Lua, and runtime files.
10. Launch the staged executable without repository-relative files.
11. Run the changed packaging or installer path.
12. Test one missing-input case.
13. Confirm that failure is non-zero and names the missing path.
14. Run the package command again and check deterministic output.
15. Run `cargo clippy -- -D warnings` when shared Cargo settings changed.
16. Compare the result with the baseline and record the intended trade-off.

## References
- `contracts: AGENTS.md, tools/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "build profiles Cargo.toml release packaging" --profile engine --limit 10, cargo build --profile <profile>, cargo clippy -- -D warnings`
- `agent: builder`
- RAG: `build profiles Cargo.toml release packaging`; inspect `Cargo.toml`, `tools/dist/`, `tools/dev/`, and staged output.
