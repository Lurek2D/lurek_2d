//! Keeps the compressed-image API surface stable while the runtime build only accepts PNG image content.
//! Keeps compressed-image parsing separate from ordinary RGBA image loading and PNG style content workflows.
//! Open this owner when DDS rejection or compressed texture metadata behavior must change.

use crate::runtime::EngineError;
/// Compressed texture format recognized from DDS metadata.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum CompressedFormat {
    /// BC1 / DXT1 compressed texture.
    Dxt1,
    /// BC2 / DXT3 compressed texture.
    Dxt3,
    /// BC3 / DXT5 compressed texture.
    Dxt5,
    /// BC7 compressed texture.
    Bc7,
    /// ETC1 compressed texture.
    Etc1,
    /// ETC2 RGB compressed texture.
    Etc2Rgb,
    /// ETC2 RGBA compressed texture.
    Etc2Rgba,
    /// Format not recognized from DDS metadata.
    Unknown,
}
impl CompressedFormat {
    /// Return the lowercase format label string for this variant.
    pub fn as_str(&self) -> &'static str {
        match self {
            CompressedFormat::Dxt1 => "dxt1",
            CompressedFormat::Dxt3 => "dxt3",
            CompressedFormat::Dxt5 => "dxt5",
            CompressedFormat::Bc7 => "bc7",
            CompressedFormat::Etc1 => "etc1",
            CompressedFormat::Etc2Rgb => "etc2_rgb",
            CompressedFormat::Etc2Rgba => "etc2_rgba",
            CompressedFormat::Unknown => "unknown",
        }
    }
}
/// Legacy DDS image metadata shape retained for API compatibility.
#[derive(Debug, Clone)]
pub struct CompressedImageData {
    /// Detected compressed format.
    pub format: CompressedFormat,
    /// Base image width in pixels.
    pub width: u32,
    /// Base image height in pixels.
    pub height: u32,
    /// Raw mipmap payloads from the DDS file.
    pub mipmaps: Vec<Vec<u8>>,
}
impl CompressedImageData {
    /// Reject DDS bytes in this PNG-only runtime build.
    pub fn from_dds(_bytes: &[u8]) -> Result<Self, EngineError> {
        Err(EngineError::FileSystemError(
            "DDS compressed textures are not supported in this runtime build; use PNG".to_string(),
        ))
    }
    /// Return the base image dimensions.
    pub fn get_dimensions(&self) -> (u32, u32) {
        (self.width, self.height)
    }
    /// Return the number of mipmap levels stored in this image.
    pub fn get_mipmap_count(&self) -> u32 {
        self.mipmaps.len() as u32
    }
    /// Return the detected compressed format string.
    pub fn get_format(&self) -> &str {
        self.format.as_str()
    }
    /// Return whether the byte slice starts with the DDS magic header.
    pub fn is_dds_magic(bytes: &[u8]) -> bool {
        bytes.len() >= 4 && bytes[..4] == [0x44, 0x44, 0x53, 0x20]
    }
    /// Read a DDS file from disk and return the same unsupported-DDS error as `from_dds`.
    pub fn from_file(path: &str) -> Result<Self, EngineError> {
        let bytes = std::fs::read(path)
            .map_err(|e| EngineError::FileSystemError(format!("Cannot read '{}': {}", path, e)))?;
        Self::from_dds(&bytes)
    }
    /// Return whether a file on disk starts with the DDS magic header.
    pub fn is_dds_file(path: &str) -> bool {
        let Ok(mut f) = std::fs::File::open(path) else {
            return false;
        };
        let mut magic = [0u8; 4];
        use std::io::Read;
        f.read_exact(&mut magic).is_ok() && Self::is_dds_magic(&magic)
    }
}
