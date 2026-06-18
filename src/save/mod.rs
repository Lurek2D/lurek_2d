//! `src/save/mod.rs` is the save module index, exposing the persistence surface that gameplay and Lua bindings consume.
//! It reexports `SaveManager`, slot metadata, serialization helpers, compression helpers, and the save value tree.
//! No runtime state lives here; this file keeps the public save boundary stable while logic stays in `save_manager.rs`.
//! Read this index when a caller needs save APIs, because it shows which persistence symbols are intentionally public.
//! The module groups table serialization, compressed slot payload handling, and manager-driven save orchestration together.
//! Changes here alter the persistence boundary, since reexports decide what the engine and Lua layer may import.

mod save_manager;
pub use save_manager::{
    compress_save_content, decompress_save_content, parse_save_table, serialize_table,
    serialize_value, SaveManager, SaveValue, SlotMeta,
};
