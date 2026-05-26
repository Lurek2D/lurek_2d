# tween_chain

A pure-Lua chainable tween sequencer. Composes property animations, waits, and callbacks into a single chain with a fluent builder API. Supports parallel groups, 11+ easing functions, loop modes, and reversal. Complementary to `lurek.tween` — adds a builder syntax for sequential animation scripts.

## Usage

```lua
local tween_chain = require("library/tween_chain")

local obj = { x = 0, y = 0, alpha = 1.0 }

local chain = tween_chain.TweenChain.new(obj)
    :to({ x = 400 }, 1.0, "ease_in_out")
    :wait(0.5)
    :to({ y = 200, alpha = 0.5 }, 0.8, "ease_out")
    :call(function() print("done!") end)
    :loop(2)

chain:start()

function lurek.update(dt)
    chain:update(dt)
end
```

## Dependencies

- `lurek.log` (optional — pure Lua)
