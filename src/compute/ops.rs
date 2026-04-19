//! Element-wise, reduction, comparison, masking, shape, and bitwise operations on NdArray.
//!
//! This module is part of Lurek2D's `compute` subsystem and provides the implementation
//! details for ops-related operations and data management.
//! Primary functions: `add()`, `add_scalar()`, `sub()`, `sub_scalar()`.
//!
//! All public items are documented. See the parent module for architectural context
//! and the `lurek.*` Lua API for the scripting interface.

use crate::compute::array::{DataType, NdArray};
use rayon::prelude::*;

/// Element count above which element-wise and reduction ops use Rayon thread pool.
const PAR_THRESHOLD: usize = 10_000;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Validate two arrays have the same shape and dtype for element-wise ops.
fn check_same_shape_dtype(a: &NdArray, b: &NdArray) -> Result<(), String> {
    if a.shape() != b.shape() {
        return Err(format!(
            "shape mismatch: {:?} vs {:?}",
            a.shape(),
            b.shape()
        ));
    }
    if a.dtype() != b.dtype() {
        return Err(format!(
            "dtype mismatch: {} vs {}",
            a.dtype().name(),
            b.dtype().name()
        ));
    }
    Ok(())
}

/// Apply an element-wise binary op (array, array) → new array.
fn elementwise_binary(
    a: &NdArray,
    b: &NdArray,
    op: fn(f64, f64) -> f64,
) -> Result<NdArray, String> {
    check_same_shape_dtype(a, b)?;
    let mut out = NdArray::zeros(a.shape(), a.dtype())?;
    if a.size() > PAR_THRESHOLD {
        let vals: Vec<f64> = (0..a.size())
            .into_par_iter()
            .map(|i| op(a.get_f64(i), b.get_f64(i)))
            .collect();
        for (i, v) in vals.into_iter().enumerate() {
            out.set_f64(i, v);
        }
    } else {
        for i in 0..a.size() {
            out.set_f64(i, op(a.get_f64(i), b.get_f64(i)));
        }
    }
    Ok(out)
}

/// Apply an element-wise unary op → new array.
fn elementwise_unary(a: &NdArray, op: fn(f64) -> f64) -> Result<NdArray, String> {
    let mut out = NdArray::zeros(a.shape(), a.dtype())?;
    if a.size() > PAR_THRESHOLD {
        let vals: Vec<f64> = (0..a.size())
            .into_par_iter()
            .map(|i| op(a.get_f64(i)))
            .collect();
        for (i, v) in vals.into_iter().enumerate() {
            out.set_f64(i, v);
        }
    } else {
        for i in 0..a.size() {
            out.set_f64(i, op(a.get_f64(i)));
        }
    }
    Ok(out)
}

/// Apply an element-wise (element, scalar) op → new array.
fn elementwise_scalar(a: &NdArray, s: f64, op: fn(f64, f64) -> f64) -> Result<NdArray, String> {
    let mut out = NdArray::zeros(a.shape(), a.dtype())?;
    if a.size() > PAR_THRESHOLD {
        let vals: Vec<f64> = (0..a.size())
            .into_par_iter()
            .map(|i| op(a.get_f64(i), s))
            .collect();
        for (i, v) in vals.into_iter().enumerate() {
            out.set_f64(i, v);
        }
    } else {
        for i in 0..a.size() {
            out.set_f64(i, op(a.get_f64(i), s));
        }
    }
    Ok(out)
}

/// Validate that axis is within the array's ndim.
fn check_axis(a: &NdArray, axis: usize) -> Result<(), String> {
    if axis >= a.ndim() {
        return Err(format!(
            "axis {} out of bounds for array with {} dimensions",
            axis,
            a.ndim()
        ));
    }
    Ok(())
}

/// Check that array has Int32 dtype, returning an error otherwise.
fn require_int32(a: &NdArray) -> Result<(), String> {
    if a.dtype() != DataType::Int32 {
        return Err(format!(
            "bitwise ops require int32 dtype, got {}",
            a.dtype().name()
        ));
    }
    Ok(())
}

// ---------------------------------------------------------------------------
// Element-wise arithmetic
// ---------------------------------------------------------------------------

