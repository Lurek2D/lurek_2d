//! Registers the `lurek.physics` Lua API for bodies, shapes, raycasts, queries, events, and debug settings.

use super::SharedState;
use crate::image::ImageData;
use crate::math::Vec2;
use crate::physics::world::{BodyContact, COLLISION_GROUP_COUNT};
use crate::physics::{
    AlphaShapeOptions, Body, BodyId, BodyType, PhysicsQueryFilter, PhysicsWorldStats, PhysicsZone,
    RaycastHit, Shape, TerrainMap, World,
};
use mlua::prelude::*;
use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::Rc;

/// Parses a strict Lua body type string into the corresponding engine body type.
fn parse_body_type(s: &str) -> LuaResult<BodyType> {
    match s {
        "static" => Ok(BodyType::Static),
        "dynamic" => Ok(BodyType::Dynamic),
        "kinematic" => Ok(BodyType::Kinematic),
        "sensor" => Ok(BodyType::Sensor),
        _ => Err(LuaError::external(format!(
            "invalid body type '{}': expected static, dynamic, kinematic, or sensor",
            s
        ))),
    }
}

fn physics_runtime_error(method: &str, message: impl std::fmt::Display) -> LuaError {
    LuaError::RuntimeError(format!("lurek.physics.{}: {}", method, message))
}

fn lua_collision_group(method: &str, group: i64) -> LuaResult<usize> {
    if !(0..COLLISION_GROUP_COUNT as i64).contains(&group) {
        return Err(physics_runtime_error(
            method,
            format!("collision group must be in 0..15, got {}", group),
        ));
    }
    Ok(group as usize)
}

fn lua_collision_group_mask(method: &str, mask: u32) -> LuaResult<u32> {
    if mask > 0xFFFF {
        return Err(physics_runtime_error(
            method,
            format!("collision group mask must be in 0..0xFFFF, got {}", mask),
        ));
    }
    Ok(mask)
}

/// Converts Lua shape constructor arguments into an engine physics shape definition.
fn shape_from_lua(lua: &Lua, shape_type: &str, args: LuaMultiValue) -> LuaResult<Shape> {
    let mut float_args: Vec<f32> = Vec::new();
    let mut closed = false;
    let mut iter = args.into_iter();
    let first = iter.next().unwrap_or(LuaValue::Nil);
    if matches!(shape_type, "polygon" | "chain") {
        let tbl: LuaTable = lua.unpack(first)?;
        let len = tbl.raw_len();
        let mut i = 1i64;
        while i < len as i64 {
            float_args.push(tbl.raw_get(i)?);
            float_args.push(tbl.raw_get(i + 1)?);
            i += 2;
        }
        if shape_type == "chain" {
            closed = lua
                .unpack(iter.next().unwrap_or(LuaValue::Boolean(false)))
                .unwrap_or(false);
        }
    } else {
        float_args.push(lua.unpack(first)?);
        for v in iter {
            if let Ok(f) = lua.unpack::<f32>(v) {
                float_args.push(f);
            }
        }
    }
    Shape::from_parts(shape_type, &float_args, closed).map_err(LuaError::runtime)
}

/// Serializes a physics raycast hit into the Lua table shape exposed by the bindings.
fn raycast_hit_to_table<'lua>(lua: &'lua Lua, hit: &RaycastHit) -> LuaResult<LuaTable<'lua>> {
    // @return table: { bodyId, x, y, normalX, normalY, toi }
    let tbl = lua.create_table()?;
    tbl.set("bodyId", hit.body_id)?;
    tbl.set("x", hit.point.0)?;
    tbl.set("y", hit.point.1)?;
    tbl.set("normalX", hit.normal.0)?;
    tbl.set("normalY", hit.normal.1)?;
    tbl.set("toi", hit.toi)?;
    Ok(tbl)
}

/// Parses an optional Lua query-filter table.
fn query_filter_from_lua(method: &str, value: Option<LuaValue>) -> LuaResult<PhysicsQueryFilter> {
    let mut filter = PhysicsQueryFilter::default();
    let Some(value) = value else {
        return Ok(filter);
    };
    if matches!(value, LuaValue::Nil) {
        return Ok(filter);
    }
    let LuaValue::Table(tbl) = value else {
        return Err(LuaError::RuntimeError(
            "physics query filter expects table or nil".into(),
        ));
    };
    filter.layer = tbl.get::<_, Option<u32>>("layer")?;
    filter.mask = tbl.get::<_, Option<u32>>("mask")?;
    let group = tbl.get::<_, Option<i64>>("group")?;
    let groups = tbl.get::<_, Option<u32>>("groups")?;
    if group.is_some() && groups.is_some() {
        return Err(physics_runtime_error(
            method,
            "query filter accepts either group or groups, not both",
        ));
    }
    if (group.is_some() || groups.is_some()) && filter.layer.is_some() {
        return Err(physics_runtime_error(
            method,
            "query filter accepts either layer or group/groups, not both",
        ));
    }
    if let Some(group) = group {
        filter.groups = Some(1u32 << lua_collision_group(method, group)?);
    }
    if let Some(groups) = groups {
        filter.groups = Some(lua_collision_group_mask(method, groups)?);
    }
    if let Some(include_sensors) = tbl.get::<_, Option<bool>>("includeSensors")? {
        filter.include_sensors = include_sensors;
    }
    Ok(filter)
}

fn alpha_shape_options_from_lua(opts: Option<LuaTable>) -> LuaResult<AlphaShapeOptions> {
    let mut options = AlphaShapeOptions::default();
    let Some(opts) = opts else {
        return Ok(options);
    };
    if let Some(threshold) = opts.get::<_, Option<u8>>("alphaThreshold")? {
        options.alpha_threshold = threshold;
    }
    if let Some(max_vertices) = opts.get::<_, Option<usize>>("maxVertices")? {
        options.max_vertices = max_vertices;
    }
    if let Some(tolerance) = opts.get::<_, Option<f32>>("circleAspectTolerance")? {
        if !tolerance.is_finite() || tolerance < 0.0 {
            return Err(physics_runtime_error(
                "shapeFromImage",
                "circleAspectTolerance must be finite and >= 0",
            ));
        }
        options.circle_aspect_tolerance = tolerance;
    }
    if let Some(tolerance) = opts.get::<_, Option<f32>>("circleFillTolerance")? {
        if !tolerance.is_finite() || tolerance < 0.0 {
            return Err(physics_runtime_error(
                "shapeFromImage",
                "circleFillTolerance must be finite and >= 0",
            ));
        }
        options.circle_fill_tolerance = tolerance;
    }
    if let Some(threshold) = opts.get::<_, Option<f32>>("rectangleFillThreshold")? {
        if !threshold.is_finite() || !(0.0..=1.0).contains(&threshold) {
            return Err(physics_runtime_error(
                "shapeFromImage",
                "rectangleFillThreshold must be finite and in [0, 1]",
            ));
        }
        options.rectangle_fill_threshold = threshold;
    }
    Ok(options)
}

/// Reads a required positional number from a Lua vararg list.
fn required_f32(lua: &Lua, vals: &[LuaValue], idx: usize, name: &str) -> LuaResult<f32> {
    let value = vals.get(idx).cloned().ok_or_else(|| {
        LuaError::RuntimeError(format!("missing required physics argument '{}'", name))
    })?;
    f32::from_lua(value, lua)
}

/// Serializes a physics contact record into Lua.
fn contact_to_table<'lua>(
    lua: &'lua Lua,
    c: &crate::physics::ContactInfo,
) -> LuaResult<LuaTable<'lua>> {
    // @return table: { bodyA, bodyB, normalX, normalY, isTouching }
    let tbl = lua.create_table()?;
    tbl.set("bodyA", c.body_a)?;
    tbl.set("bodyB", c.body_b)?;
    tbl.set("normalX", c.normal_x)?;
    tbl.set("normalY", c.normal_y)?;
    tbl.set("isTouching", c.is_touching)?;
    Ok(tbl)
}

/// Serializes world diagnostics into a Lua table.
fn stats_to_table<'lua>(lua: &'lua Lua, stats: PhysicsWorldStats) -> LuaResult<LuaTable<'lua>> {
    // @return table: { bodies, bodySlots, colliders, joints, jointSlots, zones, gravityVectors, sleepingBodies, skippedSteps, clampedSteps, invalidOperations, bodiesScanned, collidersRebuilt, zoneChecks, contacts, syncedBodies }
    let tbl = lua.create_table()?;
    tbl.set("bodies", stats.bodies)?;
    tbl.set("bodySlots", stats.body_slots)?;
    tbl.set("colliders", stats.colliders)?;
    tbl.set("joints", stats.joints)?;
    tbl.set("jointSlots", stats.joint_slots)?;
    tbl.set("zones", stats.zones)?;
    tbl.set("gravityVectors", stats.gravity_vectors)?;
    tbl.set("sleepingBodies", stats.sleeping_bodies)?;
    tbl.set("skippedSteps", stats.skipped_steps)?;
    tbl.set("clampedSteps", stats.clamped_steps)?;
    tbl.set("invalidOperations", stats.invalid_operations)?;
    tbl.set("bodiesScanned", stats.bodies_scanned)?;
    /// Number of collider shapes rebuilt during the last synchronization pass.
    tbl.set("collidersRebuilt", stats.colliders_rebuilt)?;
    /// Number of zone overlap checks performed by the last simulation step.
    tbl.set("zoneChecks", stats.zone_checks)?;
    /// Number of active contacts reported by the physics world.
    tbl.set("contacts", stats.contacts)?;
    /// Number of body transforms synchronized back to runtime state.
    tbl.set("syncedBodies", stats.synced_bodies)?;
    Ok(tbl)
}

/// Serializes an additive gravity vector into Lua.
fn gravity_vector_to_table<'lua>(
    lua: &'lua Lua,
    vector: crate::physics::GravityVector,
) -> LuaResult<LuaTable<'lua>> {
    // @return table: { id, gx, gy, layerMask, enabled }
    let tbl = lua.create_table()?;
    tbl.set("id", vector.id)?;
    tbl.set("gx", vector.gx)?;
    tbl.set("gy", vector.gy)?;
    tbl.set("layerMask", vector.layer_mask)?;
    tbl.set("enabled", vector.enabled)?;
    Ok(tbl)
}

/// Serializes raw collision event pairs into Lua.
fn collision_events_to_table<'lua>(
    lua: &'lua Lua,
    events: &[BodyContact],
) -> LuaResult<LuaTable<'lua>> {
    // @return table: array of { body_a, body_b } collision event rows.
    let tbl = lua.create_table()?;
    for (i, contact) in events.iter().enumerate() {
        let entry = lua.create_table()?;
        entry.set("body_a", contact.body_a)?;
        entry.set("body_b", contact.body_b)?;
        tbl.set(i + 1, entry)?;
    }
    Ok(tbl)
}

/// Parses optional debug-draw GPU configuration.
fn physics_debug_config_from_lua(
    config_val: LuaValue,
) -> crate::render::renderer::PhysicsDebugConfig {
    let mut cfg = crate::render::renderer::PhysicsDebugConfig::default();
    let LuaValue::Table(tbl) = config_val else {
        return cfg;
    };
    cfg.body_color = physics_debug_color(&tbl, "bodyColor", cfg.body_color);
    cfg.static_color = physics_debug_color(&tbl, "staticColor", cfg.static_color);
    cfg.sleep_color = physics_debug_color(&tbl, "sleepColor", cfg.sleep_color);
    cfg.sensor_color = physics_debug_color(&tbl, "sensorColor", cfg.sensor_color);
    if let Ok(w) = tbl.get::<_, f32>("lineWidth") {
        cfg.line_width = w;
    }
    cfg
}

fn physics_debug_color(tbl: &LuaTable, field: &str, default: [f32; 4]) -> [f32; 4] {
    let Ok(v) = tbl.get::<_, LuaTable>(field) else {
        return default;
    };
    [
        v.get::<_, f32>(1).unwrap_or(default[0]),
        v.get::<_, f32>(2).unwrap_or(default[1]),
        v.get::<_, f32>(3).unwrap_or(default[2]),
        v.get::<_, f32>(4).unwrap_or(default[3]),
    ]
}

fn new_body_from_lua_args(lua: &Lua, args: LuaMultiValue) -> LuaResult<LuaBody> {
    let vals: Vec<LuaValue> = args.into_iter().collect();
    let (world_ud, x, y, w, h, bt) =
        match vals.as_slice() {
            [wud, ax, ay, abt] => (
                LuaAnyUserData::from_lua(wud.clone(), lua)?,
                f32::from_lua(ax.clone(), lua)?,
                f32::from_lua(ay.clone(), lua)?,
                16.0_f32,
                16.0_f32,
                String::from_lua(abt.clone(), lua)?,
            ),
            [wud, ax, ay, aw, ah, abt] => (
                LuaAnyUserData::from_lua(wud.clone(), lua)?,
                f32::from_lua(ax.clone(), lua)?,
                f32::from_lua(ay.clone(), lua)?,
                f32::from_lua(aw.clone(), lua)?,
                f32::from_lua(ah.clone(), lua)?,
                String::from_lua(abt.clone(), lua)?,
            ),
            _ => return Err(LuaError::RuntimeError(
                "lurek.physics.newBody expects (world,x,y,bodyType) or (world,x,y,w,h,bodyType)"
                    .into(),
            )),
        };

    let world = world_ud.borrow::<LuaWorld>()?;
    let body_type = parse_body_type(&bt)?;
    let body = Body::try_new(x, y, w, h, body_type)
        .map_err(|err| physics_runtime_error("newBody", err))?;
    let id = world.world.borrow_mut().add_body(body);
    Ok(LuaBody {
        world: Rc::clone(&world.world),
        id,
    })
}

fn set_body_velocity_from_userdata(body_ud: LuaAnyUserData, vx: f32, vy: f32) -> LuaResult<()> {
    let body = body_ud.borrow::<LuaBody>()?;
    body.world.borrow_mut().set_body_velocity(body.id.0, vx, vy);
    Ok(())
}

fn polygon_shape_from_coords(coords: mlua::Variadic<f32>) -> LuaResult<LuaPhysicsShape> {
    let shape = Shape::from_parts("polygon", coords.as_slice(), false)
        .map_err(|err| physics_runtime_error("newPolygonShape", err))?;
    Ok(LuaPhysicsShape::new(shape))
}

fn chain_shape_from_coords(
    closed: bool,
    coords: mlua::Variadic<f32>,
) -> LuaResult<LuaPhysicsShape> {
    let shape = Shape::from_parts("chain", coords.as_slice(), closed)
        .map_err(|err| physics_runtime_error("newChainShape", err))?;
    Ok(LuaPhysicsShape::new(shape))
}

fn push_physics_debug_draw(
    state: &Rc<RefCell<SharedState>>,
    world: &LuaWorld,
    config_val: LuaValue,
) {
    let shapes: Vec<crate::render::renderer::PhysicsDebugShape> = world
        .world
        .borrow()
        .extract_shape_snapshots()
        .into_iter()
        .map(Into::into)
        .collect();
    let cfg = physics_debug_config_from_lua(config_val);
    state.borrow_mut().render_commands.push(
        crate::render::renderer::RenderCommand::DrawPhysicsDebug {
            shapes,
            config: cfg,
        },
    );
}
/// A physics world that manages rigid bodies, joints, collision detection, and simulation stepping.
/// Created via `lurek.physics.newWorld(gx, gy)` and exposes all world-level operations to Lua.
#[derive(Clone)]
pub struct LuaWorld {
    world: Rc<RefCell<World>>,
    begin_contact_key: Rc<RefCell<Option<LuaRegistryKey>>>,
    end_contact_key: Rc<RefCell<Option<LuaRegistryKey>>>,
    body_data: Rc<RefCell<HashMap<usize, LuaRegistryKey>>>,
}
impl LuaWorld {
    /// World handle. This function is part of the public API.
    pub(crate) fn world_handle(&self) -> Rc<RefCell<World>> {
        self.world.clone()
    }
}

/// Create a Lua body handle by inserting an authored body into an existing world.
pub(crate) fn lua_body_from_body(world: Rc<RefCell<World>>, body: Body) -> LuaBody {
    let id = world.borrow_mut().add_body(body);
    LuaBody { world, id }
}

