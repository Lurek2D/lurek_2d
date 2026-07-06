# Massive 2D RTS

## Product promise

Build a Rusted Warfare-style 2D RTS where the game script can focus on units, economy, combat, UI, and content instead of reimplementing scalable movement algorithms. The target is a large mutable battlefield with thousands of units, multiple footprint sizes, and common RTS orders exposed through configurable Lurek APIs.

This document is not a clone plan. It defines the Lurek-side architecture needed for a massive 2D RTS product and the gameplay-facing API shape that should hide navigation, grouping, and local-avoidance complexity from Lua game code.

## Scale target

- Map size: 1000 x 1000 logical cells as a normal supported case, not an edge-case stress test.
- Unit counts: thousands of active units, with a benchmark target that can be raised in stages: 500, 1000, 2500, 5000.
- Unit footprints: at minimum 1x1, 2x2, and 4x4 cells; later rectangular footprints such as 2x3 and building footprints.
- Dynamic obstacles: buildings, wrecks, terrain changes, closed gates, temporary blockers, and construction sites.
- Orders: move, attack-move, patrol, guard, auto-explore, stop, hold position, and stance changes.
- Movement quality: formations should remain recognizable without requiring perfect slot locking when terrain is narrow or crowded.

## Project structure

A game using this design should keep content and RTS logic separated:

```text
content/games/massive_rts/
  conf.toml
  main.lua
  assets/
    units/
    terrain/
    ui/
  data/
    unit_types.toml
    weapons.toml
    factions.toml
    maps/
  scripts/
    boot.lua
    systems/
      rts_world.lua
      orders.lua
      combat.lua
      economy.lua
      fog.lua
      selection.lua
      debug_nav.lua
    ui/
      hud.lua
      minimap.lua
      command_panel.lua
```

Lua owns game rules, data loading, faction definitions, UI, combat rules, and victory conditions. Lurek should own the generic algorithms: map navigation, flow/corridor pathing, local avoidance, formation slotting, order lifecycle, target acquisition policy, and path budget scheduling.

## Current Lurek API strategy

The current engine already has important low-level pieces:

- `lurek.tilefield` can describe gameplay cells and movement categories.
- `lurek.pathfind.newNavGridFromField` can derive navigation costs and blocked cells from a tilefield level.
- `lurek.pathfind` exposes `NavGrid`, A*, HPA*, flow fields, async path jobs, steering, context steering, ORCA, influence maps, and graph helpers.
- `lurek.ai` exposes `AIWorld`, agents, behavior trees, GOAP/HTN/MCTS, utility AI, squads, perception, traits, needs, and custom Lua callbacks.

For a massive RTS these are necessary but not sufficient. A game can assemble them manually, but doing so would force the game author to become the movement-system engineer. The missing layer is a high-level `lurek.rts` or `lurek.ai.rts` API that orchestrates those primitives in a scalable, configurable way.

## Proposed high-level API

The preferred public surface is a new `lurek.rts` module that composes `tilefield`, `pathfind`, `ai`, and spatial indexing.

```lua
local nav = lurek.pathfind.newNavGridFromField(field, {
  level = 1,
  category = "ground",
  costCategory = "ground_cost",
  diagonalMode = "nocornercut",
})

local rts = lurek.rts.newWorld({
  nav = nav,
  cell_size = 16,
  max_units = 5000,
  path_budget_ms = 2.0,
  avoidance_budget_ms = 2.0,
})

rts:defineUnitType("tank", {
  footprint = { w = 2, h = 2 },
  radius = 14,
  movement_class = "ground_heavy",
  max_speed = 46,
  separation = 4,
  path = {
    preferred = "corridor_flow",
    fallback = "hpa",
    repath_interval = 0.35,
  },
  stance = "aggressive",
})

local id = rts:addUnit({
  type = "tank",
  team = 1,
  x = 120,
  y = 80,
})

rts:issueMove(selected_units, { x = 740, y = 420 }, {
  formation = "box",
  spacing = 2,
  allow_partial = true,
})

rts:issuePatrol(selected_units, {
  { x = 100, y = 100 },
  { x = 180, y = 160 },
}, { loop = true, area_radius = 6 })

rts:issueGuard(selected_units, target_unit_id, {
  radius = 8,
  chase_radius = 14,
})

rts:issueExplore(selected_units, {
  mode = "frontier",
  avoid_enemy_strength = 0.75,
})

rts:setStance(selected_units, "defensive")
rts:update(dt)
for _, event in ipairs(rts:drainEvents()) do
  -- unit_reached_order, unit_blocked, target_lost, formation_split, etc.
end
```

