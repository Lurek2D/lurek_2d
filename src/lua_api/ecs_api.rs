//! Registers the `lurek.ecs` Lua API for ECS userdata, entity access, and thin binding helpers over ECS state.

use super::SharedState;
use crate::ecs::loadout::{Loadout, PartDef, SlotDef, StatBlock};
use crate::ecs::lua_table::deep_copy_table;
use crate::ecs::object_model::{ClassMeta, ObjectModel};
use crate::ecs::query_view::QueryView;
use crate::ecs::Universe;
use mlua::prelude::*;
use std::cell::RefCell;
use std::collections::{BTreeMap, BTreeSet, HashMap};
use std::rc::Rc;
#[derive(Clone, Default)]
/// Shared Lua-facing ECS class and object registry for one Lua VM.
struct LuaObjectModelState {
    /// Rust policy state for class metadata and live object ids.
    model: Rc<RefCell<ObjectModel>>,
    /// Original Lua class definition tables keyed by class name.
    class_refs: Rc<RefCell<HashMap<String, LuaRegistryKey>>>,
    /// Live object tables keyed by generated object id.
    object_refs: Rc<RefCell<HashMap<u64, LuaRegistryKey>>>,
}

#[derive(Clone)]
/// Lua-side handle for one ECS universe.
pub struct LuaUniverse {
    /// Shared ECS universe storage used by all cloned Lua handles.
    inner: Rc<RefCell<Universe>>,
    /// Shared class/object registry used by `spawnObject` and `attachObject`.
    object_model: LuaObjectModelState,
    /// Registered callbacks keyed by component name for add events.
    add_observers: Rc<RefCell<HashMap<String, Vec<LuaRegistryKey>>>>,
    /// Registered callbacks keyed by component name for remove events.
    remove_observers: Rc<RefCell<HashMap<String, Vec<LuaRegistryKey>>>>,
}

#[derive(Clone)]
/// Lua-side relationship manager handle owned by `lurek.ecs`.
pub struct LuaRelationshipManager {
    /// Shared relationship storage used by all cloned Lua handles.
    inner: Rc<RefCell<crate::ecs::RelationshipManager>>,
}

#[derive(Clone)]
/// Lua-side cached ECS query view handle owned by one universe.
pub struct LuaQueryView {
    /// Universe handle used to refresh the cached query results.
    world: LuaUniverse,
    /// Shared query-view cache state.
    inner: Rc<RefCell<QueryView>>,
}

#[derive(Clone)]
/// Lua-side handle for one additive stat block.
pub struct LuaStatBlock {
    /// Shared stat storage.
    inner: Rc<RefCell<StatBlock>>,
}

#[derive(Clone)]
/// Lua-side handle for one loadout slot definition.
pub struct LuaSlotDef {
    /// Slot definition.
    inner: Rc<RefCell<SlotDef>>,
}

#[derive(Clone)]
/// Lua-side handle for one loadout part definition.
pub struct LuaPartDef {
    /// Part definition.
    inner: Rc<RefCell<PartDef>>,
}

#[derive(Clone)]
/// Lua-side handle for one modular loadout.
pub struct LuaLoadout {
    /// Shared loadout storage.
    pub(crate) inner: Rc<RefCell<Loadout>>,
}

fn lua_table_to_string_set(value: LuaValue) -> LuaResult<BTreeSet<String>> {
    let mut out = BTreeSet::new();
    match value {
        LuaValue::Nil => {}
        LuaValue::String(s) => {
            out.insert(s.to_str()?.to_string());
        }
        LuaValue::Table(t) => {
            for value in t.sequence_values::<String>() {
                out.insert(value?);
            }
        }
        _ => {
            return Err(LuaError::runtime(
                "lurek.ecs loadout tags must be a string or string array",
            ));
        }
    }
    Ok(out)
}

fn lua_table_to_string_vec(value: LuaValue) -> LuaResult<Vec<String>> {
    let mut out = Vec::new();
    match value {
        LuaValue::Nil => {}
        LuaValue::String(s) => out.push(s.to_str()?.to_string()),
        LuaValue::Table(t) => {
            for value in t.sequence_values::<String>() {
                out.push(value?);
            }
        }
        _ => {
            return Err(LuaError::runtime(
                "lurek.ecs loadout hardpoints must be a string or string array",
            ));
        }
    }
    Ok(out)
}

fn stat_block_from_lua(table: Option<LuaTable>) -> LuaResult<StatBlock> {
    let mut stats = StatBlock::new();
    if let Some(table) = table {
        for pair in table.pairs::<String, f64>() {
            let (key, value) = pair?;
            if !value.is_finite() {
                return Err(LuaError::runtime(format!(
                    "lurek.ecs.newPartDef stat '{key}' must be finite"
                )));
            }
            stats.add(key, value);
        }
    }
    Ok(stats)
}

fn stat_block_from_lua_value(value: LuaValue<'_>) -> LuaResult<StatBlock> {
    match value {
        LuaValue::Nil => Ok(StatBlock::new()),
        LuaValue::Table(table) => stat_block_from_lua(Some(table)),
        LuaValue::UserData(ud) => Ok(ud.borrow::<LuaStatBlock>()?.inner.borrow().clone()),
        _ => Err(LuaError::runtime(
            "stat block must be a plain table or LStatBlock userdata",
        )),
    }
}

fn stat_block_to_lua<'lua>(lua: &'lua Lua, stats: &StatBlock) -> LuaResult<LuaTable<'lua>> {
    let out = lua.create_table()?;
    for (key, value) in &stats.values {
        out.set(key.as_str(), *value)?;
    }
    Ok(out)
}

fn string_vec_to_lua<'lua>(
    lua: &'lua Lua,
    values: impl IntoIterator<Item = String>,
) -> LuaResult<LuaTable<'lua>> {
    let out = lua.create_table()?;
    for (i, value) in values.into_iter().enumerate() {
        out.set(i + 1, value)?;
    }
    Ok(out)
}

fn part_from_lua_table(opts: LuaTable) -> LuaResult<PartDef> {
    let id: String = opts
        .get::<_, Option<String>>("id")?
        .or_else(|| opts.get::<_, Option<String>>("name").ok().flatten())
        .ok_or_else(|| LuaError::runtime("lurek.ecs.newPartDef requires id or name"))?;
    let slot: String = opts.get::<_, Option<String>>("slot")?.unwrap_or_default();
    let mut part = PartDef::new(id, slot);
    part.tags = lua_table_to_string_set(opts.get::<_, LuaValue>("tags")?)?;
    part.stats = stat_block_from_lua(opts.get::<_, Option<LuaTable>>("stats")?)?;
    part.cost = opts.get::<_, Option<f64>>("cost")?.unwrap_or(0.0);
    part.mass = opts.get::<_, Option<f64>>("mass")?.unwrap_or(0.0);
    part.energy = opts.get::<_, Option<f64>>("energy")?.unwrap_or(0.0);
    part.heat = opts.get::<_, Option<f64>>("heat")?.unwrap_or(0.0);
    part.armor = opts.get::<_, Option<f64>>("armor")?.unwrap_or(0.0);
    part.hardpoints = lua_table_to_string_vec(opts.get::<_, LuaValue>("hardpoints")?)?;
    if let Some(visuals) = opts.get::<_, Option<LuaTable>>("visuals")? {
        let mut map = BTreeMap::new();
        for pair in visuals.pairs::<String, String>() {
            let (key, value) = pair?;
            map.insert(key, value);
        }
        part.visuals = map;
    }
    Ok(part)
}

fn slot_from_lua(name: String, opts: Option<LuaTable>) -> LuaResult<SlotDef> {
    let mut slot = SlotDef::new(name);
    if let Some(opts) = opts {
        slot.accepts = lua_table_to_string_set(opts.get::<_, LuaValue>("accepts")?)?;
        slot.required = opts.get::<_, Option<bool>>("required")?.unwrap_or(false);
        slot.hardpoint = opts.get::<_, Option<String>>("hardpoint")?;
    }
    Ok(slot)
}

fn parse_string_or_sequence(value: LuaValue) -> LuaResult<Vec<String>> {
    match value {
        LuaValue::Nil => Ok(Vec::new()),
        LuaValue::String(s) => Ok(vec![s.to_str()?.to_string()]),
        LuaValue::Table(t) => t.sequence_values::<String>().collect::<LuaResult<Vec<_>>>(),
        _ => Err(LuaError::runtime(
            "lurek.ecs.defineClass expected extends/tags as string or string array",
        )),
    }
}

fn merge_table_fields<'lua>(
    lua: &'lua Lua,
    target: &LuaTable<'lua>,
    source: Option<LuaTable<'lua>>,
) -> LuaResult<()> {
    if let Some(source) = source {
        for pair in source.pairs::<LuaValue, LuaValue>() {
            let (key, value) = pair?;
            let value = match value {
                LuaValue::Table(t) => LuaValue::Table(deep_copy_table(lua, &t)?),
                other => other,
            };
            target.set(key, value)?;
        }
    }
    Ok(())
}

fn build_class_info_table<'lua>(lua: &'lua Lua, meta: &ClassMeta) -> LuaResult<LuaTable<'lua>> {
    let out = lua.create_table()?;
    out.set("name", meta.name.as_str())?;
    let parents = lua.create_table()?;
    for (i, parent) in meta.parents.iter().enumerate() {
        parents.set(i + 1, parent.as_str())?;
    }
    out.set("extends", parents)?;
    let tags = lua.create_table()?;
    for (i, tag) in meta.tags.iter().enumerate() {
        tags.set(i + 1, tag.as_str())?;
    }
    out.set("tags", tags)?;
    Ok(out)
}

