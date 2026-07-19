//! This file owns source behavior inside the tilelight subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate source state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
//! Public functions in this file are the stable entry points other modules should use for source work.
//! Serialization, indexing, and boundary checks stay here when they depend on source internals.
//! Renderer, API, and test layers should call through these helpers rather than duplicate private rules.

use crate::tilelight::LightColor;

/// Time-varying modulation applied to a tile light source.
///
/// # Fields
///
/// Intensity amplitude is `0..=1`; frequencies are cycles per second and are
/// non-negative; phases are radians. Optional colors are validated RGB values.
#[derive(Debug, Clone, Copy, Default)]
pub struct LightModulation {
    /// Intensity sine-wave amplitude, where 0 disables intensity animation.
    pub intensity_amplitude: f32,
    /// Intensity sine-wave frequency in cycles per second.
    pub intensity_frequency_hz: f32,
    /// Intensity sine-wave phase in radians.
    pub intensity_phase: f32,
    /// Optional first color for a sine-interpolated color cycle.
    pub color_a: Option<LightColor>,
    /// Optional second color for a sine-interpolated color cycle.
    pub color_b: Option<LightColor>,
    /// Color sine-wave frequency in cycles per second.
    pub color_frequency_hz: f32,
    /// Color sine-wave phase in radians.
    pub color_phase: f32,
}

impl LightModulation {
    /// Validate modulation parameters before they enter a runtime source.
    pub fn validate(&self, api: &str) -> Result<(), String> {
        if !self.intensity_amplitude.is_finite()
            || !(0.0..=1.0).contains(&self.intensity_amplitude)
            || !self.intensity_frequency_hz.is_finite()
            || self.intensity_frequency_hz < 0.0
            || !self.intensity_phase.is_finite()
            || !self.color_frequency_hz.is_finite()
            || self.color_frequency_hz < 0.0
            || !self.color_phase.is_finite()
        {
            return Err(format!(
                "tilelight {api} modulation values must be finite; amplitudes are 0..1 and frequencies are >= 0"
            ));
        }
        if let Some(color) = self.color_a {
            color.validate(api)?;
        }
        if let Some(color) = self.color_b {
            color.validate(api)?;
        }
        Ok(())
    }

    /// Return modulated intensity for a base intensity and elapsed time in seconds.
    pub fn intensity_at(self, base: f32, time_seconds: f32) -> f32 {
        if !base.is_finite() || !time_seconds.is_finite() {
            return 0.0;
        }
        if self.intensity_amplitude <= 0.0 || self.intensity_frequency_hz <= 0.0 {
            return base.max(0.0);
        }
        let wave = (time_seconds * self.intensity_frequency_hz * std::f32::consts::TAU
            + self.intensity_phase)
            .sin();
        (base * (1.0 + wave * self.intensity_amplitude)).max(0.0)
    }

    /// Return modulated color for a base color and elapsed time in seconds.
    pub fn color_at(self, base: LightColor, time_seconds: f32) -> LightColor {
        if !time_seconds.is_finite() {
            return base.clamped();
        }
        let (Some(a), Some(b)) = (self.color_a, self.color_b) else {
            return base.clamped();
        };
        if self.color_frequency_hz <= 0.0 {
            return a;
        }
        let wave = (time_seconds * self.color_frequency_hz * std::f32::consts::TAU
            + self.color_phase)
            .sin();
        let t = (wave * 0.5 + 0.5).clamp(0.0, 1.0);
        LightColor {
            r: a.r + (b.r - a.r) * t,
            g: a.g + (b.g - a.g) * t,
            b: a.b + (b.b - a.b) * t,
        }
        .clamped()
    }
}

/// Tile point light definition.
///
/// # Fields
///
/// The id is monotonically allocated by `TileLightMap`; coordinates are
/// zero-based cells; radius is in tiles; intensity is a non-negative scalar.
#[derive(Debug, Clone)]
pub struct PointLight {
    /// Stable point-light id.
    pub id: u32,
    /// Zero-based x coordinate.
    pub x: u32,
    /// Zero-based y coordinate.
    pub y: u32,
    /// Zero-based level.
    pub z: u32,
    /// Tile radius.
    pub radius: f32,
    /// Scalar intensity.
    pub intensity: f32,
    /// RGB color.
    pub color: LightColor,
    /// Time-varying intensity or color modulation.
    pub modulation: LightModulation,
}

/// Optional patch for updating an existing point light.
///
/// # Fields
///
/// `None` retains the current field. The complete candidate record is validated
/// before any field is changed.
#[derive(Debug, Clone, Copy, Default)]
pub struct PointLightUpdate {
    /// New zero-based x coordinate.
    pub x: Option<u32>,
    /// New zero-based y coordinate.
    pub y: Option<u32>,
    /// New zero-based level.
    pub z: Option<u32>,
    /// New tile radius.
    pub radius: Option<f32>,
    /// New scalar intensity.
    pub intensity: Option<f32>,
    /// New RGB color.
    pub color: Option<LightColor>,
    /// New time-varying modulation.
    pub modulation: Option<LightModulation>,
}

