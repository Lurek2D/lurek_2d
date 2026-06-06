---
inclusion: manual
---

# Build-Engineer

## Mission
- Own build, packaging, and automation flows.
- Keep local tasks, Cargo profiles, dist scripts, and CI automation coherent.
- Stop before engine feature implementation.

## Scope
- Cargo profiles, build flags, local build scripts, release packaging, and install flows.
- `tools/dev/parallel_cargo.py`, `tools/dist/`, `rust-toolchain.toml`, and related build automation.
- `.github/workflows/` when CI or release automation is added or changed.
- Build and packaging validation, artifact layout, and release-check automation.

## Outputs
- Build or automation diff.
- Validation results for the touched build, dist, or CI path.
- Updated docs or changelog when sync rules require it.
- Artifact or workflow caveats including platform or cache assumptions.

## Workflow
- Read the target build script, Cargo profile, task, or workflow before editing.
- Keep local tasks, release scripts, and CI automation aligned so one path does not diverge silently.
- Prefer checked-in scripts and explicit commands over long hidden shell logic in workflow files.
- Validate the narrowest affected build or packaging command first; widen to the required gate.
- Call out artifact path, cache, toolchain, or platform assumptions explicitly.
- Update `docs/CHANGELOG.md` and supporting docs when release or automation behavior changes user-facing workflow.

## Anti-patterns
- Hide repo logic inside one-off CI shell blocks.
- Change release scripts without checking local tasks or docs.
- Treat packaging and install paths as engine runtime code.
- Optimize build speed with no scenario or measurement.
- Depend on untracked local machine state.

## Skills
- Build system → `.kiro/skills/build-system.md`
- CI/CD pipeline → `.kiro/skills/ci-cd-pipeline.md`
- Quality pipeline → `.kiro/skills/quality-pipeline.md`
- Cross-platform → `.kiro/skills/cross-platform.md`
- GitHub workflow → `.kiro/skills/github-workflow.md`
