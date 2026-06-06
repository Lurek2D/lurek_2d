//! File: src/lua_api/asset_api.rs

use crate::asset::{AssetCache, AssetType};
use crate::runtime::SharedState;
use mlua::prelude::*;
use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::Rc;

// â”€â”€â”€ LuaAssetHandle â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

/// Lua-side handle for a single cached asset entry.
///
/// Wraps the numeric handle ID and a shared reference to the cache so that
/// methods can query or mutate ref counts without an external state reference.
#[derive(Clone)]
pub struct LuaAssetHandle {
    id: u64,
    cache: Rc<RefCell<AssetCache>>,
}

impl LuaUserData for LuaAssetHandle {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- type --
        /// Returns the Lua-visible type name for this asset handle.
        /// @return | string | The string `LAssetHandle`.
        methods.add_method("type", |_, _, ()| Ok("LAssetHandle"));

        // -- typeOf --
        /// Returns whether this handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LAssetHandle` and `LObject`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LAssetHandle" || name == "LObject")
        });
    }
}

fn load_text_content(
    path: &str,
    asset_type: &AssetType,
    context: &str,
) -> LuaResult<Option<String>> {
    if asset_type.is_text_like() {
        let content = std::fs::read_to_string(path).map_err(|e| {
            LuaError::RuntimeError(format!(
                "{}: cannot read \"{}\" (type: {}): {}",
                context,
                path,
                asset_type.as_str(),
                e
            ))
        })?;
        Ok(Some(content))
    } else {
        if !std::path::Path::new(path).exists() {
            return Err(LuaError::RuntimeError(format!(
                "{}: file not found: \"{}\"",
                context, path
            )));
        }
        Ok(None)
    }
}

fn apply_load_opts(
    cache: &Rc<RefCell<AssetCache>>,
    id: u64,
    opts: Option<LuaTable>,
) -> LuaResult<()> {
    if let Some(opts) = opts {
        if let Ok(name) = opts.get::<_, String>("name") {
            cache.borrow_mut().set_name(id, name);
        }
        if let Ok(group) = opts.get::<_, String>("group") {
            cache.borrow_mut().set_group(id, group);
        }
        if let Ok(tags_tbl) = opts.get::<_, LuaTable>("tags") {
            let len = tags_tbl.raw_len();
            for i in 1..=len {
                if let Ok(tag) = tags_tbl.get::<_, String>(i) {
                    cache.borrow_mut().add_tag(id, &tag);
                }
            }
        }
    }
    Ok(())
}

fn ids_to_handles_table<'lua>(
    lua: &'lua Lua,
    ids: &[u64],
    cache: &Rc<RefCell<AssetCache>>,
) -> LuaResult<LuaTable<'lua>> {
    let out = lua.create_table()?;
    for (i, id) in ids.iter().enumerate() {
        out.set(
            i + 1,
            LuaAssetHandle {
                id: *id,
                cache: cache.clone(),
            },
        )?;
    }
    Ok(out)
}

fn get_handle_entry(
    cache: &Rc<RefCell<AssetCache>>,
    id: u64,
    context: &str,
) -> LuaResult<crate::asset::AssetEntry> {
    let borrow = cache.borrow();
    let entry = borrow
        .get(id)
        .ok_or_else(|| LuaError::RuntimeError(format!("{}: handle not loaded", context)))?;
    Ok(crate::asset::AssetEntry {
        path: entry.path.clone(),
        asset_type: entry.asset_type.clone(),
        ref_count: entry.ref_count,
        text_content: entry.text_content.clone(),
        name: entry.name.clone(),
        group: entry.group.clone(),
        tags: entry.tags.clone(),
    })
}

