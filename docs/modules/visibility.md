# Visibility

## Purpose

Geometry-agnostic fog-of-war and shadowcasting field-of-view simulation.

## When To Use

- It combines adjacency rules, reveal cost, ownership flags, events, shadowcasting, and stored state so the same module can answer both gameplay questions and presentation needs.
- That makes it more than a single visibility check: current sight, remembered discovery, reveal transitions, and display-friendly output are meant to behave as one coherent information system.
- Team-specific reveal state and remembered exploration are especially important because many map-aware games care not only about what is visible now, but also about what was discovered earlier and by whom.

## Minimal Example

From the `lurek.visibility.new` example block:

```lua
do
    local vg = lurek.visibility.new({ regions = 20 * 15, players = 4 })
    local regions = vg:regionCount()
    local players = vg:playerCount()
    local first_state = vg:getState(0, 0)
    lurek.log.info("visibility grid created for dungeon floor")
    lurek.log.info("regions=" .. regions .. " players=" .. players .. " state=" .. first_state)
end
```

## Common Patterns

- Start with `lurek.visibility.new` when exploring this module.
- Start with `lurek.visibility.newFov` when exploring this module.

## API Reference

- Full generated API reference: [docs/api/lurek.md](../api/lurek.md)
- Runnable example owner: `content/examples/visibility.lua`

## Summary

- The `visibility` module is the shared answer to fog-of-war, line-of-sight, and remembered exploration for users building map-aware gameplay.
- It combines adjacency rules, reveal cost, ownership flags, events, shadowcasting, and stored state so the same module can answer both gameplay questions and presentation needs.
- That makes it more than a single visibility check: current sight, remembered discovery, reveal transitions, and display-friendly output are meant to behave as one coherent information system.
- Team-specific reveal state and remembered exploration are especially important because many map-aware games care not only about what is visible now, but also about what was discovered earlier and by whom.
- That unified state is what lets fog-of-war, scouting, and map presentation stay aligned.
- It also keeps team knowledge explicit.
- Read this module as the authority for what an actor currently knows about a space.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Functions

### `lurek.visibility.new`

Create a new visibility grid for shadow-cast computation.

```lua
lurek.visibility.new(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config` | table | Configuration table with `regions` (integer) and `players` (integer) fields. Optional `fog` sub-table with `discovered` (number), `hidden` (number), `smooth` (boolean), `speed` (number). |

**Returns**

