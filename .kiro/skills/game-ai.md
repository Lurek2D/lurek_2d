---
inclusion: manual
---

# game-ai

## Mission
Own game-facing AI patterns built on `lurek.ai.*`.

## When To Use
- Design or write FSM, BT, GOAP, steering, or utility AI.
- Build enemy or NPC behavior.
- Connect AI to game actions.

## When To Skip
- Rust AI internals, pathfinding algorithm work.

## Rules

### Wiring Up
Call `lurek.ai.newWorld()` once per scene, `world:addAgent("name")` for each agent, then drive from `lurek.process(dt)` by calling `world:update(dt)`.

### FSM Update Cycle
1. Check all transitions from current state in descending priority order.
2. Fire the first whose guard returns true.
3. Call `on_exit` on the old state, reset `time_in_state`, call `on_enter` on new state.
4. Call `on_update(dt)` on the current state.

To add a transition: `fsm:addTransition("from", "to", guardFn, priority)`.

### Blackboards
`src/ai/blackboard.rs` is a typed key-value store with parent chain lookup. An agent's blackboard looks up its parent (world global blackboard) when a key is not found locally. Writes always stay local. Three value types: `Number(f64)`, `Bool(bool)`, `Text(String)`.

### FSM vs BT Decision Rule
- Use FSMs for behaviors with fewer than ~8 states and predictable transitions.
- Use behavior trees when the behavior is hierarchical.
- Avoid mixing FSM and BT on the same agent — pick one model per agent.

### Steering and Squads
`lurek.ai.newSteeringAgent()` drives movement. Steering is independent of FSM/BT. Squads (`lurek.ai.newSquad()`) share a squad-level blackboard for formation or tactical data.

### Testing
Test edge states explicitly via `tests/lua/unit/test_ai_core_unit.lua`: idle, chase, lose-target, reset, empty world, conflicting goals, no-valid-action. These are headless — no window required.

### Pathfinding Separation
`pathfind` owns grid search and route math. `ai` owns decision-making and behavior composition. Never call pathfinding algorithms directly in an AI script; call `lurek.pathfind.findPath(world, x1, y1, x2, y2)` and use the returned waypoint list to set steering targets.

## References
- `docs/specs/ai.md`
- `src/lua_api/ai_api.rs`
- `tests/lua/unit/test_ai_core_unit.lua`
- `docs/specs/pathfind.md`
