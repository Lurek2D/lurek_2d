# Collectible Card Game

**Category:** Card, board, and dice  
**Reference games:** Magic: The Gathering Arena, Hearthstone, Legends of Runeterra, Netrunner digital adaptations  
**Document type:** Technical game design and architecture

## Design target

A 2D card battler with deck construction, hand management, board zones, resources, card effects, triggered abilities, AI opponents, and collection progression. The design can be single-player first to avoid large network scope.

## Market positioning

Use the reference set (Magic: The Gathering Arena, Hearthstone, Legends of Runeterra, Netrunner digital adaptations) to define player expectations around pacing, readability, and production scope, not to copy mechanics directly. Target itch.io with a clear ruleset, fast onboarding, and a small set of replayable scenarios. Target Steam with AI opponents, campaign or challenge ladders, undo/replay support, accessibility options, and enough content variance to sustain repeated sessions. For collectible card game, the store page must communicate the core verb, session length, progression promise, and why the 2D presentation is intentional.

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

## Data and content model

- Author rulesets, cards, dice faces, board spaces, costs, triggers, and victory conditions as data, not hidden script constants.
- Author match state, player hands, discard piles, public market rows, timers, and AI decision logs as data, not hidden script constants.
- Author campaign unlocks, challenge seeds, tutorial gates, and replay records as data, not hidden script constants.
- Keep collectible card game content split between durable authored files under `data/`, media under `assets/`, and orchestration modules under `scripts/`.
- Save files should store player/world progress and stable identifiers, not transient render objects, cached paths, or UI widget instances.


## Technical design notes

- Use `lurek.ui` as the primary play surface for hands, tooltips, logs, confirm buttons, and accessible rules text.
- Keep the rules engine deterministic and serializable; animation should consume resolved results rather than decide outcomes.
- Use `lurek.serialize` and `lurek.save` for match snapshots, undo stacks, campaign progress, and replay seeds.
- Use `lurek.ai` for opponent scoring over legal actions rather than embedding AI inside card or board definitions.

## Vertical slice acceptance

The slice should include 40 cards, deck builder, mulligan, resource system, creatures or units, spells, three keywords, AI opponent, match result, and collection save.

## Risks

The risk is unbounded card text. Define a constrained effect language and add new primitives only when several cards need them.
