# Acceptance checklist

- [x] `main.lua` exposes init/process/process_physics/draw/draw_ui callbacks.
- [x] No Rust or Lurek API additions; the game consumes existing APIs.
- [x] Race gameplay records are TOML and loaded through `lurek.serialize`, `lurek.asset`, `lurek.filesystem`, and `lurek.mods`; the authored arena is a PNG decoded through `lurek.image`.
- [x] Shared `lurek.tilefield` drives movement blocking, awareness channels, tilelight, minimap terrain and map rendering.
- [x] Continuous bodies/projectiles use `lurek.physics`; projectiles have independent velocity and range.
- [x] `lurek.awareness` gates enemy visibility and smoke; `lurek.ai` provides the active world and stimulus handles while game-side cadence controls LOD.
- [x] Camera, pathfinding, ORCA avoidance, UI layout, visible minimap and tween update are wired; gameplay sprites are raster PNG assets.
- [x] Campaign loop is title → hangar → battle → results with runtime save data outside the packaged game sources.
- [x] Catalog validator enforces modern_light/modern_heavy personnel and vehicle bundles, organic/alien bundles, race flags, compatible preset mounts, and twelve presets.
- [x] Six PNG map scenarios are catalogued: two free-for-all/balanced multiplayer maps, two two-team assaults, and one three-team capture-the-flag map.
- [x] Race icons, corpora, backpacks, weapons, projectiles and explosions are loaded as TOML-referenced PNG assets.
- [x] Every race, corpus, weapon and backpack has a top-down pixel-art visual description suitable as an AI image-generation brief.
- [x] Map selection cycles from the hangar with `M`; team counts and 2v2 alliances flow into spawning, AI, combat, awareness, rendering and victory checks.
- [x] Run `tools/python.cmd tools/validate/validate_game.py content/games/tactical_mech_shooter` (28 files, 0 issues).
- [x] Run `cargo test --test lua_tests -- lua_demo_colocated_games --nocapture` for the colocated headless regressions.
- [x] Run the game smoke harness for 120 frames and store evidence under the repository `work/` directory.
