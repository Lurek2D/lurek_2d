//! This file owns catalog behavior inside the tilefield subsystem, close to its data and invariants.
//! It keeps validation, defaults, and error-facing rules near the operations that mutate catalog state.
//! Local helpers here translate compact engine data into explicit behavior for callers and Lua bindings.

use crate::tilefield::TileRef;

/// Resolves reusable object/archetype data for a typed tilefield reference.
pub trait TileObjectCatalog {
    /// Catalog-owned resolved object type.
    type Object;

    /// Return the reusable object/archetype referenced by a tilefield slot ref.
    fn object_for_ref(&self, reference: &TileRef) -> Option<&Self::Object>;
}