The game should not need to implement A*, flow fields, ORCA neighbor filtering, HPA invalidation, or formation slot assignment in Lua.

## Navigation architecture

Movement should be layered from coarse to fine:

1. **Terrain source**: `tilefield` or `tilemap` stores terrain categories, costs, blockers, construction sites, and dynamic blockers.
2. **Navigation grid**: `NavGrid` stores current walkability and cost per movement class.
3. **Clearance fields**: precomputed clearance for footprint profiles such as 1x1, 2x2, 4x4, and rectangular variants.
4. **Hierarchy**: HPA or region/portal graph stores long-range connectivity and corridor routes.
5. **Flow/corridor cache**: groups moving toward the same goal share flow fields or corridor segments instead of every unit running full A*.
6. **Formation planner**: assigns slots near the destination and along corridors, with fallback when slots are blocked.
7. **Local movement**: steering and ORCA-style avoidance produce final velocities within a fixed per-frame budget.
8. **Debug telemetry**: overlays show dirty chunks, route corridors, flow vectors, slot targets, blocked units, and neighbor counts.

## Required pathfinding extensions

### Footprint and clearance profiles

Current unit-size pathing is useful, but RTS units need named movement profiles. Add API like:

```lua
nav:defineFootprint("infantry", { w = 1, h = 1 })
nav:defineFootprint("tank", { w = 2, h = 2 })
nav:defineFootprint("super_heavy", { w = 4, h = 4 })
nav:rebuildClearance({ profiles = { "infantry", "tank", "super_heavy" } })
nav:isWalkableFor("tank", x, y)
```

This avoids scanning every cell of a footprint for every neighbor expansion. It also allows rectangular footprints and movement-class-specific blockers later.

### Dynamic map updates

Dynamic blockers should be batched and committed:

```lua
nav:beginUpdate()
nav:setBlockedRect(x, y, w, h, true, { reason = "building" })
nav:setCostRect(x, y, w, h, 5, { movement_class = "ground" })
nav:commitUpdate({ rebuild = "dirty_chunks" })
```

`commitUpdate` should update generation counters, dirty rectangles, clearance fields, affected HPA chunks, and affected flow caches. Full rebuild should remain available for tools and loading, but gameplay updates should be incremental.

### Batch path requests

A high-level batch API should group similar route requests:

```lua
local batch = lurek.pathfind.submitBatch({
  grid = nav,
  movement_class = "ground",
  footprint = "tank",
  requests = {
    { owner = unit_id_1, from = {x=10,y=10}, to = {x=200,y=180}, priority = 5 },
    { owner = unit_id_2, from = {x=11,y=10}, to = {x=200,y=180}, priority = 5 },
  },
  mode = "shared_corridor_flow",
  max_ms = 1.0,
})
```

The engine should deduplicate goals, reuse corridors, reuse flow fields, and stream partial results. Lua should receive ownership-oriented events, not raw worker internals.

### Flow field cache

For RTS orders, many units usually share a destination or target region. Add a cache keyed by grid generation, movement class, footprint, team, destination region, and pathing mode.

```lua
local handle = lurek.pathfind.getFlowHandle(nav, {
  target = { x = 500, y = 500 },
  radius = 5,
  movement_class = "ground",
  footprint = "infantry",
  ttl = 0.5,
})
```

The RTS world can use this handle internally, but exposing it helps advanced games debug and tune behavior.

## Required local avoidance extensions

The current ORCA-style API should gain persistent spatial partitioning and neighbor limits so thousands of units do not become a quadratic pairwise problem.

