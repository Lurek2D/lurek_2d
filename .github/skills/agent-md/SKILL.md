---
name: agent-md
description: "Load this skill when creating or maintaining merged module reference specs in docs/specs/<module>.md. It owns the required section structure, sync contract, and scaffold+validate workflow after the retirement of src/<module>/AGENT.md. Skip it for writing production Rust code, tests, or Lua scripts."
---

# Module Reference Authoring and Maintenance Skill

## Single-Source System

Every engine module now uses one canonical documentation file:

| File | Purpose | Content |
|------|---------|---------|
| `docs/specs/<module>.md` | Merged module reference | General Info, Summary, Files, Types, Functions, Lua API Reference, References, Notes |

`src/<module>/AGENT.md` has been retired. Agents should load `docs/specs/<module>.md` directly when they need module context.

## Load When

- Creating a new `docs/specs/<module>.md` for a new engine module
- Updating a module reference after changing source files, public types, public functions, or Lua bindings
- Running `tools/audit/validate_agent_md.py` to validate the merged module reference format
- Running `tools/docs/gen_module_specs.py` to regenerate the collected sections from source
- Reviewing whether a module reference still matches its Rust source and Lua wrapper

## Owns

- Required section structure for `docs/specs/<module>.md`
- `tools/docs/gen_module_specs.py` generation workflow
- `tools/audit/validate_agent_md.py` validation workflow
- Sync contract between module specs, Rust source, docstrings, and `src/lua_api/<module>_api.rs`

## Does Not Cover

- Writing production Rust code → use `rust-coding` skill
- Writing or reviewing Lua API Rust bindings → use `lua-api-design` or `lua-rust-bridge`
- End-to-end module quality audits → use `module-audit` skill

## Purpose

The merged spec is the canonical module reference an agent reads before working in a module. It combines the old overview content and the former deep spec content in one file so agents no longer need to chase two documentation layers.

Scripts may scaffold and refresh the source-derived sections, but the Summary and Notes remain manual prose. The goal is a reference that stays accurate enough for automated checks while still carrying module-specific design context that only a human or focused agent can write well.

Validate with: `python tools/audit/validate_agent_md.py --module <name>`
Regenerate with: `python tools/docs/gen_module_specs.py --module <name>`

## Required Format (`docs/specs/<module>.md`)

The merged module reference must contain these sections in order:

1. `# <module>`
2. `## General Info`
3. `## Summary`
4. `## Files`
5. `## Types`
6. `## Functions`
7. `## Lua API Reference`
8. `## References`
9. `## Notes`

### `## General Info`

Keep this short and factual. Minimum fields:
- Module group
- Source path
- Lua API path(s)
- Primary Lua namespace
- Rust test path(s)
- Lua test path(s)

### `## Summary`

- Several paragraphs of plain text
- Explain the module's purpose, scope boundary, and why its responsibilities live here
- Start from the prior AGENT.md purpose text when migrating, then expand it manually from the actual source code
- Write module by module; do not mass-generate vague summaries

### `## Files`

- One bullet per `.rs` file under `src/<module>/`
- Format: `- \`file.rs\`: purpose`
- Source-derived and safe to regenerate

### `## Types`

- One bullet per public Rust type (`struct`, `enum`, `trait`, `type`)
- Format: `- \`TypeName\` (\`kind\`, \`file.rs\`): purpose`
- Source-derived and safe to regenerate

### `## Functions`

- One bullet per public Rust function or method that the source scanner finds
- Format: `- \`Type::method\` (\`file.rs\`): purpose`
- Source-derived and safe to regenerate

### `## Lua API Reference`

- Include binding path(s) and namespace when present
- List module functions and UserData methods as bullets
- Must stay aligned with `src/lua_api/<module>_api.rs`

### `## References`

- One bullet per module dependency or closely related module
- Explain relationship and separation of duties
- Source-derived list can be regenerated, but the notes may need manual refinement

### `## Notes`

Capture anything important that does not fit above:
- External crate constraints
- Hardware or OS-specific behavior
- Known omissions or sharp edges
- Migration warnings
- Practices future editors should not infer from the generated sections alone

## Sync Contract

Keep `docs/specs/<module>.md` synchronized with:

| What changes | What to update |
|--------------|----------------|
| New `.rs` file added | `## Files` |
| Public type added/removed | `## Types` |
| Public function added/removed | `## Functions` |
| Lua binding added/renamed/removed | `## Lua API Reference` |
| Dependency added/removed | `## References` and, if behavior changes, `## Summary` or `## Notes` |
| Scope boundary changed | `## Summary` and `## Notes` |
| Tests moved or renamed | `## General Info` |

## Scaffolding vs Manual Prose

`tools/docs/gen_module_specs.py` refreshes the source-derived sections and preserves manual Summary and Notes text when it already exists.

The Summary should not be treated as boilerplate. It must be reviewed and expanded module by module using the actual source code. The generated structure is only the starting point.

## Anti-Patterns

- Reintroducing `src/<module>/AGENT.md` as a second source of truth
- Leaving Summary as one generic sentence after regeneration
- Listing files, types, or functions that no longer exist
- Copying Lua API descriptions without checking `src/lua_api/<module>_api.rs`
- Treating the generated sections as a substitute for Notes when important caveats exist
- Leaving `TODO:` placeholders in committed module references
