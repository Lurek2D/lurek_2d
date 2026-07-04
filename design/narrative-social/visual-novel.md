# Visual Novel

**Category:** Narrative and social  
**Reference games:** Doki Doki Literature Club, Phoenix Wright as dialogue structure reference, VA-11 Hall-A, Fate/stay night  
**Document type:** Technical game design and architecture

## Design target

A 2D visual novel with branching dialogue, portraits, backgrounds, music, choices, variables, unlockable routes, history log, save slots, localization, and optional minigame hooks. Lurek2D can support it through UI, rendering, audio, save, and data-driven dialogue.

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

## Vertical slice acceptance

The slice should include one chapter, three characters, branching choice, persistent flag, backlog, save/load, skip seen text, music transition, and localization key path.

## Risks

The risk is branching content becoming impossible to audit. Store scripts in data files and validate that every choice target and condition exists.
