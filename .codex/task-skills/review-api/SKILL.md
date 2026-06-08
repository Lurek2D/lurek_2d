---
name: review-api
description: "Review lua api coverage (if public rust methods are covered by lua api wrapper, if they have properly thin layer, have proper paramers, returns, description all setup in code in lua_api module), fix all the gaps."
---
# review-api

## Goal
- Audit the Lua API bridge for completeness, "thin wrapper" compliance, and correctness.

## Required inputs
- Target module
- User specifies the module to review
- Agent must collect Rust source public methods and their Lua API counterparts

## Profile hint
- `reviewer`

## Load these skills
- `reviewer-gate`
- `lua-api-design`
- `lua-rust-bridge`

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
- `skills: lua-api-design, lua-rust-bridge`
- `tools: python tools/audit/lua_covers_lurek_api_audit.py, python tools/audit/thin_wrapper_audit.py`
- `agent: Lua-Designer`

## Invocation rules
- This is a user-invoked workflow. Do not auto-load it as a generic background skill.
- Start only after the user explicitly requests this named workflow or a clearly equivalent task.

