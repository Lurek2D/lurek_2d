-- Golden test: render compare evidence output against golden samples

-- @describe golden: render evidence comparison
describe("golden: render evidence comparison", function()
    it("matches render baselines", function()
        expect_golden_file_match(
            evidence_output_dir("render") .. "graphic_primitives.png",
            "tests/artifacts/baselines/render/graphic_primitives.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "graphic_color_grid.png",
            "tests/artifacts/baselines/render/graphic_color_grid.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "render_rectangles.png",
            "tests/artifacts/baselines/render/render_rectangles.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "render_circle_ellipse.png",
            "tests/artifacts/baselines/render/render_circle_ellipse.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "render_transform_stack.png",
            "tests/artifacts/baselines/render/render_transform_stack.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "render_blend_alpha.png",
            "tests/artifacts/baselines/render/render_blend_alpha.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "render_canvas_lifecycle.png",
            "tests/artifacts/baselines/render/render_canvas_lifecycle.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "render_canvas_sizes.png",
            "tests/artifacts/baselines/render/render_canvas_sizes.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "render_line_arc.png",
            "tests/artifacts/baselines/render/render_line_arc.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "render_triangle_polygon.png",
            "tests/artifacts/baselines/render/render_triangle_polygon.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "render_color_mask.png",
            "tests/artifacts/baselines/render/render_color_mask.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "render_depth_wireframe.png",
            "tests/artifacts/baselines/render/render_depth_wireframe.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "render_draw_layer_basic_merge.png",
            "tests/artifacts/baselines/render/render_draw_layer_basic_merge.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "render_draw_layer_management.png",
            "tests/artifacts/baselines/render/render_draw_layer_management.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "render_draw_layer_opacity.png",
            "tests/artifacts/baselines/render/render_draw_layer_opacity.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "render_scissor_region.png",
            "tests/artifacts/baselines/render/render_scissor_region.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "render_stencil_setup.png",
            "tests/artifacts/baselines/render/render_stencil_setup.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "render_summary_dashboard.png",
            "tests/artifacts/baselines/render/render_summary_dashboard.png"
        )
    end)
end)
test_summary()
