-- content/examples/compute.lua
-- Lurek2D lurek.compute API Reference
-- Run with: cargo run -- content/examples/compute
--
-- Scenario: An image processing pipeline — load a heightmap as an array,
-- apply convolution filters (blur, edge detect), normalize values, compute
-- statistics, and perform FFT analysis. Also demonstrates matrix math for
-- 2D transforms and bitwise operations for tile flag encoding.

print("=== lurek.compute — Numeric Arrays ===\n")

-- =============================================================================
-- Array Creation
-- =============================================================================

--@api-stub: lurek.compute.newArray
-- Demonstrates the proper usage of lurek.compute.newArray.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_newArray()
    local arr = lurek.compute.newArray({4, 4}, "f32")
end
local _ok, _err = pcall(demo_lurek_compute_newArray)

--@api-stub: lurek.compute.zeros
-- Demonstrates the proper usage of lurek.compute.zeros.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_zeros()
    local black = lurek.compute.zeros({256, 256}, "f32")
end
local _ok, _err = pcall(demo_lurek_compute_zeros)

--@api-stub: lurek.compute.ones
-- Demonstrates the proper usage of lurek.compute.ones.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_ones()
    local white = lurek.compute.ones({256, 256}, "f32")
end
local _ok, _err = pcall(demo_lurek_compute_ones)

--@api-stub: lurek.compute.range
-- Demonstrates the proper usage of lurek.compute.range.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_range()
    local ramp = lurek.compute.range(0, 255, 1, "f32")
end
local _ok, _err = pcall(demo_lurek_compute_range)

--@api-stub: lurek.compute.fromTable
-- Demonstrates the proper usage of lurek.compute.fromTable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_fromTable()
    local kernel = lurek.compute.fromTable({
    {-1, -1, -1},
    {-1,  8, -1},
    {-1, -1, -1},
    }, "f32")
end
local _ok, _err = pcall(demo_lurek_compute_fromTable)

-- =============================================================================
-- Array Properties
-- =============================================================================

--@api-stub: Array:getShape
-- Demonstrates the proper usage of Array:getShape.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_getShape()
    local shape = arr:getShape()
    print("shape: " .. shape[1] .. "x" .. shape[2])
end
local _ok, _err = pcall(demo_Array_getShape)

--@api-stub: Array:getDimensions
-- Demonstrates the proper usage of Array:getDimensions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_getDimensions()
    print("dims: " .. arr:getDimensions())
end
local _ok, _err = pcall(demo_Array_getDimensions)

--@api-stub: Array:getSize
-- Demonstrates the proper usage of Array:getSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_getSize()
    print("total elements: " .. arr:getSize())
end
local _ok, _err = pcall(demo_Array_getSize)

--@api-stub: Array:getDataType
-- Demonstrates the proper usage of Array:getDataType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_getDataType()
    print("dtype: " .. arr:getDataType())
end
local _ok, _err = pcall(demo_Array_getDataType)

--@api-stub: Array:isOnGPU
-- Demonstrates the proper usage of Array:isOnGPU.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_isOnGPU()
    print("on GPU: " .. tostring(arr:isOnGPU()))
end
local _ok, _err = pcall(demo_Array_isOnGPU)

-- =============================================================================
-- Element Access
-- =============================================================================

--@api-stub: Array:set
-- Demonstrates the proper usage of Array:set.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_set()
    arr:set({1, 1}, 42.0)
    arr:set({2, 3}, 7.5)
end
local _ok, _err = pcall(demo_Array_set)

--@api-stub: Array:get
-- Demonstrates the proper usage of Array:get.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_get()
    print("arr[1,1]: " .. arr:get({1, 1}))
end
local _ok, _err = pcall(demo_Array_get)

--@api-stub: Array:fill
-- Demonstrates the proper usage of Array:fill.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_fill()
    arr:fill(1.0)
end
local _ok, _err = pcall(demo_Array_fill)

