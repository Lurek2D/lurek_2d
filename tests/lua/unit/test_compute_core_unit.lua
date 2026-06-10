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

    -- @covers LArray:pow
    it("pow raises each element", function()
        local c = arr({2, 3, 4}):pow(2)
        expect_near(16.0, c:get(3), 1e-6)
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

    -- @covers LArray:zscore
    it("zscore centers the data", function()
        local centered = arr({1, 2, 3, 4}):zscore()
        expect_near(0.0, centered:mean(), 1e-5)
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
end)

test_summary()
