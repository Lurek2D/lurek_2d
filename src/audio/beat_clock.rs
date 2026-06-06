//! Implements musical time tracking that maps wall-clock progression to beats, bars, and pulses.
//! Supports tempo and meter changes while preserving coherent phase continuity over runtime updates.
//! Provides tap-tempo and quantized scheduling utilities for rhythm-aware gameplay coordination.
//! Applies latency and swing parameters to shape musical timing feel without audio-thread coupling.
//! Exposes deterministic query surfaces for beat index, measure position, and subdivision boundaries.
//! Keeps timing logic pure and playback-agnostic so multiple systems can consume one clock source.
//! Serves rhythm, sequencing, and procedural trigger systems that require stable musical time.
//! Functions as the temporal backbone for Lua callbacks aligned to musical structure.

/// Runtime options used when creating a beat clock.
#[derive(Clone, Copy, Debug)]
pub struct BeatClockOpts {
    /// Default subdivision used by division-optional query helpers.
    pub subdivision: u32,
    /// Swing amount in range [0, 0.5].
    pub swing: f64,
    /// Timing latency compensation in seconds.
    pub latency: f64,
}

impl Default for BeatClockOpts {
    fn default() -> Self {
        Self {
            subdivision: 4,
            swing: 0.0,
            latency: 0.0,
        }
    }
}

/// Timing windows used by rhythm judgement logic.
#[derive(Clone, Copy, Debug)]
pub struct JudgementWindows {
    /// Absolute error threshold in seconds for a perfect hit.
    pub perfect: f64,
    /// Absolute error threshold in seconds for a great hit.
    pub great: f64,
    /// Absolute error threshold in seconds for a good hit.
    pub good: f64,
}

impl Default for JudgementWindows {
    fn default() -> Self {
        Self {
            perfect: 0.030,
            great: 0.060,
            good: 0.100,
        }
    }
}

/// Rhythm judgement result with signed hit error in seconds.
#[derive(Clone, Copy, Debug)]
pub enum JudgementResult {
    /// Within `perfect` window.
    Perfect(f64),
    /// Within `great` window.
    Great(f64),
    /// Within `good` window.
    Good(f64),
    /// Outside `good` window.
    Miss(f64),
}

/// Beat/bar transition events emitted by [`BeatClock::update`].
#[derive(Clone, Copy, Debug, Default)]
pub struct BeatClockEvents {
    /// Last whole beat crossed during the update, if any.
    pub new_beat: Option<u32>,
    /// Last bar index crossed during the update, if any.
    pub new_bar: Option<u32>,
}

/// Represents the current musical position in a performance.
#[derive(Clone, Debug, Default)]
pub struct BeatPosition {
    /// Total beats elapsed since clock start (or last reset).
    pub beat: f64,
    /// Which bar (measure) the current beat falls in (0-based).
    pub bar: u64,
    /// Which beat within the current bar (0-based).
    pub beat_in_bar: u32,
    /// Fractional progress within the current beat (0.0 – 1.0).
    pub phase: f64,
}

/// Musical beat clock — tempo and measure tracking.
pub struct BeatClock {
    /// Beats-per-minute.
    bpm: f64,
    /// Number of beats per bar (numerator of time signature).
    beats_per_bar: u32,
    /// Total elapsed wall-clock time in seconds since the clock was last started.
    elapsed_secs: f64,
    /// Total elapsed musical beat position.
    beat_position: f64,
    /// True when the clock is running.
    running: bool,
    /// Ramp target BPM when ramping is active.
    target_bpm: Option<f64>,
    /// BPM at the start of the current ramp.
    start_bpm: f64,
    /// Ramp progress in seconds.
    ramp_t: f64,
    /// Ramp duration in seconds.
    ramp_dur: f64,
    /// Default query subdivision.
    subdivision: u32,
    /// Swing amount in [0, 0.5].
    swing: f64,
    /// Latency compensation in seconds.
    latency: f64,
    /// Local judgement windows.
    judgement_windows: JudgementWindows,
    /// BPM samples collected for tap-tempo calculation.
    tap_times: Vec<f64>,
    /// Scheduled one-shot callback times (beats), sorted ascending.
    scheduled: Vec<f64>,
    /// Fired beat thresholds — used to prevent double-fires.
    fired: Vec<f64>,
}

