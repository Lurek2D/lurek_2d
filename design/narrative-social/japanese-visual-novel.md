# Japanese Visual Novel

> Category: `narrative-social`
> Scope: story-first Japanese-style visual novel, kinetic novel, route-based romance/drama, mystery VN, courtroom VN, or social deduction VN built with Lurek2D.
> Implementation tracker: #47

## Design target

A technical game design document for a marketable 2D Japanese Visual Novel built with Lurek2D. The design target is line history, route flags, rollback, presentation timing, and persistent unlocks, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

Japanese Visual Novel should be positioned as a focused narrative social entry about line history, route flags, rollback, presentation timing, and persistent unlocks. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Dialogue reveal and choices | `lurek.dialog` | For Japanese Visual Novel, this area covers dialogue reveal and choices from the current design; it should support line history, route flags, rollback, presentation timing, and persistent unlocks. Use it for speakers, choices, branches, conditions, and conversation flow tied to route state. |
| Scene stack | `lurek.scene` | For Japanese Visual Novel, this area covers scene stack from the current design; it should support line history, route flags, rollback, presentation timing, and persistent unlocks. Use it to decide which systems are active and which state may change in each screen. |
| UI | `lurek.ui` | For Japanese Visual Novel, this area covers ui from the current design; it should support line history, route flags, rollback, presentation timing, and persistent unlocks. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Presentation | `lurek.render`, `lurek.sprite`, `lurek.tween`, `lurek.cinematic` | For Japanese Visual Novel, this area covers presentation from the current design; it should support line history, route flags, rollback, presentation timing, and persistent unlocks. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for sprite sheets, atlases, character frames, cards, pieces, and marker presentation. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for scripted camera, portrait, music, or scene presentation timelines. |
| Audio | `lurek.audio` | For Japanese Visual Novel, this area covers audio from the current design; it should support line history, route flags, rollback, presentation timing, and persistent unlocks. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Save and persistent data | `lurek.save`, `lurek.serialize` | For Japanese Visual Novel, this area covers save and persistent data from the current design; it should support line history, route flags, rollback, presentation timing, and persistent unlocks. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Localization | `lurek.i18n` | For Japanese Visual Novel, this area covers localization from the current design; it should support line history, route flags, rollback, presentation timing, and persistent unlocks. Use it for localized text keys, speaker names, item labels, UI strings, and content-safe naming. |
| AI-assisted workflow | `lurek.agent` | For Japanese Visual Novel, this area covers ai-assisted workflow from the current design; it should support line history, route flags, rollback, presentation timing, and persistent unlocks. Use it for optional authoring checks and review summaries. |
| Dialogue, choices, and route state | `lurek.dialog`, `lurek.event`, `lurek.save` | For Japanese Visual Novel, this area covers resolving choices into route flags, history entries, unlocks, and replayable story events; it should support line history, route flags, rollback, presentation timing, and persistent unlocks. Use it for speakers, choices, branches, conditions, and conversation flow tied to route state. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Presentation timelines | `lurek.cinematic`, `lurek.sprite`, `lurek.image`, `lurek.audio` | For Japanese Visual Novel, this area covers coordinating portraits, backgrounds, voice cues, music, and scene transitions from script state; it should support line history, route flags, rollback, presentation timing, and persistent unlocks. Use it for scripted camera, portrait, music, or scene presentation timelines. Use it for sprite sheets, atlases, character frames, cards, pieces, and marker presentation. Use it for portraits, CGs, backgrounds, loaded images, and image processing inputs. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Localization and readable UI | `lurek.i18n`, `lurek.ui`, `lurek.tween` | For Japanese Visual Novel, this area covers keeping text keys, speaker names, backlog controls, and choice focus accessible; it should support line history, route flags, rollback, presentation timing, and persistent unlocks. Use it for localized text keys, speaker names, item labels, UI strings, and content-safe naming. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for UI and presentation interpolation that can be skipped without changing simulation results. |
| Scene ownership and mode boundaries | `lurek.scene` | For Japanese Visual Novel, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support line history, route flags, rollback, presentation timing, and persistent unlocks. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For Japanese Visual Novel, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support line history, route flags, rollback, presentation timing, and persistent unlocks. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For Japanese Visual Novel, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support line history, route flags, rollback, presentation timing, and persistent unlocks. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For Japanese Visual Novel, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support line history, route flags, rollback, presentation timing, and persistent unlocks. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For Japanese Visual Novel, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support line history, route flags, rollback, presentation timing, and persistent unlocks. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For Japanese Visual Novel, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support line history, route flags, rollback, presentation timing, and persistent unlocks. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For Japanese Visual Novel, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support line history, route flags, rollback, presentation timing, and persistent unlocks. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For Japanese Visual Novel, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support line history, route flags, rollback, presentation timing, and persistent unlocks. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For Japanese Visual Novel, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support line history, route flags, rollback, presentation timing, and persistent unlocks. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative Japanese Visual Novel state should center on line history, route flags, rollback, presentation timing, and persistent unlocks. Treat speakers as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current Japanese Visual Novel state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for japanese visual novel previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split Japanese Visual Novel into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where speakers, portraits, text lines, choices, route markers, CG unlocks, and backlog entries need stable identity across several systems. Single-purpose values can stay in domain tables, but any japanese visual novel object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for Japanese Visual Novel is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/japanese_visual_novel/main.lua` - owns japanese visual novel callback handoff and startup wiring.
- `content/games/japanese_visual_novel/conf.toml` - owns japanese visual novel window, input, asset, and runtime defaults.
- `content/games/japanese_visual_novel/data/japanese_visual_novel_rules.toml` - owns japanese visual novel authored rules for line history, route flags, rollback, presentation timing, and persistent unlocks.
- `content/games/japanese_visual_novel/data/speakers.toml` - owns japanese visual novel content records for speakers.
- `content/games/japanese_visual_novel/scripts/scenes/japanese_visual_novel_play.lua` - owns japanese visual novel scene-local orchestration and pause/result transitions.
- `content/games/japanese_visual_novel/scripts/systems/japanese_visual_novel_state.lua` - owns japanese visual novel authoritative state containers and domain update order.
- `content/games/japanese_visual_novel/scripts/systems/japanese_visual_novel_validation.lua` - owns japanese visual novel data integrity checks before content enters a run.
- `content/games/japanese_visual_novel/scripts/ui/japanese_visual_novel_hud.lua` - owns japanese visual novel HUD, inspector, prompt, and accessibility surfaces.
- `content/games/japanese_visual_novel/assets/japanese_visual_novel/` - owns japanese visual novel media grouped by stable asset IDs.

## Game structure

Japanese Visual Novel should be built as a set of named domain services rather than one large gameplay script.

- `japanese_visual_novel_state` owns durable speakers, portraits, and text lines records.
- `japanese_visual_novel_rules` validates commands, applies line history, route flags, rollback, presentation timing, and persistent unlocks, and emits deterministic events.
- `japanese_visual_novel_content` loads tables, checks IDs, and reports missing media before play starts.
- `japanese_visual_novel_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `japanese_visual_novel_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `japanese_visual_novel_debug` exposes choices, route markers, and CG unlocks in overlays without mutating shipped state.

## Data and content model

- `speakers_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `speakers_table` data should live in `data/` and be validated before Japanese Visual Novel enters active play.
- `portraits_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `portraits_table` data should live in `data/` and be validated before Japanese Visual Novel enters active play.
- `text_lines_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `text_lines_table` data should live in `data/` and be validated before Japanese Visual Novel enters active play.
- Japanese Visual Novel save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- Japanese Visual Novel content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate japanese visual novel setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for speakers, portraits, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for line history, route flags, rollback, presentation timing, and persistent unlocks; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so Japanese Visual Novel tests can run without presentation timing.

