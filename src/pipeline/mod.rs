//! `src/pipeline/mod.rs` is the module index that exposes graph structure, step contracts, scheduling, and run results.
//! It reexports `Pipeline`, `ErrorMode`, `PipelineStep`, `StepStatus`, `PipelineScheduler`, and result types together.
//! No live pipeline graph or timers live here; this file only declares child modules and defines public visibility.
//! Read this index when wiring workflows, because it shows where structure, timing, step policy, and outcomes split.
//! Changes here reshape the pipeline boundary, since reexports decide which orchestration tools other systems import.
//! This module keeps dependency graphs, step schemas, scheduler timers, and outcome reporting separated by responsibility.

/// DAG, `Pipeline` struct, and `ErrorMode` for dependency-ordered step execution.
pub mod dag;
/// `PipelineResult` and `PipelineStatus` produced after a run completes or aborts.
pub mod result;
/// Frame-driven delay-timer scheduler that reports steps ready to execute each tick.
pub mod scheduler;
/// `PipelineStep`, `StepStatus`, and `ErrorPolicy` defining individual work units.
pub mod step;

pub use dag::{ErrorMode, Pipeline};
pub use result::{PipelineResult, PipelineStatus};
pub use scheduler::PipelineScheduler;
pub use step::{ErrorPolicy, PipelineOutputLink, PipelineStep, StepStatus, MAX_OUTPUT_SLOTS};
