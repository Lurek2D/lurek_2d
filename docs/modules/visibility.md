# Visibility

- The `visibility` module is a geometry-agnostic fog-of-war, discovery state, and line-of-sight system attachable to any region-based map (tilemap, province, globe, or custom grids).

The `visibility` module provides a universal fog-of-war and discovery layer that can be attached to any region-based map without coupling to a specific map module. The foundational abstraction is the `AdjacencyProvider` trait: callers implement a single `neighbors(region_id)` method to describe neighbor relationships. Grid maps inject 4- or 8-directional adjacency; province maps use their border index; custom systems supply arbitrary neighbor lists. This injection point is the only geometry dependency.

Per-region state is stored in the `VisibilityGrid`, a compact `(faction_id, region_id)` map tracking three built-in `VisibilityState` levels: `Hidden` (never seen), `Discovered` (seen at least once, currently out of range), and `Visible` (currently in sight range). Custom intermediate levels can be defined for richer game-state models. Multiple factions are supported simultaneously; the `PlayerOwnership` tracker groups allies so that shared-vision alliances propagate reveals automatically.

Discovery semantics are controlled per region via `VisibilityCost`: a movement-point cost gates reveal progression, and a required-flag mask (`VisibilityFlags`, a `u32` bitfield with 24 game-defined bits) can block reveal until the player possesses a specific capability. When regions transition between states, the grid queues `VisibilityEvent` entries (`RegionRevealed`, `RegionDiscovered`, `RegionHidden`) that are drained to Lua each tick — providing clean hooks for map-reveal animations, narrator cues, and scripted responses.

Rendering integration is handled via `FogRenderConfig`, which supplies per-state fog opacity values and RGBA tint colors composited as per-tile multiply in the world render pass. The full grid state serializes compactly (2 bits per region per faction) into the save file. The `lurek.visibility.*` Lua API exposes grid construction, reveal/hide calls, state queries, event draining, cost and flag mutation, faction grouping, and fog configuration.

## Functions

### `lurek.visibility.new`

Create a new visibility grid for shadow-cast computation.

```lua
-- signature
lurek.visibility.new(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config` | `table` | Configuration table with `regions` (integer) and `players` (integer) fields. Optional `fog` sub-table with `discovered` (number), `hidden` (number), `smooth` (boolean), `speed` (number). |

**Returns**

| Type | Description |
|------|-------------|
| `LVisibilityGrid` | New visibility grid handle. |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 20 * 15, players = 4 })
    print("lurek.visibility.new type=" .. type(vg))
    print("players=" .. vg:playerCount())
end
```

---

## LVisibilityGrid

### `LVisibilityGrid:drainEvents`

Drains and returns all pending visibility events.

```lua
-- signature
LVisibilityGrid:drainEvents()
```

**Returns**

| Type | Description |
|------|-------------|
| `table` | Array of event tables with `type`, `player_id`, and `region_id` fields. |

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

### `LVisibilityGrid:getCost`

Gets the discovery cost for a region.

```lua
-- signature
LVisibilityGrid:getCost(region_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `region_id` | `number` | Region index (0-based). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Discovery cost value. |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:setCost(7, 3.5)
    print("LVisibilityGrid:getCost=" .. vg:getCost(7))
end
```

---

### `LVisibilityGrid:getFogIntensity`

Gets the fog intensity for a region from a player's perspective.

```lua
-- signature
LVisibilityGrid:getFogIntensity(player_id, region_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player_id` | `number` | Player index (0-based). |
| `region_id` | `number` | Region index (0-based). |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Fog intensity from 0.0 (clear) to 1.0 (fully fogged). |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    local fog = vg:getFogIntensity(0, 0)
    print("LVisibilityGrid:getFogIntensity=" .. fog)
end
```

---

### `LVisibilityGrid:getState`

Gets the visibility state for a player at a region.

```lua
-- signature
LVisibilityGrid:getState(player_id, region_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player_id` | `number` | Player index (0-based). |
| `region_id` | `number` | Region index (0-based). |

**Returns**

| Type | Description |
|------|-------------|
| `string` | "hidden", "discovered", "visible", or a number for custom levels. |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:reveal(1, 42, 2)
    print("LVisibilityGrid:getState=" .. vg:getState(1, 42))
end
```

---

### `LVisibilityGrid:hasFlag`

Checks if a visibility flag bit is set on a region.

```lua
-- signature
LVisibilityGrid:hasFlag(region_id, bit)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `region_id` | `number` | Region index (0-based). |
| `bit` | `number` | Flag bit index (0-63). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | Whether the bit is set. |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:setFlag(4, 4, true)
    print("LVisibilityGrid:hasFlag=" .. tostring(vg:hasFlag(4, 4)))
end
```

---

### `LVisibilityGrid:hide`

Hides a region for a player (moves from Visible to Discovered).

```lua
-- signature
LVisibilityGrid:hide(player_id, region_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player_id` | `number` | Player index (0-based). |
| `region_id` | `number` | Region index (0-based). |

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

### `LVisibilityGrid:playerCount`

Returns the total number of players in the grid.

```lua
-- signature
LVisibilityGrid:playerCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Player count. |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 100, players = 2 })
    vg:setGroup({ 0, 1 })
    print("LVisibilityGrid:playerCount=" .. vg:playerCount())
end
```

---

### `LVisibilityGrid:regionCount`

Returns the total number of regions in the grid.

```lua
-- signature
LVisibilityGrid:regionCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Region count. |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 100, players = 2 })
    print("LVisibilityGrid:regionCount=" .. vg:regionCount())