/// Tile line light definition.
///
/// # Fields
///
/// Endpoints are zero-based cells on one level. The radius and intensity use
/// the same units as point lights and the id remains stable after compaction.
#[derive(Debug, Clone)]
pub struct LineLight {
    /// Stable line-light id.
    pub id: u32,
    /// Start x coordinate.
    pub x1: u32,
    /// Start y coordinate.
    pub y1: u32,
    /// Start level.
    pub z1: u32,
    /// End x coordinate.
    pub x2: u32,
    /// End y coordinate.
    pub y2: u32,
    /// End level.
    pub z2: u32,
    /// Tile radius around the line.
    pub radius: f32,
    /// Scalar intensity.
    pub intensity: f32,
    /// RGB color.
    pub color: LightColor,
    /// Time-varying intensity or color modulation.
    pub modulation: LightModulation,
}

/// Optional patch for updating an existing line light.
///
/// # Fields
///
/// `None` retains the current field. Endpoint, shape, color, and modulation
/// validation is transactional.
#[derive(Debug, Clone, Copy, Default)]
pub struct LineLightUpdate {
    /// New start x coordinate.
    pub x1: Option<u32>,
    /// New start y coordinate.
    pub y1: Option<u32>,
    /// New start level.
    pub z1: Option<u32>,
    /// New end x coordinate.
    pub x2: Option<u32>,
    /// New end y coordinate.
    pub y2: Option<u32>,
    /// New end level.
    pub z2: Option<u32>,
    /// New tile radius.
    pub radius: Option<f32>,
    /// New scalar intensity.
    pub intensity: Option<f32>,
    /// New RGB color.
    pub color: Option<LightColor>,
    /// New time-varying modulation.
    pub modulation: Option<LightModulation>,
}

/// Tile rectangular area light definition.
///
/// # Fields
///
/// The origin is zero-based; width, height, and radius are tile counts; the id
/// is stable and runtime-owned by `TileLightMap`.
#[derive(Debug, Clone)]
pub struct AreaLight {
    /// Stable area-light id.
    pub id: u32,
    /// Zero-based rectangle origin x coordinate.
    pub x: u32,
    /// Zero-based rectangle origin y coordinate.
    pub y: u32,
    /// Zero-based level.
    pub z: u32,
    /// Rectangle width in tiles.
    pub width: u32,
    /// Rectangle height in tiles.
    pub height: u32,
    /// Tile radius around the emitting rectangle.
    pub radius: f32,
    /// Scalar intensity.
    pub intensity: f32,
    /// RGB color.
    pub color: LightColor,
    /// Time-varying intensity or color modulation.
    pub modulation: LightModulation,
}

/// Optional patch for updating an existing area light.
///
/// # Fields
///
/// `None` retains the current field. Rectangle bounds, halo work, and all
/// numeric values are validated before mutation.
#[derive(Debug, Clone, Copy, Default)]
pub struct AreaLightUpdate {
    /// New zero-based rectangle origin x coordinate.
    pub x: Option<u32>,
    /// New zero-based rectangle origin y coordinate.
    pub y: Option<u32>,
    /// New zero-based level.
    pub z: Option<u32>,
    /// New rectangle width in tiles.
    pub width: Option<u32>,
    /// New rectangle height in tiles.
    pub height: Option<u32>,
    /// New tile radius.
    pub radius: Option<f32>,
    /// New scalar intensity.
    pub intensity: Option<f32>,
    /// New RGB color.
    pub color: Option<LightColor>,
    /// New time-varying modulation.
    pub modulation: Option<LightModulation>,
}

/// Controls how one global sun light source propagates through the tile-light map.
///
/// # Variants
///
/// `Top` sweeps levels from high to low. `Directional` traces a bounded
/// horizontal direction on each level and uses upper-level sun data.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum SunLightMode {
    /// Vertical top light attenuated by per-cell sun occlusion from higher levels down.
    Top,
    /// Directional tile ray light on each level.
    Directional {
        /// Direction x component in tile steps.
        dx: i32,
        /// Direction y component in tile steps.
        dy: i32,
    },
}

/// Global sun light settings.
///
/// # Fields
///
/// Intensity is finite and non-negative, color is finite RGB in `0..=1`, and
/// mode selects top or directional tile propagation.
#[derive(Debug, Clone, Copy)]
pub struct SunLight {
    /// Scalar intensity.
    pub intensity: f32,
    /// RGB color.
    pub color: LightColor,
    /// Tile propagation mode.
    pub mode: SunLightMode,
}

impl Default for SunLight {
    fn default() -> Self {
        Self {
            intensity: 0.0,
            color: LightColor::WHITE,
            mode: SunLightMode::Top,
        }
    }
}