## Vertical slice acceptance
Build a two-scene slice before adding content volume.

Minimum slice:

- title screen with New Game, Load, Preferences, Gallery
- one school background, one bedroom background, one CG
- two character speakers, each with three expressions
- 80-120 lines of script
- two choices, one affinity flag, one route branch, one ending marker
- BGM with fade, one SFX, optional voice stub ids
- backlog view, quick save/load, normal save slot list
- auto-read and skip-read mode
- rollback to the last three checkpoints
- one gallery unlock after ending

## Risks
- Content scale grows faster than code scale; build validation tools early.
- Rollback is easy to fake for dialogue and hard to make correct across custom Lua state.
- Voice timing and skip/auto behavior can become inconsistent unless centralized.
- Japanese text needs font, line wrapping, punctuation, and UI-density QA.
- AI-generated route text must be committed as deterministic content before shipping.

## Player promise

The player reads, listens, chooses, and revisits. Every click should feel safe: the player can view the backlog, rollback to a previous checkpoint, quick save, quick load, skip already-read lines, auto-advance lines, and trust that route choices are preserved correctly.

## Core loop

1. Title screen loads preferences, persistent unlocks, and save metadata.
2. A scene script selects background, music, character sprites, speaker, and text.
3. Text reveals with typewriter pacing, voice playback, and optional side portrait.
4. Player advances, opens backlog, toggles auto/skip, saves, loads, or rolls back.
5. Choices set flags, affinity values, route markers, inventory clues, or case evidence.
6. Chapter ends unlock CGs, scene replay entries, music room tracks, and endings.
7. New Game+ or route replay uses persistent data to branch differently.

## State model

Keep story state explicit and serializable.

## Need implementation notes

The current engine pieces are enough for a basic VN, but a production Japanese-style VN needs a genre runtime. Track this under issue #47.

Required new library/API layer:

- `library.vn.newRuntime(opts)` for coordinating story, dialog, scene, audio, save, history, and presentation.
- Backlog/history API with stable line ids, speaker metadata, voice ids, tags, route id, and checkpoint id.
- Rollback checkpoint ring that snapshots story cursor, variables, visible presentation state, current audio cues, selected choices, and game-defined collectors.
- Auto-read and skip modes with options for read-only skip and voice-aware timing.
- Persistent unlock registry for CG gallery, music room, ending list, and scene replay.
- VN preferences model: text speed, auto delay, skip unread, font scale, textbox opacity, language, and bus volumes.
- Save-slot helpers that can collect screenshots/thumbnails later if engine screenshot access is promoted.
- Deterministic testing hooks: run until label, assert line seen, dump route flags, export backlog JSON.

Implementation should start in pure Lua under `library/vn/`. Promote to Rust only for engine-privileged pieces such as screenshot thumbnails, lower-level text shaping, or deep runtime snapshot helpers.

## Test strategy

- Headless route test: load script, run to each ending, assert flags and ending ids.
- Backlog test: emit lines, choices, and voice ids; verify stable ordering and serialization.
- Rollback test: choose option A, rollback, choose option B, verify route state changes correctly.
- Save migration test: save old schema, migrate to current runtime schema.
- Localization test: same line ids resolve across `en` and `ja` string tables.

## Acceptance checklist

- [ ] A VN can be played using only `main.lua`, `library.vn`, content files, and existing Lurek modules.
- [ ] Backlog survives save/load and shows speaker, text, and voice metadata.
- [ ] Rollback restores story variables, visible sprites, and selected choices.
- [ ] Auto and skip modes stop safely at choices.
- [ ] Persistent gallery/music/ending unlocks are separate from slot saves.
- [ ] Tests can run a route without manual clicking.
