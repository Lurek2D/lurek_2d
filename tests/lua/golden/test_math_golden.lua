-- Golden test: math compare-only evidence validation.

-- @describe golden: math Math constants and trig identities
describe("golden: math Math constants and trig identities", function()
    it("matches current math image baselines", function()
        expect_golden_file_match(
            evidence_output_dir("math") .. "math_vec2_unit_circle.png",
            "tests/artifacts/baselines/math/math_vec2_unit_circle.png"
        )
        expect_golden_file_match(
            evidence_output_dir("math") .. "math_distance_heatmap.png",
            "tests/artifacts/baselines/math/math_distance_heatmap.png"
        )
        expect_golden_file_match(
            evidence_output_dir("math") .. "math_polygon_metrics.png",
            "tests/artifacts/baselines/math/math_polygon_metrics.png"
        )
        expect_golden_file_match(
            evidence_output_dir("math") .. "math_bezier_cubic_showcase.png",
            "tests/artifacts/baselines/math/math_bezier_cubic_showcase.png"
        )
        expect_golden_file_match(
            evidence_output_dir("math") .. "math_bezier_crossing_pair.png",
            "tests/artifacts/baselines/math/math_bezier_crossing_pair.png"
        )
        expect_golden_file_match(
            evidence_output_dir("math") .. "math_easing_apply_inout_quad.png",
            "tests/artifacts/baselines/math/math_easing_apply_inout_quad.png"
        )
        expect_golden_file_match(
            evidence_output_dir("math") .. "math_easing_apply_linear.png",
            "tests/artifacts/baselines/math/math_easing_apply_linear.png"
        )
        expect_golden_file_match(
            evidence_output_dir("math") .. "math_easing_apply_out_bounce.png",
            "tests/artifacts/baselines/math/math_easing_apply_out_bounce.png"
        )
        expect_golden_file_match(
            evidence_output_dir("math") .. "math_easing_apply_out_elastic.png",
            "tests/artifacts/baselines/math/math_easing_apply_out_elastic.png"
        )
        expect_golden_file_match(
            evidence_output_dir("math") .. "math_segment_intersections.png",
            "tests/artifacts/baselines/math/math_segment_intersections.png"
        )
        expect_golden_file_match(
            evidence_output_dir("math") .. "math_bresenham_rays.png",
            "tests/artifacts/baselines/math/math_bresenham_rays.png"
        )
        expect_golden_file_match(
            evidence_output_dir("math") .. "math_easing_in_cubic.png",
            "tests/artifacts/baselines/math/math_easing_in_cubic.png"
        )
        expect_golden_file_match(
            evidence_output_dir("math") .. "math_easing_in_quad.png",
            "tests/artifacts/baselines/math/math_easing_in_quad.png"
        )
        expect_golden_file_match(
            evidence_output_dir("math") .. "math_easing_inout_quad.png",
            "tests/artifacts/baselines/math/math_easing_inout_quad.png"
        )
        expect_golden_file_match(
            evidence_output_dir("math") .. "math_easing_linear.png",
            "tests/artifacts/baselines/math/math_easing_linear.png"
        )
        expect_golden_file_match(
            evidence_output_dir("math") .. "math_easing_out_bounce.png",
            "tests/artifacts/baselines/math/math_easing_out_bounce.png"
        )
        expect_golden_file_match(
            evidence_output_dir("math") .. "math_easing_out_cubic.png",
            "tests/artifacts/baselines/math/math_easing_out_cubic.png"
        )
        expect_golden_file_match(
            evidence_output_dir("math") .. "math_easing_out_quad.png",
            "tests/artifacts/baselines/math/math_easing_out_quad.png"
        )
        expect_golden_text_match(
            evidence_output_dir("math") .. "math_line_intersection_report.txt",
            "tests/artifacts/baselines/math/math_line_intersection_report.txt"
        )
        expect_golden_text_match(
            evidence_output_dir("math") .. "math_polygon_algorithms_report.txt",
            "tests/artifacts/baselines/math/math_polygon_algorithms_report.txt"
        )
        expect_golden_file_match(
            evidence_output_dir("math") .. "math_bezier_quadratic.png",
            "tests/artifacts/baselines/math/math_bezier_quadratic.png"
        )
        expect_golden_file_match(
            evidence_output_dir("math") .. "math_bezier_cubic_tangent.png",
            "tests/artifacts/baselines/math/math_bezier_cubic_tangent.png"
        )
    end)
end)
test_summary()
