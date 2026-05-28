//! Machine learning and evolutionary computation algorithms.
//!
//! - This module provides standalone learning algorithms that can be used
//! - independently or integrated with the AI decision-making systems.
//! - # Submodules
//! - `neural_net` — Feedforward neural networks with backpropagation
//! - `neuroevolution` — Evolving neural network topologies
//! - `genetic` — Genetic algorithms with configurable crossover and mutation
//! - `qlearner` — Tabular Q-learning for reinforcement learning
//! - `bandit` — Multi-armed bandit strategies (UCB1, Thompson, epsilon-greedy)
//! - `env` — Gym-compatible RL environment wrappers
//! - `onnx` — ONNX model loading and inference via tract-onnx

/// Multi-armed bandit strategies and statistics.
pub mod bandit;
/// Gym-compatible RL environment wrappers.
pub mod env;
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

pub use bandit::{Bandit, BanditArm, BanditStrategy};
pub use env::{FrameStack, SpaceSpec};
pub use genetic::{Chromosome, GeneticAlgorithm};
pub use neural_net::{Activation, NeuralLayer, NeuralNet};
pub use neuroevolution::Neuroevolution;
pub use onnx::{LurekTensor, OnnxModel};
pub use qlearner::QLearner;
