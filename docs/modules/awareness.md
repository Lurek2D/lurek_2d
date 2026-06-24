# Awareness

## Purpose

Player-specific fog-of-war, remembered exploration, line-of-sight, and action-mask simulation.

## When To Use

- It combines adjacency rules, reveal cost, ownership flags, events, shadowcasting, and stored state so the same module can answer both gameplay questions and presentation needs.
- That makes it more than a single visibility check: current sight, remembered discovery, reveal transitions, and display-friendly output are meant to behave as one coherent information system.
- Team-specific reveal state and remembered exploration are especially important because many map-aware games care not only about what is visible now, but also about what was discovered earlier and by whom.

## Minimal Example

Example block: `lurek.awareness.new`

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

## Common Patterns

- Start with `lurek.awareness.lineOfAction` when exploring this module.
- Start with `lurek.awareness.lineOfSight` when exploring this module.
- Start with `lurek.awareness.new` when exploring this module.
- Start with `lurek.awareness.newFov` when exploring this module.
- Start with `lurek.awareness.newTileAwareness` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

## Summary

- The `awareness` module is the shared answer to fog-of-war, line-of-sight, action reachability, and remembered exploration for users building map-aware gameplay.
- It combines adjacency rules, reveal cost, ownership flags, events, shadowcasting, and stored state so the same module can answer both gameplay questions and presentation needs.
- That makes it more than a single visibility check: current sight, remembered discovery, reveal transitions, and display-friendly output are meant to behave as one coherent information system.
- Team-specific reveal state and remembered exploration are especially important because many map-aware games care not only about what is visible now, but also about what was discovered earlier and by whom.
- That unified state is what lets fog-of-war, scouting, and map presentation stay aligned.
- It also keeps team knowledge explicit.
- Read this module as the authority for what an actor currently knows about a space.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Functions

### `lurek.awareness.lineOfAction`

Returns whether two tilefield cells have a clear action line.

```lua
lurek.awareness.lineOfAction(field, from, to, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `field` | [LTileField](#ltilefield) | Tilefield to query. |
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
| `field` | [LTileField](#ltilefield) | Tilefield to query. |
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
| `field` | [LTileField](#ltilefield) | Source tilefield. |
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
- [LTileField](#ltilefield)

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
    vg:reveal(1, 42, 2)
    local player_state = vg:getState(1, 42)
    local other_state = vg:getState(0, 42)
    local fog = vg:getFogIntensity(1, 42)
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
    local function example_log(message)
        lurek.log.info("[awareness.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
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
| `name` | any |  |
| `opts?` | any |  |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[awareness.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 5 })
    field:defineCategory("sound", { kind = "awareness" })
    local vis = lurek.awareness.newTileAwareness(field, { players = { "p1", "p2" } })
    local ok, value = pcall(function()
        vis:defineCategory("sound", { active = true, range = 2, blockerCategory = "sound" })
        return #vis:getCategories()
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
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
    local function example_log(message)
        lurek.log.info("[awareness.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 5 })
    field:defineCategory("sound", { kind = "awareness" })
    local vis = lurek.awareness.newTileAwareness(field, { players = { "p1", "p2" } })
    local ok, value = pcall(function()
        vis:defineCategory("sound", { active = true, range = 2 })
        return vis:getCategories()[1]
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
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
| table? | Category metadata table, or nil when the category is unknown. |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[awareness.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 5 })
    field:defineCategory("sound", { kind = "awareness" })
    local vis = lurek.awareness.newTileAwareness(field, { players = { "p1", "p2" } })
    local ok, value = pcall(function()
        vis:defineCategory("sound", { active = true, range = 2, blockerCategory = "sound" })
        return vis:getCategory("sound").range
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
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
| `player` | any |  |
| `category` | any |  |
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[awareness.example] " .. tostring(message))
    end
    local field = lurek.tilefield.new({ width = 5, height = 5 })
    field:defineCategory("sound", { kind = "awareness" })
    local vis = lurek.awareness.newTileAwareness(field, { players = { "p1", "p2" } })
    local ok, value = pcall(function()
        vis:defineCategory("sound", { active = true, range = 1 })
        vis:computeVisible("p1", 2, 2, 1, "sound")
        return vis:isAware("p1", 2, 2, 1, "sound")
    end)
    local status = ok and "ok" or "error"
    example_log(status .. " " .. tostring(value))
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
| `players` | any |  |
| `categories?` | any |  |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[awareness.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
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
| `from` | any |  |
| `to` | any |  |
| `category` | any |  |
| `opts?` | any |  |

**Example**

```lua
do
    local function example_log(message)
        lurek.log.info("[awareness.example] " .. tostring(message))
    end
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
    example_log(status .. " " .. tostring(value))
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

