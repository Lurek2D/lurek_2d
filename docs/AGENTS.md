# Docs Contract

Adds local rules for `docs/`.

## Mission & Scope
- Manage engine docs: specs, design docs, API reference, and contribution guides.
- Keep source code, Lua annotations, and generated Markdown docs aligned.

## Files
- `specs/`: Per-module specs for boundaries, rules, and Lua API signatures.
- `architecture/`: System design docs and core platform constraints.
- `api/`: Generated Lua types and Markdown API references.
- `templates/`: Doc templates for contracts, specs, and playbooks.

## Rules
- Do not edit generated API document outputs directly; update Rust doc comments under `src/lua_api/` and rebuild them.
- Keep Markdown file links functional; verify that document moves or renames do not break links.
- When expanding specifications, preserve hand-written `## Summary` sections across regenerations.
- Contributor docs must target developers and modders and explain constraints clearly.

## Workflow
- Start from the nearest nested docs contract before subtree-specific changes.
- Run the strict link checker after doc moves, renames, or structural edits that can affect references.
- Rebuild generated API references only when editing binding doc comments or generated-doc inputs.

## References
- `docs/specs/`
- `CONTRIBUTING.md`
- `README.md`
