//! Scene object component – generic visible entity.
// Provides position, sprite reference, visibility flag.

use std::cell::RefCell;
use std::rc::Rc;

use crate::runtime::SharedState;
use mlua::prelude::*;

#[derive(Debug, Default, Clone)]
pub struct SceneObject {
    pub x: f32,
    pub y: f32,
    pub sprite: Option<String>,
    pub visible: bool,
}

impl SceneObject {
    pub fn new() -> Self {
        Self::default()
    }
    pub fn set_position(&mut self, x: f32, y: f32) {
        self.x = x;
        self.y = y;
    }
    pub fn set_sprite(&mut self, name: String) {
        self.sprite = Some(name);
    }
    pub fn set_visible(&mut self, v: bool) {
        self.visible = v;
    }
}

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
