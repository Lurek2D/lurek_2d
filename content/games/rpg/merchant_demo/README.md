# Merchant (Demo)

_A playable demo of the Lurek2D merchant simulation — buy, sell, serve customers, and turn a profit over five in-game days._

## Run

```powershell
cargo run -- content/games/rpg/merchant_demo
```

## Controls

| Key    | Action                                         |
| ------ | ---------------------------------------------- |
| 1–8    | Buy item from shelf / sell item (in sell mode) |
| A      | Auto-buy the most expensive affordable item    |
| S      | Toggle sell mode                               |
| R      | Restock the merchant shelf                     |
| L      | Open / close the sales ledger                  |
| Escape | Quit                                           |

## Gameplay

Manage a medieval shop stocking eight items across Weapons, Armor, and Potions categories. Buy items from the shelf into your inventory and sell them back at 75% of cost — or wait for customers who pay a 120% premium. A customer arrives every five seconds wanting a random item; serving them raises your reputation, which gradually increases sell prices. Missing requests lowers reputation. Each of the five days lasts 60 seconds; after the final day your accumulated gold is your score. The sales ledger (L) logs every transaction for review. Higher reputation means more profitable deals and a larger end score.

## APIs Used

**`lurek.*` engine bindings**

- `lurek.render` — draws the shop backdrop, shelf panels, inventory grid, customer sprite, particle effects, and all text overlays.
- `lurek.input` — raw keyboard queries for number keys 1–8 and action keys A, S, R, L, Escape.
- `lurek.window` — sets the window title on startup.
- `lurek.timer` — sets the target frame rate to 60 FPS.
- `lurek.event` — signals clean engine shutdown on Escape.
- `lurek.camera` — reads camera position for scene origin alignment.

**Lunasome (`library/`) modules**

_None._

## Changes from Original Demo

This is the demo build of the `merchant` project. It uses the same mechanics and API surface as the full version, serving as a focused showcase of the engine's rendering and timer APIs in a management-game context. Note: the `## Run` path above correctly points to `content/games/rpg/merchant_demo`.