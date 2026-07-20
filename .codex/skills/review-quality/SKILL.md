---
name: review-quality
description: "Load this skill when auditing overall repo quality, hotspots, contract drift, and tool-reported quality findings. Skip it for narrow module implementation tasks with clear requested edits."
---

# review-quality

## Mission
- Audit overall quality signals and convert tool findings into fixable owner-scoped work.

## Domain Knowledge
- `quality_report.py` is a triage aggregator whose signals may overlap; one source defect can appear as docs, coverage, thin-wrapper, and contract findings and should not be counted as four independent risks.
- Quality hotspots combine churn or breadth with weak ownership, missing proof, unsafe boundaries, or tool-reported drift. File size and warning count alone are prioritization hints, not findings.
- Contract drift is highest value when a parser/tool enforces one shape while the nearest `AGENTS.md`, skill, template, or examples teach another; the parser is operational truth and the guidance set must converge on it.
- Generated output, vendored content, intentional compatibility shims, and test fixtures need provenance-aware filtering so remediation targets the source owner instead of symptoms.
- A fixable quality item names the violated invariant, evidence, owner subsystem, user/developer consequence, and a bounded acceptance command; broad “refactor” advice is not actionable.
- Hotspot review should distinguish essential coordination modules from accidental responsibility accumulation. A central runtime file can be large yet coherent, while a smaller helper may improperly combine parsing, mutation, I/O, and presentation.
- Suppression mechanisms, allowlists, baselines, compatibility exceptions, and ignored generated files are quality surfaces because stale exceptions can conceal newly reachable defects or permanently exempt the wrong owner.
- Quality trends matter when reports preserve historical categories: a stable total can hide severe findings replaced by many minor cleanups, so compare category and owner movement rather than only aggregate counts.

## Workflow
- Run the quality report for the requested scope and cluster raw signals by canonical source owner, suppressing generated/vendor symptoms and merging repeated manifestations before reading hotspot code.
- Validate each candidate against the enforcing parser, nearest contract, source behavior, and existing tests; score severity, confidence, breadth, and remediation cost, then select narrow high-confidence items rather than maximizing finding count.
- Report each retained item with violated invariant, exact evidence/path, downstream symptoms, responsible registered owner, acceptance command, and whether it is current-scope regression or pre-existing backlog.
- If fixes are authorized, repair the canonical owner and synchronized guidance/tests, rerun the focused audit and aggregate report, and confirm that disappearance of one signal did not merely move the drift to another generated surface.
- Review active allowlists and baselines touching the selected subsystem, requiring a current rationale and narrow matcher for each exception before treating the report as complete.
- Compare post-fix findings by root-cause cluster and severity distribution, not just total count, and inspect any newly appearing owner to catch a remediation that shifted responsibility instead of removing debt.

## References
- `contracts: AGENTS.md, src/AGENTS.md, tools/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "quality report hotspots contract drift" --profile all --limit 10, tools/python.cmd tools/audit/quality_report.py, tools/python.cmd tools/validate/cag_validate.py`
- `agent: reviewer`
- RAG: Start with: `quality report hotspots contract drift`, `review audits quality performance specs tests`, `review quality report hotspots`; Focus areas first: `tools/audit/`, `tests/`, `docs/`, `src/`, root `AGENTS.md`
