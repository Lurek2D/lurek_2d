//! Agent blackboard: shared read/write key-value memory for behaviour-tree nodes.
//!
//! - Stores typed values (`bool`, `i32`, `f32`, `String`) under string keys.
//! - Designed for single-agent or squad-shared access within one Lua game tick.
//! - Values are reset or persisted per agent lifecycle at the call site's discretion.
//! - Used by BT nodes to communicate patrol targets, attack counts, and state flags.

pub use crate::patterns::blackboard::{Blackboard, BlackboardValue};
