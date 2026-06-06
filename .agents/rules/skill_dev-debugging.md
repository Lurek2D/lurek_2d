---
trigger: model_decision
description: "Load this skill when diagnosing runtime bugs, crashes, or wrong behavior in Lurek2D. Skip it for feature work or test writing."
---
# dev-debugging

## Mission
- Own runtime diagnosis, repro building, and root-cause reporting.

## When To Load
- Investigate a crash.
- Investigate wrong runtime behavior.
- Read logs and traces.
- Build a small repro.

## When To Skip
- Feature implementation.
- Test authoring.

## Domain Knowledge
- Start from an existing failing script or fixture before reading src/. `tests/lua/`, `content/games/`, and `save/` already contain repro anchors.
- Common failure surfaces in this repo, in order of frequency: `RefCell::borrow_mut()` panic inside a Lua callback, stale registry key after a scene reload, wrong callback ordering between `process` and `render`, RunState transition skipping an init step, and channel drop causing silent loss of a thread result.
- To trace a Lua-boundary crash: find the Lua call in logs, then find the corresponding `*_api.rs` binding, then trace from there into `src/<module>/`. Stop at the first concrete control path that explains the symptom.
- To trace a render glitch: find which `RenderCommand` variant is wrong or missing in the command buffer log. Then find where that command is pushed.
- Use `tools/audit/parse_test_log.py` for harness failures — it extracts structured pass/fail context from the Lua test harness output. Do not scroll raw cargo test output for Lua failures.
- Separate failure classes before forming hypotheses: crash, wrong result, missing side effect, stale state, race, and backend-specific. Each implies a different first check.
- Build the smallest deterministic repro first: one Lua test, one content/games/ main.lua, or one Rust test that reliably reproduces. Write it under `work/{session}/scripts/` so it survives the session.
- When a bug crosses the Lua boundary, compare `docs/specs/<module>.md` Lua API section against the binding in `src/lua_api/<module>_api.rs` first. Spec drift — where the doc says one thing and the binding does another — is a common root cause.
- For save-file or filesystem-triggered bugs, note the exact save path relative to the GameFS root, the triggering operation, and the visible symptom before reading any src/ code.
- Confidence marking rule: CONFIRMED = demonstrated by a single test that fails and passes in controlled conditions. LIKELY = two independent signals point to the same cause.
- Check Clippy output after reproducing, because sometimes the root cause is a known pattern that Clippy would already flag.
## Companion File Index
- None.

## References
- logs/
- tests/
- src/
- tools/audit/parse_test_log.py