fn create_ecs_object<'lua>(
    lua: &'lua Lua,
    state: &LuaObjectModelState,
    class_name: &str,
    props: Option<LuaTable<'lua>>,
) -> LuaResult<LuaTable<'lua>> {
    if !state.model.borrow().has_class(class_name) {
        return Err(LuaError::runtime(format!(
            "lurek.ecs.newObject: class '{class_name}' is not defined"
        )));
    }
    let linearization = state.model.borrow().linearization(class_name);
    let object = lua.create_table()?;
    let methods = lua.create_table()?;
    let properties = lua.create_table()?;
    let tags = lua.create_table()?;
    let ctor_props = props
        .as_ref()
        .map(|table| LuaValue::Table(table.clone()))
        .unwrap_or(LuaValue::Nil);
    let mut tag_index = 1;
    for class in &linearization {
        let class_table = {
            let refs = state.class_refs.borrow();
            refs.get(class)
                .and_then(|key| lua.registry_value::<LuaTable>(key).ok())
        };
        if let Some(class_table) = class_table {
            merge_table_fields(
                lua,
                &object,
                class_table.get::<_, LuaTable>("defaults").ok(),
            )?;
            merge_table_fields(
                lua,
                &methods,
                class_table.get::<_, LuaTable>("methods").ok(),
            )?;
            merge_table_fields(
                lua,
                &properties,
                class_table.get::<_, LuaTable>("properties").ok(),
            )?;
        }
        if let Some(meta) = state.model.borrow().get_class(class) {
            for tag in &meta.tags {
                tags.set(tag_index, tag.as_str())?;
                tag_index += 1;
            }
        }
    }
    for pair in properties.clone().pairs::<LuaValue, LuaValue>() {
        let (key, value) = pair?;
        if !matches!(value, LuaValue::Table(_)) && object.get::<_, LuaValue>(key.clone())?.is_nil()
        {
            let value = match value {
                LuaValue::Table(t) => LuaValue::Table(deep_copy_table(lua, &t)?),
                other => other,
            };
            object.set(key, value)?;
        }
    }
    if let Some(props) = props {
        merge_table_fields(lua, &object, Some(props))?;
    }
    let object_id = state.model.borrow_mut().register_object(class_name);
    object.set("__id", object_id)?;
    object.set("__class", class_name)?;
    object.set("__tags", tags)?;
    object.set("__properties", properties.clone())?;

    let state_for_isa = state.clone();
    /// Returns whether this object inherits from or matches the supplied ECS class name.
    /// @param | self | LObject | Object table to inspect.
    /// @param | candidate | string | ECS class name to compare against the object's registered class hierarchy.
    /// @return | boolean | True when the object class matches or extends the supplied class.
    object.set(
        "isA",
        lua.create_function(move |_, (this, candidate): (LuaTable, String)| {
            let class: String = this.get("__class")?;
            Ok(state_for_isa.model.borrow().class_is_a(&class, &candidate))
        })?,
    )?;
    /// Returns the registered ECS class name for this object table.
    /// @param | self | LObject | Object table to inspect.
    /// @return | string | Class name assigned when the object was created.
    object.set(
        "type",
        lua.create_function(|_, this: LuaTable| this.get::<_, String>("__class"))?,
    )?;
    let state_for_typeof = state.clone();
    /// Returns whether this object matches a supported Lua-visible type or ECS class name.
    /// @param | self | LObject | Object table to inspect.
    /// @param | candidate | string | Type or class name to compare against `LObject` and the object's ECS class hierarchy.
    /// @return | boolean | True when the supplied name matches `LObject` or the object's class ancestry.
    object.set(
        "typeOf",
        lua.create_function(move |_, (this, candidate): (LuaTable, String)| {
            if candidate == "Object" || candidate == "LObject" {
                return Ok(true);
            }
            let class: String = this.get("__class")?;
            Ok(state_for_typeof
                .model
                .borrow()
                .class_is_a(&class, &candidate))
        })?,
    )?;
    /// Returns the current value of one object property, honoring any registered getter override first.
    /// @param | self | LObject | Object table that owns the property.
    /// @param | name | string | Property name to read from the object or its property metadata table.
    /// @return | LuaValue | Current property value, getter result, or `nil` when the property is unset.
    object.set(
        "getProperty",
        lua.create_function(|_, (this, name): (LuaTable, String)| {
            let properties: LuaTable = this.get("__properties")?;
            match properties.get::<_, LuaValue>(name.as_str())? {
                LuaValue::Table(prop) => {
                    if let Ok(getter) = prop
                        .get::<_, LuaFunction>("get")
                        .or_else(|_| prop.get::<_, LuaFunction>("getter"))
                    {
                        return getter.call::<_, LuaValue>(this);
                    }
                }
                LuaValue::Nil => {}
                value => {
                    let current = this.get::<_, LuaValue>(name.as_str())?;
                    return if current.is_nil() {
                        Ok(value)
                    } else {
                        Ok(current)
                    };
                }
            }
            this.get::<_, LuaValue>(name)
        })?,
    )?;
    /// Writes one object property, delegating to a registered setter override when the property defines one.
    /// @param | self | LObject | Object table that owns the property.
    /// @param | name | string | Property name to update on the object table.
    /// @param | value | any | New Lua value written directly or passed through the property's setter.
    object.set(
        "setProperty",
        lua.create_function(|_, (this, name, value): (LuaTable, String, LuaValue)| {
            let properties: LuaTable = this.get("__properties")?;
            if let Ok(prop) = properties.get::<_, LuaTable>(name.as_str()) {
                if let Ok(setter) = prop
                    .get::<_, LuaFunction>("set")
                    .or_else(|_| prop.get::<_, LuaFunction>("setter"))
                {
                    setter.call::<_, ()>((this, value))?;
                    return Ok(());
                }
            }
            this.set(name, value)
        })?,
    )?;
    let metatable = lua.create_table()?;
    metatable.set("__index", methods)?;
    object.set_metatable(Some(metatable));
    for class in &linearization {
        let class_table = {
            let refs = state.class_refs.borrow();
            refs.get(class)
                .and_then(|key| lua.registry_value::<LuaTable>(key).ok())
        };
        if let Some(class_table) = class_table {
            if let Ok(constructor) = class_table.get::<_, LuaFunction>("constructor") {
                constructor.call::<_, ()>((object.clone(), ctor_props.clone()))?;
            }
        }
    }
    let key = lua.create_registry_value(object.clone())?;
    state.object_refs.borrow_mut().insert(object_id, key);
    Ok(object)
}

impl LuaUserData for LuaRelationshipManager {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- type --
        /// Returns the Lua-visible type name for this relationship manager handle.
        /// @return | string | The string `LRelationshipManager`.
        methods.add_method("type", |_, _, ()| Ok("LRelationshipManager"));
        // -- typeOf --
        /// Returns whether this relationship manager handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LRelationshipManager` and `LObject`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LRelationshipManager" || name == "LObject")
        });
        // -- defineType --
        /// Defines a named relationship type with ordered level labels and an optional default level for new pairs.
        /// @param | name | string | Relationship type name used for later `setLevel` and `getLevel` calls.
        /// @param | levels | string[] | Array table of allowed level labels in their semantic order.
        /// @param | default_level | string? | Optional fallback level assigned when a pair has no explicit level for this type.
        methods.add_method(
            "defineType",
            |_, this, (name, levels, default_level): (String, LuaTable, Option<String>)| {
                let levels: Vec<String> = levels
                    .sequence_values::<String>()
                    .collect::<LuaResult<_>>()?;
                this.inner.borrow_mut().define_type(
                    &name,
                    levels,
                    default_level.as_deref().unwrap_or(""),
                );
                Ok(())
            },
        );
        // -- removeType --
        /// Removes a named relationship type definition.
        /// @param | name | string | Relationship type name to delete.
        methods.add_method("removeType", |_, this, name: String| {
            this.inner.borrow_mut().remove_type(&name);
            Ok(())
        });
        // -- typeNames --
        /// Returns the defined relationship type names.
        /// @return | string[] | Array table of registered relationship type names.
        methods.add_method("typeNames", |_, this, ()| {
            Ok(this.inner.borrow().type_names())
        });
        // -- setValue --
        /// Sets the numeric relationship value between two entity ids.
        /// @param | a | integer | Source entity id.
        /// @param | b | integer | Target entity id.
        /// @param | value | number | Numeric value stored for the pair.
        methods.add_method("setValue", |_, this, (a, b, value): (u32, u32, f64)| {
            this.inner.borrow_mut().set_value(a, b, value);
            Ok(())
        });
        // -- getValue --
        /// Returns the numeric relationship value between two entity ids.
        /// @param | a | integer | Source entity id.
        /// @param | b | integer | Target entity id.
        /// @return | number | Numeric value stored for the pair, or zero when unset.
        methods.add_method("getValue", |_, this, (a, b): (u32, u32)| {
            Ok(this.inner.borrow().get_value(a, b))
        });
        // -- adjustValue --
        /// Adds a delta to the numeric relationship value between two entity ids.
        /// @param | a | integer | Source entity id.
        /// @param | b | integer | Target entity id.
        /// @param | delta | number | Signed amount added to the current pair value.
        methods.add_method("adjustValue", |_, this, (a, b, delta): (u32, u32, f64)| {
            this.inner.borrow_mut().adjust_value(a, b, delta);
            Ok(())
        });
        // -- setLevel --
        /// Assigns a named level for one relationship type between two entity ids and reports whether the type-level pair was accepted.
        /// @param | a | integer | Source entity id for the relationship pair.
        /// @param | b | integer | Target entity id for the relationship pair.
        /// @param | type_name | string | Registered relationship type name to mutate.
        /// @param | level | string | Level label to store for the given type on this entity pair.
        /// @return | boolean | True when the type exists and the supplied level is valid for that type.
        methods.add_method(
            "setLevel",
            |_, this, (a, b, type_name, level): (u32, u32, String, String)| {
                Ok(this.inner.borrow_mut().set_level(a, b, &type_name, &level))
            },
        );
        // -- getLevel --
        /// Returns the effective named level for one relationship type on a pair, falling back to the type default when no explicit level exists.
        /// @param | a | integer | Source entity id for the relationship pair.
        /// @param | b | integer | Target entity id for the relationship pair.
        /// @param | type_name | string | Registered relationship type name to query.
        /// @return | string | Stored level label or the type default when available, otherwise `nil` if the type is unknown.
        methods.add_method(
            "getLevel",
            |_, this, (a, b, type_name): (u32, u32, String)| {
                Ok(this.inner.borrow().get_level(a, b, &type_name))
            },
        );
        // -- removePair --
        /// Removes all tracked relationship data between two entity ids.
        /// @param | a | integer | Source entity id.
        /// @param | b | integer | Target entity id.
        methods.add_method("removePair", |_, this, (a, b): (u32, u32)| {
            this.inner.borrow_mut().remove_relation(a, b);
            Ok(())
        });
        // -- pairCount --
        /// Returns how many entity-id pairs currently have tracked relationship data.
        /// @return | integer | Count of stored relationship pairs.
        methods.add_method("pairCount", |_, this, ()| {
            Ok(this.inner.borrow().relation_count())
        });
    }
}

