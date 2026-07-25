-- Canonical evidence file for lurek.compute data outputs.
-- @covers lurek.compute.affine2d
-- @covers lurek.compute.fft
-- @covers lurek.compute.fftMagnitude
-- @covers lurek.compute.fromTable
-- @covers lurek.compute.gaussianKernel
-- @covers lurek.compute.getParThreshold
-- @covers lurek.compute.ifft
-- @covers lurek.compute.newArray
-- @covers lurek.compute.ones
-- @covers lurek.compute.range
-- @covers lurek.compute.rotate2dMatrix
-- @covers lurek.compute.setParThreshold
-- @covers lurek.compute.zeros
-- @covers lurek.filesystem.write
-- @covers lurek.image.newImageData
-- @covers lurek.image.savePNG



local OUT = evidence_output_dir("compute")

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function draw_outline(img, x, y, w, h, r, g, b, a)
    img:drawLine(x, y, x + w - 1, y, r, g, b, a or 255)
    img:drawLine(x + w - 1, y, x + w - 1, y + h - 1, r, g, b, a or 255)
    img:drawLine(x + w - 1, y + h - 1, x, y + h - 1, r, g, b, a or 255)
    img:drawLine(x, y + h - 1, x, y, r, g, b, a or 255)
end

local function fmt(value)
    return string.format("%.6f", tonumber(value) or 0)
end

