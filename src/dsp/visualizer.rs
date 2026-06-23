//! `src/dsp/visualizer.rs` converts decoded audio buffers into waveform and spectrogram PNG diagnostics.
//! It owns mono reduction, windowing, FFT magnitude sampling, and pixel-color mapping for offline visual inspection.
//! Waveform and spectrogram export live here so audio-image tooling stays separate from playback, synthesis, and effects.
//! This file is the visual diagnostics boundary for DSP assets; it does not own meters or generated sample output.
//! It reads decoded samples from supported audio sources and writes inspection images through image crate buffers.
//! Update this file when FFT bin mapping, waveform scaling, heatmap coloring, or diagnostic export limits change.
//! Read it when DSP image export, heatmap encoding, or waveform rendering rules for inspection tools need changes.

use image::{ImageBuffer, Rgba};
use rodio::{Decoder, Source};
use std::{fs::File, io::BufReader};

const DEFAULT_WINDOW_SIZE: usize = 1024;
const DEFAULT_FFT_SIZE: usize = 2048;
const DEFAULT_DYNAMIC_RANGE_DB: f32 = 80.0;
const MIN_FREQUENCY_HZ: f32 = 20.0;

/// Controls spectrogram short-time Fourier transform and colour mapping.
#[derive(Debug, Clone)]
pub struct SpectrogramOptions {
    /// Number of input samples multiplied by the window function for each frame.
    pub window_size: usize,
    /// Number of FFT points used for each window; must be a power of two and at least `window_size`.
    pub fft_size: usize,
    /// Optional frame advance in samples. Defaults to one column per output pixel.
    pub hop_size: Option<usize>,
    /// Visible decibel range below the loudest measured bin.
    pub dynamic_range_db: f32,
    /// Use logarithmic frequency mapping on the vertical axis.
    pub log_frequency: bool,
}

impl Default for SpectrogramOptions {
    fn default() -> Self {
        Self {
            window_size: DEFAULT_WINDOW_SIZE,
            fft_size: DEFAULT_FFT_SIZE,
            hop_size: None,
            dynamic_range_db: DEFAULT_DYNAMIC_RANGE_DB,
            log_frequency: true,
        }
    }
}

impl SpectrogramOptions {
    /// Validate and normalize spectrogram options before rendering.
    pub fn validated(mut self) -> Result<Self, String> {
        self.window_size = self.window_size.clamp(16, 65_536);
        self.fft_size = self.fft_size.clamp(16, 65_536);
        if !self.fft_size.is_power_of_two() {
            return Err(format!(
                "spectrogram fftSize/fftPoints must be a power of two, got {}",
                self.fft_size
            ));
        }
        if self.fft_size < self.window_size {
            return Err(format!(
                "spectrogram fftSize/fftPoints ({}) must be at least windowSize/inputWindowSize ({})",
                self.fft_size, self.window_size
            ));
        }
        if let Some(hop_size) = self.hop_size.as_mut() {
            *hop_size = (*hop_size).clamp(1, self.window_size);
        }
        if !self.dynamic_range_db.is_finite() {
            self.dynamic_range_db = DEFAULT_DYNAMIC_RANGE_DB;
        }
        self.dynamic_range_db = self.dynamic_range_db.clamp(12.0, 160.0);
        Ok(self)
    }
}

