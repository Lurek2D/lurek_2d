//! File: tests/rust/unit/render_tests.rs

// TODO(lua-first): public Rust API coverage in this file should live in tests/lua/unit/; keep only private/internal seams here.

use std::collections::HashMap;

use lurek2d::font::{
    validate_dynamic_font_atlas_dimensions, validate_dynamic_font_point_size, Font,
    AVAILABLE_CELL_SIZES, AVAILABLE_HEIGHTS, MAX_DYNAMIC_FONT_ATLAS_DIMENSION,
    MAX_DYNAMIC_FONT_POINT_SIZE,
};
use lurek2d::render::canvas::Canvas;
use lurek2d::render::decal_surface::DecalSurface;
use lurek2d::render::image_effect::ShaderPassDescriptor;
use lurek2d::render::mesh::{Mesh, MeshDrawMode, MeshError, MeshVertex};
use lurek2d::render::postfx_pipeline::params_to_uniform;
use lurek2d::render::province_map_pipeline::ProvinceMapUniforms;
use lurek2d::render::renderer::{
    adaptive_circle_ellipse_segments, BlendMode, CompareMode, DepthMode, DrawMode,
    PhysicsDebugConfig, ProvinceMapEffectOptions, RenderCommand, StencilAction, StencilMode,
    TextSpan, TextureData,
};
use lurek2d::render::shape::{CompoundShape, ShapeCommand};
use lurek2d::render::software_capture::{
    capture_commands_to_image, capture_commands_to_image_with_diagnostics,
};

mod province_map_pipeline_tests {
    use super::*;

    fn assert_f32_slice_eq(actual: &[f32], expected: &[f32]) {
        assert_eq!(actual.len(), expected.len());
        for (i, (&a, &e)) in actual.iter().zip(expected.iter()).enumerate() {
            assert!(
                (a - e).abs() < 1e-5,
                "at index {}: expected {}, got {}",
                i,
                e,
                a
            );
        }
    }

    #[test]
    fn full_map_uniforms_cover_whole_map_and_default_to_tactical() {
        let u = ProvinceMapUniforms::full_map(2000, 900, 1920.0, 1080.0);
        assert_f32_slice_eq(&u.viewport, &[0.0, 0.0, 2000.0, 900.0]);
        assert_f32_slice_eq(&u.map_size, &[2000.0, 900.0]);
        assert_f32_slice_eq(&u.screen_size, &[1920.0, 1080.0]);
        assert_eq!(u.zoom_mode, 1);
        assert_eq!(u.terrain_texture_scale, 32.0);
        assert_eq!(u.terrain_texture_strength, 0.0);
        assert_f32_slice_eq(&u.fill_tint, &[1.0, 1.0, 1.0, 1.0]);
        assert_f32_slice_eq(
            &u.edge_gradient_color,
            &[64.0 / 255.0, 64.0 / 255.0, 60.0 / 255.0, 1.0],
        );
        assert_f32_slice_eq(&u.edge_gradient_params, &[16.0, 0.25, 0.45, 255.0]);
        assert_f32_slice_eq(
            &u.province_border_color,
            &[72.0 / 255.0, 58.0 / 255.0, 32.0 / 255.0, 1.0],
        );
        assert_f32_slice_eq(
            &u.coast_border_color,
            &[224.0 / 255.0, 196.0 / 255.0, 128.0 / 255.0, 238.0 / 255.0],
        );
        assert_f32_slice_eq(
            &u.country_border_color,
            &[230.0 / 255.0, 48.0 / 255.0, 44.0 / 255.0, 245.0 / 255.0],
        );
        assert_f32_slice_eq(&u.border_palette_params, &[1.0, 0.15, 0.0, 0.0]);
        assert_f32_slice_eq(&u.border_noise_params, &[0.07, 0.0, 1.0, 0.0]);
        assert_f32_slice_eq(&u.water_params, &[0.0, 0.08, 48.0, 0.0]);
        assert_f32_slice_eq(&u.weather_params, &[0.0, 1.0, 0.7, 1.0]);
        assert_f32_slice_eq(&u.fog_params, &[1.0, 0.0, 0.0, 0.0]);
        assert_f32_slice_eq(&u.fog_hidden_color, &[0.02, 0.02, 0.02, 1.0]);
        assert_f32_slice_eq(&u.climate_params, &[0.0, 0.0, 0.0, 0.0]);
        assert_eq!(u.highlight_ids, [0, 0, 0, 0]);
        assert_eq!(u.effect_seeds, [0, 0, 0, 0]);
    }

    #[test]
    fn province_map_shader_is_parseable_wgsl() {
        let source = include_str!("../../../src/render/shaders/province_map.wgsl");
        wgpu::naga::front::wgsl::parse_str(source)
            .expect("province map shader should remain valid WGSL");
    }

    #[test]
    fn province_map_command_validates_projection_inputs() {
        let command = RenderCommand::DrawProvinceMap {
            registry_name: "world".to_string(),
            viewport: [0.0, 0.0, 100.0, 50.0],
            screen_size: [320.0, 180.0],
            tint: [1.0, 1.0, 1.0, 1.0],
            province_tints: Vec::new(),
            terrain_texture: None,
            effects: ProvinceMapEffectOptions {
                terrain_texture_scale: 32.0,
                terrain_texture_strength: 0.0,
                edge_gradient_color: [0.0, 0.0, 0.0, 1.0],
                edge_gradient_radius: 6.0,
                edge_gradient_strength: 0.22,
                edge_gradient_softness: 0.45,
                border_palette_enabled: true,
                province_border_color: [64.0 / 255.0, 64.0 / 255.0, 60.0 / 255.0, 1.0],
                coast_border_color: [224.0 / 255.0, 196.0 / 255.0, 128.0 / 255.0, 1.0],
                country_border_color: [230.0 / 255.0, 46.0 / 255.0, 42.0 / 255.0, 1.0],
                sea_border_darken: 0.15,
                ..ProvinceMapEffectOptions::default()
            },
            selected_id: 0,
            hovered_id: 0,
            zoom_mode: 1,
            time: 0.0,
        };

        lurek2d::render::input_validation::validate_render_command(
            &command,
            &lurek2d::render::input_validation::RenderInputLimits::default(),
        )
        .expect("valid province map command");
        assert_eq!(
            command.category(),
            lurek2d::render::renderer::RenderCommandCategory::Debug
        );
    }
}

mod canvas_tests {
    use super::*;

    #[test]
    fn new_stores_dimensions() {
        let c = Canvas::new(320, 240);
        assert_eq!(c.width, 320);
        assert_eq!(c.height, 240);
    }

    #[test]
    fn new_zero_dimensions_allowed() {
        let c = Canvas::new(0, 0);
        assert_eq!(c.width, 0);
        assert_eq!(c.height, 0);
    }

    #[test]
    fn clone_produces_independent_copy() {
        let c1 = Canvas::new(100, 200);
        let c2 = c1.clone();
        assert_eq!(c2.width, 100);
        assert_eq!(c2.height, 200);
    }
}

mod decal_surface_tests {
    use super::*;

    #[test]
    fn new_stores_dimensions() {
        let ds = DecalSurface::new(512, 256);
        assert_eq!(ds.width, 512);
        assert_eq!(ds.height, 256);
    }

    #[test]
    fn get_dimensions_returns_tuple() {
        let ds = DecalSurface::new(640, 480);
        assert_eq!(ds.get_dimensions(), (640, 480));
    }

    #[test]
    fn get_width_and_height_match() {
        let ds = DecalSurface::new(1920, 1080);
        assert_eq!(ds.get_width(), 1920);
        assert_eq!(ds.get_height(), 1080);
    }

    #[test]
    fn zero_dimensions_allowed() {
        let ds = DecalSurface::new(0, 0);
        assert_eq!(ds.get_dimensions(), (0, 0));
    }
}

mod draw_layer_tests {
    use lurek2d::render::draw_layer::{allocate_callback_id, DrawLayer, DrawLayerError};

    #[test]
    fn flush_uses_total_order_and_callback_id_tie_breaker() {
        let mut layer = DrawLayer::new();
        let nan_id = layer.try_queue(f64::NAN).unwrap();
        let low_id = layer.try_queue(-1.0).unwrap();
        let first_equal_id = layer.try_queue(2.0).unwrap();
        let second_equal_id = layer.try_queue(2.0).unwrap();
        let inf_id = layer.try_queue(f64::INFINITY).unwrap();

        let ids: Vec<_> = layer
            .flush()
            .into_iter()
            .map(|entry| entry.callback_id)
            .collect();

        assert_eq!(
            ids,
            vec![low_id, first_equal_id, second_equal_id, inf_id, nan_id]
        );
        assert_eq!(layer.get_count(), 0);
    }

    #[test]
    fn callback_id_allocation_reports_exhaustion_without_wrapping() {
        let mut next_id = usize::MAX - 1;
        assert_eq!(allocate_callback_id(&mut next_id).unwrap(), usize::MAX - 1);
        assert_eq!(next_id, usize::MAX);

        assert_eq!(
            allocate_callback_id(&mut next_id).unwrap_err(),
            DrawLayerError::CallbackIdExhausted
        );
        assert_eq!(next_id, usize::MAX);
    }

    #[test]
    fn callback_id_allocation_reserves_max_as_queue_failure_sentinel() {
        let mut next_id = usize::MAX;

        assert_eq!(
            allocate_callback_id(&mut next_id).unwrap_err(),
            DrawLayerError::CallbackIdExhausted
        );
        assert_eq!(next_id, usize::MAX);
    }

    #[test]
    fn queue_convenience_path_does_not_expect_on_exhaustion() {
        let source = include_str!("../../../src/render/draw_layer.rs");
        assert!(!source.contains(".expect(\"DrawLayer callback id counter exhausted\")"));
        assert!(source.contains("usize::MAX"));
    }
}

mod font_tests {
    use super::*;

