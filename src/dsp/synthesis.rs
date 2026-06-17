//! Provides procedural audio synthesis primitives for waveform generation and envelope-shaped note rendering. `dsp/synthesis` delivers the synthesis implementation for the dsp subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Defines stable oscillator forms and parsing paths that map script choices to deterministic sample output. The file owns or coordinates data contracts including `Waveform`, `AdsrEnvelope`, `Synthesizer`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Applies ADSR gain shaping so rendered notes include natural attack, sustain behavior, and release tails. Public callable behavior is centered on no named public items, while method-level behavior such as `parse`, `as_str`, `render`, `new`, `trigger_on`, `trigger_off`, and 8 more stays attached to the local data model and invariants.
//! Combines oscillator and envelope models into renderable buffers ready for playback and further processing. Runtime integration reaches sibling engine areas through crate modules `audio`, which explains the subsystem dependencies an agent should inspect before changing behavior.
//! Delivers the synthesis layer used for generated sound effects and lightweight musical content. External integration uses no named public items, keeping third-party API details localized so higher layers continue to consume stable Lurek2D-owned abstractions.

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
    /// Parses a waveform name string into the matching enum variant.
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
    /// Creates a new ADSR envelope with clamped parameter bounds.
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
                let step = if self.attack <= 0.0 {
                    1.0
                } else {
                    1.0 / (self.attack * sr)
                };
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
                let step = if self.release <= 0.0 {
                    1.0
                } else {
                    self.level / (self.release * sr)
                };
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

    /// Sets the optional ADSR envelope used during synthesis.
    pub fn set_envelope(&mut self, envelope: AdsrEnvelope) {
        self.envelope = Some(envelope);
    }

    /// Generates a sound buffer from waveform and optional envelope.
    pub fn generate(
        &self,
        freq: f32,
        duration: f32,
        sample_rate: u32,
        amplitude: f32,
    ) -> SoundData {
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
