//! - Reusable game-logic design patterns: state machines, behavior trees, event buses, and object pools.
//! - Data structures for priority queues, graphs, tries, rings, and bidirectional maps.
//! - Command stacking, observer subscriptions, throttling, and weighted random selection.

/// Behavior tree execution engine with composite and leaf nodes.
pub mod behavior_tree;
/// Bidirectional map allowing lookup by key or value.
pub mod bimap;
/// Key-value blackboard for sharing state between behavior tree nodes.
pub mod blackboard;
/// Stack and queue abstractions with metadata tracking.
pub mod collections;
/// Undo/redo command stack with history.
pub mod command_stack;
/// Publish-subscribe event bus for decoupled communication.
pub mod event_bus;
/// Generic factory for type-keyed object construction.
pub mod factory;
/// Funnel pattern for staged filtering of candidates.
pub mod funnel;
/// Directed graph with nodes and weighted edges.
pub mod graph;
/// Mediator pattern for centralized component communication.
pub mod mediator;
/// Pre-allocated object pool for reusable instances.
pub mod object_pool;
/// Observer pattern for one-to-many change notification.
pub mod observer;
/// Min/max priority queue with keyed items.
pub mod priority_queue;
/// Fixed-capacity ring buffer with wrap-around semantics.
pub mod ring;
/// Service locator for runtime dependency resolution.
pub mod service_locator;
/// Lightweight enum-based state with enter/exit hooks.
pub mod simple_state;
/// Finite state machine with named states and transition rules.
pub mod state_machine;
/// Strategy pattern for interchangeable algorithm selection.
pub mod strategy;
/// Throttle and debounce rate limiters.
pub mod throttle;
/// Prefix trie for fast string lookup and completion.
pub mod trie;
/// Weighted random selection from a probability table.
pub mod weighted_random;
pub use behavior_tree::{BehaviorTree, BtNode, BtRunState, BtStatus, NodeId, NodeKind};
pub use bimap::BiMap;
pub use blackboard::{Blackboard, BlackboardValue};
pub use collections::{QueueMeta, StackMeta};
pub use command_stack::{CommandEntry, CommandStack};
pub use event_bus::{EventBus, Subscription};
pub use factory::Factory;
pub use funnel::{Funnel, FunnelEntry};
pub use graph::{Graph, GraphEdge, GraphNode};
pub use mediator::Mediator;
pub use object_pool::ObjectPool;
pub use observer::{Observer, ObserverEntry};
pub use priority_queue::{PriorityItem, PriorityQueue};
pub use ring::{Ring, RingEntry};
pub use service_locator::ServiceLocator;
pub use simple_state::SimpleState;
pub use state_machine::{StateMachine, TransitionRule};
pub use strategy::Strategy;
pub use throttle::{Debounce, Throttle};
pub use trie::Trie;
pub use weighted_random::{WeightedEntry, WeightedRandom};
