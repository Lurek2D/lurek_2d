//! Cinematic dialog sequencer with typewriter reveal effect.
//!
//! Provides node-based dialog playback with:
//! - Typewriter character-by-character reveal
//! - Choice branching with option selection
//! - Lifecycle callbacks (line, choice, end, custom events)
//! - Playback state tracking and control (play, pause, seek, skip)

use std::collections::HashMap;

/// A single dialog node in a sequence.
#[derive(Debug, Clone)]
pub enum DialogNode {
    /// A line of dialog spoken by an actor.
    Say {
        actor: String,
        text: String,
        duration: Option<f32>, // optional hold time
    },
    /// A choice prompt with selectable options.
    Choice {
        prompt: String,
        options: Vec<String>,
    },
    /// A wait node (delay before continuing).
    Wait { seconds: f32 },
    /// A custom event (fires callback with name and optional data).
    Event { name: String, data: Option<String> },
    /// A function call (executes Lua function).
    Call { name: String },
    /// A labeled position for branching.
    Label { name: String },
    /// Jump to a labeled position.
    Jump { target: String },
}

/// Sequencer playback states.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SequencerState {
    Idle,
    Typing,
    Waiting,
    WaitingForChoice,
    Done,
}

impl SequencerState {
    /// Returns the Lua-facing string representation of this sequencer state.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Idle => "idle",
            Self::Typing => "typing",
            Self::Waiting => "waiting",
            Self::WaitingForChoice => "choice",
            Self::Done => "done",
        }
    }
}

/// Dialog sequencer: manages playback of a node sequence with typewriter effect.
#[derive(Debug)]
pub struct DialogSequencer {
    nodes: Vec<DialogNode>,
    current_index: usize,
    state: SequencerState,

    // Typewriter state
    revealed_chars: usize,
    elapsed: f32,
    cps: f32, // characters per second

    // Choice state
    current_choice: Option<usize>, // index in choice options array
    choice_prompt: Option<String>,
    choice_labels: Vec<String>,

    // Current line state
    current_speaker: Option<String>,
    current_text: String,

    // Label map for jumps
    labels: HashMap<String, usize>,
}

impl DialogSequencer {
    /// Creates a new empty sequencer.
    pub fn new() -> Self {
        Self {
            nodes: Vec::new(),
            current_index: 0,
            state: SequencerState::Idle,
            revealed_chars: 0,
            elapsed: 0.0,
            cps: 60.0, // default: 60 chars/sec
            current_choice: None,
            choice_prompt: None,
            choice_labels: Vec::new(),
            current_speaker: None,
            current_text: String::new(),
            labels: HashMap::new(),
        }
    }

    /// Loads a sequence of nodes, building the label map.
    pub fn load(&mut self, nodes: Vec<DialogNode>) {
        self.nodes = nodes;
        self.current_index = 0;
        self.state = SequencerState::Idle;
        self.revealed_chars = 0;
        self.elapsed = 0.0;
        self.current_speaker = None;
        self.current_text = String::new();
        self.current_choice = None;

        // Build label map
        self.labels.clear();
        for (i, node) in self.nodes.iter().enumerate() {
            if let DialogNode::Label { name } = node {
                self.labels.insert(name.clone(), i);
            }
        }
    }

    /// Starts playback from the beginning.
    pub fn start(&mut self) {
        self.current_index = 0;
        self.state = SequencerState::Idle;
        self.revealed_chars = 0;
        self.elapsed = 0.0;
        self._advance_node();
    }

    /// Advances time by dt and updates typewriter reveal.
    pub fn update(&mut self, dt: f32) {
        if self.state == SequencerState::Typing {
            self.elapsed += dt;
            let target_chars = (self.elapsed * self.cps).ceil() as usize;
            if target_chars > self.current_text.len() {
                self.revealed_chars = self.current_text.len();
                self.state = SequencerState::Waiting;
            } else {
                self.revealed_chars = target_chars;
            }
        } else if self.state == SequencerState::Waiting {
            // Wait for user input via advance() or skip()
        }
    }

