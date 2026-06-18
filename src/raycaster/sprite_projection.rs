//! This file owns `SpriteProjection`, the screen-space result record produced for one raycaster billboard sprite.
//! It stores screen x, uniform scale, camera distance, and visibility so later draw code can sort and clip safely.
//! Open this file when billboard projection payload changes; projection math and sprite drawing live in siblings.

/// Screen-space projection of a single world billboard; used for depth-buffer occlusion.
#[derive(Debug, Clone)]
pub struct SpriteProjection {
    /// Horizontal screen coordinate of the sprite center in pixels.
    pub screen_x: f32,
    /// Uniform pixel scale applied to the billboard quad.
    pub scale: f32,
    /// Perpendicular camera-plane distance to the sprite.
    pub distance: f32,
    /// False when the sprite is behind the camera or outside horizontal bounds.
    pub visible: bool,
}
