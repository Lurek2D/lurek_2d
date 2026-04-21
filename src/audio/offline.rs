//! Offline audio processing utilities.
//!
//! Decodes a WAV file, threads samples through a chain of [`crate::audio::dsp`] effects, and
//! writes the result back to disk as a 16-bit PCM WAV.  All work happens synchronously in the
//! calling thread â€” no audio device is opened.
//!
//! # Entry points
//! - [`process_offline`] â€” apply an [`OfflineEffect`] chain and save the output.
//! - [`normalize_file`] â€” scale peak amplitude to a target level and save.

use std::{
    fs::File,
    io::{BufReader, BufWriter, Write},
    sync::Arc,
};

use rodio::{Decoder, Source};

use crate::audio::dsp::{ActiveEffect, AtomicParam, EffectParams, EffectType};

/// Create the parent directory of `path` if it does not already exist.
///
/// Returns `Ok(())` when `path` has no parent component (e.g. a bare file name),
/// or when the directory already exists.
fn ensure_parent_dir(path: &str) -> Result<(), String> {
    if let Some(parent) = std::path::Path::new(path).parent() {
        if !parent.as_os_str().is_empty() && !parent.exists() {
            std::fs::create_dir_all(parent)
                .map_err(|e| format!("cannot create output directory '{}': {}", parent.display(), e))?;
        }
    }
    Ok(())
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Public types
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

/// Descriptor for a single DSP effect used in offline processing.
///
/// Parameters map to the same `p1`/`p2`/`p3` slots as the real-time
/// [`EffectParams`]: see [`EffectType`] variant docs for the meaning of each slot.
///
/// # Fields
/// - `typ`  â€” `EffectType`. The effect algorithm to apply.
/// - `p1`   â€” `f32`. Primary parameter (cutoff, room\_size, drive, threshold, â€¦).
/// - `p2`   â€” `f32`. Secondary parameter (q, mix, ratio, gain\_db, â€¦).
/// - `p3`   â€” `f32`. Tertiary parameter (mix, makeup\_gain, release, â€¦).
pub struct OfflineEffect {
    pub typ: EffectType,
    pub p1: f32,
    pub p2: f32,
    pub p3: f32,
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Public API
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

/// Decodes `input_path`, applies `effects` in series, and writes the result to `output_path`.
///
/// The output is a 16-bit PCM mono/stereo WAV file with the same sample rate and
/// channel count as the input.  An empty `effects` slice performs a passthrough.
///
/// # Parameters
/// - `input_path`  â€” `&str`. Path to the source WAV file.
/// - `output_path` â€” `&str`. Destination path for the processed WAV.
/// - `effects`     â€” `&[OfflineEffect]`. Ordered chain of effects.
///
/// # Returns
/// `Result<(), String>`. Returns an error string if the input cannot be decoded or
/// the output cannot be written.
pub fn process_offline(
    input_path: &str,
    output_path: &str,
    effects: &[OfflineEffect],
) -> Result<(), String> {
    let (mut samples, sample_rate, channels) = read_wav_f32(input_path)?;

    // Build per-effect active state
    let mut active: Vec<ActiveEffect> = effects
        .iter()
        .map(|e| {
            let params = Arc::new(EffectParams {
                id: 0,
                typ: e.typ,
                p1: AtomicParam::new(e.p1),
                p2: AtomicParam::new(e.p2),
                p3: AtomicParam::new(e.p3),
            });
            ActiveEffect::new(params, sample_rate, channels)
        })
        .collect();

    // Process sample by sample through effect chain
    for (i, s) in samples.iter_mut().enumerate() {
        let ch = (i % channels as usize) as u16;
        for fx in active.iter_mut() {
            *s = fx.process(*s, ch, sample_rate);
        }
    }

    write_wav_i16(output_path, &samples, sample_rate, channels)
}

/// Normalises the peak amplitude of `input_path` to `target_level` and writes to `output_path`.
///
/// The input is decoded to f32, scaled so that the peak magnitude equals `target_level`,
/// and the result is saved as a 16-bit PCM WAV.
///
/// # Parameters
/// - `input_path`   â€” `&str`. Path to the source WAV file.
/// - `output_path`  â€” `&str`. Destination path for the normalised WAV.
/// - `target_level` â€” `f32`. Target peak level in `(0.0, 1.0]`.
///
/// # Returns
/// `Result<(), String>`. Returns an error if the target is outside the allowed range or the
/// file cannot be read or written.
pub fn normalize_file(
    input_path: &str,
    output_path: &str,
    target_level: f32,
) -> Result<(), String> {
    if target_level <= 0.0 || target_level > 1.0 {
        return Err(format!(
            "target level must be in (0.0, 1.0], got {}",
            target_level
        ));
    }

    let (mut samples, sample_rate, channels) = read_wav_f32(input_path)?;

    let peak = samples.iter().map(|s| s.abs()).fold(0.0_f32, f32::max);

    if peak > 0.0 {
        let scale = target_level / peak;
        for s in samples.iter_mut() {
            *s *= scale;
        }
    }

    write_wav_i16(output_path, &samples, sample_rate, channels)
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Internal helpers
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

/// Decodes a WAV file to 32-bit floats using the `rodio` decoder.
///
/// # Parameters
/// - `path` â€” `&str`. Path to the WAV file.
///
/// # Returns
/// `Result<(Vec<f32>, u32, u16), String>`. Returns `(samples, sample_rate, channels)`.
fn read_wav_f32(path: &str) -> Result<(Vec<f32>, u32, u16), String> {
    let file = File::open(path).map_err(|e| format!("file not found: {}: {}", path, e))?;
    let reader = BufReader::new(file);
    let decoder =
        Decoder::new(reader).map_err(|e| format!("failed to decode WAV '{}': {}", path, e))?;

    let sample_rate = decoder.sample_rate();
    let channels = decoder.channels();
    let samples: Vec<f32> = decoder.convert_samples::<f32>().collect();

    Ok((samples, sample_rate, channels))
}

/// Writes a 16-bit PCM WAV file to `path`.
///
/// # Parameters
/// - `path`        â€” `&str`. Destination path.
/// - `samples`     â€” `&[f32]`. Interleaved f32 samples in `[-1.0, 1.0]`.
/// - `sample_rate` â€” `u32`. Sample rate in Hz.
/// - `channels`    â€” `u16`. Number of interleaved channels.
///
/// # Returns
/// `Result<(), String>`.
fn write_wav_i16(
    path: &str,
    samples: &[f32],
    sample_rate: u32,
    channels: u16,
) -> Result<(), String> {
    ensure_parent_dir(path)?;
    let pcm: Vec<i16> = samples
        .iter()
        .map(|s| (s.clamp(-1.0, 1.0) * i16::MAX as f32) as i16)
        .collect();

    let bits_per_sample: u16 = 16;
    let block_align = channels * (bits_per_sample / 8);
    let byte_rate = sample_rate * block_align as u32;
    let data_size = (pcm.len() * 2) as u32;
    let file_size = 36 + data_size;

    let file = File::create(path).map_err(|e| format!("cannot create '{}': {}", path, e))?;
    let mut w = BufWriter::new(file);

    // RIFF header
    w.write_all(b"RIFF").map_err(|e| e.to_string())?;
    w.write_all(&file_size.to_le_bytes())
        .map_err(|e| e.to_string())?;
    w.write_all(b"WAVE").map_err(|e| e.to_string())?;

    // fmt chunk
    w.write_all(b"fmt ").map_err(|e| e.to_string())?;
    w.write_all(&16u32.to_le_bytes())
        .map_err(|e| e.to_string())?; // chunk size
    w.write_all(&1u16.to_le_bytes())
        .map_err(|e| e.to_string())?; // PCM
    w.write_all(&channels.to_le_bytes())
        .map_err(|e| e.to_string())?;
    w.write_all(&sample_rate.to_le_bytes())
        .map_err(|e| e.to_string())?;
    w.write_all(&byte_rate.to_le_bytes())
        .map_err(|e| e.to_string())?;
    w.write_all(&block_align.to_le_bytes())
        .map_err(|e| e.to_string())?;
    w.write_all(&bits_per_sample.to_le_bytes())
        .map_err(|e| e.to_string())?;

    // data chunk
    w.write_all(b"data").map_err(|e| e.to_string())?;
    w.write_all(&data_size.to_le_bytes())
        .map_err(|e| e.to_string())?;
    for sample in &pcm {
        w.write_all(&sample.to_le_bytes())
            .map_err(|e| e.to_string())?;
    }

    w.flush().map_err(|e| e.to_string())
}