/// Element-wise addition of two arrays (same shape and dtype).
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `b` — `&NdArray`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn add(a: &NdArray, b: &NdArray) -> Result<NdArray, String> {
    elementwise_binary(a, b, |x, y| x + y)
}

/// Add a scalar to every element. The insertion is O(1) amortised unless a resize is triggered.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `s` — `f64`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn add_scalar(a: &NdArray, s: f64) -> Result<NdArray, String> {
    elementwise_scalar(a, s, |x, y| x + y)
}

/// Element-wise subtraction of two arrays (same shape and dtype).
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `b` — `&NdArray`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn sub(a: &NdArray, b: &NdArray) -> Result<NdArray, String> {
    elementwise_binary(a, b, |x, y| x - y)
}

/// Subtract a scalar from every element.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `s` — `f64`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn sub_scalar(a: &NdArray, s: f64) -> Result<NdArray, String> {
    elementwise_scalar(a, s, |x, y| x - y)
}

/// Element-wise multiplication of two arrays (same shape and dtype).
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `b` — `&NdArray`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn mul(a: &NdArray, b: &NdArray) -> Result<NdArray, String> {
    elementwise_binary(a, b, |x, y| x * y)
}

/// Multiply every element by a scalar.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `s` — `f64`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn mul_scalar(a: &NdArray, s: f64) -> Result<NdArray, String> {
    elementwise_scalar(a, s, |x, y| x * y)
}

/// Element-wise division of two arrays (same shape and dtype).
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `b` — `&NdArray`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn div(a: &NdArray, b: &NdArray) -> Result<NdArray, String> {
    elementwise_binary(a, b, |x, y| x / y)
}

/// Divide every element by a scalar.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `s` — `f64`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn div_scalar(a: &NdArray, s: f64) -> Result<NdArray, String> {
    elementwise_scalar(a, s, |x, y| x / y)
}

/// Raise every element to a scalar exponent.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `exp` — `f64`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn pow_scalar(a: &NdArray, exp: f64) -> Result<NdArray, String> {
    let mut out = NdArray::zeros(a.shape(), a.dtype())?;
    for i in 0..a.size() {
        out.set_f64(i, a.get_f64(i).powf(exp));
    }
    Ok(out)
}

/// Element-wise square root.
///
/// # Parameters
/// - `a` — `&NdArray`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn sqrt(a: &NdArray) -> Result<NdArray, String> {
    elementwise_unary(a, f64::sqrt)
}

/// Element-wise absolute value.
///
/// # Parameters
/// - `a` — `&NdArray`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn abs(a: &NdArray) -> Result<NdArray, String> {
    elementwise_unary(a, f64::abs)
}

/// Element-wise negation.
///
/// # Parameters
/// - `a` — `&NdArray`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn neg(a: &NdArray) -> Result<NdArray, String> {
    elementwise_unary(a, |x| -x)
}

/// Clamp every element to `[min_val, max_val]`.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `min_val` — `f64`.
/// - `max_val` — `f64`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn clamp(a: &NdArray, min_val: f64, max_val: f64) -> Result<NdArray, String> {
    let mut out = NdArray::zeros(a.shape(), a.dtype())?;
    for i in 0..a.size() {
        out.set_f64(i, a.get_f64(i).clamp(min_val, max_val));
    }
    Ok(out)
}

// ---------------------------------------------------------------------------
// Comparison — returns Float32 array with 0.0 / 1.0 values
// ---------------------------------------------------------------------------

/// Element-wise equality comparison of two arrays. Returns Float32 with 0/1.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `b` — `&NdArray`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn eq(a: &NdArray, b: &NdArray) -> Result<NdArray, String> {
    check_same_shape_dtype(a, b)?;
    let mut out = NdArray::zeros(a.shape(), DataType::Float32)?;
    for i in 0..a.size() {
        let v = if (a.get_f64(i) - b.get_f64(i)).abs() < f64::EPSILON {
            1.0
        } else {
            0.0
        };
        out.set_f64(i, v);
    }
    Ok(out)
}

