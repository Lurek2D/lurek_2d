---
name: create-example
description: "Load this skill when creating or modifying API examples under content/examples for a specific public lurek API. Skip it for full demos, snippets, engine implementation, or non-public internals."
---

# create-example

## Mission
- Create or modify concise runnable API examples that cover real public behavior.
- Keep `content/examples/` at 100% public API coverage with one owner block per API.

## Domain Knowledge
- API examples live under `content/examples/`.
- One module uses one `content/examples/<module>.lua` file.
- Generated Lua API names are the example coverage keys.
- One public API has one exact `--@api:` owner.
- The marker is directly followed by one `do ... end` block.
- No comment or setup line appears between the marker and `do`.
- The owned block contains all required setup and cleanup.
- Generated pages may extract the block without the rest of the file.
- Each block contains 5-16 relevant non-comment code lines.
- `--@api-stub:` marks unfinished coverage.
- Finished examples do not contain TODO or PART markers.
- An example shows one realistic success path.
- An example has an observable result.
- Error matrices belong in unit tests.
- Multi-system loops belong in finished games.
- Asset paths use forward slashes.
- The complete module file must boot without state leaking between blocks.
- `content/examples/README.md` is the namespace index for example files.
- Shared example resources live under `content/examples/assets/`.
- Files ending in `.demo.lua` are focused user-facing workflows. They are smoke-tested but intentionally excluded from API-marker coverage; keep them short and do not add `--@api:` markers.
- Coverage states are `FULL`, `PART`, `TODO`, and `MISS`.
- `FULL` requires a marker block, no TODO line, and at least five useful non-comment body lines; strict lint separately enforces the 16-line maximum.
- Structural lint rejects duplicate markers, unowned top-level `do` blocks, and top-level Lua code outside owned blocks.
- `--report --no-stubs --no-partials` is the strict finished-example gate.

## Workflow
1. Read the examples contract.
2. Run module example coverage.
3. Select one missing, stubbed, or changed generated API.
4. Read its generated signature, spec, and unit test.
5. Open the canonical module example file.
6. Design one independent success case.
7. Put all setup inside the owned block.
8. Place the exact marker directly above `do`.
9. Call the exact generated API name.
10. Make the result visible or inspectable.
11. Bound callbacks and persistent resources.
12. Remove the matching stub and TODO text.
13. Boot the full module example file.
14. Run example validation and coverage.
15. Run the example smoke sweep.
16. Inspect the extracted generated block.
17. Confirm that the API has exactly one owner.

## References
- `contracts: content/AGENTS.md, content/examples/AGENTS.md, docs/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "content examples API coverage" --profile game --limit 10, tools/python.cmd tools/audit/example_coverage.py --module <module>, tools/python.cmd tools/validate/validate_example_coverage.py, tools/python.cmd tools/demos/smoke_sweep.py --kind example`
- `agent: content`
- RAG: `content examples <module> API coverage`; inspect the generated signature, canonical module file, unit owner, and nearest snippet.
