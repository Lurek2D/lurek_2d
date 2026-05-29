//! Defines the console-suppressed desktop launcher that delegates to the shared engine bootstrap.
//! Reuses the main runtime startup path while controlling subsystem behavior on Windows.
//! Serves as the minimal binary entrypoint for standard interactive game launch.

#![cfg_attr(windows, windows_subsystem = "windows")]
use std::process::ExitCode;
/// Start the engine using the shared runtime bootstrap path and return its exit code.
fn main() -> ExitCode {
    lurek2d::lurek_run()
}
