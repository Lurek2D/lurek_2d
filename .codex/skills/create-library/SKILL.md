---
name: create-library
description: "Load this skill when creating or modifying reusable pure Lua packages under lurek_2d_content/library with their example, tests, and docs. Skip it for Rust modules, game-local helpers, demos, or snippets."
---

# create-library

## Mission
- Create or modify portable Lua packages under `lurek_2d_content/library/` with an explicit consumer contract.

## Domain Knowledge
- Reusable Lua packages live under `lurek_2d_content/library/`.
- A package entry point is `lurek_2d_content/library/<name>/init.lua`.
- Each package has `example.lua`.
- Each package has `tests/lua/library/test_<name>_library.lua`.
- Packages support LuaJIT and Lua 5.4.
- Packages do not require Lurek callbacks or engine userdata.
- Packages do not require a repository working directory.
- Packages do not use game-local assets.
- `init.lua` returns one module table.
- Public state uses constructors or explicit module functions.
- Mutable state is instance-local.
- Packages do not create globals.
- Package loading has no hidden runtime side effects.
- Public functions use LDoc annotations.
- Internal helpers remain local.
- Table inputs and outputs define copy, borrow, and mutation behavior.
- Public errors use stable Lua-level conventions.
- Collection or recursive algorithms define practical limits.
- Games load packages as `require("library.<name>")` after adding the library parent to `package.path`.
- A game may vendor the whole `library/` directory; packages cannot assume the original repository layout.
- `validate_library.py --strict` promotes missing examples, tests, and LDoc warnings to errors.
- The library validator accepts both `-- @...` and `--- @...` LDoc tag styles.
- The docs generator reads public annotations from `init.lua`, so undocumented exports do not have a separate metadata owner.
- Maintained packages are independent modules; one package must not require another package's private locals.

## Workflow
1. Read the library contract.
2. Read the closest existing package.
3. Define public functions, inputs, returns, errors, and mutation rules.
4. Extend an existing package when it already owns the behavior.
5. Implement `init.lua` with local helpers and no engine assumptions.
6. Return one documented module table.
7. Add LDoc annotations to public functions.
8. Update `example.lua` with the main consumer path.
9. Update the canonical library test.
10. Test invalid inputs and deterministic output.
11. Test two interleaved instances.
12. Test repeated `require`.
13. Test copied versus shared table behavior.
14. Run the package under LuaJIT and Lua 5.4 when behavior may differ.
15. Run library validation and coverage.
16. Regenerate library docs.
17. Check for accidental globals and exports.

## References
- `contracts: AGENTS.md, lurek_2d_content/AGENTS.md, lurek_2d_content/library/AGENTS.md, tests/lua/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "library Lua module conventions" --profile game --limit 10, tools/python.cmd tools/audit/library_coverage.py, tools/python.cmd tools/validate/validate_library.py --library <name>`
- `agent: content`
- RAG: `pure Lua library require module portability`; inspect `lurek_2d_content/library/`, its canonical test, example, and generated library docs.
