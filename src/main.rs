//! Lurek2D engine binary entry point that initializes the Rust runtime, applies platform-specific timer optimizations, and delegates control to the core engine loop.
//! Sets Windows timer resolution on Windows targets to enable precise frame timing on operating systems that require explicit high-resolution timer setup.
//! Hands off to `lurek_run()` to orchestrate Lua VM bootstrap, renderer initialization, physics world creation, and the main game loop cycle.

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
