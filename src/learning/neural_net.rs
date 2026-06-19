//! This file owns dense feed-forward networks, including activations, layer storage, and ordered network assembly.
//! `NeuralLayer` stores row-major weights and biases, while `Activation` centralizes the elementwise output transforms.
//! Layer-by-layer forward propagation lives here because dense inference and softmax handling define this model family.
//! Flat parameter import and export also live here so optimizers and neuroevolution can rebuild dense models.
//! `NeuralNet` owns layer ordering and whole-network weight packing, not exploration policy, tensors, or sequence state.
//! Open it when dense-model behavior changes; recurrent, convolutional, and attention-based blocks live in sibling files.

use crate::learning::{
    error::LearningError,
    limits::{
        checked_product2, enforce_limit, validate_finite, validate_non_zero_count, LearningLimits,
    },
    EvolutionaryLayer,
};

/// Activation function used by a layer.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Activation {
    /// Rectified linear unit.
    ReLU,
    /// Logistic sigmoid.
    Sigmoid,
    /// Hyperbolic tangent.
    Tanh,
    /// No activation.
    Linear,
    /// Softmax over the output vector.
    Softmax,
}
impl Activation {
    #[allow(clippy::should_implement_trait)]
    /// Parse a lowercase activation name; unknown strings map to `Linear`.
    pub fn from_str(s: &str) -> Self {
        match s.to_lowercase().as_str() {
            "relu" => Self::ReLU,
            "sigmoid" => Self::Sigmoid,
            "tanh" => Self::Tanh,
            "softmax" => Self::Softmax,
            _ => Self::Linear,
        }
    }
    /// Return the canonical activation name.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::ReLU => "relu",
            Self::Sigmoid => "sigmoid",
            Self::Tanh => "tanh",
            Self::Linear => "linear",
            Self::Softmax => "softmax",
        }
    }
    /// Apply the activation in place to `v`.
    pub fn apply(self, v: &mut [f32]) {
        let _ = self.try_apply(v);
    }

    /// Apply the activation in place to `v`, returning an error for invalid numeric inputs.
    pub fn try_apply(self, v: &mut [f32]) -> Result<(), LearningError> {
        for &value in v.iter() {
            validate_finite("activation input", value as f64)?;
        }
        match self {
            Self::ReLU => {
                for x in v.iter_mut() {
                    if *x < 0.0 {
                        *x = 0.0;
                    }
                }
            }
            Self::Sigmoid => {
                for x in v.iter_mut() {
                    *x = 1.0 / (1.0 + (-*x).exp());
                }
            }
            Self::Tanh => {
                for x in v.iter_mut() {
                    *x = x.tanh();
                }
            }
            Self::Linear => {}
            Self::Softmax => {
                if v.is_empty() {
                    return Ok(());
                }
                let max = v.iter().cloned().fold(f32::NEG_INFINITY, f32::max);
                validate_finite("softmax max", max as f64)?;
                let mut sum = 0.0f32;
                for &x in v.iter() {
                    sum += (x - max).exp();
                }
                validate_finite("softmax sum", sum as f64)?;
                if sum <= 0.0 {
                    return Err(LearningError::ValueOutOfRange {
                        field: "softmax sum",
                        min: f64::EPSILON,
                        max: f64::INFINITY,
                        value: sum as f64,
                    });
                }
                for x in v.iter_mut() {
                    *x = (*x - max).exp() / sum;
                    validate_finite("softmax output", *x as f64)?;
                }
            }
        }
        Ok(())
    }
}
/// Dense layer with row-major weights and per-output biases.
pub struct NeuralLayer {
    /// Number of input units.
    pub inputs: usize,
    /// Number of output units.
    pub outputs: usize,
    /// Weight matrix stored row-major by output.
    pub weights: Vec<f32>,
    /// Bias per output unit.
    pub biases: Vec<f32>,
    /// Layer activation.
    pub activation: Activation,
}
impl NeuralLayer {
    /// Create a zeroed dense layer. This function is part of the public API.
    pub fn new(inputs: usize, outputs: usize, activation: Activation) -> Self {
        Self::try_new(inputs, outputs, activation)
            .expect("NeuralLayer::new received invalid dimensions")
    }