--@api-stub: Array:toTable
-- Demonstrates the proper usage of Array:toTable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_toTable()
    local t = arr:toTable()
    print("table elements: " .. #t)
end
local _ok, _err = pcall(demo_Array_toTable)

-- =============================================================================
-- Shape Operations
-- =============================================================================

--@api-stub: Array:reshape
-- Demonstrates the proper usage of Array:reshape.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_reshape()
    local flat = arr:reshape({16})
    print("reshaped: " .. flat:getSize())
end
local _ok, _err = pcall(demo_Array_reshape)

--@api-stub: Array:clone
-- Demonstrates the proper usage of Array:clone.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_clone()
    local copy = arr:clone()
end
local _ok, _err = pcall(demo_Array_clone)

--@api-stub: Array:transpose
-- Demonstrates the proper usage of Array:transpose.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_transpose()
    local transposed = arr:transpose()
end
local _ok, _err = pcall(demo_Array_transpose)

-- =============================================================================
-- Math Operations — Element-wise
-- =============================================================================

--@api-stub: Array:pow
-- Demonstrates the proper usage of Array:pow.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_pow()
    local squared = arr:pow(2)
end
local _ok, _err = pcall(demo_Array_pow)

--@api-stub: Array:sqrt
-- Demonstrates the proper usage of Array:sqrt.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_sqrt()
    local roots = squared:sqrt()
end
local _ok, _err = pcall(demo_Array_sqrt)

--@api-stub: Array:abs
-- Demonstrates the proper usage of Array:abs.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_abs()
    local magnitudes = arr:abs()
end
local _ok, _err = pcall(demo_Array_abs)

--@api-stub: Array:neg
-- Demonstrates the proper usage of Array:neg.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_neg()
    local negated = arr:neg()
end
local _ok, _err = pcall(demo_Array_neg)

--@api-stub: Array:clamp
-- Demonstrates the proper usage of Array:clamp.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_clamp()
    local clamped = arr:clamp(0.0, 1.0)
end
local _ok, _err = pcall(demo_Array_clamp)

--@api-stub: Array:threshold
-- Demonstrates the proper usage of Array:threshold.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_threshold()
    local binary = arr:threshold(0.5)
end
local _ok, _err = pcall(demo_Array_threshold)

-- =============================================================================
-- Reduction Operations — Statistics
-- =============================================================================

--@api-stub: Array:sum
-- Demonstrates the proper usage of Array:sum.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_sum()
    print("sum: " .. arr:sum())
end
local _ok, _err = pcall(demo_Array_sum)

--@api-stub: Array:mean
-- Demonstrates the proper usage of Array:mean.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_mean()
    print("mean: " .. arr:mean())
end
local _ok, _err = pcall(demo_Array_mean)

--@api-stub: Array:min
-- Demonstrates the proper usage of Array:min.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_min()
    print("min: " .. arr:min())
end
local _ok, _err = pcall(demo_Array_min)

--@api-stub: Array:max
-- Demonstrates the proper usage of Array:max.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_max()
    print("max: " .. arr:max())
end
local _ok, _err = pcall(demo_Array_max)

--@api-stub: Array:argmin
-- Demonstrates the proper usage of Array:argmin.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_argmin()
    print("argmin: " .. arr:argmin())
end
local _ok, _err = pcall(demo_Array_argmin)

--@api-stub: Array:argmax
-- Demonstrates the proper usage of Array:argmax.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_argmax()
    print("argmax: " .. arr:argmax())
end
local _ok, _err = pcall(demo_Array_argmax)

--@api-stub: Array:countNonZero
-- Demonstrates the proper usage of Array:countNonZero.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_countNonZero()
    print("nonzero: " .. arr:countNonZero())
end
local _ok, _err = pcall(demo_Array_countNonZero)

--@api-stub: Array:any
-- Demonstrates the proper usage of Array:any.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_any()
    print("any > 0: " .. tostring(arr:any()))
end
local _ok, _err = pcall(demo_Array_any)

--@api-stub: Array:all
-- Demonstrates the proper usage of Array:all.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_all()
    print("all > 0: " .. tostring(arr:all()))
end
local _ok, _err = pcall(demo_Array_all)

-- =============================================================================
-- Cumulative & Differential
-- =============================================================================

--@api-stub: Array:cumsum
-- Demonstrates the proper usage of Array:cumsum.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_cumsum()
    local cumulative = ramp:cumsum()
end
local _ok, _err = pcall(demo_Array_cumsum)

--@api-stub: Array:diff
-- Demonstrates the proper usage of Array:diff.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_diff()
    local gradient = ramp:diff()
end
local _ok, _err = pcall(demo_Array_diff)

--@api-stub: Array:percentile
-- Demonstrates the proper usage of Array:percentile.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_percentile()
    print("median: " .. ramp:percentile(50))
end
local _ok, _err = pcall(demo_Array_percentile)

-- =============================================================================
-- Matrix Operations
-- =============================================================================

--@api-stub: Array:matmul
-- Demonstrates the proper usage of Array:matmul.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_matmul()
    local a = lurek.compute.fromTable({{1,2},{3,4}}, "f32")
    local b = lurek.compute.fromTable({{5,6},{7,8}}, "f32")
    local product = a:matmul(b)
    print("matmul [1,1]: " .. product:get({1, 1}))
end
local _ok, _err = pcall(demo_Array_matmul)

--@api-stub: Array:dot
-- Demonstrates the proper usage of Array:dot.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_dot()
    local d = a:dot(b)
    print("dot: " .. d)
end
local _ok, _err = pcall(demo_Array_dot)

--@api-stub: Array:outer
-- Demonstrates the proper usage of Array:outer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_outer()
    local v1 = lurek.compute.fromTable({1, 2, 3}, "f32")
    local v2 = lurek.compute.fromTable({4, 5}, "f32")
    local outer_prod = v1:outer(v2)
    print("outer shape: " .. outer_prod:getShape()[1] .. "x" .. outer_prod:getShape()[2])
end
local _ok, _err = pcall(demo_Array_outer)

--@api-stub: Array:linsolve
-- Demonstrates the proper usage of Array:linsolve.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_linsolve()
    local solution = a:linsolve(lurek.compute.fromTable({1, 2}, "f32"))
end
local _ok, _err = pcall(demo_Array_linsolve)

--@api-stub: Array:luDecompose
-- Demonstrates the proper usage of Array:luDecompose.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_luDecompose()
    local L, U = a:luDecompose()
end
local _ok, _err = pcall(demo_Array_luDecompose)

-- =============================================================================
-- Statistical Analysis
-- =============================================================================

--@api-stub: Array:covariance
-- Demonstrates the proper usage of Array:covariance.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_covariance()
    local cov = a:covariance(b)
    print("covariance: " .. cov)
end
local _ok, _err = pcall(demo_Array_covariance)

--@api-stub: Array:pearsonCorr
-- Demonstrates the proper usage of Array:pearsonCorr.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_pearsonCorr()
    local corr = a:pearsonCorr(b)
    print("correlation: " .. corr)
end
local _ok, _err = pcall(demo_Array_pearsonCorr)

--@api-stub: Array:normalizeRange
-- Demonstrates the proper usage of Array:normalizeRange.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_normalizeRange()
    local normed = arr:normalizeRange()
end
local _ok, _err = pcall(demo_Array_normalizeRange)

--@api-stub: Array:zscore
-- Demonstrates the proper usage of Array:zscore.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_zscore()
    local zscored = arr:zscore()
end
local _ok, _err = pcall(demo_Array_zscore)

-- =============================================================================
-- Convolution & Image Processing
-- =============================================================================

--@api-stub: lurek.compute.gaussianKernel
-- Demonstrates the proper usage of lurek.compute.gaussianKernel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_gaussianKernel()
    local blur_kernel = lurek.compute.gaussianKernel(5, 1.0)
end
local _ok, _err = pcall(demo_lurek_compute_gaussianKernel)

--@api-stub: Array:convolve2D
-- Demonstrates the proper usage of Array:convolve2D.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_convolve2D()
    local edges = black:convolve2D(kernel)
end
local _ok, _err = pcall(demo_Array_convolve2D)

--@api-stub: Array:convolve1d
-- Demonstrates the proper usage of Array:convolve1d.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_convolve1d()
    local smoothed = ramp:convolve1d(lurek.compute.fromTable({0.25, 0.5, 0.25}, "f32"))
end
local _ok, _err = pcall(demo_Array_convolve1d)

--@api-stub: Array:correlate1d
-- Demonstrates the proper usage of Array:correlate1d.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_correlate1d()
    local correlated = ramp:correlate1d(lurek.compute.fromTable({1, -1}, "f32"))
end
local _ok, _err = pcall(demo_Array_correlate1d)

--@api-stub: Array:dilate
-- Demonstrates the proper usage of Array:dilate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_dilate()
    local dilated = binary:dilate(3)
end
local _ok, _err = pcall(demo_Array_dilate)

--@api-stub: Array:erode
-- Demonstrates the proper usage of Array:erode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_erode()
    local eroded = binary:erode(3)
end
local _ok, _err = pcall(demo_Array_erode)

--@api-stub: Array:sobel
-- Demonstrates the proper usage of Array:sobel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_sobel()
    local sobel_result = black:sobel()
end
local _ok, _err = pcall(demo_Array_sobel)

-- =============================================================================
-- FFT — Frequency analysis
-- =============================================================================

--@api-stub: lurek.compute.fft
-- Demonstrates the proper usage of lurek.compute.fft.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_fft()
    local freq = lurek.compute.fft(ramp)
end
local _ok, _err = pcall(demo_lurek_compute_fft)

--@api-stub: lurek.compute.ifft
-- Demonstrates the proper usage of lurek.compute.ifft.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_ifft()
    local spatial = lurek.compute.ifft(freq)
end
local _ok, _err = pcall(demo_lurek_compute_ifft)

--@api-stub: lurek.compute.fftMagnitude
-- Demonstrates the proper usage of lurek.compute.fftMagnitude.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_fftMagnitude()
    local magnitude = lurek.compute.fftMagnitude(freq)
end
local _ok, _err = pcall(demo_lurek_compute_fftMagnitude)

-- =============================================================================
-- Geometry Transforms
-- =============================================================================

--@api-stub: lurek.compute.rotate2dMatrix
-- Demonstrates the proper usage of lurek.compute.rotate2dMatrix.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_rotate2dMatrix()
    local rot = lurek.compute.rotate2dMatrix(math.pi / 4)
end
local _ok, _err = pcall(demo_lurek_compute_rotate2dMatrix)

--@api-stub: lurek.compute.affine2d
-- Demonstrates the proper usage of lurek.compute.affine2d.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_affine2d()
    local affine = lurek.compute.affine2d(1, 0, 10, 0, 1, 20)
end
local _ok, _err = pcall(demo_lurek_compute_affine2d)

--@api-stub: Array:transformPoints
-- Demonstrates the proper usage of Array:transformPoints.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_transformPoints()
    local points = lurek.compute.fromTable({{10, 20}, {30, 40}}, "f32")
    local transformed = points:transformPoints(affine)
end
local _ok, _err = pcall(demo_Array_transformPoints)

--@api-stub: Array:normalizeVec
-- Demonstrates the proper usage of Array:normalizeVec.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_normalizeVec()
    local directions = lurek.compute.fromTable({{3, 4}, {0, 5}}, "f32")
    local unit_dirs = directions:normalizeVec()
end
local _ok, _err = pcall(demo_Array_normalizeVec)

--@api-stub: Array:cross2d
-- Demonstrates the proper usage of Array:cross2d.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_cross2d()
    local cross = lurek.compute.fromTable({3, 4}, "f32"):cross2d(lurek.compute.fromTable({1, 2}, "f32"))
    print("2D cross: " .. cross)
end
local _ok, _err = pcall(demo_Array_cross2d)

-- =============================================================================
-- Bitwise Operations — Tile flag encoding
-- =============================================================================

--@api-stub: Array:bitwiseAnd
-- Demonstrates the proper usage of Array:bitwiseAnd.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_bitwiseAnd()
    local flags = lurek.compute.fromTable({0xFF, 0x0F, 0xF0}, "u32")
    local masked = flags:bitwiseAnd(lurek.compute.fromTable({0x0F, 0x0F, 0x0F}, "u32"))
end
local _ok, _err = pcall(demo_Array_bitwiseAnd)

--@api-stub: Array:bitwiseOr
-- Demonstrates the proper usage of Array:bitwiseOr.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_bitwiseOr()
    local combined = flags:bitwiseOr(lurek.compute.fromTable({0x01, 0x02, 0x04}, "u32"))
end
local _ok, _err = pcall(demo_Array_bitwiseOr)

--@api-stub: Array:bitwiseXor
-- Demonstrates the proper usage of Array:bitwiseXor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_bitwiseXor()
    local toggled = flags:bitwiseXor(lurek.compute.fromTable({0xFF, 0xFF, 0xFF}, "u32"))
end
local _ok, _err = pcall(demo_Array_bitwiseXor)

--@api-stub: Array:bitwiseNot
-- Demonstrates the proper usage of Array:bitwiseNot.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_bitwiseNot()
    local inverted = flags:bitwiseNot()
end
local _ok, _err = pcall(demo_Array_bitwiseNot)

--@api-stub: Array:bitwiseLShift
-- Demonstrates the proper usage of Array:bitwiseLShift.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_bitwiseLShift()
    local shifted_l = flags:bitwiseLShift(4)
end
local _ok, _err = pcall(demo_Array_bitwiseLShift)

--@api-stub: Array:bitwiseRShift
-- Demonstrates the proper usage of Array:bitwiseRShift.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_bitwiseRShift()
    local shifted_r = flags:bitwiseRShift(4)
end
local _ok, _err = pcall(demo_Array_bitwiseRShift)

-- =============================================================================
-- Type & Identity
-- =============================================================================

--@api-stub: Array:type
-- Demonstrates the proper usage of Array:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_type()
    print("type: " .. arr:type())
end
local _ok, _err = pcall(demo_Array_type)

--@api-stub: Array:typeOf
-- Demonstrates the proper usage of Array:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_typeOf()
    print("is Array: " .. tostring(arr:typeOf("Array")))
    print("\n-- compute.lua example complete --")
end
local _ok, _err = pcall(demo_Array_typeOf)

-- =============================================================================
-- STUBS: 67 uncovered lurek.compute API item(s)
-- =============================================================================

-- ---- Stub: lurek.compute.newArray ----------------------------------------
--@api-stub: lurek.compute.newArray
-- Demonstrates the proper usage of lurek.compute.newArray.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_newArray()
    local mat = lurek.compute.newArray({ 4, 4 }, "f32")
    print("array shape:", mat:getDimensions(), "dims")
end
local _ok, _err = pcall(demo_lurek_compute_newArray)

-- ---- Stub: lurek.compute.zeros -------------------------------------------
--@api-stub: lurek.compute.zeros
-- Demonstrates the proper usage of lurek.compute.zeros.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_zeros()
    local z = lurek.compute.zeros({ 64 }, "f32")
    print("zeros size:", z:getSize())
end
local _ok, _err = pcall(demo_lurek_compute_zeros)

-- ---- Stub: lurek.compute.ones --------------------------------------------
--@api-stub: lurek.compute.ones
-- Demonstrates the proper usage of lurek.compute.ones.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_ones()
    local ones = lurek.compute.ones({ 8, 8 }, "f32")
    print("ones dtype:", ones:getDataType())
end
local _ok, _err = pcall(demo_lurek_compute_ones)

-- ---- Stub: lurek.compute.range -------------------------------------------
--@api-stub: lurek.compute.range
-- Demonstrates the proper usage of lurek.compute.range.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_range()
    local idx = lurek.compute.range(0, 100, 1, "i32")
    print("range size:", idx:getSize())  -- 100
end
local _ok, _err = pcall(demo_lurek_compute_range)

-- ---- Stub: lurek.compute.fromTable ---------------------------------------
--@api-stub: lurek.compute.fromTable
-- Demonstrates the proper usage of lurek.compute.fromTable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_fromTable()
    local arr = lurek.compute.fromTable({ 1,2,3, 4,5,6 }, { 2, 3 }, "f32")
    print("arr shape:", arr:getShape()[1], "x", arr:getShape()[2])
end
local _ok, _err = pcall(demo_lurek_compute_fromTable)

-- ---- Stub: lurek.compute.gaussianKernel ----------------------------------
--@api-stub: lurek.compute.gaussianKernel
-- Demonstrates the proper usage of lurek.compute.gaussianKernel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_gaussianKernel()
    local kern = lurek.compute.gaussianKernel(5, 1.0)
    print("kernel size:", kern:getSize())
end
local _ok, _err = pcall(demo_lurek_compute_gaussianKernel)

-- ---- Stub: lurek.compute.rotate2dMatrix ----------------------------------
--@api-stub: lurek.compute.rotate2dMatrix
-- Demonstrates the proper usage of lurek.compute.rotate2dMatrix.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_rotate2dMatrix()
    local rot = lurek.compute.rotate2dMatrix(math.pi / 4)
    print("rotation matrix dims:", rot:getDimensions())
end
local _ok, _err = pcall(demo_lurek_compute_rotate2dMatrix)

-- ---- Stub: lurek.compute.affine2d ----------------------------------------
--@api-stub: lurek.compute.affine2d
-- Demonstrates the proper usage of lurek.compute.affine2d.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_affine2d()
    local aff = lurek.compute.affine2d(100, 50, math.pi / 6, 1.0, 1.0)
    print("affine shape:", aff:getShape()[1], "x", aff:getShape()[2])
end
local _ok, _err = pcall(demo_lurek_compute_affine2d)

-- ---- Stub: lurek.compute.fft ---------------------------------------------
--@api-stub: lurek.compute.fft
-- Analyse a recorded audio waveform from the OST buffer to extract
-- dominant frequency bins for a visualiser bar graph.
local samples = {}
for i = 1, 64 do samples[i] = math.sin(2 * math.pi * i / 16) end
local spectrum = lurek.compute.fft(samples)
print("FFT bins:", #spectrum)

-- ---- Stub: lurek.compute.ifft --------------------------------------------
--@api-stub: lurek.compute.ifft
-- Demonstrates the proper usage of lurek.compute.ifft.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_ifft()
    local restored = lurek.compute.ifft(spectrum)
    print("iFFT samples:", #restored)
end
local _ok, _err = pcall(demo_lurek_compute_ifft)

-- ---- Stub: lurek.compute.fftMagnitude ------------------------------------
--@api-stub: lurek.compute.fftMagnitude
-- Demonstrates the proper usage of lurek.compute.fftMagnitude.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_fftMagnitude()
    local magnitudes = lurek.compute.fftMagnitude(samples)
    print("max magnitude:", magnitudes[1])
end
local _ok, _err = pcall(demo_lurek_compute_fftMagnitude)

-- ---- Stub: Array:getShape ------------------------------------------------
--@api-stub: Array:getShape
-- Demonstrates the proper usage of Array:getShape.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_getShape()
    local shape = arr:getShape()
    print("shape:", shape[1], "rows,", shape[2], "cols")
end
local _ok, _err = pcall(demo_Array_getShape)

-- ---- Stub: Array:getDimensions -------------------------------------------
--@api-stub: Array:getDimensions
-- Demonstrates the proper usage of Array:getDimensions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_getDimensions()
    print("dimensions:", arr:getDimensions())  -- 2
end
local _ok, _err = pcall(demo_Array_getDimensions)

-- ---- Stub: Array:getSize -------------------------------------------------
--@api-stub: Array:getSize
-- Demonstrates the proper usage of Array:getSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_getSize()
    print("total elements:", arr:getSize())  -- 6
end
local _ok, _err = pcall(demo_Array_getSize)

-- ---- Stub: Array:getDataType ---------------------------------------------
--@api-stub: Array:getDataType
-- Demonstrates the proper usage of Array:getDataType.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_getDataType()
    print("data type:", arr:getDataType())  -- "f32"
end
local _ok, _err = pcall(demo_Array_getDataType)

-- ---- Stub: Array:isOnGPU -------------------------------------------------
--@api-stub: Array:isOnGPU
-- Demonstrates the proper usage of Array:isOnGPU.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_isOnGPU()
    print("on GPU:", arr:isOnGPU())  -- false (CPU array)
end
local _ok, _err = pcall(demo_Array_isOnGPU)

-- ---- Stub: Array:get -----------------------------------------------------
--@api-stub: Array:get
-- Demonstrates the proper usage of Array:get.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_get()
    print("cost at (1,2):", arr:get(1, 2))  -- 2.0
end
local _ok, _err = pcall(demo_Array_get)

-- ---- Stub: Array:set -----------------------------------------------------
--@api-stub: Array:set
-- Demonstrates the proper usage of Array:set.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_set()
    arr:set(1, 3, 99.0)
    print("obstacle cost:", arr:get(1, 3))  -- 99.0
end
local _ok, _err = pcall(demo_Array_set)

-- ---- Stub: Array:toTable -------------------------------------------------
--@api-stub: Array:toTable
-- Demonstrates the proper usage of Array:toTable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_toTable()
    local flat = arr:toTable()
    print("flat table length:", #flat)
end
local _ok, _err = pcall(demo_Array_toTable)

-- ---- Stub: Array:reshape -------------------------------------------------
--@api-stub: Array:reshape
-- Demonstrates the proper usage of Array:reshape.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_reshape()
    local flat_arr = arr:reshape({ 6 })
    print("reshaped to 1D, size:", flat_arr:getSize())
end
local _ok, _err = pcall(demo_Array_reshape)

-- ---- Stub: Array:clone ---------------------------------------------------
--@api-stub: Array:clone
-- Clone the master cost grid before running a search so the search
-- can mark visited cells without corrupting the original.
local working = arr:clone()
working:set(1, 1, 0)
print("clone differs from original:", working:get(1,1) ~= arr:get(1,1))

-- ---- Stub: Array:transpose -----------------------------------------------
--@api-stub: Array:transpose
-- Transpose the adjacency matrix to invert edge directions in the
-- graph so ancestor queries can reuse the same structure.
local adj = lurek.compute.fromTable({ 1,0,0,1,0,1,0,0,1 }, { 3, 3 }, "f32")
local adjT = adj:transpose()
print("transposed (0,1):", adjT:get(1, 2))

-- ---- Stub: Array:fill ----------------------------------------------------
--@api-stub: Array:fill
-- Reset the influence map to 0 before accumulating new threat values
-- at the start of each AI tick.
local inf_map = lurek.compute.newArray({ 16, 16 }, "f32")
inf_map:fill(0.0)
print("influence map cleared, sample:", inf_map:get(1, 1))

-- ---- Stub: Array:pow -----------------------------------------------------
--@api-stub: Array:pow
-- Square each distance value in the heuristic array to emphasise
-- greater separation in the A* priority calculation.
local dist = lurek.compute.fromTable({ 1, 2, 3, 4 }, { 4 }, "f32")
local dist2 = dist:pow(2)
print("squared distances:", dist2:get(1), dist2:get(2))  -- 1, 4

-- ---- Stub: Array:sqrt ----------------------------------------------------
--@api-stub: Array:sqrt
-- Compute Euclidean distances from squared difference arrays without
-- a Lua loop for a 2D influence map range pass.
local sq = lurek.compute.fromTable({ 4, 9, 16, 25 }, { 4 }, "f32")
local rooted = sq:sqrt()
print("distances:", rooted:get(1), rooted:get(2))  -- 2, 3

-- ---- Stub: Array:abs -----------------------------------------------------
--@api-stub: Array:abs
-- Take the absolute value of signed delta arrays to compute the
-- L1 norm for a pathfinding Manhattan heuristic.
local deltas = lurek.compute.fromTable({ -3, 1, -5, 2 }, { 4 }, "f32")
local abs_d = deltas:abs()
print("abs deltas:", abs_d:get(1), abs_d:get(2))  -- 3, 1

-- ---- Stub: Array:neg -----------------------------------------------------
--@api-stub: Array:neg
-- Negate the reward array to convert a reward landscape into a cost
-- landscape for cost-minimising search algorithms.
local reward = lurek.compute.fromTable({ 10, -3, 5 }, { 3 }, "f32")
local cost = reward:neg()
print("cost values:", cost:get(1), cost:get(2))  -- -10, 3

-- ---- Stub: Array:clamp ---------------------------------------------------
--@api-stub: Array:clamp
-- Clamp network activation outputs to the [-1, 1] tanh range to avoid
-- exploding gradient values during training.
local raw_act = lurek.compute.fromTable({ -2, 0.5, 1.8, -0.3 }, { 4 }, "f32")
local clamped = raw_act:clamp(-1.0, 1.0)
print("clamped:", clamped:get(1), clamped:get(3))  -- -1, 1

-- ---- Stub: Array:threshold -----------------------------------------------
--@api-stub: Array:threshold
-- Binarise the influence map at 0.5 to produce a reachability mask
-- where cells the AI considers accessible are marked 1.
local influences = lurek.compute.fromTable({ 0.1, 0.6, 0.4, 0.9 }, { 4 }, "f32")
local mask = influences:threshold(0.5)
print("mask:", mask:get(1), mask:get(2))  -- 0, 1

-- ---- Stub: Array:countNonZero --------------------------------------------
--@api-stub: Array:countNonZero
-- Demonstrates the proper usage of Array:countNonZero.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_countNonZero()
    print("reachable cells:", mask:countNonZero())  -- 2
end
local _ok, _err = pcall(demo_Array_countNonZero)

-- ---- Stub: Array:argmin --------------------------------------------------
--@api-stub: Array:argmin
-- Demonstrates the proper usage of Array:argmin.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_argmin()
    local costs_1d = lurek.compute.fromTable({ 5, 2, 8, 1, 6 }, { 5 }, "f32")
    print("lowest cost index:", costs_1d:argmin())  -- 4
end
local _ok, _err = pcall(demo_Array_argmin)

-- ---- Stub: Array:argmax --------------------------------------------------
--@api-stub: Array:argmax
-- Demonstrates the proper usage of Array:argmax.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_argmax()
    print("highest influence index:", influences:argmax())  -- 4
end
local _ok, _err = pcall(demo_Array_argmax)

-- ---- Stub: Array:any -----------------------------------------------------
--@api-stub: Array:any
-- Demonstrates the proper usage of Array:any.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_any()
    print("any reachable:", mask:any())  -- true
end
local _ok, _err = pcall(demo_Array_any)

-- ---- Stub: Array:all -----------------------------------------------------
--@api-stub: Array:all
-- Demonstrates the proper usage of Array:all.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_all()
    local pos = lurek.compute.fromTable({ 0.1, 0.5, 0.9 }, { 3 }, "f32")
    print("all positive:", pos:all())  -- true
end
local _ok, _err = pcall(demo_Array_all)

-- ---- Stub: Array:sum -----------------------------------------------------
--@api-stub: Array:sum
-- Demonstrates the proper usage of Array:sum.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_sum()
    print("total influence:", influences:sum())
end
local _ok, _err = pcall(demo_Array_sum)

-- ---- Stub: Array:mean ----------------------------------------------------
--@api-stub: Array:mean
-- Demonstrates the proper usage of Array:mean.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_mean()
    print("mean cost:", costs_1d:mean())
end
local _ok, _err = pcall(demo_Array_mean)

-- ---- Stub: Array:min -----------------------------------------------------
--@api-stub: Array:min
-- Demonstrates the proper usage of Array:min.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_min()
    print("min cost:", costs_1d:min())  -- 1
end
local _ok, _err = pcall(demo_Array_min)

-- ---- Stub: Array:max -----------------------------------------------------
--@api-stub: Array:max
-- Demonstrates the proper usage of Array:max.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_max()
    print("max influence:", influences:max())  -- 0.9
end
local _ok, _err = pcall(demo_Array_max)

-- ---- Stub: Array:matmul --------------------------------------------------
--@api-stub: Array:matmul
-- Multiply the position vector by the affine transform matrix to
-- project a world-space sprite onto screen-space coordinates.
local pos_vec = lurek.compute.fromTable({ 100, 200, 1 }, { 3, 1 }, "f32")
local id3 = lurek.compute.fromTable({ 1,0,0, 0,1,0, 0,0,1 }, { 3,3 }, "f32")
local projected = id3:matmul(pos_vec)
print("projected y:", projected:get(2, 1))  -- 200

-- ---- Stub: Array:dot -----------------------------------------------------
--@api-stub: Array:dot
-- Compute the dot product of the AI direction vector and the target
-- bearing to determine whether the enemy is facing the player.
local facing = lurek.compute.fromTable({ 1, 0 }, { 2 }, "f32")
local to_player = lurek.compute.fromTable({ 0.6, 0.8 }, { 2 }, "f32")
print("alignment:", facing:dot(to_player))  -- 0.6

-- ---- Stub: Array:bitwiseAnd ----------------------------------------------
--@api-stub: Array:bitwiseAnd
-- AND two Int32 tile flag arrays to find cells that have both the
-- "walkable" and "visible" flags set simultaneously.
local flags_a = lurek.compute.fromTable({ 3, 5, 7, 2 }, { 4 }, "i32")
local flags_b = lurek.compute.fromTable({ 1, 4, 6, 2 }, { 4 }, "i32")
local and_r = flags_a:bitwiseAnd(flags_b)
print("AND result:", and_r:get(1))  -- 1

-- ---- Stub: Array:bitwiseOr -----------------------------------------------
--@api-stub: Array:bitwiseOr
-- Demonstrates the proper usage of Array:bitwiseOr.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_bitwiseOr()
    local or_r = flags_a:bitwiseOr(flags_b)
    print("OR result:", or_r:get(2))  -- 5
end
local _ok, _err = pcall(demo_Array_bitwiseOr)

-- ---- Stub: Array:bitwiseXor ----------------------------------------------
--@api-stub: Array:bitwiseXor
-- XOR the current and previous frame's visible-tile bitfields to
-- find which cells changed visibility this frame.
local prev = lurek.compute.fromTable({ 0,1,1,0 }, { 4 }, "i32")
local curr = lurek.compute.fromTable({ 1,1,0,0 }, { 4 }, "i32")
local changed = prev:bitwiseXor(curr)
print("changed tiles:", changed:countNonZero())  -- 2

-- ---- Stub: Array:bitwiseNot ----------------------------------------------
--@api-stub: Array:bitwiseNot
-- NOT the visibility mask to get the fog-of-war mask representing
-- all tiles that should be hidden from the player.
local vis = lurek.compute.fromTable({ 1, 0, 1, 1 }, { 4 }, "i32")
local fog = vis:bitwiseNot()
print("fog mask sample:", fog:get(2))  -- -1 (bitwise NOT of 0)

-- ---- Stub: Array:bitwiseLShift -------------------------------------------
--@api-stub: Array:bitwiseLShift
-- Left-shift tile IDs by 4 bits to pack them into the upper nibble
-- of a combined tile+flags packed integer.
local tile_ids = lurek.compute.fromTable({ 1, 2, 3, 4 }, { 4 }, "i32")
local shifted = tile_ids:bitwiseLShift(4)
print("tile id 1 shifted:", shifted:get(1))  -- 16

-- ---- Stub: Array:bitwiseRShift -------------------------------------------
--@api-stub: Array:bitwiseRShift
-- Extract tile IDs from the upper nibble of a packed integer by
-- right-shifting 4 bits to isolate the tile type.
local packed_tiles = lurek.compute.fromTable({ 16, 32, 48, 64 }, { 4 }, "i32")
local tile_ids_r = packed_tiles:bitwiseRShift(4)
print("tile id:", tile_ids_r:get(1))  -- 1

-- ---- Stub: Array:add -----------------------------------------------------
--@api-stub: Array:add
-- Add a threat delta array to the influence map to accumulate threat
-- contributions from multiple AI units each frame.
local base_inf = lurek.compute.fromTable({ 1,2,3,4 }, { 4 }, "f32")
local delta    = lurek.compute.fromTable({ 0.5, 0.5, 0.5, 0.5 }, { 4 }, "f32")
local updated = base_inf:add(delta)
print("updated influence:", updated:get(1))  -- 1.5

-- ---- Stub: Array:sub -----------------------------------------------------
--@api-stub: Array:sub
-- Demonstrates the proper usage of Array:sub.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_sub()
    local diff = updated:sub(base_inf)
    print("delta:", diff:get(1))  -- 0.5
end
local _ok, _err = pcall(demo_Array_sub)

-- ---- Stub: Array:mul -----------------------------------------------------
--@api-stub: Array:mul
-- Scale the cost map by a difficulty multiplier so hard mode triples
-- the movement cost on rough terrain tiles.
local costs = lurek.compute.fromTable({ 1, 2, 3 }, { 3 }, "f32")
local scaled = costs:mul(lurek.compute.fromTable({ 3, 3, 3 }, { 3 }, "f32"))
print("scaled costs:", scaled:get(1))  -- 3

-- ---- Stub: Array:div -----------------------------------------------------
--@api-stub: Array:div
-- Normalise the probability distribution by dividing by the sum so
-- all action probabilities sum to 1.0.
local logits = lurek.compute.fromTable({ 2, 4, 6 }, { 3 }, "f32")
local total = logits:sum()
local prob = logits:div(lurek.compute.fromTable({ total, total, total }, { 3 }, "f32"))
print("prob sum:", prob:sum())  -- ~1.0

-- ---- Stub: Array:eq ------------------------------------------------------
--@api-stub: Array:eq
-- Compare the predicted action with the best action to compute the
-- accuracy metric during neural network evaluation.
local pred = lurek.compute.fromTable({ 1, 0, 1, 0 }, { 4 }, "f32")
local best = lurek.compute.fromTable({ 1, 1, 1, 0 }, { 4 }, "f32")
local correct = pred:eq(best)
print("correct predictions:", correct:sum())  -- 3

-- ---- Stub: Array:ne ------------------------------------------------------
--@api-stub: Array:ne
-- Find cells where the current policy differs from the previous policy
-- to identify which tiles changed preference this planning cycle.
local prev_pol = lurek.compute.fromTable({ 1, 2, 3 }, { 3 }, "i32")
local curr_pol = lurek.compute.fromTable({ 1, 3, 3 }, { 3 }, "i32")
local changed_pol = prev_pol:ne(curr_pol)
print("policy changes:", changed_pol:sum())  -- 1

-- ---- Stub: Array:lt ------------------------------------------------------
--@api-stub: Array:lt
-- Find all tiles where the path cost is below the budget threshold so
-- the agent avoids expensive routes without a Lua loop.
local path_costs = lurek.compute.fromTable({ 5, 2, 8, 1 }, { 4 }, "f32")
local budget = lurek.compute.fromTable({ 6, 6, 6, 6 }, { 4 }, "f32")
local within_budget = path_costs:lt(budget)
print("affordable tiles:", within_budget:sum())  -- 3

-- ---- Stub: Array:le ------------------------------------------------------
--@api-stub: Array:le
-- Find all cells with cost <= the current best path length to prune
-- the search frontier without a conditional loop.
local best_cost = lurek.compute.fromTable({ 5, 5, 5, 5 }, { 4 }, "f32")
local within = path_costs:le(best_cost)
print("within best cost:", within:sum())  -- 3

-- ---- Stub: Array:gt ------------------------------------------------------
--@api-stub: Array:gt
-- Identify threat cells that exceed the aggro threshold to target only
-- the most dangerous enemies each AI turn.
local threat = lurek.compute.fromTable({ 0.3, 0.8, 0.5, 0.9 }, { 4 }, "f32")
local thresh = lurek.compute.fromTable({ 0.7, 0.7, 0.7, 0.7 }, { 4 }, "f32")
local dangerous = threat:gt(thresh)
print("dangerous cells:", dangerous:sum())  -- 2

-- ---- Stub: Array:ge ------------------------------------------------------
--@api-stub: Array:ge
-- Find all tiles where the influence is at or above the aggro minimum
-- including the exact boundary value.
local min_aggro = lurek.compute.fromTable({ 0.5, 0.5, 0.5, 0.5 }, { 4 }, "f32")
local aggro_mask = threat:ge(min_aggro)
print("aggro tiles:", aggro_mask:sum())  -- 3

-- ---- Stub: Array:conv2d --------------------------------------------------
--@api-stub: Array:conv2d
-- Convolve the 8x8 fog-of-war grid with a Gaussian kernel to compute
-- a smooth visibility gradient around revealed cells.
local fog_grid = lurek.compute.zeros({ 8, 8 }, "f32")
fog_grid:set(4, 4, 1.0)  -- player position
local small_kern = lurek.compute.gaussianKernel(3, 1.0)
local blurred = fog_grid:conv2d(small_kern)
print("center after blur:", blurred:get(4, 4))

-- ---- Stub: Array:correlate2d ---------------------------------------------
--@api-stub: Array:correlate2d
-- Cross-correlate the threat map with a patrol-range kernel to find
-- cells that are heavily covered by patrol routes.
local threat_map = lurek.compute.fromTable(
    { 0,0,1,0, 0,1,1,0, 0,0,1,0, 0,0,0,0 }, { 4, 4 }, "f32")
local r_kern = lurek.compute.ones({ 3, 3 }, "f32")
local covered = threat_map:correlate2d(r_kern)
print("coverage at (2,3):", covered:get(2, 3))

-- ---- Stub: Array:softmax -------------------------------------------------
--@api-stub: Array:softmax
-- Convert raw Q-values to action probabilities using softmax so the
-- policy distribution sums to 1.0 for random sampling.
local q_vals = lurek.compute.fromTable({ 1.0, 2.0, 0.5 }, { 3 }, "f32")
local policy = q_vals:softmax()
print(string.format("policy sum: %.4f", policy:sum()))  -- ~1.0

-- ---- Stub: Array:logSoftmax ----------------------------------------------
--@api-stub: Array:logSoftmax
-- Demonstrates the proper usage of Array:logSoftmax.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_logSoftmax()
    local log_pol = q_vals:logSoftmax()
    print("log-policy[1]:", log_pol:get(1))
end
local _ok, _err = pcall(demo_Array_logSoftmax)

-- ---- Stub: Array:sigmoid -------------------------------------------------
--@api-stub: Array:sigmoid
-- Apply sigmoid to a one-vs-rest binary classifier output to get
-- independent per-action probabilities for a multi-label policy.
local raw_bin = lurek.compute.fromTable({ -2, 0, 2 }, { 3 }, "f32")
local sig_out = raw_bin:sigmoid()
print("sigmoid(0):", sig_out:get(2))  -- ~0.5

-- ---- Stub: Array:relu ----------------------------------------------------
--@api-stub: Array:relu
-- Apply ReLU to the hidden layer activations so negative pre-activations
-- are clamped to zero during the forward pass.
local pre_act = lurek.compute.fromTable({ -1, 0.5, 2, -0.3 }, { 4 }, "f32")
local activated = pre_act:relu()
print("relu(-1):", activated:get(1))  -- 0
print("relu(0.5):", activated:get(2))  -- 0.5

-- ---- Stub: Array:leakyRelu -----------------------------------------------
--@api-stub: Array:leakyRelu
-- Demonstrates the proper usage of Array:leakyRelu.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_leakyRelu()
    local leaky = pre_act:leakyRelu(0.01)
    print("leakyRelu(-1):", leaky:get(1))  -- -0.01
end
local _ok, _err = pcall(demo_Array_leakyRelu)

-- ---- Stub: Array:normalize -----------------------------------------------
--@api-stub: Array:normalize
-- L2-normalise the influence gradient to get a unit direction vector
-- for enemy steering toward the player.
local gradient = lurek.compute.fromTable({ 3, 4 }, { 2 }, "f32")
local unit = gradient:normalize()
print(string.format("unit length: %.4f", unit:dot(unit)))  -- ~1.0

-- ---- Stub: Array:standardize ---------------------------------------------
--@api-stub: Array:standardize
-- Z-score standardise the cost features before feeding them into the
-- neural network so no single feature dominates the input.
local feats = lurek.compute.fromTable({ 1, 3, 5, 7, 9 }, { 5 }, "f32")
local std_feats = feats:standardize()
print("standardized mean:", math.abs(std_feats:mean()) < 0.001)  -- true

-- ---- Stub: Array:cast ----------------------------------------------------
--@api-stub: Array:cast
-- Cast the f32 influence map to i32 after thresholding to produce
-- an integer flag layer compatible with the bitwise mask operations.
local f_mask = lurek.compute.fromTable({ 0.0, 1.0, 1.0, 0.0 }, { 4 }, "f32")
local i_mask = f_mask:cast("i32")
print("cast dtype:", i_mask:getDataType())  -- "i32"

-- ---- Stub: Array:type ----------------------------------------------------
--@api-stub: Array:type
-- Demonstrates the proper usage of Array:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_type()
    print(arr:type())  -- "Array"
end
local _ok, _err = pcall(demo_Array_type)

-- ---- Stub: Array:typeOf --------------------------------------------------
--@api-stub: Array:typeOf
-- Demonstrates the proper usage of Array:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Array_typeOf()
    print(arr:typeOf("Array"))  -- true
end
local _ok, _err = pcall(demo_Array_typeOf)

-- =============================================================================
-- Advanced Compute Functions
-- =============================================================================

-- ---- Stub: lurek.compute.convolve1d --------------------------------------
--@api-stub: lurek.compute.convolve1d
-- Demonstrates the proper usage of lurek.compute.convolve1d.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_convolve1d()
    local signal = lurek.compute.array({1, 3, 5, 3, 1, 3, 5, 3, 1})
    local kernel = lurek.compute.array({0.25, 0.5, 0.25})
    local smoothed = signal:convolve1d(kernel)
    print("convolve1d result: " .. tostring(smoothed))
end
local _ok, _err = pcall(demo_lurek_compute_convolve1d)

-- ---- Stub: lurek.compute.convolve2D --------------------------------------
--@api-stub: lurek.compute.convolve2D
-- Demonstrates the proper usage of lurek.compute.convolve2D.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_convolve2D()
    local img_patch = lurek.compute.array({
    {1, 2, 3, 4},
    {5, 6, 7, 8},
    {9, 10, 11, 12},
    {13, 14, 15, 16}
    })
    local blur_k = lurek.compute.array({{1,1,1},{1,1,1},{1,1,1}})
    local blurred = img_patch:convolve2D(blur_k)
    print("convolve2D: " .. tostring(blurred))
end
local _ok, _err = pcall(demo_lurek_compute_convolve2D)

-- ---- Stub: lurek.compute.correlate1d ------------------------------------
--@api-stub: lurek.compute.correlate1d
-- Demonstrates the proper usage of lurek.compute.correlate1d.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_correlate1d()
    local corr = signal:correlate1d(kernel)
    print("correlate1d: " .. tostring(corr))
end
local _ok, _err = pcall(demo_lurek_compute_correlate1d)

-- ---- Stub: lurek.compute.covariance --------------------------------------
--@api-stub: lurek.compute.covariance
-- Demonstrates the proper usage of lurek.compute.covariance.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_covariance()
    local scores = lurek.compute.array({10, 20, 30, 40, 50})
    local times = lurek.compute.array({1, 2, 3, 4, 5})
    local cov = scores:covariance(times)
    print("covariance: " .. tostring(cov))
end
local _ok, _err = pcall(demo_lurek_compute_covariance)

-- ---- Stub: lurek.compute.cross2d -----------------------------------------
--@api-stub: lurek.compute.cross2d
-- Demonstrates the proper usage of lurek.compute.cross2d.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_cross2d()
    local cross = img_patch:cross2d(blur_k)
    print("cross2d: " .. tostring(cross))
end
local _ok, _err = pcall(demo_lurek_compute_cross2d)

-- ---- Stub: lurek.compute.cumsum ------------------------------------------
--@api-stub: lurek.compute.cumsum
-- Demonstrates the proper usage of lurek.compute.cumsum.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_cumsum()
    local vals = lurek.compute.array({10, 20, 30, 40})
    local cs = vals:cumsum()
    print("cumsum: " .. tostring(cs))
end
local _ok, _err = pcall(demo_lurek_compute_cumsum)

-- ---- Stub: lurek.compute.diff --------------------------------------------
--@api-stub: lurek.compute.diff
-- Demonstrates the proper usage of lurek.compute.diff.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_diff()
    local positions = lurek.compute.array({0, 5, 15, 30, 50})
    local velocities = positions:diff()
    print("diff (velocities): " .. tostring(velocities))
end
local _ok, _err = pcall(demo_lurek_compute_diff)

-- ---- Stub: lurek.compute.dilate ------------------------------------------
--@api-stub: lurek.compute.dilate
-- Demonstrates the proper usage of lurek.compute.dilate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_dilate()
    local mask = lurek.compute.array({{0,0,0},{0,1,0},{0,0,0}})
    local dilated = mask:dilate(1)
    print("dilate: " .. tostring(dilated))
end
local _ok, _err = pcall(demo_lurek_compute_dilate)

-- ---- Stub: lurek.compute.erode -------------------------------------------
--@api-stub: lurek.compute.erode
-- Demonstrates the proper usage of lurek.compute.erode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_erode()
    local eroded = dilated:erode(1)
    print("erode: " .. tostring(eroded))
end
local _ok, _err = pcall(demo_lurek_compute_erode)

-- ---- Stub: lurek.compute.linsolve ----------------------------------------
--@api-stub: lurek.compute.linsolve
-- Demonstrates the proper usage of lurek.compute.linsolve.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_linsolve()
    local A = lurek.compute.array({{2, 1}, {1, 3}})
    local b = lurek.compute.array({5, 7})
    local x = A:linsolve(b)
    print("linsolve: " .. tostring(x))
end
local _ok, _err = pcall(demo_lurek_compute_linsolve)

-- ---- Stub: lurek.compute.luDecompose -------------------------------------
--@api-stub: lurek.compute.luDecompose
-- Demonstrates the proper usage of lurek.compute.luDecompose.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_luDecompose()
    local L, U = A:luDecompose()
    print("LU decompose: L=" .. tostring(L) .. " U=" .. tostring(U))
end
local _ok, _err = pcall(demo_lurek_compute_luDecompose)

-- ---- Stub: lurek.compute.normalizeRange ----------------------------------
--@api-stub: lurek.compute.normalizeRange
-- Demonstrates the proper usage of lurek.compute.normalizeRange.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_normalizeRange()
    local heights = lurek.compute.array({10, 50, 30, 80, 20})
    local normed = heights:normalizeRange()
    print("normalizeRange: " .. tostring(normed))
end
local _ok, _err = pcall(demo_lurek_compute_normalizeRange)

-- ---- Stub: lurek.compute.normalizeVec ------------------------------------
--@api-stub: lurek.compute.normalizeVec
-- Demonstrates the proper usage of lurek.compute.normalizeVec.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_normalizeVec()
    local dir_vec = lurek.compute.array({3, 4})
    local unit = dir_vec:normalizeVec()
    print("normalizeVec: " .. tostring(unit))
end
local _ok, _err = pcall(demo_lurek_compute_normalizeVec)

-- ---- Stub: lurek.compute.outer -------------------------------------------
--@api-stub: lurek.compute.outer
-- Demonstrates the proper usage of lurek.compute.outer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_outer()
    local a_vec = lurek.compute.array({1, 2, 3})
    local b_vec = lurek.compute.array({4, 5})
    local op = a_vec:outer(b_vec)
    print("outer product: " .. tostring(op))
end
local _ok, _err = pcall(demo_lurek_compute_outer)

-- ---- Stub: lurek.compute.pearsonCorr ------------------------------------
--@api-stub: lurek.compute.pearsonCorr
-- Demonstrates the proper usage of lurek.compute.pearsonCorr.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_pearsonCorr()
    local pc = scores:pearsonCorr(times)
    print("pearson correlation: " .. tostring(pc))
end
local _ok, _err = pcall(demo_lurek_compute_pearsonCorr)

-- ---- Stub: lurek.compute.percentile -------------------------------------
--@api-stub: lurek.compute.percentile
-- Demonstrates the proper usage of lurek.compute.percentile.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_percentile()
    local p90 = scores:percentile(90)
    print("90th percentile: " .. tostring(p90))
end
local _ok, _err = pcall(demo_lurek_compute_percentile)

-- ---- Stub: lurek.compute.sobel -------------------------------------------
--@api-stub: lurek.compute.sobel
-- Demonstrates the proper usage of lurek.compute.sobel.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_sobel()
    local edges = img_patch:sobel()
    print("sobel edges: " .. tostring(edges))
end
local _ok, _err = pcall(demo_lurek_compute_sobel)

-- ---- Stub: lurek.compute.transformPoints ---------------------------------
--@api-stub: lurek.compute.transformPoints
-- Demonstrates the proper usage of lurek.compute.transformPoints.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_transformPoints()
    local pts = lurek.compute.array({{1, 0}, {0, 1}, {-1, 0}})
    local rot = lurek.compute.array({{0, -1}, {1, 0}})
    local rotated = pts:transformPoints(rot)
    print("transformed points: " .. tostring(rotated))
end
local _ok, _err = pcall(demo_lurek_compute_transformPoints)

-- ---- Stub: lurek.compute.zscore ------------------------------------------
--@api-stub: lurek.compute.zscore
-- Demonstrates the proper usage of lurek.compute.zscore.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_compute_zscore()
    local stats = lurek.compute.array({100, 200, 150, 300, 250})
    local zs = stats:zscore()
    print("z-scores: " .. tostring(zs))
end
local _ok, _err = pcall(demo_lurek_compute_zscore)
