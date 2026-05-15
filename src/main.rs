//! Public types and helpers for the main module.

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
