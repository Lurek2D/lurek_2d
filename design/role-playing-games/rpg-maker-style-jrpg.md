# RPG Maker Style JRPG

> Category: `role-playing-games`
> Scope: top-down tile-based JRPG, RPG Maker-style town/dungeon adventure, party RPG, cozy quest RPG, or story-heavy 2D RPG built with Lurek2D.
> Implementation tracker: #47

## Design target

A technical game design document for a marketable 2D RPG Maker Style JRPG built with Lurek2D. The design target is tile towns, event pages, party growth, turn battles, and import-friendly data, expressed through data-driven Lua systems and exact `lurek.*` runtime boundaries.

## Market positioning

RPG Maker Style JRPG should be positioned as a focused role playing games entry about tile towns, event pages, party growth, turn battles, and import-friendly data. The short-form release should prove the core loop with a small authored content set, clear failure feedback, and one polished presentation hook. The larger release should add progression depth, content validation, accessibility settings, and enough authored variation that its main content records do not feel interchangeable. The document should describe the product promise directly instead of borrowing identity from another game.

## Lurek2D API map

| API area | Lurek2D API | How this design should use it |
|---|---|---|
| Tile world | `lurek.tilemap`, `lurek.tilefield`, `lurek.tileset`, `lurek.tilelight`, `lurek.pathfind` | For RPG Maker Style JRPG, this area covers tile world from the current design; it should support tile towns, event pages, party growth, turn battles, and import-friendly data. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it for tileset metadata, autotiles, properties, and catalogs. Use it for tile-level light propagation and darkness gameplay. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. |
| RPG Maker assets | `lurek.sprite` | For RPG Maker Style JRPG, this area covers rpg maker assets from the current design; it should support tile towns, event pages, party growth, turn battles, and import-friendly data. Use it for sprite sheets, atlases, character frames, cards, pieces, and marker presentation. |
| Player/NPC rendering | `lurek.sprite`, `lurek.animation`, `lurek.tween`, `lurek.camera` | For RPG Maker Style JRPG, this area covers player/npc rendering from the current design; it should support tile towns, event pages, party growth, turn battles, and import-friendly data. Use it for sprite sheets, atlases, character frames, cards, pieces, and marker presentation. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. |
| Events/dialogue | `lurek.dialog`, `lurek.event` | For RPG Maker Style JRPG, this area covers events/dialogue from the current design; it should support tile towns, event pages, party growth, turn battles, and import-friendly data. Use it for speakers, choices, branches, conditions, and conversation flow tied to route state. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Battle | `lurek.ui`, `lurek.audio` | For RPG Maker Style JRPG, this area covers battle from the current design; it should support tile towns, event pages, party growth, turn battles, and import-friendly data. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Database | `lurek.dataframe`, `lurek.serialize`, `lurek.filesystem` | For RPG Maker Style JRPG, this area covers database from the current design; it should support tile towns, event pages, party growth, turn battles, and import-friendly data. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. |
| Save | `lurek.save` | For RPG Maker Style JRPG, this area covers save from the current design; it should support tile towns, event pages, party growth, turn battles, and import-friendly data. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Menus | `lurek.ui` | For RPG Maker Style JRPG, this area covers menus from the current design; it should support tile towns, event pages, party growth, turn battles, and import-friendly data. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| AI workflow | `lurek.agent` | For RPG Maker Style JRPG, this area covers ai workflow from the current design; it should support tile towns, event pages, party growth, turn battles, and import-friendly data. Use it for optional authoring checks and review summaries. |
| Quests, party entities, and world state | `lurek.ecs`, `lurek.dialog`, `lurek.save` | For RPG Maker Style JRPG, this area covers binding actors, quests, dialogue flags, inventory, and progression to stable IDs; it should support tile towns, event pages, party growth, turn battles, and import-friendly data. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for speakers, choices, branches, conditions, and conversation flow tied to route state. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. |
| Maps, navigation, and encounters | `lurek.tilemap`, `lurek.tilefield`, `lurek.pathfind` | For RPG Maker Style JRPG, this area covers keeping visual maps separate from blockers, triggers, encounter regions, and reachable destinations; it should support tile towns, event pages, party growth, turn battles, and import-friendly data. Use it for visual layers, imported maps, chunks, decoration, and camera-facing tile presentation. Use it for authoritative cell facts such as blockers, costs, regions, hazards, ownership, or tags. Use it for route, range, flow, and reachability queries instead of embedding movement guesses in UI. |
| Stats, items, and authored tables | `lurek.dataframe`, `lurek.serialize`, `lurek.ui` | For RPG Maker Style JRPG, this area covers validating skills, equipment, rewards, and status descriptions before runtime use; it should support tile towns, event pages, party growth, turn battles, and import-friendly data. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Scene ownership and mode boundaries | `lurek.scene` | For RPG Maker Style JRPG, this area covers splitting boot, loading, setup, active play, pause, results, and debug review into modes with different authority; it should support tile towns, event pages, party growth, turn battles, and import-friendly data. Use it to decide which systems are active and which state may change in each screen. |
| Entity identity and cross-system state | `lurek.ecs`, `lurek.event` | For RPG Maker Style JRPG, this area covers giving long-lived objects stable IDs and publishing resolved domain events after systems mutate owned state; it should support tile towns, event pages, party growth, turn battles, and import-friendly data. Use it for objects that must be addressed by simulation, UI, save data, audio, or AI with the same stable identity. Use it for resolved commands and domain facts so UI, audio, debug, and replay logic observe the same outcome. |
| Input commands and accessibility | `lurek.input`, `lurek.ui` | For RPG Maker Style JRPG, this area covers turning device input into named commands, exposing remapping, and keeping command prompts consistent with the active scene; it should support tile towns, event pages, party growth, turn battles, and import-friendly data. Use it for named actions, buffering, rebinding, and controller parity instead of reading raw keys inside domain rules. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Authored content loading | `lurek.filesystem`, `lurek.serialize` | For RPG Maker Style JRPG, this area covers loading rules, maps, encounter tables, and manifests through runtime paths and versioned interchange data; it should support tile towns, event pages, party growth, turn battles, and import-friendly data. Use it as the runtime boundary for authored maps, rules, manifests, and asset lists. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Balance tables and validation | `lurek.dataframe`, `lurek.log` | For RPG Maker Style JRPG, this area covers keeping tunable content in inspectable tables and reporting missing IDs, bad references, or suspicious values before play; it should support tile towns, event pages, party growth, turn battles, and import-friendly data. Use it when balance data needs table validation, reporting, sorting, or spreadsheet-like review. Use it to record validation errors, command traces, and reproducible bug evidence. |
| Progress, options, and migration | `lurek.save`, `lurek.serialize` | For RPG Maker Style JRPG, this area covers storing only stable IDs, schema versions, settings, unlocks, and player progress while rebuilding runtime caches; it should support tile towns, event pages, party growth, turn battles, and import-friendly data. Use it for profile data, slots, settings, unlocks, and migrations after runtime-only fields are stripped. Use it for TOML or JSON content, snapshots, migrations, and replay-safe state interchange. |
| Camera, HUD, and readable feedback | `lurek.camera`, `lurek.render`, `lurek.ui` | For RPG Maker Style JRPG, this area covers framing the active problem, drawing passive presentation, and keeping HUD state downstream of simulation; it should support tile towns, event pages, party growth, turn battles, and import-friendly data. Use it to frame the active decision, constrain movement, handle zoom, and apply non-authoritative shake. Use it for passive drawing of world, sprites, text, shapes, and shader-backed presentation. Use it for HUD, menus, prompts, inspectors, accessibility controls, and player-facing state summaries. |
| Animation and non-authoritative polish | `lurek.animation`, `lurek.tween`, `lurek.particle`, `lurek.audio` | For RPG Maker Style JRPG, this area covers making state changes readable without letting presentation timing decide gameplay outcomes; it should support tile towns, event pages, party growth, turn battles, and import-friendly data. Use it for clips chosen from resolved state, never as the source of gameplay authority. Use it for UI and presentation interpolation that can be skipped without changing simulation results. Use it for short-lived trails, impacts, weather, and celebration feedback tied to events. Use it for music, cues, bus levels, voice timing, and feedback synced to resolved events. |
| Debug overlays and tuning | `lurek.overlay`, `lurek.devtools`, `lurek.log` | For RPG Maker Style JRPG, this area covers showing live state, timings, IDs, paths, and recent events in developer-only views; it should support tile towns, event pages, party growth, turn battles, and import-friendly data. Use it for developer-only live views of cells, paths, IDs, timings, and hidden state. Use it for tuning panels and inspectors that modify test values without becoming shipped rules. Use it to record validation errors, command traces, and reproducible bug evidence. |

