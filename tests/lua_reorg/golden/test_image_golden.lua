-- Golden test: image evidence comparison

-- @describe golden: image evidence comparison
describe("golden: image evidence comparison", function()
    it("matches image drawing and effect baselines", function()
        expect_golden_file_match(
            evidence_output_dir("image") .. "image_drawing_primitives_scene.png",
            "tests/artifacts/baselines/image/image_drawing_primitives_scene.png"
        )
        expect_golden_file_match(
            evidence_output_dir("image") .. "image_effects_variant_strip.png",
            "tests/artifacts/baselines/image/image_effects_variant_strip.png"
        )
        expect_golden_file_match(
            evidence_output_dir("image") .. "image_blur_sharpen_pair.png",
            "tests/artifacts/baselines/image/image_blur_sharpen_pair.png"
        )
        expect_golden_file_match(
            evidence_output_dir("image") .. "sprite_8x8.png",
            "tests/artifacts/baselines/image/sprite_8x8.png"
        )
        expect_golden_file_match(
            evidence_output_dir("image") .. "sprite_16x16.png",
            "tests/artifacts/baselines/image/sprite_16x16.png"
        )
        expect_golden_file_match(
            evidence_output_dir("image") .. "sprite_32x32.png",
            "tests/artifacts/baselines/image/sprite_32x32.png"
        )
        expect_golden_file_match(
            evidence_output_dir("image") .. "sprite_64x64.png",
            "tests/artifacts/baselines/image/sprite_64x64.png"
        )
        expect_golden_file_match(
            evidence_output_dir("image") .. "tileset_128x128.png",
            "tests/artifacts/baselines/image/tileset_128x128.png"
        )
        expect_golden_file_match(
            evidence_output_dir("image") .. "gradient_horizontal.png",
            "tests/artifacts/baselines/image/gradient_horizontal.png"
        )
        expect_golden_file_match(
            evidence_output_dir("image") .. "gradient_vertical.png",
            "tests/artifacts/baselines/image/gradient_vertical.png"
        )
        expect_golden_file_match(
            evidence_output_dir("image") .. "all_effects_grid.png",
            "tests/artifacts/baselines/image/all_effects_grid.png"
        )
        expect_golden_file_match(
            evidence_output_dir("image") .. "transform_atlas.png",
            "tests/artifacts/baselines/image/transform_atlas.png"
        )
        expect_golden_file_match(
            evidence_output_dir("image") .. "resize_threshold_atlas.png",
            "tests/artifacts/baselines/image/resize_threshold_atlas.png"
        )
        expect_golden_file_match(
            evidence_output_dir("image") .. "image_pixel_grid.png",
            "tests/artifacts/baselines/image/image_pixel_grid.png"
        )
        expect_golden_file_match(
            evidence_output_dir("image") .. "image_cropped_grayscale.png",
            "tests/artifacts/baselines/image/image_cropped_grayscale.png"
        )
        expect_golden_file_match(
            evidence_output_dir("image") .. "image_layered_merge_scene.png",
            "tests/artifacts/baselines/image/image_layered_merge_scene.png"
        )
        expect_golden_file_match(
            evidence_output_dir("image") .. "image_layered_opacity_visibility.png",
            "tests/artifacts/baselines/image/image_layered_opacity_visibility.png"
        )
        expect_golden_file_match(
            evidence_output_dir("image") .. "image_shape_rect_grid.png",
            "tests/artifacts/baselines/image/image_shape_rect_grid.png"
        )
        expect_golden_file_match(
            evidence_output_dir("image") .. "image_shape_concentric_circles.png",
            "tests/artifacts/baselines/image/image_shape_concentric_circles.png"
        )
        expect_golden_file_match(
            evidence_output_dir("image") .. "image_paste_composite.png",
            "tests/artifacts/baselines/image/image_paste_composite.png"
        )
        expect_golden_file_match(
            evidence_output_dir("image") .. "image_shape_radiating_lines.png",
            "tests/artifacts/baselines/image/image_shape_radiating_lines.png"
        )
        expect_golden_file_match(
            evidence_output_dir("image") .. "image_layered_swapped.limg",
            "tests/artifacts/baselines/image/image_layered_swapped.limg"
        )
    end)
end)
test_summary()
