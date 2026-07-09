# `inventory` - Agent Reference

| Property | Value |
| --- | --- |
| Tier | Tier 3 - Lureksome (pure Lua) |
| Source | `library/inventory/init.lua` |
| Lua tests | `tests/lua/library/test_inventory_library.lua` |
| Status | full |
| Optional bindings | `lurek.patterns.newEventBus`, `lurek.serialize.toJson/fromJson`, `lurek.save.SaveManager` |

## Purpose

Inventory domain model with items, item stacks, slots, containers, equipment
slots, item sets, and a top-level inventory object.

## Current shape

- `newItem`, `newItemStack`, `newSlot`, `newContainer`, `newItemSet`, and
  `newInventory` make up the main object graph.
- Containers support `fixed`, `unlimited`, and `expandable` modes.
- Inventory supports equip slots, container transfer helpers, stack merging and
  splitting, and optional item-set checks.

## Engine integration

- Event-bus support is optional via `lurek.patterns.newEventBus`.
- Serialization remains opt-in via `lurek.serialize` and save collectors.

## Notes

- This library stays domain-specific and should not be collapsed into generic
  engine containers.
- Keep constructor names and existing return shapes intact.
