-- Canonical golden file for lurek.compute evidence comparisons.

-- @describe golden: compute evidence comparison
describe("golden: compute evidence comparison", function()
    it("matches compute evidence baselines", function()
        local text_files = {
            "compute_ndarray_fill_summary.txt",
            "compute_fft_roundtrip_snapshot.txt",
            "compute_affine_transform_snapshot.txt",
            "compute_range_rotation_snapshot.txt",
            "compute_parallel_threshold_trace.txt",
            "compute_array_constructor_snapshot.txt",
            "compute_signal_analysis_pipeline.txt",
            "compute_linear_model_solve_trace.txt",
            "compute_feature_engineering_trace.txt",
            "compute_region_morphology_trace.txt",
            "compute_covariance_projection_trace.txt",
        }
        for _, name in ipairs(text_files) do
            expect_golden_text_match(
                evidence_output_dir("compute") .. name,
                "tests/artifacts/baselines/compute/" .. name
            )
        end

        local image_files = {
            "compute_gaussian_kernel_heatmap.png",
            "compute_spatial_segmentation_atlas.png",
        }
        for _, name in ipairs(image_files) do
            expect_golden_file_match(
                evidence_output_dir("compute") .. name,
                "tests/artifacts/baselines/compute/" .. name
            )
        end
    end)
end)
test_summary()
