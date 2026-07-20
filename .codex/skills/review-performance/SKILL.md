---
name: review-performance
description: "Load this skill when auditing performance regressions, baselines, and stress/perf reports before deciding fixes. Skip it for functional testing without performance evidence."
---

# review-performance

## Mission
- Audit performance data, identify regressions, and route or apply fixes with validation evidence.
- Require module-specific allocation/work ceilings and evidence that downstream consumers can process dirty updates proportionally.

## Domain Knowledge
- Performance findings require a controlled comparison: identical release profile, workload, warm-up, dataset/seed, machine context, thresholds, and metric. A slow absolute number without a baseline is not a regression.
- Frame time, throughput, allocations, peak memory, serialized size, and work amplification answer different questions; choose the metric tied to the user-visible risk before inspecting implementation.
- Stateful grid costs are shaped by representation and propagation: dense versus sparse storage, dirty-region size, reverse indexes, snapshots, culling, animation catch-up, import/decompression, and downstream recomputation must be measured separately.
- Tilemap workloads need dense layers, sparse negative-coordinate chunks, bounded rectangle edits, reverse-index rebuilds, animation, serialization/import, and renderer snapshot cases; tileset needs provider parsing, catalog cloning, sorted export, atlas lookup, and autotile access.
- A threshold should encode an architectural budget or historical envelope, not one noisy run. Median/tail behavior and repeated samples matter when timing is the oracle; deterministic counts are preferable where available.
- Optimization is incomplete when it changes error behavior, compatibility, or memory ceilings; functional and stress contracts remain part of the performance verdict.
- Derived caches should be charged to the operation that invalidates or rebuilds them, not only the later read that happens to trigger work; lazy behavior can move cost across frames and mislead attribution.
- Import, export, and restore paths need separate peak-memory analysis because temporary decoded buffers or duplicated snapshots may exceed steady-state storage even when final structures fit their limits.

## Workflow
- Define the hypothesis and measurement protocol before broad reads, capture a release baseline through the perf gate/stress report, and save raw scenario parameters/results under `work/<short-chat-name>/` with warm-up and repetition details.
- Decompose the workload around the suspected owner and vary one dimension at a time—dataset shape, dirty area, consumer count, import size, frame count, or snapshot frequency—using allocation/work counters before timing when they reveal amplification directly.
- Inspect code only after measurements localize the path; report effect size, variance, threshold, first bad scale, likely mechanism, functional risk, and exact reproducer, distinguishing product regression from benchmark noise or an unrealistic ceiling.
- If fixes are authorized, change the narrow hot path or benchmark defect, rerun the identical matrix plus functional/stress checks, and accept only gains that survive repeated release runs without increasing memory, unbounded work, or semantic drift.
- Capture at least one scaling series rather than only before/after at a single size, and inspect whether slope, fixed overhead, or threshold discontinuity changed; extrapolation from one point is not a reliable ceiling.
- Separate cold construction, warmed steady state, invalidation/update, query/read, serialization, and teardown measurements so cache benefits or deferred cleanup do not hide total lifecycle cost.
- Recheck correctness under the optimized representation with sparse/negative/boundary data and repeated teardown, then update baselines only after the new distribution is stable across repeated release runs.

## References
- `contracts: .codex/AGENTS.md, tools/audit/AGENTS.md, work/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "performance regression gate baseline" --profile engine --limit 10, tools/python.cmd tools/audit/perf_regression_gate.py, tools/python.cmd tools/audit/stress_report.py`
- `agent: reviewer`
- RAG: `performance regression gate baseline`; `stress report frame time allocation`; `perf workload threshold regression`; `tools/audit/`; `work/`; hot code paths in `src/`; performance notes in `docs/`