impl LuaUserData for LuaQueryView {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- type --
        /// Returns the Lua-visible type name for this cached query-view handle.
        /// @return | string | The string `LQueryView`.
        methods.add_method("type", |_, _, ()| Ok("LQueryView"));
        // -- typeOf --
        /// Returns whether this cached query-view handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LQueryView` and `LObject`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LQueryView" || name == "LObject")
        });
        // -- ids --
        /// Returns cached query results, refreshing when the owning universe query tick changed.
        /// @return | integer[] | Array table of matching entity ids.
        methods.add_method("ids", |lua, this, ()| {
            let world = this.world.inner.borrow();
            let ids = this.inner.borrow_mut().ids(&world, lua)?.to_vec();
            Ok(ids)
        });
        // -- lastTick --
        /// Returns the universe query-change tick used to build the current cached ids.
        /// @return | integer | Query-change tick for the cached result set.
        methods.add_method("lastTick", |lua, this, ()| {
            let world = this.world.inner.borrow();
            let mut view = this.inner.borrow_mut();
            view.refresh(&world, lua)?;
            Ok(view.last_change_tick())
        });
    }
}

/// Provides Lua methods for ECS entity, component, system, tag, blueprint, hierarchy, observer, and relation operations.
impl LuaUserData for LuaUniverse {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- spawn --
        /// Creates a new entity in this universe.
        /// @return | integer | Numeric entity id for the spawned entity.
        methods.add_method("spawn", |_, this, ()| {
            Ok(this.inner.borrow_mut().spawn().raw())
        });
        // -- spawnObject --
        /// Creates an ECS object instance from a registered class and attaches it to a new entity.
        /// @param | className | string | Registered ECS class name.
        /// @param | props | table? | Optional property overrides copied onto the new object.
        /// @return | integer | Entity id that received the object component.
        methods.add_method(
            "spawnObject",
            |lua, this, (class_name, props): (String, Option<LuaTable>)| {
                let object = create_ecs_object(lua, &this.object_model, &class_name, props)?;
                let entity = this.inner.borrow_mut().spawn().raw();
                this.inner.borrow_mut().set_component(
                    lua,
                    entity,
                    "object",
                    LuaValue::Table(object.clone()),
                )?;
                this.inner.borrow_mut().set_component(
                    lua,
                    entity,
                    "objectClass",
                    LuaValue::String(lua.create_string(class_name.as_str())?),
                )?;
                let object_id: u64 = object.get("__id")?;
                this.inner.borrow_mut().set_component(
                    lua,
                    entity,
                    "objectId",
                    LuaValue::Integer(object_id as i64),
                )?;
                Ok(entity)
            },
        );
        // -- attachObject --
        /// Attaches an existing ECS object table to an entity as the `object` component.
        /// @param | entityId | integer | Entity id that receives the object.
        /// @param | obj | table | Object table returned by `lurek.ecs.newObject`.
        methods.add_method(
            "attachObject",
            |lua, this, (entity_id, obj): (u32, LuaTable)| {
                this.inner.borrow_mut().set_component(
                    lua,
                    entity_id,
                    "object",
                    LuaValue::Table(obj.clone()),
                )?;
                if let Ok(class_name) = obj.get::<_, String>("__class") {
                    this.inner.borrow_mut().set_component(
                        lua,
                        entity_id,
                        "objectClass",
                        LuaValue::String(lua.create_string(class_name.as_str())?),
                    )?;
                }
                if let Ok(object_id) = obj.get::<_, u64>("__id") {
                    this.inner.borrow_mut().set_component(
                        lua,
                        entity_id,
                        "objectId",
                        LuaValue::Integer(object_id as i64),
                    )?;
                }
                Ok(())
            },
        );
        // -- kill --
        /// Deletes an entity and removes its components from this universe.
        /// @param | id | integer | Entity id to delete.
        methods.add_method("kill", |lua, this, id: u32| {
            this.inner.borrow_mut().kill(crate::ecs::EntityId(id), lua)
        });
        // -- isAlive --
        /// Returns whether an entity id currently exists in this universe.
        /// @param | id | integer | Entity id to test.
        /// @return | boolean | True when the entity is alive.
        methods.add_method("isAlive", |_, this, id: u32| {
            Ok(this.inner.borrow().is_alive(id))
        });
        // -- set --
        /// Stores or replaces a component value on an entity.
        /// @param | id | integer | Entity id that receives the component.
        /// @param | name | string | Component name.
        /// @param | value | any | Lua value stored as the component payload.
        methods.add_method(
            "set",
            |lua, this, (id, name, value): (u32, String, LuaValue)| {
                this.inner.borrow_mut().set_component(lua, id, &name, value)
            },
        );
        // -- get --
        /// Returns a component value from an entity.
        /// @param | id | integer | Entity id to read.
        /// @param | name | string | Component name to read.
        /// @return | table|number|string|boolean|nil | Stored component value, or nil when the entity does not have that component.
        methods.add_method("get", |lua, this, (id, name): (u32, String)| {
            this.inner.borrow().get_component(lua, id, &name)
        });
        // -- has --
        /// Returns whether an entity has a named component.
        /// @param | id | integer | Entity id to inspect.
        /// @param | name | string | Component name to check.
        /// @return | boolean | True when the component exists on the entity.
        methods.add_method("has", |lua, this, (id, name): (u32, String)| {
            this.inner.borrow().has_component(lua, id, &name)
        });
        // -- remove --
        /// Removes a named component from an entity.
        /// @param | id | integer | Entity id to mutate.
        /// @param | name | string | Component name to remove.
        methods.add_method("remove", |lua, this, (id, name): (u32, String)| {
            this.inner.borrow_mut().remove_component(lua, id, &name)
        });
        // -- getComponents --
        /// Returns component names currently stored on an entity.
        /// @param | id | integer | Entity id to inspect.
        /// @return | string[] | Component name strings.
        methods.add_method("getComponents", |lua, this, id: u32| {
            this.inner.borrow().get_component_names(lua, id)
        });
        // -- query --
        /// Returns entities that have all component names passed as varargs.
        /// @param | ... | string | Component names that every returned entity must have.
        /// @return | integer[] | Array table of matching entity ids.
        methods.add_method("query", |lua, this, args: LuaMultiValue| {
            let names: Vec<String> = args
                .into_iter()
                .filter_map(|v| match v {
                    LuaValue::String(s) => s.to_str().ok().map(|s| s.to_string()),
                    _ => None,
                })
                .collect();
            this.inner.borrow().query(lua, &names)
        });
        // -- getQueryChangeTick --
        /// Returns the coarse invalidation tick used by cached ECS query views.
        /// @return | integer | Monotonic world query-change tick.
        methods.add_method("getQueryChangeTick", |_, this, ()| {
            Ok(this.inner.borrow().get_query_change_tick())
        });
        // -- newQueryView --
        /// Creates a cached component query view that refreshes only when this universe changes.
        /// @param | with_table | table | Array table of required component names.
        /// @param | without_table | table? | Optional array table of excluded component names.
        /// @return | LQueryView | Cached query-view handle bound to this universe.
        methods.add_method(
            "newQueryView",
            |_, this, (with_table, without_table): (LuaTable, Option<LuaTable>)| {
                let with_names: Vec<String> = with_table
                    .sequence_values::<String>()
                    .collect::<LuaResult<_>>()?;
                let without_names = if let Some(without_table) = without_table {
                    without_table
                        .sequence_values::<String>()
                        .collect::<LuaResult<_>>()?
                } else {
                    Vec::new()
                };
                Ok(LuaQueryView {
                    world: this.clone(),
                    inner: Rc::new(RefCell::new(QueryView::new(with_names, without_names))),
                })
            },
        );
        // -- each --
        /// Iterates entities with one component and calls a Lua callback for each match.
        /// @param | name | string | Component name used to select entities.
        /// @param | callback | function | Callback invoked by the ECS backend for each matching entity.
        methods.add_method(
            "each",
            |lua, this, (name, callback): (String, LuaFunction)| {
                this.inner.borrow().each(lua, &name, callback)
            },
        );
        // -- getEntities --
        /// Returns all live entity ids in this universe.
        /// @return | integer[] | Array table of live entity ids.
        methods.add_method("getEntities", |_, this, ()| {
            Ok(this.inner.borrow().get_entities())
        });
        // -- getEntityCount --
        /// Returns the number of live entities in this universe.
        /// @return | integer | Live entity count.
        methods.add_method("getEntityCount", |_, this, ()| {
            Ok(this.inner.borrow().get_entity_count())
        });
        // -- addSystem --
        /// Registers a Lua system table with optional phase, priority, name, and dependency metadata.
        /// @param | system | table | System table containing update, render, draw, or event methods.
        /// @param | opts | table? | Optional table with priority, phase, name, and after fields.
        methods.add_method(
            "addSystem",
            |lua, this, (system, opts): (LuaTable, Option<LuaTable>)| {
                let priority = opts
                    .as_ref()
                    .and_then(|o| o.get::<_, i32>("priority").ok())
                    .unwrap_or(0);
                let phase = opts
                    .as_ref()
                    .and_then(|o| o.get::<_, String>("phase").ok())
                    .unwrap_or_default();
                let name = opts
                    .as_ref()
                    .and_then(|o| o.get::<_, String>("name").ok())
                    .unwrap_or_default();
                let deps: Vec<String> = opts
                    .as_ref()
                    .and_then(|o| o.get::<_, LuaTable>("after").ok())
                    .map(|t| {
                        t.sequence_values::<String>()
                            .filter_map(|r| r.ok())
                            .collect()
                    })
                    .unwrap_or_default();
                this.inner
                    .borrow_mut()
                    .add_system(lua, system, priority, phase, name, deps)
            },
        );
        // -- removeSystem --
        /// Removes a previously registered Lua system table.
        /// @param | system | table | System table to remove from this universe.
        methods.add_method("removeSystem", |lua, this, system: LuaTable| {
            this.inner.borrow_mut().remove_system(lua, system)
        });
        // -- update --
        /// Runs registered update-phase systems with a frame delta.
        /// @param | dt | number | Frame delta time in seconds.
        methods.add_method("update", |lua, this, dt: f64| {
            let count = this.inner.borrow().get_system_count(lua)?;
            if count == 0 {
                return Ok(());
            }
            let order = this
                .inner
                .borrow()
                .get_sorted_system_indices_for_phase("update");
            let store = this.inner.borrow().get_system_store(lua)?;
            let world = this.clone();
            for i in order {
                let system: LuaTable = store.get(i)?;
                if let Ok(func) = system.get::<_, LuaFunction>("update") {
                    func.call::<_, ()>((system.clone(), world.clone(), dt))?;
                }
            }
            Ok(())
        });
        // -- render --
        /// Runs registered render-phase systems using their render or draw callbacks.
        methods.add_method("render", |lua, this, ()| {
            let count = this.inner.borrow().get_system_count(lua)?;
            if count == 0 {
                return Ok(());
            }
            let order = this
                .inner
                .borrow()
                .get_sorted_system_indices_for_phase("render");
            let store = this.inner.borrow().get_system_store(lua)?;
            let world = this.clone();
            for i in order {
                let system: LuaTable = store.get(i)?;
                let func = system
                    .get::<_, LuaFunction>("render")
                    .or_else(|_| system.get::<_, LuaFunction>("draw"));
                if let Ok(f) = func {
                    f.call::<_, ()>((system.clone(), world.clone()))?;
                }
            }
            Ok(())
        });
        // -- emit --
        /// Calls matching event-named functions on registered systems.
        /// @param | event | string | Function name looked up on each system table.
        /// @param | ... | any | Extra values forwarded after the system and universe arguments.
        methods.add_method("emit", |lua, this, args: LuaMultiValue| {
            let mut args_iter = args.into_iter();
            let event: String = match args_iter.next() {
                Some(LuaValue::String(s)) => s.to_str()?.to_string(),
                _ => {
                    return Err(LuaError::runtime(
                        "emit() requires event name as first argument",
                    ))
                }
            };
            let extra_args: Vec<LuaValue> = args_iter.collect();
            let count = this.inner.borrow().get_system_count(lua)?;
            if count == 0 {
                return Ok(());
            }
            let order = this.inner.borrow().get_sorted_system_indices_all();
            let store = this.inner.borrow().get_system_store(lua)?;
            let world = this.clone();
            for i in order {
                let system: LuaTable = store.get(i)?;
                if let Ok(func) = system.get::<_, LuaFunction>(event.as_str()) {
                    let mut call_args = Vec::with_capacity(2 + extra_args.len());
                    call_args.push(LuaValue::Table(system.clone()));
                    call_args.push(LuaValue::UserData(lua.create_userdata(world.clone())?));
                    call_args.extend(extra_args.iter().cloned());
                    func.call::<_, ()>(LuaMultiValue::from_vec(call_args))?;
                }
            }
            Ok(())
        });
        // -- getSystemCount --
        /// Returns the number of registered systems.
        /// @return | integer | Registered system count.
        methods.add_method("getSystemCount", |lua, this, ()| {
            this.inner.borrow().get_system_count(lua)
        });
        // -- updatePhase --
        /// Runs registered systems assigned to a named phase.
        /// @param | phase | string | System phase name to run.
        /// @param | dt | number | Frame delta time in seconds.
        methods.add_method("updatePhase", |lua, this, (phase, dt): (String, f64)| {
            let count = this.inner.borrow().get_system_count(lua)?;
            if count == 0 {
                return Ok(());
            }
            let order = this
                .inner
                .borrow()
                .get_sorted_system_indices_for_phase(&phase);
            let store = this.inner.borrow().get_system_store(lua)?;
            let world = this.clone();
            for i in order {
                let system: LuaTable = store.get(i)?;
                if let Ok(func) = system.get::<_, LuaFunction>("update") {
                    func.call::<_, ()>((system.clone(), world.clone(), dt))?;
                }
            }
            Ok(())
        });
        // -- getDirtyEntities --
        /// Returns entities marked dirty by recent ECS mutations.
        /// @return | integer[] | Array table of dirty entity ids.
        methods.add_method("getDirtyEntities", |lua, this, ()| {
            let ids = this.inner.borrow().get_dirty_entities();
            let t = lua.create_table()?;
            for (i, id) in ids.iter().enumerate() {
                t.set(i + 1, *id)?;
            }
            Ok(LuaValue::Table(t))
        });
        // -- queryMulti --
        /// Iterates entities that have all component names from a table.
        /// @param | names_table | table | Array table of component names.
        /// @param | callback | function | Callback invoked by the ECS backend for each matching entity.
        methods.add_method(
            "queryMulti",
            |lua, this, (names_table, callback): (LuaTable, LuaFunction)| {
                let mut names: Vec<String> = Vec::new();
                for pair in names_table.sequence_values::<String>() {
                    names.push(pair?);
                }
                this.inner.borrow().query_multi(lua, &names, callback)
            },
        );
        // -- snapshot --
        /// Serializes this universe into a Lua table snapshot.
        /// @return | table | Snapshot table containing entities and component state.
        /// @field | added_components | table | Added components.
        /// @field | removed_components | table | Removed components.
        /// @field | deleted_entities | integer[] | Deleted entity ids.
        /// @field | dirty_entities | integer[] | Dirty entity ids.
        methods.add_method("snapshot", |lua, this, ()| {
            this.inner.borrow().serialize_to_table(lua)
        });
        // -- applySnapshot --
        /// Replaces this universe state from a Lua table snapshot.
        /// @param | snapshot | table | Snapshot table previously produced by `snapshot` or `serialize`.
        methods.add_method("applySnapshot", |lua, this, snapshot: LuaTable| {
            this.inner
                .borrow_mut()
                .deserialize_from_table(lua, snapshot)
        });
        // -- applyChangeSet --
        /// Applies a transport-neutral ChangeSet table to explicit ECS component operations.
        /// @param | changeset | table | Table returned by `LChangeSet:toTable()` or `serialize.decodeChangeSet`.
        /// @return | integer | Number of validated records applied in order.
        methods.add_method("applyChangeSet", |lua, this, changeset: LuaTable| {
            this.inner.borrow_mut().apply_changeset(lua, changeset)
        });
        // -- takeSnapshotDiff --
        /// Returns and clears accumulated ECS snapshot diff data.
        /// @return | table | Diff table with added_components, removed_components, deleted_entities, and dirty_entities arrays.
        /// @field | added_components | table | Array of {entity_id, name} tables.
        /// @field | removed_components | table | Array of {entity_id, name} tables.
        /// @field | deleted_entities | integer[] | Deleted entity ids.
        /// @field | dirty_entities | integer[] | Modified entity ids.
        methods.add_method("takeSnapshotDiff", |lua, this, ()| {
            let diff = this.inner.borrow_mut().take_snapshot_diff();
            let out = lua.create_table()?;
            let added = lua.create_table()?;
            for (i, (id, name)) in diff.added_components.iter().enumerate() {
                let entry = lua.create_table()?;
                /// Performs the 'entity_id' operation.
                entry.set("entity_id", *id)?;
                /// Performs the 'name' operation.
                entry.set("name", name.clone())?;
                added.set(i + 1, entry)?;
            }
            /// Performs the 'added_components' operation.
            out.set("added_components", added)?;
            let removed = lua.create_table()?;
            for (i, (id, name)) in diff.removed_components.iter().enumerate() {
                let entry = lua.create_table()?;
                /// Performs the 'entity_id' operation.
                entry.set("entity_id", *id)?;
                /// Performs the 'name' operation.
                entry.set("name", name.clone())?;
                removed.set(i + 1, entry)?;
            }
            /// Performs the 'removed_components' operation.
            out.set("removed_components", removed)?;
            let deleted = lua.create_table()?;
            for (i, id) in diff.deleted_entities.iter().enumerate() {
                deleted.set(i + 1, *id)?;
            }
            /// Performs the 'deleted_entities' operation.
            out.set("deleted_entities", deleted)?;
            let dirty = lua.create_table()?;
            for (i, id) in diff.dirty_entities.iter().enumerate() {
                dirty.set(i + 1, *id)?;
            }
            /// Performs the 'dirty_entities' operation.
            out.set("dirty_entities", dirty)?;
            Ok(out)
        });
        // -- clear --
        /// Clears all entities, components, systems, and ECS state from this universe.
        methods.add_method("clear", |lua, this, ()| this.inner.borrow_mut().clear(lua));
        // -- release --
        /// Releases universe contents by clearing all ECS state.
        methods.add_method("release", |lua, this, ()| {
            this.inner.borrow_mut().clear(lua)
        });
        // -- addTag --
        /// Assigns a string tag name to an entity in this universe.
        /// @param | id | integer | Entity id to tag.
        /// @param | tag | string | Tag name to add.
        methods.add_method("addTag", |_, this, (id, tag): (u32, String)| {
            this.inner.borrow_mut().add_tag(id, &tag);
            Ok(())
        });
        // -- removeTag --
        /// Removes a string tag from an entity.
        /// @param | id | integer | Entity id to update.
        /// @param | tag | string | Tag name to remove.
        methods.add_method("removeTag", |_, this, (id, tag): (u32, String)| {
            this.inner.borrow_mut().remove_tag(id, &tag);
            Ok(())
        });
        // -- hasTag --
        /// Returns whether an entity has a string tag.
        /// @param | id | integer | Entity id to inspect.
        /// @param | tag | string | Tag name to check.
        /// @return | boolean | True when the entity has the tag.
        methods.add_method("hasTag", |_, this, (id, tag): (u32, String)| {
            Ok(this.inner.borrow().has_tag(id, &tag))
        });
        // -- getTags --
        /// Returns string tags assigned to an entity.
        /// @param | id | integer | Entity id to inspect.
        /// @return | string[] | Tag names.
        methods.add_method("getTags", |_, this, id: u32| {
            Ok(this.inner.borrow().get_tags(id))
        });
        // -- getEntitiesByTag --
        /// Returns entities that have a string tag.
        /// @param | tag | string | Tag name used for lookup.
        /// @return | integer[] | Array table of matching entity ids.
        methods.add_method("getEntitiesByTag", |_, this, tag: String| {
            Ok(this.inner.borrow().get_entities_by_tag(&tag))
        });
        // -- setLayer --
        /// Assigns a numeric layer to an entity.
        /// @param | id | integer | Entity id to update.
        /// @param | layer | integer | Layer value stored on the entity.
        methods.add_method("setLayer", |_, this, (id, layer): (u32, i32)| {
            this.inner.borrow_mut().set_layer(id, layer);
            Ok(())
        });
        // -- getLayer --
        /// Returns the numeric layer assigned to an entity.
        /// @param | id | integer | Entity id to inspect.
        /// @return | integer | Layer value, using the ECS default when no explicit layer exists.
        methods.add_method("getLayer", |_, this, id: u32| {
            Ok(this.inner.borrow().get_layer(id))
        });
        // -- getEntitiesByLayer --
        /// Returns entities assigned to a numeric layer.
        /// @param | layer | integer | Layer value used for lookup.
        /// @return | integer[] | Array table of matching entity ids.
        methods.add_method("getEntitiesByLayer", |_, this, layer: i32| {
            Ok(this.inner.borrow().get_entities_by_layer(layer))
        });
        // -- getEntitiesSorted --
        /// Returns live entities sorted by ECS layer and stable entity ordering.
        /// @return | integer[] | Array table of sorted entity ids.
        methods.add_method("getEntitiesSorted", |_, this, ()| {
            Ok(this.inner.borrow().get_entities_sorted())
        });
        // -- defineTag --
        /// Defines a bitmap tag name and assigns it a bit slot.
        /// @param | name | string | Bitmap tag name to define.
        /// @return | integer | Bit index assigned to the tag.
        methods.add_method("defineTag", |_, this, name: String| {
            this.inner.borrow_mut().define_tag(&name)
        });
        // -- bitmapTag --
        /// Adds a bitmap tag to an entity, defining the tag if needed.
        /// @param | id | integer | Entity id to tag.
        /// @param | name | string | Bitmap tag name.
        /// @return | integer | Bit index used by the bitmap tag.
        methods.add_method("bitmapTag", |_, this, (id, name): (u32, String)| {
            this.inner.borrow_mut().bitmap_tag(id, &name)
        });
        // -- bitmapUntag --
        /// Removes a bitmap tag from an entity.
        /// @param | id | integer | Entity id to update.
        /// @param | name | string | Bitmap tag name to remove.
        methods.add_method("bitmapUntag", |_, this, (id, name): (u32, String)| {
            this.inner.borrow_mut().bitmap_untag(id, &name);
            Ok(())
        });
        // -- hasBitmapTag --
        /// Returns whether an entity has a bitmap tag.
        /// @param | id | integer | Entity id to inspect.
        /// @param | name | string | Bitmap tag name to check.
        /// @return | boolean | True when the entity has the bitmap tag.
        methods.add_method("hasBitmapTag", |_, this, (id, name): (u32, String)| {
            Ok(this.inner.borrow().has_bitmap_tag(id, &name))
        });
        // -- queryBitmapTag --
        /// Returns entities with one bitmap tag.
        /// @param | name | string | Bitmap tag name used for lookup.
        /// @return | integer[] | Array table of matching entity ids.
        methods.add_method("queryBitmapTag", |_, this, name: String| {
            Ok(this.inner.borrow().query_bitmap_tag(&name))
        });
        // -- queryBitmapAny --
        /// Returns entities with at least one bitmap tag from a list.
        /// @param | names | table | Array table of bitmap tag names.
        /// @return | integer[] | Array table of matching entity ids.
        methods.add_method("queryBitmapAny", |_, this, names: LuaTable| {
            let name_vec: Vec<String> = names
                .sequence_values::<String>()
                .collect::<LuaResult<Vec<String>>>()?;
            Ok(this.inner.borrow().query_bitmap_any(&name_vec))
        });
        // -- queryBitmapAll --
        /// Returns entities that have every bitmap tag from a list.
        /// @param | names | table | Array table of bitmap tag names.
        /// @return | integer[] | Array table of matching entity ids.
        methods.add_method("queryBitmapAll", |_, this, names: LuaTable| {
            let name_vec: Vec<String> = names
                .sequence_values::<String>()
                .collect::<LuaResult<Vec<String>>>()?;
            Ok(this.inner.borrow().query_bitmap_all(&name_vec))
        });
        // -- getBitmapTagBit --
        /// Returns the bit index assigned to a bitmap tag name.
        /// @param | name | string | Bitmap tag name to inspect.
        /// @return | integer | Bit index when the tag exists, or nil when the tag is undefined.
        methods.add_method("getBitmapTagBit", |_, this, name: String| {
            Ok(this.inner.borrow().get_bitmap_tag_bit(&name))
        });
        // -- defineBlueprint --
        /// Defines a named entity blueprint from a component table.
        /// @param | name | string | Blueprint name.
        /// @param | components | table | Component table copied when the blueprint is spawned.
        methods.add_method(
            "defineBlueprint",
            |lua, this, (name, components): (String, LuaTable)| {
                this.inner
                    .borrow_mut()
                    .define_blueprint(lua, &name, components)
            },
        );
        // -- extendBlueprint --
        /// Defines a blueprint that inherits from a parent blueprint and applies overrides.
        /// @param | name | string | Child blueprint name to define.
        /// @param | parent | string | Existing parent blueprint name.
        /// @param | overrides | table | Component overrides applied over the parent definition.
        methods.add_method(
            "extendBlueprint",
            |lua, this, (name, parent, overrides): (String, String, LuaTable)| {
                this.inner
                    .borrow_mut()
                    .extend_blueprint(lua, &name, &parent, overrides)
            },
        );
        // -- spawnBlueprint --
        /// Spawns an entity from a named blueprint with optional component overrides.
        /// @param | name | string | Blueprint name to instantiate.
        /// @param | overrides | table? | Optional component overrides applied to this spawn.
        /// @return | integer | Entity id created from the blueprint.
        methods.add_method(
            "spawnBlueprint",
            |lua, this, (name, overrides): (String, Option<LuaTable>)| {
                this.inner
                    .borrow_mut()
                    .spawn_blueprint(lua, &name, overrides)
            },
        );
        // -- hasBlueprint --
        /// Returns whether a named blueprint exists.
        /// @param | name | string | Blueprint name to check.
        /// @return | boolean | True when the blueprint is registered.
        methods.add_method("hasBlueprint", |lua, this, name: String| {
            this.inner.borrow().has_blueprint(lua, &name)
        });
        // -- removeBlueprint --
        /// Removes a named blueprint from this universe.
        /// @param | name | string | Blueprint name to remove.
        /// @return | boolean | True when a blueprint was removed.
        methods.add_method("removeBlueprint", |lua, this, name: String| {
            this.inner.borrow().remove_blueprint(lua, &name)
        });
        // -- listBlueprints --
        /// Returns names of all registered blueprints.
        /// @return | string[] | Blueprint names.
        methods.add_method("listBlueprints", |lua, this, ()| {
            this.inner.borrow().list_blueprints(lua)
        });
        // -- getBlueprintComponents --
        /// Returns the component table stored for a blueprint.
        /// @param | name | string | Blueprint name to inspect.
        /// @return | table | Blueprint component table.
        methods.add_method("getBlueprintComponents", |lua, this, name: String| {
            this.inner.borrow().get_blueprint_components(lua, &name)
        });
        // -- setParent --
        /// Sets or clears the parent entity for a child entity.
        /// @param | child_id | integer | Entity id whose parent changes.
        /// @param | parent_id | integer? | Parent entity id, or nil to clear the parent.
        methods.add_method(
            "setParent",
            |_, this, (child_id, parent_id): (u32, Option<u32>)| {
                this.inner.borrow_mut().set_parent(child_id, parent_id)
            },
        );
        // -- getParent --
        /// Returns the parent entity id for a child entity.
        /// @param | child_id | integer | Entity id whose parent is read.
        /// @return | integer | Parent entity id, or nil when the entity has no parent.
        methods.add_method("getParent", |_, this, child_id: u32| {
            Ok(this.inner.borrow().get_parent(child_id))
        });
        // -- getChildren --
        /// Returns child entity ids for a parent entity.
        /// @param | parent_id | integer | Parent entity id to inspect.
        /// @return | integer[] | Array table of child entity ids.
        methods.add_method("getChildren", |_, this, parent_id: u32| {
            Ok(this.inner.borrow().get_children(parent_id))
        });
        // -- killRecursive --
        /// Deletes an entity and all descendant entities in its hierarchy.
        /// @param | id | integer | Root entity id to delete.
        methods.add_method("killRecursive", |lua, this, id: u32| {
            this.inner.borrow_mut().kill_recursive(id, lua)
        });
        // -- queryNot --
        /// Returns entities that include one component set and exclude another component set.
        /// @param | with_tbl | table | Array table of required component names.
        /// @param | without_tbl | table | Array table of forbidden component names.
        /// @return | integer[] | Array table of matching entity ids.
        methods.add_method(
            "queryNot",
            |lua, this, (with_tbl, without_tbl): (LuaTable, LuaTable)| {
                let with_names: Vec<String> = with_tbl
                    .sequence_values::<String>()
                    .collect::<LuaResult<_>>()?;
                let without_names: Vec<String> = without_tbl
                    .sequence_values::<String>()
                    .collect::<LuaResult<_>>()?;
                this.inner
                    .borrow()
                    .query_not(lua, &with_names, &without_names)
            },
        );
        // -- serialize --
        /// Serializes this universe into a Lua table snapshot.
        /// @return | table | Snapshot table containing entities and component state.
        /// @field | entities | integer[] | Array of entity ids.
        /// @field | components | table | Map of entity id to component data tables.
        methods.add_method("serialize", |lua, this, ()| {
            this.inner.borrow().serialize_to_table(lua)
        });
        // -- deserialize --
        /// Replaces this universe state from a serialized Lua snapshot.
        /// @param | snapshot | table | Snapshot table previously produced by `serialize` or `snapshot`.
        methods.add_method("deserialize", |lua, this, snapshot: LuaTable| {
            this.inner
                .borrow_mut()
                .deserialize_from_table(lua, snapshot)
        });
        // -- onComponentAdded --
        /// Registers a callback for queued component-add events with a given component name.
        /// @param | name | string | Component name whose add events are observed.
        /// @param | cb | function | Callback receiving entity id and component name.
        methods.add_method(
            "onComponentAdded",
            |lua, this, (name, cb): (String, LuaFunction)| {
                let key = lua.create_registry_value(cb)?;
                this.add_observers
                    .borrow_mut()
                    .entry(name)
                    .or_default()
                    .push(key);
                Ok(())
            },
        );
        // -- onComponentRemoved --
        /// Registers a callback for queued component-remove events with a given component name.
        /// @param | name | string | Component name whose remove events are observed.
        /// @param | cb | function | Callback receiving entity id and component name.
        methods.add_method(
            "onComponentRemoved",
            |lua, this, (name, cb): (String, LuaFunction)| {
                let key = lua.create_registry_value(cb)?;
                this.remove_observers
                    .borrow_mut()
                    .entry(name)
                    .or_default()
                    .push(key);
                Ok(())
            },
        );
        // -- flushObservers --
        /// Delivers queued component add and remove events to registered observer callbacks.
        methods.add_method("flushObservers", |lua, this, ()| {
            let (add_evs, remove_evs) = this.inner.borrow_mut().take_component_events();
            for (id, name) in &add_evs {
                if let Some(keys) = this
                    .add_observers
                    .borrow()
                    .get(name.as_str())
                    .map(|v| v.len())
                {
                    let _ = keys;
                }
                let keys_opt: Option<Vec<LuaFunction>> = {
                    let obs = this.add_observers.borrow();
                    obs.get(name.as_str()).map(|keys| {
                        keys.iter()
                            .filter_map(|k| lua.registry_value::<LuaFunction>(k).ok())
                            .collect()
                    })
                };
                if let Some(fns) = keys_opt {
                    for f in fns {
                        f.call::<_, ()>((*id, name.as_str()))?;
                    }
                }
            }
            for (id, name) in &remove_evs {
                let keys_opt: Option<Vec<LuaFunction>> = {
                    let obs = this.remove_observers.borrow();
                    obs.get(name.as_str()).map(|keys| {
                        keys.iter()
                            .filter_map(|k| lua.registry_value::<LuaFunction>(k).ok())
                            .collect()
                    })
                };
                if let Some(fns) = keys_opt {
                    for f in fns {
                        f.call::<_, ()>((*id, name.as_str()))?;
                    }
                }
            }
            Ok(())
        });
        // -- spawnBulk --
        /// Spawns multiple entities from a blueprint using shared optional overrides.
        /// @param | name | string | Blueprint name to instantiate.
        /// @param | count | integer | Number of entities to spawn.
        /// @param | overrides | table? | Optional component overrides applied to each spawned entity.
        /// @return | integer[] | Array table of spawned entity ids.
        methods.add_method(
            "spawnBulk",
            |lua, this, (name, count, overrides): (String, usize, Option<LuaTable>)| {
                this.inner
                    .borrow_mut()
                    .spawn_bulk(lua, &name, count, overrides)
            },
        );
        // -- addRelation --
        /// Adds a named directed relation from one entity to another.
        /// @param | from | integer | Source entity id.
        /// @param | name | string | Relation name.
        /// @param | to | integer | Target entity id.
        methods.add_method(
            "addRelation",
            |_, this, (from, name, to): (u32, String, u32)| {
                this.inner.borrow_mut().add_relation(from, &name, to)
            },
        );
        // -- getRelated --
        /// Returns targets linked from an entity by a named relation.
        /// @param | from | integer | Source entity id.
        /// @param | name | string | Relation name.
        /// @return | integer[] | Array table of related target entity ids.
        methods.add_method("getRelated", |lua, this, (from, name): (u32, String)| {
            let ids = this.inner.borrow().get_related(from, &name)?;
            let tbl = lua.create_table()?;
            for (i, id) in ids.iter().enumerate() {
                tbl.set(i + 1, *id)?;
            }
            Ok(tbl)
        });
        // -- removeRelation --
        /// Removes a named directed relation between two entities.
        /// @param | from | integer | Source entity id.
        /// @param | name | string | Relation name.
        /// @param | to | integer | Target entity id.
        methods.add_method(
            "removeRelation",
            |_, this, (from, name, to): (u32, String, u32)| {
                this.inner.borrow_mut().remove_relation(from, &name, to)
            },
        );
        // -- clearRelations --
        /// Removes every target for one named relation from an entity.
        /// @param | from | integer | Source entity id.
        /// @param | name | string | Relation name to clear.
        methods.add_method("clearRelations", |_, this, (from, name): (u32, String)| {
            this.inner.borrow_mut().clear_relations(from, &name)
        });
        // -- hasRelation --
        /// Returns whether a named directed relation exists between two entities.
        /// @param | from | integer | Source entity id.
        /// @param | name | string | Relation name.
        /// @param | to | integer | Target entity id.
        /// @return | boolean | True when the relation exists.
        methods.add_method(
            "hasRelation",
            |_, this, (from, name, to): (u32, String, u32)| {
                this.inner.borrow().has_relation(from, &name, to)
            },
        );
        // -- type --
        /// Returns the Lua-visible type name for this universe handle.
        /// @return | string | The string `LUniverse`.
        methods.add_method("type", |_, _, ()| Ok("LUniverse"));
        // -- typeOf --
        /// Returns whether this universe handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LUniverse` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LUniverse" || name == "LObject")
        });
    }
}

