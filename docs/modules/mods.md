# Mods

- The `mods` module is a powerful Feature Systems tier component that provides a comprehensive framework for user-generated content and game modifications in Lurek2D.

It is engineered to handle the complete lifecycle of mods, from initial discovery on the filesystem to dependency resolution, load-order sorting, asset mounting, and runtime hot-reloading. The core orchestrator is the `ModManager`, which actively scans designated directories for `mod.toml` manifests, securely parses them, and validates their structural integrity and version constraints.

At the heart of the system is the `ModInfo` struct, which encapsulates all vital metadata for a single mod. This includes standard fields like name, version, and author, alongside critical functional data such as script entry points, declared capabilities, custom configuration schemas, and optional SHA-256 integrity signatures. A major responsibility of the `ModManager` is safely resolving inter-mod dependencies. It performs robust cyclic dependency detection and utilizes a topological sort, weighted by author-defined priority values, to compute a deterministic and stable load order. It also supports manual load-order overrides for resolving complex edge-case conflicts.

Once loaded, the module bridges the gap between engine architecture and user content. Mods can seamlessly override existing game assets within the virtual filesystem, introduce entirely new content via the typed `ContentRegistry`, and inject Lua scripts that execute within the engine's sandboxed environment. The module provides sophisticated runtime tools, including enable/disable toggling for instantaneous mod switching and a robust hot-reload queue that can re-parse and re-apply modified mods on the fly without requiring a full game restart. Fully exposed to Lua via the `lurek.mods.*` API, this system empowers developers to treat first-party game content and community mods with identical architectural parity.

## Functions

### `lurek.mods.checkApiVersion`

Checks whether a mod API version is compatible with a host version.

```lua
-- signature
lurek.mods.checkApiVersion(mod_ud, host_version)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mod_ud` | `LMod` | Mod handle. |
| `host_version` | `string` | Host API version string. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | a True when compatible. |
| `string` | b Error message when incompatible, otherwise nil. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "compat", name = "Compat" })
    mod:setApiVersion("2.0.0")
    local ok, err = lurek.mods.checkApiVersion(mod, "1.5.0")
    print("compatible = " .. tostring(ok))
    print("error = " .. tostring(err))
end
```

---

### `lurek.mods.newMod`

Creates a mod metadata handle from a Lua table.

```lua
-- signature
lurek.mods.newMod(info)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `info` | `table` | Mod metadata table. |

**Returns**

| Type | Description |
|------|-------------|
| `LMod` | New mod handle. |

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
    print("id = " .. mod:getId())
    print("priority = " .. mod:getPriority())
end
```

---

### `lurek.mods.newModManager`

Creates an empty mod manager. This function is exposed to Lua scripts.

```lua
-- signature
lurek.mods.newModManager()
```

**Returns**

| Type | Description |
|------|-------------|
| `LModManager` | New mod manager handle. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    print("mod count = " .. mgr:getModCount())
    print("type = " .. mgr:type())
end
```

---

### `lurek.mods.newRegistry`

Creates an empty content registry.

```lua
-- signature
lurek.mods.newRegistry()
```

**Returns**

| Type | Description |
|------|-------------|
| `LContentRegistry` | New content registry handle. |

**Example**

```lua
do
    local reg = lurek.mods.newRegistry()
    print("registry created = " .. tostring(reg ~= nil))
    print("type = " .. reg:type())
end
```

---

## LContentRegistry

### `LContentRegistry:get`

Returns one stored value by content type and id.

```lua
-- signature
LContentRegistry:get(type_name, id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | `string` | Content type name. |
| `id` | `string` | Entry id. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | a Stored Lua value. |
| `nil` | b If missing. |

**Example**

```lua
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:register("item", "sword", { name = "Sword", damage = 10 })
    local sword = reg:get("item", "sword")
    print("got = " .. tostring(sword ~= nil))
    print("name = " .. sword.name)
