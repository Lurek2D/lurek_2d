# input_action_map

Maps named game actions to one or more physical bindings (keyboard keys, mouse buttons, gamepad buttons/axes). Provides `pressed`, `held`, `released`, and `axis` queries by action name instead of raw input codes.

## Usage

```lua
local InputActionMap = require("library/input_action_map")

local actions = InputActionMap.new()
actions:bind("jump",    { key = "space", gamepad_button = "a" })
actions:bind("move_x",  { axis = "left_x", keys = { neg = "a", pos = "d" } })
actions:bind("attack",  { key = "z", mouse_button = 1 })

function lurek.update(dt)
    if actions:pressed("jump") then player:jump() end
    local dx = actions:axis("move_x")
    player:move(dx * 200 * dt, 0)
end
```

## Dependencies

- `lurek.input` (optional — stubs return false/0 headlessly)
