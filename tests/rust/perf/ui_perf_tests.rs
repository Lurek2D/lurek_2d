//! Release-mode UI workload measurements for the UI performance gate.
//!
//! Run with `cargo test --release --test ui_perf_tests -- --nocapture`.

use lurek2d::ui::GuiContext;
use std::time::{Duration, Instant};

fn emit(name: &str, iterations: usize, widgets: usize, elapsed: Duration) {
    println!("UI_PERF:{}", serde_json::json!({
        "scenario": name,
        "iterations": iterations,
        "widgets": widgets,
        "elapsed_ns": elapsed.as_nanos(),
    }));
}

fn populated_context(count: usize) -> GuiContext {
    let mut ctx = GuiContext::new();
    ctx.set_viewport(1920.0, 1080.0);
    for index in 0..count {
        let widget = ctx.add_button("benchmark");
        ctx.widgets[widget].base_mut().x = (index % 100) as f32 * 18.0;
        ctx.widgets[widget].base_mut().y = (index / 100) as f32 * 24.0;
        assert!(ctx.add_child(0, widget));
    }
    ctx.run_layout_pass();
    ctx
}

#[test]
fn clean_frame_100_widgets() {
    let mut ctx = populated_context(100);
    let start = Instant::now();
    for _ in 0..100 { let _ = ctx.generate_render_commands(); }
    emit("clean_frame_100", 100, 100, start.elapsed());
}

#[test]
fn clean_frame_1000_widgets() {
    let mut ctx = populated_context(1_000);
    let start = Instant::now();
    for _ in 0..20 { let _ = ctx.generate_render_commands(); }
    emit("clean_frame_1000", 20, 1_000, start.elapsed());
}

#[test]
fn clean_pointer_move_1000_widgets() {
    let mut ctx = populated_context(1_000);
    let before = ctx.runtime_stats().layout_passes;
    let start = Instant::now();
    for point in 0..500 { ctx.mouse_moved((point % 400) as f32, (point % 200) as f32); }
    assert_eq!(before, ctx.runtime_stats().layout_passes, "clean pointer moves must not relayout");
    emit("clean_pointer_move_1000", 500, 1_000, start.elapsed());
}
