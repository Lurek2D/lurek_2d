//! Release-only measurement scenarios for bounded sprite hot paths.
//!
//! Run with `cargo test --release --test sprite_perf_tests -- --nocapture`.
//! Each scenario emits one stable `SPRITE_PERF:` JSON record consumed by the
//! sprite performance gate. The tests prove the scenario remains semantically
//! valid; the gate owns comparison against a checked-in baseline.

use lurek2d::sprite::atlas::parse_aseprite_json;
use lurek2d::sprite::{
    parse_texturepacker_json, SpriteAnimator, SpriteClip, SpriteLimits, SpriteSheet, TextureAtlas,
};
use std::collections::HashMap;
use std::time::Instant;

fn emit(name: &str, iterations: usize, units: usize, bytes: usize, elapsed: std::time::Duration) {
    println!(
        "SPRITE_PERF:{}",
        serde_json::json!({
            "scenario": name,
            "iterations": iterations,
            "units": units,
            "json_bytes": bytes,
            "elapsed_ns": elapsed.as_nanos(),
        })
    );
}

#[test]
fn uniform_sheet_construction_lookup_and_export() {
    let start = Instant::now();
    let mut units = 0;
    for _ in 0..200 {
        let mut sheet = SpriteSheet::try_new(256, 256, 16, 16).unwrap();
        sheet.name_group("walk", 0, 16);
        units += sheet.get_frame_count();
        assert!(sheet.get_frame(255).is_some());
        assert_eq!(sheet.get_group("walk").unwrap().len(), 16);
    }
    emit("uniform_sheet", 200, units, 0, start.elapsed());
}

#[test]
fn atlas_parse_lookup_and_ordered_export() {
    let frames: Vec<String> = (0..128)
        .map(|index| {
            format!(
                r#"{{"filename":"f{index:03}","frame":{{"x":{},"y":0,"w":1,"h":1}}}}"#,
                index
            )
        })
        .collect();
    let json = format!(r#"{{"frames":[{}]}}"#, frames.join(","));
    let start = Instant::now();
    let mut units = 0;
    for _ in 0..100 {
        let atlas = parse_texturepacker_json(&json).unwrap();
        assert_eq!(*atlas.entry_names().first().unwrap(), "f000");
        assert_eq!(atlas.get_entry("f127").unwrap().x, 127);
        units += atlas.entry_count();
    }
    emit(
        "texturepacker_parse_lookup",
        100,
        units,
        json.len(),
        start.elapsed(),
    );
}

#[test]
fn aseprite_parse_is_canonical_and_bounded() {
    let json = r#"{"frames":{"idle":{"frame":{"x":0,"y":0,"w":16,"h":16}}},"meta":{"size":{"w":16,"h":16}}}"#;
    let start = Instant::now();
    let mut units = 0;
    for _ in 0..500 {
        let atlas = parse_aseprite_json(json).unwrap();
        assert_eq!(atlas.entry_count(), 1);
        units += atlas.entry_count();
    }
    emit("aseprite_parse", 500, units, json.len(), start.elapsed());
}

#[test]
fn generic_packer_composition_and_ordered_regions() {
    let start = Instant::now();
    let mut units = 0;
    for _ in 0..100 {
        let mut atlas = TextureAtlas::try_new(256, 256, 1).unwrap();
        for index in 0..128 {
            let name = format!("r{index:03}");
            atlas.pack_checked(&name, 8, 8, None).unwrap();
        }
        let regions = atlas.get_regions();
        assert_eq!(regions.first().unwrap().name, "r000");
        units += regions.len();
    }
    emit("generic_packer", 100, units, 0, start.elapsed());
}

#[test]
fn animator_catch_up_is_capped_independently_of_delta() {
    let mut clips = HashMap::new();
    clips.insert(
        "walk".to_string(),
        SpriteClip {
            from: 0,
            to: 15,
            fps: 60.0,
            looping: true,
            ..SpriteClip::default()
        },
    );
    let start = Instant::now();
    let mut units = 0;
    for _ in 0..10_000 {
        let mut animator = SpriteAnimator::new(clips.clone());
        assert!(animator.play("walk", true));
        let events = animator.update(10_000.0);
        assert!(events.len() <= SpriteLimits::MAX_ANIMATOR_EVENTS);
        units += events.len();
    }
    emit("animator_catch_up", 10_000, units, 0, start.elapsed());
}
