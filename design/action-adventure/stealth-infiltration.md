# Stealth Infiltration

**Category:** Action adventure  
**Reference games:** Metal Gear 2: Solid Snake, Monaco, Mark of the Ninja, Gunpoint  
**Document type:** Technical game design and architecture

## Design target

A 2D stealth game where the player studies patrols, manipulates visibility and sound, avoids alarms, uses tools, and completes objectives. The game succeeds when detection is fair, readable, and debuggable.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Level layout | `lurek.tilemap`, `lurek.tilefield`, `lurek.light` |
| Patrol and route logic | `lurek.pathfind`, `lurek.ai` behavior trees/FSMs |
| Player and guards | `lurek.ecs`, `lurek.animation`, `lurek.audio` |
| Vision/sound feedback | `lurek.render`, `lurek.effect`, `lurek.particle`, `lurek.ui` |
| Objectives and alarms | `lurek.signal`, `lurek.scene`, `lurek.save` |

## Runtime architecture

Define stealth as perception data, not as magic booleans. Guards have vision cones, hearing radius, alertness, suspicion meter, last-known-position, current patrol node, and investigation target. The player emits stimuli: footsteps, sprint noise, thrown object, opened door, visible body, camera interruption.

Perception should produce events: saw target, heard noise, lost target, confirmed alarm, found body. AI consumes those events and changes state: patrol, suspicious, investigate, combat, search, return. This makes debugging possible and allows UI to visualize why a guard reacted.

The map stores blockers for movement and sight separately. Lighting can modify visibility, but the actual detection score should be computed by a perception service that returns explainable factors: distance, angle, cover, light, motion, disguise, and obstruction.

## Suggested project structure

```text
my_stealth/
  data/levels/museum.ldtk
  data/guards.toml
  data/tools.toml
  scripts/systems/perception.lua
  scripts/systems/stimuli.lua
  scripts/systems/alarms.lua
  scripts/ai/guard_fsm.lua
  scripts/ui/awareness_overlay.lua
  scripts/state/objectives.lua
  assets/guards/
  assets/fx/
```

## Vertical slice acceptance

One level should include patrol paths, crouch/sprint noise difference, hiding zones, thrown distraction, locked door, camera or guard cone, suspicion meter, alarm state, objective extraction, and post-mission summary.

## Risks

The biggest risk is unfair detection. Always expose detection reasons in debug mode and tune from event logs. Players can accept failure when the system communicates cause and timing clearly.