impl BeatClock {
    /// Create a new beat clock at `bpm` BPM with a `beats_per_bar` time signature.
    pub fn new(bpm: f64, beats_per_bar: u32) -> Self {
        Self::new_with_opts(bpm, beats_per_bar, BeatClockOpts::default())
    }

    /// Create a new beat clock with explicit options.
    pub fn new_with_opts(bpm: f64, beats_per_bar: u32, opts: BeatClockOpts) -> Self {
        Self {
            bpm: bpm.max(1.0),
            beats_per_bar: beats_per_bar.max(1),
            elapsed_secs: 0.0,
            beat_position: 0.0,
            running: false,
            target_bpm: None,
            start_bpm: bpm.max(1.0),
            ramp_t: 0.0,
            ramp_dur: 0.0,
            subdivision: opts.subdivision.max(1),
            swing: opts.swing.clamp(0.0, 0.5),
            latency: opts.latency.max(0.0),
            judgement_windows: JudgementWindows::default(),
            tap_times: Vec::new(),
            scheduled: Vec::new(),
            fired: Vec::new(),
        }
    }

    /// Start the clock. Has no effect when already running.
    pub fn start(&mut self) {
        self.running = true;
    }

    /// Pause the clock. Has no effect when already stopped.
    pub fn stop(&mut self) {
        self.running = false;
    }

    /// Reset elapsed time to zero. Does not change running state.
    pub fn reset(&mut self) {
        self.elapsed_secs = 0.0;
        self.beat_position = 0.0;
        self.fired.clear();
    }

    /// True when the clock is running.
    pub fn is_running(&self) -> bool {
        self.running
    }

    /// Advance the clock by `dt` seconds. Returns a list of whole-beat crossings
    /// (as beat numbers) that occurred during this step.
    pub fn tick(&mut self, dt: f64) -> Vec<f64> {
        if !self.running || dt <= 0.0 {
            return Vec::new();
        }
        let before = self.beat_total();
        let ramp_active_before = self.target_bpm.is_some();
        let bpm_before = self.bpm;
        self.advance_ramp(dt);
        let bpm_for_step = if ramp_active_before {
            (bpm_before + self.bpm) * 0.5
        } else {
            self.bpm
        };
        self.elapsed_secs += dt;
        self.beat_position += dt * bpm_for_step / 60.0;
        let after = self.beat_total();

        // Collect whole beats that were crossed
        let start = before.floor() + 1.0;
        let mut crossings = Vec::new();
        let mut b = start;
        while b <= after {
            crossings.push(b);
            b += 1.0;
        }
        crossings
    }

    /// Advance the clock and emit beat/bar transition events.
    pub fn update(&mut self, dt: f64) -> BeatClockEvents {
        let before_bar = self.get_bar().floor() as u32;
        let crossings = self.tick(dt);
        let mut events = BeatClockEvents::default();
        if let Some(beat) = crossings.last() {
            events.new_beat = Some(*beat as u32);
        }
        let after_bar = self.get_bar().floor() as u32;
        if after_bar > before_bar {
            events.new_bar = Some(after_bar);
        }
        events
    }

    /// Returns the current musical position.
    pub fn position(&self) -> BeatPosition {
        let beat = self.beat_total();
        let bar = (beat / self.beats_per_bar as f64).floor() as u64;
        let beat_in_bar = (beat.floor() as u64 % self.beats_per_bar as u64) as u32;
        let phase = beat - beat.floor();
        BeatPosition {
            beat,
            bar,
            beat_in_bar,
            phase,
        }
    }

    /// Return total beats elapsed (fractional).
    pub fn beat_total(&self) -> f64 {
        self.beat_position
    }

    /// Return total beats elapsed (fractional). Alias of [`Self::beat_total`].
    pub fn get_beat(&self) -> f64 {
        self.beat_total()
    }

    /// Return total bars elapsed (fractional).
    pub fn get_bar(&self) -> f64 {
        self.get_beat() / self.beats_per_bar as f64
    }

