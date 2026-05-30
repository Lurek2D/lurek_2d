# patterns

## General Info

- Module group: `Foundations`
- Source path: `src/patterns/`
- Binding: `src/lua_api/patterns_api.rs`
- Namespace: `lurek.patterns`
- Lua API surface: `24` functions, `27` types, `218` methods
- Rust test path(s): tests/rust/unit/patterns_tests.rs
- Lua test path(s): tests/lua/unit/test_patterns_core_unit.lua; tests/lua/stress/test_patterns_stress.lua

## Summary

Designed to be highly reusable, completely decoupled from one another, and fully exposed to the Lua environment, these primitives act as high-level building blocks for complex game logic. At the core of AI decision-making is the `BehaviorTree` system, featuring Sequences, Selectors, Parallels, Inverters, Repeats, and Leaf action nodes. For transition-heavy logic, the module offers a hierarchical `StateMachine` with enter/exit/update callbacks, explicit transition rules, and bounded history, alongside a `SimpleState` alternative for simpler needs.

To facilitate decoupled communication across systems, the module provides a robust `EventBus` for pub-sub messaging with wildcard listeners and prioritized execution, as well as a channel-based `Mediator`. The `Observer` pattern is available for reactive property-change notifications, and the `Blackboard` provides a shared, typed key-value store with revision tracking—essential for coordinating AI state. For undo/redo functionality (e.g., in editors or turn-based games), the `CommandStack` offers a cursor-based linear history with batching support. Resource management is handled by the `ObjectPool`, which tracks active and idle IDs to reduce allocation churn for frequently spawned entities like bullets or particles. The `Factory` and `ServiceLocator` patterns provide dynamic object construction and dependency injection.

The module also includes specialized data structures optimized for game development. These include a `Graph` (directed/undirected with BFS/DFS traversals), a `Trie` for rapid prefix searches, a `BiMap` for bidirectional lookups, and a `PriorityQueue` with stable FIFO tie-breaking. Time-based operations are supported by a `Ring` buffer for fixed-size rolling histories (useful for telemetry or combo tracking), a `Funnel` for batching events over a time window, and `Throttle`/`Debounce` primitives for rate-limiting inputs or actions. Additionally, the `WeightedRandom` selector enables deterministic, dynamic picking with or without replacement. All these tools are instantiated via `lurek.patterns.*` and operate as standalone userdata objects, ensuring script developers have robust, C-speed architectural primitives at their fingertips.

## Files

### [behavior_tree.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/patterns/behavior_tree.rs)

- Behavior tree runtime for composing game and AI decisions as explicit node graphs that evaluate in a stable left-to-right order.
- The file provides structural node storage for sequences, selectors, parallels, repeaters, inverters, and named leaf actions without hiding execution flow behind opaque callbacks.
- It keeps build-time graph authoring and tick-time run state close together so trees can be assembled, reset, and stepped with predictable control over parent-child relationships.
- Repeat counters, running markers, and root selection live alongside compact integer node addressing, which keeps behavior updates easy to reason about and cheap to traverse.
- Functionally this file delivers the core decision backbone for scripted actors that need readable branching logic, reusable subtrees, and deterministic per-frame evaluation semantics.

### [bimap.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/patterns/bimap.rs)

- Bidirectional map storage for cases where game code must move between symbolic keys and canonical values with equal ease.
- The file maintains mirrored forward and reverse tables so each mutation preserves a single authoritative pairing instead of forcing callers to manage two separate maps by hand.
- Inserts, removals, and containment checks are shaped around keeping that two-way contract coherent even when entries are replaced or deleted from either side.
- Functionally this delivers fast reversible lookup for registries, id-name bindings, alias tables, and other systems that need symmetry rather than one-directional indexing.

### [blackboard.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/patterns/blackboard.rs)

