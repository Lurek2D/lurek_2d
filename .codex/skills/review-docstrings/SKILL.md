---
name: review-docstrings
description: "Load this skill when auditing and fixing Rust and Lua API docstrings, file docs, generated doc expectations, and stale descriptions. Skip it for general docs prose unrelated to source docstrings."
---

# review-docstrings

## Mission
- Audit and fix source docstrings so generated docs match callable behavior.

## Domain Knowledge
- Rust file docs use `//!`.
- Public Rust item docs use `///`.
- File docs explain purpose, owned state, boundary, invariants, and important related modules.
- Item docs explain behavior of the documented symbol.
- Binding annotations and docstrings under `src/lua_api/` generate Lua API reference content.
- `docs/api/lurek.md` and `docs/api/lurek.lua` are generated outputs.
- Generated API files are not the source editing surface.
- Lua-facing docs describe Lua names, Lua values, and Lua-visible errors.
- Rust domain docs describe engine behavior and must not invent Lua conversion rules.
- Numeric docs state units and valid range when the values are bounded.
- Index docs state whether Lua uses one-based indexing.
- Float docs state finite-only, positive-only, or other validation when enforced.
- Optional arguments state their default.
- Return docs state nil, table, userdata, copy, ordering, and field names when relevant.
- Mutation docs state which object changes and when the effect becomes visible.
- Callback docs state invocation phase, arguments, lifetime, replacement, removal, and error behavior.
- Frame or thread side effects are documented when callers must respect them.
- A file doc that only restates the filename is not useful.
- Presence and minimum length do not prove a docstring is correct.
- `docs/contributing/rust-file-docstrings.md` defines the expected file-doc content.
- `docstring_audit.py` reports docstring gaps.
- `gen_rust_docstrings.py` and `gen_all_docs.py` produce downstream documentation.
- Every Rust source file begins with one contiguous `//!` block.
- File-doc line bodies are required to contain 90-120 characters.
- `mod.rs` uses twice the normal LOC-based file-doc line count.
- Files under `src/lua_api/` use exactly one file-level line because callable docs live on items.
- `docstring_audit.py` requires a description, named parameter tags, and a concrete return tag when applicable.
- Bare `@return any` is a violation; use a concrete type, union, or manual documentation.
- The audit writes machine output to `logs/data/docstring_audit.json`.
- Violations change the exit code only when `docstring_audit.py --check` is used.

## Workflow
1. Read source, Lua API, and docs contracts.
2. Run docstring audits for the target module.
3. Select missing, stale, or low-value file and item docs.
4. Read the implementation before judging each comment.
5. Read Lua registration, tests, examples, and generated output when the symbol is public.
6. Check file docs for purpose, owner, boundary, invariants, and navigation.
7. Check item docs for units, indices, defaults, ranges, return shape, errors, and mutation.
8. Check callback lifetime and frame or thread behavior when relevant.
9. Record symbol, source line, stale claim, code evidence, and user effect.
10. Separate a documentation defect from behavior that needs an API decision.
11. Edit the owning `//!`, `///`, or binding annotation.
12. Do not edit generated `docs/api/lurek.md` or `docs/api/lurek.lua`.
13. Run `gen_rust_docstrings.py` when Rust doc output is affected.
14. Run `gen_all_docs.py` when Lua API output is affected.
15. Inspect generated signatures, paragraphs, annotations, table fields, and links.
16. Rerun docstring audits and freshness checks.
17. Hand unclear public behavior to the API owner before documenting a guess.
18. Hand source documentation fixes to `doc_writer` when a separate owner is required.

## References
- `contracts: AGENTS.md, src/AGENTS.md, src/lua_api/AGENTS.md, docs/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "docstring audit Rust lua_api generated docs" --profile engine --limit 10, tools/python.cmd tools/audit/docstring_audit.py, tools/python.cmd tools/docs/gen_rust_docstrings.py, tools/python.cmd tools/gen_all_docs.py`
- `agent: doc_writer`
- RAG: `docstring audit <module> Rust lua_api generated docs`; inspect source comments, implementation, binding registration, canonical tests/examples, and emitted Markdown/Lua declarations.
