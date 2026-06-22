//! Owns learning behavior with explicit state, validation, and crate-local integration boundaries.
//! Centers the implementation around LurekTensor, new, try_new, with helpers kept close to their invariants.
//! Defines how tensor data is validated, transformed, or stored before neighboring systems use it.
//! Owns learning behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on tensor behavior while Lua registration stays elsewhere.

use super::{
    error::LearningError,
    limits::{checked_product2, checked_tensor_elements, validate_non_zero_count, LearningLimits},
};
use ndarray::ArrayD;
use tract_onnx::prelude::{IntoTensor, Tensor};

/// Flat f32 tensor with explicit row-major shape metadata.
#[derive(Debug, Clone)]
pub struct LurekTensor {
    /// Dimension sizes in row-major order.
    pub shape: Vec<usize>,
    /// Flat element data in row-major order.
    pub data: Vec<f32>,
}

impl LurekTensor {
    /// Create a tensor with the given `shape` and flat `data`.
    pub fn new(shape: Vec<usize>, data: Vec<f32>) -> Self {
        Self::try_new(shape, data).expect("LurekTensor::new received invalid shape or data")
    }

    /// Create a tensor with the given `shape` and flat `data` after validation.
    pub fn try_new(shape: Vec<usize>, data: Vec<f32>) -> Result<Self, LearningError> {
        let expected = checked_tensor_elements(&shape, "tensor shape", &LearningLimits::default())?;
        if data.len() != expected {
            return Err(LearningError::ShapeDataLenMismatch {
                expected,
                actual: data.len(),
            });
        }
        for &value in &data {
            if !value.is_finite() {
                return Err(LearningError::InvalidFloat {
                    field: "tensor data",
                    value: value as f64,
                });
            }
        }
        Ok(Self { shape, data })
    }

    /// Create a zero-filled tensor for the given `shape`.
    pub fn zeros(shape: Vec<usize>) -> Self {
        Self::try_zeros(shape).expect("LurekTensor::zeros received invalid shape")
    }

    /// Create a zero-filled tensor for the given `shape` after validation.
    pub fn try_zeros(shape: Vec<usize>) -> Result<Self, LearningError> {
        let len = checked_tensor_elements(&shape, "tensor shape", &LearningLimits::default())?;
        Ok(Self {
            shape,
            data: vec![0.0; len],
        })
    }

    /// Create a tensor without validating the shape or data invariants.
    pub(crate) fn new_unchecked(shape: Vec<usize>, data: Vec<f32>) -> Self {
        Self { shape, data }
    }

    /// Returns the total number of tensor elements.
    pub fn len(&self) -> usize {
        self.data.len()
    }

    /// True when there are no elements.
    pub fn is_empty(&self) -> bool {
        self.data.is_empty()
    }

    /// Return the element at the given multi-dimensional indices (zero-based, row-major).
    pub fn get_element(&self, indices: &[usize]) -> Option<f32> {
        self.data.get(self.flat_index(indices)?).copied()
    }

    /// Convert multi-dimensional zero-based indices to a flat row-major offset.
    pub fn flat_index(&self, indices: &[usize]) -> Option<usize> {
        if indices.len() != self.shape.len() {
            return None;
        }
        let mut idx = 0usize;
        let mut stride = 1usize;
        for (axis, (&i, &s)) in indices.iter().zip(self.shape.iter()).enumerate().rev() {
            if s == 0 {
                return None;
            }
            if i >= s {
                return None;
            }
            idx = idx.checked_add(i.checked_mul(stride)?)?;
            stride = stride.checked_mul(s)?;
            if axis == 0 && idx >= self.data.len() {
                return None;
            }
        }
        Some(idx)
    }

    /// Return a flattened copy with shape `[len]`.
    pub fn flatten(&self) -> Self {
        Self {
            shape: vec![self.data.len()],
            data: self.data.clone(),
        }
    }

    /// Build a tract `Tensor` from this handle for use as a model input.
    pub fn to_tract_tensor(&self) -> Result<Tensor, String> {
        let arr = ArrayD::<f32>::from_shape_vec(self.shape.clone(), self.data.clone())
            .map_err(|e| e.to_string())?;
        Ok(arr.into_tensor())
    }
}

/// Multiply matrix A `[m x k]` by matrix B `[k x n]` and optionally add a bias `[n]`.
pub fn try_gemm(
    m: usize,
    k: usize,
    n: usize,
    a: &[f32],
    b: &[f32],
    bias: Option<&[f32]>,
) -> Result<Vec<f32>, LearningError> {
    let limits = LearningLimits::default();
    validate_non_zero_count("gemm rows", m)?;
    validate_non_zero_count("gemm inner dimension", k)?;
    validate_non_zero_count("gemm columns", n)?;
    let a_expected = checked_product2(m, k, "gemm left matrix", limits.max_tensor_elements)?;
    let b_expected = checked_product2(k, n, "gemm right matrix", limits.max_tensor_elements)?;
    let out_len = checked_product2(m, n, "gemm output matrix", limits.max_tensor_elements)?;
    if a.len() != a_expected {
        return Err(LearningError::InvalidLength {
            context: "gemm left matrix",
            expected: a_expected,
            actual: a.len(),
        });
    }
    if b.len() != b_expected {
        return Err(LearningError::InvalidLength {
            context: "gemm right matrix",
            expected: b_expected,
            actual: b.len(),
        });
    }
    if let Some(values) = bias {
        if values.len() != n {
            return Err(LearningError::InvalidLength {
                context: "gemm bias",
                expected: n,
                actual: values.len(),
            });
        }
    }
    let mut out = vec![0.0; out_len];
    for i in 0..m {
        for j in 0..n {
            let mut sum = bias.map_or(0.0, |v| v[j]);
            for p in 0..k {
                sum += a[i * k + p] * b[p * n + j];
            }
            out[i * n + j] = sum;
        }
    }
    Ok(out)
}

/// Multiply matrix A `[m x k]` by matrix B `[k x n]` and optionally add a bias `[n]`.
pub fn gemm(m: usize, k: usize, n: usize, a: &[f32], b: &[f32], bias: Option<&[f32]>) -> Vec<f32> {
    try_gemm(m, k, n, a, b, bias).expect("gemm received invalid matrix dimensions")
}
