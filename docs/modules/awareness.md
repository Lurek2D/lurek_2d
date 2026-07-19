# Awareness

## Purpose

Player-specific fog-of-war, remembered exploration, line-of-sight, and action-mask simulation.

## Summary

- The `awareness` module is the shared answer to fog-of-war, line-of-sight, action reachability, and remembered exploration for users building map-aware gameplay.
- It combines adjacency rules, reveal cost, ownership flags, events, shadowcasting, and stored state so the same module can answer both gameplay questions and presentation needs.
- That makes it more than a single visibility check: current sight, remembered discovery, reveal transitions, and display-friendly output are meant to behave as one coherent information system.
- Team-specific reveal state and remembered exploration are especially important because many map-aware games care not only about what is visible now, but also about what was discovered earlier and by whom.
- That unified state is what lets fog-of-war, scouting, and map presentation stay aligned.
- It also keeps team knowledge explicit.
- Read this module as the authority for what an actor currently knows about a space.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## API Reference

- This page is the generated API reference for this module.

## Functions

### `lurek.awareness.lineOfAction`

Returns whether two tilefield cells have a clear action line.

```lua
lurek.awareness.lineOfAction(field, from, to, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `field` | [LTileField](tilefield.md#ltilefield) | Tilefield to query. |
| `from` | table | One-based `{x,y,z?}` start. |
| `to` | table | One-based `{x,y,z?}` target. |
| `opts?` | table | Optional `{category="action"}` or legacy `{channel="action"}`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when clear. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 3 })
    field:applyProfile(3, 2, 1, "window")
    local from = { x = 1, y = 2, z = 1 }
    local to = { x = 6, y = 2, z = 1 }
    local clear = lurek.awareness.lineOfAction(field, from, to)
    lurek.log.info("lineOfAction through window = " .. tostring(clear))
end
```

---

### `lurek.awareness.lineOfSight`

Returns whether two tilefield cells have a clear sight line.

```lua
lurek.awareness.lineOfSight(field, from, to, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `field` | [LTileField](tilefield.md#ltilefield) | Tilefield to query. |
| `from` | table | One-based `{x,y,z?}` start. |
| `to` | table | One-based `{x,y,z?}` target. |
| `opts?` | table | Optional `{category="sight"}` or legacy `{channel="vision"}`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when clear. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 3 })
    field:applyProfile(3, 2, 1, "window")
    local from = { x = 1, y = 2, z = 1 }
    local to = { x = 6, y = 2, z = 1 }
    local clear = lurek.awareness.lineOfSight(field, from, to)
    lurek.log.info("lineOfSight through window = " .. tostring(clear))
end
```

---

### `lurek.awareness.new`

Create a new visibility grid for shadow-cast computation.

```lua
lurek.awareness.new(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config` | table | Configuration table with `regions` (integer) and `players` (integer) fields. Optional `fog` sub-table with `discovered` (number), `hidden` (number), `smooth` (boolean), `speed` (number). |

**Returns**

