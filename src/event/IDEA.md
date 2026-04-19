# IDEA — `src/event/`

> **This file is forward-looking.** It records ideas, not commitments.

---

## 1. Header

- **Module**: `event`
- **Owner module path**: `src/event/`
- **Last reviewed**: 2026-04-18 (UTC)
- **Reviewer agent**: `developer` · Session: `src-module-review-20260418`
- **Plugin tier candidacy**: `CORE-KEEP`
- **LOC (rust only)**: ~370 · **Public Lua surface**: `lurek.event` — 14 fns / 1 userdata (Signal)
- **Inbound non-`lua_api` callers**: `app` (pushes OS events), `automation` (injects synthetic events)
- **Heavy dependencies**: `none` (only `mlua` for Lua conversion helpers)

## 2. Mission Summary

The `event` module provides Lurek2D's centralised event queue and handle-based signal dispatcher. It serves EngDev (OS event routing), GameDev (custom game events and pub-sub), and GameTest (event injection and history). It is NOT a full ECS event system — it is a flat FIFO queue with optional pub-sub overlay.

## 3. Existing Strengths

- Simple, flat `Event { name, args }` design avoids type-system complexity; any event is a string + args.
- `Signal` provides decoupled pub-sub with wildcard pattern matching (`"damage.*"` etc.) in `signal.rs`.
- Double-buffered queue prevents re-entrant dispatch hazards within a single tick.
- `wait()` with timeout enables coroutine-based event consumption patterns.

## 4. Gap List

1. **[P2][GAP]** No event priority / ordering guarantee beyond FIFO — high-priority events (e.g. quit) wait behind low-priority ones.
   - Why: Engine exit can be delayed by a frame of buffered input events.
2. **[P3][GAP]** No typed event payload — all args are `EventArg` (string/number/bool/nil), no table support.
   - Why: GameDev passing complex data must serialize to string and back.

## 5. Feature Ideas

1. **[P3][FEAT]** Priority event lanes — separate high/normal queues; high-priority events always drain first.
   - Rationale: Ensures engine-critical events (quit, resize) process before input flood.
   - Effort: S · Risk: low.
2. **[P3][FEAT]** Table-valued `EventArg` variant — allow Lua tables as event payloads via shallow clone.
   - Rationale: Eliminates serialize/deserialize overhead for complex event data.
   - Effort: M · Risk: med (must not hold Lua references across frames).
   - Competitor inspiration: [love2d: "love.event.push supports any number of arguments" — https://love2d.org/wiki/love.event.push]

## 6. Performance / Reliability / Quality Ideas

- **[P3][PERF]** `wait()` uses 1ms spin-sleep — replace with condvar for zero-CPU blocking.
  - Hot path: `event_queue.rs:wait`.
  - Verification: measure CPU usage during `lurek.event.wait(10)`.
- **[P3][QUAL]** `pump()` is a no-op stub — consider removing or documenting as API-parity-only.
  - File / type: `event_queue.rs:EventQueue::pump`.
  - Reason: dead code creates confusion about whether OS event pump is needed.

## 7. Test Coverage Gaps

- **[P2][TEST-RUST]** Expand `glob_match` tests in `signal.rs` — add multi-star, adjacent-star, and empty-pattern cases.
- **[P2][TEST-LUA]** Add Lua BDD test for `lurek.event.pushDeferred` + `flushDeferred` cycle.

## 8. TODO(dedup): Cross-Module Overlap

TODO(dedup): thread::Channel — Channel and EventQueue both provide FIFO value queues with blocking wait; EventQueue is single-threaded while Channel is cross-thread. Consider whether EventQueue should wrap a Channel internally.

## 9. TODO(helper): Engine-Level Helper Candidates

(n/a — event API patterns are straightforward)

## 10. TODO(plugin): Plugin Candidacy Proposal

TODO(plugin): CORE-KEEP — the event queue is the central dispatch hub; every input, window, and automation event flows through it. Cannot be extracted without breaking the engine loop.
- **Extraction blockers**: `EventQueue` in `SharedState`; `app` directly pushes events.
- **Heavy dep impact if extracted**: n/a.
- **Lua surface stability**: stable.
- **Migration step**: n/a.

## 11. References

- Module spec: [docs/specs/event.md](../../docs/specs/event.md)
- Lua API reference: [docs/API/lua-api.md#event](../../docs/API/lua-api.md)
- Plugin doc tier table: [plugins.md §5](../../docs/architecture/plugins.md#5-candidate-modules)
- Competitor links cited above: https://love2d.org/wiki/love.event.push
- Authoring guide: [IDEA_AUTHORING.md](../../work/src-module-review-20260418/reports/IDEA_AUTHORING.md)
