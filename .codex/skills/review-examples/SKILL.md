---
name: review-examples
description: "Load this skill when auditing and fixing example coverage, example correctness, and content/examples conventions. Skip it for full demos, snippets, or internal tests."
---

# review-examples

## Mission
- Audit and fix API example coverage and example quality.
- Enforce one public API = one example owner block in `content/examples/`.

## Domain Knowledge
- Public API examples live under `content/examples/`.
- One generated public API entry has one marker-owned example block.
- Coverage counts marker ownership, not plain text mentions.
- Aliases and userdata methods need separate owners when they are separate generated entries.
- The example parser extracts the immediate `do ... end` block after the marker.
- Setup between a marker and its `do` block breaks extraction ownership.
- Top-level helpers are outside the extracted block.
- An extracted block must contain enough setup to stand alone.
- Structural extraction, runtime boot, and teaching value are separate checks.
- An example shows one representative success path.
- An example is not an assertion matrix, game loop, demo, or snippet recipe.
- A useful example has an observable result.
- Resource creation and mutation must happen in a legal lifecycle phase.
- Repeated allocation in draw code is usually a wrong teaching pattern.
- State changes made only during rendering can teach the wrong engine lifecycle.
- Shared assets use stable workspace paths with forward slashes.
- Machine-local and game-local assets are not portable example dependencies.
- A full module file can leak callbacks, resources, globals, or registrations between blocks.
- `example_coverage.py --module <module>` reports module ownership gaps.
- `validate_example_coverage.py` validates repository example coverage.
- Generated API inventory is the canonical list used for coverage.
- The coverage report classifies blocks as `FULL`, `PART`, `TODO`, or `MISS`.
- `PART` means the owned body has fewer than five relevant non-comment lines.
- Structural error `E6` means one API marker appears more than once.
- Structural errors `E7` and `E8` identify unowned top-level blocks or Lua statements.
- Error `E9` flags files averaging more than 60 lines per API marker.
- `--report` gates missing items and lint; `--no-stubs` and `--no-partials` add finished-content gates.
- Plain API calls discovered outside an owner block do not upgrade marker coverage.

## Workflow
1. Read content, example, and docs contracts.
2. Generate or inspect the current public API inventory.
3. Run module example coverage without accepting stubs or partial owners.
4. Run repository example validation.
5. Classify missing, duplicate, malformed, TODO, PART, and thin owners.
6. Map each finding to its generated signature and module file.
7. Inspect the exact block the parser extracts.
8. Check that the marker is followed immediately by `do`.
9. Check that setup and API use are inside the block.
10. Check that the generated public name is exact.
11. Check that the result is visible or otherwise observable.
12. Check callback and lifecycle placement.
13. Check resource bounds and asset portability.
14. Boot the full example module to detect leaked shared state.
15. Separate parser failures, runtime failures, and teaching defects.
16. Record API name, owner block, failure, generated-page effect, and minimum success case.
17. Repair the owner through the `create-example` workflow when fixes are requested.
18. Run the full module, strict coverage, validation, and example smoke.
19. Inspect the generated page extraction after the fix.
20. Compare the block with its docs, unit test, and snippet.
21. Remove test matrices, game scope, or editor-only recipe content from examples.

## References
- `contracts: AGENTS.md, content/AGENTS.md, content/examples/AGENTS.md, docs/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "example coverage content examples API" --profile game --limit 10, tools/python.cmd tools/audit/example_coverage.py --module <module>, tools/python.cmd tools/validate/validate_example_coverage.py`
- `agent: content`
- RAG: `example coverage <module> content examples API`; inspect the generated inventory, marker owner, extracted block, full module runtime, unit owner, and nearest snippet.
