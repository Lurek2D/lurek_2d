//! This file owns color behavior inside the tilelight subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate color state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
//! Public functions in this file are the stable entry points other modules should use for color work.

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

    /// Return perceived luma for gameplay overlays.
    pub fn luma(self) -> f32 {
        (self.r * 0.2126 + self.g * 0.7152 + self.b * 0.0722).clamp(0.0, 1.0)
    }
}
