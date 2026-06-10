---
name: opportunity-discovery
description: "Load this skill when mapping ideas, finding product or engine gaps, clustering opportunity signals, or ranking backlog candidates. Skip it for implementation planning, code work, or API design."
---
# opportunity-discovery

## Mission
- Own gap finding, idea clustering, and evidence-backed opportunity ranking.

## When To Load
- Review ideas/.
- Find feature or tooling gaps.
- Rank backlog candidates.
- Turn scattered notes into opportunity themes.

## When To Skip
- Implementation planning.
- Code changes.
- API design.

## Domain Knowledge
- Where to find signals in this repo: `ideas/` is the primary discovery backlog â€” scan all subdirectories. Secondary signals: `logs/quality/` for repeated lint or test failures, `tools/audit/` outputs for coverage gaps, `docs/specs/` TODO sections, and any spec file that has not been touched in many commits.
- How to cluster signals: group by affected layer. Within a layer, group by pain type: missing capability, fragile boundary, documentation gap, test gap, or tooling gap.
- How to write an opportunity card: title, evidence list, affected layer and module, estimated author impact, confidence level, and next validation action. No opportunity is complete without a validation action.
- Ranking formula: score each opportunity on / dependency cost. Impact = how many personas are affected.
- How to distinguish an opportunity from a task: an opportunity is a problem shape that could be solved multiple ways. A task is a specific solution already chosen.
- Freshness check: before generating new opportunities, run `tools/python.cmd tools/audit/test_coverage.py` and `tools/python.cmd tools/audit/doc_coverage.py`. These produce the most up-to-date gap data.
- Output shape: a ranked list where each entry has: rank, problem title, evidence, affected area, personas, confidence, validation action, and suggested next owner. Deliver as a `work/<session>/reports/opportunities.md` file, not as inline chat prose, so the planner can act on it.
## Companion File Index
- None.

## References
- ideas/
- logs/reports/
- tools/audit/
- docs/architecture/
- src/
