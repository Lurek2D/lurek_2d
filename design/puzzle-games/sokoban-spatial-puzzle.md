# Sokoban Spatial Puzzle

**Category:** Puzzle games  
**Reference games:** Sokoban, Baba Is You, Stephen's Sausage Roll, A Monster's Expedition  
**Document type:** Technical game design and architecture

## Design target

A deterministic grid puzzle where pushing, blocking, constraints, undo, and level validation matter more than animation. The game should support exact replay and rapid iteration on authored levels.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Grid levels | `lurek.tilemap`, `lurek.tilefield`, `lurek.filesystem` |
| Objects and rules | `lurek.ecs` or compact grid tables, `lurek.patterns` |
| Input/undo | `lurek.input`, `lurek.signal`, `lurek.serialize` |
| Presentation | `lurek.render`, `lurek.animation`, `lurek.tween`, `lurek.audio` |
| Progress | `lurek.save` for solved levels, best moves, unlocks |

## Runtime architecture

Use an authoritative grid state with object stacks per cell. A move request validates direction, target cell, pushed object chain, blockers, special rules, and win condition. If valid, it produces a transaction that can be appended to undo history.

Undo should restore logical state, not reverse animations. Store pre-move snapshots or inverse transactions. Animations consume the committed transaction and may lag behind logic, but input should wait or queue according to design policy.

Level data should include layout, object IDs, goal cells, rule modifiers, par move count, hints, and unlock dependencies. Validation tooling should catch unreachable goals, duplicate IDs, and missing win conditions.

## Suggested project structure

```text
my_sokoban/
  data/levels/*.txt
  data/worlds.toml
  scripts/state/grid_state.lua
  scripts/systems/move_resolver.lua
  scripts/systems/undo.lua
  scripts/systems/win_check.lua
  scripts/ui/level_select.lua
  assets/tiles/
```

## Vertical slice acceptance

The slice should include ten levels, push blocks, goals, walls, undo, restart, move counter, level select, solved-state save, and one special rule.

## Risks

The risk is desync between animation and logic. Commit logical moves atomically and let presentation follow. Never let tween completion decide puzzle truth.