## Runtime architecture

The authoritative RPG Maker Style JRPG state should center on tile towns, event pages, party growth, turn battles, and import-friendly data. Treat maps as the first state owner to inspect when a bug appears, then follow derived events into UI, audio, effects, or debug overlays.

Update order should be explicit: read commands, validate them against current RPG Maker Style JRPG state, run domain systems, publish events, then let presentation systems draw the resolved snapshot. Rendering and animation may smooth the result, but they should not decide outcomes.

Long-lived managers should be created during scene setup and passed to systems that need them. Transient caches for rpg maker style jrpg previews, paths, reports, or effects should be rebuilt from saved state rather than persisted.

## Scene and ECS architecture

`lurek.scene` should split RPG Maker Style JRPG into screens that have different authority: boot/loading, setup, active play, pause/options, results, and focused debug review. Each scene should declare which systems run, which UI surfaces are visible, and which save/profile data may be changed.

`lurek.ecs` belongs where maps, events, actors, items, skills, switches, variables, and battle rewards need stable identity across several systems. Single-purpose values can stay in domain tables, but any rpg maker style jrpg object touched by simulation, UI, audio, save data, or AI should use an entity ID plus narrow components.

The pattern for RPG Maker Style JRPG is scene-driven activation with system-owned mutation: scenes choose the active slice, systems update their owned components, and render/UI/audio consume events or snapshots.

