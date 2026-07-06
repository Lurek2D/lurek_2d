# 2.5D Classic RTS Design

## Design anchor

This document describes a 2D real-time strategy game in the spirit of classic macro RTS games such as Rusted Warfare, Total Annihilation, and Command & Conquer. The goal is not to clone those games. The goal is to define the Lurek2D project architecture needed for a large-unit-count, Lua-authored RTS where the world is visually and tactically 2D, but units and projectiles can still reason about altitude above the terrain.

The important design constraint is: the game remains a 2D RTS. It does not require a 3D scene graph, 3D rigid bodies, skeletal meshes, or full 3D navigation. The additional axis is a gameplay altitude layer used for flying units, ballistic projectiles, shadow rendering, collision filtering, line of sight, target clearance, and impact resolution.

## Market positioning

### Itch.io promise

A moddable 2D RTS toolkit where creators can ship compact skirmish maps with factories, tanks, aircraft, artillery, missiles, fog of war, and tactical terrain without building a full engine from scratch.

### Steam promise

A content-rich classic RTS with stable saves, AI skirmish opponents, large battles, mod-friendly data files, replayable maps, keyboard and mouse controls, minimap commands, and readable spectacle from hundreds of units and projectiles.

## Player fantasy

The player commands a base, expands across resource nodes, builds factories, creates combined-arms armies, scouts through fog of war, and wins by destroying the enemy base or completing scenario objectives. Battles should feel large and readable: ground units move across terrain, aircraft fly over obstacles, artillery shells arc over walls, missiles can overshoot or collide with targets at altitude, and explosions are visually layered with shadows and impact decals.

## Core loop

1. Start with a command unit or headquarters.
2. Scout nearby terrain and resource points.
3. Build extractors, power, factories, defenses, and radar.
4. Produce land, air, naval, and artillery units.
5. Use minimap and group commands to maneuver armies.
6. Resolve battles through target priorities, terrain, projectile arcs, air/ground separation, splash damage, and economy pressure.
7. Expand or tech up until one side wins.

## Required game systems

- Large-scale entity management for hundreds or thousands of units, projectiles, wrecks, decals, effects, and build previews.
- Grid or navmesh-backed pathfinding for ground, amphibious, naval, hover, and air movement classes.
- Fog of war, radar reveal, sonar-like reveal for water maps, and minimap overlays.
- Data-driven unit definitions for modding: movement type, footprint, collision radius, altitude envelope, weapons, build cost, build time, vision, radar, armor, damage classes, sprite sets, sounds, and death effects.
- Command system: move, attack-move, patrol, guard, stop, repair, reclaim, build, queue, rally point, transport load/unload.
- Production system with factory queues, prerequisites, tech tiers, build assist, and cancellation refunds.
- Weapon system with hitscan beams, direct-fire projectiles, homing missiles, ballistic arcs, artillery shells, bombs, torpedoes, and area-of-effect damage.
- 2.5D spatial rules for altitude, body height, terrain height, projectile arcs, target clearance, and air/ground collision filtering.
- Deterministic fixed-step simulation for gameplay logic, separated from visual interpolation.
- Save/replay-friendly state snapshots.

## Lurek2D API strategy

Use Lua as the gameplay orchestration layer and Rust-backed Lurek2D systems as the stable runtime substrate.

- `lurek.ecs`: preferred entity substrate for units, projectiles, orders, weapons, construction jobs, radar pings, decals, and temporary effects.
- `lurek.tilemap` / `lurek.tilefield`: visual tiles and gameplay cell facts such as terrain type, cost, buildability, resource spots, water, cliffs, ramps, and cover flags.
- `lurek.pathfind`: route planning per movement class. Ground and naval units should use obstacle-aware paths; air units can use simpler steering with soft avoidance.
- `lurek.physics`: collision queries, projectile sweeps, sensors, terrain interaction, and collision-layer policy. Current physics should be used for 2D XY authority, but altitude needs a dedicated API extension before true Rusted Warfare-style projectile/air behavior can be engine-owned.
- `lurek.minimap`: command surface, threat/reveal overlays, radar blips, and camera navigation.
- `lurek.ai`: skirmish AI planners, tactical target scoring, base expansion, build-order logic, and squad-level behavior.
- `lurek.save`: scenario saves, skirmish snapshots, campaign progression, user settings, and mod load order.
- `lurek.ui`: production panels, command cards, selection groups, health bars, tooltips, tech tree browser, lobby, and pause menu.
- `lurek.audio`: positional weapon sounds, alerts, UI cues, ambient battle loops, and faction voice responses.

## Current Lurek2D fit

