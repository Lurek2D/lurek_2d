# Life Sim RPG

**Category:** Role-playing games  
**Reference games:** Stardew Valley, Harvest Moon, Rune Factory, Persona social-calendar structure  
**Document type:** Technical game design and architecture

## Design target

A life-sim RPG with daily schedules, farming or work loops, relationships, festivals, skills, quests, shops, and long-term calendar progression. The player advances through days, not combat arenas alone.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Town/farm maps | `lurek.tilemap`, `lurek.scene`, `lurek.camera` |
| NPCs and objects | `lurek.ecs`, `lurek.pathfind`, `lurek.ai` schedules |
| Dialogue/relationships | `lurek.dialog`, Lureksome dialog/quest/stats libraries |
| Farming/crafting/economy | Lureksome crafting/economy/inventory libraries, `lurek.dataframe` |
| Time/calendar | `lurek.time`, `lurek.signal`, `lurek.save` |
| UI | `lurek.ui`, `lurek.render`, `lurek.i18n` |

## Runtime architecture

Use a `CalendarState` that owns date, season, weekday, time of day, weather, festival, and speed policy. Daily simulation resets temporary flags, advances crops, moves NPC schedules, updates shops, and triggers mail or events.

NPCs require schedule data: location by time block, condition overrides, relationship gates, dialogue pools, gifts, and event chains. Store relationship points and story flags separately from current NPC position so reloads can reconstruct schedules.

Farming plots are tile facts with crop ID, growth stage, watered flag, fertilizer, quality, and harvest policy. Crafting and shops should consume item definitions, not custom one-off tables.

## Suggested project structure

```text
my_life_sim/
  data/maps/town.ldtk
  data/npcs.toml
  data/crops.toml
  data/calendar.toml
  data/dialogue/*.toml
  scripts/state/calendar.lua
  scripts/systems/farming.lua
  scripts/systems/npc_schedules.lua
  scripts/systems/relationships.lua
  scripts/systems/shops.lua
  scripts/ui/day_planner.lua
```

## Vertical slice acceptance

The slice should include one playable day, farm plot, two crops, three NPCs with schedules, gift interaction, shop, one festival trigger, sleep/save flow, and next-day growth.

## Risks

The risk is time-dependent bugs. Make calendar transitions atomic and log daily rollovers. NPC schedules should be resolved from data every day rather than accumulated through fragile ad-hoc movement state.
