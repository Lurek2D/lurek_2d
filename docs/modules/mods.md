# Mods

## Purpose

Manages mod lifecycles using dependency sorting, permission sandboxing, and hot reloads.

## When To Use

- Schemas, registries, loaders, managers, and sandbox rules work together so mod content can be discovered, validated, ordered, and constrained under one lifecycle.
- Real mod workflows need more than file loading: projects also need dependency sorting, manifest metadata, capability boundaries, reload behavior, and explicit trust policy.
- That policy layer is the main reason the module exists, because external content can be powerful without automatically receiving unrestricted code or data access.

## Minimal Example

From the `lurek.mods.newMod` example block:

```lua
do
    local mod = lurek.mods.newMod({
        id = "my_mod",
        name = "My Mod",
        version = "1.0.0",
        author = "Dev",
        description = "Example mod",
        priority = 10,
    })
    mods_log("created mod id=" .. mod:getId())
    mods_log("priority = " .. mod:getPriority())
end
```

## Common Patterns

- Start with `lurek.mods.checkApiVersion` when exploring this module.
- Start with `lurek.mods.newMod` when exploring this module.
- Start with `lurek.mods.newModManager` when exploring this module.
- Start with `lurek.mods.newRegistry` when exploring this module.

## API Reference

- This page is the generated API reference for this module.
- Runnable example owner: `content/examples/mods.lua`

## Summary

- The `mods` module is the governed extension surface for projects that want external content packs to behave like controlled runtime extensions instead of unrestricted code drops.
- Schemas, registries, loaders, managers, and sandbox rules work together so mod content can be discovered, validated, ordered, and constrained under one lifecycle.
- Real mod workflows need more than file loading: projects also need dependency sorting, manifest metadata, capability boundaries, reload behavior, and explicit trust policy.
- That policy layer is the main reason the module exists, because external content can be powerful without automatically receiving unrestricted code or data access.
- The same system is useful for shipped player-facing mod ecosystems and for internal extension-style content workflows during development.
- Controlled reload behavior and dependency ordering are especially important because modded projects need predictable iteration, recoverable startup, and explicit load precedence rather than a best-effort folder scan.
- Default sandbox policy is deny-by-default for APIs, hooks, and read roots unless a mod is promoted into an explicit allow-all or allow-list mode.
- Sandbox policy can now travel with manifest metadata or Lua-created `LMod` handles, and `LMod:runHook(...)` is the live execution boundary that activates API, hook, filesystem, network, and memory enforcement.
- Manifest and content parsing are strict TOML decoders with byte, field, and count limits instead of line-based best-effort parsing.
- Discovery and reload flows now build structured scan and load-plan reports so missing dependencies, cycles, checksum failures, and path-policy violations are explicit.
- Hot reload is atomic at the registry level: the previous valid snapshot stays active when the new manifest set fails validation.
- `sandbox.max_memory` is enforced at hook execution time when the underlying Lua runtime supports memory limits; file writes and top-level network entry points are blocked through the normal Lua API surface while the sandbox is active.
- It keeps mod power visible, explicit, and reviewable.
- Read `mods` as the runtime policy layer for modded content: filesystem and runtime systems provide capabilities, but `mods` decides how external content is described, admitted, isolated, and managed.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Functions

### `lurek.mods.checkApiVersion`

Checks whether a mod API version is compatible with a host version.

```lua
lurek.mods.checkApiVersion(mod_ud, host_version)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mod_ud` | [LMod](#lmod) | Mod handle. |
| `host_version` | string | Host API version string. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when compatible. |
| string | Error message when incompatible; otherwise nil. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "compat", name = "Compat" })
    mod:setApiVersion("2.0.0")
    local ok, err = lurek.mods.checkApiVersion(mod, "1.5.0")
    mods_log("compatible = " .. tostring(ok))
    mods_log("error = " .. tostring(err))
end
```

---

### `lurek.mods.newMod`

Creates a mod metadata handle from a Lua table.

```lua
lurek.mods.newMod(info)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `info` | table | Mod metadata table. |

**Returns**

| Type | Description |
|------|-------------|
| [LMod](#lmod) | New mod handle. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({
        id = "my_mod",
        name = "My Mod",
        version = "1.0.0",
        author = "Dev",
        description = "Example mod",
        priority = 10,
    })
    mods_log("created mod id=" .. mod:getId())
    mods_log("priority = " .. mod:getPriority())
