---
name: examples-management
description: "Load this skill when adding or reviewing content/examples/, content/snippets/, content/games/, or tests/lua_reorg/evidence files that demonstrate lurek API usage and output artifacts. Skip it for engine Rust, docs/, or CAG work."
---
# examples-management

## Mission
- Own example and demo content structure, clarity, and coverage value.

## When To Load
- Add or update content/examples/.
- Add or update content/snippets/.
- Review content/games/ example content.
- Check example README or conf files.
- Improve API coverage through examples.
- Add or update API evidence generators in tests/lua_reorg/evidence/.

## When To Skip
- Engine Rust code.
- docs/ content.
- CAG files.

## Domain Knowledge
- One example, one concept. `content/examples/<module>.lua` is a runnable `--@api-stub:` file that demonstrates exactly one API call or pattern in realistic game context.
- The `--@api-stub: lurek.<namespace>.<function>` comment above each block is the signal that `tools/audit/example_coverage.py` uses to measure coverage. Keep that tag on the line immediately above the `do` block or coverage counting breaks.
- How to find missing coverage: run `tools/python.cmd tools/audit/example_coverage.py` and compare its output against `docs/api/lurek.lua`. The audit tool produces a list of API names with no matching `--@api-stub:` tag.
- Minimal setup is a hard rule. If an example needs a physics world, create exactly one `lurek.physics.newWorld(0, 9.81)`.
- How to add a new example file: create `content/examples/<module>.lua`, run `cargo test --test examples_load_test`, and confirm the file is picked up and loads without error. If the module has a guard, add it at the top of the file so headless CI does not fail.
- Sync rules: if an example changes a function name or parameter order because the API changed, update the matching entry in `docs/api/lurek.lua` and the affected `docs/specs/<module>.md` in the same commit. The example is living documentation; it must stay truthful.
- Coverage gap workflow: audit Ă˘â€ â€™ pick one uncovered function Ă˘â€ â€™ write the `do` block Ă˘â€ â€™ confirm the stub tag Ă˘â€ â€™ run load test Ă˘â€ â€™ commit with sync. Never inflate count by writing stub tags without runnable code.
- Snippet workflow in `content/snippets/`: each snippet block starts with `-- @snippet ...`, then `-- @prefix`, `-- @module`, `-- @description`, `-- @body`, body lines, and `-- @end`. Keep marker order exact because the parser and validator read strict line sequences.
- Snippet design rule: snippets are not single-call API showcases. Each snippet must compose multiple API calls into one reusable gameplay building block.
- Use VS Code placeholders in snippet bodies so non-AI users can tab through parameters and variable names after insertion.
- Snippet coverage is module-level, not per-function parity. Use `tools/python.cmd tools/audit/snippet_coverage.py` to check how many snippets exist for each Lua API module and snippet density against API item counts.
- Source of truth is `content/snippets/*.lua`; generated extension artifact is `extension/vscode/data/snippets.json` via `tools/python.cmd tools/snippets/gen_vscode_snippets.py`.
- Evidence workflow for `tests/lua_reorg/evidence/`: keep setup small, call the real `lurek.*` API being proven, and write one deterministic artifact per case under `tests/artifacts/current/<module>/`.
- Evidence artifacts must be produced by engine API output paths. Do not replace missing engine output paths with handmade chart drawing that hides API behavior.
- If a module has no image output method, write a deterministic text/JSON artifact from real API state instead of synthetic pixel rendering.
- Prefer one clear concept per evidence case. Avoid giant merged files with repeated blocks and avoid copying the same scaffold into many tests.
- After evidence edits, run `tools/python.cmd tools/dev/parallel_cargo.py test lua` and confirm failures are unrelated before finalizing. When a global compile failure blocks Lua tests, record that blocker explicitly in the report.
## Companion File Index
- None.

## References
- content/examples/
- content/snippets/
- content/games/
- tests/lua_reorg/evidence/
- tools/audit/example_coverage.py
- tools/audit/snippet_coverage.py
- logs/reports/coverage_gaps.md

