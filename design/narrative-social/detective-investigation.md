# Detective Investigation

**Category:** Narrative and social  
**Reference games:** Return of the Obra Dinn, Her Story as evidence-graph reference, Ace Attorney, Disco Elysium as investigation structure reference  
**Document type:** Technical game design and architecture

## Design target

A 2D investigation game where the player explores scenes, interviews characters, collects clues, connects evidence, makes accusations, and unlocks deductions. The architecture should make truth, belief, and player knowledge separate concepts.

## Market positioning

Use the reference set (Return of the Obra Dinn, Her Story as evidence-graph reference, Ace Attorney, Disco Elysium as investigation structure reference) to define player expectations around pacing, readability, and production scope, not to copy mechanics directly. Target itch.io with a strong premise, readable UI, and a complete short arc. Target Steam with branching content, localization-ready data, save slots, gallery/extras, and strong UX for re-reading, skipping, and reviewing choices. For detective investigation, the store page must communicate the core verb, session length, progression promise, and why the 2D presentation is intentional.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Scenes and hotspots | `lurek.tilemap`, `lurek.input`, `lurek.ui`, `lurek.render` |
| Dialogue/interrogation | `lurek.dialog`, `lurek.signal`, `lurek.i18n` |
| Evidence graph | `lurek.ecs` or domain tables, `lurek.serialize`, `lurek.dataframe` |
| Reasoning helpers | `lurek.ai` for hint director or NPC beliefs |
| Persistence | `lurek.save` for clues, notes, case progress |

## Runtime architecture

Use a case state with facts, clues, suspects, locations, interviews, contradictions, deductions, accusations, and fail/soft-fail policy. A clue is not just text; it has source, discovered flag, tags, related entities, unlock effects, and presentation asset.

Separate the canonical truth from player notebook state. The truth graph defines what happened. The notebook graph records what the player has found and connected. Dialogue conditions read notebook state and relationship flags, not hidden truth unless the scene is revealing it.

Hotspots and interviews emit clue-discovered events. Deduction boards validate combinations and unlock new questions, locations, or endings.

## Suggested project structure

```text
my_detective/
  data/cases/case_01.toml
  data/dialogue/*.toml
  data/scenes/*.ldtk
  scripts/state/case_state.lua
  scripts/systems/hotspots.lua
  scripts/systems/evidence_graph.lua
  scripts/systems/deductions.lua
  scripts/ui/notebook.lua
  scripts/ui/interrogation.lua
  assets/scenes/
```

## Data and content model

- Author characters, locations, scenes, dialogue graphs, relationship variables, and evidence flags as data, not hidden script constants.
- Author chapter state, choice history, timers or calendars, UI review logs, and unlockable extras as data, not hidden script constants.
- Author localization keys, portrait/sprite references, audio cues, and branch validation metadata as data, not hidden script constants.
- Keep detective investigation content split between durable authored files under `data/`, media under `assets/`, and orchestration modules under `scripts/`.
- Save files should store player/world progress and stable identifiers, not transient render objects, cached paths, or UI widget instances.


## Technical design notes

- Use `lurek.dialog` for branching dialogue flow and `lurek.ui` for backlog, choices, profile panels, and evidence review.
- Keep authored content in data files loaded through `lurek.filesystem` and parsed through `lurek.serialize` or `lurek.dataframe`.
- Use `lurek.scene` for title, chapter, free-roam, dialogue, investigation, and result screens.
- Use `lurek.save` for choice history, relationship variables, flags, and gallery unlocks.

## Vertical slice acceptance

The slice should include two scenes, three suspects, ten clues, one contradiction, one deduction board, accusation flow, hint trigger, and save/load.

## Risks

The risk is confusing hidden truth with discovered evidence. Keep them separate and log every clue unlock so narrative bugs can be traced.
