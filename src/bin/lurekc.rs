//! Console-less launcher variant for the shared `lurek_run()` bootstrap path.
//!
//! - Applies the Windows GUI subsystem attribute while preserving all runtime modes.
//! - Returns the same process exit code as the main `lurek2d` entry point.

#![cfg_attr(windows, windows_subsystem = "windows")]
use std::process::ExitCode;
/// Start the engine using the shared runtime bootstrap path and return its exit code.
fn main() -> ExitCode {
    lurek2d::lurek_run()
}
