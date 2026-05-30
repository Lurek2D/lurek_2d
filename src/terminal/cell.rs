//! This file defines the atomic cell unit that the terminal grid stores for every visible character position.
//! It packages glyph and color state into one compact record so the rest of the terminal can treat the screen as a regular matrix.
//! The type is the smallest visible building block of the terminal subsystem.

/// Default foreground color: opaque white [r, g, b, a].
pub(crate) const DEFAULT_FG: [f32; 4] = [1.0, 1.0, 1.0, 1.0];
/// Default background color: fully transparent black [r, g, b, a].
pub(crate) const DEFAULT_BG: [f32; 4] = [0.0, 0.0, 0.0, 0.0];
/// Default character codepoint: ASCII space.
pub(crate) const DEFAULT_CH: u32 = b' ' as u32;

/// One character cell in the terminal grid, used by `Terminal` and the render layer.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct TCell {
    /// Unicode codepoint to render in this cell.
    pub ch: u32,
    /// Foreground RGBA color, components in 0.0–1.0.
    pub fg: [f32; 4],
    /// Background RGBA color, components in 0.0–1.0.
    pub bg: [f32; 4],
}

/// `Default` implementation for `TCell`.
impl Default for TCell {
    fn default() -> Self {
        Self {
            ch: DEFAULT_CH,
            fg: DEFAULT_FG,
            bg: DEFAULT_BG,
        }
    }
}