    /// Return the current phase in [0, 1) for a division of the beat.
    pub fn get_phase(&self, division: u32) -> f64 {
        let div = division.max(1);
        let scaled = self.effective_beat() * div as f64;
        let phase = scaled - scaled.floor();
        if phase < 0.0 {
            phase + 1.0
        } else {
            phase
        }
    }

    /// Return whether the clock is on a division grid within `tolerance` seconds.
    pub fn is_on_beat(&self, division: u32, tolerance: f64) -> bool {
        let (_, err_seconds) = self.nearest_beat(division);
        err_seconds.abs() <= tolerance.max(0.0)
    }

    /// Return nearest grid beat and signed timing error in seconds.
    pub fn nearest_beat(&self, division: u32) -> (f64, f64) {
        let div = division.max(1) as f64;
        let current = self.effective_beat();
        let nearest = (current * div).round() / div;
        let err_beats = current - nearest;
        let err_seconds = err_beats * self.seconds_per_beat();
        (nearest, err_seconds)
    }

    /// Return seconds until the next division boundary.
    pub fn beat_time_remaining(&self, division: u32) -> f64 {
        let div = division.max(1) as f64;
        let current = self.effective_beat() * div;
        let next = current.floor() + 1.0;
        (next - current) * (self.seconds_per_beat() / div)
    }

    /// Judge a hit against the nearest beat at `division` with additional `hit_offset` seconds.
    pub fn judge(&self, division: u32, hit_offset: f64) -> JudgementResult {
        let (_, err_seconds) = self.nearest_beat(division);
        let total = err_seconds + hit_offset;
        let abs = total.abs();
        if abs <= self.judgement_windows.perfect {
            JudgementResult::Perfect(total)
        } else if abs <= self.judgement_windows.great {
            JudgementResult::Great(total)
        } else if abs <= self.judgement_windows.good {
            JudgementResult::Good(total)
        } else {
            JudgementResult::Miss(total)
        }
    }

    /// Return current BPM.
    pub fn bpm(&self) -> f64 {
        self.bpm
    }

    /// Set a new BPM. Elapsed time is preserved; only future ticks change rate.
    pub fn set_bpm(&mut self, bpm: f64) {
        self.bpm = bpm.max(1.0);
        self.start_bpm = self.bpm;
        self.target_bpm = None;
        self.ramp_t = 0.0;
        self.ramp_dur = 0.0;
    }

    /// Ramp BPM linearly to `target` over `seconds`.
    pub fn ramp_bpm(&mut self, target: f64, seconds: f64) {
        let target = target.max(1.0);
        if seconds <= 0.0 {
            self.set_bpm(target);
            return;
        }
        self.start_bpm = self.bpm;
        self.target_bpm = Some(target);
        self.ramp_t = 0.0;
        self.ramp_dur = seconds;
    }

    /// Return beats per bar.
    pub fn beats_per_bar(&self) -> u32 {
        self.beats_per_bar
    }

    /// Change the time signature beats-per-bar.
    pub fn set_beats_per_bar(&mut self, beats: u32) {
        self.beats_per_bar = beats.max(1);
    }

    /// Set default beat subdivision used by division-optional calls.
    pub fn set_subdivision(&mut self, subdivision: u32) {
        self.subdivision = subdivision.max(1);
    }

    /// Return default beat subdivision.
    pub fn subdivision(&self) -> u32 {
        self.subdivision
    }

    /// Set swing amount in [0, 0.5].
    pub fn set_swing(&mut self, amount: f64) {
        self.swing = amount.clamp(0.0, 0.5);
    }

    /// Return swing amount in [0, 0.5].
    pub fn swing(&self) -> f64 {
        self.swing
    }

    /// Set latency compensation in seconds.
    pub fn set_latency(&mut self, latency_secs: f64) {
        self.latency = latency_secs.max(0.0);
    }

    /// Return latency compensation in seconds.
    pub fn latency(&self) -> f64 {
        self.latency
    }

    /// Replace judgement windows.
    pub fn set_judgement_windows(&mut self, windows: JudgementWindows) {
        self.judgement_windows = windows;
    }

    /// Return current judgement windows.
    pub fn judgement_windows(&self) -> JudgementWindows {
        self.judgement_windows
    }

