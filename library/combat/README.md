# combat

A vehicle/turret combat system with physics-backed projectile pooling. Models chassis, mount slots, turrets, weapons, and projectiles. Handles targeting, firing arcs, cooldowns, hit detection, and pool recycling.

## Usage

```lua
local combat = require("library/combat")

local tank = combat.Chassis.new({ hp = 200, armor = 20 })
local turret = combat.Turret.new({ arc = 120, rotate_speed = 60 })
tank:mount(turret, combat.MountSlot.new({ offset_x = 0, offset_y = -10 }))

local cannon = combat.Weapon.new({ damage = 50, range = 400, cooldown = 1.5 })
turret:equip(cannon)

local pool = combat.ProjectilePool.new({ capacity = 64 })

function lurek.update(dt)
    tank:update(dt)
    pool:update(dt)
end
```

## Dependencies

- `lurek.math`, `lurek.physics` (optional)
