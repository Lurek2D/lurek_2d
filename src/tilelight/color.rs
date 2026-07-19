//! This file owns color behavior inside the tilelight subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate color state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.
//! Public functions in this file are the stable entry points other modules should use for color work.

/// RGB light color in linear 0..1 components.
///
/// # Fields
///
/// `r`, `g`, and `b` are finite linear-light channels in `0..=1` once accepted
/// by a tilelight mutation. `validate` rejects hostile input before clamping.
#[derive(Debug, Clone, Copy, PartialEq)]
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

    /// Validate that all channels are finite and lie in the linear `0..=1` range.
    pub fn validate(self, api: &str) -> Result<(), String> {
        if [self.r, self.g, self.b]
            .iter()
            .any(|channel| !channel.is_finite() || !(0.0..=1.0).contains(channel))
        {
            return Err(format!(
                "tilelight {api} color channels must be finite and in 0..1"
            ));
        }
        Ok(())
    }

    /// Return color with finite components clamped to `0..=1`.
    ///
    /// Callers that accept user input must call [`Self::validate`] first. This
    /// defensive fallback keeps derived output finite if a Rust caller passes
    /// an invalid value directly.
    pub fn clamped(self) -> Self {
        Self {
            r: clamp_channel(self.r),
            g: clamp_channel(self.g),
            b: clamp_channel(self.b),
        }
    }

    /// Add scaled color into this color and clamp to 0..1.
    pub fn add_scaled(&mut self, color: Self, scale: f32) {
        let base = self.clamped();
        let color = color.clamped();
        let scale = if scale.is_finite() {
            scale.max(0.0)
        } else {
            0.0
        };
        self.r = clamp_channel(base.r + color.r * scale);
        self.g = clamp_channel(base.g + color.g * scale);
        self.b = clamp_channel(base.b + color.b * scale);
    }

    /// Return perceived luma for gameplay overlays.
    pub fn luma(self) -> f32 {
        (self.r * 0.2126 + self.g * 0.7152 + self.b * 0.0722).clamp(0.0, 1.0)
    }
}

fn clamp_channel(value: f32) -> f32 {
    if value.is_finite() {
        value.clamp(0.0, 1.0)
    } else {
        0.0
    }
}