impl LuaUserData for LuaStatBlock {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- get --
        /// Returns one stat value, or zero when the key is absent.
        /// @param | name | string | Stat key.
        /// @return | number | Stat value.
        methods.add_method("get", |_, this, name: String| {
            Ok(this.inner.borrow().get(&name))
        });
        // -- set --
        /// Replaces one stat value.
        /// @param | name | string | Stat key.
        /// @param | value | number | Finite stat value.
        methods.add_method("set", |_, this, (name, value): (String, f64)| {
            if !value.is_finite() {
                return Err(LuaError::runtime("LStatBlock:set value must be finite"));
            }
            this.inner.borrow_mut().values.insert(name, value);
            Ok(())
        });
        // -- add --
        /// Adds a numeric delta to one stat.
        /// @param | name | string | Stat key.
        /// @param | value | number | Finite delta to add.
        methods.add_method("add", |_, this, (name, value): (String, f64)| {
            if !value.is_finite() {
                return Err(LuaError::runtime("LStatBlock:add value must be finite"));
            }
            this.inner.borrow_mut().add(name, value);
            Ok(())
        });
        // -- toTable --
        /// Returns all stat values as a plain Lua table.
        /// @return | table | Key-value stat table.
        methods.add_method("toTable", |lua, this, ()| {
            stat_block_to_lua(lua, &this.inner.borrow())
        });
        // -- type --
        /// Returns the Lua-visible type name for this stat block.
        /// @return | string | The string `LStatBlock`.
        methods.add_method("type", |_, _, ()| Ok("LStatBlock"));
        // -- typeOf --
        /// Returns whether this handle matches a supported type name.
        /// @param | name | string | Type name to compare.
        /// @return | boolean | True for `LStatBlock` or `LObject`.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LStatBlock" || name == "LObject")
        });
    }
}

