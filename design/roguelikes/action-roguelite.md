# Action Roguelite

**Category:** Roguelikes  
**Reference games:** The Binding of Isaac, Nuclear Throne, Hades as structural reference, Enter the Gungeon  
**Document type:** Technical game design and architecture

## Design target

A run-based real-time action game with procedural rooms, randomized upgrades, escalating enemies, boss encounters, and fast restart. The architecture must separate durable meta progression from per-run state.

## Market positioning

Use the reference set (The Binding of Isaac, Nuclear Throne, Hades as structural reference, Enter the Gungeon) to define player expectations around pacing, readability, and production scope, not to copy mechanics directly. Target itch.io with a short run loop, strong item identity, and readable failure feedback. Target Steam with meta progression, seeded runs, daily/challenge modes, balance telemetry, and enough encounter variety for replay-focused players. For action roguelite, the store page must communicate the core verb, session length, progression promise, and why the 2D presentation is intentional.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Room graph generation | `lurek.procgen`, `lurek.scene`, `lurek.tilemap` |
| Combat actors | `lurek.ecs`, `lurek.physics`, `lurek.animation` |
| Enemy and boss AI | `lurek.ai`, `lurek.pathfind`, `lurek.patterns` |
| Upgrades and items | `lurek.dataframe`, `lurek.serialize`, Lureksome item/stats libraries |
| Effects and juice | `lurek.particle`, `lurek.audio`, `lurek.effect`, `lurek.tween` |
| Persistence | `lurek.save` for meta unlocks, stats, settings |

## Runtime architecture

Use a `RunState` with seed, room graph, current room, player build, active enemies, pickups, temporary modifiers, and run statistics. Use a separate `ProfileState` for unlocks, currency, achievements, and options.

Rooms are generated or selected from templates. Each room declares entry doors, enemy waves, reward rules, hazards, and clear condition. The director starts a room, locks exits, spawns waves, tracks clear state, drops rewards, then unlocks transitions.

Upgrades should be modifiers applied through a stats pipeline. Avoid hard-coded item branches in combat systems. A modifier can add projectile count, change damage, alter cooldown, spawn particles, modify dash, or inject an event listener.

## Suggested project structure

```text
my_action_roguelite/
  data/rooms/*.ldtk
  data/items.toml
  data/enemies.toml
  data/bosses.toml
  scripts/state/run_state.lua
  scripts/state/profile_state.lua
  scripts/systems/room_director.lua
  scripts/systems/modifiers.lua
  scripts/systems/projectiles.lua
  scripts/ai/enemy_ai.lua
  scripts/ui/reward_choice.lua
```

## Data and content model

- Author run seed, map chunks, rooms, enemies, loot tables, events, and encounter budgets as data, not hidden script constants.
- Author player build, inventory, status effects, cooldowns, meta unlocks, and death history as data, not hidden script constants.
- Author difficulty curves, procedural constraints, challenge modifiers, and balance telemetry as data, not hidden script constants.
- Keep action roguelite content split between durable authored files under `data/`, media under `assets/`, and orchestration modules under `scripts/`.
- Save files should store player/world progress and stable identifiers, not transient render objects, cached paths, or UI widget instances.


## Technical design notes

- Use `lurek.math.newRandomGenerator` or explicit deterministic seed ownership, and store seeds in save data and run reports.
- Use `lurek.ecs` when actors, items, effects, and projectiles share update/render/component needs.
- Use `lurek.pathfind`, `lurek.ai`, and `lurek.tilefield` to keep navigation and monster decisions inspectable.
- Use `lurek.save` for meta progression and optional run suspend, not for hiding non-deterministic state.

## Vertical slice acceptance

The slice should include seeded room chain, three enemy types, one boss, ten upgrades, reward selection, death/restart loop, meta unlock flag, and run summary.

## Risks

The main risk is upgrade combinatorics. Use declarative modifiers and central conflict rules before adding many items. Every item should explain which events or stats it changes.
