-- content/examples/compute.lua
-- Auto-generated from content/examples2/compute_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/compute.lua

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
    local a = lurek.compute.range(1, 7, 1)
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

--- Compute Module Part 2: Reduction, Linear Algebra, Morphology, Statistics, Functional


--@api-stub: LArray:all
-- Returns true when all elements are non-zero.
do
    local a = lurek.compute.fromTable({1, 2, 3}, {3})
    print("all nonzero = " .. tostring(a:all()))
end

--@api-stub: LArray:sum
-- Returns the total sum of all elements.
do
    local a = lurek.compute.fromTable({1, 2, 3, 4}, {4})
    print("sum = " .. a:sum())
end

--@api-stub: LArray:mean
-- Returns the mean of all elements.
do
    local a = lurek.compute.fromTable({2, 4, 6, 8}, {4})
    print("mean = " .. a:mean())
end

--@api-stub: LArray:min
-- Returns the minimum value.
do
    local a = lurek.compute.fromTable({7, 2, 9, 1}, {4})
    print("min = " .. a:min())
end

--@api-stub: LArray:max
-- Returns the maximum value.
do
    local a = lurek.compute.fromTable({7, 2, 9, 1}, {4})
    print("max = " .. a:max())
end

--@api-stub: LArray:matmul
-- Returns matrix multiplication result.
do
    local a = lurek.compute.fromTable({1, 2, 3, 4}, {2, 2})
    local b = lurek.compute.fromTable({5, 6, 7, 8}, {2, 2})
    local c = a:matmul(b)
    print("matmul[1,1] = " .. c:get(1, 1))
end

--@api-stub: LArray:dot
-- Returns dot product of two vectors.
do
    local a = lurek.compute.fromTable({1, 2, 3}, {3})
    local b = lurek.compute.fromTable({4, 5, 6}, {3})
    print("dot = " .. a:dot(b))
end

--@api-stub: LArray:bitwiseAnd
-- Returns element-wise bitwise AND.
do
    local a = lurek.compute.fromTable({0xFF, 0x0F, 0xAA}, {3}, "int32")
    local b = lurek.compute.fromTable({0x0F, 0x0F, 0x55}, {3}, "int32")
    local c = a:bitwiseAnd(b)
    print("AND[1] = " .. c:get(1))
end

--@api-stub: LArray:bitwiseOr
-- Returns element-wise bitwise OR.
do
    local a = lurek.compute.fromTable({0xF0, 0x0F}, {2}, "int32")
    local b = lurek.compute.fromTable({0x0F, 0xF0}, {2}, "int32")
    local c = a:bitwiseOr(b)
    print("OR[1] = " .. c:get(1))
end

--@api-stub: LArray:bitwiseXor
-- Returns element-wise bitwise XOR.
do
    local a = lurek.compute.fromTable({0xFF, 0x00}, {2}, "int32")
    local b = lurek.compute.fromTable({0x0F, 0x0F}, {2}, "int32")
    local c = a:bitwiseXor(b)
    print("XOR[1] = " .. c:get(1))
end

--@api-stub: LArray:bitwiseNot
-- Returns element-wise bitwise NOT.
do
    local a = lurek.compute.fromTable({0, 255}, {2}, "int32")
    local c = a:bitwiseNot()
    print("NOT[1] = " .. c:get(1))
end

--@api-stub: LArray:bitwiseLShift
-- Returns element-wise left shift by a bit count.
do
    local a = lurek.compute.fromTable({1, 2, 4}, {3}, "int32")
    local c = a:bitwiseLShift(2)
    print("lshift(2)[1] = " .. c:get(1))
end

--@api-stub: LArray:bitwiseRShift
-- Returns element-wise right shift by a bit count.
do
    local a = lurek.compute.fromTable({8, 16, 32}, {3}, "int32")
    local c = a:bitwiseRShift(2)
    print("rshift(2)[1] = " .. c:get(1))
end

--@api-stub: LArray:convolve2D
-- Returns 2D convolution with a kernel array.
do
    local img = lurek.compute.zeros({5, 5})
    img:set(3, 3, 1)
    local kernel = lurek.compute.gaussianKernel(3, 1.0)
    local result = img:convolve2D(kernel)
    print("conv center = " .. result:get(3, 3))
