//! Owns the behavior-tree runtime that stores node structure, running status, decorators, and debug tree summaries.
//! Defines selector, sequence, parallel, inverter, repeater, succeeder, guard, action, and condition node variants.
//! Keeps running indices and repetition counters in the node tree so long-lived control flow survives across ticks.
//! Also exposes compact debug state describing node count and last status for render and tooling consumers.
//! Provides the control-flow boundary between authored hierarchical behavior logic and runtime execution state.
//! Open this owner when branching policy, decorator semantics, or tree reset behavior needs coordinated revision.

use crate::ai::validation::{validate_count, validate_depth, AiValidationLimits};
use mlua::RegistryKey;
/// Execution result produced by a behavior-tree node or whole tree.
#[derive(Debug, Clone, PartialEq)]
pub enum BTStatus {
    /// Node completed its task successfully.
    Success,
    /// Node could not complete its task.
    Failure,
    /// Node is still in progress and must be ticked again next frame.
    Running,
}
impl BTStatus {
    /// Parse a string tag into `BTStatus`; unknown strings default to `Running`.
    pub fn parse_str(s: &str) -> Self {
        match s {
            "success" => Self::Success,
            "failure" => Self::Failure,
            _ => Self::Running,
        }
    }
    /// Return the canonical lowercase string tag for this status.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Success => "success",
            Self::Failure => "failure",
            Self::Running => "running",
        }
    }
}
/// Success and failure rule used when a parallel node combines child results.
#[derive(Debug, Clone, PartialEq)]
pub enum ParallelPolicy {
    /// Parallel succeeds as soon as any one child succeeds.
    RequireOne,
    /// Parallel succeeds only when all children succeed.
    RequireAll,
}
impl ParallelPolicy {
    /// Parse a string tag; unknown strings default to `RequireOne`.
    pub fn parse_str(s: &str) -> Self {
        match s {
            "requireAll" => Self::RequireAll,
            _ => Self::RequireOne,
        }
    }
    /// Return the canonical string tag for this policy.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::RequireOne => "requireOne",
            Self::RequireAll => "requireAll",
        }
    }
}
/// Behavior-tree node with child links and any per-node progress it owns.
pub enum BTNode {
    /// Tries children in order; succeeds on the first child success, fails when all fail.
    Selector {
        /// Ordered list of child nodes.
        children: Vec<BTNode>,
        /// Index of the child currently in `Running` state; reset to 0 on restart.
        running_idx: usize,
    },
    /// Runs children in order; fails on the first child failure, succeeds when all pass.
    Sequence {
        /// Ordered list of child nodes.
        children: Vec<BTNode>,
        /// Index of the child currently in `Running` state; reset to 0 on restart.
        running_idx: usize,
    },
    /// Ticks all children each frame; result controlled by success and failure policies.
    Parallel {
        /// All child nodes ticked each update.
        children: Vec<BTNode>,
        /// Determines when the parallel node reports success.
        success_policy: ParallelPolicy,
        /// Determines when the parallel node reports failure.
        failure_policy: ParallelPolicy,
    },
    /// Flips child result: `Success` ↔ `Failure`; `Running` passes through unchanged.
    Inverter {
        /// The single child whose result is inverted.
        child: Box<BTNode>,
    },
    /// Runs its child `count` times before reporting `Success`.
    Repeater {
        /// The child to repeat.
        child: Box<BTNode>,
        /// Total repetition target; 0 means repeat indefinitely.
        count: u32,
        /// Number of repetitions completed so far.
        done: u32,
    },
    /// Always returns `Success` regardless of the child's result.
    Succeeder {
        /// The child whose result is overridden to `Success`.
        child: Box<BTNode>,
    },
    /// Evaluates a Lua predicate; runs child only when the predicate returns truthy.
    Guard {
        /// Registry key of the Lua predicate callback.
        predicate: RegistryKey,
        /// The child executed when the predicate passes.
        child: Box<BTNode>,
    },
    /// Leaf that calls a Lua callback and converts the return value to `BTStatus`.
    Action {
        /// Registry key of the Lua action callback.
        callback: RegistryKey,
    },
    /// Leaf that evaluates a Lua predicate: `true` → `Success`, `false` → `Failure`.
    Condition {
        /// Registry key of the Lua condition callback.
        callback: RegistryKey,
    },
}
impl BTNode {
    /// Reset all running indices and repetition counters in this subtree recursively.
    pub fn reset(&mut self) {
        match self {
            BTNode::Selector {
                children,
                running_idx,
            } => {
                *running_idx = 0;
                for child in children.iter_mut() {
                    child.reset();
                }
            }
            BTNode::Sequence {
                children,
                running_idx,
            } => {
                *running_idx = 0;
                for child in children.iter_mut() {
                    child.reset();
                }
            }
            BTNode::Parallel { children, .. } => {
                for child in children.iter_mut() {
                    child.reset();
                }
            }
            BTNode::Inverter { child } => child.reset(),
            BTNode::Repeater { child, done, .. } => {
                *done = 0;
                child.reset();
            }
            BTNode::Succeeder { child } => child.reset(),
            BTNode::Guard { child, .. } => child.reset(),
            BTNode::Action { .. } | BTNode::Condition { .. } => {}
        }
    }
    /// Return the number of direct children; leaf nodes return 0.
    pub fn child_count(&self) -> usize {
        match self {
            BTNode::Selector { children, .. }
            | BTNode::Sequence { children, .. }
            | BTNode::Parallel { children, .. } => children.len(),
            BTNode::Inverter { .. }
            | BTNode::Repeater { .. }
            | BTNode::Succeeder { .. }
            | BTNode::Guard { .. } => 1,
            BTNode::Action { .. } | BTNode::Condition { .. } => 0,
        }
    }
}
/// Root node and last completed status for one behavior-tree instance.
pub struct BehaviorTree {
    /// Top-level node; `None` if no tree has been built yet.
    pub root: Option<BTNode>,
    /// Result returned by the last completed tick.
    pub last_status: BTStatus,
    /// Shared safety limits for tree shape validation and guarded debug traversal.
    pub limits: AiValidationLimits,
    /// Last tree-shape validation error produced by strict root updates.
    pub last_validation_error: Option<String>,
}
impl BehaviorTree {
    /// Create an empty tree with `last_status` initialised to `Success`.
    pub fn new() -> Self {
        Self {
            root: None,
            last_status: BTStatus::Success,
            limits: AiValidationLimits::default(),
            last_validation_error: None,
        }
    }

