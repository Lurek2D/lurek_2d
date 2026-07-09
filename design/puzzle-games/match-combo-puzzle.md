# Match-Combo Puzzle

## Design target

A technical game design document for a marketable 2D Match-Combo Puzzle built with Lurek2D. The design target is board cascades, move validation, goal pressure, and readable combo feedback, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Match-Combo Puzzle should be positioned as a focused puzzle games entry about board cascades, move validation, goal pressure, and readable combo feedback. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Board rendering | `lurek.render`, `lurek.tween`, `lurek.animation` | For Match-Combo Puzzle, this area covers board rendering from the current design; it should support board cascades, move validation, goal pressure, and readable combo feedback. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for clips chosen from resolved state, never as the source of gameplay authority. |
| Grid rules | `lurek.math`, `lurek.patterns`, `lurek.serialize` | For Match-Combo Puzzle, this area covers grid rules from the current design; it should support board cascades, move validation, goal pressure, and readable combo feedback. Use it for vectors, geometry, seeded randomness, curves, and numeric rule helpers. Use it for state machines, rule phases, command patterns, and undoable transition models. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| UI and effects | `lurek.ui`, `lurek.particle`, `lurek.audio`, `lurek.effect` | For Match-Combo Puzzle, this area covers ui and effects from the current design; it should support board cascades, move validation, goal pressure, and readable combo feedback. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. Use it for screen-space feedback such as flashes, hit emphasis, palette shifts, or readability passes. |
| Goals/progression | `lurek.save`, `lurek.dataframe`, `lurek.filesystem` | For Match-Combo Puzzle, this area covers goals/progression from the current design; it should support board cascades, move validation, goal pressure, and readable combo feedback. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. |
| Board rules and undoable phases | `lurek.patterns`, `lurek.event`, `lurek.serialize` | For Match-Combo Puzzle, this area covers representing moves, cascades, resets, hints, and solved checks as traceable transitions; it should support board cascades, move validation, goal pressure, and readable combo feedback. Use it for state machines, rule phases, command patterns, and undoable transition models. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Grid facts and spatial constraints | `lurek.tilefield`, `lurek.physics`, `lurek.pathfind` | For Match-Combo Puzzle, this area covers validating blocked cells, push paths, sensor contacts, or reachable targets against authoritative state; it should support board cascades, move validation, goal pressure, and readable combo feedback. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it for collision, sensor, sweep, overlap, and contact queries while domain systems decide outcomes. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. |
| Puzzle clarity and feedback | `lurek.render`, `lurek.animation`, `lurek.audio` | For Match-Combo Puzzle, this area covers highlighting cause and effect after rules resolve rather than using effects as rule state; it should support board cascades, move validation, goal pressure, and readable combo feedback. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Scene ownership and mode boundaries | `lurek.scene` | For Match-Combo Puzzle, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support board cascades, move validation, goal pressure, and readable combo feedback. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Match-Combo Puzzle, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support board cascades, move validation, goal pressure, and readable combo feedback. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Match-Combo Puzzle, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support board cascades, move validation, goal pressure, and readable combo feedback. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Match-Combo Puzzle, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support board cascades, move validation, goal pressure, and readable combo feedback. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Match-Combo Puzzle, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support board cascades, move validation, goal pressure, and readable combo feedback. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Match-Combo Puzzle, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support board cascades, move validation, goal pressure, and readable combo feedback. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Match-Combo Puzzle, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support board cascades, move validation, goal pressure, and readable combo feedback. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Match-Combo Puzzle, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support board cascades, move validation, goal pressure, and readable combo feedback. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Match-Combo Puzzle, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support board cascades, move validation, goal pressure, and readable combo feedback. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Match-Combo Puzzle state should center on board cascades, move validation, goal pressure, and readable combo feedback. Treat cells as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Match-Combo Puzzle state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for match-combo puzzle previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Match-Combo Puzzle into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where cells, pieces, swaps, blockers, goals, cascades, boosters, and level results need stable identity across several systems. Single-purpose values can stay in domain tables, but any match-combo puzzle object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Match-Combo Puzzle is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/match_combo_puzzle/main.lua` - owns match-combo puzzle callback handoff and startup wiring.
- `content/games/match_combo_puzzle/conf.toml` - owns match-combo puzzle window, input, asset, and runtime defaults.
- `content/games/match_combo_puzzle/data/match_combo_puzzle_rules.toml` - owns match-combo puzzle authored rules for board cascades, move validation, goal pressure, and readable combo feedback.
- `content/games/match_combo_puzzle/data/cells.toml` - owns match-combo puzzle content records for cells.
- `content/games/match_combo_puzzle/scripts/scenes/match_combo_puzzle_play.lua` - owns match-combo puzzle scene-local orchestration and pause/result transitions.
- `content/games/match_combo_puzzle/scripts/systems/match_combo_puzzle_state.lua` - owns match-combo puzzle authoritative state containers and domain update order.
- `content/games/match_combo_puzzle/scripts/systems/match_combo_puzzle_validation.lua` - owns match-combo puzzle data integrity checks before content enters a run.
- `content/games/match_combo_puzzle/scripts/ui/match_combo_puzzle_hud.lua` - owns match-combo puzzle HUD, inspector, prompt, and accessibility surfaces.
- `content/games/match_combo_puzzle/assets/match_combo_puzzle/` - owns match-combo puzzle media grouped by stable asset IDs.

## Game structure

Match-Combo Puzzle should be built as a set of named domain services rather than one large gameplay script.

- `match_combo_puzzle_state` owns durable cells, pieces, and swaps records.
- `match_combo_puzzle_rules` validates commands, applies board cascades, move validation, goal pressure, and readable combo feedback, and emits deterministic events.
- `match_combo_puzzle_content` loads tables, checks IDs, and reports missing media before play starts.
- `match_combo_puzzle_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `match_combo_puzzle_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `match_combo_puzzle_debug` exposes blockers, goals, and cascades in overlays without mutating shipped state.

## Data and content model

- `cells_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `cells_table` data should live in `data/` and be validated before Match-Combo Puzzle enters active play.
- `pieces_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `pieces_table` data should live in `data/` and be validated before Match-Combo Puzzle enters active play.
- `swaps_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `swaps_table` data should live in `data/` and be validated before Match-Combo Puzzle enters active play.
- Match-Combo Puzzle save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Match-Combo Puzzle content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate match-combo puzzle setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for cells, pieces, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for board cascades, move validation, goal pressure, and readable combo feedback; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Match-Combo Puzzle tests can run without presentation timing.

## Vertical slice acceptance

The slice should include 20 levels, swap input, match-3 clear, cascades, one special piece, one blocker, score, goals, fail/win screens, and save progression.

## Risks

The risk is random unfairness. Use seedable board generation, dead-board detection, and level-specific spawn weights. Show enough information for the player to trust cascades.
