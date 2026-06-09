# Snippets Contract

Covers work under `content/snippets/`.

## Mission
- Own source snippets that feed editor tooling.
- Keep snippet metadata parseable and useful to non-AI users.

## Scope
- `content/snippets/*.lua`.
- Snippet marker syntax and extension-facing snippet source content.

## Local map
- `content/snippets/*.lua` is the source of truth.
- `content/snippets/_template.lua` is the template.

## Rules
- Keep marker order exact: `@snippet`, `@prefix`, `@module`, `@description`, `@body`, body, `@end`.
- Treat snippets as reusable gameplay building blocks.
- Use placeholders so the inserted snippet stays editable in VS Code.
- Generated extension artifacts are downstream outputs.

## Workflow
- Regenerate the extension snippet output with `python tools/snippets/gen_vscode_snippets.py` after changing snippet source format or inventory.
- Use `python tools/audit/snippet_coverage.py` when the task is snippet coverage.

## References
- `content/snippets/_template.lua`
- `tools/snippets/gen_vscode_snippets.py`
- `tools/audit/snippet_coverage.py`
