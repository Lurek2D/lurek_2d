# tools/demos/

Demo-folder maintenance for `content/games/`: structural fixes, screenshot regeneration, and smoke testing.

## Scripts

| Script | Purpose | Key args |
|---|---|---|
| `organize_demos.py` | Three-in-one demos maintenance tool (rename/sort/normalise structure) | `--dry-run` |
| `gen_demo_screenshots.py` | Capture only `screen.png` for every game demo — 6 in parallel, each window placed in its own grid slot | `--demo NAME`, `--overwrite`, `--rebuild`, `--workers`, `--screenshot-time`, `--force-window-size`, `--start-signal`, `--start-keys` |
| `smoke_sweep.py` | Smoke-test all playable demos/examples by launching each and checking for crashes | `--timeout SECS`, `--demo NAME` |
| `gen_game_readmes.py` | Generate or repair README.md files for `content/games/` projects — extracts `lurek.*` API refs from `main.lua` and writes a structured README matching the canonical template | `--game PATH`, `--all`, `--dry-run`, `--threshold N`, `--force` |

## Common usage

```powershell
# Capture all demos (6 at a time, 3-second wait, native demo resolution, saves only screen.png in each game folder)
python tools/demos/gen_demo_screenshots.py --overwrite

# Dry-run — print what would be executed without launching anything
python tools/demos/gen_demo_screenshots.py --dry-run

# Single demo by name
python tools/demos/gen_demo_screenshots.py --demo hello_world --overwrite

# Custom concurrency or timing
python tools/demos/gen_demo_screenshots.py --workers 3 --screenshot-time 3.0 --overwrite

# If a demo has a startup menu, explicitly enable startup-key simulation (enter,space,1,2,3)
python tools/demos/gen_demo_screenshots.py --overwrite --start-signal auto

# Force slot window size only if you really need fixed-size layout
python tools/demos/gen_demo_screenshots.py --overwrite --force-window-size

# Smoke-test all projects
python tools/demos/smoke_sweep.py

# Smoke-test only content/examples/*.lua sequentially through lurek2d
python tools/demos/smoke_sweep.py --kind example

# Smoke-test only playable demos under content/games/
python tools/demos/smoke_sweep.py --kind game

# Preview a generated README for one game (no file write)
python tools/demos/gen_game_readmes.py --dry-run --game content/games/rpg/loot_rpg

# Fix all READMEs that are shorter than 30 lines
python tools/demos/gen_game_readmes.py --all

# Regenerate all READMEs regardless of current length
python tools/demos/gen_game_readmes.py --all --force
```
Note: when `--binary` is omitted, auto-detection now prefers `build/debug/lurek2d(.exe)` first for capture stability.

For `--kind example`, PASS means the example ran to completion through the real engine without detected runtime/Lua errors. Examples do not need to produce screenshots to pass.

## Window layout

When running with `--workers 6` (default) the six windows are placed in a 3 × 2
grid on the primary monitor. By default demos keep their own resolution; slot
size (`--slot-width` × `--slot-height`) is used only for positioning.
Enable `--force-window-size` to resize all demo windows to slot dimensions.

```
┌──────────┬──────────┬──────────┐
│  slot 0  │  slot 1  │  slot 2  │
│ (0, 0)   │ (640, 0) │ (1280,0) │
├──────────┼──────────┼──────────┤
│  slot 3  │  slot 4  │  slot 5  │
│ (0, 480) │(640,480) │(1280,480)│
└──────────┴──────────┴──────────┘
```