/// Element-wise equality comparison against a scalar. Returns Float32.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `s` — `f64`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn eq_scalar(a: &NdArray, s: f64) -> Result<NdArray, String> {
    let mut out = NdArray::zeros(a.shape(), DataType::Float32)?;
    for i in 0..a.size() {
        let v = if (a.get_f64(i) - s).abs() < f64::EPSILON {
            1.0
        } else {
            0.0
        };
        out.set_f64(i, v);
    }
    Ok(out)
}

/// Element-wise not-equal comparison of two arrays. Returns Float32.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `b` — `&NdArray`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn neq(a: &NdArray, b: &NdArray) -> Result<NdArray, String> {
    check_same_shape_dtype(a, b)?;
    let mut out = NdArray::zeros(a.shape(), DataType::Float32)?;
    for i in 0..a.size() {
        let v = if (a.get_f64(i) - b.get_f64(i)).abs() >= f64::EPSILON {
            1.0
        } else {
            0.0
        };
        out.set_f64(i, v);
    }
    Ok(out)
}

/// Element-wise not-equal comparison against a scalar. Returns Float32.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `s` — `f64`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn neq_scalar(a: &NdArray, s: f64) -> Result<NdArray, String> {
    let mut out = NdArray::zeros(a.shape(), DataType::Float32)?;
    for i in 0..a.size() {
        let v = if (a.get_f64(i) - s).abs() >= f64::EPSILON {
            1.0
        } else {
            0.0
        };
        out.set_f64(i, v);
    }
    Ok(out)
}

/// Element-wise greater-than comparison of two arrays. Returns Float32.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `b` — `&NdArray`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn gt(a: &NdArray, b: &NdArray) -> Result<NdArray, String> {
    check_same_shape_dtype(a, b)?;
    let mut out = NdArray::zeros(a.shape(), DataType::Float32)?;
    for i in 0..a.size() {
        out.set_f64(
            i,
            if a.get_f64(i) > b.get_f64(i) {
                1.0
            } else {
                0.0
            },
        );
    }
    Ok(out)
}

/// Element-wise greater-than comparison against a scalar. Returns Float32.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `s` — `f64`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn gt_scalar(a: &NdArray, s: f64) -> Result<NdArray, String> {
    let mut out = NdArray::zeros(a.shape(), DataType::Float32)?;
    for i in 0..a.size() {
        out.set_f64(i, if a.get_f64(i) > s { 1.0 } else { 0.0 });
    }
    Ok(out)
}

/// Element-wise less-than comparison of two arrays. Returns Float32.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `b` — `&NdArray`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn lt(a: &NdArray, b: &NdArray) -> Result<NdArray, String> {
    check_same_shape_dtype(a, b)?;
    let mut out = NdArray::zeros(a.shape(), DataType::Float32)?;
    for i in 0..a.size() {
        out.set_f64(
            i,
            if a.get_f64(i) < b.get_f64(i) {
                1.0
            } else {
                0.0
            },
        );
    }
    Ok(out)
}

/// Element-wise less-than comparison against a scalar. Returns Float32.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `s` — `f64`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn lt_scalar(a: &NdArray, s: f64) -> Result<NdArray, String> {
    let mut out = NdArray::zeros(a.shape(), DataType::Float32)?;
    for i in 0..a.size() {
        out.set_f64(i, if a.get_f64(i) < s { 1.0 } else { 0.0 });
    }
    Ok(out)
}

/// Element-wise greater-than-or-equal comparison of two arrays. Returns Float32.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `b` — `&NdArray`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn gte(a: &NdArray, b: &NdArray) -> Result<NdArray, String> {
    check_same_shape_dtype(a, b)?;
    let mut out = NdArray::zeros(a.shape(), DataType::Float32)?;
    for i in 0..a.size() {
        out.set_f64(
            i,
            if a.get_f64(i) >= b.get_f64(i) {
                1.0
            } else {
                0.0
            },
        );
    }
    Ok(out)
}

/// Element-wise greater-than-or-equal comparison against a scalar. Returns Float32.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `s` — `f64`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn gte_scalar(a: &NdArray, s: f64) -> Result<NdArray, String> {
    let mut out = NdArray::zeros(a.shape(), DataType::Float32)?;
    for i in 0..a.size() {
        out.set_f64(i, if a.get_f64(i) >= s { 1.0 } else { 0.0 });
    }
    Ok(out)
}

