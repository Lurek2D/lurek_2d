# stats

A full RPG character stat sheet with attributes, buffs/debuffs, skills, perks, action points, morale, and level thresholds. Supports archetype templates (race, class) that seed a new Sheet with base values, and serialization to JSON for save files.

## Usage

```lua
local stats = require("library/stats")

local sheet = stats.Sheet.new()
sheet:applyArchetype(stats.ARCHETYPES.warrior)

print("STR:", sheet:get("strength"))    -- base + racial + class bonuses

local rage = stats.Buff.new({ name = "Rage", stat = "strength", amount = 10, duration = 5.0 })
sheet:applyBuff(rage)

sheet:useActionPoints(2)
print("AP left:", sheet:getActionPoints())

function lurek.update(dt)
    sheet:tick(dt)   -- drains buff durations, recovers morale
end
```

## Dependencies

- `lurek.math.clamp/lerp` (optional), `lurek.serialize` (optional)
