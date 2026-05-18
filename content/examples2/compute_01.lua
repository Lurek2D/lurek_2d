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
    local a = lurek.compute.fromTable({0xFF, 0x0F, 0xAA}, {3}, "uint8")
    local b = lurek.compute.fromTable({0x0F, 0x0F, 0x55}, {3}, "uint8")
    local c = a:bitwiseAnd(b)
    print("AND[1] = " .. c:get(1))
end

--@api-stub: LArray:bitwiseOr
-- Returns element-wise bitwise OR.
do
    local a = lurek.compute.fromTable({0xF0, 0x0F}, {2}, "uint8")
    local b = lurek.compute.fromTable({0x0F, 0xF0}, {2}, "uint8")
    local c = a:bitwiseOr(b)
    print("OR[1] = " .. c:get(1))
end

--@api-stub: LArray:bitwiseXor
-- Returns element-wise bitwise XOR.
do
    local a = lurek.compute.fromTable({0xFF, 0x00}, {2}, "uint8")
    local b = lurek.compute.fromTable({0x0F, 0x0F}, {2}, "uint8")
    local c = a:bitwiseXor(b)
    print("XOR[1] = " .. c:get(1))
end

--@api-stub: LArray:bitwiseNot
-- Returns element-wise bitwise NOT.
do
    local a = lurek.compute.fromTable({0, 255}, {2}, "uint8")
    local c = a:bitwiseNot()
    print("NOT[1] = " .. c:get(1))
end

--@api-stub: LArray:bitwiseLShift
-- Returns element-wise left shift by a bit count.
do
    local a = lurek.compute.fromTable({1, 2, 4}, {3}, "uint8")
    local c = a:bitwiseLShift(2)
    print("lshift(2)[1] = " .. c:get(1))
end

--@api-stub: LArray:bitwiseRShift
-- Returns element-wise right shift by a bit count.
do
    local a = lurek.compute.fromTable({8, 16, 32}, {3}, "uint8")
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
    local a = lurek.compute.range(1, 16, 1)
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

print("compute_01.lua")
