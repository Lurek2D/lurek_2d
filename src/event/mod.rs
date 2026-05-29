//! Provides the high-level event module boundary for queued dispatch and signal-based subscription routing.
//! Connects payload conversion, priority handling, and listener registration into one communication layer.
//! Delivers a stable event-facing surface for systems that need decoupled runtime messaging.

/// Priority queue and Lua payload conversion support for runtime events.
pub mod event_queue;
/// Name-based and wildcard signal subscription storage.
pub mod signal;
pub use event_queue::{
    event_arg_to_lua_value, event_to_lua_multi, Event, EventArg, EventPriority, EventQueue,
    EventTableKey,
};
pub use signal::Signal;
