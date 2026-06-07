# Compute

## Summary

The compute module serves as the primary high-performance numeric processing engine for Lurek2D. Its core purpose is to provide scripts with dense, multi-dimensional array structures, enabling heavy mathematical calculations directly within game loops. It centers around a robust NdArray model that stores typed scalar buffers with explicit shape strides, supporting initializations for zeros, ones, or custom ranges. It manages sub-regions and supports parallel multithreaded calculation thresholds for massive array blocks.

For scientific computing and complex transformations, the module exposes rich algebraic, geometric, and spectral operations. It provides linear-algebra tools including vector cross products, unit normalizations, Gaussian solvers with pivoting, LU matrix decompositions, and eigenpair estimators. It also includes radix-2 fast Fourier transforms and inverse transforms, allowing scripts to map real-valued waveforms into complex frequency spectra and back for audio or signal-processing tasks.

Spatial data processing and statistical analysis are supported through spatial grid and analytics layers. The spatial engine delivers zero-padded convolutions, Sobel gradient calculations, flood-fill propagation, and morphological dilation or erosion filters over coordinate grids. In parallel, the analytics layer computes cumulative sums, percentile distributions, histogram binning, range scaling, and Pearson correlations, supplying comprehensive telemetry capabilities.

## Functions

### `lurek.compute.affine2d`

Creates a 2D affine transform matrix.

```lua
lurek.compute.affine2d(tx, ty, angle_rad, sx, sy)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `tx` | number | Translation X component. |
| `ty` | number | Translation Y component. |
| `angle_rad` | number | Rotation angle in radians. |
| `sx` | number | Scale X component. |
| `sy` | number | Scale Y component. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New affine transform matrix array. |

**Example**

```lua
do
    local m = lurek.compute.affine2d(10, 20, 0, 1, 1)
    print("affine tx=10 ty=20, [1,3] = " .. m:get(1, 3))
end
```

---

### `lurek.compute.fft`

Computes the FFT of real-valued samples.

```lua
lurek.compute.fft(samples)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `samples` | table | Array table of real-valued samples. |

**Returns**

| Type | Description |
|------|-------------|
| LComputeFftResult | Array table of complex pairs with `re` and `im` fields. |

**Example**

```lua
do
    local freqs = lurek.compute.fft({1, 0, -1, 0})
    print("fft result count = " .. #freqs)
    print("first bin re = " .. tostring(freqs[1].re) .. " im = " .. tostring(freqs[1].im))
end
```

---

### `lurek.compute.fftMagnitude`

Computes FFT magnitudes for real-valued samples.

