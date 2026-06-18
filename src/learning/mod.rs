//! This module is the learning index, wiring tensors, dense and sequence layers, optimizers, and model adapters.
//! It reexports neural, recurrent, convolutional, attention, and transformer owners from one subsystem entry point.
//! `tensor.rs` owns row-major data carriers, while `evolutionary.rs` defines the flat-parameter contract shared by layers.
//! `neural_net.rs`, `recurrent.rs`, `conv.rs`, and `attention.rs` implement CPU learning blocks with trainable weights.
//! `transformer.rs` composes attention, norms, and feed-forward blocks, while `engine.rs` chains heterogeneous blocks.
//! `genetic.rs`, `neuroevolution.rs`, `bandit.rs`, and `qlearner.rs` cover search and reinforcement loops.
//! `onnx.rs` bridges external models, and `env.rs` plus `tensor.rs` define the data surfaces consumed by these learners.
//! This file owns visibility and navigation only; actual math, training state, and inference behavior live in siblings.

/// Attention primitives for sequence models.
pub mod attention;
/// Multi-armed bandit strategies and statistics.
pub mod bandit;
/// Convolution and pooling learning layers.
pub mod conv;
/// Heterogeneous neural engine with flat genome packing.
pub mod engine;
/// Gym-compatible RL environment wrappers.
pub mod env;
/// Flat parameter contract for evolutionary layers.
pub mod evolutionary;
/// Genetic algorithm primitives.
pub mod genetic;
/// Feed-forward neural network helpers.
pub mod neural_net;
/// Neuroevolution orchestration.
pub mod neuroevolution;
/// ONNX model loading and inference.
pub mod onnx;
/// Reinforcement learning with a tabular Q-learner.
pub mod qlearner;
/// Recurrent learning layers.
pub mod recurrent;
/// Lightweight tensor helpers.
pub mod tensor;
/// Transformer encoder and decoder blocks.
pub mod transformer;

pub use attention::{MultiHeadAttention, PositionalEncoding};
pub use bandit::{Bandit, BanditArm, BanditStrategy};
pub use conv::{Conv2D, MaxPool2D};
pub use engine::{LurekNeuralEngine, NeuralBlock};
pub use env::{FrameStack, SpaceSpec};
pub use evolutionary::EvolutionaryLayer;
pub use genetic::{Chromosome, GeneticAlgorithm};
pub use neural_net::{Activation, NeuralLayer, NeuralNet};
pub use neuroevolution::Neuroevolution;
pub use onnx::OnnxModel;
pub use qlearner::QLearner;
pub use recurrent::{GruLayer, LstmLayer};
pub use tensor::{gemm, LurekTensor};
pub use transformer::{LayerNorm, TransformerDecoderBlock, TransformerEncoderBlock};
