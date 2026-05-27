---
description: "Run a full snippet-development workflow with module-level coverage gates and VS Code output generation."
---
# Workflow Snippet Development

## Goal
- Drive one snippet batch from scoped request to validated completion.

## Inputs
- Snippet goal.
- Target modules.
- Coverage expectation (module-level).
- Required final gate.

## Steps
1. Load [skill: examples-management](../skills/examples-management/SKILL.md), [skill: documentation](../skills/documentation/SKILL.md), and [skill: vscode-extension](../skills/vscode-extension/SKILL.md) before acting.
2. Normalize the request into goal, constraints, out-of-scope items, and proof needed to call it done.
3. Author handcrafted snippets in `content/snippets/<module>.lua` using strict marker blocks:
   - `-- @snippet <symbol>`
   - `-- @prefix <trigger>`
   - `-- @module <module>`
   - `-- @description <text>`
   - `-- @body`
   - body lines with source token placeholders (`SNIP_<index>_<name>`)
   - `-- @end`
   Start from `content/snippets/_template.lua` for new blocks.
4. Require snippets to be reusable building blocks that chain multiple APIs, not single-call examples.
5. Regenerate VS Code output with `python tools/snippets/gen_vscode_snippets.py`.
6. Validate structure with `python tools/validate/validate_snippets.py`.
7. Measure module-level coverage with `python tools/audit/snippet_coverage.py`.
8. Update docs/changelog sync artifacts for touched scope.

## Success Criteria
- [ ] The workflow outcome is complete: Drive one snippet batch from scoped request to validated completion.
- [ ] Snippet source files and generated VS Code snippets are in sync.
- [ ] Validation and module-level coverage outputs are attached.
- [ ] Remaining blockers or risks are explicit.

## Anti-patterns
- Writing API one-liners that are not useful building blocks.
- Auto-generating large snippet batches without manual rationale.
- Shipping snippet markers without placeholders for user parameters.
- Updating `extensions/vscode/data/snippets.json` manually instead of using the generator.
- Closing without running both validator and coverage audit.

## Example Invocation
- /workflow-snippet-development modules=render,input,ui coverage=4-snippets-per-module

## CAG Metadata
Mode: agent
Loads skills: examples-management, documentation, vscode-extension
Inputs required: Snippet goal., Target modules., Coverage expectation (module-level)., Required final gate.
