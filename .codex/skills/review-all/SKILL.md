---
name: review-all
description: "Load this skill when running a coordinated audit and fix sweep across API, docs, examples, performance, quality, specs, and tests. Skip it for single-area reviews where a narrower review skill is enough."
---

# review-all

## Mission
- Coordinate review skills, aggregate findings, and route fixes to the correct existing owner profile.
- Include hostile-input bounds, cross-module ownership, file-level docs, and security evidence in the aggregate findings.

## Domain Knowledge
- A coordinated review is an evidence merge across API, tests, examples, specs, docstrings, architecture, performance, and quality—not eight independent reports. One root defect should have one primary finding with downstream drift attached.
- Severity is driven by user impact, exploitability/data loss, reachable incorrect behavior, and regression breadth; missing prose or coverage inherits higher severity only when it conceals or permits a behavioral defect.
- Cross-layer consistency follows the repository chain: Rust owner and Lua boundary define behavior, generated API data names it, specs/examples/tests describe or prove it, and architecture records only durable system implications.
- Stateful grid reviews require an explicit invariant matrix covering authoritative versus derived state, dense/sparse bounds, checked coordinate/size arithmetic, dirty-region propagation, serialization compatibility, importer budgets, and downstream render recomputation.
- Tilemap and tileset form a coupled boundary: local/GID conversion, atlas arithmetic, provider/import limits, compatibility aliases, catalog/snapshot semantics, animation cleanup, and finite numeric validation must agree across both owners.
- A broad review remains bounded by a declared subsystem and change surface; unrelated pre-existing debt is recorded separately so it does not obscure the verdict on the requested scope.
- Security and hostile-input findings should be traced from Lua/file/import boundaries into allocation, mutation, serialization, and diagnostics. A limit documented only in one wrapper is insufficient when alternate constructors or restore paths bypass it.
- Codec reviews must verify encoded-input, decompression-output, aggregate-frame/layer, and multiplied-work budgets; Lua saves must use the filesystem policy rather than direct host writes.
- Compatibility namespaces must identify one canonical owner, and callback or multi-step mutations must be transactional when a later step can fail.
- Sprite-like indexed APIs must declare one-based or zero-based semantics at every boundary; reject zero where one-based, bound parser/input work, validate supplied resources, and require deterministic map exports.
- Correctness review should include negative space: teardown, empty inputs, repeated initialization, partial failure, stale handles, and compatibility reads. These paths commonly escape feature-oriented examples and happy-path tests.
- Feature-gap findings are valid only when the surrounding architecture clearly intends the capability and a missing piece blocks a real workflow; speculative enhancements should not be mixed with defects or contract drift.
- Documentation and test deficiencies should be connected to the behavior they fail to explain or prove. A generic missing-doc finding is lower value than identifying an undocumented snapshot/live-state distinction that causes incorrect callers.
- Owner overlap is itself a review dimension: duplicated caches, mirrored constants, conversion helpers, and aliases can cause drift even when each local implementation passes its own tests.
- Evidence quality must be assessed across tool output, direct source inspection, focused reproduction, and artifact review. Tool findings that cannot be reproduced or tied to an invariant remain leads, not final findings.

## Workflow
- Establish scope and a review ledger before running tools: changed modules, public namespaces, generated dependents, risk themes, owner profiles, and baseline commands. Use RAG to locate owners and select only the narrow review skills needed for that surface.
- Run in dependency order—API/behavior, tests, examples, specs/docstrings, architecture, performance, then aggregate quality—feeding earlier facts into later checks; add hostile-input and bounded dense/sparse cases when storage/import/render boundaries are involved.
- Normalize every observation into evidence, affected owner, severity, confidence, and downstream artifacts; merge duplicates by root cause, distinguish current-scope regressions from backlog, and stop broadening once each declared risk theme has a verdict.
- If fixes are authorized and the profile can edit, route each root cause through its narrow owning skill, rerun the exact failing check plus impacted downstream generators/tests, then produce a residual-risk summary; otherwise hand off exact files, commands, and acceptance criteria to registered owners.
- Establish explicit review checkpoints for hostile input, correctness, resource lifetime, performance ceilings, API usability, docs/spec truth, example teaching value, and test sensitivity; mark each as passed, failed, or not applicable with evidence.
- For high-risk findings, reproduce through the narrowest public path and one internal seam where available, separating boundary-validation failure from domain-state failure before assigning the owner.
- After fixes, rerun the broad quality aggregate only after focused checks pass, then compare the final ledger to the initial one to detect displaced findings, new generated drift, or scope that remains unverified.

## References
- `contracts: AGENTS.md, tools/AGENTS.md, .codex/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "review audits quality performance specs tests" --profile all --limit 10, tools/python.cmd tools/audit/quality_report.py, tools/python.cmd tools/audit/perf_regression_gate.py, tools/python.cmd tools/validate/cag_validate.py`
- `agent: reviewer`
- RAG: Use when scoping a broad audit before reading many files; `review audits quality performance specs tests`; `api docs examples specs drift`; `quality report perf regression validation`; `docs/`; `tests/`; `tools/audit/`; touched owner paths from findings