    #[test]
    fn nearest_size_exact_match() {
        assert_eq!(Font::nearest_size(16), 0);
        assert_eq!(Font::nearest_size(27), 3);
        assert_eq!(Font::nearest_size(49), 6);
    }

    #[test]
    fn nearest_size_rounds_to_closest() {
        assert_eq!(Font::nearest_size(18), 1);
        assert_eq!(Font::nearest_size(25), 3);
        assert_eq!(Font::nearest_size(36), 4);
    }

    #[test]
    fn nearest_size_extreme_values() {
        assert_eq!(Font::nearest_size(0), 0);
        assert_eq!(Font::nearest_size(1), 0);
        assert_eq!(Font::nearest_size(100), 6);
    }

    #[test]
    fn nearest_point_size_matches_builtin_font_labels() {
        assert_eq!(Font::nearest_point_size(10), 1);
        assert_eq!(Font::nearest_point_size(12), 2);
        assert_eq!(Font::nearest_point_size(29), 6);
    }

    #[test]
    fn available_heights_and_cell_sizes_correspond() {
        assert_eq!(AVAILABLE_HEIGHTS.len(), AVAILABLE_CELL_SIZES.len());
        for (i, &h) in AVAILABLE_HEIGHTS.iter().enumerate() {
            assert_eq!(AVAILABLE_CELL_SIZES[i].1, h);
        }
    }

    #[test]
    fn load_all_sizes_returns_six_fonts() {
        let fonts = Font::load_all_sizes();
        assert_eq!(fonts.len(), 7, "expected 7 built-in font sizes");
    }

    #[test]
    fn loaded_font_glyph_lookup() {
        let fonts = Font::load_all_sizes();
        let (ref font, _, _) = fonts[0];
        let glyph = font.glyph('A');
        assert!(glyph.is_some(), "ASCII 'A' should be in the bitmap font");
        let info = glyph.unwrap();
        assert!(info.advance_width > 0.0);
    }

    #[test]
    fn glyph_returns_none_for_unsupported_chars() {
        let fonts = Font::load_all_sizes();
        let (ref font, _, _) = fonts[0];
        assert!(font.glyph('\x01').is_none());
        assert!(font.glyph('\u{FFFF}').is_none());
    }

    #[test]
    fn text_width_sums_advances() {
        let fonts = Font::load_all_sizes();
        let (ref font, _, _) = fonts[0];
        let w = font.text_width("AB");
        assert!(
            (w - 16.0).abs() < 1e-5,
            "expected approximately 16.0, got {}",
            w
        );
    }

    #[test]
    fn text_width_empty_string() {
        let fonts = Font::load_all_sizes();
        let (ref font, _, _) = fonts[0];
        let w = font.text_width("");
        assert!(
            (w - 0.0).abs() < 1e-5,
            "expected approximately 0.0, got {}",
            w
        );
    }

    #[test]
    fn line_height_default_multiplier() {
        let fonts = Font::load_all_sizes();
        let (ref font, _, ch) = fonts[0];
        assert_eq!(font.line_height(), ch as f32);
    }

    #[test]
    fn set_line_height_multiplier() {
        let fonts = Font::load_all_sizes();
        let (mut font, _, ch) = fonts.into_iter().next().unwrap();
        font.set_line_height(2.0);
        assert!((font.line_height() - ch as f32 * 2.0).abs() < 1e-5);
    }

    #[test]
    fn dirty_flag_lifecycle() {
        let fonts = Font::load_all_sizes();
        let (mut font, _, _) = fonts.into_iter().next().unwrap();
        assert!(font.is_dirty(), "newly loaded font should be dirty");
        font.mark_clean();
        assert!(!font.is_dirty());
    }

    #[test]
    fn wrap_text_single_line_within_limit() {
        let fonts = Font::load_all_sizes();
        let (ref font, _, _) = fonts[0];
        let lines = font.wrap_text("Hello", 100.0);
        assert_eq!(lines.len(), 1);
        assert_eq!(lines[0], "Hello");
    }

    #[test]
    fn wrap_text_breaks_at_limit() {
        let fonts = Font::load_all_sizes();
        let (ref font, _, _) = fonts[0];
        let lines = font.wrap_text("AB CD", 12.0);
        assert_eq!(lines.len(), 2);
    }

    #[test]
    fn wrap_text_preserves_newlines() {
        let fonts = Font::load_all_sizes();
        let (ref font, _, _) = fonts[0];
        let lines = font.wrap_text("A\nB", 1000.0);
        assert_eq!(lines.len(), 2);
    }

    #[test]
    fn wrap_text_empty_string() {
        let fonts = Font::load_all_sizes();
        let (ref font, _, _) = fonts[0];
        let lines = font.wrap_text("", 100.0);
        assert_eq!(lines, vec![""]);
    }

    #[test]
    fn wrap_text_long_line_preserves_words_with_incremental_widths() {
        let fonts = Font::load_all_sizes();
        let (ref font, _, _) = fonts[0];
        let text = (0..200)
            .map(|i| format!("w{i}"))
            .collect::<Vec<_>>()
            .join(" ");
        let lines = font.wrap_text(&text, 96.0);

        assert!(lines.len() > 1);
        assert!(lines.iter().all(|line| font.text_width(line) <= 96.0));
        assert_eq!(lines.join(" "), text);
    }

    #[test]
    fn dynamic_font_point_size_rejects_nonfinite_and_huge_values() {
        assert!(validate_dynamic_font_point_size(f32::NAN).is_err());
        assert!(validate_dynamic_font_point_size(MAX_DYNAMIC_FONT_POINT_SIZE + 1.0).is_err());
        assert_eq!(validate_dynamic_font_point_size(0.25).unwrap(), 1.0);
    }

    #[test]
    fn dynamic_font_atlas_dimensions_reject_zero_and_huge_values() {
        assert!(validate_dynamic_font_atlas_dimensions(0, 16).is_err());
        assert!(
            validate_dynamic_font_atlas_dimensions(MAX_DYNAMIC_FONT_ATLAS_DIMENSION + 1, 16)
                .is_err()
        );
        assert_eq!(
            validate_dynamic_font_atlas_dimensions(16, 16).unwrap(),
            16 * 16 * 4
        );
    }
}

mod image_effect_tests {
    use super::*;

    #[test]
    fn new_sets_name_and_defaults() {
        let pass = ShaderPassDescriptor::new("blur");
        assert_eq!(pass.effect_name, "blur");
        assert!(pass.enabled);
        assert!(pass.params.is_empty());
    }

    #[test]
    fn new_accepts_string_type() {
        let pass = ShaderPassDescriptor::new(String::from("vignette"));
        assert_eq!(pass.effect_name, "vignette");
    }

    #[test]
    fn params_can_be_mutated() {
        let mut pass = ShaderPassDescriptor::new("bloom");
        pass.params.insert("strength".to_string(), 0.5);
        pass.params.insert("radius".to_string(), 3.0);
        assert_eq!(pass.params.len(), 2);
        assert!((pass.params["strength"] - 0.5).abs() < 1e-5);
    }

    #[test]
    fn clone_produces_independent_copy() {
        let mut original = ShaderPassDescriptor::new("crt");
        original.params.insert("warp".to_string(), 0.1);
        let mut cloned = original.clone();
        cloned.enabled = false;
        assert!(original.enabled);
    }
}

mod mesh_tests {
    use super::*;

    #[test]
    fn new_creates_default_vertices() {
        let m = Mesh::new(4, MeshDrawMode::Triangles);
        assert_eq!(m.vertex_count(), 4);
        let v = m.get_vertex(0).unwrap();
        assert!((v.r - 1.0).abs() < 1e-5);
        assert!((v.a - 1.0).abs() < 1e-5);
    }

    #[test]
    fn from_vertices_preserves_data() {
        let verts = vec![
            MeshVertex {
                x: 10.0,
                y: 20.0,
                ..Default::default()
            },
            MeshVertex {
                x: 30.0,
                y: 40.0,
                ..Default::default()
            },
        ];
        let m = Mesh::from_vertices(verts, MeshDrawMode::Fan);
        assert_eq!(m.vertex_count(), 2);
        assert!((m.get_vertex(0).unwrap().x - 10.0).abs() < 1e-5);
    }

    #[test]
    fn from_vertex_rows_parses_all_fields() {
        let rows = [[1.0, 2.0, 0.5, 0.5, 0.1, 0.2, 0.3, 0.9]];
        let m = Mesh::from_vertex_rows(&rows, MeshDrawMode::Triangles);
        let v = m.get_vertex(0).unwrap();
        assert!((v.x - 1.0).abs() < 1e-5);
        assert!((v.y - 2.0).abs() < 1e-5);
        assert!((v.u - 0.5).abs() < 1e-5);
        assert!((v.b - 0.3).abs() < 1e-5);
        assert!((v.a - 0.9).abs() < 1e-5);
    }

    #[test]
    fn set_vertex_updates_position() {
        let mut m = Mesh::new(2, MeshDrawMode::Triangles);
        assert!(m.set_vertex(
            1,
            MeshVertex {
                x: 99.0,
                y: 88.0,
                ..Default::default()
            },
        ));
        assert!((m.get_vertex(1).unwrap().x - 99.0).abs() < 1e-5);
    }

    #[test]
    fn set_vertex_out_of_bounds_is_noop() {
        let mut m = Mesh::new(1, MeshDrawMode::Triangles);
        assert!(!m.set_vertex(5, MeshVertex::default()));
        assert_eq!(m.vertex_count(), 1);
    }

    #[test]
    fn get_vertex_out_of_bounds_returns_none() {
        let m = Mesh::new(1, MeshDrawMode::Triangles);
        assert!(m.get_vertex(10).is_none());
    }

    #[test]
    fn set_vertex_map_sets_indices() {
        let mut m = Mesh::new(4, MeshDrawMode::Triangles);
        m.set_vertex_map(vec![0, 1, 2, 2, 3, 0]);
        assert!(m.indices.is_some());
        assert_eq!(m.indices.as_ref().unwrap().len(), 6);
    }