impl LuaUserData for LuaSlotDef {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getName --
        /// Returns the slot name.
        /// @return | string | Slot name.
        methods.add_method("getName", |_, this, ()| {
            Ok(this.inner.borrow().name.clone())
        });
        // -- getAccepts --
        /// Returns accepted compatibility tags.
        /// @return | string[] | Accepted tags.
        methods.add_method("getAccepts", |lua, this, ()| {
            string_vec_to_lua(lua, this.inner.borrow().accepts.iter().cloned())
        });
        // -- isRequired --
        /// Returns whether this slot is required during loadout validation.
        /// @return | boolean | True when required.
        methods.add_method("isRequired", |_, this, ()| Ok(this.inner.borrow().required));
        // -- getHardpoint --
        /// Returns the slot hardpoint name when one is configured.
        /// @return | string | Hardpoint name, or nil.
        methods.add_method("getHardpoint", |_, this, ()| {
            Ok(this.inner.borrow().hardpoint.clone())
        });
        // -- type --
        /// Returns the Lua-visible type name for this slot definition.
        /// @return | string | The string `LSlotDef`.
        methods.add_method("type", |_, _, ()| Ok("LSlotDef"));
        // -- typeOf --
        /// Returns whether this handle matches a supported type name.
        /// @param | name | string | Type name to compare.
        /// @return | boolean | True for `LSlotDef` or `LObject`.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LSlotDef" || name == "LObject")
        });
    }
}

