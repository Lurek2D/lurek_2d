//! Registers the `lurek.mods` Lua API for mod metadata, config schemas, info tables, and mod-management userdata.

use super::SharedState;
use crate::mods::{
    FieldType, HookPoint, ModError, ModInfo, ModLimits, ModManager, ModSandbox, SandboxListMode,
};
use crate::runtime::{call_function_with_policy, LuaExecutionPolicy};
use mlua::prelude::*;
use std::cell::RefCell;
use std::collections::{HashMap, HashSet};
use std::rc::Rc;

fn lua_string_sequence(tbl: &LuaTable, field: &str) -> Vec<String> {
    tbl.get::<_, LuaTable>(field)
        .map(|values| values.sequence_values::<String>().flatten().collect())
        .unwrap_or_default()
}

fn lua_config_schema(tbl: &LuaTable) -> Vec<(String, String, String)> {
    tbl.get::<_, LuaTable>("config_schema")
        .map(|schema| {
            schema
                .sequence_values::<LuaTable>()
                .flatten()
                .filter_map(|entry| {
                    let key: String = entry.get("key").ok()?;
                    let type_hint: String = entry.get("type").unwrap_or_else(|_| "any".into());
                    let default: String = entry.get("default").unwrap_or_default();
                    Some((key, type_hint, default))
                })
                .collect()
        })
        .unwrap_or_default()
}

fn lua_error_from_mod(error: ModError) -> LuaError {
    LuaError::RuntimeError(error.to_string())
}

fn default_mod_limits() -> ModLimits {
    ModLimits::default()
}

fn validate_symbol(kind: &str, value: &str, max_len: usize) -> LuaResult<()> {
    if value.is_empty() {
        return Err(LuaError::RuntimeError(format!("{} cannot be empty", kind)));
    }
    if value.len() > max_len {
        return Err(LuaError::RuntimeError(format!(
            "{} '{}' exceeds max length {}",
            kind, value, max_len
        )));
    }
    if !value
        .chars()
        .all(|ch| ch.is_ascii_alphanumeric() || matches!(ch, '_' | '-' | '.' | ':'))
    {
        return Err(LuaError::RuntimeError(format!(
            "{} '{}' contains unsupported characters",
            kind, value
        )));
    }
    Ok(())
}

fn validate_version(value: &str, max_len: usize) -> LuaResult<()> {
    if value.is_empty() {
        return Err(LuaError::RuntimeError("version cannot be empty".into()));
    }
    if value.len() > max_len {
        return Err(LuaError::RuntimeError(format!(
            "version '{}' exceeds max length {}",
            value, max_len
        )));
    }
    if !value
        .chars()
        .all(|ch| ch.is_ascii_alphanumeric() || matches!(ch, '.' | '-' | '+'))
    {
        return Err(LuaError::RuntimeError(format!(
            "version '{}' contains unsupported characters",
            value
        )));
    }
    Ok(())
}

fn normalize_relative_asset_path(path: &str) -> LuaResult<String> {
    let logical = path.replace('\\', "/");
    if logical.is_empty() {
        return Err(LuaError::RuntimeError("asset path cannot be empty".into()));
    }
    let candidate = std::path::Path::new(&logical);
    if candidate.is_absolute() {
        return Err(LuaError::RuntimeError(
            "asset path must be relative to the mod root".into(),
        ));
    }
    let mut cleaned = Vec::new();
    for component in candidate.components() {
        match component {
            std::path::Component::CurDir => {}
            std::path::Component::Normal(part) => cleaned.push(part.to_string_lossy().into_owned()),
            std::path::Component::ParentDir => {
                return Err(LuaError::RuntimeError(
                    "asset path traversal is not allowed".into(),
                ))
            }
            std::path::Component::RootDir | std::path::Component::Prefix(_) => {
                return Err(LuaError::RuntimeError(
                    "asset path must be relative to the mod root".into(),
                ))
            }
        }
    }
    Ok(cleaned.join("/"))
}

fn parse_hook_point(name: &str) -> LuaResult<HookPoint> {
    HookPoint::parse_validated(name, &default_mod_limits()).map_err(lua_error_from_mod)
}

fn parse_sandbox_mode(value: &str, field: &str) -> LuaResult<SandboxListMode> {
    SandboxListMode::from_name(value).ok_or_else(|| {
        LuaError::RuntimeError(format!(
            "{} must be one of allow_all, deny_by_default, allow_list",
            field
        ))
    })
}