local function join_fmt(values, limit)
    local out = {}
    local n = math.min(#values, limit or #values)
    for i = 1, n do
        out[i] = fmt(values[i])
    end
    return table.concat(out, ",")
end

local function histogram_summary(hist)
    local out = {}
    for i, bin in ipairs(hist) do
        if type(bin) == "table" then
            out[i] = table.concat({
                tostring(bin.bin or bin[1] or i),
                tostring(bin.count or bin[2] or 0),
            }, ":")
        else
            out[i] = tostring(i) .. ":" .. tostring(bin)
        end
    end
    return table.concat(out, ",")
end

local function draw_array_heatmap(img, arr, rows, cols, x0, y0, cell, r0, g0, b0)
    local min_v = arr:min()
    local max_v = arr:max()
    local span = math.max(0.000001, max_v - min_v)
    for row = 1, rows do
        for col = 1, cols do
            local v = arr:get(row, col)
            local t = math.max(0, math.min(1, (v - min_v) / span))
            local r = math.floor(18 + r0 * t)
            local g = math.floor(24 + g0 * t)
            local b = math.floor(34 + b0 * t)
            img:drawRect(x0 + (col - 1) * cell, y0 + (row - 1) * cell, cell - 1, cell - 1, r, g, b, 255)
        end
    end
    draw_outline(img, x0 - 1, y0 - 1, cols * cell + 1, rows * cell + 1, 226, 232, 240, 255)
end

-- @describe Evidence: lurek.compute data outputs
describe("Evidence: lurek.compute data outputs", function()
    before_each(function()
        ensure_evidence_dir("compute")
    end)
    -- Does: Runs "writes compute_ndarray_fill_summary.txt" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.compute.zeros without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/compute/compute_ndarray_fill_summary.txt
    -- Why: This is meaningful only if the visible/text output comes from lurek.compute.zeros; export helpers are just the container.

    it("writes compute_ndarray_fill_summary.txt", function()
        local arr = lurek.compute.zeros({ 2, 3 })
        arr:fill(1.5)
        local text = table.concat({
            "shape=2x3",
            "fill_value=1.500000",
            "sum=" .. string.format("%.6f", arr:sum()),
        }, "\n") .. "\n"
        write_text(OUT .. "compute_ndarray_fill_summary.txt", text)
    end)
    -- Does: Runs "writes compute_gaussian_kernel_heatmap.png" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.compute.gaussianKernel without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/compute/compute_gaussian_kernel_heatmap.png
    -- Why: This is meaningful only if the visible/text output comes from lurek.compute.gaussianKernel; export helpers are just the container.

    it("writes compute_gaussian_kernel_heatmap.png", function()
        local kernel = lurek.compute.gaussianKernel(5, 1.0)
        local values = kernel:toTable()
        local img = lurek.image.newImageData(180, 180)
        img:fill(14, 16, 20, 255)
        local cell = 28
        for row = 0, 4 do
            for col = 0, 4 do
                local v = values[row * 5 + col + 1] or 0
                local shade = math.floor(40 + v * 1200)
                local x = 20 + col * 30
                local y = 20 + row * 30
                img:drawRect(x, y, cell, cell, shade, shade, 255, 255)
                draw_outline(img, x, y, cell, cell, 232, 236, 244, 255)
            end
        end
        save_png(img, OUT .. "compute_gaussian_kernel_heatmap.png")
    end)
    -- Does: Runs "writes compute_fft_roundtrip_snapshot.txt" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.compute.fft, lurek.compute.ifft, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/compute/compute_fft_roundtrip_snapshot.txt
    -- Why: This is meaningful only if the visible/text output comes from lurek.compute.fft, lurek.compute.ifft, and related owner calls; export helpers are just the container.

    it("writes compute_fft_roundtrip_snapshot.txt", function()
        local signal = { 1.0, 0.0, 1.0, 0.0 }
        local fft = lurek.compute.fft(signal)
        local ifft = lurek.compute.ifft(fft)
        local mag = lurek.compute.fftMagnitude(signal)
        local text = table.concat({
            "fft_len=" .. tostring(#fft),
            "ifft_first=" .. string.format("%.6f", ifft[1] or 0),
            "ifft_third=" .. string.format("%.6f", ifft[3] or 0),
            "mag=" .. table.concat({
                string.format("%.6f", mag[1] or 0),
                string.format("%.6f", mag[2] or 0),
                string.format("%.6f", mag[3] or 0),
                string.format("%.6f", mag[4] or 0),
            }, ","),
        }, "\n") .. "\n"
        write_text(OUT .. "compute_fft_roundtrip_snapshot.txt", text)
    end)
    -- Does: Runs "writes compute_affine_transform_snapshot.txt" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.compute.affine2d and lurek.compute.fromTable without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/compute/compute_affine_transform_snapshot.txt
    -- Why: This is meaningful only if the visible/text output comes from lurek.compute.affine2d and lurek.compute.fromTable; export helpers are just the container.

    it("writes compute_affine_transform_snapshot.txt", function()
        local matrix = lurek.compute.affine2d(5, 3, 0, 1, 1)
        local points = lurek.compute.fromTable({ 0, 0, 2, 1 }, { 2, 2 }, "float64")
        local out = matrix:transformPoints(points)
        local text = table.concat({
            "p1=" .. string.format("%.4f,%.4f", out:get(1, 1), out:get(1, 2)),
            "p2=" .. string.format("%.4f,%.4f", out:get(2, 1), out:get(2, 2)),
        }, "\n") .. "\n"
        write_text(OUT .. "compute_affine_transform_snapshot.txt", text)
    end)
    -- Does: Runs "writes compute_range_rotation_snapshot.txt" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.compute.range and lurek.compute.rotate2dMatrix without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/compute/compute_range_rotation_snapshot.txt
    -- Why: This is meaningful only if the visible/text output comes from lurek.compute.range and lurek.compute.rotate2dMatrix; export helpers are just the container.

    it("writes compute_range_rotation_snapshot.txt", function()
        local seq = lurek.compute.range(0, 10, 2)
        local rot = lurek.compute.rotate2dMatrix(math.pi / 2)
        local text = table.concat({
            "range=" .. table.concat(seq:toTable(), ","),
            "rot_11=" .. string.format("%.6f", rot:get(1, 1)),
            "rot_21=" .. string.format("%.6f", rot:get(2, 1)),
        }, "\n") .. "\n"
        write_text(OUT .. "compute_range_rotation_snapshot.txt", text)
    end)
    -- Does: Runs "writes compute_parallel_threshold_trace.txt" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.compute.getParThreshold and lurek.compute.setParThreshold without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/compute/compute_parallel_threshold_trace.txt
    -- Why: This is meaningful only if the visible/text output comes from lurek.compute.getParThreshold and lurek.compute.setParThreshold; export helpers are just the container.

    it("writes compute_parallel_threshold_trace.txt", function()
        local old_threshold = lurek.compute.getParThreshold()
        local returned_old = lurek.compute.setParThreshold(old_threshold + 1)
        local current = lurek.compute.getParThreshold()
        lurek.compute.setParThreshold(old_threshold)
        local text = table.concat({
            "old_threshold=" .. tostring(old_threshold),
            "returned_old=" .. tostring(returned_old),
            "current_threshold=" .. tostring(current),
            "restored_threshold=" .. tostring(lurek.compute.getParThreshold()),
        }, "\n") .. "\n"
        write_text(OUT .. "compute_parallel_threshold_trace.txt", text)
    end)
    -- Does: Runs "writes compute_array_constructor_snapshot.txt" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.compute.newArray and lurek.compute.ones without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/compute/compute_array_constructor_snapshot.txt
    -- Why: This is meaningful only if the visible/text output comes from lurek.compute.newArray and lurek.compute.ones; export helpers are just the container.

    it("writes compute_array_constructor_snapshot.txt", function()
        local zeros = lurek.compute.newArray({ 2, 2 })
        local ones = lurek.compute.ones({ 2, 2 })
        local text = table.concat({
            "zeros_size=" .. tostring(zeros:getSize()),
            "zeros_first=" .. string.format("%.6f", zeros:get(1, 1)),
            "ones_size=" .. tostring(ones:getSize()),
            "ones_diag=" .. string.format("%.6f,%.6f", ones:get(1, 1), ones:get(2, 2)),
        }, "\n") .. "\n"
        write_text(OUT .. "compute_array_constructor_snapshot.txt", text)
    end)
    -- Does: Builds a signal-analysis pipeline from a dense vector through smoothing, template correlation, FFT magnitudes, finite differences, histogram bins, and percentile cuts.
    -- Shows: The artifact exposes compute as a data-science style signal workspace instead of a single constructor call.
    -- Artifact: tests/artifacts/current/compute/compute_signal_analysis_pipeline.txt
    -- Why: It demonstrates that lurek.compute arrays can carry a derived numeric analysis pipeline with spectral, convolution, and summary outputs.

    it("writes compute_signal_analysis_pipeline.txt", function()
        local signal = lurek.compute.fromTable({ 0, 1, 0, -1, 0, 1, 0, -1 }, nil, "float64")
        local kernel = lurek.compute.fromTable({ 0.25, 0.5, 0.25 }, nil, "float64")
        local template = lurek.compute.fromTable({ 1, 0, -1 }, nil, "float64")
        local smooth = signal:convolve1d(kernel)
        local corr = signal:correlate1d(template)
        local diff = signal:diff()
        local cumulative = signal:cumsum()
        local hist = signal:zscore():histogram(5, -2.0, 2.0)
        local mag = lurek.compute.fftMagnitude(signal:toTable())
        local lines = {
            "signal=" .. join_fmt(signal:toTable()),
            "smooth_first_8=" .. join_fmt(smooth:toTable(), 8),
            "template_corr=" .. join_fmt(corr:toTable()),
            "diff=" .. join_fmt(diff:toTable()),
            "cumsum_last=" .. fmt(cumulative:get(cumulative:getSize())),
            "fft_mag_first_4=" .. join_fmt(mag, 4),
            "hist_bins=" .. histogram_summary(hist),
            "p25=" .. fmt(signal:percentile(25)),
            "p75=" .. fmt(signal:percentile(75)),
        }
        write_text(OUT .. "compute_signal_analysis_pipeline.txt", table.concat(lines, "\n") .. "\n")
    end)
    -- Does: Solves a linear system, inspects LU metadata, estimates the dominant eigenvalue, and computes residual error from matrix multiplication.
    -- Shows: The artifact exposes solver-style linear algebra and diagnostics that are useful for simulation, fitting, and optimization workflows.
    -- Artifact: tests/artifacts/current/compute/compute_linear_model_solve_trace.txt
    -- Why: It proves lurek.compute can move beyond scalar math into reusable matrix workflows with a checkable numeric result.

    it("writes compute_linear_model_solve_trace.txt", function()
        local a = lurek.compute.fromTable({ 4, 1, 2, 3 }, { 2, 2 }, "float64")
        local b = lurek.compute.fromTable({ 13, 11 }, nil, "float64")
        local x = a:linsolve(b)
        local predicted = a:matmul(x:reshape({ 2, 1 }))
        local lu = a:luDecompose()
        local eig = a:eigenPower(32, 0.000001)
        local eigenvalue = eig.value or eig.eigenvalue or eig[1] or 0
        local lines = {
            "matrix_shape=2x2",
            "solution=" .. join_fmt(x:toTable()),
            "predicted_rhs=" .. fmt(predicted:get(1, 1)) .. "," .. fmt(predicted:get(2, 1)),
            "residual_abs_sum=" .. fmt(math.abs(predicted:get(1, 1) - b:get(1)) + math.abs(predicted:get(2, 1) - b:get(2))),
            "lu_n=" .. tostring(lu.n),
            "lu_det_sign=" .. tostring(lu.det_sign),
            "lu_perm=" .. table.concat(lu.perm, ","),
            "dominant_eigenvalue=" .. fmt(eigenvalue),
        }
        write_text(OUT .. "compute_linear_model_solve_trace.txt", table.concat(lines, "\n") .. "\n")
    end)
    -- Does: Creates feature vectors, derives normalized and z-score columns, selects values through a mask, and summarizes top positions.
    -- Shows: The artifact demonstrates common feature-engineering steps for analytics or model-prep scripts.
    -- Artifact: tests/artifacts/current/compute/compute_feature_engineering_trace.txt
    -- Why: It makes mask/where/normalization behavior legible as a complete transformation, not isolated API trivia.

    it("writes compute_feature_engineering_trace.txt", function()
        local raw = lurek.compute.fromTable({ 12, 18, 25, 40, 33, 21, 17, 29 }, nil, "float64")
        local normalized = raw:normalizeRange(0, 1)
        local z = raw:zscore()
        local mask = raw:gt(22)
        local selected = normalized["where"](normalized, mask, lurek.compute.zeros({ raw:getSize() }, "float64"))
        local weighted = raw:map(function(x)
            return x * 1.25 + 4
        end)
        local scan = raw:scan(function(acc, x)
            return acc + x
        end, 0)
        local lines = {
            "raw=" .. join_fmt(raw:toTable()),
            "normalized=" .. join_fmt(normalized:toTable()),
            "zscore=" .. join_fmt(z:toTable()),
            "mask_count=" .. tostring(mask:countNonZero()),
            "selected_norm=" .. join_fmt(selected:toTable()),
            "weighted_mean=" .. fmt(weighted:mean()),
            "running_total_last=" .. fmt(scan:get(scan:getSize())),
            "argmax=" .. tostring(raw:argmax()),
            "argmin=" .. tostring(raw:argmin()),
        }
        write_text(OUT .. "compute_feature_engineering_trace.txt", table.concat(lines, "\n") .. "\n")
    end)
    -- Does: Edits a 2D occupancy grid by region, then runs flood-fill and morphology passes over thresholded masks.
    -- Shows: The artifact captures spatial array operations used by map analysis, segmentation, and mask cleanup.
    -- Artifact: tests/artifacts/current/compute/compute_region_morphology_trace.txt
    -- Why: It proves region IO and neighborhood operations produce measurable structural changes on a dense grid.

    it("writes compute_region_morphology_trace.txt", function()
        local grid = lurek.compute.fromTable({
            0, 0, 0, 0, 0, 0,
            0, 1, 1, 0, 0, 0,
            0, 1, 1, 0, 2, 0,
            0, 0, 0, 2, 2, 0,
            0, 3, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0,
        }, { 6, 6 }, "float64")
        local region = grid:getRegion(2, 2, 3, 3)
        local edited = grid:clone()
        edited:setRegion(3, 3, lurek.compute.ones({ 2, 2 }))
        local mask = edited:threshold(0.5)
        local dilated = mask:dilate(1)
        local eroded = dilated:erode(1)
        local filled = edited:floodFill(1, 1, 9)
        local lines = {
            "region_2_2_3x3=" .. join_fmt(region:toTable()),
            "edited_nonzero=" .. tostring(edited:countNonZero()),
            "mask_nonzero=" .. tostring(mask:countNonZero()),
            "dilated_nonzero=" .. tostring(dilated:countNonZero()),
            "eroded_nonzero=" .. tostring(eroded:countNonZero()),
            "floodfill_corner=" .. fmt(filled:get(1, 1)),
            "floodfill_nonzero=" .. tostring(filled:countNonZero()),
            "any_mask=" .. tostring(mask:any()),
            "all_mask=" .. tostring(mask:all()),
        }
        write_text(OUT .. "compute_region_morphology_trace.txt", table.concat(lines, "\n") .. "\n")
    end)
    -- Does: Computes covariance, Pearson correlation, vector normalization, dot products, cross products, and an outer-product matrix.
    -- Shows: The artifact exposes relationship analysis and projection-style vector math in one compact diagnostic.
    -- Artifact: tests/artifacts/current/compute/compute_covariance_projection_trace.txt
    -- Why: It demonstrates compute as a statistics and linear-algebra bridge for data analysis workloads.

    it("writes compute_covariance_projection_trace.txt", function()
        local x = lurek.compute.fromTable({ 2, 4, 6, 8 }, nil, "float64")
        local y = lurek.compute.fromTable({ 1, 3, 5, 7 }, nil, "float64")
        local basis = lurek.compute.fromTable({ 0.5, 1.0, 1.5 }, nil, "float64")
        local outer = x:outer(basis)
        local normalized = x:normalizeVec()
        local lines = {
            "covariance=" .. fmt(x:covariance(y)),
            "pearson=" .. fmt(x:pearsonCorr(y)),
            "dot=" .. fmt(x:dot(y)),
            "cross2d=" .. fmt(lurek.compute.fromTable({ 2, 5 }, nil, "float64"):cross2d(lurek.compute.fromTable({ 7, 3 }, nil, "float64"))),
            "normalized=" .. join_fmt(normalized:toTable()),
            "outer_shape=4x3",
            "outer_row1=" .. fmt(outer:get(1, 1)) .. "," .. fmt(outer:get(1, 2)) .. "," .. fmt(outer:get(1, 3)),
            "outer_row4=" .. fmt(outer:get(4, 1)) .. "," .. fmt(outer:get(4, 2)) .. "," .. fmt(outer:get(4, 3)),
        }
        write_text(OUT .. "compute_covariance_projection_trace.txt", table.concat(lines, "\n") .. "\n")
    end)
    -- Does: Renders a four-panel atlas from source grid, Gaussian blur, Sobel edge magnitude, and dilated threshold mask.
    -- Shows: The PNG makes a compute-only image-processing pipeline visible as changing heatmaps.
    -- Artifact: tests/artifacts/current/compute/compute_spatial_segmentation_atlas.png
    -- Why: It proves spatial compute operations create distinct intermediate fields suitable for heavy grid or image-like analysis.

    it("writes compute_spatial_segmentation_atlas.png", function()
        local src = lurek.compute.zeros({ 8, 8 })
        for row = 3, 6 do
            for col = 3, 6 do
                src:set(row, col, 1.0)
            end
        end
        src:set(2, 6, 0.7)
        src:set(6, 2, 0.4)
        local blur = src:convolve2D(lurek.compute.gaussianKernel(3, 1.0))
        local grad = blur:sobel()
        local edge = grad.gx:abs():add(grad.gy:abs())
        local mask = blur:threshold(0.12):dilate(1)
        local img = lurek.image.newImageData(420, 128)
        img:fill(12, 14, 18, 255)
        draw_array_heatmap(img, src, 8, 8, 14, 20, 11, 210, 120, 80)
        draw_array_heatmap(img, blur, 8, 8, 114, 20, 11, 90, 180, 210)
        draw_array_heatmap(img, edge, 8, 8, 214, 20, 11, 220, 210, 70)
        draw_array_heatmap(img, mask, 8, 8, 314, 20, 11, 220, 90, 120)
        save_png(img, OUT .. "compute_spatial_segmentation_atlas.png")
    end)
end)
test_summary()
