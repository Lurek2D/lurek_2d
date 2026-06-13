-- Lurek2D Stress Test: Heavy Compute Operations
-- Tests NdArray at scale: large matrix ops, reductions, broadcasting

local function ones(shape)
    return lurek.compute.ones(shape, "float32")
end

local function range(start_value, stop_value)
    return lurek.compute.range(start_value, stop_value, 1, "float32")
end

local function zero_array_size(shape)
    local arr = lurek.compute.zeros(shape, "float32")
    return arr:getSize()
end

-- @describe compute stress: large array creation
describe("compute stress: large array creation", function()
    -- @stress lurek.compute.zeros
    it("creates a 1000-element zeroed array without error", function()
        expect_equal(1000, zero_array_size({1000}), "total elements")
    end)

    -- @stress lurek.compute.ones
    it("creates a dense 100x100 matrix of ones", function()
        local arr = ones({100, 100})
        expect_equal(10000, arr:getSize(), "100x100 = 10000 elements")
    end)

    -- @stress lurek.compute.range
    it("range creates large sequence", function()
        local arr = range(0, 5000)
        expect_equal(5000, arr:getSize(), "5000 element range")
    end)
end)

-- @describe compute stress: element-wise operations
describe("compute stress: element-wise operations", function()
    -- @stress LArray:getShape
    it("getShape stays stable on a large 1D array", function()
        local arr = ones({1000})
        local shape = arr:getShape()
        expect_equal(1, #shape, "1D array")
        expect_equal(1000, shape[1], "correct logical size")
    end)

    -- @stress LArray:getSize
    it("getSize reports element count on a 100x100 matrix", function()
        local arr = ones({100, 100})
        expect_equal(10000, arr:getSize(), "100x100 = 10000 elements")
    end)

    -- @stress LArray:add
    it("adds two 10000-element arrays", function()
        local a = ones({10000})
        local b = ones({10000})
        local c = a:add(b)
        expect_equal(10000, c:getSize(), "result size matches")
        local sum = c:sum()
        expect_near(20000, sum, 1.0, "1+1 summed 10000 times")
    end)

    -- @stress LArray:mul
    it("multiplies large arrays element-wise", function()
        local a = range(1, 1001)
        local b = range(1, 1001)
        local c = a:mul(b)
        expect_equal(1000, c:getSize(), "result has 1000 elements")
    end)
end)

-- @describe compute stress: reductions
describe("compute stress: reductions", function()
    -- @stress LArray:sum
    it("sum of large array", function()
        local arr = ones({10000})
        expect_near(10000, arr:sum(), 1.0, "sum of 10000 ones")
    end)

    -- @stress LArray:min
    it("min scans a large arithmetic range", function()
        local arr = range(1, 10001)
        expect_near(1, arr:min(), 0.1, "min of range")
    end)

    -- @stress LArray:max
    it("max scans a large arithmetic range", function()
        local arr = range(1, 10001)
        expect_near(10000, arr:max(), 0.1, "max of range")
    end)

    -- @stress LArray:mean
    it("mean of uniform array", function()
        local arr = ones({5000})
        local mean = arr:mean()
        expect_near(1.0, mean, 0.001, "mean of ones")
    end)
end)
test_summary()
