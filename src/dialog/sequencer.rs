//! `src/dialog/sequencer.rs` plays authored dialog nodes as a runtime sequence with typewriter reveal and choices.
//! It owns `DialogNode`, `SequencerState`, and `DialogSequencer`, including labels, jumps, waits, calls, and events.
//! Current line text, reveal progress, active choice prompt, option labels, and label lookup tables are stored here.
//! Node advancement, skip behavior, speed control, and choice selection live here so playback policy stays centralized.
//! Wait, event, call, label, and jump nodes are interpreted here so scripted playback rules remain local to the sequencer.
//! This file is the runtime playback boundary for authored dialog scripts; it does not score topics or manage speakers.
//! Read it when reveal timing, node execution flow, choice UX state, or jump semantics for dialog playback change.

use std::collections::HashMap;

/// Metadata attached to a spoken dialog line.
#[derive(Debug, Clone, Default)]
pub struct DialogLineMeta {
    /// Stable authored line id for save/load, read-state, or analytics.
    pub id: Option<String>,
    /// Optional voice clip identifier associated with the line.
    pub voice: Option<String>,
    /// Optional route or branch label associated with the line.
    pub route: Option<String>,
    /// Arbitrary tags associated with the line.
    pub tags: Vec<String>,
}

/// One completed or active spoken line stored in the backlog/history.
#[derive(Debug, Clone)]
pub struct DialogHistoryEntry {
    /// Speaker name shown for the line, if any.
    pub speaker: Option<String>,
    /// Full line text.
    pub text: String,
    /// Structured metadata carried with the line.
    pub meta: DialogLineMeta,
}

/// Signal emitted when the sequencer reaches an event-like node.
#[derive(Debug, Clone)]
pub struct DialogSignal {
    /// Signal kind name: currently `event` or `call`.
    pub kind: String,
    /// Event or function identifier.
    pub name: String,
    /// Optional payload string.
    pub data: Option<String>,
}

/// Serializable snapshot of sequencer runtime state.
#[derive(Debug, Clone)]
pub struct DialogSequencerSnapshot {
    /// Full node list currently loaded into the sequencer.
    pub nodes: Vec<DialogNode>,
    /// Zero-based index of the next node to execute.
    pub current_index: usize,
    /// Active playback state.
    pub state: SequencerState,
    /// Number of currently revealed bytes in `current_text`.
    pub revealed_chars: usize,
    /// Elapsed seconds for the current typing node.
    pub elapsed: f32,
    /// Characters per second typing speed.
    pub cps: f32,
    /// Zero-based selected option index for the current choice, if any.
    pub current_choice: Option<usize>,
    /// Current choice prompt text, if any.
    pub choice_prompt: Option<String>,
    /// Current choice option labels.
    pub choice_labels: Vec<String>,
    /// Current speaker name, if any.
    pub current_speaker: Option<String>,
    /// Current full line text.
    pub current_text: String,
    /// Current line metadata.
    pub current_meta: DialogLineMeta,
    /// Remaining seconds for a pending wait node.
    pub wait_remaining: f32,
    /// Remaining seconds to auto-advance a revealed say node.
    pub line_hold_remaining: f32,
    /// Backlog of spoken lines.
    pub history: Vec<DialogHistoryEntry>,
    /// Pending event/call signals not yet consumed by Lua.
    pub pending_signals: Vec<DialogSignal>,
}

/// A single dialog node in a sequence.
#[derive(Debug, Clone)]
pub enum DialogNode {
    /// A line of dialog spoken by an actor.
    Say {
        actor: String,
        text: String,
        duration: Option<f32>, // optional hold time
        id: Option<String>,
        voice: Option<String>,
        route: Option<String>,
        tags: Vec<String>,
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
    current_meta: DialogLineMeta,
    wait_remaining: f32,
    line_hold_remaining: f32,
    history: Vec<DialogHistoryEntry>,
    pending_signals: Vec<DialogSignal>,

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
            current_meta: DialogLineMeta::default(),
            wait_remaining: 0.0,
            line_hold_remaining: 0.0,
            history: Vec::new(),
            pending_signals: Vec::new(),
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
        self.choice_prompt = None;
        self.choice_labels.clear();
        self.current_meta = DialogLineMeta::default();
        self.wait_remaining = 0.0;
        self.line_hold_remaining = 0.0;
        self.history.clear();
        self.pending_signals.clear();

        // Build label map
        self.rebuild_labels();
    }

