# Acceptance checklist

- [x] `main.lua` exposes init/process/process_physics/draw/draw_ui callbacks.
- [x] No Rust or Lurek API additions; the game consumes existing APIs.
- [x] All gameplay records are TOML and loaded through `lurek.serialize`, `lurek.asset`, `lurek.filesystem`, `lurek.mods`.
- [x] Shared `lurek.tilefield` drives movement blocking, awareness channels, tilelight, minimap terrain and map rendering.
- [x] Continuous bodies/projectiles use `lurek.physics`; projectiles have independent velocity and range.
- [x] `lurek.awareness` gates enemy visibility and smoke; `lurek.ai` provides the active world and stimulus handles while game-side cadence controls LOD.
- [x] Camera, pathfinding, ORCA avoidance, UI layout, visible minimap, tween update and procedural vector shapes are wired.
- [x] Campaign loop is title → hangar → battle → results with runtime save data outside the packaged game sources.
- [x] Catalog validator enforces exactly 30 corpora, 50 weapons, 30 backpacks plus `none`, and twelve presets.
- [x] Run `tools/python.cmd tools/validate/validate_game.py content/games/tactical_mech_shooter` (28 files, 0 issues).
- [x] Run `cargo test --test lua_tests -- lua_demo_colocated_games --nocapture` for the colocated headless regressions.
- [x] Run the game smoke harness for 120 frames and store evidence under the repository `work/` directory.
