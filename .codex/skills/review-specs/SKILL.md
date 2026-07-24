---
name: review-specs
description: "Load this skill when auditing and fixing module specs, generated sections, hand-written summaries, and spec coverage. Skip it for architecture prose or source docstrings without spec impact."
---

# review-specs

## Mission
- Audit and fix module specs while respecting generated-vs-hand-written section ownership.

## Domain Knowledge
- `docs/specs/*.md` is generated; durable human intent belongs in `docs/specs/manual/<module>.md`, while signatures and callable facts originate in bindings/docstrings and module linkage in `docs/meta/modules.toml`.
- A spec review must distinguish generator freshness from source truth: a stale generated file, incorrect metadata, wrong binding annotation, and outdated manual summary require four different fixes.
- Manual overlays should capture TL;DR, design intent, invariants, notable limits, and architecture links without restating generated function tables or copying implementation prose.
- Coverage means every registered user-facing module maps coherently to source, namespace, spec, example, and Lua unit owner; intentionally excluded/internal modules need metadata-backed treatment rather than silent absence.
- Generated diffs should be deterministic and a second run clean; unexplained reordering or unrelated module churn is a generator-quality finding.
- Manual intent should explicitly call out authoritative versus derived state, compatibility guarantees, resource ceilings, and cross-module relationships when those facts govern future implementation choices.
- Signature tables must agree with Lua-observable names and table shapes, not merely Rust function declarations; userdata methods, aliases, defaults, and fallibility can be lost in a naive source scan.
- Spec index/tiering metadata affects navigation and plugin/module visibility, so a correct standalone module page can still be misclassified or undiscoverable through the repository catalog.
- Architecture links should point upward only for durable cross-module constraints; linking every implementation detail into architecture creates circular documentation ownership.
- Consume the canonical generated inventory when judging coverage and flag callable no-ops, aliases without canonical ownership, or documented feature status that conflicts with observable source behavior.

## Workflow
- Run module coverage and generate the selected spec into the working tree, then classify every diff by provenance: binding/docstring, module metadata, manual overlay, template/generator, or stale emitted output.
- Compare signatures, defaults, errors, limits, examples/tests, and architecture links against their canonical sources; review the manual overlay for intent and invariants, not duplicated generated inventories.
- Report the module, generated claim, authoritative evidence, true source file to change, downstream consumers, and whether regeneration alone resolves it; flag missing metadata owners separately from prose drift.
- If editable, update only the canonical source or manual overlay, regenerate and run spec/docs quality coverage, inspect links/anchors, and require a clean second generation; otherwise hand off exact source owners rather than requests to edit generated specs.
- Compare the regenerated module with its index entry and neighboring tier peers, checking namespace, source/binding path, user-facing flag, example/test links, and manual-overlay placement for coherent catalog behavior.
- Inspect at least one complex table/options signature and one userdata method in emitted output, because these shapes reveal parser omissions that simple namespace functions may not expose.

## References
- `contracts: AGENTS.md, docs/AGENTS.md, docs/specs/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "module specs generated summary coverage" --profile engine --limit 10, tools/python.cmd tools/docs/gen_module_specs.py, tools/python.cmd tools/audit/lua_spec_coverage.py, tools/python.cmd tools/validate/validate_module_coverage.py`
- `agent: doc_writer`
- RAG: Start with: `module specs generated summary coverage`, `review specs generated summary coverage docs`, `architecture docs specs engine boundaries`; Focus areas first: `docs/specs/`, `docs/architecture/`, `src/`, `tools/docs/`; Append the module or subsystem name such as `input`, `render`, `physics`, `ui`
