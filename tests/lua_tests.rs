// File: tests/lua_tests.rs

use std::cell::RefCell;
use std::path::Path;
use std::path::PathBuf;
use std::rc::Rc;
use std::sync::{Condvar, Mutex, OnceLock};
use std::time::Instant;

use lurek2d::lua_api::{create_lua_vm, SharedState};
use lurek2d::runtime::config::Config;
use lurek2d::runtime::RuntimeMode;

fn create_test_vm() -> mlua::Lua {
    let mut shared = SharedState::new(800, 600, "Test", PathBuf::from("."));
    shared.runtime_mode = RuntimeMode::Headless;
    let state = Rc::new(RefCell::new(shared));
    state.borrow_mut().load_default_fonts();
    let lua = create_lua_vm(state, &Config::default().modules).expect("Failed to create Lua VM");

    // Pure-Lua libraries live in the adjacent content repository and expose
    // names such as `library.combat`. Add the repository root so Lua replaces
    // `?` with `library/combat` instead of duplicating the `library` segment.
    lua.load(
        r#"package.path = "./lurek_2d_content/?.lua;./lurek_2d_content/?/init.lua;" .. package.path"#,
    )
    .set_name("content_library_package_path")
    .exec()
    .expect("Failed to configure content library package path");

    // On Windows `os.clock()` is process-wide CPU time, so parallel Rust tests
    // inflate Lua stress measurements with unrelated work. Supply every VM with
    // an independent monotonic wall clock for attributable stress timing.
    let clock_started = Instant::now();
    let monotonic_seconds = lua
        .create_function(move |_, ()| Ok(clock_started.elapsed().as_secs_f64()))
        .expect("Failed to create monotonic test clock");
    lua.globals()
        .set("_test_monotonic_seconds", monotonic_seconds)
        .expect("Failed to register monotonic test clock");
    let os_clock_started = clock_started;
    let os_clock = lua
        .create_function(move |_, ()| Ok(os_clock_started.elapsed().as_secs_f64()))
        .expect("Failed to create monotonic os.clock replacement");
    {
        let os: mlua::Table = lua.globals().get("os").expect("Missing os table");
        os.set("clock", os_clock)
            .expect("Failed to register monotonic os.clock replacement");
    }

    // Expose a safe read-only file helper for static-analysis tests.
    // The sandbox removes io.open; this restores read-only access to workspace files.
    let read_file_fn = lua
        .create_function(|_, path: String| match std::fs::read_to_string(&path) {
            Ok(s) => Ok(Some(s)),
            Err(_) => Ok(None),
        })
        .expect("Failed to create read_file helper");
    lua.globals()
        .set("read_file", read_file_fn)
        .expect("Failed to register read_file");

    // Expose a write-only file helper for test evidence/reports to bypass GameFS save restriction.
    let write_file_fn = lua
        .create_function(|_, (path, data): (String, String)| {
            if let Some(parent) = Path::new(&path).parent() {
                let _ = std::fs::create_dir_all(parent);
            }
            std::fs::write(&path, &data).map_err(mlua::Error::external)
        })
        .expect("Failed to create write_file helper");
    lua.globals()
        .set("write_file", write_file_fn)
        .expect("Failed to register write_file");

    // Some Lua tests load shared helpers via dofile().
    // The sandbox does not expose it by default, so provide a local test-only implementation.
    let dofile_fn = lua
        .create_function(|lua, path: String| {
            let code = std::fs::read_to_string(&path).map_err(mlua::Error::external)?;
            lua.load(&code)
                .set_name(&path)
                .exec()
                .map_err(mlua::Error::external)?;
            Ok(())
        })
        .expect("Failed to create dofile helper");
    lua.globals()
        .set("dofile", dofile_fn)
        .expect("Failed to register dofile");

    // Load test framework
    let framework = include_str!("lua/init.lua");
    lua.load(framework)
        .set_name("test_framework")
        .exec()
        .expect("Failed to load test framework");

    // Backward-compat helper for legacy tests that expect `local T = ...`.
    lua.load(
        r#"
        _legacy_test_api = {
            group = describe,
            test = it,
            assert_equal = function(actual, expected, msg)
                return expect_equal(expected, actual, msg)
            end,
            assert_near = function(actual, expected, tol, msg)
                return expect_near(expected, actual, tol, msg)
            end,
            assert_true = expect_true,
            assert_false = expect_false,
            assert_nil = expect_nil,
            assert_not_nil = expect_not_nil,
            assert_error = expect_error,
            assert_no_error = expect_no_error,
        }
        "#,
    )
    .set_name("legacy_test_api")
    .exec()
    .expect("Failed to register legacy test API");

    lua
}

fn run_lua_test(filename: &str) {
    let rooted = format!("tests/lua/{}", filename);
    run_lua_test_at_path(filename, &rooted);
}

fn run_lua_golden_test(filename: &str, prerequisites: &[&str]) {
    if needs_lua_test_lock(filename) {
        with_lua_test_lock(filename, || {
            for prerequisite in prerequisites {
                let rooted = format!("tests/lua/{}", prerequisite);
                run_lua_test_at_path_unlocked(prerequisite, &rooted);
            }
            let rooted = format!("tests/lua/{}", filename);
            run_lua_test_at_path_unlocked(filename, &rooted);
        });
        return;
    }

    for prerequisite in prerequisites {
        run_lua_test(prerequisite);
    }
    run_lua_test(filename);
}

fn run_lua_workspace_test(path: &str) {
    run_lua_test_at_path(path, path);
}

fn run_lua_test_at_path(display_name: &str, file_path: &str) {
    with_lua_test_lock(display_name, || {
        run_lua_test_at_path_unlocked(display_name, file_path)
    });
}

#[derive(Default)]
struct LuaPerformanceGateState {
    readers: usize,
    waiting_writers: usize,
    writer_active: bool,
}

struct LuaPerformanceGateGuard {
    gate: &'static (Mutex<LuaPerformanceGateState>, Condvar),
    exclusive: bool,
}

impl Drop for LuaPerformanceGateGuard {
    fn drop(&mut self) {
        let (state, wake) = self.gate;
        let mut state = state
            .lock()
            .unwrap_or_else(|poisoned| poisoned.into_inner());
        if self.exclusive {
            state.writer_active = false;
        } else {
            state.readers = state.readers.saturating_sub(1);
        }
        wake.notify_all();
    }
}

