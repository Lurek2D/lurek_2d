//! Defines the catalog interface used to resolve typed tilefield references.
//! The trait lives in tilefield so algorithms can depend on `TileRef` semantics without importing tileset.

use crate::tilefield::TileRef;

/// Resolves reusable object/archetype data for a typed tilefield reference.
pub trait TileObjectCatalog {
    /// Catalog-owned resolved object type.
    type Object;

    /// Return the reusable object/archetype referenced by a tilefield slot ref.
    fn object_for_ref(&self, reference: &TileRef) -> Option<&Self::Object>;
}
