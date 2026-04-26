---
name: quality-pipeline
description: "Load this skill when running quality checks, audits, or doc generation for the Lurek2D engine. It owns the quality tool taxonomy, execution order, and interpretation of results. Skip it for writing code, tests, or documentation content."
---
# quality-pipeline

## Mission

Own the quality tool taxonomy (generators, validators, auditors, fixers), execution order, result interpretation, and tool selection guidance.

## When To Load

- Running pre-commit quality checks
- Choosing the right audit or validation tool for a task
- Understanding tool output and acting on findings
- Running the full documentation pipeline

## When To Skip

- Writing Rust code -> use rust-coding skill
- Writing tests -> use testing-rust skill
- Writing documentation -> use documentation skill

## Domain Knowledge

**Four tool categories:**

| Category | Purpose | Exit code | Location |
|----------|---------|-----------|----------|
| Generators | Produce JSON data and docs from source | 0 always | tools/docs/ |
| Validators | Check structure/schema, exit 1 on failure | 0=pass, 1=fail | tools/validate/ |
| Auditors | Measure quality metrics, report gaps | 0 (unless --strict/--threshold) | tools/audit/ |
| Fixers | Modify files in-place | 0 | tools/fix/ (always --dry-run first) |

**Quick quality check (every commit):** cargo test; cargo clippy -- -D warnings

**Standard pipeline (after API changes):** python tools/gen_all_docs.py (regenerates all docs), then python tools/validate/validate_generated_lua_stubs.py (verify stubs match), then python tools/audit/doc_coverage.py (measure coverage).

**Single module audit:** python tools/audit/audit_module.py NAME (12-phase check).

**Master dashboard:** python tools/audit/quality_report.py combines doc audit, test coverage, module audit, and game validation into one report.

**CAG layer validation:** python tools/validate/cag_validate.py (after .github/ changes).

**Library validation:** python tools/validate/validate_library.py --library NAME --strict (after library/ changes).

**Execution order rule:** always run generators before validators/auditors (generators produce the JSON that validators read).

## Companion File Index

None - all guidance is inline.

## References

- tools/README.md - complete tool registry with all scripts
- tools/gen_all_docs.py - pipeline orchestrator
- tools/audit/quality_report.py - master quality dashboard
