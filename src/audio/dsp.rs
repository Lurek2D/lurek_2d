//! Digital signal processing effects for the Lurek2D audio pipeline.
//!
//! Provides `AtomicParam` for lock-free parameter updates, `ActiveEffect` for
//! tracking DSP state, and a full set of audio effects: biquad filters, shelf EQ,
//! notch, bell EQ, reverb (two variants), chorus, flanger, phaser, distortion,
//! compressor, and brick-wall limiter.

use rodio::Source;
use std::sync::atomic::{AtomicU32, Ordering};
use std::sync::{Arc, RwLock};

use crate::runtime::log_messages::{DP01, DP02, DP03};
use crate::log_msg;

/// Thread-safe atomic `f32` parameter backed by an `AtomicU32` bit-cast.
///
/// Allows lock-free reads and writes across the audio thread and the main
/// engine thread without requiring a `Mutex`.
///
/// # Fields
/// - `val` — `AtomicU32` storing the bit pattern of the `f32` value.
#[derive(Debug)]
pub struct AtomicParam {
    val: AtomicU32,
}

impl AtomicParam {
    /// Creates a new `AtomicParam` initialised to `val`.
    ///
    /// # Parameters
    /// - `val` — `f32`. Initial parameter value.
    ///
    /// # Returns
    /// `Self`.
    pub fn new(val: f32) -> Self {
        Self {
            val: AtomicU32::new(val.to_bits()),
        }
    }

    /// Returns the current value, loaded with `Relaxed` ordering.
    ///
    /// # Returns
    /// `f32`.
    pub fn get(&self) -> f32 {
        f32::from_bits(self.val.load(Ordering::Relaxed))
    }

    /// Stores a new value with `Relaxed` ordering.
    ///
    /// # Parameters
    /// - `val` — `f32`. New parameter value.
    pub fn set(&self, val: f32) {
        self.val.store(val.to_bits(), Ordering::Relaxed);
    }
}

/// Category of DSP audio effect applied to a sound source.
///
/// # Variants
/// - `Lowpass` — Low-pass biquad filter; attenuates high frequencies above the cutoff.
/// - `Highpass` — High-pass biquad filter; attenuates low frequencies below the cutoff.
/// - `Bandpass` — Band-pass biquad filter; passes only a band around the center frequency.
/// - `Notch` — Notch (band-reject) biquad; cuts a narrow frequency band.
/// - `LowShelf` — Low-shelf EQ; boosts or cuts frequencies below the shelf frequency.
/// - `HighShelf` — High-shelf EQ; boosts or cuts frequencies above the shelf frequency.
/// - `BellEq` — Peaking (bell) EQ; boosts or cuts a bell-shaped band around the centre.
/// - `Reverb` — Comb-filter reverb with room-size and mix controls.
/// - `Reverb2` — Multi-tap comb reverb with pre-delay and damping controls.
/// - `Chorus` — Short-delay chorus with decay and mix controls.
/// - `Flanger` — LFO-modulated very-short delay (1–5 ms); metallic sweep.
/// - `Phaser` — Allpass-approximated phaser with LFO rate, depth, and mix.
/// - `Distortion` — Hard-clip waveshaper; drive sets clipping threshold.
/// - `Limiter` — Brick-wall peak limiter; gain reduced whenever signal exceeds threshold.
/// - `Compressor` — Dynamic-range compressor with threshold, ratio, and makeup gain.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum EffectType {
    Lowpass,
    Highpass,
    Bandpass,
    Notch,
    LowShelf,
    HighShelf,
    BellEq,
    Reverb,
    Reverb2,
    Chorus,
    Flanger,
    Phaser,
    Distortion,
    Limiter,
    Compressor,
}

/// Shared configuration for a single DSP effect slot.
///
/// `EffectParams` is shared between the main thread (which sets parameters)
/// and the audio thread (which reads them) via `Arc<EffectParams>`.
/// All parameter mutations go through `AtomicParam` to avoid locking.
///
/// # Fields
/// - `id` — `u32`. Unique monotonic slot identifier.
/// - `typ` — `EffectType`. The category of DSP effect.
/// - `p1` — `AtomicParam`. Primary parameter (cutoff / room\_size / drive / threshold).
/// - `p2` — `AtomicParam`. Secondary parameter (q / bandwidth / mix / ratio / gain\_db).
/// - `p3` — `AtomicParam`. Tertiary parameter (mix / pre\_delay / makeup\_gain / release).
#[derive(Debug)]
pub struct EffectParams {
    pub id: u32,
    pub typ: EffectType,
    pub p1: AtomicParam, // cutoff / room_size
    pub p2: AtomicParam, // center / mix
    pub p3: AtomicParam, // unused for now
}

