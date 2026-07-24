//! File: tests/rust/unit/sprite_tests.rs

// TODO(lua-first): public Rust API coverage in this file should live in tests/lua/unit/; keep only private/internal seams here.

use lurek2d::color::Color;
use lurek2d::math::Vec2;
use lurek2d::runtime::resource_keys::TextureKey;
use lurek2d::sprite::sprite_batch::BatchEntry;
use lurek2d::sprite::sprite_sheet::DirectionLayout;
use lurek2d::sprite::*;
use slotmap::KeyData;

fn dummy_key() -> TextureKey {
    TextureKey::from(KeyData::from_ffi(1))
}

mod sprite_hardening_tests {
    use super::*;
    use std::collections::HashMap;

    #[test]
    fn strict_sheet_rejects_remainders_and_excessive_frame_counts() {
        assert!(SpriteSheet::try_new(65, 32, 32, 32).is_err());
        assert!(SpriteSheet::try_new(1_000_000, 1_000_000, 1, 1).is_err());
    }

    #[test]
    fn strict_atlas_rejects_oversized_dimensions_and_invalid_padding() {
        assert!(TextureAtlas::try_new(SpriteLimits::MAX_ATLAS_DIMENSION + 1, 1, 0).is_err());
        assert!(TextureAtlas::try_new(64, 64, 64).is_err());
        assert!(TextureAtlas::try_new(64, 64, 0).is_ok());
    }

    #[test]
    fn animator_normalizes_non_finite_fps_and_caps_events() {
        let clip = SpriteClip {
            fps: f32::NAN,
            ..SpriteClip::default()
        }
        .normalized();
        assert!(clip.fps.is_finite());
        let mut clips = HashMap::new();
        clips.insert(
            "walk".to_string(),
            SpriteClip {
                from: 1,
                to: 2,
                fps: 1_000.0,
                looping: true,
                ..SpriteClip::default()
            },
        );
        let mut animator = SpriteAnimator::new(clips);
        assert!(animator.play("walk", true));
        assert!(animator.update(1_000_000.0).len() <= SpriteLimits::MAX_ANIMATOR_EVENTS);
        assert!(animator.update(f32::NAN).is_empty());
        assert!(!animator.play("missing", true));
    }

    #[test]
    fn atlas_parser_rejects_duplicates_and_bounds_are_checked() {
        let duplicate = r#"{"frames":[{"filename":"a","frame":{"x":0,"y":0,"w":1,"h":1}},{"filename":"a","frame":{"x":1,"y":0,"w":1,"h":1}}]}"#;
        assert!(parse_texturepacker_json(duplicate).is_err());
        let atlas =
            parse_texturepacker_json(r#"{"frames":{"a":{"frame":{"x":3,"y":0,"w":2,"h":1}}}}"#)
                .unwrap();
        assert!(atlas.validate_bounds(4, 4).is_err());
        let deep = format!(
            "{}{}",
            "[".repeat(SpriteLimits::MAX_ATLAS_JSON_DEPTH + 1),
            "]".repeat(SpriteLimits::MAX_ATLAS_JSON_DEPTH + 1)
        );
        assert!(parse_texturepacker_json(&deep)
            .unwrap_err()
            .contains("nesting"));
    }
}

// Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ sprite Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬

#[allow(clippy::module_inception)]
mod sprite_tests {
    use super::*;

    #[test]
    fn new_sprite_defaults() {
        let s = Sprite::new(42, Vec2::new(10.0, 20.0));
        assert_eq!(s.texture_id, 42);
        assert!((s.position.x - 10.0).abs() < 1e-5);
        assert!((s.position.y - 20.0).abs() < 1e-5);
        assert!((s.scale.x - 1.0).abs() < 1e-5);
        assert!((s.scale.y - 1.0).abs() < 1e-5);
        assert!((s.rotation).abs() < 1e-5);
        assert_eq!(s.color, Color::WHITE);
    }

    #[test]
    fn set_position_updates_vec2() {
        let mut s = Sprite::new(0, Vec2::ZERO);
        s.set_position(100.0, 200.0);
        assert!((s.position.x - 100.0).abs() < 1e-5);
        assert!((s.position.y - 200.0).abs() < 1e-5);
    }

    #[test]
    fn set_scale_replaces_value() {
        let mut s = Sprite::new(0, Vec2::ZERO);
        s.set_scale(2.0, 3.0);
        assert!((s.scale.x - 2.0).abs() < 1e-5);
        assert!((s.scale.y - 3.0).abs() < 1e-5);
    }

    #[test]
    fn set_rotation_stores_radians() {
        let mut s = Sprite::new(0, Vec2::ZERO);
        s.set_rotation(std::f32::consts::PI);
        assert!((s.rotation - std::f32::consts::PI).abs() < 1e-5);
    }

