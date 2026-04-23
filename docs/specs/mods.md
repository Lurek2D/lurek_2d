# mods

## General Info

- Module group: `Feature Systems`
- Source path: `src/mods/`
- Lua API path(s): `src/lua_api/mods_api.rs`
- Primary Lua namespace: `lurek.mods`
- Rust test path(s): none found in the workspace
- Lua test path(s): none found in the workspace

## Summary

## Summary

The `mods` module provides Lurek2D's mod-loading framework — the system by which user-created content packages extend or replace a base game without modifying its source. It is a Feature Systems tier module that integrates with `filesystem` for virtual filesystem mounting and with `runtime` for configuration.

**ModManager lifecycle.** `ModManager` handles the complete mod lifecycle: scanning configured mod search paths for `mod.toml` manifest files; parsing manifests into `ModInfo` records (unique string ID, display name, semantic version, author, description, dependency list); resolving load order via topological sort over the dependency graph; detecting circular dependencies and missing dependencies as distinct error cases; enabling and disabling individual mods at runtime; mounting enabled mod folders into `GameFS` as overlay `MountLayer` entries so game code sees a unified virtual filesystem; and polling mtime for hot-reload detection.

**Mod manifest format.** Each mod folder must contain a `mod.toml` with at minimum `id`, `name`, and `version` fields. Optional fields include `author`, `description`, and `dependencies` (a list of mod ID strings). Assets in a mod folder override base game assets at the same virtual path. New assets not in the base game are simply added to the virtual filesystem. Dependency ordering ensures that if mod B depends on mod A, mod A's assets are mounted first so mod B's overrides take precedence — the last-mounted asset wins.

**Load order.** By default `ModManager` resolves load order via `load_order()` which performs a topological sort respecting declared dependencies, then sorts within each tier by a numeric `priority` field from the manifest. `set_load_order(ids)` overrides this with an explicit sequence; `clear_load_order()` reverts to automatic sorting. `validate_dependencies()` returns a list of mod IDs whose declared dependencies are not registered, and `has_circular_dependencies()` detects cycles.

**Hot-reload.** `mark_for_reload(id)` places a mod in the pending reload queue. On the next `tick()` call the manager fans out reload events to Lua callbacks registered via `lurek.mods.onReload(fn)`. The Lua callback receives the mod ID and the reload reason. Game code can then re-execute the mod's Lua init scripts or notify subsystems that depend on mod-provided data.

**ModRegistry.** `registry.rs` introduces `ModRegistry`, a typed name-to-value store for mod-contributed content: custom item definitions, ability descriptors, configuration overrides, or any serialisable data table. Lua scripts access it through the `lurek.mods.registry.*` namespace. A mod calls `lurek.mods.registry.register(name, data)` at init time; other mods and the base game discover contributions via `lurek.mods.registry.get(name)` or `lurek.mods.registry.list(prefix)`. This allows loose coupling between mods — no mod needs to import from another, only from the shared registry.

**Lua surface.** `lurek.mods.scan(path)`, `lurek.mods.list()` → array of mod info tables, `lurek.mods.enable(id)`, `lurek.mods.disable(id)`, `lurek.mods.isEnabled(id)`, `lurek.mods.loadOrder()`, `lurek.mods.validateDeps()`, `lurek.mods.onReload(fn)`. Registry: `lurek.mods.registry.register(key, data)`, `lurek.mods.registry.get(key)`, `lurek.mods.registry.list(prefix)`, `lurek.mods.registry.unregister(key)`.

**Scope boundary.** Feature Systems tier. Depends on `filesystem` (MountLayer, GameFS), `runtime` (config, SharedState). Lua bridge in `src/lua_api/mods_api.rs`.

## Files

- `mod.rs`: Declares the mod-management surface and re-exports the manager implementation.
- `mod_manager.rs`: Implements mod discovery, manifest parsing, dependency validation, custom load ordering, and queued reload tracking.

## Types

- `ModInfo` (`struct`, `mod_manager.rs`): One parsed mod manifest plus runtime status fields such as enabled, loaded, priority, dependencies, and filesystem path.
- `ModManager` (`struct`, `mod_manager.rs`): The central registry for discovered mods. It owns the mod list, optional custom load order, dependency checks, and pending reload bookkeeping.

## Functions

