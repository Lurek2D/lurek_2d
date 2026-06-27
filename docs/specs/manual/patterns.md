# patterns manual spec overlay

## TL;DR

- Provides a comprehensive architectural toolkit for state, decision, and communication coordination.
- Implements behavior trees, finite state machines, event buses, blackboards, and command stacks.
- Controls execution cadences via throttles, debounces, and reusable object pools.
- Supports graph structures, bidirectional maps, prefix tries, factories, and service locators.
- Includes practical game/data structures such as Deck/Card when they are reusable logic patterns rather than entity identity systems.

## Summary

- The `patterns` module is the engine's reusable architectural toolkit for users who want common coordination, control-flow, storage, and utility structures implemented once and then reused across gameplay, tools, UI, AI, and automation features.
- Its defining value is that it packages recurring design patterns as runtime-ready components rather than leaving them as abstract advice. A project can directly use an event bus, a behavior tree, a bounded queue, a blackboard, or a command history instead of re-deriving those ideas from scratch.
- Decision and control-flow patterns are a major part of the surface. Behavior trees, state machines, and related orchestration helpers provide stable ways to express staged logic, branching behavior, mode transitions, and rule-driven execution.
- That is useful even outside `ai`, because many systems need explicit control flow: scripted encounters, UI workflows, tool wizards, tutorial logic, job pipelines, and editor modes all benefit from the same transition-oriented vocabulary.
- Communication patterns form another large category. Event buses, mediators, observers, channels, and related coordination helpers provide different answers to how modules should publish state changes or trigger reactions without tightly coupling every producer to every consumer.
- The presence of several communication styles matters because no single coupling model fits every feature. Some systems want broadcast signals, some want centralized arbitration, and some want direct subscription with stable state propagation rules.
- Shared-state helpers such as blackboards and keyed stores are especially valuable for collaborative runtime features where several actors or subsystems need to read and write facts under shared names.
- Those shared stores are useful for AI behavior, UI workflows, tool execution state, scripted conversations, agent memory, and validation pipelines, which makes `patterns` one of the main bridges between otherwise unrelated feature areas.
- Command-history support extends the module into authoring and reversible workflows, while factories, registries, and related helpers give projects a standardized way to organize larger runtime graphs.
- The module also provides utility data structures that keep proving useful across domains: priority queues, ring buffers, tries, weighted selectors, bidirectional maps, graph containers, bounded collections, and pooling helpers.
- Object reuse and bounded collections matter because several runtime systems need allocation control, limited history, or reusable queues without wanting ad hoc versions hidden inside every feature.
- Weighted selectors, graph containers, and queue-like helpers show that `patterns` is not only about software architecture in the narrow sense. It also owns practical reusable mechanics that often sit just below game logic and tool logic but above low-level containers.
- Deck/Card lives here rather than in `ecs` because a deck is reusable game logic: it owns draw order, shuffle determinism, discard/reset behavior, and card payload handling. It does not define object identity, inheritance, components, or world membership.
- That boundary keeps `patterns` broad and domain-neutral while leaving object/class semantics to `ecs`.
- The module also helps keep terminology stable across the codebase. Several features can depend on the same ideas of event dispatch, reversible actions, orchestration, and shared state instead of each inventing slightly different local vocabulary.
- The breadth of the module is deliberate: these pieces are small enough to stay reusable, but substantial enough that reimplementing them repeatedly would fragment the rest of the engine.
- That makes `patterns` valuable not only as a library shelf, but also as a consistency layer. Several systems can solve similar structural problems without diverging in naming, behavior, or maintenance style.
- For wiki readers, the practical boundary is that `patterns` owns reusable mechanics, not end-user domain behavior. If a component could reasonably be reused by AI, UI, tooling, and automation alike, it probably belongs here rather than inside one specialized module.
- This broad but domain-neutral scope is what makes the module distinctive. `patterns` does not try to become the owner of AI, rendering, or networking itself; it supplies the architectural pieces those higher-level systems repeatedly depend on.
- That separation matters because several engine features need the same structures without importing each other's domain logic.
- It also gives long-lived projects one place to refine shared mechanics instead of letting near-duplicates drift.
- The module therefore acts like a shared vocabulary for structure. It gives different features a common way to talk about transitions, events, coordination, reversible actions, pooling, and shared facts, which improves consistency across the rest of the engine.
- Read `patterns` as the place where recurring structural ideas become concrete runtime components and shared coordination vocabulary.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Foundations group rather than absorb behavior owned by those neighbors.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
