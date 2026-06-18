//! `src/asset/mod.rs` is the asset module index, exposing the cache surface used to track media lifetimes.
//! It reexports `AssetCache`, `AssetEntry`, and `AssetType` so callers reach asset bookkeeping through one boundary.
//! No runtime cache state lives here; this file defines visibility while concrete asset lifecycle rules stay in `cache.rs`.
//! Read this index when wiring asset features, because it shows which cache contracts are intentionally public and shared.
//! Changes here alter the asset boundary, since reexports decide what runtime systems and bindings may import directly.
//! This module keeps media lifecycle ownership separate from loaders, decoders, and subsystem-specific resources.

/// Ref-counted asset entry storage and query implementation.
pub mod cache;
pub use cache::{AssetCache, AssetEntry, AssetType};