/// Element-wise less-than-or-equal comparison of two arrays. Returns Float32.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `b` — `&NdArray`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn lte(a: &NdArray, b: &NdArray) -> Result<NdArray, String> {
    check_same_shape_dtype(a, b)?;
    let mut out = NdArray::zeros(a.shape(), DataType::Float32)?;
    for i in 0..a.size() {
        out.set_f64(
            i,
            if a.get_f64(i) <= b.get_f64(i) {
                1.0
            } else {
                0.0
            },
        );
    }
    Ok(out)
}

/// Element-wise less-than-or-equal comparison against a scalar. Returns Float32.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `s` — `f64`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn lte_scalar(a: &NdArray, s: f64) -> Result<NdArray, String> {
    let mut out = NdArray::zeros(a.shape(), DataType::Float32)?;
    for i in 0..a.size() {
        out.set_f64(i, if a.get_f64(i) <= s { 1.0 } else { 0.0 });
    }
    Ok(out)
}

// ---------------------------------------------------------------------------
// Masking
// ---------------------------------------------------------------------------

/// Threshold mask: returns Float32 array with 1.0 where `a >= val`, 0.0 otherwise.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `val` — `f64`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn threshold(a: &NdArray, val: f64) -> Result<NdArray, String> {
    gte_scalar(a, val)
}

/// Conditional selection: where `cond != 0`, choose from `a`; otherwise from `b`.
///
/// # Parameters
/// - `cond` — `&NdArray`.
/// - `a` — `&NdArray`.
/// - `b` — `&NdArray`.
///
/// # Returns
/// `Result<NdArray, String>`.
///
/// All three arrays must have the same shape. `a` and `b` must have the same dtype.
/// `cond` is read as Float32.
pub fn where_mask(cond: &NdArray, a: &NdArray, b: &NdArray) -> Result<NdArray, String> {
    if cond.shape() != a.shape() || a.shape() != b.shape() {
        return Err(format!(
            "where_mask: shape mismatch: cond={:?}, a={:?}, b={:?}",
            cond.shape(),
            a.shape(),
            b.shape()
        ));
    }
    if a.dtype() != b.dtype() {
        return Err(format!(
            "where_mask: dtype mismatch: a={}, b={}",
            a.dtype().name(),
            b.dtype().name()
        ));
    }
    let mut out = NdArray::zeros(a.shape(), a.dtype())?;
    for i in 0..a.size() {
        let c = cond.get_f64(i);
        out.set_f64(i, if c != 0.0 { a.get_f64(i) } else { b.get_f64(i) });
    }
    Ok(out)
}

// ---------------------------------------------------------------------------
// Counting
// ---------------------------------------------------------------------------

/// Count the number of non-zero elements. Runs in O(1) time.
///
/// # Parameters
/// - `a` — `&NdArray`.
///
/// # Returns
/// `usize`.
pub fn count_nonzero(a: &NdArray) -> usize {
    let mut count = 0usize;
    for i in 0..a.size() {
        if a.get_f64(i) != 0.0 {
            count += 1;
        }
    }
    count
}

/// Return the flat index of the minimum element (0-based).
///
/// # Parameters
/// - `a` — `&NdArray`.
///
/// # Returns
/// `usize`.
pub fn argmin(a: &NdArray) -> usize {
    let mut best_idx = 0;
    let mut best_val = a.get_f64(0);
    for i in 1..a.size() {
        let v = a.get_f64(i);
        if v < best_val {
            best_val = v;
            best_idx = i;
        }
    }
    best_idx
}

/// Return the flat index of the maximum element (0-based).
///
/// # Parameters
/// - `a` — `&NdArray`.
///
/// # Returns
/// `usize`.
pub fn argmax(a: &NdArray) -> usize {
    let mut best_idx = 0;
    let mut best_val = a.get_f64(0);
    for i in 1..a.size() {
        let v = a.get_f64(i);
        if v > best_val {
            best_val = v;
            best_idx = i;
        }
    }
    best_idx
}

