//! Stateful sprite-clip animator used by the Lua-facing `lurek.sprite` API.
//!
//! This module owns playback state transitions and frame stepping rules. Lua
//! bindings should stay thin and delegate update logic to this type.

use std::collections::HashMap;

/// One named animation clip definition used by [`SpriteAnimator`].
#[derive(Clone, Debug)]
pub struct SpriteClip {
    /// Sprite-sheet row index used for this clip.
    pub row: u32,
    /// First frame index (1-based, inclusive).
    pub from: u32,
    /// Last frame index (1-based, inclusive).
    pub to: u32,
    /// Clip playback speed in frames per second.
    pub fps: f32,
    /// Whether the clip loops when it reaches `to`.
    pub looping: bool,
}

impl Default for SpriteClip {
    fn default() -> Self {
        Self {
            row: 1,
            from: 1,
            to: 1,
            fps: 8.0,
            looping: true,
        }
    }
}

impl SpriteClip {
    /// Normalize invalid fields to safe defaults.
    pub fn normalized(mut self) -> Self {
        if self.from == 0 {
            self.from = 1;
        }
        if self.to < self.from {
            self.to = self.from;
        }
        if self.fps <= 0.0 {
            self.fps = 8.0;
        }
        self
    }
}

/// Playback events emitted while advancing an animator.
#[derive(Clone, Debug, PartialEq)]
pub enum AnimatorEvent {
    /// Fired when playback advances to a new frame.
    Frame { row: u32, col: u32, clip: String },
    /// Fired when a looping clip wraps from end to start.
    Loop { clip: String },
    /// Fired when a non-looping clip reaches its end and stops.
    End { clip: String },
}

/// Stateful clip animator with named clips and frame stepping.
#[derive(Clone, Debug, Default)]
pub struct SpriteAnimator {
    clips: HashMap<String, SpriteClip>,
    current_clip: Option<String>,
    current_def: Option<SpriteClip>,
    frame: u32,
    elapsed: f32,
    playing: bool,
}

impl SpriteAnimator {
    /// Create a new animator with an optional map of named clips.
    pub fn new(clips: HashMap<String, SpriteClip>) -> Self {
        let normalized = clips
            .into_iter()
            .map(|(name, def)| (name, def.normalized()))
            .collect();
        Self {
            clips: normalized,
            current_clip: None,
            current_def: None,
            frame: 1,
            elapsed: 0.0,
            playing: false,
        }
    }

    /// Add or replace a clip definition.
    pub fn add_clip(&mut self, name: String, def: SpriteClip) {
        self.clips.insert(name, def.normalized());
    }

    /// Start or restart playback for the named clip.
    pub fn play(&mut self, name: &str, restart: bool) {
        let Some(def) = self.clips.get(name).cloned() else {
            return;
        };
        if self.current_clip.as_deref() == Some(name) && !restart && self.playing {
            return;
        }
        self.current_clip = Some(name.to_string());
        self.current_def = Some(def.clone());
        self.frame = def.from;
        self.elapsed = 0.0;
        self.playing = true;
    }

    /// Pause playback without changing frame state.
    pub fn pause(&mut self) {
        self.playing = false;
    }

    /// Resume playback from the current frame if a clip is selected.
    pub fn resume(&mut self) {
        if self.current_def.is_some() {
            self.playing = true;
        }
    }

    /// Stop playback and reset to the clip's first frame.
    pub fn stop(&mut self) {
        self.playing = false;
        if let Some(def) = &self.current_def {
            self.frame = def.from;
        }
        self.elapsed = 0.0;
    }

    /// Return whether playback is currently running.
    pub fn is_playing(&self) -> bool {
        self.playing
    }

    /// Return the currently selected clip name, if any.
    pub fn current_clip(&self) -> Option<&str> {
        self.current_clip.as_deref()
    }

    /// Return current row and frame index for drawing.
    pub fn current_frame(&self) -> (u32, u32) {
        let Some(def) = &self.current_def else {
            return (1, 1);
        };
        (def.row, self.frame)
    }

    /// Return frame time in seconds for the current clip.
    pub fn frame_duration(&self) -> f32 {
        let Some(def) = &self.current_def else {
            return 0.125;
        };
        1.0 / def.fps
    }

    /// Return full clip duration in seconds for the current clip.
    pub fn clip_duration(&self) -> f32 {
        let Some(def) = &self.current_def else {
            return 0.0;
        };
        let frame_count = (def.to - def.from + 1) as f32;
        frame_count / def.fps
    }

    /// Advance playback by `dt` and emit any frame/loop/end events.
    pub fn update(&mut self, dt: f32) -> Vec<AnimatorEvent> {
        if !self.playing {
            return Vec::new();
        }
        let Some(def) = self.current_def.clone() else {
            return Vec::new();
        };
        let Some(clip_name) = self.current_clip.clone() else {
            return Vec::new();
        };

        self.elapsed += dt.max(0.0);
        let frame_time = 1.0 / def.fps;
        let mut events = Vec::new();

        while self.elapsed >= frame_time {
            self.elapsed -= frame_time;
            self.frame += 1;

            if self.frame > def.to {
                if def.looping {
                    self.frame = def.from;
                    events.push(AnimatorEvent::Loop {
                        clip: clip_name.clone(),
                    });
                } else {
                    self.frame = def.to;
                    self.playing = false;
                    events.push(AnimatorEvent::End {
                        clip: clip_name.clone(),
                    });
                    break;
                }
            }

            let (row, col) = self.current_frame();
            events.push(AnimatorEvent::Frame {
                row,
                col,
                clip: clip_name.clone(),
            });
        }

        events
    }
}
