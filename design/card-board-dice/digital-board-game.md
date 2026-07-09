# Digital Board Game

## Design target

A technical game design document for a marketable 2D Digital Board Game built with Lurek2D. The design target is board turns, piece movement, rule prompts, and replayable match state, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Digital Board Game should be positioned as a focused card board dice entry about board turns, piece movement, rule prompts, and replayable match state. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Board presentation | `lurek.render`, `lurek.tilemap`, `lurek.camera`, `lurek.ui` | For Digital Board Game, this area covers board presentation from the current design; it should support board turns, piece movement, rule prompts, and replayable match state. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Pieces/resources/cards | `lurek.ecs`, `lurek.serialize` | For Digital Board Game, this area covers pieces/resources/cards from the current design; it should support board turns, piece movement, rule prompts, and replayable match state. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Turn system | `lurek.patterns`, `lurek.event`, `lurek.timer` | For Digital Board Game, this area covers turn system from the current design; it should support board turns, piece movement, rule prompts, and replayable match state. Use it for state machines, rule phases, command patterns, and undoable transition models. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. |
| AI opponents | `lurek.ai` | For Digital Board Game, this area covers ai opponents from the current design; it should support board turns, piece movement, rule prompts, and replayable match state. Use it for inspectable decision scoring and scheduled planners. |
| Persistence | `lurek.save` | For Digital Board Game, this area covers persistence from the current design; it should support board turns, piece movement, rule prompts, and replayable match state. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Turn phases and rule stack | `lurek.patterns`, `lurek.timer`, `lurek.event` | For Digital Board Game, this area covers modeling draft, action, response, cleanup, and scoring phases as explicit state transitions; it should support board turns, piece movement, rule prompts, and replayable match state. Use it for state machines, rule phases, command patterns, and undoable transition models. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Cards, boards, and token presentation | `lurek.sprite`, `lurek.ui`, `lurek.render` | For Digital Board Game, this area covers drawing hands, pieces, prompts, legal targets, and resolved effects from rule state; it should support board turns, piece movement, rule prompts, and replayable match state. Use it for sprite sheets, atlases, character frames, cards, pieces, and marker presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. |
| Rule data and replay checks | `lurek.dataframe`, `lurek.serialize`, `lurek.save` | For Digital Board Game, this area covers validating card or board records and keeping match replays separate from profile progression; it should support board turns, piece movement, rule prompts, and replayable match state. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Scene ownership and mode boundaries | `lurek.scene` | For Digital Board Game, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support board turns, piece movement, rule prompts, and replayable match state. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Digital Board Game, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support board turns, piece movement, rule prompts, and replayable match state. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Digital Board Game, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support board turns, piece movement, rule prompts, and replayable match state. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Digital Board Game, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support board turns, piece movement, rule prompts, and replayable match state. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Digital Board Game, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support board turns, piece movement, rule prompts, and replayable match state. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Digital Board Game, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support board turns, piece movement, rule prompts, and replayable match state. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Digital Board Game, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support board turns, piece movement, rule prompts, and replayable match state. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Digital Board Game, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support board turns, piece movement, rule prompts, and replayable match state. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Digital Board Game, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support board turns, piece movement, rule prompts, and replayable match state. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Digital Board Game state should center on board turns, piece movement, rule prompts, and replayable match state. Treat pieces as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Digital Board Game state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for digital board game previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Digital Board Game into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where pieces, tiles, cards, dice, players, turn markers, and pending effects need stable identity across several systems. Single-purpose values can stay in domain tables, but any digital board game object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Digital Board Game is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/digital_board_game/main.lua` - owns digital board game callback handoff and startup wiring.
- `content/games/digital_board_game/conf.toml` - owns digital board game window, input, asset, and runtime defaults.
- `content/games/digital_board_game/data/digital_board_game_rules.toml` - owns digital board game authored rules for board turns, piece movement, rule prompts, and replayable match state.
- `content/games/digital_board_game/data/pieces.toml` - owns digital board game content records for pieces.
- `content/games/digital_board_game/scripts/scenes/digital_board_game_play.lua` - owns digital board game scene-local orchestration and pause/result transitions.
- `content/games/digital_board_game/scripts/systems/digital_board_game_state.lua` - owns digital board game authoritative state containers and domain update order.
- `content/games/digital_board_game/scripts/systems/digital_board_game_validation.lua` - owns digital board game data integrity checks before content enters a run.
- `content/games/digital_board_game/scripts/ui/digital_board_game_hud.lua` - owns digital board game HUD, inspector, prompt, and accessibility surfaces.
- `content/games/digital_board_game/assets/digital_board_game/` - owns digital board game media grouped by stable asset IDs.

## Game structure

Digital Board Game should be built as a set of named domain services rather than one large gameplay script.

- `digital_board_game_state` owns durable pieces, tiles, and cards records.
- `digital_board_game_rules` validates commands, applies board turns, piece movement, rule prompts, and replayable match state, and emits deterministic events.
- `digital_board_game_content` loads tables, checks IDs, and reports missing media before play starts.
- `digital_board_game_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `digital_board_game_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `digital_board_game_debug` exposes dice, players, and turn markers in overlays without mutating shipped state.

## Data and content model

- `pieces_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `pieces_table` data should live in `data/` and be validated before Digital Board Game enters active play.
- `tiles_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `tiles_table` data should live in `data/` and be validated before Digital Board Game enters active play.
- `cards_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `cards_table` data should live in `data/` and be validated before Digital Board Game enters active play.
- Digital Board Game save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Digital Board Game content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate digital board game setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for pieces, tiles, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for board turns, piece movement, rule prompts, and replayable match state; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Digital Board Game tests can run without presentation timing.

## Vertical slice acceptance

The slice should include one board, two to four players, turn order, dice or action selection, resource gain/spend, card draw/play, AI turn, victory condition, and save/resume.

## Risks

The risk is duplicated rule logic in UI. Legal actions must come from one authority so tooltips, AI, input, and save replay all agree.