    #[test]
    fn set_color_applies_tint() {
        let mut s = Sprite::new(0, Vec2::ZERO);
        let red = Color::new(1.0, 0.0, 0.0, 1.0);
        s.set_color(red);
        assert!((s.color.r - 1.0).abs() < 1e-5);
        assert!((s.color.g).abs() < 1e-5);
    }
}

// Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ sprite_batch Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬

mod sprite_batch_tests {
    use super::*;

    fn make_entry(x: f32, y: f32) -> BatchEntry {
        BatchEntry {
            x,
            y,
            quad_x: 0.0,
            quad_y: 0.0,
            quad_w: 32.0,
            quad_h: 32.0,
            rotation: 0.0,
            sx: 1.0,
            sy: 1.0,
            ox: 0.0,
            oy: 0.0,
        }
    }

    #[test]
    fn new_batch_starts_empty() {
        let batch = SpriteBatch::new(dummy_key(), 0);
        assert!(batch.is_empty());
        assert_eq!(batch.len(), 0);
    }

    #[test]
    fn add_returns_index() {
        let mut batch = SpriteBatch::new(dummy_key(), 0);
        let idx = batch.add(make_entry(10.0, 20.0));
        assert_eq!(idx, Some(0));
        assert_eq!(batch.len(), 1);
    }

    #[test]
    fn add_respects_max_entries() {
        let mut batch = SpriteBatch::new(dummy_key(), 2);
        assert!(batch.add(make_entry(0.0, 0.0)).is_some());
        assert!(batch.add(make_entry(0.0, 0.0)).is_some());
        assert!(batch.add(make_entry(0.0, 0.0)).is_none());
    }

    #[test]
    fn clear_empties_batch() {
        let mut batch = SpriteBatch::new(dummy_key(), 0);
        batch.add(make_entry(0.0, 0.0));
        batch.clear();
        assert!(batch.is_empty());
    }

    #[test]
    fn texture_key_matches_construction() {
        let key = dummy_key();
        let batch = SpriteBatch::new(key, 0);
        assert_eq!(batch.texture_key(), key);
    }

    #[test]
    fn zero_capacity_uses_the_bounded_default() {
        let mut batch = SpriteBatch::new(dummy_key(), 0);
        for _ in 0..256 {
            assert!(batch.add(make_entry(0.0, 0.0)).is_some());
        }
        assert!(batch.add(make_entry(0.0, 0.0)).is_none());
        assert_eq!(batch.buffer_size(), 256);
    }

    #[test]
    fn batch_capacity_is_capped_at_the_trusted_maximum() {
        let batch = SpriteBatch::new(dummy_key(), usize::MAX);
        assert_eq!(
            batch.buffer_size(),
            lurek2d::sprite::limits::SpriteLimits::MAX_BATCH_ENTRIES
        );
    }
}

// Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ sprite_sheet Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬

mod sprite_sheet_tests {
    use super::*;

    fn rect_xy(rect: &lurek2d::math::Rect) -> (i32, i32) {
        (rect.x as i32, rect.y as i32)
    }

    #[test]
    fn get_frame_out_of_range_returns_none() {
        let sheet = SpriteSheet::new(32, 32, 32, 32);
        assert!(sheet.get_frame(5).is_none());
    }

    #[test]
    fn get_range_clamps_to_bounds() {
        let sheet = SpriteSheet::new(64, 32, 32, 32);
        let range = sheet.get_range(1, 100);
        assert_eq!(range.len(), 1); // only frame index 1 exists
    }

    #[test]
    fn get_row_returns_expected_slice() {
        let sheet = SpriteSheet::new(96, 64, 32, 32);
        let row = sheet.get_row(1);
        assert_eq!(row.len(), 3);
        assert_eq!(rect_xy(&row[0]), (0, 32));
        assert_eq!(rect_xy(&row[1]), (32, 32));
        assert_eq!(rect_xy(&row[2]), (64, 32));
    }

    #[test]
    fn get_row_out_of_range_is_empty_slice() {
        let sheet = SpriteSheet::new(96, 64, 32, 32);
        let row = sheet.get_row(10);
        assert!(row.is_empty());
    }

    #[test]
    fn get_column_iterator_returns_expected_frames() {
        let sheet = SpriteSheet::new(96, 64, 32, 32);
        let col: Vec<_> = sheet.get_column(1).collect();
        assert_eq!(col.len(), 2);
        assert_eq!(rect_xy(col[0]), (32, 0));
        assert_eq!(rect_xy(col[1]), (32, 32));
    }

    #[test]
    fn get_column_out_of_range_is_empty_iterator() {
        let sheet = SpriteSheet::new(96, 64, 32, 32);
        let col: Vec<_> = sheet.get_column(10).collect();
        assert!(col.is_empty());
    }

    #[test]
    fn direction_frames_rows_layout() {
        let mut sheet = SpriteSheet::new(96, 128, 32, 32);
        sheet.set_directions(4, DirectionLayout::Rows);
        let frames = sheet.get_direction_frames(0).unwrap();
        assert_eq!(frames.len(), 3);
        assert!(sheet.get_direction_frames(10).is_none());
    }