fn parse_lua_sandbox(tbl: &LuaTable) -> LuaResult<ModSandbox> {
    let limits = default_mod_limits();
    let mut sandbox = ModSandbox::new();

    if let Ok(mode) = tbl.get::<_, String>("api_mode") {
        sandbox.set_api_mode(parse_sandbox_mode(&mode, "sandbox.api_mode")?);
    }
    if let Ok(apis) = tbl.get::<_, LuaTable>("apis") {
        for api in apis.sequence_values::<String>().flatten() {
            validate_symbol("sandbox api", &api, limits.max_capability_len)?;
            sandbox.allow_api(api);
        }
    }

    if let Ok(mode) = tbl.get::<_, String>("hook_mode") {
        sandbox.set_hook_mode(parse_sandbox_mode(&mode, "sandbox.hook_mode")?);
    }
    if let Ok(hooks) = tbl.get::<_, LuaTable>("hooks") {
        for hook_name in hooks.sequence_values::<String>().flatten() {
            sandbox.allow_hook(parse_hook_point(&hook_name)?);
        }
    }

    if let Ok(mode) = tbl.get::<_, String>("read_mode") {
        sandbox.set_read_mode(parse_sandbox_mode(&mode, "sandbox.read_mode")?);
    }
    if let Ok(read_roots) = tbl.get::<_, LuaTable>("read_roots") {
        for root in read_roots.sequence_values::<String>().flatten() {
            sandbox.allow_read_root(&root).map_err(lua_error_from_mod)?;
        }
    }

    if let Ok(blocked_ops) = tbl.get::<_, LuaTable>("blocked_ops") {
        for op in blocked_ops.sequence_values::<String>().flatten() {
            validate_symbol("sandbox blocked op", &op, limits.max_hook_len)?;
            sandbox.block_op(op);
        }
    }

    if let Ok(max_memory) = tbl.get::<_, i64>("max_memory") {
        sandbox.max_memory = usize::try_from(max_memory).map_err(|_| {
            LuaError::RuntimeError("sandbox.max_memory must be a non-negative integer".into())
        })?;
    }
    sandbox.allow_network = tbl.get::<_, bool>("allow_network").unwrap_or(false);
    sandbox.allow_file_write = tbl.get::<_, bool>("allow_file_write").unwrap_or(false);

    Ok(sandbox)
}

fn sandbox_to_lua_table<'a>(lua: &'a Lua, sandbox: &ModSandbox) -> LuaResult<LuaTable<'a>> {
    let table = lua.create_table()?;
    table.set("api_mode", sandbox.api_mode().as_str())?;
    table.set("hook_mode", sandbox.hook_mode().as_str())?;
    table.set("read_mode", sandbox.read_mode().as_str())?;
    table.set("allow_network", sandbox.allow_network)?;
    table.set("allow_file_write", sandbox.allow_file_write)?;
    table.set("max_memory", sandbox.max_memory as i64)?;

    let apis = lua.create_table()?;
    let mut api_values: Vec<String> = sandbox.allowed_apis().cloned().collect();
    api_values.sort();
    for (index, api) in api_values.into_iter().enumerate() {
        apis.set(index + 1, api)?;
    }
    table.set("apis", apis)?;

    let hooks = lua.create_table()?;
    let mut hook_values: Vec<String> = sandbox.allowed_hooks().map(HookPoint::as_str).collect();
    hook_values.sort();
    for (index, hook) in hook_values.into_iter().enumerate() {
        hooks.set(index + 1, hook)?;
    }
    table.set("hooks", hooks)?;

    let read_roots = lua.create_table()?;
    for (index, root) in sandbox.allowed_read_roots().iter().enumerate() {
        read_roots.set(index + 1, root.to_string_lossy().into_owned())?;
    }
    table.set("read_roots", read_roots)?;

    let blocked_ops = lua.create_table()?;
    let mut blocked_values: Vec<String> = sandbox.blocked_ops().cloned().collect();
    blocked_values.sort();
    for (index, op) in blocked_values.into_iter().enumerate() {
        blocked_ops.set(index + 1, op)?;
    }
    table.set("blocked_ops", blocked_ops)?;

    Ok(table)
}

fn restore_mod_context(
    state: &Rc<RefCell<SharedState>>,
    previous_mod_id: Option<String>,
    previous_sandbox: Option<ModSandbox>,
) {
    state
        .borrow_mut()
        .restore_active_mod_context(previous_mod_id, previous_sandbox);
}

fn call_hook_with_sandbox<'lua>(
    lua: &'lua Lua,
    state: &Rc<RefCell<SharedState>>,
    mod_id: &str,
    sandbox: Option<ModSandbox>,
    hook_name: &str,
    function: LuaFunction<'lua>,
    args: LuaMultiValue<'lua>,
) -> LuaResult<LuaMultiValue<'lua>> {
    let policy = LuaExecutionPolicy::with_timeout(state.borrow().lua_callback_timeout_ms);
    let Some(sandbox) = sandbox else {
        return call_function_with_policy(lua, hook_name, function, args, policy);
    };
    let hook = parse_hook_point(hook_name)?;
    if !sandbox.is_hook_allowed(&hook) {
        return Err(lua_error_from_mod(ModError::SandboxDenied {
            operation: format!("hook '{}'", hook_name),
            detail: format!("mod '{}' is not allowed to execute this hook", mod_id),
        }));
    }

    let (previous_mod_id, previous_sandbox) = state.borrow().active_mod_context();
    state
        .borrow_mut()
        .set_active_mod_sandbox(mod_id.to_string(), sandbox.clone());

    let previous_limit = match lua.set_memory_limit(sandbox.max_memory) {
        Ok(limit) => Some(limit),
        Err(LuaError::MemoryLimitNotAvailable) if sandbox.max_memory == 0 => None,
        Err(LuaError::MemoryLimitNotAvailable) => {
            restore_mod_context(state, previous_mod_id, previous_sandbox);
            return Err(LuaError::RuntimeError(format!(
                "mod '{}' requires sandbox.max_memory enforcement, but Lua memory limits are unavailable",
                mod_id
            )));
        }
        Err(error) => {
            restore_mod_context(state, previous_mod_id, previous_sandbox);
            return Err(error);
        }
    };

    let call_result = call_function_with_policy(lua, hook_name, function, args, policy);
    let restore_limit_result = match previous_limit {
        Some(limit) => lua.set_memory_limit(limit).map(|_| ()),
        None => Ok(()),
    };
    restore_mod_context(state, previous_mod_id, previous_sandbox);
    restore_limit_result?;
    call_result
}