- Shared blackboard storage for gameplay and AI systems that need a common language for state without hard-coding direct dependencies between producers and consumers.
- The file models values as a compact tagged set of common script-facing types and couples each write to revision tracking so readers can cheaply detect what changed and when.
- Parent-linked lookup lets a local board inherit broader context while still overriding specific keys, which makes squad, faction, and entity state layering practical.
- Typed getters, defaults, clears, and revision queries turn the store into more than a raw map by giving behavior code a disciplined way to read uncertain state.
- Functionally this is the coordination memory for systems that want shared facts, incremental change detection, and hierarchical fallback instead of tightly wired state plumbing.

### [collections.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/patterns/collections.rs)

- Small shared capacity metadata for collection-style pattern objects that expose bounded or unbounded behavior through one consistent rule set.
- The file centralizes count, limit, and full-state semantics so stacks, queues, and similar wrappers can agree on what capacity means without duplicating bookkeeping code.
- Functionally this delivers the lightweight policy layer behind collection limits, especially the convention that zero means unbounded while positive values enforce a hard ceiling.

### [command_stack.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/patterns/command_stack.rs)

- Command history storage for features that need explicit undo and redo flow instead of ad hoc reversal logic spread across many systems.
- The file tracks a linear timeline with a movable cursor, letting callers push new actions, walk backward through applied work, and replay discarded steps in order.
- Batch grouping keeps multi-step edits together as one logical unit, which matters for editors, tactics actions, and scripted transactions that should reverse atomically.
- Size limits and eviction rules keep history bounded without losing the current navigation model or forcing clients to hand-roll trimming behavior.
- Functionally this delivers the memory of reversible work for tooling and gameplay flows that care about chronological intent, replay, and controlled rollback.

### [event_bus.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/patterns/event_bus.rs)

- Event bus routing for decoupled gameplay communication where systems publish named signals and interested listeners react without direct caller knowledge.
- The file organizes subscriptions by event name while preserving listener identity, priority order, and wildcard reach so dispatch can stay predictable as projects grow.
- One-shot listeners, targeted clearing, and ordered listener extraction make the bus practical both for transient reactions and for long-lived system wiring.
- Rather than executing script callbacks itself, it prepares the dispatch shape that higher layers can consume while keeping subscription state authoritative in one place.
- Functionally this is the message circulation core for feature coordination, broadcast-style notifications, and low-friction cross-system signaling.

### [factory.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/patterns/factory.rs)

- Runtime factory registry for systems that construct objects by declared type names instead of hard-wiring every spawn path to concrete branches.
- The file keeps canonical names and aliases aligned so different labels can converge on the same build target while still allowing registration changes at runtime.
- Resolution, replacement, and removal are framed around keeping the name graph explicit and queryable rather than letting construction rules disappear into scattered conditionals.
- Functionally this delivers the naming and lookup backbone for data-driven spawning, pluggable content registration, and alias-friendly creation flows.

### [funnel.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/patterns/funnel.rs)

- Buffered funnel for gathering small tagged numeric events into controlled flush windows instead of reacting to every sample the instant it arrives.
- The file couples entry accumulation with elapsed-time tracking and count thresholds so callers can model batch release, burst shaping, or windowed aggregation with simple state.
- Immediate windows, manual discard, and explicit readiness checks make the behavior usable for both deterministic simulation ticks and script-driven control loops.
- Functionally this delivers a compact batching primitive for telemetry, combo capture, score staging, and other flows where grouping matters more than raw per-event immediacy.

### [graph.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/patterns/graph.rs)

- General-purpose graph structure for gameplay relationships, navigation-like topologies, and any domain that benefits from explicit nodes connected by weighted or labelled edges.
- The file stores graph state as stable integer-addressed nodes and adjacency lists, which keeps structural edits straightforward while preserving identities scripts can hold onto.
- Directed and undirected operation live behind one representation, including automatic reverse-edge behavior when a connection should semantically exist in both directions.
- Traversal helpers expose breadth-first and depth-first walks as first-class capabilities so callers can inspect reachability, discover neighborhoods, or derive ordered visits without rebuilding utility code.
- Connectivity checks, node metadata, and edge labels make the graph more than a bare container by supporting practical gameplay queries around ownership, routes, influence, or dependency webs.
- Functionally this file delivers the relational map backbone for systems that need editable topology, traversable links, and stable graph identities in script-friendly form.