end
```

---

### `lurek.mods.newModManager`

Creates an empty mod manager. This function is exposed to Lua scripts.

```lua
lurek.mods.newModManager()
```

**Returns**

| Type | Description |
|------|-------------|
| [LModManager](#lmodmanager) | New mod manager handle. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local core = lurek.mods.newMod({ id = "core_pack", name = "Core Pack", priority = 0 })
    mgr:registerMod(core)
    local order = mgr:getLoadOrder()
    local first = order[1] and order[1].id or "none"
    mods_log("manager type=" .. mgr:type() .. " count=" .. tostring(mgr:getModCount()) .. " first_in_order=" .. tostring(first))
end
```

---

### `lurek.mods.newRegistry`

Creates an empty content registry.

```lua
lurek.mods.newRegistry()
```

**Returns**

| Type | Description |
|------|-------------|
| [LContentRegistry](#lcontentregistry) | New content registry handle. |

**Example**

```lua
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("encounter")
    reg:register("encounter", "bandits", { difficulty = 3, biome = "forest" })
    local stored = reg:get("encounter", "bandits")
    local types = reg:getTypes()
    mods_log("registry created=" .. tostring(reg ~= nil) .. " type=" .. reg:type() .. " stored_biome=" .. tostring(stored and stored.biome) .. " types=" .. tostring(#types))
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## Types

- [LContentRegistry](#lcontentregistry)
- [LMod](#lmod)
- [LModManager](#lmodmanager)

## LContentRegistry

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LContentRegistry:get`

Returns one stored value by content type and id.

```lua
LContentRegistry:get(type_name, id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | string | Content type name. |
| `id` | string | Entry id. |

**Returns**

| Type | Description |
|------|-------------|
| table | Stored Lua value. |
| nil | If missing. |

**Example**

```lua
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:register("item", "sword", { name = "Sword", damage = 10 })
    local sword = reg:get("item", "sword")
    mods_log("got = " .. tostring(sword ~= nil))
    mods_log("name = " .. sword.name)
end
```

---

#### `LContentRegistry:getAll`

Returns all stored values for a content type keyed by id.

```lua
LContentRegistry:getAll(type_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | string | Content type name. |

**Returns**

| Type | Description |
|------|-------------|
| table | Table of stored values keyed by id. |

**Example**

```lua
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:register("item", "shield", { name = "Shield", armor = 5 })
    reg:register("item", "sword", { name = "Sword", damage = 10 })
    local items = reg:getAll("item")
    mods_log("shield name = " .. items.shield.name)
    mods_log("sword damage = " .. tostring(items.sword.damage))
end
```

---

#### `LContentRegistry:getTypes`

Returns registered content type names.

```lua
LContentRegistry:getTypes()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Content type names. |

**Example**

```lua
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:registerType("npc")
    local types = reg:getTypes()
    mods_log("type count = " .. #types)
end
```

---

#### `LContentRegistry:register`

Stores a Lua value under a registered content type and id.

```lua
LContentRegistry:register(type_name, id, obj)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | string | Content type name. |
| `id` | string | Entry id. |
| `obj` | table | Lua value to store. |

**Example**

```lua
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:register("item", "sword", { name = "Sword", damage = 10 })
    local sword = reg:get("item", "sword")
    mods_log("stored = " .. tostring(sword ~= nil))
    mods_log("damage = " .. tostring(sword.damage))
end
```

---

#### `LContentRegistry:registerType`

Registers a content type name. This method is available to Lua scripts.

```lua
LContentRegistry:registerType(type_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | string | Content type name. |

**Example**

```lua
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:registerType("npc")
    local types = reg:getTypes()
    mods_log("types = " .. #types)
end
```

---

#### `LContentRegistry:type`

Returns the Lua-visible type name for this content registry handle.

```lua
LContentRegistry:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LContentRegistry](#lcontentregistry)`. |

**Example**

```lua
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("encounter")
    reg:register("encounter", "wolves", { strength = 2 })
    local type_name = reg:type()
    local types = reg:getTypes()
    local wolves = reg:get("encounter", "wolves")
    mods_log("content registry type=" .. tostring(type_name) .. " type_count=" .. tostring(#types) .. " sample_strength=" .. tostring(wolves and wolves.strength))
end
```

---

#### `LContentRegistry:typeOf`

Returns whether this content registry handle matches a supported type name.

```lua
LContentRegistry:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LContentRegistry](#lcontentregistry)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("loot")
    local is_registry = reg:typeOf("LContentRegistry")
    local is_object = reg:typeOf("LObject")
    local is_manager = reg:typeOf("LModManager")
    local types = reg:getTypes()
    mods_log("registry type guard registry=" .. tostring(is_registry) .. " object=" .. tostring(is_object) .. " manager=" .. tostring(is_manager) .. " type_count=" .. tostring(#types))
end
```

---

## LMod

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LMod:getApiVersion`

Returns the optional required API version.

```lua
LMod:getApiVersion()
```

**Returns**

| Type | Description |
|------|-------------|
| string | API version string, or nil when unset. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "save_patch", name = "Save Patch" })
    local host_version = "1.3.0"
    mod:setApiVersion("1.2.0")
    local required = mod:getApiVersion()
    local compatible, reason = lurek.mods.checkApiVersion(mod, host_version)
    mods_log("saved campaign api host=" .. host_version .. " required=" .. tostring(required) .. " compatible=" .. tostring(compatible) .. " reason=" .. tostring(reason))
end
```

---

#### `LMod:getAuthor`

Returns the mod author. This method is available to Lua scripts.

```lua
LMod:getAuthor()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Mod author. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "narrative_pack", name = "Narrative Pack", author = "Dev" })
    local author = mod:getAuthor()
    local name = mod:getName()
    local id = mod:getId()
    local manager = lurek.mods.newModManager()
    manager:registerMod(mod)
    mods_log("mod credit id=" .. tostring(id) .. " name=" .. tostring(name) .. " author=" .. tostring(author) .. " registered=" .. tostring(manager:hasMod(id)))
end
```

---

#### `LMod:getCapabilities`

Returns capability names declared by the mod.

```lua
LMod:getCapabilities()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Capability names. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "renderer_pack", name = "Renderer Pack" })
    local manager = lurek.mods.newModManager()
    mod:setCapabilities({ "renderer", "audio", "physics" })
    manager:registerMod(mod)
    local capabilities = mod:getCapabilities()
    local renderers = manager:getModsByCapability("renderer")
    local capability_list = table.concat(capabilities, ", ")
    local first_renderer = renderers[1] and renderers[1].id or "none"
    mods_log("capabilities = " .. capability_list .. " renderer_matches=" .. tostring(#renderers) .. " first_renderer=" .. tostring(first_renderer))
end
```

---

#### `LMod:getConfig`

Returns the stored Lua config value.

```lua
LMod:getConfig()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Stored config value, or nil when unset. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "cfg", name = "Cfg" })
    mod:setConfig({ difficulty = "story", subtitles = true })
    local config = mod:getConfig()
    mods_log("config exists = " .. tostring(config ~= nil))
    mods_log("subtitles = " .. tostring(config.subtitles))
end
```

---

#### `LMod:getConfigSchema`

Returns config schema entries. This method is available to Lua scripts.

```lua
LMod:getConfigSchema()
```

**Returns**

| Type | Description |
|------|-------------|
| LModGetConfigSchemaResult | Array of schema entries with `key`, `type`, and `default` fields. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "schema", name = "Schema" })
    mod:setConfigSchema({
        { key = "volume", type = "number", default = "0.5" },
        { key = "language", type = "string", default = "en" },
    })
    local schema = mod:getConfigSchema()
    mods_log("schema entries = " .. #schema)
    mods_log("second default = " .. schema[2].default)
end
```

---

#### `LMod:getDependencies`

Returns mod dependency ids. This method is available to Lua scripts.

```lua
LMod:getDependencies()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of dependency ids. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({
        id = "deps",
        name = "Deps",
        dependencies = { "core", "ui" },
    })
    local dependencies = mod:getDependencies()
    mods_log("dependency count = " .. #dependencies)
    mods_log("first dependency = " .. dependencies[1])
end
```

---

#### `LMod:getDescription`

Returns the mod description. This method is available to Lua scripts.

```lua
LMod:getDescription()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Mod description. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({
        id = "my_mod",
        name = "My Mod",
        description = "Adds extra encounters",
    })
    mods_log("description = " .. mod:getDescription())
end
```

---

#### `LMod:getHook`

Returns a stored hook function by name.

```lua
LMod:getHook(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Hook name. |

**Returns**

| Type | Description |
|------|-------------|
| function | Hook callback, or nil when missing. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "hooks", name = "Hooks" })
    mod:setHook("onLoad", function()
        mods_log("hook fired")
    end)
    local hook = mod:getHook("onLoad")
    mods_log("hook exists = " .. tostring(hook ~= nil))
end
```

---

#### `LMod:getHookNames`

Returns registered hook names. This method is available to Lua scripts.

```lua
LMod:getHookNames()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Hook names. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "hooks", name = "Hooks" })
    mod:setHook("onLoad", function()
    end)
    mod:setHook("onUnload", function()
    end)
    local names = mod:getHookNames()
    mods_log("hook count = " .. #names)
    mods_log("has onLoad = " .. tostring(mod:hasHook("onLoad")))
end
```

---

#### `LMod:getId`

Returns the mod id. This method is available to Lua scripts.

```lua
LMod:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Mod id. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "ui_overhaul", name = "UI Overhaul" })
    local id = mod:getId()
    local name = mod:getName()
    local priority = mod:getPriority()
    local manager = lurek.mods.newModManager()
    manager:registerMod(mod)
    mods_log("manifest identity id=" .. tostring(id) .. " name=" .. tostring(name) .. " priority=" .. tostring(priority) .. " count=" .. tostring(manager:getModCount()))
