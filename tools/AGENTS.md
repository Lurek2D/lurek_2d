# Tools Contract

Covers work under `tools/`.

## Mission
- Own scripts, validation, packaging helpers, CI support, and tool documentation.
- Keep automation reproducible from the repository itself.

## Scope
- `tools/` scripts and command-line helpers.
- Validation scripts, packaging helpers, and release support.

## Local map
- `audit/` and `validate/` are policy gates.
- `rag/` owns repository retrieval and must match the root search workflow.
- `docs/` and `snippets/` are generator layers.
- `demos/`, `dist/`, and `mods/` are operator-facing helpers.
- `dev/` contains local orchestration helpers.
- `github/` contains migration and sync helpers.
- `gen_all_docs.py` is the umbrella docs pipeline entrypoint.

## Rules
- Prefer checked-in scripts and explicit commands over hidden CI-only logic.
- Keep local workflows, packaging scripts, and CI behavior aligned.
- Update tool docs when script behavior changes.
- Record platform and cache assumptions when they matter.
- Keep generated or cached outputs out of source control unless they are part of the contract.
- Prefer `python tools/dev/parallel_cargo.py` over raw `cargo` for repo-standard build, fmt, clippy, test, and doc flows.
- Keep quality gates ordered from cheapest to most expensive.
- Generated artifacts should land in the same change as the source or generator update.
- Windows is the primary local platform.
- Prefer repo-relative path handling.
- If CI or release automation is added, define quality stages before packaging stages.
- There is currently no committed `.github/workflows/` directory.
- Pin build-tool versions explicitly.
- Keep local packaging layout and CI artifact layout identical.

## Workflow
- Read the script or CLI entry point before editing supporting helpers.
- Use this file, the touched script entry point, and any relevant README or architecture note as the source of truth.
- Validate the narrowest command path first, then the broader release or CI gate.
- Update docs whenever the operator flow or command contract changes.

## References
- `tools/README.md`
- `.github/workflows/`
- `.vscode/`
