---
name: create-example
description: "Load this skill when creating or modifying API examples under content/examples for a specific public lurek API. Skip it for full demos, snippets, engine implementation, or non-public internals."
---

# create-example

## Mission
- Create or modify concise runnable API examples that cover real public behavior.
- Keep `content/examples/` at 100% public API coverage with one owner block per API.

## Domain Knowledge
- `content/examples/<module>.lua` is executable content and structured input to generated API pages; each exact `--@api:` plus immediately following `do ... end` is the sole owner of one generated Lua API name.
- Block isolation is semantic because generated pages may extract one block without neighboring setup; required objects, callbacks, and teardown therefore belong inside the owner even when that duplicates a few lines.
- An example demonstrates a realistic success path and observable outcome. Error matrices belong in tests, and multi-system game loops belong in `content/games/`.
- Stateful APIs need cleanup or bounded lifetime so the complete module file boots without one block contaminating later examples.
- `--@api-stub:` is unfinished generator debt; coverage is complete only when a generated name has one real, non-partial owner.
- Example ordering within a module should follow the public namespace and object lifecycle so a reader can find constructors before methods without creating execution dependencies between blocks.
- Non-visual APIs still need an observable teaching result through state inspection or engine logging appropriate to examples; visual APIs need enough initialized scene context that the effect is distinguishable from defaults.
- Error handling belongs in an example only when failure recovery is the API's primary usage. Otherwise, demonstrate valid inputs and leave exhaustive invalid cases to the canonical unit owner.

## Workflow
- Run module-scoped coverage and read the generated signature before broad example reads; locate the canonical module file and a nearby block with similar object/lifecycle needs without sharing state across markers.
- Design one independently extractable success case: create prerequisites inside the block, call the owned API by its generated name, make the result observable, and bound resources or callbacks without turning the block into a test suite.
- Place the exact marker immediately above `do`, remove any stub/TODO for that owner, and boot the complete module file to expose leaked state, duplicate registrations, invalid assets, or hidden display assumptions.
- Rerun module and repository coverage with no stubs/partials, smoke the example, and regenerate docs only when source metadata changed; confirm the API still has exactly one owner afterward.
- Read the extracted/generated representation of the block after validation, ensuring explanatory context, indentation, and required setup survive extraction and do not depend on comments or helpers outside the owner.
- Compare the example with the unit test and nearest snippet: remove assertion-heavy duplication, keep the human-readable success path here, and leave multi-call editor recipes to the snippet catalog.
- For callbacks or persistent resources, run long enough to observe the advertised result and then confirm the module file can continue executing later blocks without callback replacement, registry growth, or conflicting global state.

## References
- `contracts: content/AGENTS.md, content/examples/AGENTS.md, docs/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "content examples API coverage" --profile game --limit 10, tools/python.cmd tools/audit/example_coverage.py --module <module>, tools/python.cmd tools/validate/validate_example_coverage.py`
- `agent: content`
- RAG: Start with: `content examples API coverage`, `example coverage content examples API`, `keyboard input lua API examples tests`; Focus areas first: `content/examples/`, `docs/`, `tests/lua/`, `content/snippets/`; Append the API or module name such as `input`, `render`, `tilemap`, `math` when narrowing