end
```

---

#### `LMod:getName`

Returns the mod display name. This method is available to Lua scripts.

```lua
LMod:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Mod name. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "economy_patch", name = "Economy Patch" })
    local name = mod:getName()
    local id = mod:getId()
    local version = mod:getVersion()
    local descriptor = name .. "@" .. tostring(version)
    mods_log("display name id=" .. tostring(id) .. " name=" .. tostring(name) .. " descriptor=" .. descriptor)
end
```

---

#### `LMod:getPriority`

Returns the mod priority. This method is available to Lua scripts.

```lua
LMod:getPriority()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Mod priority. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "late_patch", name = "Late Patch", priority = 25 })
    local priority = mod:getPriority()
    local manager = lurek.mods.newModManager()
    manager:registerMod(lurek.mods.newMod({ id = "base_patch", name = "Base Patch", priority = 0 }))
    manager:registerMod(mod)
    local order = manager:getLoadOrder()
    local last_id = order[#order] and order[#order].id or "none"
    mods_log("priority value=" .. tostring(priority) .. " load_order_size=" .. tostring(#order) .. " last_id=" .. tostring(last_id))
end
```

---

#### `LMod:getSandbox`

Returns the configured sandbox policy.

```lua
LMod:getSandbox()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Sandbox configuration table, or nil when unset. |

**Example**

```lua
do
    ensure_dir("save")
    local root = "save/_mods_sandbox_readback"
    local root_abs = lurek.filesystem.getSaveDirectory() .. "/_mods_sandbox_readback"
    ensure_dir(root)
    local mod = lurek.mods.newMod({ id = "sandbox_readback", name = "Sandbox Readback" })
    mod:setSandbox({
        api_mode = "allow_list",
        apis = { "filesystem" },
        hook_mode = "allow_list",
        hooks = { "on_load" },
        read_mode = "allow_list",
        read_roots = { root_abs },
        blocked_ops = { "filesystem.remove" },
        allow_network = false,
        allow_file_write = false,
    })
    local sandbox = mod:getSandbox()
    mods_log("sandbox hooks=" .. tostring(sandbox and sandbox.hooks and sandbox.hooks[1]))
    mods_log("sandbox allow_network=" .. tostring(sandbox and sandbox.allow_network))
    mods_log("sandbox blocked_op=" .. tostring(sandbox and sandbox.blocked_ops and sandbox.blocked_ops[1]))
end
```

---

#### `LMod:getVersion`

Returns the mod version. This method is available to Lua scripts.

```lua
LMod:getVersion()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Mod version. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "patch_notes", name = "Patch Notes", version = "1.4.2" })
    local version = mod:getVersion()
    local id = mod:getId()
    local api = mod:getApiVersion()
    local combined = id .. ":" .. tostring(version)
    mods_log("version query combined=" .. combined .. " api_requirement=" .. tostring(api) .. " loaded=" .. tostring(mod:isLoaded()))
end
```

---

#### `LMod:hasHook`

Returns whether a hook name is registered.

```lua
LMod:hasHook(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Hook name. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the hook exists. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "hooks", name = "Hooks" })
    mods_log("before = " .. tostring(mod:hasHook("onLoad")))
    mod:setHook("onLoad", function()
    end)
    mods_log("after = " .. tostring(mod:hasHook("onLoad")))
end
```

---

#### `LMod:isEnabled`

Returns whether the mod is enabled.

```lua
LMod:isEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when enabled. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "ruleset", name = "Ruleset Override" })
    local default_enabled = mod:isEnabled()
    mod:setEnabled(false)
    local disabled_state = mod:isEnabled()
    mod:setEnabled(true)
    local restored_state = mod:isEnabled()
    mods_log("ruleset enabled default=" .. tostring(default_enabled) .. " disabled=" .. tostring(disabled_state) .. " restored=" .. tostring(restored_state))
end
```

---

#### `LMod:isLoaded`

Returns whether the mod is loaded. This method is available to Lua scripts.

```lua
LMod:isLoaded()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when loaded. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "fresh_manifest", name = "Fresh Manifest" })
    local before_register = mod:isLoaded()
    local manager = lurek.mods.newModManager()
    manager:registerMod(mod)
    local listed = manager:getAllMods()
    local listed_loaded = listed[1] and listed[1].loaded or nil
    mods_log("fresh mod loaded before_register=" .. tostring(before_register) .. " listed_loaded=" .. tostring(listed_loaded) .. " count=" .. tostring(#listed))
end
```

---

#### `LMod:releaseRefs`

Releases stored Lua registry references for hooks and config.

```lua
LMod:releaseRefs()
```

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "release", name = "Release" })
    mod:setHook("test", function()
    end)
    mod:setConfig({ x = 1 })
    mod:releaseRefs()
    mods_log("hook exists = " .. tostring(mod:getHook("test") ~= nil))
    mods_log("config exists = " .. tostring(mod:getConfig() ~= nil))
end
```

---

#### `LMod:runHook`

Executes one registered hook under the mod's configured sandbox policy.

```lua
LMod:runHook(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Hook name. |

**Returns**

| Type | Description |
|------|-------------|
| table | Hook return values passed through from Lua. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "runtime_hooks", name = "Runtime Hooks" })
    mod:setSandbox({
        hook_mode = "allow_list",
        hooks = { "on_load" },
    })
    mod:setHook("on_load", function(a, b)
        return a + b, "ok"
    end)
    local sum, status = mod:runHook("on_load", 2, 3)
    mods_log("hook sum=" .. tostring(sum))
    mods_log("hook status=" .. tostring(status))
