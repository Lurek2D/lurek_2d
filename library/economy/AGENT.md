# `economy` - Agent Reference

| Property | Value |
| --- | --- |
| Tier | Tier 3 - Lureksome (pure Lua) |
| Source | `library/economy/init.lua` |
| Lua tests | `tests/lua/library/test_economy_library.lua` |
| Status | full |
| Optional bindings | `lurek.math.clamp`, `lurek.patterns.newEventBus`, `lurek.serialize.toJson/fromJson` |

## Purpose

Gameplay-level economy model for named resources, decay and flow rules,
conversion rules, modifiers, and manager-level aggregation.

## Current shape

- `newResource(name, capacity)` creates one tracked resource.
- `newModifier(mod_type, value, duration, source)` defines additive,
  multiplicative, or override effects.
- `newConversionRule(from, to, rate)` models resource exchange with cooldown,
  fees, bounds, and modifier stacks.
- `newManager()` owns resources, conversion rules, ticks, and group totals.

## Engine integration

- `Resource:_clamp()` prefers `lurek.math.clamp` when available.
- `manager:getEventBus()` may use `lurek.patterns.newEventBus`.
- Serialization helpers belong in game code or save collectors.

## Notes

- This module is domain logic, not a wrapper over `lurek.flownet`.
- Keep public names and return shapes stable for existing content.
