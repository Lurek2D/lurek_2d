//! This file owns tileset reference metadata used by mapblocks to resolve slot values into concrete art resources.
//! `TilesetRef` stores ids, display name, atlas dimensions, tile sizes, and an optional image path for authored content.
//! Simple setters and accessors stay here because tileset identity is metadata, not generator or placement behavior.
//! Open it when asset reference fields change; tile payloads, blocks, and output assembly live in sibling files.

/// Reference to a tileset used by map blocks.
#[derive(Debug, Clone)]
pub struct TilesetRef {
    /// Unique ID for this tileset reference.
    pub id: u32,
    /// Human-readable name.
    pub name: String,
    /// Total number of tiles in this tileset.
    pub tile_count: u32,
    /// Number of columns in the tileset image.
    pub columns: u32,
    /// Pixel width of each tile.
    pub tile_width: u32,
    /// Pixel height of each tile.
    pub tile_height: u32,
    /// Optional texture/image path.
    pub image_path: Option<String>,
}

impl TilesetRef {
    /// Create a new tileset reference.
    pub fn new(
        id: u32,
        name: &str,
        tile_count: u32,
        columns: u32,
        tile_width: u32,
        tile_height: u32,
    ) -> Self {
        Self {
            id,
            name: name.to_string(),
            tile_count,
            columns,
            tile_width,
            tile_height,
            image_path: None,
        }
    }

    /// Set the image path for this tileset.
    pub fn set_image_path(&mut self, path: &str) {
        self.image_path = Some(path.to_string());
    }

    /// Get the numeric tileset identifier.
    pub fn id(&self) -> u32 {
        self.id
    }

    /// Get the display name of this tileset.
    pub fn name(&self) -> &str {
        &self.name
    }
}
