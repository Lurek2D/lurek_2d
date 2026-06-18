//! `src/event/mod.rs` is the module index that exposes queued events, Lua payload conversion, and signal subscriptions.
//! It reexports `EventQueue`, payload types, conversion helpers, and `Signal` through one stable event surface.
//! No queued event or subscription state lives here; this file only declares child modules and chooses public symbols.
//! Read this index when wiring runtime messaging, because it shows where queued dispatch ends and signal storage begins.
//! Changes here reshape the event boundary, since reexports decide what engine code may import without deep module paths.
//! This module keeps queue mechanics and signal matching separated, which makes event ownership easier to follow.

/// Priority queue and Lua payload conversion support for runtime events.
pub mod event_queue;
/// Name-based and wildcard signal subscription storage.
pub mod signal;
pub use event_queue::{
    event_arg_to_lua_value, event_to_lua_multi, Event, EventArg, EventPriority, EventQueue,
    EventTableKey,
};
pub use signal::Signal;
