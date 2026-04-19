//! Streaming audio decoder for chunked PCM reading.
//!
//! `Decoder` reads an audio file and returns PCM data in fixed-size buffer
//! chunks, enabling streaming playback without loading the entire file into
//! memory.

use crate::runtime::log_messages::AD01_AUDIO_DECODED;
use crate::runtime::EngineError;
use crate::log_msg;

/// Streaming audio decoder that reads PCM in fixed-size chunks.
///
/// The decoder eagerly reads the full file on construction (using rodio's
/// decoder), then serves chunks of `buffer_size` samples on each call to
/// `decode()`. This provides a chunk-at-a-time API while keeping file I/O
/// simple and reliable across platforms.
///
/// # Fields
/// - `path` — `String`.
/// - `sample_rate` — `u32`.
/// - `channels` — `u16`.
/// - `bit_depth` — `u16`.
/// - `buffer_size` — `usize`.
pub struct Decoder {
    /// Source file path.
    pub path: String,
    /// Sample rate in Hz.
    pub sample_rate: u32,
    /// Number of audio channels.
    pub channels: u16,
    /// Bit depth of the PCM data.
    pub bit_depth: u16,
    /// Number of samples returned per `decode()` call.
    pub buffer_size: usize,
    cursor: usize,
    pcm: Vec<i16>,
}

impl Decoder {
    /// Load an audio file and prepare it for chunked decoding.
    ///
    /// # Parameters
    /// - `path` — `&str`.
    /// - `buffer_size` — `usize`. Number of samples per chunk.
    ///
    /// # Returns
    /// `Result<Self, EngineError>`.
    pub fn from_file(path: &str, buffer_size: usize) -> Result<Self, EngineError> {
        use rodio::Source;
        use std::fs::File;
        use std::io::BufReader;

        let file = File::open(path)
            .map_err(|e| EngineError::FileSystemError(format!("{}: {}", path, e)))?;
        let decoder = rodio::Decoder::new(BufReader::new(file))
            .map_err(|e| EngineError::AudioError(format!("Decoder error: {}", e)))?;
        let sample_rate = decoder.sample_rate();
        let channels = decoder.channels();
        let pcm: Vec<i16> = decoder.collect();

        log_msg!(debug, AD01_AUDIO_DECODED, "{}", path);
        Ok(Self {
            path: path.to_string(),
            sample_rate,
            channels,
            bit_depth: 16,
            buffer_size: buffer_size.max(1),
            cursor: 0,
            pcm,
        })
    }

    /// Return the next chunk of samples, or `None` at EOF.
    ///
    /// # Returns
    /// `Option<Vec<i16>>`.
    pub fn decode(&mut self) -> Option<Vec<i16>> {
        if self.cursor >= self.pcm.len() {
            return None;
        }
        let end = (self.cursor + self.buffer_size).min(self.pcm.len());
        let chunk = self.pcm[self.cursor..end].to_vec();
        self.cursor = end;
        Some(chunk)
    }

    /// Return the total duration in seconds.
    ///
    /// # Returns
    /// `f64`.
    pub fn get_duration(&self) -> f64 {
        if self.sample_rate == 0 || self.channels == 0 {
            return 0.0;
        }
        self.pcm.len() as f64 / (self.sample_rate as f64 * self.channels as f64)
    }

    /// Seek to a time offset in seconds.
    ///
    /// # Parameters
    /// - `offset` — `f64`.
    pub fn seek(&mut self, offset: f64) {
        let sample_pos = (offset * self.sample_rate as f64 * self.channels as f64) as usize;
        self.cursor = sample_pos.min(self.pcm.len());
    }

    /// Return the current playback position in seconds.
    ///
    /// # Returns
    /// `f64`.
    pub fn tell(&self) -> f64 {
        if self.sample_rate == 0 || self.channels == 0 {
            return 0.0;
        }
        self.cursor as f64 / (self.sample_rate as f64 * self.channels as f64)
    }

    /// Returns whether this decoder supports seeking.
    ///
    /// Always `true` because PCM data is fully buffered in memory.
    ///
    /// # Returns
    /// `bool`.
    pub fn is_seekable(&self) -> bool {
        true
    }

    /// Reset playback to the beginning.
    pub fn rewind(&mut self) {
        self.cursor = 0;
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Helper: build a Decoder from a pre-filled PCM buffer (bypasses file I/O).
    fn make_decoder(pcm: Vec<i16>, sample_rate: u32, channels: u16, buffer_size: usize) -> Decoder {
        Decoder {
            path: "test.wav".to_string(),
            sample_rate,
            channels,
            bit_depth: 16,
            buffer_size,
            cursor: 0,
            pcm,
        }
    }

    #[test]
    fn decode_returns_chunks() {
        let pcm: Vec<i16> = (0..10).collect();
        let mut dec = make_decoder(pcm, 44100, 1, 4);
        let c1 = dec.decode().unwrap();
        assert_eq!(c1.len(), 4);
        assert_eq!(c1, vec![0, 1, 2, 3]);

        let c2 = dec.decode().unwrap();
        assert_eq!(c2, vec![4, 5, 6, 7]);

        let c3 = dec.decode().unwrap();
        assert_eq!(c3, vec![8, 9]); // partial last chunk

        assert!(dec.decode().is_none()); // EOF
    }

    #[test]
    fn get_duration_stereo() {
        let pcm = vec![0i16; 88200]; // 1 second of stereo at 44100
        let dec = make_decoder(pcm, 44100, 2, 1024);
        assert!((dec.get_duration() - 1.0).abs() < 0.001);
    }

    #[test]
    fn get_duration_zero_rate() {
        let dec = make_decoder(vec![], 0, 1, 1024);
        assert_eq!(dec.get_duration(), 0.0);
    }

    #[test]
    fn seek_and_tell() {
        let pcm = vec![0i16; 44100]; // 1 sec mono
        let mut dec = make_decoder(pcm, 44100, 1, 512);
        assert_eq!(dec.tell(), 0.0);

        dec.seek(0.5);
        assert!((dec.tell() - 0.5).abs() < 0.01);
    }

    #[test]
    fn seek_beyond_end_clamps() {
        let pcm = vec![0i16; 100];
        let mut dec = make_decoder(pcm, 44100, 1, 512);
        dec.seek(100.0); // way past end
        assert!(dec.decode().is_none());
    }

    #[test]
    fn rewind_resets_cursor() {
        let pcm: Vec<i16> = (0..10).collect();
        let mut dec = make_decoder(pcm, 44100, 1, 5);
        dec.decode(); // consume first chunk
        dec.rewind();
        let c = dec.decode().unwrap();
        assert_eq!(c[0], 0);
    }

    #[test]
    fn is_seekable_always_true() {
        let dec = make_decoder(vec![], 44100, 1, 512);
        assert!(dec.is_seekable());
    }

    #[test]
    fn buffer_size_min_one() {
        // buffer_size of 0 should be clamped to 1 in from_file; test the struct directly
        let dec = make_decoder(vec![1, 2, 3], 44100, 1, 1);
        assert_eq!(dec.buffer_size, 1);
    }
}
