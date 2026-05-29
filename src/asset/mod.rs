//! Defines the top-level asset module boundary for cache-backed media lifecycle management.
//! Exposes shared cache contracts while concentrating concrete registry behavior in the cache layer.
//! Serves as the composition entry for engine-side `lurek.asset` state and operations.
/// Ref-counted asset entry storage and query implementation.
pub mod cache;
pub use cache::{AssetCache, AssetEntry, AssetType};
