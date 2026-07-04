# Match-Combo Puzzle

**Category:** Puzzle games  
**Reference games:** Tetris Attack, Bejeweled, Puyo Puyo, Puzzle Quest  
**Document type:** Technical game design and architecture

## Design target

A grid-based matching puzzle where swaps, drops, clears, chains, scoring, hazards, and level goals create short-session depth. The architecture must separate grid logic from visual cascades.

## Market positioning

Use the reference set (Tetris Attack, Bejeweled, Puyo Puyo, Puzzle Quest) to define player expectations around pacing, readability, and production scope, not to copy mechanics directly. Target itch.io with a clean rule twist, immediate readability, and hand-authored levels. Target Steam with a level progression curve, hints/undo, editor-style validation tools, and content packs that scale without adding systemic ambiguity. For match-combo puzzle, the store page must communicate the core verb, session length, progression promise, and why the 2D presentation is intentional.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Board rendering | `lurek.render`, `lurek.tween`, `lurek.animation` |
| Grid rules | `lurek.math`, `lurek.patterns`, `lurek.serialize` |
| UI and effects | `lurek.ui`, `lurek.particle`, `lurek.audio`, `lurek.effect` |
| Goals/progression | `lurek.save`, `lurek.dataframe`, `lurek.filesystem` |

## Runtime architecture

Create a board state with cell contents, blockers, falling queue, active move, combo counter, score, goal counters, random seed, and phase. Board phases should be explicit: awaiting input, validating move, clearing, dropping, spawning, resolving chain, checking goal, game over.

The logical resolver should finish each phase before presentation catches up. The visual layer animates swaps, clears, falling pieces, score bursts, and effects based on phase events. This allows instant debugging, replay, and fast-forward.

Piece definitions should include color/type, match group, special behavior, spawn weight, blocker interaction, and score value. Level definitions should include board shape, move/time limit, goals, spawn table, initial blockers, and tutorial hints.

## Suggested project structure

```text
my_match_puzzle/
  data/levels.toml
  data/pieces.toml
  scripts/state/board.lua
  scripts/systems/match_resolver.lua
  scripts/systems/cascade.lua
  scripts/systems/scoring.lua
  scripts/ui/board_view.lua
  scripts/ui/goal_panel.lua
  assets/pieces/
```

## Data and content model

- Author level layouts, rule entities, goals, blockers, movable objects, and authored hints as data, not hidden script constants.
- Author undo stack, move counters, validation flags, completion stars, and level-pack progression as data, not hidden script constants.
- Author editor metadata, solution traces, tutorial messages, and accessibility settings as data, not hidden script constants.
- Keep match-combo puzzle content split between durable authored files under `data/`, media under `assets/`, and orchestration modules under `scripts/`.
- Save files should store player/world progress and stable identifiers, not transient render objects, cached paths, or UI widget instances.


## Technical design notes

- Use `lurek.scene` to separate level select, puzzle play, pause, and result screens.
- Keep puzzle state deterministic and serializable so undo, reset, hints, and validation can share the same state snapshots.
- Use `lurek.tilefield` for cell facts and `lurek.ui` for move counters, hint controls, level goals, and accessibility toggles.
- Use `lurek.save` for solved levels, stars, hints used, and level-pack progress.

## Vertical slice acceptance

The slice should include 20 levels, swap input, match-3 clear, cascades, one special piece, one blocker, score, goals, fail/win screens, and save progression.

## Risks

The risk is random unfairness. Use seedable board generation, dead-board detection, and level-specific spawn weights. Show enough information for the player to trust cascades.
