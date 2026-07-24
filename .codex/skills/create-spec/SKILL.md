---
name: create-spec
description: "Load this skill when authoring or updating an established module specification or manual overlay under docs/specs. Skip it for behavior changes, generated-doc refreshes, or evidence-led spec audits."
---

# create-spec

## Mission
- Keep source-backed technical specs precise when the behavior is already decided.

## Domain Knowledge
- `docs/specs/<module>.md` is generated output.
- `docs/specs/manual/<module>.md` stores hand-written intent.
- Manual overlays own `TL;DR`, `Summary`, `Notes`, and architecture links.
- Rust and binding docstrings own generated callable facts.
- `docs/meta/modules.toml` owns module paths, namespace, tier, and content owners.
- The metadata record includes the example file and Lua unit file.
- A spec records existing behavior.
- A spec does not create a new API or default.
- Lua names and table shapes must match generated API data.
- Defaults, units, limits, errors, and mutation timing must match runtime behavior.
- Userdata methods and namespace functions are separate API entries.
- Architecture links are for durable cross-module rules.
- The same metadata, bindings, and manual overlay must emit the same module spec.
- A second generator run must produce no diff.
- `docs/specs/README.md` owns the spec index and tiering guide.
- `docs/templates/SPEC_TEMPLATE.md` defines the shape of a new module spec.
- Module metadata also records the user-facing flag and plugin tier.
- Generated spec prose is never copied back into Rust docstrings.
- A missing or stale module link is a metadata defect, not manual-overlay prose.
- `docs_quality.py` checks spec and docs quality after generation.

## Workflow
1. Read the specs contract.
2. Classify the change as generated fact, metadata, manual intent, or architecture.
3. Find the source owner before editing.
4. Update Rust or binding docstrings for callable facts.
5. Update `docs/meta/modules.toml` for module mapping facts.
6. Update the manual overlay for durable intent.
7. Do not hand-edit generated spec sections.
8. Run the module spec generator.
9. Run module coverage validation.
10. Compare the result with generated API data.
11. Check the canonical example and Lua unit owner.
12. Inspect the module index and tier.
13. Run docs quality checks.
14. Run strict links when anchors or links changed.
15. Run the generator again.
16. Require a clean second run.

## References
- `contracts: docs/AGENTS.md, docs/specs/AGENTS.md, src/AGENTS.md, src/lua_api/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "module spec manual overlay generated Lua API" --profile engine --limit 10, tools/python.cmd tools/docs/gen_module_specs.py, tools/python.cmd tools/audit/lua_spec_coverage.py`
- `agent: doc_writer`
- RAG: `module spec manual overlay generated Lua API`; inspect `docs/specs/manual/`, `docs/meta/modules.toml`, bindings, and the selected module's example/test owners.