The existing physics model already covers much of the 2D foundation needed by this design:

- Dynamic, static, kinematic, and sensor bodies are sufficient for ground footprints, triggers, walls, build blockers, projectiles, and detection volumes.
- Raycasts, overlap checks, swept circle queries, contacts, collision filtering, and CCD provide a good base for fast projectiles and collision authority.
- The 16-group world collision matrix and per-body layer/mask filters are useful for separating terrain, units, projectiles, sensors, air, water, resources, and build previews.
- Terrain, liquid, flow-field, beam reflection, projectile reflection, material, and debug-rendering APIs are useful for expressive strategy maps.

However, the current physics API appears to model only 2D position and 2D velocity. It has no first-class `z`, `altitude`, `verticalVelocity`, `heightExtent`, `terrainHeight`, or altitude-aware collision query contract. A Rusted Warfare-style RTS can fake this in Lua, but then the engine is no longer the shared spatial authority for projectiles, aircraft, ballistic impacts, shadows, and collision filtering.

## Needed implementation: 2.5D physics layer

Add an optional altitude layer to the physics subsystem. This should be explicitly 2.5D, not full 3D physics.

### Core concepts

- `x, y`: existing 2D world-space position.
- `z`: altitude above a sampled ground height in world units.
- `height`: vertical extent of the body or targetable volume.
- `groundHeight`: sampled terrain height at `(x, y)`.
- `worldZMin = groundHeight + z`.
- `worldZMax = worldZMin + height`.
- `verticalVelocity`: gameplay velocity on the altitude axis.
- `verticalGravity`: optional gravity used for shells, bombs, wreck debris, and falling aircraft.
- `clearance`: minimum altitude needed to pass over a body or terrain feature.

### Proposed Lua API

```lua
local altitude = lurek.physics.newAltitudeLayer({
  width = mapWidth,
  height = mapHeight,
  cellSize = 16,
  defaultGroundHeight = 0,
})

altitude:setCellHeight(cx, cy, 12)
altitude:getCellHeight(cx, cy)
altitude:sampleHeight(x, y)
altitude:setCellClearance(cx, cy, 24)
altitude:sampleClearance(x, y)

world:setAltitudeLayer(altitude)
world:getAltitudeLayer()

body:setAltitude(0)
body:getAltitude()
body:setVerticalVelocity(0)
body:getVerticalVelocity()
body:setHeightExtent(18)
body:getHeightExtent()
body:setAltitudeMode("ground") -- ground | airborne | ballistic | fixed
body:getAltitudeMode()
body:setVerticalGravity(-480)
body:getVerticalGravity()
body:setClearanceClass("ground") -- ground | hover | air | projectile | custom
body:getClearanceClass()
body:getWorldZRange() -- zMin, zMax
body:setAltitudeCollision({
  enabled = true,
  collideWhenSeparated = false,
  hitGroundWhenBelowTerrain = true,
})

world:queryAltitudeOverlap(x, y, radius, zMin, zMax, filter)
world:castCircle2_5d({
  x = x,
  y = y,
  z = z,
  radius = radius,
  height = height,
  dx = dx,
  dy = dy,
  dz = dz,
  filter = filter,
})

world:castBallisticArc({
  from = { x = sx, y = sy, z = sz },
  to = { x = tx, y = ty, z = tz },
  speed = 260,
  gravity = -480,
  radius = 3,
  maxTime = 4,
  sampleDt = 1 / 30,
  filter = projectileFilter,
})

world:spawnBallisticProjectile({
  owner = unitId,
  from = { x = sx, y = sy, z = muzzleZ },
  target = { x = tx, y = ty, z = targetZ },
  speed = 260,
  gravity = -480,
  radius = 3,
  splashRadius = 48,
  layer = PROJECTILE_LAYER,
  mask = UNIT_MASK | TERRAIN_MASK,
})

world:drawAltitudeDebug({
  showBodyRanges = true,
  showProjectileArcs = true,
  showTerrainSamples = true,
})
```

### Contact and hit payload additions

Altitude-aware hits should extend existing collision/query results without breaking older code:

```lua
{
  body_id = id,
  point = { x = x, y = y },
  normal = { x = nx, y = ny },
  toi = toi,
  z = impactZ,
  targetZMin = zMin,
  targetZMax = zMax,
  groundHeight = groundHeight,
  hitKind = "body", -- body | terrain | ground | expired
}
```

### Collision semantics

