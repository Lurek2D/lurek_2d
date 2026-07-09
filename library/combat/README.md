# combat

A pure-Lua combat model for chassis, turrets, weapons, projectile pools, and a
top-level combat world. Games should handle actual collision queries in
`lurek.physics` and map the results back onto these combat objects.

## Usage

```lua
local combat = require("library.combat")

local tank = combat.newChassis(1, 200)
local turret = combat.newTurret(1, 1)
local cannon = combat.newWeapon("cannon")
local pool = combat.newProjectilePool(64)

cannon:setDamageAmount(50)
cannon:setRange(400)
turret:setWeaponIndex(1)
tank:addSlot(combat.newMountSlot("main", 0, -10, "medium"))

local world = combat.newCombatWorld()
world:addChassis(tank)
world:addTurret(turret)
world:addWeapon(cannon)
world:addProjectilePool(pool)

-- In game code:
-- 1. advance combat objects,
-- 2. query lurek.physics for hits,
-- 3. apply the resulting damage through library.combat objects.
```

## Optional bindings

- `lurek.physics`: recommended for projectile hit detection and collision.
