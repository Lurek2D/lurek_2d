# Digital Board Game

**Category:** Card, board, and dice  
**Reference games:** Catan digital adaptations, Armello as structure reference, Mario Party board layer, Through the Ages digital  
**Document type:** Technical game design and architecture

## Design target

A digital board game with spaces, turns, cards, resources, dice or deterministic actions, AI opponents, readable rules, and strong UI. The product should feel like a complete tabletop rules engine with digital feedback.

## Market positioning

Use the reference set (Catan digital adaptations, Armello as structure reference, Mario Party board layer, Through the Ages digital) to define player expectations around pacing, readability, and production scope, not to copy mechanics directly. Target itch.io with a clear ruleset, fast onboarding, and a small set of replayable scenarios. Target Steam with AI opponents, campaign or challenge ladders, undo/replay support, accessibility options, and enough content variance to sustain repeated sessions. For digital board game, the store page must communicate the core verb, session length, progression promise, and why the 2D presentation is intentional.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Board presentation | `lurek.render`, `lurek.tilemap`, `lurek.camera`, `lurek.ui` |
| Pieces/resources/cards | `lurek.ecs`, `lurek.serialize`, Lureksome cardgame/economy libraries |
| Turn system | `lurek.patterns`, `lurek.signal`, `lurek.time` |
| AI opponents | `lurek.ai`, utility scoring, MCTS-style helpers where appropriate |
| Persistence | `lurek.save` for match resume, profile, rule variant |

## Runtime architecture

Create a rules engine that owns legal actions, turn order, phase order, player resources, board occupancy, decks, discard piles, dice state, and victory condition. UI asks the rules engine for legal actions; it does not infer them independently.

Every player action should become a command with actor, phase, target, cost, and validation result. The resolver emits events: resource changed, piece moved, card drawn, trade offered, score updated, phase advanced. AI consumes the same legal-action list as the player.

Board visuals can be graph-based or grid-based. Spaces need stable IDs, adjacency, owner, occupant list, region, and visual anchor.

## Suggested project structure

```text
my_board_game/
  data/board.json
  data/cards.toml
  data/rules.toml
  scripts/state/match.lua
  scripts/systems/legal_actions.lua
  scripts/systems/rule_resolver.lua
  scripts/systems/decks.lua
  scripts/ai/board_ai.lua
  scripts/ui/action_panel.lua
```

## Data and content model

- Author rulesets, cards, dice faces, board spaces, costs, triggers, and victory conditions as data, not hidden script constants.
- Author match state, player hands, discard piles, public market rows, timers, and AI decision logs as data, not hidden script constants.
- Author campaign unlocks, challenge seeds, tutorial gates, and replay records as data, not hidden script constants.
- Keep digital board game content split between durable authored files under `data/`, media under `assets/`, and orchestration modules under `scripts/`.
- Save files should store player/world progress and stable identifiers, not transient render objects, cached paths, or UI widget instances.


## Technical design notes

- Use `lurek.ui` as the primary play surface for hands, tooltips, logs, confirm buttons, and accessible rules text.
- Keep the rules engine deterministic and serializable; animation should consume resolved results rather than decide outcomes.
- Use `lurek.serialize` and `lurek.save` for match snapshots, undo stacks, campaign progress, and replay seeds.
- Use `lurek.ai` for opponent scoring over legal actions rather than embedding AI inside card or board definitions.

## Vertical slice acceptance

The slice should include one board, two to four players, turn order, dice or action selection, resource gain/spend, card draw/play, AI turn, victory condition, and save/resume.

## Risks

The risk is duplicated rule logic in UI. Legal actions must come from one authority so tooltips, AI, input, and save replay all agree.