### [mediator.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/patterns/mediator.rs)

- Mediator registry for coordinating communication through named channels when systems should meet through a broker rather than pointing at each other directly.
- The file assigns durable handler identities per channel so registration, removal, counting, and inspection all speak the same compact vocabulary.
- By storing channel membership centrally it becomes easy to clear one lane of traffic or reset the whole routing surface without leaking per-subscriber bookkeeping into callers.
- Functionally this delivers a message rendezvous layer for decoupled gameplay features, scripted services, and hub-style coordination flows.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/patterns/mod.rs)

- Foundational gameplay pattern toolbox that packages decision flow, state coordination, messaging, reuse, and selection primitives into small reusable building blocks.
- The module supplies behavior trees, simple and guarded state machines, observer and event distribution layers, mediator routing, factories, service lookup, and undo-oriented command history.
- It also delivers practical supporting structures such as graphs, tries, rings, priority ordering, bidirectional lookup, weighted picks, throttling windows, buffered funnels, and object reuse pools.
- At module level this is the high-level kit for assembling decoupled game logic systems in Lua and Rust without re-implementing common orchestration patterns for each feature.

### [object_pool.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/patterns/object_pool.rs)

- Object pool state for reuse-heavy systems that would rather recycle stable ids than continuously allocate and discard short-lived gameplay resources.
- The file separates idle and active membership, supports prewarming, and enforces optional capacity so callers can shape reuse policy without inventing their own lifecycle bookkeeping.
- Acquire and release flow is designed around predictable id turnover, which suits bullets, particles, temporary actors, and other bursty populations.
- Functionally this delivers the reuse scheduler behind allocation-sensitive gameplay loops that want bounded churn and explicit ownership transitions.

### [observer.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/patterns/observer.rs)

- Observer-style notification store for reactive game state where changes on named keys should wake interested listeners without binding readers to writers.
- The file keeps subscriptions grouped by key while still supporting wildcard reach, so systems can watch a narrow property or an entire stream of change events.
- Persistent and one-shot modes share one dispatch model, which simplifies lifecycle handling and ensures cleanup happens in the same place that notifications are tracked.
- Clear operations, listener ids, and stored observer entries make the structure suitable for long-running scenes where subscriptions need explicit ownership and maintenance.
- Functionally this delivers the change-broadcast layer for reactive UI, quest logic, AI memory watchers, and any flow that responds to named value transitions.

### [priority_queue.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/patterns/priority_queue.rs)

- Ordered priority queue for gameplay scheduling and selection tasks that need highest-priority work first without losing deterministic order among ties.
- The file assigns each entry its own identity and insertion sequence so queue mutation remains inspectable even when multiple items share the same score.
- Push, pop, peek, and targeted removal operate on one consistently sorted store rather than spreading priority semantics across separate containers and side maps.
- Functionally this delivers stable urgency-based ordering for task systems, AI planners, turn resolution, and any script logic that needs predictable priority arbitration.

### [ring.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/patterns/ring.rs)

- Fixed-capacity ring buffer for rolling gameplay history where the newest samples matter most but recent context still needs to remain queryable in order.
- The file stores tagged entries in arrival order and automatically evicts the oldest data once capacity is reached, keeping the window fresh without manual trimming.
- Numeric and string payload support makes the structure useful for both measured telemetry and symbolic event trails.
- Aggregate helpers and ordered iteration turn the buffer into a practical runtime history tool instead of a passive overwrite container.
- Functionally this delivers short-horizon memory for combo tracking, diagnostics, smoothing inputs, and any system that lives on a moving recent window.

### [service_locator.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/patterns/service_locator.rs)

