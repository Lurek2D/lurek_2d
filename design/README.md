# Lurek2D Game Design Architecture Library

This directory is a catalog of technical game design documents for building real games with Lurek2D. It is intentionally not a demo folder and does not contain throwaway Lua snippets. Each document describes an architecture, data model, gameplay loop, and Lurek API strategy for a concrete 2D game type.

The documents assume Lurek2D's normal project shape: a game folder with `main.lua`, `conf.toml`, `assets/`, `data/`, and `scripts/`. Lua owns game state and orchestration, while Lurek2D provides the public `lurek.*` runtime for rendering, input, audio, physics, tile maps, pathfinding, AI, ECS, UI, saves, effects, tooling, and data loading.

## How to use these documents

1. Pick the game type closest to the product you want to build.
2. Treat the reference games as design anchors, not as clone targets.
3. Start from the proposed state model and project structure.
4. Build the vertical slice criteria before expanding content volume.
5. Keep reusable systems in `scripts/systems/`, authored content in `data/`, and media in `assets/`.
6. Check the `Market positioning`, `Data and content model`, and `Technical design notes` sections before writing implementation tasks.

## Categories

- `strategy-games/` - turn-based, real-time, and province-scale strategy designs.
- `tactics-combat/` - squad, tactics-RPG, and simulation-first battle designs.
- `simulation-management/` - colony, factory, and city management designs.
- `action-adventure/` - top-down exploration, stealth, and collectathon designs.
- `platformers/` - precision, puzzle, and run-and-gun platform designs.
- `roguelikes/` - grid roguelike, action roguelite, and deckbuilding run designs.
- `role-playing-games/` - action RPG, party CRPG, life-sim RPG, and RPG Maker-style JRPG designs.
- `shooters/` - twin-stick, bullet-hell, and tactical 2D shooter designs.
- `puzzle-games/` - spatial, match-combo, and physics logic puzzle designs.
- `survival-crafting/` - survival crafting, cozy farming, and base defense designs.
- `sports-racing/` - racing, team sports, and trick-score sports designs.
- `card-board-dice/` - board game, card game, and dice-placement designs.
- `narrative-social/` - visual novel, detective, and social simulation designs.
- `rhythm-music/` - rhythm timing, music-action, and score-attack designs.
- `commerce-economy/` - shopkeeper, trading, and small-business economy designs.

## Current design entries

- [Japanese Visual Novel](narrative-social/japanese-visual-novel.md) - story-first route-based VN architecture with backlog, rollback, save slots, auto/skip, gallery unlocks, and scene command strategy.
- [RPG Maker Style JRPG](role-playing-games/rpg-maker-style-jrpg.md) - tile-based JRPG architecture with map/event/database model, party progression, turn-based battles, and RPG Maker MZ-style importer/runtime notes.

## Market and scope assumptions

Each design should name its market promise for itch.io and Steam. Itch.io targets can be narrower, experimental, and shorter, but still need a complete loop. Steam targets need stronger onboarding, save stability, settings, input remapping, accessibility, content depth, and presentation polish.

Do not treat reference games as clone targets. Use them to clarify player expectations, production scope, UI density, session length, and replay structure.

## Cross-cutting architecture conventions

- Use `lurek.init` for loading data, creating scene state, registering UI, and preparing long-lived managers.
- Use `lurek.process` for simulation that depends on frame delta, and reserve fixed-step logic for deterministic physics-style rules.
- Use `lurek.draw` for world rendering and `lurek.draw_ui` for HUD, menus, debug overlays, and tool panels.
- Treat `lurek.scene` as the high-level screen stack: title, gameplay, pause, editor-style debug screen, combat result, and modal flows.
- Treat `lurek.ecs` as a shared entity/component substrate when a game has many actors, projectiles, items, or map objects.
- Treat `lurek.tilemap`, `lurek.tilefield`, `lurek.pathfind`, `lurek.province`, and `lurek.minimap` as separate layers: visual map, gameplay cell facts, route analysis, strategic graph, and overview visualization.
- Treat `lurek.save` as the persistence boundary, not ad-hoc file writes.
- Keep runtime-only 2D scope. Do not target 3D scene graphs, MMO-scale networking, cloud economies, or editor-first workflows from this folder.