| Type | Description |
|------|-------------|
| [LAwarenessGrid](#lawarenessgrid) | New visibility grid handle. |

**Example**

```lua
do
    local vg = lurek.awareness.new({ regions = 20 * 15, players = 4 })
    local regions = vg:regionCount()
    local players = vg:playerCount()
    local first_state = vg:getState(0, 0)
    lurek.log.info("visibility grid created for dungeon floor")
    lurek.log.info("regions=" .. regions .. " players=" .. players .. " state=" .. first_state)
end
```

---

### `lurek.awareness.newFov`

Creates a new tile-grid shadowcasting FOV for roguelike and stealth games.

```lua
lurek.awareness.newFov(opts)
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
    local fov = lurek.awareness.newFov({ width = 20, height = 20, range = 8 })
    local type_name = fov:type()
    fov:compute(10, 10)
    local visible_origin = fov:isVisible(10, 10)
    lurek.log.info("new FOV handle type = " .. type_name)
    lurek.log.info("origin visible after compute = " .. tostring(visible_origin))
end
```

---

### `lurek.awareness.newTileAwareness`

Creates per-player tile visibility/action masks backed by a tilefield.

```lua
lurek.awareness.newTileAwareness(field, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `field` | [LTileField](tilefield.md#ltilefield) | Source tilefield. |
| `opts` | table | `{players={...}, rememberExplored=true?}`. |

**Returns**

| Type | Description |
|------|-------------|
| [LTileAwareness](#ltileawareness) | New tile visibility handle. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 6 })
    local vis = lurek.awareness.newTileAwareness(field, { players = { "p1", "p2" } })
    vis:computeVisible("p1", { origin = { x = 2, y = 2, z = 1 }, range = 3 })
    local visible = vis:isVisible("p1", 3, 2, 1)
    lurek.log.info("tile visibility created, visible=" .. tostring(visible))
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LAwarenessGrid](#lawarenessgrid)
- [LFov](#lfov)
- [LTileAwareness](#ltileawareness)

## LAwarenessGrid

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LAwarenessGrid:drainEvents`

Drains and returns all pending visibility events.

```lua
LAwarenessGrid:drainEvents()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of event tables with `type`, `player_id`, and `region_id` fields. |

**Example**

```lua
do
    local vg = lurek.awareness.new({ regions = 100, players = 2 })
    vg:reveal(0, 3, 2)
    local events = vg:drainEvents()
    local drained_again = vg:drainEvents()
    local first = events[1]
    lurek.log.info("visibility events drained = " .. #events)
    lurek.log.info("first event exists=" .. tostring(first ~= nil) .. " second drain=" .. #drained_again)
end
```

---

#### `LAwarenessGrid:getCost`

Gets the discovery cost for a region.

```lua
LAwarenessGrid:getCost(region_id)
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
    local vg = lurek.awareness.new({ regions = 300, players = 4 })
    vg:setCost(7, 3.5)
    vg:setCost(8, 1.0)
    local trapped = vg:getCost(7)
    local hallway = vg:getCost(8)
    lurek.log.info("trapped room cost = " .. trapped)
    lurek.log.info("hallway cost = " .. hallway)
end
```

---

#### `LAwarenessGrid:getFogIntensity`

Gets the fog intensity for a region from a player's perspective.

```lua
LAwarenessGrid:getFogIntensity(player_id, region_id)
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
    local vg = lurek.awareness.new({ regions = 300, players = 4 })
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

#### `LAwarenessGrid:getState`

Gets the visibility state for a player at a region.

```lua
LAwarenessGrid:getState(player_id, region_id)
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
    local vg = lurek.awareness.new({ regions = 300, players = 4 })
    local player_id, region_id = 1, 42
    vg:reveal(player_id, region_id, 2)
    local player_state = vg:getState(player_id, region_id)
    local other_state = vg:getState(0, region_id)
    local fog = vg:getFogIntensity(player_id, region_id)
    lurek.log.info("scout player state at region 42 = " .. player_state)
    lurek.log.info("other player sees " .. other_state .. " with fog=" .. fog)
end
```

---

#### `LAwarenessGrid:hasFlag`

Checks if a visibility flag bit is set on a region.

```lua
LAwarenessGrid:hasFlag(region_id, bit)
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
    local vg = lurek.awareness.new({ regions = 300, players = 4 })
    vg:setFlag(4, 4, true)
    local trap = vg:hasFlag(4, 4)
    local beacon = vg:hasFlag(4, 7)
    local region = 4
    lurek.log.info("region " .. region .. " trap flag = " .. tostring(trap))
    lurek.log.info("region " .. region .. " beacon flag = " .. tostring(beacon))
end
```

---

#### `LAwarenessGrid:hide`

Hides a region for a player (moves from Visible to Discovered).

```lua
LAwarenessGrid:hide(player_id, region_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player_id` | number | Player index (0-based). |
| `region_id` | number | Region index (0-based). |

**Example**

```lua
do
    local vg = lurek.awareness.new({ regions = 300, players = 4 })
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

#### `LAwarenessGrid:playerCount`

Returns the total number of players in the grid.

```lua
LAwarenessGrid:playerCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Player count. |

**Example**

```lua
do
    local vg = lurek.awareness.new({ regions = 100, players = 2 })
    vg:setGroup({ 0, 1 })
    local players = vg:playerCount()
    local shared = vg:sharesVisibility(0, 1)
    local regions = vg:regionCount()
    lurek.log.info("player count = " .. players)
    lurek.log.info("shared party vision=" .. tostring(shared) .. " across " .. regions .. " regions")
end
```

---

#### `LAwarenessGrid:regionCount`

Returns the total number of regions in the grid.

```lua
LAwarenessGrid:regionCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Region count. |

**Example**

```lua
do
    local vg = lurek.awareness.new({ regions = 100, players = 2 })
    local regions = vg:regionCount()
    local players = vg:playerCount()
    local last_state = vg:getState(0, regions - 1)
    lurek.log.info("region count = " .. regions)
    lurek.log.info("players=" .. players .. " last region state=" .. last_state)
end
```

---

#### `LAwarenessGrid:reset`

Resets all visibility to Hidden for a player.

```lua
LAwarenessGrid:reset(player_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player_id` | number | Player index (0-based). |

**Example**

```lua
do
    local vg = lurek.awareness.new({ regions = 100, players = 2 })
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

#### `LAwarenessGrid:reveal`

Reveals a region for a player (and their allies). Optional flags argument.

```lua
LAwarenessGrid:reveal(player_id, region_id, flags)
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
    local vg = lurek.awareness.new({ regions = 300, players = 4 })
    vg:reveal(0, 5, 3)
    local state = vg:getState(0, 5)
    local fog = vg:getFogIntensity(0, 5)
    local events = vg:drainEvents()
    lurek.log.info("revealed corridor region 5 for player 0")
    lurek.log.info("state=" .. state .. " fog=" .. fog .. " events=" .. #events)
end
```

---

#### `LAwarenessGrid:revealAll`

Reveals all regions for a player (debug/cheat).

```lua
LAwarenessGrid:revealAll(player_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player_id` | number | Player index (0-based). |

**Example**

```lua
do
    local vg = lurek.awareness.new({ regions = 100, players = 2 })
    vg:revealAll(0)
    local region_state = vg:getState(0, 5)
    local last_state = vg:getState(0, 99)
    local fog = vg:getFogIntensity(0, 99)
    lurek.log.info("debug reveal all enabled for player 0")
    lurek.log.info("region5=" .. region_state .. " region99=" .. last_state .. " fog=" .. fog)
end
```

---

#### `LAwarenessGrid:setCost`

Sets the discovery cost for a region.

```lua
LAwarenessGrid:setCost(region_id, cost)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `region_id` | number | Region index (0-based). |
| `cost` | number | Discovery cost value. |

**Example**

```lua
do
    local vg = lurek.awareness.new({ regions = 300, players = 4 })
    vg:setCost(5, 2.0)
    vg:setCost(6, 4.5)
    local room_cost = vg:getCost(5)
    local boss_cost = vg:getCost(6)
    lurek.log.info("pathing cost for room 5 = " .. room_cost)
    lurek.log.info("boss wing cost = " .. boss_cost)
end
```

---

#### `LAwarenessGrid:setFlag`

Sets a visibility flag bit on a region.

```lua
LAwarenessGrid:setFlag(region_id, bit, value)
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
    local vg = lurek.awareness.new({ regions = 300, players = 4 })
    vg:setFlag(8, 6, true)
    local has_secret = vg:hasFlag(8, 6)
    vg:setFlag(8, 1, true)
    local has_loot = vg:hasFlag(8, 1)
    lurek.log.info("secret-door flag set = " .. tostring(has_secret))
    lurek.log.info("loot flag set = " .. tostring(has_loot))
end
```

---

#### `LAwarenessGrid:setGroup`

Sets an alliance group for a list of players (shared visibility).

```lua
LAwarenessGrid:setGroup(players)
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
    local vg = lurek.awareness.new({ regions = 300, players = 4 })
    local groupId = vg:setGroup({ 0, 1 })
    local shared = vg:sharesVisibility(0, 1)
    local not_shared = vg:sharesVisibility(0, 2)
    lurek.log.info("alliance group id = " .. groupId)
    lurek.log.info("0<->1 shared=" .. tostring(shared) .. " 0<->2 shared=" .. tostring(not_shared))
end
```

---

#### `LAwarenessGrid:sharesVisibility`

Checks if two players share visibility (same alliance group or same player).

```lua
LAwarenessGrid:sharesVisibility(player_a, player_b)
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
    local vg = lurek.awareness.new({ regions = 300, players = 4 })
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
    local fov = lurek.awareness.newFov({ width = 20, height = 20, range = 8 })
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
    local fov = lurek.awareness.newFov({ width = 20, height = 20, range = 6 })
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
    local fov = lurek.awareness.newFov({ width = 20, height = 20, range = 6 })
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
    local fov = lurek.awareness.newFov({ width = 20, height = 20, range = 6 })
    fov:compute(10, 10)
    local blob = fov:export()

    local fov2 = lurek.awareness.newFov({ width = 20, height = 20, range = 6 })
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
    local fov = lurek.awareness.newFov({ width = 20, height = 20, range = 8 })
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
    local fov = lurek.awareness.newFov({ width = 20, height = 20, range = 8 })
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
    local fov = lurek.awareness.newFov({ width = 20, height = 20, range = 8 })
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
    local fov = lurek.awareness.newFov({ width = 20, height = 20, range = 8 })
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
    local fov = lurek.awareness.newFov({ width = 20, height = 20, range = 4 })
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
    local fov = lurek.awareness.newFov({ width = 8, height = 8, range = 4 })
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
    local fov = lurek.awareness.newFov({ width = 8, height = 8, range = 4 })
    local is_fov = fov:typeOf("LFov")
    local is_object = fov:typeOf("LObject")
    local is_grid = fov:typeOf("LAwarenessGrid")
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
    local fov = lurek.awareness.newFov({ width = 20, height = 20, range = 6 })
    fov:compute(10, 10)
    local cells = fov:visibleCells()
    local first = cells[1]
    local first_label = first and (first.x .. "," .. first.y) or "none"
    lurek.log.info("visible cell count = " .. #cells)
    lurek.log.info("first visible cell = " .. first_label)
end
```

---

## LTileAwareness

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTileAwareness:actionCells`

Returns all currently actionable cells for a player, optionally filtered to a level.

```lua
LTileAwareness:actionCells(player, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player` | string | Player identifier to query. |
| `z?` | number | Optional one-based level filter. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of one-based actionable cell tables. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local vis = lurek.awareness.newTileAwareness(field, { players = { "p1" } })
    vis:computeAction("p1", { origin = { x = 2, y = 2, z = 1 }, range = 1 })
    local cells = vis:actionCells("p1", 1)
    lurek.log.info("actionCells count = " .. #cells)
end
```

---

#### `LTileAwareness:canActOn`

Returns whether a one-based cell is currently actionable for a player.

```lua
LTileAwareness:canActOn(player, x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player` | string | Player identifier to query. |
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the cell is currently actionable. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local vis = lurek.awareness.newTileAwareness(field, { players = { "p1" } })
    vis:computeAction("p1", { origin = { x = 2, y = 2, z = 1 }, range = 1 })
    local actionable = vis:canActOn("p1", 2, 2, 1)
    lurek.log.info("center actionable = " .. tostring(actionable))
end
```

---

#### `LTileAwareness:clearAll`

Clears current, explored, and action masks for all players.

```lua
LTileAwareness:clearAll()
```

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local vis = lurek.awareness.newTileAwareness(field, { players = { "p1", "p2" } })
    vis:computeAction("p1", { origin = { x = 2, y = 2, z = 1 }, range = 1 })
    vis:clearAll()
    lurek.log.info("after clearAll action = " .. tostring(vis:canActOn("p1", 2, 2, 1)))
end
```

---

#### `LTileAwareness:clearPlayer`

Clears current, explored, and action masks for one player.

```lua
LTileAwareness:clearPlayer(player)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player` | string | Player identifier whose visibility state should be cleared. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local vis = lurek.awareness.newTileAwareness(field, { players = { "p1" } })
    vis:computeVisible("p1", { origin = { x = 2, y = 2, z = 1 }, range = 1 })
    vis:clearPlayer("p1")
    lurek.log.info("after clearPlayer visible = " .. tostring(vis:isVisible("p1", 2, 2, 1)))
end
```

---

#### `LTileAwareness:clearShares`

Clears all directed awareness share edges.

```lua
LTileAwareness:clearShares()
```

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 5 })
    field:defineCategory("sound", { kind = "awareness" })
    local vis = lurek.awareness.newTileAwareness(field, { players = { "p1", "p2" } })
    local ok, value = pcall(function()
        vis:defineCategory("sound", { active = true, range = 1 })
        vis:share("p1", "p2", "sound")
        vis:clearShares()
        return #vis:getCategories()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileAwareness:computeAction`

Computes one player's current action mask from a tilefield origin.

```lua
LTileAwareness:computeAction(player, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player` | string | Player identifier whose action mask should be computed. |
| `opts` | table | Options table with origin, range, and optional action channel. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 3 })
    field:applyProfile(3, 2, 1, "window")
    local vis = lurek.awareness.newTileAwareness(field, { players = { "p1" } })
    vis:computeAction("p1", { origin = { x = 1, y = 2, z = 1 }, range = 6 })
    lurek.log.info("can act through window = " .. tostring(vis:canActOn("p1", 6, 2, 1)))
end
```

---

#### `LTileAwareness:computeVisible`

Computes one player's current visible mask from a tilefield origin.

```lua
LTileAwareness:computeVisible(player, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player` | string | Player identifier whose visibility mask should be computed. |
| `opts` | table | Options table with origin, range, category, mode, arc, facing, and blockerCategory. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 6, height = 6 })
    local vis = lurek.awareness.newTileAwareness(field, { players = { "p1" } })
    vis:computeVisible("p1", { origin = { x = 2, y = 2, z = 1 }, range = 2 })
    local count = #vis:visibleCells("p1", 1)
    lurek.log.info("visible tile count = " .. count)
end
```

---

#### `LTileAwareness:defineCategory`

Defines or replaces one awareness category.

```lua
LTileAwareness:defineCategory(name, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Category name to create or replace. |
| `opts?` | table | Optional category settings such as range, arc, facing, active, and blocker rules. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 5 })
    field:defineCategory("sound", { kind = "awareness" })
    local vis = lurek.awareness.newTileAwareness(field, { players = { "p1", "p2" } })
    local ok, value = pcall(function()
        vis:defineCategory("sound", { active = true, range = 2, blockerCategory = "sound" })
        return #vis:getCategories()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileAwareness:getCategories`

Returns known awareness category names.

```lua
LTileAwareness:getCategories()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of registered awareness category names. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 5 })
    field:defineCategory("sound", { kind = "awareness" })
    local vis = lurek.awareness.newTileAwareness(field, { players = { "p1", "p2" } })
    local ok, value = pcall(function()
        vis:defineCategory("sound", { active = true, range = 2 })
        return vis:getCategories()[1]
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileAwareness:getCategory`

Returns awareness category metadata.

```lua
LTileAwareness:getCategory(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Category name to inspect. |

**Returns**

| Type | Description |
|------|-------------|
| table | Category metadata table, or nil when the category is unknown. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 5 })
    field:defineCategory("sound", { kind = "awareness" })
    local vis = lurek.awareness.newTileAwareness(field, { players = { "p1", "p2" } })
    local ok, value = pcall(function()
        vis:defineCategory("sound", { active = true, range = 2, blockerCategory = "sound" })
        return vis:getCategory("sound").range
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileAwareness:isAware`

Returns whether a one-based cell is visible for a specific awareness category.

```lua
LTileAwareness:isAware(player, category, x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player` | string | Player identifier to query. |
| `category` | string | Awareness category name. |
| `x` | number | One-based cell column. |
| `y` | number | One-based cell row. |
| `z?` | number | Optional one-based level index, defaulting to 1. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the addressed cell is visible for the selected category. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 5 })
    field:defineCategory("sound", { kind = "awareness" })
    local vis = lurek.awareness.newTileAwareness(field, { players = { "p1", "p2" } })
    local ok, value = pcall(function()
        vis:defineCategory("sound", { active = true, range = 1 })
        vis:computeVisible("p1", 2, 2, 1, "sound")
        return vis:isAware("p1", 2, 2, 1, "sound")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileAwareness:isExplored`

Returns whether a one-based cell has been explored for a player.

```lua
LTileAwareness:isExplored(player, x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player` | string | Player identifier to query. |
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the cell has been explored. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local vis = lurek.awareness.newTileAwareness(field, { players = { "p1" }, rememberExplored = true })
    vis:computeVisible("p1", { origin = { x = 2, y = 2, z = 1 }, range = 1 })
    local explored = vis:isExplored("p1", 2, 2, 1)
    lurek.log.info("center explored = " .. tostring(explored))
end
```

---

#### `LTileAwareness:isVisible`

Returns whether a one-based cell is currently visible for a player.

```lua
LTileAwareness:isVisible(player, x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player` | string | Player identifier to query. |
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the cell is currently visible. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local vis = lurek.awareness.newTileAwareness(field, { players = { "p1" } })
    vis:computeVisible("p1", { origin = { x = 2, y = 2, z = 1 }, range = 1 })
    local visible = vis:isVisible("p1", 2, 2, 1)
    lurek.log.info("center visible = " .. tostring(visible))
end
```

---

#### `LTileAwareness:setTeam`

Creates directed share edges between all listed players for selected categories.

```lua
LTileAwareness:setTeam(players, categories)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `players` | table | Array of player identifiers that should share visibility. |
| `categories?` | table | Optional array of category names to share; omitted shares every category. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 5 })
    field:defineCategory("sound", { kind = "awareness" })
    local vis = lurek.awareness.newTileAwareness(field, { players = { "p1", "p2" } })
    local ok, value = pcall(function()
        vis:setTeam("p1", "blue")
        vis:setTeam("p2", "blue")
        vis:defineCategory("sound", { active = true, range = 1 })
        return vis:type()
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileAwareness:share`

Adds a directed awareness share edge for one category.

```lua
LTileAwareness:share(from, to, category, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from` | string | Source player identifier. |
| `to` | string | Target player identifier. |
| `category` | string | Awareness category to share. |
| `opts?` | table | Reserved optional settings table for future share options. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 5, height = 5 })
    field:defineCategory("sound", { kind = "awareness" })
    local vis = lurek.awareness.newTileAwareness(field, { players = { "p1", "p2" } })
    local ok, value = pcall(function()
        vis:defineCategory("sound", { active = true, range = 1 })
        vis:computeVisible("p1", 2, 2, 1, "sound")
        vis:share("p1", "p2", "sound")
        return vis:isAware("p2", 2, 2, 1, "sound")
    end)
    local status = ok and "ok" or "error"
    lurek.log.info(status .. " " .. tostring(value))
end
```

---

#### `LTileAwareness:type`

Returns the Lua-visible type name for this tile visibility handle.

```lua
LTileAwareness:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LTileAwareness](#ltileawareness)`. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 2, height = 2 })
    local vis = lurek.awareness.newTileAwareness(field, { players = { "p1" } })
    local name = vis:type()
    local object = vis:typeOf("LObject")
    lurek.log.info("tile visibility type = " .. name .. " object=" .. tostring(object))
end
```

---

#### `LTileAwareness:typeOf`

Returns whether this handle matches a supported type name.

```lua
LTileAwareness:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against this handle. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True for `[LTileAwareness](#ltileawareness)` or `LObject`. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 2, height = 2 })
    local vis = lurek.awareness.newTileAwareness(field, { players = { "p1" } })
    local exact = vis:typeOf("LTileAwareness")
    local miss = vis:typeOf("LFov")
    lurek.log.info("tile visibility typeOf = " .. tostring(exact) .. " miss=" .. tostring(miss))
end
```

---

#### `LTileAwareness:updateSightSources`

Computes one player's current visible mask from multiple tilefield sight sources.

```lua
LTileAwareness:updateSightSources(player, sources)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player` | string | Player identifier whose visibility mask should be computed. |
| `sources` | table | Array of source tables with origin, range, category, mode, arc, facing, and blockerCategory. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of processed sight sources. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 8, height = 8 })
    local awareness = lurek.awareness.newTileAwareness(field, { players = { "blue" } })
    awareness:updateSightSources("blue", { { x = 2, y = 2, z = 1, range = 2 }, { x = 6, y = 6, z = 1, range = 1 } })
    local near = awareness:isVisible("blue", 2, 2, 1)
    local far = awareness:isVisible("blue", 6, 6, 1)
    lurek.log.info("updated sight near=" .. tostring(near) .. " far=" .. tostring(far))
end
```

---

#### `LTileAwareness:visibleCells`

Returns all currently visible cells for a player, optionally filtered to a level.

```lua
LTileAwareness:visibleCells(player, categoryOrZ, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player` | string | Player identifier to query. |
| `categoryOrZ?` | string|number | Optional category name or one-based level filter when no separate `z` argument is supplied. |
| `z?` | number | Optional one-based level filter used when `categoryOrZ` is a category string. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of one-based visible cell tables. |

**Example**

```lua
do
    local field = lurek.tilefield.new({ width = 4, height = 4 })
    local vis = lurek.awareness.newTileAwareness(field, { players = { "p1" } })
    vis:computeVisible("p1", { origin = { x = 2, y = 2, z = 1 }, range = 1 })
    local cells = vis:visibleCells("p1", 1)
    lurek.log.info("visibleCells count = " .. #cells)
end
```

---
