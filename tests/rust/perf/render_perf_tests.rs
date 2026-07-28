//! Release-mode render command replay measurements for the render performance gate.
//!
//! The suite deliberately uses deterministic software replay so it runs on CI
//! and headless tools without an adapter. GPU telemetry remains optional at the
//! live renderer boundary; these samples provide stable command/build/replay
//! percentiles and command-family accounting.

use lurek2d::render::gpu_screenshot_readback::surface_readback_layout;
use lurek2d::render::renderer::{PostFxPass, TextSpan};
use lurek2d::render::software_capture::capture_commands_to_image_sized;
use lurek2d::render::{DrawMode, Mesh, MeshDrawMode, RenderCommand};
use lurek2d::runtime::resource_keys::{CanvasKey, FontKey};
use slotmap::Key;
use std::time::Instant;

const SAMPLES: usize = 31;

fn percentile(sorted: &[u128], numerator: usize) -> u128 {
    let index = (sorted.len().saturating_sub(1) * numerator) / 100;
    sorted[index]
}

fn emit(name: &str, commands: &[RenderCommand]) {
    let mut samples = Vec::with_capacity(SAMPLES);
    for _ in 0..SAMPLES {
        let start = Instant::now();
        let image = capture_commands_to_image_sized(commands, [0.02, 0.03, 0.05, 1.0], 256, 192);
        assert_eq!(image.width(), 256);
        samples.push(start.elapsed().as_nanos());
    }
    samples.sort_unstable();
    println!(
        "RENDER_PERF:{}",
        serde_json::json!({
            "scenario": name,
            "backend": "software",
            "samples": SAMPLES,
            "command_count": commands.len(),
            "p50_ns": percentile(&samples, 50),
            "p95_ns": percentile(&samples, 95),
            "p99_ns": percentile(&samples, 99),
            "draw_count": commands.iter().filter(|command| !matches!(command, RenderCommand::SetColor(..))).count(),
        })
    );
}

fn emit_cpu_validation(name: &str, command_count: usize, mut work: impl FnMut()) {
    let mut samples = Vec::with_capacity(SAMPLES);
    for _ in 0..SAMPLES {
        let start = Instant::now();
        work();
        samples.push(start.elapsed().as_nanos());
    }
    samples.sort_unstable();
    println!(
        "RENDER_PERF:{}",
        serde_json::json!({
            "scenario": name,
            "backend": "cpu_validation",
            "samples": SAMPLES,
            "command_count": command_count,
            "p50_ns": percentile(&samples, 50),
            "p95_ns": percentile(&samples, 95),
            "p99_ns": percentile(&samples, 99),
            "draw_count": 0,
        })
    );
}

fn primitive_commands() -> Vec<RenderCommand> {
    let mut commands = Vec::with_capacity(192);
    for index in 0..64 {
        commands.push(RenderCommand::SetColor(
            (index % 7) as f32 / 7.0,
            (index % 11) as f32 / 11.0,
            0.8,
            1.0,
        ));
        commands.push(RenderCommand::Rectangle {
            mode: DrawMode::Fill,
            x: (index % 16) as f32 * 15.0,
            y: (index / 16) as f32 * 21.0,
            w: 13.0,
            h: 18.0,
        });
        commands.push(RenderCommand::Circle {
            mode: DrawMode::Fill,
            x: (index % 16) as f32 * 15.0 + 7.0,
            y: (index / 16) as f32 * 21.0 + 9.0,
            r: 5.0,
        });
    }
    commands
}

#[test]
fn primitive_heavy_steady_state() {
    emit("primitive_heavy_steady_state", &primitive_commands());
}

#[test]
fn transform_and_clip_command_stream() {
    let mut commands = primitive_commands();
    commands.insert(0, RenderCommand::PushTransform);
    commands.insert(1, RenderCommand::Translate { x: 6.0, y: 8.0 });
    commands.insert(2, RenderCommand::SetScissor(Some((8.0, 8.0, 224.0, 168.0))));
    commands.push(RenderCommand::SetScissor(None));
    commands.push(RenderCommand::PopTransform);
    emit("transform_clip_stream", &commands);
}

