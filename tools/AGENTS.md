# Tools Contract

This file adds local rules for work under `tools/`.

## Mission
- Own scripts, validation, packaging helpers, CI support, and tool documentation.
- Keep automation reproducible from the repository itself.

## Scope
- `tools/` scripts and command-line helpers.
- Validation scripts, packaging helpers, and release support.
- Tool docs, script entry points, and repo automation glue.

## Local map
- `audit/` and `validate/` are policy gates; edits there change what the repo accepts.
- `rag/` owns repository retrieval and must stay aligned with the mandatory search workflow in the root `AGENTS.md`.
- `docs/` and `snippets/` are generator layers; prefer fixing source generators over hand-editing generated outputs.
- `demos/`, `dist/`, and `mods/` are operator-facing helpers for runnable artifacts and packaging.
- `dev/` contains local orchestration helpers for repeatable cargo workflows.
- `github/` contains migration and sync helpers for the legacy prompt/agent layer.
- `gen_all_docs.py` is the umbrella docs pipeline entrypoint.
- `agent_cli_reference.md` is the quickest local reference when a tool change affects how Codex or operators invoke repo automation.

## Local rules
- Prefer checked-in scripts and explicit commands over hidden CI-only logic.
- Keep local workflows, packaging scripts, and CI behavior aligned.
- Update tool docs when script behavior changes.
- Record platform assumptions and cache assumptions when they matter.
- Keep generated or cached outputs out of source control unless they are part of the contract.

## Workflow
- Read the script or CLI entry point before editing supporting helpers.
- Load `build-system`, `ci-cd-pipeline`, `cross-platform`, and `quality-pipeline` when the task touches automation.
- Validate the narrowest command path first, then the broader release or CI gate.
- Update docs whenever the operator flow or command contract changes.

## Expected outputs
- Script or automation changes with reproducible validation proof.
- Updated tool docs when behavior changes.

## Anti-patterns
- Hide repo logic inside CI-only shell fragments.
- Depend on untracked local machine state.
- Change scripts without checking the narrow command path first.

## References
- `tools/README.md`
- `.github/workflows/`
- `.vscode/`
