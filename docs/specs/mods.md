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

- The `mods` module is the governed extension surface for projects that want external content packs to behave like controlled runtime extensions instead of unrestricted code drops.
- Schemas, registries, loaders, managers, and sandbox rules work together so mod content can be discovered, validated, ordered, and constrained under one lifecycle.
- Real mod workflows need more than file loading: projects also need dependency sorting, manifest metadata, capability boundaries, reload behavior, and explicit trust policy.
- That policy layer is the main reason the module exists, because external content can be powerful without automatically receiving unrestricted code or data access.
- The same system is useful for shipped player-facing mod ecosystems and for internal extension-style content workflows during development.
- Controlled reload behavior and dependency ordering are especially important because modded projects need predictable iteration, recoverable startup, and explicit load precedence rather than a best-effort folder scan.
- It keeps mod power visible, explicit, and reviewable.
- Read `mods` as the runtime policy layer for modded content: filesystem and runtime systems provide capabilities, but `mods` decides how external content is described, admitted, isolated, and managed.

## Imports

- `runtime`: Imports or references `runtime` from `src/runtime/`.

## Files

### api_registry.rs

- `src/mods/api_registry.rs` owns the registry of mod-declarable API types and the validation rules attached to each type.
- It stores `TypeSchema` records with fields, methods, asset requirements, and descriptions for manifest-driven instances.
- Required-field checks and unknown-field detection live here so mod instance validation stays consistent across loaders.
- This file depends on schema definitions but does not parse TOML, manage live mods, or enforce Lua sandbox boundaries.
- Read it when mod type registration, instance validation, or allowed API surface contracts need to change.

### api_schema.rs

- `src/mods/api_schema.rs` defines schema types that describe mod fields, methods, and asset requirements.
- It owns `FieldType`, `FieldDef`, `MethodDef`, and `AssetRequirement`, including helper builders and type-name parsing.
- Optional, array, and userdata type encoding lives here so manifests and generated API metadata share one contract shape.
- This file carries schema data only; it does not register types, load manifests, or coordinate live mod lifecycles.
- Read it when mod schema fields, type parsing semantics, or API-description payload shapes need to change.

### mod.rs

- `src/mods/mod.rs` is the module index for mod schemas, registries, loading, sandboxing, and lifecycle management.
- It declares the files that own API contracts, manifest parsing, runtime coordination, and Lua-facing safety boundaries.
- This file reexports the main mod types so higher layers can use the subsystem without importing deep internal paths.
- No manifest parsing or runtime mod state lives here; it only defines visibility and the public module surface.
- Read this index first when tracing mod support, because it shows where schema, loader, manager, and sandbox logic split.
- Changes here affect reachability and API shape, not dependency ordering, sandbox policy, or manifest interpretation.

### mod_loader.rs

- `src/mods/mod_loader.rs` parses TOML content files into typed `ModInstance` records ready for registry validation.
- It owns `FieldValue`, `ModInstance`, scalar coercion helpers, line-based manifest parsing, and source-path attachment.
- Instance bootstrap from content files happens here so manifest decoding stays separate from registration and execution.
- Complex field values are flattened for validation, while richer table and array data stay in `FieldValue`.
- This file does not manage dependency order or sandbox policy; it only turns content text into structured instances.
- Read it when TOML parsing, field coercion, instance IDs, or source-file tracking for mods needs to change.

### mod_manager.rs

- `src/mods/mod_manager.rs` owns the runtime registry for discovered mods, manifest metadata, reload queues, and order.
- It stores `ModInfo` records with dependencies, capabilities, asset paths, config schema, signatures, and session state.
- Registration, lookup, enable-state tracking, capability queries, and custom load-order overrides all live in this file.
- Dependency validation and topological ordering live here so mod startup remains deterministic and cycle-aware.
- Manifest parsing from `mod.toml` also happens here, including warnings, signature checks, and asset conflicts.
- Folder scanning and hot-reload processing are coordinated here so disk changes can update registered mods safely.
- This file is the lifecycle and integrity boundary for mods; it does not define schema types or sandbox policy details.
- Read it when manifest semantics, reload behavior, dependency resolution, or mod registry ownership needs to change.
- Higher layers should treat this file as the source of truth for mod discovery and effective runtime load order.

### mod_sandbox.rs

- `src/mods/mod_sandbox.rs` defines the capability sandbox that filters what a mod may call, read, write, or hook into.
- It owns allowed API namespaces, blocked operations, hook permissions, memory and network flags, and read-path policy.
- `HookPoint` parsing and canonical names live here so manifest declarations and runtime checks use one hook vocabulary.
- This file does not load mods or resolve dependencies; it only describes and answers capability checks for mod execution.
- Read it when sandbox defaults, hook permissions, or file and API access rules for mods need to change.



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
