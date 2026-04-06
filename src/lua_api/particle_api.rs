//! `luna.particle` — Emitter-based 2D particle systems and trail ribbons.

use super::SharedState;
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

use crate::engine::resource_keys::ParticleKey;
use crate::particle::{
    AreaDistribution, EmissionShape, InsertMode, ParticleConfig, ParticleShape, ParticleSystem,
    RelativeMode, Trail,
};

// -------------------------------------------------------------------------------
// Config table → ParticleConfig marshalling
// -------------------------------------------------------------------------------

/// Reads Lua-table keys into a `ParticleConfig`, falling back to defaults.
fn config_from_table(t: &LuaTable) -> LuaResult<ParticleConfig> {
    let mut c = ParticleConfig::default();
    if let Ok(v) = t.get::<_, u32>("maxParticles") {
        c.max_particles = v;
    }
    if let Ok(v) = t.get::<_, f32>("emissionRate") {
        c.emission_rate = v;
    }
    if let Ok(v) = t.get::<_, f32>("lifetimeMin") {
        c.lifetime_min = v;
    }
    if let Ok(v) = t.get::<_, f32>("lifetimeMax") {
        c.lifetime_max = v;
    }
    if let Ok(v) = t.get::<_, f32>("speedMin") {
        c.speed_min = v;
    }
    if let Ok(v) = t.get::<_, f32>("speedMax") {
        c.speed_max = v;
    }
    if let Ok(v) = t.get::<_, f32>("direction") {
        c.direction = v;
    }
    if let Ok(v) = t.get::<_, f32>("spread") {
        c.spread = v;
    }
    if let Ok(v) = t.get::<_, f32>("gravityX") {
        c.gravity_x = v;
    }
    if let Ok(v) = t.get::<_, f32>("gravityY") {
        c.gravity_y = v;
    }
    if let Ok(v) = t.get::<_, f32>("spinMin") {
        c.spin_min = v;
    }
    if let Ok(v) = t.get::<_, f32>("spinMax") {
        c.spin_max = v;
    }
    if let Ok(v) = t.get::<_, f32>("spinVariation") {
        c.spin_variation = v;
    }
    if let Ok(v) = t.get::<_, f32>("sizeVariation") {
        c.size_variation = v;
    }
    if let Ok(v) = t.get::<_, f32>("rotationMin") {
        c.rotation_min = v;
    }
    if let Ok(v) = t.get::<_, f32>("rotationMax") {
        c.rotation_max = v;
    }
    if let Ok(v) = t.get::<_, f32>("emitterLifetime") {
        c.emitter_lifetime = v;
    }
    if let Ok(v) = t.get::<_, f32>("linearAccelXMin") {
        c.linear_accel_x_min = v;
    }
    if let Ok(v) = t.get::<_, f32>("linearAccelXMax") {
        c.linear_accel_x_max = v;
    }
    if let Ok(v) = t.get::<_, f32>("linearAccelYMin") {
        c.linear_accel_y_min = v;
    }
    if let Ok(v) = t.get::<_, f32>("linearAccelYMax") {
        c.linear_accel_y_max = v;
    }
    if let Ok(v) = t.get::<_, f32>("radialAccelMin") {
        c.radial_accel_min = v;
    }
    if let Ok(v) = t.get::<_, f32>("radialAccelMax") {
        c.radial_accel_max = v;
    }
    if let Ok(v) = t.get::<_, f32>("tangentialAccelMin") {
        c.tangential_accel_min = v;
    }
    if let Ok(v) = t.get::<_, f32>("tangentialAccelMax") {
        c.tangential_accel_max = v;
    }
    if let Ok(v) = t.get::<_, f32>("linearDampingMin") {
        c.linear_damping_min = v;
    }
    if let Ok(v) = t.get::<_, f32>("linearDampingMax") {
        c.linear_damping_max = v;
    }
    if let Ok(v) = t.get::<_, f32>("areaWidth") {
        c.area_width = v;
    }
    if let Ok(v) = t.get::<_, f32>("areaHeight") {
        c.area_height = v;
    }
    if let Ok(v) = t.get::<_, f32>("areaAngle") {
        c.area_angle = v;
    }
    if let Ok(v) = t.get::<_, bool>("areaDirectionRelative") {
        c.area_direction_relative = v;
    }
    if let Ok(v) = t.get::<_, bool>("relativeRotation") {
        c.relative_rotation = v;
    }
    if let Ok(v) = t.get::<_, f32>("offsetX") {
        c.offset_x = v;
    }
    if let Ok(v) = t.get::<_, f32>("offsetY") {
        c.offset_y = v;
    }
    if let Ok(v) = t.get::<_, f32>("turbulence") {
        c.turbulence = v;
    }
    if let Ok(v) = t.get::<_, f32>("drag") {
        c.drag = v;
    }
    if let Ok(v) = t.get::<_, f32>("orbitSpeed") {
        c.orbit_speed = v;
    }
    if let Ok(v) = t.get::<_, u32>("animatedFrames") {
        c.animated_frames = v;
    }
    if let Ok(v) = t.get::<_, f32>("frameRate") {
        c.frame_rate = v;
    }
    if let Ok(v) = t.get::<_, bool>("colorBySpeed") {
        c.color_by_speed = v;
    }
    if let Ok(v) = t.get::<_, f32>("speedColorMin") {
        c.speed_color_min = v;
    }
    if let Ok(v) = t.get::<_, f32>("speedColorMax") {
        c.speed_color_max = v;
    }

    // sizes: table of floats
    if let Ok(st) = t.get::<_, LuaTable>("sizes") {
        let mut sizes = Vec::new();
        for i in 1..=32 {
            match st.get::<_, f32>(i) {
                Ok(v) => sizes.push(v),
                Err(_) => break,
            }
        }
        if !sizes.is_empty() {
            c.sizes = sizes;
        }
    }

    // colors: table of {r, g, b, a}
    if let Ok(ct) = t.get::<_, LuaTable>("colors") {
        let mut colors = Vec::new();
        for i in 1..=16 {
            match ct.get::<_, LuaTable>(i) {
                Ok(entry) => {
                    let r = entry.get::<_, f32>(1).unwrap_or(1.0);
                    let g = entry.get::<_, f32>(2).unwrap_or(1.0);
                    let b = entry.get::<_, f32>(3).unwrap_or(1.0);
                    let a = entry.get::<_, f32>(4).unwrap_or(1.0);
                    colors.push([r, g, b, a]);
                }
                Err(_) => break,
            }
        }
        if !colors.is_empty() {
            c.colors = colors;
        }
    }

    // alphaKeyframes: table of floats
    if let Ok(at) = t.get::<_, LuaTable>("alphaKeyframes") {
        let mut alphas = Vec::new();
        for i in 1..=16 {
            match at.get::<_, f32>(i) {
                Ok(v) => alphas.push(v),
                Err(_) => break,
            }
        }
        if !alphas.is_empty() {
            c.alpha_keyframes = alphas;
        }
    }

    // areaDistribution: string → enum
    if let Ok(v) = t.get::<_, String>("areaDistribution") {
        c.area_distribution = match v.as_str() {
            "uniform" => AreaDistribution::Uniform,
            "normal" => AreaDistribution::Normal,
            "ellipse" => AreaDistribution::Ellipse,
            "borderRectangle" => AreaDistribution::BorderRectangle,
            "borderEllipse" => AreaDistribution::BorderEllipse,
            _ => AreaDistribution::default(),
        };
    }

    // insertMode: string → enum
    if let Ok(v) = t.get::<_, String>("insertMode") {
        c.insert_mode = match v.as_str() {
            "top" => InsertMode::Top,
            "bottom" => InsertMode::Bottom,
            "random" => InsertMode::Random,
            _ => InsertMode::default(),
        };
    }

    // emissionShape: string → enum
    if let Ok(v) = t.get::<_, String>("emissionShape") {
        c.emission_shape = match v.as_str() {
            "point" => EmissionShape::Point,
            "circle" => EmissionShape::Circle {
                radius: 50.0,
                fill: true,
            },
            "rectangle" => EmissionShape::Rectangle {
                width: 100.0,
                height: 100.0,
            },
            "ring" => EmissionShape::Ring {
                inner_radius: 20.0,
                outer_radius: 50.0,
            },
            "line" => EmissionShape::Line {
                length: 100.0,
                angle: 0.0,
            },
            "cone" => EmissionShape::Cone {
                radius: 50.0,
                angle: 0.0,
                spread: 0.5,
            },
            "star" => EmissionShape::Star {
                points: 5,
                outer_radius: 50.0,
                inner_radius: 25.0,
            },
            "spiral" => EmissionShape::Spiral {
                revolutions: 2.0,
                radius: 50.0,
            },
            _ => EmissionShape::default(),
        };
    }

    // relativeMode: string → enum
    if let Ok(v) = t.get::<_, String>("relativeMode") {
        c.relative_mode = match v.as_str() {
            "attached" => RelativeMode::Attached,
            _ => RelativeMode::Detached,
        };
    }

    // shape: string → ParticleShape
    if let Ok(v) = t.get::<_, String>("shape") {
        c.shape = match v.as_str() {
            "square" => ParticleShape::Square,
            "circle" => ParticleShape::Circle,
            "triangle" => ParticleShape::Triangle,
            "spark" => ParticleShape::Spark,
            "diamond" => ParticleShape::Diamond,
            _ => ParticleShape::Square,
        };
    }

    Ok(c)
}

