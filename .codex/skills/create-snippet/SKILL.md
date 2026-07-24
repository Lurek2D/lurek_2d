---
name: create-snippet
description: "Load this skill when creating or modifying Lua snippets and generated VS Code snippet output. Skip it for full examples, docs pages, or extension features unrelated to snippets."
---

# create-snippet

## Mission
- Create or modify snippets that reflect idiomatic public API usage and generated editor output.

## Domain Knowledge
- Snippet sources live in `content/snippets/<module>.lua`.
- `tools/snippets/gen_vscode_snippets.py` currently writes `lurek_2d_extension/vscode/data/snippets.json`.
- The generated JSON is output. The Lua catalog is the source of truth.
- The active extension manifest consumes `lurek_2d_extension/data/snippets.json`; it is a separate path from the current generator output.
- A marker block uses this order: `@snippet`, `@prefix`, `@module`, `@description`, `@body`, `@end`.
- The `@module` value must match the source file stem.
- A public prefix uses `lk-<module>-<name>`.
- Every prefix must be unique across the full catalog.
- A description explains the inserted result and has at least 20 characters.
- A useful snippet joins at least two distinct `lurek.*` calls into one small task.
- Every public API name in a snippet must exist in generated API docs.
- Snippet code must be valid for LuaJIT. Lua 5.3-only syntax is not allowed.
- `SNIP_<index>_<name>` becomes an editor tab stop during generation.
- Placeholder indices define cursor order. The first user decision has the lowest index.
- Repeated decisions may reuse one placeholder index and name.
- Placeholder names describe user input, such as `speed` or `texture_path`.
- A body must show required callback scope, local state, asset path, and setup.
- Quotes, backslashes, dollar signs, and indentation are escaped in generated JSON.
- Source validation does not prove editor insertion behavior.
- Snippets provide reusable insertion, not a complete runnable example.
- `content/snippets/_template.lua` documents marker syntax and is excluded from catalog parsing.
- `snippet_catalog.py` reads namespace files in sorted filename order.
- An incomplete marker block or missing `@end` is a parser error, not a partial snippet.
- The validator rejects an empty body even when all metadata markers are valid.
- `SNIP_<index>_<name>` is generated as `${index:name}` in VS Code snippet JSON.
- Generated snippet titles use `<module>: <prefix>`, so module and prefix wording affects editor discovery.

## Workflow
1. Read `content/snippets/AGENTS.md` and the target module catalog.
2. Run snippet coverage and select one missing user task.
3. Check generated API docs for every `lurek.*` name used by the task.
4. Search all snippet sources for the planned prefix and similar bodies.
5. Choose a unique `lk-<module>-<name>` prefix.
6. List user decisions in the order they should be edited.
7. Assign stable `SNIP_<index>_<name>` placeholders to those decisions.
8. Write a short body with at least two distinct public API calls.
9. Include required callback, local state, asset path, and setup context.
10. Add the marker block in the required marker order.
11. Run `tools/snippets/gen_vscode_snippets.py`.
12. Inspect the generated entry in `lurek_2d_extension/vscode/data/snippets.json`.
13. Check its label, prefix, description, module, escaping, indentation, and tab-stop order.
14. Run snippet validation and snippet coverage.
15. Build the extension consumer when generated JSON changed.
16. Insert the snippet into a Lua file through the editor.
17. Replace every placeholder with a representative value.
18. Run or smoke the inserted Lua code in its expected callback.
19. Fix the source catalog and repeat generation if insertion behavior is wrong.

## References
- `contracts: content/snippets/AGENTS.md, docs/AGENTS.md, lurek_2d_extension/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "content snippets API usage" --profile game --limit 10, tools/python.cmd tools/audit/snippet_coverage.py, tools/python.cmd tools/snippets/gen_vscode_snippets.py, tools/python.cmd tools/validate/validate_snippets.py --vscode-snippets lurek_2d_extension/data/snippets.json`
- `agent: doc_writer`
- RAG: `content snippets <module> API usage`; inspect the source catalog, generated JSON entry, neighboring prefixes, canonical examples, and extension consumer.
