---
inclusion: manual
---

# dev-debugging

## Mission
Own runtime diagnosis, repro building, and root-cause reporting.

## When To Use
- Investigating a crash or wrong runtime behavior.
- Reading logs and traces.
- Building a small repro.

## When To Skip
- Feature implementation, test authoring.

## Rules

### Start Point
- Start from an existing failing script or fixture before reading `src/`. `tests/lua/`, `content/games/`, and `save/` already contain repro anchors. A narrowed Lua test is faster to isolate than re-reading large module trees.

### Common Failure Surfaces (in order of frequency)
1. `RefCell::borrow_mut()` panic inside a Lua callback — always check SharedState borrow scope first.
2. Stale registry key after a scene reload.
3. Wrong callback ordering between `process` and `render`.
4. `RunState` transition skipping an init step.
5. Channel drop causing silent loss of a thread result.

### Tracing Strategy
- **Lua-boundary crash**: find the Lua call in logs (`RUST_LOG=lurek2d::lua_api=debug`), find the `*_api.rs` binding, trace into `src/<module>/`. Stop at the first control path that explains the symptom.
- **Render glitch**: find which `RenderCommand` variant is wrong or missing (`RUST_LOG=lurek2d::render=trace`). Find where that command is pushed. Never start by reading the shader unless the command itself is correct.
- **Harness failures**: use `tools/audit/parse_test_log.py` — do not scroll raw `cargo test` output for Lua failures.

### Failure Classification
Separate before forming hypotheses: crash (panic/SIGSEGV), wrong result (logic), missing side effect (event never fired), stale state (old value persisted), race (non-deterministic), backend-specific (wgpu validation error). Each implies a different first check.

### Repro Building
- Build the smallest deterministic repro: one Lua test, one `content/games/main.lua`, or one Rust test.
- Write it under `work/{session}/scripts/` so it survives the session.
- A non-reproducible repro is not a repro.

### Spec Drift
- When a bug crosses the Lua boundary, compare `docs/specs/<module>.md` Lua API section against the binding in `src/lua_api/<module>_api.rs` first. Spec drift is a common root cause.

### Confidence Marking
- CONFIRMED = demonstrated by a single test that fails and passes in controlled conditions.
- LIKELY = two independent signals point to the same cause.
- SUSPECT = one signal that could have other explanations.
- Never report CONFIRMED without a passing fix or reproducer.

### After Reproducing
- Run `cargo clippy --all-targets -- -D warnings` — the root cause is sometimes a pattern Clippy already flags.

## References
- `logs/`
- `tests/`
- `src/`
- `tools/audit/parse_test_log.py`
