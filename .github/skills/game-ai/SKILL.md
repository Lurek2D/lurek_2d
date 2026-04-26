---
name: game-ai
description: "Load this skill when designing or implementing AI behaviour for game actors in Lurek2D using the lurek.ai.* API: finite state machines, behaviour trees, GOAP planners, steering behaviours, utility AI, Q-learning, squad formations, command queues, influence maps, or the shared Blackboard. Use for: enemy patrol/chase/flee, NPC decision-making, group tactics, pathfinding integration, AI testing. Skip it for general Rust AI module internals (see docs/specs/ai.md) or pathfinding algorithms (see docs/specs/pathfind.md)."
---
# game-ai

## Mission

Own the lurek.ai.* Lua API patterns: decision model selection, FSM/BTree/GOAP/Utility/Steering/Q-learning setup, Blackboard usage, squad tactics, and AI testing strategies.

## When To Load

- Choosing which AI model to use for a game actor
- Building enemy patrol, chase, flee, idle, or attack behaviour
- Designing NPC decision trees or goal-oriented planning
- Implementing group/squad tactics or formation movement
- Integrating AI agents with physics and pathfinding
- Testing AI behaviour headlessly

## When To Skip

- General Rust AI module internals → see docs/specs/ai.md
- Pathfinding algorithms → see docs/specs/pathfind.md

## Domain Knowledge

**Decision model selection — choose the simplest that fits:**

| Model | Best for | Avoid when |
|-------|---------|-----------|
| FSM | Small discrete states with clear transitions (guard: patrol→alert→attack) | >8 states — becomes spaghetti |
| Behaviour Tree | Prioritised, reusable, hierarchical actions (patrol UNTIL enemy THEN chase AND shoot) | Simple 2-3 state machines — overkill |
| GOAP | Open-ended NPC with many possible actions and goals, emergent behaviour | Real-time enemies where planning cost matters |
| Utility AI | Multi-axis decisions where multiple actions compete on scored criteria | Binary yes/no decisions — FSM is simpler |
| Steering | Smooth movement: seek, flee, arrive, wander, flock | Discrete turn-based movement |
| Q-learning | Simple adaptive agents that improve with play (tabular, discrete state space) | Large or continuous state spaces |

**AIWorld setup:** one AIWorld per scene via lurek.ai.newWorld(). All AI agents live inside the world registry.

**FSM API:** addState(name, onEnter, onUpdate, onExit), addTransition(from, to, priority, condition). Set initial state, call update(dt) each frame.

**Behaviour tree node types:** sequence (ALL children succeed), selector (ANY child succeeds), parallel (N children succeed simultaneously), inverter (child returns failure), repeater (child ran N times), succeeder (always succeeds), condition (fn returns truthy), action (fn returns "success").

**Blackboard — shared AI memory:** world-level (global, all agents read) and agent-level (local, walks parent chain on read miss). Use for sharing patrol routes, alert flags, and target positions between agents.

**Steering behaviours:** seek, arrive, wander, flee, evade, pursue, flock. Combine via "weighted" (sum forces) or "priority" (first non-zero wins). Always multiply by dt.

**GOAP:** define actions with preconditions and effects, set a goal state, planner finds action sequence. Cost function drives efficiency.

**Utility AI:** score each action on multiple axes (health, distance, ammo), highest combined score wins. Normalise axes to 0-1.

**Squad/formation:** command queue for group orders, formation shapes (line, wedge, circle), leader-follower offset patterns.

**Testing AI headlessly:** create fresh AIWorld per test, step update in a loop, assert state transitions. AI is fully available in headless Lua VM.

## Companion File Index

None — all guidance is inline.

## References

- docs/specs/ai.md — canonical Rust AI module reference
- docs/specs/pathfind.md — pathfinding algorithms reference
- content/examples/ — AI example scripts
