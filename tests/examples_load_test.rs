//! Test runner: loads all content/examples/*.lua files via create_lua_vm
//! and reports which ones fail to load without error.
//!
//! Run: cargo test --test examples_load_test
//!
//! Each file is loaded in isolation. If it panics, the test fails.
//! By default all example files are tested; set `LUREK_EXAMPLE_FILTER` to a
//! comma-separated list of file names for a focused smoke check.

use std::cell::RefCell;
use std::path::{Path, PathBuf};
use std::rc::Rc;

use lurek2d::lua_api::{create_lua_vm, SharedState};
use lurek2d::runtime::config::Config;

fn make_vm() -> mlua::Lua {
    let state = Rc::new(RefCell::new(SharedState::new(
        800,
        600,
        "ExamplesTest",
        PathBuf::from("."),
    )));
    state.borrow_mut().load_default_fonts();
    create_lua_vm(state, &Config::default().modules).expect("create_lua_vm failed")
}

fn load_example(path: &str) -> Result<(), String> {
    let lua = make_vm();
    let code = std::fs::read_to_string(path).map_err(|e| format!("read error: {e}"))?;
    lua.load(&code)
        .set_name(Path::new(path).file_name().unwrap().to_str().unwrap())
        .exec()
        .map_err(|e| format!("{e}"))
}

#[test]
fn examples_load_all() {
    let mut failed = Vec::new();
    let mut passed = 0usize;
    let filter = std::env::var("LUREK_EXAMPLE_FILTER")
        .ok()
        .map(|raw| {
            raw.split(',')
                .map(str::trim)
                .filter(|item| !item.is_empty())
                .map(str::to_string)
                .collect::<Vec<_>>()
        })
        .filter(|items| !items.is_empty());

    let mut paths: Vec<_> = std::fs::read_dir("content/examples")
        .expect("read_dir failed")
        .filter_map(|e| e.ok())
        .map(|e| e.path())
        .filter(|p| p.extension().map(|x| x == "lua").unwrap_or(false))
        .filter(|p| {
            if let Some(filter) = &filter {
                let name = p
                    .file_name()
                    .and_then(|name| name.to_str())
                    .unwrap_or_default();
                let path = p.to_string_lossy();
                filter
                    .iter()
                    .any(|item| item == name || path.ends_with(item))
            } else {
                true
            }
        })
        .collect();
    paths.sort();

    for path in &paths {
        let s = path.to_str().unwrap();
        match load_example(s) {
            Ok(()) => {
                passed += 1;
                println!("PASS {s}");
            }
            Err(e) => {
                let name = path.file_name().unwrap().to_str().unwrap();
                println!("FAIL {name}: {e}");
                failed.push((name.to_string(), e));
            }
        }
    }

    println!("\n=== SUMMARY ===");
    println!("Passed: {}/{}", passed, paths.len());
    if !failed.is_empty() {
        println!("Failed:");
        for (name, err) in &failed {
            println!("  {name}: {err}");
        }
        panic!("{} example file(s) failed to load", failed.len());
    }
}