fn acquire_lua_performance_slot(exclusive: bool) -> LuaPerformanceGateGuard {
    static LUA_PERFORMANCE_GATE: OnceLock<(Mutex<LuaPerformanceGateState>, Condvar)> =
        OnceLock::new();
    let gate = LUA_PERFORMANCE_GATE.get_or_init(|| {
        (
            Mutex::new(LuaPerformanceGateState::default()),
            Condvar::new(),
        )
    });
    let (state, wake) = gate;
    let mut state = state
        .lock()
        .unwrap_or_else(|poisoned| poisoned.into_inner());
    if exclusive {
        state.waiting_writers += 1;
        while state.readers != 0 || state.writer_active {
            state = wake
                .wait(state)
                .unwrap_or_else(|poisoned| poisoned.into_inner());
        }
        state.waiting_writers -= 1;
        state.writer_active = true;
    } else {
        while state.writer_active || state.waiting_writers != 0 {
            state = wake
                .wait(state)
                .unwrap_or_else(|poisoned| poisoned.into_inner());
        }
        state.readers += 1;
    }
    drop(state);
    LuaPerformanceGateGuard { gate, exclusive }
}

fn with_lua_test_lock<T>(display_name: &str, run: impl FnOnce() -> T) -> T {
    let _performance_guard =
        acquire_lua_performance_slot(needs_exclusive_lua_performance_slot(display_name));

    with_lua_state_lock(display_name, run)
}

fn with_lua_state_lock<T>(display_name: &str, run: impl FnOnce() -> T) -> T {
    if !needs_lua_test_lock(display_name) {
        return run();
    }

    static LUA_TEST_LOCK: OnceLock<Mutex<()>> = OnceLock::new();
    let lock = LUA_TEST_LOCK.get_or_init(|| Mutex::new(()));
    let _guard = lock.lock().unwrap_or_else(|poisoned| poisoned.into_inner());
    run()
}

fn needs_exclusive_lua_performance_slot(display_name: &str) -> bool {
    // Stress and complete-game scenarios enforce elapsed-time ceilings. Let their
    // measured workload own the CPU instead of competing with unrelated Lua VMs.
    display_name.starts_with("stress/") || display_name.starts_with("lurek_2d_content/games/")
}

fn needs_lua_test_lock(display_name: &str) -> bool {
    const ASYNC_PATHFIND_TESTS: &[&str] = &[
        "unit/test_ai_unit.lua",
        "unit/test_pathfind_unit.lua",
        "stress/test_ai_stress.lua",
        "stress/test_pathfind_stress.lua",
    ];
    // The async pathfinding pool is process-wide, so these tests cannot consume
    // completion events concurrently without stealing each other's results.
    // Province evidence and golden tests also share one output directory.
    ASYNC_PATHFIND_TESTS.contains(&display_name) || display_name.contains("province")
}

fn run_lua_test_at_path_unlocked(display_name: &str, file_path: &str) {
    let start = Instant::now();
    let lua = create_test_vm();

    let code = std::fs::read_to_string(file_path)
        .unwrap_or_else(|e| panic!("Failed to read {}: {}", display_name, e));

    let legacy_test_api: mlua::Table = lua
        .globals()
        .get("_legacy_test_api")
        .expect("Missing _legacy_test_api global");

    lua.load(&code)
        .set_name(display_name)
        .call::<_, ()>(legacy_test_api)
        .unwrap_or_else(|e| panic!("Lua error in {}: {}", display_name, e));

    // Collect results from _test_results global
    let results: mlua::Table = lua
        .globals()
        .get("_test_results")
        .expect("Missing _test_results global");

    let total: i64 = results.get("total").unwrap_or(0);
    let passed: i64 = results.get("passed").unwrap_or(0);
    let failed: i64 = results.get("failed").unwrap_or(0);
    let skipped: i64 = results.get("skipped").unwrap_or(0);

    let elapsed = start.elapsed();

    // Print structured result line (parseable by parse_test_log.py)
    println!(
        "{}: {}/{} passed, {} failed, {} skipped [{:.2}s]",
        display_name,
        passed,
        total,
        failed,
        skipped,
        elapsed.as_secs_f64()
    );

    // Print all failures with FAIL: prefix (parseable by parse_test_log.py)
    if failed > 0 {
        if let Ok(errors) = results.get::<_, mlua::Table>("errors") {
            for (_, err_tbl) in errors.pairs::<i64, mlua::Table>().flatten() {
                let suite: String = err_tbl.get("suite").unwrap_or_default();
                let test: String = err_tbl.get("test").unwrap_or_default();
                let error: String = err_tbl.get("error").unwrap_or_default();
                eprintln!("  FAIL: [{}] {} - {}", suite, test, error);
            }
        }
    }

    assert_eq!(failed, 0, "{} Lua tests failed in {}", failed, display_name);
    assert!(
        total > 0 || skipped > 0,
        "No tests were run in {}",
        display_name
    );
}

fn collect_colocated_game_tests(dir: &Path, out: &mut Vec<PathBuf>) {
    let Ok(entries) = std::fs::read_dir(dir) else {
        return;
    };

    for entry in entries.filter_map(|e| e.ok()) {
        let path = entry.path();
        if path.is_dir() {
            collect_colocated_game_tests(&path, out);
        } else if path.file_name().map(|n| n == "test.lua").unwrap_or(false) {
            out.push(path);
        }
    }
}

// === lurek.log tests ===// === lurek.render.newShape / CompoundShape tests ===
// === Stress Tests ===
// === lurek.ui tests ===
// === Validation Tests ===

// === Cross-Module Integration Tests ===

// Generated reorganized Lua test registrations.

#[test]
fn lua_config_runtime_config() {
    run_lua_test("config/test_runtime_config.lua");
}

#[test]
fn lua_evidence_ai_evidence() {
    run_lua_test("evidence/test_ai_evidence.lua");
}

#[test]
fn lua_evidence_animation_evidence() {
    run_lua_test("evidence/test_animation_evidence.lua");
}

#[test]
fn lua_evidence_agent_evidence() {
    run_lua_test("evidence/test_agent_evidence.lua");
}

#[test]
fn lua_evidence_awareness_evidence() {
    run_lua_test("evidence/test_awareness_evidence.lua");
}

#[test]
fn lua_evidence_automation_evidence() {
    run_lua_test("evidence/test_automation_evidence.lua");
}

#[test]
fn lua_evidence_audio_evidence() {
    run_lua_test("evidence/test_audio_evidence.lua");
}

#[test]
fn lua_evidence_binary_evidence() {
    run_lua_test("evidence/test_binary_evidence.lua");
}

#[test]
fn lua_evidence_color_evidence() {
    run_lua_test("evidence/test_color_evidence.lua");
}

#[test]
fn lua_evidence_camera_evidence() {
    run_lua_test("evidence/test_camera_evidence.lua");
}

