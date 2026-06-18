//! `src/scene/object.rs` owns the lightweight scene object entity exposed to Lua for simple positioned sprite state.
//! It defines `SceneObject` plus Lua registration helpers, keeping position, sprite, and visibility mutation together.
//! This file is the small object-state boundary for simple scene scripts, separate from stack control and rendering flow.
//! Read it when scene-object fields, Lua API shape, or basic object mutation behavior needs to change.

use std::cell::RefCell;
use std::rc::Rc;

use crate::runtime::SharedState;
use mlua::prelude::*;

#[derive(Debug, Default, Clone)]
/// Lightweight scene object with position, optional sprite name, and visibility state for Lua-controlled scenes.
pub struct SceneObject {
    /// World or screen x coordinate depending on the owning scene convention.
    pub x: f32,
    /// World or screen y coordinate depending on the owning scene convention.
    pub y: f32,
    /// Optional sprite resource name used when drawing this object.
    pub sprite: Option<String>,
    /// Whether this object should be considered visible by scene rendering code.
    pub visible: bool,
}

impl SceneObject {
    /// Creates a default invisible scene object at the origin.
    pub fn new() -> Self {
        Self::default()
    }

    /// Updates the object's 2D position.
    pub fn set_position(&mut self, x: f32, y: f32) {
        self.x = x;
        self.y = y;
    }

    /// Assigns the sprite resource name used by this object.
    pub fn set_sprite(&mut self, name: String) {
        self.sprite = Some(name);
    }

    /// Sets whether this object is visible.
    pub fn set_visible(&mut self, v: bool) {
        self.visible = v;
    }
}

/// Register the lightweight `lurek.scene_object` Lua table and its mutation helpers.
pub fn register(lua: &Lua, lurek: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let api = lua.create_table()?;
    api.set("new", lua.create_function(|_, ()| Ok(SceneObject::new()))?)?;
    api.set(
        "set_position",
        lua.create_function(|_, (obj, x, y): (LuaAnyUserData, f32, f32)| {
            let mut o: std::cell::RefMut<SceneObject> = obj.borrow_mut();
            o.set_position(x, y);
            Ok(())
        })?,
    )?;
    api.set(
        "set_sprite",
        lua.create_function(|_, (obj, name): (LuaAnyUserData, String)| {
            let mut o: std::cell::RefMut<SceneObject> = obj.borrow_mut();
            o.set_sprite(name);
            Ok(())
        })?,
    )?;
    api.set(
        "set_visible",
        lua.create_function(|_, (obj, v): (LuaAnyUserData, bool)| {
            let mut o: std::cell::RefMut<SceneObject> = obj.borrow_mut();
            o.set_visible(v);
            Ok(())
        })?,
    )?;
    lurek.set("scene_object", api)?;
    Ok(())
}
