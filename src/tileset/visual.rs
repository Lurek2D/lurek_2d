//! This file owns visual behavior inside the tileset subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate visual state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.

/// Visual representation for one tileset object archetype.
#[derive(Debug, Clone, Default)]
pub struct TileVisual {
    /// Optional renderer texture handle used by textured tilemap rendering.
    pub texture_id: Option<u64>,
    /// Optional sprite atlas name or asset id authored by Lua.
    pub atlas: Option<String>,
    /// Optional sprite/region name inside the atlas.
    pub sprite: Option<String>,
    /// Optional source image path for tools/importers.
    pub image: Option<String>,
    /// Optional local tile ID override for grid-atlas rendering.
    pub tile_id: Option<u32>,
    /// Optional explicit source quad `[x, y, width, height]` in atlas pixels.
    pub quad: Option<[f32; 4]>,
    /// Optional explicit atlas texture size `[width, height]` in pixels.
    pub texture_size: Option<[f32; 2]>,
    /// Optional explicit draw order within one cell.
    pub order: i32,
}
