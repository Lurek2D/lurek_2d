# IDEA.md — `timer` module

> Migrated from `ideas/features/timer.md`.
> Status checked against `src/timer/` and `src/lua_api/timer_api.rs`.
> Lua namespace: `lurek.time`.

---

## Features

### 🤔 CONSIDER — Fixed Timestep Accumulator
**Source**: features/timer.md — Feature Gaps #3

No built-in fixed-timestep physics accumulator. Must implement manually in Lua.
Relevant if physics integration frequency need to be decoupled from render rate.
Low priority — rapier2d handles physics internally at a fixed step already.
