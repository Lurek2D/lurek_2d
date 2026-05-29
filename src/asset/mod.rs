//! `lurek.asset` — ref-counted media cache for images, fonts, audio, and text assets.
//! Asset registry module for `lurek.asset`.
//!
//! Re-exports [`AssetCache`], [`AssetEntry`], and [`AssetType`] from
//! `cache.rs`.  All business logic lives in `cache.rs`; `asset_api.rs`
//! contains only the thin Lua bindings.
pub mod cache;
pub use cache::{AssetCache, AssetEntry, AssetType};
