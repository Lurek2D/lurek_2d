//! This module provides the save-system surface for collecting game state, storing it by slot, and restoring it later.
//! It combines persistence, compression, backup rotation, and migration support under one gameplay-facing feature stack.
//! At the highest level this is the engine subsystem that turns live Lua state into durable save slots.

mod save_manager;
pub use save_manager::{
    compress_save_content, decompress_save_content, serialize_table, serialize_value, SaveManager,
    SaveValue, SlotMeta,
};
