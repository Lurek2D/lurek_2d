//! Native scene object container used by `lurek.scene.newObjectContainer`.

use mlua::prelude::*;
use std::collections::HashMap;

/// Native container for Lua scene object tables.
pub struct LSceneObjectContainer {
    objects: Vec<LuaRegistryKey>,
    group_bits: HashMap<String, u8>,
    group_names: Vec<String>,
    pass_enabled: HashMap<&'static str, [bool; 16]>,
}

impl LSceneObjectContainer {
    /// Create an empty native scene object container.
    pub fn new(_lua: &Lua) -> LuaResult<Self> {
        Ok(Self {
            objects: Vec::new(),
            group_bits: HashMap::new(),
            group_names: Vec::new(),
            pass_enabled: HashMap::from([
                ("update", [true; 16]),
                ("physics", [true; 16]),
                ("draw", [true; 16]),
            ]),
        })
    }

    pub fn add(&mut self, lua: &Lua, obj: LuaTable) -> LuaResult<()> {
        self.objects.push(lua.create_registry_value(obj)?);
        Ok(())
    }

    pub fn define_group(&mut self, name: String) -> LuaResult<u8> {
        if let Some(bit) = self.group_bits.get(&name) {
            return Ok(*bit);
        }
        let bit = self.group_names.len();
        if bit >= 16 {
            return Err(LuaError::RuntimeError(
                "scene object container supports at most 16 groups".to_string(),
            ));
        }
        self.group_names.push(name.clone());
        self.group_bits.insert(name, bit as u8);
        Ok(bit as u8)
    }

    pub fn get_group_bit(&self, name: &str) -> Option<u8> {
        self.group_bits.get(name).copied()
    }

    pub fn set_group_enabled(&mut self, group: LuaValue, pass: String, enabled: bool) -> bool {
        let Some(bit) = self.group_bit_from_lua(group) else {
            return false;
        };
        let Some(pass) = normalize_pass(&pass) else {
            return false;
        };
        self.pass_enabled.get_mut(pass).unwrap()[bit as usize] = enabled;
        true
    }

    pub fn is_group_enabled(&self, group: LuaValue, pass: String) -> bool {
        let Some(bit) = self.group_bit_from_lua(group) else {
            return false;
        };
        let Some(pass) = normalize_pass(&pass) else {
            return false;
        };
        self.pass_enabled
            .get(pass)
            .map(|bits| bits[bit as usize])
            .unwrap_or(false)
    }

    pub fn remove(&mut self, lua: &Lua, obj: LuaTable) -> LuaResult<()> {
        let mut remove_index = None;
        for (index, key) in self.objects.iter().enumerate() {
            let current: LuaTable = lua.registry_value(key)?;
            if current.equals(obj.clone())? {
                remove_index = Some(index);
                break;
            }
        }
        if let Some(index) = remove_index {
            let key = self.objects.remove(index);
            lua.remove_registry_value(key)?;
        }
        Ok(())
    }

    pub fn clear(&mut self, lua: &Lua) -> LuaResult<()> {
        for key in self.objects.drain(..) {
            lua.remove_registry_value(key)?;
        }
        Ok(())
    }

    pub fn update(&self, lua: &Lua, dt: f64) -> LuaResult<()> {
        for key in &self.objects {
            let obj: LuaTable = lua.registry_value(key)?;
            if self.enabled_for_pass(&obj, "update")? {
                if let Ok(update) = obj.get::<_, LuaFunction>("update") {
                    update.call::<_, ()>((obj.clone(), dt))?;
                }
            }
        }
        Ok(())
    }

    pub fn process_physics(&self, lua: &Lua, dt: f64) -> LuaResult<()> {
        for key in &self.objects {
            let obj: LuaTable = lua.registry_value(key)?;
            if self.enabled_for_pass(&obj, "physics")? {
                if let Ok(process_physics) = obj.get::<_, LuaFunction>("process_physics") {
                    process_physics.call::<_, ()>((obj.clone(), dt))?;
                } else if let Ok(physics) = obj.get::<_, LuaFunction>("physics") {
                    physics.call::<_, ()>((obj.clone(), dt))?;
                }
            }
        }
        Ok(())
    }