end
```

---

### `LContentRegistry:getAll`

Returns all stored values for a content type keyed by id.

```lua
-- signature
LContentRegistry:getAll(type_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | `string` | Content type name. |

**Returns**

| Type | Description |
|------|-------------|
| `table` | Table of stored values keyed by id. |

**Example**

```lua
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:register("item", "shield", { name = "Shield", armor = 5 })
    reg:register("item", "sword", { name = "Sword", damage = 10 })
    local items = reg:getAll("item")
    print("shield name = " .. items.shield.name)
    print("sword damage = " .. tostring(items.sword.damage))
end
```

---

### `LContentRegistry:getTypes`

Returns registered content type names.

```lua
-- signature
LContentRegistry:getTypes()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Content type names. |

**Example**

```lua
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:registerType("npc")
    local types = reg:getTypes()
    print("type count = " .. #types)
end
```

---

### `LContentRegistry:register`

Stores a Lua value under a registered content type and id.

```lua
-- signature
LContentRegistry:register(type_name, id, obj)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | `string` | Content type name. |
| `id` | `string` | Entry id. |
| `obj` | `table` | Lua value to store. |

**Example**

```lua
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:register("item", "sword", { name = "Sword", damage = 10 })
    local sword = reg:get("item", "sword")
    print("stored = " .. tostring(sword ~= nil))
    print("damage = " .. tostring(sword.damage))
end
```

---

### `LContentRegistry:registerType`

Registers a content type name. This method is available to Lua scripts.

```lua
-- signature
LContentRegistry:registerType(type_name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `type_name` | `string` | Content type name. |

**Example**

```lua
do
    local reg = lurek.mods.newRegistry()
    reg:registerType("item")
    reg:registerType("npc")
    local types = reg:getTypes()
    print("types = " .. #types)
end
```

---

### `LContentRegistry:type`

Returns the Lua-visible type name for this content registry handle.

```lua
-- signature
LContentRegistry:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LContentRegistry`. |

**Example**

```lua
do
    local reg = lurek.mods.newRegistry()
    print("type = " .. reg:type())
end
```

---

### `LContentRegistry:typeOf`

Returns whether this content registry handle matches a supported type name.

```lua
-- signature
LContentRegistry:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LContentRegistry` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local reg = lurek.mods.newRegistry()
    print("is registry = " .. tostring(reg:typeOf("LContentRegistry")))
end
```

---

## LMod

### `LMod:getApiVersion`

Returns the optional required API version.

```lua
-- signature
LMod:getApiVersion()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | API version string, or nil when unset. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "ver", name = "Ver" })
    mod:setApiVersion("1.2.0")
    print("api version = " .. mod:getApiVersion())
end
```

---

### `LMod:getAuthor`

Returns the mod author. This method is available to Lua scripts.

```lua
-- signature
LMod:getAuthor()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Mod author. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "my_mod", name = "My Mod", author = "Dev" })
    print("author = " .. mod:getAuthor())
end
```

---

### `LMod:getCapabilities`

Returns capability names declared by the mod.

```lua
-- signature
LMod:getCapabilities()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Capability names. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "caps", name = "Caps" })
    mod:setCapabilities({ "renderer", "audio", "physics" })
    local capabilities = mod:getCapabilities()
    print("capabilities = " .. table.concat(capabilities, ", "))
end
```

---

### `LMod:getConfig`

Returns the stored Lua config value.

```lua
-- signature
LMod:getConfig()
```

**Returns**

| Type | Description |
|------|-------------|
| `table` | Stored config value, or nil when unset. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "cfg", name = "Cfg" })
    mod:setConfig({ difficulty = "story", subtitles = true })
    local config = mod:getConfig()
    print("config exists = " .. tostring(config ~= nil))
    print("subtitles = " .. tostring(config.subtitles))
end
```

---

### `LMod:getConfigSchema`

Returns config schema entries. This method is available to Lua scripts.

```lua
-- signature
LMod:getConfigSchema()
```

**Returns**

| Type | Description |
|------|-------------|
| `LModGetConfigSchemaResult` | Array of schema entries with `key`, `type`, and `default` fields. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "schema", name = "Schema" })
    mod:setConfigSchema({
        { key = "volume", type = "number", default = "0.5" },
        { key = "language", type = "string", default = "en" },
    })
    local schema = mod:getConfigSchema()
    print("schema entries = " .. #schema)
    print("second default = " .. schema[2].default)
end
```

---

### `LMod:getDependencies`

Returns mod dependency ids. This method is available to Lua scripts.

```lua
-- signature
LMod:getDependencies()
```

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array table of dependency ids. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({
        id = "deps",
        name = "Deps",
        dependencies = { "core", "ui" },
    })
    local dependencies = mod:getDependencies()
    print("dependency count = " .. #dependencies)
    print("first dependency = " .. dependencies[1])
end
```

---

### `LMod:getDescription`

Returns the mod description. This method is available to Lua scripts.

```lua
-- signature
LMod:getDescription()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Mod description. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({
        id = "my_mod",
        name = "My Mod",
        description = "Adds extra encounters",
    })
    print("description = " .. mod:getDescription())
end
```

---

### `LMod:getHook`

Returns a stored hook function by name.

```lua
-- signature
LMod:getHook(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Hook name. |

**Returns**

| Type | Description |
|------|-------------|
| `function` | Hook callback, or nil when missing. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "hooks", name = "Hooks" })
    mod:setHook("onLoad", function()
        print("hook fired")
    end)
    local hook = mod:getHook("onLoad")
    print("hook exists = " .. tostring(hook ~= nil))
end
```

---

### `LMod:getHookNames`

Returns registered hook names. This method is available to Lua scripts.

```lua
-- signature
LMod:getHookNames()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Hook names. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "hooks", name = "Hooks" })
    mod:setHook("onLoad", function()
    end)
    mod:setHook("onUnload", function()
    end)
    local names = mod:getHookNames()
    print("hook count = " .. #names)
    print("has onLoad = " .. tostring(mod:hasHook("onLoad")))
end
```

---

### `LMod:getId`

Returns the mod id. This method is available to Lua scripts.

```lua
-- signature
LMod:getId()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Mod id. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "my_mod", name = "My Mod" })
    print("id = " .. mod:getId())