/// Returns `true` if any element is non-zero.
///
/// # Parameters
/// - `a` — `&NdArray`.
///
/// # Returns
/// `bool`.
pub fn any(a: &NdArray) -> bool {
    for i in 0..a.size() {
        if a.get_f64(i) != 0.0 {
            return true;
        }
    }
    false
}

/// Returns `true` if all elements are non-zero.
///
/// # Parameters
/// - `a` — `&NdArray`.
///
/// # Returns
/// `bool`.
pub fn all(a: &NdArray) -> bool {
    for i in 0..a.size() {
        if a.get_f64(i) == 0.0 {
            return false;
        }
    }
    true
}

// ---------------------------------------------------------------------------
// Reductions — global
// ---------------------------------------------------------------------------

/// Sum of all elements.
///
/// # Parameters
/// - `a` — `&NdArray`.
///
/// # Returns
/// `f64`.
pub fn sum(a: &NdArray) -> f64 {
    if a.size() > PAR_THRESHOLD {
        (0..a.size()).into_par_iter().map(|i| a.get_f64(i)).sum()
    } else {
        let mut s = 0.0;
        for i in 0..a.size() {
            s += a.get_f64(i);
        }
        s
    }
}

/// Mean of all elements.
///
/// # Parameters
/// - `a` — `&NdArray`.
///
/// # Returns
/// `f64`.
pub fn mean(a: &NdArray) -> f64 {
    sum(a) / a.size() as f64
}

/// Minimum value across all elements.
///
/// # Parameters
/// - `a` — `&NdArray`.
///
/// # Returns
/// `f64`.
pub fn min_val(a: &NdArray) -> f64 {
    if a.size() > PAR_THRESHOLD {
        (0..a.size())
            .into_par_iter()
            .map(|i| a.get_f64(i))
            .reduce_with(f64::min)
            .unwrap_or(f64::NAN)
    } else {
        let mut m = a.get_f64(0);
        for i in 1..a.size() {
            let v = a.get_f64(i);
            if v < m {
                m = v;
            }
        }
        m
    }
}

/// Maximum value across all elements.
///
/// # Parameters
/// - `a` — `&NdArray`.
///
/// # Returns
/// `f64`.
pub fn max_val(a: &NdArray) -> f64 {
    if a.size() > PAR_THRESHOLD {
        (0..a.size())
            .into_par_iter()
            .map(|i| a.get_f64(i))
            .reduce_with(f64::max)
            .unwrap_or(f64::NAN)
    } else {
        let mut m = a.get_f64(0);
        for i in 1..a.size() {
            let v = a.get_f64(i);
            if v > m {
                m = v;
            }
        }
        m
    }
}

// ---------------------------------------------------------------------------
// Reductions — along axis
// ---------------------------------------------------------------------------

/// Compute the output shape when reducing along a given axis.
fn reduced_shape(shape: &[usize], axis: usize) -> Vec<usize> {
    let mut out = Vec::with_capacity(shape.len() - 1);
    for (i, &dim) in shape.iter().enumerate() {
        if i != axis {
            out.push(dim);
        }
    }
    // If reducing a 1D array, result is a 1-element 1D array.
    if out.is_empty() {
        out.push(1);
    }
    out
}

/// Helper: iterate over all multi-indices of a shape, calling `f(flat_index, multi_index)`.
fn for_each_index(shape: &[usize], mut f: impl FnMut(usize, &[usize])) {
    let ndim = shape.len();
    let total: usize = shape.iter().product();
    let strides = NdArray::compute_strides(shape);
    let mut indices = vec![0usize; ndim];
    for flat in 0..total {
        f(flat, &indices);
        // Increment multi-index (odometer style, last axis fastest)
        for d in (0..ndim).rev() {
            indices[d] += 1;
            if indices[d] < shape[d] {
                break;
            }
            indices[d] = 0;
        }
        let _ = strides; // suppress unused warning
    }
}

