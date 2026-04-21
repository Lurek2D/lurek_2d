//! Tests for the parallax module.

use lurek2d::parallax::layer::ParallaxDrawBatch;
use lurek2d::parallax::render::batch_to_render_commands;
use lurek2d::parallax::ParallaxLayer;
use lurek2d::render::renderer::RenderCommand;
use lurek2d::render::BlendMode;
use lurek2d::runtime::resource_keys::TextureKey;
use slotmap::KeyData;

fn dummy_key() -> TextureKey {
    TextureKey::from(KeyData::from_ffi(1))
}

// ── layer ─────────────────────────────────────────────────────────────────────

mod layer_tests {
    use super::*;

    #[test]
    fn parallax_layer_new_defaults() {
        let layer = ParallaxLayer::new(dummy_key(), 512.0, 256.0);
        assert!((layer.opacity - 1.0).abs() < 1e-5);
        assert!(layer.visible);
        assert!(layer.repeat_x);
        assert!(!layer.repeat_y);
        assert_eq!(layer.z, 0);
    }

    #[test]
    fn parallax_layer_update_accumulates_autoscroll() {
        let mut layer = ParallaxLayer::new(dummy_key(), 512.0, 256.0);
        layer.autoscroll = [100.0, 50.0];
        layer.update(0.5);
        assert!((layer.autoscroll_accum[0] - 50.0).abs() < 1e-4);
        assert!((layer.autoscroll_accum[1] - 25.0).abs() < 1e-4);
    }

    #[test]
    fn parallax_layer_autoscroll_wraps_within_tex_size() {
        let mut layer = ParallaxLayer::new(dummy_key(), 100.0, 100.0);
        layer.autoscroll = [100.0, 0.0];
        layer.update(1.5); // 150 px — should wrap to 50 within [0, 100)
        assert!((layer.autoscroll_accum[0] - 50.0).abs() < 1e-4);
    }

    #[test]
    fn parallax_layer_invisible_builds_no_calls() {
        let mut layer = ParallaxLayer::new(dummy_key(), 128.0, 128.0);
        layer.visible = false;
        let batch = layer.build_draw_calls(0.0, 0.0, 800.0, 600.0);
        assert!(batch.is_none());
    }

    #[test]
    fn parallax_layer_zero_opacity_builds_no_calls() {
        let mut layer = ParallaxLayer::new(dummy_key(), 128.0, 128.0);
        layer.opacity = 0.0;
        let batch = layer.build_draw_calls(0.0, 0.0, 800.0, 600.0);
        assert!(batch.is_none());
    }

    #[test]
    fn parallax_layer_non_repeat_single_tile() {
        let mut layer = ParallaxLayer::new(dummy_key(), 512.0, 512.0);
        layer.repeat_x = false;
        layer.repeat_y = false;
        let batch = layer.build_draw_calls(0.0, 0.0, 800.0, 600.0).unwrap();
        assert_eq!(batch.tiles.len(), 1);
    }

    #[test]
    fn parallax_layer_repeat_x_fills_screen() {
        let mut layer = ParallaxLayer::new(dummy_key(), 200.0, 600.0);
        layer.repeat_x = true;
        layer.repeat_y = false;
        // 800 / 200 = 4 tiles, starting at 0 offset → tiles at x=0,200,400,600
        let batch = layer.build_draw_calls(0.0, 0.0, 800.0, 600.0).unwrap();
        assert_eq!(batch.tiles.len(), 4);
    }

    #[test]
    fn parallax_layer_scroll_factor_offsets_camera() {
        let layer = ParallaxLayer::new(dummy_key(), 200.0, 200.0);
        // scroll_factor [1,0], repeat_x true, cam_x = 100
        // pixel offset = 100 * 1 = 100; start_x = -100 % 200 = -100
        let batch = layer.build_draw_calls(100.0, 0.0, 400.0, 200.0).unwrap();
        assert!((batch.tiles[0].0 - (-100.0)).abs() < 1e-4);
    }

    #[test]
    fn parallax_layer_reset_autoscroll_clears_accum() {
        let mut layer = ParallaxLayer::new(dummy_key(), 100.0, 100.0);
        layer.autoscroll = [50.0, 20.0];
        layer.update(1.0);
        layer.reset_autoscroll();
        assert!((layer.autoscroll_accum[0]).abs() < 1e-5);
        assert!((layer.autoscroll_accum[1]).abs() < 1e-5);
    }

