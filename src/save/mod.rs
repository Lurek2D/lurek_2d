//! This module provides the save-system surface for collecting game state, storing it by slot, and restoring it later. `save/mod` is the save module index, declaring `save_manager` so agents can identify which files own each feature slice before opening implementation code.
//! It combines persistence, compression, backup rotation, and migration support under one gameplay-facing feature stack. `src/save/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `save_manager::{ compress_save_content, decompress_save_content, parse_save_table, serialize_table, serialize_value, SaveManager, SaveValue, SlotMeta, }` centralized for the save subsystem.

mod save_manager;
pub use save_manager::{
    compress_save_content, decompress_save_content, parse_save_table, serialize_table,
    serialize_value, SaveManager, SaveValue, SlotMeta,
};
