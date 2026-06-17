//! Legacy cut-based cinematic timeline. `cinematic/cinematic_legacy` delivers the cinematic legacy implementation for the cinematic subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Provides backward compatibility for the simple cut-based API. The file owns or coordinates data contracts including `Cut`, `Cinematic`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! New code should use CinematicTimeline from timeline.rs instead. Public callable behavior is centered on no named public items, while method-level behavior such as `new`, `add_cut`, `cuts`, `play`, `clear` stays attached to the local data model and invariants.

/// A single timed event in a cinematic timeline.
#[derive(Debug, Clone)]
pub struct Cut {
    /// Time in seconds when this cut fires.
    pub time: f32,
    /// Human-readable description of the cut.
    pub description: String,
}

/// A sequence of timed events (cuts) that form a cinematic timeline.
///
/// This is the legacy API; new code should use CinematicTimeline for multi-track support.
#[derive(Debug, Default, Clone)]
pub struct Cinematic {
    /// Ordered list of cuts sorted by time.
    cuts: Vec<Cut>,
}

impl Cinematic {
    /// Creates an empty cinematic timeline.
    pub fn new() -> Self {
        Self::default()
    }

    /// Appends a cut at `time` seconds with the given `description`.
    /// Cuts are kept in insertion order; sort manually if needed.
    pub fn add_cut(&mut self, time: f32, description: String) {
        self.cuts.push(Cut { time, description });
    }

    /// Returns a slice of all cuts in this timeline.
    pub fn cuts(&self) -> &[Cut] {
        &self.cuts
    }

    /// Plays back the timeline by printing each cut to stdout.
    /// In a real engine this would schedule engine events on a frame timeline.
    pub fn play(&self) {
        for cut in &self.cuts {
            log::info!("[Cinematic] at {:.2}s: {}", cut.time, cut.description);
        }
    }

    /// Clears all cuts from the timeline.
    pub fn clear(&mut self) {
        self.cuts.clear();
    }
}
