# sprite

A rule-based sprite animation state machine controller. Wraps `lurek.sprite` frame playback inside an `AnimController` that transitions between named states (idle, walk, attack, hurt) based on conditions you define, eliminating manual `if/else` animation switching.

## Usage

```lua
local sprite = require("library/sprite")

local ctrl = sprite.AnimController.new(sprite_sheet)
ctrl:addState("idle",   { anim = "idle",   loop = true })
ctrl:addState("walk",   { anim = "walk",   loop = true })
ctrl:addState("attack", { anim = "attack", loop = false, then_state = "idle" })

ctrl:addTransition("idle",  "walk",   function() return math.abs(vx) > 1 end)
ctrl:addTransition("walk",  "idle",   function() return math.abs(vx) < 1 end)
ctrl:addTransition("idle",  "attack", function() return attacking end)

function lurek.update(dt)
    ctrl:update(dt)
end

function lurek.draw()
    ctrl:draw(x, y)
end
```

## Dependencies

- `lurek.sprite` (optional — stubs work headlessly)