- Lightweight service locator for runtime feature discovery when systems need to find shared capabilities by agreed names instead of direct construction paths.
- The file keeps registration, removal, lookup, and sorted listing in one compact registry so service presence stays explicit and easy to inspect.
- Functionally this delivers a simple dependency access hub for loosely coupled gameplay code, especially where availability changes during runtime.

### [simple_state.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/patterns/simple_state.rs)

- Minimal named-state tracker for systems that only need one active mode at a time without the heavier transition model of a full state machine.
- The file focuses on managing the known state set and the current selection, which keeps switching semantics explicit and validation cheap.
- Enumeration and counting support make the registry easy to inspect from scripts and tooling that want to reason about available modes.
- Functionally this delivers the lightweight mode switch core for menus, AI phases, control states, and other simple single-state flows.

### [state_machine.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/patterns/state_machine.rs)

- Full finite state machine runtime for systems that need named states, validated transitions, and a remembered trail of where control has moved over time.
- The file separates state membership from transition rules so allowed movement stays explicit and can be guarded rather than implied by arbitrary caller behavior.
- Bounded history gives each machine a replayable memory of recent changes, which is useful for debugging, analytics, and gameplay rules that depend on prior modes.
- Current-state management, rule inspection, and history maintenance live together so switching logic stays coherent instead of fragmenting across helpers.
- Functionally this delivers the structured mode-control layer for actors, encounters, UI flows, and scripted systems with meaningful transition policy.

### [strategy.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/patterns/strategy.rs)

- Strategy registry for features that swap among named behaviors or algorithms while keeping the selection surface explicit and data-driven.
- The file assigns stable ids to registered strategies and tracks which one is currently active so callers can inspect or switch policy without hidden branching.
- Registration and removal are treated as first-class operations, which fits systems where available strategies change with content, upgrades, or scripting.
- Functionally this delivers the hot-swappable behavior catalog behind interchangeable decision rules, tactics, generators, or processing modes.

### [throttle.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/patterns/throttle.rs)

- Timing control primitives for gameplay actions that should be rate-limited or delayed instead of firing on every raw input or event edge.
- The file pairs throttle and debounce behaviors in one place because both solve cadence control while differing in whether they emit immediately or only after quiet time.
- Shared state around elapsed time, enable flags, fire counts, and reset flow makes these utilities practical for per-frame ticking and script-side inspection.
- Progress queries on throttle and trigger-cancel semantics on debounce cover the two common rhythms of spaced repetition and delayed confirmation.
- Functionally this delivers the pacing layer for input smoothing, cooldown-like gates, UI chatter suppression, and event burst control.

### [trie.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/patterns/trie.rs)

- Prefix trie storage for string-centric gameplay data where whole-key lookup and shared-prefix discovery should both be fast and structurally related.
- The file models words as character paths, letting inserts and exact searches coexist naturally with prefix queries that expand into many matching keys.
- Removal includes branch pruning so the structure sheds dead paths instead of accumulating empty nodes after content churn.
- Depth-first key collection turns the trie into a practical retrieval tool for completions, dictionaries, filters, and lookup-heavy scripting workflows.
- Functionally this delivers the text-prefix indexing backbone for command palettes, content search, lexicons, and other systems built around incremental string matching.

### [weighted_random.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/patterns/weighted_random.rs)

- Weighted random selector for content and gameplay systems that want probability-driven picks while still keeping the candidate set editable at runtime.
- The file stores named weighted entries and supports structural mutation so drops, spawns, behaviors, or narrative beats can rebalance without rebuilding the container.
- It covers both single draws and multi-pick selection without replacement, which makes the same structure useful for one-off rolls and curated batches.
- Revision tracking gives outside code a reliable signal that probabilities or membership changed, helping caches and derived tables stay honest.
- Functionally this delivers the probability orchestration layer for loot tables, encounter variation, weighted choices, and repeat-aware random selection flows.