end
```

---

#### `LMod:setApiVersion`

Sets the required API version string.

```lua
LMod:setApiVersion(api_version)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `api_version` | string | API version string. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "ui_patch", name = "UI Patch" })
    local host_version = "1.5.0"
    mod:setApiVersion("2.0.0")
    local required = mod:getApiVersion()
    local compatible, reason = lurek.mods.checkApiVersion(mod, host_version)
    mods_log("api requirement host=" .. host_version .. " required=" .. tostring(required) .. " compatible=" .. tostring(compatible) .. " reason=" .. tostring(reason))
end
```

---

#### `LMod:setCapabilities`

Sets capability names from an array table.

```lua
LMod:setCapabilities(caps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `caps` | table | Array table of capability names. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "caps", name = "Caps" })
    mod:setCapabilities({ "renderer", "audio", "physics" })
    local capabilities = mod:getCapabilities()
    mods_log("capability count = " .. #capabilities)
    mods_log("first = " .. capabilities[1])
end
```

---

#### `LMod:setConfig`

Stores a Lua config value for this mod.

```lua
LMod:setConfig(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | Config value to store (table, number, string, or boolean). |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "cfg", name = "Cfg" })
    mod:setConfig({ difficulty = "hard", volume = 0.8 })
    local config = mod:getConfig()
    mods_log("difficulty = " .. config.difficulty)
    mods_log("volume = " .. tostring(config.volume))
