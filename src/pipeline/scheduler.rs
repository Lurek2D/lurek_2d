//! `src/pipeline/scheduler.rs` owns frame-driven delay timers that decide when waiting pipeline steps become ready to run.
//! `PipelineScheduler` tracks elapsed time, running state, and per-step countdowns without duplicating graph rules.
//! Waiting-step synchronization and ready-step reporting live here, keeping pacing policy distinct from validation.
//! This file keeps timer state separate from pipeline definitions, which preserves cleaner orchestration data.
//! Read this file when delay countdowns, readiness emission, or scheduler reset behavior for pipeline execution changes.

use crate::pipeline::dag::Pipeline;
use crate::pipeline::step::StepStatus;
use std::collections::HashMap;

/// Drives step-delay countdowns and reports which steps become ready each frame.
pub struct PipelineScheduler {
    /// Remaining delay seconds per step name; decremented each `update` call.
    delay_timers: HashMap<String, f32>,
    /// Whether the pipeline is currently executing.
    pub is_running: bool,
    /// Total wall-clock seconds since `start` was called.
    pub elapsed: f32,
}

impl PipelineScheduler {
    /// Create a stopped scheduler with no active timers.
    pub fn new() -> Self {
        Self {
            delay_timers: HashMap::new(),
            is_running: false,
            elapsed: 0.0,
        }
    }

    /// Clear prior timers and begin execution.
    ///
    /// Waiting steps already present on the pipeline at start are seeded into
    /// internal timers so borrowed ready refs work for status-driven call sites.
    pub fn start(&mut self, _pipeline: &Pipeline) {
        self.delay_timers.clear();
        self.elapsed = 0.0;
        self.is_running = true;
    }

    /// Advance timers by `dt` seconds and return names of steps whose delay has expired and are still `Waiting`.
    pub fn update(&mut self, dt: f32, pipeline: &Pipeline) -> Vec<String> {
        self.update_ready_refs(dt, pipeline)
            .into_iter()
            .map(str::to_owned)
            .collect()
    }

    /// Advance timers by `dt` seconds and return borrowed names of steps whose delay has expired.
    ///
    /// The waiting set is represented by `delay_timers` keys. It is fed by
    /// `mark_step_waiting` and also auto-synced from pipeline steps currently in
    /// `StepStatus::Waiting` for compatibility with status-driven call sites.
    /// Once a step is ready it is removed so it is emitted at most once per
    /// waiting transition.
    pub fn update_ready_refs<'a>(&mut self, dt: f32, pipeline: &'a Pipeline) -> Vec<&'a str> {
        if !self.is_running {
            return Vec::new();
        }
        self.elapsed += dt;

        // Keep scheduler-owned timers in sync with status-driven waiting steps.
        for step in pipeline.get_steps() {
            if step.status == StepStatus::Waiting {
                self.delay_timers
                    .entry(step.name.clone())
                    .or_insert(step.delay);
            }
        }

        let mut ready_names: Vec<String> = Vec::new();
        for (name, timer) in &mut self.delay_timers {
            *timer -= dt;
            if *timer <= 0.0 {
                ready_names.push(name.clone());
            }
        }
        let mut ready: Vec<&str> = Vec::new();
        for name in ready_names {
            self.delay_timers.remove(name.as_str());
            if let Some(step) = pipeline.get_step(name.as_str()) {
                ready.push(step.name.as_str());
            }
        }
        ready
    }

    /// Reset and arm the delay timer for `name` using its configured delay from `pipeline`.
    pub fn mark_step_waiting(&mut self, name: &str, pipeline: &Pipeline) {
        let delay = pipeline.get_step(name).map(|s| s.delay).unwrap_or(0.0);
        self.delay_timers.insert(name.to_owned(), delay);
    }

    /// Clear all timers and stop execution; does not reset step statuses in the pipeline.
    pub fn reset(&mut self) {
        self.delay_timers.clear();
        self.is_running = false;
        self.elapsed = 0.0;
    }
}

/// Delegate to `PipelineScheduler::new`.
impl Default for PipelineScheduler {
    fn default() -> Self {
        Self::new()
    }
}