fn resolve_asset_value(lua: &Lua, entry: crate::asset::AssetEntry) -> LuaResult<LuaValue<'_>> {
    match entry.asset_type {
        AssetType::Text
        | AssetType::Toml
        | AssetType::Json
        | AssetType::Obj
        | AssetType::Shader
        | AssetType::Lua => match entry.text_content {
            Some(s) => Ok(LuaValue::String(lua.create_string(&s)?)),
            None => Ok(LuaValue::Nil),
        },
        AssetType::Image => {
            let image_tbl: LuaTable = lua.globals().get::<_, LuaTable>("lurek")?.get("image")?;
            let load_fn: LuaFunction = image_tbl.get("loadImage")?;
            load_fn.call(entry.path)
        }
        AssetType::Font => {
            let font_tbl: LuaTable = lua.globals().get::<_, LuaTable>("lurek")?.get("font")?;
            let load_fn: LuaFunction = font_tbl.get("load")?;
            load_fn.call((entry.path, 16i64))
        }
        AssetType::Audio | AssetType::Music => {
            let audio_tbl: LuaTable = lua.globals().get::<_, LuaTable>("lurek")?.get("audio")?;
            let new_source_fn: LuaFunction = audio_tbl.get("newSource")?;
            new_source_fn.call(entry.path)
        }
        AssetType::Unknown(_) => Ok(LuaValue::Nil),
    }
}

fn preload_assets(
    cache: &Rc<RefCell<AssetCache>>,
    paths: LuaTable,
    callback: LuaFunction,
) -> LuaResult<()> {
    let count = paths.raw_len() as i64;
    for i in 1..=count {
        let row: LuaTable = paths.get(i)?;

        let path: String = row
            .get::<_, Option<String>>(1)?
            .or_else(|| row.get::<_, Option<String>>("path").ok().flatten())
            .ok_or_else(|| {
                LuaError::RuntimeError("lurek.asset.preload: each entry must have a path".into())
            })?;

        let type_str: String = row
            .get::<_, Option<String>>(2)?
            .or_else(|| row.get::<_, Option<String>>("type").ok().flatten())
            .ok_or_else(|| {
                LuaError::RuntimeError("lurek.asset.preload: each entry must have a type".into())
            })?;

        let asset_type = AssetType::from_type_str(&type_str);
        let text_content = load_text_content(&path, &asset_type, "lurek.asset.preload")?;
        cache.borrow_mut().register(path, asset_type, text_content);
        callback.call::<_, ()>((i, count))?;
    }

    callback.call::<_, ()>((LuaValue::Nil, LuaValue::Nil))?;
    Ok(())
}

// â”€â”€â”€ register â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

