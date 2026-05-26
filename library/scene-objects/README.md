# scene-objects

A pure-Lua, runtime-agnostic container for managing game objects within a scene. It holds any table with optional `draw`, `update`, and `layer` fields, calls `update(dt)` on all objects in insertion order every frame, and calls `draw()` in ascending layer order so that background, mid-ground, and UI objects paint correctly without any manual sorting.

## Usage

```lua
local sceneobj = require("library/scene-objects")

local world = sceneobj.new()

local bg     = { layer = 0, draw = function(self) ... end }
local player = { layer = 5, draw = function(self) ... end,
                             update = function(self, dt) ... end }
local hud    = { layer = 10, draw = function(self) ... end }

world:add(bg)
world:add(player)
world:add(hud)

-- inside your scene update callback:
world:update(dt)

-- inside your scene draw callback:
world:draw()

-- cleanup when leaving the scene:
world:clear()
```