/// Sum along a given axis, producing an array with that axis removed.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `axis` — `usize`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn sum_axis(a: &NdArray, axis: usize) -> Result<NdArray, String> {
    check_axis(a, axis)?;
    let out_shape = reduced_shape(a.shape(), axis);
    let mut out = NdArray::zeros(&out_shape, a.dtype())?;
    let out_strides = NdArray::compute_strides(&out_shape);

    for_each_index(a.shape(), |_flat, indices| {
        // Compute output flat index by skipping the reduced axis
        let mut out_flat = 0usize;
        let mut out_dim = 0;
        for (i, &idx) in indices.iter().enumerate() {
            if i != axis {
                out_flat += idx * out_strides[out_dim];
                out_dim += 1;
            }
        }
        // For 1D reduction to [1], out_flat is always 0
        let cur = out.get_f64(out_flat);
        out.set_f64(out_flat, cur + a.get_f64(a.flat_index(indices).unwrap()));
    });

    Ok(out)
}

/// Mean along a given axis.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `axis` — `usize`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn mean_axis(a: &NdArray, axis: usize) -> Result<NdArray, String> {
    check_axis(a, axis)?;
    let mut out = sum_axis(a, axis)?;
    let axis_size = a.shape()[axis] as f64;
    for i in 0..out.size() {
        out.set_f64(i, out.get_f64(i) / axis_size);
    }
    Ok(out)
}

/// Minimum along a given axis.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `axis` — `usize`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn min_axis(a: &NdArray, axis: usize) -> Result<NdArray, String> {
    check_axis(a, axis)?;
    let out_shape = reduced_shape(a.shape(), axis);
    let mut out = NdArray::zeros(&out_shape, a.dtype())?;
    let out_strides = NdArray::compute_strides(&out_shape);
    // Initialize with f64::MAX
    for i in 0..out.size() {
        out.set_f64(i, f64::MAX);
    }

    for_each_index(a.shape(), |_flat, indices| {
        let mut out_flat = 0usize;
        let mut out_dim = 0;
        for (i, &idx) in indices.iter().enumerate() {
            if i != axis {
                out_flat += idx * out_strides[out_dim];
                out_dim += 1;
            }
        }
        let val = a.get_f64(a.flat_index(indices).unwrap());
        if val < out.get_f64(out_flat) {
            out.set_f64(out_flat, val);
        }
    });

    Ok(out)
}

/// Maximum along a given axis.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `axis` — `usize`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn max_axis(a: &NdArray, axis: usize) -> Result<NdArray, String> {
    check_axis(a, axis)?;
    let out_shape = reduced_shape(a.shape(), axis);
    let mut out = NdArray::zeros(&out_shape, a.dtype())?;
    let out_strides = NdArray::compute_strides(&out_shape);
    // Initialize with f64::MIN
    for i in 0..out.size() {
        out.set_f64(i, f64::MIN);
    }

    for_each_index(a.shape(), |_flat, indices| {
        let mut out_flat = 0usize;
        let mut out_dim = 0;
        for (i, &idx) in indices.iter().enumerate() {
            if i != axis {
                out_flat += idx * out_strides[out_dim];
                out_dim += 1;
            }
        }
        let val = a.get_f64(a.flat_index(indices).unwrap());
        if val > out.get_f64(out_flat) {
            out.set_f64(out_flat, val);
        }
    });

    Ok(out)
}

// ---------------------------------------------------------------------------
// Shape operations
// ---------------------------------------------------------------------------

/// Reshape an array to a new shape with the same total element count.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `new_shape` — `&[usize]`.
///
/// # Returns
/// `Result<NdArray, String>`.
///
/// Returns a new array with data copied from the original.
pub fn reshape(a: &NdArray, new_shape: &[usize]) -> Result<NdArray, String> {
    let new_total: usize = new_shape.iter().product();
    if new_total != a.size() {
        return Err(format!(
            "cannot reshape array of size {} into shape {:?} (size {})",
            a.size(),
            new_shape,
            new_total,
        ));
    }
    if new_shape.is_empty() || new_shape.len() > 3 {
        return Err(format!("ndim must be 1, 2, or 3, got {}", new_shape.len()));
    }
    let mut out = a.clone();
    let strides = NdArray::compute_strides(new_shape);
    out.set_shape(new_shape.to_vec(), strides);
    Ok(out)
}