/// Create parent directories for `path` when needed.
fn ensure_parent_dir(path: &str) -> Result<(), String> {
    if let Some(parent) = std::path::Path::new(path).parent() {
        if !parent.as_os_str().is_empty() && !parent.exists() {
            std::fs::create_dir_all(parent).map_err(|e| {
                format!(
                    "cannot create output directory '{}': {}",
                    parent.display(),
                    e
                )
            })?;
        }
    }
    Ok(())
}
/// Render waveform overview of `input_wav` to `output_png` with given image size.
pub fn waveform_to_png(
    input_wav: &str,
    output_png: &str,
    width: u32,
    height: u32,
) -> Result<(), String> {
    let (samples, _) = read_mono_f32(input_wav)?;
    let bg: Rgba<u8> = Rgba([12, 14, 28, 255]);
    let fg: Rgba<u8> = Rgba([0, 200, 220, 255]);
    let mut img: ImageBuffer<Rgba<u8>, Vec<u8>> = ImageBuffer::from_fn(width, height, |_, _| bg);
    let n = samples.len().max(1);
    let samples_per_col = n as f32 / width as f32;
    let half_h = height as f32 * 0.5;
    for x in 0..width {
        let start = ((x as f32 * samples_per_col) as usize).min(n - 1);
        let end = (((x + 1) as f32 * samples_per_col) as usize).min(n);
        let slice = &samples[start..end];
        let (mn, mx) = if slice.is_empty() {
            (0.0_f32, 0.0_f32)
        } else {
            let mn = slice.iter().cloned().fold(f32::INFINITY, f32::min);
            let mx = slice.iter().cloned().fold(f32::NEG_INFINITY, f32::max);
            (mn, mx)
        };
        let y_top = ((half_h - mx.clamp(-1.0, 1.0) * half_h) as u32).min(height - 1);
        let y_bot = ((half_h - mn.clamp(-1.0, 1.0) * half_h) as u32).min(height - 1);
        for y in y_top..=y_bot {
            img.put_pixel(x, y, fg);
        }
    }
    ensure_parent_dir(output_png)?;
    img.save(output_png)
        .map_err(|e| format!("cannot save PNG '{}': {}", output_png, e))
}
#[allow(clippy::needless_range_loop)]
/// Render a spectrogram heatmap of `input_wav` to `output_png` using default FFT options.
pub fn spectrogram_to_png(
    input_wav: &str,
    output_png: &str,
    width: u32,
    height: u32,
) -> Result<(), String> {
    spectrogram_to_png_with_options(
        input_wav,
        output_png,
        width,
        height,
        SpectrogramOptions::default(),
    )
}

/// Render a spectrogram heatmap of `input_wav` to `output_png` using configurable FFT options.
pub fn spectrogram_to_png_with_options(
    input_wav: &str,
    output_png: &str,
    width: u32,
    height: u32,
    options: SpectrogramOptions,
) -> Result<(), String> {
    if width == 0 || height == 0 {
        return Err("spectrogram image width and height must be greater than zero".to_string());
    }

    let options = options.validated()?;
    let (samples, sample_rate) = read_mono_f32(input_wav)?;
    let n_frames = frame_count(samples.len(), width, &options);
    let spectra = compute_spectrogram(&samples, n_frames, &options);
    let max_db = spectra
        .iter()
        .flat_map(|m| m.iter())
        .cloned()
        .fold(f32::NEG_INFINITY, f32::max)
        .max(-120.0);
    let bg: Rgba<u8> = Rgba([0, 0, 0, 255]);
    let mut img: ImageBuffer<Rgba<u8>, Vec<u8>> = ImageBuffer::from_fn(width, height, |_, _| bg);
    for px in 0..width {
        let frame_idx = ((px as f32 / width as f32) * n_frames as f32) as usize;
        let frame_idx = frame_idx.min(n_frames - 1);
        let mags = &spectra[frame_idx];
        for py in 0..height {
            let bin =
                frequency_bin_for_pixel(py, height, mags.len(), sample_rate, options.log_frequency);
            let db = sample_bin_db(mags, bin);
            let mag_norm = ((db - (max_db - options.dynamic_range_db)) / options.dynamic_range_db)
                .clamp(0.0, 1.0);
            let colour = heat_colour(mag_norm);
            img.put_pixel(px, py, colour);
        }
    }
    ensure_parent_dir(output_png)?;
    img.save(output_png)
        .map_err(|e| format!("cannot save PNG '{}': {}", output_png, e))
}

/// Decode an audio file and return mono f32 samples plus sample rate.
fn read_mono_f32(path: &str) -> Result<(Vec<f32>, u32), String> {
    let file = File::open(path).map_err(|e| format!("file not found: {}: {}", path, e))?;
    let reader = BufReader::new(file);
    let decoder =
        Decoder::new(reader).map_err(|e| format!("failed to decode '{}': {}", path, e))?;
    let channels = decoder.channels() as usize;
    let sample_rate = decoder.sample_rate();
    let raw: Vec<f32> = decoder.convert_samples::<f32>().collect();
    if channels <= 1 {
        return Ok((raw, sample_rate));
    }
    let inv = 1.0 / channels as f32;
    let mono: Vec<f32> = raw
        .chunks(channels)
        .map(|c| c.iter().sum::<f32>() * inv)
        .collect();
    Ok((mono, sample_rate))
}

