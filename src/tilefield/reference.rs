//! Owns typed tilefield slot references that point from placed cells to tileset-local tiles or named objects.
//! The reference is pure data so renderers and gameplay systems can resolve it through their own catalog handles.

/// Typed reference stored in one tilefield slot.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct TileRef {
    /// Stable tileset id from a tileset catalog.
    pub tileset_id: String,
    /// Optional zero-based tileset-local tile id.
    pub local_id: Option<u32>,
    /// Optional named object archetype id.
    pub object_id: Option<String>,
}

impl TileRef {
    /// Create a tile reference to a local tileset tile.
    pub fn tile(tileset_id: String, local_id: u32) -> Result<Self, String> {
        Self::new(tileset_id, Some(local_id), None)
    }

    /// Create a tile reference to a named tileset object.
    pub fn object(tileset_id: String, object_id: String) -> Result<Self, String> {
        Self::new(tileset_id, None, Some(object_id))
    }

    /// Create a validated typed slot reference.
    pub fn new(
        tileset_id: String,
        local_id: Option<u32>,
        object_id: Option<String>,
    ) -> Result<Self, String> {
        let tileset_id = tileset_id.trim();
        if tileset_id.is_empty() {
            return Err("tilefield ref tileset id must not be empty".to_string());
        }
        let object_id = object_id
            .map(|value| value.trim().to_string())
            .filter(|value| !value.is_empty());
        if local_id.is_none() && object_id.is_none() {
            return Err("tilefield typed ref needs tile or object".to_string());
        }
        Ok(Self {
            tileset_id: tileset_id.to_string(),
            local_id,
            object_id,
        })
    }
}