end
```

---

#### `LMod:setConfigSchema`

Sets config schema entries from a Lua table.

```lua
LMod:setConfigSchema(schema)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `schema` | table | Array table of schema entries. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "schema", name = "Schema" })
    mod:setConfigSchema({
        { key = "volume", type = "number", default = "0.5" },
        { key = "language", type = "string", default = "en" },
    })
    local schema = mod:getConfigSchema()
    mods_log("schema count = " .. #schema)
    mods_log("first key = " .. schema[1].key)
end
```

---

#### `LMod:setEnabled`

Sets whether the mod is enabled. This method is available to Lua scripts.

```lua
LMod:setEnabled(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | boolean | Enabled flag. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "toggle_campaign", name = "Toggle Campaign Rules" })
    local before = mod:isEnabled()
    mod:setEnabled(false)
    local after = mod:isEnabled()
    local manager = lurek.mods.newModManager()
    manager:registerMod(mod)
    mods_log("campaign toggle before=" .. tostring(before) .. " after=" .. tostring(after) .. " registered=" .. tostring(manager:hasMod(mod:getId())))
end
```

---

#### `LMod:setHook`

Stores a Lua hook function by name. This method is available to Lua scripts.

```lua
LMod:setHook(name, func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Hook name. |
| `func` | function | Hook callback function. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "hooks", name = "Hooks" })
    mod:setHook("onLoad", function()
        mods_log("hook fired")
    end)
    mods_log("has onLoad = " .. tostring(mod:hasHook("onLoad")))
    mods_log("hook value = " .. tostring(mod:getHook("onLoad") ~= nil))