impl LuaUserData for LuaWorld {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- drawDebug --
        /// Renders a debug visualization of all physics bodies onto a software ImageData target.
        /// @param | target | LImageData | The image to draw debug shapes onto.
        /// @param | r | integer? | Red channel (0-255, default 0).
        /// @param | g | integer? | Green channel (0-255, default 255).
        /// @param | b | integer? | Blue channel (0-255, default 0).
        /// @param | a | integer? | Alpha channel (0-255, default 255).
        methods.add_method(
            "drawDebug",
            |_,
             this,
             (target, r, g, b, a): (
                mlua::AnyUserData,
                Option<u8>,
                Option<u8>,
                Option<u8>,
                Option<u8>,
            )| {
                let mut target_ref = target.borrow_mut::<crate::image::ImageData>()?;
                this.world.borrow().draw_debug_to_image(
                    &mut target_ref,
                    r.unwrap_or(0),
                    g.unwrap_or(255),
                    b.unwrap_or(0),
                    a.unwrap_or(255),
                );
                Ok(())
            },
        );
        // -- step --
        /// Advances the physics simulation by a time delta and fires any registered contact callbacks.
        /// @param | dt | number | Time step in seconds (e.g. 1/60 for 60 FPS).
        methods.add_method("step", |lua, this, dt: f32| {
            this.world.borrow_mut().step(dt);
            let begins: Vec<(usize, usize)> =
                this.world.borrow().get_begin_contact_events().to_vec();
            let ends: Vec<(usize, usize)> = this.world.borrow().get_end_contact_events().to_vec();
            if let Some(key) = &*this.begin_contact_key.borrow() {
                let cb: LuaFunction = lua.registry_value(key)?;
                for (a, b) in begins {
                    cb.call::<_, ()>((a, b))?;
                }
            }
            if let Some(key) = &*this.end_contact_key.borrow() {
                let cb: LuaFunction = lua.registry_value(key)?;
                for (a, b) in ends {
                    cb.call::<_, ()>((a, b))?;
                }
            }
            Ok(())
        });
        // -- clear --
        /// Removes bodies, joints, terrain colliders, and zones while preserving world-level settings.
        /// Gravity, solver iterations, meter scale, and other world configuration remain unchanged.
        methods.add_method("clear", |_, this, ()| {
            this.world.borrow_mut().clear();
            Ok(())
        });
        // -- resetWorld --
        /// Fully resets the world to its post-construction state.
        /// This clears runtime state and restores constructor-owned settings such as gravity and solver configuration.
        methods.add_method("resetWorld", |_, this, ()| {
            this.world.borrow_mut().reset_world();
            Ok(())
        });
        // -- setCollisionPair --
        /// Enables or disables collisions between two world-level collision groups.
        /// @param | groupA | integer | First collision group index, 0..15.
        /// @param | groupB | integer | Second collision group index, 0..15.
        /// @param | enabled | boolean | True to allow collisions, false to block them.
        methods.add_method(
            "setCollisionPair",
            |_, this, (group_a, group_b, enabled): (i64, i64, bool)| {
                let group_a = lua_collision_group("setCollisionPair", group_a)?;
                let group_b = lua_collision_group("setCollisionPair", group_b)?;
                this.world
                    .borrow_mut()
                    .try_set_collision_pair(group_a, group_b, enabled)
                    .map_err(|err| physics_runtime_error("setCollisionPair", err))?;
                Ok(())
            },
        );
        // -- getCollisionPair --
        /// Returns whether collisions are enabled between two world-level collision groups.
        /// @param | groupA | integer | First collision group index, 0..15.
        /// @param | groupB | integer | Second collision group index, 0..15.
        /// @return | boolean | True when the pair is enabled in both matrix directions.
        methods.add_method(
            "getCollisionPair",
            |_, this, (group_a, group_b): (i64, i64)| {
                let group_a = lua_collision_group("getCollisionPair", group_a)?;
                let group_b = lua_collision_group("getCollisionPair", group_b)?;
                this.world
                    .borrow()
                    .try_get_collision_pair(group_a, group_b)
                    .map_err(|err| physics_runtime_error("getCollisionPair", err))
            },
        );
        // -- setCollisionGroupMask --
        /// Replaces one row of the 16-group collision matrix.
        /// @param | group | integer | Source collision group index, 0..15.
        /// @param | mask | integer | Target group bitmask in 0..0xFFFF.
        methods.add_method(
            "setCollisionGroupMask",
            |_, this, (group, mask): (i64, u32)| {
                let group = lua_collision_group("setCollisionGroupMask", group)?;
                let mask = lua_collision_group_mask("setCollisionGroupMask", mask)?;
                this.world
                    .borrow_mut()
                    .try_set_collision_group_mask(group, mask)
                    .map_err(|err| physics_runtime_error("setCollisionGroupMask", err))?;
                Ok(())
            },
        );
        // -- getCollisionGroupMask --
        /// Returns one row of the 16-group collision matrix.
        /// @param | group | integer | Source collision group index, 0..15.
        /// @return | integer | Target group bitmask.
        methods.add_method("getCollisionGroupMask", |_, this, group: i64| {
            let group = lua_collision_group("getCollisionGroupMask", group)?;
            this.world
                .borrow()
                .try_get_collision_group_mask(group)
                .map_err(|err| physics_runtime_error("getCollisionGroupMask", err))
        });
        // -- resetCollisionGroups --
        /// Restores all 16 collision groups so every group can collide with every other group.
        methods.add_method("resetCollisionGroups", |_, this, ()| {
            this.world.borrow_mut().reset_collision_groups();
            Ok(())
        });
        // -- getGravity --
        /// Returns the current world gravity vector.
        /// @return | number | Gravity X component in world units per second squared.
        /// @return | number | Gravity Y component in world units per second squared.
        methods.add_method("getGravity", |_, this, ()| {
            Ok(this.world.borrow().get_gravity())
        });
        // -- setGravity --
        /// Sets the world gravity vector. Affects all dynamic bodies.
        /// @param | gx | number | Horizontal gravity component.
        /// @param | gy | number | Vertical gravity component (positive = down in screen space).
        methods.add_method("setGravity", |_, this, (gx, gy): (f32, f32)| {
            this.world.borrow_mut().set_gravity(gx, gy);
            Ok(())
        });
        // -- addGravityVector --
        /// Adds an extra directional gravity vector that is summed with world gravity when no non-additive zone override is active.
        /// @param | gx | number | Horizontal acceleration in world units per second squared.
        /// @param | gy | number | Vertical acceleration in world units per second squared.
        /// @param | layerMask | integer? | Optional body layer mask, defaults to all layers.
        /// @return | integer | Stable gravity vector ID.
        methods.add_method(
            "addGravityVector",
            |_, this, (gx, gy, layer_mask): (f32, f32, Option<u32>)| {
                let id = this
                    .world
                    .borrow_mut()
                    .try_add_gravity_vector(gx, gy, layer_mask.unwrap_or(u32::MAX))
                    .map_err(|err| physics_runtime_error("addGravityVector", err))?;
                Ok(id)
            },
        );
        // -- setGravityVector --
        /// Replaces the direction, strength, and optional layer mask of an existing additive gravity vector.
        /// @param | id | integer | Gravity vector ID returned by addGravityVector.
        /// @param | gx | number | Horizontal acceleration in world units per second squared.
        /// @param | gy | number | Vertical acceleration in world units per second squared.
        /// @param | layerMask | integer? | Optional body layer mask, defaults to all layers.
        methods.add_method(
            "setGravityVector",
            |_, this, (id, gx, gy, layer_mask): (usize, f32, f32, Option<u32>)| {
                this.world
                    .borrow_mut()
                    .try_set_gravity_vector(id, gx, gy, layer_mask.unwrap_or(u32::MAX))
                    .map_err(|err| physics_runtime_error("setGravityVector", err))?;
                Ok(())
            },
        );
        // -- removeGravityVector --
        /// Removes one additive gravity vector so it no longer affects future steps.
        /// @param | id | integer | Gravity vector ID returned by addGravityVector.
        /// @return | boolean | True if an active vector was removed.
        methods.add_method("removeGravityVector", |_, this, id: usize| {
            Ok(this.world.borrow_mut().remove_gravity_vector(id))
        });
        // -- clearGravityVectors --
        /// Removes all additive gravity vectors from the world.
        methods.add_method("clearGravityVectors", |_, this, ()| {
            this.world.borrow_mut().clear_gravity_vectors();
            Ok(())
        });
        // -- getGravityVector --
        /// Returns an additive gravity vector by ID, or nil when no active vector exists.
        /// @param | id | integer | Gravity vector ID returned by addGravityVector.
        /// @return | table? | Table with id, gx, gy, layerMask, and enabled fields.
        methods.add_method("getGravityVector", |lua, this, id: usize| {
            match this.world.borrow().get_gravity_vector(id) {
                Some(vector) => Ok(Some(gravity_vector_to_table(lua, vector)?)),
                None => Ok(None),
            }
        });
        // -- setMeter --
        /// Sets the pixels-per-meter scale used to convert between pixel coordinates and physics units.
        /// @param | ppm | number | Pixels per meter (e.g. 64 means 64 px = 1 meter in physics).
        methods.add_method("setMeter", |_, this, ppm: f32| {
            this.world.borrow_mut().set_meter(ppm);
            Ok(())
        });
        // -- getMeter --
        /// Returns the current pixels-per-meter scale.
        /// @return | number | Pixels per meter.
        methods.add_method("getMeter", |_, this, ()| {
            Ok(this.world.borrow().get_meter())
        });
        // -- toPhysics --
        /// Converts a pixel measurement to physics-world meters using the current meter scale.
        /// @param | px | number | Value in pixels.
        /// @return | number | Equivalent value in physics meters.
        methods.add_method("toPhysics", |_, this, px: f32| {
            Ok(this.world.borrow().to_physics(px))
        });
        // -- toPixels --
        /// Converts a physics-world meter measurement to pixels using the current meter scale.
        /// @param | m | number | Value in physics meters.
        /// @return | number | Equivalent value in pixels.
        methods.add_method("toPixels", |_, this, m: f32| {
            Ok(this.world.borrow().to_pixels(m))
        });
        // -- getBodyCount --
        /// Returns the total number of active bodies in the world.
        /// @return | integer | Body count.
        methods.add_method("getBodyCount", |_, this, ()| {
            Ok(this.world.borrow().body_count())
        });
        // -- hasBody --
        /// Returns true when a body ID still refers to a live body slot.
        /// @param | id | integer | Body ID to check.
        /// @return | boolean | True if the body is active.
        methods.add_method("hasBody", |_, this, id: usize| {
            Ok(this.world.borrow().has_body(id))
        });
        // -- getBodyIds --
        /// Returns a sequential table of all body IDs currently in the world.
        /// @return | integer[] | Body ID numbers.
        methods.add_method("getBodyIds", |_, this, ()| {
            Ok(this.world.borrow().get_body_ids())
        });
        // -- hasJoint --
        /// Returns true when a joint ID still refers to a live joint slot.
        /// @param | id | integer | Joint ID to check.
        /// @return | boolean | True if the joint is active.
        methods.add_method("hasJoint", |_, this, id: usize| {
            Ok(this.world.borrow().has_joint(id))
        });
        // -- getStats --
        /// Returns active counts and slot diagnostics for the world.
        /// @return | table | Stats table with bodies, bodySlots, colliders, joints, jointSlots, zones, gravityVectors, sleepingBodies.
        /// @field | bodies | integer | Number of active body slots.
        /// @field | bodySlots | integer | Total allocated body slots, including inactive tombstones.
        /// @field | colliders | integer | Number of active Rapier colliders.
        /// @field | joints | integer | Number of active joint slots.
        /// @field | jointSlots | integer | Total allocated joint slots, including inactive tombstones.
        /// @field | zones | integer | Number of active physics zones.
        /// @field | gravityVectors | integer | Number of active additive gravity vectors.
        /// @field | sleepingBodies | integer | Number of active bodies currently sleeping.
        methods.add_method("getStats", |lua, this, ()| {
            let stats = this.world.borrow().get_stats();
            stats_to_table(lua, stats)
        });
        // -- destroyBody --
        /// Removes a body from the world by its ID, along with all attached fixtures and joints.
        /// @param | id | integer | The body ID to destroy.
        methods.add_method("destroyBody", |_, this, id: usize| {
            this.world.borrow_mut().destroy_body(id);
            Ok(())
        });
        // -- newBody --
        /// Creates a new physics body at the given position with the specified type and dimensions.
        /// @param | x | number | Initial X position in world coordinates.
        /// @param | y | number | Initial Y position in world coordinates.
        /// @param | bodyType | string | One of "static", "dynamic", "kinematic", or "sensor".
        /// @return | LBody | The newly created body handle.
        methods.add_method("newBody", |lua, this, args: LuaMultiValue| {
            let vals: Vec<LuaValue> = args.into_iter().collect();
            let (x, y, w, h, bt) = match vals.as_slice() {
                // Legacy form: world:newBody(x, y, bodyType)
                [ax, ay, abt] => (
                    f32::from_lua(ax.clone(), lua)?,
                    f32::from_lua(ay.clone(), lua)?,
                    16.0_f32,
                    16.0_f32,
                    String::from_lua(abt.clone(), lua)?,
                ),
                // Full form: world:newBody(x, y, w, h, bodyType)
                [ax, ay, aw, ah, abt] => (
                    f32::from_lua(ax.clone(), lua)?,
                    f32::from_lua(ay.clone(), lua)?,
                    f32::from_lua(aw.clone(), lua)?,
                    f32::from_lua(ah.clone(), lua)?,
                    String::from_lua(abt.clone(), lua)?,
                ),
                _ => {
                    return Err(LuaError::RuntimeError(
                        "LWorld:newBody expects (x,y,bodyType) or (x,y,w,h,bodyType)".into(),
                    ))
                }
            };
            let body_type = parse_body_type(&bt)?;
            let body = Body::try_new(x, y, w, h, body_type)
                .map_err(|err| physics_runtime_error("newBody", err))?;
            let id = this.world.borrow_mut().add_body(body);
            Ok(LuaBody {
                world: Rc::clone(&this.world),
                id,
            })
        });
        // -- newCircleBody --
        /// Creates a new body with a circle collider already attached.
        /// @param | x | number | Initial X position in world coordinates.
        /// @param | y | number | Initial Y position in world coordinates.
        /// @param | radius | number | Circle radius in world units.
        /// @param | bodyType | string | One of "static", "dynamic", "kinematic", or "sensor".
        /// @return | LBody | The newly created body handle.
        methods.add_method(
            "newCircleBody",
            |_, this, (x, y, radius, bt): (f32, f32, f32, String)| {
                let body_type = parse_body_type(&bt)?;
                let body = Body::try_new_circle(x, y, radius, body_type)
                    .map_err(|err| physics_runtime_error("newCircleBody", err))?;
                let id = this.world.borrow_mut().add_body(body);
                Ok(LuaBody {
                    world: Rc::clone(&this.world),
                    id,
                })
            },
        );
        // -- newPolygonBody --
        /// Creates a new body with a convex polygon collider defined by vertex pairs.
        /// @param | x | number | Initial X position in world coordinates.
        /// @param | y | number | Initial Y position in world coordinates.
        /// @param | vertices | table | Flat array of vertex coordinates {x1,y1,x2,y2,...}.
        /// @param | bodyType | string | One of "static", "dynamic", "kinematic", or "sensor".
        /// @return | LBody | The newly created body handle.
        methods.add_method(
            "newPolygonBody",
            |_, this, (x, y, tbl, bt): (f32, f32, LuaTable, String)| {
                let body_type = parse_body_type(&bt)?;
                let mut verts = Vec::new();
                let len = tbl.raw_len();
                let mut i = 1;
                while i < len {
                    let vx: f32 = tbl.raw_get(i)?;
                    let vy: f32 = tbl.raw_get(i + 1)?;
                    verts.push(Vec2::new(vx, vy));
                    i += 2;
                }
                let body = Body::try_new_polygon(x, y, verts, body_type)
                    .map_err(|err| physics_runtime_error("newPolygonBody", err))?;
                let id = this.world.borrow_mut().add_body(body);
                Ok(LuaBody {
                    world: Rc::clone(&this.world),
                    id,
                })
            },
        );
        // -- newEdgeBody --
        /// Creates a new body with an edge (line segment) collider between two local points.
        /// @param | x | number | Body X position in world coordinates.
        /// @param | y | number | Body Y position in world coordinates.
        /// @param | x1 | number | Edge start X relative to body.
        /// @param | y1 | number | Edge start Y relative to body.
        /// @param | x2 | number | Edge end X relative to body.
        /// @param | y2 | number | Edge end Y relative to body.
        /// @param | bodyType | string | One of "static", "dynamic", "kinematic", or "sensor".
        /// @return | LBody | The newly created body handle.
        #[allow(clippy::too_many_arguments)]
        methods.add_method(
            "newEdgeBody",
            |_, this, (x, y, x1, y1, x2, y2, bt): (f32, f32, f32, f32, f32, f32, String)| {
                let body_type = parse_body_type(&bt)?;
                let body =
                    Body::try_new_edge(x, y, Vec2::new(x1, y1), Vec2::new(x2, y2), body_type)
                        .map_err(|err| physics_runtime_error("newEdgeBody", err))?;
                let id = this.world.borrow_mut().add_body(body);
                Ok(LuaBody {
                    world: Rc::clone(&this.world),
                    id,
                })
            },
        );
        // -- newChainBody --
        /// Creates a new body with a chain (polyline) collider. Useful for terrain edges.
        /// @param | x | number | Body X position in world coordinates.
        /// @param | y | number | Body Y position in world coordinates.
        /// @param | vertices | table | Flat array of vertex coordinates {x1,y1,x2,y2,...}.
        /// @param | closed | boolean | If true, connects the last vertex back to the first.
        /// @param | bodyType | string | One of "static", "dynamic", "kinematic", or "sensor".
        /// @return | LBody | The newly created body handle.
        methods.add_method(
            "newChainBody",
            |_, this, (x, y, tbl, closed, bt): (f32, f32, LuaTable, bool, String)| {
                let body_type = parse_body_type(&bt)?;
                let mut verts = Vec::new();
                let len = tbl.raw_len();
                let mut i = 1;
                while i < len {
                    let vx: f32 = tbl.raw_get(i)?;
                    let vy: f32 = tbl.raw_get(i + 1)?;
                    verts.push(Vec2::new(vx, vy));
                    i += 2;
                }
                let body = Body::try_new_chain(x, y, verts, closed, body_type)
                    .map_err(|err| physics_runtime_error("newChainBody", err))?;
                let id = this.world.borrow_mut().add_body(body);
                Ok(LuaBody {
                    world: Rc::clone(&this.world),
                    id,
                })
            },
        );
        // -- addFixture --
        /// Attaches a new collider shape to an existing body with material properties.
        /// @param | bodyId | number | The target body ID.
        /// @param | shapeType | string | Shape kind: "circle", "rectangle", "polygon", "edge", or "chain".
        /// @param | density | number | Mass density (affects dynamic body mass calculation).
        /// @param | friction | number | Surface friction coefficient (0 = ice, 1 = rubber).
        /// @param | restitution | number | Bounciness (0 = no bounce, 1 = perfectly elastic).
        /// @param | sensor | boolean | If true, detects overlaps without generating collision response.
        /// @param | ... | number | Shape-specific size arguments (radius, width/height, or vertex list).
        /// @return | integer | The fixture index on the body.
        methods.add_method(
            "addFixture",
            |lua,
             this,
             (body_id, shape_type, density, friction, restitution, sensor, args): (
                usize,
                String,
                f32,
                f32,
                f32,
                bool,
                LuaMultiValue,
            )| {
                let shape = shape_from_lua(lua, &shape_type, args)?;
                let idx = this
                    .world
                    .borrow_mut()
                    .try_add_fixture(body_id, shape, density, friction, restitution, sensor)
                    .map_err(|err| physics_runtime_error("addFixture", err))?;
                Ok(idx)
            },
        );
        // -- fixtureCount --
        /// Returns how many fixtures (colliders) are attached to a body.
        /// @param | bodyId | integer | The body to query.
        /// @return | integer | Number of attached fixtures.
        methods.add_method("fixtureCount", |_, this, body_id: usize| {
            Ok(this.world.borrow().fixture_count(body_id))
        });
        // -- setFixtureFriction --
        /// Updates the friction coefficient of a specific fixture on a body.
        /// @param | bodyId | integer | The body ID.
        /// @param | fixtureIndex | integer | Zero-based fixture index on the body.
        /// @param | friction | number | New friction value (0Ä‚ËĂ˘â€šÂ¬Ă˘â‚¬Ĺ›1 typical range).
        methods.add_method(
            "setFixtureFriction",
            |_, this, (body_id, fix_idx, friction): (usize, usize, f32)| {
                this.world
                    .borrow_mut()
                    .try_set_fixture_friction(body_id, fix_idx, friction)
                    .map_err(|err| physics_runtime_error("setFixtureFriction", err))?;
                Ok(())
            },
        );
        // -- setFixtureRestitution --
        /// Updates the restitution (bounciness) of a specific fixture on a body.
        /// @param | bodyId | integer | The body ID.
        /// @param | fixtureIndex | integer | Zero-based fixture index on the body.
        /// @param | restitution | number | New restitution value (0 = no bounce, 1 = full bounce).
        methods.add_method(
            "setFixtureRestitution",
            |_, this, (body_id, fix_idx, restitution): (usize, usize, f32)| {
                this.world
                    .borrow_mut()
                    .try_set_fixture_restitution(body_id, fix_idx, restitution)
                    .map_err(|err| physics_runtime_error("setFixtureRestitution", err))?;
                Ok(())
            },
        );
        // -- setFixtureSensor --
        /// Toggles whether a fixture acts as a sensor (overlap detection only, no physical response).
        /// @param | bodyId | integer | The body ID.
        /// @param | fixtureIndex | integer | Zero-based fixture index on the body.
        /// @param | sensor | boolean | True to make it a sensor, false for solid collision.
        methods.add_method(
            "setFixtureSensor",
            |_, this, (body_id, fix_idx, sensor): (usize, usize, bool)| {
                this.world
                    .borrow_mut()
                    .try_set_fixture_sensor(body_id, fix_idx, sensor)
                    .map_err(|err| physics_runtime_error("setFixtureSensor", err))?;
                Ok(())
            },
        );
        // -- addRevoluteJoint --
        /// Creates a revolute (hinge) joint connecting two bodies at an anchor point. Bodies can rotate freely around the anchor.
        /// @param | bodyA | integer | First body ID.
        /// @param | bodyB | integer | Second body ID.
        /// @param | anchorX | number | Anchor X in world coordinates.
        /// @param | anchorY | number | Anchor Y in world coordinates.
        /// @return | integer | The joint ID.
        methods.add_method(
            "addRevoluteJoint",
            |_, this, (a, b, ax, ay): (usize, usize, f32, f32)| {
                this.world
                    .borrow_mut()
                    .try_add_revolute_joint(a, b, ax, ay)
                    .map_err(|err| physics_runtime_error("addRevoluteJoint", err))
            },
        );
        // -- addDistanceJoint --
        /// Creates a distance joint that keeps two bodies at a fixed distance apart, like a rigid rod.
        /// @param | bodyA | integer | First body ID.
        /// @param | bodyB | integer | Second body ID.
        /// @param | anchorAX | number | Local anchor X on body A.
        /// @param | anchorAY | number | Local anchor Y on body A.
        /// @param | anchorBX | number | Local anchor X on body B.
        /// @param | anchorBY | number | Local anchor Y on body B.
        /// @param | length | number | Target distance between anchors.
        /// @return | integer | The joint ID.
        #[allow(clippy::too_many_arguments)]
        methods.add_method(
            "addDistanceJoint",
            |_, this, (a, b, ax1, ay1, ax2, ay2, len): (usize, usize, f32, f32, f32, f32, f32)| {
                this.world
                    .borrow_mut()
                    .try_add_distance_joint(a, b, ax1, ay1, ax2, ay2, len)
                    .map_err(|err| physics_runtime_error("addDistanceJoint", err))
            },
        );
        // -- addPrismaticJoint --
        /// Creates a prismatic (slider) joint that constrains body B to move along an axis relative to body A.
        /// @param | bodyA | integer | First body ID.
        /// @param | bodyB | integer | Second body ID.
        /// @param | anchorX | number | Anchor X in world coordinates.
        /// @param | anchorY | number | Anchor Y in world coordinates.
        /// @param | axisX | number | Slide axis X direction.
        /// @param | axisY | number | Slide axis Y direction.
        /// @return | integer | The joint ID.
        methods.add_method(
            "addPrismaticJoint",
            |_, this, (a, b, ax, ay, axis_x, axis_y): (usize, usize, f32, f32, f32, f32)| {
                this.world
                    .borrow_mut()
                    .try_add_prismatic_joint(a, b, ax, ay, axis_x, axis_y)
                    .map_err(|err| physics_runtime_error("addPrismaticJoint", err))
            },
        );
        // -- addWeldJoint --
        /// Creates a weld joint that rigidly connects two bodies at an anchor point (no relative movement).
        /// @param | bodyA | integer | First body ID.
        /// @param | bodyB | integer | Second body ID.
        /// @param | anchorX | number | Anchor X in world coordinates.
        /// @param | anchorY | number | Anchor Y in world coordinates.
        /// @return | integer | The joint ID.
        methods.add_method(
            "addWeldJoint",
            |_, this, (a, b, ax, ay): (usize, usize, f32, f32)| {
                this.world
                    .borrow_mut()
                    .try_add_weld_joint(a, b, ax, ay)
                    .map_err(|err| physics_runtime_error("addWeldJoint", err))
            },
        );
        // -- addRopeJoint --
        /// Creates a rope joint limiting the maximum distance between two anchor points on two bodies.
        /// @param | bodyA | integer | First body ID.
        /// @param | bodyB | integer | Second body ID.
        /// @param | anchorAX | number | Local anchor X on body A.
        /// @param | anchorAY | number | Local anchor Y on body A.
        /// @param | anchorBX | number | Local anchor X on body B.
        /// @param | anchorBY | number | Local anchor Y on body B.
        /// @param | maxLength | number | Maximum allowed distance between anchors.
        /// @return | integer | The joint ID.
        #[allow(clippy::too_many_arguments)]
        methods.add_method(
            "addRopeJoint",
            |_, this, (a, b, ax1, ay1, ax2, ay2, max): (usize, usize, f32, f32, f32, f32, f32)| {
                this.world
                    .borrow_mut()
                    .try_add_rope_joint(a, b, ax1, ay1, ax2, ay2, max)
                    .map_err(|err| physics_runtime_error("addRopeJoint", err))
            },
        );
        // -- addWheelJoint --
        /// Creates a wheel joint simulating a suspension: allows rotation and linear movement along an axis.
        /// @param | bodyA | integer | First body ID (chassis).
        /// @param | bodyB | integer | Second body ID (wheel).
        /// @param | anchorX | number | Anchor X in world coordinates.
        /// @param | anchorY | number | Anchor Y in world coordinates.
        /// @param | axisX | number | Suspension axis X direction.
        /// @param | axisY | number | Suspension axis Y direction.
        /// @return | integer | The joint ID.
        methods.add_method(
            "addWheelJoint",
            |_, this, (a, b, ax, ay, axis_x, axis_y): (usize, usize, f32, f32, f32, f32)| {
                this.world
                    .borrow_mut()
                    .try_add_wheel_joint(a, b, ax, ay, axis_x, axis_y)
                    .map_err(|err| physics_runtime_error("addWheelJoint", err))
            },
        );
        // -- addFrictionJoint --
        /// Creates a friction joint that applies resistance to relative motion between two bodies.
        /// @param | bodyA | integer | First body ID.
        /// @param | bodyB | integer | Second body ID.
        /// @param | anchorX | number | Anchor X in world coordinates.
        /// @param | anchorY | number | Anchor Y in world coordinates.
        /// @param | maxForce | number | Maximum friction force.
        /// @param | maxTorque | number | Maximum friction torque.
        /// @return | integer | The joint ID.
        methods.add_method(
            "addFrictionJoint",
            |_, this, (a, b, ax, ay, max_f, max_t): (usize, usize, f32, f32, f32, f32)| {
                this.world
                    .borrow_mut()
                    .try_add_friction_joint(a, b, ax, ay, max_f, max_t)
                    .map_err(|err| physics_runtime_error("addFrictionJoint", err))
            },
        );
        // -- addMotorJoint --
        /// Creates a motor joint that drives body B toward a target offset from body A using a correction factor.
        /// @param | bodyA | integer | First body ID.
        /// @param | bodyB | integer | Second body ID.
        /// @param | factor | number | Correction factor (0Ä‚ËĂ˘â€šÂ¬Ă˘â‚¬Ĺ›1), higher = faster convergence.
        /// @return | integer | The joint ID.
        methods.add_method(
            "addMotorJoint",
            |_, this, (a, b, factor): (usize, usize, f32)| {
                this.world
                    .borrow_mut()
                    .try_add_motor_joint(a, b, factor)
                    .map_err(|err| physics_runtime_error("addMotorJoint", err))
            },
        );
        // -- addMouseJoint --
        /// Creates a mouse joint that pulls a body toward a world target point with spring-like force.
        /// @param | bodyId | integer | The body to pull.
        /// @param | targetX | number | Initial target X in world coordinates.
        /// @param | targetY | number | Initial target Y in world coordinates.
        /// @param | maxForce | number | Maximum force applied to reach the target.
        /// @return | integer | The joint ID.
        methods.add_method(
            "addMouseJoint",
            |_, this, (body_id, tx, ty, max_f): (usize, f32, f32, f32)| {
                this.world
                    .borrow_mut()
                    .try_add_mouse_joint(body_id, tx, ty, max_f)
                    .map_err(|err| physics_runtime_error("addMouseJoint", err))
            },
        );
        // -- addPulleyJoint --
        /// Creates a pulley joint connecting two bodies so that movement of one affects the other inversely.
        /// @param | bodyA | integer | First body ID.
        /// @param | bodyB | integer | Second body ID.
        /// @param | anchorX | number | Shared anchor X.
        /// @param | anchorY | number | Shared anchor Y.
        /// @return | integer | The joint ID.
        methods.add_method(
            "addPulleyJoint",
            |_, this, (a, b, ax, ay): (usize, usize, f32, f32)| {
                this.world
                    .borrow_mut()
                    .try_add_weld_joint(a, b, ax, ay)
                    .map_err(|err| physics_runtime_error("addPulleyJoint", err))
            },
        );
        // -- addGearJoint --
        /// Creates a gear joint that synchronizes rotation between two bodies at an anchor.
        /// @param | bodyA | integer | First body ID.
        /// @param | bodyB | integer | Second body ID.
        /// @param | anchorX | number | Gear anchor X.
        /// @param | anchorY | number | Gear anchor Y.
        /// @return | integer | The joint ID.
        methods.add_method(
            "addGearJoint",
            |_, this, (a, b, ax, ay): (usize, usize, f32, f32)| {
                this.world
                    .borrow_mut()
                    .try_add_weld_joint(a, b, ax, ay)
                    .map_err(|err| physics_runtime_error("addGearJoint", err))
            },
        );
        // -- jointCount --
        /// Returns the total number of joints in the world.
        /// @return | integer | Joint count.
        methods.add_method("jointCount", |_, this, ()| {
            Ok(this.world.borrow().joint_count())
        });
        // -- getJointIds --
        /// Returns a sequential table of all joint IDs currently in the world.
        /// @return | integer[] | Joint ID numbers.
        methods.add_method("getJointIds", |_, this, ()| {
            Ok(this.world.borrow().get_joint_ids())
        });
        // -- getJointBodies --
        /// Returns the two body IDs connected by a joint.
        /// @param | jointId | integer | The joint ID to query.
        /// @return | integer | Body A ID.
        /// @return | integer | Body B ID.
        methods.add_method("getJointBodies", |_, this, jid: usize| {
            match this.world.borrow().get_joint_bodies(jid) {
                Some((a, b)) => Ok((a, b)),
                None => Err(LuaError::external(format!("invalid joint id: {}", jid))),
            }
        });
        // -- destroyJoint --
        /// Removes a joint from the world, disconnecting the two bodies it linked.
        /// @param | jointId | integer | The joint ID to destroy.
        methods.add_method("destroyJoint", |_, this, jid: usize| {
            this.world.borrow_mut().destroy_joint(jid);
            Ok(())
        });
        // -- getJointType --
        /// Returns the type name of a joint (e.g. "revolute", "distance", "prismatic").
        /// @param | jointId | integer | The joint ID.
        /// @return | string | The joint type name.
        methods.add_method("getJointType", |_, this, jid: usize| {
            Ok(this.world.borrow().get_joint_type(jid).to_string())
        });
        // -- setJointMotorSpeed --
        /// Sets the motor speed on a motorized joint (revolute or prismatic).
        /// @param | jointId | integer | The joint ID.
        /// @param | speed | number | Desired motor speed (radians/sec for revolute, meters/sec for prismatic).
        methods.add_method(
            "setJointMotorSpeed",
            |_, this, (jid, speed): (usize, f32)| {
                let mut world = this.world.borrow_mut();
                if !world.has_joint(jid) {
                    return Err(physics_runtime_error(
                        "setJointMotorSpeed",
                        format!("invalid joint id {}", jid),
                    ));
                }
                world.set_joint_motor_speed(jid, speed);
                Ok(())
            },
        );
        // -- getJointMotorSpeed --
        /// Returns the current motor speed setting of a joint.
        /// @param | jointId | integer | The joint ID.
        /// @return | number | Motor speed value.
        methods.add_method("getJointMotorSpeed", |_, this, jid: usize| {
            Ok(this.world.borrow().get_joint_motor_speed(jid))
        });
        // -- setJointLimitsEnabled --
        /// Enables or disables angular/linear limits on a joint.
        /// @param | jointId | integer | The joint ID.
        /// @param | enabled | boolean | True to enforce limits, false to allow free movement.
        methods.add_method(
            "setJointLimitsEnabled",
            |_, this, (jid, enabled): (usize, bool)| {
                let mut world = this.world.borrow_mut();
                if !world.has_joint(jid) {
                    return Err(physics_runtime_error(
                        "setJointLimitsEnabled",
                        format!("invalid joint id {}", jid),
                    ));
                }
                world.set_joint_limits_enabled(jid, enabled);
                Ok(())
            },
        );
        // -- setJointLimits --
        /// Sets the lower and upper bounds for a joint's limited range of motion.
        /// @param | jointId | integer | The joint ID.
        /// @param | lower | number | Lower limit (radians or meters depending on joint type).
        /// @param | upper | number | Upper limit.
        methods.add_method(
            "setJointLimits",
            |_, this, (jid, lower, upper): (usize, f32, f32)| {
                let mut world = this.world.borrow_mut();
                if !world.has_joint(jid) {
                    return Err(physics_runtime_error(
                        "setJointLimits",
                        format!("invalid joint id {}", jid),
                    ));
                }
                world.set_joint_limits(jid, lower, upper);
                Ok(())
            },
        );
        // -- getJointLimits --
        /// Returns the lower and upper limit values for a joint.
        /// @param | jointId | integer | The joint ID.
        /// @return | number | Lower limit.
        /// @return | number | Upper limit.
        methods.add_method("getJointLimits", |_, this, jid: usize| {
            Ok(this.world.borrow().get_joint_limits(jid))
        });
        // -- setMouseJointTarget --
        /// Moves the target position of a mouse joint, causing the attached body to follow.
        /// @param | jointId | integer | The mouse joint ID.
        /// @param | x | number | New target X in world coordinates.
        /// @param | y | number | New target Y in world coordinates.
        methods.add_method(
            "setMouseJointTarget",
            |_, this, (jid, x, y): (usize, f32, f32)| {
                let mut world = this.world.borrow_mut();
                if !world.has_joint(jid) {
                    return Err(physics_runtime_error(
                        "setMouseJointTarget",
                        format!("invalid joint id {}", jid),
                    ));
                }
                world.set_mouse_joint_target(jid, x, y);
                Ok(())
            },
        );
        // -- raycast --
        /// Casts a ray from point (x1,y1) to (x2,y2) and returns the first body hit, or nil.
        /// @param | x1 | number | Ray origin X.
        /// @param | y1 | number | Ray origin Y.
        /// @param | x2 | number | Ray end X.
        /// @param | y2 | number | Ray end Y.
        /// @param | filter | table? | Optional query filter: {layer?, mask?, group?, groups?, includeSensors?}.
        /// @return | table | Hit info {bodyId, x, y, normalX, normalY, toi} or nil if no hit.
        /// @field | bodyId | integer | BodyId.
        /// @field | x | number | X.
        /// @field | y | number | Y.
        /// @field | normalX | number | NormalX.
        /// @field | normalY | number | NormalY.
        /// @field | toi | number | Toi.
        methods.add_method("raycast", |lua, this, args: LuaMultiValue| {
            let vals: Vec<LuaValue> = args.into_iter().collect();
            let x1 = required_f32(lua, &vals, 0, "x1")?;
            let y1 = required_f32(lua, &vals, 1, "y1")?;
            let x2 = required_f32(lua, &vals, 2, "x2")?;
            let y2 = required_f32(lua, &vals, 3, "y2")?;
            let filter = query_filter_from_lua("raycast", vals.get(4).cloned())?;
            match this.world.borrow().raycast_filtered(x1, y1, x2, y2, filter) {
                Some(hit) => Ok(LuaValue::Table(raycast_hit_to_table(lua, &hit)?)),
                None => Ok(LuaValue::Nil),
            }
        });
        // -- raycastClosest --
        /// Casts a directional ray from a point and returns the closest hit within max distance.
        /// @param | x | number | Ray origin X.
        /// @param | y | number | Ray origin Y.
        /// @param | dx | number | Ray direction X (does not need to be normalized).
        /// @param | dy | number | Ray direction Y.
        /// @param | maxDist | number | Maximum ray travel distance.
        /// @param | filter | table? | Optional query filter: {layer?, mask?, group?, groups?, includeSensors?}.
        /// @return | table | Hit info {bodyId, x, y, normalX, normalY, toi} or nil if no hit.
        /// @field | bodyId | integer | BodyId.
        /// @field | x | number | X.
        /// @field | y | number | Y.
        /// @field | normalX | number | NormalX.
        /// @field | normalY | number | NormalY.
        /// @field | toi | number | Toi.
        methods.add_method("raycastClosest", |lua, this, args: LuaMultiValue| {
            let vals: Vec<LuaValue> = args.into_iter().collect();
            let x1 = required_f32(lua, &vals, 0, "x")?;
            let y1 = required_f32(lua, &vals, 1, "y")?;
            let dx = required_f32(lua, &vals, 2, "dx")?;
            let dy = required_f32(lua, &vals, 3, "dy")?;
            let max_dist = required_f32(lua, &vals, 4, "maxDist")?;
            let filter = query_filter_from_lua("raycastClosest", vals.get(5).cloned())?;
            match this
                .world
                .borrow()
                .raycast_closest_filtered(x1, y1, dx, dy, max_dist, filter)
            {
                Some(hit) => Ok(LuaValue::Table(raycast_hit_to_table(lua, &hit)?)),
                None => Ok(LuaValue::Nil),
            }
        });
        // -- raycastAll --
        /// Casts a directional ray and returns all bodies hit within max distance as a table of results.
        /// @param | x | number | Ray origin X.
        /// @param | y | number | Ray origin Y.
        /// @param | dx | number | Ray direction X.
        /// @param | dy | number | Ray direction Y.
        /// @param | maxDist | number | Maximum ray travel distance.
        /// @param | filter | table? | Optional query filter: {layer?, mask?, group?, groups?, includeSensors?}.
        /// @return | table | Array of hit tables {bodyId, x, y, normalX, normalY, toi}.
        /// @field | bodyId | integer | BodyId.
        /// @field | x | number | X.
        /// @field | y | number | Y.
        /// @field | normalX | number | NormalX.
        /// @field | normalY | number | NormalY.
        /// @field | toi | number | Toi.
        methods.add_method("raycastAll", |lua, this, args: LuaMultiValue| {
            let vals: Vec<LuaValue> = args.into_iter().collect();
            let x1 = required_f32(lua, &vals, 0, "x")?;
            let y1 = required_f32(lua, &vals, 1, "y")?;
            let dx = required_f32(lua, &vals, 2, "dx")?;
            let dy = required_f32(lua, &vals, 3, "dy")?;
            let max_dist = required_f32(lua, &vals, 4, "maxDist")?;
            let filter = query_filter_from_lua("raycastAll", vals.get(5).cloned())?;
            let hits = this
                .world
                .borrow()
                .raycast_all_filtered(x1, y1, dx, dy, max_dist, filter);
            let result = lua.create_table()?;
            for (i, hit) in hits.iter().enumerate() {
                result.set(i + 1, raycast_hit_to_table(lua, hit)?)?;
            }
            Ok(result)
        });
        // -- queryAABB --
        /// Returns all body IDs whose axis-aligned bounding boxes overlap the given rectangle.
        /// @param | x | number | Query rectangle left X.
        /// @param | y | number | Query rectangle top Y.
        /// @param | w | number | Query rectangle width.
        /// @param | h | number | Query rectangle height.
        /// @param | filter | table? | Optional query filter: {layer?, mask?, group?, groups?, includeSensors?}.
        /// @return | integer[] | Body ID numbers found in the region.
        methods.add_method("queryAABB", |lua, this, args: LuaMultiValue| {
            let vals: Vec<LuaValue> = args.into_iter().collect();
            let x = required_f32(lua, &vals, 0, "x")?;
            let y = required_f32(lua, &vals, 1, "y")?;
            let w = required_f32(lua, &vals, 2, "w")?;
            let h = required_f32(lua, &vals, 3, "h")?;
            let filter = query_filter_from_lua("queryAABB", vals.get(4).cloned())?;
            Ok(this.world.borrow().query_aabb_filtered(x, y, w, h, filter))
        });
        // -- getBodyAtPoint --
        /// Returns the body ID at a specific world point, or nil if no body is there.
        /// @param | x | number | Query point X.
        /// @param | y | number | Query point Y.
        /// @param | filter | table? | Optional query filter: {layer?, mask?, group?, groups?, includeSensors?}.
        /// @return | integer | Body ID at the point, or nil.
        methods.add_method("getBodyAtPoint", |lua, this, args: LuaMultiValue| {
            let vals: Vec<LuaValue> = args.into_iter().collect();
            let x = required_f32(lua, &vals, 0, "x")?;
            let y = required_f32(lua, &vals, 1, "y")?;
            let filter = query_filter_from_lua("getBodyAtPoint", vals.get(2).cloned())?;
            Ok(this.world.borrow().get_body_at_point_filtered(x, y, filter))
        });
        // -- getCollisionEvents --
        /// Returns all collision events from the last step as a table of {bodyA, bodyB} pairs.
        /// @return | table | Array of collision event tables.
        /// @field | bodyA | integer | Body A id.
        /// @field | bodyB | integer | Body B id.
        methods.add_method("getCollisionEvents", |lua, this, ()| {
            let w = this.world.borrow();
            let events = w.get_collision_events();
            let result = lua.create_table()?;
            for (i, evt) in events.iter().enumerate() {
                let tbl = lua.create_table()?;
                tbl.set("bodyA", evt.body_a)?;
                tbl.set("bodyB", evt.body_b)?;
                result.set(i + 1, tbl)?;
            }
            Ok(result)
        });
        // -- getBeginContactEvents --
        /// Returns contact-begin events from the last step (pairs of bodies that started touching).
        /// @return | table | Array of {bodyA, bodyB} tables.
        /// @field | bodyA | integer | BodyA.
        /// @field | bodyB | integer | BodyB.
        methods.add_method("getBeginContactEvents", |lua, this, ()| {
            let w = this.world.borrow();
            let events = w.get_begin_contact_events();
            let result = lua.create_table()?;
            for (i, (a, b)) in events.iter().enumerate() {
                let tbl = lua.create_table()?;
                tbl.set("bodyA", *a)?;
                tbl.set("bodyB", *b)?;
                result.set(i + 1, tbl)?;
            }
            Ok(result)
        });
        // -- getEndContactEvents --
        /// Returns contact-end events from the last step (pairs of bodies that stopped touching).
        /// @return | table | Array of {bodyA, bodyB} tables.
        /// @field | bodyA | integer | BodyA.
        /// @field | bodyB | integer | BodyB.
        methods.add_method("getEndContactEvents", |lua, this, ()| {
            let w = this.world.borrow();
            let events = w.get_end_contact_events();
            let result = lua.create_table()?;
            for (i, (a, b)) in events.iter().enumerate() {
                let tbl = lua.create_table()?;
                tbl.set("bodyA", *a)?;
                tbl.set("bodyB", *b)?;
                result.set(i + 1, tbl)?;
            }
            Ok(result)
        });
        // -- getContacts --
        /// Returns all currently active contact manifolds with normals and touching state.
        /// @return | table | Array of {bodyA, bodyB, normalX, normalY, isTouching} tables.
        /// @field | bodyA | integer | BodyA.
        /// @field | bodyB | integer | BodyB.
        /// @field | normalX | number | NormalX.
        /// @field | normalY | number | NormalY.
        /// @field | isTouching | boolean | True while the bodies are currently touching.
        methods.add_method("getContacts", |lua, this, ()| {
            let contacts = this.world.borrow().get_contacts();
            let result = lua.create_table()?;
            for (i, c) in contacts.iter().enumerate() {
                result.set(i + 1, contact_to_table(lua, c)?)?;
            }
            Ok(result)
        });
        // -- getBodyContacts --
        /// Returns all contacts involving a specific body.
        /// @param | bodyId | integer | The body to query contacts for.
        /// @return | table | Array of {bodyA, bodyB, normalX, normalY, isTouching} tables.
        /// @field | bodyA | integer | BodyA.
        /// @field | bodyB | integer | BodyB.
        /// @field | normalX | number | NormalX.
        /// @field | normalY | number | NormalY.
        /// @field | isTouching | boolean | True while the body pair is currently touching.
        methods.add_method("getBodyContacts", |lua, this, body_id: usize| {
            let contacts = this.world.borrow().get_body_contacts(body_id);
            let result = lua.create_table()?;
            for (i, c) in contacts.iter().enumerate() {
                result.set(i + 1, contact_to_table(lua, c)?)?;
            }
            Ok(result)
        });
        // -- setBodyType --
        /// Changes the type of an existing body (e.g. from "dynamic" to "static").
        /// @param | id | integer | The body ID.
        /// @param | bodyType | string | New type: "static", "dynamic", "kinematic", or "sensor".
        methods.add_method("setBodyType", |_, this, (id, bt): (usize, String)| {
            let body_type = parse_body_type(&bt)?;
            this.world.borrow_mut().set_body_type(id, body_type);
            Ok(())
        });
        // -- getBodyType --
        /// Returns the type name of a body as a string.
        /// @param | id | integer | The body ID.
        /// @return | string | Body type: "static", "dynamic", "kinematic", or "sensor".
        methods.add_method("getBodyType", |_, this, id: usize| {
            Ok(this.world.borrow().get_body_type_str(id).to_string())
        });
        // -- setBeginContact --
        /// Registers a callback function invoked whenever two bodies begin touching.
        /// @param | callback | function | Called with (bodyIdA, bodyIdB) on each new contact.
        methods.add_method("setBeginContact", |lua, this, f: LuaFunction| {
            *this.begin_contact_key.borrow_mut() = Some(lua.create_registry_value(f)?);
            Ok(())
        });
        // -- clearBeginContact --
        /// Removes the begin-contact callback so it is no longer called.
        methods.add_method("clearBeginContact", |_, this, ()| {
            *this.begin_contact_key.borrow_mut() = None;
            Ok(())
        });
        // -- setEndContact --
        /// Registers a callback function invoked whenever two bodies stop touching.
        /// @param | callback | function | Called with (bodyIdA, bodyIdB) on each ended contact.
        methods.add_method("setEndContact", |lua, this, f: LuaFunction| {
            *this.end_contact_key.borrow_mut() = Some(lua.create_registry_value(f)?);
            Ok(())
        });
        // -- clearEndContact --
        /// Removes the end-contact callback so it is no longer called.
        methods.add_method("clearEndContact", |_, this, ()| {
            *this.end_contact_key.borrow_mut() = None;
            Ok(())
        });
        // -- setBodyData --
        /// Attaches arbitrary Lua data to a body ID for later retrieval (e.g. entity reference, tag).
        /// @param | id | integer | The body ID.
        /// @param | value | any | Lua value to associate with this body (table, number, string, etc.).
        methods.add_method(
            "setBodyData",
            |lua, this, (id, value): (usize, LuaValue)| {
                let key = lua.create_registry_value(value)?;
                this.body_data.borrow_mut().insert(id, key);
                Ok(())
            },
        );
        // -- getBodyData --
        /// Retrieves the Lua data previously attached to a body, or nil if none was set.
        /// @param | id | integer | The body ID.
        /// @return | table | The stored value, or nil if none was set.
        methods.add_method("getBodyData", |lua, this, id: usize| {
            let map = this.body_data.borrow();
            match map.get(&id) {
                Some(key) => lua.registry_value::<LuaValue>(key),
                None => Ok(LuaValue::Nil),
            }
        });
        // -- clearBodyData --
        /// Removes and releases the Lua data attached to a body.
        /// @param | id | integer | The body ID.
        methods.add_method("clearBodyData", |lua, this, id: usize| {
            let removed = this.body_data.borrow_mut().remove(&id);
            if let Some(key) = removed {
                lua.remove_registry_value(key)?;
            }
            Ok(())
        });
        // -- setBodyCCD --
        /// Enables or disables continuous collision detection (bullet mode) on a body to prevent tunneling.
        /// @param | id | integer | The body ID.
        /// @param | enabled | boolean | True to enable CCD.
        methods.add_method("setBodyCCD", |_, this, (id, enabled): (usize, bool)| {
            this.world.borrow_mut().set_bullet(id, enabled);
            Ok(())
        });
        // -- getBodyCCD --
        /// Returns whether continuous collision detection is enabled on a body.
        /// @param | id | integer | The body ID.
        /// @return | boolean | True if CCD is enabled.
        methods.add_method("getBodyCCD", |_, this, id: usize| {
            Ok(this.world.borrow().is_bullet(id))
        });
        // -- setBodyOneWay --
        /// Marks a body as a one-way platform: other bodies can pass through from the opposite side of the normal.
        /// @param | id | integer | The body ID.
        /// @param | nx | number | One-way normal X (points toward the blocking side).
        /// @param | ny | number | One-way normal Y.
        methods.add_method(
            "setBodyOneWay",
            |_, this, (id, nx, ny): (usize, f32, f32)| {
                this.world.borrow_mut().set_body_one_way(id, nx, ny);
                Ok(())
            },
        );
        // -- clearBodyOneWay --
        /// Removes the one-way platform behavior from a body, making it block from all directions.
        /// @param | id | integer | The body ID.
        methods.add_method("clearBodyOneWay", |_, this, id: usize| {
            this.world.borrow_mut().clear_body_one_way(id);
            Ok(())
        });
        // -- getBodyOneWay --
        /// Returns the one-way platform normal for a body, or nil,nil if not set.
        /// @param | id | integer | The body ID.
        /// @return | number | Normal X, or nil if not a one-way body.
        /// @return | number | Normal Y, or nil if not a one-way body.
        methods.add_method("getBodyOneWay", |_, this, id: usize| {
            match this.world.borrow().get_body_one_way(id) {
                Some((nx, ny)) => Ok((Some(nx), Some(ny))),
                None => Ok((None, None)),
            }
        });
        // -- setJointBreakForce --
        /// Sets the maximum force a joint can withstand before it breaks and is automatically destroyed.
        /// @param | jointId | integer | The joint ID.
        /// @param | force | number | Break threshold force (use math.huge for unbreakable).
        methods.add_method("setJointBreakForce", |_, this, (jid, f): (usize, f32)| {
            this.world.borrow_mut().set_joint_break_force(jid, f);
            Ok(())
        });
        // -- getJointBreakForce --
        /// Returns the break force threshold for a joint.
        /// @param | jointId | integer | The joint ID.
        /// @return | number | Break force value.
        methods.add_method("getJointBreakForce", |_, this, jid: usize| {
            Ok(this.world.borrow().get_joint_break_force(jid))
        });
        // -- isBodySleeping --
        /// Returns whether a body is currently in the sleeping (inactive) state.
        /// @param | id | integer | The body ID.
        /// @return | boolean | True if the body is sleeping.
        methods.add_method("isBodySleeping", |_, this, id: usize| {
            Ok(this.world.borrow().is_body_sleeping(id))
        });
        // -- wakeUpBody --
        /// Forces a sleeping body to wake up and participate in simulation again.
        /// @param | id | integer | The body ID.
        methods.add_method("wakeUpBody", |_, this, id: usize| {
            this.world.borrow_mut().wake_up_body(id);
            Ok(())
        });
        // -- sleepBody --
        /// Forces a body into the sleeping state, pausing its simulation until disturbed.
        /// @param | id | integer | The body ID.
        methods.add_method("sleepBody", |_, this, id: usize| {
            this.world.borrow_mut().sleep_body(id);
            Ok(())
        });
        // -- setSolverIterations --
        /// Sets the number of velocity solver iterations. Higher values improve stability at the cost of performance.
        /// @param | n | integer | Number of iterations (default is typically 4Ä‚ËĂ˘â€šÂ¬Ă˘â‚¬Ĺ›8).
        methods.add_method("setSolverIterations", |_, this, n: usize| {
            this.world.borrow_mut().set_solver_iterations(n);
            Ok(())
        });
        // -- getSolverIterations --
        /// Returns the current number of velocity solver iterations.
        /// @return | integer | Iteration count.
        methods.add_method("getSolverIterations", |_, this, ()| {
            Ok(this.world.borrow().get_solver_iterations())
        });
        // -- newBodies --
        /// Batch-creates multiple bodies at once for better performance. Each entry is {x, y, w, h, type} or {x, y, type}.
        /// @param | specs | table | Array of tables: {{x, y, w, h, "dynamic"}, ...} or {{x, y, "dynamic"}, ...} (defaults to 16x16).
        /// @return | integer[] | Body ID numbers in creation order.
        methods.add_method("newBodies", |lua, this, specs: LuaTable| {
            let mut pairs: Vec<(f32, f32, f32, f32, BodyType)> = Vec::new();
            for entry in specs.sequence_values::<LuaTable>() {
                let t = entry?;
                let x: f32 = t.get(1)?;
                let y: f32 = t.get(2)?;
                // Accept both 3-element {x, y, type} and 5-element {x, y, w, h, type} forms.
                let third: LuaValue = t.get(3)?;
                let (w, h, bt_str) = match &third {
                    LuaValue::String(_) => {
                        let s = String::from_lua(third, lua)?;
                        (16.0_f32, 16.0_f32, s)
                    }
                    _ => {
                        let w = f32::from_lua(third, lua)?;
                        let h: f32 = t.get(4)?;
                        let bt_str: String = t.get(5)?;
                        (w, h, bt_str)
                    }
                };
                pairs.push((x, y, w, h, parse_body_type(&bt_str)?));
            }
            let ids = this.world.borrow_mut().add_bodies(pairs);
            Ok(ids)
        });
        // -- stepFixed --
        /// Performs fixed-timestep physics stepping, consuming accumulated time. Returns the leftover time.
        /// @param | accumulator | number | Accumulated time since last frame (seconds).
        /// @param | stepDt | number | Fixed step size (e.g. 1/60).
        /// @param | maxSteps | integer | Maximum sub-steps per call to prevent spiral of death.
        /// @return | number | Remaining unstepped time to carry into next frame.
        methods.add_method_mut(
            "stepFixed",
            |_, this, (accum, step_dt, max_steps): (f32, f32, u32)| {
                let (_, remainder) = this
                    .world
                    .borrow_mut()
                    .step_fixed(accum, step_dt, max_steps);
                Ok(remainder)
            },
        );
        // -- addZone --
        /// Creates a rectangular physics zone for area-based effects (custom gravity, damping overrides).
        /// @param | x | number | Zone left X.
        /// @param | y | number | Zone top Y.
        /// @param | w | number | Zone width.
        /// @param | h | number | Zone height.
        /// @return | LZone | The zone handle.
        methods.add_method_mut("addZone", |_, this, (x, y, w, h): (f32, f32, f32, f32)| {
            let zone = PhysicsZone::try_new_rect(0, x, y, w, h)
                .map_err(|err| physics_runtime_error("addZone", err))?;
            let id = this
                .world
                .borrow_mut()
                .try_add_zone(zone)
                .map_err(|err| physics_runtime_error("addZone", err))?;
            Ok(LuaZone {
                zone_id: id,
                world: this.world.clone(),
            })
        });
        // -- getZoneEvents --
        /// Returns all zone enter/leave events from the last step.
        /// @return | table | Array of {zone_id, body_id, kind} tables where kind is "enter" or "leave".
        /// @field | zone_id | integer | Zone_id.
        /// @field | body_id | integer | Body_id.
        /// @field | kind | string | Kind.
        methods.add_method("getZoneEvents", |lua, this, ()| {
            let w = this.world.borrow();
            let events = w.get_zone_events();
            let tbl = lua.create_table()?;
            for (i, evt) in events.iter().enumerate() {
                let row = lua.create_table()?;
                row.set("zone_id", evt.zone_id)?;
                row.set("body_id", evt.body_id)?;
                row.set(
                    "kind",
                    match evt.kind {
                        crate::physics::ZoneEventKind::Enter => "enter",
                        crate::physics::ZoneEventKind::Leave => "leave",
                    },
                )?;
                tbl.set(i + 1, row)?;
            }
            Ok(tbl)
        });
        // -- type --
        /// Returns the type name of this object ("LWorld").
        /// @return | string | "LWorld".
        methods.add_method("type", |_, _, ()| Ok("LWorld"));
        // -- typeOf --
        /// Checks if this object is of a given type name. Supports inheritance (always matches "Object").
        /// @param | name | string | Type name to check.
        /// @return | boolean | True if the object matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LWorld" || name == "LObject")
        });
    }
}
/// A physics zone that applies area-based effects (gravity overrides, damping) to bodies within its bounds.
#[derive(Clone)]
pub struct LuaZone {
    zone_id: usize,
    world: Rc<RefCell<World>>,
}
impl LuaUserData for LuaZone {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getId --
        /// Returns the unique ID of this zone. This method is available to Lua scripts.
        /// @return | integer | Zone ID.
        methods.add_method("getId", |_, this, ()| Ok(this.zone_id));
        // -- setEnabled --
        /// Enables or disables this zone. Disabled zones have no effect on bodies.
        /// @param | enabled | boolean | True to enable, false to disable.
        methods.add_method("setEnabled", |_, this, enabled: bool| {
            let mut w = this.world.borrow_mut();
            if let Some(z) = w.zone_mut(this.zone_id) {
                z.enabled = enabled;
            }
            Ok(())
        });
        // -- setPriority --
        /// Sets the priority of this zone. Higher-priority zones take precedence when overlapping.
        /// @param | priority | integer | Integer priority value.
        methods.add_method("setPriority", |_, this, priority: i32| {
            let mut w = this.world.borrow_mut();
            if let Some(z) = w.zone_mut(this.zone_id) {
                z.priority = priority;
            }
            Ok(())
        });
        // -- setLayerMask --
        /// Sets a bitmask controlling which body layers this zone affects.
        /// @param | mask | integer | Layer bitmask (bitwise AND with body layer must be nonzero).
        methods.add_method("setLayerMask", |_, this, mask: u32| {
            let mut w = this.world.borrow_mut();
            if let Some(z) = w.zone_mut(this.zone_id) {
                z.layer_mask = mask;
            }
            Ok(())
        });
        // -- setCircle --
        /// Changes this zone's shape to a circle (overrides the initial rectangle).
        /// @param | cx | number | Center X.
        /// @param | cy | number | Center Y.
        /// @param | radius | number | Circle radius.
        methods.add_method("setCircle", |_, this, (cx, cy, radius): (f32, f32, f32)| {
            let mut w = this.world.borrow_mut();
            if let Some(z) = w.zone_mut(this.zone_id) {
                z.try_set_circle(cx, cy, radius)
                    .map_err(|err| physics_runtime_error("setCircle", err))?;
            }
            Ok(())
        });
        // -- setGravityDirectional --
        /// Sets the zone to apply a constant directional gravity to bodies inside.
        /// @param | gx | number | Gravity X component.
        /// @param | gy | number | Gravity Y component.
        methods.add_method("setGravityDirectional", |_, this, (gx, gy): (f32, f32)| {
            let mut w = this.world.borrow_mut();
            if let Some(z) = w.zone_mut(this.zone_id) {
                z.try_set_gravity_directional(gx, gy)
                    .map_err(|err| physics_runtime_error("setGravityDirectional", err))?;
            }
            Ok(())
        });
        // -- setGravityPoint --
        /// Sets the zone to attract bodies toward a center point with a given strength.
        /// @param | cx | number | Attractor center X.
        /// @param | cy | number | Attractor center Y.
        /// @param | strength | number | Pull force magnitude.
        methods.add_method(
            "setGravityPoint",
            |_, this, (cx, cy, strength): (f32, f32, f32)| {
                let mut w = this.world.borrow_mut();
                if let Some(z) = w.zone_mut(this.zone_id) {
                    z.try_set_gravity_point(cx, cy, strength)
                        .map_err(|err| physics_runtime_error("setGravityPoint", err))?;
                }
                Ok(())
            },
        );
        // -- setGravityRepulsor --
        /// Sets the zone to push bodies away from a center point with a given strength.
        /// @param | cx | number | Repulsor center X.
        /// @param | cy | number | Repulsor center Y.
        /// @param | strength | number | Push force magnitude.
        methods.add_method(
            "setGravityRepulsor",
            |_, this, (cx, cy, strength): (f32, f32, f32)| {
                let mut w = this.world.borrow_mut();
                if let Some(z) = w.zone_mut(this.zone_id) {
                    z.try_set_gravity_repulsor(cx, cy, strength)
                        .map_err(|err| physics_runtime_error("setGravityRepulsor", err))?;
                }
                Ok(())
            },
        );
        // -- setGravityZero --
        /// Sets the zone to cancel all gravity for bodies inside (zero-G area).
        methods.add_method("setGravityZero", |_, this, ()| {
            let mut w = this.world.borrow_mut();
            if let Some(z) = w.zone_mut(this.zone_id) {
                z.set_gravity_zero();
            }
            Ok(())
        });
        // -- setGravityAdditive --
        /// Controls whether this zone adds gravity to other fields instead of overriding world gravity by priority.
        /// @param | additive | boolean | True to add this zone's gravity; false for priority override behavior.
        methods.add_method("setGravityAdditive", |_, this, additive: bool| {
            let mut w = this.world.borrow_mut();
            if let Some(z) = w.zone_mut(this.zone_id) {
                z.set_gravity_additive(additive);
            }
            Ok(())
        });
        // -- isGravityAdditive --
        /// Returns whether this zone adds gravity to other fields.
        /// @return | boolean | True when additive gravity mode is enabled.
        methods.add_method("isGravityAdditive", |_, this, ()| {
            let w = this.world.borrow();
            Ok(w.zone(this.zone_id).is_some_and(|z| z.gravity_additive))
        });
        // -- setGravityFalloff --
        /// Sets point/repulsor gravity falloff. Accepted modes: inverseSquare, inverse, linear, constant.
        /// @param | mode | string | Falloff mode name.
        methods.add_method("setGravityFalloff", |_, this, mode: String| {
            let mut w = this.world.borrow_mut();
            if let Some(z) = w.zone_mut(this.zone_id) {
                z.try_set_gravity_falloff(&mode)
                    .map_err(|err| physics_runtime_error("setGravityFalloff", err))?;
            }
            Ok(())
        });
        // -- getGravityFalloff --
        /// Returns the current point/repulsor gravity falloff mode.
        /// @return | string | Falloff mode name.
        methods.add_method("getGravityFalloff", |_, this, ()| {
            let w = this.world.borrow();
            Ok(w.zone(this.zone_id)
                .map(|z| z.gravity_falloff.as_str())
                .unwrap_or("inverseSquare"))
        });
        // -- setGravityRadius --
        /// Sets the inner radius and optional outer radius used by point/repulsor falloff.
        /// @param | innerRadius | number | Minimum distance used for falloff, must be > 0.
        /// @param | outerRadius | number? | Optional maximum active distance, must be greater than innerRadius.
        methods.add_method(
            "setGravityRadius",
            |_, this, (inner_radius, outer_radius): (f32, Option<f32>)| {
                let mut w = this.world.borrow_mut();
                if let Some(z) = w.zone_mut(this.zone_id) {
                    z.try_set_gravity_radius(inner_radius, outer_radius)
                        .map_err(|err| physics_runtime_error("setGravityRadius", err))?;
                }
                Ok(())
            },
        );
        // -- setGravityLimits --
        /// Sets optional minimum and maximum acceleration clamps for point/repulsor gravity.
        /// @param | minAccel | number? | Optional minimum acceleration magnitude.
        /// @param | maxAccel | number? | Optional maximum acceleration magnitude.
        methods.add_method(
            "setGravityLimits",
            |_, this, (min_accel, max_accel): (Option<f32>, Option<f32>)| {
                let mut w = this.world.borrow_mut();
                if let Some(z) = w.zone_mut(this.zone_id) {
                    z.try_set_gravity_limits(min_accel, max_accel)
                        .map_err(|err| physics_runtime_error("setGravityLimits", err))?;
                }
                Ok(())
            },
        );
        // -- setLinearDampingOverride --
        /// Overrides the linear damping of bodies inside this zone, or nil to use each body's own value.
        /// @param | value | number? | Damping override, or nil to clear.
        methods.add_method("setLinearDampingOverride", |_, this, value: Option<f32>| {
            let mut w = this.world.borrow_mut();
            if let Some(z) = w.zone_mut(this.zone_id) {
                z.try_set_linear_damping_override(value)
                    .map_err(|err| physics_runtime_error("setLinearDampingOverride", err))?;
            }
            Ok(())
        });
        // -- setAngularDampingOverride --
        /// Overrides the angular damping of bodies inside this zone, or nil to use each body's own value.
        /// @param | value | number? | Damping override, or nil to clear.
        methods.add_method(
            "setAngularDampingOverride",
            |_, this, value: Option<f32>| {
                let mut w = this.world.borrow_mut();
                if let Some(z) = w.zone_mut(this.zone_id) {
                    z.try_set_angular_damping_override(value)
                        .map_err(|err| physics_runtime_error("setAngularDampingOverride", err))?;
                }
                Ok(())
            },
        );
        // -- setLinearDrag --
        /// Sets or clears area drag proportional to velocity for bodies inside this zone.
        /// @param | value | number? | Drag coefficient, or nil to clear.
        methods.add_method("setLinearDrag", |_, this, value: Option<f32>| {
            let mut w = this.world.borrow_mut();
            if let Some(z) = w.zone_mut(this.zone_id) {
                z.try_set_linear_drag(value)
                    .map_err(|err| physics_runtime_error("setLinearDrag", err))?;
            }
            Ok(())
        });
        // -- setQuadraticDrag --
        /// Sets or clears area drag proportional to speed times velocity for bodies inside this zone.
        /// @param | value | number? | Drag coefficient, or nil to clear.
        methods.add_method("setQuadraticDrag", |_, this, value: Option<f32>| {
            let mut w = this.world.borrow_mut();
            if let Some(z) = w.zone_mut(this.zone_id) {
                z.try_set_quadratic_drag(value)
                    .map_err(|err| physics_runtime_error("setQuadraticDrag", err))?;
            }
            Ok(())
        });
        // -- destroy --
        /// Removes this zone from the world. Bodies will no longer be affected by it.
        methods.add_method("destroy", |_, this, ()| {
            this.world.borrow_mut().remove_zone(this.zone_id);
            Ok(())
        });
        // -- type --
        /// Returns the type name of this object ("LZone").
        /// @return | string | "LZone".
        methods.add_method("type", |_, _, ()| Ok("LZone"));
        // -- typeOf --
        /// Checks if this object is of a given type name.
        /// @param | name | string | Type name to check.
        /// @return | boolean | True if the object matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LZone" || name == "LObject")
        });
    }
}
/// A destructible terrain map backed by a grid of solid/empty cells. Generates physics colliders on flush.
#[derive(Clone)]
pub struct LuaTerrain {
    terrain: Rc<RefCell<TerrainMap>>,
    world: Rc<RefCell<World>>,
}
impl LuaUserData for LuaTerrain {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- setCell --
        /// Sets a single terrain cell to solid or empty.
        /// @param | cx | integer | Cell column (0-based).
        /// @param | cy | integer | Cell row (0-based).
        /// @param | solid | boolean | True for solid, false for empty.
        methods.add_method_mut("setCell", |_, this, (cx, cy, solid): (u32, u32, bool)| {
            this.terrain.borrow_mut().set_cell(cx, cy, solid);
            Ok(())
        });
        // -- getCell --
        /// Returns whether a cell is solid. This method is available to Lua scripts.
        /// @param | cx | integer | Cell column.
        /// @param | cy | integer | Cell row.
        /// @return | boolean | True if the cell is solid.
        methods.add_method("getCell", |_, this, (cx, cy): (u32, u32)| {
            Ok(this.terrain.borrow().get_cell(cx, cy))
        });
        // -- fillCircle --
        /// Fills or clears a circular region of terrain cells.
        /// @param | wx | number | Circle center X in world coordinates.
        /// @param | wy | number | Circle center Y in world coordinates.
        /// @param | radius | number | Circle radius in world units.
        /// @param | solid | boolean | True to fill solid, false to carve empty.
        methods.add_method_mut(
            "fillCircle",
            |_, this, (wx, wy, radius, solid): (f32, f32, f32, bool)| {
                this.terrain
                    .borrow_mut()
                    .try_fill_circle(wx, wy, radius, solid)
                    .map_err(|err| physics_runtime_error("fillCircle", err))?;
                Ok(())
            },
        );
        // -- fillRect --
        /// Fills or clears a rectangular region of terrain cells.
        /// @param | wx | number | Rectangle left X in world coordinates.
        /// @param | wy | number | Rectangle top Y in world coordinates.
        /// @param | w | number | Rectangle width.
        /// @param | h | number | Rectangle height.
        /// @param | solid | boolean | True to fill solid, false to carve empty.
        methods.add_method_mut(
            "fillRect",
            |_, this, (wx, wy, w, h, solid): (f32, f32, f32, f32, bool)| {
                this.terrain
                    .borrow_mut()
                    .try_fill_rect(wx, wy, w, h, solid)
                    .map_err(|err| physics_runtime_error("fillRect", err))?;
                Ok(())
            },
        );
        // -- fillAll --
        /// Sets all terrain cells to either solid or empty.
        /// @param | solid | boolean | True to fill everything solid, false to clear.
        methods.add_method_mut("fillAll", |_, this, solid: bool| {
            this.terrain.borrow_mut().fill_all(solid);
            Ok(())
        });
        // -- flush --
        /// Regenerates physics colliders from the current terrain grid state. Call after modifying cells.
        methods.add_method_mut("flush", |_, this, ()| {
            this.terrain
                .borrow_mut()
                .flush(&mut this.world.borrow_mut());
            Ok(())
        });
        // -- isDirty --
        /// Returns true if terrain cells have been modified since the last flush.
        /// @return | boolean | True if a flush is needed.
        methods.add_method("isDirty", |_, this, ()| {
            Ok(this.terrain.borrow().is_dirty())
        });
        // -- collapseColumns --
        /// Optimizes terrain by merging vertically adjacent solid cells into larger colliders.
        /// @return | integer | Number of columns collapsed.
        methods.add_method_mut("collapseColumns", |_, this, ()| {
            Ok(this.terrain.borrow_mut().collapse_columns())
        });
        // -- solidPositions --
        /// Returns all solid cell positions as a table of {x, y} entries.
        /// @return | table | Array of tables with x and y fields (cell coordinates).
        /// @field | x | integer | Cell x coordinate.
        /// @field | y | integer | Cell y coordinate.
        methods.add_method("solidPositions", |lua, this, ()| {
            let positions = this.terrain.borrow().solid_cell_positions();
            let tbl = lua.create_table()?;
            for (i, (x, y)) in positions.iter().enumerate() {
                let row = lua.create_table()?;
                row.set("x", *x)?;
                row.set("y", *y)?;
                tbl.set(i + 1, row)?;
            }
            Ok(tbl)
        });
        // -- spawnDebris --
        /// Spawns small dynamic debris bodies at the given positions (for destruction effects).
        /// @param | positions | table | Array of {x, y} tables in world coordinates.
        /// @param | mass | number | Mass of each debris body.
        /// @param | restitution | number | Bounciness of debris bodies.
        /// @return | integer[] | Array of body IDs for the spawned debris.
        methods.add_method_mut(
            "spawnDebris",
            |lua, this, (positions, mass, restitution): (LuaTable, f32, f32)| {
                let mut pts: Vec<(f32, f32)> = Vec::new();
                for i in 1..=positions.raw_len() {
                    let row: LuaTable = positions.raw_get(i)?;
                    let x: f32 = row.get("x")?;
                    let y: f32 = row.get("y")?;
                    pts.push((x, y));
                }
                let ids = this.terrain.borrow().spawn_debris_at(
                    &mut this.world.borrow_mut(),
                    &pts,
                    mass,
                    restitution,
                );
                let tbl = lua.create_table()?;
                for (i, id) in ids.iter().enumerate() {
                    tbl.set(i + 1, *id)?;
                }
                Ok(tbl)
            },
        );
        // -- toImageData --
        /// Renders the terrain grid to raw RGBA pixel data with solid and empty colors.
        /// @param | sr | integer | Solid color red (0-255).
        /// @param | sg | integer | Solid color green.
        /// @param | sb | integer | Solid color blue.
        /// @param | er | integer | Empty color red.
        /// @param | eg | integer | Empty color green.
        /// @param | eb | integer | Empty color blue.
        /// @return | string | Raw RGBA pixel bytes.
        methods.add_method(
            "toImageData",
            |lua, this, (sr, sg, sb, er, eg, eb): (u8, u8, u8, u8, u8, u8)| {
                let buf = this
                    .terrain
                    .borrow()
                    .to_image_data_checked([sr, sg, sb, 255], [er, eg, eb, 255])
                    .map_err(|err| physics_runtime_error("toImageData", err))?;
                lua.create_string(&buf)
            },
        );
        // -- toBytes --
        /// Serializes the terrain grid to a compact binary format for saving.
        /// @return | string | Binary terrain data.
        methods.add_method("toBytes", |lua, this, ()| {
            lua.create_string(this.terrain.borrow().to_bytes())
        });
        // -- loadFromBytes --
        /// Restores terrain grid state from binary data previously produced by toBytes.
        /// @param | data | string | Binary terrain data.
        /// @return | boolean | True if loading succeeded.
        methods.add_method_mut("loadFromBytes", |_, this, data: LuaString| {
            Ok(this
                .terrain
                .borrow_mut()
                .load_from_bytes(data.as_bytes().as_ref()))
        });
        // -- type --
        /// Returns the type name of this object ("LTerrain").
        /// @return | string | "LTerrain".
        methods.add_method("type", |_, _, ()| Ok("LTerrain"));
        // -- typeOf --
        /// Checks if this object is of a given type name.
        /// @param | name | string | Type name to check.
        /// @return | boolean | True if the object matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LTerrain" || name == "LObject")
        });
    }
}
/// A handle to a single physics body in the world, providing per-body manipulation methods.
#[derive(Clone)]
pub struct LuaBody {
    world: Rc<RefCell<World>>,
    id: BodyId,
}
impl LuaBody {
    /// Shared world handle for internal cross-module integrations.
    pub(crate) fn world_handle(&self) -> Rc<RefCell<World>> {
        self.world.clone()
    }

