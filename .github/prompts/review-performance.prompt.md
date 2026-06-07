---
name: review-performance
description: Review performance using tools/audit/perf_regression_gate.py.
---

# GOAL
- Analyze the engine for performance regressions and optimize hot paths.

# INPUTS REQUIRED
- Target module or scenario
= User triggers a performance audit
- Agent must collect profiling data and baseline metrics

# STEPS TO DO
1. Load skills: performance-profiling.
2. Execute `python tools/audit/perf_regression_gate.py`. Identify the number of tests failing the performance baseline (e.g. taking >16.6ms per frame).
3. Use `cargo flamegraph` to pinpoint bottlenecks in the failing areas.
4. Implement optimizations in the Rust source code to resolve the bottlenecks.
5. Execute `python tools/audit/perf_regression_gate.py` again. If the number of failing benchmarks is >0, return to step 3 and apply further optimizations.

# OUTPUTS PROVIDED
- Performance optimization code changes
- Before/after performance metrics report

# SUCCESS CRITERIA
- `python tools/audit/perf_regression_gate.py` exits with code 0 (exactly 0 performance regressions detected).

# ANIT PATTERNS
- Micro-optimizing non-critical paths while ignoring major algorithmic bottlenecks.
- Breaking architectural boundaries to achieve a minor speedup.

# REFERENCES
- skills: performance-profiling
- tools: python tools/audit/perf_regression_gate.py, cargo flamegraph
- agent: Verifier
