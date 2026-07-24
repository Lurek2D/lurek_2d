---
name: review-quality
description: "Load this skill when auditing overall repo quality, hotspots, contract drift, and tool-reported quality findings. Skip it for narrow module implementation tasks with clear requested edits."
---

# review-quality

## Mission
- Audit overall quality signals and convert tool findings into fixable owner-scoped work.

## Domain Knowledge
- `quality_report.py` aggregates repository quality signals for triage.
- One root defect can appear in coverage, docs, wrapper, and contract reports.
- Duplicate symptoms do not count as separate root risks.
- File size and warning count are investigation hints, not defects by themselves.
- A hotspot combines broad responsibility or churn with weak ownership, missing proof, unsafe input, or contract drift.
- A large coordination module can be coherent.
- A smaller helper can be a hotspot when it mixes parsing, mutation, I/O, and presentation.
- A parser-enforced filename, marker, registry, or schema is operational contract truth.
- The nearest `AGENTS.md`, skill, template, fixture, and test must match parser behavior.
- Generated output is fixed through its canonical source or generator.
- Vendored files are not normal repository source owners.
- Test fixtures can contain intentional invalid or old shapes.
- Compatibility shims can contain intentional duplication.
- Provenance must be checked before proposing a fix.
- A useful finding names the violated invariant, evidence, owner, consequence, and acceptance command.
- “Refactor this file” is not an actionable finding.
- Allowlists, suppressions, baselines, and compatibility exceptions can become stale.
- An exception needs a current reason and a narrow matcher.
- Total finding count can stay flat while severity and ownership get worse.
- Quality comparison uses root-cause clusters and severity, not only totals.
- `cag_validate.py` checks CAG contracts but does not validate product behavior.
- The master quality dashboard combines docs-general, test coverage, module audit, and API validation payloads.
- Its current documentation gates are 90% for Rust items and 50% for Lua API functions.
- Its current test gates are 50% for Rust functions and 30% for Lua functions.
- Any API validation issue prevents an overall PASS.
- A child audit result with malformed JSON is reported as a tool error, not a product finding.
- Quality report exit codes distinguish pass (`0`), failed gates (`1`), and fatal report failure (`2`).
- Aggregate percentages do not replace exact owner audits for examples, tests, specs, or CAG routing.

## Workflow
1. Read root, source, and tools contracts for the requested scope.
2. Run `quality_report.py` for that scope.
3. Group raw findings by canonical source owner.
4. Merge coverage, docs, wrapper, and contract symptoms with the same root cause.
5. Exclude generated, vendored, fixture, and intentional compatibility symptoms only after checking provenance.
6. Read the enforcing parser or validator for each contract finding.
7. Compare parser behavior with the nearest guidance and tests.
8. Inspect source and proof for each hotspot candidate.
9. Score severity, confidence, breadth, and remediation cost.
10. Keep narrow, high-confidence findings.
11. Mark current-scope regressions separately from existing backlog.
12. Record invariant, exact evidence, owner, consequence, and acceptance command.
13. Inspect allowlists, suppressions, baselines, and exceptions in the same subsystem.
14. Reject exceptions without a current reason or narrow matcher.
15. Fix the canonical owner only when fixes are requested.
16. Sync parser guidance, fixtures, and tests when the contract changed.
17. Run the focused audit after each fix.
18. Run `cag_validate.py` when CAG surfaces changed.
19. Rerun `quality_report.py`.
20. Compare root-cause clusters and severity before and after fixes.
21. Inspect new findings to confirm responsibility was removed, not moved.

## References
- `contracts: AGENTS.md, src/AGENTS.md, tools/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "quality report hotspots contract drift" --profile all --limit 10, tools/python.cmd tools/audit/quality_report.py, tools/python.cmd tools/validate/cag_validate.py`
- `agent: reviewer`
- RAG: `quality report hotspots contract drift <scope>`; inspect the aggregate finding, enforcing parser/contract, canonical source owner, tests, and active exceptions.
