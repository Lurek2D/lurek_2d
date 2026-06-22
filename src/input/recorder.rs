//! Owns input behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps input data ownership and helper behavior clear for future engine maintenance. with focused crate-local behavior.
//! Defines how recorder data is validated, transformed, or stored before neighboring systems use it.
//! Owns input behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on recorder behavior while Lua registration stays elsewhere.
//! Documents where input callers should change defaults, errors, or lifecycle behavior. with focused crate-local behavior.
//! Use this file when changing recorder defaults, lifecycle handling, validation, or data ownership.

/// A single input event with a kind tag and a key/button name.
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize, PartialEq)]
pub struct InputEvent {
    /// Event category: `"key"`, `"mouse"`, etc.
    pub kind: String,
    /// Key name, button name, or action identifier.
    pub name: String,
}

/// All input events and optional mouse position captured for one recorded frame.
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize, PartialEq)]
pub struct RecordedFrame {
    /// Absolute frame number within the recording.
    pub frame: u64,
    /// Key and button events that occurred during this frame.
    pub key_events: Vec<InputEvent>,
    /// Optional captured mouse X coordinate (only present when the mouse moved).
    pub mouse_x: Option<f64>,
    /// Optional captured mouse Y coordinate (only present when the mouse moved).
    pub mouse_y: Option<f64>,
}

/// Determinism and provenance metadata stored alongside a serialized input recording.
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize, PartialEq, Eq)]
pub struct InputRecordingMetadata {
    /// Engine version that created the recording.
    pub engine_version: String,
    /// Input schema version carried by the recording payload.
    pub input_schema: u32,
    /// Frame-timing mode such as `variable` or `fixed`.
    pub timestep_mode: String,
    /// Optional locale hint captured when the recording started.
    pub locale_hint: Option<String>,
    /// Optional keyboard-layout hint captured when the recording started.
    pub keyboard_layout_hint: Option<String>,
}

/// JSON schema version embedded in the serialisation envelope.
const INPUT_RECORDING_SCHEMA_VERSION: u32 = 2;

impl Default for InputRecordingMetadata {
    fn default() -> Self {
        Self {
            engine_version: env!("CARGO_PKG_VERSION").to_string(),
            input_schema: INPUT_RECORDING_SCHEMA_VERSION,
            timestep_mode: "variable".to_string(),
            locale_hint: None,
            keyboard_layout_hint: None,
        }
    }
}

/// Complete input recording: sparse frame list and total frame count.
#[derive(Debug, Clone, Default, serde::Serialize, serde::Deserialize, PartialEq)]
pub struct InputRecording {
    /// Sparse list of frames that had input activity; frames without events are omitted.
    pub frames: Vec<RecordedFrame>,
    /// Total number of frames captured, including silent frames.
    pub total_frames: u64,
    /// Metadata required to reason about replay determinism and compatibility.
    #[serde(default)]
    pub metadata: InputRecordingMetadata,
}

/// Validation limits enforced when loading recording JSON from an untrusted source.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct InputRecordingLimits {
    /// Maximum total frame count accepted by the parser.
    pub max_frames: u64,
    /// Maximum number of sparse frame entries accepted by the parser.
    pub max_sparse_frames: usize,
    /// Maximum number of events accepted in one frame.
    pub max_events_per_frame: usize,
    /// Maximum allowed character length for an input event name or kind.
    pub max_event_name_len: usize,
    /// Maximum JSON byte size accepted by the parser before deserializing.
    pub max_json_bytes: usize,
    /// Maximum length allowed for metadata strings.
    pub max_metadata_len: usize,
}

impl Default for InputRecordingLimits {
    fn default() -> Self {
        Self {
            max_frames: 100_000,
            max_sparse_frames: 100_000,
            max_events_per_frame: 512,
            max_event_name_len: 128,
            max_json_bytes: 2 * 1024 * 1024,
            max_metadata_len: 128,
        }
    }
}

/// Internal JSON wrapper that adds a version field around the recording data.
#[derive(Debug, serde::Serialize, serde::Deserialize)]
struct RecordingEnvelope {
    /// Schema version; must equal `INPUT_RECORDING_SCHEMA_VERSION` on read.
    version: u32,
    /// Recorded frame data.
    frames: Vec<RecordedFrame>,
    /// Total frames including silent ones.
    total_frames: u64,
    /// Recording metadata carried in schema version 2 and newer.
    #[serde(default)]
    metadata: InputRecordingMetadata,
}

