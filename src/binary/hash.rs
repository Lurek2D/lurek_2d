//! This file owns digest and checksum helpers that turn arbitrary bytes into deterministic hash strings or CRC32.
//! `HashAlgorithm` normalizes user-facing algorithm names for MD5, SHA-1, SHA-256, and SHA-512 selection.
//! The main helpers compute lowercase hex digests from buffers without introducing streaming or file I/O concerns.
//! Open it when binary identity or integrity semantics change; compression and packing behavior live in siblings.

use md5::Digest;
use sha1;
#[derive(Debug, Clone, Copy, PartialEq)]
/// Select hash algorithm used for digest computation.
///
/// # Variants
/// - `Md5`: MD5 digest.
/// - `Sha1`: SHA-1 digest.
/// - `Sha256`: SHA-256 digest.
/// - `Sha512`: SHA-512 digest.
pub enum HashAlgorithm {
    /// Compute MD5 digest.
    Md5,
    /// Compute SHA-1 digest.
    Sha1,
    /// Compute SHA-256 digest.
    Sha256,
    /// Compute SHA-512 digest.
    Sha512,
}
impl HashAlgorithm {
    /// Parse algorithm label and return hash variant or error.
    pub fn parse_str(s: &str) -> Result<Self, String> {
        match s.to_lowercase().as_str() {
            "md5" => Ok(HashAlgorithm::Md5),
            "sha1" | "sha-1" => Ok(HashAlgorithm::Sha1),
            "sha256" | "sha-256" => Ok(HashAlgorithm::Sha256),
            "sha512" | "sha-512" => Ok(HashAlgorithm::Sha512),
            _ => Err(format!(
                "Unknown hash algorithm: '{}'. Use 'md5', 'sha1', 'sha256', or 'sha512'.",
                s
            )),
        }
    }
}
/// Hash bytes with selected algorithm and return hex digest.
pub fn hash(algorithm: HashAlgorithm, data: &[u8]) -> String {
    match algorithm {
        HashAlgorithm::Md5 => {
            let result = md5::Md5::digest(data);
            hex::encode(result)
        }
        HashAlgorithm::Sha1 => {
            let result = sha1::Sha1::digest(data);
            hex::encode(result)
        }
        HashAlgorithm::Sha256 => {
            let result = sha2::Sha256::digest(data);
            hex::encode(result)
        }
        HashAlgorithm::Sha512 => {
            let result = sha2::Sha512::digest(data);
            hex::encode(result)
        }
    }
}
/// Compute CRC32 checksum and return value as u64.
pub fn crc32(data: &[u8]) -> u64 {
    crc32fast::hash(data) as u64
}
