//! Implements a read-only typed view over shared byte storage with offset and length windows. `binary/dataview` delivers the dataview implementation for the binary subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Provides bounds-checked scalar decoding for integer and floating-point primitive types. The file owns or coordinates data contracts including `DataView`, `LuaDataView`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Supports validated sub-view creation for structured parsing of nested binary regions. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `new_slice`, `get_size`, `get_u8`, `get_i8`, `get_u16`, and 5 more stays attached to the local data model and invariants.
//! Keeps shared ownership cheap through Arc-backed buffer references in multi-consumer paths. Runtime integration reaches sibling engine areas through crate modules no named public items, which explains the subsystem dependencies an agent should inspect before changing behavior.

use std::sync::Arc;
/// Hold shared byte slice window with offset and size.
///
/// # Fields
/// - `data`: Shared backing byte buffer.
/// - `offset`: Start offset of the view in the backing buffer.
/// - `size`: Readable byte length of the view.
pub struct DataView {
    /// Store shared backing bytes.
    pub data: Arc<Vec<u8>>,
    /// Store start offset in backing bytes.
    pub offset: usize,
    /// Store readable view length in bytes.
    pub size: usize,
}
impl DataView {
    /// Create full-buffer view and return value.
    pub fn new(data: Arc<Vec<u8>>) -> Self {
        let size = data.len();
        Self {
            data,
            offset: 0,
            size,
        }
    }
    /// Create sub-slice view and return value or bounds error.
    pub fn new_slice(data: Arc<Vec<u8>>, offset: usize, size: usize) -> Result<Self, String> {
        if offset + size > data.len() {
            return Err(format!(
                "DataView: slice out of bounds (offset={} size={} buffer_len={})",
                offset,
                size,
                data.len()
            ));
        }
        Ok(Self { data, offset, size })
    }
    /// Return view size in bytes. This function is part of the public API.
    pub fn get_size(&self) -> usize {
        self.size
    }
    /// Read u8 at index and return value or error.
    pub fn get_u8(&self, idx: usize) -> Result<u8, String> {
        self.check(idx, 1)?;
        Ok(self.data[self.offset + idx])
    }
    /// Read i8 at index and return value or error.
    pub fn get_i8(&self, idx: usize) -> Result<i8, String> {
        self.check(idx, 1)?;
        Ok(self.data[self.offset + idx] as i8)
    }
    /// Read little-endian u16 at index and return value or error.
    pub fn get_u16(&self, idx: usize) -> Result<u16, String> {
        self.check(idx, 2)?;
        let abs = self.offset + idx;
        Ok(u16::from_le_bytes([self.data[abs], self.data[abs + 1]]))
    }
    /// Read little-endian i16 at index and return value or error.
    pub fn get_i16(&self, idx: usize) -> Result<i16, String> {
        self.check(idx, 2)?;
        let abs = self.offset + idx;
        Ok(i16::from_le_bytes([self.data[abs], self.data[abs + 1]]))
    }
    /// Read little-endian u32 at index and return value or error.
    pub fn get_u32(&self, idx: usize) -> Result<u32, String> {
        self.check(idx, 4)?;
        let abs = self.offset + idx;
        Ok(u32::from_le_bytes([
            self.data[abs],
            self.data[abs + 1],
            self.data[abs + 2],
            self.data[abs + 3],
        ]))
    }
    /// Read little-endian i32 at index and return value or error.
    pub fn get_i32(&self, idx: usize) -> Result<i32, String> {
        self.check(idx, 4)?;
        let abs = self.offset + idx;
        Ok(i32::from_le_bytes([
            self.data[abs],
            self.data[abs + 1],
            self.data[abs + 2],
            self.data[abs + 3],
        ]))
    }
    /// Read little-endian f32 at index and return value or error.
    pub fn get_f32(&self, idx: usize) -> Result<f32, String> {
        self.check(idx, 4)?;
        let abs = self.offset + idx;
        Ok(f32::from_le_bytes([
            self.data[abs],
            self.data[abs + 1],
            self.data[abs + 2],
            self.data[abs + 3],
        ]))
    }
    /// Read little-endian f64 at index and return value or error.
    pub fn get_f64(&self, idx: usize) -> Result<f64, String> {
        self.check(idx, 8)?;
        let abs = self.offset + idx;
        Ok(f64::from_le_bytes([
            self.data[abs],
            self.data[abs + 1],
            self.data[abs + 2],
            self.data[abs + 3],
            self.data[abs + 4],
            self.data[abs + 5],
            self.data[abs + 6],
            self.data[abs + 7],
        ]))
    }
    /// Check that read of `width` bytes at `idx` fits within view size and return error otherwise.
    fn check(&self, idx: usize, width: usize) -> Result<(), String> {
        if idx + width > self.size {
            Err(format!(
                "DataView: read {} bytes at index {} out of bounds (view size {})",
                width, idx, self.size
            ))
        } else {
            Ok(())
        }
    }
}
/// Wrap DataView for Lua-facing ownership patterns.
///
/// # Fields
/// - `inner`: Wrapped validated data view.
pub struct LuaDataView {
    /// Store wrapped data view.
    pub(crate) inner: DataView,
}
impl LuaDataView {
    /// Wrap DataView and return LuaDataView.
    pub fn new(inner: DataView) -> Self {
        Self { inner }
    }
}
