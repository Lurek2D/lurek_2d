# Turn-Based 4X Grid Strategy

**Category:** Strategy games  
**Reference games:** Civilization II, Freeciv, Battle for Wesnoth, Old World  
**Document type:** Technical game design and architecture

## Design target

A turn-based empire game where the player explores a tile map, founds settlements, researches technologies, moves units, negotiates borders, and grows an economy across many turns. The product should feel strategic rather than tactical: one turn is a bundle of movement, production, diplomacy, and long-term planning.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Hex or square world map | `lurek.tilemap`, `lurek.tilefield`, `lurek.camera`, `lurek.minimap` |
| Movement range and route previews | `lurek.pathfind` with weighted grid or hex graph costs |
| Cities, units, improvements | `lurek.ecs` entities plus typed components |
| AI players | `lurek.ai` utility scoring, behavior trees, blackboards, AI LOD |
| Research/economy tables | `lurek.filesystem`, `lurek.serialize`, `lurek.dataframe` |
| Save/load | `lurek.save` with schema versioned sections |
| Interface | `lurek.ui`, `lurek.render.drawText`, `lurek.overlay` |

## Runtime architecture

Use a deterministic `TurnState` as the authority. It owns the turn number, active faction, fog state, known map, diplomacy matrix, technology state, city production queues, unit orders, and pending notifications. `lurek.process` should only animate camera movement, previews, and UI transitions while the simulation waits for explicit turn commands.

Represent the map as visual tile data plus gameplay facts. `tilemap` stores terrain IDs, decorations, and layers. `tilefield` stores movement blockers, yields, ownership, roads, visibility, and improvement tags. `pathfind` reads the gameplay layer, not the art layer. Cities and units are ECS entities that reference tile coordinates, faction IDs, and order queues.

AI should run in phases: evaluate empire needs, assign city production, issue unit goals, resolve diplomacy, then submit orders. Keep expensive route search batched or async. The AI output should be inspectable as intent records, not hidden direct mutations.

## Suggested project structure

```text
my_4x/
  main.lua
  conf.toml
  data/rules/terrain.toml
  data/rules/units.toml
  data/rules/tech_tree.toml
  data/maps/earthlike.json
  scripts/state/turn_state.lua
  scripts/systems/economy.lua
  scripts/systems/diplomacy.lua
  scripts/systems/ai_empire.lua
  scripts/ui/city_screen.lua
  scripts/ui/map_hud.lua
  assets/tiles/
  assets/ui/
```

## Vertical slice acceptance

The first shippable slice should support one generated map, two factions, one city per faction, three unit types, movement range overlay, end-turn resolution, fog update, production queue completion, and a save/load round trip. Avoid adding diplomacy depth before the core turn transaction is reliable.

## Risks

The largest risk is mixing visual tiles with strategic truth. Keep terrain art, gameplay costs, ownership, and visibility as separate layers. The second risk is non-deterministic AI; log every AI decision with inputs and selected policy so turn replays can be debugged.