end
```

---

### `LMod:getName`

Returns the mod display name. This method is available to Lua scripts.

```lua
-- signature
LMod:getName()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Mod name. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "my_mod", name = "My Mod" })
    print("name = " .. mod:getName())
end
```

---

### `LMod:getPriority`

Returns the mod priority. This method is available to Lua scripts.

```lua
-- signature
LMod:getPriority()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Mod priority. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "my_mod", name = "My Mod", priority = 25 })
    print("priority = " .. mod:getPriority())
end
```

---

### `LMod:getVersion`

Returns the mod version. This method is available to Lua scripts.

```lua
-- signature
LMod:getVersion()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | Mod version. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "my_mod", name = "My Mod", version = "1.4.2" })
    print("version = " .. mod:getVersion())
end
```

---

### `LMod:hasHook`

Returns whether a hook name is registered.

```lua
-- signature
LMod:hasHook(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Hook name. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the hook exists. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "hooks", name = "Hooks" })
    print("before = " .. tostring(mod:hasHook("onLoad")))
    mod:setHook("onLoad", function()
    end)
    print("after = " .. tostring(mod:hasHook("onLoad")))
end
```

---

### `LMod:isEnabled`

Returns whether the mod is enabled.

```lua
-- signature
LMod:isEnabled()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when enabled. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "toggle", name = "Toggle" })
    mod:setEnabled(false)
    print("enabled = " .. tostring(mod:isEnabled()))
end
```

---

### `LMod:isLoaded`

Returns whether the mod is loaded. This method is available to Lua scripts.

```lua
-- signature
LMod:isLoaded()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when loaded. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "toggle", name = "Toggle" })
    print("loaded = " .. tostring(mod:isLoaded()))
end
```

---

### `LMod:releaseRefs`

Releases stored Lua registry references for hooks and config.

```lua
-- signature
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
    print("hook exists = " .. tostring(mod:getHook("test") ~= nil))
    print("config exists = " .. tostring(mod:getConfig() ~= nil))
end
```

---

### `LMod:setApiVersion`

Sets the required API version string.

```lua
-- signature
LMod:setApiVersion(api_version)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `api_version` | `string` | API version string. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "ver", name = "Ver" })
    mod:setApiVersion("2.0.0")
    print("api version = " .. mod:getApiVersion())
end
```

---

### `LMod:setCapabilities`

Sets capability names from an array table.

```lua
-- signature
LMod:setCapabilities(caps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `caps` | `table` | Array table of capability names. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "caps", name = "Caps" })
    mod:setCapabilities({ "renderer", "audio", "physics" })
    local capabilities = mod:getCapabilities()
    print("capability count = " .. #capabilities)
    print("first = " .. capabilities[1])
end
```

---

### `LMod:setConfig`

Stores a Lua config value for this mod.

```lua
-- signature
LMod:setConfig(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | `any` | Config value to store (table, number, string, or boolean). |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "cfg", name = "Cfg" })
    mod:setConfig({ difficulty = "hard", volume = 0.8 })
    local config = mod:getConfig()
    print("difficulty = " .. config.difficulty)
    print("volume = " .. tostring(config.volume))
