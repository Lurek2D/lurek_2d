# AI Contract

Covers work under `src/ai/`.

## Mission
- Own game-facing AI decision systems, world and agent wiring, and the boundary between behavior logic and pathfinding.

## Scope
- `src/ai/` behavior and world wiring.

## Local map
- `docs/specs/ai.md` defines the AI contract.
- `src/lua_api/ai_api.rs` is the Lua-facing edge.
- `tests/lua/unit/test_ai_core_unit.lua` is the first regression target.
- `docs/specs/pathfind.md` covers route search.

## Rules
- Keep world ownership explicit.
- Preserve FSM lifecycle ordering.
- Use FSMs for compact state machines and behavior trees for deeper hierarchy.
- Keep steering independent from high-level decision models.
- `pathfind` owns route search; `ai` owns decision-making and behavior composition.
- Cover idle, chase, lose-target, reset, empty-world, and conflicting-goal cases when changing common flows.

## Workflow
- Read `docs/specs/ai.md` and the matching Lua API before changing agent lifecycle or behavior composition.
- Use the existing Lua AI tests as the first regression target.

## References
- `docs/specs/ai.md`
- `src/lua_api/ai_api.rs`
- `tests/lua/unit/test_ai_core_unit.lua`
- `docs/specs/pathfind.md`
