//! Owns the onnx owner for the learning subsystem and keeps its rules local to this file while keeping call sites explicit.
//! Centers the implementation around TractPlan, OnnxLoadOptions, default, with helpers kept close to their invariants.
//! Defines how onnx data is validated, transformed, or stored before neighboring systems use it.
//! Owns learning behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on onnx behavior while Lua registration stays elsewhere.
//! Documents the boundary where learning code accepts inputs, reports errors, or updates state.

use crate::learning::{
    error::LearningError,
    limits::{checked_tensor_elements, enforce_limit, LearningLimits},
    tensor::LurekTensor,
};
use std::{
    fs,
    path::{Path, PathBuf},
};
use tract_onnx::prelude::*;

/// Type alias for a runnable optimised tract ONNX plan.
type TractPlan = SimplePlan<TypedFact, Box<dyn TypedOp>, Graph<TypedFact, Box<dyn TypedOp>>>;

/// Safe loading options for ONNX models.
#[derive(Debug, Clone)]
pub struct OnnxLoadOptions {
    /// Canonical sandbox root for allowed ONNX model files.
    pub sandbox_root: Option<PathBuf>,
    /// Maximum file bytes allowed for a single ONNX model.
    pub max_file_bytes: u64,
    /// Maximum number of input tensors allowed by the loaded model.
    pub max_input_tensors: usize,
    /// Maximum number of output tensors allowed by the loaded model.
    pub max_output_tensors: usize,
    /// Maximum elements allowed in one output tensor returned from inference.
    pub max_output_elements: usize,
}

impl Default for OnnxLoadOptions {
    fn default() -> Self {
        let limits = LearningLimits::default();
        Self {
            sandbox_root: std::env::current_dir().ok(),
            max_file_bytes: limits.max_onnx_file_bytes,
            max_input_tensors: limits.max_onnx_inputs,
            max_output_tensors: limits.max_onnx_outputs,
            max_output_elements: limits.max_onnx_output_elements,
        }
    }
}

/// Loaded and optimised ONNX model wrapped around a tract runnable plan.
pub struct OnnxModel {
    /// Runnable tract inference plan produced after optimisation.
    plan: TractPlan,
    /// Number of input tensors the model expects.
    input_count: usize,
    /// Number of output tensors the model produces.
    output_count: usize,
    /// Maximum elements allowed in one returned output tensor.
    max_output_elements: usize,
}

impl OnnxModel {
    /// Load an ONNX model from `path`, optimise it, and return a runnable handle.
    ///
    /// Returns `Err(String)` if the file is missing, malformed, outside the sandbox, or optimisation fails.
    pub fn load(path: &str) -> Result<Self, String> {
        Self::load_with_options(path, &OnnxLoadOptions::default()).map_err(|e| e.to_string())
    }

    /// Load an ONNX model from `path` using explicit safety limits and sandbox settings.
    pub fn load_with_options(path: &str, options: &OnnxLoadOptions) -> Result<Self, LearningError> {
        let canonical_path = canonicalize_model_path(path, options)?;
        let metadata = fs::metadata(&canonical_path).map_err(|_| LearningError::InvalidLength {
            context: "ONNX file metadata",
            expected: 1,
            actual: 0,
        })?;
        if metadata.len() > options.max_file_bytes {
            return Err(LearningError::FileTooLarge {
                path: canonical_path.display().to_string(),
                bytes: metadata.len(),
                max_bytes: options.max_file_bytes,
            });
        }

        let plan = tract_onnx::onnx()
            .model_for_path(&canonical_path)
            .map_err(|e| LearningError::External {
                context: "ONNX load",
                detail: e.to_string(),
            })?
            .into_optimized()
            .map_err(|e| LearningError::External {
                context: "ONNX optimize",
                detail: e.to_string(),
            })?
            .into_runnable()
            .map_err(|e| LearningError::External {
                context: "ONNX runnable",
                detail: e.to_string(),
            })?;
        let input_count = plan
            .model()
            .input_outlets()
            .map_err(|e| LearningError::External {
                context: "ONNX input query",
                detail: e.to_string(),
            })?
            .len();
        let output_count = plan
            .model()
            .output_outlets()
            .map_err(|e| LearningError::External {
                context: "ONNX output query",
                detail: e.to_string(),
            })?
            .len();
        enforce_limit("ONNX input tensors", input_count, options.max_input_tensors)?;
        enforce_limit(
            "ONNX output tensors",
            output_count,
            options.max_output_tensors,
        )?;
        Ok(Self {
            plan,
            input_count,
            output_count,
            max_output_elements: options.max_output_elements,
        })
    }

    /// Run inference on `inputs`, returning one `LurekTensor` per model output.
    ///
    /// Output shapes are read from the tract tensor; data is always cast to `f32`.
    /// Returns `Err(String)` if the input count mismatches or inference fails.
    pub fn run(&self, inputs: Vec<LurekTensor>) -> Result<Vec<LurekTensor>, String> {
        self.try_run(inputs).map_err(|e| e.to_string())
    }

    /// Run inference on `inputs`, returning one `LurekTensor` per model output.
    pub fn try_run(&self, inputs: Vec<LurekTensor>) -> Result<Vec<LurekTensor>, LearningError> {
        if inputs.len() != self.input_count {
            return Err(LearningError::InputCountMismatch {
                expected: self.input_count,
                actual: inputs.len(),
            });
        }
        let tvec: TVec<TValue> = inputs
            .into_iter()
            .map(|t| t.to_tract_tensor().map(TValue::from))
            .collect::<Result<TVec<_>, _>>()
            .map_err(|e| LearningError::External {
                context: "ONNX input tensor conversion",
                detail: e.to_string(),
            })?;
        let outputs = self.plan.run(tvec).map_err(|e| LearningError::External {
            context: "ONNX inference",
            detail: e.to_string(),
        })?;
        outputs
            .iter()
            .enumerate()
            .map(|(index, output)| {
                let shape = output.shape().to_vec();
                let output_limits = LearningLimits {
                    max_tensor_elements: self.max_output_elements,
                    ..LearningLimits::default()
                };
                let expected =
                    checked_tensor_elements(&shape, "ONNX output tensor", &output_limits)?;
                let data = output
                    .as_slice::<f32>()
                    .map(|slice| slice.to_vec())
                    .map_err(|e| LearningError::External {
                        context: "ONNX output tensor type",
                        detail: format!("output {} is not f32-compatible: {}", index, e),
                    })?;
                if data.len() != expected {
                    return Err(LearningError::InvalidLength {
                        context: "ONNX output tensor data",
                        expected,
                        actual: data.len(),
                    });
                }
                Ok(LurekTensor::new_unchecked(shape, data))
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

fn canonicalize_model_path(
    path: &str,
    options: &OnnxLoadOptions,
) -> Result<PathBuf, LearningError> {
    let canonical_path = fs::canonicalize(path).map_err(|_| LearningError::InvalidLength {
        context: "ONNX path",
        expected: 1,
        actual: 0,
    })?;
    if let Some(root) = &options.sandbox_root {
        let canonical_root = canonicalize_root(root)?;
        if !canonical_path.starts_with(&canonical_root) {
            return Err(LearningError::SandboxViolation {
                path: canonical_path.display().to_string(),
                root: canonical_root.display().to_string(),
            });
        }
    }
    Ok(canonical_path)
}

fn canonicalize_root(root: &Path) -> Result<PathBuf, LearningError> {
    fs::canonicalize(root).map_err(|_| LearningError::InvalidLength {
        context: "ONNX sandbox root",
        expected: 1,
        actual: 0,
    })
}
