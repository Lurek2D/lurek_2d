---
name: review-specs
description: "Regenerate specs via script, then explicitly review and rewrite the human Summary section for the selected module(s)."
---
# review-specs

## Goal
- Ensure module specifications are up-to-date with code reality and rewrite `## Summary` as a unique, user-oriented synopsis of the module's delivered functionality.

## Required inputs
- Target module
- User must define which module spec to review. Allowed values: a single module name (for example `agent`) or `all modules`.
- Agent must collect current source code vs existing spec state

## Profile hint
- `reviewer`

## Load these skills
- `reviewer-gate`
- `docs-general`
- `module-architecture`

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
- `skills: docs-general, module-architecture`
- `tools: python tools/docs/gen_module_specs.py, python tools/audit/lua_spec_coverage.py`
- `agent: Doc-Writer`

## Invocation rules
- This is a user-invoked workflow. Do not auto-load it as a generic background skill.
- Start only after the user explicitly requests this named workflow or a clearly equivalent task.