#[test]
fn lua_evidence_charts_evidence() {
    run_lua_test("evidence/test_charts_evidence.lua");
}

#[test]
fn lua_evidence_cinematic_evidence() {
    run_lua_test("evidence/test_cinematic_evidence.lua");
}

#[test]
fn lua_evidence_compute_evidence() {
    run_lua_test("evidence/test_compute_evidence.lua");
}

#[test]
fn lua_evidence_dsp_evidence() {
    run_lua_test("evidence/test_dsp_evidence.lua");
}

#[test]
fn lua_evidence_dataframe_evidence() {
    run_lua_test("evidence/test_dataframe_evidence.lua");
}

#[test]
fn lua_evidence_ecs_evidence() {
    run_lua_test("evidence/test_ecs_evidence.lua");
}

#[test]
fn lua_evidence_effect_evidence() {
    run_lua_test("evidence/test_effect_evidence.lua");
}

#[test]
fn lua_evidence_globe_evidence() {
    run_lua_test("evidence/test_globe_evidence.lua");
}

#[test]
fn lua_evidence_image_evidence() {
    run_lua_test("evidence/test_image_evidence.lua");
}

#[test]
fn lua_evidence_flownet_evidence() {
    run_lua_test("evidence/test_flownet_evidence.lua");
}

#[test]
fn lua_evidence_layout_evidence() {
    run_lua_test("evidence/test_layout_evidence.lua");
}

#[test]
fn lua_evidence_light_evidence() {
    run_lua_test("evidence/test_light_evidence.lua");
}

#[test]
fn lua_evidence_math_evidence() {
    run_lua_test("evidence/test_math_evidence.lua");
}

#[test]
fn lua_evidence_mapblock_evidence() {
    run_lua_test("evidence/test_mapblock_evidence.lua");
}

#[test]
fn lua_evidence_minimap_evidence() {
    run_lua_test("evidence/test_minimap_evidence.lua");
}

#[test]
fn lua_evidence_particle_evidence() {
    run_lua_test("evidence/test_particle_evidence.lua");
}

#[test]
fn lua_evidence_parallax_evidence() {
    run_lua_test("evidence/test_parallax_evidence.lua");
}

#[test]
fn lua_evidence_overlay_evidence() {
    run_lua_test("evidence/test_overlay_evidence.lua");
}

#[test]
fn lua_evidence_province_evidence() {
    run_lua_test("evidence/test_province_evidence.lua");
}

#[test]
fn lua_evidence_pathfind_evidence() {
    run_lua_test("evidence/test_pathfind_evidence.lua");
}

#[test]
fn lua_evidence_p0_isolation_evidence() {
    run_lua_test("evidence/test_p0_isolation_evidence.lua");
}

#[test]
fn lua_evidence_physics_evidence() {
    run_lua_test("evidence/test_physics_evidence.lua");
}

#[test]
fn lua_evidence_procgen_evidence() {
    run_lua_test("evidence/test_procgen_evidence.lua");
}

#[test]
fn lua_evidence_progression_evidence() {
    run_lua_test("evidence/test_progression_evidence.lua");
}

#[test]
fn lua_evidence_raycaster_evidence() {
    run_lua_test("evidence/test_raycaster_evidence.lua");
}

#[test]
fn lua_evidence_repl_evidence() {
    run_lua_test("evidence/test_repl_evidence.lua");
}

#[test]
fn lua_evidence_render_evidence() {
    run_lua_test("evidence/test_render_evidence.lua");
}

#[test]
fn lua_evidence_scene_evidence() {
    run_lua_test("evidence/test_scene_evidence.lua");
}

#[test]
fn lua_evidence_render_shader_evidence() {
    run_lua_test("evidence/test_render_shader_evidence.lua");
}

#[test]
fn lua_evidence_spine_evidence() {
    run_lua_test("evidence/test_spine_evidence.lua");
}

#[test]
fn lua_evidence_sprite_evidence() {
    run_lua_test("evidence/test_sprite_evidence.lua");
}

#[test]
fn lua_evidence_svg_evidence() {
    run_lua_test("evidence/test_svg_evidence.lua");
}

#[test]
fn lua_evidence_tilemap_evidence() {
    run_lua_test("evidence/test_tilemap_evidence.lua");
}

#[test]
fn lua_evidence_tilefield_evidence() {
    run_lua_test("evidence/test_tilefield_evidence.lua");
}

#[test]
fn lua_evidence_tilelight_evidence() {
    run_lua_test("evidence/test_tilelight_evidence.lua");
}

#[test]
fn lua_evidence_terminal_evidence() {
    run_lua_test("evidence/test_terminal_evidence.lua");
}

#[test]
fn lua_evidence_tween_evidence() {
    run_lua_test("evidence/test_tween_evidence.lua");
}

#[test]
fn lua_evidence_ui_evidence() {
    run_lua_test("evidence/test_ui_evidence.lua");
}

#[test]
fn lua_golden_ai_golden() {
    run_lua_golden_test(
        "golden/test_ai_golden.lua",
        &["evidence/test_ai_evidence.lua"],
    );
}

#[test]
fn lua_golden_animation_golden() {
    run_lua_golden_test(
        "golden/test_animation_golden.lua",
        &["evidence/test_animation_evidence.lua"],
    );
}

#[test]
fn lua_golden_agent_golden() {
    run_lua_golden_test(
        "golden/test_agent_golden.lua",
        &["evidence/test_agent_evidence.lua"],
    );
}

#[test]
fn lua_golden_awareness_golden() {
    run_lua_golden_test(
        "golden/test_awareness_golden.lua",
        &["evidence/test_awareness_evidence.lua"],
    );
}

#[test]
fn lua_golden_automation_golden() {
    run_lua_golden_test(
        "golden/test_automation_golden.lua",
        &["evidence/test_automation_evidence.lua"],
    );
}

#[test]
fn lua_golden_audio_golden() {
    run_lua_golden_test(
        "golden/test_audio_golden.lua",
        &["evidence/test_audio_evidence.lua"],
    );
}

#[test]
fn lua_golden_binary_golden() {
    run_lua_golden_test(
        "golden/test_binary_golden.lua",
        &["evidence/test_binary_evidence.lua"],
    );
}

#[test]
fn lua_golden_camera_golden() {
    run_lua_golden_test(
        "golden/test_camera_golden.lua",
        &["evidence/test_camera_evidence.lua"],
    );
}

#[test]
fn lua_golden_charts_golden() {
    run_lua_golden_test(
        "golden/test_charts_golden.lua",
        &["evidence/test_charts_evidence.lua"],
    );
}

#[test]
fn lua_golden_cinematic_golden() {
    run_lua_golden_test(
        "golden/test_cinematic_golden.lua",
        &["evidence/test_cinematic_evidence.lua"],
    );
}

