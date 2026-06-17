//! `src/main.rs` is the native executable entrypoint and keeps boot logic thin by forwarding control into `lurek2d`.
//! On Windows it raises timer resolution before startup so frame pacing and input timing stay consistent at launch.
//! Beyond that hook, the file delegates to `lurek_run()`, leaving runtime policy and argument handling in the library.

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
