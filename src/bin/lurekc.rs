//! Defines the console-suppressed desktop launcher that delegates to the shared engine bootstrap. `bin/lurekc` delivers the lurekc implementation for the bin subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.

#![cfg_attr(windows, windows_subsystem = "windows")]
use std::process::ExitCode;
/// Start the engine using the shared runtime bootstrap path and return its exit code.
fn main() -> ExitCode {
    lurek2d::lurek_run()
}