#[test]
fn lua_golden_color_golden() {
    run_lua_golden_test(
        "golden/test_color_golden.lua",
        &["evidence/test_color_evidence.lua"],
    );
}

#[test]
fn lua_golden_compute_golden() {
    run_lua_golden_test(
        "golden/test_compute_golden.lua",
        &["evidence/test_compute_evidence.lua"],
    );
}

#[test]
fn lua_golden_dataframe_golden() {
    run_lua_golden_test(
        "golden/test_dataframe_golden.lua",
        &["evidence/test_dataframe_evidence.lua"],
    );
}

#[test]
fn lua_golden_ecs_golden() {
    run_lua_golden_test(
        "golden/test_ecs_golden.lua",
        &["evidence/test_ecs_evidence.lua"],
    );
}

#[test]
fn lua_golden_dsp_golden() {
    run_lua_golden_test(
        "golden/test_dsp_golden.lua",
        &["evidence/test_dsp_evidence.lua"],
    );
}

#[test]
fn lua_golden_effect_golden() {
    run_lua_golden_test(
        "golden/test_effect_golden.lua",
        &["evidence/test_effect_evidence.lua"],
    );
}

#[test]
fn lua_golden_globe_golden() {
    run_lua_golden_test(
        "golden/test_globe_golden.lua",
        &["evidence/test_globe_evidence.lua"],
    );
}

#[test]
fn lua_golden_image_golden() {
    run_lua_golden_test(
        "golden/test_image_golden.lua",
        &["evidence/test_image_evidence.lua"],
    );
}

#[test]
fn lua_golden_flownet_golden() {
    run_lua_golden_test(
        "golden/test_flownet_golden.lua",
        &["evidence/test_flownet_evidence.lua"],
    );
}

#[test]
fn lua_golden_layout_golden() {
    run_lua_golden_test(
        "golden/test_layout_golden.lua",
        &["evidence/test_layout_evidence.lua"],
    );
}

#[test]
fn lua_golden_light_golden() {
    run_lua_golden_test(
        "golden/test_light_golden.lua",
        &["evidence/test_light_evidence.lua"],
    );
}

#[test]
fn lua_golden_math_golden() {
    run_lua_golden_test(
        "golden/test_math_golden.lua",
        &["evidence/test_math_evidence.lua"],
    );
}

#[test]
fn lua_golden_mapblock_golden() {
    run_lua_golden_test(
        "golden/test_mapblock_golden.lua",
        &["evidence/test_mapblock_evidence.lua"],
    );
}

#[test]
fn lua_golden_minimap_golden() {
    run_lua_golden_test(
        "golden/test_minimap_golden.lua",
        &["evidence/test_minimap_evidence.lua"],
    );
}

#[test]
fn lua_golden_overlay_golden() {
    run_lua_golden_test(
        "golden/test_overlay_golden.lua",
        &["evidence/test_overlay_evidence.lua"],
    );
}

#[test]
fn lua_golden_particle_golden() {
    run_lua_golden_test(
        "golden/test_particle_golden.lua",
        &["evidence/test_particle_evidence.lua"],
    );
}

#[test]
fn lua_golden_parallax_golden() {
    run_lua_golden_test(
        "golden/test_parallax_golden.lua",
        &["evidence/test_parallax_evidence.lua"],
    );
}

#[test]
fn lua_golden_pathfind_golden() {
    run_lua_golden_test(
        "golden/test_pathfind_golden.lua",
        &["evidence/test_pathfind_evidence.lua"],
    );
}

#[test]
fn lua_golden_physics_golden() {
    run_lua_golden_test(
        "golden/test_physics_golden.lua",
        &["evidence/test_physics_evidence.lua"],
    );
}

#[test]
fn lua_golden_procgen_golden() {
    run_lua_golden_test(
        "golden/test_procgen_golden.lua",
        &["evidence/test_procgen_evidence.lua"],
    );
}

#[test]
fn lua_golden_province_golden() {
    run_lua_golden_test(
        "golden/test_province_golden.lua",
        &["evidence/test_province_evidence.lua"],
    );
}

#[test]
fn lua_golden_raycaster_golden() {
    run_lua_golden_test(
        "golden/test_raycaster_golden.lua",
        &["evidence/test_raycaster_evidence.lua"],
    );
}

#[test]
fn lua_golden_repl_golden() {
    run_lua_golden_test(
        "golden/test_repl_golden.lua",
        &["evidence/test_repl_evidence.lua"],
    );
}

#[test]
fn lua_golden_render_golden() {
    run_lua_golden_test(
        "golden/test_render_golden.lua",
        &["evidence/test_render_evidence.lua"],
    );
}

#[test]
fn lua_golden_scene_golden() {
    run_lua_golden_test(
        "golden/test_scene_golden.lua",
        &["evidence/test_scene_evidence.lua"],
    );
}

#[test]
fn lua_golden_serialize_golden() {
    run_lua_golden_test(
        "golden/test_serialize_golden.lua",
        &["evidence/test_binary_evidence.lua"],
    );
}

#[test]
fn lua_golden_spine_golden() {
    run_lua_golden_test(
        "golden/test_spine_golden.lua",
        &["evidence/test_spine_evidence.lua"],
    );
}

#[test]
fn lua_golden_sprite_golden() {
    run_lua_golden_test(
        "golden/test_sprite_golden.lua",
        &["evidence/test_sprite_evidence.lua"],
    );
}

#[test]
fn lua_golden_svg_golden() {
    run_lua_golden_test(
        "golden/test_svg_golden.lua",
        &["evidence/test_svg_evidence.lua"],
    );
}

#[test]
fn lua_golden_tilemap_golden() {
    run_lua_golden_test(
        "golden/test_tilemap_golden.lua",
        &["evidence/test_tilemap_evidence.lua"],
    );
}

#[test]
fn lua_golden_tilefield_golden() {
    run_lua_golden_test(
        "golden/test_tilefield_golden.lua",
        &["evidence/test_tilefield_evidence.lua"],
    );
}

#[test]
fn lua_golden_tilelight_golden() {
    run_lua_golden_test(
        "golden/test_tilelight_golden.lua",
        &["evidence/test_tilelight_evidence.lua"],
    );
}

#[test]
fn lua_golden_terminal_golden() {
    run_lua_golden_test(
        "golden/test_terminal_golden.lua",
        &["evidence/test_terminal_evidence.lua"],
    );
}

#[test]
fn lua_golden_tween_golden() {
    run_lua_golden_test(
        "golden/test_tween_golden.lua",
        &["evidence/test_tween_evidence.lua"],
    );
}

