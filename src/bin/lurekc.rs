//! `src/bin/lurekc.rs` owns the console-suppressed desktop launcher that forwards startup into the shared entrypoint.
//! It exists mainly to provide the Windows GUI binary variant while keeping real bootstrap logic in the main library crate.
//! Read this file when binary launch behavior or platform-specific subsystem flags change, not when runtime logic changes.

#![cfg_attr(windows, windows_subsystem = "windows")]
use std::process::ExitCode;
/// Start the engine using the shared runtime bootstrap path and return its exit code.
fn main() -> ExitCode {
    lurek2d::lurek_run_desktop()
}
