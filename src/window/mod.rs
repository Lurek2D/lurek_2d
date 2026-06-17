//! This module delivers the high-level desktop window subsystem for lifecycle and display control. `window/mod` is the window module index, declaring `event_loop`, `management`, `viewport` so agents can identify which files own each feature slice before opening implementation code.
//! It unifies monitor handling, mode changes, viewport scaling, and state query surfaces. `src/window/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `event_loop::{ current_display_index_or_default, desktop_dimensions_or_fallback, display_name_or_unknown, display_snapshots, fullscreen_mode_snapshots, get_displays, get_fullscreen_modes, DisplayInfo, FullscreenModeInfo, }`, `management::{ close, display_orientation, flash, focus, from_dpi_pixels, get_dpi_scale, get_fullscreen, get_fullscreen_type_str, get_mode, get_pixel_dimensions, get_position, get_vsync, has_focus, has_mouse_focus, is_fullscreen, is_maximized, is_minimized, is_visible, maximize, minimize, request_attention, restore, set_display, set_fullscreen, set_icon, set_mode, set_position, set_size, set_title, set_vsync, show_message_box, to_dpi_pixels, ModeInfo, }`, `viewport::{ from_pixels, get_height, get_scale_info, get_scale_mode, get_width, set_scale_mode, set_scale_mode_validated, to_pixels, ScaleInfo, }` centralized for the window subsystem.

/// Event-loop helpers: display enumeration, monitor selection, window centering, and startup placement.
pub mod event_loop;
/// OS window control: size, position, title, DPI, fullscreen, vsync, focus, icon, and message boxes.
pub mod management;
/// Virtual viewport scaling: logical-to-pixel mapping and scale-mode selection.
pub mod viewport;
pub(crate) use event_loop::{
    center_window_on_monitor, move_window_to_display, select_startup_monitor,
};
pub use event_loop::{
    current_display_index_or_default, desktop_dimensions_or_fallback, display_name_or_unknown,
    display_snapshots, fullscreen_mode_snapshots, get_displays, get_fullscreen_modes, DisplayInfo,
    FullscreenModeInfo,
};
pub use management::{
    close, display_orientation, flash, focus, from_dpi_pixels, get_dpi_scale, get_fullscreen,
    get_fullscreen_type_str, get_mode, get_pixel_dimensions, get_position, get_vsync, has_focus,
    has_mouse_focus, is_fullscreen, is_maximized, is_minimized, is_visible, maximize, minimize,
    request_attention, restore, set_display, set_fullscreen, set_icon, set_mode, set_position,
    set_size, set_title, set_vsync, show_message_box, to_dpi_pixels, ModeInfo,
};
pub use viewport::{
    from_pixels, get_height, get_scale_info, get_scale_mode, get_width, set_scale_mode,
    set_scale_mode_validated, to_pixels, ScaleInfo,
};