#[test]
fn lua_golden_ui_golden() {
    run_lua_golden_test(
        "golden/test_ui_golden.lua",
        &["evidence/test_ui_evidence.lua"],
    );
}

#[test]
fn lua_integration_ai_ecs_scene_integration() {
    run_lua_test("integration/test_ai_ecs_scene_integration.lua");
}

#[test]
fn lua_integration_ai_pathfind_integration() {
    run_lua_test("integration/test_ai_pathfind_integration.lua");
}

#[test]
fn lua_integration_ai_physics_integration() {
    run_lua_test("integration/test_ai_physics_integration.lua");
}

#[test]
fn lua_integration_ai_scene_camera_integration() {
    run_lua_test("integration/test_ai_scene_camera_integration.lua");
}

#[test]
fn lua_integration_animation_tween_integration() {
    run_lua_test("integration/test_animation_tween_integration.lua");
}

#[test]
fn lua_integration_sprite_image_integration() {
    run_lua_test("integration/test_sprite_image_integration.lua");
}

#[test]
fn lua_integration_audio_event_integration() {
    run_lua_test("integration/test_audio_event_integration.lua");
}

#[test]
fn lua_integration_audio_scene_integration() {
    run_lua_test("integration/test_audio_scene_integration.lua");
}

#[test]
fn lua_integration_automation_event_integration() {
    run_lua_test("integration/test_automation_event_integration.lua");
}

#[test]
fn lua_integration_binary_compute_integration() {
    run_lua_test("integration/test_binary_compute_integration.lua");
}

#[test]
fn lua_integration_binary_filesystem_integration() {
    run_lua_test("integration/test_binary_filesystem_integration.lua");
}

#[test]
fn lua_integration_compute_dataframe_integration() {
    run_lua_test("integration/test_compute_dataframe_integration.lua");
}

#[test]
fn lua_integration_ecs_ai_integration() {
    run_lua_test("integration/test_ecs_ai_integration.lua");
}

#[test]
fn lua_integration_ecs_scene_object_model_integration() {
    run_lua_test("integration/test_ecs_scene_object_model_integration.lua");
}

#[test]
fn lua_integration_ecs_physics_integration() {
    run_lua_test("integration/test_ecs_physics_integration.lua");
}

#[test]
fn lua_integration_ecs_render_integration() {
    run_lua_test("integration/test_ecs_render_integration.lua");
}

#[test]
fn lua_integration_effect_camera_integration() {
    run_lua_test("integration/test_effect_camera_integration.lua");
}

#[test]
fn lua_integration_effect_light_integration() {
    run_lua_test("integration/test_effect_light_integration.lua");
}

#[test]
fn lua_integration_tilefield_light_integration() {
    run_lua_test("integration/test_tilefield_light_integration.lua");
}

#[test]
fn lua_integration_tilefield_physics_integration() {
    run_lua_test("integration/test_tilefield_physics_integration.lua");
}

#[test]
fn lua_integration_event_entity_integration() {
    run_lua_test("integration/test_event_entity_integration.lua");
}

#[test]
fn lua_integration_ecs_progression_integration() {
    run_lua_test("integration/test_ecs_progression_integration.lua");
}

#[test]
fn lua_integration_i18n_ui_integration() {
    run_lua_test("integration/test_i18n_ui_integration.lua");
}

#[test]
fn lua_integration_image_dataframe_integration() {
    run_lua_test("integration/test_image_dataframe_integration.lua");
}

#[test]
fn lua_integration_image_physics_integration() {
    run_lua_test("integration/test_image_physics_integration.lua");
}

#[test]
fn lua_integration_factory_dataflow_integration() {
    run_lua_test("integration/test_factory_dataflow_integration.lua");
}

#[test]
fn lua_integration_math_pathfind_integration() {
    run_lua_test("integration/test_math_pathfind_integration.lua");
}

#[test]
fn lua_integration_math_physics_integration() {
    run_lua_test("integration/test_math_physics_integration.lua");
}

#[test]
fn lua_integration_minimap_pathfind_integration() {
    run_lua_test("integration/test_minimap_pathfind_integration.lua");
}

#[test]
fn lua_integration_minimap_tilemap_camera_integration() {
    run_lua_test("integration/test_minimap_tilemap_camera_integration.lua");
}

#[test]
fn lua_integration_mods_filesystem_integration() {
    run_lua_test("integration/test_mods_filesystem_integration.lua");
}

#[test]
fn lua_integration_network_save_integration() {
    run_lua_test("integration/test_network_save_integration.lua");
}

#[test]
fn lua_integration_parallax_camera_integration() {
    run_lua_test("integration/test_parallax_camera_integration.lua");
}

#[test]
fn lua_integration_particle_timer_integration() {
    run_lua_test("integration/test_particle_timer_integration.lua");
}

#[test]
fn lua_integration_shooter_helpers_integration() {
    run_lua_test("integration/test_shooter_helpers_integration.lua");
}

#[test]
fn lua_integration_pathfind_ecs_integration() {
    run_lua_test("integration/test_pathfind_ecs_integration.lua");
}

#[test]
fn lua_integration_pathfind_graph_integration() {
    run_lua_test("integration/test_pathfind_graph_integration.lua");
}

#[test]
fn lua_integration_postfx_camera_integration() {
    run_lua_test("integration/test_postfx_camera_integration.lua");
}

#[test]
fn lua_integration_procgen_tilemap_integration() {
    run_lua_test("integration/test_procgen_tilemap_integration.lua");
}

#[test]
fn lua_integration_raycaster_render_integration() {
    run_lua_test("integration/test_raycaster_render_integration.lua");
}

#[test]
fn lua_integration_raycaster_tilemap_integration() {
    run_lua_test("integration/test_raycaster_tilemap_integration.lua");
}

#[test]
fn lua_integration_render_animation_integration() {
    run_lua_test("integration/test_render_animation_integration.lua");
}

#[test]
fn lua_integration_svg_animation_integration() {
    run_lua_test("integration/test_svg_animation_integration.lua");
}

#[test]
fn lua_integration_render_camera_integration() {
    run_lua_test("integration/test_render_camera_integration.lua");
}

#[test]
fn lua_integration_save_ecs_integration() {
    run_lua_test("integration/test_save_ecs_integration.lua");
}

#[test]
fn lua_integration_save_ecs_scene_integration() {
    run_lua_test("integration/test_save_ecs_scene_integration.lua");
}

#[test]
fn lua_integration_save_tilemap_integration() {
    run_lua_test("integration/test_save_tilemap_integration.lua");
}

#[test]
fn lua_integration_scene_camera_integration() {
    run_lua_test("integration/test_scene_camera_integration.lua");
}

