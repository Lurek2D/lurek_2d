# AI Contract

This file adds local rules for work under `src/ai/`.

## Mission
- Own game-facing AI decision systems, world and agent wiring, and the boundary between behavior logic and pathfinding.

## Local rules
- Keep world ownership explicit: scene code should drive one AI world update path rather than scattering agent updates.
- Preserve the existing FSM lifecycle ordering when changing transitions or state hooks.
- Use FSMs for compact, predictable state machines and behavior trees for deeper hierarchical behavior rather than mixing both without a clear reason.
- Keep steering movement independent from high-level decision models so it can be attached or replaced without rewriting the behavior layer.
- `pathfind` owns route search; `ai` owns decision-making and behavior composition. Do not let pathfinding concerns swallow agent logic or vice versa.
- When changing common decision flows, cover edge states such as idle, chase, lose-target, reset, empty-world, and conflicting-goal scenarios.

## Workflow
- Read `docs/specs/ai.md` and the matching Lua API before changing agent lifecycle or behavior composition.
- Use the existing Lua AI tests as the first regression target for behavioral changes.

## References
- `docs/specs/ai.md`
- `src/lua_api/ai_api.rs`
- `tests/lua/unit/test_ai_core_unit.lua`
- `docs/specs/pathfind.md`