impl LuaUserData for LuaPartDef {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getId --
        /// Returns the stable part id.
        /// @return | string | Part id.
        methods.add_method("getId", |_, this, ()| Ok(this.inner.borrow().id.clone()));
        // -- getSlot --
        /// Returns the preferred slot name.
        /// @return | string | Slot name, or empty string when unrestricted.
        methods.add_method("getSlot", |_, this, ()| {
            Ok(this.inner.borrow().slot.clone())
        });
        // -- getTags --
        /// Returns compatibility tags.
        /// @return | string[] | Part tags.
        methods.add_method("getTags", |lua, this, ()| {
            string_vec_to_lua(lua, this.inner.borrow().tags.iter().cloned())
        });
        // -- getStats --
        /// Returns additive stat modifiers as a plain table.
        /// @return | table | Stat key-value table.
        methods.add_method("getStats", |lua, this, ()| {
            stat_block_to_lua(lua, &this.inner.borrow().stats)
        });
        // -- getCost --
        /// Returns the part cost value.
        /// @return | number | Part cost.
        methods.add_method("getCost", |_, this, ()| Ok(this.inner.borrow().cost));
        // -- getHardpoints --
        /// Returns hardpoints exposed by this part.
        /// @return | string[] | Hardpoint names.
        methods.add_method("getHardpoints", |lua, this, ()| {
            string_vec_to_lua(lua, this.inner.borrow().hardpoints.clone())
        });
        // -- getVisuals --
        /// Returns visual attachment mapping for this part.
        /// @return | table | Visual slot mapping.
        methods.add_method("getVisuals", |lua, this, ()| {
            let out = lua.create_table()?;
            for (key, value) in &this.inner.borrow().visuals {
                out.set(key.as_str(), value.as_str())?;
            }
            Ok(out)
        });
        // -- type --
        /// Returns the Lua-visible type name for this part definition.
        /// @return | string | The string `LPartDef`.
        methods.add_method("type", |_, _, ()| Ok("LPartDef"));
        // -- typeOf --
        /// Returns whether this handle matches a supported type name.
        /// @param | name | string | Type name to compare.
        /// @return | boolean | True for `LPartDef` or `LObject`.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LPartDef" || name == "LObject")
        });
    }
}

