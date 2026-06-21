-- Golden test: render compare evidence output against golden samples

-- @describe golden: render evidence comparison
describe("golden: render evidence comparison", function()
    it("matches render baselines", function()
        expect_golden_file_match(
            evidence_output_dir("render") .. "graphic_circle_outline_points.png",
            "tests/artifacts/baselines/render/graphic_circle_outline_points.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "graphic_diagonal_line.png",
            "tests/artifacts/baselines/render/graphic_diagonal_line.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "graphic_filled_circle.png",
            "tests/artifacts/baselines/render/graphic_filled_circle.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "graphic_filled_rectangle.png",
            "tests/artifacts/baselines/render/graphic_filled_rectangle.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "graphic_horizontal_line.png",
            "tests/artifacts/baselines/render/graphic_horizontal_line.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "graphic_outlined_rectangle.png",
            "tests/artifacts/baselines/render/graphic_outlined_rectangle.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "graphic_point_strip.png",
            "tests/artifacts/baselines/render/graphic_point_strip.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "graphic_vertical_line.png",
            "tests/artifacts/baselines/render/graphic_vertical_line.png"
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
            evidence_output_dir("render") .. "render_arc.png",
            "tests/artifacts/baselines/render/render_arc.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "render_circle.png",
            "tests/artifacts/baselines/render/render_circle.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "render_ellipse.png",
            "tests/artifacts/baselines/render/render_ellipse.png"
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
            evidence_output_dir("render") .. "render_lines.png",
            "tests/artifacts/baselines/render/render_lines.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "render_polygon.png",
            "tests/artifacts/baselines/render/render_polygon.png"
        )
        expect_golden_file_match(
            evidence_output_dir("render") .. "render_triangle.png",
            "tests/artifacts/baselines/render/render_triangle.png"
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
    end)
end)
test_summary()