#[test]
fn lua_integration_scene_physics_activation_integration() {
    run_lua_test("integration/test_scene_physics_activation_integration.lua");
}

#[test]
fn lua_integration_serialize_filesystem_integration() {
    run_lua_test("integration/test_serialize_filesystem_integration.lua");
}

#[test]
fn lua_integration_terminal_input_integration() {
    run_lua_test("integration/test_terminal_input_integration.lua");
}

#[test]
fn lua_integration_thread_data_integration() {
    run_lua_test("integration/test_thread_data_integration.lua");
}

#[test]
fn lua_integration_tilemap_camera_integration() {
    run_lua_test("integration/test_tilemap_camera_integration.lua");
}

#[test]
fn lua_integration_tilemap_pathfind_integration() {
    run_lua_test("integration/test_tilemap_pathfind_integration.lua");
}

#[test]
fn lua_integration_tilefield_pathfind_integration() {
    run_lua_test("integration/test_tilefield_pathfind_integration.lua");
}

#[test]
fn lua_integration_tilefield_awareness_integration() {
    run_lua_test("integration/test_tilefield_awareness_integration.lua");
}

#[test]
fn lua_integration_tilefield_raycaster_integration() {
    run_lua_test("integration/test_tilefield_raycaster_integration.lua");
}

#[test]
fn lua_integration_minimap_tilefield_integration() {
    run_lua_test("integration/test_minimap_tilefield_integration.lua");
}

#[test]
fn lua_integration_tilefield_systems_integration() {
    run_lua_test("integration/test_tilefield_systems_integration.lua");
}

#[test]
fn lua_integration_procgen_tilefield_integration() {
    run_lua_test("integration/test_procgen_tilefield_integration.lua");
}

#[test]
fn lua_integration_tilemap_physics_integration() {
    run_lua_test("integration/test_tilemap_physics_integration.lua");
}

#[test]
fn lua_integration_timer_event_integration() {
    run_lua_test("integration/test_timer_event_integration.lua");
}

#[test]
fn lua_integration_timer_math_integration() {
    run_lua_test("integration/test_timer_math_integration.lua");
}

#[test]
fn lua_integration_tween_camera_integration() {
    run_lua_test("integration/test_tween_camera_integration.lua");
}

#[test]
fn lua_integration_tween_ecs_integration() {
    run_lua_test("integration/test_tween_ecs_integration.lua");
}

#[test]
fn lua_integration_ui_localization_data_integration() {
    run_lua_test("integration/test_ui_localization_data_integration.lua");
}

#[test]
fn lua_integration_ui_render_integration() {
    run_lua_test("integration/test_ui_render_integration.lua");
}

#[test]
fn lua_integration_workbench_particle_integration() {
    run_lua_test("integration/test_workbench_particle_integration.lua");
}

#[test]
fn lua_integration_workbench_tilemap_integration() {
    run_lua_test("integration/test_workbench_tilemap_integration.lua");
}

#[test]
fn lua_integration_workbench_asset_creation_integration() {
    run_lua_test("integration/test_workbench_asset_creation_integration.lua");
}

#[test]
fn lua_library_battle_library() {
    run_lua_test("library/test_battle_library.lua");
}

#[test]
fn lua_library_combat_library() {
    run_lua_test("library/test_combat_library.lua");
}

#[test]
fn lua_library_crafting_library() {
    run_lua_test("library/test_crafting_library.lua");
}

#[test]
fn lua_library_doll_library() {
    run_lua_test("library/test_doll_library.lua");
}

#[test]
fn lua_library_economy_library() {
    run_lua_test("library/test_economy_library.lua");
}

#[test]
fn lua_library_inventory_library() {
    run_lua_test("library/test_inventory_library.lua");
}

#[test]
fn lua_library_item_library() {
    run_lua_test("library/test_item_library.lua");
}

#[test]
fn lua_library_loot_library() {
    run_lua_test("library/test_loot_library.lua");
}

#[test]
fn lua_library_roguelike_library() {
    run_lua_test("library/test_roguelike_library.lua");
}

#[test]
fn lua_security_filesystem_security() {
    run_lua_test("security/test_filesystem_security.lua");
}

#[test]
fn lua_security_image_security() {
    run_lua_test("security/test_image_security.lua");
}

#[test]
fn lua_security_network_security() {
    run_lua_test("security/test_network_security.lua");
}

#[test]
fn lua_security_render_security() {
    run_lua_test("security/test_render_security.lua");
}

#[test]
fn lua_security_runtime_security() {
    run_lua_test("security/test_runtime_security.lua");
}

#[test]
fn lua_security_save_security() {
    run_lua_test("security/test_save_security.lua");
}

#[test]
fn lua_security_tilefield_security() {
    run_lua_test("security/test_tilefield_security.lua");
}

#[test]
fn lua_security_tilelight_security() {
    run_lua_test("security/test_tilelight_security.lua");
}

#[test]
fn lua_security_light_security() {
    run_lua_test("security/test_light_security.lua");
}

#[test]
fn lua_security_physics_security() {
    run_lua_test("security/test_physics_security.lua");
}

#[test]
fn lua_security_tilemap_security() {
    run_lua_test("security/test_tilemap_security.lua");
}

#[test]
fn lua_security_tileset_security() {
    run_lua_test("security/test_tileset_security.lua");
}

#[test]
fn lua_security_sprite_security() {
    run_lua_test("security/test_sprite_security.lua");
}

#[test]
fn lua_security_ui_security() {
    run_lua_test("security/test_ui_security.lua");
}

#[test]
fn lua_security_audio_security() {
    run_lua_test("security/test_audio_security.lua");
}

#[test]
fn lua_security_procgen_security() {
    run_lua_test("security/test_procgen_security.lua");
}

#[test]
fn lua_security_progression_security() {
    run_lua_test("security/test_progression_security.lua");
}

#[test]
fn lua_stress_ai_stress() {
    run_lua_test("stress/test_ai_stress.lua");
}

#[test]
fn lua_stress_animation_stress() {
    run_lua_test("stress/test_animation_stress.lua");
}

#[test]
fn lua_stress_audio_stress() {
    run_lua_test("stress/test_audio_stress.lua");
}

#[test]
fn lua_stress_binary_stress() {
    run_lua_test("stress/test_binary_stress.lua");
}

#[test]
fn lua_stress_camera_stress() {
    run_lua_test("stress/test_camera_stress.lua");
}

#[test]
fn lua_stress_compute_stress() {
    run_lua_test("stress/test_compute_stress.lua");
}

#[test]
fn lua_stress_dataframe_stress() {
    run_lua_test("stress/test_dataframe_stress.lua");
}

