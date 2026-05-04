# Dungeon Crawler

**Category:** retro
**Engine:** Lurek2D

First-person grid-based dungeon crawler inspired by Eye of the Beholder and Dungeon Master. Navigate a 12x12 dungeon rendered with raycasting pseudo-3D, collect orbs, and explore by torchlight.

## Run

```bash
python tools/dev/parallel_cargo.py run debug -- content/games/retro/dungeon_crawler
```

## Controls

| Key    | Action          |
| ------ | --------------- |
| W      | Move forward    |
| S      | Move backward   |
| A      | Turn 90° left   |
| D      | Turn 90° right  |
| F1     | Weather: clear  |
| F2     | Weather: rain   |
| F3     | Weather: snow   |
| Escape | Quit            |

## Gameplay

- Grid-based movement with smooth lerp transitions between cells
- Raycasting renders a first-person pseudo-3D viewport on the left half of the screen
- Textured-quad first-person scene built by lurek.raycaster:buildScene
- Six procedural wall materials (stone, brick, mossy, magic, wood, steel)
- Floor and ceiling shading from scene parameters
- Collect all 8 orbs scattered through the dungeon (+100 score each)
- Minimap on the right panel reveals explored cells, orb locations, and player direction
- Compass indicator shows current facing direction (N/E/S/W)
- Weather mode switch (F1-F3) in HUD
- Two states: PLAYING -> COMPLETE (all orbs collected)

## APIs Used

- `lurek.render` — rectangle, circle, line, print, setColor, setBackgroundColor
- `lurek.input` — bind, wasActionPressed, isActionDown
- `lurek.camera` — viewport management
- `lurek.window` — setTitle
- `lurek.timer` — getFPS, getTime, delta
- `lurek.event` — quit

## Changes from Original Demo

- Full rewrite with action-based input system
- Added raycaster buildScene viewport using textured quads
- Added six procedural wall textures mapped per tile id
- Smooth lerp movement and turning animations
- Minimap with fog-of-war exploration
- Compass indicator
- Two-state flow: PLAYING -> COMPLETE
- Keyboard-first controls with WSAD movement/turning
- Separated render/render_ui callbacks
