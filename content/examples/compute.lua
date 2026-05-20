-- content/examples/compute.lua
-- Auto-generated from content/examples2/compute_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/compute.lua

--- Compute Module Part 1: Array Creation, Element Access, Shape, Arithmetic, Comparisons


--@api-stub: lurek.compute.newArray
do
    local a = lurek.compute.newArray({4, 4}, "float32")
    print("new 4x4 array, size = " .. a:getSize())
end

--@api-stub: lurek.compute.zeros
do
    local z = lurek.compute.zeros({3, 3})
    print("zeros 3x3, val[1,1] = " .. z:get(1, 1))
end

--@api-stub: lurek.compute.ones
do
    local o = lurek.compute.ones({2, 5}, "float32")
    print("ones 2x5, val[1,3] = " .. o:get(1, 3))
end

--@api-stub: lurek.compute.range
do
    local r = lurek.compute.range(0, 10, 2, "float32")
    print("range 0..10 step 2, size = " .. r:getSize())
end

--@api-stub: lurek.compute.fromTable
do
    local a = lurek.compute.fromTable({1, 2, 3, 4, 5, 6}, {2, 3})
    print("fromTable 2x3, val[2,1] = " .. a:get(2, 1))
end

--@api-stub: lurek.compute.gaussianKernel
do
    local k = lurek.compute.gaussianKernel(5, 1.0)
    print("gaussian 5x5, center = " .. k:get(3, 3))
end

--@api-stub: lurek.compute.rotate2dMatrix
do
    local m = lurek.compute.rotate2dMatrix(math.pi / 4)
    print("rotation 45 deg, [1,1] = " .. m:get(1, 1))
end

--@api-stub: lurek.compute.affine2d
do
    local m = lurek.compute.affine2d(10, 20, 0, 1, 1)
    print("affine tx=10 ty=20, [1,3] = " .. m:get(1, 3))
end