// -------------------------------------------------------------------------------
// LuaParticleSystem UserData
// -------------------------------------------------------------------------------

/// Lua-side handle to a particle system stored in SharedState.
#[derive(Clone)]
pub struct LuaParticleSystem {
    pub(crate) state: Rc<RefCell<SharedState>>,
    pub(crate) key: ParticleKey,
}

impl LuaUserData for LuaParticleSystem {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- update --
        /// Advances the particle simulation by dt seconds.
        /// @param dt : number
        /// @return nil
        methods.add_method("update", |_, this, dt: f32| {
            let mut st = this.state.borrow_mut();
            if let Some(ps) = st.particle_systems.get_mut(this.key) {
                ps.update(dt);
            }
            Ok(())
        });

        // -- emit --
        /// Emits a burst of the given number of particles.
        /// @param count : integer
        /// @return nil
        methods.add_method("emit", |_, this, count: u32| {
            let mut st = this.state.borrow_mut();
            if let Some(ps) = st.particle_systems.get_mut(this.key) {
                ps.emit(count);
            }
            Ok(())
        });

        // -- start --
        /// Starts or restarts particle emission.
        /// @return nil
        methods.add_method("start", |_, this, ()| {
            let mut st = this.state.borrow_mut();
            if let Some(ps) = st.particle_systems.get_mut(this.key) {
                ps.start();
            }
            Ok(())
        });