```lua
lurek.compute.fftMagnitude(samples)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `samples` | table | Array table of real-valued samples. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of magnitude values. |

**Example**

```lua
do
    local mags = lurek.compute.fftMagnitude({1, 0, -1, 0})
    print("magnitudes count = " .. #mags)
    print("magnitude[1] = " .. tostring(mags[1]))
end
```

---

### `lurek.compute.fromTable`

Creates an array from a flat Lua table and optional shape.

```lua
lurek.compute.fromTable(data, shape, dtype)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `data` | table | Array table of numeric values. |
| `shape?` | table | Optional array table of positive dimension sizes. |
| `dtype?` | string | Data type name; defaults to `float32`. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array handle containing table values. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({1, 2, 3, 4, 5, 6}, {2, 3})
    print("fromTable 2x3, val[2,1] = " .. a:get(2, 1))
end
```

---

### `lurek.compute.gaussianKernel`

Creates a square Gaussian kernel array.

```lua
lurek.compute.gaussianKernel(size, sigma)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `size` | number | Kernel width and height. |
| `sigma` | number | Gaussian sigma value. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New Gaussian kernel array. |

**Example**

```lua
do
    local k = lurek.compute.gaussianKernel(5, 1.0)
    print("gaussian 5x5, center = " .. k:get(3, 3))
    print("kernel size = " .. k:getSize())
end
```

---

### `lurek.compute.getParThreshold`

Returns the global compute parallelism threshold.

```lua
lurek.compute.getParThreshold()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current parallel threshold. |

**Example**

```lua
do
    local t = lurek.compute.getParThreshold()
    print("par threshold = " .. t)
end
```

---

### `lurek.compute.ifft`

Computes the inverse FFT of complex frequency pairs.

```lua
lurek.compute.ifft(freqs)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `freqs` | table | Array table of complex pairs with `re` and `im` fields. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of reconstructed real-valued samples. |

**Example**

```lua
do
    local freqs = lurek.compute.fft({1, 0, -1, 0})
    local samples = lurek.compute.ifft(freqs)
    print("ifft reconstructed, count = " .. #samples)
    print("sample[1] = " .. tostring(samples[1]))
end
```

---

### `lurek.compute.newArray`

Creates a zero-filled array with the requested shape and data type.

```lua
lurek.compute.newArray(shape, dtype)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shape` | table | Array table of positive dimension sizes. |
| `dtype?` | string | Data type name; defaults to `float32`. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New zero-filled array handle. |

**Example**

```lua
do
    local a = lurek.compute.newArray({4, 4}, "float32")
    print("new 4x4 array, size = " .. a:getSize())
    print("dimensions = " .. a:getDimensions())
end
```

---

### `lurek.compute.ones`

Creates a one-filled array with the requested shape and data type.

```lua
lurek.compute.ones(shape, dtype)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shape` | table | Array table of positive dimension sizes. |
| `dtype?` | string | Data type name; defaults to `float32`. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New one-filled array handle. |

**Example**

```lua
do
    local o = lurek.compute.ones({2, 5}, "float32")
    print("ones 2x5, val[1,3] = " .. o:get(1, 3))
end
```

---

### `lurek.compute.range`

Creates a one-dimensional range array.

```lua
lurek.compute.range(start, stop, step, dtype)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `start` | number | First value in the range. |
| `stop` | number | Stop value for the range. |
| `step?` | number | Step size; defaults to 1.0. |
| `dtype?` | string | Data type name; defaults to `float32`. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New range array handle. |

**Example**

```lua
do
    local r = lurek.compute.range(0, 10, 2, "float32")
    print("range 0..10 step 2, size = " .. r:getSize())
    print("last value = " .. r:get(5))
end
```

---

### `lurek.compute.rotate2dMatrix`

Creates a 2D rotation matrix from an angle in radians.

```lua
lurek.compute.rotate2dMatrix(angle_rad)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `angle_rad` | number | Rotation angle in radians. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New rotation matrix array. |

**Example**

```lua
do
    local m = lurek.compute.rotate2dMatrix(math.pi / 4)
    print("rotation 45 deg, [1,1] = " .. m:get(1, 1))
    print("rotation 45 deg, [1,2] = " .. m:get(1, 2))
end
```

---

### `lurek.compute.setParThreshold`

Sets the global compute parallelism threshold and returns the previous value.

```lua
lurek.compute.setParThreshold(threshold)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `threshold` | number | New threshold; values below one are clamped to one. |

**Returns**

| Type | Description |
|------|-------------|
| number | Previous parallel threshold. |

**Example**

```lua
do
    local prev = lurek.compute.setParThreshold(1024)
    print("prev threshold = " .. prev)
    print("current threshold = " .. lurek.compute.getParThreshold())
end
```

---

### `lurek.compute.zeros`

Creates a zero-filled array with the requested shape and data type.

```lua
lurek.compute.zeros(shape, dtype)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shape` | table | Array table of positive dimension sizes. |
| `dtype?` | string | Data type name; defaults to `float32`. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New zero-filled array handle. |

**Example**

```lua
do
    local z = lurek.compute.zeros({3, 3})
    print("zeros 3x3, val[1,1] = " .. z:get(1, 1))
end
```

---

## Module Fields

*No module-level fields documented.*

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## Types

- [LArray](#larray)

## LArray

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LArray:abs`

Returns element-wise absolute values.

```lua
LArray:abs()
```

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing absolute values. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({-3, -1, 2}, {3})
    local b = a:abs()
    print("abs → [1] = " .. b:get(1))
end
```

---

#### `LArray:add`

Returns element-wise addition with an array or scalar.

```lua
LArray:add(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | Array or scalar number for element-wise operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing the addition result. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({1, 2, 3}, {3})
    local b = a:add(10)
    print("a + 10 → [1] = " .. b:get(1))
end
```

---

#### `LArray:addInplace`

Adds another array into this array in place.

```lua
LArray:addInplace(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LArray](#larray) | Array with a compatible shape. |

**Example**

```lua
do
    local a = lurek.compute.ones({3, 3})
    local b = lurek.compute.ones({3, 3})
    a:addInplace(b)
    print("after addInplace[1,1] = " .. a:get(1, 1))
    print("after addInplace[3,3] = " .. a:get(3, 3))
end
```

---

#### `LArray:all`

Returns whether all elements are non-zero.

```lua
LArray:all()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when every element is non-zero. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({1, 2, 3}, {3})
    print("all nonzero = " .. tostring(a:all()))
end
```

---

#### `LArray:any`

Returns whether any element is non-zero.

```lua
LArray:any()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when at least one element is non-zero. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({0, 0, 1}, {3})
    print("any = " .. tostring(a:any()))
    print("all = " .. tostring(a:all()))
end
```

---

#### `LArray:argmax`

Returns the one-based flat index of the maximum value.

```lua
LArray:argmax()
```

**Returns**

| Type | Description |
|------|-------------|
| number | One-based index of the maximum element. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({5, 1, 8, 3}, {4})
    print("argmax = " .. a:argmax())
end
```

---

#### `LArray:argmin`

Returns the one-based flat index of the minimum value.

```lua
LArray:argmin()
```

**Returns**

| Type | Description |
|------|-------------|
| number | One-based index of the minimum element. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({5, 1, 8, 3}, {4})
    print("argmin = " .. a:argmin())
end
```

---

#### `LArray:bitwiseAnd`

Returns element-wise bitwise AND with another array.

```lua
LArray:bitwiseAnd(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LArray](#larray) | Array used as the right-hand operand. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing bitwise AND results. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({0xFF, 0x0F, 0xAA}, {3}, "int32")
    local b = lurek.compute.fromTable({0x0F, 0x0F, 0x55}, {3}, "int32")
    local c = a:bitwiseAnd(b)
    print("AND[1] = " .. c:get(1))
end
```

---

#### `LArray:bitwiseLShift`

Returns element-wise left shift by a bit count.

```lua
LArray:bitwiseLShift(amount)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `amount` | number | Bit count to shift left. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing shifted values. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({1, 2, 4}, {3}, "int32")
    local c = a:bitwiseLShift(2)
    print("lshift(2)[1] = " .. c:get(1))
end
```

---

#### `LArray:bitwiseNot`

Returns element-wise bitwise NOT.

```lua
LArray:bitwiseNot()
```

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing bitwise NOT results. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({0, 255}, {2}, "int32")
    local c = a:bitwiseNot()
    print("NOT[1] = " .. c:get(1))
end
```

---

#### `LArray:bitwiseOr`

Returns element-wise bitwise OR with another array.

```lua
LArray:bitwiseOr(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LArray](#larray) | Array used as the right-hand operand. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing bitwise OR results. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({0xF0, 0x0F}, {2}, "int32")
    local b = lurek.compute.fromTable({0x0F, 0xF0}, {2}, "int32")
    local c = a:bitwiseOr(b)
    print("OR[1] = " .. c:get(1))
end
```

---

#### `LArray:bitwiseRShift`

Returns element-wise right shift by a bit count.

```lua
LArray:bitwiseRShift(amount)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `amount` | number | Bit count to shift right. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing shifted values. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({8, 16, 32}, {3}, "int32")
    local c = a:bitwiseRShift(2)
    print("rshift(2)[1] = " .. c:get(1))
end
```

---

#### `LArray:bitwiseXor`

Returns element-wise bitwise XOR with another array.

```lua
LArray:bitwiseXor(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LArray](#larray) | Array used as the right-hand operand. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing bitwise XOR results. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({0xFF, 0x00}, {2}, "int32")
    local b = lurek.compute.fromTable({0x0F, 0x0F}, {2}, "int32")
    local c = a:bitwiseXor(b)
    print("XOR[1] = " .. c:get(1))
end
```

---

#### `LArray:clamp`

Returns values clamped between minimum and maximum bounds.

```lua
LArray:clamp(min, max)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `min` | number | Minimum allowed value. |
| `max` | number | Maximum allowed value. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing clamped values. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({-5, 0, 3, 10, 15}, {5})
    local b = a:clamp(0, 10)
    print("clamp(0,10) → [1]=" .. b:get(1) .. " [5]=" .. b:get(5))
end
```

---

#### `LArray:clone`

Returns an independent deep copy of this array.

```lua
LArray:clone()
```

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array with copied data and shape. |

**Example**

```lua
do
    local a = lurek.compute.ones({3, 3})
    local b = a:clone()
    b:set(1, 1, 5)
    print("original[1,1] = " .. a:get(1, 1) .. " clone[1,1] = " .. b:get(1, 1))
end
```

---

#### `LArray:convolve1d`

Returns one-dimensional convolution with a kernel array.

```lua
LArray:convolve1d(kernel)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `kernel` | [LArray](#larray) | Kernel array used for convolution. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing convolution result. |

**Example**

```lua
do
    local signal = lurek.compute.fromTable({0, 1, 2, 3, 4}, {5})
    local kernel = lurek.compute.fromTable({1, 0, -1}, {3})
    local c = signal:convolve1d(kernel)
    print("conv1d size = " .. c:getSize())
end
```

---

#### `LArray:convolve2D`

Returns two-dimensional convolution with a kernel array.

```lua
LArray:convolve2D(kernel)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `kernel` | [LArray](#larray) | Kernel array used for convolution. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing convolution result. |

**Example**

```lua
do
    local img = lurek.compute.zeros({5, 5})
    img:set(3, 3, 1)
    local kernel = lurek.compute.gaussianKernel(3, 1.0)
    local result = img:convolve2D(kernel)
    print("conv center = " .. result:get(3, 3))
    print("conv neighbor = " .. result:get(3, 2))
end
```

---

#### `LArray:correlate1d`

Returns one-dimensional correlation with a template array.

```lua
LArray:correlate1d(template)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `template` | [LArray](#larray) | Template array used for correlation. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing correlation result. |

**Example**

```lua
do
    local signal = lurek.compute.fromTable({0, 0, 1, 0, 0}, {5})
    local templ = lurek.compute.fromTable({1}, {1})
    local c = signal:correlate1d(templ)
    print("corr peak at [3] = " .. c:get(3))
end
```

---

#### `LArray:countNonZero`

Counts the number of non-zero elements in this array.

```lua
LArray:countNonZero()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Number of non-zero elements. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({0, 1, 0, 2, 3}, {5})
    print("nonzero count = " .. a:countNonZero())
end
```

---

#### `LArray:covariance`

Returns covariance with another array.

```lua
LArray:covariance(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LArray](#larray) | Array used as the second variable. |

**Returns**

| Type | Description |
|------|-------------|
| number | Covariance value. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({1, 2, 3, 4, 5}, {5})
    local b = lurek.compute.fromTable({2, 4, 6, 8, 10}, {5})
    print("covariance = " .. a:covariance(b))
end
```

---

#### `LArray:cross2d`

Returns two-dimensional cross product with another vector.

```lua
LArray:cross2d(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LArray](#larray) | Vector array used as the second operand. |

**Returns**

| Type | Description |
|------|-------------|
| number | Scalar 2D cross product result. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({1, 0}, {2})
    local b = lurek.compute.fromTable({0, 1}, {2})
    print("cross2d = " .. a:cross2d(b))
end
```

---

#### `LArray:cumsum`

Returns cumulative sum over the flattened array.

```lua
LArray:cumsum()
```

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing cumulative sums. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({1, 2, 3, 4}, {4})
    local cs = a:cumsum()
    print("cumsum[4] = " .. cs:get(4))
end
```

---

#### `LArray:diff`

Returns finite differences over the flattened array.

```lua
LArray:diff(order)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `order?` | number | Difference order; defaults to 1. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing differences. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({1, 3, 6, 10}, {4})
    local d = a:diff()
    print("diff[1] = " .. d:get(1))
end
```

---

#### `LArray:dilate`

Returns morphological dilation with a radius.

```lua
LArray:dilate(radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `radius` | number | Dilation radius in cells. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing dilation result. |

**Example**

```lua
do
    local a = lurek.compute.zeros({5, 5})
    a:set(3, 3, 1)
    local d = a:dilate(1)
    print("dilated[2,3] = " .. d:get(2, 3))
end
```

---

#### `LArray:div`

Returns element-wise division with an array or scalar.

```lua
LArray:div(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | Array or scalar number for element-wise operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing the division result. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({10, 20, 30}, {3})
    local b = a:div(10)
    print("a / 10 → [1] = " .. b:get(1))
end
```

---

#### `LArray:divInplace`

Divides this array by another array in place.

```lua
LArray:divInplace(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LArray](#larray) | Array with a compatible shape. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({10, 20, 30, 40}, {2, 2})
    local b = lurek.compute.fromTable({2, 4, 5, 8}, {2, 2})
    a:divInplace(b)
    print("after divInplace[1,1] = " .. a:get(1, 1))
end
```

---

#### `LArray:dot`

Returns dot product with another array.

```lua
LArray:dot(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LArray](#larray) | Array used as the right-hand operand. |

**Returns**

| Type | Description |
|------|-------------|
| number | Dot product result. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({1, 2, 3}, {3})
    local b = lurek.compute.fromTable({4, 5, 6}, {3})
    print("dot = " .. a:dot(b))
end
```

---

#### `LArray:eigenPower`

Estimates dominant eigenvalue and eigenvector using power iteration.

```lua
LArray:eigenPower(max_iter, tol)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `max_iter?` | number | Maximum iteration count; zero uses the engine default. |
| `tol?` | number | Convergence tolerance; zero uses the engine default. |

**Returns**

| Type | Description |
|------|-------------|
| LArrayEigenPowerResult | Table containing `value` and `vector` fields. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({2, 1, 1, 2}, {2, 2})
    local result = a:eigenPower(100, 1e-6)
    print("eigenvalue = " .. result.value)
    print("eigenvector[1] = " .. tostring(result.vector[1]))
end
```

---

#### `LArray:eq`

Returns element-wise equality comparison with an array or scalar.

```lua
LArray:eq(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | Array or scalar number for element-wise operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New mask array containing comparison results. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({1, 2, 3, 2, 1}, {5})
    local mask = a:eq(2)
    print("eq(2) → [2] = " .. mask:get(2))
end
```

---

#### `LArray:erode`

Returns morphological erosion with a radius.

```lua
LArray:erode(radius)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `radius` | number | Erosion radius in cells. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing erosion result. |

**Example**

```lua
do
    local a = lurek.compute.ones({5, 5})
    a:set(1, 1, 0)
    local e = a:erode(1)
    print("eroded[2,2] = " .. e:get(2, 2))
end
```

---

#### `LArray:eval`

Maps each element through a Lua expression compiled as `function(x) return expression end`.

```lua
LArray:eval(expr)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `expr` | string | Lua expression that can read the current element as `x`. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing expression results. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({1, 2, 3}, {3})
    local b = a:eval("x * x + 1")
    print("eval[2] = " .. b:get(2))
end
```

---

#### `LArray:fill`

Fills this array in place with one value.

```lua
LArray:fill(val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `val` | number | Value written to every element. |

**Example**

```lua
do
    local a = lurek.compute.newArray({3, 3})
    a:fill(7)
    print("filled[2,2] = " .. a:get(2, 2))
end
```

---

#### `LArray:floodFill`

Returns a flood-filled copy starting at a one-based row and column.

```lua
LArray:floodFill(row, col, val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row` | number | One-based start row. |
| `col` | number | One-based start column. |
| `val` | number | Replacement value. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing flood-fill result. |

**Example**

```lua
do
    local a = lurek.compute.zeros({5, 5})
    a:set(1, 1, 1)
    a:set(1, 2, 1)
    local filled = a:floodFill(1, 1, 9)
    print("flood[1,2] = " .. filled:get(1, 2))
end
```

---

#### `LArray:get`

Reads an array element using one-based indices.

```lua
LArray:get(...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| — | — | @param ... number One-based indices, one per dimension. |

**Returns**

| Type | Description |
|------|-------------|
| number | Element value at the requested index. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({10, 20, 30, 40}, {2, 2})
    print("a[1,2] = " .. a:get(1, 2))
end
```

---

#### `LArray:getDataType`

Returns the element data type name as a string.

```lua
LArray:getDataType()
```

**Returns**

| Type | Description |
|------|-------------|
| string | Data type name such as `float32`. |

**Example**

```lua
do
    local a = lurek.compute.newArray({2, 2}, "float32")
    print("dtype = " .. a:getDataType())
end
```

---

#### `LArray:getDimensions`

Returns the number of array dimensions.

```lua
LArray:getDimensions()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Dimension count. |

**Example**

```lua
do
    local a = lurek.compute.newArray({2, 3, 4})
    print("dims = " .. a:getDimensions())
    print("size = " .. a:getSize())
end
```

---

#### `LArray:getRegion`

Returns a rectangular region from this array.

```lua
LArray:getRegion(row, col, rows, cols)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row` | number | One-based start row. |
| `col` | number | One-based start column. |
| `rows` | number | Region row count. |
| `cols` | number | Region column count. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing the requested region. |

**Example**

```lua
do
    local a = lurek.compute.range(1, 17, 1)
    local m = a:reshape({4, 4})
    local region = m:getRegion(2, 2, 2, 2)
    print("region[1,1] = " .. region:get(1, 1))
end
```

---

#### `LArray:getShape`

Returns the array shape as one-based dimension table.

```lua
LArray:getShape()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array table of dimension sizes. |

**Example**

```lua
do
    local a = lurek.compute.newArray({3, 4})
    local shape = a:getShape()
    print("shape = " .. shape[1] .. "x" .. shape[2])
end
```

---

#### `LArray:getSize`

Returns the total number of array elements.

```lua
LArray:getSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Element count. |

**Example**

```lua
do
    local a = lurek.compute.newArray({5, 5})
    print("size = " .. a:getSize())
end
```

---

#### `LArray:gt`

Returns element-wise greater-than comparison with an array or scalar.

```lua
LArray:gt(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | Array or scalar number for element-wise operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New mask array containing comparison results. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({1, 5, 10}, {3})
    local mask = a:gt(4)
    print("gt(4) → [2] = " .. mask:get(2))
end
```

---

#### `LArray:gte`

Returns element-wise greater-or-equal comparison with an array or scalar.

```lua
LArray:gte(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | Array or scalar number for element-wise operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New mask array containing comparison results. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({1, 5, 10}, {3})
    local mask = a:gte(5)
    print("gte(5) → [2] = " .. mask:get(2))
end
```

---

#### `LArray:histogram`

Returns histogram bins for the array values.

```lua
LArray:histogram(bins, lo, hi)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `bins` | number | Number of histogram bins. |
| `lo?` | number | Optional lower bound. |
| `hi?` | number | Optional upper bound. |

**Returns**

| Type | Description |
|------|-------------|
| LArrayHistogramResult | Array of bin tables with `lo`, `hi`, and `count` fields. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({1, 2, 3, 4, 5, 6, 7, 8}, {8})
    local bins = a:histogram(4)
    print("bin count = " .. #bins)
    print("first bin count = " .. tostring(bins[1].count))
end
```

---

#### `LArray:isOnGPU`

Returns whether this array is currently stored on the GPU.

```lua
LArray:isOnGPU()
```

**Returns**

| Type | Description |
|------|-------------|
| boolean | Always false for the current CPU-backed implementation. |

**Example**

```lua
do
    local a = lurek.compute.ones({4, 4})
    print("on GPU = " .. tostring(a:isOnGPU()))
end
```

---

#### `LArray:linsolve`

Solves a linear system using this matrix and a right-hand side array.

```lua
LArray:linsolve(b)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `b` | [LArray](#larray) | Right-hand side array. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | Solution array. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({2, 1, 5, 7}, {2, 2})
    local b = lurek.compute.fromTable({11, 13}, {2})
    local x = a:linsolve(b)
    print("x[1] = " .. x:get(1))
end
```

---

#### `LArray:lt`

Returns element-wise less-than comparison with an array or scalar.

```lua
LArray:lt(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | Array or scalar number for element-wise operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New mask array containing comparison results. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({1, 5, 10}, {3})
    local mask = a:lt(6)
    print("lt(6) → [3] = " .. mask:get(3))
end
```

---

#### `LArray:lte`

Returns element-wise less-or-equal comparison with an array or scalar.

```lua
LArray:lte(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | Array or scalar number for element-wise operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New mask array containing comparison results. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({1, 5, 10}, {3})
    local mask = a:lte(5)
    print("lte(5) → [2] = " .. mask:get(2))
end
```

---

#### `LArray:luDecompose`

Decomposes this matrix into LU data and permutation metadata.

```lua
LArray:luDecompose()
```

**Returns**

| Type | Description |
|------|-------------|
| LArrayLuDecomposeResult | Table containing `n`, `det_sign`, `perm`, and `lu_data` fields. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({4, 3, 6, 3}, {2, 2})
    local lu = a:luDecompose()
    print("n = " .. lu.n .. " det_sign = " .. lu.det_sign)
    print("perm[1] = " .. tostring(lu.perm[1]))
end
```

---

#### `LArray:map`

Maps each element through a Lua function and returns a new array.

```lua
LArray:map(func)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func` | function | Function called with each element value and returning a number. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing mapped values. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({1, 4, 9}, {3})
    local b = a:map(function(x) return x * 2 end)
    print("mapped[2] = " .. b:get(2))
end
```

---

#### `LArray:matmul`

Returns matrix multiplication of this array and another array.

```lua
LArray:matmul(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LArray](#larray) | Right-hand matrix array. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing matrix multiplication result. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({1, 2, 3, 4}, {2, 2})
    local b = lurek.compute.fromTable({5, 6, 7, 8}, {2, 2})
    local c = a:matmul(b)
    print("matmul[1,1] = " .. c:get(1, 1))
    print("matmul[2,2] = " .. c:get(2, 2))
end
```

---

#### `LArray:max`

Returns total maximum or a maximum array along a one-based axis.

```lua
LArray:max()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Scalar maximum when no axis is given. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({7, 2, 9, 1}, {4})
    print("max = " .. a:max())
end
```

---

#### `LArray:mean`

Returns total mean or a mean array along a one-based axis.

```lua
LArray:mean()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Scalar mean when no axis is given. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({2, 4, 6, 8}, {4})
    print("mean = " .. a:mean())
end
```

---

#### `LArray:min`

Returns total minimum or a minimum array along a one-based axis.

```lua
LArray:min()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Scalar minimum when no axis is given. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({7, 2, 9, 1}, {4})
    print("min = " .. a:min())
end
```

---

#### `LArray:mul`

Returns element-wise multiplication with an array or scalar.

```lua
LArray:mul(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | Array or scalar number for element-wise operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing the multiplication result. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({2, 3, 4}, {3})
    local b = a:mul(3)
    print("a * 3 → [3] = " .. b:get(3))
end
```

---

#### `LArray:mulInplace`

Multiplies this array by another array in place.

```lua
LArray:mulInplace(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LArray](#larray) | Array with a compatible shape. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({2, 3, 4, 5}, {2, 2})
    local b = lurek.compute.fromTable({10, 10, 10, 10}, {2, 2})
    a:mulInplace(b)
    print("after mulInplace[1,1] = " .. a:get(1, 1))
end
```

---

#### `LArray:neg`

Returns element-wise negated values.

```lua
LArray:neg()
```

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing negated values. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({5, -3, 0}, {3})
    local b = a:neg()
    print("neg → [1] = " .. b:get(1))
end
```

---

#### `LArray:neq`

Returns element-wise inequality comparison with an array or scalar.

```lua
LArray:neq(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | Array or scalar number for element-wise operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New mask array containing comparison results. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({1, 2, 3}, {3})
    local mask = a:neq(2)
    print("neq(2) → [1] = " .. mask:get(1))
end
```

---

#### `LArray:normalizeRange`

Returns array values normalized into a target range.

```lua
LArray:normalizeRange(lo, hi)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `lo` | number | Target lower bound. |
| `hi` | number | Target upper bound. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New normalized array. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({0, 50, 100}, {3})
    local n = a:normalizeRange(0, 1)
    print("normalized[2] = " .. n:get(2))
end
```

---

#### `LArray:normalizeVec`

Returns this vector normalized to unit length.

```lua
LArray:normalizeVec()
```

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New normalized vector array. |

**Example**

```lua
do
    local v = lurek.compute.fromTable({3, 4}, {2})
    local n = v:normalizeVec()
    print("normalized[1] = " .. n:get(1))
    print("normalized[2] = " .. n:get(2))
end
```

---

#### `LArray:outer`

Returns outer product with another vector array.

```lua
LArray:outer(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LArray](#larray) | Vector array used as the second operand. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing outer product result. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({1, 2, 3}, {3})
    local b = lurek.compute.fromTable({4, 5}, {2})
    local o = a:outer(b)
    print("outer[1,2] = " .. o:get(1, 2))
end
```

---

#### `LArray:pearsonCorr`

Returns Pearson correlation with another array.

```lua
LArray:pearsonCorr(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LArray](#larray) | Array used as the second variable. |

**Returns**

| Type | Description |
|------|-------------|
| number | Pearson correlation coefficient. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({1, 2, 3, 4, 5}, {5})
    local b = lurek.compute.fromTable({2, 4, 6, 8, 10}, {5})
    print("pearson = " .. a:pearsonCorr(b))
end
```

---

#### `LArray:percentile`

Returns a percentile value from the array.

```lua
LArray:percentile(p)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `p` | number | Percentile between 0 and 100. |

**Returns**

| Type | Description |
|------|-------------|
| number | Percentile result. |

**Example**

```lua
do
    local a = lurek.compute.range(1, 100, 1)
    local p50 = a:percentile(50)
    print("p50 = " .. p50)
end
```

---

#### `LArray:pow`

Returns this array raised element-wise to a scalar exponent.

```lua
LArray:pow(exp)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `exp` | number | Exponent applied to every element. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing powered values. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({2, 3, 4}, {3})
    local b = a:pow(2)
    print("a^2 → [2] = " .. b:get(2))
end
```

---

#### `LArray:reduce`

Reduces array values with a Lua accumulator function.

```lua
LArray:reduce(func, init)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func` | function | Function called as `(accumulator, value)` and returning the next accumulator. |
| `init` | number | Initial accumulator value. |

**Returns**

| Type | Description |
|------|-------------|
| number | Final accumulator value. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({1, 2, 3, 4}, {4})
    local total = a:reduce(function(acc, v) return acc + v end, 0)
    print("reduce sum = " .. total)
end
```

---

#### `LArray:reshape`

Returns a reshaped copy of this array.

```lua
LArray:reshape(shape)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shape` | table | Array table of positive dimension sizes. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array with the requested shape. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({1, 2, 3, 4, 5, 6}, {6})
    local b = a:reshape({2, 3})
    print("reshaped dims = " .. b:getDimensions())
    print("reshaped[2,3] = " .. b:get(2, 3))
end
```

---

#### `LArray:scan`

Produces prefix accumulator values with a Lua function.

```lua
LArray:scan(func, init)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `func` | function | Function called as `(accumulator, value)` and returning the next accumulator. |
| `init` | number | Initial accumulator value. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing accumulator values. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({1, 2, 3, 4}, {4})
    local s = a:scan(function(acc, v) return acc + v end, 0)
    print("scan[4] = " .. s:get(4))
    print("scan[2] = " .. s:get(2))
end
```

---

#### `LArray:set`

Writes an array element using one-based indices followed by the value.

```lua
LArray:set(...)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| — | — | @param ... number One-based indices followed by the numeric value to store. |

**Example**

```lua
do
    local a = lurek.compute.zeros({3, 3})
    a:set(2, 2, 99)
    print("a[2,2] = " .. a:get(2, 2))
end
```

---

#### `LArray:setRegion`

Writes a source array into this array at a one-based row and column.

```lua
LArray:setRegion(row, col, source)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `row` | number | One-based destination row. |
| `col` | number | One-based destination column. |
| `source` | [LArray](#larray) | Source array copied into this array. |

**Example**

```lua
do
    local a = lurek.compute.zeros({4, 4})
    local patch = lurek.compute.ones({2, 2})
    a:setRegion(2, 2, patch)
    print("after setRegion[2,2] = " .. a:get(2, 2))
end
```

---

#### `LArray:sobel`

Computes Sobel gradients for this array.

```lua
LArray:sobel()
```

**Returns**

| Type | Description |
|------|-------------|
| LArraySobelResult | Table with `gx` and `gy` gradient arrays. |

**Example**

```lua
do
    local img = lurek.compute.zeros({5, 5})
    img:set(3, 3, 1)
    local grad = img:sobel()
    print("gx size = " .. grad.gx:getSize())
    print("gy size = " .. grad.gy:getSize())
end
```

---

#### `LArray:sqrt`

Returns element-wise square roots.

```lua
LArray:sqrt()
```

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing square root values. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({4, 9, 16}, {3})
    local b = a:sqrt()
    print("sqrt → [1] = " .. b:get(1))
end
```

---

#### `LArray:sub`

Returns element-wise subtraction with an array or scalar.

```lua
LArray:sub(value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `value` | any | Array or scalar number for element-wise operation. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing the subtraction result. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({10, 20, 30}, {3})
    local b = a:sub(5)
    print("a - 5 → [2] = " .. b:get(2))
end
```

---

#### `LArray:subInplace`

Subtracts another array from this array in place.

```lua
LArray:subInplace(other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `other` | [LArray](#larray) | Array with a compatible shape. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({5, 5, 5, 5}, {2, 2})
    local b = lurek.compute.ones({2, 2})
    a:subInplace(b)
    print("after subInplace[1,1] = " .. a:get(1, 1))
end
```

---

#### `LArray:sum`

Returns total sum or a summed array along a one-based axis.

```lua
LArray:sum()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Scalar sum when no axis is given. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({1, 2, 3, 4}, {4})
    print("sum = " .. a:sum())
    print("mean = " .. a:mean())
end
```

---

#### `LArray:threshold`

Returns a mask array where values above a threshold are selected.

```lua
LArray:threshold(val)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `val` | number | Threshold value. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New mask array containing threshold results. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({0.1, 0.5, 0.9}, {3})
    local mask = a:threshold(0.4)
    print("threshold(0.4) → [1]=" .. mask:get(1) .. " [3]=" .. mask:get(3))
end
```

---

#### `LArray:toTable`

Returns array values flattened into a Lua table.

```lua
LArray:toTable()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Numeric values in storage order. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({1, 2, 3}, {3})
    local t = a:toTable()
    print("table = " .. t[1] .. "," .. t[2] .. "," .. t[3])
end
```

---

#### `LArray:transformPoints`

Transforms a point array by this transform matrix.

```lua
LArray:transformPoints(pts)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pts` | [LArray](#larray) | Point array to transform. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing transformed points. |

**Example**

```lua
do
    local m = lurek.compute.affine2d(10, 20, 0, 1, 1)
    local pts = lurek.compute.fromTable({0, 0, 5, 5}, {2, 2})
    local result = m:transformPoints(pts)
    print("transformed[1,1] = " .. result:get(1, 1))
end
```

---

#### `LArray:transpose`

Returns a transposed copy of a two-dimensional array.

```lua
LArray:transpose()
```

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New transposed array. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({1, 2, 3, 4, 5, 6}, {2, 3})
    local t = a:transpose()
    local shape = t:getShape()
    print("transposed shape = " .. shape[1] .. "x" .. shape[2])
end
```

---

#### `LArray:type`

Returns the Lua-visible type name for this array handle.

```lua
LArray:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LArray](#larray)`. |

**Example**

```lua
do
    local a = lurek.compute.ones({2, 2})
    print("type = " .. a:type())
end
```

---

#### `LArray:typeOf`

Returns whether this array handle matches a supported type name.

```lua
LArray:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LArray](#larray)`, `Array`, and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local a = lurek.compute.ones({2, 2})
    print("is LArray = " .. tostring(a:typeOf("LArray")))
    print("is Object = " .. tostring(a:typeOf("LObject")))
end
```

---

#### `LArray:where`

Selects values from this array or another array using a mask array.

```lua
LArray:where(mask, other)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `mask` | [LArray](#larray) | Mask array used to choose between arrays. |
| `other` | [LArray](#larray) | Array used where the mask is false. |

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New array containing selected values. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({10, 20, 30}, {3})
    local b = lurek.compute.fromTable({-1, -2, -3}, {3})
    local mask = a:gt(15)
    local result = a:where(mask, b)
    print("where → [1]=" .. result:get(1) .. " [2]=" .. result:get(2))
    print("where → [3]=" .. result:get(3))
end
```

---

#### `LArray:zscore`

Returns z-score normalized array values.

```lua
LArray:zscore()
```

**Returns**

| Type | Description |
|------|-------------|
| [LArray](#larray) | New z-score normalized array. |

**Example**

```lua
do
    local a = lurek.compute.fromTable({2, 4, 4, 4, 5, 5, 7, 9}, {8})
    local z = a:zscore()
    print("zscore[1] = " .. z:get(1))
end
```

---
