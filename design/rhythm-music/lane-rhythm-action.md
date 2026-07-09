# Lane Rhythm Action

## Design target

A technical game design document for a marketable 2D Lane Rhythm Action built with Lurek2D. The design target is audio-clock authority, judgement windows, calibration, and chart readability, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Lane Rhythm Action should be positioned as a focused rhythm music entry about audio-clock authority, judgement windows, calibration, and chart readability. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Beat timing and judgement | `lurek.audio` | For Lane Rhythm Action, this area covers beat timing and judgement from the current design; it should support audio-clock authority, judgement windows, calibration, and chart readability. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Music and sound routing | `lurek.audio` | For Lane Rhythm Action, this area covers music and sound routing from the current design; it should support audio-clock authority, judgement windows, calibration, and chart readability. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Input bindings and replay | `lurek.input` | For Lane Rhythm Action, this area covers input bindings and replay from the current design; it should support audio-clock authority, judgement windows, calibration, and chart readability. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. |
| Chart data | `lurek.filesystem`, `lurek.serialize`, `lurek.dataframe` | For Lane Rhythm Action, this area covers chart data from the current design; it should support audio-clock authority, judgement windows, calibration, and chart readability. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. |
| Note rendering and effects | `lurek.render`, `lurek.sprite`, `lurek.animation`, `lurek.tween`, `lurek.particle` | For Lane Rhythm Action, this area covers note rendering and effects from the current design; it should support audio-clock authority, judgement windows, calibration, and chart readability. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for sprite sheets, atlases, character frames, cards, pieces, and marker presentation. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. |
| Menus and results | `lurek.ui`, `lurek.scene`, `lurek.save` | For Lane Rhythm Action, this area covers menus and results from the current design; it should support audio-clock authority, judgement windows, calibration, and chart readability. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it to decide which systems are active and which state may change in each screen. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Debug and calibration | `lurek.overlay`, `lurek.log`, `lurek.devtools` | For Lane Rhythm Action, this area covers debug and calibration from the current design; it should support audio-clock authority, judgement windows, calibration, and chart readability. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it to record validation errors, command traces, and reproducible bug evidence. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. |
| Audio-clock authority | `lurek.audio`, `lurek.timer`, `lurek.input` | For Lane Rhythm Action, this area covers driving chart timing, calibration, judgement windows, and buffered hits from one clock model; it should support audio-clock authority, judgement windows, calibration, and chart readability. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. Use it for explicit clocks, cooldowns, production ticks, turn timers, and scheduled actions. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. |
| Charts, lanes, and scoring records | `lurek.dataframe`, `lurek.serialize`, `lurek.save` | For Lane Rhythm Action, this area covers loading note data, validating lane IDs, and storing results without mixing them into song definitions; it should support audio-clock authority, judgement windows, calibration, and chart readability. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Judgement feedback | `lurek.sprite`, `lurek.overlay`, `lurek.tween` | For Lane Rhythm Action, this area covers showing hit windows, note travel, combo feedback, and calibration diagnostics; it should support audio-clock authority, judgement windows, calibration, and chart readability. Use it for sprite sheets, atlases, character frames, cards, pieces, and marker presentation. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for UI and presentation interpolation that can be skipped without changing simulation results. |
| Scene ownership and mode boundaries | `lurek.scene` | For Lane Rhythm Action, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support audio-clock authority, judgement windows, calibration, and chart readability. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Lane Rhythm Action, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support audio-clock authority, judgement windows, calibration, and chart readability. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Lane Rhythm Action, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support audio-clock authority, judgement windows, calibration, and chart readability. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Lane Rhythm Action, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support audio-clock authority, judgement windows, calibration, and chart readability. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Lane Rhythm Action, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support audio-clock authority, judgement windows, calibration, and chart readability. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Lane Rhythm Action, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support audio-clock authority, judgement windows, calibration, and chart readability. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Lane Rhythm Action, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support audio-clock authority, judgement windows, calibration, and chart readability. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Lane Rhythm Action, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support audio-clock authority, judgement windows, calibration, and chart readability. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Lane Rhythm Action, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support audio-clock authority, judgement windows, calibration, and chart readability. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Lane Rhythm Action state should center on audio-clock authority, judgement windows, calibration, and chart readability. Treat songs as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Lane Rhythm Action state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for lane rhythm action previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Lane Rhythm Action into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where songs, notes, lanes, hit records, score state, calibration profiles, and results need stable identity across several systems. Single-purpose values can stay in domain tables, but any lane rhythm action object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Lane Rhythm Action is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/lane_rhythm_action/main.lua` - owns lane rhythm action callback handoff and startup wiring.
- `content/games/lane_rhythm_action/conf.toml` - owns lane rhythm action window, input, asset, and runtime defaults.
- `content/games/lane_rhythm_action/data/lane_rhythm_action_rules.toml` - owns lane rhythm action authored rules for audio-clock authority, judgement windows, calibration, and chart readability.
- `content/games/lane_rhythm_action/data/songs.toml` - owns lane rhythm action content records for songs.
- `content/games/lane_rhythm_action/scripts/scenes/lane_rhythm_action_play.lua` - owns lane rhythm action scene-local orchestration and pause/result transitions.
- `content/games/lane_rhythm_action/scripts/systems/lane_rhythm_action_state.lua` - owns lane rhythm action authoritative state containers and domain update order.
- `content/games/lane_rhythm_action/scripts/systems/lane_rhythm_action_validation.lua` - owns lane rhythm action data integrity checks before content enters a run.
- `content/games/lane_rhythm_action/scripts/ui/lane_rhythm_action_hud.lua` - owns lane rhythm action HUD, inspector, prompt, and accessibility surfaces.
- `content/games/lane_rhythm_action/assets/lane_rhythm_action/` - owns lane rhythm action media grouped by stable asset IDs.

## Game structure

Lane Rhythm Action should be built as a set of named domain services rather than one large gameplay script.

- `lane_rhythm_action_state` owns durable songs, notes, and lanes records.
- `lane_rhythm_action_rules` validates commands, applies audio-clock authority, judgement windows, calibration, and chart readability, and emits deterministic events.
- `lane_rhythm_action_content` loads tables, checks IDs, and reports missing media before play starts.
- `lane_rhythm_action_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `lane_rhythm_action_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `lane_rhythm_action_debug` exposes hit records, score state, and calibration profiles in overlays without mutating shipped state.

## Data and content model

- `songs_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `songs_table` data should live in `data/` and be validated before Lane Rhythm Action enters active play.
- `notes_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `notes_table` data should live in `data/` and be validated before Lane Rhythm Action enters active play.
- `lanes_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `lanes_table` data should live in `data/` and be validated before Lane Rhythm Action enters active play.
- Lane Rhythm Action save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Lane Rhythm Action content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate lane rhythm action setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for songs, notes, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for audio-clock authority, judgement windows, calibration, and chart readability; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Lane Rhythm Action tests can run without presentation timing.

## Vertical slice acceptance

The first slice should include three songs, two difficulties per song, calibration, four-lane input, tap and hold notes, miss/bad/good/perfect judgements, combo, fail state, result screen, saved best scores, and a debug overlay for timing deltas.

## Risks

The major risk is timing drift. Do not couple judgement to frame rate, animation progress, or render visibility. Validate every chart against audio start, offset, BPM changes, and note windows before treating scoring bugs as player skill issues.
