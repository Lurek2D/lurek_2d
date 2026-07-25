# Contributing to Lurek2D

Lurek2D is a desktop-only 2D engine written in Rust that runs Lua game scripts. Start with [docs/contributing/index.md](docs/contributing/index.md) for the contributor doc map, then read [docs/architecture/philosophy.md](docs/architecture/philosophy.md), [docs/architecture/engine-core.md](docs/architecture/engine-core.md), and [docs/architecture/docs-system.md](docs/architecture/docs-system.md) before making structural or documentation-flow changes.

---

## Setup

**Prerequisites**: Rust stable â‰Ą 1.78, Cargo, Python 3.10+ (for tooling scripts).

```bash
git clone https://github.com/LurekDude/lurek_2d.git
cd lurek_2d
python tools/dev/parallel_cargo.py build debug  # debug build â†’ build/debug/lurek2d
python tools/dev/parallel_cargo.py run debug -- lurek_2d_content/games/music_composer  # verify it works
```

Release build:

```bash
python tools/dev/parallel_cargo.py build release  # â†’ build/release/lurek2d (~10 MB)
```

The build output directory is `build/` (not `target/`) â€” configured via `.cargo/config.toml`.

Rust/build config files are split into two buckets:

- **Fixed-location files** required by tooling: `Cargo.toml`, `build.rs`, `rust-toolchain.toml`, `Cargo.lock`, and `.cargo/config.toml` stay where Cargo/rustup expect them.
- **Cargo-discovered support config** also lives under `.cargo/`; for example, `cargo-nextest` reads `.cargo/nextest.toml`.

Do **not** move the fixed-location files into a custom `config/` folder â€” Cargo and rustup will stop discovering them.

---

## Quality Gates

Run before every pull request:

```bash
python tools/dev/parallel_cargo.py fmt check
python tools/dev/parallel_cargo.py clippy --deny-warnings
python tools/dev/parallel_cargo.py test rust-full
```

During development, prefer scoped commands to avoid saturating CPU:

```bash
python tools/dev/parallel_cargo.py check   # type-check only (~2â€“5 s incremental)
python tools/dev/parallel_cargo.py test rust                    # fast Rust suite (excludes slow load/smoke)
python tools/dev/parallel_cargo.py test target <module>_tests  # one Rust test suite
python tools/dev/parallel_cargo.py test lua                     # Lua test suite
python tools/dev/parallel_cargo.py clippy --deny-warnings       # strict lint
```

If you use `cargo nextest`, the repository config is at `.cargo/nextest.toml`.

---

## Contributing to Different Areas

### Engine (Rust source â€” `src/`)

- Read `docs/specs/<module>.md` and the matching architecture docs before touching a module â€” they carry the current public contract and design rules.
- No `unsafe` without a `// SAFETY:` comment explaining the invariant.
- Per-frame code must not heap-allocate â€” grow buffers at startup.
- Add `///` doc-comments to every new `pub` item. Verify: `python tools/validate/validate_rust_source_docs.py` must exit 0.
- Use `log::info!` / `log::debug!` / `log::warn!` / `log::error!` â€” never `println!`.
- No `.unwrap()` or `.expect()` in production paths â€” use `?` or return a `LuaError`.
- Regenerate API docs after any `lurek.*` binding change: `python tools/gen_all_docs.py`.

### Tests (`tests/`)

Lurek2D has two test layers â€” both run **headless** (no window, GPU, or audio device needed):

**Rust tests** (`tests/rust/`):

```bash
cargo test --test <module>_tests -- --nocapture
```

- Name tests `<subject>_<scenario>_<expected>` â€” no `test_` prefix.
- Float comparisons: `assert!((val - expected).abs() < 1e-5)` â€” never `assert_eq!` on floats.
- Bug fixes require a regression test first.

**Lua BDD tests** (`tests/lua/`):

```bash
cargo test lua_test_<category>_<name> -- --nocapture
```

- Use `describe` / `it` / `expect_equal` / `expect_error` from `tests/lua/init.lua`.
- Every file must end with `test_summary()`.
- New `.lua` test file â†’ add a matching `#[test] fn lua_test_<category>_<name>()` in `tests/lua/harness.rs`.
- Lua tests must not call GPU, audio, or window APIs.
- New `lurek.*` functions need at least one Lua test before merge.

### Demos (`lurek_2d_content/games/`)

Demos are playable projects kept directly under `lurek_2d_content/games/<name>/`.

- Each demo needs: `main.lua`, `conf.lua` (optional), `README.md`, `screen.png`.
- Every demo may provide a colocated `lurek_2d_content/games/**/test.lua` headless test.
- Register new demos in `lurek_2d_content/games/README.md`.
- Demos must run with `python tools/dev/parallel_cargo.py run debug -- lurek_2d_content/games/<name>` and exit cleanly.
- Use `library/` modules and `lurek.*` API â€” no engine Rust internals.

### API Examples (`content/examples/`)

Examples are single-file documentation scripts â€” one per `lurek.*` module.

- One script, one module, one concept. Keep it under ~80 lines where possible.
- No external assets unless strictly necessary.
- Must be runnable: `python tools/dev/parallel_cargo.py run debug -- content/examples/<module>.lua`.
- Batch-run all examples through the real engine with `python tools/demos/smoke_sweep.py --kind example` or the `â–¶ Run: Examples Sweep (Debug)` VS Code task.
- Add a line to `content/examples/README.md` describing what it demonstrates.

### Lua Libraries (`lurek_2d_content/library/`)

Libraries are pure-Lua game-mechanics modules with no Rust internals.

- May only call `lurek.*` public API â€” never `require` engine internals.
- Each library lives in its own subfolder with `init.lua` and a `README.md`.
- Add tests under `tests/lua/library/test_<name>.lua`.
- Keep libraries self-contained â€” minimal cross-library dependencies.

### VS Code Extension (`lurek_2d_extension/`)

See [`lurek_2d_extension/README.md`](lurek_2d_extension/README.md) and [Developer Ecosystem Architecture](docs/architecture/developer-ecosystem.md).

- TypeScript source is in `lurek_2d_extension/src/`.
- The extension reads API data from `docs/` â€” regenerate with `python tools/gen_all_docs.py` after engine API changes.
- Test the extension with `F5` launch in VS Code (Extension Development Host).
- Keep MCP server endpoints in sync with engine API additions.

### CAG Layer (`.codex/` and `AGENTS.md`)

The `.codex/` directory contains active roles, skills, coverage, and shared Codex workspace guidance.

- Validate after every edit: `tools/python.cmd tools/validate/cag_validate.py`.
- Agent files live in `.codex/agents/`, skills in `.codex/skills/<name>/SKILL.md`.
- Follow [.codex/README.md](.codex/README.md) and the nearest `AGENTS.md`.

---

## Documentation

- Update `docs/specs/<module>.md` and the relevant `docs/architecture/*.md` files when public APIs or behavior change.
- Update `docs/CHANGELOG.md` for every code, API, or tooling change (required for every commit).
- Regenerate generated reference files: `python tools/gen_all_docs.py`.
- Verify doc coverage: `python tools/audit/doc_coverage.py`.

---

## Pull Requests

- Keep changes focused â€” one logical change per PR.
- Describe user-visible behavior, test coverage, and scope limits in the PR description.
- Stage only files directly changed by the task â€” never `git add .`.
- Commit format: `type(scope): description` (types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`).
- Security issues: follow [SECURITY.md](SECURITY.md) â€” do not post exploit details publicly.


