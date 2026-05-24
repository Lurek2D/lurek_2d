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

## Source Documentation

### `mod.rs`
- Mod system entry point exposing lifecycle management for game mods.
- Handles discovery, enabling/disabling, and Lua script integration of mods.
- Re-exports all public items from the mod manager submodule.

### `mod_manager.rs`
- Mod registry: register, unregister, and look up mods by id or capability.
- Manifest parsing: load `mod.toml` files, validate fields, and compute SHA-256 signatures.
- Load ordering: topological sort with dependency resolution, priority tie-breaking, and custom override.
- Asset conflict detection: prevent two mods from declaring the same asset path.
- Hot-reload queue: mark mods dirty, re-parse their manifests, and re-register atomically.
- Folder scanning: discover mod directories on disk and batch-register valid entries.
- Dependency validation: detect missing deps and circular dependency cycles.
- Config schema: carry typed key/default triples from manifests for runtime config UI.

## Types

- `ModInfo` (`struct`, `mod_manager.rs`): One parsed mod manifest plus runtime status fields such as enabled, loaded, priority, dependencies, filesystem path, asset paths, and optional integrity signature.
- `ModManager` (`struct`, `mod_manager.rs`): The central registry for discovered mods. It owns the mod list, optional custom load order, dependency checks, and pending reload bookkeeping.

## Functions

- `ModInfo::new` (`mod_manager.rs`): Create a minimal `ModInfo` with defaults; logs MD02.
- `ModInfo::from_parts` (`mod_manager.rs`): Create a `ModInfo` from explicit parts, falling back to defaults when `None` is supplied.
- `ModInfo::check_api_version` (`mod_manager.rs`): Checks whether the mod's declared API version is compatible with the host engine version.
- `ModManager::new` (`mod_manager.rs`): Create an empty mod manager; logs MD01.
- `ModManager::register_mod` (`mod_manager.rs`): Insert or replace `info` by id; removes it from the reload queue if present.
- `ModManager::unregister_mod` (`mod_manager.rs`): Remove the mod with `id`; returns true when a mod was actually removed.
- `ModManager::get_mod` (`mod_manager.rs`): Return a shared reference to the mod with `id`, or `None` when not found.
- `ModManager::get_mod_mut` (`mod_manager.rs`): Return a mutable reference to the mod with `id`, or `None` when not found.
- `ModManager::has_mod` (`mod_manager.rs`): Return true when a mod with `id` is registered.
- `ModManager::mod_count` (`mod_manager.rs`): Return the total number of registered mods.
- `ModManager::all_mods` (`mod_manager.rs`): Return the full slice of registered mods in insertion order.
- `ModManager::get_mods_by_capability` (`mod_manager.rs`): Return all mods that declare `capability` in their capabilities list.
- `ModManager::load_order` (`mod_manager.rs`): Return mods in their effective load order: custom order, then topological by priority; logs MD04.
- `ModManager::set_load_order` (`mod_manager.rs`): Override the default priority/topological sort with an explicit id order.
- `ModManager::clear_load_order` (`mod_manager.rs`): Remove the custom load order, restoring priority/topological sort.
- `ModManager::get_custom_load_order` (`mod_manager.rs`): Return the current custom load order slice, or `None` when not set.
- `ModManager::scan_folder` (`mod_manager.rs`): Scan `path` for subdirectories with a `mod.toml`; registers valid mods and returns discovered `ModInfo` list.
- `ModManager::mark_for_reload` (`mod_manager.rs`): Enqueue mod `id` for hot-reload; marks it unloaded; returns false when the id is unknown.
- `ModManager::get_reload_queue` (`mod_manager.rs`): Return the pending reload queue in submission order.
- `ModManager::clear_reload_queue` (`mod_manager.rs`): Clear the reload queue without processing it.
- `ModManager::process_reload_queue` (`mod_manager.rs`): Re-parse manifests for all queued mods and re-register them; return the ids that succeeded.
- `ModManager::validate_dependencies` (`mod_manager.rs`): Return the ids of dependencies declared by any mod that are not themselves registered.
- `ModManager::has_circular_dependencies` (`mod_manager.rs`): Return true when the registered mods contain a dependency cycle.

## Lua API Reference

- Binding path(s): `src/lua_api/mods_api.rs`
- Namespace: `lurek.mods`

