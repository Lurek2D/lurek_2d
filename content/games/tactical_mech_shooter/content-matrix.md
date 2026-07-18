# Content matrix

The game data is intentionally exhaustive so a later content pass can replace entries without changing Lua modules.

| TOML file | Required records | Runtime consumer | Proof |
|---|---:|---|---|
| `mods/core/races/modern_light/corpora.toml` | personnel chassis | `domain/build.lua`, actor stats, renderer | `app/content_validator.lua` |
| `mods/core/races/modern_heavy/corpora.toml` | vehicle chassis | `domain/build.lua`, actor stats, renderer | `app/content_validator.lua` |
| `mods/core/races/*/weapons.toml` | modern light/heavy plus organic/alien equipment | `systems/combat.lua`, projectile/beam/area dispatch | `app/content_validator.lua` |
| `mods/core/races/*/backpacks.toml` | race-specific cargo modules and universal empty mount | `domain/build.lua`, energy/armor/signature modifiers | `app/content_validator.lua` |
| `mods/core/races/*/race.toml` | modern_light, modern_heavy, organic, alien flags | loader and race compatibility checks | `app/content_validator.lua` |
| `description` fields in race/corpus/weapon/backpack TOML | 121 top-down pixel-art visual briefs | future AI asset generation and catalog review | `app/content_validator.lua` |
| `mods/core/assets/races/*.png` | 4 race icons | hangar identity and race selection | `app/content_loader.lua`, `scenes/hangar.lua` |
| `mods/core/assets/corpora/**/*.png` | one raster sprite per corpus | mech body rendering | `systems/render.lua` |
| `mods/core/assets/backpacks/**/*.png` | one raster sprite per backpack | equipment preview and mech loadout rendering | `systems/render.lua`, `scenes/hangar.lua` |
| `mods/core/assets/weapons/**/*.png` | one raster sprite per weapon | weapon preview and firing animation | `systems/render.lua`, `scenes/hangar.lua` |
| `mods/core/assets/{races,corpora,weapons,backpacks}/**/*.svg` | 121 individually authored same-name vector source sprites | source art, one file per visual brief, before PNG rasterization | `tools/render_svg_assets.py` |
| `mods/core/effects.toml` + `mods/core/assets/effects/*.png` | 8 projectile/effect records | projectile, beam, smoke and explosion rendering | `systems/combat.lua`, `systems/effects.lua`, `systems/render.lua` |
| `mods/core/presets.toml` | 12 | hangar and squad spawns | `app/content_validator.lua` |
| `mods/core/maps/maps.toml` | 6 scenario records | map selection, modes, teams and objectives | `app/content_loader.lua`, `app/content_validator.lua` |
| `mods/core/maps/*.png` | 6 palette-indexed maps | shared tilefield, physics walls, tilelight and objective markers | `systems/world.lua`, `systems/render.lua` |
| `mods/core/tiles.toml` | tile profiles | movement, awareness, lighting, minimap | registry load |
| `mods/core/ai.toml` | AI profiles | `systems/ai.lua` | registry load |

The HTML prototype is represented by the `f1..f8` presets plus four support presets, twin-hand weapons, smooth aim/movement, jump/run/sneak states, projectile/explosion feedback and an 8,000×8,000 world. The TXT brief is represented by the race-partitioned catalogs, cargo budget, energy delay, PNG palette terrain, tile visibility, light/smoke, awareness, AI and mod registry contracts.