impl EffectParams {
    /// Creates a new `EffectParams` with the given slot ID and effect type.
    ///
    /// # Parameters
    /// - `id` — `u32`. Unique monotonic slot identifier.
    /// - `typ` — `EffectType`. The category of DSP effect.
    ///
    /// # Returns
    /// `Self`.
    pub fn new(id: u32, typ: EffectType) -> Self {
        log_msg!(debug, DP01, "id={}", id);
        Self {
            id,
            typ,
            p1: AtomicParam::new(0.0),
            p2: AtomicParam::new(0.0),
            p3: AtomicParam::new(0.0),
        }
    }

    /// Sets an effect parameter by name using lock-free atomic writes.
    ///
    /// Valid parameter names depend on the effect type:
    /// - Biquad filters (`lowpass`, `highpass`, `bandpass`): `"cutoff"` / `"frequency"`, `"q"`, `"mix"`.
    /// - `notch`: `"cutoff"` / `"frequency"`, `"bandwidth"`.
    /// - `lowshelf` / `highshelf`: `"cutoff"` / `"frequency"`, `"gain_db"`.
    /// - `bell_eq`: `"cutoff"` / `"frequency"`, `"gain_db"`, `"q"`.
    /// - `reverb`: `"room_size"`, `"damping"`, `"mix"`.
    /// - `reverb2`: `"room_size"`, `"damping"`, `"pre_delay"`, `"mix"`.
    /// - `chorus` / `flanger` / `phaser`: `"rate"`, `"depth"`, `"mix"`.
    /// - `distortion`: `"drive"`, `"mix"`.
    /// - `limiter`: `"threshold"`, `"release"`.
    /// - `compressor`: `"threshold"`, `"ratio"`, `"makeup_gain"`.
    ///
    /// # Parameters
    /// - `param` — `&str`. The parameter name.
    /// - `value` — `f32`. The parameter value.
    ///
    /// # Returns
    /// `Result<(), String>`.
    pub fn set_param(&self, param: &str, value: f32) -> Result<(), String> {
        match self.typ {
            EffectType::Lowpass | EffectType::Highpass | EffectType::Bandpass => match param {
                "cutoff" | "frequency" => {
                    self.p1.set(value);
                    Ok(())
                }
                "q" => {
                    self.p2.set(value);
                    Ok(())
                }
                "mix" => {
                    self.p3.set(value);
                    Ok(())
                }
                _ => Err(format!("invalid parameter: {}", param)),
            },
            EffectType::Notch => match param {
                "cutoff" | "frequency" => {
                    self.p1.set(value);
                    Ok(())
                }
                "bandwidth" | "q" => {
                    self.p2.set(value);
                    Ok(())
                }
                _ => Err(format!("invalid parameter: {}", param)),
            },
            EffectType::LowShelf | EffectType::HighShelf => match param {
                "cutoff" | "frequency" => {
                    self.p1.set(value);
                    Ok(())
                }
                "gain_db" => {
                    self.p2.set(value);
                    Ok(())
                }
                _ => Err(format!("invalid parameter: {}", param)),
            },
            EffectType::BellEq => match param {
                "cutoff" | "frequency" => {
                    self.p1.set(value);
                    Ok(())
                }
                "gain_db" => {
                    self.p2.set(value);
                    Ok(())
                }
                "q" => {
                    self.p3.set(value);
                    Ok(())
                }
                _ => Err(format!("invalid parameter: {}", param)),
            },
            EffectType::Reverb => match param {
                "room_size" => {
                    self.p1.set(value);
                    Ok(())
                }
                "damping" => {
                    self.p2.set(value);
                    Ok(())
                }
                "mix" => {
                    self.p3.set(value);
                    Ok(())
                }
                _ => Err(format!("invalid parameter: {}", param)),
            },
            EffectType::Reverb2 => match param {
                "room_size" => {
                    self.p1.set(value);
                    Ok(())
                }
                "damping" | "pre_delay" => {
                    self.p2.set(value);
                    Ok(())
                }
                "mix" => {
                    self.p3.set(value);
                    Ok(())
                }
                _ => Err(format!("invalid parameter: {}", param)),
            },
            EffectType::Chorus | EffectType::Flanger | EffectType::Phaser => match param {
                "rate" => {
                    self.p1.set(value);
                    Ok(())
                }
                "depth" => {
                    self.p2.set(value);
                    Ok(())
                }
                "mix" => {
                    self.p3.set(value);
                    Ok(())
                }
                _ => Err(format!("invalid parameter: {}", param)),
            },
            EffectType::Distortion => match param {
                "drive" => {
                    self.p1.set(value);
                    Ok(())
                }
                "mix" => {
                    self.p2.set(value);
                    Ok(())
                }
                _ => Err(format!("invalid parameter: {}", param)),
            },
            EffectType::Limiter => match param {
                "threshold" => {
                    self.p1.set(value);
                    Ok(())
                }
                "release" => {
                    self.p2.set(value);
                    Ok(())
                }
                _ => Err(format!("invalid parameter: {}", param)),
            },
            EffectType::Compressor => match param {
                "threshold" => {
                    self.p1.set(value);
                    Ok(())
                }
                "ratio" => {
                    self.p2.set(value);
                    Ok(())
                }
                "makeup_gain" => {
                    self.p3.set(value);
                    Ok(())
                }
                _ => Err(format!("invalid parameter: {}", param)),
            },
        }
    }
}

