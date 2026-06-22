# validator manual spec overlay

## TL;DR

- Static validator verifying APIs, assets, and imports.

## Summary

- The `validator` module is the content-checking surface for users who want assets, imports, and API usage to be verified as a structured workflow instead of informal manual review.
- Rule types, execution policy, engine orchestration, and report structures work together so several validation checks can be run through one reusable framework.
- That matters because a project often needs to catch different classes of mistakes, such as missing assets or invalid `lurek.*` usage, before those problems become runtime failures.
- It is therefore useful for CI, local authoring passes, and package or mod checks.
- Read it as the engine's validation coordinator. Individual rules know what they are checking, but `validator` owns how those rules are configured, executed, and reported.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