    /// Create a zeroed dense layer after validating dimensions and parameter budgets.
    pub fn try_new(
        inputs: usize,
        outputs: usize,
        activation: Activation,
    ) -> Result<Self, LearningError> {
        validate_non_zero_count("layer inputs", inputs)?;
        validate_non_zero_count("layer outputs", outputs)?;
        let limits = LearningLimits::default();
        let weight_count =
            checked_product2(inputs, outputs, "dense layer weights", limits.max_params)?;
        let total_params =
            weight_count
                .checked_add(outputs)
                .ok_or(LearningError::CountOverflow {
                    context: "dense layer parameters",
                })?;
        enforce_limit("dense layer parameters", total_params, limits.max_params)?;
        Ok(Self {
            inputs,
            outputs,
            weights: vec![0.0; weight_count],
            biases: vec![0.0; outputs],
            activation,
        })
    }

    fn validate_parameters(&self) -> Result<(), LearningError> {
        let expected_weights = checked_product2(
            self.inputs,
            self.outputs,
            "dense layer weights",
            LearningLimits::default().max_params,
        )?;
        if self.weights.len() != expected_weights {
            return Err(LearningError::InvalidLength {
                context: "dense layer weights",
                expected: expected_weights,
                actual: self.weights.len(),
            });
        }
        if self.biases.len() != self.outputs {
            return Err(LearningError::InvalidLength {
                context: "dense layer biases",
                expected: self.outputs,
                actual: self.biases.len(),
            });
        }
        for &value in self.weights.iter().chain(self.biases.iter()) {
            validate_finite("dense layer parameter", value as f64)?;
        }
        Ok(())
    }

    /// Return the number of learnable parameters in the layer.
    pub fn param_count(&self) -> usize {
        self.inputs * self.outputs + self.outputs
    }

    #[allow(clippy::needless_range_loop)]
    /// Compute the layer output for `input`.
    pub fn forward(&self, input: &[f32]) -> Vec<f32> {
        self.try_forward(input)
            .expect("NeuralLayer::forward received invalid input or parameters")
    }

    #[allow(clippy::needless_range_loop)]
    /// Compute the layer output for `input`, returning validation errors instead of panicking.
    pub fn try_forward(&self, input: &[f32]) -> Result<Vec<f32>, LearningError> {
        self.validate_parameters()?;
        if input.len() != self.inputs {
            return Err(LearningError::InvalidLength {
                context: "dense layer input",
                expected: self.inputs,
                actual: input.len(),
            });
        }
        for &value in input {
            validate_finite("dense layer input", value as f64)?;
        }
        let mut out = vec![0.0f32; self.outputs];
        for o in 0..self.outputs {
            let mut sum = self.biases[o];
            for i in 0..self.inputs {
                sum += self.weights[o * self.inputs + i] * input[i];
            }
            out[o] = sum;
            validate_finite("dense layer output", sum as f64)?;
        }
        self.activation.try_apply(&mut out)?;
        Ok(out)
    }
}

impl EvolutionaryLayer for NeuralLayer {
    fn param_count(&self) -> usize {
        NeuralLayer::param_count(self)
    }

    fn set_weights(&mut self, weights: &[f32]) -> bool {
        if weights.len() != self.param_count() {
            return false;
        }

        let w_count = self.inputs * self.outputs;
        self.weights.copy_from_slice(&weights[..w_count]);
        self.biases.copy_from_slice(&weights[w_count..]);
        true
    }

