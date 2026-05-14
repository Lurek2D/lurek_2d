//! Per-frame timing formatter that converts profiling samples to compact diagnostic strings.
//!
//! - Renders tick, update, render, and callback phase durations as a single log line
//! - Stateless helper; the profile sample is owned and collected by the runtime layer

use crate::runtime::FrameProfile;
/// Format one `FrameProfile` sample as a compact single-line timing string.
pub fn format_frame_profile_line(profile: &FrameProfile) -> String {
    format!(
        "tick={:.2}ms update={:.2}ms render={:.2}ms cb={:.2}ms",
        profile.app_tick_ms,
        profile.app_update_ms,
        profile.app_render_ms,
        profile.callback_total_ms,
    )
}