// --- AtomicParam unit tests ---

// Tests migrated to tests/rust/unit/audio_tests.rs

/// Per-stream instantiation of an `EffectParams` slot, holding the filter state for a single audio stream.
///
/// One `ActiveEffect` is created per `EffectParams` inside each `DynamicEffectSource`.
/// It owns the biquad filter history (`bq_x1`/`bq_x2`/`bq_y1`/`bq_y2`) for two channels
/// and the comb-filter delay buffer used by the reverb and chorus effects.
///
/// # Fields
/// - `params` — `Arc<EffectParams>`. Shared reference to the effect configuration.
/// - `bq_x1`/`bq_x2` — `[f32; 2]`. Biquad input history for left and right channels.
/// - `bq_y1`/`bq_y2` — `[f32; 2]`. Biquad output history for left and right channels.
/// - `comb_buf` — `Vec<f32>`. Delay-line ring buffer for reverb/chorus/flanger/phaser.
/// - `comb_pos` — `usize`. Current write head position in `comb_buf`.
/// - `compressor_env` — `f32`. Running RMS envelope level for the compressor sidechain.
/// - `lfo_phase` — `f32`. Current LFO phase (radians) for flanger/phaser/chorus modulation.
#[derive(Clone)]
pub struct ActiveEffect {
    pub params: Arc<EffectParams>,
    // biquad state: x1, x2, y1, y2 for 2 channels
    pub bq_x1: [f32; 2],
    pub bq_x2: [f32; 2],
    pub bq_y1: [f32; 2],
    pub bq_y2: [f32; 2],
    // comb state
    pub comb_buf: Vec<f32>,
    pub comb_pos: usize,
    // compressor sidechain envelope
    pub compressor_env: f32,
    // LFO phase for modulation effects
    pub lfo_phase: f32,
}

