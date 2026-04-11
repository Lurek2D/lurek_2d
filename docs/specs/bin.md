# bin

## General Info

- Module group: `Edge/Integration`
- Source path: `src/bin/`
- Lua API path(s): None direct
- Primary Lua namespace: None direct
- Rust test path(s): None dedicated
- Lua test path(s): None

## Summary

The bin module holds alternative compiled entry points for the engine. It exists so the project can ship or develop with different binary behaviors while still routing all real startup logic through the shared library crate.

Right now the important distinction is between the main console-attached launcher and the console-less Windows launcher under src/bin/. The bin module keeps that packaging concern separate from engine startup behavior, which still belongs in lib.rs and app.

This module does not own configuration parsing, platform initialization, splash behavior, or the event loop. If a change affects engine boot semantics rather than which binary wrapper calls into them, it belongs somewhere else.

**Scope boundary**: This module currently acts as a mostly self-contained part of the Edge/Integration layer. Cross-module behavior should remain anchored to the top-level source files and Lua bindings listed below.

## Files

- `lurekc.rs`: Minimal console-less launcher for Windows builds that applies the windows_subsystem attribute and then delegates straight to lurek2d::lurek_run(). This file should stay intentionally tiny because it is only a wrapper binary.

## Types

- No public Rust types are currently exposed from this module.

## Functions

- No public Rust functions are currently exposed from this module.

## Lua API Reference

- No dedicated direct `lurek.*` namespace is exposed by this module.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- Keep this module reference synchronized with `src/bin/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
- This module has no dedicated direct `lurek.*` namespace and is usually consumed through higher integration layers.
