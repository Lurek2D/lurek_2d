-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_compute_core_unit.lua
do
-- Lurek2D compute API owner tests.

local function arr(values, shape)
    if shape then
        return lurek.compute.fromTable(values, shape)
    end
    return lurek.compute.fromTable(values)
end

local function matrix2(values)
    return arr(values, {2, 2})
end

local function int_arr(values)
    return lurek.compute.fromTable(values, {#values}, "int32")
end

-- @describe lurek.compute module
describe("lurek.compute module", function()
    -- @covers lurek.compute.newArray
    it("newArray creates a zero-initialized array", function()
        local a = lurek.compute.newArray({2, 2})
        expect_equal(4, a:getSize())
        expect_near(0.0, a:get(1, 1), 1e-6)
    end)

    -- @covers lurek.compute.zeros
    it("zeros respects the requested shape", function()
        local a = lurek.compute.zeros({3, 2})
        local shape = a:getShape()
        expect_equal(3, shape[1])
        expect_equal(2, shape[2])
    end)

    -- @covers lurek.compute.ones
    it("ones fills every cell with one", function()
        local a = lurek.compute.ones({2, 2})
        expect_near(1.0, a:get(1, 1), 1e-6)
        expect_near(1.0, a:get(2, 2), 1e-6)
    end)

    -- @covers lurek.compute.range
    it("range honors a custom step", function()
        local a = lurek.compute.range(0, 10, 2)
        expect_equal(5, a:getSize())
        expect_near(8.0, a:get(5), 1e-6)
    end)

    -- @covers lurek.compute.fromTable
    it("fromTable reshapes flat data", function()
        local a = lurek.compute.fromTable({1, 2, 3, 4}, {2, 2})
        expect_near(1.0, a:get(1, 1), 1e-6)
        expect_near(4.0, a:get(2, 2), 1e-6)
    end)

    -- @covers lurek.compute.gaussianKernel
    it("gaussianKernel sums to one", function()
        local k = lurek.compute.gaussianKernel(3, 1.0)
        local total = 0.0
        for _, v in ipairs(k:toTable()) do
            total = total + v
        end
        expect_near(1.0, total, 1e-5)
    end)

    -- @covers lurek.compute.rotate2dMatrix
    it("rotate2dMatrix rotates x axis to y axis at ninety degrees", function()
        local m = lurek.compute.rotate2dMatrix(math.pi / 2)
        expect_near(0.0, m:get(1, 1), 1e-4)
        expect_near(1.0, m:get(2, 1), 1e-4)
    end)

    -- @covers lurek.compute.affine2d
    it("affine2d applies translation components", function()
        local m = lurek.compute.affine2d(5, 3, 0, 1, 1)
        local points = lurek.compute.fromTable({0, 0}, nil, "float64"):reshape({1, 2})
        local out = m:transformPoints(points)
        expect_near(5.0, out:get(1, 1), 1e-5)
        expect_near(3.0, out:get(1, 2), 1e-5)
    end)

    -- @covers lurek.compute.fft
    it("fft returns a result for a real input signal", function()
        local result = lurek.compute.fft({1.0, 0.0, 1.0, 0.0})
        expect_not_nil(result)
        expect_true(#result >= 4)
    end)

    -- @covers lurek.compute.ifft
    it("ifft approximately reconstructs the original signal", function()
        local data = {1.0, 0.0, 1.0, 0.0}
        local recovered = lurek.compute.ifft(lurek.compute.fft(data))
        expect_near(1.0, recovered[1], 1e-4)
        expect_near(1.0, recovered[3], 1e-4)
    end)

    -- @covers lurek.compute.fftMagnitude
    it("fftMagnitude returns one magnitude per input sample", function()
        local mag = lurek.compute.fftMagnitude({0.1, -0.2, 0.3, -0.4})
        expect_equal(4, #mag)
    end)

    -- @covers lurek.compute.getParThreshold
    it("getParThreshold returns a positive integer", function()
        local threshold = lurek.compute.getParThreshold()
        expect_true(threshold >= 1)
    end)

    -- @covers lurek.compute.setParThreshold
    it("setParThreshold updates the threshold and returns the previous value", function()
        local old_threshold = lurek.compute.getParThreshold()
        local returned_old = lurek.compute.setParThreshold(old_threshold + 1)
        expect_equal(old_threshold, returned_old)
        expect_equal(old_threshold + 1, lurek.compute.getParThreshold())
        lurek.compute.setParThreshold(old_threshold)
    end)
end)

-- @describe LArray metadata
describe("LArray metadata", function()
    -- @covers LArray:getShape
    it("getShape returns each dimension", function()
        local shape = lurek.compute.zeros({4, 5}):getShape()
        expect_equal(4, shape[1])
        expect_equal(5, shape[2])
    end)

    -- @covers LArray:getSize
    it("getSize returns the flattened element count", function()
        expect_equal(12, lurek.compute.zeros({3, 4}):getSize())
    end)

    -- @covers LArray:getDimensions
    it("getDimensions returns the rank", function()
        expect_equal(3, lurek.compute.zeros({2, 3, 4}):getDimensions())
    end)

    -- @covers LArray:getDataType
    it("getDataType reflects the constructor dtype", function()
        local a = lurek.compute.zeros({3}, "int32")
        expect_equal("int32", a:getDataType())
    end)

    -- @covers LArray:type
    it("type returns LArray", function()
        expect_equal("LArray", lurek.compute.zeros({1}):type())
    end)

    -- @covers LArray:typeOf
    it("typeOf recognizes LArray and LObject", function()
        local a = lurek.compute.zeros({1})
        expect_true(a:typeOf("LArray"))
        expect_true(a:typeOf("LObject"))
    end)

    -- @covers LArray:isOnGPU
    it("isOnGPU returns a boolean", function()
        expect_equal("boolean", type(lurek.compute.zeros({1}):isOnGPU()))
    end)
end)

-- @describe LArray access and transforms
describe("LArray access and transforms", function()
    -- @covers LArray:get
    it("get reads an element by coordinates", function()
        local a = arr({1, 2, 3, 4}, {2, 2})
        expect_near(3.0, a:get(2, 1), 1e-6)
    end)

    -- @covers LArray:set
    it("set overwrites a value in place", function()
        local a = lurek.compute.zeros({2, 2})
        a:set(2, 1, 7.5)
        expect_near(7.5, a:get(2, 1), 1e-6)
    end)

    -- @covers LArray:toTable
    it("toTable flattens values in row-major order", function()
        local t = arr({10, 20, 30, 40}, {2, 2}):toTable()
        expect_equal(4, #t)
        expect_near(30.0, t[3], 1e-6)
    end)

    -- @covers LArray:reshape
    it("reshape changes dimensions without changing values", function()
        local a = arr({1, 2, 3, 4}, {4})
        local b = a:reshape({2, 2})
        expect_equal(2, b:getDimensions())
        expect_near(4.0, b:get(2, 2), 1e-6)
    end)

    -- @covers LArray:clone
    it("clone returns an independent copy", function()
        local a = arr({1, 2, 3})
        local b = a:clone()
        b:set(1, 99)
        expect_near(1.0, a:get(1), 1e-6)
    end)

    -- @covers LArray:transpose
    it("transpose swaps rows and columns", function()
        local a = arr({1, 2, 3, 4, 5, 6}, {2, 3})
        local t = a:transpose()
        expect_equal(3, t:getShape()[1])
        expect_near(4.0, t:get(1, 2), 1e-6)
    end)

    -- @covers LArray:fill
    it("fill assigns one value to every cell", function()
        local a = lurek.compute.zeros({2, 2})
        a:fill(9)
        expect_near(9.0, a:get(1, 1), 1e-6)
        expect_near(9.0, a:get(2, 2), 1e-6)
    end)

    -- @covers LArray:getRegion
    it("getRegion extracts a rectangular slice", function()
        local a = arr({1, 2, 3, 4, 5, 6, 7, 8, 9}, {3, 3})
        local region = a:getRegion(2, 2, 2, 2)
        expect_near(5.0, region:get(1, 1), 1e-6)
        expect_near(9.0, region:get(2, 2), 1e-6)
    end)

    -- @covers LArray:setRegion
    it("setRegion writes a smaller array into a target region", function()
        local a = lurek.compute.zeros({3, 3})
        local patch = arr({8, 9, 6, 7}, {2, 2})
        a:setRegion(2, 2, patch)
        expect_near(8.0, a:get(2, 2), 1e-6)
        expect_near(7.0, a:get(3, 3), 1e-6)
    end)
end)

-- @describe LArray math
describe("LArray math", function()
    -- @covers LArray:add
    it("add returns an element-wise sum", function()
        local c = arr({1, 2, 3}):add(arr({10, 20, 30}))
        expect_near(22.0, c:get(2), 1e-6)
    end)

    -- @covers LArray:sub
    it("sub returns an element-wise difference", function()
        local c = arr({10, 20, 30}):sub(arr({1, 2, 3}))
        expect_near(27.0, c:get(3), 1e-6)
    end)

    -- @covers LArray:mul
    it("mul returns an element-wise product", function()
        local c = arr({2, 3, 4}):mul(arr({5, 6, 7}))
        expect_near(18.0, c:get(2), 1e-6)
    end)

    -- @covers LArray:div
    it("div returns an element-wise quotient", function()
        local c = arr({10, 20, 30}):div(arr({2, 4, 5}))
        expect_near(5.0, c:get(1), 1e-6)
        expect_near(6.0, c:get(3), 1e-6)
    end)

    -- @covers LArray:addInplace
    it("addInplace mutates the receiver", function()
        local a = arr({1, 2, 3})
        a:addInplace(arr({4, 5, 6}))
        expect_near(9.0, a:get(3), 1e-6)
    end)

    -- @covers LArray:subInplace
    it("subInplace subtracts values in place", function()
        local a = arr({10, 20, 30})
        a:subInplace(arr({1, 2, 3}))
        expect_near(9.0, a:get(1), 1e-6)
        expect_near(27.0, a:get(3), 1e-6)
    end)

    -- @covers LArray:mulInplace
    it("mulInplace multiplies values in place", function()
        local a = arr({2, 3, 4})
        a:mulInplace(arr({5, 6, 7}))
        expect_near(18.0, a:get(2), 1e-6)
        expect_near(28.0, a:get(3), 1e-6)
    end)

    -- @covers LArray:divInplace
    it("divInplace divides values in place", function()
        local a = arr({10, 20, 30})
        a:divInplace(arr({2, 4, 5}))
        expect_near(5.0, a:get(1), 1e-6)
        expect_near(6.0, a:get(3), 1e-6)
    end)

    -- @covers LArray:pow
    it("pow raises each element", function()
        local c = arr({2, 3, 4}):pow(2)
        expect_near(16.0, c:get(3), 1e-6)
    end)

    -- @covers LArray:sqrt
    it("sqrt returns element-wise square roots", function()
        local b = arr({4, 9, 16}):sqrt()
        expect_near(2.0, b:get(1), 1e-6)
        expect_near(4.0, b:get(3), 1e-6)
    end)

    -- @covers LArray:abs
    it("abs removes the sign from each element", function()
        local b = arr({-4, 0, 5}):abs()
        expect_near(4.0, b:get(1), 1e-6)
        expect_near(5.0, b:get(3), 1e-6)
    end)

    -- @covers LArray:neg
    it("neg flips the sign of each element", function()
        local b = arr({-4, 0, 5}):neg()
        expect_near(4.0, b:get(1), 1e-6)
        expect_near(-5.0, b:get(3), 1e-6)
    end)

    -- @covers LArray:clamp
    it("clamp limits values to the requested range", function()
        local b = arr({-5, 0, 3, 10, 15}):clamp(0, 10)
        expect_near(0.0, b:get(1), 1e-6)
        expect_near(10.0, b:get(5), 1e-6)
    end)

    -- @covers LArray:eq
    it("eq returns a mask for equal elements", function()
        local mask = arr({1, 2, 3}):eq(2)
        expect_near(0.0, mask:get(1), 1e-6)
        expect_near(1.0, mask:get(2), 1e-6)
        expect_near(0.0, mask:get(3), 1e-6)
    end)

    -- @covers LArray:neq
    it("neq returns a mask for non-equal elements", function()
        local mask = arr({1, 2, 3}):neq(2)
        expect_near(1.0, mask:get(1), 1e-6)
        expect_near(0.0, mask:get(2), 1e-6)
        expect_near(1.0, mask:get(3), 1e-6)
    end)

    -- @covers LArray:gt
    it("gt returns a mask for greater-than elements", function()
        local mask = arr({1, 5, 10}):gt(5)
        expect_near(0.0, mask:get(1), 1e-6)
        expect_near(0.0, mask:get(2), 1e-6)
        expect_near(1.0, mask:get(3), 1e-6)
    end)

    -- @covers LArray:lt
    it("lt returns a mask for less-than elements", function()
        local mask = arr({1, 5, 10}):lt(5)
        expect_near(1.0, mask:get(1), 1e-6)
        expect_near(0.0, mask:get(2), 1e-6)
        expect_near(0.0, mask:get(3), 1e-6)
    end)

    -- @covers LArray:gte
    it("gte returns a mask for greater-or-equal elements", function()
        local mask = arr({1, 5, 10}):gte(5)
        expect_near(0.0, mask:get(1), 1e-6)
        expect_near(1.0, mask:get(2), 1e-6)
        expect_near(1.0, mask:get(3), 1e-6)
    end)

    -- @covers LArray:lte
    it("lte returns a mask for less-or-equal elements", function()
        local mask = arr({1, 5, 10}):lte(5)
        expect_near(1.0, mask:get(1), 1e-6)
        expect_near(1.0, mask:get(2), 1e-6)
        expect_near(0.0, mask:get(3), 1e-6)
    end)

    -- @covers LArray:threshold
    it("threshold emits one where the value meets the cutoff", function()
        local c = arr({0.2, 0.5, 0.8}):threshold(0.5)
        expect_near(0.0, c:get(1), 1e-6)
        expect_near(1.0, c:get(2), 1e-6)
    end)

    -- @covers LArray:where
    it("where selects between arrays using a mask", function()
        local mask = arr({1, 0, 1, 0})
        local a = arr({10, 20, 30, 40})
        local b = arr({100, 200, 300, 400})
        local out = a["where"](a, mask, b)
        expect_near(10.0, out:get(1), 1e-6)
        expect_near(200.0, out:get(2), 1e-6)
        expect_near(30.0, out:get(3), 1e-6)
        expect_near(400.0, out:get(4), 1e-6)
    end)

    -- @covers LArray:sum
    it("sum reduces all values", function()
        expect_near(10.0, arr({1, 2, 3, 4}):sum(), 1e-6)
    end)

    -- @covers LArray:mean
    it("mean returns the arithmetic average", function()
        expect_near(2.5, arr({1, 2, 3, 4}):mean(), 1e-6)
    end)

    -- @covers LArray:countNonZero
    it("countNonZero ignores zero entries", function()
        expect_equal(3, arr({0, 4, 0, 5, 6}):countNonZero())
    end)

    -- @covers LArray:argmin
    it("argmin returns the one-based flat index of the minimum", function()
        expect_equal(2, arr({5, 1, 8, 3}):argmin())
    end)

    -- @covers LArray:argmax
    it("argmax returns the one-based flat index of the maximum", function()
        expect_equal(3, arr({5, 1, 8, 3}):argmax())
    end)

    -- @covers LArray:any
    it("any reports whether any element is non-zero", function()
        expect_true(arr({0, 0, 1}):any())
    end)

    -- @covers LArray:all
    it("all reports whether every element is non-zero", function()
        expect_true(arr({1, 2, 3}):all())
        expect_false(arr({1, 0, 3}):all())
    end)

    -- @covers LArray:min
    it("min returns the smallest value", function()
        expect_near(1.0, arr({5, 1, 8, 3}):min(), 1e-6)
    end)

    -- @covers LArray:max
    it("max returns the largest value", function()
        expect_near(8.0, arr({5, 1, 8, 3}):max(), 1e-6)
    end)

    -- @covers LArray:matmul
    it("matmul multiplies compatible matrices", function()
        local c = matrix2({1, 2, 3, 4}):matmul(matrix2({5, 6, 7, 8}))
        expect_near(19.0, c:get(1, 1), 1e-6)
        expect_near(50.0, c:get(2, 2), 1e-6)
    end)

    -- @covers LArray:dot
    it("dot returns the vector dot product", function()
        expect_near(32.0, arr({1, 2, 3}):dot(arr({4, 5, 6})), 1e-6)
    end)

    -- @covers LArray:histogram
    it("histogram counts values into bins", function()
        local bins = arr({0, 0, 1, 1, 2, 2}):histogram(3, 0, 2)
        expect_equal(3, #bins)
        expect_true(bins[1].count >= 1)
    end)

    -- @covers LArray:bitwiseAnd
    it("bitwiseAnd combines integer arrays with AND", function()
        local c = int_arr({0xFF, 0x0F, 0xAA}):bitwiseAnd(int_arr({0x0F, 0x0F, 0x55}))
        expect_equal(0x0F, c:get(1))
        expect_equal(0x00, c:get(3))
    end)

    -- @covers LArray:bitwiseOr
    it("bitwiseOr combines integer arrays with OR", function()
        local c = int_arr({0xF0, 0x0F}):bitwiseOr(int_arr({0x0F, 0xF0}))
        expect_equal(0xFF, c:get(1))
        expect_equal(0xFF, c:get(2))
    end)

    -- @covers LArray:bitwiseXor
    it("bitwiseXor combines integer arrays with XOR", function()
        local c = int_arr({0xFF, 0x00}):bitwiseXor(int_arr({0x0F, 0x0F}))
        expect_equal(0xF0, c:get(1))
        expect_equal(0x0F, c:get(2))
    end)

    -- @covers LArray:bitwiseNot
    it("bitwiseNot flips integer bits", function()
        local c = int_arr({0, 255}):bitwiseNot()
        expect_equal(-1, c:get(1))
        expect_equal(-256, c:get(2))
    end)

    -- @covers LArray:bitwiseLShift
    it("bitwiseLShift shifts integer values left", function()
        local c = int_arr({1, 2, 4}):bitwiseLShift(2)
        expect_equal(4, c:get(1))
        expect_equal(16, c:get(3))
    end)

    -- @covers LArray:bitwiseRShift
    it("bitwiseRShift shifts integer values right", function()
        local c = int_arr({8, 16, 32}):bitwiseRShift(2)
        expect_equal(2, c:get(1))
        expect_equal(8, c:get(3))
    end)

    -- @covers LArray:convolve2D
    it("convolve2D spreads a point impulse with the kernel", function()
        local img = lurek.compute.zeros({5, 5})
        img:set(3, 3, 1)
        local result = img:convolve2D(lurek.compute.gaussianKernel(3, 1.0))
        expect_true(result:get(3, 3) > result:get(3, 2))
        expect_true(result:get(3, 2) > 0.0)
    end)

    -- @covers LArray:dilate
    it("dilate expands non-zero neighborhoods", function()
        local a = lurek.compute.zeros({5, 5})
        a:set(3, 3, 1)
        local d = a:dilate(1)
        expect_near(1.0, d:get(2, 3), 1e-6)
        expect_near(1.0, d:get(3, 2), 1e-6)
    end)

    -- @covers LArray:erode
    it("erode shrinks non-zero neighborhoods", function()
        local a = lurek.compute.ones({5, 5})
        a:set(1, 1, 0)
        local e = a:erode(1)
        expect_near(0.0, e:get(1, 2), 1e-6)
        expect_near(0.0, e:get(2, 1), 1e-6)
    end)

    -- @covers LArray:floodFill
    it("floodFill replaces connected regions", function()
        local a = lurek.compute.zeros({5, 5})
        a:set(1, 1, 1)
        a:set(1, 2, 1)
        local filled = a:floodFill(1, 1, 9)
        expect_near(9.0, filled:get(1, 1), 1e-6)
        expect_near(9.0, filled:get(1, 2), 1e-6)
        expect_near(0.0, filled:get(5, 5), 1e-6)
    end)

    -- @covers LArray:cumsum
    it("cumsum returns running totals", function()
        local cs = arr({1, 2, 3, 4}):cumsum()
        expect_near(10.0, cs:get(4), 1e-6)
    end)

    -- @covers LArray:diff
    it("diff returns consecutive differences", function()
        local d = arr({1, 3, 6, 10}):diff()
        expect_near(2.0, d:get(1), 1e-6)
        expect_near(4.0, d:get(3), 1e-6)
    end)

    -- @covers LArray:percentile
    it("percentile returns interpolated quantiles", function()
        expect_near(50.0, lurek.compute.range(1, 100, 1):percentile(50), 1e-6)
    end)

    -- @covers LArray:covariance
    it("covariance returns the population covariance", function()
        local a = arr({1, 2, 3, 4, 5})
        local b = arr({2, 4, 6, 8, 10})
        expect_near(4.0, a:covariance(b), 1e-6)
    end)

    -- @covers LArray:pearsonCorr
    it("pearsonCorr returns one for perfectly correlated data", function()
        local a = arr({1, 2, 3, 4, 5})
        local b = arr({2, 4, 6, 8, 10})
        expect_near(1.0, a:pearsonCorr(b), 1e-6)
    end)

    -- @covers LArray:normalizeRange
    it("normalizeRange rescales values to the requested interval", function()
        local n = arr({0, 50, 100}):normalizeRange(0, 1)
        expect_near(0.5, n:get(2), 1e-6)
    end)

    -- @covers LArray:zscore
    it("zscore centers the data", function()
        local centered = arr({1, 2, 3, 4}):zscore()
        expect_near(0.0, centered:mean(), 1e-5)
    end)

    -- @covers LArray:convolve1d
    it("convolve1d returns the full 1D convolution", function()
        local signal = arr({0, 1, 2, 3, 4})
        local kernel = arr({1, 0, -1})
        local c = signal:convolve1d(kernel)
        expect_equal(7, c:getSize())
    end)

    -- @covers LArray:correlate1d
    it("correlate1d returns the valid sliding correlation", function()
        local signal = arr({0, 0, 1, 0, 0})
        local templ = arr({1})
        local c = signal:correlate1d(templ)
        expect_near(1.0, c:get(3), 1e-6)
    end)

    -- @covers LArray:normalizeVec
    it("normalizeVec returns a unit-length vector", function()
        local n = arr({3, 4}):normalizeVec()
        expect_near(0.6, n:get(1), 1e-6)
        expect_near(0.8, n:get(2), 1e-6)
    end)

    -- @covers LArray:outer
    it("outer returns the outer product matrix", function()
        local o = arr({1, 2, 3}):outer(arr({4, 5}))
        expect_near(5.0, o:get(1, 2), 1e-6)
        expect_near(12.0, o:get(3, 1), 1e-6)
    end)

    -- @covers LArray:cross2d
    it("cross2d returns the 2D cross-product scalar", function()
        expect_near(1.0, arr({1, 0}):cross2d(arr({0, 1})), 1e-6)
    end)

    -- @covers LArray:map
    it("map applies a callback element-wise", function()
        local b = arr({2, 4, 6}):map(function(x) return x / 2 end)
        expect_near(3.0, b:get(3), 1e-6)
    end)

    -- @covers LArray:eval
    it("eval applies an expression to each element", function()
        local b = arr({1, 2, 3}):eval("x * x")
        expect_near(4.0, b:get(2), 1e-6)
    end)

    -- @covers LArray:reduce
    it("reduce folds the array with an accumulator", function()
        local total = arr({1, 2, 3, 4}):reduce(function(acc, x) return acc + x end, 0)
        expect_equal(10, total)
    end)

    -- @covers LArray:scan
    it("scan returns running accumulation", function()
        local running = arr({1, 2, 3, 4}):scan(function(acc, x) return acc + x end, 0)
        expect_near(10.0, running:get(4), 1e-6)
    end)

    -- @covers LArray:eigenPower
    it("eigenPower returns a dominant eigenvalue estimate", function()
        local m = matrix2({2, 0, 0, 1})
        local result = m:eigenPower()
        local eigenvalue = result.value or result.eigenvalue or result[1]
        expect_true(eigenvalue >= 1.9)
    end)

    -- @covers LArray:linsolve
    it("linsolve solves a small linear system", function()
        local a = lurek.compute.fromTable({2, 1, 1, 3}, nil, "float64"):reshape({2, 2})
        local b = lurek.compute.fromTable({5, 10}, nil, "float64")
        local x = a:linsolve(b)
        expect_near(1.0, x:get(1), 1e-4)
        expect_near(3.0, x:get(2), 1e-4)
    end)

    -- @covers LArray:sobel
    it("sobel returns x and y gradient arrays", function()
        local img = lurek.compute.zeros({5, 5})
        img:set(3, 3, 1)
        local grad = img:sobel()
        expect_type("table", grad)
        expect_not_nil(grad.gx)
        expect_not_nil(grad.gy)
        expect_equal(25, grad.gx:getSize())
        expect_equal(25, grad.gy:getSize())
    end)

    -- @covers LArray:luDecompose
    it("luDecompose returns factorization metadata", function()
        local lu = lurek.compute.fromTable({4, 3, 6, 3}, {2, 2}):luDecompose()
        expect_type("table", lu)
        expect_equal(2, lu.n)
        expect_type("table", lu.perm)
        expect_type("number", lu.det_sign)
    end)
end)
end
-- END test_compute_core_unit.lua

test_summary()
