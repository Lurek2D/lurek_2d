//! This file stores the screen-facing projection result for a billboard after world position has been interpreted through the raycaster camera.
//! It captures where the sprite should land, how large it should read, and whether it remains meaningfully visible to the viewer.
//! That compact record lets later passes sort, cull, and clip billboard content against wall depth without repeating camera math.

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
