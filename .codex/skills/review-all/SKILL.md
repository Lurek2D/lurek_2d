---
name: review-all
description: "Perform all below reviews one by one."
---
# review-all

## Goal
- Execute a comprehensive suite of review prompts sequentially to ensure full repository health.

## Required inputs
- Target module or entire repo scope
- User specifies the scope of the full review sweep
- Agent must collect the list of all review prompts

## Profile hint
- `reviewer`

## Read these contracts
- `AGENTS.md`
- `tools/AGENTS.md`

## Steps
- Read the listed contracts and stay in read-only mode.
- Run the full review sequence in this order: `review-api`, `review-architecture`, `review-docstrings`, `review-examples`, `review-performance`, `review-quality`, `review-specs`, and `review-tests`.
- For each review, run the associated audit or generator, then inspect the changed files and the current source or docs state that the audit covers.
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
- `contracts: AGENTS.md, tools/AGENTS.md`
- `skills: review-api, review-architecture, review-docstrings, review-examples, review-performance, review-quality, review-specs, review-tests`
- `agent: Verifier`


