//! Lurek2D engine entry point: CLI parsing, engine bootstrap, and run-loop start.
//!
//! - Parses the `--game <path>` and `--demo <name>` CLI arguments.
//! - Constructs `EngineConfig` from CLI args and the game's `conf.toml`.
//! - Calls `app::run(config)` which owns the winit event loop and Lua VM lifecycle.
//! - Exit codes: 0 = clean quit, 1 = startup error, 2 = runtime panic caught.

use std::process::ExitCode;

#[cfg(target_os = "windows")]
fn set_windows_timer_resolution() {
    unsafe {
        windows_sys::Win32::Media::timeBeginPeriod(1);
    }
}
fn main() -> ExitCode {
    #[cfg(target_os = "windows")]
    set_windows_timer_resolution();
    lurek2d::lurek_run()
}