        // -- stop --
        /// Stops particle emission immediately.
        /// @return nil
        methods.add_method("stop", |_, this, ()| {
            let mut st = this.state.borrow_mut();
            if let Some(ps) = st.particle_systems.get_mut(this.key) {
                ps.stop();
            }
            Ok(())
        });

        // -- pause --
        /// Pauses the emitter.
        /// @return nil
        methods.add_method("pause", |_, this, ()| {
            let mut st = this.state.borrow_mut();
            if let Some(ps) = st.particle_systems.get_mut(this.key) {
                ps.pause();
            }
            Ok(())
        });

        // -- resume --
        /// Resumes a paused emitter.
        /// @return nil
        methods.add_method("resume", |_, this, ()| {
            let mut st = this.state.borrow_mut();
            if let Some(ps) = st.particle_systems.get_mut(this.key) {
                ps.resume();
            }
            Ok(())
        });

        // -- reset --
        /// Removes all particles and resets the emitter.
        /// @return nil
        methods.add_method("reset", |_, this, ()| {
            let mut st = this.state.borrow_mut();
            if let Some(ps) = st.particle_systems.get_mut(this.key) {
                ps.reset();
            }
            Ok(())
        });

        // -- moveTo --
        /// Moves the emitter to the given world position.
        /// @param x : number
        /// @param y : number
        /// @return nil
        methods.add_method("moveTo", |_, this, (x, y): (f32, f32)| {
            let mut st = this.state.borrow_mut();
            if let Some(ps) = st.particle_systems.get_mut(this.key) {
                ps.move_to(x, y);
            }
            Ok(())
        });

        // -- count --
        /// Returns the number of living particles.
        /// @return integer
        methods.add_method("count", |_, this, ()| {
            let st = this.state.borrow();
            Ok(st.particle_systems.get(this.key).map_or(0, |ps| ps.count()))
        });

        // -- isActive --
        /// Returns true if the emitter is currently emitting or has live particles.
        /// @return boolean
        methods.add_method("isActive", |_, this, ()| {
            let st = this.state.borrow();
            Ok(st
                .particle_systems
                .get(this.key)
                .map_or(false, |ps| ps.is_active()))
        });

        // -- isPaused --
        /// Returns true if the emitter is paused.
        /// @return boolean
        methods.add_method("isPaused", |_, this, ()| {
            let st = this.state.borrow();
            Ok(st
                .particle_systems
                .get(this.key)
                .map_or(false, |ps| ps.is_paused()))
        });

        // -- isStopped --
        /// Returns true if the emitter is stopped.
        /// @return boolean
        methods.add_method("isStopped", |_, this, ()| {
            let st = this.state.borrow();
            Ok(st
                .particle_systems
                .get(this.key)
                .map_or(true, |ps| ps.is_stopped()))
        });

        // -- isEmpty --
        /// Returns true if there are no live particles.
        /// @return boolean
        methods.add_method("isEmpty", |_, this, ()| {
            let st = this.state.borrow();
            Ok(st
                .particle_systems
                .get(this.key)
                .map_or(true, |ps| ps.is_empty()))
        });

        // -- isFull --
        /// Returns true if the system has reached max_particles.
        /// @return boolean
        methods.add_method("isFull", |_, this, ()| {
            let st = this.state.borrow();
            Ok(st
                .particle_systems
                .get(this.key)
                .map_or(false, |ps| ps.is_full()))
        });

