# Docs Contract

Covers work under `docs/`.

## Mission & Scope
- Manage the engine documentation architecture, including specifications, design documents, APIs reference, and contribution guidelines.
- Enforce consistency rules between source code implementation, Lua annotations, and generated Markdown docs.

## Files
- `specs/`: Per-module specification files detailing boundaries, rules, and Lua API signatures.
- `architecture/`: Holds system design diagrams and core platform constraints.
- `api/`: Output directories for generated Lua types definitions and Markdown references.
- `templates/`: Document structures blueprints for contracts, specs, and playbooks.

## Rules
- Do not edit generated API document outputs directly; update Rust doc comments under `src/lua_api/` and rebuild them.
- Keep Markdown file links functional; verify that document moves or renames do not break links.
- When expanding specifications, preserve hand-written `## Summary` sections across regenerations.
- Contributor documentation must target developers and modders, explaining technical constraints clearly.

## Workflow
- Verify doc link coverage and document formatting by running the link checker.
- Rebuild API references using `python tools/gen_all_docs.py` after editing binding doc comments.

## References
- `docs/specs/`
- `CONTRIBUTING.md`
- `README.md`
