---
inclusion: manual
---

# library-authoring

## Mission
Own `library/` module layout, docs, examples, and test registration.

## When To Use
- Create or refactor a library.
- Regenerate library docs.
- Add harness registration for library tests.

## When To Skip
- Engine Rust work, single examples, full demos.

## Rules

### Fixed Package Layout
`library/<name>/init.lua` (entry point, all public API), `library/<name>/example.lua` (single happy-path consumer script), and `README.md` (one-paragraph summary and usage snippet). Every library must have all three.

### Harness Registration
Open `tests/lua/harness.rs`, find the `lua_library_*` test list, and add a `lua_library_<name>` entry pointing to `tests/lua/library/test_library_<name>.lua`. Without this entry, the library is never tested in CI.

### Doc Generation
LDoc comment tags on public functions in `init.lua` are read by `tools/docs/gen_lib_docs.py`. Run `python tools/docs/gen_lib_docs.py` after any API change. Doc comment format: `--- Summary line. @param name type desc @return type desc`.

### Pure Lua Rule
Library modules are pure Lua. They may call `lurek.*` APIs but must not call internal engine symbols or reach into `src/` at runtime. If a library needs behavior the engine does not expose, add a `lurek.*` function — do not add a Rust dependency to the library.

### Honest example.lua
Must run headlessly via `cargo test --test examples_load_test` without error. Should call every major public function at least once. Show both paths when the library has conditional behavior.

### Naming Rules
Public functions use `snake_case`. The module table returned by `init.lua` should be named to match the folder: `library/stats/init.lua` returns a table assigned to `stats`. Do not use `M` or `_M` as the return name.

### Updating a Library API
Update `init.lua`, then `example.lua`, then `tests/lua/library/test_library_<name>.lua`, then regenerate docs. All four in the same commit, no exceptions.

## References
- `library/`
- `tests/lua/library/`
- `tests/lua/harness.rs`
- `tools/docs/gen_lib_docs.py`
