//! Workflow orchestration module for building dependency-aware task graphs, advancing them over time, and collecting explicit run outcomes.
//! It ties together graph structure, per-step policy, frame-driven scheduling, and result reporting into one coherent surface for asynchronous or staged work.

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