    #[test]
    fn triangulate_triangles_mode_passthrough() {
        let m = Mesh::new(6, MeshDrawMode::Triangles);
        let tri = m.triangulate();
        assert_eq!(tri, vec![0, 1, 2, 3, 4, 5]);
    }

    #[test]
    fn triangulate_fan_mode() {
        let m = Mesh::new(5, MeshDrawMode::Fan);
        let tri = m.triangulate();
        assert_eq!(tri, vec![0, 1, 2, 0, 2, 3, 0, 3, 4]);
    }

    #[test]
    fn triangulate_strip_mode() {
        let m = Mesh::new(4, MeshDrawMode::Strip);
        let tri = m.triangulate();
        assert_eq!(tri, vec![0, 1, 2, 2, 1, 3]);
    }

    #[test]
    fn triangulate_fan_too_few_vertices() {
        let m = Mesh::new(2, MeshDrawMode::Fan);
        assert!(m.triangulate().is_empty());
    }

    #[test]
    fn triangulate_with_index_buffer() {
        let mut m = Mesh::new(4, MeshDrawMode::Triangles);
        m.set_vertex_map(vec![3, 2, 1]);
        let tri = m.triangulate();
        assert_eq!(tri, vec![3, 2, 1]);
    }

    #[test]
    fn validate_rejects_index_out_of_range() {
        let mut m = Mesh::new(3, MeshDrawMode::Triangles);
        m.set_vertex_map(vec![0, 1, 3]);
        assert_eq!(
            m.validate().unwrap_err(),
            MeshError::InvalidIndex {
                index_position: 2,
                vertex_index: 3,
                vertex_count: 3,
            }
        );
        assert!(m.try_triangulate().is_err());
        assert!(m.triangulate().is_empty());
    }

    #[test]
    fn validate_rejects_nonfinite_vertex_fields() {
        let mut m = Mesh::new(3, MeshDrawMode::Triangles);
        assert!(m.set_vertex(
            1,
            MeshVertex {
                x: f32::NAN,
                ..Default::default()
            },
        ));
        assert_eq!(
            m.validate().unwrap_err(),
            MeshError::NonFiniteVertex {
                vertex_index: 1,
                field: "x",
            }
        );
    }

    #[test]
    fn validate_rejects_triangle_lists_with_partial_triangles() {
        let m = Mesh::new(4, MeshDrawMode::Triangles);
        assert_eq!(
            m.validate().unwrap_err(),
            MeshError::InvalidTriangleIndexCount { index_count: 4 }
        );
        assert!(m.try_triangulate().is_err());
    }

    #[test]
    fn default_vertex_values() {
        let v = MeshVertex::default();
        assert!((v.x - 0.0).abs() < 1e-5);
        assert!((v.y - 0.0).abs() < 1e-5);
        assert!((v.r - 1.0).abs() < 1e-5);
        assert!((v.g - 1.0).abs() < 1e-5);
        assert!((v.b - 1.0).abs() < 1e-5);
        assert!((v.a - 1.0).abs() < 1e-5);
    }
}

mod shape_tests {
    use super::*;

    #[test]
    fn new_starts_empty_with_defaults() {
        let s = CompoundShape::new();
        assert_eq!(s.command_count(), 0);
        assert!((s.current_color[0] - 1.0).abs() < 1e-5);
        assert!((s.current_color[1] - 1.0).abs() < 1e-5);
        assert!((s.current_color[2] - 1.0).abs() < 1e-5);
        assert!((s.current_color[3] - 1.0).abs() < 1e-5);
        assert!((s.current_line_width - 1.0).abs() < 1e-5);
    }

    #[test]
    fn push_command_increments_count() {
        let mut s = CompoundShape::new();
        s.push_command(ShapeCommand::SetColor(1.0, 0.0, 0.0, 1.0));
        s.push_command(ShapeCommand::SetLineWidth(2.0));
        assert_eq!(s.command_count(), 2);
    }

    #[test]
    fn clear_resets_everything() {
        let mut s = CompoundShape::new();
        s.push_command(ShapeCommand::Circle {
            mode: DrawMode::Fill,
            x: 10.0,
            y: 10.0,
            r: 5.0,
        });
        s.current_color = [1.0, 0.0, 0.0, 1.0];
        s.current_line_width = 3.0;
        s.clear();
        assert_eq!(s.command_count(), 0);
        assert!((s.current_color[0] - 1.0).abs() < 1e-5);
        assert!((s.current_color[1] - 1.0).abs() < 1e-5);
        assert!((s.current_color[2] - 1.0).abs() < 1e-5);
        assert!((s.current_color[3] - 1.0).abs() < 1e-5);
        assert!((s.current_line_width - 1.0).abs() < 1e-5);
    }

    #[test]
    fn default_is_same_as_new() {
        let s = CompoundShape::default();
        assert_eq!(s.command_count(), 0);
    }

    #[test]
    fn clone_produces_independent_copy() {
        let mut original = CompoundShape::new();
        original.push_command(ShapeCommand::Line {
            x1: 0.0,
            y1: 0.0,
            x2: 10.0,
            y2: 10.0,
        });
        let mut cloned = original.clone();
        cloned.push_command(ShapeCommand::SetColor(1.0, 0.0, 0.0, 1.0));
        assert_eq!(original.command_count(), 1);
        assert_eq!(cloned.command_count(), 2);
    }
}

mod renderer_tests {
    use super::*;

    #[test]
    fn stencil_mode_default() {
        let sm = StencilMode::default();
        assert_eq!(sm.action, StencilAction::Keep);
        assert_eq!(sm.compare, lurek2d::render::renderer::CompareMode::Always);
        assert_eq!(sm.value, 0);
    }

    #[test]
    fn depth_mode_default_is_always() {
        let dm = DepthMode::default();
        assert_eq!(dm, DepthMode::Always);
    }

    #[test]
    fn blend_mode_default_is_alpha() {
        let bm = BlendMode::default();
        assert_eq!(bm, BlendMode::Alpha);
    }

    #[test]
    fn adaptive_circle_ellipse_segments_is_monotonic_by_extent() {
        let small = adaptive_circle_ellipse_segments(2.0, 2.0);
        let medium = adaptive_circle_ellipse_segments(8.0, 8.0);
        let large = adaptive_circle_ellipse_segments(32.0, 32.0);
        assert!(small <= medium, "expected non-decreasing segments");
        assert!(medium <= large, "expected non-decreasing segments");
    }

    #[test]
    fn adaptive_circle_ellipse_segments_clamps_tiny_and_huge_extents() {
        assert_eq!(adaptive_circle_ellipse_segments(0.0, 0.0), 12);
        assert_eq!(adaptive_circle_ellipse_segments(0.01, 0.02), 12);
        assert_eq!(adaptive_circle_ellipse_segments(10_000.0, 5_000.0), 96);
    }

    #[test]
    fn adaptive_circle_ellipse_segments_uses_max_axis_and_abs_values() {
        let by_x = adaptive_circle_ellipse_segments(40.0, 8.0);
        let by_y = adaptive_circle_ellipse_segments(8.0, 40.0);
        let negative = adaptive_circle_ellipse_segments(-40.0, -8.0);
        assert_eq!(by_x, by_y);
        assert_eq!(by_x, negative);
    }

    #[test]
    fn text_span_new_stores_all_fields() {
        let span = TextSpan::new("hello", 255, 128, 64, 200, 1.5);
        assert_eq!(span.text, "hello");
        assert_eq!(span.r, 255);
        assert_eq!(span.g, 128);
        assert_eq!(span.b, 64);
        assert_eq!(span.a, 200);
        assert!((span.scale - 1.5).abs() < 1e-5);
    }

    #[test]
    fn text_span_new_accepts_string() {
        let span = TextSpan::new(String::from("world"), 0, 0, 0, 255, 1.0);
        assert_eq!(span.text, "world");
    }

    #[test]
    fn physics_debug_config_default_values() {
        let cfg = PhysicsDebugConfig::default();
        assert!((cfg.body_color[1] - 1.0).abs() < 1e-5);
        assert!((cfg.static_color[0] - 0.8).abs() < 1e-5);
        assert!((cfg.line_width - 1.0).abs() < 1e-5);
    }

    #[test]
    fn texture_data_clone() {
        let mut td = TextureData::new(
            vec![255, 0, 0, 255],
            1,
            1,
            lurek2d::image::TextureColorSpace::Srgb,
        );
        td.mark_dirty();
        let td2 = td.clone();
        assert_eq!(td2.pixels, vec![255, 0, 0, 255]);
        assert_eq!(td2.width, 1);
        assert_eq!(td2.revision, 1);
    }
}

mod software_capture_tests {
    use super::*;

    #[test]
    fn stencil_write_and_test_mask_color_output() {
        let image = capture_commands_to_image(
            &[
                RenderCommand::SetColorMask(false, false, false, false),
                RenderCommand::StencilBegin {
                    action: StencilAction::Replace,
                    value: 1,
                },
                RenderCommand::Rectangle {
                    mode: DrawMode::Fill,
                    x: 10.0,
                    y: 10.0,
                    w: 20.0,
                    h: 20.0,
                },
                RenderCommand::StencilEnd,
                RenderCommand::SetColorMask(true, true, true, true),
                RenderCommand::SetStencilTest(Some((CompareMode::Equal, 1))),
                RenderCommand::SetColor(1.0, 0.0, 0.0, 1.0),
                RenderCommand::Rectangle {
                    mode: DrawMode::Fill,
                    x: 0.0,
                    y: 0.0,
                    w: 40.0,
                    h: 40.0,
                },
                RenderCommand::SetStencilTest(None),
            ],
            [0.0, 0.0, 0.0, 1.0],
        );
        let pixel = |x: u32, y: u32| {
            let bytes = image.as_bytes();
            let i = ((y * image.width() + x) * 4) as usize;
            [bytes[i], bytes[i + 1], bytes[i + 2], bytes[i + 3]]
        };
        assert_eq!(pixel(15, 15), [255, 0, 0, 255]);
        assert_eq!(pixel(5, 5), [0, 0, 0, 255]);
    }

