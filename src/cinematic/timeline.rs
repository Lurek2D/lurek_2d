//! `src/cinematic/timeline.rs` owns the multi-track cinematic timeline used for timed clips, playback state, and branching.
//! It defines `CinematicClip`, `ClipType`, `Track`, `TimelineState`, and `CinematicTimeline` under one playback owner.
//! Track creation, clip insertion, duration recalculation, play or pause control, seeking, and completion checks live here.
//! Label storage and branch jumps also live here, keeping authored timeline flow control next to the state it manipulates.
//! Active-clip queries also live here, so runtime systems can inspect which camera, audio, tween, or signal apply.
//! Read this file when timeline scheduling, clip categories, branching semantics, or playback-state behavior changes.

use std::collections::HashMap;

/// A single clip on a track.
#[derive(Debug, Clone)]
pub struct CinematicClip {
    /// Time in seconds when this clip starts.
    pub at: f32,
    /// Duration in seconds for this clip.
    pub duration: f32,
    /// Clip type: determines interpretation of data.
    pub clip_type: ClipType,
}

/// Describes the payload and behavior of a clip.
#[derive(Debug, Clone)]
pub enum ClipType {
    /// Animate a Lua object's properties with tween.
    Tween {
        target: String, // Lua object reference key
        properties: HashMap<String, f32>,
        easing: Option<String>, // easing function name
    },
    /// Move and zoom a camera.
    Camera {
        x: f32,
        y: f32,
        zoom: f32,
        easing: Option<String>,
    },
    /// Play audio from a file.
    Audio { path: String },
    /// Fire a named signal event.
    Signal { name: String, data: Option<String> },
}

impl CinematicClip {
    /// Returns the end time of this clip (at + duration).
    pub fn end_time(&self) -> f32 {
        self.at + self.duration
    }
}

/// Represents a single track (audio, camera, tween, signal).
#[derive(Debug, Clone)]
pub struct Track {
    /// Display name for this track.
    pub name: String,
    /// Clips on this track, sorted by start time.
    pub clips: Vec<CinematicClip>,
}

impl Track {
    /// Creates an empty track with the given display name.
    pub fn new(name: String) -> Self {
        Self {
            name,
            clips: Vec::new(),
        }
    }

    /// Adds a clip to this track and maintains time order.
    pub fn add_clip(&mut self, clip: CinematicClip) {
        self.clips.push(clip);
        self.clips
            .sort_by(|a, b| a.at.partial_cmp(&b.at).unwrap_or(std::cmp::Ordering::Equal));
    }

    /// Finds clips active at the given time.
    pub fn clips_at(&self, time: f32) -> Vec<&CinematicClip> {
        self.clips
            .iter()
            .filter(|c| time >= c.at && time < c.end_time())
            .collect()
    }
}

/// Playback states for the timeline.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TimelineState {
    Stopped,
    Playing,
    Paused,
}

impl TimelineState {
    /// Returns the Lua-facing string representation of this playback state.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Stopped => "stopped",
            Self::Playing => "playing",
            Self::Paused => "paused",
        }
    }
}

/// A cinematic timeline: collection of tracks with timing and playback control.
#[derive(Debug)]
pub struct CinematicTimeline {
    tracks: Vec<Track>,
    current_time: f32,
    state: TimelineState,
    duration: f32,                // max end time across all tracks
    labels: HashMap<String, f32>, // named time positions for branching
    on_complete_fired: bool,
}

impl CinematicTimeline {
    /// Creates an empty timeline.
    pub fn new() -> Self {
        Self {
            tracks: Vec::new(),
            current_time: 0.0,
            state: TimelineState::Stopped,
            duration: 0.0,
            labels: HashMap::new(),
            on_complete_fired: false,
        }
    }

    /// Adds a new track to this timeline.
    pub fn add_track(&mut self, name: String) -> &mut Track {
        let track = Track::new(name);
        self.tracks.push(track);
        self.recalc_duration();
        self.tracks.last_mut().unwrap()
    }