    /// Numeric body id for internal cross-module integrations.
    pub(crate) fn body_id(&self) -> usize {
        self.id.0
    }
}
impl LuaUserData for LuaBody {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getId --
        /// Returns the unique numeric ID of this body within the world.
        /// @return | integer | Body ID.
        methods.add_method("getId", |_, this, ()| Ok(this.id.0));
        // -- isValid --
        /// Returns whether this body handle still points to an active body.
        /// @return | boolean | True if the body has not been destroyed.
        methods.add_method("isValid", |_, this, ()| {
            Ok(this.world.borrow().has_body(this.id.0))
        });
        // -- getPosition --
        /// Returns the current world-space position of this body.
        /// @return | number | X coordinate.
        /// @return | number | Y coordinate.
        methods.add_method("getPosition", |_, this, ()| {
            let w = this.world.borrow();
            match w.get_body(this.id.0) {
                Some(b) => Ok((b.position.x, b.position.y)),
                None => Ok((0.0, 0.0)),
            }
        });
        // -- setPosition --
        /// Teleports the body to a new world-space position (does not apply physics forces).
        /// @param | x | number | New X position.
        /// @param | y | number | New Y position.
        methods.add_method("setPosition", |_, this, (x, y): (f32, f32)| {
            this.world.borrow_mut().set_body_position(this.id.0, x, y);
            Ok(())
        });
        // -- getX --
        /// Returns only the X component of the body's position.
        /// @return | number | X coordinate.
        methods.add_method("getX", |_, this, ()| {
            let w = this.world.borrow();
            Ok(w.get_body(this.id.0).map_or(0.0, |b| b.position.x))
        });
        // -- getY --
        /// Returns only the Y component of the body's position.
        /// @return | number | Y coordinate.
        methods.add_method("getY", |_, this, ()| {
            let w = this.world.borrow();
            Ok(w.get_body(this.id.0).map_or(0.0, |b| b.position.y))
        });
        // -- getVelocity --
        /// Returns the body's current linear velocity.
        /// @return | number | Velocity X component.
        /// @return | number | Velocity Y component.
        methods.add_method("getVelocity", |_, this, ()| {
            let w = this.world.borrow();
            match w.get_body(this.id.0) {
                Some(b) => Ok((b.velocity.x, b.velocity.y)),
                None => Ok((0.0, 0.0)),
            }
        });
        // -- setVelocity --
        /// Directly sets the body's linear velocity.
        /// @param | vx | number | Velocity X component.
        /// @param | vy | number | Velocity Y component.
        methods.add_method("setVelocity", |_, this, (vx, vy): (f32, f32)| {
            this.world.borrow_mut().set_body_velocity(this.id.0, vx, vy);
            Ok(())
        });
        // -- getAngle --
        /// Returns the body's rotation angle in radians.
        /// @return | number | Angle in radians.
        methods.add_method("getAngle", |_, this, ()| {
            Ok(this.world.borrow().get_body_angle(this.id.0))
        });
        // -- setAngle --
        /// Sets the body's rotation angle directly.
        /// @param | angle | number | New angle in radians.
        methods.add_method("setAngle", |_, this, angle: f32| {
            this.world.borrow_mut().set_body_angle(this.id.0, angle);
            Ok(())
        });
        // -- getAngularVelocity --
        /// Returns the body's angular (rotational) velocity.
        /// @return | number | Angular velocity in radians per second.
        methods.add_method("getAngularVelocity", |_, this, ()| {
            Ok(this.world.borrow().get_angular_velocity(this.id.0))
        });
        // -- setAngularVelocity --
        /// Sets the body's angular velocity directly.
        /// @param | omega | number | Angular velocity in radians per second.
        methods.add_method("setAngularVelocity", |_, this, omega: f32| {
            this.world
                .borrow_mut()
                .set_angular_velocity(this.id.0, omega);
            Ok(())
        });
        // -- getMass --
        /// Returns the body's total mass (computed from density and fixture areas).
        /// @return | number | Mass in kilograms.
        methods.add_method("getMass", |_, this, ()| {
            Ok(this.world.borrow().get_body_mass(this.id.0))
        });
        // -- setMass --
        /// Overrides the body's mass directly.
        /// @param | mass | number | New mass value.
        methods.add_method("setMass", |_, this, mass: f32| {
            this.world.borrow_mut().set_body_mass(this.id.0, mass);
            Ok(())
        });
        // -- getType --
        /// Returns the body's type as a string.
        /// @return | string | Body type: "static", "dynamic", "kinematic", or "sensor".
        methods.add_method("getType", |_, this, ()| {
            Ok(this.world.borrow().get_body_type_str(this.id.0).to_string())
        });
        // -- setType --
        /// Changes the body's type at runtime.
        /// @param | bodyType | string | New type: "static", "dynamic", "kinematic", or "sensor".
        methods.add_method("setType", |_, this, bt: String| {
            let body_type = parse_body_type(&bt)?;
            this.world.borrow_mut().set_body_type(this.id.0, body_type);
            Ok(())
        });
        // -- getWidth --
        /// Returns the body's bounding width (from its primary shape).
        /// @return | number | Width in world units.
        methods.add_method("getWidth", |_, this, ()| {
            let w = this.world.borrow();
            Ok(w.get_body(this.id.0).map_or(0.0, |b| b.width))
        });
        // -- getHeight --
        /// Returns the body's bounding height (from its primary shape).
        /// @return | number | Height in world units.
        methods.add_method("getHeight", |_, this, ()| {
            let w = this.world.borrow();
            Ok(w.get_body(this.id.0).map_or(0.0, |b| b.height))
        });
        // -- getFriction --
        /// Returns the body's friction coefficient.
        /// @return | number | Friction value.
        methods.add_method("getFriction", |_, this, ()| {
            let w = this.world.borrow();
            Ok(w.get_body(this.id.0).map_or(0.5, |b| b.friction))
        });
        // -- setFriction --
        /// Sets the body's friction coefficient.
        /// @param | friction | number | New friction value (0 = ice, 1 = rubber).
        methods.add_method("setFriction", |_, this, friction: f32| {
            let mut w = this.world.borrow_mut();
            if let Some(b) = w.get_body_mut(this.id.0) {
                b.friction = friction;
            }
            Ok(())
        });
        // -- getRestitution --
        /// Returns the body's restitution (bounciness) value.
        /// @return | number | Restitution (0 = no bounce, 1 = perfectly elastic).
        methods.add_method("getRestitution", |_, this, ()| {
            let w = this.world.borrow();
            Ok(w.get_body(this.id.0).map_or(0.3, |b| b.restitution))
        });
        // -- setRestitution --
        /// Sets the body's restitution (bounciness) value.
        /// @param | restitution | number | New restitution (0Ä‚ËĂ˘â€šÂ¬Ă˘â‚¬Ĺ›1).
        methods.add_method("setRestitution", |_, this, restitution: f32| {
            let mut w = this.world.borrow_mut();
            if let Some(b) = w.get_body_mut(this.id.0) {
                b.restitution = restitution;
            }
            Ok(())
        });
        // -- getLayer --
        /// Returns the body's collision layer bitmask.
        /// @return | integer | Layer bitmask.
        methods.add_method("getLayer", |_, this, ()| {
            let w = this.world.borrow();
            Ok(w.get_body(this.id.0).map_or(1u32, |b| b.layer))
        });
        // -- setLayer --
        /// Sets the body's collision layer bitmask (which layers this body belongs to).
        /// @param | layer | integer | Layer bitmask.
        methods.add_method("setLayer", |_, this, layer: u32| {
            this.world.borrow_mut().set_body_layer(this.id.0, layer);
            Ok(())
        });
        // -- getMask --
        /// Returns the body's collision mask (which layers this body can collide with).
        /// @return | integer | Mask bitmask.
        methods.add_method("getMask", |_, this, ()| {
            let w = this.world.borrow();
            Ok(w.get_body(this.id.0).map_or(1u32, |b| b.mask))
        });
        // -- setMask --
        /// Sets the body's collision mask (which layers this body can collide with).
        /// @param | mask | integer | Collision mask bitmask.
        methods.add_method("setMask", |_, this, mask: u32| {
            this.world.borrow_mut().set_body_mask(this.id.0, mask);
            Ok(())
        });
        // -- getCollisionGroup --
        /// Returns the single 0..15 collision group for this body, or nil for multi-group masks.
        /// @return | integer? | Collision group index, or nil.
        methods.add_method("getCollisionGroup", |_, this, ()| {
            Ok(this.world.borrow().get_body_collision_group(this.id.0))
        });
        // -- setCollisionGroup --
        /// Assigns the body to one collision group and opens its local mask to the 16 group bits.
        /// @param | group | integer | Collision group index, 0..15.
        methods.add_method("setCollisionGroup", |_, this, group: i64| {
            let group = lua_collision_group("setCollisionGroup", group)?;
            this.world
                .borrow_mut()
                .try_set_body_collision_group(this.id.0, group)
                .map_err(|err| physics_runtime_error("setCollisionGroup", err))?;
            Ok(())
        });
        // -- applyImpulse --
        /// Applies an instantaneous linear impulse to the body's center of mass.
        /// @param | ix | number | Impulse X component.
        /// @param | iy | number | Impulse Y component.
        methods.add_method("applyImpulse", |_, this, (ix, iy): (f32, f32)| {
            this.world.borrow_mut().apply_impulse(this.id.0, ix, iy);
            Ok(())
        });
        // -- applyForce --
        /// Applies a continuous force to the body's center of mass (accumulates over the step).
        /// @param | fx | number | Force X component.
        /// @param | fy | number | Force Y component.
        methods.add_method("applyForce", |_, this, (fx, fy): (f32, f32)| {
            this.world.borrow_mut().apply_force(this.id.0, fx, fy);
            Ok(())
        });
        // -- applyTorque --
        /// Applies a rotational torque to the body.
        /// @param | torque | number | Torque value (positive = counter-clockwise).
        methods.add_method("applyTorque", |_, this, torque: f32| {
            this.world.borrow_mut().apply_torque(this.id.0, torque);
            Ok(())
        });
        // -- applyForceAtPoint --
        /// Applies a force at a specific world point, generating both linear and angular acceleration.
        /// @param | fx | number | Force X component.
        /// @param | fy | number | Force Y component.
        /// @param | px | number | Application point X in world coordinates.
        /// @param | py | number | Application point Y in world coordinates.
        methods.add_method(
            "applyForceAtPoint",
            |_, this, (fx, fy, px, py): (f32, f32, f32, f32)| {
                this.world
                    .borrow_mut()
                    .apply_force_at_point(this.id.0, fx, fy, px, py);
                Ok(())
            },
        );
        // -- applyAngularImpulse --
        /// Applies an instantaneous angular impulse (spin) to the body.
        /// @param | impulse | number | Angular impulse value.
        methods.add_method("applyAngularImpulse", |_, this, impulse: f32| {
            this.world
                .borrow_mut()
                .apply_angular_impulse(this.id.0, impulse);
            Ok(())
        });
        // -- getGravityScale --
        /// Returns the gravity scale multiplier for this body (1.0 = normal gravity).
        /// @return | number | Gravity scale.
        methods.add_method("getGravityScale", |_, this, ()| {
            Ok(this.world.borrow().get_gravity_scale(this.id.0))
        });
        // -- setGravityScale --
        /// Sets a per-body gravity scale multiplier (0 = no gravity, 2 = double gravity, -1 = inverted).
        /// @param | scale | number | Gravity scale factor.
        methods.add_method("setGravityScale", |_, this, scale: f32| {
            this.world.borrow_mut().set_gravity_scale(this.id.0, scale);
            Ok(())
        });
        // -- isFixedRotation --
        /// Returns whether the body's rotation is locked.
        /// @return | boolean | True if rotation is fixed.
        methods.add_method("isFixedRotation", |_, this, ()| {
            Ok(this.world.borrow().is_fixed_rotation(this.id.0))
        });
        // -- setFixedRotation --
        /// Locks or unlocks the body's rotation. Useful for player characters.
        /// @param | fixed | boolean | True to prevent rotation.
        methods.add_method("setFixedRotation", |_, this, fixed: bool| {
            this.world.borrow_mut().set_fixed_rotation(this.id.0, fixed);
            Ok(())
        });
        // -- getLinearDamping --
        /// Returns the linear damping factor (velocity decay rate, like air resistance).
        /// @return | number | Damping value.
        methods.add_method("getLinearDamping", |_, this, ()| {
            Ok(this.world.borrow().get_linear_damping(this.id.0))
        });
        // -- setLinearDamping --
        /// Sets the linear damping factor (higher = more velocity decay per step).
        /// @param | damping | number | Damping value (0 = no damping).
        methods.add_method("setLinearDamping", |_, this, damping: f32| {
            this.world
                .borrow_mut()
                .set_linear_damping(this.id.0, damping);
            Ok(())
        });
        // -- getAngularDamping --
        /// Returns the angular damping factor (rotational decay rate).
        /// @return | number | Angular damping value.
        methods.add_method("getAngularDamping", |_, this, ()| {
            Ok(this.world.borrow().get_angular_damping(this.id.0))
        });
        // -- setAngularDamping --
        /// Sets the angular damping factor (higher = rotation decays faster).
        /// @param | damping | number | Angular damping value.
        methods.add_method("setAngularDamping", |_, this, damping: f32| {
            this.world
                .borrow_mut()
                .set_angular_damping(this.id.0, damping);
            Ok(())
        });
        // -- isBullet --
        /// Returns whether continuous collision detection (bullet mode) is enabled for this body.
        /// @return | boolean | True if CCD is active.
        methods.add_method("isBullet", |_, this, ()| {
            Ok(this.world.borrow().is_bullet(this.id.0))
        });
        // -- setBullet --
        /// Enables or disables continuous collision detection to prevent fast-moving tunneling.
        /// @param | bullet | boolean | True to enable CCD.
        methods.add_method("setBullet", |_, this, bullet: bool| {
            this.world.borrow_mut().set_bullet(this.id.0, bullet);
            Ok(())
        });
        // -- isSleepingAllowed --
        /// Returns whether the body is allowed to enter sleep state when at rest.
        /// @return | boolean | True if sleeping is allowed.
        methods.add_method("isSleepingAllowed", |_, this, ()| {
            Ok(this.world.borrow().is_sleeping_allowed(this.id.0))
        });
        // -- setSleepingAllowed --
        /// Controls whether the body can enter sleep state. Disable for bodies that must stay active.
        /// @param | allowed | boolean | True to allow sleeping.
        methods.add_method("setSleepingAllowed", |_, this, allowed: bool| {
            this.world
                .borrow_mut()
                .set_sleeping_allowed(this.id.0, allowed);
            Ok(())
        });
        // -- destroy --
        /// Destroys this body, removing it from the world along with all fixtures and joints.
        methods.add_method("destroy", |_, this, ()| {
            this.world.borrow_mut().destroy_body(this.id.0);
            Ok(())
        });
        // -- isSleeping --
        /// Returns whether this body is currently in the sleeping (inactive) state.
        /// @return | boolean | True if sleeping.
        methods.add_method("isSleeping", |_, this, ()| {
            Ok(this.world.borrow().is_body_sleeping(this.id.0))
        });
        // -- wakeUp --
        /// Wakes the body from sleep, making it active in the simulation again.
        methods.add_method("wakeUp", |_, this, ()| {
            this.world.borrow_mut().wake_up_body(this.id.0);
            Ok(())
        });
        // -- sleep --
        /// Forces the body into sleep state, pausing its simulation until disturbed.
        methods.add_method("sleep", |_, this, ()| {
            this.world.borrow_mut().sleep_body(this.id.0);
            Ok(())
        });
        // -- type --
        /// Returns the type name of this object ("LBody").
        /// @return | string | "LBody".
        methods.add_method("type", |_, _, ()| Ok("LBody"));
        // -- typeOf --
        /// Checks if this object is of a given type name.
        /// @param | name | string | Type name to check.
        /// @return | boolean | True if the object matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LBody" || name == "LObject")
        });
    }
}
/// Stores raw shape geometry and default fixture material properties for a Lua shape handle.
#[derive(Clone)]
pub(crate) struct LuaPhysicsShapeData {
    /// Collision geometry attached to bodies created from this handle.
    pub(crate) shape: Shape,
    /// Density applied to attached fixtures.
    pub(crate) density: f32,
    /// Friction coefficient applied to attached fixtures.
    pub(crate) friction: f32,
    /// Restitution coefficient applied to attached fixtures.
    pub(crate) restitution: f32,
    /// Whether attached fixtures should behave as sensors only.
    pub(crate) sensor: bool,
}
/// A standalone collision shape with material properties, to be attached to bodies via `attachShape`.
#[derive(Clone)]
pub struct LuaPhysicsShape {
    inner: Rc<RefCell<LuaPhysicsShapeData>>,
}
impl LuaPhysicsShape {
    /// Creates a Lua shape wrapper with default density, friction, restitution, and sensor settings.
    pub(crate) fn new(shape: Shape) -> Self {
        Self {
            inner: Rc::new(RefCell::new(LuaPhysicsShapeData {
                shape,
                density: 1.0,
                friction: 0.2,
                restitution: 0.0,
                sensor: false,
            })),
        }
    }

