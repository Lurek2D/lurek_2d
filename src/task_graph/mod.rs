//! Compatibility wrapper exposing the workflow scheduler under the clearer `task_graph` name.
//! The canonical implementation remains in `crate::pipeline` during incremental migration.

/// Re-export of DAG graph structures and validation helpers.
pub mod dag {
    pub use crate::pipeline::dag::*;
}

/// Re-export of run result models.
pub mod result {
    pub use crate::pipeline::result::*;
}

/// Re-export of frame-based scheduler helpers.
pub mod scheduler {
    pub use crate::pipeline::scheduler::*;
}

/// Re-export of per-step configuration and status types.
pub mod step {
    pub use crate::pipeline::step::*;
}

pub use crate::pipeline::{
    ErrorMode, ErrorPolicy, Pipeline, PipelineResult, PipelineScheduler, PipelineStatus,
    PipelineStep, StepStatus,
};
