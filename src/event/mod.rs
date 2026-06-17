//! Provides the high-level event module boundary for queued dispatch and signal-based subscription routing. `event/mod` is the event module index, declaring `event_queue`, `signal` so agents can identify which files own each feature slice before opening implementation code.
//! Connects payload conversion, priority handling, and listener registration into one communication layer. `src/event/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `event_queue::{ event_arg_to_lua_value, event_to_lua_multi, Event, EventArg, EventPriority, EventQueue, EventTableKey, }`, `signal::Signal` centralized for the event subsystem.

/// Priority queue and Lua payload conversion support for runtime events.
pub mod event_queue;
/// Name-based and wildcard signal subscription storage.
pub mod signal;
pub use event_queue::{
    event_arg_to_lua_value, event_to_lua_multi, Event, EventArg, EventPriority, EventQueue,
    EventTableKey,
};
pub use signal::Signal;