- XY broad phase remains 2D and uses the existing physics world.
- Altitude filtering runs after a candidate XY hit/overlap is found.
- Two bodies collide only when their vertical intervals overlap, unless a body explicitly opts into ground-only or all-altitude collision.
- Ground units have `z = 0` and collide against terrain/building footprints in XY.
- Air units can pass over ground units and low blockers when `worldZMin` is above the blocker `worldZMax` plus clearance.
- Projectiles can hit terrain when their ballistic `worldZ` becomes less than or equal to sampled terrain height.
- Splash damage can choose whether it is cylindrical, ground-projected, or spherical-in-altitude.

## RTS data model

### Unit definition

```lua
{
  id = "tank_medium",
  name = "Medium Tank",
  movement = "tracked",
  footprint = { radius = 13 },
  altitude = { mode = "ground", height = 18, clearanceClass = "ground" },
  maxSpeed = 64,
  turnRate = 4.0,
  acceleration = 180,
  health = 450,
  armor = "vehicle",
  visionRadius = 220,
  radarSignature = 1.0,
  weapons = { "cannon_75mm" },
  build = { cost = 320, time = 18, factory = "vehicle_factory" },
  sprites = { body = "tank_body", turret = "tank_turret", shadow = "tank_shadow" },
}
```

### Weapon definition

```lua
{
  id = "artillery_shell",
  type = "ballistic",
  range = 620,
  reload = 4.2,
  muzzleZ = 20,
  targetPolicy = "ground_or_structure",
  projectile = {
    speed = 260,
    gravity = -480,
    radius = 3,
    splashRadius = 56,
    damage = 140,
    damageFalloff = "linear",
    collideWith = { "terrain", "ground_units", "structures" },
  },
}
```

### Map cell facts

```lua
{
  terrain = "grass",
  movementCost = { ground = 1.0, hover = 1.0, naval = nil, air = 1.0 },
  buildable = true,
  groundHeight = 0,
  clearance = 0,
  resource = nil,
  blocksVision = false,
  radarPenalty = 0,
}
```

## Simulation architecture

### Fixed update pipeline

1. Read player and AI commands.
2. Update selection, command queues, build queues, and production.
3. Update fog/radar visibility snapshots.
4. Resolve unit steering and path following.
5. Step 2D physics or movement authority for units.
6. Step altitude layer for airborne, ballistic, falling, and fixed-height bodies.
7. Resolve projectile arcs and impact events.
8. Apply damage, splash, death, wreck, reclaim, and resource events.
9. Emit UI notifications and minimap alerts.
10. Snapshot replay/save-relevant events.

### Rendering pipeline

1. Draw terrain and decals.
2. Draw ground shadows for units and projectiles, offset or scaled by altitude.
3. Draw ground units and structures sorted by Y when needed.
4. Draw airborne units and projectiles with altitude-adjusted sprite offsets.
5. Draw explosions, trails, muzzle flashes, and smoke.
6. Draw selection rings, health bars, command lines, build previews, fog, radar, minimap, and UI.

## Vertical slice

The first playable slice should prove the 2.5D requirement, not just generic RTS control.

- One small skirmish map with ground height samples, cliffs, ramps, and resource points.
- One builder, one factory, one tank, one artillery unit, one aircraft, one turret, and one HQ.
- Ground units path around blockers.
- Aircraft pass over ground blockers and cast altitude-aware shadows.
- Artillery shells arc over low obstacles, collide with high terrain or valid target altitude, and produce splash damage.
- Direct-fire cannon projectiles use swept circle 2D checks plus altitude filtering.
- Fog of war, minimap pings, basic enemy AI, and save/load work.
- Debug overlay can show XY colliders, altitude ranges, terrain height samples, projectile arcs, and impact kind.

## Technical risks

- If altitude remains script-only, Lua systems must duplicate physics filtering, projectile collision, terrain impact, and debug visualization. That will make large RTS simulations harder to optimize and harder to keep deterministic.
- If the engine tries to solve this as full 3D physics, the feature will become too broad and conflict with the runtime-only 2D scope of the design library.
- Ballistic projectiles need deterministic sampling and a predictable maximum number of substeps to avoid frame-dependent hits.
- Large battles require stable data-oriented update patterns. The altitude layer should be cheap metadata plus query helpers, not one full rigid body per shell fragment or visual-only effect.

## Acceptance criteria for engine support

- Lua can attach altitude metadata to physics bodies without replacing existing 2D APIs.
- Lua can query and debug body altitude ranges.
- Ballistic projectile helpers can return body, terrain, ground, or expiry hit kinds.
- Altitude-aware collision filtering can be tested independently from rendering.
- Existing 2D physics behavior remains unchanged when no altitude layer is attached.
- Tests cover ground-vs-air separation, shell arc over low blockers, shell impact into high terrain, aircraft over ground units, and splash damage mode selection.