- `ModInfo::new` (`mod_manager.rs`): Create a new ModInfo with the given ID and sensible defaults.
- `ModInfo::from_parts` (`mod_manager.rs`): Creates a `ModInfo` from its constituent parts, applying optional overrides over the defaults from [`ModInfo::new`].
- `ModManager::new` (`mod_manager.rs`): Create a new empty ModManager.
- `ModManager::register_mod` (`mod_manager.rs`): Register a mod with the manager.
- `ModManager::unregister_mod` (`mod_manager.rs`): Removes a mod from the registry by its assigned ID.
- `ModManager::get_mod` (`mod_manager.rs`): Get a reference to a mod by ID.
- `ModManager::get_mod_mut` (`mod_manager.rs`): Get a mutable reference to a mod by ID.
- `ModManager::has_mod` (`mod_manager.rs`): Check if a mod is registered.
- `ModManager::mod_count` (`mod_manager.rs`): Returns the count of all currently registered mods.
- `ModManager::all_mods` (`mod_manager.rs`): Returns a slice of all registered mod metadata records.
- `ModManager::load_order` (`mod_manager.rs`): Get mods in their effective load order.
- `ModManager::set_load_order` (`mod_manager.rs`): Set an explicit load order by providing a list of mod IDs.
- `ModManager::clear_load_order` (`mod_manager.rs`): Clear any custom load order, reverting to priority-based sorting.
- `ModManager::get_custom_load_order` (`mod_manager.rs`): Returns a reference to the current custom load order, if any.
- `ModManager::scan_folder` (`mod_manager.rs`): Scan a directory for mods and register them.
- `ModManager::mark_for_reload` (`mod_manager.rs`): Marks a registered mod as requiring hot-reload on the next update tick.
- `ModManager::get_reload_queue` (`mod_manager.rs`): Returns the current reload queue (mod IDs pending hot-reload).
- `ModManager::clear_reload_queue` (`mod_manager.rs`): Clear the reload queue without reloading anything.
- `ModManager::validate_dependencies` (`mod_manager.rs`): List mod IDs whose dependencies are missing.
- `ModManager::has_circular_dependencies` (`mod_manager.rs`): Check for circular dependency cycles.

## Lua API Reference

- Binding path(s): `src/lua_api/mods_api.rs`
- Namespace: `lurek.mods`

### Module Functions
- `lurek.mods.newMod`: Creates a new Mod from an info table with at least an `id` field.
- `lurek.mods.newModManager`: Creates a new empty ModManager.
- `lurek.mods.newRegistry`: Creates a new empty ContentRegistry for mod-contributed assets.
- `lurek.mods.checkApiVersion`: Checks whether a mod's required `api_version` is compatible with the given `host_version`.

### `ContentRegistry` Methods
- `ContentRegistry:registerType`: Register a new content type.
- `ContentRegistry:register`: Register a content entry.
- `ContentRegistry:get`: Retrieve a content entry.
- `ContentRegistry:getAll`: Get all entries for a type.
- `ContentRegistry:getTypes`: Get all registered type names.

### `Mod` Methods
- `Mod:getId`: Returns the unique mod identifier
- `Mod:getName`: Returns the localized or human-readable display name of the mod.
- `Mod:getVersion`: Returns the version string
- `Mod:getAuthor`: Returns the author name string from this mod's metadata manifest
- `Mod:getDescription`: Returns the mod description
- `Mod:getDependencies`: Returns the list of required mod IDs
- `Mod:getPriority`: Returns the load-order priority
- `Mod:isEnabled`: Returns whether the mod is enabled
- `Mod:setEnabled`: Enables or disables this mod; disabled mods are skipped during loading
- `Mod:isLoaded`: Returns whether the mod has been loaded
- `Mod:getApiVersion`: Returns the required engine API version string, or nil if not set
- `Mod:setApiVersion`: Sets the required engine API version string
- `Mod:getCapabilities`: Returns an array of declared capability flags
- `Mod:setCapabilities`: Replaces the capability list with the given array of strings
- `Mod:getConfigSchema`: Returns the config schema as an array of `{key, type, default}` tables.
- `Mod:setConfigSchema`: Replaces the config schema with the given array of `{key, type, default}` tables.
- `Mod:getHook`: Returns the hook function for the given name, or nil
- `Mod:hasHook`: Returns whether a hook with the given name exists
- `Mod:getHookNames`: Returns an array of registered hook names
- `Mod:setConfig`: Stores an arbitrary config value for this mod
- `Mod:getConfig`: Returns the stored config value, or nil
- `Mod:releaseRefs`: Releases all hook and config registry references

### `ModManager` Methods
- `ModManager:registerMod`: Registers a mod from its Mod userdata
- `ModManager:unregisterMod`: Removes a mod by ID and returns whether it was found
- `ModManager:hasMod`: Returns whether a mod with the given ID is registered
- `ModManager:getModCount`: Returns the number of registered mods
- `ModManager:getAllMods`: Returns an array of info tables for all registered mods
- `ModManager:getLoadOrder`: Returns an array of info tables in effective load order
- `ModManager:validateDependencies`: Returns an array of mod IDs with missing dependencies
- `ModManager:hasCircularDependencies`: Returns whether any circular dependency cycles exist
- `ModManager:setLoadOrder`: Sets an explicit load order from an array of mod ID strings
- `ModManager:clearLoadOrder`: Clears the custom load order, reverting to priority-based sorting
- `ModManager:scanFolder`: Scans a directory for mods with mod.toml and registers them
- `ModManager:getModPath`: Returns the filesystem path of a registered mod, or nil
- `ModManager:markForReload`: Marks a registered mod for hot-reload
- `ModManager:getReloadQueue`: Returns the array of mod IDs pending hot-reload
- `ModManager:clearReloadQueue`: Clears the reload queue without reloading

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- Keep this module reference synchronized with `src/mods/` and any matching Lua bindings.
- Summary paragraphs are manual prose. The collected Files, Types, Functions, Lua API Reference, and References sections can be regenerated when the source changes.
