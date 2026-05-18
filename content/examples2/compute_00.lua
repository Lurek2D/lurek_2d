--- Compute Module Part 1: Array Creation, Element Access, Shape, Arithmetic, Comparisons

--@api-stub: lurek.compute.newArray
-- Creates a zero-filled array with a given shape and optional data type.
do
    local a = lurek.compute.newArray({4, 4}, "float32")
    print("new 4x4 array, size = " .. a:getSize())
end

--@api-stub: lurek.compute.zeros
-- Creates a zero-filled array.
do
    local z = lurek.compute.zeros({3, 3})
    print("zeros 3x3, val[1,1] = " .. z:get(1, 1))
end

--@api-stub: lurek.compute.ones
-- Creates a one-filled array.
do
    local o = lurek.compute.ones({2, 5}, "float32")
    print("ones 2x5, val[1,3] = " .. o:get(1, 3))
end

--@api-stub: lurek.compute.range
-- Creates a 1D range array from start to stop with optional step.
do
    local r = lurek.compute.range(0, 10, 2, "float32")
    print("range 0..10 step 2, size = " .. r:getSize())
end

--@api-stub: lurek.compute.fromTable
-- Creates an array from a flat Lua table and optional shape.
do
    local a = lurek.compute.fromTable({1, 2, 3, 4, 5, 6}, {2, 3})
    print("fromTable 2x3, val[2,1] = " .. a:get(2, 1))
end

--@api-stub: lurek.compute.gaussianKernel
-- Creates a square Gaussian kernel array.
do
    local k = lurek.compute.gaussianKernel(5, 1.0)
    print("gaussian 5x5, center = " .. k:get(3, 3))
end

--@api-stub: lurek.compute.rotate2dMatrix
-- Creates a 2D rotation matrix from an angle in radians.
do
    local m = lurek.compute.rotate2dMatrix(math.pi / 4)
    print("rotation 45 deg, [1,1] = " .. m:get(1, 1))
end

--@api-stub: lurek.compute.affine2d
-- Creates a 2D affine transform matrix.
do
    local m = lurek.compute.affine2d(10, 20, 0, 1, 1)
    print("affine tx=10 ty=20, [1,3] = " .. m:get(1, 3))
end

