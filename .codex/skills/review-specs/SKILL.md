---
name: review-specs
description: "Load this skill when auditing and fixing module specs, generated sections, hand-written summaries, and spec coverage. Skip it for architecture prose or source docstrings without spec impact."
---

# review-specs

## Mission
- Audit and fix module specs while respecting generated-vs-hand-written section ownership.

## Domain Knowledge
- Generated module specs live in `docs/specs/*.md`.
- Durable hand-written intent lives in `docs/specs/manual/<module>.md`.
- Lua binding names and docstrings provide callable names, signatures, defaults, and errors.
- `docs/meta/modules.toml` links module metadata, namespace, source, spec, examples, and tests.
- `gen_module_specs.py` creates generated module pages.
- Generated spec pages are output, not the normal editing surface.
- A stale generated page is fixed by regeneration.
- Wrong module metadata is fixed in `docs/meta/modules.toml`.
- Wrong callable text is fixed in the binding annotation or docstring.
- Wrong durable intent is fixed in the manual overlay.
- A manual overlay contains TL;DR, design intent, invariants, important limits, and architecture links.
- A manual overlay does not copy generated function tables.
- Public signatures use Lua-observable names and table shapes.
- Rust declarations alone do not show Lua aliases, userdata methods, defaults, or fallibility.
- Every registered user-facing module maps to source, namespace, spec, example, and Lua unit owner.
- Internal or excluded modules need explicit metadata treatment.
- `lua_spec_coverage.py` checks Lua API spec ownership.
- `validate_module_coverage.py` checks module linkage.
- Spec generation order and content must stay stable for unchanged inputs.
- An unchanged second generation must create no diff.
- Unrelated page churn or unstable order is a generator defect.
- Index and tier metadata control navigation and module visibility.
- Module metadata also owns the user-facing flag and plugin tier.
- `lua_spec_coverage.py` reports both missing bound functions and stale names present only in a spec.
- Its fallback binding scan reads direct `tbl.set("name", ...)` registrations.
- The spec coverage command does not fail by default; a positive `--threshold` enables the coverage gate.
- `docs/templates/SPEC_TEMPLATE.md` is the structural source for a new manual module-intent overlay.
- `docs_quality.py` checks the generated spec set after regeneration.
- Copying generated module prose into Rust docstrings creates a source-output feedback loop.

## Workflow
1. Read docs and spec contracts.
2. Select the target module and inspect its metadata entry.
3. Run Lua spec coverage and module coverage validation.
4. Generate the selected module spec.
5. Classify each diff as stale output, metadata, binding docstring, manual overlay, template, or generator.
6. Compare public names and signatures with the generated API inventory.
7. Compare defaults, errors, limits, and table shapes with bindings and tests.
8. Compare example and unit links with their canonical owners.
9. Check the manual overlay for intent, invariants, limits, and architecture links.
10. Flag copied generated tables or implementation prose in the manual overlay.
11. Check index, tier, namespace, source path, binding path, and user-facing metadata.
12. Record module, wrong claim, authoritative evidence, true source owner, and consumers.
13. Fix only the canonical source when fixes are requested.
14. Regenerate module specs.
15. Inspect the generated page, links, anchors, and index entry.
16. Run spec coverage and module coverage again.
17. Run the generator a second time and require no diff.
18. Report generator churn separately from source or manual prose drift.
19. Hand binding facts to the API owner and manual intent to `doc_writer` when ownership differs.

## References
- `contracts: AGENTS.md, docs/AGENTS.md, docs/specs/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "module specs generated summary coverage" --profile engine --limit 10, tools/python.cmd tools/docs/gen_module_specs.py, tools/python.cmd tools/audit/lua_spec_coverage.py, tools/python.cmd tools/validate/validate_module_coverage.py`
- `agent: doc_writer`
- RAG: `module specs <module> generated summary coverage`; inspect metadata, binding/docstring sources, manual overlay, generated page, index, example, and unit owner.
