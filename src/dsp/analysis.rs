//! `src/dsp/analysis.rs` owns realtime signal measurement for loudness, peaks, clipping, and bounded spectrum summaries.
//! It stores rolling RMS and peak state in `LevelDetector` and delegates spectral bins through `SpectrumAnalyzer`.
//! This file is the measurement boundary for runtime diagnostics and Lua-facing analysis; it does not alter audio samples.
//! SoundData-wide scans and per-sample accumulation both live here so analysis semantics stay consistent across call sites.
//! Read it when meter behavior, clipping thresholds, DFT bin sizing, or diagnostic signal analysis rules need changes.

use crate::audio::sound_data::SoundData;

/// Running level detector for RMS, peak, and clipping checks.
#[derive(Debug, Clone)]
pub struct LevelDetector {
    sum_squares: f32,
    peak: f32,
    sample_count: usize,
    clipping_threshold: f32,
    clipping: bool,
}

impl LevelDetector {
    /// Create a detector with the provided clipping threshold.
    pub fn new(clipping_threshold: f32) -> Self {
        Self {
            sum_squares: 0.0,
            peak: 0.0,
            sample_count: 0,
            clipping_threshold: clipping_threshold.clamp(0.0, 1.0),
            clipping: false,
        }
    }

    /// Process one sample and update detector state.
    pub fn process_sample(&mut self, sample: f32) {
        let abs = sample.abs();
        self.sum_squares += sample * sample;
        self.peak = self.peak.max(abs);
        self.sample_count += 1;
        if abs >= self.clipping_threshold {
            self.clipping = true;
        }
    }

    /// Process an entire sound buffer and return `(rms, peak, clipping)`.
    pub fn process_sound_data(&mut self, sound_data: &SoundData) -> (f32, f32, bool) {
        self.reset();
        for &sample in sound_data.samples() {
            self.process_sample(sample);
        }
        (self.get_rms(), self.get_peak(), self.clipping)
    }

    /// Return the current RMS level.
    pub fn get_rms(&self) -> f32 {
        if self.sample_count == 0 {
            0.0
        } else {
            (self.sum_squares / self.sample_count as f32).sqrt()
        }
    }

    /// Return the current peak level.
    pub fn get_peak(&self) -> f32 {
        self.peak
    }

    /// Return whether any processed sample reached the clipping threshold.
    pub fn is_clipping(&self) -> bool {
        self.clipping
    }

    /// Convert a linear amplitude to decibels full scale.
    pub fn to_db(value: f32) -> f32 {
        if value <= 0.0 {
            f32::NEG_INFINITY
        } else {
            20.0 * value.log10()
        }
    }

    /// Resets all accumulated detector state counters to defaults.
    pub fn reset(&mut self) {
        self.sum_squares = 0.0;
        self.peak = 0.0;
        self.sample_count = 0;
        self.clipping = false;
    }
}

impl Default for LevelDetector {
    fn default() -> Self {
        Self::new(0.99)
    }
}

/// Bounded spectrum analyzer using the SoundData DFT helper.
#[derive(Debug, Clone)]
pub struct SpectrumAnalyzer {
    size: usize,
}

impl SpectrumAnalyzer {
    /// Create a spectrum analyzer with a bounded bin count.
    pub fn new(size: usize) -> Self {
        Self {
            size: size.clamp(1, 512),
        }
    }

    /// Sets the analyzer output bin count with safe clamping.
    pub fn set_size(&mut self, size: usize) {
        self.size = size.clamp(1, 512);
    }

    /// Analyze a sound buffer and return `(frequency, magnitude)` bins.
    pub fn analyze(&self, sound_data: &SoundData) -> Vec<(f32, f32)> {
        sound_data.analyze_dft(self.size)
    }
}

impl Default for SpectrumAnalyzer {
    fn default() -> Self {
        Self::new(512)
    }
}
