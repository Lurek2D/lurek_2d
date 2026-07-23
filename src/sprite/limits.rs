//! Defines bounded input and work limits for sprite-owned runtime data.

/// # Fields
///
/// Limits that prevent sprite sheets, atlases, and animation catch-up from growing without bound.
pub struct SpriteLimits;

impl SpriteLimits {
    /// Maximum uniform-grid frames accepted from one sheet.
    pub const MAX_SHEET_FRAMES: usize = 65_536;
    /// Maximum clips accepted in one animator.
    pub const MAX_CLIPS: usize = 1_024;
    /// Maximum UTF-8 bytes in a sprite-owned name.
    pub const MAX_NAME_BYTES: usize = 256;
    /// Maximum JSON payload accepted by sprite atlas import.
    pub const MAX_ATLAS_JSON_BYTES: usize = 4 * 1024 * 1024;
    /// Maximum recursive nesting depth accepted from atlas JSON.
    pub const MAX_ATLAS_JSON_DEPTH: usize = 64;
    /// Maximum atlas entries accepted by import or runtime packing.
    pub const MAX_ATLAS_ENTRIES: usize = 65_536;
    /// Maximum width or height of a runtime sprite atlas in pixels.
    pub const MAX_ATLAS_DIMENSION: u32 = 16_384;
    /// Maximum pixel area of a runtime sprite atlas.
    pub const MAX_ATLAS_AREA: u64 = 268_435_456;
    /// Maximum atlas padding in pixels.
    pub const MAX_ATLAS_PADDING: u32 = 1_024;
    /// Maximum named frame groups on one sheet.
    pub const MAX_GROUPS: usize = 1_024;
    /// Maximum frames per second accepted by lightweight sprite clips.
    pub const MAX_FPS: f32 = 1_000.0;
    /// Maximum events emitted by one animator update.
    pub const MAX_ANIMATOR_EVENTS: usize = 256;
}
