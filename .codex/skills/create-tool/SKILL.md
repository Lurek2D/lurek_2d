---
name: create-tool
description: "Load this skill when creating or modifying tools under tools, audit scripts, validators, generators, or CLI registry entries. Skip it for product runtime changes or one-off local scripts that should stay in work/."
---

# create-tool

## Mission
- Create or modify repo tools so they are discoverable, documented, locally runnable, and registered.

## Domain Knowledge
- Repository tools live under `tools/`.
- Tool families include `audit`, `validate`, `docs`, `demos`, `rag`, `snippets`, `ui`, and `dist`.
- `tools/python.cmd` is the supported Python launcher on Windows.
- A tool must work from the workspace root with Windows paths.
- An audit reads repository state and reports findings. It does not mutate source.
- A validator checks a contract and exits nonzero when the contract is broken.
- A generator derives owned output from canonical source.
- A fixer changes source or configuration and is a mutating command.
- One command must not hide mutation inside audit or validator mode.
- Parser rules for filenames, markers, registries, and schemas are repository contracts.
- Parser contract changes keep the nearest `AGENTS.md`, skill, fixtures, and tests in sync.
- Machine output needs deterministic ordering and stable exit codes.
- Diagnostics use workspace-relative paths and name the exact broken rule.
- Clean success output stays quiet unless the command promises a report.
- A mutating tool validates its full target set before the first write.
- A broad mutating tool needs a dry-run or preview mode.
- A tool must reject resolved targets outside the workspace.
- An unchanged second generator run must create no diff.
- Timestamps and unordered traversal must not change generated files.
- Python tool tests live under `tests/python`.
- Tests call parser or CLI behavior with realistic fixtures.
- `tools/agent_cli_reference.md` is the registry for agent-facing commands.
- Registry entries and help text must match real command behavior.
- Tool dependencies stay minimal and are documented where the command is registered.
- Light syntax, parser, and link checks run before heavy Cargo compilation.
- Module audit CLIs accept the module as a positional argument unless their parser documents a named flag.
- Audit diagnostics include exact files and line numbers when the parser can provide them.
- A banned pattern is valid only when the repo defines a replacement or a narrow exception.
- Profiling and stress tools use release builds.
- Parsers that consume stored test logs remain compatible with historical log shapes.

## Workflow
1. Read `tools/AGENTS.md` and the nearest tool-family contract.
2. Classify the command as audit, validate, generate, fix, package, or developer helper.
3. Search for the existing owner of the same input format or repository contract.
4. Extend that owner when possible instead of adding a competing command.
5. Define inputs, outputs, mutation policy, exit codes, and diagnostic format.
6. Define dry-run behavior before implementing a mutating command.
7. Define deterministic ordering and workspace-relative path output.
8. Inspect nearby fixtures and tests under `tests/python`.
9. Implement the command with useful `--help` text.
10. Use shared parsers from the same tool family when they already exist.
11. Add tests for clean input, one violation, multiple violations, malformed input, and empty input.
12. Add Windows separator and encoding cases when paths or text are parsed.
13. Test dry-run and target validation for every mutating command.
14. Run the command through `tools/python.cmd` from the workspace root.
15. Use a small real repository slice and inspect the full output.
16. Update the nearest contract, skill, fixture, or schema when parser rules changed.
17. Update `tools/agent_cli_reference.md`.
18. Run focused Python tests and `tool_registry_audit.py`.
19. Run a generator twice and require the second run to leave no diff.
20. Review dry-run and real-run diffs for a mutator.
21. Confirm audit and validator ordering and exit codes for clean and failing cases.
22. Run CAG validation when the command changes agent-facing contracts.

## References
- `contracts: tools/AGENTS.md, tools/audit/AGENTS.md`
- `tools: tools/python.cmd tools/rag/query.py "tools audit validator CLI registry" --profile engine --limit 10, tools/python.cmd tools/audit/tool_registry_audit.py, tools/python.cmd tools/validate/cag_validate.py`
- `agent: builder`
- RAG: `tools <family> audit validator CLI registry`; inspect the nearest tool family, `tests/python/`, `tools/agent_cli_reference.md`, and the parser-owned contract.
