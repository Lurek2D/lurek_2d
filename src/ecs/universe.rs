//! This file owns `Universe`, the central ECS world that manages entity lifetime, component rows, and queries.
//! It stores live slots, recycled ids, generation counters, and retired slots that prevent stale-handle reuse.
//! Component data lives in Lua registry tables, while dirty sets and add or remove events track row mutations.
//! Tagging support includes string-tag indexes, bitmap-tag bit assignment, layer values, and sorted retrieval.
//! Hierarchy support stores parent and child slot maps, validates cycles, and enables recursive deletions.
//! Blueprint support deep-copies template tables, supports extension with overrides, and spawns named entities.
//! System support tracks Lua system tables with priorities, phases, names, and dependency lists for scheduling.
//! Relationship support delegates directed links and pairwise affinity data while still enforcing entity liveness.
//! Query helpers cover exact component sets, cached invalidation ticks, per-component callbacks, and tag scans.
//! Snapshot helpers expose component events, dirty entities, deleted ids, and structured diff drains to callers.
//! Open it when ECS storage or lifecycle semantics change; extensions and caches depend on this owner file.

use super::relationships::RelationshipManager;
use crate::ecs::generational_id::GenerationalId;
use crate::ecs::lua_table::deep_copy_table;
use crate::ecs::types::EntityId;
use crate::log_msg;
use crate::runtime::log_messages::{EN01_UNIVERSE_INIT, EN02_ENTITY_SPAWN};
use mlua::{Function, Lua, RegistryKey, Result as LuaResult, Table, Value as LuaValue};
use std::collections::{HashMap, HashSet};
#[path = "universe_ext.rs"]
mod ext;
#[path = "universe_systems.rs"]
mod systems;
const MAX_BITMAP_TAGS: usize = 63;
type EcsChangeOperation<'lua> = (u32, String, String, LuaValue<'lua>);
#[derive(Debug, Default, Clone)]
/// Captures component and entity changes accumulated since the previous diff read.
///
/// # Fields
/// - `added_components`: Component additions as `(entity_id, component_name)` pairs.
/// - `removed_components`: Component removals as `(entity_id, component_name)` pairs.
/// - `deleted_entities`: Entity ids deleted since the previous diff drain.
/// - `dirty_entities`: Entity ids whose component rows changed since the previous diff drain.
pub struct SnapshotDiff {
    /// Component additions recorded as `(entity_id, component_name)` pairs.
    pub added_components: Vec<(u32, String)>,
    /// Component removals recorded as `(entity_id, component_name)` pairs.
    pub removed_components: Vec<(u32, String)>,
    /// Packed entity ids deleted since the previous diff read.
    pub deleted_entities: Vec<u32>,
    /// Packed entity ids whose component sets changed since the previous diff read.
    pub dirty_entities: Vec<u32>,
}
/// Owns all ECS entity state, component rows, tags, systems, and relationship data.
///
/// # Fields
/// - `relationships`: Pairwise and directed inter-entity relationship storage.
pub struct Universe {
    /// Next fresh slot id used when no recycled slots are available.
    next_id: u32,
    /// Recycled slot ids available for reuse.
    free_list: Vec<u32>,
    /// Live entity slots currently allocated in the universe.
    alive: HashSet<u32>,
    /// Generation counters keyed by entity slot.
    generations: HashMap<u32, u8>,
    /// Slots permanently retired after generation saturation to avoid stale-id aliasing.
    retired_slots: HashSet<u32>,
    /// Per-entity string tags keyed by slot.
    string_tags: HashMap<u32, Vec<String>>,
    /// Reverse index from tag name to packed entity ids.
    tag_index: HashMap<String, Vec<u32>>,
    /// Registered bitmap tag names ordered by bit position.
    bitmap_tag_names: Vec<String>,
    /// Bitmap tag bits keyed by tag name for O(1) lookup.
    bitmap_tag_bits: HashMap<String, u8>,
    /// Per-entity bitmap tag masks keyed by slot.
    bitmap_masks: HashMap<u32, u64>,
    /// Per-entity layer values keyed by slot.
    layers: HashMap<u32, i32>,
    /// Parent slot for each child slot in the entity hierarchy.
    parents: HashMap<u32, u32>,
    /// Child slots grouped by parent slot.
    children: HashMap<u32, Vec<u32>>,
    /// Lua registry table containing per-entity component rows.
    component_store: Option<RegistryKey>,
    #[cfg(feature = "ecs-archetype")]
    /// Component-name index used to accelerate archetype-style queries.
    component_index: HashMap<String, HashSet<u32>>,
    /// Lua registry table containing blueprint component templates.
    blueprint_store: Option<RegistryKey>,
    /// Lua registry table containing registered system tables.
    system_store: Option<RegistryKey>,
    /// Sort priority per registered system.
    system_priorities: Vec<i32>,
    /// Execution phase name per registered system.
    system_phases: Vec<String>,
    /// Stable name per registered system.
    system_names: Vec<String>,
    /// Dependency name list per registered system.
    system_deps: Vec<Vec<String>>,
    /// Buffered component-add notifications.
    add_events: Vec<(u32, String)>,
    /// Buffered component-remove notifications.
    remove_events: Vec<(u32, String)>,
    /// Entities whose component rows changed since the last event drain.
    dirty_set: HashSet<u32>,
    /// Buffered entity deletions since the last diff drain.
    deleted_entities: Vec<u32>,
    /// Coarse invalidation tick for cached query views and other selection caches.
    query_change_tick: u64,
    /// Relationship graph and directed link state associated with this universe.
    pub relationships: RelationshipManager,
}
impl Universe {
    /// Creates an empty universe with fresh stores and counters.
    pub fn new() -> Self {
        log_msg!(debug, EN01_UNIVERSE_INIT);
        Self {
            next_id: 1,
            free_list: Vec::new(),
            alive: HashSet::new(),
            generations: HashMap::new(),
            retired_slots: HashSet::new(),
            string_tags: HashMap::new(),
            tag_index: HashMap::new(),
            bitmap_tag_names: Vec::new(),
            bitmap_tag_bits: HashMap::new(),
            bitmap_masks: HashMap::new(),
            layers: HashMap::new(),
            parents: HashMap::new(),
            children: HashMap::new(),
            component_store: None,
            #[cfg(feature = "ecs-archetype")]
            component_index: HashMap::new(),
            blueprint_store: None,
            system_store: None,
            system_priorities: Vec::new(),
            system_phases: Vec::new(),
            system_names: Vec::new(),
            system_deps: Vec::new(),
            add_events: Vec::new(),
            remove_events: Vec::new(),
            dirty_set: HashSet::new(),
            deleted_entities: Vec::new(),
            query_change_tick: 0,
            relationships: RelationshipManager::new(),
        }
    }
    /// Lazily allocates the Lua registry tables backing components, blueprints, and systems.
    fn ensure_stores(&mut self, lua: &Lua) -> LuaResult<()> {
        if self.component_store.is_none() {
            self.component_store = Some(lua.create_registry_value(lua.create_table()?)?);
        }
        if self.blueprint_store.is_none() {
            self.blueprint_store = Some(lua.create_registry_value(lua.create_table()?)?);
        }
        if self.system_store.is_none() {
            self.system_store = Some(lua.create_registry_value(lua.create_table()?)?);
        }
        Ok(())
    }
    /// Fetches the Lua component store table, failing if the universe is not initialized.
    fn get_component_store<'lua>(&self, lua: &'lua Lua) -> LuaResult<Table<'lua>> {
        let key = self
            .component_store
            .as_ref()
            .ok_or_else(|| mlua::Error::runtime("Universe not initialized"))?;
        lua.registry_value::<Table>(key)
    }
    /// Fetches the Lua blueprint store table, failing if the universe is not initialized.
    fn get_blueprint_store<'lua>(&self, lua: &'lua Lua) -> LuaResult<Table<'lua>> {
        let key = self
            .blueprint_store
            .as_ref()
            .ok_or_else(|| mlua::Error::runtime("Universe not initialized"))?;
        lua.registry_value::<Table>(key)
    }
    /// Fetches the Lua system store table, failing if the universe is not initialized.
    pub fn get_system_store<'lua>(&self, lua: &'lua Lua) -> LuaResult<Table<'lua>> {
        let key = self
            .system_store
            .as_ref()
            .ok_or_else(|| mlua::Error::runtime("Universe not initialized"))?;
        lua.registry_value::<Table>(key)
    }
    #[inline]
    /// Packs a slot and generation into the public entity id format.
    pub fn pack_id(slot: u32, gen: u8) -> u32 {
        GenerationalId::pack(slot, gen)
    }
    #[inline]
    /// Extracts the slot portion from a packed entity id.
    pub fn unpack_slot(id: u32) -> u32 {
        GenerationalId::unpack_slot(id)
    }
    #[inline]
    /// Extracts the generation portion from a packed entity id.
    pub fn unpack_gen(id: u32) -> u8 {
        GenerationalId::unpack_gen(id)
    }
    #[inline]
    /// Returns the current generation counter for a slot.
    fn current_gen(&self, slot: u32) -> u8 {
        *self.generations.get(&slot).unwrap_or(&0)
    }

    #[inline]
    /// Advances the coarse query invalidation tick after a selection-affecting mutation.
    fn bump_query_change_tick(&mut self) {
        self.query_change_tick = self.query_change_tick.wrapping_add(1);
    }

    /// Returns the coarse invalidation tick used by cached ECS query views.
    pub fn get_query_change_tick(&self) -> u64 {
        self.query_change_tick
    }

    /// Returns the monotonic universe mutation version.
    pub fn version(&self) -> u64 {
        self.query_change_tick
    }

    #[inline]
    /// Returns a runtime error when `id` is not a currently live entity.
    fn ensure_alive(&self, id: u32, context: &str) -> LuaResult<()> {
        if self.is_alive(id) {
            Ok(())
        } else {
            Err(mlua::Error::runtime(format!(
                "{context}: entity {} is not alive",
                id
            )))
        }
    }

    /// Returns the packed ancestry chain for `entity`, stopping at the root.
    fn ancestry_chain(&self, entity: u32) -> Vec<u32> {
        let mut chain = Vec::new();
        let mut cursor = self.get_parent(entity);
        while let Some(parent_id) = cursor {
            chain.push(parent_id);
            cursor = self.get_parent(parent_id);
        }
        chain
    }
    #[cfg(feature = "ecs-archetype")]
    /// Rebuilds archetype query indices from one entity component row.
    fn reindex_component_row(&mut self, slot: u32, row: &Table) -> LuaResult<()> {
        for pair in row.clone().pairs::<String, LuaValue>() {
            let (name, value) = pair?;
            if !value.is_nil() {
                self.component_index.entry(name).or_default().insert(slot);
            }
        }
        Ok(())
    }
    /// Produces candidate slots that may contain all requested component names.
    fn candidate_slots_for_all(&self, names: &[String]) -> Vec<u32> {
        if names.is_empty() {
            return self.alive.iter().copied().collect();
        }
        #[cfg(feature = "ecs-archetype")]
        {
            let mut base: Option<HashSet<u32>> = None;
            for name in names {
                let Some(slots) = self.component_index.get(name) else {
                    return Vec::new();
                };
                if let Some(ref mut set) = base {
                    set.retain(|slot| slots.contains(slot));
                    if set.is_empty() {
                        return Vec::new();
                    }
                } else {
                    base = Some(slots.clone());
                }
            }
            return base
                .unwrap_or_default()
                .into_iter()
                .filter(|slot| self.alive.contains(slot))
                .collect();
        }
        #[cfg(not(feature = "ecs-archetype"))]
        {
            self.alive.iter().copied().collect()
        }
    }
    /// Allocates a live entity id, reusing a recycled slot when available.
    pub fn spawn(&mut self) -> EntityId {
        log_msg!(debug, EN02_ENTITY_SPAWN);
        let slot = loop {
            if let Some(recycled) = self.free_list.pop() {
                if !self.retired_slots.contains(&recycled) {
                    break recycled;
                }
            } else {
                let s = self.next_id;
                self.next_id += 1;
                break s;
            }
        };
        self.alive.insert(slot);
        self.bump_query_change_tick();
        EntityId(Self::pack_id(slot, self.current_gen(slot)))
    }
    /// Deletes one entity, clears its stored state, and recycles its slot.
    pub fn kill(&mut self, id: EntityId, lua: &Lua) -> LuaResult<()> {
        let slot = Self::unpack_slot(id.raw());
        let gen = Self::unpack_gen(id.raw());
        if !self.alive.contains(&slot) || self.current_gen(slot) != gen {
            return Ok(());
        }
        self.alive.remove(&slot);
        self.relationships.remove_entity(id.raw());
        if let Some(ref key) = self.component_store {
            let store: Table = lua.registry_value(key)?;
            store.set(slot, LuaValue::Nil)?;
        }
        #[cfg(feature = "ecs-archetype")]
        {
            for slots in self.component_index.values_mut() {
                slots.remove(&slot);
            }
        }
        if let Some(tags) = self.string_tags.remove(&slot) {
            for tag in &tags {
                if let Some(entries) = self.tag_index.get_mut(tag) {
                    if let Some(pos) = entries.iter().position(|&tid| tid == id.raw()) {
                        entries.swap_remove(pos);
                    }
                }
            }
        }
        self.bitmap_masks.remove(&slot);
        self.layers.remove(&slot);
        if let Some(parent_slot) = self.parents.remove(&slot) {
            if let Some(siblings) = self.children.get_mut(&parent_slot) {
                siblings.retain(|&c| c != slot);
            }
        }
        if let Some(child_slots) = self.children.remove(&slot) {
            for cs in child_slots {
                self.parents.remove(&cs);
            }
        }
        match self.generations.entry(slot) {
            std::collections::hash_map::Entry::Occupied(mut entry) => {
                if *entry.get() == u8::MAX {
                    self.retired_slots.insert(slot);
                } else {
                    *entry.get_mut() += 1;
                    self.free_list.push(slot);
                }
            }
            std::collections::hash_map::Entry::Vacant(entry) => {
                entry.insert(1);
                self.free_list.push(slot);
            }
        }
        self.deleted_entities.push(id.raw());
        self.bump_query_change_tick();
        Ok(())
    }
    /// Reassigns the parent of an entity within the hierarchy graph.
    pub fn set_parent(&mut self, entity: u32, parent: Option<u32>) -> LuaResult<()> {
        self.ensure_alive(entity, "lurek.ecs.setParent")?;
        if let Some(parent_id) = parent {
            self.ensure_alive(parent_id, "lurek.ecs.setParent")?;
            if parent_id == entity {
                return Err(mlua::Error::runtime(
                    "lurek.ecs.setParent: entity cannot be its own parent",
                ));
            }
            if self.ancestry_chain(parent_id).contains(&entity) {
                return Err(mlua::Error::runtime(
                    "lurek.ecs.setParent: cyclic hierarchy is not allowed",
                ));
            }
        }
        let entity_slot = Self::unpack_slot(entity);
        if let Some(old_parent_slot) = self.parents.remove(&entity_slot) {
            let mut remove_bucket = false;
            if let Some(siblings) = self.children.get_mut(&old_parent_slot) {
                siblings.retain(|&c| c != entity_slot);
                remove_bucket = siblings.is_empty();
            }
            if remove_bucket {
                self.children.remove(&old_parent_slot);
            }
        }
        if let Some(new_parent) = parent {
            let parent_slot = Self::unpack_slot(new_parent);
            self.parents.insert(entity_slot, parent_slot);
            let siblings = self.children.entry(parent_slot).or_default();
            if !siblings.contains(&entity_slot) {
                siblings.push(entity_slot);
            }
        }
        self.bump_query_change_tick();
        Ok(())
    }
    /// Returns the packed parent id for an entity when one is assigned.
    pub fn get_parent(&self, entity: u32) -> Option<u32> {
        let entity_slot = Self::unpack_slot(entity);
        self.parents
            .get(&entity_slot)
            .copied()
            .map(|parent_slot| Self::pack_id(parent_slot, self.current_gen(parent_slot)))
    }
    /// Returns the live packed child ids for an entity.
    pub fn get_children(&self, entity: u32) -> Vec<u32> {
        let entity_slot = Self::unpack_slot(entity);
        self.children
            .get(&entity_slot)
            .map(|slots| {
                slots
                    .iter()
                    .filter(|&&s| self.alive.contains(&s))
                    .map(|&s| Self::pack_id(s, self.current_gen(s)))
                    .collect()
            })
            .unwrap_or_default()
    }
    /// Deletes an entity and every descendant reachable through the hierarchy.
    pub fn kill_recursive(&mut self, root: u32, lua: &Lua) -> LuaResult<()> {
        let mut to_kill: Vec<u32> = Vec::new();
        let mut stack: Vec<u32> = vec![root];
        while let Some(id) = stack.pop() {
            to_kill.push(id);
            let slot = Self::unpack_slot(id);
            if let Some(child_slots) = self.children.get(&slot) {
                for &cs in child_slots {
                    stack.push(Self::pack_id(cs, self.current_gen(cs)));
                }
            }
        }
        for id in to_kill {
            self.kill(EntityId(id), lua)?;
        }
        Ok(())
    }
    /// Returns whether a packed entity id still refers to a live slot and generation.
    pub fn is_alive(&self, id: u32) -> bool {
        let slot = Self::unpack_slot(id);
        let gen = Self::unpack_gen(id);
        self.alive.contains(&slot) && self.current_gen(slot) == gen
    }
    /// Returns the number of live entities.
    pub fn get_entity_count(&self) -> usize {
        self.alive.len()
    }
    /// Returns all live entity ids in ascending order.
    pub fn get_entities(&self) -> Vec<u32> {
        let mut ids: Vec<u32> = self
            .alive
            .iter()
            .map(|&slot| Self::pack_id(slot, self.current_gen(slot)))
            .collect();
        ids.sort();
        ids
    }
    /// Writes one component value into an entity row and records the change.
    pub fn set_component(
        &mut self,
        lua: &Lua,
        id: u32,
        name: &str,
        value: LuaValue,
    ) -> LuaResult<()> {
        if !self.is_alive(id) {
            return Err(mlua::Error::runtime(format!("Entity {} is not alive", id)));
        }
        self.ensure_stores(lua)?;
        let store = self.get_component_store(lua)?;
        let slot = Self::unpack_slot(id);
        let entity_table: Table = match store.get::<_, Table>(slot) {
            Ok(t) => t,
            Err(_) => {
                let t = lua.create_table()?;
                store.set(slot, t.clone())?;
                t
            }
        };
        entity_table.set(name, value.clone())?;
        #[cfg(feature = "ecs-archetype")]
        self.component_index
            .entry(name.to_string())
            .or_default()
            .insert(slot);
        self.add_events.push((id, name.to_string()));
        self.dirty_set.insert(id);
        self.bump_query_change_tick();
        Ok(())
    }
    /// Reads one component value from an entity row, yielding `nil` when absent.
    pub fn get_component<'lua>(
        &self,
        lua: &'lua Lua,
        id: u32,
        name: &str,
    ) -> LuaResult<LuaValue<'lua>> {
        if !self.is_alive(id) {
            return Ok(LuaValue::Nil);
        }
        let slot = Self::unpack_slot(id);
        if let Some(ref key) = self.component_store {
            let store: Table = lua.registry_value(key)?;
            if let Ok(entity_table) = store.get::<_, Table>(slot) {
                return entity_table.get::<_, LuaValue>(name);
            }
        }
        Ok(LuaValue::Nil)
    }
    /// Returns whether an entity row contains a non-`nil` value for the component name.
    pub fn has_component(&self, lua: &Lua, id: u32, name: &str) -> LuaResult<bool> {
        if !self.is_alive(id) {
            return Ok(false);
        }
        let slot = Self::unpack_slot(id);
        if let Some(ref key) = self.component_store {
            let store: Table = lua.registry_value(key)?;
            if let Ok(entity_table) = store.get::<_, Table>(slot) {
                let val: LuaValue = entity_table.get(name)?;
                return Ok(!val.is_nil());
            }
        }
        Ok(false)
    }
    /// Removes one component from an entity row and records the change when present.
    pub fn remove_component(&mut self, lua: &Lua, id: u32, name: &str) -> LuaResult<()> {
        let slot = Self::unpack_slot(id);
        if let Some(ref key) = self.component_store {
            let store: Table = lua.registry_value(key)?;
            if let Ok(entity_table) = store.get::<_, Table>(slot) {
                let had: LuaValue = entity_table.get(name)?;
                if !had.is_nil() {
                    entity_table.set(name, LuaValue::Nil)?;
                    #[cfg(feature = "ecs-archetype")]
                    if let Some(slots) = self.component_index.get_mut(name) {
                        slots.remove(&slot);
                    }
                    self.remove_events.push((id, name.to_string()));
                    self.dirty_set.insert(id);
                    self.bump_query_change_tick();
                }
            }
        }
        Ok(())
    }

    /// Applies a validated neutral ChangeSet table to explicit ECS component operations.
    ///
    /// Supported operation names are `set`/`replace`/`upsert` (component payload),
    /// `remove` (component removal), and `kill`/`despawn` (entity deletion). The
    /// table is validated in order before any mutation is performed so a stale or
    /// unsupported operation cannot leave a partially applied batch.
    fn parse_changeset<'lua>(
        &self,
        changeset: Table<'lua>,
    ) -> LuaResult<Vec<EcsChangeOperation<'lua>>> {
        let schema: String = changeset.get("schema")?;
        if schema.trim().is_empty() || schema.len() > 128 {
            return Err(mlua::Error::runtime(
                "ECS ChangeSet schema must contain 1..=128 characters",
            ));
        }
        let changes: Table = changeset.get("changes")?;
        if changes.raw_len() > 100_000 {
            return Err(mlua::Error::runtime("ECS ChangeSet exceeds 100000 records"));
        }
        let mut operations = Vec::new();
        let mut simulated_alive: HashSet<u32> = self.get_entities().into_iter().collect();
        for value in changes.sequence_values::<Table>() {
            let row = value?;
            let object_id: u64 = row.get("objectId")?;
            let id = u32::try_from(object_id).map_err(|_| {
                mlua::Error::runtime("ECS ChangeSet objectId must fit a 32-bit entity id")
            })?;
            if id == 0 {
                return Err(mlua::Error::runtime(
                    "ECS ChangeSet objectId must be greater than zero",
                ));
            }
            let component: String = row.get("component")?;
            if component.trim().is_empty() || component.len() > 128 {
                return Err(mlua::Error::runtime(
                    "ECS ChangeSet component must contain 1..=128 characters",
                ));
            }
            let operation: String = row.get("operation")?;
            match operation.as_str() {
                "set" | "replace" | "upsert" => {
                    if !simulated_alive.contains(&id) {
                        return Err(mlua::Error::runtime(format!(
                            "ECS ChangeSet targets dead entity {id}"
                        )));
                    }
                    let payload: LuaValue = row.get("payload")?;
                    operations.push((id, component, operation, payload));
                }
                "remove" => {
                    if !simulated_alive.contains(&id) {
                        return Err(mlua::Error::runtime(format!(
                            "ECS ChangeSet targets dead entity {id}"
                        )));
                    }
                    operations.push((id, component, operation, LuaValue::Nil));
                }
                "kill" | "despawn" => {
                    if !simulated_alive.remove(&id) {
                        return Err(mlua::Error::runtime(format!(
                            "ECS ChangeSet targets dead entity {id}"
                        )));
                    }
                    operations.push((id, component, operation, LuaValue::Nil));
                }
                _ => {
                    return Err(mlua::Error::runtime(format!(
                        "unsupported ECS ChangeSet operation '{operation}'"
                    )))
                }
            }
        }
        Ok(operations)
    }

    /// Validates a neutral ECS ChangeSet without mutating this universe.
    pub fn validate_changeset(&self, changeset: Table) -> LuaResult<usize> {
        self.parse_changeset(changeset)
            .map(|operations| operations.len())
    }

    /// Applies a validated neutral ChangeSet as one versioned logical mutation.
    pub fn apply_changeset(&mut self, lua: &Lua, changeset: Table) -> LuaResult<usize> {
        let operations = self.parse_changeset(changeset)?;
        let change_count = operations.len();
        let base_version = self.query_change_tick;
        for (id, component, operation, payload) in operations {
            match operation.as_str() {
                "set" | "replace" | "upsert" => {
                    self.set_component(lua, id, &component, payload)?;
                }
                "remove" => {
                    self.remove_component(lua, id, &component)?;
                }
                "kill" | "despawn" => {
                    self.kill(EntityId(id), lua)?;
                }
                _ => unreachable!("operation was validated above"),
            }
        }
        if change_count > 0 {
            self.query_change_tick = base_version.wrapping_add(1);
        }
        Ok(change_count)
    }
    /// Lists the component names currently stored on an entity row.
    pub fn get_component_names(&self, lua: &Lua, id: u32) -> LuaResult<Vec<String>> {
        let slot = Self::unpack_slot(id);
        let mut names = Vec::new();
        if let Some(ref key) = self.component_store {
            let store: Table = lua.registry_value(key)?;
            if let Ok(entity_table) = store.get::<_, Table>(slot) {
                for pair in entity_table.pairs::<String, LuaValue>() {
                    let (k, _) = pair?;
                    names.push(k);
                }
            }
        }
        names.sort();
        Ok(names)
    }
    /// Returns entity ids whose rows contain every requested component name.
    pub fn query(&self, lua: &Lua, names: &[String]) -> LuaResult<Vec<u32>> {
        self.query_component_sets(lua, names, &[])
    }

    /// Returns entity ids that match required components and exclude forbidden components.
    pub(crate) fn query_component_sets(
        &self,
        lua: &Lua,
        with_names: &[String],
        without_names: &[String],
    ) -> LuaResult<Vec<u32>> {
        let mut result = Vec::new();
        if let Some(ref key) = self.component_store {
            let store: Table = lua.registry_value(key)?;
            for slot in self.candidate_slots_for_all(with_names) {
                if let Ok(entity_table) = store.get::<_, Table>(slot) {
                    let mut all = true;
                    for name in with_names {
                        let val: LuaValue = entity_table.get(name.as_str())?;
                        if val.is_nil() {
                            all = false;
                            break;
                        }
                    }
                    if !all {
                        continue;
                    }
                    let mut has_excluded = false;
                    for name in without_names {
                        let val: LuaValue = entity_table.get(name.as_str())?;
                        if !val.is_nil() {
                            has_excluded = true;
                            break;
                        }
                    }
                    if !has_excluded {
                        result.push(Self::pack_id(slot, self.current_gen(slot)));
                    }
                } else if with_names.is_empty() {
                    result.push(Self::pack_id(slot, self.current_gen(slot)));
                }
            }
        } else if with_names.is_empty() {
            result = self.get_entities();
        }
        result.sort();
        Ok(result)
    }
    /// Calls a Lua callback for each live entity that owns the named component.
    pub fn each(&self, lua: &Lua, name: &str, callback: Function) -> LuaResult<()> {
        if let Some(ref key) = self.component_store {
            let store: Table = lua.registry_value(key)?;
            let mut slots: Vec<u32> = self.alive.iter().copied().collect();
            slots.sort();
            for slot in slots {
                if let Ok(entity_table) = store.get::<_, Table>(slot) {
                    let val: LuaValue = entity_table.get(name)?;
                    if !val.is_nil() {
                        callback
                            .call::<_, ()>((Self::pack_id(slot, self.current_gen(slot)), val))?;
                    }
                }
            }
        }
        Ok(())
    }
    /// Attaches a string tag to a live entity and updates the reverse index.
    pub fn add_tag(&mut self, id: u32, tag: &str) {
        if !self.is_alive(id) {
            return;
        }
        let slot = Self::unpack_slot(id);
        let tag_str = tag.to_string();
        let tags = self.string_tags.entry(slot).or_default();
        if !tags.contains(&tag_str) {
            tags.push(tag_str.clone());
            self.tag_index.entry(tag_str).or_default().push(id);
            self.bump_query_change_tick();
        }
    }
    /// Removes a string tag from an entity and the reverse tag index.
    pub fn remove_tag(&mut self, id: u32, tag: &str) {
        let slot = Self::unpack_slot(id);
        if let Some(tags) = self.string_tags.get_mut(&slot) {
            let before = tags.len();
            tags.retain(|t| t != tag);
            if tags.len() != before {
                self.bump_query_change_tick();
            }
        }
        if let Some(entries) = self.tag_index.get_mut(tag) {
            entries.retain(|&tid| tid != id);
        }
    }
    /// Returns whether an entity currently owns the given string tag.
    pub fn has_tag(&self, id: u32, tag: &str) -> bool {
        let slot = Self::unpack_slot(id);
        self.string_tags
            .get(&slot)
            .map(|tags| tags.iter().any(|t| t == tag))
            .unwrap_or(false)
    }
    /// Returns all string tags currently attached to an entity.
    pub fn get_tags(&self, id: u32) -> Vec<String> {
        let slot = Self::unpack_slot(id);
        self.string_tags.get(&slot).cloned().unwrap_or_default()
    }
    /// Returns all live entities currently indexed under the given string tag.
    pub fn get_entities_by_tag(&self, tag: &str) -> Vec<u32> {
        let mut result: Vec<u32> = self
            .iter_entities_by_tag(tag)
            .filter(|&id| self.is_alive(id))
            .collect();
        result.sort();
        result
    }
    /// Iterates over entity ids indexed under the given string tag.
    pub fn iter_entities_by_tag<'a>(&'a self, tag: &'a str) -> impl Iterator<Item = u32> + 'a {
        self.tag_index
            .get(tag)
            .into_iter()
            .flat_map(|entries| entries.iter().copied())
    }
    /// Resolves or allocates the bitmap bit position for a tag name.
    fn get_or_define_tag_bit(&mut self, name: &str) -> LuaResult<u8> {
        if let Some(&bit) = self.bitmap_tag_bits.get(name) {
            return Ok(bit);
        }
        if self.bitmap_tag_names.len() >= MAX_BITMAP_TAGS {
            return Err(mlua::Error::runtime(format!(
                "Maximum of {} bitmap tags reached",
                MAX_BITMAP_TAGS
            )));
        }
        let bit = self.bitmap_tag_names.len() as u8;
        self.bitmap_tag_names.push(name.to_string());
        self.bitmap_tag_bits.insert(name.to_string(), bit);
        Ok(bit)
    }
    /// Reserves and returns the bitmap bit position for a tag name.
    pub fn define_tag(&mut self, name: &str) -> LuaResult<u8> {
        self.get_or_define_tag_bit(name)
    }
    /// Sets one bitmap tag bit on a live entity.
    pub fn bitmap_tag(&mut self, id: u32, name: &str) -> LuaResult<()> {
        if !self.is_alive(id) {
            return Ok(());
        }
        let slot = Self::unpack_slot(id);
        let bit = self.get_or_define_tag_bit(name)?;
        let mask = self.bitmap_masks.entry(slot).or_insert(0);
        let before = *mask;
        *mask |= 1u64 << bit;
        if *mask != before {
            self.bump_query_change_tick();
        }
        Ok(())
    }
    /// Clears one bitmap tag bit on an entity when the tag exists.
    pub fn bitmap_untag(&mut self, id: u32, name: &str) {
        let slot = Self::unpack_slot(id);
        if let Some(&pos) = self.bitmap_tag_bits.get(name) {
            if let Some(mask) = self.bitmap_masks.get_mut(&slot) {
                let before = *mask;
                *mask &= !(1u64 << pos);
                if *mask != before {
                    self.bump_query_change_tick();
                }
            }
        }
    }
    /// Returns whether an entity currently has the named bitmap tag bit set.
    pub fn has_bitmap_tag(&self, id: u32, name: &str) -> bool {
        let slot = Self::unpack_slot(id);
        if let Some(&pos) = self.bitmap_tag_bits.get(name) {
            if let Some(mask) = self.bitmap_masks.get(&slot) {
                return (*mask & (1u64 << pos)) != 0;
            }
        }
        false
    }
    /// Returns live entities whose bitmap mask includes the named tag bit.
    pub fn query_bitmap_tag(&self, name: &str) -> Vec<u32> {
        if let Some(&pos) = self.bitmap_tag_bits.get(name) {
            let bit = 1u64 << pos;
            let mut result: Vec<u32> = self
                .alive
                .iter()
                .filter(|&&slot| {
                    self.bitmap_masks
                        .get(&slot)
                        .map(|m| m & bit != 0)
                        .unwrap_or(false)
                })
                .map(|&slot| Self::pack_id(slot, self.current_gen(slot)))
                .collect();
            result.sort();
            result
        } else {
            Vec::new()
        }
    }
    /// Returns live entities whose bitmap mask contains any requested tag bit.
    pub fn query_bitmap_any(&self, names: &[String]) -> Vec<u32> {
        let mut combined = 0u64;
        for name in names {
            if let Some(&pos) = self.bitmap_tag_bits.get(name.as_str()) {
                combined |= 1u64 << pos;
            }
        }
        if combined == 0 {
            return Vec::new();
        }
        let mut result: Vec<u32> = self
            .alive
            .iter()
            .filter(|&&slot| {
                self.bitmap_masks
                    .get(&slot)
                    .map(|m| m & combined != 0)
                    .unwrap_or(false)
            })
            .map(|&slot| Self::pack_id(slot, self.current_gen(slot)))
            .collect();
        result.sort();
        result
    }
    /// Returns live entities whose bitmap mask contains every requested tag bit.
    pub fn query_bitmap_all(&self, names: &[String]) -> Vec<u32> {
        let mut combined = 0u64;
        for name in names {
            if let Some(&pos) = self.bitmap_tag_bits.get(name.as_str()) {
                combined |= 1u64 << pos;
            } else {
                return Vec::new();
            }
        }
        if combined == 0 {
            return Vec::new();
        }
        let mut result: Vec<u32> = self
            .alive
            .iter()
            .filter(|&&slot| {
                self.bitmap_masks
                    .get(&slot)
                    .map(|m| m & combined == combined)
                    .unwrap_or(false)
            })
            .map(|&slot| Self::pack_id(slot, self.current_gen(slot)))
            .collect();
        result.sort();
        result
    }
    /// Returns the bit position assigned to a bitmap tag name.
    pub fn get_bitmap_tag_bit(&self, name: &str) -> Option<u8> {
        self.bitmap_tag_bits.get(name).copied()
    }
    /// Writes the layer value for a live entity.
    pub fn set_layer(&mut self, id: u32, layer: i32) {
        if self.is_alive(id) {
            let slot = Self::unpack_slot(id);
            let previous = self.layers.insert(slot, layer);
            if previous != Some(layer) {
                self.bump_query_change_tick();
            }
        }
    }
    /// Returns the stored layer value for an entity, defaulting to zero.
    pub fn get_layer(&self, id: u32) -> i32 {
        self.layers
            .get(&Self::unpack_slot(id))
            .copied()
            .unwrap_or(0)
    }
    /// Returns live entities whose stored layer equals the requested value.
    pub fn get_entities_by_layer(&self, layer: i32) -> Vec<u32> {
        let mut result: Vec<u32> = self
            .alive
            .iter()
            .filter(|&&slot| self.get_layer(slot) == layer)
            .map(|&slot| Self::pack_id(slot, self.current_gen(slot)))
            .collect();
        result.sort();
        result
    }
    /// Returns live entities sorted by layer and then by slot id.
    pub fn get_entities_sorted(&self) -> Vec<u32> {
        let mut entities: Vec<u32> = self
            .alive
            .iter()
            .map(|&slot| Self::pack_id(slot, self.current_gen(slot)))
            .collect();
        entities.sort_by(|a, b| {
            let la = self.get_layer(*a);
            let lb = self.get_layer(*b);
            la.cmp(&lb)
                .then(Self::unpack_slot(*a).cmp(&Self::unpack_slot(*b)))
        });
        entities
    }
    /// Stores a blueprint template under a name after deep-copying its Lua table.
    pub fn define_blueprint(&mut self, lua: &Lua, name: &str, components: Table) -> LuaResult<()> {
        self.ensure_stores(lua)?;
        let bp_store = self.get_blueprint_store(lua)?;
        let copy = deep_copy_table(lua, &components)?;
        bp_store.set(name, copy)?;
        Ok(())
    }
    /// Builds a child blueprint by copying a parent template and applying overrides.
    pub fn extend_blueprint(
        &mut self,
        lua: &Lua,
        name: &str,
        parent: &str,
        overrides: Table,
    ) -> LuaResult<()> {
        self.ensure_stores(lua)?;
        let bp_store = self.get_blueprint_store(lua)?;
        let parent_table: Table = bp_store.get(parent).map_err(|_| {
            mlua::Error::runtime(format!("Parent blueprint '{}' not found", parent))
        })?;
        let merged = deep_copy_table(lua, &parent_table)?;
        for pair in overrides.pairs::<LuaValue, LuaValue>() {
            let (k, v) = pair?;
            merged.set(k, v)?;
        }
        bp_store.set(name, merged)?;
        Ok(())
    }
    /// Spawns an entity from a named blueprint and optional override table.
    pub fn spawn_blueprint(
        &mut self,
        lua: &Lua,
        name: &str,
        overrides: Option<Table>,
    ) -> LuaResult<u32> {
        self.ensure_stores(lua)?;
        let bp_store = self.get_blueprint_store(lua)?;
        let bp_table: Table = bp_store
            .get(name)
            .map_err(|_| mlua::Error::runtime(format!("Blueprint '{}' not defined", name)))?;
        let id = self.spawn().raw();
        let store = self.get_component_store(lua)?;
        let entity_comps = deep_copy_table(lua, &bp_table)?;
        if let Some(ov) = overrides {
            for pair in ov.pairs::<LuaValue, LuaValue>() {
                let (k, v) = pair?;
                entity_comps.set(k, v)?;
            }
        }
        let slot = Self::unpack_slot(id);
        #[cfg(feature = "ecs-archetype")]
        self.reindex_component_row(slot, &entity_comps)?;
        store.set(slot, entity_comps)?;
        Ok(id)
    }
    /// Returns whether a blueprint name is present in the blueprint store.
    pub fn has_blueprint(&self, lua: &Lua, name: &str) -> LuaResult<bool> {
        if let Some(ref key) = self.blueprint_store {
            let store: Table = lua.registry_value(key)?;
            let val: LuaValue = store.get(name)?;
            Ok(!val.is_nil())
        } else {
            Ok(false)
        }
    }
    /// Removes one named blueprint from the blueprint store.
    pub fn remove_blueprint(&self, lua: &Lua, name: &str) -> LuaResult<()> {
        if let Some(ref key) = self.blueprint_store {
            let store: Table = lua.registry_value(key)?;
            store.set(name, LuaValue::Nil)?;
        }
        Ok(())
    }
    /// Returns the names of all stored blueprints.
    pub fn list_blueprints(&self, lua: &Lua) -> LuaResult<Vec<String>> {
        let mut names = Vec::new();
        if let Some(ref key) = self.blueprint_store {
            let store: Table = lua.registry_value(key)?;
            for pair in store.pairs::<String, LuaValue>() {
                let (k, _) = pair?;
                names.push(k);
            }
        }
        names.sort();
        Ok(names)
    }
    /// Returns a deep-copied Lua table containing one blueprint's component template.
    pub fn get_blueprint_components<'lua>(
        &self,
        lua: &'lua Lua,
        name: &str,
    ) -> LuaResult<LuaValue<'lua>> {
        if let Some(ref key) = self.blueprint_store {
            let store: Table = lua.registry_value(key)?;
            if let Ok(bp) = store.get::<_, Table>(name) {
                return Ok(LuaValue::Table(deep_copy_table(lua, &bp)?));
            }
        }
        Ok(LuaValue::Nil)
    }
    /// Resets the universe to an empty state and clears its Lua-backed stores.
    pub fn clear(&mut self, lua: &Lua) -> LuaResult<()> {
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
        self.system_priorities.clear();
        self.system_phases.clear();
        self.system_names.clear();
        self.system_deps.clear();
        self.add_events.clear();
        self.remove_events.clear();
        self.dirty_set.clear();
        self.deleted_entities.clear();
        self.relationships = RelationshipManager::new();
        self.bump_query_change_tick();
        if let Some(ref key) = self.component_store {
            let store: Table = lua.registry_value(key)?;
            let keys: Vec<u32> = store
                .clone()
                .pairs::<u32, LuaValue>()
                .filter_map(|p| p.ok().map(|(k, _)| k))
                .collect();
            for k in keys {
                store.set(k, LuaValue::Nil)?;
            }
        }
        if let Some(ref key) = self.system_store {
            let store: Table = lua.registry_value(key)?;
            let len = store.raw_len();
            for i in 1..=len {
                store.set(i, LuaValue::Nil)?;
            }
        }
        #[cfg(feature = "ecs-archetype")]
        self.component_index.clear();
        Ok(())
    }
    #[allow(clippy::type_complexity)]
    /// Drains buffered component add and remove notifications.
    pub fn take_component_events(&mut self) -> (Vec<(u32, String)>, Vec<(u32, String)>) {
        let adds = std::mem::take(&mut self.add_events);
        let removes = std::mem::take(&mut self.remove_events);
        self.dirty_set.clear();
        (adds, removes)
    }
    /// Returns the sorted set of entities marked dirty by component changes.
    pub fn get_dirty_entities(&self) -> Vec<u32> {
        let mut ids: Vec<u32> = self.dirty_set.iter().copied().collect();
        ids.sort();
        ids
    }
    /// Drains buffered component and entity changes into a snapshot diff.
    pub fn take_snapshot_diff(&mut self) -> SnapshotDiff {
        let dirty_entities = self.get_dirty_entities();
        let (added_components, removed_components) = self.take_component_events();
        let deleted_entities = std::mem::take(&mut self.deleted_entities);
        SnapshotDiff {
            added_components,
            removed_components,
            deleted_entities,
            dirty_entities,
        }
    }

    /// Adds a named directed relation between two live entities.
    pub fn add_relation(&mut self, from: u32, name: &str, to: u32) -> LuaResult<()> {
        self.ensure_alive(from, "lurek.ecs.addRelation")?;
        self.ensure_alive(to, "lurek.ecs.addRelation")?;
        self.relationships.add_link(from, name, to);
        Ok(())
    }

    /// Returns targets linked from a live entity by a named relation.
    pub fn get_related(&self, from: u32, name: &str) -> LuaResult<Vec<u32>> {
        self.ensure_alive(from, "lurek.ecs.getRelated")?;
        Ok(self.relationships.get_links(from, name).to_vec())
    }

    /// Removes one named directed relation between live entities.
    pub fn remove_relation(&mut self, from: u32, name: &str, to: u32) -> LuaResult<()> {
        self.ensure_alive(from, "lurek.ecs.removeRelation")?;
        self.ensure_alive(to, "lurek.ecs.removeRelation")?;
        self.relationships.remove_link(from, name, to);
        Ok(())
    }

    /// Clears every target for one named relation from a live source entity.
    pub fn clear_relations(&mut self, from: u32, name: &str) -> LuaResult<()> {
        self.ensure_alive(from, "lurek.ecs.clearRelations")?;
        self.relationships.clear_links(from, name);
        Ok(())
    }

    /// Returns whether a named directed relation exists between two live entities.
    pub fn has_relation(&self, from: u32, name: &str, to: u32) -> LuaResult<bool> {
        self.ensure_alive(from, "lurek.ecs.hasRelation")?;
        self.ensure_alive(to, "lurek.ecs.hasRelation")?;
        Ok(self.relationships.has_link(from, name, to))
    }
}
/// Default trait forwarding to `Universe::new()`.
impl Default for Universe {
    /// Creates an empty universe with default storage state.
    fn default() -> Self {
        Self::new()
    }
}