#### `LTileAwareness:visibleCells`

Returns all currently visible cells for a player, optionally filtered to a level.

```lua
LTileAwareness:visibleCells(player, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `player` | string | Player identifier to query. |
| `z?` | number | Optional one-based level filter. |

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

## LTileField

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTileField:applyModifier`

Applies a named modifier to one cell.

```lua
LTileField:applyModifier(x, y, z, modifier)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `modifier` | string | Modifier name. |

---

#### `LTileField:applyProfile`

Applies a legacy profile to one cell.

```lua
LTileField:applyProfile(x, y, z, profile)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `profile` | string | Profile name. |

---

#### `LTileField:applyTilesetObject`

Applies the object archetype defaults for a tileset tile referenced from one cell.

```lua
LTileField:applyTilesetObject(x, y, z, slot, tileset, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](tileset.md#ltileset) | Tileset that stores object archetype metadata. |
| `opts?` | table | Options: refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the tileset object was found and applied. |

---

#### `LTileField:applyTilesetObjectLayer`

Applies tileset object defaults for every referenced cell on one tilefield level.

```lua
LTileField:applyTilesetObjectLayer(slot, tileset, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](tileset.md#ltileset) | Tileset that stores object metadata. |
| `opts?` | table | Options: z, refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| number | Number of cells that received object defaults. |

---

#### `LTileField:blocks`

Returns whether a cell blocks a channel.

```lua
LTileField:blocks(x, y, z, channel)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `channel` | string | Blocker channel name to query. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the addressed cell blocks the channel. |

---

#### `LTileField:blocksCategory`

Returns whether one cell blocks a category.

```lua
LTileField:blocksCategory(x, y, z, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |

---

#### `LTileField:clear`

Clears all cell gameplay state.

```lua
LTileField:clear()
```

---

#### `LTileField:clearCell`

Clears gameplay state for one addressed cell.

```lua
LTileField:clearCell(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

---

#### `LTileField:clearLine`

Returns true when the line between two cell tables has no blocker for a channel.

```lua
LTileField:clearLine(from_tbl, to_tbl, channel, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_tbl` | table | Start cell table with one-based x, y, and optional z fields. |
| `to_tbl` | table | End cell table with one-based x, y, and optional z fields. |
| `channel` | string | Blocker channel name to test along the line. |
| `opts?` | table | Reserved optional line query options. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when no blocker exists between the two cells. |

---

#### `LTileField:clearModifier`

Removes one modifier from one cell.

```lua
LTileField:clearModifier(x, y, z, modifier)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `modifier` | string | Modifier name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the cell had the modifier. |

---

#### `LTileField:clearRef`

Clears a named object/tile reference from one cell.

```lua
LTileField:clearRef(x, y, z, slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |

---

#### `LTileField:defineCategory`

Defines or replaces a user category used by movement, awareness, light, sun, or custom systems.

```lua
LTileField:defineCategory(name, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Stable category name. |
| `opts?` | table?|Options | custom', active=true?. |

---

#### `LTileField:defineSlot`

Defines a named object slot that cells may reference.

```lua
LTileField:defineSlot(slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Slot name chosen by the Lua game. |

---

#### `LTileField:exportBlockLayer`

Exports one blocker channel and level as a row-major boolean array.

```lua
LTileField:exportBlockLayer(channel, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `channel` | string | Blocker channel name to export. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| table | Row-major boolean array for the requested channel and level. |

---

#### `LTileField:exportCostLayer`

Exports one cost channel and level as a row-major number array.

```lua
LTileField:exportCostLayer(channel, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `channel` | string | Cost channel name to export. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| table | Row-major number array for the requested channel and level. |

---

#### `LTileField:exportRefLayer`

Exports one named object/tile reference slot and level as a row-major array.

```lua
LTileField:exportRefLayer(slot, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Reference slot name to export. |
| `z?` | number | One-based level, default 1. |

---

#### `LTileField:firstBlocker`

Returns the first one-based blocking cell table between two cells, or nil.

```lua
LTileField:firstBlocker(from_tbl, to_tbl, channel, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `from_tbl` | table | Start cell table with one-based x, y, and optional z fields. |
| `to_tbl` | table | End cell table with one-based x, y, and optional z fields. |
| `channel` | string | Blocker channel name to test along the line. |
| `opts?` | table | Reserved optional line query options. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | First blocking cell table, or nil when the line is clear. |

---

#### `LTileField:footprintPassable`

Returns whether a rectangular footprint can occupy a cell anchor for a category.

```lua
LTileField:footprintPassable(x, y, z, w, h, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `w` | any |  |
| `h` | any |  |
| `category` | any |  |

---

#### `LTileField:getCategories`

Returns known category names.

```lua
LTileField:getCategories()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Sorted category names. |

---

#### `LTileField:getCategory`

Returns category metadata, or nil when the category is unknown.

```lua
LTileField:getCategory(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Category name. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | Category table with name, kind, and active. |

---

#### `LTileField:getCategoryCost`

Returns one effective category cost.

```lua
LTileField:getCategoryCost(x, y, z, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |

---

#### `LTileField:getCategoryFilter`

Returns one effective RGB category filter.

```lua
LTileField:getCategoryFilter(x, y, z, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |

---

#### `LTileField:getCategoryTransmission`

Returns one effective category transmission multiplier.

```lua
LTileField:getCategoryTransmission(x, y, z, category)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |

---

#### `LTileField:getCell`

Returns a table with blockers, costs, sun occlusion, refs, and modifiers.

```lua
LTileField:getCell(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| table | Cell state table. |

---

#### `LTileField:getCost`

Returns the cost for one cell/channel.

```lua
LTileField:getCost(x, y, z, channel)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `channel` | string | Cost channel name to query. |

**Returns**

| Type | Description |
|------|-------------|
| number | Movement or traversal cost value. |

---

#### `LTileField:getModifier`

Returns a named tile modifier table, or nil.

```lua
LTileField:getModifier(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Modifier name. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | Modifier table. |

---

#### `LTileField:getModifiers`

Returns active modifier names on one cell.

```lua
LTileField:getModifiers(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| string[] | Active modifier names. |

---

#### `LTileField:getNeighbors`

Returns topology-aware same-level neighbours for one cell.

```lua
LTileField:getNeighbors(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array of one-based coordinate tables. |

---

#### `LTileField:getProfile`

Returns a legacy profile table, or nil.

```lua
LTileField:getProfile(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Profile name. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | Profile table. |

---

#### `LTileField:getRef`

Returns a named object/tile reference from one cell, or nil.

```lua
LTileField:getRef(x, y, z, slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |

**Returns**

| Type | Description |
|------|-------------|
| number | table|nil | Stored legacy id, typed ref table, or nil when unset. |

---

#### `LTileField:getRefProperties`

Reads all tileset properties for a tile referenced from one cell.

```lua
LTileField:getRefProperties(x, y, z, slot, tileset, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](tileset.md#ltileset) | Tileset that stores object metadata. |
| `opts?` | table | Options: refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| table | nil | Property name/value table, or nil when the ref is missing/outside the tileset. |

---

#### `LTileField:getRefProperty`

Reads a tileset property for a tile referenced from one cell.

```lua
LTileField:getRefProperty(x, y, z, slot, tileset, property, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](tileset.md#ltileset) | Tileset that stores object metadata. |
| `property` | string | Property name to read. |
| `opts?` | table | Options: refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| string | nil | Property value, or nil when missing. |

---

#### `LTileField:getRefPropertyBool`

Reads a tileset property for a tile referenced from one cell and parses it as a boolean.

```lua
LTileField:getRefPropertyBool(x, y, z, slot, tileset, property, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](tileset.md#ltileset) | Tileset that stores object metadata. |
| `property` | string | Property name to read. |
| `opts?` | table | Options: refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | nil | Boolean property value, or nil when missing/not boolean. |

---

#### `LTileField:getRefPropertyNumber`

Reads a tileset property for a tile referenced from one cell and parses it as a number.

```lua
LTileField:getRefPropertyNumber(x, y, z, slot, tileset, property, opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name. |
| `tileset` | [LTileSet](tileset.md#ltileset) | Tileset that stores object metadata. |
| `property` | string | Property name to read. |
| `opts?` | table | Options: refIsGid. |

**Returns**

| Type | Description |
|------|-------------|
| number | nil | Numeric property value, or nil when missing/not numeric. |

---

#### `LTileField:getRefSlots`

Returns every declared ref slot.

```lua
LTileField:getRefSlots()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Ref slot names. |

---

#### `LTileField:getRegionCells`

Returns one-based cells for a named region, or nil when it does not exist.

```lua
LTileField:getRegionCells(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Region name. |

**Returns**

| Type | Description |
|------|-------------|
| table? | Array of `{ x, y, z }` cells. |

---

#### `LTileField:getRegionNames`

Returns all region names in stable order.

```lua
LTileField:getRegionNames()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Array of region names. |

---

#### `LTileField:getSize`

Returns field width, height, and level count.

```lua
LTileField:getSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Field width in cells. |
| number | Field height in cells. |
| number | Level count. |

---

#### `LTileField:getSunOcclusion`

Returns top-light occlusion in the inclusive range 0..1.

```lua
LTileField:getSunOcclusion(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| number | Top-light occlusion value in the inclusive range 0..1. |

---

#### `LTileField:getTopology`

Returns the field topology name used for coordinate interpretation.

```lua
LTileField:getTopology()
```

**Returns**

| Type | Description |
|------|-------------|
| string | `square`, `square4`, `square8`, `iso_square`, or `hex`. |

---

#### `LTileField:getVersion`

Returns the current tilefield data version.

```lua
LTileField:getVersion()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Monotonic field version incremented by data mutations. |

---

#### `LTileField:hasSlot`

Returns true when a named object slot is declared.

```lua
LTileField:hasSlot(slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Slot name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when declared. |

---

#### `LTileField:inBounds`

Returns whether one-based coordinates are inside the field.

```lua
LTileField:inBounds(x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when coordinates are in bounds. |

---

#### `LTileField:line`

Returns topology-aware one-based cells between `from` and `to` tables.

```lua
LTileField:line(opts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `opts` | table | `{from={x,y,z?}, to={x,y,z?}, includeEndpoints?}`. |

---

#### `LTileField:regionContains`

Returns whether a named region contains a one-based tile cell.

```lua
LTileField:regionContains(name, x, y, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Region name. |
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the region contains the cell. |

---

#### `LTileField:removeModifier`

Removes a named modifier and clears it from all cells.

```lua
LTileField:removeModifier(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Modifier name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when removed. |

---

#### `LTileField:removeProfile`

Removes a legacy profile and clears it from all cells.

```lua
LTileField:removeProfile(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Profile name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when removed. |

---

#### `LTileField:removeRegion`

Removes a named region.

```lua
LTileField:removeRegion(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Region name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the region existed. |

---

#### `LTileField:removeSlot`

Removes a named object slot and clears its references from the field.

```lua
LTileField:removeSlot(slot)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Slot name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the slot existed. |

---

#### `LTileField:setBlock`

Sets whether a cell blocks a channel.

```lua
LTileField:setBlock(x, y, z, channel, blocked)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `channel` | string | Blocker channel name to update. |
| `blocked` | boolean | True when the channel should be blocked. |

---

#### `LTileField:setCategoryBlock`

Sets one category blocker on one cell.

```lua
LTileField:setCategoryBlock(x, y, z, category, blocked)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |
| `blocked` | any |  |

---

#### `LTileField:setCategoryCost`

Sets one category cost on one cell.

```lua
LTileField:setCategoryCost(x, y, z, category, cost)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |
| `cost` | any |  |

---

#### `LTileField:setCategoryFilter`

Sets one RGB category filter on one cell.

```lua
LTileField:setCategoryFilter(x, y, z, category, filter)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |
| `filter` | any |  |

---

#### `LTileField:setCategoryTransmission`

Sets one category transmission multiplier on one cell.

```lua
LTileField:setCategoryTransmission(x, y, z, category, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | any |  |
| `y` | any |  |
| `z?` | any |  |
| `category` | any |  |
| `value` | any |  |

---

#### `LTileField:setCell`

Sets cell state from a table with optional `blocks`, `costs`, `sunOcclusion`, `refs`, and `modifiers`.

```lua
LTileField:setCell(x, y, z, cell)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `cell` | table | Cell data. |

---

#### `LTileField:setCost`

Sets the cost for one cell/channel.

```lua
LTileField:setCost(x, y, z, channel, cost)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `channel` | string | Cost channel name to update. |
| `cost` | number | Movement or traversal cost value. |

---

#### `LTileField:setModifier`

Registers or replaces a named tile modifier.

```lua
LTileField:setModifier(name, modifier)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Modifier name. |
| `modifier` | table | Modifier table with blocks, costAdd, costMul, sunOcclusionAdd, light, properties. |

---

#### `LTileField:setProfile`

Registers or replaces a legacy tilefield profile.

```lua
LTileField:setProfile(name, profile)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Profile name. |
| `profile` | table | Profile table with blocks, costs, sunOcclusion, light, or properties. |

---

#### `LTileField:setRef`

Sets a named object/tile reference on one cell.

```lua
LTileField:setRef(x, y, z, slot, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `slot` | string | Reference slot name defined by the Lua game. |
| `value` | number|table | Legacy id or typed `{ tileset, tile?/object? }` ref stored for the slot. |

---

#### `LTileField:setRegionCells`

Defines or replaces a named region from explicit one-based tile cells.

```lua
LTileField:setRegionCells(name, cells)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Region name. |
| `cells` | table | Array of `{ x, y, z? }` cells. |

---

#### `LTileField:setRegionRect`

Defines or replaces a named region from an inclusive one-based tile rectangle.

```lua
LTileField:setRegionRect(name, x1, y1, x2, y2, z)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Region name. |
| `x1` | number | First one-based column. |
| `y1` | number | First one-based row. |
| `x2` | number | Second one-based column. |
| `y2` | number | Second one-based row. |
| `z?` | number | One-based level, default 1. |

---

#### `LTileField:setSunOcclusion`

Sets top-light occlusion in the inclusive range 0..1.

```lua
LTileField:setSunOcclusion(x, y, z, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `x` | number | One-based column. |
| `y` | number | One-based row. |
| `z?` | number | One-based level, default 1. |
| `value` | number | Top-light occlusion value in the inclusive range 0..1. |

---

#### `LTileField:type`

Returns the Lua-visible type name for this tilefield handle.

```lua
LTileField:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LTileField](#ltilefield)`. |

---

#### `LTileField:typeOf`

Returns whether this handle matches a supported type name.

```lua
LTileField:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True for `[LTileField](#ltilefield)` or `LObject`. |

---

#### `LTileField:writeBlockLayer`

Writes one full blocker channel layer from a row-major boolean array.

```lua
LTileField:writeBlockLayer(channel, z, values)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `channel` | string | Blocker channel name to write. |
| `z?` | number | One-based level, default 1. |
| `values` | table | Row-major boolean array with width*height entries. |

---

#### `LTileField:writeCostLayer`

Writes one full cost channel layer from a row-major number array.

```lua
LTileField:writeCostLayer(channel, z, values)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `channel` | string | Cost channel name to write. |
| `z?` | number | One-based level, default 1. |
| `values` | table | Row-major number array with width*height entries. |

---

#### `LTileField:writeRefLayer`

Writes one full named ref layer from a row-major integer-or-nil array.

```lua
LTileField:writeRefLayer(slot, z, values)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `slot` | string | Reference slot name to write. |
| `z?` | number | One-based level, default 1. |
| `values` | table | Row-major integer-or-nil array with width*height entries. |

---
