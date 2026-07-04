# Deckbuilding Roguelike

**Category:** Roguelikes  
**Reference games:** Slay the Spire, Monster Train, Dicey Dungeons, Griftlands  
**Document type:** Technical game design and architecture

## Design target

A run-based card combat game with map navigation, deck mutation, relics, enemies, events, and deterministic combat turns. Lurek2D is well suited because the design is UI-heavy, data-driven, and 2D.

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

## Vertical slice acceptance

The slice should include 20 cards, five enemies, three relics, generated path map, one event, card rewards, upgrades, enemy intent display, save/resume, and run end screen.

## Risks

The risk is effect spaghetti. Use a small effect vocabulary and event hooks instead of arbitrary card-specific scripts everywhere. Maintain a combat log that can replay card resolution.
