//! Re-exports a typed shared memory surface for AI context that multiple decision layers can trust.
//! Keeps transient reasoning facts in one neutral exchange space across actors and coordinators.
//! Functions as the canonical semantic scratchpad for behavior continuity between system boundaries.

pub use crate::patterns::blackboard::{Blackboard, BlackboardValue};