/// Serialisation and deserialisation of input recordings.
impl InputRecording {
    /// Serialise to JSON, wrapping in a versioned envelope; return error string on failure.
    pub fn to_json(&self) -> Result<String, String> {
        let envelope = RecordingEnvelope {
            version: INPUT_RECORDING_SCHEMA_VERSION,
            frames: self.frames.clone(),
            total_frames: self.total_frames,
            metadata: self.metadata.clone(),
        };
        serde_json::to_string(&envelope).map_err(|e| format!("InputRecording serialize error: {e}"))
    }

    /// Deserialise from JSON; returns error when the version field is unsupported.
    pub fn from_json(json: &str) -> Result<Self, String> {
        Self::from_json_with_limits(json, InputRecordingLimits::default())
    }

    /// Deserialise from JSON using explicit validation limits.
    pub fn from_json_with_limits(json: &str, limits: InputRecordingLimits) -> Result<Self, String> {
        if json.len() > limits.max_json_bytes {
            return Err(format!(
                "InputRecording parse error: JSON size {} exceeds limit {}",
                json.len(),
                limits.max_json_bytes
            ));
        }
        if let Ok(envelope) = serde_json::from_str::<RecordingEnvelope>(json) {
            if envelope.version != INPUT_RECORDING_SCHEMA_VERSION {
                return Err(format!(
                    "InputRecording parse error: unsupported version {}",
                    envelope.version
                ));
            }
            return Self {
                frames: envelope.frames,
                total_frames: envelope.total_frames,
                metadata: envelope.metadata,
            }
            .validate(limits);
        }
        let mut recording: Self =
            serde_json::from_str(json).map_err(|e| format!("InputRecording parse error: {e}"))?;
        recording.metadata = InputRecordingMetadata::default();
        recording.validate(limits)
    }

    fn validate(self, limits: InputRecordingLimits) -> Result<Self, String> {
        if self.total_frames > limits.max_frames {
            return Err(format!(
                "InputRecording parse error: total_frames {} exceeds limit {}",
                self.total_frames, limits.max_frames
            ));
        }
        if self.frames.len() > limits.max_sparse_frames {
            return Err(format!(
                "InputRecording parse error: sparse frame count {} exceeds limit {}",
                self.frames.len(),
                limits.max_sparse_frames
            ));
        }
        let mut previous_frame = None;
        for frame in &self.frames {
            if frame.key_events.len() > limits.max_events_per_frame {
                return Err(format!(
                    "InputRecording parse error: frame {} has {} events, limit is {}",
                    frame.frame,
                    frame.key_events.len(),
                    limits.max_events_per_frame
                ));
            }
            if frame.frame >= self.total_frames && self.total_frames > 0 {
                return Err(format!(
                    "InputRecording parse error: frame {} is outside total_frames {}",
                    frame.frame, self.total_frames
                ));
            }
            if let Some(prev) = previous_frame {
                if frame.frame < prev {
                    return Err("InputRecording parse error: frames must be sorted".to_string());
                }
            }
            previous_frame = Some(frame.frame);
            for event in &frame.key_events {
                if event.name.chars().count() > limits.max_event_name_len {
                    return Err(format!(
                        "InputRecording parse error: event name '{}' exceeds limit {}",
                        event.name, limits.max_event_name_len
                    ));
                }
                if event.kind.chars().count() > limits.max_event_name_len {
                    return Err(format!(
                        "InputRecording parse error: event kind '{}' exceeds limit {}",
                        event.kind, limits.max_event_name_len
                    ));
                }
            }
        }
        for value in [&self.metadata.engine_version, &self.metadata.timestep_mode] {
            if value.chars().count() > limits.max_metadata_len {
                return Err(format!(
                    "InputRecording parse error: metadata value '{}' exceeds limit {}",
                    value, limits.max_metadata_len
                ));
            }
        }
        for value in [
            self.metadata.locale_hint.as_deref(),
            self.metadata.keyboard_layout_hint.as_deref(),
        ]
        .into_iter()
        .flatten()
        {
            if value.chars().count() > limits.max_metadata_len {
                return Err(format!(
                    "InputRecording parse error: metadata value '{}' exceeds limit {}",
                    value, limits.max_metadata_len
                ));
            }
        }
        Ok(self)
    }
}