## Suggested project structure

- `content/games/rpg_maker_style_jrpg/main.lua` - owns rpg maker style jrpg callback handoff and startup wiring.
- `content/games/rpg_maker_style_jrpg/conf.toml` - owns rpg maker style jrpg window, input, asset, and runtime defaults.
- `content/games/rpg_maker_style_jrpg/data/rpg_maker_style_jrpg_rules.toml` - owns rpg maker style jrpg authored rules for tile towns, event pages, party growth, turn battles, and import-friendly data.
- `content/games/rpg_maker_style_jrpg/data/maps.toml` - owns rpg maker style jrpg content records for maps.
- `content/games/rpg_maker_style_jrpg/scripts/scenes/rpg_maker_style_jrpg_play.lua` - owns rpg maker style jrpg scene-local orchestration and pause/result transitions.
- `content/games/rpg_maker_style_jrpg/scripts/systems/rpg_maker_style_jrpg_state.lua` - owns rpg maker style jrpg authoritative state containers and domain update order.
- `content/games/rpg_maker_style_jrpg/scripts/systems/rpg_maker_style_jrpg_validation.lua` - owns rpg maker style jrpg data integrity checks before content enters a run.
- `content/games/rpg_maker_style_jrpg/scripts/ui/rpg_maker_style_jrpg_hud.lua` - owns rpg maker style jrpg HUD, inspector, prompt, and accessibility surfaces.
- `content/games/rpg_maker_style_jrpg/assets/rpg_maker_style_jrpg/` - owns rpg maker style jrpg media grouped by stable asset IDs.

## Game structure

RPG Maker Style JRPG should be built as a set of named domain services rather than one large gameplay script.

- `rpg_maker_style_jrpg_state` owns durable maps, events, and actors records.
- `rpg_maker_style_jrpg_rules` validates commands, applies tile towns, event pages, party growth, turn battles, and import-friendly data, and emits deterministic events.
- `rpg_maker_style_jrpg_content` loads tables, checks IDs, and reports missing media before play starts.
- `rpg_maker_style_jrpg_presentation` converts resolved state into render, audio, tween, particle, and UI requests.
- `rpg_maker_style_jrpg_save` writes only stable IDs, schema versions, player progress, and settings through `lurek.save`.
- `rpg_maker_style_jrpg_debug` exposes items, skills, and switches in overlays without mutating shipped state.

## Data and content model

- `maps_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `maps_table` data should live in `data/` and be validated before RPG Maker Style JRPG enters active play.
- `events_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `events_table` data should live in `data/` and be validated before RPG Maker Style JRPG enters active play.
- `actors_id` records should be stable across saves, tests, telemetry, and authored data revisions.
- `actors_table` data should live in `data/` and be validated before RPG Maker Style JRPG enters active play.
- RPG Maker Style JRPG save data should store progress, settings, unlocked content, and schema versions; runtime handles and generated caches should be rebuilt.
- RPG Maker Style JRPG content should use `lurek.filesystem`, `lurek.serialize`, and `lurek.dataframe` according to file shape and table size.

## Technical design notes

- Use `lurek.scene` to isolate rpg maker style jrpg setup, active play, pause, result, and debug review so each mode has a clear state owner.
- Use `lurek.ecs` only for maps, events, and other records that cross simulation, UI, save, AI, or audio boundaries.
- Use data files for tile towns, event pages, party growth, turn battles, and import-friendly data; hard-coded constants should be limited to defaults and migration fallbacks.
- Use `lurek.event` to publish resolved domain events, not speculative preview state.
- Use `lurek.save` after converting runtime state into stable IDs, versioned tables, and player-visible progress.
- Keep render, tween, particle, and audio requests downstream of simulation so RPG Maker Style JRPG tests can run without presentation timing.