impl LuaUserData for LuaLoadout {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addSlot --
        /// Adds or replaces one slot definition on this loadout.
        /// @param | slot | LSlotDef | Slot definition to add.
        methods.add_method("addSlot", |_, this, slot_ud: LuaAnyUserData| {
            let slot = slot_ud.borrow::<LuaSlotDef>()?.inner.borrow().clone();
            this.inner.borrow_mut().add_slot(slot);
            Ok(())
        });
        // -- equip --
        /// Equips a part into a named slot after compatibility checks.
        /// @return boolean
        /// @param | slot | string | Slot name.
        /// @param | part | LPartDef | Part definition to equip.
        methods.add_method("equip", |_, this, args: LuaMultiValue| {
            let mut values = args.into_iter();
            let first = values.next().unwrap_or(LuaValue::Nil);
            let second = values.next().unwrap_or(LuaValue::Nil);
            let (slot, part_ud) = match (first, second) {
                (LuaValue::UserData(part_ud), LuaValue::Nil) => {
                    let part = part_ud.borrow::<LuaPartDef>()?.inner.borrow().clone();
                    (part.slot.clone(), part)
                }
                (LuaValue::String(slot), LuaValue::UserData(part_ud)) => {
                    let part = part_ud.borrow::<LuaPartDef>()?.inner.borrow().clone();
                    (slot.to_str()?.to_string(), part)
                }
                _ => {
                    return Err(LuaError::runtime(
                        "LLoadout:equip expects (part) or (slot, part)",
                    ));
                }
            };
            this.inner
                .borrow_mut()
                .equip(&slot, part_ud)
                .map_err(LuaError::runtime)?;
            Ok(true)
        });
        // -- unequip --
        /// Removes the part currently equipped in one slot.
        /// @param | slot | string | Slot name.
        /// @return | boolean | True when a part was removed.
        methods.add_method("unequip", |_, this, slot: String| {
            Ok(this.inner.borrow_mut().unequip(&slot).is_some())
        });
        // -- validate --
        /// Returns validation errors for missing or incompatible equipment.
        /// @return | string[] | Validation errors. Empty means the loadout is valid.
        methods.add_method("validate", |lua, this, ()| {
            let errors = this.inner.borrow().validate();
            let out = lua.create_table()?;
            out.set("valid", errors.is_empty())?;
            out.set("errors", string_vec_to_lua(lua, errors.clone())?)?;
            for (i, error) in errors.into_iter().enumerate() {
                out.set(i + 1, error)?;
            }
            Ok(out)
        });
        // -- computeStats --
        /// Computes final additive stats from base stats and equipped parts.
        /// @return | LStatBlock | Derived stat block.
        methods.add_method("computeStats", |_, this, ()| {
            Ok(LuaStatBlock {
                inner: Rc::new(RefCell::new(this.inner.borrow().compute_stats())),
            })
        });
        // -- getHardpoints --
        /// Returns slot and part hardpoints exposed by this loadout.
        /// @return | string[] | Hardpoint names.
        methods.add_method("getHardpoints", |lua, this, ()| {
            string_vec_to_lua(lua, this.inner.borrow().get_hardpoints())
        });
        // -- getCost --
        /// Returns total cost of equipped parts.
        /// @return | number | Total equipped cost.
        methods.add_method("getCost", |_, this, ()| Ok(this.inner.borrow().get_cost()));
        // -- toComponent --
        /// Returns a plain ECS component table with stats, hardpoints, cost, and equipped part ids.
        /// @return | table | Component table suitable for `LUniverse:set`.
        methods.add_method("toComponent", |lua, this, ()| {
            let loadout = this.inner.borrow();
            let out = lua.create_table()?;
            out.set("stats", stat_block_to_lua(lua, &loadout.compute_stats())?)?;
            out.set("cost", loadout.get_cost())?;
            out.set(
                "hardpoints",
                string_vec_to_lua(lua, loadout.get_hardpoints())?,
            )?;
            let equipped = lua.create_table()?;
            for (slot, part) in &loadout.equipped {
                equipped.set(slot.as_str(), part.id.as_str())?;
            }
            out.set("equipped", equipped)?;
            Ok(out)
        });
        // -- type --
        /// Returns the Lua-visible type name for this loadout.
        /// @return | string | The string `LLoadout`.
        methods.add_method("type", |_, _, ()| Ok("LLoadout"));
        // -- typeOf --
        /// Returns whether this handle matches a supported type name.
        /// @param | name | string | Type name to compare.
        /// @return | boolean | True for `LLoadout` or `LObject`.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LLoadout" || name == "LObject")
        });
    }
}