    /// Clone the current shape payload and material settings for internal module integrations.
    pub(crate) fn data(&self) -> LuaPhysicsShapeData {
        self.inner.borrow().clone()
    }
}
impl LuaUserData for LuaPhysicsShape {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- getType --
        /// Returns the shape kind as a string: "circle", "rectangle", "polygon", "edge", or "chain".
        /// @return | string | Shape type name.
        methods.add_method("getType", |_, this, ()| {
            let name = match this.inner.borrow().shape {
                Shape::Circle { .. } => "circle",
                Shape::Rect { .. } => "rectangle",
                Shape::Polygon { .. } => "polygon",
                Shape::Edge { .. } => "edge",
                Shape::Chain { .. } => "chain",
            };
            Ok(name)
        });
        // -- getRadius --
        /// Returns the radius of a circle shape. Errors if called on a non-circle shape.
        /// @return | number | Circle radius.
        methods.add_method("getRadius", |_, this, ()| match this.inner.borrow().shape {
            Shape::Circle { radius } => Ok(radius),
            _ => Err(LuaError::RuntimeError(
                "getRadius: shape is not a circle".to_string(),
            )),
        });
        // -- getBoundingBox --
        /// Returns the axis-aligned bounding box of the shape in local coordinates.
        /// @return | number | Minimum X.
        /// @return | number | Minimum Y.
        /// @return | number | Maximum X.
        /// @return | number | Maximum Y.
        methods.add_method("getBoundingBox", |_, this, ()| {
            let d = this.inner.borrow();
            let (x1, y1, x2, y2) = match &d.shape {
                Shape::Circle { radius } => (-radius, -radius, *radius, *radius),
                Shape::Rect { width, height } => {
                    (-width / 2.0, -height / 2.0, *width / 2.0, *height / 2.0)
                }
                Shape::Edge { v1, v2 } => (
                    v1.x.min(v2.x),
                    v1.y.min(v2.y),
                    v1.x.max(v2.x),
                    v1.y.max(v2.y),
                ),
                Shape::Polygon { vertices } | Shape::Chain { vertices, .. } => {
                    let mut min_x = f32::INFINITY;
                    let mut min_y = f32::INFINITY;
                    let mut max_x = f32::NEG_INFINITY;
                    let mut max_y = f32::NEG_INFINITY;
                    for v in vertices {
                        min_x = min_x.min(v.x);
                        min_y = min_y.min(v.y);
                        max_x = max_x.max(v.x);
                        max_y = max_y.max(v.y);
                    }
                    (min_x, min_y, max_x, max_y)
                }
            };
            Ok((x1, y1, x2, y2))
        });
        // -- getVertexCount --
        /// Returns the number of local-space vertices for polygon, rectangle, edge, or chain shapes; circles return 0.
        /// @return | integer | Vertex count.
        methods.add_method("getVertexCount", |_, this, ()| {
            Ok(this
                .inner
                .borrow()
                .shape
                .vertices()
                .map_or(0usize, |vertices| vertices.len()))
        });
        // -- getVertices --
        /// Returns local-space vertices as an array of `{x, y}` tables, or nil for circles.
        /// @return | table? | Vertex table, or nil for circles.
        methods.add_method("getVertices", |lua, this, ()| {
            let Some(vertices) = this.inner.borrow().shape.vertices() else {
                return Ok(LuaValue::Nil);
            };
            let out = lua.create_table()?;
            for (i, vertex) in vertices.iter().enumerate() {
                let row = lua.create_table()?;
                row.set("x", vertex.x)?;
                row.set("y", vertex.y)?;
                out.set(i + 1, row)?;
            }
            Ok(LuaValue::Table(out))
        });
        // -- setDensity --
        /// Sets the density used when this shape is attached to a body (affects mass calculation).
        /// @param | density | number | Mass density.
        methods.add_method("setDensity", |_, this, density: f32| {
            if !density.is_finite() || density <= 0.0 {
                return Err(physics_runtime_error(
                    "setDensity",
                    "density must be finite and > 0",
                ));
            }
            this.inner.borrow_mut().density = density;
            Ok(())
        });
        // -- setFriction --
        /// Sets the friction coefficient for this shape.
        /// @param | friction | number | Friction (0 = ice, 1 = rubber).
        methods.add_method("setFriction", |_, this, friction: f32| {
            if !friction.is_finite() || !(0.0..=1.0).contains(&friction) {
                return Err(physics_runtime_error(
                    "setFriction",
                    "friction must be finite and in [0, 1]",
                ));
            }
            this.inner.borrow_mut().friction = friction;
            Ok(())
        });
        // -- setRestitution --
        /// Sets the restitution (bounciness) for this shape.
        /// @param | restitution | number | Restitution (0\u20131).
        methods.add_method("setRestitution", |_, this, restitution: f32| {
            if !restitution.is_finite() || !(0.0..=1.0).contains(&restitution) {
                return Err(physics_runtime_error(
                    "setRestitution",
                    "restitution must be finite and in [0, 1]",
                ));
            }
            this.inner.borrow_mut().restitution = restitution;
            Ok(())
        });
        // -- setSensor --
        /// Marks this shape as a sensor (overlap detection only, no physical response).
        /// @param | sensor | boolean | True for sensor mode.
        methods.add_method("setSensor", |_, this, sensor: bool| {
            this.inner.borrow_mut().sensor = sensor;
            Ok(())
        });
        // -- destroy --
        /// No-op placeholder for API consistency. Shapes are freed when no longer referenced.
        methods.add_method("destroy", |_, _this, ()| Ok(()));
        // -- type --
        /// Returns the type name of this object ("LPhysicsShape").
        /// @return | string | "LPhysicsShape".
        methods.add_method("type", |_, _, ()| Ok("LPhysicsShape"));
        // -- typeOf --
        /// Checks if this object is of a given type name.
        /// @param | name | string | Type name to check.
        /// @return | boolean | True if the object matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LPhysicsShape" || name == "LObject")
        });
    }
}

