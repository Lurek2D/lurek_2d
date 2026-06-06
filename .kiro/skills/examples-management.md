---
inclusion: manual
---

# examples-management

## Mission
Own example and demo content structure, clarity, and coverage value.

## When To Use
- Add or update `content/examples/`, `content/snippets/`, or `content/games/` example content.
- Check example README or conf files.
- Improve API coverage through examples.
- Add or update API evidence generators in `tests/lua/evidence/`.

## When To Skip
- Engine Rust code, `docs/` content, CAG files.

## Rules

### One Example, One Concept
`content/examples/<module>.lua` demonstrates exactly one API call or pattern in realistic game context. Each block opens with `do`, includes a comment explaining the usage, and closes with `end`.

### Coverage Tags
The `--@api-stub: lurek.<namespace>.<function>` comment above each block is the signal that `tools/audit/example_coverage.py` uses to measure coverage. Keep that tag on the line immediately above the `do` block.

### Finding Missing Coverage
Run `python tools/audit/example_coverage.py` and compare against `docs/api/lurek.lua`. Prioritize functions that game authors call in their first session.

### Minimal Setup Rule
If an example needs a physics world, create exactly one `lurek.physics.newWorld(0, 9.81)`. Never import a library module or build helper utilities or share state between `do` blocks. If the example is becoming too complex, it wants to be a demo in `content/games/`.

### Adding a New Example File
Create `content/examples/<module>.lua`, run `cargo test --test examples_load_test`, and confirm the file loads without error. If the module has a guard (e.g., `if not lurek.html then return end`), add it at the top so headless CI does not fail.

### Sync Rules
If an example changes a function name or parameter order because the API changed, update `docs/api/lurek.lua` (after regenerating) and the affected `docs/specs/<module>.md` in the same commit.

### Snippet Workflow
Each snippet in `content/snippets/` starts with `-- @snippet ...`, then `-- @prefix`, `-- @module`, `-- @description`, `-- @body`, body lines, and `-- @end`. Keep marker order exact. Use VS Code placeholders (`${1:name}`, `${2:value}`) so users can tab through parameters.

### Snippet Design
Each snippet must compose multiple API calls into one reusable gameplay building block, not a single-call showcase.

### Evidence Workflow
In `tests/lua/evidence/`: keep setup small, call the real `lurek.*` API being proven, write one deterministic artifact per case under `tests/output/<module>/`. Artifacts must be produced by engine API output paths.

## References
- `content/examples/`
- `content/snippets/`
- `content/games/`
- `tests/lua/evidence/`
- `tools/audit/example_coverage.py`
- `tools/audit/snippet_coverage.py`