    #[test]
    fn clamps_partly_offscreen_polygon_bbox_before_fill() {
        let (_, diagnostics) = capture_commands_to_image_with_diagnostics(
            &[
                RenderCommand::SetColor(1.0, 0.0, 0.0, 1.0),
                RenderCommand::Rectangle {
                    mode: DrawMode::Fill,
                    x: -10_000.0,
                    y: 10.0,
                    w: 10_010.0,
                    h: 10.0,
                },
            ],
            [0.0, 0.0, 0.0, 1.0],
        );
        assert_eq!(diagnostics.clamped_polygon_bboxes, 1);
        assert_eq!(diagnostics.skipped_offscreen_polygons, 0);
    }

    #[test]
    fn skips_fully_offscreen_polygon_bbox_before_fill() {
        let (_, diagnostics) = capture_commands_to_image_with_diagnostics(
            &[RenderCommand::Polygon {
                mode: DrawMode::Fill,
                vertices: vec![
                    -1_000_000.0,
                    -1_000_000.0,
                    -999_900.0,
                    -1_000_000.0,
                    -999_900.0,
                    -999_900.0,
                ],
            }],
            [0.0, 0.0, 0.0, 1.0],
        );
        assert_eq!(diagnostics.skipped_offscreen_polygons, 1);
    }

    #[test]
    fn counts_unsupported_capture_commands() {
        let (_, diagnostics) = capture_commands_to_image_with_diagnostics(
            &[RenderCommand::SetBlendMode(BlendMode::Add)],
            [0.0, 0.0, 0.0, 1.0],
        );
        assert_eq!(diagnostics.unsupported_capture_commands, 1);
    }
}

mod postfx_pipeline_tests {
    use super::*;

    #[test]
    fn postfx_cache_accessors_do_not_use_expect_panics() {
        let source = include_str!("../../../src/render/postfx_pipeline.rs");
        assert!(!source.contains("expect(\"postfx"));
    }

    #[test]
    fn params_to_uniform_empty_map_returns_zeros() {
        let params = HashMap::new();
        let u = params_to_uniform(&params);
        for &val in u.iter() {
            assert!((val - 0.0).abs() < 1e-5);
        }
    }

    #[test]
    fn params_to_uniform_maps_known_keys() {
        let mut params = HashMap::new();
        params.insert("strength".to_string(), 0.5);
        params.insert("intensity".to_string(), 1.2);
        params.insert("radius".to_string(), 3.0);
        params.insert("time".to_string(), 42.0);
        let u = params_to_uniform(&params);
        assert!((u[0] - 0.5).abs() < 1e-5);
        assert!((u[1] - 1.2).abs() < 1e-5);
        assert!((u[2] - 3.0).abs() < 1e-5);
        assert!((u[11] - 42.0).abs() < 1e-5);
    }

    #[test]
    fn params_to_uniform_unknown_keys_ignored() {
        let mut params = HashMap::new();
        params.insert("nonexistent".to_string(), 99.0);
        let u = params_to_uniform(&params);
        assert!((u[0] - 0.0).abs() < 1e-5);
    }

    #[test]
    fn params_to_uniform_all_slots_populated() {
        let mut params = HashMap::new();
        params.insert("strength".to_string(), 1.0);
        params.insert("intensity".to_string(), 2.0);
        params.insert("radius".to_string(), 3.0);
        params.insert("thickness".to_string(), 4.0);
        params.insert("focus_x".to_string(), 5.0);
        params.insert("focus_y".to_string(), 6.0);
        params.insert("density".to_string(), 7.0);
        params.insert("exposure".to_string(), 8.0);
        params.insert("color_r".to_string(), 9.0);
        params.insert("color_g".to_string(), 10.0);
        params.insert("color_b".to_string(), 11.0);
        params.insert("time".to_string(), 12.0);
        params.insert("frequency".to_string(), 13.0);
        params.insert("amplitude".to_string(), 14.0);
        params.insert("samples".to_string(), 15.0);
        params.insert("palette_size".to_string(), 16.0);
        let u = params_to_uniform(&params);
        for (i, &val) in u.iter().enumerate() {
            assert_eq!(val, (i + 1) as f32, "slot {i} mismatch");
        }
    }
}

mod obj_loader_tests {
    use lurek2d::render::obj_loader::ObjLoader;
    use std::path::{Path, PathBuf};

    fn parse_obj_error_contains(src: &str, expected: &str) {
        parse_obj_error_contains_with_base(src, Path::new("."), expected);
    }

    fn parse_obj_error_contains_with_base(src: &str, base: &Path, expected: &str) {
        let result = ObjLoader::parse_obj(src, base);
        let message = match result {
            Ok(_) => panic!("expected OBJ parse error containing '{expected}'"),
            Err(err) => err.to_string(),
        };
        assert!(
            message.contains(expected),
            "expected '{message}' to contain '{expected}'"
        );
    }

    fn fixture_base() -> PathBuf {
        Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("tests")
            .join("rust")
            .join("fixtures")
            .join("render")
            .join("obj")
    }

    #[test]
    fn obj_rejects_zero_face_index() {
        parse_obj_error_contains("v 0 0 0\nv 1 0 0\nv 0 1 0\nf 0 1 2\n", "got 0");
    }

    #[test]
    fn obj_rejects_positive_out_of_range_face_index() {
        parse_obj_error_contains("v 0 0 0\nv 1 0 0\nv 0 1 0\nf 1 2 4\n", "out of range");
    }

    #[test]
    fn obj_rejects_too_negative_face_index() {
        parse_obj_error_contains("v 0 0 0\nv 1 0 0\nv 0 1 0\nf -4 -1 -2\n", "out of range");
    }

    #[test]
    fn obj_rejects_mtllib_parent_traversal() {
        parse_obj_error_contains("mtllib ../secret.mtl\n", "escapes");
    }

    #[test]
    fn obj_rejects_absolute_mtllib_path() {
        let absolute = fixture_base().join("bad_material.mtl");
        parse_obj_error_contains(
            &format!("mtllib {}\n", absolute.display()),
            "must be relative",
        );
    }

    #[test]
    fn obj_rejects_non_mtl_material_library_extension() {
        parse_obj_error_contains("mtllib material.txt\n", "must use .mtl extension");
    }

    #[test]
    fn obj_reports_missing_material_library_instead_of_ignoring_it() {
        parse_obj_error_contains_with_base("mtllib missing.mtl\n", &fixture_base(), "OBJ IO error");
    }

    #[test]
    fn obj_rejects_malformed_material_diffuse_color() {
        parse_obj_error_contains_with_base(
            "mtllib bad_material.mtl\n",
            &fixture_base(),
            "expected float",
        );
    }
}

mod render_diagnostics_tests {
    use lurek2d::render::RenderDiagnostics;