#[test]
fn lua_stress_ecs_stress() {
    run_lua_test("stress/test_ecs_stress.lua");
}

#[test]
fn lua_stress_event_stress() {
    run_lua_test("stress/test_event_stress.lua");
}

#[test]
fn lua_stress_filesystem_stress() {
    run_lua_test("stress/test_filesystem_stress.lua");
}

#[test]
fn lua_stress_flownet_stress() {
    run_lua_test("stress/test_flownet_stress.lua");
}

#[test]
fn lua_stress_image_stress() {
    run_lua_test("stress/test_image_stress.lua");
}

#[test]
fn lua_stress_input_stress() {
    run_lua_test("stress/test_input_stress.lua");
}

#[test]
fn lua_stress_learning_stress() {
    run_lua_test("stress/test_learning_stress.lua");
}

#[test]
fn lua_stress_light_stress() {
    run_lua_test("stress/test_light_stress.lua");
}

#[test]
fn lua_stress_math_stress() {
    run_lua_test("stress/test_math_stress.lua");
}

#[test]
fn lua_stress_particle_stress() {
    run_lua_test("stress/test_particle_stress.lua");
}

#[test]
fn lua_stress_pathfind_stress() {
    run_lua_test("stress/test_pathfind_stress.lua");
}

#[test]
fn lua_stress_patterns_stress() {
    run_lua_test("stress/test_patterns_stress.lua");
}

#[test]
fn lua_stress_physics_stress() {
    run_lua_test("stress/test_physics_stress.lua");
}

#[test]
fn lua_stress_procgen_stress() {
    run_lua_test("stress/test_procgen_stress.lua");
}

#[test]
fn lua_stress_progression_stress() {
    run_lua_test("stress/test_progression_stress.lua");
}

#[test]
fn lua_stress_raycaster_stress() {
    run_lua_test("stress/test_raycaster_stress.lua");
}

#[test]
fn lua_stress_render_stress() {
    run_lua_test("stress/test_render_stress.lua");
}

#[test]
fn lua_stress_svg_stress() {
    run_lua_test("stress/test_svg_stress.lua");
}

#[test]
fn lua_stress_save_stress() {
    run_lua_test("stress/test_save_stress.lua");
}

#[test]
fn lua_stress_scene_stress() {
    run_lua_test("stress/test_scene_stress.lua");
}

#[test]
fn lua_stress_serialize_stress() {
    run_lua_test("stress/test_serialize_stress.lua");
}

#[test]
fn lua_stress_thread_stress() {
    run_lua_test("stress/test_thread_stress.lua");
}

#[test]
fn lua_stress_tilemap_stress() {
    run_lua_test("stress/test_tilemap_stress.lua");
}

#[test]
fn lua_stress_tileset_stress() {
    run_lua_test("stress/test_tileset_stress.lua");
}

#[test]
fn lua_stress_tilefield_stress() {
    run_lua_test("stress/test_tilefield_stress.lua");
}

#[test]
fn lua_stress_tilelight_stress() {
    run_lua_test("stress/test_tilelight_stress.lua");
}

#[test]
fn lua_stress_timer_stress() {
    run_lua_test("stress/test_timer_stress.lua");
}

#[test]
fn lua_stress_tween_stress() {
    run_lua_test("stress/test_tween_stress.lua");
}

#[test]
fn lua_stress_sprite_stress() {
    run_lua_test("stress/test_sprite_stress.lua");
}

#[test]
fn lua_stress_ui_stress() {
    run_lua_test("stress/test_ui_stress.lua");
}

#[test]
fn lua_unit_agent_unit() {
    run_lua_test("unit/test_agent_unit.lua");
}

#[test]
fn lua_unit_ai_unit() {
    run_lua_test("unit/test_ai_unit.lua");
}

#[test]
fn lua_unit_animation_unit() {
    run_lua_test("unit/test_animation_unit.lua");
}

#[test]
fn lua_unit_asset_unit() {
    run_lua_test("unit/test_asset_unit.lua");
}

#[test]
fn lua_unit_audio_unit() {
    run_lua_test("unit/test_audio_unit.lua");
}

#[test]
fn lua_unit_automation_unit() {
    run_lua_test("unit/test_automation_unit.lua");
}

#[test]
fn lua_unit_beat_clock_unit() {
    run_lua_test("unit/test_beat_clock_unit.lua");
}

#[test]
fn lua_unit_binary_unit() {
    run_lua_test("unit/test_binary_unit.lua");
}

#[test]
fn lua_unit_camera_unit() {
    run_lua_test("unit/test_camera_unit.lua");
}

#[test]
fn lua_unit_charts_unit() {
    run_lua_test("unit/test_charts_unit.lua");
}

#[test]
fn lua_unit_cinematic_unit() {
    run_lua_test("unit/test_cinematic_unit.lua");
}

#[test]
fn lua_unit_collision_unit() {
    run_lua_test("unit/test_collision_unit.lua");
}

#[test]
fn lua_unit_color_unit() {
    run_lua_test("unit/test_color_unit.lua");
}

#[test]
fn lua_unit_compute_unit() {
    run_lua_test("unit/test_compute_unit.lua");
}

#[test]
fn lua_unit_cursor_unit() {
    run_lua_test("unit/test_cursor_unit.lua");
}

#[test]
fn lua_unit_dataframe_unit() {
    run_lua_test("unit/test_dataframe_unit.lua");
}

#[test]
fn lua_unit_debugbridge_unit() {
    run_lua_test("unit/test_debugbridge_unit.lua");
}

#[test]
fn lua_unit_devtools_unit() {
    run_lua_test("unit/test_devtools_unit.lua");
}

#[test]
fn lua_unit_dialog_unit() {
    run_lua_test("unit/test_dialog_unit.lua");
}

#[test]
fn lua_unit_docs_unit() {
    run_lua_test("unit/test_docs_unit.lua");
}

#[test]
fn lua_unit_dsp_unit() {
    run_lua_test("unit/test_dsp_unit.lua");
}

#[test]
fn lua_unit_ecs_unit() {
    run_lua_test("unit/test_ecs_unit.lua");
}

#[test]
fn lua_unit_effect_unit() {
    run_lua_test("unit/test_effect_unit.lua");
}

#[test]
fn lua_unit_engine_unit() {
    run_lua_test("unit/test_engine_unit.lua");
}

#[test]
fn lua_unit_event_unit() {
    run_lua_test("unit/test_event_unit.lua");
}

#[test]
fn lua_unit_filesystem_unit() {
    run_lua_test("unit/test_filesystem_unit.lua");
}