end
```

---

### `LMod:setConfigSchema`

Sets config schema entries from a Lua table.

```lua
-- signature
LMod:setConfigSchema(schema)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `schema` | `table` | Array table of schema entries. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "schema", name = "Schema" })
    mod:setConfigSchema({
        { key = "volume", type = "number", default = "0.5" },
        { key = "language", type = "string", default = "en" },
    })
    local schema = mod:getConfigSchema()
    print("schema count = " .. #schema)
    print("first key = " .. schema[1].key)
end
```

---

### `LMod:setEnabled`

Sets whether the mod is enabled. This method is available to Lua scripts.

```lua
-- signature
LMod:setEnabled(enabled)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `enabled` | `boolean` | Enabled flag. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "toggle", name = "Toggle" })
    print("before = " .. tostring(mod:isEnabled()))
    mod:setEnabled(false)
    print("after = " .. tostring(mod:isEnabled()))
end
```

---

### `LMod:setHook`

Stores a Lua hook function by name. This method is available to Lua scripts.

```lua
-- signature
LMod:setHook(name, func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Hook name. |
| `func` | `function` | Hook callback function. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "hooks", name = "Hooks" })
    mod:setHook("onLoad", function()
        print("hook fired")
    end)
    print("has onLoad = " .. tostring(mod:hasHook("onLoad")))
    print("hook value = " .. tostring(mod:getHook("onLoad") ~= nil))
end
```

---

### `LMod:type`

Returns the Lua-visible type name for this mod handle.

```lua
-- signature
LMod:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LMod`. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "my_mod", name = "My Mod" })
    print("type = " .. mod:type())
end
```

---

### `LMod:typeOf`

Returns whether this mod handle matches a supported type name.

```lua
-- signature
LMod:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LMod` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local mod = lurek.mods.newMod({ id = "my_mod", name = "My Mod" })
    print("is LMod = " .. tostring(mod:typeOf("LMod")))
end
```

---

## LModManager

### `LModManager:clearLoadOrder`

Clears explicit load order. This method is available to Lua scripts.

```lua
-- signature
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
    print("custom first = " .. mgr:getLoadOrder()[1].id)
    mgr:clearLoadOrder()
    print("default first = " .. mgr:getLoadOrder()[1].id)
end
```

---

### `LModManager:clearReloadQueue`

Clears the reload queue. This method is available to Lua scripts.

```lua
-- signature
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
    print("queued = " .. #mgr:getReloadQueue())
end
```

---

### `LModManager:getAllMods`

Returns metadata for all registered mods.

```lua
-- signature
LModManager:getAllMods()
```

**Returns**

| Type | Description |
|------|-------------|
| `LModManagerGetAllModsResult` | Array table of mod metadata tables. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "list", name = "List", version = "2.0.0" })
    mgr:registerMod(mod)
    local mods = mgr:getAllMods()
    print("mods = " .. #mods)
    print("first id = " .. mods[1].id)
end
```

---

### `LModManager:getLoadOrder`

Returns the resolved load order. This method is available to Lua scripts.

```lua
-- signature
LModManager:getLoadOrder()
```

**Returns**

| Type | Description |
|------|-------------|
| `LModManagerGetLoadOrderResult` | Array table of mod metadata tables. |

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
    print("first = " .. order[1].id)
    print("second = " .. order[2].id)
end
```

---

### `LModManager:getModCount`

Returns the number of registered mods.

```lua
-- signature
LModManager:getModCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Mod count. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "core", name = "Core", priority = 0 })
    print("before = " .. mgr:getModCount())
    mgr:registerMod(mod)
    print("after = " .. mgr:getModCount())
end
```

---

### `LModManager:getModPath`

Returns the filesystem path for a registered mod.

```lua
-- signature
LModManager:getModPath(mod_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mod_id` | `string` | Mod id. |

**Returns**

| Type | Description |
|------|-------------|
| `string` | Mod path, or nil when unknown. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "memory_only", name = "Memory Only" })
    mgr:registerMod(mod)
    local path = mgr:getModPath("memory_only")
    print("has mod = " .. tostring(mgr:hasMod("memory_only")))
    print("path = " .. tostring(path))
end
```

---

### `LModManager:getModsByCapability`

Returns metadata for mods declaring a capability.

```lua
-- signature
LModManager:getModsByCapability(capability)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `capability` | `string` | Capability name. |

**Returns**

| Type | Description |
|------|-------------|
| `LModManagerGetModsByCapabilityResult` | Array table of mod metadata tables. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "render_mod", name = "Renderer Mod" })
    mod:setCapabilities({ "renderer" })
    mgr:registerMod(mod)
    local renderers = mgr:getModsByCapability("renderer")
    print("renderer mods = " .. #renderers)
    print("first id = " .. renderers[1].id)
end
```

---

### `LModManager:getReloadQueue`

Returns mod ids waiting for reload.

```lua
-- signature
LModManager:getReloadQueue()
```

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array table of mod ids. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "hot", name = "Hot" })
    mgr:registerMod(mod)
    mgr:markForReload("hot")
    print("queued = " .. #mgr:getReloadQueue())
end
```

---

### `LModManager:hasCircularDependencies`

Returns whether registered mods have circular dependencies.

```lua
-- signature
LModManager:hasCircularDependencies()
```

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when a cycle exists. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local mod_a = lurek.mods.newMod({ id = "a", name = "A", dependencies = { "b" } })
    local mod_b = lurek.mods.newMod({ id = "b", name = "B", dependencies = { "a" } })
    mgr:registerMod(mod_a)
    mgr:registerMod(mod_b)
    print("circular = " .. tostring(mgr:hasCircularDependencies()))
end
```

---

### `LModManager:hasMod`

Returns whether a mod id is registered.

```lua
-- signature
LModManager:hasMod(mod_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mod_id` | `string` | Mod id. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the mod exists. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "core", name = "Core", priority = 0 })
    print("before = " .. tostring(mgr:hasMod("core")))
    mgr:registerMod(mod)
    print("after = " .. tostring(mgr:hasMod("core")))