    fn renderer_command_source() -> &'static str {
        concat!(
            include_str!("../../../src/render/gpu_renderer/frame_basic.rs"),
            include_str!("../../../src/render/gpu_renderer/frame_mid.rs"),
            include_str!("../../../src/render/gpu_renderer/frame_advanced.rs"),
        )
    }

    fn source_section<'a>(source: &'a str, start: &str, end: &str) -> &'a str {
        source
            .split(start)
            .nth(1)
            .unwrap_or_else(|| panic!("missing source marker {start}"))
            .split(end)
            .next()
            .unwrap_or_else(|| panic!("missing source end marker {end}"))
    }

    #[test]
    fn records_drop_reasons_and_invalid_resources() {
        let mut diagnostics = RenderDiagnostics::default();

        diagnostics.record_missing_texture();
        diagnostics.record_missing_canvas();
        diagnostics.record_missing_mesh();
        diagnostics.record_missing_shape();
        diagnostics.record_missing_static_geometry();
        diagnostics.record_missing_instance_buffer();
        diagnostics.record_unsupported_instanced_sprite_batch();
        diagnostics.record_invalid_texture_upload();
        diagnostics.record_invalid_canvas_allocation();
        diagnostics.record_invalid_mesh();
        diagnostics.record_invalid_render_input();
        diagnostics.record_shader_pipeline_failure();
        diagnostics.record_buffer_growth_event();
        diagnostics.record_shadow_dispatch(4, 8);

        assert!(diagnostics.has_findings());
        assert_eq!(diagnostics.dropped_commands, 8);
        assert_eq!(diagnostics.missing_textures, 1);
        assert_eq!(diagnostics.missing_canvases, 1);
        assert_eq!(diagnostics.missing_meshes, 1);
        assert_eq!(diagnostics.missing_shapes, 1);
        assert_eq!(diagnostics.missing_static_geometry, 1);
        assert_eq!(diagnostics.missing_instance_buffers, 1);
        assert_eq!(diagnostics.unsupported_instanced_sprite_batches, 1);
        assert_eq!(diagnostics.invalid_texture_uploads, 1);
        assert_eq!(diagnostics.invalid_canvas_allocations, 1);
        assert_eq!(diagnostics.invalid_meshes, 1);
        assert_eq!(diagnostics.invalid_render_inputs, 1);
        assert_eq!(diagnostics.shader_pipeline_failures, 1);
        assert_eq!(diagnostics.buffer_growth_events, 1);
        assert_eq!(diagnostics.shadow_lights_rendered, 1);
        assert_eq!(diagnostics.shadow_edges_collected, 4);
        assert_eq!(diagnostics.shadow_edges_culled, 8);
        assert_eq!(diagnostics.finding_total(), 34);
    }

    #[test]
    fn resets_and_saturates_counters() {
        let mut diagnostics = RenderDiagnostics {
            dropped_commands: u32::MAX,
            ..RenderDiagnostics::default()
        };

        diagnostics.record_missing_texture();
        assert_eq!(diagnostics.dropped_commands, u32::MAX);
        assert_eq!(diagnostics.missing_textures, 1);
        assert_eq!(diagnostics.finding_total(), u32::MAX);

        diagnostics.reset();
        assert_eq!(diagnostics, RenderDiagnostics::default());
        assert!(!diagnostics.has_findings());
    }

    #[test]
    fn gpu_renderer_preparation_reports_missing_texture_and_canvas_sources() {
        let source = renderer_command_source();
        let texture_sections = [
            ("RenderCommand::DrawImage {", "RenderCommand::DrawImageEx {"),
            ("RenderCommand::DrawImageEx {", "RenderCommand::DrawQuad {"),
            (
                "RenderCommand::DrawQuad {",
                "RenderCommand::DrawTexturedQuad {",
            ),
            (
                "RenderCommand::DrawTexturedQuad {",
                "RenderCommand::DrawBatch {",
            ),
            ("RenderCommand::DrawBatch {", "RenderCommand::SetCanvas"),
            ("RenderCommand::DrawNineSlice {", "RenderCommand::SetShader"),
        ];

        for (start, end) in texture_sections {
            assert!(
                source_section(source, start, end).contains("record_missing_texture()"),
                "{start} should report missing texture resources"
            );
        }

        assert!(
            source_section(
                source,
                "RenderCommand::DrawCanvas {",
                "RenderCommand::SetPointSize"
            )
            .contains("record_missing_canvas()"),
            "DrawCanvas should report missing canvas resources"
        );
    }

    #[test]
    fn gpu_renderer_draw_rich_text_uses_font_atlas_instead_of_noop() {
        let renderer_source = renderer_command_source();
        let renderer_section = source_section(
            renderer_source,
            "RenderCommand::DrawRichText {",
            "RenderCommand::DrawConvexFan",
        );
        let text_replay_source = include_str!("../../../src/render/gpu_text_replay.rs");

        assert!(!renderer_source.contains("RenderCommand::DrawRichText { .. } => {}"));
        assert!(renderer_section.contains("replay_rich_text"));
        assert!(text_replay_source.contains("TexRef::FontAtlas(font_key)"));
        assert!(text_replay_source.contains("span_color"));
    }

    #[test]
    fn gpu_renderer_print_delegates_to_text_replay() {
        let renderer_source = renderer_command_source();
        let print_section = source_section(
            renderer_source,
            "RenderCommand::Print {",
            "RenderCommand::DrawImage",
        );
        let formatted_section = source_section(
            renderer_source,
            "RenderCommand::PrintFormatted {",
            "RenderCommand::StencilBegin",
        );
        let text_replay_source = include_str!("../../../src/render/gpu_text_replay.rs");

        assert!(print_section.contains("replay_plain_text"));
        assert!(formatted_section.contains("replay_formatted_text"));
        assert!(text_replay_source.contains("pub(crate) fn replay_plain_text"));
        assert!(text_replay_source.contains("pub(crate) fn replay_formatted_text"));
        assert!(text_replay_source.contains("wrap_text"));
        assert!(text_replay_source.contains("ensure_font_atlas"));
    }

    #[test]
    fn gpu_renderer_draw_shape_replays_compound_shape_commands() {
        let renderer_source = renderer_command_source();
        let renderer_section = source_section(
            renderer_source,
            "RenderCommand::DrawShape {",
            "RenderCommand::DrawParticleSystem",
        );
        let replay_source = include_str!("../../../src/render/gpu_shape_replay.rs");

        assert!(!renderer_source.contains("RenderCommand::DrawShape { .. } => {}"));
        assert!(renderer_section.contains("shapes.get(*shape_key)"));
        assert!(renderer_section.contains("record_missing_shape()"));
        assert!(renderer_section.contains("validate_compound_shape"));
        assert!(renderer_section.contains("replay_compound_shape"));
        assert!(replay_source.contains("ShapeCommand::Rectangle"));
        assert!(replay_source.contains("ShapeCommand::Arc"));
    }
}

mod gpu_shadow_tests {
    use lurek2d::light::occluder::Occluder;
    use lurek2d::math::Vec2;
    use lurek2d::render::gpu_shadows::{
        collect_shadow_edges, collect_shadow_edges_with_cache, collect_shadow_edges_with_stats,
        ShadowEdgeCache,
    };

    fn square_at(x: f32, y: f32) -> Occluder {
        let mut occluder = Occluder::new(vec![
            Vec2::new(-1.0, -1.0),
            Vec2::new(1.0, -1.0),
            Vec2::new(1.0, 1.0),
            Vec2::new(-1.0, 1.0),
        ]);
        occluder.set_position(Vec2::new(x, y));
        occluder
    }

    #[test]
    fn shadow_edge_collection_culls_occluders_outside_light_radius() {
        let near = square_at(4.0, 0.0);
        let far = square_at(100.0, 0.0);
        let collection = collect_shadow_edges_with_stats(0.0, 0.0, 10.0, 0xFFFF, [&near, &far]);

        assert_eq!(collection.edges.len(), 4);
        assert_eq!(collection.edges_collected, 4);
        assert_eq!(collection.edges_culled_by_radius, 4);
    }

    #[test]
    fn shadow_edge_collection_preserves_mask_filtering_and_legacy_wrapper() {
        let mut matching = square_at(100.0, 0.0);
        matching.set_light_mask(0b0010);
        let mut skipped_by_mask = square_at(0.0, 0.0);
        skipped_by_mask.set_light_mask(0b0100);

        let edges = collect_shadow_edges(0.0, 0.0, 0b0010, [&matching, &skipped_by_mask]);

        assert_eq!(edges.len(), 4);
    }

    #[test]
    fn shadow_edge_cache_reuses_edges_until_occluder_generation_changes() {
        let mut cache = ShadowEdgeCache::default();
        let mut occluder = square_at(0.0, 0.0);

        let first =
            collect_shadow_edges_with_cache(0.0, 0.0, 10.0, 0xFFFF, [&occluder], &mut cache);
        assert_eq!(first.edges.len(), 4);
        assert_eq!(first.cache_hits, 0);
        assert_eq!(first.cache_misses, 1);

        let second =
            collect_shadow_edges_with_cache(4.0, 0.0, 10.0, 0xFFFF, [&occluder], &mut cache);
        assert_eq!(second.edges.len(), 4);
        assert_eq!(second.cache_hits, 1);
        assert_eq!(second.cache_misses, 0);

        let generation_before = occluder.edge_generation();
        occluder.set_position(Vec2::new(2.0, 0.0));
        assert_ne!(occluder.edge_generation(), generation_before);

        let third =
            collect_shadow_edges_with_cache(0.0, 0.0, 10.0, 0xFFFF, [&occluder], &mut cache);
        assert_eq!(third.edges.len(), 4);
        assert_eq!(third.cache_hits, 0);
        assert_eq!(third.cache_misses, 1);
    }
}

mod frame_buffer_tests {
    use lurek2d::render::gpu_state::{FrameRenderBufferReservations, FrameRenderBuffers};

    #[test]
    fn frame_render_buffers_clear_without_shrinking_capacity() {
        let mut buffers = FrameRenderBuffers::default();
        buffers.reserve_for_frame(FrameRenderBufferReservations {
            color_verts: 8,
            color_idxs: 12,
            tex_verts: 16,
            tex_idxs: 20,
            particle_verts: 5,
            particle_idxs: 7,
            draws: 4,
            instances: 6,
        });
        buffers.scratch_color_verts.reserve(10);
        buffers.scratch_color_idxs.reserve(14);
        buffers.scratch_tex_verts.reserve(18);
        buffers.scratch_tex_idxs.reserve(22);
        let capacities = buffers.capacities();

        buffers.clear_for_frame();

        assert_eq!(buffers.lengths(), [0; 13]);
        assert_eq!(buffers.capacities(), capacities);
        assert!(capacities[0] >= 8);
        assert!(capacities[1] >= 12);
        assert!(capacities[2] >= 16);
        assert!(capacities[3] >= 20);
        assert!(capacities[4] >= 5);
        assert!(capacities[5] >= 7);
        assert!(capacities[6] >= 4);
        assert!(capacities[7] >= 6);
        assert!(capacities[8] >= 10);
        assert!(capacities[9] >= 14);
        assert!(capacities[10] >= 18);
        assert!(capacities[11] >= 22);
        assert!(capacities[12] >= 4);
    }
}

mod render_input_validation_tests {
    use lurek2d::math::Vec2;
    use lurek2d::render::input_validation::{
        validate_compound_shape, validate_render_command, validate_render_command_with_category,
        RenderInputError, RenderInputLimits,
    };
    use lurek2d::render::shape::{CompoundShape, ShapeCommand};
    use lurek2d::render::{DrawMode, RenderCommand, RenderCommandCategory};
    use lurek2d::runtime::resource_keys::{CanvasKey, FontKey};
    use slotmap::SlotMap;

    fn dummy_font_key() -> FontKey {
        let mut fonts: SlotMap<FontKey, ()> = SlotMap::with_key();
        fonts.insert(())
    }

    fn dummy_canvas_key() -> CanvasKey {
        let mut canvases: SlotMap<CanvasKey, ()> = SlotMap::with_key();
        canvases.insert(())
    }

    #[test]
    fn command_category_groups_representative_render_families() {
        assert_eq!(
            RenderCommand::SetColor(1.0, 1.0, 1.0, 1.0).category(),
            RenderCommandCategory::State
        );
        assert_eq!(
            RenderCommand::Translate { x: 1.0, y: 2.0 }.category(),
            RenderCommandCategory::Transform
        );
        assert_eq!(
            RenderCommand::Rectangle {
                mode: DrawMode::Fill,
                x: 0.0,
                y: 0.0,
                w: 8.0,
                h: 8.0,
            }
            .category(),
            RenderCommandCategory::Shape
        );
        assert_eq!(
            RenderCommand::DrawRichText {
                font_key: dummy_font_key(),
                spans: Vec::new(),
                x: 0.0,
                y: 0.0,
            }
            .category(),
            RenderCommandCategory::Text
        );
        assert_eq!(
            RenderCommand::RegisterCanvas {
                canvas_key: dummy_canvas_key(),
                width: 32,
                height: 32,
            }
            .category(),
            RenderCommandCategory::Canvas
        );
        assert_eq!(
            RenderCommand::BeginPostFx { stack_id: 9 }.category(),
            RenderCommandCategory::Effect
        );
    }

