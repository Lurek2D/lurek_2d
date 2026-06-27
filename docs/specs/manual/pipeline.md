# pipeline manual spec overlay

## TL;DR

- Orchestrates steps using validated dependency graphs.
- Supports parallel groups, branch conditions, delays, retries, and output-slot routing.
- Runs synchronously or asynchronously with step reports.

## Summary

- The `pipeline` module is the engine's workflow-orchestration surface for users who want multi-step processing to behave like explicit directed workflows instead of loosely nested call sequences.
- Its core value is that staged work becomes data. Steps, dependencies, scheduler policy, inputs, outputs, and result handling can be represented and advanced as pipeline state rather than hidden inside bespoke control flow.
- DAG structure matters because many real workflows are dependency-aware rather than purely linear: some work can run only after prerequisites complete, while other work may branch, fan out, or proceed in parallel.
- That makes the module useful for asset processing, validation chains, analytics jobs, build-like tasks, scripted tool workflows, content transforms, and other domains where several operations must be coordinated explicitly.
- Scheduler logic is important because a pipeline must decide when steps are eligible, blocked, complete, retried, or failed instead of merely storing a list of actions.
- Result handling matters for the same reason. Multi-step workflows usually need explicit output capture, pass-through state, intermediate artifacts, and error-aware progression rather than simple immediate returns.
- Each step is a process block, not a logistics node. A callback can receive arbitrary Lua input data, keep local Lua state, return up to five output slots, and let configured output links forward data to later blocks.
- Signal routing and data routing are separate. A completed block can signal another block without meaningful payload data, forward payload data without being the only structural dependency, or gate either behavior with Lua conditions.
- Output links make branching and fan-out explicit: one source can send slot 1 to one target, slot 2 to another target, and suppress a target entirely when a predicate rejects the payload.
- Tool-facing workflows benefit when those stages stay inspectable instead of becoming a black box.
- The module therefore gives users a stable vocabulary for reasoning about staged work, dependency flow, and execution state instead of accidental nested control structure.
- Read `pipeline` as the engine feature for explicit staged workflows with clear execution semantics.
- Do not read `pipeline` as the resource-network simulation owner. `flownet` owns graph logistics, capacities, queues, routing, and item movement; `pipeline` owns flexible process execution and block orchestration that may optionally be driven by data from a graph.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Edge/Integration group rather than absorb behavior owned by those neighbors.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
