# Loot RPG (Demo)

_A focused demo of the Lurek2D loot-and-combat loop — fight enemies, collect tiered gear, and see how many floors you can climb._

## Run

```powershell
cargo run -- content/games/rpg/loot_rpg_demo
```

## Controls

| Key       | Action                                        |
| --------- | --------------------------------------------- |
| Space     | Advance room / attack (combat) / collect loot |
| E         | Auto-equip best item from backpack            |
| B         | Buy healing potion (5g)                       |
| Up / Down | Scroll inventory list                         |
| Escape    | Quit                                          |

## Gameplay

Progress through a dungeon one room at a time. Each room triggers either an enemy encounter, a loot drop, or a rest stop before the next floor. Combat is turn-based and fully automatic — your effectiveness comes entirely from equipped gear across five slots: weapon, armor, helm, boots, and accessory. Items drop with four rarity tiers (Common, Rare, Epic, Legendary) that multiply stat rolls. Your backpack is weight-limited, so choosing what to keep and what to discard is the core decision. Every five rooms a new floor begins with harder enemies and better loot. Survive as many floors as possible.

## APIs Used

**`lurek.*` engine bindings**

- `lurek.render` — draws all HUD elements, health bars, combat log, inventory list, and game-over screen.
- `lurek.camera` — creates and positions the 2D camera for the 800 x 600 viewport.
- `lurek.particle` — sparkle burst on loot discovery and red flash on combat hits.
- `lurek.tween` — animates the HP bar shrink and the loot glow fade-in.
- `lurek.input` — action-bound keyboard controls (next_room, equip, buy, quit).
- `lurek.window` — updates the window title with the current floor and room number.
- `lurek.event` — signals clean engine shutdown on Escape.

**Lureksome (`library/`) modules**

_None._

## Changes from Original Demo

This is the demo build of the `loot_rpg` project — same core mechanics, same API surface. It serves as a focused showcase of the engine's particle, tween, and render APIs in a minimal RPG setting without additional content layers.