#[test]
fn large_command_stream() {
    let mut commands = Vec::with_capacity(1_024);
    for index in 0..512 {
        commands.push(RenderCommand::SetColor(0.2, 0.6, 0.9, 0.65));
        commands.push(RenderCommand::Line {
            x1: 0.0,
            y1: (index % 192) as f32,
            x2: 255.0,
            y2: ((index * 7) % 192) as f32,
        });
    }
    emit("large_command_stream", &commands);
}

#[test]
fn text_and_rich_text_command_stream() {
    let font_key = FontKey::null();
    let mut commands = Vec::with_capacity(128);
    for index in 0..64 {
        commands.push(RenderCommand::Print {
            font_key,
            text: format!("label-{index:03}"),
            x: (index % 16) as f32 * 15.0,
            y: (index / 16) as f32 * 22.0,
            scale: 1.0,
        });
        commands.push(RenderCommand::DrawRichText {
            font_key,
            spans: vec![
                TextSpan::new("cache", 220, 230, 255, 255, 1.0),
                TextSpan::new(" miss", 255, 180, 90, 255, 0.9),
            ],
            x: (index % 16) as f32 * 15.0,
            y: (index / 16) as f32 * 22.0 + 10.0,
        });
    }
    emit("text_rich_command_stream", &commands);
}

#[test]
fn canvas_postfx_command_stream() {
    let canvas_key = CanvasKey::null();
    let pass = PostFxPass {
        effect_name: "bloom".into(),
        params: Default::default(),
        shader_id: None,
        auto_uniforms: true,
    };
    let mut commands = Vec::with_capacity(192);
    for index in 0..32 {
        commands.push(RenderCommand::RegisterCanvas {
            canvas_key,
            width: 256,
            height: 192,
        });
        commands.push(RenderCommand::SetCanvas(Some(canvas_key)));
        commands.push(RenderCommand::SetColor(0.1, 0.2, 0.4, 1.0));
        commands.push(RenderCommand::Rectangle {
            mode: DrawMode::Fill,
            x: (index % 8) as f32 * 24.0,
            y: (index / 8) as f32 * 32.0,
            w: 22.0,
            h: 30.0,
        });
        commands.push(RenderCommand::SetCanvas(None));
        commands.push(RenderCommand::ApplyPostFx {
            stack_id: index,
            passes: vec![pass.clone()],
            width: 256,
            height: 192,
        });
    }
    emit("canvas_postfx_command_stream", &commands);
}

#[test]
fn mesh_resource_lifecycle_stream() {
    let mesh = Mesh::new(3, MeshDrawMode::Triangles);
    let mut commands = Vec::with_capacity(96);
    for index in 0..48 {
        commands.push(RenderCommand::SyncMesh {
            mesh_key: slotmap::SlotMap::with_key().insert(mesh.clone()),
            mesh: mesh.clone(),
        });
        commands.push(RenderCommand::DrawMeshTransient {
            mesh: mesh.clone(),
            x: (index % 12) as f32 * 20.0,
            y: (index / 12) as f32 * 30.0,
            rotation: 0.0,
            sx: 1.0,
            sy: 1.0,
            ox: 0.0,
            oy: 0.0,
        });
    }
    emit("mesh_resource_lifecycle_stream", &commands);
}

#[test]
fn readback_row_layout_pressure() {
    emit_cpu_validation("readback_row_layout_pressure", 96, || {
        for width in 1..=96 {
            let (row_bytes, total_bytes) =
                surface_readback_layout(width, 1080).expect("bounded readback layout");
            assert!(row_bytes >= width * 4);
            assert!(total_bytes >= u64::from(row_bytes));
        }
    });
}
