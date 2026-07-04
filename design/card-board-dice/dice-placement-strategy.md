# Dice Placement Strategy

**Category:** Card, board, and dice  
**Reference games:** Dicey Dungeons, Roll Player, Tharsis, Sagrada  
**Document type:** Technical game design and architecture

## Design target

A dice-driven strategy game where rolled dice become resources placed into slots, abilities, workers, rooms, or actions. The game should balance randomness with planning, mitigation, and readable probabilities.

## Market positioning

Use the reference set (Dicey Dungeons, Roll Player, Tharsis, Sagrada) to define player expectations around pacing, readability, and production scope, not to copy mechanics directly. Target itch.io with a clear ruleset, fast onboarding, and a small set of replayable scenarios. Target Steam with AI opponents, campaign or challenge ladders, undo/replay support, accessibility options, and enough content variance to sustain repeated sessions. For dice placement strategy, the store page must communicate the core verb, session length, progression promise, and why the 2D presentation is intentional.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Board and dice UI | `lurek.ui`, `lurek.render`, `lurek.tween`, `lurek.audio` |
| Rule state | `lurek.patterns`, `lurek.serialize`, `lurek.math` |
| Data | `lurek.filesystem`, `lurek.dataframe` |
| AI/tutorial | `lurek.ai`, `lurek.dialog` |
| Persistence | `lurek.save` for campaign, unlocks, best scores |

## Runtime architecture

Use a phase state machine: roll, modify, place, resolve, cleanup, reward, next round. Dice are instances with value, color, source, lock state, modifiers, and owner. Slots define accepted values/colors, cost, output, occupancy rule, timing, and combo tags.

The resolver should validate placements before mutation. Resolved placements emit events such as gain resource, damage enemy, advance track, draw card, reroll die, unlock slot, or trigger combo.

Because randomness is central, expose probability and mitigation. Store seed and roll history for replay and debugging. UI should show valid slots when a die is selected.

## Suggested project structure

```text
my_dice_strategy/
  data/dice.toml
  data/slots.toml
  data/encounters.toml
  scripts/state/run.lua
  scripts/systems/rolls.lua
  scripts/systems/placement_rules.lua
  scripts/systems/resolution.lua
  scripts/ui/dice_tray.lua
  scripts/ui/slot_board.lua
```

## Data and content model

- Author rulesets, cards, dice faces, board spaces, costs, triggers, and victory conditions as data, not hidden script constants.
- Author match state, player hands, discard piles, public market rows, timers, and AI decision logs as data, not hidden script constants.
- Author campaign unlocks, challenge seeds, tutorial gates, and replay records as data, not hidden script constants.
- Keep dice placement strategy content split between durable authored files under `data/`, media under `assets/`, and orchestration modules under `scripts/`.
- Save files should store player/world progress and stable identifiers, not transient render objects, cached paths, or UI widget instances.


## Technical design notes

- Use `lurek.ui` as the primary play surface for hands, tooltips, logs, confirm buttons, and accessible rules text.
- Keep the rules engine deterministic and serializable; animation should consume resolved results rather than decide outcomes.
- Use `lurek.serialize` and `lurek.save` for match snapshots, undo stacks, campaign progress, and replay seeds.
- Use `lurek.ai` for opponent scoring over legal actions rather than embedding AI inside card or board definitions.

## Vertical slice acceptance

The slice should include four dice types, ten slots, reroll/modify actions, one enemy or objective track, combo scoring, round rewards, seed logging, and save progression.

## Risks

The risk is randomness feeling arbitrary. Every failure should show why a die could not be placed and what mitigation options exist.
