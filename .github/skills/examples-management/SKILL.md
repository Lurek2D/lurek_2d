---
name: examples-management
description: "Load this skill when adding or reviewing content/examples/, content/snippets/, content/games/, or tests/lua/evidence files that demonstrate lurek API usage and output artifacts. Skip it for engine Rust, docs/, or CAG work."
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
- Add or update API evidence generators in tests/lua/evidence/.

## When To Skip
- Engine Rust code.
- docs/ content.
- CAG files.

## Domain Knowledge
- One example, one concept. `content/examples/<module>.lua` is a runnable `--@api-stub:` file that demonstrates exactly one API call or pattern in realistic game context. Look at `content/examples/ai.lua` or `content/examples/physics.lua` for the established format: each block opens with `do`, includes a comment explaining the usage, and closes with `end`.
- The `--@api-stub: lurek.<namespace>.<function>` comment above each block is the signal that `tools/audit/example_coverage.py` uses to measure coverage. Keep that tag on the line immediately above the `do` block or coverage counting breaks.
- How to find missing coverage: run `python tools/audit/example_coverage.py` and compare its output against `docs/api/lurek.lua`. The audit tool produces a list of API names with no matching `--@api-stub:` tag. Prioritise functions that game authors call in their first session (constructors, common callbacks, core configuration) over edge-case functions.
- Minimal setup is a hard rule. If an example needs a physics world, create exactly one `lurek.physics.newWorld(0, 9.81)`. If it needs a sprite, load one asset. Never import a library module, never build helper utilities, never share state between `do` blocks in the same file. If the example is becoming too complex, it wants to be a demo in `content/games/`.
- How to add a new example file: create `content/examples/<module>.lua`, run `cargo test --test examples_load_test`, and confirm the file is picked up and loads without error. If the module has a guard (e.g., `if not lurek.html then return end`), add it at the top of the file so headless CI does not fail.
- Sync rules: if an example changes a function name or parameter order because the API changed, update the matching entry in `docs/api/lurek.lua` (after regenerating via `python tools/gen_all_docs.py`) and the affected `docs/specs/<module>.md` in the same commit. The example is living documentation; it must stay truthful.
- Coverage gap workflow: audit â†’ pick one uncovered function â†’ write the `do` block â†’ confirm the stub tag â†’ run load test â†’ commit with sync. Never inflate count by writing stub tags without runnable code.
- Snippet workflow in `content/snippets/`: each snippet block starts with `-- @snippet ...`, then `-- @prefix`, `-- @module`, `-- @description`, `-- @body`, body lines, and `-- @end`. Keep marker order exact because the parser and validator read strict line sequences.
- Snippet design rule: snippets are not single-call API showcases. Each snippet must compose multiple API calls into one reusable gameplay building block (for example state bootstrap + event emit + timer scheduling + render hook).
- Use VS Code placeholders in snippet bodies (`${1:name}`, `${2:value}`) so non-AI users can tab through parameters and variable names after insertion.
- Snippet coverage is module-level, not per-function parity. Use `python tools/audit/snippet_coverage.py` to check how many snippets exist for each Lua API module and snippet density against API item counts.
- Source of truth is `content/snippets/*.lua`; generated extension artifact is `extension/vscode/data/snippets.json` via `python tools/snippets/gen_vscode_snippets.py`.
- Evidence workflow for `tests/lua/evidence/`: keep setup small, call the real `lurek.*` API being proven, and write one deterministic artifact per case under `tests/output/<module>/`.
- Evidence artifacts must be produced by engine API output paths (for example `drawToImage`, `renderToImage`, `toImageData`, `saveWAV`, HTML document state accessors). Do not replace missing engine output paths with handmade chart drawing that hides API behavior.
- If a module has no image output method (for example light systems without `drawToImage`), write a deterministic text/JSON artifact from real API state (counts, params, computed results) instead of synthetic pixel rendering.
- Prefer one clear concept per evidence case. Avoid giant merged files with repeated blocks and avoid copying the same scaffold into many tests.
- After evidence edits, run `python tools/dev/parallel_cargo.py test lua` and confirm failures are unrelated before finalizing. When a global compile failure blocks Lua tests, record that blocker explicitly in the report.
## Companion File Index
- None.

## References
- content/examples/
- content/snippets/
- content/games/
- tests/lua/evidence/
- tools/audit/example_coverage.py
- tools/audit/snippet_coverage.py
- logs/reports/coverage_gaps.md

