//! Owns tile-light source data: point lights, line lights, temporal modulation, and sun settings.
//! Does not compute light maps or read tilefield state.

use crate::tilelight::LightColor;

/// Time-varying modulation applied to a tile light source.
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
    /// Return modulated intensity for a base intensity and elapsed time in seconds.
    pub fn intensity_at(self, base: f32, time_seconds: f32) -> f32 {
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
        let (Some(a), Some(b)) = (self.color_a, self.color_b) else {
            return base;
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

/// Sun propagation mode.
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
