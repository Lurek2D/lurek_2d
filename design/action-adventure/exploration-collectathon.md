# Exploration Collectathon

**Category:** Action adventure  
**Reference games:** Banjo-Kazooie as structural reference, Yoku's Island Express, A Short Hike, Fez  
**Document type:** Technical game design and architecture

## Design target

A 2D exploration game built around traversal abilities, collectible sets, hub areas, secrets, characters, and soft progression. It should emphasize curiosity and spatial memory rather than combat depth.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Connected zones | `lurek.scene`, `lurek.tilemap`, `lurek.camera`, `lurek.parallax` |
| Collectibles and triggers | `lurek.ecs`, `lurek.signal`, `lurek.save` |
| Movement feel | `lurek.physics`, `lurek.animation`, `lurek.tween` |
| Map and completion UI | `lurek.ui`, `lurek.minimap`, `lurek.render` |
| Characters and flavor | `lurek.dialog`, `lurek.audio`, `lurek.i18n` |

## Runtime architecture

Use zones as authored content units. Each zone defines traversal surfaces, exits, camera bounds, collectible groups, NPC anchors, secret triggers, and unlock requirements. A global completion service tracks per-zone totals, discovered entrances, ability unlocks, and collectible flags.

Traversal abilities should be capabilities on the player state: double jump, glide, wall climb, swim, dash, magnet, light, or instrument. Gates query capabilities rather than item names. This keeps progression flexible when abilities are renamed or combined.

Collectibles should have stable IDs and categories. A collectible pickup emits an event that updates save state, UI counters, audio feedback, and optional world mutation. Avoid respawning persistent collectibles from room reloads by resolving them through saved flags during zone load.

## Suggested project structure

```text
my_collectathon/
  data/zones/*.ldtk
  data/collectibles.toml
  data/abilities.toml
  data/dialogue/*.toml
  scripts/state/progression.lua
  scripts/systems/zone_loader.lua
  scripts/systems/collectibles.lua
  scripts/systems/traversal.lua
  scripts/ui/zone_map.lua
  scripts/ui/completion_panel.lua
  assets/characters/
  assets/tiles/
```

## Vertical slice acceptance

The slice should include one hub, two connected zones, three collectible types, one unlockable traversal ability, map completion UI, one NPC hint, secret room, music transition, and save/load.

## Risks

The risk is content drift: collectathon games become hard to test when item IDs and gates are informal. Maintain a completion registry and validate that every persistent pickup and gate has a stable data ID.