impl ActiveEffect {
    /// Creates a new `ActiveEffect` for the given effect configuration.
    ///
    /// Allocates the comb-filter delay buffer sized to `sample_rate` and `channels`.
    ///
    /// # Parameters
    /// - `params` — `Arc<EffectParams>`. Shared effect slot configuration.
    /// - `sample_rate` — `u32`. Sample rate of the audio stream.
    /// - `channels` — `u16`. Channel count of the audio stream.
    ///
    /// # Returns
    /// `Self`.
    pub fn new(params: Arc<EffectParams>, sample_rate: u32, channels: u16) -> Self {
        // Allocate a delay buffer large enough for the effect's maximum delay requirement.
        // Flanger/Phaser use very short delays (5 ms); Reverb/Chorus use longer ones (50 ms).
        // Reverb2 uses the largest buffer (120 ms for long tails with pre-delay).
        let comb_len = match params.typ {
            EffectType::Reverb | EffectType::Chorus => {
                let ms = if params.typ == EffectType::Chorus {
                    0.02
                } else {
                    0.05
                };
                ((sample_rate as f32 * ms) as usize * channels as usize).max(1)
            }
            EffectType::Reverb2 => {
                // 120 ms for multi-tap reverb plus pre-delay headroom
                ((sample_rate as f32 * 0.12) as usize * channels as usize).max(1)
            }
            EffectType::Flanger => {
                // 5 ms max flanger delay
                ((sample_rate as f32 * 0.005) as usize * channels as usize).max(1)
            }
            EffectType::Phaser => {
                // 10 ms buffer for allpass approximation
                ((sample_rate as f32 * 0.01) as usize * channels as usize).max(1)
            }
            _ => 1,
        };

        log_msg!(debug, DP02, "sr={} ch={}", sample_rate, channels);

        Self {
            params,
            bq_x1: [0.0; 2],
            bq_x2: [0.0; 2],
            bq_y1: [0.0; 2],
            bq_y2: [0.0; 2],
            comb_buf: vec![0.0; comb_len],
            comb_pos: 0,
            compressor_env: 0.0,
            lfo_phase: 0.0,
        }
    }

