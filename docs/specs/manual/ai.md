# ai manual spec overlay

## TL;DR

- Orchestrates agent choices via behavior trees, FSMs, GOAP, HTN, and utility AI.
- Interprets sensory perception, internal state, goals, plans, and action-selection models.
- Tracks squad coordination, trait-driven emotional motives, needs, and dramatic pacing.
- Consumes learned policies only through explicit `learning` integration points; ML/RL constructors live under the `learning` module.
- Controls dramatic pacing waves and optimizes runtime budgets with distance-based LOD tiers.

## Summary

- The `ai` module is the engine's gameplay-intelligence surface for users who need actors to perceive, decide, coordinate, and adapt in ways that go far beyond hard-coded if-then behavior.
- Its defining characteristic is breadth of decision models. The module deliberately supports behavior trees, finite state machines, utility scoring, GOAP, HTN, Monte Carlo Tree Search, and related helpers so a single project can choose the right reasoning style for each actor type or gameplay layer.
- That breadth matters because game AI is rarely solved by one universal algorithm.
- Reactive control and deliberative planning are both first-class here. An actor can respond immediately through short-horizon stateful logic while also relying on planning, utility, or hierarchical decomposition for larger goals and longer-term behavior.
- The module is therefore not only about selecting an action. It also models the internal information that makes action selection meaningful: perceptions, remembered stimuli, blackboard facts, needs, emotions, traits, alertness, and contextual world knowledge.
- Perception support is especially important because believable decisions depend on what an agent knows, not only on what the world objectively contains. Vision, hearing, custom stimuli, awareness memory, and alertness tracking all shape what options the actor should consider.
- This makes the AI contract more realistic and more debuggable. Instead of a hidden boolean like “sees player,” the module encourages explicit sensory interpretation that can be inspected, tuned, and reused across several behavior styles.
- Needs, drives, and emotional-style state broaden the feature beyond combat logic. They make the module useful for simulation actors, companions, social agents, or director systems where behavior depends on internal pressure as much as on external threats.
- Blackboard-style context storage and shared decision data matter because larger AI systems usually need stable intermediate state. Several subsystems may contribute facts, priorities, or targets, and the module provides a shared surface for that internal coordination.
- Movement-side helpers are deliberately owned by `pathfind`. Steering stacks, context steering, ORCA-style local avoidance, flow fields, and influence maps live there so navigation and tactical space analysis have one public owner.
- Squad support extends the module from isolated actors to coordinated groups. Shared group state and coordinated command handling make it possible to express teams or patrols, while pure movement and local-avoidance execution stays in `pathfind`.
- Command queues are important because AI output is often not the final physical action. A stable queue boundary separates “what the AI wants next” from “what the actor is currently doing,” which helps with interruption, inspection, and synchronization with animation or movement systems.
- Director-style pacing support shows that the module also thinks beyond single actors. Encounter rhythm, phase pressure, tension, spawn pacing, and other orchestration behavior can be represented here when the “agent” is really the game experience itself.
- Level-of-detail and update-policy support matter for scale. Large groups of intelligent actors can become expensive quickly, so the module includes ways to throttle, schedule, or simplify updates without abandoning the common behavior vocabulary.
- Debug rendering and inspection support are essential for real use. Visualizing state machines, behavior trees, perception ranges, chosen targets, or queue contents shortens the path from “the agent behaved strangely” to “here is the exact internal reason.”
- The module is useful for enemies, companions, neutral populations, strategic directors, simulation agents, crowd coordinators, and any feature where behavior should be data-driven, inspectable, and scalable rather than buried in one-off control code.
- Machine-learning, reinforcement-learning, bandit, neural-network, genetic, and neuroevolution constructors are not owned here. Those belong to `learning`; `ai` may consume their outputs through explicit integration but must not duplicate their public API.
- Neighboring modules still matter, but the boundary is clear. `pathfind` owns route search, influence maps, steering, and local avoidance; `physics` defines motion and collision semantics; and `render` visualizes results, while `ai` owns the reasoning structures, internal drives, sensory interpretation, and coordination layers that decide what to do.
- The breadth of the spec is intentional because modern game AI is an ecosystem. Perception, memory, scoring, planning, execution intent, and group coordination all reinforce one another, while movement execution uses the neighboring `pathfind` surface.
- That ecosystem view also improves authoring. Teams can mix authored logic, tactical heuristics, and simulation-like drives within one runtime surface instead of treating each behavior family as an isolated special case.
- It also helps debugging stay on one common reasoning vocabulary.
- That common vocabulary matters once several actor types share a world.
- The module is therefore not only about smarter enemies; it is also about giving complex runtime behavior a legible structure that can be tuned, debugged, and scaled over the lifetime of a project.
- For wiki readers, the key takeaway is that `ai` is not one algorithm or one enemy helper. It is the engine's full runtime toolkit for building decision-rich actors whose perception, planning, movement, group behavior, and debugging story are treated as one coherent feature family.

This module primarily collaborates with `dialog`, `image`, `learning`, `patterns`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
