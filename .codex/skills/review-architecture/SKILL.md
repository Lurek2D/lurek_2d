---
name: review-architecture
description: "Review if docs in architecture are in sync with specs and lurek api, fix all gaps."
---
# review-architecture

## Goal
- Validate that high-level architecture documents align with module specs and the actual API surface.

## Required inputs
- Entire codebase context
- User triggers the architecture review
- Agent must collect `docs/architecture/` files, specs, and API definitions

## Profile hint
- `reviewer`

## Read these contracts
- `AGENTS.md`
- `docs/AGENTS.md`
- `docs/architecture/AGENTS.md`

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
- `contracts: AGENTS.md, docs/AGENTS.md, docs/architecture/AGENTS.md`
- `tools: python tools/audit/cag_link_check.py`
- `agent: Architect`


