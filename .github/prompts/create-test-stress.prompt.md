---
name: create-test-stress
description: Create or update heavy stress test for specific module and check test coverage.
---

# GOAL
- Develop stress and load tests to evaluate the performance boundaries and stability of a specific module.

# INPUTS REQUIRED
- Target module
- Expected load parameters (e.g., number of entities, iteration counts)
= User must provide the target module and acceptable performance degradation thresholds
- Agent must collect current baseline performance metrics

# STEPS TO DO
1. Load skills: testing-ecosystem, performance-profiling.
2. Execute `python tools/audit/stress_report.py` to gather current stress test ceilings.
3. Write high-volume loops or parallel execution paths that hammer the module's primary functionality in `tests/lua/stress/` or `tests/rust/stress/`.
4. Execute the stress script and monitor output. If the script causes an OOM crash or the frame time exceeds the target threshold (e.g. >16.6ms), adjust the load parameters or implement graceful degradation in step 3.
5. Re-run `python tools/audit/stress_report.py`. If the output ceiling is below the user-provided target, return to step 3.

# OUTPUTS PROVIDED
- Stress test scripts
- Performance/Stress report output

# SUCCESS CRITERIA
- Engine crash count is exactly 0 under load.
- `python tools/audit/stress_report.py` generates a report showing the load ceiling is >= the user's expected target.

# ANIT PATTERNS
- Writing stress tests that don't clean up resources, leading to artificial OOMs.
- Making stress tests part of the standard CI pipeline without isolating them.

# REFERENCES
- skills: testing-ecosystem, performance-profiling
- tools: python tools/audit/stress_report.py
- agent: Tester
