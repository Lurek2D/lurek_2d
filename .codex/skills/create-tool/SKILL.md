---
name: create-tool
description: "Load this skill when creating or modifying tools under tools, audit scripts, validators, generators, or CLI registry entries. Skip it for product runtime changes or one-off local scripts that should stay in work/."
---

# create-tool

## Mission
- Create or modify repo tools so they are discoverable, documented, locally runnable, and registered.

## Domain Knowledge
- Repository tools are grouped by function under `tools/audit`, `validate`, `docs`, `demos`, `rag`, `snippets`, `ui`, and `dist`; a new command belongs with the data contract it parses or emits, not in a generic utility bucket.
- `tools/python.cmd` is the supported Windows Python launcher and preserves the repository runtime; scripts should not assume a globally configured interpreter or Unix shell behavior.
- Audit tools report evidence without mutation, validators enforce a contract, generators derive owned output, and fixers mutate source. Mixing these modes makes automation unsafe and obscures what a command promises.
- Parser-enforced filenames, markers, registries, and schemas become repository contracts; their owning `AGENTS.md`, skill, fixtures, and validator self-tests must evolve together.
- Machine-consumable output needs deterministic ordering, stable exit codes, relative workspace paths, and a quiet success path; human diagnostics need exact targets and actionable reasons.
- Mutation tools should compute and validate the complete target set before the first write, expose dry-run or preview when changes are broad, and avoid following paths outside the workspace through unresolved inputs.
- Generator freshness is a two-run property: the first run may update outputs, while an unchanged second run must produce no diff. Non-idempotence usually indicates ordering, timestamps, or source/output feedback loops.
- Tool self-tests belong under `tests/python` and should exercise parser contracts through realistic fixtures rather than importing private constants alone, so CLI behavior and diagnostics remain covered.

## Workflow
- Classify the command as audit, validate, generate, fix, package, or developer helper; inspect the nearest parser, fixtures, self-tests, and CLI registry to extend an owner instead of introducing a competing entry point.
- Specify inputs, workspace-relative outputs, mutation policy, stdout/stderr format, exit codes, dry-run or confirmation behavior where relevant, and Windows path/encoding cases before implementation; keep shared parsing in an existing family module when one exists.
- Implement `--help` and deterministic behavior, add Python `unittest` coverage for success, malformed input, empty input, path separators, and idempotence or dry-run semantics, then exercise the command through `tools/python.cmd` from the workspace root.
- Update `tools/agent_cli_reference.md` and any parser-owned contract/template, run focused self-tests and `tool_registry_audit.py`, then use the tool on a real repository slice and run CAG validation when its shape changes agent guidance.
- For mutating commands, review a dry-run and real-run diff, rerun to prove idempotence, and verify malformed or out-of-workspace paths fail before any partial write.
- For audits and validators, test stable diagnostic ordering and exit status with zero, one, and multiple violations so CI/agent consumers distinguish clean output from parser failure.

## References
- `contracts: tools/AGENTS.md, tools/audit/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "tools audit validator CLI registry" --profile engine --limit 10, tools/python.cmd tools/audit/tool_registry_audit.py, tools/python.cmd tools/validate/cag_validate.py`
- `agent: builder`
- RAG: Start with: `tools audit validator CLI registry`, `tool registry audit agent cli reference`, `cag validate baseline prompts skills agents`; Focus areas first: `tools/`, `tools/audit/`, `tools/validate/`, `tools/tests/`, root `AGENTS.md`; Append the tool family or script name such as `rag`, `audit`, `validate`, `mcp`, `snippets`
