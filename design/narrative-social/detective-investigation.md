# Detective Investigation

## Design target

A technical game design document for a marketable 2D Detective Investigation built with Lurek2D. The design target is evidence collection, interrogation pressure, contradiction tracking, and case flow, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Detective Investigation should be positioned as a focused narrative social entry about evidence collection, interrogation pressure, contradiction tracking, and case flow. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Scenes and hotspots | `lurek.tilemap`, `lurek.input`, `lurek.ui`, `lurek.render` | For Detective Investigation, this area covers scenes and hotspots from the current design; it should support evidence collection, interrogation pressure, contradiction tracking, and case flow. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. |
| Dialogue/interrogation | `lurek.dialog`, `lurek.event`, `lurek.i18n` | For Detective Investigation, this area covers dialogue/interrogation from the current design; it should support evidence collection, interrogation pressure, contradiction tracking, and case flow. Use it for speakers, choices, branches, conditions, and conversation flow tied to route state. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. Use it for localized text keys, speaker names, item labels, UI strings, and content-safe naming. |
| Evidence graph | `lurek.ecs`, `lurek.serialize`, `lurek.dataframe` | For Detective Investigation, this area covers evidence graph from the current design; it should support evidence collection, interrogation pressure, contradiction tracking, and case flow. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. |
| Reasoning helpers | `lurek.ai` | For Detective Investigation, this area covers reasoning helpers from the current design; it should support evidence collection, interrogation pressure, contradiction tracking, and case flow. Use it for inspectable decision scoring and scheduled planners. |
| Persistence | `lurek.save` | For Detective Investigation, this area covers persistence from the current design; it should support evidence collection, interrogation pressure, contradiction tracking, and case flow. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Dialogue, choices, and route state | `lurek.dialog`, `lurek.event`, `lurek.save` | For Detective Investigation, this area covers resolving choices into route flags, history entries, unlocks, and replayable story events; it should support evidence collection, interrogation pressure, contradiction tracking, and case flow. Use it for speakers, choices, branches, conditions, and conversation flow tied to route state. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Presentation timelines | `lurek.cinematic`, `lurek.sprite`, `lurek.image`, `lurek.audio` | For Detective Investigation, this area covers coordinating portraits, backgrounds, voice cues, music, and scene transitions from script state; it should support evidence collection, interrogation pressure, contradiction tracking, and case flow. Use it for scripted camera, portrait, music, or scene presentation timelines. Use it for sprite sheets, atlases, character frames, cards, pieces, and marker presentation. Use it for portraits, CGs, backgrounds, loaded images, and image processing inputs. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Localization and readable UI | `lurek.i18n`, `lurek.ui`, `lurek.tween` | For Detective Investigation, this area covers keeping text keys, speaker names, backlog controls, and choice focus accessible; it should support evidence collection, interrogation pressure, contradiction tracking, and case flow. Use it for localized text keys, speaker names, item labels, UI strings, and content-safe naming. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for UI and presentation interpolation that can be skipped without changing simulation results. |
| Scene ownership and mode boundaries | `lurek.scene` | For Detective Investigation, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support evidence collection, interrogation pressure, contradiction tracking, and case flow. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Detective Investigation, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support evidence collection, interrogation pressure, contradiction tracking, and case flow. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Detective Investigation, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support evidence collection, interrogation pressure, contradiction tracking, and case flow. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Detective Investigation, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support evidence collection, interrogation pressure, contradiction tracking, and case flow. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Detective Investigation, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support evidence collection, interrogation pressure, contradiction tracking, and case flow. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Detective Investigation, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support evidence collection, interrogation pressure, contradiction tracking, and case flow. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Detective Investigation, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support evidence collection, interrogation pressure, contradiction tracking, and case flow. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Detective Investigation, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support evidence collection, interrogation pressure, contradiction tracking, and case flow. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Detective Investigation, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support evidence collection, interrogation pressure, contradiction tracking, and case flow. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Detective Investigation state should center on evidence collection, interrogation pressure, contradiction tracking, and case flow. Treat clues as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Detective Investigation state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for detective investigation previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Detective Investigation into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where clues, suspects, statements, locations, timers, evidence boards, and deductions need stable identity across several systems. Single-purpose values can stay in domain tables, but any detective investigation object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Detective Investigation is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/detective_investigation/main.lua` - owns detective investigation callback handoff and startup wiring.
- `content/games/detective_investigation/conf.toml` - owns detective investigation window, input, asset, and runtime defaults.
- `content/games/detective_investigation/data/detective_investigation_rules.toml` - owns detective investigation authored rules for evidence collection, interrogation pressure, contradiction tracking, and case flow.
- `content/games/detective_investigation/data/clues.toml` - owns detective investigation content records for clues.
- `content/games/detective_investigation/scripts/scenes/detective_investigation_play.lua` - owns detective investigation scene-local orchestration and pause/result transitions.
- `content/games/detective_investigation/scripts/systems/detective_investigation_state.lua` - owns detective investigation authoritative state containers and domain update order.
- `content/games/detective_investigation/scripts/systems/detective_investigation_validation.lua` - owns detective investigation data integrity checks before content enters a run.
- `content/games/detective_investigation/scripts/ui/detective_investigation_hud.lua` - owns detective investigation HUD, inspector, prompt, and accessibility surfaces.
- `content/games/detective_investigation/assets/detective_investigation/` - owns detective investigation media grouped by stable asset IDs.

## Game structure

Detective Investigation should be built as a set of named domain services rather than one large gameplay script.

- `detective_investigation_state` owns durable clues, suspects, and statements records.
- `detective_investigation_rules` validates commands, applies evidence collection, interrogation pressure, contradiction tracking, and case flow, and emits deterministic events.
- `detective_investigation_content` loads tables, checks IDs, and reports missing media before play starts.
- `detective_investigation_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `detective_investigation_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `detective_investigation_debug` exposes locations, timers, and evidence boards in overlays without mutating shipped state.

## Data and content model

- `clues_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `clues_table` data should live in `data/` and be validated before Detective Investigation enters active play.
- `suspects_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `suspects_table` data should live in `data/` and be validated before Detective Investigation enters active play.
- `statements_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `statements_table` data should live in `data/` and be validated before Detective Investigation enters active play.
- Detective Investigation save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Detective Investigation content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate detective investigation setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for clues, suspects, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for evidence collection, interrogation pressure, contradiction tracking, and case flow; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Detective Investigation tests can run without presentation timing.

## Vertical slice acceptance

The slice should include two scenes, three suspects, ten clues, one contradiction, one deduction board, accusation flow, hint trigger, and save/load.

## Risks

The risk is confusing hidden truth with discovered evidence. Keep them separate and log every clue unlock so narrative bugs can be traced.