/// Registers the `lurek.ecs` API table with the Lua VM.
pub fn register(lua: &Lua, lurek: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    let object_state = LuaObjectModelState::default();
    // -- newUniverse --
    /// Creates an empty ECS universe for entity, component, system, and relationship management.
    /// @return | LUniverse | New universe handle.
    let universe_object_state = object_state.clone();
    tbl.set(
        "newUniverse",
        lua.create_function(move |_, ()| {
            Ok(LuaUniverse {
                inner: Rc::new(RefCell::new(Universe::new())),
                object_model: universe_object_state.clone(),
                add_observers: Rc::new(RefCell::new(HashMap::new())),
                remove_observers: Rc::new(RefCell::new(HashMap::new())),
            })
        })?,
    )?;
    // -- newRelationshipManager --
    /// Creates a relationship manager for tracking numeric values and named levels between entity pairs.
    /// @return | LRelationshipManager | New relationship manager handle owned by `lurek.ecs`.
    tbl.set(
        "newRelationshipManager",
        lua.create_function(|_, ()| {
            Ok(LuaRelationshipManager {
                inner: Rc::new(RefCell::new(crate::ecs::RelationshipManager::new())),
            })
        })?,
    )?;
    // -- newSlotDef --
    /// Creates a modular loadout slot definition.
    /// @param | name | string | Slot name.
    /// @param | opts | table? | Options: accepts string/string[], required boolean, hardpoint string.
    /// @return | LSlotDef | New slot definition handle.
    tbl.set(
        "newSlotDef",
        lua.create_function(|_, (name, opts): (String, Option<LuaTable>)| {
            Ok(LuaSlotDef {
                inner: Rc::new(RefCell::new(slot_from_lua(name, opts)?)),
            })
        })?,
    )?;
    // -- newPartDef --
    /// Creates a modular loadout part definition.
    /// @param | opts | table | Part options: id/name, slot, tags, stats, cost, mass, energy, heat, armor, hardpoints, visuals.
    /// @return | LPartDef | New part definition handle.
    tbl.set(
        "newPartDef",
        lua.create_function(|_, opts: LuaTable| {
            Ok(LuaPartDef {
                inner: Rc::new(RefCell::new(part_from_lua_table(opts)?)),
            })
        })?,
    )?;
    // -- newLoadout --
    /// Creates a modular loadout from optional slot definitions and base stats.
    /// @param | opts | table? | Options: slots array of LSlotDef, baseStats table.
    /// @return | LLoadout | New loadout handle.
    tbl.set(
        "newLoadout",
        lua.create_function(|_, opts: Option<LuaTable>| {
            let mut loadout = Loadout::new();
            if let Some(opts) = opts {
                loadout.base_stats = stat_block_from_lua_value(opts.get("baseStats")?)?;
                if let Some(slots) = opts.get::<_, Option<LuaTable>>("slots")? {
                    for slot_ud in slots.sequence_values::<LuaAnyUserData>() {
                        let slot = slot_ud?.borrow::<LuaSlotDef>()?.inner.borrow().clone();
                        loadout.add_slot(slot);
                    }
                }
            }
            Ok(LuaLoadout {
                inner: Rc::new(RefCell::new(loadout)),
            })
        })?,
    )?;
    // -- newStatBlock --
    /// Creates a standalone stat block from a plain table.
    /// @param | stats | table? | Optional stat key-value table.
    /// @return | LStatBlock | New stat block handle.
    tbl.set(
        "newStatBlock",
        lua.create_function(|_, stats: Option<LuaTable>| {
            Ok(LuaStatBlock {
                inner: Rc::new(RefCell::new(stat_block_from_lua(stats)?)),
            })
        })?,
    )?;
    // -- defineClass --
    /// Defines or replaces a global ECS class for Lua object instances.
    /// @param | name | string | Class name used by `newObject` and `LUniverse:spawnObject`.
    /// @param | def | table | Class definition with optional extends, defaults, methods, properties, constructor, and tags.
    let define_state = object_state.clone();
    tbl.set(
        "defineClass",
        lua.create_function(move |lua, (name, def): (String, LuaTable)| {
            let parents = parse_string_or_sequence(def.get::<_, LuaValue>("extends")?)?;
            let tags = parse_string_or_sequence(def.get::<_, LuaValue>("tags")?)?;
            define_state
                .model
                .borrow_mut()
                .define_class(ClassMeta::new(&name, parents, tags));
            if let Some(old) = define_state.class_refs.borrow_mut().remove(&name) {
                lua.remove_registry_value(old)?;
            }
            let key = lua.create_registry_value(def)?;
            define_state.class_refs.borrow_mut().insert(name, key);
            Ok(())
        })?,
    )?;
    // -- hasClass --
    /// Returns whether a global ECS class name is defined.
    /// @param | name | string | Class name to check.
    /// @return | boolean | True when the class exists.
    let has_class_state = object_state.clone();
    tbl.set(
        "hasClass",
        lua.create_function(move |_, name: String| {
            Ok(has_class_state.model.borrow().has_class(&name))
        })?,
    )?;
    // -- getClass --
    /// Returns metadata for a global ECS class.
    /// @param | name | string | Class name to inspect.
    /// @return | table | Metadata table with name, extends, and tags; nil when unknown.
    let get_class_state = object_state.clone();
    tbl.set(
        "getClass",
        lua.create_function(move |lua, name: String| {
            if let Some(meta) = get_class_state.model.borrow().get_class(&name) {
                Ok(LuaValue::Table(build_class_info_table(lua, meta)?))
            } else {
                Ok(LuaValue::Nil)
            }
        })?,
    )?;
    // -- classNames --
    /// Returns all global ECS class names in deterministic order.
    /// @return | string[] | Registered class names.
    let class_names_state = object_state.clone();
    tbl.set(
        "classNames",
        lua.create_function(move |_, ()| Ok(class_names_state.model.borrow().class_names()))?,
    )?;
    // -- clearClasses --
    /// Removes every global ECS class definition.
    let clear_classes_state = object_state.clone();
    tbl.set(
        "clearClasses",
        lua.create_function(move |lua, ()| {
            clear_classes_state.model.borrow_mut().clear_classes();
            let refs: Vec<LuaRegistryKey> = clear_classes_state
                .class_refs
                .borrow_mut()
                .drain()
                .map(|(_, key)| key)
                .collect();
            for key in refs {
                lua.remove_registry_value(key)?;
            }
            Ok(())
        })?,
    )?;
    // -- newObject --
    /// Creates a Lua table object from a registered ECS class.
    /// @param | className | string | Registered class name.
    /// @param | props | table? | Optional property overrides.
    /// @return | table | Object table with type, typeOf, isA, getProperty, and setProperty methods.
    let new_object_state = object_state.clone();
    tbl.set(
        "newObject",
        lua.create_function(
            move |lua, (class_name, props): (String, Option<LuaTable>)| {
                create_ecs_object(lua, &new_object_state, &class_name, props)
            },
        )?,
    )?;
    // -- getObject --
    /// Returns a live ECS object table by object id.
    /// @param | id | integer | Object id returned in the object's `__id` field.
    /// @return | table | Object table, or nil when not found.
    let get_object_state = object_state.clone();
    tbl.set(
        "getObject",
        lua.create_function(move |lua, id: u64| {
            if !get_object_state.model.borrow().has_object(id) {
                return Ok(LuaValue::Nil);
            }
            if let Some(key) = get_object_state.object_refs.borrow().get(&id) {
                return Ok(LuaValue::Table(lua.registry_value::<LuaTable>(key)?));
            }
            Ok(LuaValue::Nil)
        })?,
    )?;
    // -- hasObject --
    /// Returns whether a live ECS object id exists.
    /// @param | id | integer | Object id to check.
    /// @return | boolean | True when the object id is live.
    let has_object_state = object_state.clone();
    tbl.set(
        "hasObject",
        lua.create_function(move |_, id: u64| Ok(has_object_state.model.borrow().has_object(id)))?,
    )?;
    // -- objectIds --
    /// Returns all live ECS object ids in ascending order.
    /// @return | integer[] | Object ids.
    let object_ids_state = object_state.clone();
    tbl.set(
        "objectIds",
        lua.create_function(move |_, ()| Ok(object_ids_state.model.borrow().object_ids()))?,
    )?;
    // -- destroyObject --
    /// Removes a live ECS object from the global object registry.
    /// @param | id | integer | Object id to destroy.
    /// @return | boolean | True when an object was removed.
    let destroy_object_state = object_state.clone();
    tbl.set(
        "destroyObject",
        lua.create_function(move |lua, id: u64| {
            let existed = destroy_object_state.model.borrow_mut().destroy_object(id);
            if let Some(key) = destroy_object_state.object_refs.borrow_mut().remove(&id) {
                lua.remove_registry_value(key)?;
            }
            Ok(existed)
        })?,
    )?;
    // -- clearObjects --
    /// Removes every live ECS object while keeping class definitions.
    let clear_objects_state = object_state.clone();
    tbl.set(
        "clearObjects",
        lua.create_function(move |lua, ()| {
            clear_objects_state.model.borrow_mut().clear_objects();
            let refs: Vec<LuaRegistryKey> = clear_objects_state
                .object_refs
                .borrow_mut()
                .drain()
                .map(|(_, key)| key)
                .collect();
            for key in refs {
                lua.remove_registry_value(key)?;
            }
            Ok(())
        })?,
    )?;
    /// The 'ecs' field value exposed to Lua scripts.
    lurek.set("ecs", tbl)?;
    Ok(())
}
