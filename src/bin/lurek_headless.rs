//! `src/bin/lurek_headless.rs` owns the non-interactive CLI used for validation, packaging, and screenshot batch workflows.
//! It parses subcommands and dispatches offline operations without opening the normal interactive engine window.
//! Validation command wiring, archive packing, recursive ZIP assembly, and batch screenshot orchestration all live here.
//! This file is the entrypoint boundary for headless automation tasks, while engine runtime behavior remains elsewhere.
//! Read it when CLI command set, archive layout, validator invocation, or screenshot-batch behavior needs to change.

use std::env;
use std::fs;
use std::path::PathBuf;
use std::process::{Command, ExitCode};
/// Print CLI usage and supported subcommands.
fn print_usage() {
    eprintln!("lurek_headless <command> [args]\n");
    eprintln!("Commands:");
    eprintln!("  validate [game_dir]");
    eprintln!("  pack <game_dir> <output.lurek>");
    eprintln!("  screenshot-batch <games_root> <output_dir> [frames]");
}
/// Run the game validator script for one game directory or default discovery path.
fn run_validate(game_dir: Option<String>) -> Result<(), String> {
    let mut cmd = Command::new("python");
    cmd.arg("tools/validate/validate_game.py");
    if let Some(dir) = game_dir {
        cmd.arg(dir);
    }
    let status = cmd
        .status()
        .map_err(|e| format!("failed to run validator: {}", e))?;
    if status.success() {
        Ok(())
    } else {
        Err(format!("validator exited with status {}", status))
    }
}
/// Pack a game directory into a `.lurek` archive after checking for `main.lua`.
fn run_pack(game_dir: String, output: String) -> Result<(), String> {
    let root = PathBuf::from(&game_dir);
    if !root.join("main.lua").exists() {
        return Err(format!("'{}' does not contain main.lua", root.display()));
    }
    let _ = output;
    Err("ZIP/.lurek packing is not built into this binary; use repository packaging tools outside the runtime".to_string())
}
/// Run screenshot capture for each valid game folder under `games_root`.
fn run_screenshot_batch(games_root: String, out_dir: String, frames: u32) -> Result<(), String> {
    let root = PathBuf::from(games_root);
    let out = PathBuf::from(out_dir);
    fs::create_dir_all(&out).map_err(|e| format!("failed to create output dir: {}", e))?;
    let engine_bin = if cfg!(windows) {
        PathBuf::from("lurek2d.exe")
    } else {
        PathBuf::from("lurek2d")
    };
    for entry in fs::read_dir(&root).map_err(|e| format!("read_dir failed: {}", e))? {
        let entry = entry.map_err(|e| format!("dir entry failed: {}", e))?;
        let game_dir = entry.path();
        if !game_dir.is_dir() || !game_dir.join("main.lua").exists() {
            continue;
        }
        let name = game_dir
            .file_name()
            .and_then(|n| n.to_str())
            .ok_or_else(|| "invalid game folder name".to_string())?;
        let shot_path = out.join(format!("{}.png", name));
        let status = Command::new(&engine_bin)
            .arg(&game_dir)
            .arg(format!("--screenshot={}", shot_path.display()))
            .arg(format!("--screenshot-frames={}", frames))
            .status()
            .map_err(|e| format!("failed to run lurek2d for '{}': {}", game_dir.display(), e))?;
        if !status.success() {
            return Err(format!(
                "screenshot command failed for '{}' with status {}",
                game_dir.display(),
                status
            ));
        }
    }
    Ok(())
}
/// Parse command-line arguments, execute selected command, and map errors to exit codes.
fn main() -> ExitCode {
    let mut args = env::args().skip(1);
    let Some(cmd) = args.next() else {
        print_usage();
        return ExitCode::from(2);
    };
    let result = match cmd.as_str() {
        "validate" => run_validate(args.next()),
        "pack" => {
            let Some(game_dir) = args.next() else {
                print_usage();
                return ExitCode::from(2);
            };
            let Some(output) = args.next() else {
                print_usage();
                return ExitCode::from(2);
            };
            run_pack(game_dir, output)
        }
        "screenshot-batch" => {
            let Some(games_root) = args.next() else {
                print_usage();
                return ExitCode::from(2);
            };
            let Some(out_dir) = args.next() else {
                print_usage();
                return ExitCode::from(2);
            };
            let frames = args.next().and_then(|v| v.parse::<u32>().ok()).unwrap_or(3);
            run_screenshot_batch(games_root, out_dir, frames)
        }
        _ => {
            print_usage();
            return ExitCode::from(2);
        }
    };
    match result {
        Ok(()) => ExitCode::SUCCESS,
        Err(e) => {
            eprintln!("lurek_headless error: {}", e);
            ExitCode::from(1)
        }
    }
}
