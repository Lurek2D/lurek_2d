# Snippets Contract

Adds local rules for `content/snippets/`.

## Mission & Scope
- Own source snippets that compile into IDE autocomplete templates and VS Code extensions.
- Keep tag markers and syntax templates valid.
- Provide practical multi-call recipes for common gameplay or layout patterns.

## Files
- `_template.lua`: Reference guide showing correct snippet marker ordering and syntax conventions.
- `*.lua`: Namespace snippet libraries such as `render.lua`, `ui.lua`, and `input.lua`.

## Rules
- Every snippet block must use this tag order: `@snippet`, `@prefix`, `@module`, `@description`, `@body`, `@end`.
- Snippets must compose at least two distinct `lurek.*` function calls; do not write trivial single-line or wrapper-only code.
- Autocomplete prefixes must use `lk-<module>-<name>` in lowercase hyphen form.
- Do not use Lua 5.4-specific operators (like binary `~`); use the `bit` library to preserve LuaJIT compatibility.
- Placeholders in the body must use the format `SNIP_<index>_<name>` to enable VS Code tab-stop conversion.

## Workflow
- Regenerate the VS Code snippets file by running `python tools/snippets/gen_vscode_snippets.py`.
- Run `python tools/audit/snippet_coverage.py` to check which public namespaces lack snippet coverage.

## References
- content/snippets/_template.lua
- tools/snippets/gen_vscode_snippets.py
- tools/audit/snippet_coverage.py