    /// Applies this effect's DSP algorithm to a single PCM sample.
    ///
    /// # Parameters
    /// - `sample` — `f32`. The input PCM sample.
    /// - `channel` — `u16`. The interleaved channel index (0 = left, 1 = right).
    /// - `sample_rate` — `u32`. Sample rate of the audio stream.
    ///
    /// # Returns
    /// `f32`. The processed output sample.
    pub fn process(&mut self, sample: f32, channel: u16, sample_rate: u32) -> f32 {
        let c = (channel as usize) % 2;
        let typ = self.params.typ;
        let sr = sample_rate as f32;

        match typ {
            // ── Biquad filters ───────────────────────────────────────────────────────
            // Standard second-order IIR (biquad) using the Audio EQ Cookbook formulae.
            // w0 = normalised angular frequency; alpha = bandwidth parameter from Q.
            EffectType::Lowpass | EffectType::Highpass | EffectType::Bandpass => {
                let f0 = self.params.p1.get().clamp(20.0, 20000.0);
                let q = 0.707_f32; // Butterworth Q for maximally flat passband
                let w0 = 2.0 * std::f32::consts::PI * f0 / sr;
                let alpha = w0.sin() / (2.0 * q);
                let cos_w0 = w0.cos();

                let (b0, b1, b2, a0, a1, a2) = match typ {
                    EffectType::Lowpass => (
                        (1.0 - cos_w0) / 2.0,
                        1.0 - cos_w0,
                        (1.0 - cos_w0) / 2.0,
                        1.0 + alpha,
                        -2.0 * cos_w0,
                        1.0 - alpha,
                    ),
                    EffectType::Highpass => (
                        (1.0 + cos_w0) / 2.0,
                        -(1.0 + cos_w0),
                        (1.0 + cos_w0) / 2.0,
                        1.0 + alpha,
                        -2.0 * cos_w0,
                        1.0 - alpha,
                    ),
                    EffectType::Bandpass => (
                        w0.sin() / 2.0,
                        0.0,
                        -w0.sin() / 2.0,
                        1.0 + alpha,
                        -2.0 * cos_w0,
                        1.0 - alpha,
                    ),
                    _ => unreachable!(),
                };

                // Direct-form I biquad: y[n] = (b0*x[n] + b1*x[n-1] + b2*x[n-2]
                //                                - a1*y[n-1] - a2*y[n-2]) / a0
                let x0 = sample;
                let out = (b0 / a0) * x0 + (b1 / a0) * self.bq_x1[c] + (b2 / a0) * self.bq_x2[c]
                    - (a1 / a0) * self.bq_y1[c]
                    - (a2 / a0) * self.bq_y2[c];

                // Shift delay-line history for next sample
                self.bq_x2[c] = self.bq_x1[c];
                self.bq_x1[c] = x0;
                self.bq_y2[c] = self.bq_y1[c];
                self.bq_y1[c] = out;

                out
            }

            // ── Notch (band-reject) ──────────────────────────────────────────────────
            EffectType::Notch => {
                let f0 = self.params.p1.get().clamp(20.0, 20000.0);
                let bw = self.params.p2.get().clamp(10.0, 5000.0).max(10.0);
                let q = f0 / bw;
                let w0 = 2.0 * std::f32::consts::PI * f0 / sr;
                let alpha = w0.sin() / (2.0 * q);
                let cos_w0 = w0.cos();
                let a0 = 1.0 + alpha;

                let x0 = sample;
                let out = (1.0 / a0) * x0
                    + (-2.0 * cos_w0 / a0) * self.bq_x1[c]
                    + (1.0 / a0) * self.bq_x2[c]
                    - (-2.0 * cos_w0 / a0) * self.bq_y1[c]
                    - ((1.0 - alpha) / a0) * self.bq_y2[c];

                self.bq_x2[c] = self.bq_x1[c];
                self.bq_x1[c] = x0;
                self.bq_y2[c] = self.bq_y1[c];
                self.bq_y1[c] = out;
                out
            }

            // ── Low-shelf and High-shelf EQ ──────────────────────────────────────────
            EffectType::LowShelf | EffectType::HighShelf => {
                let f0 = self.params.p1.get().clamp(20.0, 20000.0);
                let gain_db = self.params.p2.get().clamp(-24.0, 24.0);
                let a_gain = 10.0_f32.powf(gain_db / 40.0); // sqrt(10^(dB/20))
                let w0 = 2.0 * std::f32::consts::PI * f0 / sr;
                let cos_w0 = w0.cos();
                let sin_w0 = w0.sin();
                let alpha = sin_w0 / 2.0 * (a_gain + 1.0 / a_gain).sqrt();

                let (b0, b1, b2, a0, a1, a2) = if typ == EffectType::LowShelf {
                    (
                        a_gain * ((a_gain + 1.0) - (a_gain - 1.0) * cos_w0 + 2.0 * a_gain.sqrt() * alpha),
                        2.0 * a_gain * ((a_gain - 1.0) - (a_gain + 1.0) * cos_w0),
                        a_gain * ((a_gain + 1.0) - (a_gain - 1.0) * cos_w0 - 2.0 * a_gain.sqrt() * alpha),
                        (a_gain + 1.0) + (a_gain - 1.0) * cos_w0 + 2.0 * a_gain.sqrt() * alpha,
                        -2.0 * ((a_gain - 1.0) + (a_gain + 1.0) * cos_w0),
                        (a_gain + 1.0) + (a_gain - 1.0) * cos_w0 - 2.0 * a_gain.sqrt() * alpha,
                    )
                } else {
                    // HighShelf
                    (
                        a_gain * ((a_gain + 1.0) + (a_gain - 1.0) * cos_w0 + 2.0 * a_gain.sqrt() * alpha),
                        -2.0 * a_gain * ((a_gain - 1.0) + (a_gain + 1.0) * cos_w0),
                        a_gain * ((a_gain + 1.0) + (a_gain - 1.0) * cos_w0 - 2.0 * a_gain.sqrt() * alpha),
                        (a_gain + 1.0) - (a_gain - 1.0) * cos_w0 + 2.0 * a_gain.sqrt() * alpha,
                        2.0 * ((a_gain - 1.0) - (a_gain + 1.0) * cos_w0),
                        (a_gain + 1.0) - (a_gain - 1.0) * cos_w0 - 2.0 * a_gain.sqrt() * alpha,
                    )
                };

                let x0 = sample;
                let out = (b0 / a0) * x0 + (b1 / a0) * self.bq_x1[c] + (b2 / a0) * self.bq_x2[c]
                    - (a1 / a0) * self.bq_y1[c]
                    - (a2 / a0) * self.bq_y2[c];

                self.bq_x2[c] = self.bq_x1[c];
                self.bq_x1[c] = x0;
                self.bq_y2[c] = self.bq_y1[c];
                self.bq_y1[c] = out;
                out
            }

            // ── Bell (peaking) EQ ────────────────────────────────────────────────────
            EffectType::BellEq => {
                let f0 = self.params.p1.get().clamp(20.0, 20000.0);
                let gain_db = self.params.p2.get().clamp(-24.0, 24.0);
                let q = self.params.p3.get().max(0.1).max(0.1);
                let q = if q <= 0.0 { 1.0 } else { q };
                let a_gain = 10.0_f32.powf(gain_db / 40.0);
                let w0 = 2.0 * std::f32::consts::PI * f0 / sr;
                let alpha = w0.sin() / (2.0 * q);
                let cos_w0 = w0.cos();
                let a0 = 1.0 + alpha / a_gain;

                let x0 = sample;
                let out = ((1.0 + alpha * a_gain) / a0) * x0
                    + ((-2.0 * cos_w0) / a0) * self.bq_x1[c]
                    + ((1.0 - alpha * a_gain) / a0) * self.bq_x2[c]
                    - ((-2.0 * cos_w0) / a0) * self.bq_y1[c]
                    - ((1.0 - alpha / a_gain) / a0) * self.bq_y2[c];

                self.bq_x2[c] = self.bq_x1[c];
                self.bq_x1[c] = x0;
                self.bq_y2[c] = self.bq_y1[c];
                self.bq_y1[c] = out;
                out
            }

            // ── Reverb (single comb) ─────────────────────────────────────────────────
            EffectType::Reverb | EffectType::Chorus => {
                let p1 = self.params.p1.get(); // room_size / decay
                let p2 = self.params.p2.get(); // mix

                let delayed = self.comb_buf[self.comb_pos];
                self.comb_buf[self.comb_pos] = sample + delayed * p1;
                self.comb_pos = (self.comb_pos + 1) % self.comb_buf.len();

                sample * (1.0 - p2) + delayed * p2
            }

            // ── Reverb2 (multi-tap with damping) ─────────────────────────────────────
            EffectType::Reverb2 => {
                let room_size = self.params.p1.get().clamp(0.0, 1.0);
                let damping = self.params.p2.get().clamp(0.0, 1.0);
                let mix = self.params.p3.get().clamp(0.0, 1.0);

                let buf_len = self.comb_buf.len().max(1);
                // Four evenly-spaced taps across the buffer for a richer tail
                let tap_offsets = [
                    buf_len / 4,
                    buf_len / 3,
                    buf_len / 2,
                    (buf_len * 2) / 3,
                ];

                let mut wet = 0.0_f32;
                for offset in tap_offsets {
                    let tap_pos = (self.comb_pos + buf_len - offset) % buf_len;
                    wet += self.comb_buf[tap_pos];
                }
                wet *= 0.25; // average across taps

                // Apply damping to stored signal
                let store = sample + wet * room_size * (1.0 - damping);
                self.comb_buf[self.comb_pos] = store;
                self.comb_pos = (self.comb_pos + 1) % buf_len;

                sample * (1.0 - mix) + wet * mix
            }

            // ── Flanger (LFO-modulated short delay) ──────────────────────────────────
            EffectType::Flanger => {
                let rate = self.params.p1.get().clamp(0.01, 10.0);
                let depth = self.params.p2.get().clamp(0.0, 1.0);
                let mix = self.params.p3.get().clamp(0.0, 1.0);
                let buf_len = self.comb_buf.len().max(2);

                // Only advance LFO on the left/first channel to keep L+R in sync
                if c == 0 {
                    self.lfo_phase = (self.lfo_phase + 2.0 * std::f32::consts::PI * rate / sr)
                        % (2.0 * std::f32::consts::PI);
                }

                // modulate delay position within the buffer
                let lfo_val = (self.lfo_phase.sin() + 1.0) * 0.5; // 0..1
                let delay_samps = ((buf_len - 1) as f32 * depth * lfo_val) as usize;
                let tap_pos = (self.comb_pos + buf_len - delay_samps.clamp(0, buf_len - 1)) % buf_len;
                let delayed = self.comb_buf[tap_pos];

                self.comb_buf[self.comb_pos] = sample;
                self.comb_pos = (self.comb_pos + 1) % buf_len;

                sample * (1.0 - mix) + delayed * mix
            }

            // ── Phaser (allpass approximation via short comb modulation) ─────────────
            EffectType::Phaser => {
                let rate = self.params.p1.get().clamp(0.01, 10.0);
                let depth = self.params.p2.get().clamp(0.0, 1.0);
                let mix = self.params.p3.get().clamp(0.0, 1.0);
                let buf_len = self.comb_buf.len().max(2);

                if c == 0 {
                    self.lfo_phase = (self.lfo_phase + 2.0 * std::f32::consts::PI * rate / sr)
                        % (2.0 * std::f32::consts::PI);
                }

                let lfo_val = (self.lfo_phase.sin() + 1.0) * 0.5;
                let delay_samps = ((buf_len - 1) as f32 * depth * lfo_val) as usize;
                let tap_pos = (self.comb_pos + buf_len - delay_samps.clamp(0, buf_len - 1)) % buf_len;
                let delayed = self.comb_buf[tap_pos];

                self.comb_buf[self.comb_pos] = sample;
                self.comb_pos = (self.comb_pos + 1) % buf_len;

                // Allpass-like blend: inverting the delayed signal creates phase cancellation
                sample * (1.0 - mix) + (sample - delayed) * mix
            }

            // ── Distortion (hard-clip waveshaper) ────────────────────────────────────
            EffectType::Distortion => {
                let drive = self.params.p1.get().max(1.0);
                let mix = self.params.p2.get().clamp(0.0, 1.0);
                let threshold = 1.0 / drive;
                let driven = sample * drive;
                let clipped = driven.clamp(-1.0, 1.0) * threshold;
                sample * (1.0 - mix) + clipped * mix
            }

            // ── Brick-wall limiter ───────────────────────────────────────────────────
            EffectType::Limiter => {
                let threshold = self.params.p1.get().clamp(0.001, 1.0);
                let release = self.params.p2.get().clamp(0.001, 1.0);
                let abs_s = sample.abs();
                if abs_s > threshold {
                    let gain = threshold / abs_s;
                    // Smooth the gain reduction using a simple one-pole envelope
                    self.compressor_env = self.compressor_env * (1.0 - release) + gain * release;
                } else {
                    // Recover towards 1.0 at release speed
                    self.compressor_env = (self.compressor_env + release).min(1.0);
                }
                sample * self.compressor_env
            }

            // ── Compressor ───────────────────────────────────────────────────────────
            EffectType::Compressor => {
                let threshold = self.params.p1.get().clamp(0.0, 1.0);
                let ratio = self.params.p2.get().max(1.0);
                let makeup = self.params.p3.get().max(0.0);

                // Simple feed-forward RMS compressor with a 10 ms envelope follower
                let attack = 1.0 - (-1.0_f32 / (0.01 * sr)).exp();
                let release_coeff = 1.0 - (-1.0_f32 / (0.1 * sr)).exp();
                let level = sample.abs();
                if level > self.compressor_env {
                    self.compressor_env += attack * (level - self.compressor_env);
                } else {
                    self.compressor_env += release_coeff * (level - self.compressor_env);
                }

                let gain = if self.compressor_env > threshold && threshold > 0.0 {
                    let db_over = 20.0 * (self.compressor_env / threshold).log10();
                    let db_reduced = db_over / ratio;
                    let gain_linear = 10.0_f32.powf(-db_reduced / 20.0);
                    gain_linear * (1.0 + makeup)
                } else {
                    1.0 + makeup
                };

                sample * gain
            }
        }
    }
}

