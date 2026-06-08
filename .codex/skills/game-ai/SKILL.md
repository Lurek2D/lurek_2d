---
name: game-ai
description: "Load this skill when designing or implementing lurek.ai.* game behavior like FSMs, behavior trees, GOAP, steering, or squad logic. Skip it for Rust AI internals or pathfinding algorithms."
---
# game-ai

## Use when
- Design or write FSM, BT, GOAP, steering, or utility AI.
- Build enemy or NPC behavior.
- Connect AI to game actions.

## Avoid when
- Rust AI internals.
- Pathfinding algorithm work.

## Repo rules
- How AI worlds and agents wire up: call `lurek.ai.newWorld()` once per scene, call `world:addAgent("name")` for each agent, then drive the whole world from `lurek.process(dt)` by calling `world:update(dt)`. The FSM/BT/GOAP decision model is assigned per-agent; it is not a global world setting.
- How FSMs work in code: `src/ai/fsm.rs` implements guarded priority transitions. The update cycle is: check all transitions from current state in descending priority order, fire the first whose guard returns true, call `on_exit` on the old state, reset `time_in_state`, call `on_enter` on the new state, call `on_update(dt)` on the current state.
- How blackboards work: `src/patterns/blackboard.rs` is a typed key-value store with parent chain lookup. An agent's blackboard looks up its parent when a key is not found locally.
- FSM vs BT decision rule: use FSMs for behaviors with fewer than ~8 states and predictable transitions. Use behavior trees when the behavior is hierarchical.
- Steering and squads: `lurek.ai.newSteeringAgent()` drives movement. Steering is independent of FSM/BT; attach it to any agent and call `agent:setSteeringTarget(x, y)` each frame.
- Test edge states explicitly via `tests/lua/unit/test_ai_core_unit.lua`: idle, chase, lose-target, reset, empty world, conflicting goals, no-valid-action. These are the common failure modes.
- `pathfind` owns grid search and route math. `ai` owns decision-making and behavior composition.

## Checks
- `Run the narrowest relevant validation for the touched files or workflow.`

## References
- `docs/specs/ai.md`
- `src/lua_api/ai_api.rs`
- `tests/lua/unit/test_ai_core_unit.lua`
- `docs/specs/pathfind.md`

