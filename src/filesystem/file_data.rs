//! Provides a lightweight file payload container pairing logical paths with loaded raw bytes.
//! Exposes basic size, emptiness, and UTF-8 decode helpers for convenient caller-side consumption.
//! Delivers the shared data object returned by filesystem read operations.

/// Cached file bytes paired with the logical path they came from.
pub struct FileData {
    /// Logical path used to load or label the payload.
    pub path: String,
    /// Raw file contents in load order.
    pub bytes: Vec<u8>,
}

/// Core constructors and accessors for `FileData`.
impl FileData {
    /// Create a file payload from a path and raw bytes.
    pub fn new(path: String, bytes: Vec<u8>) -> Self {
        Self { path, bytes }
    }
    /// Return the payload length in bytes.
    pub fn len(&self) -> usize {
        self.bytes.len()
    }
    /// Return true when the payload has no bytes.
    pub fn is_empty(&self) -> bool {
        self.bytes.is_empty()
    }
    /// Decode the payload as UTF-8 or return the decode error.
    pub fn as_str(&self) -> Result<&str, std::str::Utf8Error> {
        std::str::from_utf8(&self.bytes)
    }
}