    /// Adds a clip to a named track (creates track if missing).
    pub fn add_clip_to_track(&mut self, track_name: &str, clip: CinematicClip) {
        // Find or create track
        if !self.tracks.iter().any(|t| t.name == track_name) {
            self.add_track(track_name.to_string());
        }

        if let Some(track) = self.tracks.iter_mut().find(|t| t.name == track_name) {
            track.add_clip(clip);
            self.recalc_duration();
        }
    }

    /// Recalculates the total timeline duration (max end time of all clips).
    fn recalc_duration(&mut self) {
        let mut max_end: f32 = 0.0;
        for track in &self.tracks {
            for clip in &track.clips {
                max_end = max_end.max(clip.end_time());
            }
        }
        self.duration = max_end;
    }

    /// Starts playback from the current time.
    pub fn play(&mut self) {
        self.state = TimelineState::Playing;
        self.on_complete_fired = false;
    }

    /// Pauses playback without changing current time.
    pub fn pause(&mut self) {
        self.state = TimelineState::Paused;
    }

    /// Stops playback and resets to time 0.
    pub fn stop(&mut self) {
        self.state = TimelineState::Stopped;
        self.current_time = 0.0;
        self.on_complete_fired = false;
    }

    /// Jumps to a specific time.
    pub fn seek(&mut self, time: f32) {
        self.current_time = time.max(0.0).min(self.duration);
        self.on_complete_fired = false;
    }

    /// Advances time by dt (only if playing).
    pub fn update(&mut self, dt: f32) {
        if self.state == TimelineState::Playing {
            self.current_time += dt;
            if self.current_time >= self.duration {
                self.current_time = self.duration;
                self.on_complete_fired = true;
            }
        }
    }

    /// Instantly jumps to the end of the timeline.
    pub fn skip_to_end(&mut self) {
        self.current_time = self.duration;
        self.on_complete_fired = true;
    }

    /// Returns the current playback time.
    pub fn get_time(&self) -> f32 {
        self.current_time
    }

    /// Returns the total duration of the timeline.
    pub fn get_duration(&self) -> f32 {
        self.duration
    }

    /// Returns the current playback state.
    pub fn get_state(&self) -> TimelineState {
        self.state
    }

    /// Returns the state as a string for Lua.
    pub fn get_state_str(&self) -> &'static str {
        self.state.as_str()
    }

    /// Checks if currently playing.
    pub fn is_playing(&self) -> bool {
        self.state == TimelineState::Playing
    }

    /// Checks if playback has finished (reached end time).
    pub fn is_complete(&self) -> bool {
        self.current_time >= self.duration
    }

    /// Checks if onComplete callback should fire.
    pub fn should_fire_complete(&self) -> bool {
        self.on_complete_fired && !self.is_playing()
    }

    /// Registers a labeled time position for branching.
    pub fn add_label(&mut self, name: String, time: f32) {
        self.labels.insert(name, time);
    }

    /// Branches (seeks) to a named label.
    pub fn branch(&mut self, label: &str) -> bool {
        if let Some(&time) = self.labels.get(label) {
            self.seek(time);
            true
        } else {
            false
        }
    }

    /// Gets all tracks (for inspection).
    pub fn tracks(&self) -> &[Track] {
        &self.tracks
    }

    /// Gets all clips from a named track, or empty if not found.
    pub fn clips_from_track(&self, track_name: &str) -> Vec<&CinematicClip> {
        self.tracks
            .iter()
            .find(|t| t.name == track_name)
            .map(|t| t.clips.iter().collect())
            .unwrap_or_default()
    }

    /// Gets all clips active at the current time.
    pub fn clips_at_current(&self) -> Vec<(&str, &CinematicClip)> {
        let mut result = Vec::new();
        for track in &self.tracks {
            for clip in track.clips_at(self.current_time) {
                result.push((track.name.as_str(), clip));
            }
        }
        result
    }
}

impl Default for CinematicTimeline {
    fn default() -> Self {
        Self::new()
    }
}
