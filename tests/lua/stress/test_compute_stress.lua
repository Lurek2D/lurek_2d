-- Lurek2D Stress Test: Heavy Compute Operations
-- Tests NdArray at scale: large matrix ops, reductions, broadcasting


-- @description Covers suite: compute stress: large array creation.
describe("compute stress: large array creation", function()
    -- @covers lurek.compute.zeros
    -- @covers NdArray:getShape
    -- @covers NdArray:getSize
    -- @stress Allocates one 1000-element zero-filled vector and immediately inspects its shape metadata.
    -- @description Stresses small-array allocation and metadata access by creating a 1D float32 array and validating its dimensional bookkeeping.
    it("creates and fills a 1000-element array", function()
        local arr = lurek.compute.zeros({1000}, "float32")
        local shape = arr:getShape()
        expect_equal(1, #shape, "1D array")
        expect_equal(1000, shape[1], "correct size")
        expect_equal(1000, arr:getSize(), "total elements")
    end)

    -- @covers lurek.compute.ones
    -- @covers NdArray:sum
    -- @stress Allocates a 100x100 matrix of ones and reduces all 10000 elements with sum.
    -- @description Stresses dense matrix allocation plus a full-array reduction by creating a square matrix and verifying the aggregate value.
    it("creates a 100x100 matrix", function()
        local arr = lurek.compute.ones({100, 100}, "float32")
        expect_equal(10000, arr:getSize(), "100x100 = 10000 elements")

        -- Verify all ones
        local sum = arr:sum()
        expect_near(10000, sum, 0.1, "sum of ones = 10000")
    end)

    -- @covers lurek.compute.range
    -- @covers NdArray:getSize
    -- @stress Builds a contiguous 5000-element numeric range in one allocation.
    -- @description Stresses sequential array generation by materializing a large float32 range and checking total element count.
    it("range creates large sequence", function()
        local arr = lurek.compute.range(0, 5000, 1, "float32")
        expect_equal(5000, arr:getSize(), "5000 element range")
    end)
end)

-- @description Covers suite: compute stress: element-wise operations.
describe("compute stress: element-wise operations", function()
    -- @covers lurek.compute.ones
    -- @covers NdArray:add
    -- @covers NdArray:sum
    -- @stress Adds two 10000-element vectors and reduces the full result.
    -- @description Stresses element-wise addition and result traversal by combining two large arrays and summing the output buffer.
    it("adds two 10000-element arrays", function()
        local a = lurek.compute.ones({10000}, "float32")
        local b = lurek.compute.ones({10000}, "float32")
        local c = a:add(b)
        expect_equal(10000, c:getSize(), "result size matches")

        -- Check sum is doubled
        local sum = c:sum()
        expect_near(20000, sum, 1.0, "1+1 summed 10000 times")
    end)

    -- @covers lurek.compute.range
    -- @covers NdArray:mul
    -- @stress Multiplies two 1000-element ranges element-wise.
    -- @description Stresses element-wise multiplication on non-constant inputs by generating two ranges and producing a third computed array.
    it("multiplies large arrays element-wise", function()
        local a = lurek.compute.range(1, 1001, 1, "float32")
        local b = lurek.compute.range(1, 1001, 1, "float32")
        local c = a:mul(b)
        expect_equal(1000, c:getSize(), "result has 1000 elements")
    end)

    -- @covers lurek.compute.ones
    -- @covers NdArray:add
    -- @covers NdArray:mul
    -- @covers NdArray:sub
    -- @stress Chains add, multiply, and subtract across a 5000-element vector pipeline.
    -- @description Stresses intermediate-array creation and arithmetic chaining by executing three sequential vector operations before a final reduction.
    it("chains multiple operations", function()
        local a = lurek.compute.ones({5000}, "float32")
        -- Chain: add ďż˝ mul ďż˝ sub
        local b = a:add(a)       -- 2
        local c = b:mul(b)       -- 4
        local d = c:sub(a)       -- 3
        local sum = d:sum()
        expect_near(15000, sum, 1.0, "chain ops result")
    end)
end)

-- @description Covers suite: compute stress: reductions.
describe("compute stress: reductions", function()
    -- @covers lurek.compute.ones
    -- @covers NdArray:sum
    -- @stress Reduces a 10000-element uniform vector with sum.
    -- @description Stresses reduction throughput by summing a large array whose expected total is trivial to verify.
    it("sum of large array", function()
        local arr = lurek.compute.ones({10000}, "float32")
        expect_near(10000, arr:sum(), 1.0, "sum of 10000 ones")
    end)

    -- @covers lurek.compute.range
    -- @covers NdArray:min
    -- @covers NdArray:max
    -- @stress Scans a 10000-element range for both extrema.
    -- @description Stresses full-buffer traversal in two different reduction passes by computing minimum and maximum on a large monotonic array.
    it("min/max of range", function()
        local arr = lurek.compute.range(1, 10001, 1, "float32")
        expect_near(1, arr:min(), 0.1, "min of range")
        expect_near(10000, arr:max(), 0.1, "max of range")
    end)

    -- @covers lurek.compute.ones
    -- @covers NdArray:mean
    -- @stress Computes the mean of a 5000-element uniform vector.
    -- @description Stresses average reduction logic on a medium-size array where every element is identical and the expected mean is stable.
    it("mean of uniform array", function()
        local arr = lurek.compute.ones({5000}, "float32")
        local mean = arr:mean()
        expect_near(1.0, mean, 0.001, "mean of ones")
    end)
end)
