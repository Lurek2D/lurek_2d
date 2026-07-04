# Visual Novel

**Category:** Narrative and social  
**Reference games:** Doki Doki Literature Club, Phoenix Wright as dialogue structure reference, VA-11 Hall-A, Fate/stay night  
**Document type:** Technical game design and architecture

## Design target

A 2D visual novel with branching dialogue, portraits, backgrounds, music, choices, variables, unlockable routes, history log, save slots, localization, and optional minigame hooks. Lurek2D can support it through UI, rendering, audio, save, and data-driven dialogue.

## Market positioning

Use the reference set (Doki Doki Literature Club, Phoenix Wright as dialogue structure reference, VA-11 Hall-A, Fate/stay night) to define player expectations around pacing, readability, and production scope, not to copy mechanics directly. Target itch.io with a strong premise, readable UI, and a complete short arc. Target Steam with branching content, localization-ready data, save slots, gallery/extras, and strong UX for re-reading, skipping, and reviewing choices. For visual novel, the store page must communicate the core verb, session length, progression promise, and why the 2D presentation is intentional.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Dialogue flow | `lurek.dialog`, `lurek.ui`, `lurek.signal` |
| Portraits/backgrounds | `lurek.render`, `lurek.image`, `lurek.tween`, `lurek.effect` |
| Music/sound | `lurek.audio`, `lurek.dsp` |
| Localization | `lurek.i18n`, `lurek.filesystem` |
| Save/history | `lurek.save`, `lurek.serialize` |

## Runtime architecture

Use script assets rather than hard-coded scene functions. Each dialogue node should include speaker, text key, portrait state, background, music cue, conditions, choices, and effects. Effects set flags, branch routes, change relationship values, unlock gallery entries, or start minigames.

The runtime state owns current script, node, backlog, variables, route flags, seen text, auto/skip mode, and presentation state. Save slots should capture enough to resume the exact node and visual state, while global save tracks unlocks and seen text.

Presentation should be a layer on top of dialogue state. Text speed, fade, portrait tween, voice blip, and choice animation should not alter narrative logic.

## Suggested project structure

```text
my_visual_novel/
  data/scripts/chapter_01.toml
  data/i18n/en.toml
  data/characters.toml
  scripts/state/novel_state.lua
  scripts/systems/dialogue_runner.lua
  scripts/systems/choice_effects.lua
  scripts/ui/textbox.lua
  scripts/ui/save_load.lua
  assets/backgrounds/
  assets/portraits/
```

## Data and content model

- Author characters, locations, scenes, dialogue graphs, relationship variables, and evidence flags as data, not hidden script constants.
- Author chapter state, choice history, timers or calendars, UI review logs, and unlockable extras as data, not hidden script constants.
- Author localization keys, portrait/sprite references, audio cues, and branch validation metadata as data, not hidden script constants.
- Keep visual novel content split between durable authored files under `data/`, media under `assets/`, and orchestration modules under `scripts/`.
- Save files should store player/world progress and stable identifiers, not transient render objects, cached paths, or UI widget instances.


## Technical design notes

- Use `lurek.dialog` for branching dialogue flow and `lurek.ui` for backlog, choices, profile panels, and evidence review.
- Keep authored content in data files loaded through `lurek.filesystem` and parsed through `lurek.serialize` or `lurek.dataframe`.
- Use `lurek.scene` for title, chapter, free-roam, dialogue, investigation, and result screens.
- Use `lurek.save` for choice history, relationship variables, flags, and gallery unlocks.

## Vertical slice acceptance

The slice should include one chapter, three characters, branching choice, persistent flag, backlog, save/load, skip seen text, music transition, and localization key path.

## Risks

The risk is branching content becoming impossible to audit. Store scripts in data files and validate that every choice target and condition exists.
