//! Cryptographic hash functions for data integrity verification.
//!
//! [`hash()`] computes a digest over an in-memory byte slice and returns a
//! hex-encoded string. Supported algorithms: MD5, SHA-1, SHA-256, SHA-512.
//! MD5 and SHA-1 are provided for compatibility checks only — not for security.

use md5::Digest;
use sha1;

/// Supported cryptographic hash algorithms for `lurek.data.hash()`.
///
/// # Variants
/// - `Md5` — Md5 variant.
/// - `Sha1` — Sha1 variant.
/// - `Sha256` — Sha256 variant.
/// - `Sha512` — Sha512 variant.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum HashAlgorithm {
    /// MD5 (128-bit, not recommended for security).
    Md5,
    /// SHA-1 (160-bit, not recommended for security).
    Sha1,
    /// SHA-256 (256-bit).
    Sha256,
    /// SHA-512 (512-bit).
    Sha512,
}

impl HashAlgorithm {
    /// Parse an algorithm name string (case-insensitive).
    /// Accepts `"md5"`, `"sha1"` / `"sha-1"`, `"sha256"` / `"sha-256"`,
    /// `"sha512"` / `"sha-512"`.
    ///
    /// # Parameters
    /// - `s` — `&str`.
    ///
    /// # Returns
    /// `Result<Self, String>`.
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

/// Compute the hash of data using the specified algorithm, returned as a hex string.
///
/// # Parameters
/// - `algorithm` — `HashAlgorithm`.
/// - `data` — `&[u8]`.
///
/// # Returns
/// `String`.
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
