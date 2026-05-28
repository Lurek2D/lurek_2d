//! Machine learning and evolutionary computation algorithms.

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