## Vertical slice acceptance
Build one town-to-dungeon loop.

Minimum slice:

- title screen and load screen
- one town map, one forest/dungeon map
- player character with four-direction walk cycle
- two NPC events with dialogue and choices
- one treasure chest with self switch
- one transfer event between maps
- one shop event
- one save point
- one random or scripted battle
- three actors, four skills, five items, two enemies, one troop
- one quest with two objectives
- one boss gate controlled by a switch or variable

## Risks
- RPG Maker compatibility scope can explode; define an MZ subset and reject unsupported plugin commands clearly.
- Event command blocking semantics must be deterministic or bugs will be hard to reproduce.
- Tileset passability rules are more important than visual import for gameplay feel.
- Battle formulas and states can become a scripting language inside the scripting language; keep formula evaluation sandboxed.
- Editor-first expectations should be redirected to importers, validators, and VS Code tooling rather than a full built-in editor.

## Player promise

The player explores a readable tile world, talks to NPCs, solves event-driven problems, collects items, grows a party, fights tactical turn-based battles, and returns to saved progress without losing context.

## Core loop

1. Load the current map, player position, party, inventory, switches, variables, and self switches.
2. Player moves on a tile grid with camera follow and collision/passability rules.
3. Action button or collision trigger runs an event: NPC dialogue, chest, transfer, shop, inn, cutscene, puzzle, or battle.
4. Battles award gold, items, experience, quest progress, and state changes.
5. Switches, variables, and self switches select new event pages and unlock new content.
6. Save points or menu saves persist map state, party state, and database-driven progress.
7. Chapter milestones unlock new maps, quests, shops, and enemy tables.

## State model

The state should mirror the mental model RPG Maker users already understand, while keeping Lua data explicit.

## Need implementation notes

The current Lurek API can build a native JRPG, but RPG Maker-style support needs a dedicated compatibility/data/event layer. Track this under issue #47.

Required new library/API layer:

- `library.rpgmaker.loadDatabase(path)` to load RPG Maker MZ-style `data/*.json` files into normalized Lua tables.
- `library.rpgmaker.loadMap(path, database)` to build tilemap, tilefield, events, encounters, regions, transfer metadata, and tileset references.
- `library.rpgmaker.newEventRuntime(opts)` to execute event pages and command lists deterministically.
- Switch, variable, and self-switch APIs.
- Event page resolver with conditions: switch, variable, self switch, item, actor, party member.
- Trigger APIs: action button, player touch, event touch, autorun, parallel.
- Blocking command interpreter: dialogue waits, choice waits, move route waits, battle waits, transfer waits, shop waits.
- Passability adapter from RPG Maker tileset flags to `lurek.tilefield` blockers and path costs.
- Region and terrain tag metadata bridge for random encounters, hazards, quest zones, and cutscene triggers.
- Event trace output for tests and debugging.

## Event command subset for phase 1

Implement a practical subset before chasing full compatibility.

- Show Text
- Show Choices
- Control Switches
- Control Variables
- Control Self Switch
- Conditional Branch
- Transfer Player
- Set Event Location
- Set Move Route
- Wait
- Play BGM / BGS / ME / SE
- Stop or fade audio
- Change Gold
- Change Items
- Change Weapons
- Change Armors
- Change Party Member
- Battle Processing
- Shop Processing
- Common Event
- Label / Jump to Label
- Loop / Break Loop
- Exit Event Processing
- Show Picture / Move Picture / Erase Picture

## Test strategy

- Import test: load database and map files, assert table counts and normalized keys.
- Passability test: blocked tile prevents movement and pathfinding avoids it.
- Event page test: switch/self-switch changes selected page.
- Command interpreter test: execute chest event and assert item + self switch.
- Transfer test: execute transfer and assert map id, x, y, facing.
- Battle adapter test: event starts troop, battle result writes rewards, quest progress updates.
- Save/load test: switches, variables, self switches, party, map id, and inventory round-trip.
- Headless event trace test: run an autorun cutscene and compare trace artifact.

## Acceptance checklist

- [ ] A native Lurek JRPG can be built without RPG Maker imports.
- [ ] A MZ-style database subset can be imported into normalized Lua tables.
- [ ] A MZ-style map subset can create tilemap, tilefield, events, and region metadata.
- [ ] Event pages resolve by switch/variable/self-switch conditions.
- [ ] Event runtime can block on dialogue, choices, move routes, transfers, shops, and battles.
- [ ] Tile passability feeds movement and pathfinding.
- [ ] Party, inventory, quests, battle rewards, switches, variables, and self switches persist through `lurek.save`.
