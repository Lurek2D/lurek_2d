# Europa Universalis 2 Lite - Playable Province Slice

**Category:** Strategy / Grand Strategy  
**Engine:** Lurek2D  

This demo is a playable vertical slice built on the Lurek2D `lurek.province`
renderer. It keeps the large EU-style province map, then adds enough campaign
state to feel like a small grand strategy sandbox: semi-historical countries,
time, economy, manpower, armies, map modes, province selection, and simple AI
movement.

The current build also acts as a live showcase for the newer GPU-side province
presentation work: palette-driven borders, interior edge shading, subtle
terrain watermarking, hover/selection highlighting, and province labels drawn
from imported label lines.

## Run

```powershell
cargo run -- content/games/eu2
```

## What Is Playable

- Poland is the default player country.
- AI countries include Lithuania, Teutonic Order, Muscovy, Ottoman, France,
  England, and Castile.
- Provinces are assigned semi-historically from existing `province.toml`
  metadata, with neutral fallback for unmatched land.
- Monthly ticks collect treasury and manpower.
- Armies can be selected and moved through province adjacency via the public
  province route adapter.
- Occupying neutral or enemy land changes owner and refreshes the political map.
- AI armies periodically move toward frontier provinces.

## Controls

| Input | Action |
| :--- | :--- |
| LMB drag | Pan the map |
| LMB click | Select a province and a player army on that province |
| RMB click | Move the selected army toward the clicked province |
| Mouse wheel | Zoom around cursor |
| 1 | Political map |
| 2 | Terrain map |
| 3 | Economy map |
| 4 | Diplomacy map |
| 5 | Unrest/supply map |
| Space | Pause/resume campaign time |
| + / - | Change speed |
| Tab | Cycle player armies |
| R | Reset camera |
| L | Toggle labels |
| F12 | Toggle debug roads/adjacency markers |
| Esc | Quit |

## Structure

- `main.lua` owns the runtime loop, camera, and GPU province renderer setup.
  It now also applies the province FX showcase defaults used by the EU2 slice.
- `scripts/scenario.lua` defines countries, ownership rules, and starting armies.
- `scripts/state.lua` owns campaign state, time, economy, army movement, and AI;
  it consumes province adjacency/routes without owning pathfinding internals.
- `scripts/map_modes.lua` maps campaign state back into `lurek.province` styles.
- `scripts/ui.lua` owns the anchored HUD render pass and the `lurek.minimap`
  campaign overview.
- `scripts/input.lua` maps keys to state/view changes.
- `tools/prototype_map_explorer.html` is a preserved HTML prototype, not runtime content.

## Validation

```powershell
tools\python.cmd tools\validate\validate_game.py content/games/eu2
cargo test --test games_load_test -- --nocapture
```

Manual smoke checklist:

- game starts without a crash,
- pan/zoom works,
- hover and select province work,
- `Space`, `+/-`, `1..5`, `L`, `R`, `Tab`, `F12`, and RMB movement work,
- the base map is rendered by the GPU province path, while map-mode and ownership
  changes refresh registry colors and border styles,
- province labels appear on zoomed-in views, stay centered on province
  centroids, and use engine-side collision filtering,
- the province showcase FX are visible: terrain watermark, edge gradient,
  palette-driven borders, and hover/selection emphasis.