    /// Starts playback from the beginning.
    pub fn start(&mut self) {
        self.current_index = 0;
        self.state = SequencerState::Idle;
        self.revealed_chars = 0;
        self.elapsed = 0.0;
        self.wait_remaining = 0.0;
        self.line_hold_remaining = 0.0;
        self.choice_prompt = None;
        self.choice_labels.clear();
        self.current_choice = None;
        self.current_speaker = None;
        self.current_text.clear();
        self.current_meta = DialogLineMeta::default();
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
            if self.wait_remaining > 0.0 {
                self.wait_remaining = (self.wait_remaining - dt).max(0.0);
                if self.wait_remaining == 0.0 {
                    self._advance_node();
                }
            } else if self.line_hold_remaining > 0.0 {
                self.line_hold_remaining = (self.line_hold_remaining - dt).max(0.0);
                if self.line_hold_remaining == 0.0 {
                    self._advance_node();
                }
            }
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
                self.wait_remaining = 0.0;
                self.line_hold_remaining = 0.0;
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
            self.choice_prompt = None;
            self.choice_labels.clear();
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

    /// Returns the current authored line id, if any.
    pub fn current_id(&self) -> Option<&str> {
        self.current_meta.id.as_deref()
    }

    /// Returns the current voice id, if any.
    pub fn current_voice(&self) -> Option<&str> {
        self.current_meta.voice.as_deref()
    }

    /// Returns the current route label, if any.
    pub fn current_route(&self) -> Option<&str> {
        self.current_meta.route.as_deref()
    }

    /// Returns current line tags.
    pub fn current_tags(&self) -> &[String] {
        &self.current_meta.tags
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

    /// Returns spoken-line history in insertion order.
    pub fn history(&self) -> &[DialogHistoryEntry] {
        &self.history
    }

    /// Clear spoken-line history.
    pub fn clear_history(&mut self) {
        self.history.clear();
    }

    /// Returns the next pending event/call signal without removing it.
    pub fn peek_signal(&self) -> Option<&DialogSignal> {
        self.pending_signals.first()
    }

    /// Removes and returns the next pending event/call signal.
    pub fn pop_signal(&mut self) -> Option<DialogSignal> {
        if self.pending_signals.is_empty() {
            None
        } else {
            Some(self.pending_signals.remove(0))
        }
    }

    /// Capture a runtime snapshot that can be restored later.
    pub fn snapshot(&self) -> DialogSequencerSnapshot {
        DialogSequencerSnapshot {
            nodes: self.nodes.clone(),
            current_index: self.current_index,
            state: self.state,
            revealed_chars: self.revealed_chars,
            elapsed: self.elapsed,
            cps: self.cps,
            current_choice: self.current_choice,
            choice_prompt: self.choice_prompt.clone(),
            choice_labels: self.choice_labels.clone(),
            current_speaker: self.current_speaker.clone(),
            current_text: self.current_text.clone(),
            current_meta: self.current_meta.clone(),
            wait_remaining: self.wait_remaining,
            line_hold_remaining: self.line_hold_remaining,
            history: self.history.clone(),
            pending_signals: self.pending_signals.clone(),
        }
    }

    /// Replace runtime state from a previously captured snapshot.
    pub fn restore(&mut self, snapshot: DialogSequencerSnapshot) {
        self.nodes = snapshot.nodes;
        self.current_index = snapshot.current_index.min(self.nodes.len());
        self.state = snapshot.state;
        self.revealed_chars = snapshot.revealed_chars.min(snapshot.current_text.len());
        self.elapsed = snapshot.elapsed.max(0.0);
        self.cps = snapshot.cps.max(1.0);
        self.current_choice = snapshot.current_choice;
        self.choice_prompt = snapshot.choice_prompt;
        self.choice_labels = snapshot.choice_labels;
        self.current_speaker = snapshot.current_speaker;
        self.current_text = snapshot.current_text;
        self.current_meta = snapshot.current_meta;
        self.wait_remaining = snapshot.wait_remaining.max(0.0);
        self.line_hold_remaining = snapshot.line_hold_remaining.max(0.0);
        self.history = snapshot.history;
        self.pending_signals = snapshot.pending_signals;
        self.rebuild_labels();
    }

    // Private helper: advances to the next actionable node
    fn _advance_node(&mut self) {
        loop {
            if self.current_index >= self.nodes.len() {
                self.state = SequencerState::Done;
                self.current_speaker = None;
                self.current_text.clear();
                self.current_meta = DialogLineMeta::default();
                self.choice_prompt = None;
                self.choice_labels.clear();
                self.wait_remaining = 0.0;
                self.line_hold_remaining = 0.0;
                return;
            }

            let node = self.nodes[self.current_index].clone();
            self.current_index += 1;

            match node {
                DialogNode::Say {
                    actor,
                    text,
                    duration,
                    id,
                    voice,
                    route,
                    tags,
                } => {
                    let meta = DialogLineMeta {
                        id,
                        voice,
                        route,
                        tags,
                    };
                    self.current_speaker = Some(actor.clone());
                    self.current_text = text.clone();
                    self.current_meta = meta.clone();
                    self.choice_prompt = None;
                    self.choice_labels.clear();
                    self.wait_remaining = 0.0;
                    self.line_hold_remaining = duration.unwrap_or(0.0).max(0.0);
                    self.revealed_chars = 0;
                    self.elapsed = 0.0;
                    self.history.push(DialogHistoryEntry {
                        speaker: Some(actor),
                        text,
                        meta,
                    });
                    self.state = SequencerState::Typing;
                    return;
                }
                DialogNode::Choice { prompt, options } => {
                    self.choice_prompt = Some(prompt);
                    self.choice_labels = options;
                    self.current_choice = None;
                    self.current_speaker = None;
                    self.current_text.clear();
                    self.current_meta = DialogLineMeta::default();
                    self.wait_remaining = 0.0;
                    self.line_hold_remaining = 0.0;
                    self.state = SequencerState::WaitingForChoice;
                    return;
                }
                DialogNode::Wait { seconds } => {
                    self.current_speaker = None;
                    self.current_text.clear();
                    self.current_meta = DialogLineMeta::default();
                    self.choice_prompt = None;
                    self.choice_labels.clear();
                    self.revealed_chars = 0;
                    self.elapsed = 0.0;
                    self.line_hold_remaining = 0.0;
                    self.wait_remaining = seconds.max(0.0);
                    if self.wait_remaining == 0.0 {
                        continue;
                    }
                    self.state = SequencerState::Waiting;
                    return;
                }
                DialogNode::Event { name, data } => {
                    self.pending_signals.push(DialogSignal {
                        kind: "event".to_string(),
                        name,
                        data,
                    });
                    continue;
                }
                DialogNode::Call { name } => {
                    self.pending_signals.push(DialogSignal {
                        kind: "call".to_string(),
                        name,
                        data: None,
                    });
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

    fn rebuild_labels(&mut self) {
        self.labels.clear();
        for (i, node) in self.nodes.iter().enumerate() {
            if let DialogNode::Label { name } = node {
                self.labels.insert(name.clone(), i);
            }
        }
    }
}

impl Default for DialogSequencer {
    fn default() -> Self {
        Self::new()
    }
}
