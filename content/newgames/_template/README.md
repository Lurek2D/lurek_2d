# Sector Runner Template

**Category:** Template / Arcade  
**Engine:** Lurek2D

Sector Runner is a small complete mini-game template for new `content/newgames`
projects. The player pilots a rescue craft through patrol drones, collects
three fuel cells, and reaches the extraction gate before the shield fails.

## Run

From the repository root:

- `cargo run -- content/newgames/_template`

## Controls

| Input | Action |
| :--- | :--- |
| WASD / arrows | Move ship |
| Space / Enter | Start or restart |
| R | Restart |
| Escape | Quit |

## Design Notes

- `main.lua` only loads modules and exposes Lurek callbacks.
- `scripts/state.lua` owns the playable loop, win/loss rules, collisions, particles, and timers.
- `scripts/input.lua` owns action bindings and player intent.
- `scripts/renderer.lua` owns world rendering and uses `lurek.render` plus a local PNG sprite.
- `scripts/ui.lua` loads `ui.toml` and updates HUD/title/end-state widgets.
- `scripts/audio.lua` loads local WAV files and plays short feedback sounds.

## APIs Used

- `lurek.window` for title and dimensions.
- `lurek.render` for shapes, sprites, background, and text fallback.
- `lurek.input` for action bindings.
- `lurek.ui` for TOML-driven HUD and overlays.
- `lurek.audio` for local WAV feedback.
- `lurek.particle` for pickup, damage, and extraction bursts.
- `lurek.timer` for FPS and time display.
- `lurek.event` for clean quit.
- `lurek.filesystem` for module loading.

## New Game Checklist

- Rename the folder and update `scripts/config.lua`.
- Replace the template mission with the requested game design.
- Keep modules split by responsibility; do not collapse the game into one file.
- Keep all custom PNG/audio/font/data assets in this folder.
- Capture `screen.png` from active gameplay, not the title screen.
- Run `tools\python.cmd tools\validate\validate_game.py content/newgames/<name>`.
- Run `build\debug\lurek2d.exe content/newgames/<name> --screenshot=screen.png --screenshot-frames=180`.
