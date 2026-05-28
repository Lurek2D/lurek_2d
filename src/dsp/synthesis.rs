//! Procedural audio synthesis: waveform oscillators, noise generation, ADSR envelope, and multi-oscillator rendering.
//!
//! - `Waveform` selects the oscillator shape — sine, square, sawtooth, triangle, or white noise — and exposes `parse()` for name-based construction from Lua configuration.
//! - `AdsrEnvelope` applies attack, decay, sustain, and release amplitude shaping; `amplitude_at(elapsed)` returns the gain multiplier at any point in the note's lifetime.
//! - `Synthesizer` combines a `Waveform` oscillator and an `AdsrEnvelope` to render a complete `SoundData` PCM buffer at a given frequency, duration, sample rate, and peak amplitude.
//! - All rendering is CPU-side in a tight sample loop; the resulting `SoundData` is passed to `rodio` for device mixing via the audio subsystem.

use crate::audio::sound_data::SoundData;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
/// Procedural oscillator waveform type.
pub enum Waveform {
    /// Sine oscillator.
    Sine,
    /// Square oscillator.
    Square,
    /// Sawtooth oscillator.
    Sawtooth,
    /// Triangle oscillator.
    Triangle,
    /// White noise generator.
    WhiteNoise,
}

impl Waveform {
    /// Parse a waveform name.
    pub fn parse(kind: &str) -> Result<Self, String> {
        match kind {
            "sine" => Ok(Self::Sine),
            "square" => Ok(Self::Square),
            "sawtooth" => Ok(Self::Sawtooth),
            "triangle" => Ok(Self::Triangle),
            "white_noise" | "noise" | "whiteNoise" => Ok(Self::WhiteNoise),
            other => Err(format!(
                "unknown waveform '{}'; expected sine, square, sawtooth, triangle, or white_noise",
                other
            )),
        }
    }

    /// Return the stable Lua-facing waveform name.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Sine => "sine",
            Self::Square => "square",
            Self::Sawtooth => "sawtooth",
            Self::Triangle => "triangle",
            Self::WhiteNoise => "white_noise",
        }
    }

    /// Render a mono sound buffer for this waveform.
    pub fn render(self, freq: f32, duration: f32, sample_rate: u32, amplitude: f32) -> SoundData {
        match self {
            Self::Sine => SoundData::sine_wave(freq, duration, sample_rate, amplitude),
            Self::Square => SoundData::square_wave(freq, duration, sample_rate, amplitude),
            Self::Sawtooth => SoundData::sawtooth_wave(freq, duration, sample_rate, amplitude),
            Self::Triangle => SoundData::triangle_wave(freq, duration, sample_rate, amplitude),
            Self::WhiteNoise => SoundData::white_noise(duration, sample_rate, amplitude, 1),
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum EnvelopePhase {
    Idle,
    Attack,
    Decay,
    Sustain,
    Release,
}

#[derive(Debug, Clone)]
/// ADSR amplitude envelope with sample-by-sample state.
pub struct AdsrEnvelope {
    /// Attack duration in seconds.
    pub attack: f32,
    /// Decay duration in seconds.
    pub decay: f32,
    /// Sustain gain in `[0, 1]`.
    pub sustain: f32,
    /// Release duration in seconds.
    pub release: f32,
    phase: EnvelopePhase,
    level: f32,
    sample_rate: u32,
}

impl AdsrEnvelope {
    /// Create a new ADSR envelope.
    pub fn new(attack: f32, decay: f32, sustain: f32, release: f32) -> Self {
        Self {
            attack: attack.max(0.0),
            decay: decay.max(0.0),
            sustain: sustain.clamp(0.0, 1.0),
            release: release.max(0.0),
            phase: EnvelopePhase::Idle,
            level: 0.0,
            sample_rate: 44_100,
        }
    }

    /// Start the envelope attack phase.
    pub fn trigger_on(&mut self) {
        self.phase = EnvelopePhase::Attack;
    }

    /// Start the envelope release phase.
    pub fn trigger_off(&mut self) {
        self.phase = EnvelopePhase::Release;
    }

    /// Return the next envelope gain sample.
    pub fn next_sample(&mut self) -> f32 {
        let sr = self.sample_rate as f32;
        match self.phase {
            EnvelopePhase::Idle => 0.0,
            EnvelopePhase::Attack => {
                let step = if self.attack <= 0.0 { 1.0 } else { 1.0 / (self.attack * sr) };
                self.level = (self.level + step).min(1.0);
                if self.level >= 1.0 {
                    self.phase = EnvelopePhase::Decay;
                }
                self.level
            }
            EnvelopePhase::Decay => {
                let step = if self.decay <= 0.0 {
                    1.0
                } else {
                    (1.0 - self.sustain) / (self.decay * sr)
                };
                self.level = (self.level - step).max(self.sustain);
                if self.level <= self.sustain {
                    self.phase = EnvelopePhase::Sustain;
                }
                self.level
            }
            EnvelopePhase::Sustain => self.sustain,
            EnvelopePhase::Release => {
                let step = if self.release <= 0.0 { 1.0 } else { self.level / (self.release * sr) };
                self.level = (self.level - step).max(0.0);
                if self.level <= 0.0 {
                    self.phase = EnvelopePhase::Idle;
                }
                self.level
            }
        }
    }

    /// Return true when the envelope is idle.
    pub fn is_idle(&self) -> bool {
        self.phase == EnvelopePhase::Idle
    }

    /// Apply this envelope to a whole sound buffer.
    pub fn apply(&self, sound_data: &mut SoundData) {
        sound_data.apply_adsr(self.attack, self.decay, self.sustain, self.release);
    }

    /// Set the sample rate used by `next_sample`.
    pub fn set_sample_rate(&mut self, sample_rate: u32) {
        self.sample_rate = sample_rate.max(1);
    }
}

#[derive(Debug, Clone)]
/// Simple procedural synthesizer combining a waveform and optional envelope.
pub struct Synthesizer {
    waveform: Waveform,
    envelope: Option<AdsrEnvelope>,
}

impl Synthesizer {
    /// Create a synthesizer using a sine waveform and no envelope.
    pub fn new() -> Self {
        Self {
            waveform: Waveform::Sine,
            envelope: None,
        }
    }

    /// Return a copy of this synthesizer with an envelope attached.
    pub fn with_envelope(mut self, envelope: AdsrEnvelope) -> Self {
        self.envelope = Some(envelope);
        self
    }

    /// Set the oscillator waveform.
    pub fn set_waveform(&mut self, waveform: Waveform) {
        self.waveform = waveform;
    }

    /// Set the optional envelope.
    pub fn set_envelope(&mut self, envelope: AdsrEnvelope) {
        self.envelope = Some(envelope);
    }

    /// Generate a sound buffer.
    pub fn generate(&self, freq: f32, duration: f32, sample_rate: u32, amplitude: f32) -> SoundData {
        let mut sound_data = self.waveform.render(freq, duration, sample_rate, amplitude);
        if let Some(envelope) = &self.envelope {
            envelope.apply(&mut sound_data);
        }
        sound_data
    }
}

impl Default for Synthesizer {
    fn default() -> Self {
        Self::new()
    }
}
