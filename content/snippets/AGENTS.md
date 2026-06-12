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
- Avoid Lua 5.4-only syntax; keep LuaJIT compatibility.
- Body placeholders use `SNIP_<index>_<name>`.

## Workflow
- Run `python tools/snippets/gen_vscode_snippets.py`.
- Run `python tools/audit/snippet_coverage.py`.
