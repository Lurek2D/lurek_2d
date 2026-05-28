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

/// Multi-armed bandit strategies and statistics.
pub mod bandit;
/// Genetic algorithm primitives.
pub mod genetic;
/// Feed-forward neural network helpers.
pub mod neural_net;
/// Neuroevolution orchestration.
pub mod neuroevolution;
/// Reinforcement learning with a tabular Q-learner.
pub mod qlearner;

pub use bandit::{Bandit, BanditArm, BanditStrategy};
pub use genetic::{Chromosome, GeneticAlgorithm};
pub use neural_net::{Activation, NeuralLayer, NeuralNet};
pub use neuroevolution::Neuroevolution;
pub use qlearner::QLearner;