fn frame_count(sample_len: usize, width: u32, options: &SpectrogramOptions) -> usize {
    if let Some(hop_size) = options.hop_size {
        let padded = sample_len.max(options.window_size);
        return ((padded.saturating_sub(options.window_size)) / hop_size + 1).max(1);
    }
    width.max(1) as usize
}

fn frame_start(
    index: usize,
    n_frames: usize,
    sample_len: usize,
    options: &SpectrogramOptions,
) -> usize {
    if sample_len <= options.window_size {
        return 0;
    }
    if let Some(hop_size) = options.hop_size {
        return (index * hop_size).min(sample_len - options.window_size);
    }
    if n_frames <= 1 {
        0
    } else {
        (index * (sample_len - options.window_size)) / (n_frames - 1)
    }
}

fn compute_spectrogram(
    samples: &[f32],
    n_frames: usize,
    options: &SpectrogramOptions,
) -> Vec<Vec<f32>> {
    let half_bins = options.fft_size / 2 + 1;
    let mut spectra: Vec<Vec<f32>> = Vec::with_capacity(n_frames);
    for i in 0..n_frames {
        let start = frame_start(i, n_frames, samples.len(), options);
        let end = (start + options.window_size).min(samples.len());
        let slice = if start < samples.len() {
            &samples[start..end]
        } else {
            &[]
        };
        let mut window = vec![0.0_f64; options.fft_size];
        for (k, &sample) in slice.iter().enumerate().take(options.window_size) {
            let hann = if options.window_size <= 1 {
                1.0
            } else {
                0.5 * (1.0
                    - (2.0 * std::f64::consts::PI * k as f64 / (options.window_size - 1) as f64)
                        .cos())
            };
            window[k] = sample as f64 * hann;
        }
        let mags = crate::compute::fft::fft_magnitude(&window);
        let scale = options.window_size.max(1) as f32;
        spectra.push(
            mags.into_iter()
                .take(half_bins)
                .map(|mag| {
                    let normalized = (mag as f32 / scale).max(1e-12);
                    20.0 * normalized.log10()
                })
                .collect(),
        );
    }
    spectra
}

fn frequency_bin_for_pixel(
    py: u32,
    height: u32,
    bin_count: usize,
    sample_rate: u32,
    log_frequency: bool,
) -> f32 {
    let nyquist = (sample_rate as f32 * 0.5).max(MIN_FREQUENCY_HZ * 2.0);
    let y_norm = (height - 1 - py) as f32 / (height - 1).max(1) as f32;
    let freq = if log_frequency {
        let min_freq = MIN_FREQUENCY_HZ.min(nyquist * 0.5);
        min_freq * (nyquist / min_freq).powf(y_norm)
    } else {
        y_norm * nyquist
    };
    let max_bin = bin_count.saturating_sub(1).max(1) as f32;
    (freq / nyquist * max_bin).clamp(0.0, max_bin)
}

fn sample_bin_db(mags: &[f32], bin: f32) -> f32 {
    if mags.is_empty() {
        return -120.0;
    }
    let low = bin.floor() as usize;
    let high = bin.ceil() as usize;
    if low == high || high >= mags.len() {
        return mags[low.min(mags.len() - 1)];
    }
    let t = bin - low as f32;
    mags[low] * (1.0 - t) + mags[high] * t
}

/// Map normalized magnitude `t` in [0,1] to an RGB heatmap colour.
fn heat_colour(t: f32) -> Rgba<u8> {
    let (r, g, b) = if t < 0.25 {
        let u = t / 0.25;
        (0.0_f32, 0.0, u)
    } else if t < 0.5 {
        let u = (t - 0.25) / 0.25;
        (0.0, u, 1.0)
    } else if t < 0.75 {
        let u = (t - 0.5) / 0.25;
        (u, 1.0, 1.0 - u)
    } else {
        let u = (t - 0.75) / 0.25;
        (1.0, 1.0, u)
    };
    Rgba([(r * 255.0) as u8, (g * 255.0) as u8, (b * 255.0) as u8, 255])
}