end

--@api-stub: LArray:dilate
-- Returns morphological dilation with a radius.
do
    local a = lurek.compute.zeros({5, 5})
    a:set(3, 3, 1)
    local d = a:dilate(1)
    print("dilated[2,3] = " .. d:get(2, 3))
end

--@api-stub: LArray:erode
-- Returns morphological erosion with a radius.
do
    local a = lurek.compute.ones({5, 5})
    a:set(1, 1, 0)
    local e = a:erode(1)
    print("eroded[2,2] = " .. e:get(2, 2))
end

--@api-stub: LArray:floodFill
-- Returns a flood-filled copy starting at a row and column.
do
    local a = lurek.compute.zeros({5, 5})
    a:set(1, 1, 1)
    a:set(1, 2, 1)
    local filled = a:floodFill(1, 1, 9)
    print("flood[1,2] = " .. filled:get(1, 2))
end

--@api-stub: LArray:getRegion
-- Returns a rectangular sub-region.
do
    local a = lurek.compute.range(1, 17, 1)
    local m = a:reshape({4, 4})
    local region = m:getRegion(2, 2, 2, 2)
    print("region[1,1] = " .. region:get(1, 1))
end

--@api-stub: LArray:setRegion
-- Writes a source array into this array at a position.
do
    local a = lurek.compute.zeros({4, 4})
    local patch = lurek.compute.ones({2, 2})
    a:setRegion(2, 2, patch)
    print("after setRegion[2,2] = " .. a:get(2, 2))
end

--@api-stub: LArray:cumsum
-- Returns cumulative sum over flattened array.
do
    local a = lurek.compute.fromTable({1, 2, 3, 4}, {4})
    local cs = a:cumsum()
    print("cumsum[4] = " .. cs:get(4))
end

--@api-stub: LArray:diff
-- Returns finite differences with optional order.
do
    local a = lurek.compute.fromTable({1, 3, 6, 10}, {4})
    local d = a:diff()
    print("diff[1] = " .. d:get(1))
end