        // -- release --
        /// Removes the particle system from the engine, freeing its slot.
        /// @return nil
        methods.add_method("release", |_, this, ()| {
            let mut st = this.state.borrow_mut();
            st.particle_systems.remove(this.key);
            Ok(())
        });
    }
}

// -------------------------------------------------------------------------------
// LuaTrail UserData
// -------------------------------------------------------------------------------

/// Lua-side wrapper around a [`Trail`] ribbon effect.
pub struct LuaTrail {
    inner: Trail,
}

impl LuaUserData for LuaTrail {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- pushPoint --
        /// Appends a new point to the trail head.
        /// @param x : number
        /// @param y : number
        /// @return nil
        methods.add_method_mut("pushPoint", |_, this, (x, y): (f32, f32)| {
            this.inner.push_point(x, y);
            Ok(())
        });

        // -- update --
        /// Ages trail points and removes expired ones.
        /// @param dt : number
        /// @return nil
        methods.add_method_mut("update", |_, this, dt: f32| {
            this.inner.update(dt);
            Ok(())
        });

        // -- setWidth --
        /// Sets the start and end width of the trail ribbon.
        /// @param start_width : number
        /// @param end_width : number
        /// @return nil
        methods.add_method_mut("setWidth", |_, this, (start, end): (f32, Option<f32>)| {
            this.inner.set_width(start, end);
            Ok(())
        });

        // -- getWidth --
        /// Returns the start and end width.
        /// @return number, number
        methods.add_method("getWidth", |_, this, ()| Ok(this.inner.get_width()));

        // -- setLifetime --
        /// Sets how long each trail point persists in seconds.
        /// @param lifetime : number
        /// @return nil
        methods.add_method_mut("setLifetime", |_, this, lifetime: f32| {
            this.inner.set_lifetime(lifetime);
            Ok(())
        });

        // -- getLifetime --
        /// Returns the trail point lifetime in seconds.
        /// @return number
        methods.add_method("getLifetime", |_, this, ()| Ok(this.inner.get_lifetime()));

        // -- setMinDistance --
        /// Sets the minimum distance between trail points.
        /// @param distance : number
        /// @return nil
        methods.add_method_mut("setMinDistance", |_, this, distance: f32| {
            this.inner.set_min_distance(distance);
            Ok(())
        });

        // -- setHeadColor --
        /// Sets the colour at the newest end of the trail.
        /// @param r : number
        /// @param g : number
        /// @param b : number
        /// @param a : number
        /// @return nil
        methods.add_method_mut(
            "setHeadColor",
            |_, this, (r, g, b, a): (f32, f32, f32, f32)| {
                this.inner
                    .set_head_color(crate::math::color::Color::new(r, g, b, a));
                Ok(())
            },
        );

        // -- setTailColor --
        /// Sets the colour at the oldest end of the trail.
        /// @param r : number
        /// @param g : number
        /// @param b : number
        /// @param a : number
        /// @return nil
        methods.add_method_mut(
            "setTailColor",
            |_, this, (r, g, b, a): (f32, f32, f32, f32)| {
                this.inner
                    .set_tail_color(crate::math::color::Color::new(r, g, b, a));
                Ok(())
            },
        );

        // -- getPointCount --
        /// Returns the number of active trail points.
        /// @return integer
        methods.add_method("getPointCount", |_, this, ()| {
            Ok(this.inner.get_point_count())
        });

        // -- clear --
        /// Removes all trail points.
        /// @return nil
        methods.add_method_mut("clear", |_, this, ()| {
            this.inner.clear();
            Ok(())
        });
    }
}

// -------------------------------------------------------------------------------
// Register
// -------------------------------------------------------------------------------

/// Registers the `luna.particle` API table with the Lua VM.
pub fn register(lua: &Lua, luna: &LuaTable, state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;

    // -- newSystem --
    /// Creates a new particle system and stores it in the engine pool.
    /// @param config : table
    /// @return ParticleSystem
    let s = state.clone();
    tbl.set(
        "newSystem",
        lua.create_function(move |lua, config: Option<LuaTable>| {
            let cfg = match config {
                Some(t) => config_from_table(&t)?,
                None => ParticleConfig::default(),
            };
            let ps = ParticleSystem::new(cfg);
            let mut st = s.borrow_mut();
            let key = st.particle_systems.insert(ps);
            lua.create_userdata(LuaParticleSystem {
                state: s.clone(),
                key,
            })
        })?,
    )?;

    // -- newTrail --
    /// Creates a new trail ribbon effect.
    /// @param lifetime : number
    /// @param start_width : number
    /// @return Trail
    tbl.set(
        "newTrail",
        lua.create_function(|lua, (lifetime, start_width): (f32, f32)| {
            lua.create_userdata(LuaTrail {
                inner: Trail::new(lifetime, start_width),
            })
        })?,
    )?;

    luna.set("particle", tbl)?;
    Ok(())
}
