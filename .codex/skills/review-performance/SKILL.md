---
name: review-performance
description: "Load this skill when auditing performance regressions, baselines, and stress/perf reports before deciding fixes. Skip it for functional testing without performance evidence."
---

# review-performance

## Mission
- Audit performance data, identify regressions, and route or apply fixes with validation evidence.

## Domain Knowledge
- A regression compares the same workload with a baseline.
- The release profile, warm-up, dataset, seed, machine context, metric, and threshold must match.
- One slow run without a baseline is not regression evidence.
- `perf_regression_gate.py` evaluates stored performance expectations.
- `stress_report.py` reports heavy-load scenarios and ceilings.
- Frame time measures latency per frame.
- Throughput measures completed work per time unit.
- Allocation count measures allocation pressure.
- Peak memory measures the highest live memory during a scenario.
- Serialized size measures output volume, not runtime memory.
- Work counters can expose amplification without noisy wall-clock timing.
- Timing comparisons need repeated samples and a stable statistic.
- Deterministic work or allocation counters are preferred when they answer the same question.
- Thresholds represent an accepted budget or historical range.
- Dense and sparse data shapes can have different costs.
- Dirty-region size, consumer count, snapshots, culling, catch-up, import, and recomputation are separate workload dimensions.
- Lazy caches move rebuild cost from mutation to a later read.
- Cache cost belongs to the invalidation and rebuild lifecycle, not only the read site.
- Import and restore can use temporary decoded buffers larger than final state.
- Peak import memory must be measured separately from steady-state memory.
- Performance fixes must keep functional behavior, errors, compatibility, and memory limits.
- A module baseline records workload shape, scale, metric, threshold, and release context.
- `perf_regression_gate.py` reads module analytics from `logs/data/test_analytics.json`.
- Its default baseline is `logs/data/perf_baseline.json`.
- The default gate requires stress ownership for at least 35% of modules.
- The baseline stores `stress_pct` and the average module quality score.
- The gate rejects either value when it drops by more than `0.001`.
- UI performance uses release-mode `ui_perf_tests` and `tests/artifacts/baselines/ui_perf_baseline.json`.
- UI baselines name required scenarios and a maximum accepted slowdown ratio.
- `--update-baseline` changes reviewed performance policy and is not a normal measurement flag.

## Workflow
1. Read root and performance audit contracts.
2. State the suspected regression and its user-visible effect.
3. Choose frame time, throughput, allocations, peak memory, size, or work count.
4. Define release profile, warm-up, workload, seed, repetitions, and threshold.
5. Run the performance gate and stress report before reading broad implementation.
6. Save scenario parameters and raw results under `work/<short-chat-name>/`.
7. Repeat the baseline to estimate normal variance.
8. Vary one workload dimension at a time.
9. Test sparse, dense, empty, boundary, and over-limit shapes when relevant.
10. Separate construction, warm steady state, invalidation, read, serialization, and teardown.
11. Use work and allocation counters before timing when they localize amplification.
12. Inspect source only after measurements identify the expensive path.
13. Record effect size, variance, threshold, first bad scale, and exact reproducer.
14. Separate product regression, benchmark defect, noise, and unrealistic threshold.
15. Apply a narrow hot-path or benchmark fix only when fixes are requested.
16. Rerun the identical workload matrix after the change.
17. Run functional and stress checks for the affected module.
18. Check that memory, errors, compatibility, and work bounds did not regress.
19. Repeat release measurements until the result is stable.
20. Update a baseline only after the new distribution is reviewed and accepted.

## References
- `contracts: AGENTS.md, tools/audit/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "performance regression gate baseline" --profile engine --limit 10, tools/python.cmd tools/audit/perf_regression_gate.py, tools/python.cmd tools/audit/stress_report.py`
- `agent: reviewer`
- RAG: `performance regression <module> baseline workload threshold`; inspect the perf gate/stress report, saved scenario, hot owner in `src/`, and documented budget.