| Type | Description |
|------|-------------|
| [LVisibilityGrid](#lvisibilitygrid) | New visibility grid handle. |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 20 * 15, players = 4 })
    local regions = vg:regionCount()
    local players = vg:playerCount()
    local first_state = vg:getState(0, 0)
    lurek.log.info("visibility grid created for dungeon floor")
    lurek.log.info("regions=" .. regions .. " players=" .. players .. " state=" .. first_state)
end
```

---

### `lurek.visibility.newFov`

Creates a new tile-grid shadowcasting FOV for roguelike and stealth games.

```lua
lurek.visibility.newFov(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | `{ range=integer, light_walls=boolean? }` (default light_walls=true). |

**Returns**

| Type | Description |
|------|-------------|
| [LFov](#lfov) | New FOV handle ready for blocker assignment and compute calls. |

**Example**

```lua
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 8 })
    local type_name = fov:type()
    fov:compute(10, 10)
    local visible_origin = fov:isVisible(10, 10)
    lurek.log.info("new FOV handle type = " .. type_name)
    lurek.log.info("origin visible after compute = " .. tostring(visible_origin))
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## Types

- [LFov](#lfov)
- [LVisibilityGrid](#lvisibilitygrid)

## LFov

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LFov:compute`

Runs recursive shadowcasting from the observer position.

```lua
LFov:compute(ox, oy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ox` | number | Observer column (one-based). |
| `oy` | number | Observer row (one-based). |

**Example**

```lua
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 8 })
    fov:compute(10, 10)
    local origin = fov:isVisible(10, 10)
    local east = fov:isVisible(12, 10)
    local cells = fov:visibleCells()
    lurek.log.info("computed FOV from player position")
    lurek.log.info("origin=" .. tostring(origin) .. " east=" .. tostring(east) .. " cells=" .. #cells)
end
```

---

#### `LFov:eachVisible`

Calls `fn(x, y)` for every currently visible cell (one-based coordinates).

```lua
LFov:eachVisible(fn)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fn` | function | Callback receiving column and row integers. |

**Example**

```lua
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 6 })
    fov:compute(10, 10)
    local count = 0
    fov:eachVisible(function(_x, _y)
        count = count + 1
    end)
    lurek.log.info("LFov:eachVisible count=" .. count)
end
```

---

#### `LFov:export`

Serialises the visible and explored masks to a binary blob.

```lua
LFov:export()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Binary blob. |

**Example**

```lua
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 6 })
    fov:compute(10, 10)
    local blob = fov:export()
    local cells = fov:visibleCells()
    local explored = fov:isExplored(10, 10)
    lurek.log.info("export blob bytes = " .. #blob)
    lurek.log.info("saved " .. #cells .. " visible cells, explored=" .. tostring(explored))
end
```

---

#### `LFov:import`

Restores visible and explored masks from a blob produced by `export`.

```lua
LFov:import(blob)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `blob` | string | Binary blob. |

**Example**

```lua
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 6 })
    fov:compute(10, 10)
    local blob = fov:export()

    local fov2 = lurek.visibility.newFov({ width = 20, height = 20, range = 6 })
    fov2:import(blob)
    lurek.log.info("LFov:import explored_10_10=" .. tostring(fov2:isExplored(10, 10)))
end
```

---

#### `LFov:isExplored`

Returns true if the cell has ever been visible.

```lua
LFov:isExplored(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Column (one-based). |
| `y` | number | Row (one-based). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when explored. |

**Example**

```lua
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 8 })
    fov:compute(10, 10)
    local explored_before = fov:isExplored(10, 10)
    fov:resetExplored()
    local explored_after = fov:isExplored(10, 10)
    lurek.log.info("explored before reset = " .. tostring(explored_before))
    lurek.log.info("explored after reset = " .. tostring(explored_after))
end
```

---

#### `LFov:isVisible`

Returns true if the cell is visible in the current frame.

```lua
LFov:isVisible(x, y)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | Column (one-based). |
| `y` | number | Row (one-based). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when visible. |

**Example**

```lua
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 8 })
    fov:compute(10, 10)
    local target = fov:isVisible(12, 10)
    local far = fov:isVisible(19, 10)
    local explored = fov:isExplored(12, 10)
    lurek.log.info("target tile visible = " .. tostring(target))
    lurek.log.info("far tile visible = " .. tostring(far) .. " explored=" .. tostring(explored))
end
```

---

#### `LFov:resetExplored`

Clears the explored mask so all cells appear unexplored.

```lua
LFov:resetExplored()
```

**Example**

```lua
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 8 })
    fov:compute(10, 10)
    fov:resetExplored()
    local explored_origin = fov:isExplored(10, 10)
    local visible_origin = fov:isVisible(10, 10)
    local cells = fov:visibleCells()
    lurek.log.info("explored mask cleared = " .. tostring(explored_origin))
    lurek.log.info("current frame still sees origin=" .. tostring(visible_origin) .. " cells=" .. #cells)
end
```

---

#### `LFov:setBlocker`

Sets the Lua predicate that determines which cells are opaque.

```lua
LFov:setBlocker(fn)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `fn` | function | `fn(x: integer, y: integer) -> boolean` (one-based). |

**Example**

```lua
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 8 })
    fov:setBlocker(function(x, y)
        return x == 10 and y >= 6 and y <= 14
    end)
    fov:compute(5, 10)
    lurek.log.info("LFov:setBlocker visible_12_10=" .. tostring(fov:isVisible(12, 10)))