    #[test]
    fn rejects_nonfinite_shape_coordinates_before_tessellation() {
        let err = validate_render_command(
            &RenderCommand::Rectangle {
                mode: DrawMode::Fill,
                x: f32::NAN,
                y: 0.0,
                w: 10.0,
                h: 10.0,
            },
            &RenderInputLimits::default(),
        )
        .unwrap_err();

        assert_eq!(
            err,
            RenderInputError::NonFinite {
                field: "rectangle.x"
            }
        );
    }

    #[test]
    fn categorized_validation_error_preserves_command_family_and_source() {
        let err = validate_render_command_with_category(
            &RenderCommand::Print {
                font_key: dummy_font_key(),
                text: "bad scale".to_string(),
                x: 0.0,
                y: 0.0,
                scale: 0.0,
            },
            &RenderInputLimits::default(),
        )
        .unwrap_err();

        assert_eq!(err.category, RenderCommandCategory::Text);
        assert_eq!(
            err.error,
            RenderInputError::NonPositive {
                field: "print.scale"
            }
        );
        assert_eq!(
            err.to_string(),
            "Text command: print.scale must be greater than zero"
        );
    }

    #[test]
    fn validates_compound_shape_commands_before_gpu_replay() {
        let mut shape = CompoundShape::new();
        shape.push_command(ShapeCommand::SetColor(1.0, 0.5, 0.0, 1.0));
        shape.push_command(ShapeCommand::Rectangle {
            mode: DrawMode::Fill,
            x: 0.0,
            y: 0.0,
            w: 8.0,
            h: 4.0,
        });

        assert!(validate_compound_shape(&shape, &RenderInputLimits::default()).is_ok());
    }

    #[test]
    fn rejects_invalid_compound_shape_commands_before_tessellation() {
        let mut shape = CompoundShape::new();
        shape.push_command(ShapeCommand::Polygon {
            mode: DrawMode::Fill,
            vertices: vec![0.0, 0.0, 1.0],
        });

        assert_eq!(
            validate_compound_shape(&shape, &RenderInputLimits::default()).unwrap_err(),
            RenderInputError::OddCoordinateCount {
                field: "shape.polygon.vertices",
                len: 3,
            }
        );

        let mut bad_line_width = CompoundShape::new();
        bad_line_width.push_command(ShapeCommand::SetLineWidth(0.0));
        assert_eq!(
            validate_compound_shape(&bad_line_width, &RenderInputLimits::default()).unwrap_err(),
            RenderInputError::NonPositive {
                field: "shape.line_width",
            }
        );
    }

    #[test]
    fn rejects_invalid_state_scalars_and_color_ranges() {
        assert_eq!(
            validate_render_command(
                &RenderCommand::SetLineWidth(0.0),
                &RenderInputLimits::default()
            )
            .unwrap_err(),
            RenderInputError::NonPositive {
                field: "line_width"
            }
        );
        assert_eq!(
            validate_render_command(
                &RenderCommand::SetColor(1.2, 0.0, 0.0, 1.0),
                &RenderInputLimits::default()
            )
            .unwrap_err(),
            RenderInputError::OutOfRange { field: "SetColor" }
        );
    }

    #[test]
    fn rejects_segment_and_vertex_count_over_limits() {
        let limits = RenderInputLimits {
            max_vertices_per_command: 2,
            max_segments_per_command: 4,
            max_postfx_passes: 1,
        };

        assert_eq!(
            validate_render_command(
                &RenderCommand::Arc {
                    mode: DrawMode::Line,
                    x: 0.0,
                    y: 0.0,
                    radius: 5.0,
                    angle1: 0.0,
                    angle2: 1.0,
                    segments: 5,
                },
                &limits,
            )
            .unwrap_err(),
            RenderInputError::TooMany {
                field: "arc.segments",
                len: 5,
                max: 4,
            }
        );
        assert_eq!(
            validate_render_command(
                &RenderCommand::Points {
                    points: vec![(0.0, 0.0), (1.0, 1.0), (2.0, 2.0)]
                },
                &limits,
            )
            .unwrap_err(),
            RenderInputError::TooMany {
                field: "points",
                len: 3,
                max: 2,
            }
        );
    }

    #[test]
    fn validates_array_lengths_for_polygon_like_commands() {
        assert_eq!(
            validate_render_command(
                &RenderCommand::Polygon {
                    mode: DrawMode::Fill,
                    vertices: vec![0.0, 0.0, 1.0],
                },
                &RenderInputLimits::default(),
            )
            .unwrap_err(),
            RenderInputError::OddCoordinateCount {
                field: "polygon.vertices",
                len: 3,
            }
        );
        assert_eq!(
            validate_render_command(
                &RenderCommand::DrawConvexFan {
                    vertices: vec![Vec2::new(0.0, 0.0), Vec2::new(1.0, 0.0)],
                    uvs: vec![Vec2::new(0.0, 0.0)],
                    texture_key: None,
                    tint: [1.0, 1.0, 1.0, 1.0],
                    blend: lurek2d::render::BlendMode::Alpha,
                },
                &RenderInputLimits::default(),
            )
            .unwrap_err(),
            RenderInputError::LengthMismatch {
                field: "convex_fan.uvs",
                expected: 2,
                actual: 1,
            }
        );
    }

    #[test]
    fn accepts_valid_common_render_commands() {
        let limits = RenderInputLimits::default();
        assert!(
            validate_render_command(&RenderCommand::SetColor(0.25, 0.5, 0.75, 1.0), &limits)
                .is_ok()
        );
        assert!(validate_render_command(
            &RenderCommand::DrawQuadBezier {
                start: Vec2::new(0.0, 0.0),
                control: Vec2::new(4.0, 8.0),
                end: Vec2::new(10.0, 0.0),
                segments: 16,
            },
            &limits,
        )
        .is_ok());
    }
}

mod gpu_renderer_tests {
    use lurek2d::render::gpu_frame_builder::merge_adjacent_prepared_draws;
    use lurek2d::render::gpu_pipeline::{
        build_custom_color_shader_source, build_custom_light_shader_source,
        build_custom_particle_shader_source, build_custom_texture_shader_source,
        build_custom_textured_particle_shader_source, depth_stencil_state, GeometryKind,
        GpuStencilMode,
    };
    use lurek2d::render::gpu_resources::{
        canvas_texture_needs_recreate, is_builtin_static_geometry_key, texture_needs_upload,
        validate_canvas_size, validate_rgba_texture_upload,
    };
    use lurek2d::render::gpu_shaders::ShaderUniformKind;
    use lurek2d::render::gpu_tess::{
        append_color_draw_range, color_write_mask_bits, color_write_mask_from_bits,
        normalize_scissor, parse_filter_mode, sanitize_arc_segments, uniform_bytes,
    };
    use lurek2d::render::gpu_types::{PreparedDraw, RenderTargetId};
    use lurek2d::render::renderer::{CompareMode, StencilAction};
    use lurek2d::render::shader::validate_uniform_name;
    use lurek2d::render::{BlendMode, Shader, ShaderTarget, TextureData, UniformValue};
    use lurek2d::runtime::resource_keys::StaticGeometryKey;

