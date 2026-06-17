//! Implements an owned mutable byte buffer with indexed access and conversion helpers. `binary/byte_data` delivers the byte data implementation for the binary subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Supports UTF-8 encoding and tolerant text decoding from arbitrary byte content. The file owns or coordinates data contracts including `ByteData`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Exposes immutable and mutable slice views for efficient downstream processing. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `from_bytes`, `from_string`, `len`, `is_empty`, `get_byte`, and 5 more stays attached to the local data model and invariants.

#[derive(Debug, Clone)]
/// Hold owned raw bytes with convenience conversion helpers.
///
/// # Fields
/// - `data`: Owned byte payload backing all byte operations.
pub struct ByteData {
    /// Store raw bytes for this buffer.
    data: Vec<u8>,
}
impl ByteData {
    /// Create zero-filled buffer and return new value.
    pub fn new(size: usize) -> Self {
        Self {
            data: vec![0; size],
        }
    }
    /// Wrap existing bytes and return new value.
    pub fn from_bytes(bytes: Vec<u8>) -> Self {
        Self { data: bytes }
    }
    /// Encode UTF-8 text bytes and return new value.
    pub fn from_string(s: &str) -> Self {
        Self {
            data: s.as_bytes().to_vec(),
        }
    }
    /// Return buffer length in bytes.
    pub fn len(&self) -> usize {
        self.data.len()
    }
    /// Return true when buffer has no bytes.
    pub fn is_empty(&self) -> bool {
        self.data.is_empty()
    }
    /// Read byte at offset and return optional value.
    pub fn get_byte(&self, offset: usize) -> Option<u8> {
        self.data.get(offset).copied()
    }
    /// Write byte at offset and return success flag.
    pub fn set_byte(&mut self, offset: usize, value: u8) -> bool {
        if offset < self.data.len() {
            self.data[offset] = value;
            true
        } else {
            false
        }
    }
    /// Decode bytes as UTF-8 lossily and return string.
    pub fn get_string(&self) -> String {
        String::from_utf8_lossy(&self.data).to_string()
    }
    /// Return immutable byte slice view.
    pub fn as_bytes(&self) -> &[u8] {
        &self.data
    }
    /// Return mutable byte slice view.
    pub fn as_bytes_mut(&mut self) -> &mut [u8] {
        &mut self.data
    }
    /// Clone internal bytes and return copied buffer.
    pub fn clone_data(&self) -> Self {
        Self {
            data: self.data.clone(),
        }
    }
}
