---
name: create-test-evidence
description: "Load this skill when creating or modifying Lua tests that produce evidence artifacts such as logs, snapshots, or golden files. Skip it for ordinary unit tests without artifacts or performance stress tests."
---

# create-test-evidence

## Mission
- Create or modify evidence tests that produce durable artifacts for public Lua behavior.
- Keep `tests/lua/evidence/test_<module>_evidence.lua` focused on behavior that its screenshot, audio, text, or JSON artifact visibly demonstrates; golden comparison remains a separate layer.

## Domain Knowledge
- Lua evidence tests live in `tests/lua/evidence/test_<module>_evidence.lua`.
- Current evidence files live under `tests/artifacts/current/<module>/`.
- Evidence proves behavior through a file that a reviewer can inspect.
- Test ownership comes from the test file and produced artifact.
- Evidence tests do not use `@covers` markers.
- Export helpers such as `image.savePNG` are sinks, not behavior owners.
- Four lines appear directly above each evidence `it()`: `Does`, `Shows`, `Artifact`, and `Why`.
- `Does` names the public behavior used by the test.
- `Shows` names the visible or recorded difference that proves it.
- `Artifact` gives the exact workspace-relative output path.
- `Why` explains value beyond normal assertions.
- Images fit spatial output, drawing, transforms, clipping, and layout.
- Structured text or JSON fits state transitions, ordering, and serialization.
- Logs fit diagnostics and event order. Logs are weak proof for visual behavior.
- Evidence writes current output. It does not update a golden baseline.
- Golden tests compare current output with a reviewed baseline.
- Baseline reseeding is a separate review decision.
- Evidence and reseed commands share `tests/artifacts/.lua_artifacts.lock`.
- Deterministic evidence fixes random seed, viewport, frame count, input sequence, assets, output order, and numeric format when relevant.
- A repeated run must recreate the same owned files.
- Blank, tiny, hidden, or unlabeled differences are not useful evidence.
- Exact pass or fail rules belong in unit tests when the behavior also needs assertions.
- Rationale lines use the exact forms `-- Does:`, `-- Shows:`, `-- Artifact:`, and `-- Why:`.
- Evidence files do not use the legacy `-- @evidence` marker.
- One public module has one owning evidence file when its owner is known.
- Committed comparison files live under `tests/artifacts/baselines/`, never under `current/`.
- The only Lua artifact root is `tests/artifacts/`; parallel output roots are contract violations.
- Runnable evidence files end with one bare `test_summary()` as their last non-empty line.

## Workflow
1. Read `tests/AGENTS.md` and `tests/lua/AGENTS.md`.
2. Run evidence and non-unit coverage audits for the target module.
3. Choose one public behavior that needs human-visible proof.
4. State the exact difference a reviewer must see.
5. Inspect existing evidence tests, current files, and baselines for the module.
6. Choose an image, structured text, JSON, or log that directly shows the difference.
7. Fix every input that can make output vary between runs.
8. Design a small scene or data set with labels, reference marks, or control values.
9. Add `Does`, `Shows`, `Artifact`, and `Why` directly above the new `it()`.
10. Write the test in `tests/lua/evidence/test_<module>_evidence.lua`.
11. Write only to a descriptive file under `tests/artifacts/current/<module>/`.
12. Do not add `@covers` and do not write a baseline.
13. Run the test through the canonical command that uses the artifact lock.
14. Open the artifact and inspect the actual proof.
15. Reject blank frames, hidden differences, unreadable values, and exporter-dominated output.
16. Run again after removing only this test's current output.
17. Run once more without cleanup and confirm deterministic owned files.
18. Run evidence contract and non-unit coverage audits.
19. Add a separate unit test when the behavior also needs an exact assertion.
20. If golden comparison is required, compare current and baseline before reseeding.
21. Record why an accepted baseline change is intentional and rerun comparison.

## References
- `contracts: tests/AGENTS.md, tests/lua/AGENTS.md, lurek_2d_content/games/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "Lua evidence tests golden artifacts" --profile game --limit 10, tools/python.cmd tools/audit/lua_nonunit_test_coverage.py --category evidence, tools/python.cmd tools/audit/lua_evidence_golden_contract_audit.py, tools/python.cmd tools/audit/golden_test.py`
- `agent: tester`
- RAG: `Lua evidence tests golden artifacts <module>`; inspect the evidence owner, current artifact, baseline/comparator when applicable, artifact lock, and exporter helper.