impl From<crate::physics::PhysicsShapeSnapshot> for crate::render::renderer::PhysicsDebugShape {
    fn from(s: crate::physics::PhysicsShapeSnapshot) -> Self {
        Self {
            x: s.x,
            y: s.y,
            half_w: s.half_w,
            half_h: s.half_h,
            angle: s.angle,
            is_static: s.is_static,
            is_sleeping: s.is_sleeping,
            is_sensor: s.is_sensor,
            is_circle: s.is_circle,
            hull_verts: s.hull_verts,
        }
    }
}
/// Registers the `lurek.physics` module table and all its free functions onto the given Lua table.
pub fn register(lua: &Lua, luna: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    // --- Free functions ---
    // -- newWorld --
    /// Creates a new physics world with the given gravity vector.
    /// @param | gx | number | Gravity X component.
    /// @param | gy | number | Gravity Y component (positive = down).
    /// @return | LWorld | The new physics world.
    tbl.set(
        "newWorld",
        lua.create_function(|_, (gx, gy): (f32, f32)| {
            if !gx.is_finite() || !gy.is_finite() {
                return Err(physics_runtime_error("newWorld", "gravity must be finite"));
            }
            Ok(LuaWorld {
                world: Rc::new(RefCell::new(World::new(gx, gy))),
                begin_contact_key: Rc::new(RefCell::new(None)),
                end_contact_key: Rc::new(RefCell::new(None)),
                body_data: Rc::new(RefCell::new(HashMap::new())),
            })
        })?,
    )?;
    // -- step --
    /// Steps a physics world forward by dt seconds (free-function variant).
    /// @param | world | LWorld | The world to step.
    /// @param | dt | number | Time step in seconds.
    tbl.set(
        "step",
        lua.create_function(|_, (world_ud, dt): (LuaAnyUserData, f32)| {
            if !dt.is_finite() || dt <= 0.0 {
                return Err(physics_runtime_error("step", "dt must be finite and > 0"));
            }
            let world = world_ud.borrow::<LuaWorld>()?;
            world.world.borrow_mut().step(dt);
            Ok(())
        })?,
    )?;
    // -- destroyWorld --
    /// No-op placeholder for API parity. Worlds are freed when no longer referenced.
    /// @param | world | LWorld | The world to destroy.
    tbl.set(
        "destroyWorld",
        lua.create_function(|_, _world_ud: LuaAnyUserData| Ok(()))?,
    )?;
    // -- newBody --
    /// Creates a new body in a world (free-function variant).
    /// @param | world | LWorld | The target world.
    /// @param | x | number | Initial X position.
    /// @param | y | number | Initial Y position.
    /// @param | bodyType | string | Body type: "static", "dynamic", "kinematic", or "sensor".
    /// @return | LBody | The newly created body.
    tbl.set(
        "newBody",
        lua.create_function(|lua, args: LuaMultiValue| new_body_from_lua_args(lua, args))?,
    )?;
    // -- getBody --
    /// Returns position and velocity of a body (free-function variant for quick queries).
    /// @param | world | LWorld | The world.
    /// @param | body | LBody | The body to query.
    /// @return | number | X position.
    /// @return | number | Y position.
    /// @return | number | Velocity X.
    /// @return | number | Velocity Y.
    tbl.set(
        "getBody",
        lua.create_function(
            |_, (_world_ud, body_ud): (LuaAnyUserData, LuaAnyUserData)| {
                let body = body_ud.borrow::<LuaBody>()?;
                let w = body.world.borrow();
                let (x, y) = w
                    .get_body(body.id.0)
                    .map_or((0.0_f32, 0.0_f32), |b| (b.position.x, b.position.y));
                let (vx, vy) = w
                    .get_body(body.id.0)
                    .map_or((0.0_f32, 0.0_f32), |b| (b.velocity.x, b.velocity.y));
                Ok((x, y, vx, vy))
            },
        )?,
    )?;
    // -- setBodyVelocity --
    /// Sets a body's velocity (free-function variant).
    /// @param | world | LWorld | The world.
    /// @param | body | LBody | The body.
    /// @param | vx | number | Velocity X.
    /// @param | vy | number | Velocity Y.
    tbl.set(
        "setBodyVelocity",
        lua.create_function(
            |_, (_world_ud, body_ud, vx, vy): (LuaAnyUserData, LuaAnyUserData, f32, f32)| {
                set_body_velocity_from_userdata(body_ud, vx, vy)
            },
        )?,
    )?;
    // -- isSleepingAllowed --
    /// Checks if sleeping is allowed on a body (free-function variant).
    /// @param | world | LWorld | The world.
    /// @param | body | LBody | The body.
    /// @return | boolean | True if sleeping is allowed.
    tbl.set(
        "isSleepingAllowed",
        lua.create_function(
            |_, (_world_ud, body_ud): (LuaAnyUserData, LuaAnyUserData)| {
                let body = body_ud.borrow::<LuaBody>()?;
                let allowed = body.world.borrow().is_sleeping_allowed(body.id.0);
                Ok(allowed)
            },
        )?,
    )?;
    // -- setSleepingAllowed --
    /// Sets whether a body is allowed to sleep (free-function variant).
    /// @param | world | LWorld | The world.
    /// @param | body | LBody | The body.
    /// @param | allowed | boolean | True to allow sleeping.
    tbl.set(
        "setSleepingAllowed",
        lua.create_function(
            |_, (_world_ud, body_ud, allowed): (LuaAnyUserData, LuaAnyUserData, bool)| {
                let body = body_ud.borrow::<LuaBody>()?;
                body.world
                    .borrow_mut()
                    .set_sleeping_allowed(body.id.0, allowed);
                Ok(())
            },
        )?,
    )?;
    // -- newRectangleShape --
    /// Creates a rectangle collision shape with the given dimensions.
    /// @param | w | number | Width.
    /// @param | h | number | Height.
    /// @return | LPhysicsShape | The shape object.
    tbl.set(
        "newRectangleShape",
        lua.create_function(|_, (w, h): (f32, f32)| {
            let shape = Shape::from_parts("rectangle", &[w, h], false)
                .map_err(|err| physics_runtime_error("newRectangleShape", err))?;
            Ok(LuaPhysicsShape::new(shape))
        })?,
    )?;
    // -- newCircleShape --
    /// Creates a circle collision shape with the given radius.
    /// @param | r | number | Radius.
    /// @return | LPhysicsShape | The shape object.
    tbl.set(
        "newCircleShape",
        lua.create_function(|_, r: f32| {
            let shape = Shape::from_parts("circle", &[r], false)
                .map_err(|err| physics_runtime_error("newCircleShape", err))?;
            Ok(LuaPhysicsShape::new(shape))
        })?,
    )?;
    // -- newEdgeShape --
    /// Creates an edge (line segment) collision shape between two local points.
    /// @param | x1 | number | Start X.
    /// @param | y1 | number | Start Y.
    /// @param | x2 | number | End X.
    /// @param | y2 | number | End Y.
    /// @return | LPhysicsShape | The shape object.
    tbl.set(
        "newEdgeShape",
        lua.create_function(|_, (x1, y1, x2, y2): (f32, f32, f32, f32)| {
            let shape = Shape::from_parts("edge", &[x1, y1, x2, y2], false)
                .map_err(|err| physics_runtime_error("newEdgeShape", err))?;
            Ok(LuaPhysicsShape::new(shape))
        })?,
    )?;
    // -- newPolygonShape --
    /// Creates a convex polygon collision shape from vertex coordinate pairs.
    /// @param | ... | number | Alternating x,y coordinates (minimum 3 pairs = 6 numbers).
    /// @return | LPhysicsShape | The shape object.
    tbl.set(
        "newPolygonShape",
        lua.create_function(|_, coords: mlua::Variadic<f32>| polygon_shape_from_coords(coords))?,
    )?;
    // -- newChainShape --
    /// Creates a chain (polyline) collision shape. Useful for terrain outlines.
    /// @param | closed | boolean | If true, connects last vertex to first.
    /// @param | ... | number | Alternating x,y coordinates (minimum 2 pairs = 4 numbers).
    /// @return | LPhysicsShape | The shape object.
    tbl.set(
        "newChainShape",
        lua.create_function(|_, (closed, coords): (bool, mlua::Variadic<f32>)| {
            chain_shape_from_coords(closed, coords)
        })?,
    )?;
    // -- shapeFromImage --
    /// Builds an approximate collision shape from an image alpha mask.
    /// @param | image | LImageData | Source image; pixels with alpha above threshold are treated as solid.
    /// @param | opts | table? | Optional keys: alphaThreshold, maxVertices, circleAspectTolerance, circleFillTolerance, rectangleFillThreshold.
    /// @return | LPhysicsShape | Circle, rectangle, or convex polygon approximating the opaque pixels.
    tbl.set(
        "shapeFromImage",
        lua.create_function(|_, (image_ud, opts): (LuaAnyUserData, Option<LuaTable>)| {
            let image = image_ud.borrow::<ImageData>()?;
            let options = alpha_shape_options_from_lua(opts)?;
            let shape = Shape::from_image_alpha(&image, options)
                .map_err(|err| physics_runtime_error("shapeFromImage", err))?;
            Ok(LuaPhysicsShape::new(shape))
        })?,
    )?;
    // -- attachShape --
    /// Attaches a previously created shape to a body, using the shape's stored material properties.
    /// @param | body | LBody | The target body.
    /// @param | shape | LPhysicsShape | The shape to attach.
    tbl.set(
        "attachShape",
        lua.create_function(|_, (body_ud, shape_ud): (LuaAnyUserData, LuaAnyUserData)| {
            let body = body_ud.borrow::<LuaBody>()?;
            let shape_lua = shape_ud.borrow::<LuaPhysicsShape>()?;
            let d = shape_lua.inner.borrow();
            body.world
                .borrow_mut()
                .try_add_fixture(
                    body.id.0,
                    d.shape.clone(),
                    d.density,
                    d.friction,
                    d.restitution,
                    d.sensor,
                )
                .map_err(|err| physics_runtime_error("attachShape", err))?;
            Ok(())
        })?,
    )?;
    // -- getCollisions --
    /// Returns all collision events from the last world step as {body_a, body_b} pairs.
    /// @param | world | LWorld | The world to query.
    /// @return | table | Array of collision event tables.
    /// @field | body_a | integer | Body A id.
    /// @field | body_b | integer | Body B id.
    tbl.set(
        "getCollisions",
        lua.create_function(|lua, world_ud: LuaAnyUserData| {
            let world_lua = world_ud.borrow::<LuaWorld>()?;
            let world = world_lua.world.borrow();
            collision_events_to_table(lua, world.get_collision_events())
        })?,
    )?;
    // -- debugDraw --
    /// Enables or disables automatic physics debug overlay rendering for the next frame.
    /// @param | enable | boolean | True to show debug shapes.
    let s = state.clone();
    tbl.set(
        "debugDraw",
        lua.create_function(move |_, enable: bool| {
            s.borrow_mut().physics_run.debug_draw = enable;
            Ok(())
        })?,
    )?;
    // -- drawDebugGpu --
    /// Queues a GPU-rendered physics debug visualization using the world's current body state.
    /// @param | world | LWorld | The world to visualize.
    /// @param | config | table? | Optional config: {bodyColor, staticColor, sleepColor, sensorColor, lineWidth}.
    let s = state.clone();
    tbl.set(
        "drawDebugGpu",
        lua.create_function(
            move |_, (world_ud, config_val): (LuaAnyUserData, LuaValue)| {
                let world_ref = world_ud.borrow::<LuaWorld>()?;
                push_physics_debug_draw(&s, &world_ref, config_val);
                Ok(())
            },
        )?,
    )?;
    // -- newTerrain --
    /// Creates a destructible terrain grid linked to a physics world for automatic collider generation.
    /// @param | width | integer | Grid width in cells.
    /// @param | height | integer | Grid height in cells.
    /// @param | cellSize | number | World-space size of each cell.
    /// @param | world | LWorld | The physics world that will own the generated colliders.
    /// @return | LTerrain | The terrain object.
    tbl.set(
        "newTerrain",
        lua.create_function({
            move |_, (width, height, cell_size, world_ud): (u32, u32, f32, mlua::AnyUserData)| {
                let world_handle: std::cell::Ref<LuaWorld> = world_ud.borrow::<LuaWorld>()?;
                let terrain = TerrainMap::try_new(width, height, cell_size)
                    .map_err(|err| physics_runtime_error("newTerrain", err))?;
                Ok(LuaTerrain {
                    terrain: Rc::new(RefCell::new(terrain)),
                    world: world_handle.world.clone(),
                })
            }
        })?,
    )?;
    // -- testAABB --
    /// Tests whether two axis-aligned bounding boxes overlap. Lightweight collision check without physics world.
    /// @param | ax | number | First rect X.
    /// @param | ay | number | First rect Y.
    /// @param | aw | number | First rect width.
    /// @param | ah | number | First rect height.
    /// @param | bx | number | Second rect X.
    /// @param | by | number | Second rect Y.
    /// @param | bw | number | Second rect width.
    /// @param | bh | number | Second rect height.
    /// @return | boolean | True if the rectangles overlap.
    tbl.set(
        "testAABB",
        lua.create_function(
            |_, (ax, ay, aw, ah, bx, by, bw, bh): (f32, f32, f32, f32, f32, f32, f32, f32)| {
                Ok(crate::physics::collision_helpers::test_aabb(
                    ax, ay, aw, ah, bx, by, bw, bh,
                ))
            },
        )?,
    )?;
    // -- testCircles --
    /// Tests whether two circles overlap. Lightweight collision check without physics world.
    /// @param | ax | number | First circle center X.
    /// @param | ay | number | First circle center Y.
    /// @param | ar | number | First circle radius.
    /// @param | bx | number | Second circle center X.
    /// @param | by | number | Second circle center Y.
    /// @param | br | number | Second circle radius.
    /// @return | boolean | True if the circles overlap.
    tbl.set(
        "testCircles",
        lua.create_function(
            |_, (ax, ay, ar, bx, by, br): (f32, f32, f32, f32, f32, f32)| {
                Ok(crate::physics::collision_helpers::test_circles(
                    ax, ay, ar, bx, by, br,
                ))
            },
        )?,
    )?;
    // -- testPoint --
    /// Tests whether a point lies inside an AABB. Lightweight check without physics world.
    /// @param | px | number | Point X.
    /// @param | py | number | Point Y.
    /// @param | ax | number | Rect X.
    /// @param | ay | number | Rect Y.
    /// @param | aw | number | Rect width.
    /// @param | ah | number | Rect height.
    /// @return | boolean | True if the point is inside.
    tbl.set(
        "testPoint",
        lua.create_function(
            |_, (px, py, ax, ay, aw, ah): (f32, f32, f32, f32, f32, f32)| {
                Ok(crate::physics::collision_helpers::test_point_aabb(
                    px, py, ax, ay, aw, ah,
                ))
            },
        )?,
    )?;
    // -- testCircleAABB --
    /// Tests whether a circle overlaps an AABB. Lightweight check without physics world.
    /// @param | cx | number | Circle center X.
    /// @param | cy | number | Circle center Y.
    /// @param | cr | number | Circle radius.
    /// @param | ax | number | Rect X.
    /// @param | ay | number | Rect Y.
    /// @param | aw | number | Rect width.
    /// @param | ah | number | Rect height.
    /// @return | boolean | True if circle and AABB overlap.
    tbl.set(
        "testCircleAABB",
        lua.create_function(
            |_, (cx, cy, cr, ax, ay, aw, ah): (f32, f32, f32, f32, f32, f32, f32)| {
                Ok(crate::physics::collision_helpers::test_circle_aabb(
                    cx, cy, cr, ax, ay, aw, ah,
                ))
            },
        )?,
    )?;
    luna.set("physics", tbl)?;
    Ok(())
}
