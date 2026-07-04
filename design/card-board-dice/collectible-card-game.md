# Collectible Card Game

**Category:** Card, board, and dice  
**Reference games:** Magic: The Gathering Arena, Hearthstone, Legends of Runeterra, Netrunner digital adaptations  
**Document type:** Technical game design and architecture

## Design target

A 2D card battler with deck construction, hand management, board zones, resources, card effects, triggered abilities, AI opponents, and collection progression. The design can be single-player first to avoid large network scope.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Card UI | `lurek.ui`, `lurek.render`, `lurek.tween`, `lurek.audio` |
| Rules and effects | Lureksome cardgame library, `lurek.patterns`, `lurek.serialize` |
| Data and localization | `lurek.filesystem`, `lurek.dataframe`, `lurek.i18n` |
| AI opponent | `lurek.ai` utility scoring, possible search helpers |
| Persistence | `lurek.save` for collection, decks, campaign, settings |

## Runtime architecture

Separate card definition, card instance, deck list, collection entry, and combat zone. Definitions are immutable data. Instances hold owner, zone, damage, counters, temporary tags, and generated ID. Zones include deck, hand, board, discard, exile, stack, and reveal areas.

The rules engine should process events through a small vocabulary: play card, pay cost, choose target, resolve effect, trigger ability, modify stat, move zone, deal damage, draw, discard, win check. Avoid card-specific imperative logic when an effect table can express the behavior.

AI should evaluate legal actions from the same rules engine. For early versions, utility scoring is more reliable than deep search.

## Suggested project structure

```text
my_ccg/
  data/cards.toml
  data/keywords.toml
  data/starter_decks.toml
  scripts/state/collection.lua
  scripts/state/match.lua
  scripts/systems/rules_engine.lua
  scripts/systems/effects.lua
  scripts/systems/deck_builder.lua
  scripts/ai/card_ai.lua
  scripts/ui/card_inspector.lua
```

## Vertical slice acceptance

The slice should include 40 cards, deck builder, mulligan, resource system, creatures or units, spells, three keywords, AI opponent, match result, and collection save.

## Risks

The risk is unbounded card text. Define a constrained effect language and add new primitives only when several cards need them.
