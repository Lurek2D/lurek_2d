//! High-level learning module that aggregates neural, evolutionary, and reinforcement components. `learning/mod` is the learning module index, declaring `attention`, `bandit`, `conv`, `engine`, `env`, and 9 more so agents can identify which files own each feature slice before opening implementation code.
//! Re-exports core model, optimizer, tensor, and environment types for unified caller access. `src/learning/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `attention::{MultiHeadAttention, PositionalEncoding}`, `bandit::{Bandit, BanditArm, BanditStrategy}`, `conv::{Conv2D, MaxPool2D}`, `engine::{LurekNeuralEngine, NeuralBlock}`, and 10 more centralized for the learning subsystem.
//! Connects lightweight CPU learning primitives with optional ONNX inference capabilities. The file documents how learning submodules compose into one engine surface, with module declarations separating storage, behavior, rendering, and Lua-facing integration points.
//! Defines the integration layer for experimentation-oriented training and decision systems. Agents should read this index to choose the narrow owner file first, because it maps names such as `attention`, `bandit`, `conv`, `engine`, `env`, and 9 more to concrete implementation responsibilities.
//! `learning/mod` is the learning module index, declaring `attention`, `bandit`, `conv`, `engine`, `env`, and 9 more so agents can identify which files own each feature slice before opening implementation code.
//! `src/learning/mod.rs` owns visibility and re-export boundaries rather than runtime state, keeping public access through `attention::{MultiHeadAttention, PositionalEncoding}`, `bandit::{Bandit, BanditArm, BanditStrategy}`, `conv::{Conv2D, MaxPool2D}`, `engine::{LurekNeuralEngine, NeuralBlock}`, and 10 more centralized for the learning subsystem.

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
