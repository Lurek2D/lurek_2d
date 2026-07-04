# Social Simulation

**Category:** Narrative and social  
**Reference games:** The Sims as systems reference, Animal Crossing, Princess Maker, Tokimeki Memorial  
**Document type:** Technical game design and architecture

## Design target

A 2D social simulation where characters have schedules, relationships, needs, traits, memories, routines, conversations, events, and evolving social networks. The focus is believable change over time rather than combat.

## Market positioning

Use the reference set (The Sims as systems reference, Animal Crossing, Princess Maker, Tokimeki Memorial) to define player expectations around pacing, readability, and production scope, not to copy mechanics directly. Target itch.io with a strong premise, readable UI, and a complete short arc. Target Steam with branching content, localization-ready data, save slots, gallery/extras, and strong UX for re-reading, skipping, and reviewing choices. For social simulation, the store page must communicate the core verb, session length, progression promise, and why the 2D presentation is intentional.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Shared spaces | `lurek.tilemap`, `lurek.scene`, `lurek.camera` |
| Characters | `lurek.ecs`, `lurek.ai`, `lurek.pathfind` |
| Dialogue and events | `lurek.dialog`, `lurek.signal`, `lurek.i18n` |
| Traits/needs/memories | `lurek.ai`, `lurek.agent`, `lurek.serialize` |
| UI | `lurek.ui`, `lurek.render`, `lurek.charts` |
| Persistence | `lurek.save` for schedules, relationships, memories, event history |

## Runtime architecture

Represent each character as identity, traits, needs, relationships, memories, schedule, current goal, and current scene. Schedules produce default behavior, while needs and events can override it. Relationship changes should be event-sourced so the UI can explain why someone likes or distrusts another character.

Use a social graph with directed values: affinity, trust, rivalry, familiarity, romance, respect, fear, or obligation. Dialogue choices and witnessed events mutate the graph through explicit events.

AI should pick goals from utility: satisfy need, attend schedule, seek character, avoid conflict, work, rest, socialize, pursue story event. Movement and local avoidance remain pathfinding concerns.

## Suggested project structure

```text
my_social_sim/
  data/characters.toml
  data/schedules.toml
  data/dialogue/*.toml
  data/events.toml
  scripts/state/social_world.lua
  scripts/systems/schedules.lua
  scripts/systems/relationships.lua
  scripts/systems/memories.lua
  scripts/ai/social_ai.lua
  scripts/ui/relationship_panel.lua
```

## Data and content model

- Author characters, locations, scenes, dialogue graphs, relationship variables, and evidence flags as data, not hidden script constants.
- Author chapter state, choice history, timers or calendars, UI review logs, and unlockable extras as data, not hidden script constants.
- Author localization keys, portrait/sprite references, audio cues, and branch validation metadata as data, not hidden script constants.
- Keep social simulation content split between durable authored files under `data/`, media under `assets/`, and orchestration modules under `scripts/`.
- Save files should store player/world progress and stable identifiers, not transient render objects, cached paths, or UI widget instances.


## Technical design notes

- Use `lurek.dialog` for branching dialogue flow and `lurek.ui` for backlog, choices, profile panels, and evidence review.
- Keep authored content in data files loaded through `lurek.filesystem` and parsed through `lurek.serialize` or `lurek.dataframe`.
- Use `lurek.scene` for title, chapter, free-roam, dialogue, investigation, and result screens.
- Use `lurek.save` for choice history, relationship variables, flags, and gallery unlocks.

## Vertical slice acceptance

The slice should include one shared location, five characters, daily schedule, two needs, relationship changes, memory record, branching conversation, one social event, and save/load.

## Risks

The risk is opaque simulation. Show schedules, current goals, relationship causes, and recent memories in debug UI. Social systems need explanation to feel intentional rather than random.
