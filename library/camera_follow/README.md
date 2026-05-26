# camera_follow

A smooth camera controller built on top of `lurek.camera`. Adds deadzone, lookahead, world-bounds clamping, camera shake presets, and a cutscene override mode that the native follow API does not bundle together.

## Usage

```lua
local CameraFollow = require("library/camera_follow")

local cam = CameraFollow.new({
    deadzone = { w = 80, h = 60 },
    lookahead = { x = 40, y = 0 },
    bounds = { x = 0, y = 0, w = 3200, h = 2400 },
})

function lurek.update(dt)
    local px, py = player:getPosition()
    cam:setTarget(px, py)
    cam:update(dt)
    cam:apply()
end

cam:shake({ duration = 0.4, intensity = 8 })
```

## Dependencies

- `lurek.camera`, `lurek.math.clamp` (optional — stubs work headlessly)
