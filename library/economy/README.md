# economy

A pure-Lua resource economy library with named resources, conversion rules,
modifiers, and a manager for ticking and aggregation.

## Usage

```lua
local economy = require("library.economy")

local mgr = economy.newManager()
mgr:newResource("gold", 1000):setValue(100)
mgr:newResource("food", 200):setDecayRate(1)

local sell = economy.newConversionRule("food", "gold", 2)
sell:setCooldown(5)
mgr:addConversionRule(sell)

mgr:tick(1.0)
local converted = mgr:convert("food", "gold", 10)
print(converted, mgr:getValue("gold"))
```

## Optional bindings

- `lurek.math.clamp`: used by resource clamping when available.
- `lurek.patterns.newEventBus`: used by `manager:getEventBus()` when available.
- `lurek.serialize.toJson/fromJson`: recommended for save payloads.

This library is a gameplay-level economy model, not a wrapper over
`lurek.flownet`.
