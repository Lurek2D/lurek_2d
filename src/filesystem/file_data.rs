//! `src/filesystem/file_data.rs` owns the lightweight payload object returned by filesystem reads and cache lookups.
//! It stores a logical path with raw bytes and exposes size, emptiness, and UTF-8 decoding helpers for callers.
//! Read it when file payload shape, decode helpers, or shared read-result contracts in the filesystem need changes.

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
