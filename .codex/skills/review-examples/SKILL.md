---
name: review-examples
description: "Review example coverage and fix all the gaps, ensure all practices are followed."
---
# review-examples

## Goal
- Audit `content/examples/` to ensure every public Lua API is demonstrated correctly.

## Required inputs
- Target module or full codebase
- User defines the scope of the example review
- Agent must collect output from `python tools/audit/example_coverage.py`

## Profile hint
- `content`

## Read these contracts
- `AGENTS.md`
- `content/AGENTS.md`
- `content/examples/AGENTS.md`

## Steps
- Read the listed contracts and stay in read-only mode.
- Run `python tools/audit/example_coverage.py --module <module>` for the selected scope and inspect the uncovered example list.
- Cross-check the example scripts under `content/examples/` against the current API documentation and module contracts.
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
- `contracts: AGENTS.md, content/AGENTS.md, content/examples/AGENTS.md`
- `tools: python tools/audit/example_coverage.py, python tools/validate/validate_example_coverage.py`
- `agent: content`