    /// Sync clock to an external audio position in seconds.
    pub fn sync_to_position(&mut self, audio_pos: f64) {
        let compensated = (audio_pos - self.latency).max(0.0);
        self.elapsed_secs = compensated;
        self.beat_position = compensated * self.bpm / 60.0;
    }

    /// Record a tap for tap-tempo estimation. After at least 2 taps the estimated BPM
    /// is applied immediately. Returns the new BPM, or 0.0 when not enough taps yet.
    pub fn tap(&mut self, wall_time_secs: f64) -> f64 {
        self.tap_times.push(wall_time_secs);
        // Keep only the last 8 taps
        if self.tap_times.len() > 8 {
            self.tap_times.remove(0);
        }
        if self.tap_times.len() < 2 {
            return 0.0;
        }
        let n = self.tap_times.len();
        let interval = (self.tap_times[n - 1] - self.tap_times[0]) / (n - 1) as f64;
        let new_bpm = 60.0 / interval.max(f64::EPSILON);
        self.bpm = new_bpm.clamp(20.0, 400.0);
        self.start_bpm = self.bpm;
        self.target_bpm = None;
        self.ramp_t = 0.0;
        self.ramp_dur = 0.0;
        self.bpm
    }

    /// Schedule a one-shot beat callback at `beat`. Returns `true` when the beat
    /// is in the future relative to the current position.
    pub fn schedule_at(&mut self, beat: f64) -> bool {
        if beat <= self.beat_total() {
            return false;
        }
        if let Err(pos) = self
            .scheduled
            .binary_search_by(|b| b.partial_cmp(&beat).unwrap())
        {
            self.scheduled.insert(pos, beat);
        }
        true
    }

    /// Drain all scheduled beats that are now in the past. Call after `tick`.
    pub fn drain_fired(&mut self) -> Vec<f64> {
        let now = self.beat_total();
        let (fired, remaining): (Vec<f64>, Vec<f64>) =
            self.scheduled.drain(..).partition(|&b| b <= now);
        self.scheduled = remaining;
        fired
    }

    /// Return seconds-per-beat at the current BPM.
    pub fn seconds_per_beat(&self) -> f64 {
        60.0 / self.bpm
    }

    /// Return seconds until the next whole beat boundary.
    pub fn seconds_to_next_beat(&self) -> f64 {
        let beat = self.effective_beat();
        let next = beat.floor() + 1.0;
        (next - beat) * self.seconds_per_beat()
    }

    /// Quantise `beat` to the nearest `grid` beat grid (e.g. 0.25 for 16th notes).
    pub fn quantise(beat: f64, grid: f64) -> f64 {
        if grid <= 0.0 {
            return beat;
        }
        (beat / grid).round() * grid
    }

    /// Return 1-based step indices crossed in `(before, after]` for a beat division.
    pub fn crossed_steps(before: f64, after: f64, division: u32) -> Vec<i64> {
        if after <= before {
            return Vec::new();
        }
        let div = division.max(1) as f64;
        let start = (before * div).floor() as i64 + 1;
        let end = (after * div).floor() as i64;
        if end < start {
            return Vec::new();
        }
        (start..=end).collect()
    }

    fn advance_ramp(&mut self, dt: f64) {
        let Some(target) = self.target_bpm else {
            return;
        };
        if self.ramp_dur <= 0.0 {
            self.bpm = target;
            self.start_bpm = target;
            self.target_bpm = None;
            self.ramp_t = 0.0;
            self.ramp_dur = 0.0;
            return;
        }
        self.ramp_t = (self.ramp_t + dt).min(self.ramp_dur);
        let t = (self.ramp_t / self.ramp_dur).clamp(0.0, 1.0);
        self.bpm = self.start_bpm + (target - self.start_bpm) * t;
        if self.ramp_t >= self.ramp_dur {
            self.bpm = target;
            self.start_bpm = target;
            self.target_bpm = None;
            self.ramp_t = 0.0;
            self.ramp_dur = 0.0;
        }
    }

    fn effective_beat(&self) -> f64 {
        self.beat_total() + self.latency * self.bpm / 60.0
    }
}
