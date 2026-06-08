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

## Load these skills
- `reviewer-gate`
- `rust-coding`
- `docs-general`

## Steps
- Load the listed review skills and stay in read-only mode.
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
- `skills: rust-coding, docs-general`
- `tools: python tools/audit/docstring_audit.py, cargo test`
- `agent: Doc-Writer`

## Invocation rules
- This is a user-invoked workflow. Do not auto-load it as a generic background skill.
- Start only after the user explicitly requests this named workflow or a clearly equivalent task.

