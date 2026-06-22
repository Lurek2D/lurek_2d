# flownet manual spec overlay

## TL;DR

- Simulates directed logistics networks using node inventories, push-pull rates, and overflow policies.
- Integrates weighted transits, pathfinding, supply-demand balancing, and circular layouts.

## Summary

- The `flownet` module is the logistics-graph simulation surface for users who want resources, items, queues, routes, and transformation rules to behave as one explicit networked system.
- Nodes, edges, items, capacities, queue rules, cooldowns, transit timing, and placement semantics combine into a model where supply and processing are visible parts of gameplay rather than hidden bookkeeping.
- Logistics-heavy features depend on more than pathfinding alone. They also need ownership of where an item is, how much throughput a path supports, how congestion behaves, and how transformation steps consume and produce goods.
- Push and pull flows, reservations, demand matching, and simulation ticks make the module useful for factory loops, economy simulations, routing puzzles, and colony-style systems where movement through a graph is itself part of the game.
- Structural algorithms such as components and cycle checks keep the module useful for diagnostics and tooling.
- Visualization, serialization, and deterministic state handling make `flownet` practical for saves, tests, long-running scenarios, and bottleneck debugging where users need to explain why a network did or did not move goods.
- Reservation and throughput semantics are especially important because most logistics gameplay is really about contention. Users need to understand why an item waited, which edge saturated first, whether a consumer starved, or how competing flows were prioritized through the same network.
- Transformation support broadens the module beyond transport. Many networks do not merely move goods; they refine, combine, split, package, or otherwise convert them, so production logic has to remain visible inside the same graph model as routing.
- Simulation ticks give the system a temporal identity as well. Transit delays, cooldowns, queue progress, and staged processing make flow behavior something that evolves over time rather than resolving as an instant path query.
- That timing layer helps explain congestion.
- This makes `flownet` strong for factory chains, colony logistics, convoy simulation, resource routing puzzles, and economy layers where bottlenecks, congestion, and transformation rules are core gameplay rather than invisible backend bookkeeping.
- Read `flownet` as the owner of directed resource movement and conversion across a graph. Other systems may feed data into the network or draw conclusions from it, but this module decides how items, capacities, paths, queues, and transformations interact over time.

This module primarily collaborates with `image`, `render`, `runtime`. Its responsibility should stay inside the `Foundations` group rather than absorb behavior owned by those neighbors.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
