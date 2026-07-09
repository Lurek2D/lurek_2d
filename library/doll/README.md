# doll

A socket-based composition library for layered 2D characters, equipment, and
modular visuals. The library produces draw-list entries; the game renders them.

## Usage

```lua
local doll = require("library.doll")

local template = doll.newTemplate("humanoid")
template:addSocket("body", "body", 0, 0, 0, 0)
template:addSocket("head", "head", 0, -20, 0, 10)
template:addSocket("weapon", "", 14, -8, 0, 20)

local actor = doll.newDoll(template)
local body = doll.newPart()
body:setTexture("assets/body.png")
actor:attach("body", body)

actor:setPosition(100, 200)
for _, entry in ipairs(actor:getDrawList()) do
    -- Dispatch entry.texture / entry.x / entry.y / entry.rotation / entry.color
    -- to lurek.render or another renderer in game code.
end
```

## Optional bindings

- `lurek.image`: texture loading for part textures in game code.
- `lurek.render`: one possible renderer for `getDrawList()` entries.

`Doll:draw()` is deprecated and intentionally does not own rendering anymore.