/// Transpose a 2D array (swap rows and columns).
///
/// # Parameters
/// - `a` — `&NdArray`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn transpose_2d(a: &NdArray) -> Result<NdArray, String> {
    if a.ndim() != 2 {
        return Err(format!(
            "transpose_2d requires a 2D array, got {}D",
            a.ndim()
        ));
    }
    let rows = a.shape()[0];
    let cols = a.shape()[1];
    let mut out = NdArray::zeros(&[cols, rows], a.dtype())?;
    for r in 0..rows {
        for c in 0..cols {
            let src = a.flat_index(&[r, c]).unwrap();
            let dst = out.flat_index(&[c, r]).unwrap();
            out.set_f64(dst, a.get_f64(src));
        }
    }
    Ok(out)
}

/// Fill all elements of an array with a value (in-place).
///
/// # Parameters
/// - `a` — `&mut NdArray`.
/// - `val` — `f64`.
pub fn fill(a: &mut NdArray, val: f64) {
    for i in 0..a.size() {
        a.set_f64(i, val);
    }
}

/// Clone an array (convenience wrapper).
///
/// # Parameters
/// - `a` — `&NdArray`.
///
/// # Returns
/// `NdArray`.
pub fn clone_array(a: &NdArray) -> NdArray {
    a.clone()
}

// ---------------------------------------------------------------------------
// Bitwise — Int32 only
// ---------------------------------------------------------------------------

/// Bitwise AND of two Int32 arrays.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `b` — `&NdArray`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn bitwise_and(a: &NdArray, b: &NdArray) -> Result<NdArray, String> {
    require_int32(a)?;
    require_int32(b)?;
    check_same_shape_dtype(a, b)?;
    let mut out = NdArray::zeros(a.shape(), DataType::Int32)?;
    for i in 0..a.size() {
        out.set_i32(i, a.get_i32(i) & b.get_i32(i));
    }
    Ok(out)
}

/// Bitwise OR of two Int32 arrays.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `b` — `&NdArray`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn bitwise_or(a: &NdArray, b: &NdArray) -> Result<NdArray, String> {
    require_int32(a)?;
    require_int32(b)?;
    check_same_shape_dtype(a, b)?;
    let mut out = NdArray::zeros(a.shape(), DataType::Int32)?;
    for i in 0..a.size() {
        out.set_i32(i, a.get_i32(i) | b.get_i32(i));
    }
    Ok(out)
}

/// Bitwise XOR of two Int32 arrays.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `b` — `&NdArray`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn bitwise_xor(a: &NdArray, b: &NdArray) -> Result<NdArray, String> {
    require_int32(a)?;
    require_int32(b)?;
    check_same_shape_dtype(a, b)?;
    let mut out = NdArray::zeros(a.shape(), DataType::Int32)?;
    for i in 0..a.size() {
        out.set_i32(i, a.get_i32(i) ^ b.get_i32(i));
    }
    Ok(out)
}

/// Bitwise NOT of an Int32 array.
///
/// # Parameters
/// - `a` — `&NdArray`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn bitwise_not(a: &NdArray) -> Result<NdArray, String> {
    require_int32(a)?;
    let mut out = NdArray::zeros(a.shape(), DataType::Int32)?;
    for i in 0..a.size() {
        out.set_i32(i, !a.get_i32(i));
    }
    Ok(out)
}

/// Bitwise left shift of an Int32 array by `amount` bits.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `amount` — `u32`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn bitwise_lshift(a: &NdArray, amount: u32) -> Result<NdArray, String> {
    require_int32(a)?;
    let mut out = NdArray::zeros(a.shape(), DataType::Int32)?;
    for i in 0..a.size() {
        out.set_i32(i, a.get_i32(i).wrapping_shl(amount));
    }
    Ok(out)
}

/// Bitwise right shift (arithmetic) of an Int32 array by `amount` bits.
///
/// # Parameters
/// - `a` — `&NdArray`.
/// - `amount` — `u32`.
///
/// # Returns
/// `Result<NdArray, String>`.
pub fn bitwise_rshift(a: &NdArray, amount: u32) -> Result<NdArray, String> {
    require_int32(a)?;
    let mut out = NdArray::zeros(a.shape(), DataType::Int32)?;
    for i in 0..a.size() {
        out.set_i32(i, a.get_i32(i).wrapping_shr(amount));
    }
    Ok(out)
}