/// Converts a Lua mod metadata table into a Rust `ModInfo` value.
fn mod_info_from_table(tbl: &LuaTable) -> LuaResult<ModInfo> {
    let limits = default_mod_limits();
    let id: String = tbl
        .get::<_, String>("id")
        .map_err(|_| LuaError::RuntimeError("newMod requires 'id' field".into()))?;
    validate_symbol("mod id", &id, limits.max_id_len)?;
    let dependencies = lua_string_sequence(tbl, "dependencies");
    for dependency in &dependencies {
        validate_symbol("dependency id", dependency, limits.max_id_len)?;
    }
    let capabilities = lua_string_sequence(tbl, "capabilities");
    for capability in &capabilities {
        validate_symbol("capability", capability, limits.max_capability_len)?;
    }
    let config_schema = lua_config_schema(tbl);
    for (key, type_hint, _) in &config_schema {
        validate_symbol("config_schema key", key, limits.max_id_len)?;
        FieldType::parse_config_type_name(type_hint).map_err(LuaError::RuntimeError)?;
    }
    let asset_paths = lua_string_sequence(tbl, "assets")
        .into_iter()
        .map(|path| normalize_relative_asset_path(&path))
        .collect::<LuaResult<Vec<_>>>()?;
    let mut info = ModInfo::from_parts(
        id,
        tbl.get::<_, String>("name").ok(),
        tbl.get::<_, String>("version").ok(),
        tbl.get::<_, String>("author").ok(),
        tbl.get::<_, String>("description").ok(),
        tbl.get::<_, i32>("priority").ok(),
        dependencies,
    );
    info.api_version = tbl.get::<_, String>("api_version").ok();
    if let Some(api_version) = &info.api_version {
        validate_version(api_version, limits.max_version_len)?;
    }
    info.capabilities = capabilities;
    info.config_schema = config_schema;
    info.asset_paths = asset_paths;
    info.signature = tbl.get::<_, String>("signature").ok();
    if let Ok(sandbox_tbl) = tbl.get::<_, LuaTable>("sandbox") {
        info.sandbox = Some(parse_lua_sandbox(&sandbox_tbl)?);
    }
    Ok(info)
}
/// Converts a Rust `ModInfo` value into a Lua table.
fn mod_info_to_table<'a>(lua: &'a Lua, info: &ModInfo) -> LuaResult<LuaTable<'a>> {
    let t = lua.create_table()?;
    /// The 'id' field value exposed to Lua scripts.
    t.set("id", info.id.as_str())?;
    /// Performs the 'name' operation.
    t.set("name", info.name.as_str())?;
    /// Performs the 'version' operation.
    t.set("version", info.version.as_str())?;
    /// Performs the 'author' operation.
    t.set("author", info.author.as_str())?;
    /// Performs the 'description' operation.
    t.set("description", info.description.as_str())?;
    /// Performs the 'priority' operation.
    t.set("priority", info.priority)?;
    /// Performs the 'enabled' operation.
    t.set("enabled", info.enabled)?;
    /// Performs the 'loaded' operation.
    t.set("loaded", info.loaded)?;
    if let Some(ref p) = info.path {
        /// Performs the 'path' operation.
        t.set("path", p.as_str() as &str)?;
    }
    if let Some(ref av) = info.api_version {
        /// Performs the 'api_version' operation.
        t.set("api_version", av.as_str())?;
    }
    let caps = {
        let c = lua.create_table()?;
        for (i, cap) in info.capabilities.iter().enumerate() {
            c.set(i + 1, cap.as_str())?;
        }
        c
    };
    /// Performs the 'capabilities' operation.
    t.set("capabilities", caps)?;
    let schema = {
        let s = lua.create_table()?;
        for (i, (key, type_hint, default)) in info.config_schema.iter().enumerate() {
            let entry = lua.create_table()?;
            /// The 'key' field value exposed to Lua scripts.
            entry.set("key", key.as_str())?;
            /// Performs the 'type' operation.
            entry.set("type", type_hint.as_str())?;
            /// Performs the 'default' operation.
            entry.set("default", default.as_str())?;
            s.set(i + 1, entry)?;
        }
        s
    };
    /// Performs the 'config_schema' operation.
    t.set("config_schema", schema)?;
    let assets = {
        let a = lua.create_table()?;
        for (i, asset) in info.asset_paths.iter().enumerate() {
            a.set(i + 1, asset.as_str())?;
        }
        a
    };
    /// Performs the 'assets' operation.
    t.set("assets", assets)?;
    if let Some(ref signature) = info.signature {
        /// Performs the 'signature' operation.
        t.set("signature", signature.as_str())?;
    }
    if let Some(sandbox) = &info.sandbox {
        t.set("sandbox", sandbox_to_lua_table(lua, sandbox)?)?;
    }
    let deps = lua.create_table()?;
    for (i, dep) in info.dependencies.iter().enumerate() {
        deps.set(i + 1, dep.as_str() as &str)?;
    }
    /// Performs the 'dependencies' operation.
    t.set("dependencies", deps)?;
    Ok(t)
}
/// Converts multiple Rust `ModInfo` values into an array-style Lua table.
fn mod_infos_to_table<'a, 'lua>(
    lua: &'lua Lua,
    infos: impl Iterator<Item = &'a ModInfo>,
) -> LuaResult<LuaTable<'lua>> {
    let t = lua.create_table()?;
    for (i, info) in infos.enumerate() {
        t.set(i + 1, mod_info_to_table(lua, info)?)?;
    }
    Ok(t)
}
/// Converts a Rust string slice into an array-style Lua table.
fn string_slice_to_table<'a>(lua: &'a Lua, items: &[String]) -> LuaResult<LuaTable<'a>> {
    let t = lua.create_table()?;
    for (i, s) in items.iter().enumerate() {
        t.set(i + 1, s.as_str())?;
    }
    Ok(t)
}
/// Lua-side wrapper for mod metadata, hooks, and config references.
pub struct LuaMod {
    /// Wrapped mod metadata exposed by the lurek engine.
    pub(super) inner: ModInfo,
    /// Hook callbacks stored in the Lua registry by hook name.
    hooks: HashMap<String, LuaRegistryKey>,
    /// Optional config value stored in the Lua registry.
    config: Option<LuaRegistryKey>,
}
impl LuaMod {
    /// Creates a Lua mod wrapper from mod metadata.
    pub fn new(inner: ModInfo) -> Self {
        Self {
            inner,
            hooks: HashMap::new(),
            config: None,
        }
    }
}
/// Provides Lua methods for mod metadata, hooks, and config values.
impl LuaUserData for LuaMod {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getId --
        /// Returns the mod id. This method is available to Lua scripts.
        /// @return | string | Mod id.
        methods.add_method("getId", |_, this, ()| Ok(this.inner.id.clone()));
        // -- getName --
        /// Returns the mod display name. This method is available to Lua scripts.
        /// @return | string | Mod name.
        methods.add_method("getName", |_, this, ()| Ok(this.inner.name.clone()));
        // -- getVersion --
        /// Returns the mod version. This method is available to Lua scripts.
        /// @return | string | Mod version.
        methods.add_method("getVersion", |_, this, ()| Ok(this.inner.version.clone()));
        // -- getAuthor --
        /// Returns the mod author. This method is available to Lua scripts.
        /// @return | string | Mod author.
        methods.add_method("getAuthor", |_, this, ()| Ok(this.inner.author.clone()));
        // -- getDescription --
        /// Returns the mod description. This method is available to Lua scripts.
        /// @return | string | Mod description.
        methods.add_method("getDescription", |_, this, ()| {
            Ok(this.inner.description.clone())
        });
        // -- getDependencies --
        /// Returns mod dependency ids. This method is available to Lua scripts.
        /// @return | integer[] | Array table of dependency ids.
        methods.add_method("getDependencies", |lua, this, ()| {
            string_slice_to_table(lua, &this.inner.dependencies)
        });
        // -- getPriority --
        /// Returns the mod priority. This method is available to Lua scripts.
        /// @return | integer | Mod priority.
        methods.add_method("getPriority", |_, this, ()| Ok(this.inner.priority));
        // -- isEnabled --
        /// Returns whether the mod is enabled.
        /// @return | boolean | True when enabled.
        methods.add_method("isEnabled", |_, this, ()| Ok(this.inner.enabled));
        // -- setEnabled --
        /// Sets whether the mod is enabled. This method is available to Lua scripts.
        /// @param | enabled | boolean | Enabled flag.
        methods.add_method_mut("setEnabled", |_, this, enabled: bool| {
            this.inner.enabled = enabled;
            Ok(())
        });
        // -- isLoaded --
        /// Returns whether the mod is loaded. This method is available to Lua scripts.
        /// @return | boolean | True when loaded.
        methods.add_method("isLoaded", |_, this, ()| Ok(this.inner.loaded));
        // -- getApiVersion --
        /// Returns the optional required API version.
        /// @return | string | API version string, or nil when unset.
        methods.add_method("getApiVersion", |_, this, ()| {
            Ok(this.inner.api_version.clone())
        });
        // -- setApiVersion --
        /// Sets the required API version string.
        /// @param | api_version | string | API version string.
        methods.add_method_mut("setApiVersion", |_, this, api_version: String| {
            validate_version(&api_version, default_mod_limits().max_version_len)?;
            this.inner.api_version = Some(api_version);
            Ok(())
        });
        // -- getCapabilities --
        /// Returns capability names declared by the mod.
        /// @return | string[] | Capability names.
        methods.add_method("getCapabilities", |lua, this, ()| {
            string_slice_to_table(lua, &this.inner.capabilities)
        });
        // -- setCapabilities --
        /// Sets capability names from an array table.
        /// @param | caps | table | Array table of capability names.
        methods.add_method_mut("setCapabilities", |_, this, caps: LuaTable| {
            let limits = default_mod_limits();
            let values: Vec<String> = caps.sequence_values::<String>().flatten().collect();
            for capability in &values {
                validate_symbol("capability", capability, limits.max_capability_len)?;
            }
            this.inner.capabilities = values;
            Ok(())
        });
        // -- getConfigSchema --
        /// Returns config schema entries. This method is available to Lua scripts.
        /// @return | table | Array of schema entries with `key`, `type`, and `default` fields.
        /// @field | key | string | Config key.
        /// @field | type | string | Type hint.
        /// @field | default | string | Default value.
        methods.add_method("getConfigSchema", |lua, this, ()| {
            let t = lua.create_table()?;
            for (i, (key, type_hint, default)) in this.inner.config_schema.iter().enumerate() {
                let entry = lua.create_table()?;
                /// The 'key' field value exposed to Lua scripts.
                entry.set("key", key.as_str())?;
                /// Performs the 'type' operation.
                entry.set("type", type_hint.as_str())?;
                /// Performs the 'default' operation.
                entry.set("default", default.as_str())?;
                t.set(i + 1, entry)?;
            }
            Ok(t)
        });
        // -- setConfigSchema --
        /// Sets config schema entries from a Lua table.
        /// @param | schema | table | Array table of schema entries.
        methods.add_method_mut("setConfigSchema", |_, this, schema: LuaTable| {
            let limits = default_mod_limits();
            this.inner.config_schema = schema
                .sequence_values::<LuaTable>()
                .flatten()
                .filter_map(|entry| {
                    let key: String = entry.get("key").ok()?;
                    let type_hint: String = entry.get("type").unwrap_or_else(|_| "any".into());
                    let default: String = entry.get("default").unwrap_or_default();
                    Some((key, type_hint, default))
                })
                .map(|(key, type_hint, default)| {
                    validate_symbol("config_schema key", &key, limits.max_id_len)?;
                    FieldType::parse_config_type_name(&type_hint)
                        .map_err(LuaError::RuntimeError)?;
                    Ok((key, type_hint, default))
                })
                .collect::<LuaResult<Vec<_>>>()?;
            Ok(())
        });
        // -- setHook --
        /// Stores a Lua hook function by name. This method is available to Lua scripts.
        /// @param | name | string | Hook name.
        /// @param | func | function | Hook callback function.
        methods.add_method_mut(
            "setHook",
            |lua, this, (name, func): (String, LuaFunction)| {
                parse_hook_point(&name)?;
                if let Some(old_key) = this.hooks.remove(&name) {
                    lua.remove_registry_value(old_key)?;
                }
                let key = lua.create_registry_value(func)?;
                this.hooks.insert(name, key);
                Ok(())
            },
        );
        // -- getHook --
        /// Returns a stored hook function by name.
        /// @param | name | string | Hook name.
        /// @return | function | Hook callback, or nil when missing.
        methods.add_method("getHook", |lua, this, name: String| {
            if let Some(key) = this.hooks.get(&name) {
                let func = lua.registry_value::<LuaFunction>(key)?;
                Ok(LuaValue::Function(func))
            } else {
                Ok(LuaValue::Nil)
            }
        });
        // -- hasHook --
        /// Returns whether a hook name is registered.
        /// @param | name | string | Hook name.
        /// @return | boolean | True when the hook exists.
        methods.add_method("hasHook", |_, this, name: String| {
            Ok(this.hooks.contains_key(&name))
        });
        // -- getHookNames --
        /// Returns registered hook names. This method is available to Lua scripts.
        /// @return | string[] | Hook names.
        methods.add_method("getHookNames", |lua, this, ()| {
            let t = lua.create_table()?;
            for (i, name) in this.hooks.keys().enumerate() {
                t.set(i + 1, name.as_str())?;
            }
            Ok(t)
        });
        // -- setSandbox --
        /// Sets the sandbox policy used by `runHook`.
        /// @param | sandbox | table | Sandbox configuration table.
        methods.add_method_mut("setSandbox", |_, this, sandbox: LuaTable| {
            this.inner.sandbox = Some(parse_lua_sandbox(&sandbox)?);
            Ok(())
        });
        // -- getSandbox --
        /// Returns the configured sandbox policy.
        /// @return | table | Sandbox configuration table, or nil when unset.
        methods.add_method("getSandbox", |lua, this, ()| {
            if let Some(sandbox) = &this.inner.sandbox {
                Ok(LuaValue::Table(sandbox_to_lua_table(lua, sandbox)?))
            } else {
                Ok(LuaValue::Nil)
            }
        });
        // -- runHook --
        /// Executes one registered hook under the mod's configured sandbox policy.
        /// @param | name | string | Hook name.
        /// @return | any | Hook return values.
        methods.add_method("runHook", |lua, this, args: LuaMultiValue| {
            let mut values = args.into_iter();
            let hook_name = match values.next() {
                Some(LuaValue::String(name)) => name.to_str()?.to_string(),
                Some(_) => {
                    return Err(LuaError::RuntimeError(
                        "runHook requires a string hook name".into(),
                    ))
                }
                None => {
                    return Err(LuaError::RuntimeError(
                        "runHook requires at least a hook name".into(),
                    ))
                }
            };
            let Some(key) = this.hooks.get(&hook_name) else {
                return Err(LuaError::RuntimeError(format!(
                    "hook '{}' is not registered for mod '{}'",
                    hook_name, this.inner.id
                )));
            };
            let function = lua.registry_value::<LuaFunction>(key)?;
            let remaining: LuaMultiValue = values.collect();
            let state = lua
                .app_data_ref::<Rc<RefCell<SharedState>>>()
                .ok_or_else(|| LuaError::RuntimeError("missing SharedState app data".into()))?
                .clone();
            call_hook_with_sandbox(
                lua,
                &state,
                &this.inner.id,
                this.inner.sandbox.clone(),
                &hook_name,
                function,
                remaining,
            )
        });
        // -- setConfig --
        /// Stores a Lua config value for this mod.
        /// @param | value | any | Config value to store (table, number, string, or boolean).
        methods.add_method_mut("setConfig", |lua, this, value: LuaValue| {
            if let Some(old_key) = this.config.take() {
                lua.remove_registry_value(old_key)?;
            }
            let key = lua.create_registry_value(value)?;
            this.config = Some(key);
            Ok(())
        });
        // -- getConfig --
        /// Returns the stored Lua config value.
        /// @return | table | Stored config value, or nil when unset.
        methods.add_method("getConfig", |lua, this, ()| {
            if let Some(key) = &this.config {
                lua.registry_value::<LuaValue>(key)
            } else {
                Ok(LuaValue::Nil)
            }
        });
        // -- releaseRefs --
        /// Releases stored Lua registry references for hooks and config.
        methods.add_method_mut("releaseRefs", |lua, this, ()| {
            for (_, key) in this.hooks.drain() {
                lua.remove_registry_value(key)?;
            }
            if let Some(key) = this.config.take() {
                lua.remove_registry_value(key)?;
            }
            Ok(())
        });
        methods.add_meta_method(LuaMetaMethod::ToString, |_, this, ()| {
            Ok(format!("Mod({})", this.inner.id))
        });
        // -- type --
        /// Returns the Lua-visible type name for this mod handle.
        /// @return | string | The string `LMod`.
        methods.add_method("type", |_, _, ()| Ok("LMod"));
        // -- typeOf --
        /// Returns whether this mod handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LMod` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LMod" || name == "LObject")
        });
    }
}
/// Lua-side wrapper for the mod manager.
pub struct LuaModManager {
    /// Wrapped mod manager state for this object.
    inner: ModManager,
}
impl LuaModManager {
    /// Creates an empty Lua mod manager wrapper.
    pub fn new() -> Self {
        Self {
            inner: ModManager::new(),
        }
    }
}
impl Default for LuaModManager {
    fn default() -> Self {
        Self::new()
    }
}
/// Provides Lua methods for mod registration, dependency checks, load order, folder scans, and reload queues.
impl LuaUserData for LuaModManager {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- registerMod --
        /// Registers a mod with the manager. This method is available to Lua scripts.
        /// @param | ud | LMod | Mod handle.
        methods.add_method_mut("registerMod", |_, this, ud: LuaAnyUserData| {
            let info = ud.borrow::<LuaMod>()?.inner.clone();
            this.inner.register_mod(info);
            Ok(())
        });
        // -- unregisterMod --
        /// Unregisters a mod by id. This method is available to Lua scripts.
        /// @param | mod_id | string | Mod id.
        /// @return | boolean | True when a mod was removed.
        methods.add_method_mut("unregisterMod", |_, this, mod_id: String| {
            Ok(this.inner.unregister_mod(&mod_id))
        });
        // -- hasMod --
        /// Returns whether a mod id is registered.
        /// @param | mod_id | string | Mod id.
        /// @return | boolean | True when the mod exists.
        methods.add_method("hasMod", |_, this, mod_id: String| {
            Ok(this.inner.has_mod(&mod_id))
        });
        // -- getModCount --
        /// Returns the number of registered mods.
        /// @return | integer | Mod count.
        methods.add_method("getModCount", |_, this, ()| Ok(this.inner.mod_count()));
        // -- getAllMods --
        /// Returns metadata for all registered mods.
        /// @return | table | Array table of mod metadata tables.
        /// @field | id | string | Mod id.
        /// @field | name | string | Mod display name.
        /// @field | version | string | Version string.
        /// @field | author | string | Author name.
        /// @field | description | string | Mod description.
        /// @field | priority | integer | Load priority.
        /// @field | enabled | boolean | Whether enabled.
        /// @field | loaded | boolean | Whether loaded.
        methods.add_method("getAllMods", |lua, this, ()| {
            mod_infos_to_table(lua, this.inner.all_mods().iter())
        });
        // -- getModsByCapability --
        /// Returns metadata for mods declaring a capability.
        /// @param | capability | string | Capability name.
        /// @return | table | Array table of mod metadata tables.
        /// @field | id | string | Mod id.
        /// @field | name | string | Mod display name.
        /// @field | version | string | Version string.
        /// @field | author | string | Author name.
        /// @field | description | string | Mod description.
        /// @field | priority | integer | Load priority.
        /// @field | enabled | boolean | Whether enabled.
        /// @field | loaded | boolean | Whether loaded.
        methods.add_method("getModsByCapability", |lua, this, capability: String| {
            mod_infos_to_table(
                lua,
                this.inner.get_mods_by_capability(&capability).into_iter(),
            )
        });
        // -- getLoadOrder --
        /// Returns the resolved load order. This method is available to Lua scripts.
        /// @return | table | Array table of mod metadata tables.
        /// @field | id | string | Mod id.
        /// @field | name | string | Mod display name.
        /// @field | version | string | Version string.
        /// @field | author | string | Author name.
        /// @field | description | string | Mod description.
        /// @field | priority | integer | Load priority.
        /// @field | enabled | boolean | Whether enabled.
        /// @field | loaded | boolean | Whether loaded.
        methods.add_method("getLoadOrder", |lua, this, ()| {
            let order = this.inner.load_order();
            mod_infos_to_table(lua, order.into_iter())
        });
        // -- validateDependencies --
        /// Returns dependency validation messages.
        /// @return | string[] | Validation message strings.
        methods.add_method("validateDependencies", |lua, this, ()| {
            string_slice_to_table(lua, &this.inner.validate_dependencies())
        });
        // -- hasCircularDependencies --
        /// Returns whether registered mods have circular dependencies.
        /// @return | boolean | True when a cycle exists.
        methods.add_method("hasCircularDependencies", |_, this, ()| {
            Ok(this.inner.has_circular_dependencies())
        });
        // -- setLoadOrder --
        /// Sets explicit load order from an array of mod ids.
        /// @param | order_table | table | Array table of mod ids.
        methods.add_method_mut("setLoadOrder", |_, this, order_table: LuaTable| {
            let order: Vec<String> = order_table.sequence_values::<String>().flatten().collect();
            this.inner.set_load_order(order);
            Ok(())
        });
        // -- clearLoadOrder --
        /// Clears explicit load order. This method is available to Lua scripts.
        methods.add_method_mut("clearLoadOrder", |_, this, ()| {
            this.inner.clear_load_order();
            Ok(())
        });
        // -- scanFolder --
        /// Scans a folder for mod metadata. This method is available to Lua scripts.
        /// @param | path | string | Folder path.
        /// @return | table | Array table of discovered mod metadata tables.
        /// @field | id | string | Mod id.
        /// @field | name | string | Mod display name.
        /// @field | version | string | Version string.
        /// @field | author | string | Author name.
        /// @field | description | string | Mod description.
        /// @field | priority | integer | Load priority.
        /// @field | enabled | boolean | Whether enabled.
        /// @field | loaded | boolean | Whether loaded.
        methods.add_method_mut("scanFolder", |lua, this, path: String| {
            let found = this.inner.scan_folder(&path);
            mod_infos_to_table(lua, found.iter())
        });
        // -- getModPath --
        /// Returns the filesystem path for a registered mod.
        /// @param | mod_id | string | Mod id.
        /// @return | string | Mod path, or nil when unknown.
        methods.add_method("getModPath", |_, this, mod_id: String| {
            Ok(this.inner.get_mod(&mod_id).and_then(|m| m.path.clone()))
        });
        // -- markForReload --
        /// Marks a mod id for reload. This method is available to Lua scripts.
        /// @param | mod_id | string | Mod id.
        /// @return | boolean | True when the mod was marked.
        methods.add_method_mut("markForReload", |_, this, mod_id: String| {
            Ok(this.inner.mark_for_reload(&mod_id))
        });
        // -- getReloadQueue --
        /// Returns mod ids waiting for reload.
        /// @return | integer[] | Array table of mod ids.
        methods.add_method("getReloadQueue", |lua, this, ()| {
            string_slice_to_table(lua, this.inner.get_reload_queue())
        });
        // -- clearReloadQueue --
        /// Clears the reload queue. This method is available to Lua scripts.
        methods.add_method_mut("clearReloadQueue", |_, this, ()| {
            this.inner.clear_reload_queue();
            Ok(())
        });
        // -- processReloadQueue --
        /// Processes and clears the reload queue.
        /// @return | integer[] | Array table of processed mod ids.
        methods.add_method_mut("processReloadQueue", |lua, this, ()| {
            string_slice_to_table(lua, &this.inner.process_reload_queue())
        });
        methods.add_meta_method(LuaMetaMethod::ToString, |_, this, ()| {
            Ok(format!("ModManager({} mods)", this.inner.mod_count()))
        });
        // -- type --
        /// Returns the Lua-visible type name for this mod manager handle.
        /// @return | string | The string `LModManager`.
        methods.add_method("type", |_, _, ()| Ok("LModManager"));
        // -- typeOf --
        /// Returns whether this mod manager handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LModManager` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LModManager" || name == "LObject")
        });
    }
}
/// Lua-side content registry for storing typed Lua values by id.
pub struct LuaContentRegistry {
    /// Registry entries keyed by type name and entry id.
    entries: HashMap<String, HashMap<String, LuaRegistryKey>>,
    /// Registered content type names.
    types: HashSet<String>,
}
impl LuaContentRegistry {
    #[allow(clippy::new_without_default)]
    /// Creates an empty content registry with no registered types or entries.
    pub fn new() -> Self {
        Self {
            entries: HashMap::new(),
            types: HashSet::new(),
        }
    }
}
/// Provides Lua methods for content type registration and value lookup.
impl LuaUserData for LuaContentRegistry {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- registerType --
        /// Registers a content type name. This method is available to Lua scripts.
        /// @param | type_name | string | Content type name.
        methods.add_method_mut("registerType", |_, this, type_name: String| {
            this.types.insert(type_name.clone());
            this.entries.entry(type_name).or_default();
            Ok(())
        });
        // -- register --
        /// Stores a Lua value under a registered content type and id.
        /// @param | type_name | string | Content type name.
        /// @param | id | string | Entry id.
        /// @param | obj | table | Lua value to store.
        methods.add_method_mut(
            "register",
            |lua, this, (type_name, id, obj): (String, String, LuaValue)| {
                if !this.types.contains(&type_name) {
                    return Err(LuaError::RuntimeError(format!(
                        "content type '{}' not registered",
                        type_name
                    )));
                }
                let key = lua.create_registry_value(obj)?;
                this.entries.entry(type_name).or_default().insert(id, key);
                Ok(())
            },
        );
        // -- get --
        /// Returns one stored value by content type and id.
        /// @param | type_name | string | Content type name.
        /// @param | id | string | Entry id.
        /// @return | table | Stored Lua value.
        /// @return | nil | If missing.
        methods.add_method("get", |lua, this, (type_name, id): (String, String)| {
            let val = this
                .entries
                .get(&type_name)
                .and_then(|m| m.get(&id))
                .map(|key| lua.registry_value::<LuaValue>(key))
                .transpose()?
                .unwrap_or(LuaValue::Nil);
            Ok(val)
        });
        // -- getAll --
        /// Returns all stored values for a content type keyed by id.
        /// @param | type_name | string | Content type name.
        /// @return | table | Table of stored values keyed by id.
        methods.add_method("getAll", |lua, this, type_name: String| {
            let tbl = lua.create_table()?;
            if let Some(map) = this.entries.get(&type_name) {
                for (id, key) in map {
                    let val: LuaValue = lua.registry_value(key)?;
                    tbl.set(id.as_str(), val)?;
                }
            }
            Ok(tbl)
        });
        // -- getTypes --
        /// Returns registered content type names.
        /// @return | string[] | Content type names.
        methods.add_method("getTypes", |lua, this, ()| {
            let tbl = lua.create_table()?;
            for (i, t) in this.types.iter().enumerate() {
                tbl.set(i + 1, t.as_str())?;
            }
            Ok(tbl)
        });
        methods.add_meta_method(LuaMetaMethod::ToString, |_, this, ()| {
            Ok(format!("ContentRegistry({} types)", this.types.len()))
        });
        // -- type --
        /// Returns the Lua-visible type name for this content registry handle.
        /// @return | string | The string `LContentRegistry`.
        methods.add_method("type", |_, _, ()| Ok("LContentRegistry"));
        // -- typeOf --
        /// Returns whether this content registry handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LContentRegistry` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LContentRegistry" || name == "LObject")
        });
    }
}
/// Registers the `lurek.mods` module.
pub fn register(lua: &Lua, lurek: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    // -- newMod --
    /// Creates a mod metadata handle from a Lua table.
    /// @param | info | table | Mod metadata table.
    /// @return | LMod | New mod handle.
    tbl.set(
        "newMod",
        lua.create_function(|lua, info: LuaTable| {
            let mod_info = mod_info_from_table(&info)?;
            lua.create_userdata(LuaMod::new(mod_info))
        })?,
    )?;
    // -- newModManager --
    /// Creates an empty mod manager. This function is exposed to Lua scripts.
    /// @return | LModManager | New mod manager handle.
    tbl.set(
        "newModManager",
        lua.create_function(|lua, ()| lua.create_userdata(LuaModManager::new()))?,
    )?;
    // -- newRegistry --
    /// Creates an empty content registry.
    /// @return | LContentRegistry | New content registry handle.
    tbl.set(
        "newRegistry",
        lua.create_function(|lua, ()| lua.create_userdata(LuaContentRegistry::new()))?,
    )?;
    // -- checkApiVersion --
    /// Checks whether a mod API version is compatible with a host version.
    /// @param | mod_ud | LMod | Mod handle.
    /// @param | host_version | string | Host API version string.
    /// @return | boolean | True when compatible.
    /// @return | string | Error message when incompatible, otherwise nil.
    tbl.set(
        "checkApiVersion",
        lua.create_function(|lua, (mod_ud, host_version): (LuaAnyUserData, String)| {
            let m = mod_ud.borrow::<LuaMod>()?;
            match m.inner.check_api_version(&host_version) {
                Ok(()) => Ok((true, LuaValue::Nil)),
                Err(e) => Ok((false, LuaValue::String(lua.create_string(e.as_bytes())?))),
            }
        })?,
    )?;
    /// Performs the 'mods' operation.
    lurek.set("mods", tbl)?;
    Ok(())
}
