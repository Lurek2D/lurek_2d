# Loot RPG

_Descend through procedural dungeons, smash enemies for gear, and climb floors until your build is unstoppable._

## Run

```powershell
cargo run -- content/games/rpg/loot_rpg
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

Progress through a dungeon one room at a time. Each room triggers either an enemy encounter, a loot drop, or a rest stop before the next floor. Combat is turn-based and fully automatic — your effectiveness comes entirely from equipped gear across five slots: weapon, armor, helm, boots, and accessory. Items have four rarity tiers (Common, Rare, Epic, Legendary) that multiply their stat rolls. Your backpack is weight-limited, so choosing what to keep is the core strategic decision. Every five rooms a new floor begins with tougher enemies, better loot rolls, and scaled difficulty. Survive as many floors as possible before running out of HP.

## APIs Used

**`lurek.*` engine bindings**

- `lurek.render` — draws all HUD elements, health bars, combat log, inventory list, and game-over screen.
- `lurek.camera` — creates and positions the 2D camera for the 800 x 600 viewport.
- `lurek.particle` — sparkle burst on loot discovery and red flash on taking a combat hit.
- `lurek.tween` — animates the HP bar shrink and the loot glow fade-in.
- `lurek.input` — action-bound keyboard controls (next_room, equip, buy, quit).
- `lurek.window` — updates the window title with current floor and room number.
- `lurek.event` — signals clean engine shutdown on Escape.

**Lureksome (`library/`) modules**

_None._

## Changes from Original Demo

This is an original game created for the Lurek2D RPG category — no prior demo existed. The item rarity system, equipment slot model, weight-limited backpack, and floor progression are all custom implementations designed to showcase the engine's rendering and tween APIs in an RPG context.