end
```

---

#### `LFov:setRange`

Changes the visibility radius for subsequent compute calls.

```lua
LFov:setRange(range)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `range` | number | Maximum sight radius in cells. |

**Example**

```lua
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 4 })
    fov:setRange(10)
    fov:compute(10, 10)
    local far_visible = fov:isVisible(18, 10)
    local near_visible = fov:isVisible(14, 10)
    local explored = fov:isExplored(18, 10)
    lurek.log.info("range extended to 10 tiles")
    lurek.log.info("far=" .. tostring(far_visible) .. " near=" .. tostring(near_visible) .. " explored=" .. tostring(explored))
end
```

---

#### `LFov:type`

Returns the Lua-visible type name for this FOV handle.

```lua
LFov:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LFov](#lfov)`. |

**Example**

```lua
do
    local fov = lurek.visibility.newFov({ width = 8, height = 8, range = 4 })
    fov:compute(4, 4)
    local type_name = fov:type()
    local visible = fov:isVisible(4, 4)
    lurek.log.info("FOV type = " .. type_name)
    lurek.log.info("origin visible = " .. tostring(visible))
end
```

---

#### `LFov:typeOf`

Returns whether this FOV handle matches the given type name.

```lua
LFov:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to check. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the name matches. |

**Example**

```lua
do
    local fov = lurek.visibility.newFov({ width = 8, height = 8, range = 4 })
    local is_fov = fov:typeOf("LFov")
    local is_object = fov:typeOf("LObject")
    local is_grid = fov:typeOf("LVisibilityGrid")
    lurek.log.info("typeOf LFov = " .. tostring(is_fov))
    lurek.log.info("is object = " .. tostring(is_object) .. " grid=" .. tostring(is_grid))
end
```

---

#### `LFov:visibleCells`

Returns an array of `{x, y}` tables for all currently visible cells (one-based).

```lua
LFov:visibleCells()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of cell position tables. |

**Example**

```lua
do
    local fov = lurek.visibility.newFov({ width = 20, height = 20, range = 6 })
    fov:compute(10, 10)
    local cells = fov:visibleCells()
    local first = cells[1]
    local first_label = first and (first.x .. "," .. first.y) or "none"
    lurek.log.info("visible cell count = " .. #cells)
    lurek.log.info("first visible cell = " .. first_label)
end
```

---

