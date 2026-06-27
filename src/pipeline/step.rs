//! `src/pipeline/step.rs` owns the schema for one pipeline step, including lifecycle state and per-step failure policy.
//! It defines `StepStatus`, `ErrorPolicy`, and `PipelineStep`, keeping authored work-unit metadata under one owner.
//! Dependency names, delays, retry settings, optionality, tags, metadata, and runtime status fields all live in this file.
//! Read it when step contract fields, status vocabulary, reset behavior, or per-step error handling semantics need changes.
//! This file is the step-schema boundary for pipelines, while graph structure and delay scheduling stay in sibling files.

use std::collections::HashMap;

/// Maximum number of named output slots exposed by one pipeline step.
pub const MAX_OUTPUT_SLOTS: u8 = 5;

/// Execution lifecycle state of a single pipeline step.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum StepStatus {
    /// Created but not yet enqueued for execution.
    Pending,
    /// Enqueued; waiting for its delay timer to expire.
    Waiting,
    /// Currently executing.
    Running,
    /// Finished successfully.
    Completed,
    /// Execution ended with an error.
    Failed,
    /// Not executed because a required dependency failed.
    Skipped,
    /// Cancelled when the pipeline aborted before this step ran.
    Cancelled,
}

impl StepStatus {
    /// Return the canonical lowercase token string for this status.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Pending => "pending",
            Self::Waiting => "waiting",
            Self::Running => "running",
            Self::Completed => "completed",
            Self::Failed => "failed",
            Self::Skipped => "skipped",
            Self::Cancelled => "cancelled",
        }
    }
}

/// Per-step failure response, overriding the pipeline-level `ErrorMode`.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ErrorPolicy {
    /// Abort the entire pipeline on failure.
    Abort,
    /// Mark this step failed and continue scheduling other steps.
    Continue,
    /// Re-queue this step up to `retry_count` times before failing.
    Retry,
}

/// Declarative connection from one step output slot to another step input slot.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct PipelineOutputLink {
    /// Output slot on the source step, clamped by API validation to 1..=5.
    pub output_slot: u8,
    /// Target step name that may receive the signal and data payload.
    pub target: String,
    /// Input slot on the target step, clamped by API validation to 1..=5.
    pub target_input: u8,
    /// Whether completion of this output link should signal the target as eligible.
    pub signal: bool,
    /// Optional metadata key used by Lua bindings to attach a condition callback.
    pub condition_key: Option<String>,
}

impl PipelineOutputLink {
    /// Create a link between output and input slots; caller must provide valid step names.
    pub fn new(output_slot: u8, target: impl Into<String>, target_input: u8) -> Self {
        Self {
            output_slot: output_slot.clamp(1, MAX_OUTPUT_SLOTS),
            target: target.into(),
            target_input: target_input.clamp(1, MAX_OUTPUT_SLOTS),
            signal: true,
            condition_key: None,
        }
    }
}

/// Single named unit of work in a `Pipeline`, carrying dependency, timing, and retry configuration.
#[derive(Debug, Clone)]
pub struct PipelineStep {
    /// Unique name within the owning `Pipeline`.
    pub name: String,
    /// Names of steps that must complete before this one can run.
    pub deps: Vec<String>,
    /// Seconds to wait after deps satisfy before transitioning from `Waiting` to `Running`.
    pub delay: f32,
    /// When `true`, downstream steps are not blocked if this step fails.
    pub optional: bool,
    /// Maximum number of automatic retries on failure; 0 means no retries.
    pub retry_count: u32,
    /// Seconds to wait between retry attempts.
    pub retry_delay: f32,
    /// Per-step policy that overrides the pipeline `ErrorMode` on failure.
    pub on_error: ErrorPolicy,
    /// Optional grouping tag used for filtering or reporting.
    pub tag: Option<String>,
    /// Arbitrary key-value metadata stored for Lua consumption.
    pub metadata: HashMap<String, String>,
    /// Output-slot links used to route process data and trigger signals after completion.
    pub output_links: Vec<PipelineOutputLink>,
    /// Current execution lifecycle state.
    pub status: StepStatus,
    /// Number of execution attempts made so far, including retries.
    pub attempt: u32,
    /// Wall-clock seconds the most recent execution attempt took.
    pub duration: f32,
    /// Error message from the most recent failure, if any.
    pub error_msg: Option<String>,
}

impl PipelineStep {
    /// Create a step with default settings: no deps, no delay, no retries, `ErrorPolicy::Abort`.
    pub fn new(name: impl Into<String>) -> Self {
        Self {
            name: name.into(),
            deps: Vec::new(),
            delay: 0.0,
            optional: false,
            retry_count: 0,
            retry_delay: 0.0,
            on_error: ErrorPolicy::Abort,
            tag: None,
            metadata: HashMap::new(),
            output_links: Vec::new(),
            status: StepStatus::Pending,
            attempt: 0,
            duration: 0.0,
            error_msg: None,
        }
    }

    /// Reset runtime state to `Pending`; clears attempt count, duration, and error message.
    pub fn reset(&mut self) {
        self.status = StepStatus::Pending;
        self.attempt = 0;
        self.duration = 0.0;
        self.error_msg = None;
    }

    /// Add an output link and return its stable condition key.
    pub fn add_output_link(
        &mut self,
        output_slot: u8,
        target: impl Into<String>,
        target_input: u8,
        signal: bool,
    ) -> String {
        let target = target.into();
        let key = format!(
            "{}:{}:{}:{}",
            self.name,
            output_slot.clamp(1, MAX_OUTPUT_SLOTS),
            target,
            target_input.clamp(1, MAX_OUTPUT_SLOTS)
        );
        let mut link = PipelineOutputLink::new(output_slot, target, target_input);
        link.signal = signal;
        link.condition_key = Some(key.clone());
        self.output_links.push(link);
        key
    }

    /// Return all output links that target `target_name`.
    pub fn links_to<'a>(
        &'a self,
        target_name: &'a str,
    ) -> impl Iterator<Item = &'a PipelineOutputLink> {
        self.output_links
            .iter()
            .filter(move |link| link.target == target_name)
    }
}
