# asset manual spec overlay

## TL;DR

- Caches, tags, and queries reference-counted asset handles.

## Summary

- The `asset` module is the shared runtime catalog for loaded resources, so users can work with stable handles instead of repeatedly reopening raw file paths.
- Its core value is lifecycle control: the cache keeps assets deduplicated, reference counted, and discoverable by name, group, and tag.
- Preload and lookup features keep it useful during startup setup, content pipelines, and diagnostics because the same module can answer what is loaded and what should stay alive.
- Read it as the ownership layer for resource identity and retention. Neighboring modules still decide how loaded resources are consumed.

This module is mostly self-contained inside the `Feature Systems` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
