//! Slot-based save/load with compression and rotation

mod save_manager;
pub use save_manager::{
    compress_save_content, decompress_save_content, serialize_table, serialize_value, SaveManager,
    SaveValue, SlotMeta,
};
