# roguelike

A roguelike toolkit with field-of-view, an energy scheduler, and goal-map
distance fields. `Fov` and `GoalMap` use engine backends when available and
fall back to pure Lua behavior otherwise.

## Usage

```lua
local rl = require("library.roguelike")

local fov = rl.newFov({ range = 8 })
fov:setBlocker(function(x, y)
    return x == 2 and y == 0
end)
fov:compute(0, 0)

local scheduler = rl.newScheduler()
scheduler:add("hero", 12)
scheduler:add("goblin", 8)

local goals = rl.newGoalMap(20, 20)
goals:addSource(10, 10, 0):bake()
local dx, dy = goals:gradientAt(5, 5)
print(fov:isVisible(1, 0), scheduler:peek(), dx, dy)
```

## Optional bindings

- `lurek.awareness.newFov`: engine-backed FOV with the same visible/explored API.
- `lurek.pathfind.newGoalMap`: engine-backed goal map used by `GoalMap:bake()`.
- `lurek.math.bresenham`: preferred backend for `rl.bresenham()`.
- `lurek.tilemap`: convenient blocker source for `attachTilemap()`.

`Scheduler` remains pure Lua because it models energy turns, not real-time
engine scheduling.
