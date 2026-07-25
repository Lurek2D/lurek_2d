# Snippets Contract

## Mission & Scope
- Own snippet sources that generate IDE autocomplete templates.
- Keep snippets practical, LuaJIT-safe, and covered by generation audits.

## Files
- `_template.lua`: Marker order and syntax guide.
- `*.lua`: Namespace snippet libraries.

## Rules
- Use marker order: `@snippet`, `@prefix`, `@module`, `@description`, `@body`, `@end`.
- Snippets must combine at least two distinct `lurek.*` calls.
- Prefixes use lowercase `lk-<module>-<name>`.
- `@module` must match the source file stem, descriptions need at least 20 characters, and each body needs a `SNIP_<index>_<name>` placeholder.
- Avoid Lua 5.4-only syntax; keep LuaJIT compatibility.

## Workflow
- Run `tools/python.cmd tools/snippets/gen_vscode_snippets.py`.
- Run `tools/python.cmd tools/audit/snippet_coverage.py`.
- Run `tools/python.cmd tools/validate/validate_snippets.py`.
