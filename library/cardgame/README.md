# cardgame

A TCG/card-game framework. Models card type definitions, individual card instances, stacks (hand, deck, discard), slot zones, and a deck builder. Handles shuffling, drawing, playing, and zone transfers.

## Usage

```lua
local cardgame = require("library/cardgame")

local fire_bolt = cardgame.CardTypeDef.new({ id = "fire_bolt", name = "Fire Bolt", cost = 2 })
local deck = cardgame.DeckBuilder.new():add(fire_bolt, 4):build()

local hand = cardgame.Stack.new({ max_size = 7 })
deck:drawInto(hand, 5)

local card = hand:peek()
hand:playCard(card)
```

## Dependencies

- `lurek.math` (optional), `lurek.tween` (optional), `lurek.event` (optional)
