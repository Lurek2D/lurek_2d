-- content/examples/compute.lua
-- love2d-style usage snippets for the lurek.compute API (67 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/compute.lua

-- ── lurek.compute.* functions ──

--@api-stub: lurek.compute.newArray
-- Creates a zero-initialized array with the given shape and optional dtype.
-- Build once at startup; reuse across frames.
local array = lurek.compute.newArray(shape, dtype)
print("created", array)
return array

--@api-stub: lurek.compute.zeros
-- Creates a zero-filled array with the given shape and optional dtype.
-- See the module spec for detailed semantics.
local result = lurek.compute.zeros(shape, dtype)
print("zeros:", result)
return result

--@api-stub: lurek.compute.ones
-- Creates a one-filled array with the given shape and optional dtype.
-- See the module spec for detailed semantics.
local result = lurek.compute.ones(shape, dtype)
print("ones:", result)
return result

--@api-stub: lurek.compute.range
-- Creates a 1D array from start to stop with optional step and dtype.
-- See the module spec for detailed semantics.
local result = lurek.compute.range(start, stop, step, dtype)
print("range:", result)
return result

--@api-stub: lurek.compute.fromTable
-- Creates an array from a Lua table of numbers with optional shape and dtype.
-- Build once at startup; reuse across frames.
local fromtable = lurek.compute.fromTable({ x = 0, y = 0 }, shape, dtype)
print("created", fromtable)
return fromtable

--@api-stub: lurek.compute.gaussianKernel
-- Creates a sizeĂ—size Gaussian kernel array.
-- See the module spec for detailed semantics.
local result = lurek.compute.gaussianKernel(10, sigma)
print("gaussianKernel:", result)
return result

--@api-stub: lurek.compute.rotate2dMatrix
-- Creates a 2Ă—2 rotation matrix for the given angle in radians.
-- See the module spec for detailed semantics.
local result = lurek.compute.rotate2dMatrix(angle_rad)
print("rotate2dMatrix:", result)
return result

--@api-stub: lurek.compute.affine2d
-- Creates a 3Ă—3 homogeneous affine matrix.
-- See the module spec for detailed semantics.
local result = lurek.compute.affine2d(tx, ty, angle_rad, sx, sy)
print("affine2d:", result)
return result

--@api-stub: lurek.compute.fft
-- Computes the discrete Fourier transform of a 1D real-valued sample array.
-- See the module spec for detailed semantics.
local result = lurek.compute.fft(samples)
print("fft:", result)
return result

--@api-stub: lurek.compute.ifft
-- Computes the inverse discrete Fourier transform.
-- See the module spec for detailed semantics.
local result = lurek.compute.ifft(freqs)
print("ifft:", result)
return result

--@api-stub: lurek.compute.fftMagnitude
-- Returns the magnitude spectrum `|X[k]|` of a real-valued sample array.
-- See the module spec for detailed semantics.
local result = lurek.compute.fftMagnitude(samples)
print("fftMagnitude:", result)
return result

-- ── Array methods ──

--@api-stub: Array:getShape
-- Returns the shape as a table of dimension sizes.
-- Cheap to call; safe inside callbacks.
local array = lurek.compute.newArray()  -- or your existing handle
local value = array:getShape()
print("Array:getShape ->", value)

--@api-stub: Array:getDimensions
-- Returns the number of dimensions.
-- Cheap to call; safe inside callbacks.
local array = lurek.compute.newArray()  -- or your existing handle
local value = array:getDimensions()
print("Array:getDimensions ->", value)

--@api-stub: Array:getSize
-- Returns the total number of elements.
-- Cheap to call; safe inside callbacks.
local array = lurek.compute.newArray()  -- or your existing handle
local value = array:getSize()
print("Array:getSize ->", value)

--@api-stub: Array:getDataType
-- Returns the element data type name.
-- Cheap to call; safe inside callbacks.
local array = lurek.compute.newArray()  -- or your existing handle
local value = array:getDataType()
print("Array:getDataType ->", value)

--@api-stub: Array:isOnGPU
-- Returns false (CPU arrays only).
-- Use as a guard inside lurek.update or event handlers.
local array = lurek.compute.newArray()
if array:isOnGPU() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: Array:get
-- Returns the element at the given 1-based indices.
-- Cheap to call; safe inside callbacks.
local array = lurek.compute.newArray()  -- or your existing handle
local value = array:get({ x = 0, y = 0 })
print("Array:get ->", value)

--@api-stub: Array:set
-- Sets the element at the given 1-based indices to a value.
-- Apply at startup or in response to user input.
local array = lurek.compute.newArray()
array:set({ x = 0, y = 0 })
print("Array:set applied")

--@api-stub: Array:toTable
-- Returns all elements as a flat table of numbers.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:toTable()
print("Array:toTable done")

--@api-stub: Array:reshape
-- Returns a new array with the given shape and the same data.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:reshape(shape)
print("Array:reshape done")

--@api-stub: Array:clone
-- Returns a deep copy of this array.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:clone()
print("Array:clone done")

--@api-stub: Array:transpose
-- Returns the transposed 2D array.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:transpose()
print("Array:transpose done")

--@api-stub: Array:fill
-- Fills all elements with the given value in-place.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:fill(val)
print("Array:fill done")

--@api-stub: Array:pow
-- Raises each element to a scalar exponent.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:pow(exp)
print("Array:pow done")

--@api-stub: Array:sqrt
-- Element-wise square root.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:sqrt()
print("Array:sqrt done")

--@api-stub: Array:abs
-- Element-wise absolute value.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:abs()
print("Array:abs done")

--@api-stub: Array:neg
-- Returns a new Array with every element negated (multiplied by â’1).
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:neg()
print("Array:neg done")

--@api-stub: Array:clamp
-- Clamps each element to the given range.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:clamp(0, 100)
print("Array:clamp done")

--@api-stub: Array:threshold
-- Returns a mask array with 1.0 where elements >= val, else 0.0.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:threshold(val)
print("Array:threshold done")

--@api-stub: Array:countNonZero
-- Returns the count of nonzero elements.
-- Cheap to call; safe inside callbacks.
local array = lurek.compute.newArray()  -- or your existing handle
local value = array:countNonZero()
print("Array:countNonZero ->", value)

--@api-stub: Array:argmin
-- Returns the 1-based flat index of the minimum element.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:argmin()
print("Array:argmin done")

--@api-stub: Array:argmax
-- Returns the 1-based flat index of the maximum element.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:argmax()
print("Array:argmax done")

--@api-stub: Array:any
-- Returns true if any element is nonzero.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:any()
print("Array:any done")

--@api-stub: Array:all
-- Returns true if all elements are nonzero.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:all()
print("Array:all done")

--@api-stub: Array:sum
-- Sum of all elements, or along an axis (1-based).
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:sum(axis)
print("Array:sum done")

--@api-stub: Array:mean
-- Mean of all elements, or along an axis (1-based).
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:mean(axis)
print("Array:mean done")

--@api-stub: Array:min
-- Minimum of all elements, or along an axis (1-based).
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:min(axis)
print("Array:min done")

--@api-stub: Array:max
-- Maximum of all elements, or along an axis (1-based).
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:max(axis)
print("Array:max done")

--@api-stub: Array:matmul
-- Matrix multiplication of two 2D arrays.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:matmul(other)
print("Array:matmul done")

--@api-stub: Array:dot
-- Dot product of two 1D arrays.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:dot(other)
print("Array:dot done")

--@api-stub: Array:bitwiseAnd
-- Bitwise AND of two Int32 arrays.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:bitwiseAnd(other)
print("Array:bitwiseAnd done")

--@api-stub: Array:bitwiseOr
-- Bitwise OR of two Int32 arrays.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:bitwiseOr(other)
print("Array:bitwiseOr done")

--@api-stub: Array:bitwiseXor
-- Bitwise XOR of two Int32 arrays.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:bitwiseXor(other)
print("Array:bitwiseXor done")

--@api-stub: Array:bitwiseNot
-- Bitwise NOT of an Int32 array.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:bitwiseNot()
print("Array:bitwiseNot done")

--@api-stub: Array:bitwiseLShift
-- Bitwise left shift of an Int32 array.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:bitwiseLShift(amount)
print("Array:bitwiseLShift done")

--@api-stub: Array:bitwiseRShift
-- Bitwise right shift of an Int32 array.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:bitwiseRShift(amount)
print("Array:bitwiseRShift done")

--@api-stub: Array:convolve2D
-- 2D convolution with zero-padding.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:convolve2D(kernel)
print("Array:convolve2D done")

--@api-stub: Array:dilate
-- Morphological dilation with a diamond structuring element.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:dilate(radius)
print("Array:dilate done")

--@api-stub: Array:erode
-- Morphological erosion with a diamond structuring element.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:erode(radius)
print("Array:erode done")

--@api-stub: Array:cumsum
-- Cumulative sum of all elements (flattened).
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:cumsum()
print("Array:cumsum done")

--@api-stub: Array:diff
-- Discrete difference applied `order` times.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:diff(order)
print("Array:diff done")

--@api-stub: Array:percentile
-- Compute the p-th percentile (0â€“100).
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:percentile(p)
print("Array:percentile done")

--@api-stub: Array:covariance
-- Population covariance with another 1D array.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:covariance(other)
print("Array:covariance done")

--@api-stub: Array:pearsonCorr
-- Pearson correlation coefficient with another 1D array.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:pearsonCorr(other)
print("Array:pearsonCorr done")

--@api-stub: Array:normalizeRange
-- Linearly rescale values to [out_min, out_max].
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:normalizeRange(lo, hi)
print("Array:normalizeRange done")

--@api-stub: Array:zscore
-- Standardise values to zero mean and unit variance.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:zscore()
print("Array:zscore done")

--@api-stub: Array:convolve1d
-- 1D convolution with a kernel array (full output).
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:convolve1d(kernel)
print("Array:convolve1d done")

--@api-stub: Array:correlate1d
-- 1D cross-correlation with a template array (valid output).
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:correlate1d(template)
print("Array:correlate1d done")

--@api-stub: Array:normalizeVec
-- L2-normalise a 1D vector.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:normalizeVec()
print("Array:normalizeVec done")

--@api-stub: Array:outer
-- Outer product of two 1D vectors â†’ 2D array [m, n].
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:outer(other)
print("Array:outer done")

--@api-stub: Array:cross2d
-- Signed 2D cross product with another length-2 array.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:cross2d(other)
print("Array:cross2d done")

--@api-stub: Array:transformPoints
-- Apply this 2Ă—2 or 3Ă—3 matrix to an [N,2] points array.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:transformPoints(pts)
print("Array:transformPoints done")

--@api-stub: Array:sobel
-- Apply Sobel edge detection to a 2D array.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:sobel()
print("Array:sobel done")

--@api-stub: Array:linsolve
-- Solve AÂ·x = b where this array is A (square [n,n]) and b is a 1D vector.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:linsolve(0)
print("Array:linsolve done")

--@api-stub: Array:luDecompose
-- Decomposes this square matrix into L and U factors with partial pivoting.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:luDecompose()
print("Array:luDecompose done")

--@api-stub: Array:type
-- Returns the type name "Array".
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:type()
print("Array:type done")

--@api-stub: Array:typeOf
-- Returns true when the given name matches "Array" or a parent type.
-- See the module spec for detailed semantics.
local array = lurek.compute.newArray()
array:typeOf("main")
print("Array:typeOf done")

