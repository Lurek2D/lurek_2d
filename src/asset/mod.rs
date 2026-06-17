//! Defines the top-level asset module boundary for cache-backed media lifecycle management. `asset/mod` is the asset module index, declaring `cache` so agents can identify which files own each feature slice before opening implementation code.
//! Exposes shared cache contracts while concentrating concrete registry behavior in the cache layer. `src/asset/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `cache::{AssetCache, AssetEntry, AssetType}` centralized for the asset subsystem.

/// Ref-counted asset entry storage and query implementation.
pub mod cache;
pub use cache::{AssetCache, AssetEntry, AssetType};
