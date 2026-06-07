---
trigger: model_decision
description: "Load this skill when creating or updating a library/ module, its docs, example, or harness registration. Skip it for engine Rust, single examples, or full game demos."
---
# library-authoring

## Mission
- Own library/ module layout, docs, examples, and test registration.

## When To Load
- Create a library.
- Refactor a library.
- Regenerate library docs.
- Add harness registration for library tests.

## When To Skip
- Engine Rust work.
- Single examples.
- Full demos.

## Domain Knowledge
- Package layout is fixed: `library/<name>/init.lua`, `library/<name>/example.lua`, and `README.md`. Every library must have all three.
- How to register a library in the test harness: open `tests/lua/harness.rs`, find the `lua_library_*` test list, and add a `lua_library_<name>` entry pointing to `tests/lua/library/test_library_<name>.lua`. This file is what `cargo test --test lua` runs.
- How library docs-general is generated: LDoc comment tags on public functions in `init.lua` are read by `tools/docs/gen_lib_docs.py`. Run `python tools/docs/gen_lib_docs.py` after any API change and check `docs/api/lureksome.md` for the updated output.
- Library modules are pure Lua. They may call `lurek.*` APIs but must not call internal engine symbols or reach into `src/` at runtime.
- How to keep example.lua honest: `example.lua` must run headlessly via `cargo test --test examples_load_test` without error. It should call every major public function of the library at least once.
- Naming rules: public functions use `snake_case`. The module table returned by `init.lua` must be named to match the folder: `library/stats/init.lua` returns a table assigned to `stats`.
- When updating a library API: update `init.lua`, then update `example.lua` to call the new signature, then update `tests/lua/library/test_library_<name>.lua` to test the new behavior, then regenerate docs. All four in the same commit, no exceptions.
## Companion File Index
- None.

## References
- library/
- tests/lua/library/
- tests/lua/harness.rs
- tools/docs/gen_lib_docs.py