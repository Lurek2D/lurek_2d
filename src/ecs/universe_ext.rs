//! This file extends `Universe` with higher-level queries, bulk blueprint spawning, and table snapshot exchange.
//! `query_not` and `query_multi` build on core component selection for exclusions and callback-based iteration.
//! `spawn_bulk` clones optional overrides per entity so repeated blueprint spawns do not share Lua tables.
//! Snapshot helpers serialize entities, components, tags, layers, bitmap tags, and hierarchy into Lua tables.
//! Deserialization rebuilds live state, stores, indexes, and parent-child links from one captured snapshot.
//! Open it when ECS import/export or batch-spawn semantics change; core storage lives in `universe.rs`.

use super::Universe;
use crate::ecs::lua_table::deep_copy_table;
use mlua::{Function, Lua, Result as LuaResult, Table, Value as LuaValue};
impl Universe {
    /// Returns entities that contain all required components and none of the excluded ones.
    pub fn query_not(
        &self,
        lua: &Lua,
        with_names: &[String],
        without_names: &[String],
    ) -> LuaResult<Vec<u32>> {
        self.query_component_sets(lua, with_names, without_names)
    }
    /// Invokes a Lua callback with entity ids followed by multiple requested component values.
    pub fn query_multi(&self, lua: &Lua, names: &[String], callback: Function) -> LuaResult<()> {
        if names.is_empty() {
            return Ok(());
        }
        if let Some(ref key) = self.component_store {
            let store: Table = lua.registry_value(key)?;
            let mut slots = self.candidate_slots_for_all(names);
            slots.sort();
            for slot in slots {
                if let Ok(entity_table) = store.get::<_, Table>(slot) {
                    let mut vals: Vec<LuaValue> = Vec::with_capacity(names.len());
                    let mut all = true;
                    for name in names {
                        let v: LuaValue = entity_table.get(name.as_str())?;
                        if v.is_nil() {
                            all = false;
                            break;
                        }
                        vals.push(v);
                    }
                    if all {
                        let id = Self::pack_id(slot, self.current_gen(slot));
                        let mut args = Vec::with_capacity(1 + vals.len());
                        args.push(LuaValue::Integer(id as i64));
                        args.extend(vals);
                        callback.call::<_, ()>(mlua::MultiValue::from_vec(args))?;
                    }
                }
            }
        }
        Ok(())
    }
    /// Spawns multiple entities from one blueprint, cloning the optional override table per spawn.
    pub fn spawn_bulk(
        &mut self,
        lua: &Lua,
        name: &str,
        count: usize,
        overrides: Option<Table>,
    ) -> LuaResult<Vec<u32>> {
        if count > 100_000 {
            return Err(mlua::Error::runtime(
                "lurek.ecs.spawnBulk: count exceeds 100000",
            ));
        }
        self.ensure_stores(lua)?;
        let bp_store = self.get_blueprint_store(lua)?;
        let blueprint: Table = bp_store
            .get(name)
            .map_err(|_| mlua::Error::runtime(format!("Blueprint '{name}' not defined")))?;
        let mut rows = Vec::new();
        rows.try_reserve_exact(count)
            .map_err(|_| mlua::Error::runtime("lurek.ecs.spawnBulk: staging allocation failed"))?;
        for _ in 0..count {
            let row = deep_copy_table(lua, &blueprint)?;
            if let Some(ref values) = overrides {
                let values = deep_copy_table(lua, values)?;
                for pair in values.pairs::<LuaValue, LuaValue>() {
                    let (key, value) = pair?;
                    row.set(key, value)?;
                }
            }
            rows.push(row);
        }

        let base_version = self.query_change_tick;
        let store = self.get_component_store(lua)?;
        let mut ids = Vec::new();
        ids.try_reserve_exact(count)
            .map_err(|_| mlua::Error::runtime("lurek.ecs.spawnBulk: id allocation failed"))?;
        for row in rows {
            let id = self.spawn().raw();
            store.set(Self::unpack_slot(id), row)?;
            ids.push(id);
        }
        if count > 0 {
            self.query_change_tick = base_version.wrapping_add(1);
        }
        Ok(ids)
    }
    /// Serializes live entities, components, tags, layers, and hierarchy into a Lua snapshot table.
    pub fn serialize_to_table<'lua>(&self, lua: &'lua Lua) -> LuaResult<Table<'lua>> {
        let snapshot = lua.create_table()?;
        let entities_arr = lua.create_table()?;
        let mut sorted_slots: Vec<u32> = self.alive.iter().copied().collect();
        sorted_slots.sort();
        for (i, slot) in sorted_slots.iter().enumerate() {
            let slot = *slot;
            let generation = self.current_gen(slot);
            let id = Self::pack_id(slot, generation);
            let entry = lua.create_table()?;
            entry.set("id", id)?;
            entry.set("slot", slot)?;
            entry.set("gen", generation)?;
            let components = lua.create_table()?;
            if let Some(ref key) = self.component_store {
                let store: Table = lua.registry_value(key)?;
                if let Ok(comp_row) = store.get::<_, Table>(slot) {
                    for pair in comp_row.clone().pairs::<String, LuaValue>() {
                        let (k, v) = pair?;
                        let v_copy = match v {
                            LuaValue::Table(ref t) => LuaValue::Table(deep_copy_table(lua, t)?),
                            other => other,
                        };
                        components.set(k, v_copy)?;
                    }
                }
            }
            entry.set("components", components)?;
            let tags = lua.create_table()?;
            if let Some(tag_list) = self.string_tags.get(&slot) {
                for (j, t) in tag_list.iter().enumerate() {
                    tags.set(j + 1, t.as_str())?;
                }
            }
            entry.set("tags", tags)?;
            entry.set("layer", self.layers.get(&slot).copied().unwrap_or(0))?;
            entry.set(
                "bitmap",
                self.bitmap_masks.get(&slot).copied().unwrap_or(0u64) as i64,
            )?;
            if let Some(&parent_slot) = self.parents.get(&slot) {
                if self.alive.contains(&parent_slot) {
                    entry.set(
                        "parent",
                        Self::pack_id(parent_slot, self.current_gen(parent_slot)),
                    )?;
                }
            }
            entities_arr.set(i + 1, entry)?;
        }
        snapshot.set("entities", entities_arr)?;
        let btnames = lua.create_table()?;
        for (j, name) in self.bitmap_tag_names.iter().enumerate() {
            btnames.set(j + 1, name.as_str())?;
        }
        snapshot.set("bitmap_tags", btnames)?;
        Ok(snapshot)
    }
    /// Rebuilds universe state from a previously serialized Lua snapshot table.
    pub fn deserialize_from_table(&mut self, lua: &Lua, snapshot: Table) -> LuaResult<()> {
        self.alive.clear();
        self.free_list.clear();
        self.next_id = 1;
        self.string_tags.clear();
        self.tag_index.clear();
        self.generations.clear();
        self.retired_slots.clear();
        self.bitmap_tag_names.clear();
        self.bitmap_tag_bits.clear();
        self.bitmap_masks.clear();
        self.layers.clear();
        self.parents.clear();
        self.children.clear();
        self.add_events.clear();
        self.remove_events.clear();
        self.dirty_set.clear();
        #[cfg(feature = "ecs-archetype")]
        self.component_index.clear();
        if let Some(ref key) = self.component_store {
            let store: Table = lua.registry_value(key)?;
            let ks: Vec<u32> = store
                .clone()
                .pairs::<u32, LuaValue>()
                .filter_map(|p| p.ok().map(|(k, _)| k))
                .collect();
            for k in ks {
                store.set(k, LuaValue::Nil)?;
            }
        }
        self.ensure_stores(lua)?;
        let comp_store = self.get_component_store(lua)?;
        if let Ok(btnames) = snapshot.get::<_, Table>("bitmap_tags") {
            for name in btnames.sequence_values::<String>() {
                let name = name?;
                if !self.bitmap_tag_bits.contains_key(name.as_str()) {
                    let bit = self.bitmap_tag_names.len() as u8;
                    self.bitmap_tag_bits.insert(name.clone(), bit);
                    self.bitmap_tag_names.push(name);
                }
            }
        }
        let entities: Table = snapshot.get("entities")?;
        let mut parent_data: Vec<(u32, u32)> = Vec::new();
        for entry_val in entities.sequence_values::<Table>() {
            let entry = entry_val?;
            let id: u32 = entry.get("id")?;
            let slot = Self::unpack_slot(id);
            let generation: u8 = entry.get("gen").unwrap_or(0);
            self.alive.insert(slot);
            *self.generations.entry(slot).or_insert(0) = generation;
            if slot >= self.next_id {
                self.next_id = slot + 1;
            }
            let comp_row = lua.create_table()?;
            if let Ok(components) = entry.get::<_, Table>("components") {
                for pair in components.pairs::<LuaValue, LuaValue>() {
                    let (k, v) = pair?;
                    comp_row.set(k, v)?;
                }
            }
            comp_store.set(slot, comp_row.clone())?;
            #[cfg(feature = "ecs-archetype")]
            self.reindex_component_row(slot, &comp_row)?;
            if let Ok(tags) = entry.get::<_, Table>("tags") {
                let mut tag_list = Vec::new();
                for t in tags.sequence_values::<String>() {
                    let t = t?;
                    self.tag_index.entry(t.clone()).or_default().push(id);
                    tag_list.push(t);
                }
                if !tag_list.is_empty() {
                    self.string_tags.insert(slot, tag_list);
                }
            }
            let layer: i32 = entry.get("layer").unwrap_or(0);
            if layer != 0 {
                self.layers.insert(slot, layer);
            }
            let bitmap: i64 = entry.get("bitmap").unwrap_or(0);
            if bitmap != 0 {
                self.bitmap_masks.insert(slot, bitmap as u64);
            }
            if let Ok(parent_id) = entry.get::<_, u32>("parent") {
                parent_data.push((slot, parent_id));
            }
        }
        for (child_slot, parent_id) in parent_data {
            let parent_slot = Self::unpack_slot(parent_id);
            if self.alive.contains(&parent_slot) {
                self.parents.insert(child_slot, parent_slot);
                self.children
                    .entry(parent_slot)
                    .or_default()
                    .push(child_slot);
            }
        }
        self.bump_query_change_tick();
        Ok(())
    }
}
