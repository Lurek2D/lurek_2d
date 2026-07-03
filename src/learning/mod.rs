//! This module re-exports learning surface for `attention.rs`, `bandit.rs`, `conv.rs`, and `engine.rs` and runtime helpers.
//! It keeps navigation explicit by showing which sibling files own state, validation, transport, or render behavior.
//! Public exports here route callers toward `attention.rs`, `bandit.rs`, and `conv.rs` first, while deeper behavior owners.
//! Open this file when the public learning symbol map moves; edit siblings when runtime rules themselves change.
//! This index exists to organize entrypoints, not to absorb the state, caches, or algorithms its children own.
//! Use neighboring owners for behavioral fixes, and keep this file limited to exports, docs, and navigation.
//! Reexports here help agents find right module quickly when changes touch `attention.rs`, `bandit.rs`, subsystem.
//! Keep concrete logic in `attention.rs`, `bandit.rs`, and `conv.rs` so symbol lookup stays shallow.

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
/// Shared learning validation and safety errors.
pub mod error;
/// Flat parameter contract for evolutionary layers.
pub mod evolutionary;
/// Genetic algorithm primitives.
pub mod genetic;
/// Shared learning sizing and numeric policy helpers.
pub mod limits;
/// Feed-forward neural network helpers.
pub mod neural_net;
/// Neuroevolution orchestration.
pub mod neuroevolution;
/// Reinforcement learning with a tabular Q-learner.
pub mod qlearner;
/// Recurrent learning layers.
pub mod recurrent;
/// Deterministic RNG shared by learning components.
pub mod rng;
/// Lightweight tensor helpers.
pub mod tensor;
/// Transformer encoder and decoder blocks.
pub mod transformer;

pub use attention::{MultiHeadAttention, PositionalEncoding};
pub use bandit::{Bandit, BanditArm, BanditStrategy};
pub use conv::{Conv2D, MaxPool2D};
pub use engine::{LurekNeuralEngine, NeuralBlock};
pub use env::{FrameStack, SpaceSpec};
pub use error::LearningError;
pub use evolutionary::EvolutionaryLayer;
pub use genetic::{Chromosome, GeneticAlgorithm};
pub use limits::LearningLimits;
pub use neural_net::{Activation, NeuralLayer, NeuralNet};
pub use neuroevolution::Neuroevolution;
pub use qlearner::QLearner;
pub use recurrent::{GruLayer, LstmLayer};
pub use rng::{LearningRng, LearningRngSnapshot, LEARNING_RNG_VERSION};
pub use tensor::{gemm, LurekTensor};
pub use transformer::{LayerNorm, TransformerDecoderBlock, TransformerEncoderBlock};