## LVisibilityGrid

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LVisibilityGrid:drainEvents`

Drains and returns all pending visibility events.

```lua
LVisibilityGrid:drainEvents()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of event tables with `type`, `player_id`, and `region_id` fields. |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 100, players = 2 })
    vg:reveal(0, 3, 2)
    local events = vg:drainEvents()
    local drained_again = vg:drainEvents()
    local first = events[1]
    lurek.log.info("visibility events drained = " .. #events)
    lurek.log.info("first event exists=" .. tostring(first ~= nil) .. " second drain=" .. #drained_again)
end
```

---

#### `LVisibilityGrid:getCost`

Gets the discovery cost for a region.

```lua
LVisibilityGrid:getCost(region_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `region_id` | number | Region index (0-based). |

**Returns**

| Type | Description |
|------|-------------|
| number | Discovery cost value. |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:setCost(7, 3.5)
    vg:setCost(8, 1.0)
    local trapped = vg:getCost(7)
    local hallway = vg:getCost(8)
    lurek.log.info("trapped room cost = " .. trapped)
    lurek.log.info("hallway cost = " .. hallway)
end
```

---

#### `LVisibilityGrid:getFogIntensity`

Gets the fog intensity for a region from a player's perspective.

```lua
LVisibilityGrid:getFogIntensity(player_id, region_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player_id` | number | Player index (0-based). |
| `region_id` | number | Region index (0-based). |

**Returns**

| Type | Description |
|------|-------------|
| number | Fog intensity from 0.0 (clear) to 1.0 (fully fogged). |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:reveal(0, 0)
    vg:hide(0, 0)
    local fog = vg:getFogIntensity(0, 0)
    local state = vg:getState(0, 0)
    local hidden_fog = vg:getFogIntensity(1, 0)
    lurek.log.info("fog for discovered room = " .. fog)
    lurek.log.info("state=" .. state .. " hidden-player fog=" .. hidden_fog)
end
```

---

#### `LVisibilityGrid:getState`

Gets the visibility state for a player at a region.

```lua
LVisibilityGrid:getState(player_id, region_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player_id` | number | Player index (0-based). |
| `region_id` | number | Region index (0-based). |

**Returns**

| Type | Description |
|------|-------------|
| string | "hidden", "discovered", "visible", or a number for custom levels. |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:reveal(1, 42, 2)
    local player_state = vg:getState(1, 42)
    local other_state = vg:getState(0, 42)
    local fog = vg:getFogIntensity(1, 42)
    lurek.log.info("scout player state at region 42 = " .. player_state)
    lurek.log.info("other player sees " .. other_state .. " with fog=" .. fog)
end
```

---

#### `LVisibilityGrid:hasFlag`

Checks if a visibility flag bit is set on a region.

```lua
LVisibilityGrid:hasFlag(region_id, bit)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `region_id` | number | Region index (0-based). |
| `bit` | number | Flag bit index (0-63). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | Whether the bit is set. |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:setFlag(4, 4, true)
    local trap = vg:hasFlag(4, 4)
    local beacon = vg:hasFlag(4, 7)
    local region = 4
    lurek.log.info("region " .. region .. " trap flag = " .. tostring(trap))
    lurek.log.info("region " .. region .. " beacon flag = " .. tostring(beacon))
end
```

---

#### `LVisibilityGrid:hide`

Hides a region for a player (moves from Visible to Discovered).

```lua
LVisibilityGrid:hide(player_id, region_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player_id` | number | Player index (0-based). |
| `region_id` | number | Region index (0-based). |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:revealAll(0)
    vg:hide(0, 3)
    local state = vg:getState(0, 3)
    local fog = vg:getFogIntensity(0, 3)
    local still_visible = state == "visible"
    lurek.log.info("hiding room 3 after player leaves vision")
    lurek.log.info("state=" .. state .. " fog=" .. fog .. " visible=" .. tostring(still_visible))
end
```

---

#### `LVisibilityGrid:playerCount`

Returns the total number of players in the grid.

```lua
LVisibilityGrid:playerCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Player count. |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 100, players = 2 })
    vg:setGroup({ 0, 1 })
    local players = vg:playerCount()
    local shared = vg:sharesVisibility(0, 1)
    local regions = vg:regionCount()
    lurek.log.info("player count = " .. players)
    lurek.log.info("shared party vision=" .. tostring(shared) .. " across " .. regions .. " regions")
end
```

---

#### `LVisibilityGrid:regionCount`

Returns the total number of regions in the grid.

```lua
LVisibilityGrid:regionCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Region count. |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 100, players = 2 })
    local regions = vg:regionCount()
    local players = vg:playerCount()
    local last_state = vg:getState(0, regions - 1)
    lurek.log.info("region count = " .. regions)
    lurek.log.info("players=" .. players .. " last region state=" .. last_state)
end
```

---

#### `LVisibilityGrid:reset`

Resets all visibility to Hidden for a player.

```lua
LVisibilityGrid:reset(player_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player_id` | number | Player index (0-based). |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 100, players = 2 })
    vg:revealAll(0)
    vg:reset(0)
    local region_state = vg:getState(0, 5)
    local fog = vg:getFogIntensity(0, 5)
    local hidden = region_state == "hidden"
    lurek.log.info("reset visibility for player 0")
    lurek.log.info("state=" .. region_state .. " fog=" .. fog .. " hidden=" .. tostring(hidden))
end
```

---

#### `LVisibilityGrid:reveal`

Reveals a region for a player (and their allies). Optional flags argument.

```lua
LVisibilityGrid:reveal(player_id, region_id, flags)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player_id` | number | Player index (0-based). |
| `region_id` | number | Region index (0-based). |
| `flags?` | number | Optional bitfield flags to set on the region. |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:reveal(0, 5, 3)
    local state = vg:getState(0, 5)
    local fog = vg:getFogIntensity(0, 5)
    local events = vg:drainEvents()
    lurek.log.info("revealed corridor region 5 for player 0")
    lurek.log.info("state=" .. state .. " fog=" .. fog .. " events=" .. #events)
end
```

---

#### `LVisibilityGrid:revealAll`

Reveals all regions for a player (debug/cheat).

```lua
LVisibilityGrid:revealAll(player_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player_id` | number | Player index (0-based). |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 100, players = 2 })
    vg:revealAll(0)
    local region_state = vg:getState(0, 5)
    local last_state = vg:getState(0, 99)
    local fog = vg:getFogIntensity(0, 99)
    lurek.log.info("debug reveal all enabled for player 0")
    lurek.log.info("region5=" .. region_state .. " region99=" .. last_state .. " fog=" .. fog)
end
```

---

#### `LVisibilityGrid:setCost`

Sets the discovery cost for a region.

```lua
LVisibilityGrid:setCost(region_id, cost)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `region_id` | number | Region index (0-based). |
| `cost` | number | Discovery cost value. |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:setCost(5, 2.0)
    vg:setCost(6, 4.5)
    local room_cost = vg:getCost(5)
    local boss_cost = vg:getCost(6)
    lurek.log.info("pathing cost for room 5 = " .. room_cost)
    lurek.log.info("boss wing cost = " .. boss_cost)
end
```

---

#### `LVisibilityGrid:setFlag`

Sets a visibility flag bit on a region.

```lua
LVisibilityGrid:setFlag(region_id, bit, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `region_id` | number | Region index (0-based). |
| `bit` | number | Flag bit index (0-63). |
| `value` | boolean | Whether to set or clear the bit. |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:setFlag(8, 6, true)
    local has_secret = vg:hasFlag(8, 6)
    vg:setFlag(8, 1, true)
    local has_loot = vg:hasFlag(8, 1)
    lurek.log.info("secret-door flag set = " .. tostring(has_secret))
    lurek.log.info("loot flag set = " .. tostring(has_loot))
end
```

---

#### `LVisibilityGrid:setGroup`

Sets an alliance group for a list of players (shared visibility).

```lua
LVisibilityGrid:setGroup(players)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `players` | table | Array of player IDs (0-based) to group together. |

**Returns**

| Type | Description |
|------|-------------|
| number | The assigned group ID. |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    local groupId = vg:setGroup({ 0, 1 })
    local shared = vg:sharesVisibility(0, 1)
    local not_shared = vg:sharesVisibility(0, 2)
    lurek.log.info("alliance group id = " .. groupId)
    lurek.log.info("0<->1 shared=" .. tostring(shared) .. " 0<->2 shared=" .. tostring(not_shared))
end
```

---

#### `LVisibilityGrid:sharesVisibility`

Checks if two players share visibility (same alliance group or same player).

```lua
LVisibilityGrid:sharesVisibility(player_a, player_b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player_a` | number | First player index (0-based). |
| `player_b` | number | Second player index (0-based). |

**Returns**

| Type | Description |
|------|-------------|
| boolean | Whether they share visibility. |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:setGroup({ 1, 2 })
    local shared = vg:sharesVisibility(1, 2)
    local enemy_shared = vg:sharesVisibility(1, 3)
    vg:reveal(1, 20)
    local ally_state = vg:getState(2, 20)
    lurek.log.info("allied scouts share vision = " .. tostring(shared))
    lurek.log.info("enemy shared=" .. tostring(enemy_shared) .. " ally sees " .. ally_state)
end
```

---
