---
name: reviewer-gate
description: "Use this skill for read-only review, validation, verification, security/performance gate checks, and binary accept/reject decisions."
---
# reviewer-gate

## Use when
- The task is a review, audit, validation, check, or verification request.
- The user asks for findings, risks, acceptance conditions, or a read-only opinion.
- A workflow needs a final gate before closure.

## Avoid when
- The task is implementation-first and the user wants code changes immediately.
- The task requires writing tests or fixing production code as part of the same pass.

## Repo rules
- Treat review-only tasks as read-only unless the user explicitly expands scope to include fixes.
- Report findings first, ordered by severity, with exact file and line references when possible.
- Make the decision binary: accept or reject with explicit gate conditions.
- Check spec drift, architecture drift, and performance or security regressions when relevant.
- Do not write tests or mutate source during pure review work.

## Checks
- `cargo clippy -- -D warnings`
- `python tools/audit/quality_report.py`
- `python tools/audit/perf_regression_gate.py`
- `python tools/validate/cag_validate.py`

## References
- `AGENTS.md`
- `.codex/config.toml`
- `.codex/migration/map.md`
- `docs/specs/`
- `docs/architecture/`

