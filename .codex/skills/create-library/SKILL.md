---
name: create-library
description: "Load this skill when creating or modifying pure Lua library modules under library with tests and docs. Skip it for engine Rust modules, content demos, or one-off snippets."
---

# create-library

## Mission
- Create or modify pure Lua library modules that are reusable, documented, and covered.

## Domain Knowledge
- `library/<name>/init.lua` is a portable package boundary shared by LuaJIT and Lua 5.4; it cannot assume Lurek callbacks, engine userdata, repository working directories, or game-local assets.
- Reusable packages expose explicit constructors or module functions and keep mutation instance-local; globals, implicit singletons, and load-time side effects make games interfere and tests order-dependent.
- `example.lua` is the consumer contract for ergonomics, while `tests/lua/library/test_<name>_library.lua` owns behavioral proof; neither participates in public `lurek.*` API coverage.
- Compatibility includes syntax and module loading: avoid Lua 5.4-only features and make `require` predictable from the library root without editor-only path configuration.
- LDoc annotations define the public package surface and feed generated library docs; internal helpers should remain unexported unless consumers need a stable contract.
- Table ownership must be explicit: document whether inputs are borrowed, copied, normalized, or mutated and whether returned tables are snapshots or live references. Accidental aliasing is a common portability defect in reusable Lua packages.
- Error contracts should use stable return/error conventions that do not depend on Lurek's mlua boundary; validate arguments close to the public function and keep diagnostic text useful in both Lua runtimes.
- Algorithmic packages need declared complexity or practical ceilings when callers can provide unbounded collections, graphs, grids, or recursive structures, especially where a game frame may call the function repeatedly.

## Workflow
- Locate the closest package owner and define its portable contract first: inputs, returns, mutation model, errors, and whether state is instance-local or pure; create a package only when that contract cannot fit an existing owner.
- Implement `init.lua` without engine or asset assumptions, keep internals local, return one documented module table, and check every language feature against both LuaJIT and Lua 5.4.
- Show the primary consumer path in `example.lua` and prove edge cases, isolation between instances, invalid inputs, and deterministic results in the canonical library test; update both with every public contract change.
- Run library validation and coverage, execute the registered test and example with supported module loading, regenerate library docs, and inspect the public surface for accidental exports or missing annotations.
- Test repeated `require`, multiple constructors, and interleaved instances to expose load-time mutation, shared caches, or global writes; include a round-trip or copy-isolation case whenever tables cross the public boundary.
- Run representative behavior under both supported interpreters when syntax, iteration order, numeric behavior, or standard-library availability could diverge, and document intentional runtime differences instead of silently branching on engine globals.

## References
- `contracts: library/AGENTS.md, tests/lua/AGENTS.md, content/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "library Lua module conventions" --profile game --limit 10, tools/python.cmd tools/audit/library_coverage.py, tools/python.cmd tools/validate/validate_library.py --library <name>`
- `agent: content`
- RAG: Use when finding existing Lua helper modules and tests; `library Lua module conventions`; `require library module pattern`; `tests lua helper assert fixture`; `library/`; `tests/lua/`; `content/examples/`; `docs/` API references
