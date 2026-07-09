# Visual Novel

## Design target

A technical game design document for a marketable 2D Visual Novel built with Lurek2D. The design target is choice readability, backlog safety, route variables, and polished reading flow, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Visual Novel should be positioned as a focused narrative social entry about choice readability, backlog safety, route variables, and polished reading flow. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Dialogue flow | `lurek.dialog`, `lurek.ui`, `lurek.event` | For Visual Novel, this area covers dialogue flow from the current design; it should support choice readability, backlog safety, route variables, and polished reading flow. Use it for speakers, choices, branches, conditions, and conversation flow tied to route state. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Portraits/backgrounds | `lurek.render`, `lurek.image`, `lurek.tween`, `lurek.effect` | For Visual Novel, this area covers portraits/backgrounds from the current design; it should support choice readability, backlog safety, route variables, and polished reading flow. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for portraits, CGs, backgrounds, loaded images, and image processing inputs. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for screen-space feedback such as flashes, hit emphasis, palette shifts, or readability passes. |
| Music/sound | `lurek.audio`, `lurek.dsp` | For Visual Novel, this area covers music/sound from the current design; it should support choice readability, backlog safety, route variables, and polished reading flow. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. Use it for audio filtering and richer music presentation. |
| Localization | `lurek.i18n`, `lurek.filesystem` | For Visual Novel, this area covers localization from the current design; it should support choice readability, backlog safety, route variables, and polished reading flow. Use it for localized text keys, speaker names, item labels, UI strings, and content-safe naming. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. |
| Save/history | `lurek.save`, `lurek.serialize` | For Visual Novel, this area covers save/history from the current design; it should support choice readability, backlog safety, route variables, and polished reading flow. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Dialogue, choices, and route state | `lurek.dialog`, `lurek.event`, `lurek.save` | For Visual Novel, this area covers resolving choices into route flags, history entries, unlocks, and replayable story events; it should support choice readability, backlog safety, route variables, and polished reading flow. Use it for speakers, choices, branches, conditions, and conversation flow tied to route state. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Presentation timelines | `lurek.cinematic`, `lurek.sprite`, `lurek.image`, `lurek.audio` | For Visual Novel, this area covers coordinating portraits, backgrounds, voice cues, music, and scene transitions from script state; it should support choice readability, backlog safety, route variables, and polished reading flow. Use it for scripted camera, portrait, music, or scene presentation timelines. Use it for sprite sheets, atlases, character frames, cards, pieces, and marker presentation. Use it for portraits, CGs, backgrounds, loaded images, and image processing inputs. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Localization and readable UI | `lurek.i18n`, `lurek.ui`, `lurek.tween` | For Visual Novel, this area covers keeping text keys, speaker names, backlog controls, and choice focus accessible; it should support choice readability, backlog safety, route variables, and polished reading flow. Use it for localized text keys, speaker names, item labels, UI strings, and content-safe naming. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for UI and presentation interpolation that can be skipped without changing simulation results. |
| Scene ownership and mode boundaries | `lurek.scene` | For Visual Novel, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support choice readability, backlog safety, route variables, and polished reading flow. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Visual Novel, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support choice readability, backlog safety, route variables, and polished reading flow. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Visual Novel, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support choice readability, backlog safety, route variables, and polished reading flow. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Visual Novel, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support choice readability, backlog safety, route variables, and polished reading flow. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Visual Novel, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support choice readability, backlog safety, route variables, and polished reading flow. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Visual Novel, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support choice readability, backlog safety, route variables, and polished reading flow. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Visual Novel, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support choice readability, backlog safety, route variables, and polished reading flow. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Visual Novel, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support choice readability, backlog safety, route variables, and polished reading flow. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Visual Novel, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support choice readability, backlog safety, route variables, and polished reading flow. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Visual Novel state should center on choice readability, backlog safety, route variables, and polished reading flow. Treat speakers as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Visual Novel state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for visual novel previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Visual Novel into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where speakers, backgrounds, choices, history entries, route flags, saves, and gallery unlocks need stable identity across several systems. Single-purpose values can stay in domain tables, but any visual novel object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Visual Novel is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/visual_novel/main.lua` - owns visual novel callback handoff and startup wiring.
- `content/games/visual_novel/conf.toml` - owns visual novel window, input, asset, and runtime defaults.
- `content/games/visual_novel/data/visual_novel_rules.toml` - owns visual novel authored rules for choice readability, backlog safety, route variables, and polished reading flow.
- `content/games/visual_novel/data/speakers.toml` - owns visual novel content records for speakers.
- `content/games/visual_novel/scripts/scenes/visual_novel_play.lua` - owns visual novel scene-local orchestration and pause/result transitions.
- `content/games/visual_novel/scripts/systems/visual_novel_state.lua` - owns visual novel authoritative state containers and domain update order.
- `content/games/visual_novel/scripts/systems/visual_novel_validation.lua` - owns visual novel data integrity checks before content enters a run.
- `content/games/visual_novel/scripts/ui/visual_novel_hud.lua` - owns visual novel HUD, inspector, prompt, and accessibility surfaces.
- `content/games/visual_novel/assets/visual_novel/` - owns visual novel media grouped by stable asset IDs.

## Game structure

Visual Novel should be built as a set of named domain services rather than one large gameplay script.

- `visual_novel_state` owns durable speakers, backgrounds, and choices records.
- `visual_novel_rules` validates commands, applies choice readability, backlog safety, route variables, and polished reading flow, and emits deterministic events.
- `visual_novel_content` loads tables, checks IDs, and reports missing media before play starts.
- `visual_novel_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `visual_novel_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `visual_novel_debug` exposes history entries, route flags, and saves in overlays without mutating shipped state.

## Data and content model

- `speakers_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `speakers_table` data should live in `data/` and be validated before Visual Novel enters active play.
- `backgrounds_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `backgrounds_table` data should live in `data/` and be validated before Visual Novel enters active play.
- `choices_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `choices_table` data should live in `data/` and be validated before Visual Novel enters active play.
- Visual Novel save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Visual Novel content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate visual novel setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for speakers, backgrounds, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for choice readability, backlog safety, route variables, and polished reading flow; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Visual Novel tests can run without presentation timing.

## Vertical slice acceptance

The slice should include one chapter, three characters, branching choice, persistent flag, backlog, save/load, skip seen text, music transition, and localization key path.

## Risks

The risk is branching content becoming impossible to audit. Store scripts in data files and validate that every choice target and condition exists.