/// Input data replayed for one frame, including sparse mouse coordinates.
#[derive(Debug, Clone, Default, PartialEq)]
pub struct PlaybackFrame {
    /// Events emitted on this frame.
    pub key_events: Vec<InputEvent>,
    /// Replayed mouse X coordinate when captured.
    pub mouse_x: Option<f64>,
    /// Replayed mouse Y coordinate when captured.
    pub mouse_y: Option<f64>,
}

/// Stateful recorder and playback cursor for one input recording session.
#[derive(Debug, Default)]
pub struct InputRecorder {
    /// Recording buffer being written to; `None` when not recording.
    current: Option<InputRecording>,
    /// Recording loaded for playback; `None` when no recording is loaded.
    playback: Option<InputRecording>,
    /// Index into `playback.frames` for the current playback position.
    playback_idx: usize,
    /// Current frame counter, used for both recording and playback.
    frame: u64,
    /// True when an active recording is in progress.
    recording: bool,
    /// True when playback is in progress.
    playing: bool,
}

/// Recording and playback lifecycle methods.
impl InputRecorder {
    /// Create a new recorder with no active recording or playback.
    pub fn new() -> Self {
        Self::default()
    }

    /// Begin a new recording; clears any previous in-progress recording.
    pub fn start_recording(&mut self) {
        self.current = Some(InputRecording::default());
        self.frame = 0;
        self.recording = true;
        self.playing = false;
    }

    /// Append events for the current frame to the active recording; advances the frame counter.
    pub fn record_frame(
        &mut self,
        key_events: Vec<InputEvent>,
        mouse_x: Option<f64>,
        mouse_y: Option<f64>,
    ) {
        if let Some(rec) = &mut self.current {
            if !key_events.is_empty() || mouse_x.is_some() || mouse_y.is_some() {
                rec.frames.push(RecordedFrame {
                    frame: self.frame,
                    key_events,
                    mouse_x,
                    mouse_y,
                });
            }
        }
        self.frame += 1;
    }

    /// Stop recording and return the completed `InputRecording`, or `None` when nothing was recorded.
    pub fn stop_recording(&mut self) -> Option<InputRecording> {
        self.recording = false;
        if let Some(mut rec) = self.current.take() {
            rec.total_frames = self.frame;
            Some(rec)
        } else {
            None
        }
    }

    /// Return true when a recording is currently in progress.
    pub fn is_recording(&self) -> bool {
        self.recording
    }

    /// Load `recording` as the active playback source; resets the playback cursor.
    pub fn load(&mut self, recording: InputRecording) {
        self.playback = Some(recording);
        self.playback_idx = 0;
    }

    /// Start playing back the loaded recording from the beginning; no-op when no recording is loaded.
    pub fn start_playback(&mut self) {
        if self.playback.is_some() {
            self.playing = true;
            self.playback_idx = 0;
            self.frame = 0;
            self.recording = false;
        }
    }

    /// Stop playback immediately. This function is part of the public API.
    pub fn stop_playback(&mut self) {
        self.playing = false;
    }

    /// Return true when playback is currently in progress.
    pub fn is_playing_back(&self) -> bool {
        self.playing
    }

    /// Return the current frame index within the active playback.
    pub fn playback_frame_index(&self) -> u64 {
        self.frame
    }

    /// Return all replay data for the current playback frame and advance; stops playback at the end.
    pub fn playback_frame(&mut self) -> PlaybackFrame {
        if !self.playing {
            return PlaybackFrame::default();
        }
        let mut frame = PlaybackFrame::default();
        if let Some(rec) = &self.playback {
            while self.playback_idx < rec.frames.len()
                && rec.frames[self.playback_idx].frame == self.frame
            {
                let source = &rec.frames[self.playback_idx];
                frame.key_events.extend(source.key_events.clone());
                if source.mouse_x.is_some() {
                    frame.mouse_x = source.mouse_x;
                }
                if source.mouse_y.is_some() {
                    frame.mouse_y = source.mouse_y;
                }
                self.playback_idx += 1;
            }
            if self.frame + 1 >= rec.total_frames {
                self.playing = false;
            }
        }
        self.frame += 1;
        frame
    }
}