/// Shared, thread-safe graph of active DSP effects owned by a sound source.
///
/// The main thread pushes `Arc<EffectParams>` entries into the graph; the audio
/// thread observes them via a non-blocking `try_read` lock on every sample batch
/// and synchronises its `active_effects` list accordingly.
///
/// # Fields
/// - `effects` — `Arc<RwLock<Vec<Arc<EffectParams>>>>`. The list of effects to apply in order.
pub struct SharedEffectGraph {
    pub effects: Arc<RwLock<Vec<Arc<EffectParams>>>>,
}

impl SharedEffectGraph {
    /// Creates an empty `SharedEffectGraph` with no effects in the chain.
    ///
    /// # Returns
    /// `Self`.
    pub fn new() -> Self {
        log_msg!(debug, DP03);
        Self {
            effects: Arc::new(RwLock::new(Vec::new())),
        }
    }
}

impl Default for SharedEffectGraph {
    fn default() -> Self {
        Self::new()
    }
}

impl SharedEffectGraph {}

/// A rodio `Source` wrapper that applies a dynamic chain of DSP effects to an inner audio source.
///
/// On every audio-thread call to `Iterator::next`, `DynamicEffectSource` checks whether the
/// shared effect list has changed (`sync_effects`) and processes the sample through each
/// `ActiveEffect` in sequence before returning it to the mixer.
///
/// # Type Parameters
/// - `I` — The inner [`rodio::Source`] that produces `f32` samples.
///
/// # Fields
/// - `input` — `I`. The wrapped inner audio source.
/// - `shared_graph` — `Arc<RwLock<Vec<Arc<EffectParams>>>>`. Lock-shared effect configuration.
/// - `active_effects` — `Vec<ActiveEffect>`. Per-stream effect state, synchronised from `shared_graph`.
/// - `current_channel` — `u16`. Interleaved channel index used to route samples to the correct filter lane.
/// - `sample_rate` — `u32`. Sample rate of the inner source, cached for filter coefficient computation.
/// - `channels` — `u16`. Channel count of the inner source.
pub struct DynamicEffectSource<I: Source<Item = f32>> {
    input: I,
    shared_graph: Arc<RwLock<Vec<Arc<EffectParams>>>>,
    active_effects: Vec<ActiveEffect>,
    current_channel: u16,
    sample_rate: u32,
    channels: u16,
}

