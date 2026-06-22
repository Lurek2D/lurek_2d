//! Owns overlay behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps overlay data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
//! Defines how weather data is validated, transformed, or stored before neighboring systems use it.
//! Owns overlay behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on weather behavior while Lua registration stays elsewhere.
//! Documents the boundary where overlay code accepts inputs, reports errors, or updates state.
//! Use this file when changing weather defaults, lifecycle handling, validation, or data ownership.

use std::collections::HashMap;

/// Stable version tag for the overlay weather RNG and particle-profile interpretation.
pub const WEATHER_RNG_VERSION: u32 = 1;
const DEFAULT_WEATHER_RNG_SEED: u64 = 0x9E37_79B9_7F4A_7C15;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
/// Enumerates supported weather particle behaviors.
pub enum WeatherType {
    /// Disables weather particle spawning.
    None,
    /// Fast downward streaks representing rain.
    Rain,
    /// Slow drifting flakes representing snow.
    Snow,
    /// Heavy fast-falling hail particles.
    Hail,
    /// Light dusty particles moving close to the ground.
    Dust,
    /// Larger drifting leaf particles.
    Leaves,
    /// Slow floating ash particles.
    Ash,
    /// Very light floating pollen particles.
    Pollen,
}
impl WeatherType {
    /// Resolves a lowercase weather type name into the matching enum entry.
    pub fn from_name(name: &str) -> Option<Self> {
        match name {
            "none" => Some(Self::None),
            "rain" => Some(Self::Rain),
            "snow" => Some(Self::Snow),
            "hail" => Some(Self::Hail),
            "dust" => Some(Self::Dust),
            "leaves" => Some(Self::Leaves),
            "ash" => Some(Self::Ash),
            "pollen" => Some(Self::Pollen),
            _ => None,
        }
    }
    /// Returns the lowercase canonical name for this weather type.
    pub fn name(&self) -> &'static str {
        match self {
            Self::None => "none",
            Self::Rain => "rain",
            Self::Snow => "snow",
            Self::Hail => "hail",
            Self::Dust => "dust",
            Self::Leaves => "leaves",
            Self::Ash => "ash",
            Self::Pollen => "pollen",
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq)]
/// Data-driven weather parameters used when spawning and culling particles for one mode.
pub struct WeatherProfile {
    /// Multiplier applied to the base per-intensity spawn rate.
    pub spawn_rate_multiplier: f32,
    /// Minimum downward velocity in screen units per second.
    pub velocity_min: f32,
    /// Maximum downward velocity in screen units per second.
    pub velocity_max: f32,
    /// Minimum particle size scalar.
    pub size_min: f32,
    /// Maximum particle size scalar.
    pub size_max: f32,
    /// Minimum particle alpha multiplier.
    pub alpha_min: f32,
    /// Maximum particle alpha multiplier.
    pub alpha_max: f32,
    /// Extra screen-space margin used when culling particles.
    pub culling_margin: f32,
}

impl WeatherProfile {
    /// Returns the default validated spawn profile for the given weather type.
    pub fn for_type(weather_type: WeatherType) -> Self {
        match weather_type {
            WeatherType::Rain => Self {
                spawn_rate_multiplier: 1.0,
                velocity_min: 200.0,
                velocity_max: 300.0,
                size_min: 2.0,
                size_max: 2.5,
                alpha_min: 0.65,
                alpha_max: 0.8,
                culling_margin: 50.0,
            },
            WeatherType::Snow => Self {
                spawn_rate_multiplier: 0.75,
                velocity_min: 30.0,
                velocity_max: 50.0,
                size_min: 3.0,
                size_max: 5.0,
                alpha_min: 0.75,
                alpha_max: 0.95,
                culling_margin: 60.0,
            },
            WeatherType::Hail => Self {
                spawn_rate_multiplier: 0.8,
                velocity_min: 250.0,
                velocity_max: 300.0,
                size_min: 3.5,
                size_max: 4.5,
                alpha_min: 0.75,
                alpha_max: 0.9,
                culling_margin: 55.0,
            },
            WeatherType::Dust => Self {
                spawn_rate_multiplier: 0.5,
                velocity_min: 10.0,
                velocity_max: 25.0,
                size_min: 1.0,
                size_max: 2.0,
                alpha_min: 0.25,
                alpha_max: 0.45,
                culling_margin: 70.0,
            },
            WeatherType::Leaves => Self {
                spawn_rate_multiplier: 0.35,
                velocity_min: 40.0,
                velocity_max: 70.0,
                size_min: 5.0,
                size_max: 8.0,
                alpha_min: 0.65,
                alpha_max: 0.85,
                culling_margin: 80.0,
            },
            WeatherType::Ash => Self {
                spawn_rate_multiplier: 0.45,
                velocity_min: 15.0,
                velocity_max: 25.0,
                size_min: 1.5,
                size_max: 2.5,
                alpha_min: 0.35,
                alpha_max: 0.55,
                culling_margin: 70.0,
            },
            WeatherType::Pollen => Self {
                spawn_rate_multiplier: 0.25,
                velocity_min: 5.0,
                velocity_max: 15.0,
                size_min: 1.0,
                size_max: 2.0,
                alpha_min: 0.2,
                alpha_max: 0.4,
                culling_margin: 75.0,
            },
            WeatherType::None => Self {
                spawn_rate_multiplier: 0.0,
                velocity_min: 0.0,
                velocity_max: 0.0,
                size_min: 0.0,
                size_max: 0.0,
                alpha_min: 0.0,
                alpha_max: 0.0,
                culling_margin: 50.0,
            },
        }
        .validated()
    }

