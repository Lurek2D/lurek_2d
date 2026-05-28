//! `lurek.asset` — ref-counted media cache bindings.
//!
//! - Registers `lurek.asset.*` functions and types via `register()`.
//! - Bridges 8 Lua-callable functions and 2 `LAssetHandle` methods via `mlua`.
//! - See `docs/specs/asset.md` for the full API specification.

use crate::asset::{AssetCache, AssetType};
use crate::runtime::SharedState;
use mlua::prelude::*;
use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::Rc;

// ─── LuaAssetHandle ──────────────────────────────────────────────────────────

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

// ─── register ────────────────────────────────────────────────────────────────

/// Registers `lurek.asset.*` functions into the `lurek` table.
pub fn register(
    lua: &Lua,
    lurek: &LuaTable,
    _state: Rc<RefCell<SharedState>>,
) -> LuaResult<()> {
    let cache: Rc<RefCell<AssetCache>> = Rc::new(RefCell::new(AssetCache::new()));

    let asset_tbl = lua.create_table()?;

    // ─── load ─────────────────────────────────────────────────────────────────

    // -- load --
    /// Loads and caches an asset by path and type, returning a ref-counted handle.
    /// @param | path | string | Filesystem path to the asset file.
    /// @param | asset_type | string | One of `image`, `font`, `audio`, or `text`.
    /// @return | LAssetHandle | Handle that keeps the asset alive in the cache.
    {
        let cache = cache.clone();
        asset_tbl.set(
            "load",
            lua.create_function(move |_lua, (path, type_str): (String, String)| {
                let asset_type = AssetType::from_type_str(&type_str);
                let text_content = match &asset_type {
                    AssetType::Text => {
                        let content = std::fs::read_to_string(&path).map_err(|e| {
                            LuaError::RuntimeError(format!(
                                "lurek.asset.load: cannot read text file \"{}\": {}",
                                path, e
                            ))
                        })?;
                        Some(content)
                    }
                    _ => {
                        if !std::path::Path::new(&path).exists() {
                            return Err(LuaError::RuntimeError(format!(
                                "lurek.asset.load: file not found: \"{}\"",
                                path
                            )));
                        }
                        None
                    }
                };
                let id = cache.borrow_mut().register(path, asset_type, text_content);
                Ok(LuaAssetHandle {
                    id,
                    cache: cache.clone(),
                })
            })?,
        )?;
    }

    // ─── unload ───────────────────────────────────────────────────────────────

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

    // ─── get ──────────────────────────────────────────────────────────────────

    // -- get --
    /// Returns the underlying asset value for a cached handle.
    /// For `text` assets returns the file content as a string.
    /// For `image`, `font`, and `audio` assets calls the appropriate `lurek.*` constructor.
    /// @param | handle | LAssetHandle | Asset handle to retrieve.
    /// @return | any | Asset value, or nil when the handle is no longer loaded or the type is unknown.
    {
        let cache = cache.clone();
        asset_tbl.set(
            "get",
            lua.create_function(move |lua, handle: LuaAnyUserData| {
                // Extract all data while the borrow is live, then drop before Lua calls.
                let (path, asset_type, text_content) = {
                    let h = handle.borrow::<LuaAssetHandle>()?;
                    let borrow = cache.borrow();
                    let entry = borrow.get(h.id).ok_or_else(|| {
                        LuaError::RuntimeError(
                            "lurek.asset.get: handle is no longer loaded".into(),
                        )
                    })?;
                    (
                        entry.path.clone(),
                        entry.asset_type.clone(),
                        entry.text_content.clone(),
                    )
                };

                match asset_type {
                    AssetType::Text => match text_content {
                        Some(s) => Ok(LuaValue::String(lua.create_string(&s)?)),
                        None => Ok(LuaValue::Nil),
                    },
                    AssetType::Image => {
                        let image_tbl: LuaTable =
                            lua.globals().get::<_, LuaTable>("lurek")?.get("image")?;
                        let load_fn: LuaFunction = image_tbl.get("loadImage")?;
                        load_fn.call(path)
                    }
                    AssetType::Font => {
                        let font_tbl: LuaTable =
                            lua.globals().get::<_, LuaTable>("lurek")?.get("font")?;
                        let load_fn: LuaFunction = font_tbl.get("load")?;
                        load_fn.call((path, 16i64))
                    }
                    AssetType::Audio => {
                        let audio_tbl: LuaTable =
                            lua.globals().get::<_, LuaTable>("lurek")?.get("audio")?;
                        let new_source_fn: LuaFunction = audio_tbl.get("newSource")?;
                        new_source_fn.call(path)
                    }
                    AssetType::Unknown(_) => Ok(LuaValue::Nil),
                }
            })?,
        )?;
    }

    // ─── preload ──────────────────────────────────────────────────────────────

    // -- preload --
    /// Synchronously loads a batch of assets and fires `callback(loaded, total)` after each item.
    /// Fires `callback(nil, nil)` when all items have been processed.
    /// @param | paths | table | Array of `{path, type}` pairs (or `{path=…, type=…}` tables).
    /// @param | callback | any | Function invoked as `callback(loaded, total)` per item; `callback(nil, nil)` on finish.
    /// @return | nil | No value is returned.
    {
        let cache = cache.clone();
        asset_tbl.set(
            "preload",
            lua.create_function(move |_lua, (paths, callback): (LuaTable, LuaFunction)| {
                let count = paths.raw_len() as i64;
                for i in 1..=count {
                    let entry: LuaTable = paths.get(i)?;

                    let path: String = entry
                        .get::<_, Option<String>>(1)?
                        .or_else(|| entry.get::<_, Option<String>>("path").ok().flatten())
                        .ok_or_else(|| {
                            LuaError::RuntimeError(
                                "lurek.asset.preload: each entry must have a path".into(),
                            )
                        })?;

                    let type_str: String = entry
                        .get::<_, Option<String>>(2)?
                        .or_else(|| entry.get::<_, Option<String>>("type").ok().flatten())
                        .ok_or_else(|| {
                            LuaError::RuntimeError(
                                "lurek.asset.preload: each entry must have a type".into(),
                            )
                        })?;

                    let asset_type = AssetType::from_type_str(&type_str);
                    let text_content = if asset_type == AssetType::Text {
                        std::fs::read_to_string(&path)
                            .map(Some)
                            .map_err(|e| {
                                LuaError::RuntimeError(format!(
                                    "lurek.asset.preload: cannot read \"{}\": {}",
                                    path, e
                                ))
                            })?
                    } else {
                        None
                    };

                    cache.borrow_mut().register(path, asset_type, text_content);
                    callback.call::<_, ()>((i, count))?;
                }
                callback.call::<_, ()>((LuaValue::Nil, LuaValue::Nil))?;
                Ok(())
            })?,
        )?;
    }

    // ─── refcount ─────────────────────────────────────────────────────────────

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

    // ─── isLoaded ─────────────────────────────────────────────────────────────

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

    // ─── stats ────────────────────────────────────────────────────────────────

    // -- stats --
    /// Returns a snapshot table describing the current cache state.
    /// @return | table | Table with `loaded`, `total_refs`, and `types` fields.
    /// @field | loaded | integer | Number of distinct assets currently cached.
    /// @field | total_refs | integer | Sum of all ref counts across all cached assets.
    /// @field | types | table | Per-type entry counts keyed by type string.
    {
        let cache = cache.clone();
        asset_tbl.set(
            "stats",
            lua.create_function(move |lua, ()| {
                // Extract all needed data while holding the borrow, then drop before Lua calls.
                let (loaded, total_refs, type_counts) = {
                    let borrow = cache.borrow();
                    let mut counts = HashMap::<String, usize>::new();
                    for (_, entry) in borrow.iter() {
                        *counts
                            .entry(entry.asset_type.as_str().to_string())
                            .or_insert(0) += 1;
                    }
                    (borrow.loaded_count(), borrow.total_refs(), counts)
                };

                let tbl = lua.create_table()?;
                tbl.set("loaded", loaded)?;
                tbl.set("total_refs", total_refs)?;
                let types_tbl = lua.create_table()?;
                for (k, v) in &type_counts {
                    types_tbl.set(k.as_str(), *v)?;
                }
                tbl.set("types", types_tbl)?;
                Ok(tbl)
            })?,
        )?;
    }

    // ─── clear ────────────────────────────────────────────────────────────────

    // -- clear --
    /// Unloads all assets from the cache immediately, regardless of ref counts.
    /// @return | nil | No value is returned.
    {
        let cache = cache.clone();
        asset_tbl.set(
            "clear",
            lua.create_function(move |_lua, ()| {
                cache.borrow_mut().clear();
                Ok(())
            })?,
        )?;
    }

    lurek.set("asset", asset_tbl)?;
    Ok(())
}