--@api-stub: lurek.compute.fft
do
    local freqs = lurek.compute.fft({1, 0, -1, 0})
    print("fft result count = " .. #freqs)
end

--@api-stub: lurek.compute.ifft
do
    local freqs = lurek.compute.fft({1, 0, -1, 0})
    local samples = lurek.compute.ifft(freqs)
    print("ifft reconstructed, count = " .. #samples)
end

--@api-stub: lurek.compute.fftMagnitude
do
    local mags = lurek.compute.fftMagnitude({1, 0, -1, 0})
    print("magnitudes count = " .. #mags)
end

--@api-stub: lurek.compute.getParThreshold
do
    local t = lurek.compute.getParThreshold()
    print("par threshold = " .. t)
end

--@api-stub: lurek.compute.setParThreshold
do
    local prev = lurek.compute.setParThreshold(1024)
    print("prev threshold = " .. prev)
end

--@api-stub: LArray:getShape
do
    local a = lurek.compute.newArray({3, 4})
    local shape = a:getShape()
    print("shape = " .. shape[1] .. "x" .. shape[2])
end

--@api-stub: LArray:getDimensions
do
    local a = lurek.compute.newArray({2, 3, 4})
    print("dims = " .. a:getDimensions())
end

--@api-stub: LArray:getSize
do
    local a = lurek.compute.newArray({5, 5})
    print("size = " .. a:getSize())
end

--@api-stub: LArray:getDataType
do
    local a = lurek.compute.newArray({2, 2}, "float32")
    print("dtype = " .. a:getDataType())
end

--@api-stub: LArray:isOnGPU
do
    local a = lurek.compute.ones({4, 4})
    print("on GPU = " .. tostring(a:isOnGPU()))
end

--@api-stub: LArray:get
do
    local a = lurek.compute.fromTable({10, 20, 30, 40}, {2, 2})
    print("a[1,2] = " .. a:get(1, 2))
end

--@api-stub: LArray:set
do
    local a = lurek.compute.zeros({3, 3})
    a:set(2, 2, 99)
    print("a[2,2] = " .. a:get(2, 2))
end

--@api-stub: LArray:toTable
do
    local a = lurek.compute.fromTable({1, 2, 3}, {3})
    local t = a:toTable()
    print("table = " .. t[1] .. "," .. t[2] .. "," .. t[3])
end

--@api-stub: LArray:reshape
do
    local a = lurek.compute.fromTable({1, 2, 3, 4, 5, 6}, {6})
    local b = a:reshape({2, 3})
    print("reshaped dims = " .. b:getDimensions())
end

--@api-stub: LArray:clone
do
    local a = lurek.compute.ones({3, 3})
    local b = a:clone()
    b:set(1, 1, 5)
    print("original[1,1] = " .. a:get(1, 1) .. " clone[1,1] = " .. b:get(1, 1))
end

--@api-stub: LArray:transpose
do
    local a = lurek.compute.fromTable({1, 2, 3, 4, 5, 6}, {2, 3})
    local t = a:transpose()
    local shape = t:getShape()
    print("transposed shape = " .. shape[1] .. "x" .. shape[2])
end

--@api-stub: LArray:fill
do
    local a = lurek.compute.newArray({3, 3})
    a:fill(7)
    print("filled[2,2] = " .. a:get(2, 2))
end

--@api-stub: LArray:addInplace
do
    local a = lurek.compute.ones({3, 3})
    local b = lurek.compute.ones({3, 3})
    a:addInplace(b)
    print("after addInplace[1,1] = " .. a:get(1, 1))
end

--@api-stub: LArray:subInplace
do
    local a = lurek.compute.fromTable({5, 5, 5, 5}, {2, 2})
    local b = lurek.compute.ones({2, 2})
    a:subInplace(b)
    print("after subInplace[1,1] = " .. a:get(1, 1))
end

--@api-stub: LArray:mulInplace
do
    local a = lurek.compute.fromTable({2, 3, 4, 5}, {2, 2})
    local b = lurek.compute.fromTable({10, 10, 10, 10}, {2, 2})
    a:mulInplace(b)
    print("after mulInplace[1,1] = " .. a:get(1, 1))
end

--@api-stub: LArray:divInplace
do
    local a = lurek.compute.fromTable({10, 20, 30, 40}, {2, 2})
    local b = lurek.compute.fromTable({2, 4, 5, 8}, {2, 2})
    a:divInplace(b)
    print("after divInplace[1,1] = " .. a:get(1, 1))
end

--@api-stub: LArray:add
do
    local a = lurek.compute.fromTable({1, 2, 3}, {3})
    local b = a:add(10)
    print("a + 10 → [1] = " .. b:get(1))
end

--@api-stub: LArray:sub
do
    local a = lurek.compute.fromTable({10, 20, 30}, {3})
    local b = a:sub(5)
    print("a - 5 → [2] = " .. b:get(2))
end

--@api-stub: LArray:mul
do
    local a = lurek.compute.fromTable({2, 3, 4}, {3})
    local b = a:mul(3)
    print("a * 3 → [3] = " .. b:get(3))
end

--@api-stub: LArray:div
do
    local a = lurek.compute.fromTable({10, 20, 30}, {3})
    local b = a:div(10)
    print("a / 10 → [1] = " .. b:get(1))
end

--@api-stub: LArray:pow
do
    local a = lurek.compute.fromTable({2, 3, 4}, {3})
    local b = a:pow(2)
    print("a^2 → [2] = " .. b:get(2))
end

--@api-stub: LArray:sqrt
do
    local a = lurek.compute.fromTable({4, 9, 16}, {3})
    local b = a:sqrt()
    print("sqrt → [1] = " .. b:get(1))
end

--@api-stub: LArray:abs
do
    local a = lurek.compute.fromTable({-3, -1, 2}, {3})
    local b = a:abs()
    print("abs → [1] = " .. b:get(1))
end

--@api-stub: LArray:neg
do
    local a = lurek.compute.fromTable({5, -3, 0}, {3})
    local b = a:neg()
    print("neg → [1] = " .. b:get(1))
end

--@api-stub: LArray:clamp
do
    local a = lurek.compute.fromTable({-5, 0, 3, 10, 15}, {5})
    local b = a:clamp(0, 10)
    print("clamp(0,10) → [1]=" .. b:get(1) .. " [5]=" .. b:get(5))
end

--@api-stub: LArray:eq
do
    local a = lurek.compute.fromTable({1, 2, 3, 2, 1}, {5})
    local mask = a:eq(2)
    print("eq(2) → [2] = " .. mask:get(2))
end

--@api-stub: LArray:neq
do
    local a = lurek.compute.fromTable({1, 2, 3}, {3})
    local mask = a:neq(2)
    print("neq(2) → [1] = " .. mask:get(1))
end

--@api-stub: LArray:gt
do
    local a = lurek.compute.fromTable({1, 5, 10}, {3})
    local mask = a:gt(4)
    print("gt(4) → [2] = " .. mask:get(2))
end

--@api-stub: LArray:lt
do
    local a = lurek.compute.fromTable({1, 5, 10}, {3})
    local mask = a:lt(6)
    print("lt(6) → [3] = " .. mask:get(3))
end

--@api-stub: LArray:gte
do
    local a = lurek.compute.fromTable({1, 5, 10}, {3})
    local mask = a:gte(5)
    print("gte(5) → [2] = " .. mask:get(2))
end

--@api-stub: LArray:lte
do
    local a = lurek.compute.fromTable({1, 5, 10}, {3})
    local mask = a:lte(5)
    print("lte(5) → [2] = " .. mask:get(2))
end

--@api-stub: LArray:threshold
do
    local a = lurek.compute.fromTable({0.1, 0.5, 0.9}, {3})
    local mask = a:threshold(0.4)
    print("threshold(0.4) → [1]=" .. mask:get(1) .. " [3]=" .. mask:get(3))
end

--@api-stub: LArray:where
do
    local a = lurek.compute.fromTable({10, 20, 30}, {3})
    local b = lurek.compute.fromTable({-1, -2, -3}, {3})
    local mask = a:gt(15)
    local result = a:where(mask, b)
    print("where → [1]=" .. result:get(1) .. " [2]=" .. result:get(2))
end

--@api-stub: LArray:countNonZero
do
    local a = lurek.compute.fromTable({0, 1, 0, 2, 3}, {5})
    print("nonzero count = " .. a:countNonZero())
end

--@api-stub: LArray:argmin
do
    local a = lurek.compute.fromTable({5, 1, 8, 3}, {4})
    print("argmin = " .. a:argmin())
end

--@api-stub: LArray:argmax
do
    local a = lurek.compute.fromTable({5, 1, 8, 3}, {4})
    print("argmax = " .. a:argmax())
end

--@api-stub: LArray:any
do
    local a = lurek.compute.fromTable({0, 0, 1}, {3})
    print("any = " .. tostring(a:any()))
end

--- Compute Module Part 2: Reduction, Linear Algebra, Morphology, Statistics, Functional


--@api-stub: LArray:all
do
    local a = lurek.compute.fromTable({1, 2, 3}, {3})
    print("all nonzero = " .. tostring(a:all()))
end

--@api-stub: LArray:sum
do
    local a = lurek.compute.fromTable({1, 2, 3, 4}, {4})
    print("sum = " .. a:sum())
end

--@api-stub: LArray:mean
do
    local a = lurek.compute.fromTable({2, 4, 6, 8}, {4})
    print("mean = " .. a:mean())
end

--@api-stub: LArray:min
do
    local a = lurek.compute.fromTable({7, 2, 9, 1}, {4})
    print("min = " .. a:min())
end

--@api-stub: LArray:max
do
    local a = lurek.compute.fromTable({7, 2, 9, 1}, {4})
    print("max = " .. a:max())
end

--@api-stub: LArray:matmul
do
    local a = lurek.compute.fromTable({1, 2, 3, 4}, {2, 2})
    local b = lurek.compute.fromTable({5, 6, 7, 8}, {2, 2})
    local c = a:matmul(b)
    print("matmul[1,1] = " .. c:get(1, 1))
end

--@api-stub: LArray:dot
do
    local a = lurek.compute.fromTable({1, 2, 3}, {3})
    local b = lurek.compute.fromTable({4, 5, 6}, {3})
    print("dot = " .. a:dot(b))
end

--@api-stub: LArray:bitwiseAnd
do
    local a = lurek.compute.fromTable({0xFF, 0x0F, 0xAA}, {3}, "int32")
    local b = lurek.compute.fromTable({0x0F, 0x0F, 0x55}, {3}, "int32")
    local c = a:bitwiseAnd(b)
    print("AND[1] = " .. c:get(1))
end

--@api-stub: LArray:bitwiseOr
do
    local a = lurek.compute.fromTable({0xF0, 0x0F}, {2}, "int32")
    local b = lurek.compute.fromTable({0x0F, 0xF0}, {2}, "int32")
    local c = a:bitwiseOr(b)
    print("OR[1] = " .. c:get(1))
end

--@api-stub: LArray:bitwiseXor
do
    local a = lurek.compute.fromTable({0xFF, 0x00}, {2}, "int32")
    local b = lurek.compute.fromTable({0x0F, 0x0F}, {2}, "int32")
    local c = a:bitwiseXor(b)
    print("XOR[1] = " .. c:get(1))
end

--@api-stub: LArray:bitwiseNot
do
    local a = lurek.compute.fromTable({0, 255}, {2}, "int32")
    local c = a:bitwiseNot()
    print("NOT[1] = " .. c:get(1))
end

--@api-stub: LArray:bitwiseLShift
do
    local a = lurek.compute.fromTable({1, 2, 4}, {3}, "int32")
    local c = a:bitwiseLShift(2)
    print("lshift(2)[1] = " .. c:get(1))
end

--@api-stub: LArray:bitwiseRShift
do
    local a = lurek.compute.fromTable({8, 16, 32}, {3}, "int32")
    local c = a:bitwiseRShift(2)
    print("rshift(2)[1] = " .. c:get(1))
end

--@api-stub: LArray:convolve2D
do
    local img = lurek.compute.zeros({5, 5})
    img:set(3, 3, 1)
    local kernel = lurek.compute.gaussianKernel(3, 1.0)
    local result = img:convolve2D(kernel)
    print("conv center = " .. result:get(3, 3))
end

--@api-stub: LArray:dilate
do
    local a = lurek.compute.zeros({5, 5})
    a:set(3, 3, 1)
    local d = a:dilate(1)
    print("dilated[2,3] = " .. d:get(2, 3))
end

--@api-stub: LArray:erode
do
    local a = lurek.compute.ones({5, 5})
    a:set(1, 1, 0)
    local e = a:erode(1)
    print("eroded[2,2] = " .. e:get(2, 2))
end

--@api-stub: LArray:floodFill
do
    local a = lurek.compute.zeros({5, 5})
    a:set(1, 1, 1)
    a:set(1, 2, 1)
    local filled = a:floodFill(1, 1, 9)
    print("flood[1,2] = " .. filled:get(1, 2))
end

--@api-stub: LArray:getRegion
do
    local a = lurek.compute.range(1, 17, 1)
    local m = a:reshape({4, 4})
    local region = m:getRegion(2, 2, 2, 2)
    print("region[1,1] = " .. region:get(1, 1))
end

--@api-stub: LArray:setRegion
do
    local a = lurek.compute.zeros({4, 4})
    local patch = lurek.compute.ones({2, 2})
    a:setRegion(2, 2, patch)
    print("after setRegion[2,2] = " .. a:get(2, 2))
end

--@api-stub: LArray:cumsum
do
    local a = lurek.compute.fromTable({1, 2, 3, 4}, {4})
    local cs = a:cumsum()
    print("cumsum[4] = " .. cs:get(4))
end

--@api-stub: LArray:diff
do
    local a = lurek.compute.fromTable({1, 3, 6, 10}, {4})
    local d = a:diff()
    print("diff[1] = " .. d:get(1))
end

--@api-stub: LArray:histogram
do
    local a = lurek.compute.fromTable({1, 2, 3, 4, 5, 6, 7, 8}, {8})
    local bins = a:histogram(4)
    print("bin count = " .. #bins)
end

--@api-stub: LArray:percentile
do
    local a = lurek.compute.range(1, 100, 1)
    local p50 = a:percentile(50)
    print("p50 = " .. p50)
end

--@api-stub: LArray:covariance
do
    local a = lurek.compute.fromTable({1, 2, 3, 4, 5}, {5})
    local b = lurek.compute.fromTable({2, 4, 6, 8, 10}, {5})
    print("covariance = " .. a:covariance(b))
end

--@api-stub: LArray:pearsonCorr
do
    local a = lurek.compute.fromTable({1, 2, 3, 4, 5}, {5})
    local b = lurek.compute.fromTable({2, 4, 6, 8, 10}, {5})
    print("pearson = " .. a:pearsonCorr(b))
end

--@api-stub: LArray:normalizeRange
do
    local a = lurek.compute.fromTable({0, 50, 100}, {3})
    local n = a:normalizeRange(0, 1)
    print("normalized[2] = " .. n:get(2))
end

--@api-stub: LArray:zscore
do
    local a = lurek.compute.fromTable({2, 4, 4, 4, 5, 5, 7, 9}, {8})
    local z = a:zscore()
    print("zscore[1] = " .. z:get(1))
end

--@api-stub: LArray:convolve1d
do
    local signal = lurek.compute.fromTable({0, 1, 2, 3, 4}, {5})
    local kernel = lurek.compute.fromTable({1, 0, -1}, {3})
    local c = signal:convolve1d(kernel)
    print("conv1d size = " .. c:getSize())
end

--@api-stub: LArray:correlate1d
do
    local signal = lurek.compute.fromTable({0, 0, 1, 0, 0}, {5})
    local templ = lurek.compute.fromTable({1}, {1})
    local c = signal:correlate1d(templ)
    print("corr peak at [3] = " .. c:get(3))
end

--@api-stub: LArray:normalizeVec
do
    local v = lurek.compute.fromTable({3, 4}, {2})
    local n = v:normalizeVec()
    print("normalized[1] = " .. n:get(1))
end

--@api-stub: LArray:outer
do
    local a = lurek.compute.fromTable({1, 2, 3}, {3})
    local b = lurek.compute.fromTable({4, 5}, {2})
    local o = a:outer(b)
    print("outer[1,2] = " .. o:get(1, 2))
end

--@api-stub: LArray:cross2d
do
    local a = lurek.compute.fromTable({1, 0}, {2})
    local b = lurek.compute.fromTable({0, 1}, {2})
    print("cross2d = " .. a:cross2d(b))
end

--@api-stub: LArray:transformPoints
do
    local m = lurek.compute.affine2d(10, 20, 0, 1, 1)
    local pts = lurek.compute.fromTable({0, 0, 5, 5}, {2, 2})
    local result = m:transformPoints(pts)
    print("transformed[1,1] = " .. result:get(1, 1))
end

--@api-stub: LArray:sobel
do
    local img = lurek.compute.zeros({5, 5})
    img:set(3, 3, 1)
    local grad = img:sobel()
    print("gx size = " .. grad.gx:getSize())
end

--@api-stub: LArray:linsolve
do
    local a = lurek.compute.fromTable({2, 1, 5, 7}, {2, 2})
    local b = lurek.compute.fromTable({11, 13}, {2})
    local x = a:linsolve(b)
    print("x[1] = " .. x:get(1))
end

--@api-stub: LArray:luDecompose
do
    local a = lurek.compute.fromTable({4, 3, 6, 3}, {2, 2})
    local lu = a:luDecompose()
    print("n = " .. lu.n .. " det_sign = " .. lu.det_sign)
end

--@api-stub: LArray:eigenPower
do
    local a = lurek.compute.fromTable({2, 1, 1, 2}, {2, 2})
    local result = a:eigenPower(100, 1e-6)
    print("eigenvalue = " .. result.value)
end

--@api-stub: LArray:map
do
    local a = lurek.compute.fromTable({1, 4, 9}, {3})
    local b = a:map(function(x) return x * 2 end)
    print("mapped[2] = " .. b:get(2))
end

--@api-stub: LArray:eval
do
    local a = lurek.compute.fromTable({1, 2, 3}, {3})
    local b = a:eval("x * x + 1")
    print("eval[2] = " .. b:get(2))
end

--@api-stub: LArray:reduce
do
    local a = lurek.compute.fromTable({1, 2, 3, 4}, {4})
    local total = a:reduce(function(acc, v) return acc + v end, 0)
    print("reduce sum = " .. total)
end

--@api-stub: LArray:scan
do
    local a = lurek.compute.fromTable({1, 2, 3, 4}, {4})
    local s = a:scan(function(acc, v) return acc + v end, 0)
    print("scan[4] = " .. s:get(4))
end

--@api-stub: LArray:type
do
    local a = lurek.compute.ones({2, 2})
    print("type = " .. a:type())
end

--@api-stub: LArray:typeOf
do
    local a = lurek.compute.ones({2, 2})
    print("is LArray = " .. tostring(a:typeOf("LArray")))
    print("is Object = " .. tostring(a:typeOf("Object")))
end

print("content/examples/compute.lua")
