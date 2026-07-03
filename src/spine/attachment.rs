//! Owns the spine attachment implementation for the spine subsystem and keeps related runtime rules local here.
//! Keeps Spine assets, attachment data, and animation-facing helpers so helpers stay close to invariants this file updates.
//! Defines how spine attachment data is validated, transformed, or stored before neighboring systems consume it.
//! Separates spine attachment behavior from Lua bindings, tests, and sibling owners so integration stays readable.

/// Neutral source kind for a resolved Spine slot attachment.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum AttachmentSourceKind {
    /// A named region from a sprite atlas or sheet.
    SpriteRegion,
    /// A rectangular region from a single image.
    ImageRegion,
    /// A visual tile from a tileset.
    TilesetVisual,
}

impl AttachmentSourceKind {
    /// Parse a Lua/API kind string.
    pub fn parse(value: &str) -> Option<Self> {
        match value {
            "spriteRegion" | "sprite_region" => Some(Self::SpriteRegion),
            "imageRegion" | "image_region" => Some(Self::ImageRegion),
            "tilesetVisual" | "tileset_visual" => Some(Self::TilesetVisual),
            _ => None,
        }
    }

    /// Return the Lua/API kind string.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::SpriteRegion => "spriteRegion",
            Self::ImageRegion => "imageRegion",
            Self::TilesetVisual => "tilesetVisual",
        }
    }
}

/// Source rectangle and optional render texture for a skeleton attachment.
#[derive(Debug, Clone)]
pub struct AttachmentSource {
    /// Source kind.
    pub kind: AttachmentSourceKind,
    /// Optional source name, such as an atlas region name.
    pub name: Option<String>,
    /// Source rectangle x coordinate in pixels.
    pub x: f32,
    /// Source rectangle y coordinate in pixels.
    pub y: f32,
    /// Source rectangle width in pixels.
    pub w: f32,
    /// Source rectangle height in pixels.
    pub h: f32,
    /// Full texture width in pixels.
    pub texture_w: f32,
    /// Full texture height in pixels.
    pub texture_h: f32,
    /// Optional renderer texture handle.
    pub texture_id: Option<u64>,
}
