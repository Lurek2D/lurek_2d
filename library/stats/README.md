# stats

A pure-Lua character-stats library with attributes, buffs, thresholds, traits,
skills, perks, action points, morale, and snapshot helpers.

## Usage

```lua
local stats = require("library.stats")

local sheet = stats.newSheet()
sheet:define("hp", 100, { min = 0, max = 200, regen = 5 })
sheet:define("str", 10)
sheet:addBuff("str", 5, 1, -1, "blessing")

local ap = stats.newActionPoints(6)
ap:spend(2)

local snap = sheet:snapshot()
print(sheet:get("str"), ap.current, snap.attributes.hp.base)
```

## Optional bindings

- `lurek.math.clamp`: preferred clamp backend when both bounds are present.
- `lurek.serialize.toJson/fromJson`: used by `snapshotToJson()` and
  `snapshotFromJson()`.

The JSON helpers preserve snapshot round-trips for open-ended bounds such as
`math.huge`.
