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
- Prefer `python tools/dev/parallel_cargo.py` over raw `cargo` for repo-standard build, fmt, clippy, test, and doc flows.
- Keep quality gates ordered from cheapest to most expensive when you document or automate them.
- Generated artifacts should land in the same change as the source or generator update that produced them.
- Windows is the primary local platform; document any Linux-only or PowerShell-only path explicitly in tool docs.
- Prefer repo-relative path handling and avoid hardcoded separator or drive-specific assumptions when tool work affects runtime-facing paths.
- If CI or release automation is added, define the quality stages before the packaging stages and keep the sequence readable as named steps rather than long inline shell blocks.
- There is currently no committed `.github/workflows/` directory. Any CI workflow added from tool work should assume a fresh setup rather than patching an existing pipeline.
- Pin build-tool versions explicitly in automation instead of using floating `latest` tags.
- Keep local packaging layout and CI artifact layout identical so release outputs can be compared structurally.

## Workflow
- Read the script or CLI entry point before editing supporting helpers.
- Use this file, the touched script entry point, and any relevant README or architecture note as the source of truth for automation work.
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