end
```

---

#### `LMod:setSandbox`

Sets the sandbox policy used by `runHook`.

```lua
LMod:setSandbox(sandbox)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sandbox` | table | Sandbox configuration table. |

**Example**

```lua
do
    ensure_dir("save")
    ensure_dir("save/example-mods")
    local root = "save/_mods_sandbox_unit"
    local root_abs = lurek.filesystem.getSaveDirectory() .. "/_mods_sandbox_unit"
    ensure_dir(root)
    local mod = lurek.mods.newMod({ id = "sandbox_guard", name = "Sandbox Guard" })
    mod:setSandbox({
        api_mode = "allow_list",
        apis = { "filesystem" },
        hook_mode = "allow_list",
        hooks = { "on_load" },
        read_mode = "allow_list",
        read_roots = { root_abs },
        allow_network = false,
        allow_file_write = false,
        max_memory = 4096,
    })
    local sandbox = mod:getSandbox()
    mods_log("sandbox api_mode=" .. tostring(sandbox and sandbox.api_mode))
    mods_log("sandbox max_memory=" .. tostring(sandbox and sandbox.max_memory))
end
```

---

#### `LMod:type`

Returns the Lua-visible type name for this mod handle.

```lua
LMod:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LMod](#lmod)`. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "strict_type", name = "Strict Type" })
    local type_name = mod:type()
    local is_mod = mod:typeOf("LMod")
    local is_object = mod:typeOf("LObject")
    local id = mod:getId()
    mods_log("mod type=" .. tostring(type_name) .. " is_mod=" .. tostring(is_mod) .. " is_object=" .. tostring(is_object) .. " id=" .. tostring(id))
end
```

---

#### `LMod:typeOf`

Returns whether this mod handle matches a supported type name.

```lua
LMod:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LMod](#lmod)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "type_guard", name = "Type Guard" })
    local is_mod = mod:typeOf("LMod")
    local is_object = mod:typeOf("LObject")
    local is_manager = mod:typeOf("LModManager")
    local type_name = mod:type()
    mods_log("type guard type=" .. tostring(type_name) .. " mod=" .. tostring(is_mod) .. " object=" .. tostring(is_object) .. " manager=" .. tostring(is_manager))
end
```

---

## LModManager

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LModManager:clearLoadOrder`

Clears explicit load order. This method is available to Lua scripts.

```lua
LModManager:clearLoadOrder()
```

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local mod_a = lurek.mods.newMod({ id = "a", name = "A", priority = 0 })
    local mod_b = lurek.mods.newMod({ id = "b", name = "B", priority = 10 })
    mgr:registerMod(mod_a)
    mgr:registerMod(mod_b)
    mgr:setLoadOrder({ "b", "a" })
    mods_log("custom first = " .. mgr:getLoadOrder()[1].id)
    mgr:clearLoadOrder()
    mods_log("default first = " .. mgr:getLoadOrder()[1].id)
end
```

---

#### `LModManager:clearReloadQueue`

Clears the reload queue. This method is available to Lua scripts.

```lua
LModManager:clearReloadQueue()
```

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "hot", name = "Hot" })
    mgr:registerMod(mod)
    mgr:markForReload("hot")
    mgr:clearReloadQueue()
    mods_log("queued = " .. #mgr:getReloadQueue())
end
```

---

#### `LModManager:getAllMods`

Returns metadata for all registered mods.

```lua
LModManager:getAllMods()
```

**Returns**

| Type | Description |
|------|-------------|
| LModManagerGetAllModsResult | Array table of mod metadata tables. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "list", name = "List", version = "2.0.0" })
    mgr:registerMod(mod)
    local mods = mgr:getAllMods()
    mods_log("mods = " .. #mods)
    mods_log("first id = " .. mods[1].id)
end
```

---

#### `LModManager:getLoadOrder`

Returns the resolved load order. This method is available to Lua scripts.

```lua
LModManager:getLoadOrder()
```

**Returns**

| Type | Description |
|------|-------------|
| LModManagerGetLoadOrderResult | Array table of mod metadata tables. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local core = lurek.mods.newMod({ id = "core", name = "Core", priority = 0 })
    local patch = lurek.mods.newMod({
        id = "patch",
        name = "Patch",
        priority = 10,
        dependencies = { "core" },
    })
    mgr:registerMod(core)
    mgr:registerMod(patch)
    local order = mgr:getLoadOrder()
    mods_log("first = " .. order[1].id)
    mods_log("second = " .. order[2].id)
end
```

---

#### `LModManager:getModCount`

Returns the number of registered mods.

```lua
LModManager:getModCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Mod count. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "core", name = "Core", priority = 0 })
    mods_log("before = " .. mgr:getModCount())
    mgr:registerMod(mod)
    mods_log("after = " .. mgr:getModCount())
end
```

---

#### `LModManager:getModPath`

Returns the filesystem path for a registered mod.

```lua
LModManager:getModPath(mod_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mod_id` | string | Mod id. |

**Returns**

| Type | Description |
|------|-------------|
| string | Mod path, or nil when unknown. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "memory_only", name = "Memory Only" })
    mgr:registerMod(mod)
    local path = mgr:getModPath("memory_only")
    mods_log("has mod = " .. tostring(mgr:hasMod("memory_only")))
    mods_log("path = " .. tostring(path))
