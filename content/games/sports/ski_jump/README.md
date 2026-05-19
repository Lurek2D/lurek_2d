# Ski Jump

_Choose your hill, crouch for speed on the approach, time your jump at the ramp lip, and lean through the air for maximum distance and style points._

## Run

```powershell
cargo run -- content/games/sports/ski_jump
```

## Controls

| Key       | Action                                              |
| --------- | --------------------------------------------------- |
| D         | Crouch during approach (+10% speed, less drag)      |
| Space     | Jump at ramp end / confirm landing                  |
| W         | Lean forward while airborne                         |
| S         | Lean backward while airborne                        |
| 1 / 2 / 3 | Select hill: Small (90 m) / Normal (120 m) / Large (150 m) |
| Escape    | Quit                                                |

## Gameplay

Each round consists of three phases. During the approach the skier accelerates down the ramp; holding D lowers drag and increases launch speed. Press Space at the ramp lip to jump — timing determines jump quality and initial air velocity. In the airborne phase use W/S to lean the skier forward or backward: forward lean reduces drag and extends distance, backward lean bleeds speed and improves landing stability. The simulation applies gravity, wind, and aerodynamic drag to compute a landing position. On touchdown, five judges each award up to 3 style points based on lean angle, wobble, and impact force; a clean landing scores a bonus. Points accumulate over three rounds. Three hill sizes scale ramp length and K-point distance so the same technique produces very different scores on each.

## APIs Used

**`lurek.*` engine bindings**

- `lurek.render` — draws the sky gradient, mountain silhouettes, snow landing slope, ramp line, distance markers, animated skier, particles, and all HUD overlays.
- `lurek.input` — action bindings for crouch, jump, lean forward/backward, hill selection, and quit.
- `lurek.window` — sets the window title and sky background colour on startup.
- `lurek.event` — signals clean engine shutdown on Escape.

**Lureksome (`library/`) modules**

_None._

## Changes from Original Demo

This is an original game created for the Lurek2D sports category — no prior demo existed. Physics (gravity, aerodynamic drag, lean coefficient) are custom Lua implementations. The five-judge scoring panel and three-round competition structure are designed specifically to showcase the engine's rendering API across multi-phase game states.