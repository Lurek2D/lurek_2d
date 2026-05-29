# mods

## TL;DR

- The `mods` module is a powerful Feature Systems tier component that provides a comprehensive framework for user-generated content and game modifications in Lurek2D.

## General Info

- Module group: `Feature Systems`
- Source path: `src/mods/`
- Lua API path(s): `src/lua_api/mods_api.rs`
- Primary Lua namespace: `lurek.mods`
- Rust test path(s): none found in the workspace
- Lua test path(s): none found in the workspace

## Summary

It is engineered to handle the complete lifecycle of mods, from initial discovery on the filesystem to dependency resolution, load-order sorting, asset mounting, and runtime hot-reloading. The core orchestrator is the `ModManager`, which actively scans designated directories for `mod.toml` manifests, securely parses them, and validates their structural integrity and version constraints.

At the heart of the system is the `ModInfo` struct, which encapsulates all vital metadata for a single mod. This includes standard fields like name, version, and author, alongside critical functional data such as script entry points, declared capabilities, custom configuration schemas, and optional SHA-256 integrity signatures. A major responsibility of the `ModManager` is safely resolving inter-mod dependencies. It performs robust cyclic dependency detection and utilizes a topological sort, weighted by author-defined priority values, to compute a deterministic and stable load order. It also supports manual load-order overrides for resolving complex edge-case conflicts.

Once loaded, the module bridges the gap between engine architecture and user content. Mods can seamlessly override existing game assets within the virtual filesystem, introduce entirely new content via the typed `ContentRegistry`, and inject Lua scripts that execute within the engine's sandboxed environment. The module provides sophisticated runtime tools, including enable/disable toggling for instantaneous mod switching and a robust hot-reload queue that can re-parse and re-apply modified mods on the fly without requiring a full game restart. Fully exposed to Lua via the `lurek.mods.*` API, this system empowers developers to treat first-party game content and community mods with identical architectural parity.

## Files

### api_registry.rs

- Mod API registry: records which `lurek.*` namespaces are available to mod scripts.
- `ApiRegistry` maps API name strings to the set of permitted function identifiers.
- Populated at engine startup from the built-in API schema and any engine plugins.
- Mods declare their required API surface in `mod.toml`; the sandbox checks against it.
- Unknown API requests produce a sandbox violation error before the mod is loaded.

### api_schema.rs

- Mod API schema: JSON-serialisable description of every `lurek.*` function signature.
- `ApiSchema` is generated from `docs/api/lurek.json` at startup.
- Used by the sandbox to validate that a mod only calls permitted, typed API entries.
- Schema entries carry parameter types, return types, and a human-readable summary.
- Versioned by the engine semver; mods may declare a minimum engine version.

### mod.rs

- Mod system entry point exposing lifecycle management for game mods.
- Handles discovery, enabling/disabling, and Lua script integration of mods.
- Game API registry for type-safe mod content declarations.
- Sandboxing to restrict mod capabilities.
- Instance loading from TOML content files.

### mod_loader.rs

- Mod loader: discovers, validates, and loads mod packages from the mods directory.
- Scans `content/mods/` for `mod.toml` manifests and loads each into a `ModInstance`.
- `load_instances_from_toml` parses a single manifest and builds the instance.
- Validates API requirements against the `ApiRegistry` before executing any Lua.
- Load order is deterministic (alphabetical by mod ID) and overrideable via priority.

### mod_manager.rs

- Mod registry: register, unregister, and look up mods by id or capability.
- Manifest parsing: load `mod.toml` files, validate fields, and compute SHA-256 signatures.
- Load ordering: topological sort with dependency resolution, priority tie-breaking, and custom override.
- Asset conflict detection: prevent two mods from declaring the same asset path.
- Hot-reload queue: mark mods dirty, re-parse their manifests, and re-register atomically.
- Folder scanning: discover mod directories on disk and batch-register valid entries.
- Dependency validation: detect missing deps and circular dependency cycles.
- Config schema: carry typed key/default triples from manifests for runtime config UI.

### mod_sandbox.rs

- Mod sandbox: restricts mod Lua API access to the declared capability set.
- Wraps the shared Lua state with a per-mod permission filter over `lurek.*`.
- Attempts to call undeclared API functions raise a Lua error instead of panicking.
- File system access for mods is limited to their own `content/mods/<id>/` directory.
- Sandbox is re-applied after each hot-reload; capability set cannot expand at runtime.

## Lua API Ref

- Binding: `src/lua_api/mods_api.rs`
- Namespace: `lurek.mods`

### Functions

