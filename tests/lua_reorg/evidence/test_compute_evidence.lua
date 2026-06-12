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

-- @describe Evidence: lurek.compute data outputs
describe("Evidence: lurek.compute data outputs", function()
    before_each(function()
        ensure_evidence_dir("compute")
    end)

    -- @evidence lurek.compute.zeros
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

    -- @evidence lurek.compute.gaussianKernel
    -- @evidence lurek.image.savePNG
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

    -- @evidence lurek.compute.fft
    -- @evidence lurek.compute.ifft
    -- @evidence lurek.compute.fftMagnitude
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

    -- @evidence lurek.compute.affine2d
    -- @evidence lurek.compute.fromTable
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

    -- @evidence lurek.compute.range
    -- @evidence lurek.compute.rotate2dMatrix
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

    -- @evidence lurek.compute.getParThreshold
    -- @evidence lurek.compute.setParThreshold
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

    -- @evidence lurek.compute.newArray
    -- @evidence lurek.compute.ones
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
end)
test_summary()
