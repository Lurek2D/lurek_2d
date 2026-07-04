//! `src/main.rs` is the native executable entrypoint and keeps boot logic thin by forwarding control into `lurek2d`.
//! On Windows the shared desktop launcher raises timer resolution before startup so frame pacing and input timing stay consistent at launch.
//! Runtime policy and argument handling remain in the library entrypoint.

use std::process::ExitCode;

fn main() -> ExitCode {
    lurek2d::lurek_run_desktop()
}
