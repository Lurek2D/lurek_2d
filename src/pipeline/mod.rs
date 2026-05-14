//! - DAG-based pipeline for dependency-ordered step execution.
//! - Frame-driven scheduler ticks steps when delay timers expire.
//! - Per-step error policies with abort-on-failure or continue modes.
//! - Result types report completed, skipped, and failed steps after a run.

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
pub use step::{ErrorPolicy, PipelineStep, StepStatus};
