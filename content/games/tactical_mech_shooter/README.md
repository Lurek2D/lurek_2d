# Tactical Mech Shooter

Scale: game

Status: complete playable game

A data-driven top-down tactical shooter inspired by the supplied Gemini HTML prototype, Star Control 2 and Metal Fatigue. The player buys an affordable squad, pilots one mech at a time, fights through a tile-based arena and carries stars/levels into the next battle.

## Run

```powershell
cargo run -- content/games/tactical_mech_shooter
```

Run the colocated headless regression suite with:

```powershell
cargo test --test lua_tests -- lua_demo_colocated_games --nocapture
```

## Controls

| Key | Action |
|---|---|
| WASD | Smooth world movement |
| Space | Jump / temporary airborne movement |
| Shift | Run; drains energy |
| Ctrl | Sneak; slower and harder to detect |
| Alt | Aim; stops movement and tightens both reticles |
| Mouse | Turret target |
| LMB / RMB | Fire the two hands independently |
| Tab | Switch the active allied mech during battle |
| F1-F12 | Select the hangar preset before deployment |
| M | Cycle through the six PNG map scenarios in the hangar |
| P | Pause or return (Escape quits the engine window) |
| R | Restart the current battle |

## Architecture

The game keeps runtime state in Lua context tables and loads gameplay data through `lurek.filesystem.listRecursive`, `lurek.serialize.fromToml`, `lurek.mods`, and `lurek.image.newImageData`. Six one-pixel-per-tile PNG maps are catalogued in `mods/core/maps/maps.toml`; the image defines terrain, walls, doors, bases, point lights and the CTF flag marker. `lurek.tilefield` is the shared semantic map. Continuous positions and projectiles use `lurek.physics`; awareness, tile light, pathfinding, AI, camera, minimap and UI consume the same map state.

Typography uses Lurek's bundled bitmap atlas at exactly 10 px for render text and TOML UI labels.

The core mod ships with `modern_light`, `modern_heavy`, organic, and alien race bundles. `modern_light` owns personnel chassis and portable equipment; `modern_heavy` owns vehicle chassis and heavy equipment. Each race owns its corpus, backpack, and weapon files under `mods/core/races/<race>/`. The loader injects race flags into every entry, and build composition requires an intersecting flag (or `universal`) before equipment can be mounted. Twelve presets include scout, assault, medic, engineer, artillery, and vehicle roles. The core mod is discovered by `lurek.mods`; additional data-only packs can register the same content types in a follow-up mod pass.

### Raster asset pipeline

Every visible unit and combat asset is a PNG referenced by TOML: races use `icon`, while corpora, backpacks and weapons use `sprite`; `effects.toml` maps projectile, beam, smoke, hazard, field and explosion records to PNGs. `app/content_loader.lua` loads these paths with `lurek.render.newImage`, and the renderer draws the resulting images with `lurek.render.draw`. The core pack contains 129 deterministic pixel-art PNGs under `mods/core/assets/`; no mech, weapon, projectile or explosion silhouette is built from runtime primitives.

Every race, corpus, weapon, and backpack entry also has a long English `description` written as a visual brief for a top-down pixel-art sprite. It specifies the transparent background, silhouette, palette, materials, lighting accents, and identifying details so an external art model can regenerate the matching PNG later. The catalog validator requires these descriptions on every entry.

For Gemini, use [GEMINI_ASSET_BRIEF.md](GEMINI_ASSET_BRIEF.md) together with `tools/visual_asset_descriptions.toml`. It defines the exact top-down camera, canvas sizes, sprite-local orientation, corpus rotation frame, equipment layering, faction language, and a copy-ready per-asset prompt format.

### SVG authoring pipeline

`extract_visual_asset_descriptions.py` exports all 121 visual briefs to `visual_asset_descriptions.toml`. Each SVG is an individual source file beside its PNG target under `assets/races`, `assets/corpora/<race>`, `assets/weapons/<race>`, or `assets/backpacks/<race>`; there is no template SVG generator. Edit the appropriate SVG directly, using its matching TOML description as the art brief. Every corpus source has a circular 96×96 frame so the complete top-down chassis stays visually coherent while it rotates. Backpacks are rear modules and weapons point horizontally outward, allowing the game to compose them behind and on each side of the chassis.

After changing an SVG, rasterize the sources from the repository root:

```powershell
tools\python.cmd content/games/tactical_mech_shooter/tools/extract_visual_asset_descriptions.py
tools\python.cmd content/games/tactical_mech_shooter/tools/render_svg_assets.py
```

### PNG map palette

The maps are authored one pixel per tile. RGB values already used by `mods/core/tiles.toml` select floor, grass, sand, water, walls, windows, and doors. Special marker colors select team bases, colored point lights, and the neutral white CTF flag. `maps.toml` supplies scenario metadata only: `free_for_all`, `balanced_2v2`, `assault`, or `capture_the_flag`, plus team counts and objective labels. The palette legend is kept next to the decoder in `app/content_loader.lua`.

### Map catalog

| Map | Scenario | Teams | Objective |
|---|---|---:|---|
| `arena_01` | Free for all | 4 | Elimination |
| `twin_bastion` | Balanced 2v2 | 4 | Two allied pairs |
| `crossfire_quads` | Free for all | 4 | Elimination |
| `assault_northline` | Assault | 2 | Destroy team 2 base |
| `assault_reactor` | Assault | 2 | Destroy team 2 base |
| `tri_flag_rift` | Capture the flag | 3 | Capture the neutral flag three times |

## APIs used

`lurek.mods`, `lurek.asset`, `lurek.filesystem`, `lurek.serialize`, `lurek.event`, `lurek.input`, `lurek.camera`, `lurek.tilefield`, `lurek.tilelight`, `lurek.awareness`, `lurek.physics`, `lurek.pathfind`, `lurek.ai`, `lurek.minimap`, `lurek.ui`, `lurek.tween`, `lurek.math`, `lurek.window` and `lurek.render`.