/// Registers `lurek.asset.*` functions into the `lurek` table.
pub fn register(lua: &Lua, lurek: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let cache: Rc<RefCell<AssetCache>> = Rc::new(RefCell::new(AssetCache::new()));

    let asset_tbl = lua.create_table()?;

    // â”€â”€â”€ load â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // -- load --
    /// Loads and caches an asset by path and type, returning a ref-counted handle.
    /// Supported types: `image`, `font`, `audio`, `music`, `text`, `toml`, `json`,
    /// `obj`, `shader`, `lua`. Text-like types read and cache the file content;
    /// binary types (`image`, `font`, `audio`, `music`) store the path reference only
    /// and are resolved lazily when `lurek.asset.get` is called.
    /// @param | path | string | Filesystem path to the asset file.
    /// @param | asset_type | string | Asset type string; see above for valid values.
    /// @param | opts | table? | Optional metadata: `{name, group, tags}`.
    /// @return | LAssetHandle | Handle that keeps the asset alive in the cache.
    let load_cache = cache.clone();
    asset_tbl.set(
        "load",
        lua.create_function(
            move |_lua, (path, type_str, opts): (String, String, Option<LuaTable>)| {
                let asset_type = AssetType::from_type_str(&type_str);
                let text_content = load_text_content(&path, &asset_type, "lurek.asset.load")?;
                let id = load_cache
                    .borrow_mut()
                    .register(path, asset_type, text_content);
                apply_load_opts(&load_cache, id, opts)?;
                Ok(LuaAssetHandle {
                    id,
                    cache: load_cache.clone(),
                })
            },
        )?,
    )?;

    // â”€â”€â”€ unload â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // -- unload --
    /// Decrements the ref count for a cached asset; removes the entry when it reaches zero.
    /// @param | handle | LAssetHandle | Asset handle to release.
    /// @return | nil | No value is returned.
    asset_tbl.set(
        "unload",
        lua.create_function(|_lua, handle: LuaAnyUserData| {
            let h = handle.borrow::<LuaAssetHandle>()?;
            h.cache.borrow_mut().dec_ref(h.id);
            Ok(())
        })?,
    )?;

    // â”€â”€â”€ get â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // -- get --
    /// Returns the underlying asset value for a cached handle.
    /// Text-like types (`text`, `toml`, `json`, `obj`, `shader`, `lua`) return the
    /// cached file content as a string. `image` calls `lurek.image.loadImage`,
    /// `font` calls `lurek.font.load`, `audio` and `music` call `lurek.audio.newSource`.
    /// @param | handle | LAssetHandle | Asset handle to retrieve.
    /// @return | string | Source text for text-like asset types.
    /// @overload | handle | LAssetHandle | table | Runtime object returned by image/font/audio loaders for binary types.
    let get_cache = cache.clone();
    asset_tbl.set(
        "get",
        lua.create_function(move |lua, handle: LuaAnyUserData| {
            let h = handle.borrow::<LuaAssetHandle>()?;
            let entry = get_handle_entry(&get_cache, h.id, "lurek.asset.get")?;
            resolve_asset_value(lua, entry)
        })?,
    )?;

    // â”€â”€â”€ preload â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // -- preload --
    /// Synchronously loads a batch of assets and fires `callback(loaded, total)` after each item.
    /// Fires `callback(nil, nil)` when all items have been processed.
    /// @param | paths | table | Array of `{path, type}` pairs (or `{path=â€¦, type=â€¦}` tables).
    /// @param | callback | any | Function invoked as `callback(loaded, total)` per item; `callback(nil, nil)` on finish.
    /// @return | nil | No value is returned.
    let preload_cache = cache.clone();
    asset_tbl.set(
        "preload",
        lua.create_function(move |_lua, (paths, callback): (LuaTable, LuaFunction)| {
            preload_assets(&preload_cache, paths, callback)
        })?,
    )?;

    // â”€â”€â”€ refcount â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // -- refcount --
    /// Returns the current ref count for a handle, or 0 when it is no longer loaded.
    /// @param | handle | LAssetHandle | Asset handle to inspect.
    /// @return | integer | Current reference count.
    asset_tbl.set(
        "refcount",
        lua.create_function(|_lua, handle: LuaAnyUserData| {
            let h = handle.borrow::<LuaAssetHandle>()?;
            let count = h.cache.borrow().ref_count(h.id);
            Ok(count)
        })?,
    )?;

    // â”€â”€â”€ isLoaded â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // -- isLoaded --
    /// Returns true when the asset for the given handle is still in the cache.
    /// @param | handle | LAssetHandle | Asset handle to check.
    /// @return | boolean | True when the asset is still cached.
    asset_tbl.set(
        "isLoaded",
        lua.create_function(|_lua, handle: LuaAnyUserData| {
            let h = handle.borrow::<LuaAssetHandle>()?;
            let loaded = h.cache.borrow().is_loaded(h.id);
            Ok(loaded)
        })?,
    )?;

    // â”€â”€â”€ stats â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // -- stats --
    /// Returns a snapshot table describing the current cache state.
    /// @return | table | Table with `loaded`, `total_refs`, `types`, and `groups` fields.
    /// @field | loaded | integer | Number of distinct assets currently cached.
    /// @field | total_refs | integer | Sum of all ref counts across all cached assets.
    /// @field | types | table | Per-type entry counts keyed by type string.
    /// @field | groups | table | Sorted array of unique group labels in the cache.
    let stats_cache = cache.clone();
    asset_tbl.set(
        "stats",
        lua.create_function(move |lua, ()| {
            let (loaded, total_refs, type_counts, groups) = {
                let borrow = stats_cache.borrow();
                let mut counts = HashMap::<String, usize>::new();
                for (_, entry) in borrow.iter() {
                    *counts
                        .entry(entry.asset_type.as_str().to_string())
                        .or_insert(0) += 1;
                }
                (
                    borrow.loaded_count(),
                    borrow.total_refs(),
                    counts,
                    borrow.unique_groups(),
                )
            };

            let out = lua.create_table()?;
            out.set("loaded", loaded)?;
            out.set("total_refs", total_refs)?;
            let per_type = lua.create_table()?;
            for (k, v) in &type_counts {
                per_type.set(k.as_str(), *v)?;
            }
            out.set("types", per_type)?;
            let groups_array = lua.create_table()?;
            for (i, g) in groups.iter().enumerate() {
                groups_array.set(i + 1, g.as_str())?;
            }
            out.set("groups", groups_array)?;
            Ok(out)
        })?,
    )?;

    // â”€â”€â”€ clear â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // -- clear --
    /// Removes all entries from the cache immediately, regardless of ref counts.
    /// @return | nil | No value is returned.
    let clear_cache = cache.clone();
    asset_tbl.set(
        "clear",
        lua.create_function(move |_lua, ()| {
            clear_cache.borrow_mut().clear();
            Ok(())
        })?,
    )?;

    // â”€â”€â”€ getPath â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // -- getPath --
    /// Returns the filesystem path for the asset associated with a handle.
    /// @param | handle | LAssetHandle | Asset handle to inspect.
    /// @return | string | Path that was passed to `lurek.asset.load`.
    asset_tbl.set(
        "getPath",
        lua.create_function(|_lua, handle: LuaAnyUserData| {
            let h = handle.borrow::<LuaAssetHandle>()?;
            let path = h
                .cache
                .borrow()
                .get(h.id)
                .ok_or_else(|| {
                    LuaError::RuntimeError("lurek.asset.getPath: handle not loaded".into())
                })?
                .path
                .clone();
            Ok(path)
        })?,
    )?;

    // â”€â”€â”€ getType â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // -- getType --
    /// Returns the type string for the asset associated with a handle.
    /// @param | handle | LAssetHandle | Asset handle to inspect.
    /// @return | string | Type string, for example `"image"`, `"audio"`, `"toml"`.
    asset_tbl.set(
        "getType",
        lua.create_function(|_lua, handle: LuaAnyUserData| {
            let h = handle.borrow::<LuaAssetHandle>()?;
            let type_str = h
                .cache
                .borrow()
                .get(h.id)
                .ok_or_else(|| {
                    LuaError::RuntimeError("lurek.asset.getType: handle not loaded".into())
                })?
                .asset_type
                .as_str()
                .to_string();
            Ok(type_str)
        })?,
    )?;

    // â”€â”€â”€ getInfo â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // -- getInfo --
    /// Returns a table containing all metadata for an asset handle.
    /// @param | handle | LAssetHandle | Asset handle to inspect.
    /// @return | table | Metadata table; see fields below.
    /// @field | path | string | Filesystem path to the asset.
    /// @field | type | string | Asset type string.
    /// @field | name | string | Display name, or the path file-stem when none is set.
    /// @field | group | string | Group label, or empty string when none is set.
    /// @field | tags | table | Array of tag strings.
    /// @field | refcount | integer | Current reference count.
    let info_cache = cache.clone();
    asset_tbl.set(
        "getInfo",
        lua.create_function(move |lua, handle: LuaAnyUserData| {
            let h = handle.borrow::<LuaAssetHandle>()?;
            let entry = get_handle_entry(&info_cache, h.id, "lurek.asset.getInfo")?;
            let name = entry.name.unwrap_or_else(|| {
                std::path::Path::new(&entry.path)
                    .file_stem()
                    .and_then(|s| s.to_str())
                    .unwrap_or("")
                    .to_string()
            });
            let group = entry.group.unwrap_or_default();
            let mut tags: Vec<String> = entry.tags.into_iter().collect();
            tags.sort();

            let info = lua.create_table()?;
            info.set("path", entry.path)?;
            info.set("type", entry.asset_type.as_str())?;
            info.set("name", name)?;
            info.set("group", group)?;
            let tag_array = lua.create_table()?;
            for (i, tag) in tags.iter().enumerate() {
                tag_array.set(i + 1, tag.as_str())?;
            }
            info.set("tags", tag_array)?;
            info.set("refcount", entry.ref_count)?;
            Ok(info)
        })?,
    )?;

    // â”€â”€â”€ setName â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // -- setName --
    /// Sets the display name for an asset handle.
    /// @param | handle | LAssetHandle | Asset handle to update.
    /// @param | name | string | Display name to assign.
    /// @return | nil | No value is returned.
    asset_tbl.set(
        "setName",
        lua.create_function(|_lua, (handle, name): (LuaAnyUserData, String)| {
            let h = handle.borrow::<LuaAssetHandle>()?;
            h.cache.borrow_mut().set_name(h.id, name);
            Ok(())
        })?,
    )?;

    // â”€â”€â”€ getName â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // -- getName --
    /// Returns the display name of an asset handle.
    /// Returns the path file-stem when no explicit name has been set.
    /// @param | handle | LAssetHandle | Asset handle to query.
    /// @return | string | Display name or path file-stem.
    asset_tbl.set(
        "getName",
        lua.create_function(|_lua, handle: LuaAnyUserData| {
            let h = handle.borrow::<LuaAssetHandle>()?;
            let borrow = h.cache.borrow();
            let entry = borrow.get(h.id).ok_or_else(|| {
                LuaError::RuntimeError("lurek.asset.getName: handle not loaded".into())
            })?;
            let name = entry.name.clone().unwrap_or_else(|| {
                std::path::Path::new(&entry.path)
                    .file_stem()
                    .and_then(|s| s.to_str())
                    .unwrap_or("")
                    .to_string()
            });
            Ok(name)
        })?,
    )?;

    // â”€â”€â”€ setGroup â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // -- setGroup --
    /// Assigns an asset handle to a named group.
    /// @param | handle | LAssetHandle | Asset handle to update.
    /// @param | group | string | Group label to assign.
    /// @return | nil | No value is returned.
    asset_tbl.set(
        "setGroup",
        lua.create_function(|_lua, (handle, group): (LuaAnyUserData, String)| {
            let h = handle.borrow::<LuaAssetHandle>()?;
            h.cache.borrow_mut().set_group(h.id, group);
            Ok(())
        })?,
    )?;

    // â”€â”€â”€ getGroup â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // -- getGroup --
    /// Returns the group label for an asset handle.
    /// Returns an empty string when no group has been assigned.
    /// @param | handle | LAssetHandle | Asset handle to query.
    /// @return | string | Group label or empty string.
    asset_tbl.set(
        "getGroup",
        lua.create_function(|_lua, handle: LuaAnyUserData| {
            let h = handle.borrow::<LuaAssetHandle>()?;
            let borrow = h.cache.borrow();
            let group = borrow
                .get(h.id)
                .ok_or_else(|| {
                    LuaError::RuntimeError("lurek.asset.getGroup: handle not loaded".into())
                })?
                .group
                .clone()
                .unwrap_or_default();
            Ok(group)
        })?,
    )?;

    // â”€â”€â”€ addTag â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // -- addTag --
    /// Adds a tag to the tag set of an asset handle.
    /// @param | handle | LAssetHandle | Asset handle to update.
    /// @param | tag | string | Tag string to add.
    /// @return | nil | No value is returned.
    asset_tbl.set(
        "addTag",
        lua.create_function(|_lua, (handle, tag): (LuaAnyUserData, String)| {
            let h = handle.borrow::<LuaAssetHandle>()?;
            h.cache.borrow_mut().add_tag(h.id, &tag);
            Ok(())
        })?,
    )?;

    // â”€â”€â”€ removeTag â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // -- removeTag --
    /// Removes a tag from the tag set of an asset handle.
    /// @param | handle | LAssetHandle | Asset handle to update.
    /// @param | tag | string | Tag string to remove.
    /// @return | boolean | True when the tag was present and removed.
    asset_tbl.set(
        "removeTag",
        lua.create_function(|_lua, (handle, tag): (LuaAnyUserData, String)| {
            let h = handle.borrow::<LuaAssetHandle>()?;
            let removed = h.cache.borrow_mut().remove_tag(h.id, &tag);
            Ok(removed)
        })?,
    )?;

    // â”€â”€â”€ getTags â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // -- getTags --
    /// Returns an array of all tags for an asset handle.
    /// @param | handle | LAssetHandle | Asset handle to query.
    /// @return | table | Array of tag strings.
    asset_tbl.set(
        "getTags",
        lua.create_function(|lua, handle: LuaAnyUserData| {
            let tags: Vec<String> = {
                let h = handle.borrow::<LuaAssetHandle>()?;
                let borrow = h.cache.borrow();
                let entry = borrow.get(h.id).ok_or_else(|| {
                    LuaError::RuntimeError("lurek.asset.getTags: handle not loaded".into())
                })?;
                entry.tags.iter().cloned().collect()
            };
            let tbl = lua.create_table()?;
            for (i, tag) in tags.iter().enumerate() {
                tbl.set(i + 1, tag.as_str())?;
            }
            Ok(tbl)
        })?,
    )?;

    // â”€â”€â”€ hasTag â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // -- hasTag --
    /// Returns true when an asset handle has the given tag in its tag set.
    /// @param | handle | LAssetHandle | Asset handle to check.
    /// @param | tag | string | Tag string to test.
    /// @return | boolean | True when the tag is present.
    asset_tbl.set(
        "hasTag",
        lua.create_function(|_lua, (handle, tag): (LuaAnyUserData, String)| {
            let h = handle.borrow::<LuaAssetHandle>()?;
            let has = h.cache.borrow().has_tag(h.id, &tag);
            Ok(has)
        })?,
    )?;

    // â”€â”€â”€ findByName â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // -- findByName --
    /// Returns an array of asset handles whose display name contains the substring.
    /// The comparison is case-insensitive. Assets with no explicit name use their path file-stem.
    /// @param | substr | string | Substring to search for in display names.
    /// @return | table | Array of `LAssetHandle` values whose name contains `substr`.
    let by_name_cache = cache.clone();
    asset_tbl.set(
        "findByName",
        lua.create_function(move |lua, substr: String| {
            let ids = by_name_cache.borrow().find_by_name(&substr);
            ids_to_handles_table(lua, &ids, &by_name_cache)
        })?,
    )?;

    // â”€â”€â”€ findByGroup â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // -- findByGroup --
    /// Returns an array of asset handles whose group label exactly matches `group`.
    /// @param | group | string | Group label to match.
    /// @return | table | Array of `LAssetHandle` values in the given group.
    let by_group_cache = cache.clone();
    asset_tbl.set(
        "findByGroup",
        lua.create_function(move |lua, group: String| {
            let ids = by_group_cache.borrow().find_by_group(&group);
            ids_to_handles_table(lua, &ids, &by_group_cache)
        })?,
    )?;

    // â”€â”€â”€ findByTag â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // -- findByTag --
    /// Returns an array of asset handles that have the given tag in their tag set.
    /// @param | tag | string | Tag string to match.
    /// @return | table | Array of `LAssetHandle` values tagged with `tag`.
    let by_tag_cache = cache.clone();
    asset_tbl.set(
        "findByTag",
        lua.create_function(move |lua, tag: String| {
            let ids = by_tag_cache.borrow().find_by_tag(&tag);
            ids_to_handles_table(lua, &ids, &by_tag_cache)
        })?,
    )?;

    // â”€â”€â”€ findByType â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    // -- findByType --
    /// Returns an array of asset handles whose type exactly matches `type_str`.
    /// @param | type_str | string | Type string such as `"image"`, `"audio"`, `"toml"`.
    /// @return | table | Array of `LAssetHandle` values of that type.
    let by_type_cache = cache.clone();
    asset_tbl.set(
        "findByType",
        lua.create_function(move |lua, type_str: String| {
            let ids = by_type_cache.borrow().find_by_type(&type_str);
            ids_to_handles_table(lua, &ids, &by_type_cache)
        })?,
    )?;

    lurek.set("asset", asset_tbl)?;
    Ok(())
}
