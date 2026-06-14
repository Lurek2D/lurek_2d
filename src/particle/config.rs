//! Runtime configuration for particle emitters and their tunable behavior.
//! Carries spawn distribution, insertion order, state, and coordinate mode settings.
//! Describes emission shapes from point and circle to cone, star, spiral, and custom callbacks.
//! Includes attractor and bounce helper types for motion control.
//! Covers world-space versus emitter-attached spawning rules.
//! Packs every serializable knob into one config object for scripts and data files.
//! Serves as the authored contract for building particle systems.

use super::shapes::ParticleShape;
use crate::runtime::resource_keys::TextureKey;

const MIN_PARTICLE_LIFETIME: f32 = 1.0e-4;

fn finite_or(value: f32, fallback: f32) -> f32 {
    if value.is_finite() {
        value
    } else {
        fallback
    }
}

fn non_negative_finite_or(value: f32, fallback: f32) -> f32 {
    finite_or(value, fallback).max(0.0)
}

/// Controls how particles are distributed across the emitter's area when `area_width`/`area_height` > 0.
#[derive(Clone, Debug, Default, PartialEq, serde::Serialize, serde::Deserialize)]
pub enum AreaDistribution {
    /// No area distribution; all particles spawn at the emitter origin.
    #[default]
    None,
    /// Uniform random distribution across the full area rectangle.
    Uniform,
    /// Gaussian distribution centred on the emitter origin.
    Normal,
    /// Uniform distribution within an ellipse defined by `area_width`/`area_height`.
    Ellipse,
    /// Uniform distribution on the border of an ellipse.
    BorderEllipse,
    /// Uniform distribution on the border of the area rectangle.
    BorderRectangle,
}
/// Determines which end of the particle pool receives newly spawned particles.
#[derive(Clone, Debug, Default, PartialEq, serde::Serialize, serde::Deserialize)]
pub enum InsertMode {
    /// Insert at the front of the pool (default).
    #[default]
    Top,
    /// Insert at the back of the pool.
    Bottom,
    /// Insert at a random position in the pool.
    Random,
}
/// Current operating state of a `ParticleSystem`.
#[derive(Clone, Debug, PartialEq, serde::Serialize, serde::Deserialize)]
pub enum EmitterState {
    /// Spawning and updating particles.
    Active,
    /// Update loop runs but no new particles are spawned.
    Paused,
    /// No update; particles remain frozen at current state.
    Stopped,
}
/// Geometric shape used to distribute spawn positions across the emitter area.
#[derive(Clone, Debug, Default, PartialEq, serde::Serialize, serde::Deserialize)]
pub enum EmissionShape {
    /// All particles spawn at the emitter origin.
    #[default]
    Point,
    /// Spawn within or on the border of a circle.
    Circle {
        /// Circle radius in pixels.
        radius: f32,
        /// When `true` fill the interior; `false` spawns on the circumference.
        fill: bool,
    },
    /// Spawn within an axis-aligned rectangle.
    Rectangle {
        /// Rectangle width in pixels.
        width: f32,
        /// Rectangle height in pixels.
        height: f32,
    },
    /// Spawn in an annular ring between two radii.
    Ring {
        /// Inner exclusion radius in pixels.
        inner_radius: f32,
        /// Outer spawn radius in pixels.
        outer_radius: f32,
    },
    /// Spawn uniformly along a directed line segment.
    Line {
        /// Line length in pixels.
        length: f32,
        /// Line angle in radians.
        angle: f32,
    },
    /// Spawn in a cone volume directed toward `direction` with the given `spread`.
    Cone {
        /// Cone length in pixels.
        radius: f32,
        /// Centre direction of the cone in radians.
        angle: f32,
        /// Half-angle spread of the cone in radians.
        spread: f32,
    },
    /// Spawn on the outline of a star polygon.
    Star {
        /// Number of star points.
        points: u32,
        /// Outer tip radius in pixels.
        outer_radius: f32,
        /// Inner notch radius in pixels.
        inner_radius: f32,
    },
    /// Spawn along an Archimedean spiral.
    Spiral {
        /// Number of full turns.
        revolutions: f32,
        /// Maximum spiral radius in pixels.
        radius: f32,
    },
    /// Spawn positions driven by a Lua callback identified by `callback_id`.
    Custom {
        /// Opaque identifier registered via the Lua API.
        callback_id: u32,
    },
}
/// Controls whether particles move relative to the emitter transform or the world.
#[derive(Clone, Debug, Default, PartialEq, serde::Serialize, serde::Deserialize)]
pub enum RelativeMode {
    /// Particles detach from the emitter on spawn; they move in world space.
    #[default]
    Detached,
    /// Particles stay attached; they inherit emitter movement after spawn.
    Attached,
}
/// Point attractor that pulls or pushes particles within a radius.
#[derive(Clone, Debug, PartialEq)]
pub struct Attractor {
    /// World-space X position of the attractor.
    pub x: f32,
    /// World-space Y position of the attractor.
    pub y: f32,
    /// Attraction force magnitude; negative values repel.
    pub strength: f32,
    /// Radius of influence in pixels; particles outside are unaffected.
    pub radius: f32,
}
/// Axis-aligned bounce boundary that reflects particles on collision.
#[derive(Clone, Debug, PartialEq)]
pub struct BounceBounds {
    /// Left boundary X in pixels.
    pub x_min: f32,
    /// Right boundary X in pixels.
    pub x_max: f32,
    /// Top boundary Y in pixels.
    pub y_min: f32,
    /// Bottom boundary Y in pixels.
    pub y_max: f32,
    /// Velocity retention factor on bounce, in `[0.0, 1.0]`.
    pub restitution: f32,
}
/// All tunable parameters for a particle emitter; serialisable to/from TOML.
#[derive(Clone, Debug, serde::Serialize, serde::Deserialize)]
#[serde(default)]
pub struct ParticleConfig {
    /// Maximum live particles kept in the pool at any time.
    pub max_particles: u32,
    /// New particles spawned per second.
    pub emission_rate: f32,
    /// Minimum particle lifetime in seconds.
    pub lifetime_min: f32,
    /// Maximum particle lifetime in seconds.
    pub lifetime_max: f32,
    /// Minimum initial speed in pixels per second.
    pub speed_min: f32,
    /// Maximum initial speed in pixels per second.
    pub speed_max: f32,
    /// Mean emission direction in radians (0 = right, -PI/2 = up).
    pub direction: f32,
    /// Half-angle spread around `direction` in radians.
    pub spread: f32,
    /// Constant X gravity force applied each second.
    pub gravity_x: f32,
    /// Constant Y gravity force applied each second.
    pub gravity_y: f32,
    /// Size keyframes interpolated over particle lifetime; at least one value required.
    pub sizes: Vec<f32>,
    /// RGBA colour keyframes interpolated over particle lifetime.
    pub colors: Vec<[f32; 4]>,
    /// Minimum angular velocity in radians per second.
    pub spin_min: f32,
    /// Maximum angular velocity in radians per second.
    pub spin_max: f32,
    /// Minimum initial rotation in radians.
    pub rotation_min: f32,
    /// Maximum initial rotation in radians.
    pub rotation_max: f32,
    /// Per-particle random spin offset added to the base spin range.
    pub spin_variation: f32,
    /// Per-particle random size multiplier offset.
    pub size_variation: f32,
    /// Minimum constant X linear acceleration in pixels/sec^2.
    pub linear_accel_x_min: f32,
    /// Maximum constant X linear acceleration in pixels/sec^2.
    pub linear_accel_x_max: f32,
    /// Minimum constant Y linear acceleration in pixels/sec^2.
    pub linear_accel_y_min: f32,
    /// Maximum constant Y linear acceleration in pixels/sec^2.
    pub linear_accel_y_max: f32,
    /// Minimum radial (away-from-origin) acceleration in pixels/sec^2.
    pub radial_accel_min: f32,
    /// Maximum radial acceleration in pixels/sec^2.
    pub radial_accel_max: f32,
    /// Minimum tangential (perpendicular-to-radial) acceleration in pixels/sec^2.
    pub tangential_accel_min: f32,
    /// Maximum tangential acceleration in pixels/sec^2.
    pub tangential_accel_max: f32,
    /// Minimum linear damping coefficient (velocity multiplied by `1 - damping * dt`).
    pub linear_damping_min: f32,
    /// Maximum linear damping coefficient.
    pub linear_damping_max: f32,
    /// Distribution strategy used when spawning across the emitter area.
    pub area_distribution: AreaDistribution,
    /// Width of the spawn area in pixels.
    pub area_width: f32,
    /// Height of the spawn area in pixels.
    pub area_height: f32,
    /// Rotation of the spawn area in radians.
    pub area_angle: f32,
    /// When `true` initial velocity direction is relative to the spawn area orientation.
    pub area_direction_relative: bool,
    /// Total emitter lifetime in seconds; negative means infinite.
    pub emitter_lifetime: f32,
    /// Optional RNG seed used to make particle emission and evolution deterministic.
    pub seed: Option<u64>,
    /// Controls insertion position in the particle pool when spawning.
    pub insert_mode: InsertMode,
    /// X offset applied to spawn positions relative to the emitter position.
    pub offset_x: f32,
    /// Y offset applied to spawn positions relative to the emitter position.
    pub offset_y: f32,
    /// When `true` particles inherit the emitter's current rotation.
    pub relative_rotation: bool,
    /// Texture used to render particles; `None` falls back to a unit square.
    #[serde(skip)]
    /// Texture id.
    pub texture_id: Option<TextureKey>,
    /// Sub-texture quads `[x, y, w, h]` for sprite-sheet animation.
    pub quads: Vec<[f32; 4]>,
    /// Alpha multiplier keyframes interpolated over lifetime in addition to `colors` alpha.
    pub alpha_keyframes: Vec<f32>,
    /// Geometric shape that determines spawn-position distribution.
    pub emission_shape: EmissionShape,
    /// Whether particles are world-space detached or emitter-attached.
    pub relative_mode: RelativeMode,
    /// Turbulence noise strength applied to particle velocity each frame.
    pub turbulence: f32,
    /// Drag coefficient reducing speed proportionally each frame.
    pub drag: f32,
    /// Angular orbit speed around the emitter origin in radians per second.
    pub orbit_speed: f32,
    /// Number of sprite-sheet animation frames; 0 disables animation.
    pub animated_frames: u32,
    /// Sprite-sheet frame rate in frames per second.
    pub frame_rate: f32,
    /// When `true` tint colour is driven by particle speed instead of keyframes.
    pub color_by_speed: bool,
    /// Speed value mapped to the first colour keyframe.
    pub speed_color_min: f32,
    /// Speed value mapped to the last colour keyframe.
    pub speed_color_max: f32,
    /// Render shape for each particle: point, circle, rectangle, etc.
    pub shape: ParticleShape,
    /// Optional sub-emitter spawned when a particle dies.
    pub death_emitter: Option<Box<ParticleConfig>>,
    /// Number of particles spawned from the death sub-emitter.
    pub death_burst_count: u32,
    /// Number of edges for shrapnel polygon render shape.
    pub shrapnel_edges: u8,
    /// Width-to-height ratio for ray render shape.
    pub ray_aspect: f32,
    /// Ring thickness expressed as a fraction of the outer radius in `[0.0, 1.0]`.
    pub ring_thickness: f32,
}
/// Provide sensible starting values for a general-purpose upward particle fountain.
impl Default for ParticleConfig {
    fn default() -> Self {
        Self {
            max_particles: 256,
            emission_rate: 10.0,
            lifetime_min: 1.0,
            lifetime_max: 2.0,
            speed_min: 50.0,
            speed_max: 100.0,
            direction: -std::f32::consts::FRAC_PI_2,
            spread: std::f32::consts::FRAC_PI_4,
            gravity_x: 0.0,
            gravity_y: 0.0,
            sizes: vec![4.0, 1.0],
            colors: vec![[1.0, 1.0, 1.0, 1.0], [1.0, 1.0, 1.0, 0.0]],
            spin_min: 0.0,
            spin_max: 0.0,
            rotation_min: 0.0,
            rotation_max: 0.0,
            spin_variation: 0.0,
            size_variation: 0.0,
            linear_accel_x_min: 0.0,
            linear_accel_x_max: 0.0,
            linear_accel_y_min: 0.0,
            linear_accel_y_max: 0.0,
            radial_accel_min: 0.0,
            radial_accel_max: 0.0,
            tangential_accel_min: 0.0,
            tangential_accel_max: 0.0,
            linear_damping_min: 0.0,
            linear_damping_max: 0.0,
            area_distribution: AreaDistribution::None,
            area_width: 0.0,
            area_height: 0.0,
            area_angle: 0.0,
            area_direction_relative: false,
            emitter_lifetime: -1.0,
            seed: None,
            insert_mode: InsertMode::Top,
            offset_x: 0.0,
            offset_y: 0.0,
            relative_rotation: false,
            texture_id: None,
            quads: Vec::new(),
            alpha_keyframes: Vec::new(),
            emission_shape: EmissionShape::default(),
            relative_mode: RelativeMode::default(),
            turbulence: 0.0,
            drag: 0.0,
            orbit_speed: 0.0,
            animated_frames: 0,
            frame_rate: 12.0,
            color_by_speed: false,
            speed_color_min: 0.0,
            speed_color_max: 200.0,
            shape: ParticleShape::default(),
            death_emitter: None,
            death_burst_count: 0,
            shrapnel_edges: 6,
            ray_aspect: 4.0,
            ring_thickness: 0.2,
        }
    }
}
/// Construction helpers for `ParticleConfig`.
impl ParticleConfig {
    /// Clamps and normalizes hostile or malformed values into a safe runtime configuration.
    pub fn sanitize(&mut self) {
        self.max_particles = self.max_particles.max(1);
        self.emission_rate = non_negative_finite_or(self.emission_rate, 0.0);

        let life_min = non_negative_finite_or(self.lifetime_min, 1.0).max(MIN_PARTICLE_LIFETIME);
        let life_max = non_negative_finite_or(self.lifetime_max, life_min).max(MIN_PARTICLE_LIFETIME);
        self.lifetime_min = life_min.min(life_max);
        self.lifetime_max = life_min.max(life_max);

        let speed_min = non_negative_finite_or(self.speed_min, 0.0);
        let speed_max = non_negative_finite_or(self.speed_max, speed_min);
        self.speed_min = speed_min.min(speed_max);
        self.speed_max = speed_min.max(speed_max);

        self.direction = finite_or(self.direction, -std::f32::consts::FRAC_PI_2);
        self.spread = non_negative_finite_or(self.spread, std::f32::consts::FRAC_PI_4);
        self.gravity_x = finite_or(self.gravity_x, 0.0);
        self.gravity_y = finite_or(self.gravity_y, 0.0);

        self.sizes.retain(|size| size.is_finite() && *size > 0.0);
        if self.sizes.is_empty() {
            self.sizes = vec![4.0, 1.0];
        }

        self.colors.retain(|rgba| rgba.iter().all(|channel| channel.is_finite()));
        if self.colors.is_empty() {
            self.colors = vec![[1.0, 1.0, 1.0, 1.0], [1.0, 1.0, 1.0, 0.0]];
        } else {
            for rgba in &mut self.colors {
                for channel in rgba {
                    *channel = channel.clamp(0.0, 1.0);
                }
            }
        }

        self.spin_min = finite_or(self.spin_min, 0.0);
        self.spin_max = finite_or(self.spin_max, self.spin_min);
        if self.spin_min > self.spin_max {
            std::mem::swap(&mut self.spin_min, &mut self.spin_max);
        }

        self.rotation_min = finite_or(self.rotation_min, 0.0);
        self.rotation_max = finite_or(self.rotation_max, self.rotation_min);
        if self.rotation_min > self.rotation_max {
            std::mem::swap(&mut self.rotation_min, &mut self.rotation_max);
        }

        self.spin_variation = finite_or(self.spin_variation, 0.0).clamp(0.0, 1.0);
        self.size_variation = non_negative_finite_or(self.size_variation, 0.0);

        self.linear_accel_x_min = finite_or(self.linear_accel_x_min, 0.0);
        self.linear_accel_x_max = finite_or(self.linear_accel_x_max, self.linear_accel_x_min);
        if self.linear_accel_x_min > self.linear_accel_x_max {
            std::mem::swap(&mut self.linear_accel_x_min, &mut self.linear_accel_x_max);
        }
        self.linear_accel_y_min = finite_or(self.linear_accel_y_min, 0.0);
        self.linear_accel_y_max = finite_or(self.linear_accel_y_max, self.linear_accel_y_min);
        if self.linear_accel_y_min > self.linear_accel_y_max {
            std::mem::swap(&mut self.linear_accel_y_min, &mut self.linear_accel_y_max);
        }

        self.radial_accel_min = finite_or(self.radial_accel_min, 0.0);
        self.radial_accel_max = finite_or(self.radial_accel_max, self.radial_accel_min);
        if self.radial_accel_min > self.radial_accel_max {
            std::mem::swap(&mut self.radial_accel_min, &mut self.radial_accel_max);
        }
        self.tangential_accel_min = finite_or(self.tangential_accel_min, 0.0);
        self.tangential_accel_max =
            finite_or(self.tangential_accel_max, self.tangential_accel_min);
        if self.tangential_accel_min > self.tangential_accel_max {
            std::mem::swap(&mut self.tangential_accel_min, &mut self.tangential_accel_max);
        }

        self.linear_damping_min = non_negative_finite_or(self.linear_damping_min, 0.0);
        self.linear_damping_max =
            non_negative_finite_or(self.linear_damping_max, self.linear_damping_min);
        if self.linear_damping_min > self.linear_damping_max {
            std::mem::swap(&mut self.linear_damping_min, &mut self.linear_damping_max);
        }

        self.area_width = non_negative_finite_or(self.area_width, 0.0);
        self.area_height = non_negative_finite_or(self.area_height, 0.0);
        self.area_angle = finite_or(self.area_angle, 0.0);

        self.emitter_lifetime = if self.emitter_lifetime.is_finite() {
            if self.emitter_lifetime < 0.0 {
                -1.0
            } else {
                self.emitter_lifetime.max(MIN_PARTICLE_LIFETIME)
            }
        } else {
            -1.0
        };

        self.offset_x = finite_or(self.offset_x, 0.0);
        self.offset_y = finite_or(self.offset_y, 0.0);
        self.alpha_keyframes.retain(|alpha| alpha.is_finite());
        for alpha in &mut self.alpha_keyframes {
            *alpha = alpha.clamp(0.0, 1.0);
        }

        self.turbulence = non_negative_finite_or(self.turbulence, 0.0);
        self.drag = non_negative_finite_or(self.drag, 0.0);
        self.orbit_speed = finite_or(self.orbit_speed, 0.0);
        self.frame_rate = non_negative_finite_or(self.frame_rate, 12.0).max(MIN_PARTICLE_LIFETIME);
        self.speed_color_min = finite_or(self.speed_color_min, 0.0);
        self.speed_color_max = finite_or(self.speed_color_max, self.speed_color_min);
        if self.speed_color_min > self.speed_color_max {
            std::mem::swap(&mut self.speed_color_min, &mut self.speed_color_max);
        }

        self.shrapnel_edges = self.shrapnel_edges.max(3);
        self.ray_aspect = non_negative_finite_or(self.ray_aspect, 4.0).max(0.1);
        self.ring_thickness = finite_or(self.ring_thickness, 0.2).clamp(0.0, 1.0);

        match &mut self.emission_shape {
            EmissionShape::Circle { radius, .. } => {
                *radius = non_negative_finite_or(*radius, 50.0);
            }
            EmissionShape::Rectangle { width, height } => {
                *width = non_negative_finite_or(*width, 100.0);
                *height = non_negative_finite_or(*height, 100.0);
            }
            EmissionShape::Ring {
                inner_radius,
                outer_radius,
            } => {
                *inner_radius = non_negative_finite_or(*inner_radius, 20.0);
                *outer_radius = non_negative_finite_or(*outer_radius, 50.0).max(*inner_radius);
            }
            EmissionShape::Line { length, angle } => {
                *length = non_negative_finite_or(*length, 100.0);
                *angle = finite_or(*angle, 0.0);
            }
            EmissionShape::Cone {
                radius,
                angle,
                spread,
            } => {
                *radius = non_negative_finite_or(*radius, 50.0);
                *angle = finite_or(*angle, 0.0);
                *spread = non_negative_finite_or(*spread, 0.5);
            }
            EmissionShape::Star {
                points,
                outer_radius,
                inner_radius,
            } => {
                *points = (*points).max(3);
                *outer_radius = non_negative_finite_or(*outer_radius, 50.0);
                *inner_radius = non_negative_finite_or(*inner_radius, 25.0).min(*outer_radius);
            }
            EmissionShape::Spiral { revolutions, radius } => {
                *revolutions = non_negative_finite_or(*revolutions, 2.0);
                *radius = non_negative_finite_or(*radius, 50.0);
            }
            EmissionShape::Point | EmissionShape::Custom { .. } => {}
        }

        self.shape = match self.shape.clone() {
            ParticleShape::Shrapnel { .. } => ParticleShape::Shrapnel {
                edges: self.shrapnel_edges,
            },
            ParticleShape::Ray { .. } => ParticleShape::Ray {
                aspect: self.ray_aspect,
            },
            ParticleShape::Ring { .. } => ParticleShape::Ring {
                thickness: self.ring_thickness,
            },
            other => other,
        };

        if let Some(sub) = &mut self.death_emitter {
            sub.sanitize();
        }
    }

    /// Returns a sanitized copy of the config.
    pub fn normalized(mut self) -> Self {
        self.sanitize();
        self
    }

    /// Parse a `ParticleConfig` from a TOML string; returns the error string on failure.
    pub fn from_toml_str(toml_str: &str) -> Result<Self, String> {
        toml::from_str::<Self>(toml_str)
            .map(|cfg| cfg.normalized())
            .map_err(|e| e.to_string())
    }
}