### Module Functions
- `lurek.mods.newMod`: Creates a mod metadata handle from a Lua table.
- `lurek.mods.newModManager`: Creates an empty mod manager. This function is exposed to Lua scripts.
- `lurek.mods.newRegistry`: Creates an empty content registry.
- `lurek.mods.checkApiVersion`: Checks whether a mod API version is compatible with a host version.

### `LContentRegistry` Methods
- `LContentRegistry:registerType`: Registers a content type name. This method is available to Lua scripts.
- `LContentRegistry:register`: Stores a Lua value under a registered content type and id.
- `LContentRegistry:get`: Returns one stored value by content type and id.
- `LContentRegistry:getAll`: Returns all stored values for a content type keyed by id.
- `LContentRegistry:getTypes`: Returns registered content type names.
- `LContentRegistry:type`: Returns the Lua-visible type name for this content registry handle.
- `LContentRegistry:typeOf`: Returns whether this content registry handle matches a supported type name.

### `LMod` Methods
- `LMod:getId`: Returns the mod id. This method is available to Lua scripts.
- `LMod:getName`: Returns the mod display name. This method is available to Lua scripts.
- `LMod:getVersion`: Returns the mod version. This method is available to Lua scripts.
- `LMod:getAuthor`: Returns the mod author. This method is available to Lua scripts.
- `LMod:getDescription`: Returns the mod description. This method is available to Lua scripts.
- `LMod:getDependencies`: Returns mod dependency ids. This method is available to Lua scripts.
- `LMod:getPriority`: Returns the mod priority. This method is available to Lua scripts.
- `LMod:isEnabled`: Returns whether the mod is enabled.
- `LMod:setEnabled`: Sets whether the mod is enabled. This method is available to Lua scripts.
- `LMod:isLoaded`: Returns whether the mod is loaded. This method is available to Lua scripts.
- `LMod:getApiVersion`: Returns the optional required API version.
- `LMod:setApiVersion`: Sets the required API version string.
- `LMod:getCapabilities`: Returns capability names declared by the mod.
- `LMod:setCapabilities`: Sets capability names from an array table.
- `LMod:getConfigSchema`: Returns config schema entries. This method is available to Lua scripts.
- `LMod:setConfigSchema`: Sets config schema entries from a Lua table.
- `LMod:setHook`: Stores a Lua hook function by name. This method is available to Lua scripts.
- `LMod:getHook`: Returns a stored hook function by name.
- `LMod:hasHook`: Returns whether a hook name is registered.
- `LMod:getHookNames`: Returns registered hook names. This method is available to Lua scripts.
- `LMod:setConfig`: Stores a Lua config value for this mod.
- `LMod:getConfig`: Returns the stored Lua config value.
- `LMod:releaseRefs`: Releases stored Lua registry references for hooks and config.
- `LMod:type`: Returns the Lua-visible type name for this mod handle.
- `LMod:typeOf`: Returns whether this mod handle matches a supported type name.

### `LModManager` Methods
- `LModManager:registerMod`: Registers a mod with the manager. This method is available to Lua scripts.
- `LModManager:unregisterMod`: Unregisters a mod by id. This method is available to Lua scripts.
- `LModManager:hasMod`: Returns whether a mod id is registered.
- `LModManager:getModCount`: Returns the number of registered mods.
- `LModManager:getAllMods`: Returns metadata for all registered mods.
- `LModManager:getModsByCapability`: Returns metadata for mods declaring a capability.
- `LModManager:getLoadOrder`: Returns the resolved load order. This method is available to Lua scripts.
- `LModManager:validateDependencies`: Returns dependency validation messages.
- `LModManager:hasCircularDependencies`: Returns whether registered mods have circular dependencies.
- `LModManager:setLoadOrder`: Sets explicit load order from an array of mod ids.
- `LModManager:clearLoadOrder`: Clears explicit load order. This method is available to Lua scripts.
- `LModManager:scanFolder`: Scans a folder for mod metadata. This method is available to Lua scripts.
- `LModManager:getModPath`: Returns the filesystem path for a registered mod.
- `LModManager:markForReload`: Marks a mod id for reload. This method is available to Lua scripts.
- `LModManager:getReloadQueue`: Returns mod ids waiting for reload.
- `LModManager:clearReloadQueue`: Clears the reload queue. This method is available to Lua scripts.
- `LModManager:processReloadQueue`: Processes and clears the reload queue.
- `LModManager:type`: Returns the Lua-visible type name for this mod manager handle.
- `LModManager:typeOf`: Returns whether this mod manager handle matches a supported type name.

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/mods/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
