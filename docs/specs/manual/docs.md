# docs manual spec overlay

## TL;DR

- Builds an API catalog to generate editor files and Markdown reference.
- Analyzes docs-general coverage and quality using live table reflection.

## Summary

- The `docs` module treats documentation as an active engine-managed system rather than as a pile of disconnected markdown files.
- It builds and maintains a structured catalog of API knowledge, compares that catalog against what the engine actually exposes, and turns the result into actionable reports about missing, stale, or incomplete documentation.
- This matters because documentation quality drifts quickly in evolving codebases. Without a module like this, docs become passive artifacts that are only corrected sporadically instead of being continuously checked against source reality.
- The module acts as a bridge between implementation and publication by discovering what exists, validating whether it is described, and preparing that knowledge for several downstream consumers.
- Export paths are a major part of the feature. The same curated knowledge can be shaped into wiki-style outputs, editor hover text, completion data, machine-readable references, and other formats aimed at different readers and tools.
- Quality scoring, schema-oriented checks, and module-focused audits make the system practical for ongoing maintenance instead of occasional cleanup passes.
- This makes the module useful not only for publishing, but also for governance. Teams can spot undocumented APIs, stale wording, or inconsistent coverage before those gaps spread across several outputs.
- It also gives tooling one stable documentation catalog to consume.
- Other modules own behavior and signatures, but `docs` owns how that behavior is discovered, checked, cataloged, and published.
- Read `docs` as the coordination layer between engine reality and documentation output.

This module is mostly self-contained inside the Edge/Integration group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Notes

- `scan(opts)` can now reflect arbitrary Lua tables under caller-provided namespaces and module names instead of assuming every catalog entry lives under `lurek.*`.
- Editable catalog paths such as `describe(...)` and legacy `export*` helpers preserve fully qualified names outside the `lurek` namespace, so custom tool APIs round-trip without renaming.
- The Rust docs backend now supports strict export options with safe roots, JSON-only file targets, atomic writes, byte limits, and versioned payload envelopes. The current Lua `export*` helpers remain compatible with the legacy flat payload shapes.
- Catalog mutation is now deterministic by qualified name: duplicate entries can be rejected in checked mode and default merges replace the earlier entry in insertion order.
- Catalog search now uses cached normalized search text and supports explicit result caps through `SearchOptions`, so repeated case-insensitive queries do not rebuild lowercase strings for every entry.
- Quality scoring now follows a weighted policy that distinguishes missing description, missing signature data, parameter/return documentation gaps, missing examples, and missing `since` tags as separate rule ids.
- Validation and quality reports now carry structured issues with `ruleId`, `severity`, `message`, and optional `hint`, while preserving the legacy missing/phantom/incomplete bucket views for compatibility.
- Export trimming now applies configurable limits for entries, descriptions, parameters, returns, and output bytes so large catalogs can be bounded instead of silently producing oversized payloads.

## Architecture Links

- [Documentation System](../../architecture/docs-system.md)
- [Runtime Tooling Boundaries](../../architecture/runtime-tooling-boundaries.md)
