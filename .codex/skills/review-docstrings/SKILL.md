---
name: review-docstrings
description: "Load this skill when auditing and fixing Rust and Lua API docstrings, file docs, generated doc expectations, and stale descriptions. Skip it for general docs prose unrelated to source docstrings."
---

# review-docstrings

## Mission
- Audit and fix source docstrings so generated docs match callable behavior.

## Domain Knowledge
- Rust `//!` file docs explain purpose, owned state, boundary, and key invariants; public `///` docs explain symbol behavior. Passing a presence audit does not establish that either is accurate or useful.
- Lua API reference is generated from binding annotations/docstrings under `src/lua_api/`; `docs/api/lurek.md` and `.lua` are evidence outputs, never the correction surface.
- High-value callable docs state units, coordinate/index conventions, defaults, valid ranges/ceilings, return shape, errors, mutation, callback lifetime, and frame/thread side effects when those facts apply.
- Docs on wrappers must describe Lua-observable semantics rather than Rust implementation types, while domain docs should not promise Lua names or conversions they do not own.
- Staleness often appears as signature parity with semantic mismatch: renamed defaults, newly fallible behavior, copied text across aliases, or methods that now return snapshots instead of live state.
- File docs should name why the file exists within its module and what it deliberately does not own; restating the filename or listing imports does not help future boundary decisions.
- Numeric documentation should distinguish validation range, meaningful operating range, storage type, and unit. Saying “number” or copying a Rust type can hide finite-only, positive-only, coordinate, duration, or byte-size semantics.
- Callback documentation should state invocation phase, argument lifetime, replacement/removal behavior, error propagation, and whether callbacks may mutate the originating object safely.
- Examples in docstrings should be kept only when the generator supports and validates them; otherwise link behavior to the canonical example owner rather than maintaining a second untested code sample.
- File-doc review is qualitative as well as mechanical: compare `//!` content with `rust_file_docstring_guidelines.md` for real ownership, boundaries, invariants, and navigation rather than accepting marker presence or length alone.

## Workflow
- Run file/public/docstring audits for the module and use their gaps to select symbols; compare each source comment with implementation, Lua registration, tests/examples, and emitted docs rather than editing generated prose.
- Review file docs for ownership/boundary quality and callable docs for behavior dimensions relevant to that symbol, prioritizing misleading units/defaults/errors/side effects above missing stylistic detail.
- Record exact symbol and source line, stale claim, code evidence, user consequence, and corrected fact pattern; distinguish a documentation defect from unclear behavior that first needs an API/spec decision.
- If editable, fix the source-owned `//!`, `///`, or Lua binding annotation, regenerate affected docs, inspect emitted signatures/anchors, and rerun audits/freshness checks; otherwise hand off source symbols and evidence to `doc_writer` or the API owner.
- Compare sibling methods and aliases for terminology, units, and error conventions, but preserve meaningful semantic differences instead of normalizing text mechanically.
- Sample the emitted Markdown and Lua declaration consumers after regeneration, verifying paragraph breaks, annotations, table fields, optional values, and links survive the generator's parser rather than merely appearing correct in Rust source.

## References
- `contracts: AGENTS.md, src/AGENTS.md, src/lua_api/AGENTS.md, docs/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "docstring audit Rust lua_api generated docs" --profile engine --limit 10, tools/python.cmd tools/audit/docstring_audit.py, tools/python.cmd tools/docs/gen_rust_docstrings.py, tools/python.cmd tools/gen_all_docs.py`
- `agent: doc_writer`
- RAG: Use when locating source-owned docs before prose edits; `docstring audit Rust lua_api generated docs`; `/// lua api docs example`; `module docs comment generated`; `src/`; `library/`; generated docs in `docs/`; examples proving behavior
