# mods

## TL;DR

- Manages mod lifecycles using dependency sorting, permission sandboxing, and hot reloads.

## General Info

- Module group: `Feature Systems`
- Source path: `src/mods/`
- Binding: `src/lua_api/mods_api.rs`
- Namespace: `lurek.mods`
- Lua API surface: `4` functions, `8` types, `51` methods
- Rust test path(s): none found in the workspace
- Lua test path(s): tests/lua/unit/test_mods_unit.lua

## Summary

- This module gives users a managed mod runtime for discovering, validating, loading, and reloading extension packages.
- Manifest processing captures metadata, dependencies, capabilities, and config schema requirements.
- Dependency ordering ensures mods initialize in a stable sequence without circular dependency breakage.
- Collision checks help prevent conflicting resource paths across concurrently loaded mods.
- Hot-reload queues support iterative mod development without full runtime restart.
- Capability-based sandboxing limits mod API access to declared permissions.
- Registry/schema checks validate requested APIs before mod logic executes.
- Unauthorized operations are surfaced as script errors instead of hard runtime crashes.
- File-access boundaries keep mods confined to their own content scope.
- Mod manager APIs support querying by capability, load order, and lifecycle status.
- Content registry support enables typed content registration by mods.
- For users, this module balances openness to modding with runtime safety and control.
- It reduces brittle manual load scripting in mod-heavy projects.
- The practical result is more reliable extension ecosystems and faster iteration for creators.
- Overall, users get a structured, scriptable mod platform inside the engine.
- This makes third-party content integration much easier to govern.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Imports

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### api_registry.rs

- Registry of which lurek namespaces and functions a mod may use. `mods/api_registry` delivers the api registry implementation for the mods subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Maps API names to permitted callable identifiers for sandbox checks. The file owns or coordinates data contracts including `TypeSchema`, `GameApiRegistry`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Loads from the built-in API schema and any engine plugins at startup. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `add_field`, `add_method`, `add_asset_requirement`, `required_fields`, `optional_fields`, and 6 more stays attached to the local data model and invariants.
- Lets mods declare required API surface in manifest data. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### api_schema.rs

- Serializable description of the engine API surface exposed to mods. `mods/api_schema` delivers the api schema implementation for the mods subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Stores parameter types, return types, and short summaries for each entry. The file owns or coordinates data contracts including `FieldType`, `FieldDef`, `MethodDef`, `AssetRequirement`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Loads from generated API metadata at startup. Public callable behavior is centered on no named public items, while method-level behavior such as `from_name`, `as_str`, `new`, `optional`, `with_default`, `with_description`, and 2 more stays attached to the local data model and invariants.
- Supports version checks so mods can declare a minimum engine release. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

### mod.rs

- Entry point for the mod system and its lifecycle management. `mods/mod` is the mods module index, declaring `api_registry`, `api_schema`, `mod_loader`, `mod_manager`, `mod_sandbox` so agents can identify which files own each feature slice before opening implementation code.
- Groups discovery, enable/disable flow, sandboxing, and Lua integration. `src/mods/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `api_registry::{GameApiRegistry, TypeSchema}`, `api_schema::{FieldDef, FieldType, MethodDef}`, `mod_loader::{FieldValue, ModInstance}`, `mod_manager::*`, and 1 more centralized for the mods subsystem.

### mod_loader.rs

- Discovers, validates, and loads mod packages from disk. `mods/mod_loader` delivers the mod loader implementation for the mods subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Scans manifests, builds instances, and applies deterministic load order. The file owns or coordinates data contracts including `FieldValue`, `ModInstance`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Verifies API requirements before any Lua code starts running. Public callable behavior is centered on `load_instances_from_toml`, while method-level behavior such as `as_string`, `as_integer`, `as_float`, `as_bool`, `new`, `set_field`, and 2 more stays attached to the local data model and invariants.
- Supports priority-based override and atomic reload of changed packages. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Provides the bootstrap path from content folders into live mod instances. External integration uses `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

### mod_manager.rs

- Registry and coordination layer for live mods and their dependencies. `mods/mod_manager` delivers the mod manager implementation for the mods subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Tracks enabled mods by id and capability for lookup and lifecycle control. The file owns or coordinates data contracts including `ModInfo`, `ModManager`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Parses manifests and validates the required fields before registration. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `from_parts`, `check_api_version`, `register_mod`, `unregister_mod`, `get_mod`, and 16 more stays attached to the local data model and invariants.
- Resolves dependency order with topological sorting and priority ties. Runtime integration reaches sibling engine areas through crate modules `log_msg`, `runtime`, which explains the subsystem dependencies an agent should inspect before changing behavior.
- Detects missing dependencies and circular relationships early. External integration uses `sha2`, `std`, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.
- Prevents asset path collisions across simultaneously loaded mods. The file boundary separates mods implementation details from Lua bindings, generated specs, and examples, so public behavior remains documented at the owning source.

### mod_sandbox.rs

- Sandbox wrapper that restricts mod Lua access to declared capabilities. `mods/mod_sandbox` delivers the mod sandbox implementation for the mods subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
- Applies per-mod permission filtering over the shared lurek namespace. The file owns or coordinates data contracts including `HookPoint`, `ModSandbox`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
- Converts undeclared API calls into Lua errors instead of crashes. Public callable behavior is centered on no named public items, while method-level behavior such as `from_name`, `as_str`, `new`, `permissive`, `allow_api`, `block_op`, and 5 more stays attached to the local data model and invariants.
- Limits file-system access to each mod's own content directory. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.



## Lua API Ref

### Functions

