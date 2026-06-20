# Demo Template

_A small playable Lurek2D demo skeleton for new catalog-ready games._

## Run

```powershell
cargo run -- content/games/<category>/<name>
```

## Controls

| Key | Action |
|---|---|
| WASD / Arrows | Move |
| Space / Enter | Start or restart |
| R | Restart |
| Escape | Quit |

## Gameplay

Collect every marker in the arena. Use this template as the starting point for a small complete game, then replace the pickup loop with the real mechanic.

## APIs Used

- `lurek.window` - title setup.
- `lurek.render` - background, text, shapes, and HUD drawing.
- `lurek.input` - action-based input bindings.
- `lurek.event` - clean quit handling.

## Catalog Requirements

- Keep `main.lua`, `README.md`, `screen.png`, and `preview.gif` in the game folder.
- Run `python tools/validate/validate_game.py content/games/<category>/<name>`.
- Run `python tools/demos/smoke_sweep.py --kind game --only <name> --frames 300`.
