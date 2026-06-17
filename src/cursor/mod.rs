//! Defines the cursor module boundary for system, custom, animated, contextual, and effect-driven cursor behavior. `cursor/mod` is the cursor module index, declaring `animated_cursor`, `config`, `context`, `custom_cursor`, `system_cursor`, and 2 more so agents can identify which files own each feature slice before opening implementation code.
//! Groups cursor state types, visual effects, and configuration contracts into one cohesive runtime surface. `src/cursor/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `animated_cursor::{AnimatedCursor, PulseConfig}`, `config::CursorConfig`, `context::{CursorContext, CursorManager}`, `custom_cursor::CustomCursor`, and 3 more centralized for the cursor subsystem.

/// Animated cursor with frame sequences, timing, and pulse effects.
pub mod animated_cursor;
/// Cursor system configuration and shared settings.
pub mod config;
/// Context-sensitive cursor switching by named application context.
pub mod context;
/// Custom image cursor with configurable hotspot position and pixel data.
pub mod custom_cursor;
/// System cursor selection (arrow, hand, crosshair, ibeam, wait, etc.).
pub mod system_cursor;
/// Cursor trail effects: fading dots, connected lines, and particle trails.
pub mod trail;
/// Magnifier lens that follows the cursor at a configurable zoom level.
pub mod zoom;

pub use animated_cursor::{AnimatedCursor, PulseConfig};
pub use config::CursorConfig;
pub use context::{CursorContext, CursorManager};
pub use custom_cursor::CustomCursor;
pub use system_cursor::SystemCursor;
pub use trail::{CursorTrail, TrailMode};
pub use zoom::CursorZoom;
