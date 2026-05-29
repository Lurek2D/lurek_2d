//! Musical beat clock — tempo and measure tracking for rhythm games and procedural audio.
//!
//! - `BeatClock` converts wall-clock time into beats, bars, and pulse events.
//! - Supports BPM change, time-signature change, tap-tempo, and quantised scheduling.
//! - No audio playback — pure timing. Wire it to audio callbacks in Lua.

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
    /// True when the clock is running.
    running: bool,
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
        Self {
            bpm: bpm.max(1.0),
            beats_per_bar: beats_per_bar.max(1),
            elapsed_secs: 0.0,
            running: false,
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
        self.fired.clear();
    }

    /// True when the clock is running.
    pub fn is_running(&self) -> bool {
        self.running
    }

    /// Advance the clock by `dt` seconds. Returns a list of whole-beat crossings
    /// (as beat numbers) that occurred during this step.
    pub fn tick(&mut self, dt: f64) -> Vec<f64> {
        if !self.running {
            return Vec::new();
        }
        let before = self.beat_total();
        self.elapsed_secs += dt;
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

    /// Returns the current musical position.
    pub fn position(&self) -> BeatPosition {
        let beat = self.beat_total();
        let bar = (beat / self.beats_per_bar as f64).floor() as u64;
        let beat_in_bar = (beat.floor() as u64 % self.beats_per_bar as u64) as u32;
        let phase = beat - beat.floor();
        BeatPosition { beat, bar, beat_in_bar, phase }
    }

    /// Return total beats elapsed (fractional).
    pub fn beat_total(&self) -> f64 {
        self.elapsed_secs * self.bpm / 60.0
    }

    /// Return current BPM.
    pub fn bpm(&self) -> f64 {
        self.bpm
    }

    /// Set a new BPM. Elapsed time is preserved; only future ticks change rate.
    pub fn set_bpm(&mut self, bpm: f64) {
        self.bpm = bpm.max(1.0);
    }

    /// Return beats per bar.
    pub fn beats_per_bar(&self) -> u32 {
        self.beats_per_bar
    }

    /// Change the time signature beats-per-bar.
    pub fn set_beats_per_bar(&mut self, beats: u32) {
        self.beats_per_bar = beats.max(1);
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
        self.bpm
    }

    /// Schedule a one-shot beat callback at `beat`. Returns `true` when the beat
    /// is in the future relative to the current position.
    pub fn schedule_at(&mut self, beat: f64) -> bool {
        if beat <= self.beat_total() {
            return false;
        }
        if let Err(pos) = self.scheduled.binary_search_by(|b| b.partial_cmp(&beat).unwrap()) {
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
        let beat = self.beat_total();
        let next = beat.floor() + 1.0;
        (next - beat) * self.seconds_per_beat()
    }

    /// Quantise `beat` to the nearest `grid` beat grid (e.g. 0.25 for 16th notes).
    pub fn quantise(beat: f64, grid: f64) -> f64 {
        if grid <= 0.0 { return beat; }
        (beat / grid).round() * grid
    }
}
