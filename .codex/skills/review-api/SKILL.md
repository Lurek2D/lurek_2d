---
name: review-api
description: "Load this skill when auditing and fixing Rust-to-Lua API coverage, thin wrappers, signatures, docs, and specs. Skip it for internal Rust-only tests or docs reviews without Lua API impact."
---

# review-api

## Mission
- Audit and fix Lua API parity between Rust modules, `src/lua_api/`, specs, and generated docs.
- Flag public namespace closures that perform runtime work owned by another module, even when a generic thin-wrapper heuristic passes.

## Domain Knowledge
- API parity is four-dimensional: callable names/signatures, Lua-to-Rust conversion and validation, runtime semantics/errors, and generated documentation/spec/example/test ownership. Equal method counts do not prove parity.
- Thin wrappers may validate, convert, manage userdata/registry handles, and translate errors; stateful algorithms, cross-module orchestration, caching, and runtime work belong in the Rust domain owner.
- Lua boundaries require explicit handling of one-based indices, integer narrowing, finite floats, enum strings, option-table depth/size, callback lifetime, and fallible userdata borrowing; defaults must match docs and Rust behavior.
- Compatibility aliases are public contracts: they need canonical ownership, identical validation/error semantics where promised, and a deprecation or persistence story rather than silent divergence.
- Generated Lua API names drive docs, exact example markers, and unit-test ownership, so generator omissions and duplicate aliases can fan out as false coverage gaps.
- For tilemap/tileset specifically, review authoritative map versus renderer snapshot semantics, local/GID conversion, atlas/provider ceilings, importer error tables, fallible quad lookup, animation/archetype numerics, and alias parity together.
- Return-shape parity includes nil versus empty tables, array versus keyed tables, copied snapshots versus live userdata, stable field names, and deterministic ordering where generated docs or callers rely on it.
- Wrapper audits must follow every construction path, not only top-level functions: userdata methods, metamethods, callbacks, compatibility namespaces, and imported objects can expose the same domain state with different validation.
- Error parity should compare type/category, method context, and mutation atomicity across aliases and fallible/legacy pairs rather than requiring incidental Rust wording to match byte for byte.

## Workflow
- Generate the current API inventory and run coverage/thin-wrapper audits for the module; build a symbol matrix joining Rust owner, Lua registration, generated signature/doc, spec, example owner, and unit owner before judging gaps.
- Inspect high-risk conversions and methods directly, exercising valid defaults, boundary values, wrong Lua types, non-finite/overflow values, stale userdata, callbacks, aliases, and error names; verify runtime work remains behind the domain module.
- Rank findings by reachable semantic mismatch first, unsafe or unbounded boundary second, missing callable/coverage third, and documentation-only drift last; attach exact symbol, file, observed behavior, expected contract, and affected generated consumers.
- If editable, fix the canonical Rust/binding source, regenerate API data, then update specs/examples/tests from emitted names and rerun the same matrix and behavioral probes; otherwise hand off domain fixes to `developer` and binding/parity fixes to `lua_designer`.
- Diff generated API inventories before and after the review, checking removed/renamed symbols, overload collapse, userdata method ownership, optional/default encoding, and table-field annotations for changes not obvious in Rust signatures.
- Probe mutation atomicity by inspecting state after rejected values, callback failures, and importer errors; report wrappers that validate only after partially changing the domain object.
- Verify compatibility aliases through the same success and failure table as the canonical entry point, then confirm examples/tests own only the canonical generated names unless alias coverage is an explicit public requirement.

## References
- `contracts: AGENTS.md, src/lua_api/AGENTS.md, docs/specs/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "Lua API wrapper coverage thin wrapper" --profile engine --limit 10, tools/python.cmd tools/audit/lua_covers_lurek_api_audit.py, tools/python.cmd tools/audit/thin_wrapper_audit.py, tools/python.cmd tools/gen_all_docs.py`
- `agent: lua_designer`
- RAG: Start with: `Lua API wrapper coverage thin wrapper`, `Rust engine module lua_api docs specs`, `src lua_api AGENTS thin wrappers registration only`; Focus areas first: `src/lua_api/`, `src/`, `docs/specs/`, `tests/lua/`, `tools/audit/`; Append the API path or module name such as `lurek.input`, `lurek.render`, `math`, `scene`