impl<I: Source<Item = f32>> DynamicEffectSource<I> {
    /// Wraps an inner audio source with a dynamic DSP effect chain.
    ///
    /// # Parameters
    /// - `input` — `I`. The inner rodio source that produces `f32` samples.
    /// - `shared_graph` — `Arc<RwLock<Vec<Arc<EffectParams>>>>`. The shared effect list.
    ///
    /// # Returns
    /// `Self`.
    pub fn new(input: I, shared_graph: Arc<RwLock<Vec<Arc<EffectParams>>>>) -> Self {
        let sample_rate = input.sample_rate();
        let channels = input.channels();
        Self {
            input,
            shared_graph,
            active_effects: Vec::new(),
            current_channel: 0,
            sample_rate,
            channels,
        }
    }

    fn sync_effects(&mut self) {
        if let Ok(guard) = self.shared_graph.try_read() {
            let shared_len = guard.len();
            // simple diffing: just replace if sizes differ. In a real engine, we'd check IDs
            if self.active_effects.len() != shared_len {
                self.active_effects.clear();
                for ef in guard.iter() {
                    self.active_effects.push(ActiveEffect::new(
                        Arc::clone(ef),
                        self.sample_rate,
                        self.channels,
                    ));
                }
            } else {
                for (i, ef) in guard.iter().enumerate() {
                    if self.active_effects[i].params.id != ef.id {
                        self.active_effects[i] =
                            ActiveEffect::new(Arc::clone(ef), self.sample_rate, self.channels);
                    }
                }
            }
        }
    }
}

impl<I: Source<Item = f32>> Iterator for DynamicEffectSource<I> {
    type Item = I::Item;

    fn next(&mut self) -> Option<Self::Item> {
        let sample_opt = self.input.next();
        if let Some(sample) = sample_opt {
            if self.current_channel == 0 {
                // only sync on frames, not interleaved channels
                self.sync_effects();
            }

            let mut current_val = sample;
            for ef in &mut self.active_effects {
                current_val = ef.process(current_val, self.current_channel, self.sample_rate);
            }

            self.current_channel = (self.current_channel + 1) % self.channels;

            // convert back to whatever sample type the pipeline uses
            Some(current_val)
        } else {
            None
        }
    }
}

impl<I: Source<Item = f32>> Source for DynamicEffectSource<I> {
    fn current_frame_len(&self) -> Option<usize> {
        self.input.current_frame_len()
    }

    fn channels(&self) -> u16 {
        self.input.channels()
    }

    fn sample_rate(&self) -> u32 {
        self.input.sample_rate()
    }

    fn total_duration(&self) -> Option<std::time::Duration> {
        self.input.total_duration()
    }
}