    const VALID_WGSL_FRAGMENT_SHADER: &str = r#"
    @fragment
    fn fs_main(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    ) -> @location(0) vec4<f32> {
    return color + vec4<f32>(uv, 0.0, 0.0);
    }
    "#;
    const SCREEN_SHADER: &str = r#"
    @fragment
    fn fs_main(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) pixel: vec2<f32>,
    @location(3) resolution: vec2<f32>,
    @location(4) texel: vec2<f32>,
    ) -> @location(0) vec4<f32> {
    return color + vec4<f32>(uv * texel * resolution + pixel * 0.0, 0.0, 0.0);
    }
    "#;
    const PARTICLE_SHADER: &str = r#"
    @fragment
    fn fs_main(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) local_pos: vec2<f32>,
    @location(3) world_pos: vec2<f32>,
    @location(4) velocity: vec2<f32>,
    @location(5) age: f32,
    @location(6) lifetime: f32,
    @location(7) seed: f32,
    @location(8) sampled_color: vec4<f32>,
    ) -> @location(0) vec4<f32> {
    return sampled_color + color + vec4<f32>(uv + local_pos * 0.0 + world_pos * 0.0 + velocity * 0.0, age + lifetime + seed, 0.0);
    }
    "#;
    const LIGHT_SHADER: &str = r#"
    @fragment
    fn fs_main(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    @location(2) world_pos: vec2<f32>,
    @location(3) light_pos: vec2<f32>,
    @location(4) normal_hint: vec2<f32>,
    @location(5) distance_norm: f32,
    @location(6) radius: f32,
    @location(7) intensity: f32,
    @location(8) shadow_factor: f32,
    @location(9) ambient_color: vec4<f32>,
    @location(10) direction_spot: vec4<f32>,
    ) -> @location(0) vec4<f32> {
    let falloff = max(1.0 - distance_norm, 0.0) * intensity * shadow_factor;
    return vec4<f32>(color.rgb * falloff + ambient_color.rgb * 0.0 + (world_pos + light_pos + normal_hint + uv).x * 0.0 + direction_spot.xyz * 0.0, color.a + radius * 0.0 + direction_spot.w * 0.0);
    }
    "#;
    const SPRITE_SHADER: &str = r#"
    @fragment
    fn fs_main(
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
    ) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb * vec3<f32>(uv, 1.0), color.a);
    }
    "#;

    fn prepared_color_draw(idx_start: u32, idx_count: u32) -> PreparedDraw {
        PreparedDraw {
            target: RenderTargetId::Screen,
            geometry: GeometryKind::Color,
            texture_ref: None,
            idx_start,
            idx_count,
            blend_mode: BlendMode::Alpha,
            scissor: None,
            color_mask_bits: color_write_mask_bits((true, true, true, true)),
            shader: None,
            stencil_mode: GpuStencilMode::Disabled,
            stencil_reference: 0,
            static_geometry: None,
            instance_buffer: None,
            instance_start: 0,
            instance_count: 0,
        }
    }

    #[test]
    fn scissor_normalization_clamps_to_target_bounds() {
        assert_eq!(
            normalize_scissor(Some((-1.2, 2.8, 20.1, 100.0)), 10, 8),
            Some((0, 2, 10, 6))
        );
    }
    #[test]
    fn scissor_normalization_discards_fully_offscreen_rects() {
        assert_eq!(normalize_scissor(Some((11.0, 0.0, 2.0, 2.0)), 10, 8), None);
    }
    #[test]
    fn color_mask_bits_round_trip_selected_channels() {
        let bits = color_write_mask_bits((true, false, true, false));
        let mask = color_write_mask_from_bits(bits);
        assert_eq!(mask, wgpu::ColorWrites::RED | wgpu::ColorWrites::BLUE);
    }
    #[test]
    fn filter_mode_maps_linear_and_defaults_to_nearest() {
        assert_eq!(parse_filter_mode("linear"), wgpu::FilterMode::Linear);
        assert_eq!(parse_filter_mode("nearest"), wgpu::FilterMode::Nearest);
        assert_eq!(parse_filter_mode("unsupported"), wgpu::FilterMode::Nearest);
    }

    #[test]
    fn color_draw_range_records_existing_shared_index_span() {
        let mut draws = Vec::new();
        append_color_draw_range(
            &mut draws,
            3,
            3,
            RenderTargetId::Screen,
            BlendMode::Alpha,
            None,
            color_write_mask_bits((true, true, true, true)),
            None,
            GpuStencilMode::Disabled,
            0,
        );
        assert!(draws.is_empty());

        append_color_draw_range(
            &mut draws,
            3,
            9,
            RenderTargetId::Screen,
            BlendMode::Alpha,
            Some((1, 2, 3, 4)),
            color_write_mask_bits((true, false, true, false)),
            None,
            GpuStencilMode::Disabled,
            7,
        );

        assert_eq!(draws.len(), 1);
        let draw = draws[0];
        assert_eq!(draw.idx_start, 3);
        assert_eq!(draw.idx_count, 6);
        assert_eq!(draw.scissor, Some((1, 2, 3, 4)));
        assert_eq!(
            draw.color_mask_bits,
            color_write_mask_bits((true, false, true, false))
        );
        assert_eq!(draw.stencil_reference, 7);
    }

    #[test]
    fn frame_builder_merges_adjacent_compatible_prepared_draws() {
        let mut draws = vec![prepared_color_draw(0, 6), prepared_color_draw(6, 6)];
        let mut scratch = Vec::new();

        let merged = merge_adjacent_prepared_draws(&mut draws, &mut scratch);

        assert_eq!(merged, 1);
        assert_eq!(draws.len(), 1);
        assert_eq!(draws[0].idx_start, 0);
        assert_eq!(draws[0].idx_count, 12);
        assert!(scratch.is_empty());
    }

    #[test]
    fn frame_builder_keeps_resource_identity_boundaries() {
        let mut static_draw = prepared_color_draw(0, 6);
        static_draw.static_geometry = Some(StaticGeometryKey::default());
        let mut instanced_a = prepared_color_draw(12, 6);
        instanced_a.geometry = GeometryKind::ColorInstanced;
        instanced_a.instance_start = 0;
        instanced_a.instance_count = 1;
        let mut instanced_b = prepared_color_draw(18, 6);
        instanced_b.geometry = GeometryKind::ColorInstanced;
        instanced_b.instance_start = 1;
        instanced_b.instance_count = 1;
        let mut draws = vec![
            static_draw,
            prepared_color_draw(6, 6),
            instanced_a,
            instanced_b,
        ];
        let mut scratch = Vec::new();

        let merged = merge_adjacent_prepared_draws(&mut draws, &mut scratch);

        assert_eq!(merged, 0);
        assert_eq!(draws.len(), 4);
        assert_eq!(draws[0].static_geometry, Some(StaticGeometryKey::default()));
        assert_eq!(draws[2].instance_start, 0);
        assert_eq!(draws[3].instance_start, 1);
    }

    #[test]
    fn texture_upload_validation_rejects_invalid_dimensions_and_lengths() {
        let limits = wgpu::Limits {
            max_texture_dimension_2d: 64,
            ..Default::default()
        };
        assert!(validate_rgba_texture_upload(0, 1, 4, &limits).is_err());
        assert!(validate_rgba_texture_upload(65, 1, 260, &limits).is_err());
        assert!(validate_rgba_texture_upload(2, 2, 12, &limits).is_err());
        assert!(validate_rgba_texture_upload(2, 2, 16, &limits).is_ok());
    }

    #[test]
    fn texture_upload_freshness_tracks_dimensions_and_revision() {
        let mut texture =
            TextureData::new(vec![255; 16], 2, 2, lurek2d::image::TextureColorSpace::Srgb);
        assert!(texture_needs_upload(None, &texture));
        assert!(!texture_needs_upload(Some((2, 2, 0)), &texture));
        assert!(texture_needs_upload(Some((1, 2, 0)), &texture));

        texture.mark_dirty();
        assert!(texture_needs_upload(Some((2, 2, 0)), &texture));
        assert!(!texture_needs_upload(Some((2, 2, 1)), &texture));
    }

    #[test]
    fn canvas_validation_and_resize_detection_cover_zero_limit_and_size_drift() {
        let limits = wgpu::Limits {
            max_texture_dimension_2d: 64,
            ..Default::default()
        };
        assert!(validate_canvas_size(0, 32, &limits).is_err());
        assert!(validate_canvas_size(32, 65, &limits).is_err());
        assert!(validate_canvas_size(32, 32, &limits).is_ok());
        assert!(canvas_texture_needs_recreate(None, 32, 32));
        assert!(canvas_texture_needs_recreate(Some((16, 32)), 32, 32));
        assert!(!canvas_texture_needs_recreate(Some((32, 32)), 32, 32));
    }

    #[test]
    fn builtin_static_quad_key_is_not_user_mesh_geometry() {
        assert!(is_builtin_static_geometry_key(StaticGeometryKey::default()));
    }

    #[test]
    fn arc_segment_sanitizer_prevents_zero_segments() {
        assert_eq!(sanitize_arc_segments(0), 1);
        assert_eq!(sanitize_arc_segments(8), 8);
    }

    #[test]
    fn uniform_bytes_pack_bool_and_vec4_values() {
        let bool_bytes = uniform_bytes(&UniformValue::Bool(true));
        let vec4_bytes = uniform_bytes(&UniformValue::Vec4([1.0, 2.0, 3.0, 4.0]));
        assert_eq!(u32::from_ne_bytes(bool_bytes[..4].try_into().unwrap()), 1);
        assert_eq!(
            f32::from_ne_bytes(vec4_bytes[0..4].try_into().unwrap()),
            1.0
        );
        assert_eq!(
            f32::from_ne_bytes(vec4_bytes[4..8].try_into().unwrap()),
            2.0
        );
        assert_eq!(
            f32::from_ne_bytes(vec4_bytes[8..12].try_into().unwrap()),
            3.0
        );
        assert_eq!(
            f32::from_ne_bytes(vec4_bytes[12..16].try_into().unwrap()),
            4.0
        );
    }

    #[test]
    fn shader_send_rejects_invalid_or_reserved_uniform_names() {
        assert!(validate_uniform_name("tint_color").is_ok());
        assert!(validate_uniform_name("bad name").is_err());
        assert!(validate_uniform_name("lurek").is_err());
        assert!(validate_uniform_name("let").is_err());

        let mut shader = Shader::new(VALID_WGSL_FRAGMENT_SHADER.to_string())
            .expect("expected valid fragment shader");
        assert!(shader
            .send("tint_color".to_string(), UniformValue::Vec4([1.0; 4]))
            .is_ok());
        assert!(shader
            .send("bad;name".to_string(), UniformValue::Float(1.0))
            .is_err());
        assert!(shader.has_uniform("tint_color"));
        assert!(!shader.has_uniform("bad;name"));
    }

    #[test]
    fn custom_color_shader_source_is_parseable_with_uniforms() {
        let uniform_signature = vec![
            ("tint".to_string(), ShaderUniformKind::Vec4),
            ("time_scale".to_string(), ShaderUniformKind::Float),
        ];
        let shader = Shader::new(VALID_WGSL_FRAGMENT_SHADER.to_string())
            .expect("expected valid fragment shader");
        let source = build_custom_color_shader_source(&shader, &uniform_signature);
        assert!(source.contains("@group(1) @binding(0) var<uniform> tint: vec4<f32>;"));
        assert!(source.contains("@group(1) @binding(1) var<uniform> time_scale: f32;"));
        assert!(source.contains("fn lurek_fragment_main"));
        wgpu::naga::front::wgsl::parse_str(&source)
            .expect("wrapped color shader source should remain valid WGSL");
    }
    #[test]
    fn custom_texture_shader_source_is_parseable_with_uniforms() {
        let uniform_signature = vec![("uv_scale".to_string(), ShaderUniformKind::Vec2)];
        let shader = Shader::new(VALID_WGSL_FRAGMENT_SHADER.to_string())
            .expect("expected valid fragment shader");
        let source = build_custom_texture_shader_source(&shader, &uniform_signature);
        assert!(source.contains("@group(1) @binding(0) var t_diffuse: texture_2d<f32>;"));
        assert!(source.contains("@group(1) @binding(1) var s_diffuse: sampler;"));
        assert!(source.contains("@group(2) @binding(0) var<uniform> uv_scale: vec2<f32>;"));
        assert!(source.contains("textureSample(t_diffuse, s_diffuse, in.uv) * in.color"));
        wgpu::naga::front::wgsl::parse_str(&source)
            .expect("wrapped texture shader source should remain valid WGSL");
    }

    #[test]
    fn custom_particle_shader_source_forwards_particle_inputs() {
        let shader = Shader::new_for_target(PARTICLE_SHADER.to_string(), ShaderTarget::Particle)
            .expect("expected valid particle shader");
        let source = build_custom_particle_shader_source(&shader, &[]);

        assert!(source.contains("in.local_pos"));
        assert!(source.contains("out.uv = in.uv"));
        assert!(source.contains("in.world_pos"));
        assert!(source.contains("in.velocity"));
        assert!(source.contains("in.normalized_age"));
        assert!(source.contains("in.lifetime"));
        assert!(source.contains("in.seed"));
        assert!(source.contains("out.sampled_color = in.color"));
        assert!(source.contains("in.sampled_color"));
        wgpu::naga::front::wgsl::parse_str(&source)
            .expect("wrapped particle shader source should remain valid WGSL");
    }

    #[test]
    fn custom_textured_particle_shader_source_samples_texture_color() {
        let shader = Shader::new_for_target(PARTICLE_SHADER.to_string(), ShaderTarget::Particle)
            .expect("expected valid particle shader");
        let source = build_custom_textured_particle_shader_source(
            &shader,
            &[("amount".to_string(), ShaderUniformKind::Float)],
        );

        assert!(source.contains("@group(1) @binding(0) var t_particle: texture_2d<f32>;"));
        assert!(source.contains("@group(1) @binding(1) var s_particle: sampler;"));
        assert!(source.contains("@group(2) @binding(0) var<uniform> amount: f32;"));
        assert!(source.contains("textureSample(t_particle, s_particle, in.uv) * in.color"));
        assert!(source.contains("in.sampled_color"));
        wgpu::naga::front::wgsl::parse_str(&source)
            .expect("wrapped textured particle shader source should remain valid WGSL");
    }

    #[test]
    fn custom_light_shader_source_forwards_light_inputs() {
        let shader = Shader::new_for_target(LIGHT_SHADER.to_string(), ShaderTarget::Light)
            .expect("expected valid light shader");
        let source = build_custom_light_shader_source(
            &shader,
            &[("rim".to_string(), ShaderUniformKind::Float)],
        );

        assert!(source.contains("in.world_pos"));
        assert!(source.contains("in.light_pos"));
        assert!(source.contains("in.normal_hint"));
        assert!(source.contains("in.distance_norm"));
        assert!(source.contains("in.radius"));
        assert!(source.contains("in.intensity"));
        assert!(source.contains("in.shadow_factor"));
        assert!(source.contains("in.ambient_color"));
        assert!(source.contains("in.direction_spot"));
        assert!(source.contains("@group(2) @binding(0) var<uniform> rim: f32;"));
        wgpu::naga::front::wgsl::parse_str(&source)
            .expect("wrapped light shader source should remain valid WGSL");
    }

    #[test]
    fn shader_targets_validate_expected_contracts() {
        let draw =
            Shader::new_for_target(VALID_WGSL_FRAGMENT_SHADER.to_string(), ShaderTarget::Draw)
                .expect("draw shader should validate");
        assert_eq!(draw.target(), ShaderTarget::Draw);

        for target in [
            ShaderTarget::PostFx,
            ShaderTarget::Image,
            ShaderTarget::Overlay,
        ] {
            let shader = Shader::new_for_target(SCREEN_SHADER.to_string(), target)
                .expect("screen shader should validate");
            assert_eq!(shader.target(), target);
            let generated = shader.fullscreen_postfx_source();
            wgpu::naga::front::wgsl::parse_str(&format!(
                "{}\n{}",
                r#"
    struct VertexOutput {
    @builtin(position) clip_pos: vec4<f32>,
    @location(0) uv: vec2<f32>,
    }
    "#,
                generated
            ))
            .expect("generated fullscreen source parses");
        }

        Shader::new_for_target(PARTICLE_SHADER.to_string(), ShaderTarget::Particle)
            .expect("particle shader should validate");
        Shader::new_for_target(LIGHT_SHADER.to_string(), ShaderTarget::Light)
            .expect("light shader should validate");
        Shader::new_for_target(SPRITE_SHADER.to_string(), ShaderTarget::Sprite)
            .expect("sprite shader should validate");
        Shader::new_for_target(SPRITE_SHADER.to_string(), ShaderTarget::Tilemap)
            .expect("tilemap shader should validate");
        Shader::new_for_target(SCREEN_SHADER.to_string(), ShaderTarget::MapViz)
            .expect("mapviz shader should validate");
        Shader::new_for_target(SCREEN_SHADER.to_string(), ShaderTarget::Text)
            .expect("text shader should validate");
        Shader::new_for_target(SCREEN_SHADER.to_string(), ShaderTarget::Ui)
            .expect("ui shader should validate");
        Shader::new_for_target(SCREEN_SHADER.to_string(), ShaderTarget::DebugViz)
            .expect("debugviz shader should validate");
    }

    #[test]
    fn shader_targets_reject_wrong_contracts() {
        let err = Shader::new_for_target(SCREEN_SHADER.to_string(), ShaderTarget::Draw)
            .expect_err("draw target must reject screen shader inputs");
        assert!(err.contains("draw shader uses unsupported input"));
    }

    #[test]
    fn example_shader_assets_validate_for_declared_targets() {
        let shaders = [
            (
                include_str!("../../../content/examples/assets/shaders/image_palette_lut.wgsl"),
                ShaderTarget::Image,
            ),
            (
                include_str!("../../../content/examples/assets/shaders/image_mask_threshold.wgsl"),
                ShaderTarget::Image,
            ),
            (
                include_str!("../../../content/examples/assets/shaders/overlay_heat_haze.wgsl"),
                ShaderTarget::Overlay,
            ),
            (
                include_str!(
                    "../../../content/examples/assets/shaders/overlay_water_distortion.wgsl"
                ),
                ShaderTarget::Overlay,
            ),
            (
                include_str!(
                    "../../../content/examples/assets/shaders/particle_dissolve_glow.wgsl"
                ),
                ShaderTarget::Particle,
            ),
            (
                include_str!(
                    "../../../content/examples/assets/shaders/light_custom_falloff_rim.wgsl"
                ),
                ShaderTarget::Light,
            ),
            (
                include_str!("../../../content/examples/assets/shaders/postfx_crt_chroma.wgsl"),
                ShaderTarget::PostFx,
            ),
            (
                include_str!(
                    "../../../content/examples/assets/shaders/postfx_screen_transition_wipe.wgsl"
                ),
                ShaderTarget::PostFx,
            ),
            (
                include_str!(
                    "../../../content/examples/assets/shaders/sprite_recolor_palette_swap.wgsl"
                ),
                ShaderTarget::Sprite,
            ),
            (
                include_str!("../../../content/examples/assets/shaders/tilemap_biome_tint.wgsl"),
                ShaderTarget::Tilemap,
            ),
            (
                include_str!("../../../content/examples/assets/shaders/fog_of_war.wgsl"),
                ShaderTarget::Overlay,
            ),
            (
                include_str!("../../../content/examples/assets/shaders/procedural_background.wgsl"),
                ShaderTarget::Overlay,
            ),
            (
                include_str!(
                    "../../../content/examples/assets/shaders/province_minimap_visualization.wgsl"
                ),
                ShaderTarget::MapViz,
            ),
            (
                include_str!("../../../content/examples/assets/shaders/text_glow_gradient.wgsl"),
                ShaderTarget::Text,
            ),
            (
                include_str!("../../../content/examples/assets/shaders/ui_terminal_crt.wgsl"),
                ShaderTarget::Ui,
            ),
            (
                include_str!("../../../content/examples/assets/shaders/debugviz_cost_heatmap.wgsl"),
                ShaderTarget::DebugViz,
            ),
        ];

        for (source, target) in shaders {
            Shader::new_for_target(source.to_string(), target)
                .unwrap_or_else(|err| panic!("{target:?} shader asset failed: {err}"));
        }
    }
    #[test]
    fn stencil_write_depth_state_enables_writes_and_action() {
        let state = depth_stencil_state(GpuStencilMode::Write(StencilAction::IncrementWrap));
        assert_eq!(state.format, wgpu::TextureFormat::Depth24PlusStencil8);
        assert_eq!(state.depth_compare, wgpu::CompareFunction::Always);
        assert_eq!(state.stencil.read_mask, 0xFF);
        assert_eq!(state.stencil.write_mask, 0xFF);
        assert_eq!(state.stencil.front.compare, wgpu::CompareFunction::Always);
        assert_eq!(
            state.stencil.front.pass_op,
            wgpu::StencilOperation::IncrementWrap
        );
        assert_eq!(
            state.stencil.back.pass_op,
            wgpu::StencilOperation::IncrementWrap
        );
    }
    #[test]
    fn stencil_test_depth_state_reads_without_writing() {
        let state = depth_stencil_state(GpuStencilMode::Test(CompareMode::GreaterEqual));
        assert_eq!(state.stencil.read_mask, 0xFF);
        assert_eq!(state.stencil.write_mask, 0);
        assert_eq!(
            state.stencil.front.compare,
            wgpu::CompareFunction::GreaterEqual
        );
        assert_eq!(state.stencil.front.pass_op, wgpu::StencilOperation::Keep);
        assert_eq!(
            state.stencil.back.compare,
            wgpu::CompareFunction::GreaterEqual
        );
    }
}
