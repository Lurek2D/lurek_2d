---
name: create-build
description: Create or update build (release, debug, dist) settings.
---

# GOAL
- Modify Cargo profiles, feature flags, or distribution scripts to optimize the build process.

# INPUTS REQUIRED
- Target environment (debug, release, dist)
- Desired build characteristic (e.g., smaller binary, faster compile)
= User must specify what needs optimization
- Agent must collect current `Cargo.toml` profiles and build scripts

# STEPS TO DO
1. Load skills: build-system, ci-cd-pipeline.
2. Open `Cargo.toml` or `tools/dist/` scripts and apply the specific requested build configuration changes.
3. Execute `cargo build --profile <target>`. If compilation fails (exit code >0), revert the unstable flags and repeat step 2.
4. Measure the binary output size or compile times via OS stat commands. If the metric has not improved by the target percentage, tweak flags and repeat step 3.
5. Document the profile improvements in `CONTRIBUTING.md`.

# OUTPUTS PROVIDED
- Modified `Cargo.toml` or dist scripts
- Build metrics report

# SUCCESS CRITERIA
- [ ] `cargo build --profile <target>` exits with code 0.
- [ ] Binary size or compilation time metric shows an improvement >0% compared to baseline.

# ANTI-PATTERNS
- Enabling features that break cross-platform compatibility.
- Using unstable Rust features that require nightly.

# EXAMPLE INVOCATION
- User: "request for this prompt"
- Agent: Runs this prompt workflow with provided constraints and reports changed files plus validation evidence.

# REFERENCES
- skills: build-system, ci-cd-pipeline
- tools: cargo build --profile
- agent: Build-Engineer