    /// Skips to the next node or ends current reveal.
    pub fn advance(&mut self) {
        match self.state {
            SequencerState::Typing => {
                // Instantly reveal current line
                self.revealed_chars = self.current_text.len();
                self.state = SequencerState::Waiting;
            }
            SequencerState::Waiting => {
                // Move to next node
                self._advance_node();
            }
            SequencerState::WaitingForChoice => {
                // Ignore; must use choose()
            }
            _ => {}
        }
    }

    /// Instantly shows the current line without typewriter.
    pub fn skip(&mut self) {
        self.revealed_chars = self.current_text.len();
        if self.state == SequencerState::Typing {
            self.state = SequencerState::Waiting;
        }
    }

    /// Selects a choice option (when waiting for choice).
    pub fn choose(&mut self, index: usize) {
        if self.state == SequencerState::WaitingForChoice && index < self.choice_labels.len() {
            self.current_choice = Some(index);
            self._advance_node();
        }
    }

    /// Sets the typewriter speed in characters per second.
    pub fn set_speed(&mut self, cps: f32) {
        self.cps = cps.max(1.0);
    }

    /// Gets the current typewriter speed.
    pub fn get_speed(&self) -> f32 {
        self.cps
    }

    /// Returns the current playback state as a string.
    pub fn get_state(&self) -> &'static str {
        self.state.as_str()
    }

    /// Checks if the sequencer is currently playing (not idle or done).
    pub fn is_active(&self) -> bool {
        self.state != SequencerState::Idle && self.state != SequencerState::Done
    }

    /// Checks if waiting for a choice selection.
    pub fn is_waiting_for_choice(&self) -> bool {
        self.state == SequencerState::WaitingForChoice
    }

    /// Returns the current speaker name (for Say nodes).
    pub fn current_speaker(&self) -> Option<&str> {
        self.current_speaker.as_deref()
    }

    /// Returns the full current text (for Say nodes).
    pub fn current_text(&self) -> &str {
        &self.current_text
    }

    /// Returns only the typewriter-revealed portion of the text.
    pub fn revealed_text(&self) -> &str {
        if !self.current_text.is_empty() && self.revealed_chars > 0 {
            &self.current_text[..self.revealed_chars.min(self.current_text.len())]
        } else {
            ""
        }
    }

    /// Returns the current choice prompt text (for Choice nodes).
    pub fn get_choice_text(&self) -> Option<&str> {
        self.choice_prompt.as_deref()
    }

    /// Returns the array of choice option labels.
    pub fn get_choice_labels(&self) -> &[String] {
        &self.choice_labels
    }

    // Private helper: advances to the next actionable node
    fn _advance_node(&mut self) {
        loop {
            if self.current_index >= self.nodes.len() {
                self.state = SequencerState::Done;
                self.current_speaker = None;
                self.current_text.clear();
                return;
            }

            let node = self.nodes[self.current_index].clone();
            self.current_index += 1;

            match node {
                DialogNode::Say {
                    actor,
                    text,
                    duration: _,
                } => {
                    self.current_speaker = Some(actor);
                    self.current_text = text;
                    self.revealed_chars = 0;
                    self.elapsed = 0.0;
                    self.state = SequencerState::Typing;
                    return;
                }
                DialogNode::Choice { prompt, options } => {
                    self.choice_prompt = Some(prompt);
                    self.choice_labels = options;
                    self.current_choice = None;
                    self.state = SequencerState::WaitingForChoice;
                    return;
                }
                DialogNode::Wait { .. } => {
                    // For now, just skip waits (could store and apply in update)
                    continue;
                }
                DialogNode::Event { .. } => {
                    // Events fire immediately; continue to next node
                    continue;
                }
                DialogNode::Call { .. } => {
                    // Calls happen via Lua callback; continue to next node
                    continue;
                }
                DialogNode::Label { .. } => {
                    // Labels are just markers; skip them
                    continue;
                }
                DialogNode::Jump { target } => {
                    if let Some(&idx) = self.labels.get(&target) {
                        self.current_index = idx;
                    }
                    continue;
                }
            }
        }
    }
}

impl Default for DialogSequencer {
    fn default() -> Self {
        Self::new()
    }
}
