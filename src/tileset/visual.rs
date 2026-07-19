//! Owns atlas-local visual references stored on tileset object archetypes.
//!
//! Visual records contain identifiers and source rectangles only. Texture loading,
//! handles, GPU lifetime, and draw submission remain owned by asset/image/render.

use crate::tileset::error::TilesetError;
use crate::tileset::limits::TilesetLimits;

/// Visual representation for one tileset object archetype.
///
/// # Fields
///
/// Visual data stores identifiers, optional source rectangles, texture dimensions,
/// and ordering only; it does not own a loaded texture.
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

impl TileVisual {
    /// Validate identifiers and optional numeric rectangles before downstream use.
    pub fn validate(&self, limits: &TilesetLimits) -> Result<(), TilesetError> {
        for (field, value) in [
            ("visual.atlas", self.atlas.as_deref()),
            ("visual.sprite", self.sprite.as_deref()),
            ("visual.image", self.image.as_deref()),
        ] {
            if let Some(value) = value {
                if value.trim().is_empty() {
                    return Err(TilesetError::invalid(field, "must not be empty"));
                }
                if value.len() > limits.max_string_bytes {
                    return Err(TilesetError::LimitExceeded {
                        resource: "visual string bytes",
                        requested: value.len() as u64,
                        maximum: limits.max_string_bytes as u64,
                    });
                }
            }
        }
        if let Some(quad) = self.quad {
            for (field, value) in [
                ("visual.quad.x", quad[0]),
                ("visual.quad.y", quad[1]),
                ("visual.quad.width", quad[2]),
                ("visual.quad.height", quad[3]),
            ] {
                if !value.is_finite() || value < 0.0 {
                    return Err(TilesetError::invalid(
                        field,
                        "must be finite and non-negative",
                    ));
                }
            }
            if quad[2] == 0.0 || quad[3] == 0.0 {
                return Err(TilesetError::invalid(
                    "visual.quad",
                    "width and height must be greater than zero",
                ));
            }
        }
        if let Some(size) = self.texture_size {
            for (field, value) in [
                ("visual.textureSize.width", size[0]),
                ("visual.textureSize.height", size[1]),
            ] {
                if !value.is_finite() || value <= 0.0 {
                    return Err(TilesetError::invalid(
                        field,
                        "must be finite and greater than zero",
                    ));
                }
            }
        }
        Ok(())
    }
}