#[test]
fn lua_unit_flownet_unit() {
    run_lua_test("unit/test_flownet_unit.lua");
}

#[test]
fn lua_unit_font_unit() {
    run_lua_test("unit/test_font_unit.lua");
}

#[test]
fn lua_unit_globe_unit() {
    run_lua_test("unit/test_globe_unit.lua");
}

#[test]
fn lua_unit_grep_unit() {
    run_lua_test("unit/test_grep_unit.lua");
}

#[test]
fn lua_unit_i18n_unit() {
    run_lua_test("unit/test_i18n_unit.lua");
}

#[test]
fn lua_unit_image_unit() {
    run_lua_test("unit/test_image_unit.lua");
}

#[test]
fn lua_unit_input_unit() {
    run_lua_test("unit/test_input_unit.lua");
}

#[test]
fn lua_unit_learning_unit() {
    run_lua_test("unit/test_learning_unit.lua");
}

#[test]
fn lua_unit_layout_unit() {
    run_lua_test("unit/test_layout_unit.lua");
}

#[test]
fn lua_unit_light_unit() {
    run_lua_test("unit/test_light_unit.lua");
}

#[test]
fn lua_unit_log_unit() {
    run_lua_test("unit/test_log_unit.lua");
}

#[test]
fn lua_unit_loot_unit() {
    run_lua_test("unit/test_loot_unit.lua");
}

#[test]
fn lua_unit_math_unit() {
    run_lua_test("unit/test_math_unit.lua");
}

#[test]
fn lua_unit_mapblock_unit() {
    run_lua_test("unit/test_mapblock_unit.lua");
}

#[test]
fn lua_unit_minimap_unit() {
    run_lua_test("unit/test_minimap_unit.lua");
}

#[test]
fn lua_unit_mods_unit() {
    run_lua_test("unit/test_mods_unit.lua");
}

#[test]
fn lua_unit_modular_topdown_api_unit() {
    run_lua_test("unit/test_modular_topdown_api_unit.lua");
}

#[test]
fn lua_unit_net_unit() {
    run_lua_test("unit/test_net_unit.lua");
}

#[test]
fn lua_unit_network_unit() {
    run_lua_test("unit/test_network_unit.lua");
}

#[test]
fn lua_unit_overlay_unit() {
    run_lua_test("unit/test_overlay_unit.lua");
}

#[test]
fn lua_unit_parallax_unit() {
    run_lua_test("unit/test_parallax_unit.lua");
}

#[test]
fn lua_unit_particle_unit() {
    run_lua_test("unit/test_particle_unit.lua");
}

#[test]
fn lua_unit_pathfind_unit() {
    run_lua_test("unit/test_pathfind_unit.lua");
}

#[test]
fn lua_unit_patterns_unit() {
    run_lua_test("unit/test_patterns_unit.lua");
}

#[test]
fn lua_unit_physics_unit() {
    run_lua_test("unit/test_physics_unit.lua");
}

#[test]
fn lua_unit_pipeline_unit() {
    run_lua_test("unit/test_pipeline_unit.lua");
}

#[test]
fn lua_unit_progression_unit() {
    run_lua_test("unit/test_progression_unit.lua");
}

#[test]
fn lua_unit_procgen_unit() {
    run_lua_test("unit/test_procgen_unit.lua");
}

#[test]
fn lua_unit_procgen_gap_unit() {
    run_lua_test("unit/test_procgen_gap_unit.lua");
}

#[test]
fn lua_unit_province_unit() {
    run_lua_test("unit/test_province_unit.lua");
}

#[test]
fn lua_unit_raycaster_unit() {
    run_lua_test("unit/test_raycaster_unit.lua");
}

#[test]
fn lua_unit_render_unit() {
    run_lua_test("unit/test_render_unit.lua");
}

#[test]
fn lua_unit_repl_unit() {
    run_lua_test("unit/test_repl_unit.lua");
}

#[test]
fn lua_unit_runtime_unit() {
    run_lua_test("unit/test_runtime_unit.lua");
}

#[test]
fn lua_unit_save_unit() {
    run_lua_test("unit/test_save_unit.lua");
}

#[test]
fn lua_unit_scene_unit() {
    run_lua_test("unit/test_scene_unit.lua");
}

#[test]
fn lua_unit_serialize_unit() {
    run_lua_test("unit/test_serialize_unit.lua");
}

#[test]
fn lua_unit_shape_unit() {
    run_lua_test("unit/test_shape_unit.lua");
}

#[test]
fn lua_unit_spine_unit() {
    run_lua_test("unit/test_spine_unit.lua");
}

#[test]
fn lua_unit_sprite_unit() {
    run_lua_test("unit/test_sprite_unit.lua");
}

#[test]
fn lua_unit_svg_unit() {
    run_lua_test("unit/test_svg_unit.lua");
}

#[test]
fn lua_unit_terminal_unit() {
    run_lua_test("unit/test_terminal_unit.lua");
}

#[test]
fn lua_unit_thread_unit() {
    run_lua_test("unit/test_thread_unit.lua");
}

#[test]
fn lua_unit_tilemap_unit() {
    run_lua_test("unit/test_tilemap_unit.lua");
}

#[test]
fn lua_unit_tilefield_unit() {
    run_lua_test("unit/test_tilefield_unit.lua");
}

#[test]
fn lua_unit_tilefield_gap_unit() {
    run_lua_test("unit/test_tilefield_gap_unit.lua");
}

#[test]
fn lua_unit_tilelight_unit() {
    run_lua_test("unit/test_tilelight_unit.lua");
}

#[test]
fn lua_unit_tileset_unit() {
    run_lua_test("unit/test_tileset_unit.lua");
}

#[test]
fn lua_unit_timer_unit() {
    run_lua_test("unit/test_timer_unit.lua");
}

#[test]
fn lua_unit_tween_unit() {
    run_lua_test("unit/test_tween_unit.lua");
}

#[test]
fn lua_unit_ui_unit() {
    run_lua_test("unit/test_ui_unit.lua");
}

#[test]
fn lua_unit_validator_unit() {
    run_lua_test("unit/test_validator_unit.lua");
}

#[test]
fn lua_unit_awareness_unit() {
    run_lua_test("unit/test_awareness_unit.lua");
}

#[test]
fn lua_unit_window_unit() {
    run_lua_test("unit/test_window_unit.lua");
}

#[test]
fn lua_demo_colocated_games() {
    let mut paths = Vec::new();
    collect_colocated_game_tests(Path::new("lurek_2d_content/games"), &mut paths);
    paths.sort();
    for path in &paths {
        let display = path.to_str().expect("non-utf8 game test path");
        run_lua_workspace_test(display);
    }
}
