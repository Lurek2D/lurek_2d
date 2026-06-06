---
inclusion: manual
---

# quality-pipeline

## Mission
Own tool choice, run order, and result reading for quality work.

## When To Use
- Run pre-commit checks.
- Pick the right audit or validator.
- Read tool output.
- Run the full doc pipeline.

## When To Skip
- Writing Rust code, writing tests, writing docs.

## Rules

### Quality Gate Order
1. `python tools/dev/parallel_cargo.py fmt check` — formatting.
2. `python tools/dev/parallel_cargo.py clippy --deny-warnings` — zero-warning lint.
3. `python tools/dev/parallel_cargo.py test rust` — Rust tests.
4. `python tools/dev/parallel_cargo.py test lua` — Lua harness.
5. `python tools/gen_all_docs.py` — docs freshness.

Running out of order wastes time — fmt and clippy failures are cheap to fix early.

### Correct Entry Point by Change Type
- Lua API change → `python tools/validate/validate_generated_lua_stubs.py`
- Module structure change → `python tools/validate/validate_module_coverage.py`
- CAG file change → `python tools/validate/cag_validate.py`
- Library change → `python tools/docs/gen_lib_docs.py`

Running the full pipeline for a CAG-only change is unnecessary.

### quality_report.py
`python tools/audit/quality_report.py` outputs a module-by-module quality score. It is a routing signal, not a pass/fail gate. Modules with score < 70 are candidates for an audit task.

### Clippy Hard Gate
Every warning is a blocker. When Clippy emits a warning for intentional code, add a targeted `#[allow(clippy::...)]` with a `// Reason:` comment directly in the source file — never suppress categories repo-wide.

### Generated Files Must Be Committed
`docs/api/lurek.md`, `docs/api/lurek.lua`, `docs/api/lureksome.md` must be committed in the same PR as the source changes that produced them. CI catches stale generated files by running the generator and diffing.

### parallel_cargo.py
Prefer it over raw `cargo` commands for test, clippy, and fmt so output format stays stable and CI/local behavior is identical.

### Intermittent CI Failures
Most common causes: (1) non-deterministic Lua tests due to missing fixed seed, (2) generated docs differing by line ending (CRLF vs LF), (3) a test that reads wall-clock time.

### Full Quality Gate
Run the full Quality Gate task before any commit that touches multiple files. The sequence (fmt → clippy → tests) aborts at the first failure, so early failures are found first.

## References
- `tools/README.md`
- `tools/gen_all_docs.py`
- `tools/audit/quality_report.py`
- `tools/validate/`
