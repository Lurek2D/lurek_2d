---
inclusion: manual
---

# opportunity-discovery

## Mission
Own gap finding, idea clustering, and evidence-backed opportunity ranking.

## When To Use
- Review `ideas/`.
- Find feature or tooling gaps.
- Rank backlog candidates.
- Turn scattered notes into opportunity themes.

## When To Skip
- Implementation planning, code changes, API design.

## Rules

### Where to Find Signals
- `ideas/` — primary discovery backlog (scan all subdirectories: `ideas/rust/`, `ideas/extension/`, `ideas/plugins/`, `ideas/simulation/`, `ideas/tests/`).
- `logs/quality/` — repeated lint or test failures.
- `tools/audit/` outputs — coverage gaps.
- `docs/specs/` TODO sections.
- Spec files not touched in many commits (drift signal).

### How to Cluster
Group by affected layer (Foundations, Core Runtime, Platform Services, Feature Systems, Edge/Integration). Within a layer, group by pain type: missing capability, fragile boundary, documentation gap, test gap, or tooling gap. One cluster = one opportunity card. Keep the title as a problem statement, not a solution name.

### Opportunity Card Format
- Title (problem statement, not solution name).
- Evidence list (file paths, audit results, or issue references).
- Affected layer and module.
- Estimated author impact (which personas: EngDev, GameDev, Modder, GameTest, EngTest).
- Confidence level (low/medium/high).
- Next validation action (what to run or read to confirm the gap).

### Ranking Formula
score = (impact × leverage × confidence) / dependency cost

- Impact = how many personas are affected.
- Leverage = how many future tasks unblock.
- Confidence = strength of evidence (audit output = high, single idea note = low).
- Dependency cost = how many other changes must land first.

### Opportunity vs Task
An opportunity is a problem shape that could be solved multiple ways. A task is a specific solution already chosen. Discovery hands off to Planner (for task breakdown) or Architect (for solution design). Do not merge phases.

### Freshness Check
Before generating new opportunities, run `python tools/audit/test_coverage.py` and `python tools/audit/doc_coverage.py`. Discovery from stale notes without checking current audit output often produces already-resolved opportunities.

### Output Shape
Deliver as `work/<session>/reports/opportunities.md`, not as inline chat prose.

## References
- `ideas/`
- `logs/reports/`
- `tools/audit/`
- `docs/architecture/`
- `src/`
