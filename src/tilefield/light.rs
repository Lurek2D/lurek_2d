//! Owns tile-based light data records shared by `TileField` and Lua conversion code at the API boundary.
//! Defines RGB colors, point-light definitions, point-light patch updates, and global top-light values.
//! Keeps these structs data-only so the field solver can query blockers without cyclic module ownership.
//! Provides clamp and construction helpers while leaving occlusion, falloff, and accumulation to `field.rs`.
//! Does not render light, manage GPU state, infer visibility, or alter movement/action channel semantics.

/// RGB light color in linear 0..1 components.
#[derive(Debug, Clone, Copy)]
pub struct LightColor {
    /// Red channel.
    pub r: f32,
    /// Green channel.
    pub g: f32,
    /// Blue channel.
    pub b: f32,
}

impl LightColor {
    /// Black light color.
    pub const BLACK: Self = Self {
        r: 0.0,
        g: 0.0,
        b: 0.0,
    };

    /// White light color.
    pub const WHITE: Self = Self {
        r: 1.0,
        g: 1.0,
        b: 1.0,
    };

    /// Return color with components clamped to 0..1.
    pub fn clamped(self) -> Self {
        Self {
            r: self.r.clamp(0.0, 1.0),
            g: self.g.clamp(0.0, 1.0),
            b: self.b.clamp(0.0, 1.0),
        }
    }

    /// Add scaled color into this color and clamp to 0..1.
    pub fn add_scaled(&mut self, color: Self, scale: f32) {
        self.r = (self.r + color.r * scale).clamp(0.0, 1.0);
        self.g = (self.g + color.g * scale).clamp(0.0, 1.0);
        self.b = (self.b + color.b * scale).clamp(0.0, 1.0);
    }

    /// Return perceived luma for simple gameplay overlays.
    pub fn luma(self) -> f32 {
        (self.r * 0.2126 + self.g * 0.7152 + self.b * 0.0722).clamp(0.0, 1.0)
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
}

/// Global top light settings.
#[derive(Debug, Clone, Copy)]
pub struct GlobalLight {
    /// Scalar intensity.
    pub intensity: f32,
    /// RGB color.
    pub color: LightColor,
}

impl Default for GlobalLight {
    fn default() -> Self {
        Self {
            intensity: 0.0,
            color: LightColor::WHITE,
        }
    }
}