--@api-stub: LArray:histogram
-- Returns histogram bins with lo, hi, and count fields.
do
    local a = lurek.compute.fromTable({1, 2, 3, 4, 5, 6, 7, 8}, {8})
    local bins = a:histogram(4)
    print("bin count = " .. #bins)
end

--@api-stub: LArray:percentile
-- Returns a percentile value from the array.
do
    local a = lurek.compute.range(1, 100, 1)
    local p50 = a:percentile(50)
    print("p50 = " .. p50)
end

--@api-stub: LArray:covariance
-- Returns covariance with another array.
do
    local a = lurek.compute.fromTable({1, 2, 3, 4, 5}, {5})
    local b = lurek.compute.fromTable({2, 4, 6, 8, 10}, {5})
    print("covariance = " .. a:covariance(b))
end

--@api-stub: LArray:pearsonCorr
-- Returns Pearson correlation coefficient.
do
    local a = lurek.compute.fromTable({1, 2, 3, 4, 5}, {5})
    local b = lurek.compute.fromTable({2, 4, 6, 8, 10}, {5})
    print("pearson = " .. a:pearsonCorr(b))
end

--@api-stub: LArray:normalizeRange
-- Returns values normalized into a target range.
do
    local a = lurek.compute.fromTable({0, 50, 100}, {3})
    local n = a:normalizeRange(0, 1)
    print("normalized[2] = " .. n:get(2))
end

--@api-stub: LArray:zscore
-- Returns z-score normalized values.
do
    local a = lurek.compute.fromTable({2, 4, 4, 4, 5, 5, 7, 9}, {8})
    local z = a:zscore()
    print("zscore[1] = " .. z:get(1))
end

--@api-stub: LArray:convolve1d
-- Returns 1D convolution with a kernel array.
do
    local signal = lurek.compute.fromTable({0, 1, 2, 3, 4}, {5})
    local kernel = lurek.compute.fromTable({1, 0, -1}, {3})
    local c = signal:convolve1d(kernel)
    print("conv1d size = " .. c:getSize())
end

--@api-stub: LArray:correlate1d
-- Returns 1D correlation with a template array.
do
    local signal = lurek.compute.fromTable({0, 0, 1, 0, 0}, {5})
    local templ = lurek.compute.fromTable({1}, {1})
    local c = signal:correlate1d(templ)
    print("corr peak at [3] = " .. c:get(3))
end

--@api-stub: LArray:normalizeVec
-- Returns this vector normalized to unit length.
do
    local v = lurek.compute.fromTable({3, 4}, {2})
    local n = v:normalizeVec()
    print("normalized[1] = " .. n:get(1))
end

--@api-stub: LArray:outer
-- Returns outer product of two vectors.
do
    local a = lurek.compute.fromTable({1, 2, 3}, {3})
    local b = lurek.compute.fromTable({4, 5}, {2})
    local o = a:outer(b)
    print("outer[1,2] = " .. o:get(1, 2))
end

--@api-stub: LArray:cross2d
-- Returns 2D cross product (scalar result).
do
    local a = lurek.compute.fromTable({1, 0}, {2})
    local b = lurek.compute.fromTable({0, 1}, {2})
    print("cross2d = " .. a:cross2d(b))
end

--@api-stub: LArray:transformPoints
-- Transforms a point array by this transform matrix.
do
    local m = lurek.compute.affine2d(10, 20, 0, 1, 1)
    local pts = lurek.compute.fromTable({0, 0, 5, 5}, {2, 2})
    local result = m:transformPoints(pts)
    print("transformed[1,1] = " .. result:get(1, 1))
end

--@api-stub: LArray:sobel
-- Computes Sobel gradients returning gx and gy arrays.
do
    local img = lurek.compute.zeros({5, 5})
    img:set(3, 3, 1)
    local grad = img:sobel()
    print("gx size = " .. grad.gx:getSize())
end

--@api-stub: LArray:linsolve
-- Solves a linear system Ax = b.
do
    local a = lurek.compute.fromTable({2, 1, 5, 7}, {2, 2})
    local b = lurek.compute.fromTable({11, 13}, {2})
    local x = a:linsolve(b)
    print("x[1] = " .. x:get(1))
end

--@api-stub: LArray:luDecompose
-- Decomposes this matrix into LU data and permutation.
do
    local a = lurek.compute.fromTable({4, 3, 6, 3}, {2, 2})
    local lu = a:luDecompose()
    print("n = " .. lu.n .. " det_sign = " .. lu.det_sign)
end

--@api-stub: LArray:eigenPower
-- Estimates dominant eigenvalue and eigenvector.
do
    local a = lurek.compute.fromTable({2, 1, 1, 2}, {2, 2})
    local result = a:eigenPower(100, 1e-6)
    print("eigenvalue = " .. result.value)
end

--@api-stub: LArray:map
-- Maps each element through a Lua function.
do
    local a = lurek.compute.fromTable({1, 4, 9}, {3})
    local b = a:map(function(x) return x * 2 end)
    print("mapped[2] = " .. b:get(2))
end

--@api-stub: LArray:eval
-- Maps each element through a Lua expression string.
do
    local a = lurek.compute.fromTable({1, 2, 3}, {3})
    local b = a:eval("x * x + 1")
    print("eval[2] = " .. b:get(2))
end

--@api-stub: LArray:reduce
-- Reduces array with an accumulator function.
do
    local a = lurek.compute.fromTable({1, 2, 3, 4}, {4})
    local total = a:reduce(function(acc, v) return acc + v end, 0)
    print("reduce sum = " .. total)
end

--@api-stub: LArray:scan
-- Produces prefix accumulator values.
do
    local a = lurek.compute.fromTable({1, 2, 3, 4}, {4})
    local s = a:scan(function(acc, v) return acc + v end, 0)
    print("scan[4] = " .. s:get(4))
end

--@api-stub: LArray:type
-- Returns the type name ("LArray").
do
    local a = lurek.compute.ones({2, 2})
    print("type = " .. a:type())
end

--@api-stub: LArray:typeOf
-- Returns whether this handle matches a type name.
do
    local a = lurek.compute.ones({2, 2})
    print("is LArray = " .. tostring(a:typeOf("LArray")))
    print("is Object = " .. tostring(a:typeOf("Object")))
end

print("content/examples/compute.lua")
