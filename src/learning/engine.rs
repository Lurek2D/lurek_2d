//! Defines a dynamic neural engine that chains heterogeneous learning blocks in one runtime graph.
//! Hosts dense, convolutional, recurrent, and transformer-like components behind a unified interface.
//! Packs and unpacks flat parameter buffers so composite models work with evolutionary optimizers.
//! Executes staged forward passes through configured block sequences on shared tensor carriers.
//! Serves as the composition hub for mixed-architecture experimentation in the learning module.

use crate::learning::{
    Conv2D, EvolutionaryLayer, GruLayer, LstmLayer, MaxPool2D, NeuralLayer, TransformerDecoderBlock,
    TransformerEncoderBlock,
};

/// Supported functional blocks for `LurekNeuralEngine`.
pub enum NeuralBlock {
    /// Dense layer.
    Dense(NeuralLayer),
    /// 2D convolution.
    Conv2D(Conv2D),
    /// 2D max pooling (no trainable parameters).
    MaxPool2D(MaxPool2D),
    /// LSTM recurrent layer.
    Lstm(LstmLayer),
    /// GRU recurrent layer.
    Gru(GruLayer),
    /// Transformer encoder block.
    TransformerEncoder(Box<TransformerEncoderBlock>),
    /// Transformer decoder block.
    TransformerDecoder(Box<TransformerDecoderBlock>),
}

impl NeuralBlock {
    /// Trainable parameter count for this block.
    pub fn param_count(&self) -> usize {
        match self {
            Self::Dense(layer) => layer.param_count(),
            Self::Conv2D(layer) => layer.param_count(),
            Self::MaxPool2D(_) => 0,
            Self::Lstm(layer) => layer.param_count(),
            Self::Gru(layer) => layer.param_count(),
            Self::TransformerEncoder(block) => block.param_count(),
            Self::TransformerDecoder(block) => block.param_count(),
        }
    }

    /// Load trainable parameters for this block.
    pub fn set_weights(&mut self, weights: &[f32]) -> bool {
        match self {
            Self::Dense(layer) => layer.set_weights(weights),
            Self::Conv2D(layer) => layer.set_weights(weights),
            Self::MaxPool2D(_) => weights.is_empty(),
            Self::Lstm(layer) => layer.set_weights(weights),
            Self::Gru(layer) => layer.set_weights(weights),
            Self::TransformerEncoder(block) => block.set_weights(weights),
            Self::TransformerDecoder(block) => block.set_weights(weights),
        }
    }

    /// Export trainable parameters for this block.
    pub fn get_weights(&self) -> Vec<f32> {
        match self {
            Self::Dense(layer) => layer.get_weights(),
            Self::Conv2D(layer) => layer.get_weights(),
            Self::MaxPool2D(_) => Vec::new(),
            Self::Lstm(layer) => layer.get_weights(),
            Self::Gru(layer) => layer.get_weights(),
            Self::TransformerEncoder(block) => block.get_weights(),
            Self::TransformerDecoder(block) => block.get_weights(),
        }
    }
}

/// Heterogeneous neural graph with deterministic flat-parameter packing.
#[derive(Default)]
pub struct LurekNeuralEngine {
    blocks: Vec<NeuralBlock>,
}

impl LurekNeuralEngine {
    /// Create an empty engine.
    pub fn new() -> Self {
        Self::default()
    }

    /// Append one block.
    pub fn add_block(&mut self, block: NeuralBlock) {
        self.blocks.push(block);
    }

    /// Immutable block access.
    pub fn blocks(&self) -> &[NeuralBlock] {
        &self.blocks
    }

    /// Mutable block access.
    pub fn blocks_mut(&mut self) -> &mut [NeuralBlock] {
        &mut self.blocks
    }

    /// Number of blocks in the engine.
    pub fn block_count(&self) -> usize {
        self.blocks.len()
    }

    /// Total trainable parameter count across all blocks.
    pub fn param_count(&self) -> usize {
        self.blocks.iter().map(NeuralBlock::param_count).sum()
    }

    /// Load a flat parameter buffer and split it across blocks in insertion order.
    pub fn set_weights(&mut self, weights: &[f32]) -> bool {
        if weights.len() != self.param_count() {
            return false;
        }

        let mut offset = 0usize;
        for block in &mut self.blocks {
            let count = block.param_count();
            let slice = &weights[offset..offset + count];
            if !block.set_weights(slice) {
                return false;
            }
            offset += count;
        }
        true
    }

    /// Export all trainable parameters in block insertion order.
    pub fn get_weights(&self) -> Vec<f32> {
        let mut out = Vec::with_capacity(self.param_count());
        for block in &self.blocks {
            out.extend_from_slice(&block.get_weights());
        }
        out
    }
}
