# tools/demos/

Demo-folder maintenance for `content/games/`: structural fixes, screenshot regeneration, and smoke testing.

## Scripts

| Script | Purpose | Key args |
|---|---|---|
| `organize_demos.py` | Three-in-one demos maintenance tool (rename/sort/normalise structure) | `--dry-run` |
| `gen_demo_screenshots.py` | Capture a `screen.png` for every game demo — 6 in parallel, each window placed in its own grid slot | `--demo NAME`, `--overwrite`, `--rebuild`, `--workers`, `--screenshot-time` |
| `smoke_sweep.py` | Smoke-test all playable demos/examples by launching each and checking for crashes | `--timeout SECS`, `--demo NAME` |
| `gen_game_readmes.py` | Generate or repair README.md files for `content/games/` projects — extracts `lurek.*` API refs from `main.lua` and writes a structured README matching the canonical template | `--game PATH`, `--all`, `--dry-run`, `--threshold N`, `--force` |

## Common usage

```powershell
# Capture all 124 demos (6 at a time, 2-second wait, saves screen.png in each game folder)
python tools/demos/gen_demo_screenshots.py --overwrite

# Dry-run — print what would be executed without launching anything
python tools/demos/gen_demo_screenshots.py --dry-run

# Single demo by name
python tools/demos/gen_demo_screenshots.py --demo hello_world --overwrite

# Custom concurrency or timing
python tools/demos/gen_demo_screenshots.py --workers 3 --screenshot-time 3.0 --overwrite

# Smoke-test all projects
python tools/demos/smoke_sweep.py

# Preview a generated README for one game (no file write)
python tools/demos/gen_game_readmes.py --dry-run --game content/games/rpg/loot_rpg

# Fix all READMEs that are shorter than 30 lines
python tools/demos/gen_game_readmes.py --all

# Regenerate all READMEs regardless of current length
python tools/demos/gen_game_readmes.py --all --force
```

## Window layout

When running with `--workers 6` (default) the six windows are placed in a 3 × 2
grid on the primary monitor.  Each slot is `--slot-width` × `--slot-height`
pixels (default 640 × 480):

```
┌──────────┬──────────┬──────────┐
│  slot 0  │  slot 1  │  slot 2  │
│ (0, 0)   │ (640, 0) │ (1280,0) │
├──────────┼──────────┼──────────┤
│  slot 3  │  slot 4  │  slot 5  │
│ (0, 480) │(640,480) │(1280,480)│
└──────────┴──────────┴──────────┘
```