    pub fn draw(&self, lua: &Lua) -> LuaResult<()> {
        let mut objects = self.objects_with_layers(lua)?;
        objects.sort_by(|a, b| a.0.partial_cmp(&b.0).unwrap_or(std::cmp::Ordering::Equal));
        for (_, _, obj) in objects {
            if self.enabled_for_pass(&obj, "draw")? {
                if let Ok(draw) = obj.get::<_, LuaFunction>("draw") {
                    draw.call::<_, ()>(obj.clone())?;
                }
            }
        }
        Ok(())
    }

    pub fn count(&self) -> usize {
        self.objects.len()
    }

    pub fn objects_table<'lua>(&self, lua: &'lua Lua) -> LuaResult<LuaTable<'lua>> {
        let out = lua.create_table()?;
        for (index, key) in self.objects.iter().enumerate() {
            out.set(index + 1, lua.registry_value::<LuaTable>(key)?)?;
        }
        Ok(out)
    }

    pub fn by_layer<'lua>(&self, lua: &'lua Lua, layer: i32) -> LuaResult<LuaTable<'lua>> {
        let out = lua.create_table()?;
        for key in &self.objects {
            let obj: LuaTable = lua.registry_value(key)?;
            if object_layer(&obj)? as i32 == layer {
                out.set(out.len()? + 1, obj)?;
            }
        }
        Ok(out)
    }

    pub fn has(&self, lua: &Lua, obj: LuaTable) -> LuaResult<bool> {
        for key in &self.objects {
            let current: LuaTable = lua.registry_value(key)?;
            if current.equals(obj.clone())? {
                return Ok(true);
            }
        }
        Ok(false)
    }

    fn group_bit_from_lua(&self, group: LuaValue) -> Option<u8> {
        match group {
            LuaValue::Integer(value) if (0..16).contains(&value) => Some(value as u8),
            LuaValue::Number(value) if value.fract() == 0.0 && (0.0..16.0).contains(&value) => {
                Some(value as u8)
            }
            LuaValue::String(name) => self.group_bits.get(name.to_str().ok()?).copied(),
            _ => None,
        }
    }

    fn enabled_for_pass(&self, obj: &LuaTable, pass: &'static str) -> LuaResult<bool> {
        let mask = self.object_mask(obj)?;
        if mask == 0 {
            return Ok(true);
        }
        let Some(bits) = self.pass_enabled.get(pass) else {
            return Ok(true);
        };
        for (bit, enabled) in bits.iter().enumerate().take(16) {
            if mask & (1u32 << bit) != 0 && !enabled {
                return Ok(false);
            }
        }
        Ok(true)
    }

    fn object_mask(&self, obj: &LuaTable) -> LuaResult<u32> {
        let mut mask = obj
            .get::<_, Option<u32>>("groupMask")?
            .or_else(|| obj.get::<_, Option<u32>>("mask").ok().flatten())
            .unwrap_or(0);
        if let Some(group) = obj.get::<_, Option<String>>("group")? {
            if let Some(bit) = self.group_bits.get(&group) {
                mask |= 1u32 << *bit;
            }
        }
        if let Some(groups) = obj.get::<_, Option<LuaTable>>("groups")? {
            for value in groups.sequence_values::<String>() {
                if let Some(bit) = self.group_bits.get(&value?) {
                    mask |= 1u32 << *bit;
                }
            }
        }
        Ok(mask)
    }

    fn objects_with_layers<'lua>(
        &self,
        lua: &'lua Lua,
    ) -> LuaResult<Vec<(f64, usize, LuaTable<'lua>)>> {
        let mut out = Vec::with_capacity(self.objects.len());
        for (index, key) in self.objects.iter().enumerate() {
            let obj: LuaTable = lua.registry_value(key)?;
            out.push((object_layer(&obj)?, index, obj));
        }
        Ok(out)
    }
}

fn normalize_pass(pass: &str) -> Option<&'static str> {
    match pass {
        "update" | "process" => Some("update"),
        "physics" | "process_physics" => Some("physics"),
        "draw" => Some("draw"),
        _ => None,
    }
}

fn object_layer(obj: &LuaTable) -> LuaResult<f64> {
    Ok(obj.get::<_, Option<f64>>("layer")?.unwrap_or(0.0))
}
