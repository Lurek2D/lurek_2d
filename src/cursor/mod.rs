//! `src/cursor/mod.rs` is the module index that exposes cursor state types, policy managers, and visual cursor effects.
//! It reexports system, custom, and animated cursor types plus context, trail, zoom, and config helpers together.
//! No active cursor state lives here; this file only declares child modules and defines which cursor symbols are public.
//! Read this index when wiring pointer features, because it shows where cursor assets, policy, and effects are separated.
//! Changes here reshape the cursor boundary, since reexports decide what runtime code may import without deep paths.
//! This module keeps cursor images, context switching, trail effects, and zoom-lens state split by clear ownership.

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
