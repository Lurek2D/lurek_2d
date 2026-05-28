//! Slot-based save/load with compression and rotation
//!
//! - Serialize Lua tables to binary SaveValue format
//! - Backup management with configurable slot count

mod save_manager;
pub use save_manager::{
    compress_save_content, decompress_save_content, serialize_table, serialize_value, SaveManager,
    SaveValue, SlotMeta,
};
