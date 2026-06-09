# Snippets Contract

Covers work under `content/snippets/`.

## Mission & Scope
- Own source code snippets that compile into IDE autocomplete templates and VS Code extensions.
- Maintain correct structural tag markers and parseable syntax templates across all snippet modules.
- Provide practical multi-call recipes showcasing common gameplay or layout patterns.

## Files
- `_template.lua`: Reference guide showing correct snippet marker ordering and syntax conventions.
- `*.lua`: Namespace-specific snippet libraries (e.g., `render.lua`, `ui.lua`, `input.lua`).

## Rules
- Every snippet block must strictly use the tag ordering: `@snippet`, `@prefix`, `@module`, `@description`, `@body`, and `@end`.
- Snippets must compose at least two distinct `lurek.*` function calls; do not write trivial single-line or wrapper-only code.
- Autocomplete prefixes must follow the `lk-<module>-<name>` lowercase hyphenated naming standard.
- Do not use Lua 5.4-specific operators (like binary `~`); use the `bit` library to preserve LuaJIT compatibility.
- Placeholders in the body must use the format `SNIP_<index>_<name>` to enable VS Code tab-stop conversion.

## Workflow
- Regenerate the VS Code snippets file by running `python tools/snippets/gen_vscode_snippets.py`.
- Run `python tools/audit/snippet_coverage.py` to check which public namespaces lack snippet coverage.

## References
- content/snippets/_template.lua
- tools/snippets/gen_vscode_snippets.py
- tools/audit/snippet_coverage.py