    /// Returns a normalized copy with finite, non-negative, and ordered ranges.
    pub fn validated(self) -> Self {
        fn finite_or(value: f32, fallback: f32) -> f32 {
            if value.is_finite() {
                value
            } else {
                fallback
            }
        }

        fn ordered_pair(a: f32, b: f32, fallback_a: f32, fallback_b: f32) -> (f32, f32) {
            let a = finite_or(a, fallback_a).max(0.0);
            let b = finite_or(b, fallback_b).max(0.0);
            if a <= b {
                (a, b)
            } else {
                (b, a)
            }
        }

        let base = Self::for_type_or_default_fallback();
        let (velocity_min, velocity_max) = ordered_pair(
            self.velocity_min,
            self.velocity_max,
            base.velocity_min,
            base.velocity_max,
        );
        let (size_min, size_max) =
            ordered_pair(self.size_min, self.size_max, base.size_min, base.size_max);
        let (alpha_min, alpha_max) = ordered_pair(
            finite_or(self.alpha_min, base.alpha_min).clamp(0.0, 1.0),
            finite_or(self.alpha_max, base.alpha_max).clamp(0.0, 1.0),
            base.alpha_min,
            base.alpha_max,
        );

        Self {
            spawn_rate_multiplier: finite_or(
                self.spawn_rate_multiplier,
                base.spawn_rate_multiplier,
            )
            .max(0.0),
            velocity_min,
            velocity_max,
            size_min,
            size_max,
            alpha_min: alpha_min.clamp(0.0, 1.0),
            alpha_max: alpha_max.clamp(0.0, 1.0),
            culling_margin: finite_or(self.culling_margin, base.culling_margin).max(0.0),
        }
    }

    fn for_type_or_default_fallback() -> Self {
        Self {
            spawn_rate_multiplier: 1.0,
            velocity_min: 0.0,
            velocity_max: 1.0,
            size_min: 0.0,
            size_max: 1.0,
            alpha_min: 0.0,
            alpha_max: 1.0,
            culling_margin: 50.0,
        }
    }
}
#[derive(Debug, Clone)]
/// Stores the current position, velocity, and visual size of one weather particle.
pub struct WeatherParticle {
    /// Horizontal screen position.
    pub x: f32,
    /// Vertical screen position.
    pub y: f32,
    /// Horizontal particle velocity before wind is applied.
    pub vx: f32,
    /// Vertical particle velocity before wind is applied.
    pub vy: f32,
    /// Render size scalar for the particle.
    pub size: f32,
    /// Opacity multiplier for the particle.
    pub alpha: f32,
}
#[derive(Debug, Clone)]
/// Tracks weather mode, particle pool, wind, and random generation state.
pub struct WeatherState {
    /// Enables weather simulation and rendering.
    pub enabled: bool,
    /// Active weather particle behavior.
    pub weather_type: WeatherType,
    /// Spawn density multiplier for particle simulation.
    pub intensity: f32,
    /// Wind direction in radians.
    pub wind_direction: f32,
    /// Wind speed added to particle motion.
    pub wind_speed: f32,
    /// Live weather particles currently on screen.
    pub particles: Vec<WeatherParticle>,
    /// Accumulator used to schedule the next particle spawn.
    pub spawn_timer: f32,
    /// Internal PRNG state for particle placement and variation.
    pub rng_state: u64,
    /// Optional per-type profile overrides validated into safe bounds.
    pub profile_overrides: HashMap<WeatherType, WeatherProfile>,
}
impl WeatherState {
    /// Advances the internal PRNG and returns a sample in the `[0, 1)` range.
    pub fn next_unit(&mut self) -> f32 {
        let mut x = self.rng_state;
        x ^= x >> 12;
        x ^= x << 25;
        x ^= x >> 27;
        self.rng_state = x;
        let out = x.wrapping_mul(0x2545_F491_4F6C_DD1D);
        ((out >> 40) as u32) as f32 / (1u32 << 24) as f32
    }

    /// Sets a deterministic weather seed for future particle sampling.
    pub fn set_seed(&mut self, seed: u64) {
        self.rng_state = normalize_rng_state(seed);
    }

    /// Returns the current deterministic weather RNG state.
    pub fn rng_state(&self) -> u64 {
        self.rng_state
    }

    /// Replaces the current deterministic weather RNG state.
    pub fn set_rng_state(&mut self, state: u64) {
        self.rng_state = normalize_rng_state(state);
    }

    /// Returns the validated active profile for the supplied weather type.
    pub fn profile_for(&self, weather_type: WeatherType) -> WeatherProfile {
        self.profile_overrides
            .get(&weather_type)
            .copied()
            .unwrap_or_else(|| WeatherProfile::for_type(weather_type))
            .validated()
    }

    /// Stores a validated profile override for one weather type.
    pub fn set_profile_override(&mut self, weather_type: WeatherType, profile: WeatherProfile) {
        self.profile_overrides
            .insert(weather_type, profile.validated());
    }

    /// Removes any custom profile override for one weather type.
    pub fn clear_profile_override(&mut self, weather_type: WeatherType) {
        self.profile_overrides.remove(&weather_type);
    }
}
/// Provide default disabled weather state with seeded PRNG.
impl Default for WeatherState {
    /// Build the default disabled weather simulation state.
    fn default() -> Self {
        Self {
            enabled: false,
            weather_type: WeatherType::None,
            intensity: 0.5,
            wind_direction: 0.0,
            wind_speed: 0.0,
            particles: Vec::new(),
            spawn_timer: 0.0,
            rng_state: DEFAULT_WEATHER_RNG_SEED,
            profile_overrides: HashMap::new(),
        }
    }
}

fn normalize_rng_state(state: u64) -> u64 {
    if state == 0 {
        DEFAULT_WEATHER_RNG_SEED
    } else {
        state
    }
}
