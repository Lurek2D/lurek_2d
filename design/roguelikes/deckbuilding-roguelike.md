# Deckbuilding Roguelike

**Category:** Roguelikes  
**Reference games:** Slay the Spire, Monster Train, Dicey Dungeons, Griftlands  
**Document type:** Technical game design and architecture

## Design target

A run-based card combat game with map navigation, deck mutation, relics, enemies, events, and deterministic combat turns. Lurek2D is well suited because the design is UI-heavy, data-driven, and 2D.

## Market positioning

Use the reference set (Slay the Spire, Monster Train, Dicey Dungeons, Griftlands) to define player expectations around pacing, readability, and production scope, not to copy mechanics directly. Target itch.io with a short run loop, strong item identity, and readable failure feedback. Target Steam with meta progression, seeded runs, daily/challenge modes, balance telemetry, and enough encounter variety for replay-focused players. For deckbuilding roguelike, the store page must communicate the core verb, session length, progression promise, and why the 2D presentation is intentional.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Cards and combat UI | `lurek.ui`, `lurek.render`, `lurek.tween`, `lurek.audio` |
| Run map | `lurek.procgen`, `lurek.scene`, `lurek.render` |
| Rules data | `lurek.filesystem`, `lurek.serialize`, `lurek.dataframe` |
| Enemy intent | `lurek.ai` utility or scripted intent queues |
| Persistence | `lurek.save` for profile unlocks and run resume |
| Modding potential | `lurek.mods`, `lurek.i18n` |

## Runtime architecture

Separate card definitions from card instances. Definitions hold cost, tags, target policy, effect script key, upgrade path, rarity, and presentation. Instances hold identity, upgraded state, temporary modifiers, and run ownership.

Combat state owns draw pile, hand, discard, exhaust, energy, block, powers, enemy intents, turn number, and pending animation queue. Card play creates a rule event list: pay cost, select target, resolve effects, trigger powers, discard or exhaust, then check death.

Enemy behavior should show intent before the player commits. AI can be a fixed pattern, weighted pattern, or utility selector, but the UI must display the chosen next action.

## Suggested project structure

```text
my_deckbuilder/
  data/cards.toml
  data/relics.toml
  data/enemies.toml
  data/events.toml
  scripts/state/run.lua
  scripts/state/combat.lua
  scripts/systems/card_resolver.lua
  scripts/systems/powers.lua
  scripts/systems/relics.lua
  scripts/ui/card_view.lua
  scripts/ui/run_map.lua
```

## Data and content model

- Author run seed, map chunks, rooms, enemies, loot tables, events, and encounter budgets as data, not hidden script constants.
- Author player build, inventory, status effects, cooldowns, meta unlocks, and death history as data, not hidden script constants.
- Author difficulty curves, procedural constraints, challenge modifiers, and balance telemetry as data, not hidden script constants.
- Keep deckbuilding roguelike content split between durable authored files under `data/`, media under `assets/`, and orchestration modules under `scripts/`.
- Save files should store player/world progress and stable identifiers, not transient render objects, cached paths, or UI widget instances.


## Technical design notes

- Use `lurek.math.newRandomGenerator` or explicit deterministic seed ownership, and store seeds in save data and run reports.
- Use `lurek.ecs` when actors, items, effects, and projectiles share update/render/component needs.
- Use `lurek.pathfind`, `lurek.ai`, and `lurek.tilefield` to keep navigation and monster decisions inspectable.
- Use `lurek.save` for meta progression and optional run suspend, not for hiding non-deterministic state.

## Vertical slice acceptance

The slice should include 20 cards, five enemies, three relics, generated path map, one event, card rewards, upgrades, enemy intent display, save/resume, and run end screen.

## Risks

The risk is effect spaghetti. Use a small effect vocabulary and event hooks instead of arbitrary card-specific scripts everywhere. Maintain a combat log that can replay card resolution.