--@api-stub: lurek.compute.fft
-- Computes FFT of real-valued samples.
do
    local freqs = lurek.compute.fft({1, 0, -1, 0})
    print("fft result count = " .. #freqs)
end

--@api-stub: lurek.compute.ifft
-- Computes inverse FFT from complex frequency pairs.
do
    local freqs = lurek.compute.fft({1, 0, -1, 0})
    local samples = lurek.compute.ifft(freqs)
    print("ifft reconstructed, count = " .. #samples)
end

--@api-stub: lurek.compute.fftMagnitude
-- Computes magnitudes from real-valued samples.
do
    local mags = lurek.compute.fftMagnitude({1, 0, -1, 0})
    print("magnitudes count = " .. #mags)
end

--@api-stub: lurek.compute.getParThreshold
-- Returns the global parallelism threshold.
do
    local t = lurek.compute.getParThreshold()
    print("par threshold = " .. t)
end

--@api-stub: lurek.compute.setParThreshold
-- Sets the global parallelism threshold and returns the previous value.
do
    local prev = lurek.compute.setParThreshold(1024)
    print("prev threshold = " .. prev)
end

--@api-stub: LArray:getShape
-- Returns the array shape as a dimension table.
do
    local a = lurek.compute.newArray({3, 4})
    local shape = a:getShape()
    print("shape = " .. shape[1] .. "x" .. shape[2])
end

--@api-stub: LArray:getDimensions
-- Returns the number of dimensions.
do
    local a = lurek.compute.newArray({2, 3, 4})
    print("dims = " .. a:getDimensions())
end

--@api-stub: LArray:getSize
-- Returns the total element count.
do
    local a = lurek.compute.newArray({5, 5})
    print("size = " .. a:getSize())
end

--@api-stub: LArray:getDataType
-- Returns the element data type name.
do
    local a = lurek.compute.newArray({2, 2}, "float32")
    print("dtype = " .. a:getDataType())
end

--@api-stub: LArray:isOnGPU
-- Returns whether the array is stored on the GPU.
do
    local a = lurek.compute.ones({4, 4})
    print("on GPU = " .. tostring(a:isOnGPU()))
end

--@api-stub: LArray:get
-- Reads an element at one-based indices.
do
    local a = lurek.compute.fromTable({10, 20, 30, 40}, {2, 2})
    print("a[1,2] = " .. a:get(1, 2))
end

--@api-stub: LArray:set
-- Writes an element at one-based indices followed by the value.
do
    local a = lurek.compute.zeros({3, 3})
    a:set(2, 2, 99)
    print("a[2,2] = " .. a:get(2, 2))
end

--@api-stub: LArray:toTable
-- Flattens array values into a Lua table.
do
    local a = lurek.compute.fromTable({1, 2, 3}, {3})
    local t = a:toTable()
    print("table = " .. t[1] .. "," .. t[2] .. "," .. t[3])
end

--@api-stub: LArray:reshape
-- Returns a reshaped copy.
do
    local a = lurek.compute.range(1, 6, 1)
    local b = a:reshape({2, 3})
    print("reshaped dims = " .. b:getDimensions())
end

--@api-stub: LArray:clone
-- Returns an independent deep copy.
do
    local a = lurek.compute.ones({3, 3})
    local b = a:clone()
    b:set(1, 1, 5)
    print("original[1,1] = " .. a:get(1, 1) .. " clone[1,1] = " .. b:get(1, 1))
end

--@api-stub: LArray:transpose
-- Returns a transposed copy of a 2D array.
do
    local a = lurek.compute.fromTable({1, 2, 3, 4, 5, 6}, {2, 3})
    local t = a:transpose()
    local shape = t:getShape()
    print("transposed shape = " .. shape[1] .. "x" .. shape[2])
end

--@api-stub: LArray:fill
-- Fills the array in place with a single value.
do
    local a = lurek.compute.newArray({3, 3})
    a:fill(7)
    print("filled[2,2] = " .. a:get(2, 2))
end

--@api-stub: LArray:addInplace
-- Adds another array in place.
do
    local a = lurek.compute.ones({3, 3})
    local b = lurek.compute.ones({3, 3})
    a:addInplace(b)
    print("after addInplace[1,1] = " .. a:get(1, 1))
end

--@api-stub: LArray:subInplace
-- Subtracts another array in place.
do
    local a = lurek.compute.fromTable({5, 5, 5, 5}, {2, 2})
    local b = lurek.compute.ones({2, 2})
    a:subInplace(b)
    print("after subInplace[1,1] = " .. a:get(1, 1))
end

--@api-stub: LArray:mulInplace
-- Multiplies by another array in place.
do
    local a = lurek.compute.fromTable({2, 3, 4, 5}, {2, 2})
    local b = lurek.compute.fromTable({10, 10, 10, 10}, {2, 2})
    a:mulInplace(b)
    print("after mulInplace[1,1] = " .. a:get(1, 1))
end

--@api-stub: LArray:divInplace
-- Divides by another array in place.
do
    local a = lurek.compute.fromTable({10, 20, 30, 40}, {2, 2})
    local b = lurek.compute.fromTable({2, 4, 5, 8}, {2, 2})
    a:divInplace(b)
    print("after divInplace[1,1] = " .. a:get(1, 1))
end

--@api-stub: LArray:add
-- Returns element-wise addition with an array or scalar.
do
    local a = lurek.compute.fromTable({1, 2, 3}, {3})
    local b = a:add(10)
    print("a + 10 → [1] = " .. b:get(1))
end

--@api-stub: LArray:sub
-- Returns element-wise subtraction with an array or scalar.
do
    local a = lurek.compute.fromTable({10, 20, 30}, {3})
    local b = a:sub(5)
    print("a - 5 → [2] = " .. b:get(2))
end

--@api-stub: LArray:mul
-- Returns element-wise multiplication with an array or scalar.
do
    local a = lurek.compute.fromTable({2, 3, 4}, {3})
    local b = a:mul(3)
    print("a * 3 → [3] = " .. b:get(3))
end

--@api-stub: LArray:div
-- Returns element-wise division with an array or scalar.
do
    local a = lurek.compute.fromTable({10, 20, 30}, {3})
    local b = a:div(10)
    print("a / 10 → [1] = " .. b:get(1))
end

--@api-stub: LArray:pow
-- Returns element-wise power with a scalar exponent.
do
    local a = lurek.compute.fromTable({2, 3, 4}, {3})
    local b = a:pow(2)
    print("a^2 → [2] = " .. b:get(2))
end

--@api-stub: LArray:sqrt
-- Returns element-wise square roots.
do
    local a = lurek.compute.fromTable({4, 9, 16}, {3})
    local b = a:sqrt()
    print("sqrt → [1] = " .. b:get(1))
end

--@api-stub: LArray:abs
-- Returns element-wise absolute values.
do
    local a = lurek.compute.fromTable({-3, -1, 2}, {3})
    local b = a:abs()
    print("abs → [1] = " .. b:get(1))
end

--@api-stub: LArray:neg
-- Returns element-wise negation.
do
    local a = lurek.compute.fromTable({5, -3, 0}, {3})
    local b = a:neg()
    print("neg → [1] = " .. b:get(1))
end

--@api-stub: LArray:clamp
-- Returns values clamped between min and max.
do
    local a = lurek.compute.fromTable({-5, 0, 3, 10, 15}, {5})
    local b = a:clamp(0, 10)
    print("clamp(0,10) → [1]=" .. b:get(1) .. " [5]=" .. b:get(5))
end

--@api-stub: LArray:eq
-- Returns element-wise equality mask.
do
    local a = lurek.compute.fromTable({1, 2, 3, 2, 1}, {5})
    local mask = a:eq(2)
    print("eq(2) → [2] = " .. mask:get(2))
end

--@api-stub: LArray:neq
-- Returns element-wise inequality mask.
do
    local a = lurek.compute.fromTable({1, 2, 3}, {3})
    local mask = a:neq(2)
    print("neq(2) → [1] = " .. mask:get(1))
end

--@api-stub: LArray:gt
-- Returns element-wise greater-than mask.
do
    local a = lurek.compute.fromTable({1, 5, 10}, {3})
    local mask = a:gt(4)
    print("gt(4) → [2] = " .. mask:get(2))
end

--@api-stub: LArray:lt
-- Returns element-wise less-than mask.
do
    local a = lurek.compute.fromTable({1, 5, 10}, {3})
    local mask = a:lt(6)
    print("lt(6) → [3] = " .. mask:get(3))
end

--@api-stub: LArray:gte
-- Returns element-wise greater-or-equal mask.
do
    local a = lurek.compute.fromTable({1, 5, 10}, {3})
    local mask = a:gte(5)
    print("gte(5) → [2] = " .. mask:get(2))
end

--@api-stub: LArray:lte
-- Returns element-wise less-or-equal mask.
do
    local a = lurek.compute.fromTable({1, 5, 10}, {3})
    local mask = a:lte(5)
    print("lte(5) → [2] = " .. mask:get(2))
end

--@api-stub: LArray:threshold
-- Returns a mask where values exceed the threshold.
do
    local a = lurek.compute.fromTable({0.1, 0.5, 0.9}, {3})
    local mask = a:threshold(0.4)
    print("threshold(0.4) → [1]=" .. mask:get(1) .. " [3]=" .. mask:get(3))
end

--@api-stub: LArray:where
-- Selects values from this array or another using a mask.
do
    local a = lurek.compute.fromTable({10, 20, 30}, {3})
    local b = lurek.compute.fromTable({-1, -2, -3}, {3})
    local mask = a:gt(15)
    local result = a:where(mask, b)
    print("where → [1]=" .. result:get(1) .. " [2]=" .. result:get(2))
end

--@api-stub: LArray:countNonZero
-- Counts non-zero elements.
do
    local a = lurek.compute.fromTable({0, 1, 0, 2, 3}, {5})
    print("nonzero count = " .. a:countNonZero())
end

--@api-stub: LArray:argmin
-- Returns the one-based flat index of the minimum.
do
    local a = lurek.compute.fromTable({5, 1, 8, 3}, {4})
    print("argmin = " .. a:argmin())
end

--@api-stub: LArray:argmax
-- Returns the one-based flat index of the maximum.
do
    local a = lurek.compute.fromTable({5, 1, 8, 3}, {4})
    print("argmax = " .. a:argmax())
end

--@api-stub: LArray:any
-- Returns true if any element is non-zero.
do
    local a = lurek.compute.fromTable({0, 0, 1}, {3})
    print("any = " .. tostring(a:any()))
end

print("compute_00.lua")
