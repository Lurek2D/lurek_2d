---
name: review-quality
description: "Review overall code quality using tools/audit/quality_report.py."
---
# review-quality

## Goal
- Perform a holistic quality review of the codebase using comprehensive reporting tools.

## Required inputs
- Target module or full codebase
- User triggers the general quality audit
- Agent must collect output from `quality_report.py`

## Profile hint
- `reviewer`

## Read these contracts
- `AGENTS.md`
- `src/AGENTS.md`
- `tools/AGENTS.md`

## Steps
- Read the listed contracts and stay in read-only mode.
- Inspect the target scope and run the referenced checks or audits.
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
- `contracts: AGENTS.md, src/AGENTS.md, tools/AGENTS.md`
- `tools: python tools/audit/quality_report.py, cargo clippy`
- `agent: Verifier`


