---
name: create-snippet
description: "Load this skill when creating or modifying Lua snippets and generated VS Code snippet output. Skip it for full examples, docs pages, or extension features unrelated to snippets."
---

# create-snippet

## Mission
- Create or modify snippets that reflect idiomatic public API usage and generated editor output.

## Domain Knowledge
- `content/snippets/<module>.lua` is the source catalog; `tools/snippets/gen_vscode_snippets.py` parses marker blocks into `../lurek_2D_extension/vscode/data/snippets.json`, so emitted JSON is never the editing surface.
- A snippet is a compositional recipe rather than a one-call API example: it should connect at least two `lurek.*` calls into a useful editor insertion while remaining small enough to adapt.
- Prefixes are user-facing identifiers and must remain unique and discoverable; module names drive catalog grouping and must match the source filename used by the parser.
- `SNIP_<index>_<name>` placeholders encode edit order before generation into editor tab stops. Duplicate indices, missing primary placeholders, or unstable names degrade insertion even if JSON validates.
- Snippet bodies target LuaJIT syntax and must make assumptions—callback scope, prerequisite state, asset path, or lifecycle placement—visible in the inserted code rather than hidden in generator context.
- Placeholder names should describe the user's decision rather than implementation trivia; stable semantic names make repeated tab stops understandable and reduce accidental inconsistent edits across the inserted recipe.
- Generated JSON escaping can change literal backslashes, quotes, dollar signs, and indentation, so correctness must be judged from an actual insertion rather than only the Lua-like source block.
- Coverage should prioritize repeated authoring tasks with meaningful setup cost, not mechanically add a snippet for every API that already has a concise example or completion signature.

## Workflow
- Use snippet coverage and generated API docs to find a high-value workflow gap, then inspect neighboring prefixes and bodies so the new recipe complements rather than paraphrases an existing snippet or example.
- Design the insertion from the editor user's cursor path: choose a specific unique prefix, order placeholders by the edits a user makes, include lifecycle context and prerequisites, and combine only verified generated API names.
- Write the canonical marker block in the matching module source, generate VS Code JSON, and inspect the emitted label, description, escaped body, placeholder/tab-stop order, and module grouping rather than trusting parser success.
- Run snippet validation and coverage, build the extension consumer, and manually insert the snippet into a Lua file to verify syntax, indentation, placeholder navigation, and that the resulting code can fit a real Lurek callback/module.
- Test prefix collision and discovery in the extension catalog, confirming the intended snippet appears under the right module and does not shadow a more common recipe with an overly broad prefix.
- Execute or smoke the inserted Lua after replacing placeholders with representative values, catching missing locals, invalid callback placement, asset assumptions, and generated escaping that static snippet validation cannot see.

## References
- `contracts: content/snippets/AGENTS.md, docs/AGENTS.md, ../lurek_2D_extension/vscode/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "content snippets API usage" --profile game --limit 10, tools/python.cmd tools/audit/snippet_coverage.py, tools/python.cmd tools/snippets/gen_vscode_snippets.py, tools/python.cmd tools/validate/validate_snippets.py --vscode-snippets ../lurek_2D_extension/vscode/data/snippets.json`
- `agent: doc_writer`
- RAG: Use when locating snippet sources and generated output; `content snippets API usage`; `snippets json generated extension`; `template placeholder trigger description`; `../lurek_2D_extension/`; snippet source files in `tools/` or `docs/`; generated snippet output; user-facing examples