- `lurek.mods.checkApiVersion`: Checks whether a mod API version is compatible with a host version.
- `lurek.mods.newMod`: Creates a mod metadata handle from a Lua table.
- `lurek.mods.newModManager`: Creates an empty mod manager. This function is exposed to Lua scripts.
- `lurek.mods.newRegistry`: Creates an empty content registry.

### Enums

- No documented module-level enums/constants.

### Types


#### LContentRegistry Type


##### Fields

- No documented fields.

##### Methods

- `LContentRegistry:get`: Returns one stored value by content type and id.
- `LContentRegistry:getAll`: Returns all stored values for a content type keyed by id.
- `LContentRegistry:getTypes`: Returns registered content type names.
- `LContentRegistry:register`: Stores a Lua value under a registered content type and id.
- `LContentRegistry:registerType`: Registers a content type name. This method is available to Lua scripts.
- `LContentRegistry:type`: Returns the Lua-visible type name for this content registry handle.
- `LContentRegistry:typeOf`: Returns whether this content registry handle matches a supported type name.


#### LMod Type


##### Fields

- No documented fields.

##### Methods

- `LMod:getApiVersion`: Returns the optional required API version.
- `LMod:getAuthor`: Returns the mod author. This method is available to Lua scripts.
- `LMod:getCapabilities`: Returns capability names declared by the mod.
- `LMod:getConfig`: Returns the stored Lua config value.
- `LMod:getConfigSchema`: Returns config schema entries. This method is available to Lua scripts.
- `LMod:getDependencies`: Returns mod dependency ids. This method is available to Lua scripts.
- `LMod:getDescription`: Returns the mod description. This method is available to Lua scripts.
- `LMod:getHook`: Returns a stored hook function by name.
- `LMod:getHookNames`: Returns registered hook names. This method is available to Lua scripts.
- `LMod:getId`: Returns the mod id. This method is available to Lua scripts.
- `LMod:getName`: Returns the mod display name. This method is available to Lua scripts.
- `LMod:getPriority`: Returns the mod priority. This method is available to Lua scripts.
- `LMod:getVersion`: Returns the mod version. This method is available to Lua scripts.
- `LMod:hasHook`: Returns whether a hook name is registered.
- `LMod:isEnabled`: Returns whether the mod is enabled.
- `LMod:isLoaded`: Returns whether the mod is loaded. This method is available to Lua scripts.
- `LMod:releaseRefs`: Releases stored Lua registry references for hooks and config.
- `LMod:setApiVersion`: Sets the required API version string.
- `LMod:setCapabilities`: Sets capability names from an array table.
- `LMod:setConfig`: Stores a Lua config value for this mod.
- `LMod:setConfigSchema`: Sets config schema entries from a Lua table.
- `LMod:setEnabled`: Sets whether the mod is enabled. This method is available to Lua scripts.
- `LMod:setHook`: Stores a Lua hook function by name. This method is available to Lua scripts.
- `LMod:type`: Returns the Lua-visible type name for this mod handle.
- `LMod:typeOf`: Returns whether this mod handle matches a supported type name.


#### LModManager Type


##### Fields

- No documented fields.

##### Methods

- `LModManager:clearLoadOrder`: Clears explicit load order. This method is available to Lua scripts.
- `LModManager:clearReloadQueue`: Clears the reload queue. This method is available to Lua scripts.
- `LModManager:getAllMods`: Returns metadata for all registered mods.
- `LModManager:getLoadOrder`: Returns the resolved load order. This method is available to Lua scripts.
- `LModManager:getModCount`: Returns the number of registered mods.
- `LModManager:getModPath`: Returns the filesystem path for a registered mod.
- `LModManager:getModsByCapability`: Returns metadata for mods declaring a capability.
- `LModManager:getReloadQueue`: Returns mod ids waiting for reload.
- `LModManager:hasCircularDependencies`: Returns whether registered mods have circular dependencies.
- `LModManager:hasMod`: Returns whether a mod id is registered.
- `LModManager:markForReload`: Marks a mod id for reload. This method is available to Lua scripts.
- `LModManager:processReloadQueue`: Processes and clears the reload queue.
- `LModManager:registerMod`: Registers a mod with the manager. This method is available to Lua scripts.
- `LModManager:scanFolder`: Scans a folder for mod metadata. This method is available to Lua scripts.
- `LModManager:setLoadOrder`: Sets explicit load order from an array of mod ids.
- `LModManager:type`: Returns the Lua-visible type name for this mod manager handle.
- `LModManager:typeOf`: Returns whether this mod manager handle matches a supported type name.
- `LModManager:unregisterMod`: Unregisters a mod by id. This method is available to Lua scripts.
- `LModManager:validateDependencies`: Returns dependency validation messages.

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.
