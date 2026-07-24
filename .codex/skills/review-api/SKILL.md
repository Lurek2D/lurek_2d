---
name: review-api
description: "Load this skill when auditing and fixing Rust-to-Lua API coverage, thin wrappers, signatures, docs, and specs. Skip it for internal Rust-only tests or docs reviews without Lua API impact."
---

# review-api

## Mission
- Audit and fix Lua API parity between Rust modules, `src/lua_api/`, specs, and generated docs.
- Flag public namespace closures that perform runtime work owned by another module, even when a generic thin-wrapper heuristic passes.

## Domain Knowledge
- Rust engine modules own state and runtime algorithms.
- `src/lua_api/` owns Lua registration, conversion, validation, userdata access, and error translation.
- Generated API docs provide the public Lua name and signature inventory.
- `lua_covers_lurek_api_audit.py` checks public API ownership in Lua tests.
- `thin_wrapper_audit.py` reports bindings that may contain domain work.
- A thin wrapper may convert values, validate Lua input, borrow userdata, manage registry handles, and translate errors.
- A thin wrapper does not own simulation, caching, cross-module orchestration, or stateful algorithms.
- Lua arrays use one-based indices.
- Integer conversion must reject values outside the Rust target range.
- Float validation must define whether NaN and infinity are accepted.
- Enum strings need an exact accepted set and a useful invalid-value error.
- Option tables need known fields, defaults, and size or depth limits when nested input is accepted.
- Callback registration needs lifetime, replacement, removal, and error behavior.
- Userdata borrowing can fail and must return Lua-visible context.
- Public aliases are contracts and need a canonical owner.
- An alias must not silently use different validation or mutation rules.
- Return shape includes nil versus empty table, array versus keyed table, field names, userdata versus copy, and item order.
- Top-level functions, userdata methods, metamethods, callbacks, aliases, and imported objects can expose separate API paths.
- Error parity compares error category, API context, and state after failure.
- A rejected value or failed callback must not leave partial mutation.
- Generated docs, specs, examples, and tests are consumers of the binding contract.
- Intentionally loose Lua values use Rust `any`; a binding must not invent a fake Lua cast.
- Callbacks stored beyond one call use `lua.create_registry_value(...)`.
- Engine handles cross the boundary as `UserData`, not copied raw Rust structs.
- `LuaUserData::add_methods` contains registration, not domain algorithms.
- `thin_wrapper_audit.py` flags long free functions, collection ownership, loops, iterators, and numeric-update hotspots.
- A thin-wrapper `SUSPECT` is heuristic evidence; only `VIOLATION` makes the audit exit nonzero.
- Public binding additions enter generated API data before example or `@covers` ownership is written.

## Workflow
1. Read root, `src/lua_api`, and spec contracts.
2. Generate the current API inventory.
3. Run Lua coverage and thin-wrapper audits for the target module.
4. Build a table of public name, Rust owner, binding source, generated signature, spec, example, and test owner.
5. Inspect every missing or mismatched entry in source.
6. Check defaults against Rust behavior and generated docs.
7. Test valid values, boundary values, wrong Lua types, overflow, NaN, and infinity where relevant.
8. Check one-based index conversion and empty collection behavior.
9. Check enum strings and option-table validation.
10. Check stale or wrong userdata access.
11. Check callback registration, replacement, removal, and failure.
12. Follow top-level, userdata, alias, metamethod, and import construction paths.
13. Confirm domain algorithms remain in the Rust owner.
14. Inspect state after rejected input and callback or importer failure.
15. Record symbol, file, observed behavior, expected behavior, and affected consumers.
16. Rank semantic and unsafe boundary defects above coverage or docs drift.
17. Fix the canonical Rust or binding owner when fixes are requested.
18. Regenerate API data after source annotations or registrations change.
19. Update specs, examples, and tests from the emitted public names.
20. Rerun the same audits and behavioral probes.
21. Hand Rust domain defects to `developer` and binding defects to `lua_designer` when ownership differs.

## References
- `contracts: AGENTS.md, src/lua_api/AGENTS.md, docs/specs/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "Lua API wrapper coverage thin wrapper" --profile engine --limit 10, tools/python.cmd tools/audit/lua_covers_lurek_api_audit.py, tools/python.cmd tools/audit/thin_wrapper_audit.py, tools/python.cmd tools/gen_all_docs.py`
- `agent: lua_designer`
- RAG: `Lua API <module> wrapper coverage thin wrapper`; inspect the Rust owner, every binding construction path, generated symbol, spec, example, unit owner, and relevant audits.