Proposed API:

```lua
local crowd = lurek.pathfind.newCrowdSolver({
  cell_size = 32,
  max_neighbors = 12,
  time_horizon = 1.5,
  max_agents = 5000,
})

crowd:setAgent(unit_id, {
  x = unit.x,
  y = unit.y,
  vx = unit.vx,
  vy = unit.vy,
  radius = unit.radius,
  max_speed = unit.max_speed,
  preferred_vx = intent.vx,
  preferred_vy = intent.vy,
})

crowd:compute({ max_ms = 2.0 })
local vx, vy = crowd:getVelocity(unit_id)
```

This should be backed by a persistent spatial hash or grid index updated once per frame, not rebuilt per unit query.

## Required RTS order API

The engine should provide common RTS order primitives:

| Order | Engine responsibility | Lua responsibility |
| --- | --- | --- |
| `move` | route, formation slots, local avoidance, arrival events | choose selected units and target point |
| `attack_move` | move toward point, acquire hostile targets along route | combat damage rules and weapon data |
| `patrol` | route or area loop, reacquire path when blocked | decide patrol points/area |
| `guard` | follow/escort target with leash and response radius | decide target and faction rules |
| `explore` | frontier selection from fog/exploration data | fog source and exploration rewards |
| `stop` | clear path, clear queued commands | UI/action rules |
| `hold_position` | suppress chase movement, allow fire rules | combat policy |
| `stance` | passive/defensive/aggressive target policy | expose UX and faction defaults |

Orders should have a queue and lifecycle:

```lua
rts:queueOrder(units, {
  type = "patrol",
  points = { {x=10,y=10}, {x=50,y=30} },
  repeat_order = true,
  interruptible = true,
  priority = 4,
})

local order = rts:getCurrentOrder(unit_id)
rts:clearOrders(unit_id)
```

## Stance behavior profiles

Recommended built-in stances:

| Stance | Target acquisition | Chase | Movement interruption |
| --- | --- | --- | --- |
| `passive` | none unless explicitly targeted | no | never |
| `hold_fire` | track targets but do not fire | no | never |
| `defensive` | return fire or enemies inside guard radius | short leash | only inside leash |
| `aggressive` | acquire visible hostile in range | normal leash | can interrupt move briefly |
| `berserk` | acquire any visible hostile | long leash | can abandon formation |

The engine should make stance policy configurable, not hard-coded to one RTS design.

## Formation design

Existing squad offsets are a useful start, but RTS formations need destination slot assignment and obstacle-aware fallback.

Required formation API:

```lua
rts:defineFormation("box", {
  shape = "grid",
  spacing = 2,
  preserve_subgroups = true,
  sort = "by_distance_to_slot",
})

rts:issueMove(units, target, {
  formation = "box",
  facing = "toward_target",
  regroup = "soft",
  blocked_slot_policy = "nearest_valid",
})
```

The formation planner should:

- reserve or score slots by unit footprint;
- avoid assigning 4x4 units to narrow slots;
- split large groups when a corridor is too narrow;
- keep the formation readable in open terrain;
- allow tactical fallback to a stream/column in chokepoints;
- emit debug events when formation quality degrades.

## Fog and auto-explore

Auto-explore should not be a random walk. It should be a generic frontier planner that reads a game-supplied exploration grid:

```lua
rts:setExplorationProvider({
  width = map_w,
  height = map_h,
  isKnown = function(x, y) return fog:isKnown(x, y) end,
  isVisible = function(x, y) return fog:isVisible(x, y) end,
  danger = function(x, y) return threat_map:get(x, y) end,
})

rts:issueExplore(units, {
  frontier = "nearest_unknown",
  avoid_danger_above = 0.8,
  regroup_radius = 6,
})
```

The engine chooses candidate frontier cells and routes units there; Lua defines what counts as known, visible, valuable, or dangerous.

## UI and control loop

A normal RTS frame should look like this:

