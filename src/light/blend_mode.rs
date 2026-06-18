//! This file owns `LightBlendMode`, the enum that describes how one light contributes to the accumulated buffer.
//! It defines additive, subtractive, and mix-style compositing so light accumulation policy stays explicit in data.
//! Open this file when light compositing semantics change; per-light state and world processing live in siblings.

/// Blend mode for how a light's contribution is combined with the light accumulation buffer.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub enum LightBlendMode {
    /// Additive: light values are summed into the buffer (default, classic glow).
    #[default]
    Add,
    /// Subtractive: light values are subtracted from the buffer (shadow zones).
    Sub,
    /// Alpha-mix: light values are linearly interpolated with the buffer by intensity.
    Mix,
}
