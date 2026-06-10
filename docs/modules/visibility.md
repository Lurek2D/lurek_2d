# Visibility

## Summary

- The visibility module provides geometry-agnostic fog-of-war and discovery state simulation.
- Topology is abstracted through adjacency contracts rather than a fixed map representation.
- Per-player region state tracks hidden, discovered, and currently visible layers.
- Alliance grouping supports shared visibility between cooperating actors.
- Cost and flag channels support configurable reveal progression rules.
- Visibility transitions are emitted as structured events for script systems.
- Fog rendering parameters map state to visual intensity outputs.
- Shadowcasting FOV provides efficient tile-grid line-of-sight computation.
- State export/import supports save persistence of visibility history.
- The module owns visibility semantics, not renderer or AI policy.

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
    print("lurek.visibility.new type=" .. type(vg))
    print("players=" .. vg:playerCount())
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
    print("newFov type=" .. fov:type())
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
    print("LFov:compute visible_10_10=" .. tostring(fov:isVisible(10, 10)))
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
    print("LFov:eachVisible count=" .. count)
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
    print("LFov:export bytes=" .. #blob)
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
    print("LFov:import explored_10_10=" .. tostring(fov2:isExplored(10, 10)))
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
    print("LFov:isExplored_before_reset=" .. tostring(fov:isExplored(10, 10)))
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
    print("LFov:isVisible=" .. tostring(fov:isVisible(12, 10)))
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
    print("LFov:resetExplored=" .. tostring(fov:isExplored(10, 10)))
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
    print("LFov:setBlocker visible_12_10=" .. tostring(fov:isVisible(12, 10)))
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
    print("LFov:setRange visible_18_10=" .. tostring(fov:isVisible(18, 10)))
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
    print("LFov:type=" .. fov:type())
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
    print("LFov:typeOf_Fov=" .. tostring(fov:typeOf("LFov")))
    print("LFov:typeOf_Object=" .. tostring(fov:typeOf("LObject")))
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
    print("LFov:visibleCells count=" .. #cells)
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
    print("LVisibilityGrid:drainEvents count=" .. #events)
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
    print("LVisibilityGrid:getCost=" .. vg:getCost(7))
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
    local fog = vg:getFogIntensity(0, 0)
    print("LVisibilityGrid:getFogIntensity=" .. fog)
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
    print("LVisibilityGrid:getState=" .. vg:getState(1, 42))
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
    print("LVisibilityGrid:hasFlag=" .. tostring(vg:hasFlag(4, 4)))
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
    print("LVisibilityGrid:hide state=" .. vg:getState(0, 3))
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
    print("LVisibilityGrid:playerCount=" .. vg:playerCount())
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
    print("LVisibilityGrid:regionCount=" .. vg:regionCount())
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
    print("LVisibilityGrid:reset state=" .. vg:getState(0, 5))
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
    print("LVisibilityGrid:reveal state=" .. vg:getState(0, 5))
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
    print("LVisibilityGrid:revealAll state=" .. vg:getState(0, 5))
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
    print("LVisibilityGrid:setCost=" .. vg:getCost(5))
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
    print("LVisibilityGrid:setFlag=" .. tostring(vg:hasFlag(8, 6)))
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
    print("LVisibilityGrid:setGroup id=" .. groupId)
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
    print("LVisibilityGrid:sharesVisibility=" .. tostring(shared))
end
```

---
