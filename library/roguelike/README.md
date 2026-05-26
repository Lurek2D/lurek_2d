# roguelike

A roguelike toolkit providing three foundational algorithms: a shadowcast FOV system, an energy-based turn scheduler, and a Dijkstra goal-map for AI navigation. All three work on a shared tile grid and interoperate cleanly.

## Usage

```lua
local roguelike = require("library/roguelike")

-- Field of view
local fov = roguelike.Fov.new({ radius = 8 })
fov:compute(player_x, player_y, function(x, y) return is_opaque(x, y) end)
print("Can see 10,5:", fov:visible(10, 5))

-- Turn scheduler (energy model)
local sched = roguelike.Scheduler.new()
sched:add(player,  { speed = 12 })
sched:add(goblin1, { speed =  8 })
local actor = sched:next()   -- returns actor with most energy

-- Goal map (Dijkstra)
local goals = roguelike.GoalMap.new(MAP_W, MAP_H)
goals:setGoal(player_x, player_y)
goals:compute(function(x, y) return is_passable(x, y) end)
local nx, ny = goals:bestNeighbour(goblin_x, goblin_y)
```

## Dependencies

- `lurek.tilemap` (optional), `lurek.pathfind` (optional)