    /// Replace the root after validating node count and depth against shared limits.
    pub fn set_root_checked(&mut self, root: BTNode) -> Result<(), String> {
        if let Err(err) = validate_tree_shape(&root, &self.limits) {
            let message = err.to_string();
            self.last_validation_error = Some(message.clone());
            return Err(message);
        }
        self.last_validation_error = None;
        self.root = Some(root);
        Ok(())
    }
}
/// `Default` delegates to `BehaviorTree::new`.
impl Default for BehaviorTree {
    /// `Default` delegates to `BehaviorTree::new`.
    fn default() -> Self {
        Self::new()
    }
}
/// Debug summary containing node count and the last resolved tree status.
pub struct BtDebugState {
    /// Total node count in the associated tree.
    pub node_count: usize,
    /// Maximum tree depth reached during guarded traversal.
    pub max_depth: usize,
    /// String form of the last tick status.
    pub last_status: String,
    /// Whether guarded traversal hit a configured node or depth limit.
    pub limit_exceeded: bool,
}
impl BehaviorTree {
    /// Build a `BtDebugState` snapshot from the current tree shape and status.
    pub fn debug_state(&self) -> BtDebugState {
        let (node_count, max_depth, limit_exceeded) = match &self.root {
            Some(root) => guarded_tree_summary(root, &self.limits),
            None => (0, 0, false),
        };
        BtDebugState {
            node_count,
            max_depth,
            last_status: self.last_status.as_str().to_string(),
            limit_exceeded,
        }
    }
}

fn validate_tree_shape(
    node: &BTNode,
    limits: &AiValidationLimits,
) -> Result<(), crate::ai::AiError> {
    let (node_count, max_depth, limit_exceeded) = guarded_tree_summary(node, limits);
    validate_count("behavior tree nodes", node_count, limits.max_bt_nodes)?;
    validate_depth("behavior tree", max_depth, limits.max_bt_depth)?;
    if limit_exceeded {
        return Err(crate::ai::AiError::InvalidConfig {
            context: "behavior tree",
            detail: "guarded traversal reported a limit breach".to_string(),
        });
    }
    Ok(())
}

fn guarded_tree_summary(node: &BTNode, limits: &AiValidationLimits) -> (usize, usize, bool) {
    let mut stack = vec![(node, 1usize)];
    let mut node_count = 0usize;
    let mut max_depth = 0usize;
    while let Some((node, depth)) = stack.pop() {
        node_count += 1;
        max_depth = max_depth.max(depth);
        if node_count > limits.max_bt_nodes || depth > limits.max_bt_depth {
            return (node_count, max_depth, true);
        }
        match node {
            BTNode::Selector { children, .. }
            | BTNode::Sequence { children, .. }
            | BTNode::Parallel { children, .. } => {
                for child in children.iter().rev() {
                    stack.push((child, depth + 1));
                }
            }
            BTNode::Inverter { child }
            | BTNode::Repeater { child, .. }
            | BTNode::Succeeder { child }
            | BTNode::Guard { child, .. } => stack.push((child, depth + 1)),
            BTNode::Action { .. } | BTNode::Condition { .. } => {}
        }
    }
    (node_count, max_depth, false)
}
