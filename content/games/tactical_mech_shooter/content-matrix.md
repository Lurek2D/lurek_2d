# Content matrix

The game data is intentionally exhaustive so a later content pass can replace entries without changing Lua modules.

| TOML file | Required records | Runtime consumer | Proof |
|---|---:|---|---|
| `mods/core/corpora.toml` | 30 | `domain/build.lua`, actor stats, renderer | `app/content_validator.lua` |
| `mods/core/weapons.toml` | 50 | `systems/combat.lua`, projectile/beam/area dispatch | `app/content_validator.lua` |
| `mods/core/backpacks.toml` | 30 + `none` | `domain/build.lua`, energy/armor/signature modifiers | `app/content_validator.lua` |
| `mods/core/presets.toml` | 12 | hangar and squad spawns | `app/content_validator.lua` |
| `mods/core/maps/arena_01.toml` | 1 map | shared tilefield, physics walls, tilelight | `systems/world.lua` |
| `mods/core/tiles.toml` | tile profiles | movement, awareness, lighting, minimap | registry load |
| `mods/core/ai.toml` | AI profiles | `systems/ai.lua` | registry load |

The HTML prototype is represented by the `f1..f8` presets plus four support presets, twin-hand weapons, smooth aim/movement, jump/run/sneak states, projectile/explosion feedback and an 8,000×8,000 world. The TXT brief is represented by the full 30/50/30 catalogs, cargo budget, energy delay, terrain, tile visibility, light/smoke, awareness, AI and mod registry contracts.
