---
name: create-build
description: "Create or update build (release, debug, dist) settings."
---
# create-build

## Goal
- Modify Cargo profiles, feature flags, or distribution scripts to optimize the build process.

## Required inputs
- Target environment (debug, release, dist)
- Desired build characteristic (e.g., smaller binary, faster compile)
- User must specify what needs optimization
- Agent must collect current `Cargo.toml` profiles and build scripts

## Profile hint
- `builder`

## Load these skills
- `build-system`
- `ci-cd-pipeline`

## Steps
- Load skills: build-system, ci-cd-pipeline.
- Open `Cargo.toml` or `tools/dist/` scripts and apply the specific requested build configuration changes.
- Execute `cargo build --profile <target>`. If compilation fails (exit code >0), revert the unstable flags and repeat step 2.
- Measure the binary output size or compile times via OS stat commands. If the metric has not improved by the target percentage, tweak flags and repeat step 3.
- Document the profile improvements in `CONTRIBUTING.md`.

## Outputs
- Modified `Cargo.toml` or dist scripts
- Build metrics report

## Success criteria
- [ ] `cargo build --profile <target>` exits with code 0.
- [ ] Binary size or compilation time metric shows an improvement >0% compared to baseline.

## Stop conditions
- Enabling features that break cross-platform compatibility.
- Using unstable Rust features that require nightly.

## References
- `skills: build-system, ci-cd-pipeline`
- `tools: cargo build --profile`
- `agent: Build-Engineer`

## Invocation rules
- This is a user-invoked workflow. Do not auto-load it as a generic background skill.
- Start only after the user explicitly requests this named workflow or a clearly equivalent task.