```lua
function lurek.process(dt)
  input:updateSelection(camera)
  orders:consumePlayerCommands(rts)
  economy:update(dt)
  combat:update(dt)
  rts:update(dt)
  fog:update(rts)
end

function lurek.draw()
  renderer:drawMap()
  renderer:drawUnits(rts)
end

function lurek.draw_ui()
  hud:drawSelection()
  minimap:draw()
  debug_nav:drawIfEnabled(rts)
end
```

The main game loop calls `rts:update(dt)` and inspects events. It should not manually step thousands of path requests or solve every unit's local avoidance from Lua.

## Debug overlays

Add a debug surface to inspect RTS-scale movement:

```lua
rts.debug:setEnabled(true)
rts.debug:draw({
  dirty_chunks = true,
  hpa_portals = true,
  flow_vectors = true,
  corridors = true,
  formation_slots = true,
  avoidance_neighbors = true,
  blocked_units = true,
})
```

Debug output should include counts for active flow fields, path jobs, dirty chunks, average neighbor count, worst path queue latency, and units without valid orders.

## Vertical slice acceptance criteria

The first production-ready slice should prove these cases:

1. Load a 1000 x 1000 map and derive navigation from `tilefield`.
2. Spawn at least 1000 mixed-footprint units: 1x1 infantry, 2x2 tanks, and 4x4 heavy units.
3. Select 200+ units and issue one move order with a visible formation.
4. Units share path/corridor/flow work instead of each unit calculating a full independent route.
5. Build or remove a building during gameplay and update only affected navigation regions.
6. Patrol, guard, stop, hold position, and stance changes work through engine-level orders.
7. Auto-explore can use a fog/exploration provider to choose frontier targets.
8. Debug overlays show pathing, dirty regions, flow fields, formations, and blocked units.
9. Lua gameplay code does not implement A*, HPA, flow fields, ORCA, or formation slot assignment.
10. Benchmarks report path queue time, movement update time, and frame-time impact.

## API gaps to track

- Add `lurek.rts` high-level module or an equivalent `lurek.ai.rts` namespace.
- Add footprint profiles and clearance fields to `NavGrid`.
- Add rectangular footprint support, not only square `unit_size`.
- Add movement classes and movement-layer-specific costs/blockers.
- Add dynamic nav generation, batch updates, and true dirty-chunk rebuilds.
- Add shared corridor and flow-field caches for group orders.
- Add batch path submission that deduplicates routes and goals.
- Add persistent spatial indexing for steering/ORCA/fog/threat queries.
- Replace all-pairs crowd avoidance with neighbor-limited spatial queries.
- Add built-in RTS orders and order queues.
- Add configurable stance/target-acquisition policies.
- Extend squads/formations into obstacle-aware slot assignment.
- Add RTS movement debug overlays and benchmark scenes.

## Risks

- Independent A* per unit will not scale to thousands of units on a 1000 x 1000 grid.
- Full-grid flow-field recomputation can become expensive if many unique goals are requested every frame.
- All-pairs local avoidance is not viable at RTS scale.
- Rebuilding spatial hashes per query defeats the purpose of spatial partitioning.
- Dynamic terrain changes need generation-aware caches or units will follow stale paths.
- Exposing too much low-level pathfinding to Lua will make every game duplicate engine algorithms.

## Suggested implementation phases

1. **API contracts and docs**: define `lurek.rts` concepts, Lua signatures, events, and benchmark goals.
2. **Navigation substrate**: add footprint profiles, clearance fields, generation counters, and dirty-region APIs.
3. **Batch routing**: add shared route/corridor/flow cache and batch path requests for selections.
4. **Crowd movement**: add persistent spatial index and neighbor-limited local avoidance.
5. **RTS world and orders**: add unit registry, unit types, order queues, formations, stances, patrol, guard, and explore.
6. **Debug and benchmarks**: add overlays and automated evidence scenes for 1000 x 1000 maps and thousands of units.

## Definition of done

The RTS API is good enough when a Lua game can implement a playable massive 2D RTS prototype using declarative unit types and engine-provided orders without writing custom A*, HPA, flow-field, local-avoidance, or formation-slot algorithms.