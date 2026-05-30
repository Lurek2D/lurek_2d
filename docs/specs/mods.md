# mods

## TL;DR

- The `mods` module manages mod discovery, validation, dependency order, sandboxing, and hot-reload for user-generated content.

## General Info

- Module group: `Feature Systems`
- Source path: `src/mods/`
- Binding: `src/lua_api/mods_api.rs`
- Namespace: `lurek.mods`
- Lua API surface: `4` functions, `8` types, `51` methods
- Rust test path(s): none found in the workspace
- Lua test path(s): none found in the workspace

## Summary

The `mods` module is the engine runtime for user-generated content lifecycle management. It discovers mod packages, parses manifests, validates metadata, and keeps mod state organized through one manager surface.

Dependency handling is a core responsibility. The module resolves required mod relationships, detects missing or cyclic links, and computes deterministic load order so startup behavior is stable across runs.

Capability and API checks are built in through schema and registry support. This helps ensure mods request known engine surfaces and stay within declared sandbox boundaries before script execution begins.

Runtime operations include enabling, disabling, and hot-reload style refresh flows. This allows developers and players to iterate on content quickly without rebuilding the whole game session for every change.

In practice, `lurek.mods` provides one consistent contract for mod governance: discover packages, validate constraints, apply ordered loading, enforce sandbox policy, and maintain content registry integration.

## Imports

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### api_registry.rs

- Registry of which lurek namespaces and functions a mod may use.
- Maps API names to permitted callable identifiers for sandbox checks.
- Loads from the built-in API schema and any engine plugins at startup.
- Lets mods declare required API surface in manifest data.
- Rejects unknown API requests before they can reach mod scripts.

### api_schema.rs

- Serializable description of the engine API surface exposed to mods.
- Stores parameter types, return types, and short summaries for each entry.
- Loads from generated API metadata at startup.
- Supports version checks so mods can declare a minimum engine release.
- Gives the sandbox a typed contract to validate against.

### mod.rs

- Entry point for the mod system and its lifecycle management.
- Groups discovery, enable/disable flow, sandboxing, and Lua integration.
- Keeps the mod runtime surface compact and centralised.

### mod_loader.rs

- Discovers, validates, and loads mod packages from disk.
- Scans manifests, builds instances, and applies deterministic load order.
- Verifies API requirements before any Lua code starts running.
- Supports priority-based override and atomic reload of changed packages.
- Provides the bootstrap path from content folders into live mod instances.

### mod_manager.rs

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

### mod_sandbox.rs

- Sandbox wrapper that restricts mod Lua access to declared capabilities.
- Applies per-mod permission filtering over the shared lurek namespace.
- Converts undeclared API calls into Lua errors instead of crashes.
- Limits file-system access to each mod's own content directory.
- Reapplies the sandbox after reload so capabilities never expand at runtime.

## Lua API Ref

### Functions

- `lurek.mods.checkApiVersion`: Checks whether a mod API version is compatible with a host version.
- `lurek.mods.newMod`: Creates a mod metadata handle from a Lua table.
- `lurek.mods.newModManager`: Creates an empty mod manager. This function is exposed to Lua scripts.
- `lurek.mods.newRegistry`: Creates an empty content registry.

### Callbacks

- `LMod:setHook` param `func` (`function`): Hook callback function.

### Enums

- No documented module-level enums/constants.

### Types

#### LContentRegistry Type

- Lua-side content registry for storing typed Lua values by id.

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

- Lua-side wrapper for mod metadata, hooks, and config references.

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

#### LModGetConfigSchemaResult Type

- Generated result shape from @field tags.

##### Fields

- `default` (`string`): Default value.
- `key` (`string`): Config key.
- `type` (`string`): Type hint.

##### Methods

- No documented methods.

#### LModManager Type

- Lua-side wrapper for the mod manager.

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

#### LModManagerGetAllModsResult Type

- Generated result shape from @field tags.

##### Fields

- `author` (`string`): Author name.
- `description` (`string`): Mod description.
- `enabled` (`boolean`): Whether enabled.
- `id` (`string`): Mod id.
- `loaded` (`boolean`): Whether loaded.
- `name` (`string`): Mod display name.
- `priority` (`integer`): Load priority.
- `version` (`string`): Version string.

##### Methods

- No documented methods.

#### LModManagerGetLoadOrderResult Type

- Generated result shape from @field tags.

##### Fields

- `author` (`string`): Author name.
- `description` (`string`): Mod description.
- `enabled` (`boolean`): Whether enabled.
- `id` (`string`): Mod id.
- `loaded` (`boolean`): Whether loaded.
- `name` (`string`): Mod display name.
- `priority` (`integer`): Load priority.
- `version` (`string`): Version string.

##### Methods

- No documented methods.

#### LModManagerGetModsByCapabilityResult Type

- Generated result shape from @field tags.

##### Fields

- `author` (`string`): Author name.
- `description` (`string`): Mod description.
- `enabled` (`boolean`): Whether enabled.
- `id` (`string`): Mod id.
- `loaded` (`boolean`): Whether loaded.
- `name` (`string`): Mod display name.
- `priority` (`integer`): Load priority.
- `version` (`string`): Version string.

##### Methods

- No documented methods.

#### LModManagerScanFolderResult Type

- Generated result shape from @field tags.

##### Fields

- `author` (`string`): Author name.
- `description` (`string`): Mod description.
- `enabled` (`boolean`): Whether enabled.
- `id` (`string`): Mod id.
- `loaded` (`boolean`): Whether loaded.
- `name` (`string`): Mod display name.
- `priority` (`integer`): Load priority.
- `version` (`string`): Version string.

##### Methods

- No documented methods.
