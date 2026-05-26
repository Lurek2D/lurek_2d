# doll

A socket-based sprite composition engine. Defines a DollTemplate with named attachment sockets, then instantiates Doll objects that slot Part images (body, head, weapon, armor) into those sockets. Supports per-part tinting, offsets, and z-order.

## Usage

```lua
local doll = require("library/doll")

local template = doll.DollTemplate.new("humanoid")
template:addSocket("body",   { x = 0,   y = 0,  z = 0 })
template:addSocket("head",   { x = 0,   y = -24, z = 1 })
template:addSocket("weapon", { x = 14,  y = -8,  z = 2 })

local d = doll.Doll.new(template)
d:setPart("body",   doll.Part.fromImage("assets/body_warrior.png"))
d:setPart("head",   doll.Part.fromImage("assets/head_knight.png"))
d:setPart("weapon", doll.Part.fromImage("assets/sword.png", { tint = 0xccccccff }))

function lurek.draw()
    d:draw(100, 200)
end
```

## Dependencies

- `lurek.render`, `lurek.image` (optional — stubs work headlessly)