end
```

---

#### `LModManager:getModsByCapability`

Returns metadata for mods declaring a capability.

```lua
LModManager:getModsByCapability(capability)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `capability` | string | Capability name. |

**Returns**

| Type | Description |
|------|-------------|
| LModManagerGetModsByCapabilityResult | Array table of mod metadata tables. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "render_mod", name = "Renderer Mod" })
    mod:setCapabilities({ "renderer" })
    mgr:registerMod(mod)
    local renderers = mgr:getModsByCapability("renderer")
    mods_log("renderer mods = " .. #renderers)
    mods_log("first id = " .. renderers[1].id)
end
```

---

#### `LModManager:getReloadQueue`

Returns mod ids waiting for reload.

```lua
LModManager:getReloadQueue()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of mod ids. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "hot", name = "Hot" })
    mgr:registerMod(mod)
    mgr:markForReload("hot")
    mods_log("queued = " .. #mgr:getReloadQueue())
end
```

---

#### `LModManager:hasCircularDependencies`

Returns whether registered mods have circular dependencies.

```lua
LModManager:hasCircularDependencies()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a cycle exists. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local mod_a = lurek.mods.newMod({ id = "a", name = "A", dependencies = { "b" } })
    local mod_b = lurek.mods.newMod({ id = "b", name = "B", dependencies = { "a" } })
    mgr:registerMod(mod_a)
    mgr:registerMod(mod_b)
    mods_log("circular = " .. tostring(mgr:hasCircularDependencies()))
end
```

---

#### `LModManager:hasMod`

Returns whether a mod id is registered.

```lua
LModManager:hasMod(mod_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mod_id` | string | Mod id. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the mod exists. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "core", name = "Core", priority = 0 })
    mods_log("before = " .. tostring(mgr:hasMod("core")))
    mgr:registerMod(mod)
    mods_log("after = " .. tostring(mgr:hasMod("core")))
end
```

---

#### `LModManager:markForReload`

Marks a mod id for reload. This method is available to Lua scripts.

```lua
LModManager:markForReload(mod_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mod_id` | string | Mod id. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the mod was marked. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "hot", name = "Hot" })
    mgr:registerMod(mod)
    local marked = mgr:markForReload("hot")
    mods_log("marked = " .. tostring(marked))
    mods_log("queued = " .. #mgr:getReloadQueue())
end
```

---

#### `LModManager:processReloadQueue`

Processes and clears the reload queue.

```lua
LModManager:processReloadQueue()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of processed mod ids. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "hot", name = "Hot" })
    mgr:registerMod(mod)
    mgr:markForReload("hot")
    local processed = mgr:processReloadQueue()
    mods_log("processed = " .. #processed)
    mods_log("queued after = " .. #mgr:getReloadQueue())
end
```

---

#### `LModManager:registerMod`

Registers a mod with the manager. This method is available to Lua scripts.

```lua
LModManager:registerMod(ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ud` | [LMod](#lmod) | Mod handle. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "core", name = "Core", priority = 0 })
    mod:setEnabled(true)
    mgr:registerMod(mod)
    mods_log("count = " .. mgr:getModCount())
end
```

---

#### `LModManager:scanFolder`

Scans a folder for mod metadata. This method is available to Lua scripts.

```lua
LModManager:scanFolder(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Folder path. |

**Returns**

| Type | Description |
|------|-------------|
| LModManagerScanFolderResult | Array table of discovered mod metadata tables. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local root = "save/example-mods/scan_case"
    prepare_scan_folder(root)
    local found = mgr:scanFolder(root)
    local has_demo = mgr:hasMod("demo_pack")
    local all_mods = mgr:getAllMods()
    local first_id = all_mods[1] and all_mods[1].id or "none"
    mods_log("scanned mods = " .. #found .. " registered=" .. tostring(mgr:getModCount()) .. " has_demo=" .. tostring(has_demo) .. " first_id=" .. tostring(first_id))
end
```

---

#### `LModManager:setLoadOrder`

Sets explicit load order from an array of mod ids.

```lua
LModManager:setLoadOrder(order_table)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `order_table` | table | Array table of mod ids. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local mod_a = lurek.mods.newMod({ id = "a", name = "A", priority = 0 })
    local mod_b = lurek.mods.newMod({ id = "b", name = "B", priority = 10 })
    mgr:registerMod(mod_a)
    mgr:registerMod(mod_b)
    mgr:setLoadOrder({ "b", "a" })
    local order = mgr:getLoadOrder()
    mods_log("first = " .. order[1].id)
    mods_log("second = " .. order[2].id)
end
```

---

#### `LModManager:type`

Returns the Lua-visible type name for this mod manager handle.

```lua
LModManager:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LModManager](#lmodmanager)`. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "typed_manager_mod", name = "Typed Manager Mod" })
    mgr:registerMod(mod)
    local type_name = mgr:type()
    local is_manager = mgr:typeOf("LModManager")
    local count = mgr:getModCount()
    mods_log("manager type=" .. tostring(type_name) .. " is_manager=" .. tostring(is_manager) .. " count=" .. tostring(count))
end
```

---

#### `LModManager:typeOf`

Returns whether this mod manager handle matches a supported type name.

```lua
LModManager:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LModManager](#lmodmanager)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    mgr:registerMod(lurek.mods.newMod({ id = "guarded_mod", name = "Guarded Mod" }))
    local is_manager = mgr:typeOf("LModManager")
    local is_object = mgr:typeOf("LObject")
    local is_mod = mgr:typeOf("LMod")
    local count = mgr:getModCount()
    mods_log("manager type guard manager=" .. tostring(is_manager) .. " object=" .. tostring(is_object) .. " mod=" .. tostring(is_mod) .. " count=" .. tostring(count))
end
```

---

#### `LModManager:unregisterMod`

Unregisters a mod by id. This method is available to Lua scripts.

```lua
LModManager:unregisterMod(mod_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mod_id` | string | Mod id. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when a mod was removed. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "temp", name = "Temp" })
    mgr:registerMod(mod)
    local removed = mgr:unregisterMod("temp")
    mods_log("removed = " .. tostring(removed) .. " after = " .. mgr:getModCount())
end
```

---

#### `LModManager:validateDependencies`

Returns dependency validation messages.

```lua
LModManager:validateDependencies()
```

**Returns**

| Type | Description |
|------|-------------|
| string[] | Validation message strings. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({
        id = "addon",
        name = "Addon",
        dependencies = { "core" },
    })
    mgr:registerMod(mod)
    local missing = mgr:validateDependencies()
    mods_log("missing count = " .. #missing)
    mods_log("first missing = " .. tostring(missing[1]))
end
```

---
