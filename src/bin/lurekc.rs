//! Console-less launcher variant for the shared `lurek_run()` bootstrap path.

#![cfg_attr(windows, windows_subsystem = "windows")]
use std::process::ExitCode;
/// Start the engine using the shared runtime bootstrap path and return its exit code.
fn main() -> ExitCode {
    lurek2d::lurek_run()
}
