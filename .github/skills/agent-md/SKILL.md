---
name: agent-md
description: "Load this skill when creating or maintaining merged module reference specs in docs/specs/<module>.md. It owns the required section structure, sync contract, and scaffold+validate workflow after the retirement of src/<module>/AGENT.md. Skip it for writing production Rust code, tests, or Lua scripts."
---
# agent-md

## Mission

Own the required section structure, sync contract, and scaffold+validate workflow for merged module reference specs at docs/specs/<module>.md.

## When To Load

- Creating a new docs/specs/<module>.md for a new engine module
- Updating a module reference after changing source files, public types, functions, or Lua bindings
- Reviewing whether a module reference still matches its Rust source and Lua wrapper

## When To Skip

- Writing production Rust code → use rust-coding skill
- Writing or reviewing Lua API Rust bindings → use lua-api-design or lua-rust-bridge
- End-to-end module quality audits → use module-audit skill

## Domain Knowledge

Every engine module uses one canonical file: docs/specs/<module>.md. The retired src/<module>/AGENT.md must never be reintroduced.

**Required sections in order:** General Info, Summary, Files, Types, Functions, Lua API Reference, References, Notes.

- **General Info** — short and factual: module group, source path, Lua API path(s), primary Lua namespace, Rust/Lua test paths.
- **Summary** — several paragraphs explaining purpose, scope boundary, and why responsibilities live here. Write per-module; never mass-generate vague text.
- **Files** — one bullet per .rs file: "file.rs: purpose". Source-derived, safe to regenerate.
- **Types** — one bullet per public type: "TypeName (kind, file.rs): purpose". Source-derived.
- **Functions** — one bullet per public function/method. Source-derived.
- **Lua API Reference** — binding paths and namespace. Must stay aligned with src/lua_api/<module>_api.rs.
- **References** — one bullet per dependency/related module with relationship explanation.
- **Notes** — external crate constraints, OS-specific behaviour, known omissions, migration warnings, sharp edges.

**Sync contract** — when source changes, update the matching section:

| Source change | Update section |
|---|---|
| New .rs file | Files |
| Public type added/removed | Types |
| Public function added/removed | Functions |
| Lua binding added/renamed/removed | Lua API Reference |
| Dependency added/removed | References (and Summary/Notes if behaviour changes) |

**Tooling** — see tools/docs/gen_module_specs.py (scaffold/refresh) and tools/validate/cag_validate.py (validation). gen_module_specs.py refreshes source-derived sections but preserves manual Summary and Notes.

**Anti-patterns:** reintroducing src/<module>/AGENT.md; leaving Summary as one generic sentence; listing items that no longer exist; TODO placeholders in committed specs.

## Companion File Index

None — all guidance is inline.

## References

- docs/specs/ — module reference files
- tools/docs/gen_module_specs.py — scaffold and regenerate
- tools/validate/cag_validate.py — validate format
