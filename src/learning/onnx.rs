//! Provides ONNX model loading and inference by bridging `LurekTensor` data into tract runtimes. `learning/onnx` delivers the onnx implementation for the learning subsystem, giving agents the file-level map for what behavior, state, and boundaries live here.
//! Builds optimized runnable plans from ONNX files for CPU execution paths. The file owns or coordinates data contracts including `OnnxModel`, so readers can connect concrete Rust types to the feature responsibilities described by this module.
//! Converts input and output tensors between engine-native and tract-native representations. Public callable behavior is centered on no named public items, while method-level behavior such as `load`, `run`, `input_count`, `output_count` stays attached to the local data model and invariants.
//! Exposes deterministic inference entry points used by learning APIs without game-loop coupling. Runtime integration reaches sibling engine areas through crate modules `learning`, which explains the subsystem dependencies an agent should inspect before changing behavior.

use crate::learning::tensor::LurekTensor;
use tract_onnx::prelude::*;

/// Type alias for a runnable optimised tract ONNX plan.
type TractPlan = SimplePlan<TypedFact, Box<dyn TypedOp>, Graph<TypedFact, Box<dyn TypedOp>>>;

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