    fn get_weights(&self) -> Vec<f32> {
        let mut out = Vec::with_capacity(self.param_count());
        out.extend_from_slice(&self.weights);
        out.extend_from_slice(&self.biases);
        out
    }
}
/// Ordered stack of dense layers.
#[derive(Default)]
pub struct NeuralNet {
    /// Layer list from input to output.
    layers: Vec<NeuralLayer>,
}
impl NeuralNet {
    /// Create an empty neural net. This function is part of the public API.
    pub fn new() -> Self {
        Self::default()
    }
    /// Append a new dense layer. This function is part of the public API.
    pub fn add_layer(&mut self, inputs: usize, outputs: usize, activation: Activation) {
        self.try_add_layer(inputs, outputs, activation)
            .expect("NeuralNet::add_layer received invalid layer dimensions");
    }

    /// Append a new dense layer after validating dimensions, topology, and parameter budgets.
    pub fn try_add_layer(
        &mut self,
        inputs: usize,
        outputs: usize,
        activation: Activation,
    ) -> Result<(), LearningError> {
        let limits = LearningLimits::default();
        enforce_limit(
            "neural net layers",
            self.layers.len() + 1,
            limits.max_layers,
        )?;
        if let Some(previous) = self.layers.last() {
            if previous.outputs != inputs {
                return Err(LearningError::TopologyMismatch {
                    layer_index: self.layers.len(),
                    previous_outputs: previous.outputs,
                    current_inputs: inputs,
                });
            }
        }
        let layer = NeuralLayer::try_new(inputs, outputs, activation)?;
        let projected_params = self.param_count().checked_add(layer.param_count()).ok_or(
            LearningError::CountOverflow {
                context: "neural net parameters",
            },
        )?;
        enforce_limit("neural net parameters", projected_params, limits.max_params)?;
        self.layers.push(layer);
        Ok(())
    }
    /// Return the total number of learnable parameters.
    pub fn param_count(&self) -> usize {
        self.layers.iter().map(|l| l.param_count()).sum()
    }
    /// Run a forward pass through all layers.
    pub fn forward(&self, input: &[f32]) -> Vec<f32> {
        self.try_forward(input)
            .expect("NeuralNet::forward received invalid input or topology")
    }

    /// Validate adjacent layer compatibility before inference.
    pub fn validate_topology(&self) -> Result<(), LearningError> {
        for (idx, pair) in self.layers.windows(2).enumerate() {
            if pair[0].outputs != pair[1].inputs {
                return Err(LearningError::TopologyMismatch {
                    layer_index: idx + 1,
                    previous_outputs: pair[0].outputs,
                    current_inputs: pair[1].inputs,
                });
            }
        }
        Ok(())
    }

    /// Run a forward pass through all layers, returning validation errors instead of panicking.
    pub fn try_forward(&self, input: &[f32]) -> Result<Vec<f32>, LearningError> {
        self.validate_topology()?;
        let mut buf: Vec<f32> = input.to_vec();
        for layer in &self.layers {
            buf = layer.try_forward(&buf)?;
        }
        Ok(buf)
    }
    /// Load flattened weights and biases; returns `false` when the shape mismatches.
    pub fn set_weights(&mut self, weights: &[f32]) -> bool {
        if weights.len() != self.param_count() {
            return false;
        }
        let mut offset = 0;
        for layer in &mut self.layers {
            let w_count = layer.inputs * layer.outputs;
            layer
                .weights
                .copy_from_slice(&weights[offset..offset + w_count]);
            offset += w_count;
            layer
                .biases
                .copy_from_slice(&weights[offset..offset + layer.outputs]);
            offset += layer.outputs;
        }
        true
    }
    /// Return the flattened weights and biases.
    pub fn get_weights(&self) -> Vec<f32> {
        let mut out = Vec::with_capacity(self.param_count());
        for layer in &self.layers {
            out.extend_from_slice(&layer.weights);
            out.extend_from_slice(&layer.biases);
        }
        out
    }
    /// Return the number of layers. This function is part of the public API.
    pub fn layer_count(&self) -> usize {
        self.layers.len()
    }
}
