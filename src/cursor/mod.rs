//! Defines the cursor module boundary for system, custom, animated, contextual, and effect-driven cursor behavior.
//! Groups cursor state types, visual effects, and configuration contracts into one cohesive runtime surface.
//! Serves as the composition entry for engine and script-side cursor control workflows.

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
