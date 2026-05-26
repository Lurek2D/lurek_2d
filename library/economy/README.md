# economy

A resource flow simulator for game economies. Models named resources with per-tick production, consumption, decay, and interest rules. Supports conversion chains, capacity limits, and modifier stacks (buffs/debuffs).

## Usage

```lua
local economy = require("library/economy")

local mgr = economy.ResourceManager.new()
mgr:addResource(economy.Resource.new({ name = "gold", initial = 100, cap = 9999 }))
mgr:addResource(economy.Resource.new({ name = "food", initial = 50,  cap = 500,
    decay = 0.01 }))

mgr:addConversion(economy.ConversionRule.new({
    from = "food", amount = 10,
    to   = "gold", yield  = 2,
    interval = 5.0,
}))

function lurek.update(dt)
    mgr:tick(dt)
end

print("Gold:", mgr:get("gold"))
```

## Dependencies

- `lurek.math.clamp` (optional), `lurek.patterns.newEventBus` (optional)
