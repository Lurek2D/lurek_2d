# IDEA.md — `patterns` module

> No `ideas/features/` file. Assembled from `src/patterns/` directory listing.
> This is a Foundations-tier pure-Rust utility library — no Lua exposure, no external deps.
> Lua namespace: N/A.

---

## Purpose

Reusable game-programming pattern implementations shared across engine modules.
All types here are pure data structures and algorithms with no render/audio/input
dependencies.

---

## Implemented Types

| File                 | Contents                                       |
| -------------------- | ---------------------------------------------- |
| `blackboard.rs`      | Typed string→value store (shared AI state)     |
| `collections.rs`     | Utility collections (see also specific files)  |
| `command_stack.rs`   | Undo/redo command stack                        |
| `event_bus.rs`       | In-process typed event pub/sub                 |
| `factory.rs`         | Factory trait + registry map                   |
| `funnel.rs`          | Multi-input fan-in aggregator                  |
| `mediator.rs`        | Mediator pattern for decoupled module comms    |
| `object_pool.rs`     | Reusable pre-allocated object pools            |
| `observer.rs`        | Observer pattern (typed callbacks list)        |
| `priority_queue.rs`  | BinaryHeap priority queue wrapper              |
| `ring.rs`            | Fixed-size ring buffer                         |
| `service_locator.rs` | Service locator (runtime dependency injection) |
| `simple_state.rs`    | Simple enum-based state machine                |
| `state_machine.rs`   | Full push-down automata state machine          |
| `strategy.rs`        | Strategy pattern (swappable algorithm)         |
| `throttle.rs`        | Rate limiter / throttle utility                |

---

## Gaps / Ideas

### 🔇 LOW — Merge `observer.rs` and `event_bus.rs`
**Source**: Design clarity

Both implement pub/sub. `observer.rs` = synchronous callback list.
`event_bus.rs` = possibly deferred/queued. If not functionally distinct, consolidate.
