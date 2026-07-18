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
| P | Pause or return (Escape quits the engine window) |
| R | Restart the current battle |

## Architecture

The game keeps runtime state in Lua context tables and loads all gameplay data from `mods/core/*.toml`. `lurek.tilefield` is the shared semantic map. Continuous positions and projectiles use `lurek.physics`; awareness, tile light, pathfinding, AI, camera, minimap and UI consume the same map state.

Typography uses Lurek's bundled bitmap atlas at exactly 10 px for render text and TOML UI labels.

The game ships with 30 corpora, 50 weapons, 30 backpacks and twelve presets, including medic, engineer, sapper and optical scout roles. The core mod is discovered by `lurek.mods`; additional data-only packs can register the same content types in a follow-up mod pass.

## APIs used

`lurek.mods`, `lurek.asset`, `lurek.filesystem`, `lurek.serialize`, `lurek.event`, `lurek.input`, `lurek.camera`, `lurek.tilefield`, `lurek.tilelight`, `lurek.awareness`, `lurek.physics`, `lurek.pathfind`, `lurek.ai`, `lurek.minimap`, `lurek.ui`, `lurek.tween`, `lurek.math`, `lurek.window` and `lurek.render`.