    #[test]
    fn parallax_layer_color_multiplies_tint_and_opacity() {
        let mut layer = ParallaxLayer::new(dummy_key(), 100.0, 200.0);
        layer.repeat_x = false;
        layer.repeat_y = false;
        layer.tint = [0.5, 0.8, 1.0, 1.0];
        layer.opacity = 0.5;
        let batch = layer.build_draw_calls(0.0, 0.0, 800.0, 600.0).unwrap();
        assert!((batch.color[3] - 0.5).abs() < 1e-5); // 1.0 * 0.5 = 0.5
    }
}

// ── render ────────────────────────────────────────────────────────────────────

mod render_tests {
    use super::*;

    #[test]
    fn invisible_layer_produces_empty_commands() {
        let mut layer = ParallaxLayer::new(dummy_key(), 256.0, 256.0);
        layer.visible = false;
        let cmds = layer.generate_render_commands(0.0, 0.0, 800.0, 600.0);
        assert!(cmds.is_empty());
    }

    #[test]
    fn visible_layer_produces_draw_image_ex_commands() {
        let layer = ParallaxLayer::new(dummy_key(), 256.0, 256.0);
        let cmds = layer.generate_render_commands(0.0, 0.0, 800.0, 600.0);
        // Should have: SetColor + SetBlendMode + N DrawImageEx tiles
        assert!(
            cmds.len() >= 3,
            "Expected at least 3 commands, got {}",
            cmds.len()
        );
        // First is SetColor
        assert!(matches!(cmds[0], RenderCommand::SetColor(..)));
        // Second is SetBlendMode
        assert!(matches!(cmds[1], RenderCommand::SetBlendMode(_)));
        // Rest are DrawImageEx
        for cmd in &cmds[2..] {
            assert!(matches!(cmd, RenderCommand::DrawImageEx { .. }));
        }
    }

    #[test]
    fn batch_to_commands_preserves_tile_positions() {
        let batch = ParallaxDrawBatch {
            texture_key: dummy_key(),
            tiles: vec![(10.0, 20.0), (266.0, 20.0)],
            sx: 1.0,
            sy: 1.0,
            color: [1.0, 1.0, 1.0, 1.0],
            blend_mode: BlendMode::Alpha,
        };
        let cmds = batch_to_render_commands(&batch);
        assert_eq!(cmds.len(), 4); // SetColor + SetBlendMode + 2 tiles
        if let RenderCommand::DrawImageEx { x, y, .. } = &cmds[2] {
            assert!((*x - 10.0).abs() < 1e-5);
            assert!((*y - 20.0).abs() < 1e-5);
        } else {
            panic!("Expected DrawImageEx");
        }
    }
}

// ── draw ──────────────────────────────────────────────────────────────────────

mod draw_tests {
    use super::*;

    #[test]
    fn draw_to_image_correct_dimensions() {
        let layer = ParallaxLayer::new(dummy_key(), 256.0, 256.0);
        let img = layer.draw_to_image(320, 240);
        assert_eq!(img.width(), 320);
        assert_eq!(img.height(), 240);
    }

    #[test]
    fn draw_to_image_invisible_layer_is_transparent() {
        let mut layer = ParallaxLayer::new(dummy_key(), 256.0, 256.0);
        layer.visible = false;
        let img = layer.draw_to_image(16, 16);
        if let Some((_, _, _, a)) = img.get_pixel(0, 0) {
            assert_eq!(a, 0, "invisible layer should be fully transparent");
        }
    }

    #[test]
    fn draw_to_image_uses_layer_tint() {
        let mut layer = ParallaxLayer::new(dummy_key(), 256.0, 256.0);
        layer.tint = [1.0, 0.0, 0.5, 1.0];
        layer.opacity = 1.0;
        let img = layer.draw_to_image(16, 16);
        if let Some((r, g, _, _)) = img.get_pixel(0, 0) {
            assert!(r > 200, "expected high red channel from tint");
            assert!(g < 10, "expected zero green channel from tint");
        }
    }
}