end
```

---

### `LVisibilityGrid:reset`

Resets all visibility to Hidden for a player.

```lua
-- signature
LVisibilityGrid:reset(player_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player_id` | `number` | Player index (0-based). |

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

### `LVisibilityGrid:reveal`

Reveals a region for a player (and their allies). Optional flags argument.

```lua
-- signature
LVisibilityGrid:reveal(player_id, region_id, flags)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player_id` | `number` | Player index (0-based). |
| `region_id` | `number` | Region index (0-based). |
| `flags?` | `number` | Optional bitfield flags to set on the region. |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:reveal(0, 5, 3)
    print("LVisibilityGrid:reveal state=" .. vg:getState(0, 5))
end
```

---

### `LVisibilityGrid:revealAll`

Reveals all regions for a player (debug/cheat).

```lua
-- signature
LVisibilityGrid:revealAll(player_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player_id` | `number` | Player index (0-based). |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 100, players = 2 })
    vg:revealAll(0)
    print("LVisibilityGrid:revealAll state=" .. vg:getState(0, 5))
end
```

---

### `LVisibilityGrid:setCost`

Sets the discovery cost for a region.

```lua
-- signature
LVisibilityGrid:setCost(region_id, cost)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `region_id` | `number` | Region index (0-based). |
| `cost` | `number` | Discovery cost value. |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:setCost(5, 2.0)
    print("LVisibilityGrid:setCost=" .. vg:getCost(5))
end
```

---

### `LVisibilityGrid:setFlag`

Sets a visibility flag bit on a region.

```lua
-- signature
LVisibilityGrid:setFlag(region_id, bit, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `region_id` | `number` | Region index (0-based). |
| `bit` | `number` | Flag bit index (0-63). |
| `value` | `boolean` | Whether to set or clear the bit. |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    vg:setFlag(8, 6, true)
    print("LVisibilityGrid:setFlag=" .. tostring(vg:hasFlag(8, 6)))
end
```

---

### `LVisibilityGrid:setGroup`

Sets an alliance group for a list of players (shared visibility).

```lua
-- signature
LVisibilityGrid:setGroup(players)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `players` | `table` | Array of player IDs (0-based) to group together. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | The assigned group ID. |

**Example**

```lua
do
    local vg = lurek.visibility.new({ regions = 300, players = 4 })
    local groupId = vg:setGroup({ 0, 1 })
    print("LVisibilityGrid:setGroup id=" .. groupId)
end
```

---

### `LVisibilityGrid:sharesVisibility`

Checks if two players share visibility (same alliance group or same player).

```lua
-- signature
LVisibilityGrid:sharesVisibility(player_a, player_b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player_a` | `number` | First player index (0-based). |
| `player_b` | `number` | Second player index (0-based). |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | Whether they share visibility. |

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
