//! Registers the `luna.spine` namespace.
//!
//! Provides Lua-level skeletal animation: bone hierarchies, slot bindings,
//! and world-transform propagation via [`Skeleton`].
//!
//! This module is part of Luna2D's `lua_api` subsystem.
//! Key types exported: `LuaSkeleton`.
//! Primary functions: `register()`.

use std::cell::RefCell;
use std::rc::Rc;

use mlua::prelude::*;

use crate::lua_api::lua_types::{add_type_methods, LunaType};
use crate::spine::{Bone, Skeleton, Slot};

// ── UserData wrapper ──────────────────────────────────────────────────────────

/// Lua UserData wrapper for a [`Skeleton`].
///
/// # Fields
/// - `inner` — `Rc<RefCell<Skeleton>>`. Shared skeleton state.
#[derive(Clone)]
pub struct LuaSkeleton {
    /// Shared skeleton state.
    pub(crate) inner: Rc<RefCell<Skeleton>>,
}

impl LunaType for LuaSkeleton {
    const TYPE_NAME: &'static str = "Skeleton";
    const TYPE_HIERARCHY: &'static [&'static str] = &["Skeleton", "Object"];
}

impl LuaUserData for LuaSkeleton {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        add_type_methods::<Self>(methods);

        // ── Bone management ───────────────────────────────────────────────

        /// Adds a root bone (no parent) and returns its index.
        ///
        /// `opts` fields (all optional):
        /// - `x`         — `number`  Local X offset (default 0).
        /// - `y`         — `number`  Local Y offset (default 0).
        /// - `rotation`  — `number`  Local rotation in radians (default 0).
        /// - `scale_x`   — `number`  Local X scale (default 1).
        /// - `scale_y`   — `number`  Local Y scale (default 1).
        ///
        /// @param name string
        /// @param opts table  (optional)
        /// @return number   Bone index (0-based internally, returned as Lua number).
        methods.add_method("addBone", |_, this, (name, opts): (String, Option<LuaTable>)| {
            let mut bone = Bone::new(&name);
            if let Some(tbl) = opts {
                if let Ok(v) = tbl.get::<_, f32>("x") { bone.local_x = v; }
                if let Ok(v) = tbl.get::<_, f32>("y") { bone.local_y = v; }
                if let Ok(v) = tbl.get::<_, f32>("rotation") { bone.local_rotation = v; }
                if let Ok(v) = tbl.get::<_, f32>("scale_x") { bone.local_scale_x = v; }
                if let Ok(v) = tbl.get::<_, f32>("scale_y") { bone.local_scale_y = v; }
            }
            let idx = this.inner.borrow_mut().add_bone(bone);
            Ok(idx)
        });

        /// Adds a child bone attached to `parent_idx` and returns its index.
        ///
        /// `opts` fields are the same as `addBone`.
        ///
        /// @param name       string
        /// @param parent_idx number  0-based parent bone index.
        /// @param opts       table   (optional)
        /// @return number
        methods.add_method(
            "addChildBone",
            |_, this, (name, parent_idx, opts): (String, usize, Option<LuaTable>)| {
                let mut bone = Bone::with_parent(&name, parent_idx, 0.0, 0.0);
                if let Some(tbl) = opts {
                    if let Ok(v) = tbl.get::<_, f32>("x") { bone.local_x = v; }
                    if let Ok(v) = tbl.get::<_, f32>("y") { bone.local_y = v; }
                    if let Ok(v) = tbl.get::<_, f32>("rotation") { bone.local_rotation = v; }
                    if let Ok(v) = tbl.get::<_, f32>("scale_x") { bone.local_scale_x = v; }
                    if let Ok(v) = tbl.get::<_, f32>("scale_y") { bone.local_scale_y = v; }
                }
                let idx = this.inner.borrow_mut().add_bone(bone);
                Ok(idx)
            },
        );

        // ── Slot management ───────────────────────────────────────────────

