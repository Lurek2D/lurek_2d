# grep manual spec overlay

## TL;DR

- Provides literal-first file scanning, lightweight pattern helpers, and JSON/log searches.

## Summary

- The `grep` module is the scriptable text-search surface for users who want to scan project files, logs, or structured content from inside the engine environment.
- Search configuration, path filtering, matching, and specialized JSON or log helpers work together so one module can cover ordinary content search as well as more structured diagnostic queries.
- Literal-first behavior matters because many runtime and tooling searches are about exact identifiers, paths, or messages rather than full external-regex-engine complexity.
- Threaded scanning and result shaping make the module practical for tools, editors, audit scripts, and content workflows that need search without leaving the project runtime.
- Read it as the in-engine file-search utility layer: it does not replace every external grep tool, but it gives scripts a controlled search workflow that fits the engine's data and file model.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Notes

- The current implementation is intentionally narrower than the older docs: no mmap reader, no rayon-specific engine contract, and no promise of full regex semantics.
- Lua-facing grep reads now resolve through `GameFS` and active mod sandbox enforcement instead of bypassing runtime path policy.
- Lua-facing grep results now report logical GameFS-style paths back to scripts rather than leaking host filesystem paths.

## Architecture Links

- [Runtime Tooling Boundaries](../../architecture/runtime-tooling-boundaries.md)
