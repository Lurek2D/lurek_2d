---
name: review-docstrings
description: "Review docstrings for specific module, on rust level evreything on methods, classes, objects, file level, ensure this follows practices and is being collected by scripts / tools."
---
# review-docstrings

## Goal
- Audit Rust docstrings to ensure comprehensive docs-general that tooling can extract.

## Required inputs
- Target module
- User must provide the module to inspect
- Agent must collect Rust docstring standards and generator expectations

## Profile hint
- `reviewer`

## Read these contracts
- `AGENTS.md`
- `src/lua_api/AGENTS.md`

## Steps
- Read the listed contracts and stay in read-only mode.
- Run `python tools/audit/docstring_audit.py` for the selected module and inspect missing, stale, or malformed docstrings.
- Compare the Rust source comments under `src/` and `src/lua_api/` with the generated docs or docstring expectations.
- Record findings first, with severity and exact file or line evidence where possible.
- Return a binary accept or reject decision with explicit follow-up gate conditions.

## Outputs
- Findings-first review report
- File and line evidence
- Accept or reject decision with follow-up conditions

## Success criteria
- The review stays read-only unless the user explicitly expands scope to include fixes.
- The output lists concrete findings and an explicit gate condition.
- The decision is binary and supported by evidence.

## Stop conditions
- Do not mutate source or write tests during pure review work.
- Do not return vague opinions without file-backed evidence.
- Do not merge review and implementation into the same pass unless the user explicitly asks for both.

## References
- `contracts: AGENTS.md, src/lua_api/AGENTS.md`
- `tools: python tools/audit/docstring_audit.py, cargo test`
- `agent: Doc-Writer`