end
```

---

### `LModManager:markForReload`

Marks a mod id for reload. This method is available to Lua scripts.

```lua
-- signature
LModManager:markForReload(mod_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mod_id` | `string` | Mod id. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the mod was marked. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "hot", name = "Hot" })
    mgr:registerMod(mod)
    local marked = mgr:markForReload("hot")
    print("marked = " .. tostring(marked))
    print("queued = " .. #mgr:getReloadQueue())
end
```

---

### `LModManager:processReloadQueue`

Processes and clears the reload queue.

```lua
-- signature
LModManager:processReloadQueue()
```

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array table of processed mod ids. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "hot", name = "Hot" })
    mgr:registerMod(mod)
    mgr:markForReload("hot")
    local processed = mgr:processReloadQueue()
    print("processed = " .. #processed)
    print("queued after = " .. #mgr:getReloadQueue())
end
```

---

### `LModManager:registerMod`

Registers a mod with the manager. This method is available to Lua scripts.

```lua
-- signature
LModManager:registerMod(ud)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `ud` | `LMod` | Mod handle. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "core", name = "Core", priority = 0 })
    mod:setEnabled(true)
    mgr:registerMod(mod)
    print("count = " .. mgr:getModCount())
end
```

---

### `LModManager:scanFolder`

Scans a folder for mod metadata. This method is available to Lua scripts.

```lua
-- signature
LModManager:scanFolder(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | `string` | Folder path. |

**Returns**

| Type | Description |
|------|-------------|
| `LModManagerScanFolderResult` | Array table of discovered mod metadata tables. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local found = mgr:scanFolder("content/examples")
    print("scanned mods = " .. #found)
    print("registered = " .. mgr:getModCount())
end
```

---

### `LModManager:setLoadOrder`

Sets explicit load order from an array of mod ids.

```lua
-- signature
LModManager:setLoadOrder(order_table)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `order_table` | `table` | Array table of mod ids. |

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
    print("first = " .. order[1].id)
    print("second = " .. order[2].id)
end
```

---

### `LModManager:type`

Returns the Lua-visible type name for this mod manager handle.

```lua
-- signature
LModManager:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LModManager`. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    print("type = " .. mgr:type())
end
```

---

### `LModManager:typeOf`

Returns whether this mod manager handle matches a supported type name.

```lua
-- signature
LModManager:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LModManager` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    print("is manager = " .. tostring(mgr:typeOf("LModManager")))
end
```

---

### `LModManager:unregisterMod`

Unregisters a mod by id. This method is available to Lua scripts.

```lua
-- signature
LModManager:unregisterMod(mod_id)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mod_id` | `string` | Mod id. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when a mod was removed. |

**Example**

```lua
do
    local mgr = lurek.mods.newModManager()
    local mod = lurek.mods.newMod({ id = "temp", name = "Temp" })
    mgr:registerMod(mod)
    local removed = mgr:unregisterMod("temp")
    print("removed = " .. tostring(removed) .. " after = " .. mgr:getModCount())
end
```

---

### `LModManager:validateDependencies`

Returns dependency validation messages.

```lua
-- signature
LModManager:validateDependencies()
```

**Returns**

| Type | Description |
|------|-------------|
| `string[]` | Validation message strings. |

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
    print("missing count = " .. #missing)
    print("first missing = " .. tostring(missing[1]))
end
```

---
