---
name: review-performance
description: "Review performance using tools/audit/perf_regression_gate.py."
---
# review-performance

## Goal
- Analyze the engine for performance regressions and optimize hot paths.

## Required inputs
- Target module or scenario
- User triggers a performance audit
- Agent must collect profiling data and baseline metrics

## Profile hint
- `reviewer`

## Read these contracts
- `.codex/AGENTS.md`
- `tools/audit/AGENTS.md`
- `work/AGENTS.md`

## Steps
- Read the listed contracts and stay in read-only mode.
- Run `python tools/audit/perf_regression_gate.py` on the selected scenario and capture the baseline report.
- If the scenario needs a flamegraph or deeper profiling, capture it in `work/` with `cargo flamegraph` and compare the hotspot to the regression gate output.
- Record findings first, with severity and exact file or line evidence where possible.
- Return a binary accept or reject decision with explicit follow-up gate conditions.

## Outputs
- Findings-first review report
- File and line evidence
- Accept or reject decision with follow-up conditions

## Success criteria
- The review stays read-only unless the user explicitly expands scope to include fixes.
- The output lists concrete findings and an explicit gate condition.
- The decision is binary and supported by evidence.

## Stop conditions
- Do not mutate source or write tests during pure review work.
- Do not return vague opinions without file-backed evidence.
- Do not merge review and implementation into the same pass unless the user explicitly asks for both.

## References
- `contracts: .codex/AGENTS.md, tools/audit/AGENTS.md, work/AGENTS.md`
- `tools: python tools/audit/perf_regression_gate.py, cargo flamegraph`
- `agent: reviewer`