- `lurek.mods.checkApiVersion(mod_ud, host_version) -> boolean`: Checks whether a mod API version is compatible with a host version.
- `lurek.mods.newMod(info) -> LMod`: Creates a mod metadata handle from a Lua table.
- `lurek.mods.newModManager() -> LModManager`: Creates an empty mod manager. This function is exposed to Lua scripts.
- `lurek.mods.newRegistry() -> LContentRegistry`: Creates an empty content registry.

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

- `LContentRegistry:get(type_name, id) -> table`: Returns one stored value by content type and id.
- `LContentRegistry:getAll(type_name) -> table`: Returns all stored values for a content type keyed by id.
- `LContentRegistry:getTypes() -> string[]`: Returns registered content type names.
- `LContentRegistry:register(type_name, id, obj) -> nil`: Stores a Lua value under a registered content type and id.
- `LContentRegistry:registerType(type_name) -> nil`: Registers a content type name. This method is available to Lua scripts.
- `LContentRegistry:type() -> string`: Returns the Lua-visible type name for this content registry handle.
- `LContentRegistry:typeOf(name) -> boolean`: Returns whether this content registry handle matches a supported type name.

#### LMod Type

- Lua-side wrapper for mod metadata, hooks, and config references.

##### Fields

- No documented fields.

##### Methods

- `LMod:getApiVersion() -> string`: Returns the optional required API version.
- `LMod:getAuthor() -> string`: Returns the mod author. This method is available to Lua scripts.
- `LMod:getCapabilities() -> string[]`: Returns capability names declared by the mod.
- `LMod:getConfig() -> table`: Returns the stored Lua config value.
- `LMod:getConfigSchema() -> table`: Returns config schema entries. This method is available to Lua scripts.
- `LMod:getDependencies() -> integer[]`: Returns mod dependency ids. This method is available to Lua scripts.
- `LMod:getDescription() -> string`: Returns the mod description. This method is available to Lua scripts.
- `LMod:getHook(name) -> function`: Returns a stored hook function by name.
- `LMod:getHookNames() -> string[]`: Returns registered hook names. This method is available to Lua scripts.
- `LMod:getId() -> string`: Returns the mod id. This method is available to Lua scripts.
- `LMod:getName() -> string`: Returns the mod display name. This method is available to Lua scripts.
- `LMod:getPriority() -> integer`: Returns the mod priority. This method is available to Lua scripts.
- `LMod:getVersion() -> string`: Returns the mod version. This method is available to Lua scripts.
- `LMod:hasHook(name) -> boolean`: Returns whether a hook name is registered.
- `LMod:isEnabled() -> boolean`: Returns whether the mod is enabled.
- `LMod:isLoaded() -> boolean`: Returns whether the mod is loaded. This method is available to Lua scripts.
- `LMod:releaseRefs() -> nil`: Releases stored Lua registry references for hooks and config.
- `LMod:setApiVersion(api_version) -> nil`: Sets the required API version string.
- `LMod:setCapabilities(caps) -> nil`: Sets capability names from an array table.
- `LMod:setConfig(value) -> nil`: Stores a Lua config value for this mod.
- `LMod:setConfigSchema(schema) -> nil`: Sets config schema entries from a Lua table.
- `LMod:setEnabled(enabled) -> nil`: Sets whether the mod is enabled. This method is available to Lua scripts.
- `LMod:setHook(name, func) -> nil`: Stores a Lua hook function by name. This method is available to Lua scripts.
- `LMod:type() -> string`: Returns the Lua-visible type name for this mod handle.
- `LMod:typeOf(name) -> boolean`: Returns whether this mod handle matches a supported type name.

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

- `LModManager:clearLoadOrder() -> nil`: Clears explicit load order. This method is available to Lua scripts.
- `LModManager:clearReloadQueue() -> nil`: Clears the reload queue. This method is available to Lua scripts.
- `LModManager:getAllMods() -> table`: Returns metadata for all registered mods.
- `LModManager:getLoadOrder() -> table`: Returns the resolved load order. This method is available to Lua scripts.
- `LModManager:getModCount() -> integer`: Returns the number of registered mods.
- `LModManager:getModPath(mod_id) -> string`: Returns the filesystem path for a registered mod.
- `LModManager:getModsByCapability(capability) -> table`: Returns metadata for mods declaring a capability.
- `LModManager:getReloadQueue() -> integer[]`: Returns mod ids waiting for reload.
- `LModManager:hasCircularDependencies() -> boolean`: Returns whether registered mods have circular dependencies.
- `LModManager:hasMod(mod_id) -> boolean`: Returns whether a mod id is registered.
- `LModManager:markForReload(mod_id) -> boolean`: Marks a mod id for reload. This method is available to Lua scripts.
- `LModManager:processReloadQueue() -> integer[]`: Processes and clears the reload queue.
- `LModManager:registerMod(ud) -> nil`: Registers a mod with the manager. This method is available to Lua scripts.
- `LModManager:scanFolder(path) -> table`: Scans a folder for mod metadata. This method is available to Lua scripts.
- `LModManager:setLoadOrder(order_table) -> nil`: Sets explicit load order from an array of mod ids.
- `LModManager:type() -> string`: Returns the Lua-visible type name for this mod manager handle.
- `LModManager:typeOf(name) -> boolean`: Returns whether this mod manager handle matches a supported type name.
- `LModManager:unregisterMod(mod_id) -> boolean`: Unregisters a mod by id. This method is available to Lua scripts.
- `LModManager:validateDependencies() -> string[]`: Returns dependency validation messages.

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

## References

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Notes

- No additional module-specific notes.
