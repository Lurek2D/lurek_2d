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

It is engineered to handle the complete lifecycle of mods, from initial discovery on the filesystem to dependency resolution, load-order sorting, asset mounting, and runtime hot-reloading. The core orchestrator is the `ModManager`, which actively scans designated directories for `mod.toml` manifests, securely parses them, and validates their structural integrity and version constraints.

At the heart of the system is the `ModInfo` struct, which encapsulates all vital metadata for a single mod. This includes standard fields like name, version, and author, alongside critical functional data such as script entry points, declared capabilities, custom configuration schemas, and optional SHA-256 integrity signatures. A major responsibility of the `ModManager` is safely resolving inter-mod dependencies. It performs robust cyclic dependency detection and utilizes a topological sort, weighted by author-defined priority values, to compute a deterministic and stable load order. It also supports manual load-order overrides for resolving complex edge-case conflicts.

Once loaded, the module bridges the gap between engine architecture and user content. Mods can seamlessly override existing game assets within the virtual filesystem, introduce entirely new content via the typed `ContentRegistry`, and inject Lua scripts that execute within the engine's sandboxed environment. The module provides sophisticated runtime tools, including enable/disable toggling for instantaneous mod switching and a robust hot-reload queue that can re-parse and re-apply modified mods on the fly without requiring a full game restart. Fully exposed to Lua via the `lurek.mods.*` API, this system empowers developers to treat first-party game content and community mods with identical architectural parity.

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
