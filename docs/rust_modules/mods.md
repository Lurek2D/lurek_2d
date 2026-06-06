# mods

## General Info

- Module group: `Feature Systems`
- Source path: `src/mods/`
- Binding: `src/lua_api/mods_api.rs`
- Namespace: `lurek.mods`
- Lua API surface: `4` functions, `8` types, `51` methods
- Rust test path(s): none found in the workspace
- Lua test path(s): none found in the workspace

## Summary

This module represents the modular extension and package management subsystem, supplying tools to discover, validate, and orchestrate user-created packages. It processes manifest declarations to register mods with the manager, tracking metadata such as versions, authors, and configuration schemas. This decouples core engine operations from custom content folders while guaranteeing stable load pathways at runtime.

To ensure stable execution, the manager resolves mod priorities and dependencies using a topological sorting algorithm. This sorting detects circular dependencies, handles missing requirements early, and prevents file path collisions across loaded packages. Furthermore, a hot-reload queue coordinates atomic re-registration of modified mod packages during active gameplay, making it easy to test changes on the fly.

Security and containment are managed by a capability-based sandbox framework. It tracks API registries and schemas, mapping permitted engine methods to mod permissions to restrict access to the core namespaces. Mod execution is sandboxed, converting unauthorized API requests into non-fatal scripting errors. This sandbox confinement also limits file access to each mod's own directory, maintaining sandbox guarantees after hot reloads.

## Files

### [api_registry.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/mods/api_registry.rs)

- Registry of which lurek namespaces and functions a mod may use.
- Maps API names to permitted callable identifiers for sandbox checks.
- Loads from the built-in API schema and any engine plugins at startup.
- Lets mods declare required API surface in manifest data.
- Rejects unknown API requests before they can reach mod scripts.

### [api_schema.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/mods/api_schema.rs)

- Serializable description of the engine API surface exposed to mods.
- Stores parameter types, return types, and short summaries for each entry.
- Loads from generated API metadata at startup.
- Supports version checks so mods can declare a minimum engine release.
- Gives the sandbox a typed contract to validate against.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/mods/mod.rs)

- Entry point for the mod system and its lifecycle management.
- Groups discovery, enable/disable flow, sandboxing, and Lua integration.
- Keeps the mod runtime surface compact and centralised.

### [mod_loader.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/mods/mod_loader.rs)

- Discovers, validates, and loads mod packages from disk.
- Scans manifests, builds instances, and applies deterministic load order.
- Verifies API requirements before any Lua code starts running.
- Supports priority-based override and atomic reload of changed packages.
- Provides the bootstrap path from content folders into live mod instances.

### [mod_manager.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/mods/mod_manager.rs)

- Registry and coordination layer for live mods and their dependencies.
- Tracks enabled mods by id and capability for lookup and lifecycle control.
- Parses manifests and validates the required fields before registration.
- Resolves dependency order with topological sorting and priority ties.
- Detects missing dependencies and circular relationships early.
- Prevents asset path collisions across simultaneously loaded mods.
- Manages hot reload by marking dirty mods and re-registering them atomically.
- Scans folders on disk and batches valid entries into the registry.
- Carries typed config schema data from manifests into runtime UI.
- Serves as the central authority for mod registration and load sequencing.

### [mod_sandbox.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/mods/mod_sandbox.rs)

- Sandbox wrapper that restricts mod Lua access to declared capabilities.
- Applies per-mod permission filtering over the shared lurek namespace.
- Converts undeclared API calls into Lua errors instead of crashes.
- Limits file-system access to each mod's own content directory.
- Reapplies the sandbox after reload so capabilities never expand at runtime.
