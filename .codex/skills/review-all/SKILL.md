---
name: review-all
description: "Load this skill when running a coordinated audit and fix sweep across API, docs, examples, performance, quality, specs, and tests. Skip it for single-area reviews where a narrower review skill is enough."
---

# review-all

## Mission
- Coordinate review skills, aggregate findings, and route fixes to the correct existing owner profile.

## Domain Knowledge
- `review-all` coordinates API, tests, examples, specs, docstrings, architecture, performance, and quality reviews.
- A broad review still needs a named subsystem, module set, or change set.
- One root defect has one primary finding. Related doc, test, and example drift belongs under it.
- Rust module code owns engine behavior.
- `src/lua_api/` owns the public Lua boundary and Lua conversion rules.
- Generated API data provides the canonical public symbol inventory.
- Specs, examples, and tests describe or prove the same public behavior.
- Architecture docs own durable boundaries, state ownership, lifecycle, and dependency direction.
- `quality_report.py` aggregates quality findings. It does not replace focused review tools.
- `perf_regression_gate.py` reports performance regression evidence.
- `cag_validate.py` checks CAG file shape and limits.
- Severity depends on reachable wrong behavior, data loss, security risk, compatibility break, and regression breadth.
- Missing docs or tests are lower severity unless they hide or permit a behavior defect.
- A tool result is a lead until source, reproduction, or artifact evidence confirms it.
- Findings outside the declared scope are recorded as existing debt.
- Public aliases and userdata methods remain separate inventory entries when the generated inventory lists them separately.
- Lua input, file input, and imported data are hostile-input boundaries.
- Size and depth limits must apply to every constructor, import, and restore path that can create the same state.
- A failed callback or later validation step must not leave a partially changed public object.
- Fix ownership follows the root cause, not the file where the symptom appears.
- The registered `reviewer` profile is read-only; implementation fixes move to the narrow owning profile.
- `quality_report.py` gates Rust docs at 90%, Lua API docs at 50%, Rust tests at 50%, and Lua tests at 30%.
- The aggregate quality gate also requires zero API validation issues.
- Quality report exit code `1` means a failed gate; exit code `2` means the report itself failed.
- Exact example and Lua unit ownership audits are stronger evidence than aggregate percentage fields.
- Domain ownership and active skill coverage are checked separately by `cag_coverage.py --require-workspace`.

## Workflow
1. Read root, tools, and `.codex` contracts.
2. Define the reviewed modules, public namespaces, changed files, and excluded areas.
3. List the generated outputs and consumers affected by that scope.
4. Create one review ledger with risk theme, evidence, owner, severity, and status.
5. Use RAG to locate canonical owners and focused audit commands.
6. Run API and behavior review first.
7. Run test review against the confirmed public behavior.
8. Run example review against the canonical generated inventory.
9. Run spec and docstring review against source and bindings.
10. Review architecture only for durable boundary or lifecycle impact.
11. Run performance review when hot paths, limits, allocation, or load changed.
12. Add hostile, dense, sparse, empty, and limit cases when inputs or storage are involved.
13. Reproduce tool findings in source, a focused test, or an artifact.
14. Merge duplicate observations under one root cause.
15. Separate current-scope regressions from existing debt.
16. Assign each root cause to its narrow skill and registered owner.
17. Apply fixes only when the review request includes fixes.
18. Rerun the exact failing check after each focused fix.
19. Regenerate and validate downstream artifacts owned by the changed source.
20. Run `quality_report.py` after focused checks pass.
21. Run `perf_regression_gate.py` and `cag_validate.py` when relevant.
22. Compare the final ledger with the initial scope and list any unverified risk.

## References
- `contracts: AGENTS.md, tools/AGENTS.md, .codex/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "review audits quality performance specs tests" --profile all --limit 10, tools/python.cmd tools/audit/quality_report.py, tools/python.cmd tools/audit/perf_regression_gate.py, tools/python.cmd tools/validate/cag_validate.py`
- `agent: reviewer`
- RAG: `review audits API docs examples performance specs tests`; inspect the scoped owners, generated inventory, focused audit tools, and downstream artifacts named by findings.
