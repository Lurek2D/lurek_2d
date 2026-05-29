//! ONNX model loading and inference via tract-onnx.
//!
//! - Provides `OnnxModel` which loads and optimises an ONNX file into a runnable plan.
//! - Provides `LurekTensor` which holds a flat f32 buffer with explicit shape metadata.
//! - `OnnxModel::run` converts `LurekTensor` inputs to tract `Tensor` values, runs the
//!   plan, and converts outputs back to `LurekTensor`, preserving output shapes.
//! - `LurekTensor::to_tract_tensor` builds a row-major `ndarray::ArrayD<f32>` and converts
//!   it to a tract `Tensor` using the standard `From` implementation.
//! - Used exclusively by `src/lua_api/learning_api.rs`; no game-loop dependencies.

use ndarray::ArrayD;
use tract_onnx::prelude::*;

/// Type alias for a runnable optimised tract ONNX plan.
type TractPlan =
    SimplePlan<TypedFact, Box<dyn TypedOp>, Graph<TypedFact, Box<dyn TypedOp>>>;

/// Loaded and optimised ONNX model wrapped around a tract runnable plan.
pub struct OnnxModel {
    /// Runnable tract inference plan produced after optimisation.
    plan: TractPlan,
    /// Number of input tensors the model expects.
    input_count: usize,
    /// Number of output tensors the model produces.
    output_count: usize,
}

impl OnnxModel {
    /// Load an ONNX model from `path`, optimise it, and return a runnable handle.
    ///
    /// Returns `Err(String)` if the file is missing, malformed, or optimisation fails.
    pub fn load(path: &str) -> Result<Self, String> {
        let plan = tract_onnx::onnx()
            .model_for_path(path)
            .map_err(|e| e.to_string())?
            .into_optimized()
            .map_err(|e| e.to_string())?
            .into_runnable()
            .map_err(|e| e.to_string())?;
        let input_count = plan
            .model()
            .input_outlets()
            .map_err(|e| e.to_string())?
            .len();
        let output_count = plan
            .model()
            .output_outlets()
            .map_err(|e| e.to_string())?
            .len();
        Ok(Self {
            plan,
            input_count,
            output_count,
        })
    }

    /// Run inference on `inputs`, returning one `LurekTensor` per model output.
    ///
    /// Output shapes are read from the tract tensor; data is always cast to `f32`.
    /// Returns `Err(String)` if the input count mismatches or inference fails.
    pub fn run(&self, inputs: Vec<LurekTensor>) -> Result<Vec<LurekTensor>, String> {
        let tvec: TVec<TValue> = inputs
            .into_iter()
            .map(|t| t.to_tract_tensor().map(TValue::from))
            .collect::<Result<TVec<_>, _>>()?;
        let outputs = self.plan.run(tvec).map_err(|e| e.to_string())?;
        outputs
            .iter()
            .map(|o| {
                let shape = o.shape().to_vec();
                let data = o
                    .as_slice::<f32>()
                    .map(|s| s.to_vec())
                    .map_err(|e| e.to_string())?;
                Ok(LurekTensor::new(shape, data))
            })
            .collect()
    }

    /// Number of input tensors expected by the model.
    pub fn input_count(&self) -> usize {
        self.input_count
    }

    /// Number of output tensors produced by the model.
    pub fn output_count(&self) -> usize {
        self.output_count
    }
}

/// Flat f32 tensor with explicit shape metadata.
///
/// Shapes use row-major (C) order. Indexing via `get_element` accepts one index per
/// dimension. Used both as input to `OnnxModel::run` and as output from it.
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

    /// Returns the total number of tensor elements.
    pub fn len(&self) -> usize {
        self.data.len()
    }

    /// True when there are no elements.
    pub fn is_empty(&self) -> bool {
        self.data.is_empty()
    }

    /// Return the element at the given multi-dimensional indices (zero-based, row-major).
    ///
    /// Returns `None` if `indices` has the wrong rank or any index is out of range.
    pub fn get_element(&self, indices: &[usize]) -> Option<f32> {
        self.data.get(self.flat_index(indices)?).copied()
    }

    /// Convert multi-dimensional zero-based indices to a flat row-major offset.
    fn flat_index(&self, indices: &[usize]) -> Option<usize> {
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

    /// Build a tract `Tensor` from this handle for use as a model input.
    pub fn to_tract_tensor(&self) -> Result<Tensor, String> {
        let arr = ArrayD::<f32>::from_shape_vec(self.shape.clone(), self.data.clone())
            .map_err(|e| e.to_string())?;
        Ok(arr.into_tensor())
    }
}
