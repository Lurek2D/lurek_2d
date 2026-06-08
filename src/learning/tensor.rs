//! Lightweight tensor container with explicit row-major shape metadata and flat f32 data layout for CPU-based learning pipeline operations.
//! Supports multi-dimensional indexing through flat_index() with shape validation and zero-based coordinate conversion for safe element access.
//! Converts to tract Tensor format enabling interop with ONNX model inference engines for neural network evaluation on game tasks.
//! Provides flatten(), gemm() operations enabling tensor transformations and basic linear algebra needed by learning layer computations.

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
        Self { shape, data }
    }

    /// Create a zero-filled tensor for the given `shape`.
    pub fn zeros(shape: Vec<usize>) -> Self {
        let len = shape.iter().product();
        Self {
            shape,
            data: vec![0.0; len],
        }
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
        for (&i, &s) in indices.iter().zip(self.shape.iter()).rev() {
            if i >= s {
                return None;
            }
            idx += i * stride;
            stride *= s;
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
pub fn gemm(m: usize, k: usize, n: usize, a: &[f32], b: &[f32], bias: Option<&[f32]>) -> Vec<f32> {
    let mut out = vec![0.0; m * n];
    for i in 0..m {
        for j in 0..n {
            let mut sum = bias.map_or(0.0, |v| v[j]);
            for p in 0..k {
                sum += a[i * k + p] * b[p * n + j];
            }
            out[i * n + j] = sum;
        }
    }
    out
}