        /// Adds a slot bound to `bone_idx` and returns its index.
        /// @param name       string
        /// @param bone_idx   number  0-based bone index.
        /// @param attachment string  (optional) Initial attachment name.
        /// @return number
        methods.add_method(
            "addSlot",
            |_, this, (name, bone_idx, attachment): (String, usize, Option<String>)| {
                let mut slot = Slot::new(&name, bone_idx);
                slot.attachment_name = attachment;
                let idx = this.inner.borrow_mut().add_slot(slot);
                Ok(idx)
            },
        );

        // ── Queries ───────────────────────────────────────────────────────

        /// Returns the index of the named bone, or `nil` if not found.
        /// @param name string
        /// @return number|nil
        methods.add_method("findBone", |_, this, name: String| {
            Ok(this.inner.borrow().find_bone(&name))
        });

        /// Returns the index of the named slot, or `nil` if not found.
        /// @param name string
        /// @return number|nil
        methods.add_method("findSlot", |_, this, name: String| {
            Ok(this.inner.borrow().find_slot(&name))
        });

        // ── World transforms ──────────────────────────────────────────────

        /// Propagates all local transforms down the bone hierarchy to compute
        /// world-space positions and rotations.
        methods.add_method("updateWorldTransforms", |_, this, ()| {
            this.inner.borrow_mut().update_world_transforms();
            Ok(())
        });

        /// Returns world-space transform of bone at `idx` as a table.
        ///
        /// Table fields: `x`, `y`, `rotation`, `scale_x`, `scale_y`.
        ///
        /// @param idx number  0-based bone index.
        /// @return table|nil
        methods.add_method("getBoneWorld", |lua, this, idx: usize| {
            let skel = this.inner.borrow();
            if idx >= skel.bones.len() {
                return Ok(LuaValue::Nil);
            }
            let bone = &skel.bones[idx];
            let t = lua.create_table()?;
            t.set("x", bone.world_x)?;
            t.set("y", bone.world_y)?;
            t.set("rotation", bone.world_rotation)?;
            t.set("scale_x", bone.world_scale_x)?;
            t.set("scale_y", bone.world_scale_y)?;
            Ok(LuaValue::Table(t))
        });

        /// Sets the local position of the root offset (bone 0 world position seed).
        ///
        /// This adjusts `local_x` / `local_y` of the bone at index 0 and calls
        /// `update_world_transforms()` so the whole hierarchy shifts.
        ///
        /// @param x number
        /// @param y number
        methods.add_method("setPosition", |_, this, (x, y): (f32, f32)| {
            let mut skel = this.inner.borrow_mut();
            if let Some(root) = skel.bones.first_mut() {
                root.local_x = x;
                root.local_y = y;
            }
            skel.update_world_transforms();
            Ok(())
        });

        /// Returns the total number of bones.
        /// @return number
        methods.add_method("boneCount", |_, this, ()| {
            Ok(this.inner.borrow().bones.len())
        });

        /// Returns the total number of slots.
        /// @return number
        methods.add_method("slotCount", |_, this, ()| {
            Ok(this.inner.borrow().slots.len())
        });
    }
}

// ── Registration ──────────────────────────────────────────────────────────────

/// Registers the `luna.spine` namespace into the given `luna` table.
///
/// # Parameters
/// - `lua` — `&Lua`.
/// - `luna` — `&LuaTable`.
///
/// # Returns
/// `LuaResult<()>`.
pub fn register(lua: &Lua, luna: &LuaTable) -> LuaResult<()> {
    let spine_tbl = lua.create_table()?;

    /// Creates a new, empty [`Skeleton`] with the given name.
    /// @param name string
    /// @return Skeleton
    spine_tbl.set(
        "newSkeleton",
        lua.create_function(|_, name: String| {
            Ok(LuaSkeleton {
                inner: Rc::new(RefCell::new(Skeleton::new(&name))),
            })
        })?,
    )?;

    luna.set("spine", spine_tbl)?;
    Ok(())
}