    #[test]
    fn zero_frame_size_yields_empty_sheet() {
        let sheet = SpriteSheet::new(128, 128, 0, 0);
        assert_eq!(sheet.get_frame_count(), 0);
    }
}

// Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ nine_slice Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬

mod nine_slice_tests {
    use super::*;

    #[test]
    fn patches_corners_preserve_size() {
        let ns = NineSlice::new(dummy_key(), 10.0, 10.0, 10.0, 10.0, 100.0, 100.0);
        let p = ns.patches(0.0, 0.0, 200.0, 200.0);
        // Top-left corner: dst_w = left (10), dst_h = top (10)
        assert!((p[0].6 - 10.0).abs() < 1e-5);
        assert!((p[0].7 - 10.0).abs() < 1e-5);
        // Top-right corner: dst_w = right (10)
        assert!((p[2].6 - 10.0).abs() < 1e-5);
    }

    #[test]
    fn patches_center_stretches() {
        let ns = NineSlice::new(dummy_key(), 10.0, 10.0, 10.0, 10.0, 100.0, 100.0);
        let p = ns.patches(0.0, 0.0, 200.0, 200.0);
        // Center patch: dst_w = 200 - 10 - 10 = 180, dst_h = 180
        assert!((p[4].6 - 180.0).abs() < 1e-5);
        assert!((p[4].7 - 180.0).abs() < 1e-5);
    }

    #[test]
    fn patches_small_destination_clamps_center() {
        let ns = NineSlice::new(dummy_key(), 10.0, 10.0, 10.0, 10.0, 100.0, 100.0);
        // Destination smaller than combined insets
        let p = ns.patches(0.0, 0.0, 15.0, 15.0);
        // Center width clamps to 0
        assert!(p[4].6 >= 0.0);
    }
}

// Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬ atlas Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬Ă˘â€ťâ‚¬

mod atlas_tests {
    use super::*;
    use lurek2d::sprite::{NineSliceInsets, TextureAtlas};

    #[test]
    fn atlas_hash_format_parses_correctly() {
        let json =
            r#"{"frames":{"hero.png":{"frame":{"x":0,"y":0,"w":32,"h":32},"rotated":false}}}"#;
        let atlas = parse_texturepacker_json(json).unwrap();
        assert_eq!(atlas.entry_count(), 1);
        let entry = atlas.get_entry("hero.png").unwrap();
        assert_eq!(entry.x, 0);
        assert_eq!(entry.w, 32);
        assert!(!entry.rotated);
    }

    #[test]
    fn atlas_array_format_parses_correctly() {
        let json = r#"{"frames":[{"filename":"bullet.png","frame":{"x":32,"y":0,"w":8,"h":8},"rotated":true}]}"#;
        let atlas = parse_texturepacker_json(json).unwrap();
        let entry = atlas.get_entry("bullet.png").unwrap();
        assert_eq!(entry.x, 32);
        assert!(entry.rotated);
    }

    #[test]
    fn atlas_missing_frames_key_returns_error() {
        let json = r#"{"meta":{}}"#;
        assert!(parse_texturepacker_json(json).is_err());
    }

    #[test]
    fn runtime_texture_atlas_pack_lookup_and_clear() {
        let mut atlas = TextureAtlas::new(64, 64, 1);
        assert!(atlas.pack("hero", 16, 16));

        let region = atlas.get_region("hero").expect("region should exist");
        assert_eq!(region.name, "hero");
        assert_eq!(region.w, 16);
        assert_eq!(region.h, 16);
        assert_eq!(atlas.get_region_count(), 1);

        atlas.clear();
        assert_eq!(atlas.get_region_count(), 0);
        assert!(atlas.get_region("hero").is_none());
    }

    #[test]
    fn runtime_texture_atlas_rejects_unfittable_region() {
        let mut atlas = TextureAtlas::new(16, 16, 1);
        assert!(!atlas.pack("too_big", 32, 4));
        assert_eq!(atlas.get_region_count(), 0);
    }

    #[test]
    fn runtime_texture_atlas_set_nine_slice_validates_insets() {
        let mut atlas = TextureAtlas::new(64, 64, 1);
        assert!(atlas.pack("panel", 20, 20));

        assert!(atlas.set_nine_slice(
            "panel",
            Some(NineSliceInsets {
                left: 2,
                right: 2,
                top: 3,
                bottom: 3,
            })
        ));

        let region = atlas.get_region("panel").expect("panel should exist");
        let insets = region.nine_slice.expect("insets should be set");
        assert_eq!(insets.left, 2);
        assert_eq!(insets.top, 3);

        assert!(!atlas.set_nine_slice(
            "panel",
            Some(NineSliceInsets {
                left: 50,
                right: 50,
                top: 0,
                bottom: 0,
            })
        ));
    }
}
