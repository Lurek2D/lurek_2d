# learning

## TL;DR

- The `learning` module provides standalone machine learning and evolutionary computation algorithms that can be used independently or integrated with the AI decision-making systems.

## General Info

- Module group: `Feature Systems`
- Source path: `src/learning/`
- Lua API path(s): `src/lua_api/learning_api.rs`
- Primary Lua namespace: `lurek.learning`
- Rust test path(s): tests/rust/unit/learning_tests.rs
- Lua test path(s): tests/lua/unit/test_learning_core_unit.lua

## Summary

The `learning` module extracts machine learning and evolutionary computation primitives into a focused, standalone subsystem. These algorithms have no dependency on the AI decision-making infrastructure (FSMs, behavior trees, GOAP, etc.) and can be used in any game context — from evolving creature behaviors to adaptive difficulty tuning to player modeling.

The module contains five core components:

- **NeuralNet** — A lightweight feed-forward neural network with configurable dense layers and activation functions (ReLU, Sigmoid, Tanh, Linear, Softmax). Supports forward inference, weight import/export, and parameter counting.

- **GeneticAlgorithm** — A population-based optimizer with tournament selection, single-point crossover, Gaussian mutation, and elitism. Uses a deterministic xorshift64 RNG for reproducible evolution runs.

- **Neuroevolution** — An orchestrator that combines `GeneticAlgorithm` with `NeuralNet` to evolve neural network weights through population-based search. Chromosomes map directly to network parameters.

- **QLearner** — A tabular Q-learning agent with epsilon-greedy exploration, Bellman updates, episode decay, and JSON serialization for policy persistence.

- **Bandit** — A multi-armed bandit with three selection strategies: epsilon-greedy, UCB1, and Thompson sampling. Tracks per-arm statistics and supports full reset.

All types are pure CPU, headless-testable, and have zero rendering dependencies. The module is exposed to Lua via `lurek.learning.*`.

## Source Documentation

### `bandit.rs`
- Compact multi-armed bandit storing per-arm reward history and posterior parameters.
- Strategy switch for epsilon-greedy, UCB1, and Thompson sampling policies.
- Selection, reward ingestion, and reset for adaptive arm choice without a planning framework.
- Internal gamma and beta sampling driven by a deterministic xorshift64 RNG.
- Per-arm pull counts, cumulative reward, and Bayesian alpha/beta parameter tracking.

### `genetic.rs`
- Population-based genetic optimization storing genomes, fitness values, and generation bookkeeping.
- Evolution step preserving elites, tournament selection, crossover, and in-place mutation.
- Deterministic random helpers driving parent selection, crossover, and Gaussian mutation.
- Stable per-chromosome identifiers persisting across generations for lineage tracking.
- Seeded xorshift64 RNG with Box-Muller normal sampling for reproducible evolution.

### `mod.rs`
- Machine learning and evolutionary computation algorithms.
- This module provides standalone learning algorithms that can be used
- independently or integrated with the AI decision-making systems.
- # Submodules
- `neural_net` — Feedforward neural networks with backpropagation
- `neuroevolution` — Evolving neural network topologies
- `genetic` — Genetic algorithms with configurable crossover and mutation
- `qlearner` — Tabular Q-learning for reinforcement learning
- `bandit` — Multi-armed bandit strategies (UCB1, Thompson, epsilon-greedy)

### `neural_net.rs`
- Lightweight feed-forward neural-network with dense layers, activation modes, and flat parameters.
- Layer-local forward evaluation, activation application, and parameter counting.
- Network-level operations: append layers, run forward passes, load/export weight buffers.

### `neuroevolution.rs`
- Neuroevolution wrapper joining genetic algorithm with neural-network for population-based weight search.
- Template layer specification for rebuilding networks from flat chromosome genes.
- Orchestration logic mapping chromosomes to networks, recording fitness, and advancing evolution.

### `qlearner.rs`
- Tabular Q-learning model with flat state-action value table and training parameters.
- Epsilon-greedy action selection, Bellman updates, and episode bookkeeping.
- Lightweight persistence helpers for serializing and reloading learned policies.

## Types

- `BanditArm` (`struct`, `bandit.rs`): `bandit.rs`
- `BanditStrategy` (`enum`, `bandit.rs`): `bandit.rs`
- `Bandit` (`struct`, `bandit.rs`): `bandit.rs`
- `Chromosome` (`struct`, `genetic.rs`): `genetic.rs`
- `GeneticAlgorithm` (`struct`, `genetic.rs`): `genetic.rs`
- `Activation` (`enum`, `neural_net.rs`): `neural_net.rs`
- `NeuralLayer` (`struct`, `neural_net.rs`): `neural_net.rs`
- `NeuralNet` (`struct`, `neural_net.rs`): `neural_net.rs`
- `Neuroevolution` (`struct`, `neuroevolution.rs`): `neuroevolution.rs`
- `QLearner` (`struct`, `qlearner.rs`): `qlearner.rs`

## Functions

- `BanditArm::mean_reward` (`bandit.rs`): Return the empirical mean reward; returns 0.5 before the first pull.
- `Bandit::new` (`bandit.rs`): Create a bandit with `arm_count` arms and a fixed RNG seed.
- `Bandit::arm_count` (`bandit.rs`): Return the number of available arms.
- `Bandit::select` (`bandit.rs`): Select an arm index according to the current strategy.
- `Bandit::update` (`bandit.rs`): Update the chosen arm with an observed reward in the range `[0, 1]`.
- `Bandit::best_arm` (`bandit.rs`): Return the greedy best arm by empirical mean reward.
- `Bandit::reset` (`bandit.rs`): Reset all arm statistics and the total pull counter.
- `Chromosome::new` (`genetic.rs`): Create a zeroed chromosome with `gene_count` genes.
- `GeneticAlgorithm::new` (`genetic.rs`): Create a population with random initial genes.
- `GeneticAlgorithm::pop_size` (`genetic.rs`): Return the current population size.
- `GeneticAlgorithm::best` (`genetic.rs`): Return the chromosome with the highest fitness, or `None` if empty.
- `GeneticAlgorithm::evolve` (`genetic.rs`): Build the next generation using elitism, tournament selection, crossover, and mutation.
- `Activation::from_str` (`neural_net.rs`): Parse a lowercase activation name; unknown strings map to `Linear`.
- `Activation::as_str` (`neural_net.rs`): Return the canonical activation name.
- `Activation::apply` (`neural_net.rs`): Apply the activation in place to `v`.
- `NeuralLayer::new` (`neural_net.rs`): Create a zeroed dense layer.
- `NeuralLayer::param_count` (`neural_net.rs`): Return the number of learnable parameters in the layer.
- `NeuralLayer::forward` (`neural_net.rs`): Compute the layer output for `input`.
- `NeuralNet::new` (`neural_net.rs`): Create an empty neural net.
- `NeuralNet::add_layer` (`neural_net.rs`): Append a new dense layer.
- `NeuralNet::param_count` (`neural_net.rs`): Return the total number of learnable parameters.
- `NeuralNet::forward` (`neural_net.rs`): Run a forward pass through all layers.
- `NeuralNet::set_weights` (`neural_net.rs`): Load flattened weights and biases; returns `false` when the shape mismatches.
- `NeuralNet::get_weights` (`neural_net.rs`): Return the flattened weights and biases.
- `NeuralNet::layer_count` (`neural_net.rs`): Return the number of layers.
- `Neuroevolution::new` (`neuroevolution.rs`): Create a population for the provided layer spec.
- `Neuroevolution::pop_size` (`neuroevolution.rs`): Return the population size.
- `Neuroevolution::chromosome_to_net` (`neuroevolution.rs`): Build a neural net from chromosome `i`; returns `None` when the index is invalid.
- `Neuroevolution::set_fitness` (`neuroevolution.rs`): Assign fitness to chromosome `i` when present.
- `Neuroevolution::evolve` (`neuroevolution.rs`): Advance the underlying genetic algorithm and generation counter.
- `Neuroevolution::best_network` (`neuroevolution.rs`): Build the network for the best chromosome, or `None` if the population is empty.
- `Neuroevolution::best_fitness` (`neuroevolution.rs`): Return the best fitness in the current population, or 0.0 if empty.
- `Neuroevolution::population` (`neuroevolution.rs`): Return the current chromosome slice.
- `QLearner::new` (`qlearner.rs`): Create a zeroed Q-table for `state_count` states and `action_count` actions.
- `QLearner::choose_action` (`qlearner.rs`): Return a randomly chosen action (explore) or the greedy best action (exploit).
- `QLearner::best_action` (`qlearner.rs`): Return the action with the highest Q-value for `state`; ties broken by index.
- `QLearner::learn` (`qlearner.rs`): Apply a Bellman update: Q[s,a] ← Q[s,a] + α(r + γ·max Q[s'] − Q[s,a]).
- `QLearner::end_episode` (`qlearner.rs`): Decay epsilon and increment `episode_count`; call once at the end of each episode.
- `QLearner::get_q` (`qlearner.rs`): Return Q[state, action]; returns 0.0 if indices are out of bounds.
- `QLearner::set_q` (`qlearner.rs`): Set Q[state, action] to `value`; no-op if indices are out of bounds.
- `QLearner::serialize` (`qlearner.rs`): Serialize the Q-table to a compact JSON string `[[row0], [row1], ...]`.
- `QLearner::deserialize` (`qlearner.rs`): Parse a JSON Q-table string and overwrite the current table; returns error on shape mismatch.

## Lua API Reference

- Binding path(s): `src/lua_api/learning_api.rs`
- Namespace: `lurek.learning`

### Module Functions
- `lurek.learning.newQLearner`: Creates a Q-learner with fixed state and action counts.
- `lurek.learning.newNeuralNet`: Creates an empty feed-forward neural network.
- `lurek.learning.newGeneticAlgorithm`: Creates a genetic algorithm population with fixed chromosome length.
- `lurek.learning.newBandit`: Creates a multi-armed bandit with a named selection strategy.
- `lurek.learning.newNeuroevolution`: Creates a neuroevolution population from a layer specification table.

### `LBandit` Methods
- `LBandit:select`: Selects an arm using the configured bandit strategy.
- `LBandit:update`: Updates one arm with a received reward.
- `LBandit:bestArm`: Returns the arm with the best current estimate.
- `LBandit:reset`: Resets all bandit arm statistics. This method is available to Lua scripts.
- `LBandit:armCount`: Returns the number of arms in this bandit.
- `LBandit:totalPulls`: Returns the total number of arm selections recorded by this bandit.
- `LBandit:type`: Returns the Lua-visible type name for this bandit handle.
- `LBandit:typeOf`: Returns whether this bandit handle matches a supported type name.

### `LGeneticAlgorithm` Methods
- `LGeneticAlgorithm:evolve`: Advances the genetic algorithm by one generation.
- `LGeneticAlgorithm:generation`: Returns the current generation index.
- `LGeneticAlgorithm:popSize`: Returns the population size. This method is available to Lua scripts.
- `LGeneticAlgorithm:setFitness`: Sets the fitness value for a chromosome by zero-based index.
- `LGeneticAlgorithm:getGenes`: Returns the genes for a chromosome by zero-based index.
- `LGeneticAlgorithm:bestGenes`: Returns the genes for the best chromosome in the population.
- `LGeneticAlgorithm:type`: Returns the Lua-visible type name for this genetic algorithm handle.
- `LGeneticAlgorithm:typeOf`: Returns whether this genetic algorithm handle matches a supported type name.

### `LNeuralNet` Methods
- `LNeuralNet:addLayer`: Adds a neural network layer with an activation function.
- `LNeuralNet:forward`: Runs a forward pass and returns output values.
- `LNeuralNet:setWeights`: Replaces the network weights from a flat numeric array.
- `LNeuralNet:getWeights`: Returns the network weights as a flat numeric array.
- `LNeuralNet:paramCount`: Returns the total number of trainable parameters.
- `LNeuralNet:layerCount`: Returns the number of layers in the network.
- `LNeuralNet:type`: Returns the Lua-visible type name for this neural network handle.
- `LNeuralNet:typeOf`: Returns whether this neural network handle matches a supported type name.

### `LNeuroevolution` Methods
- `LNeuroevolution:evolve`: Advances the neuroevolution population by one generation.
- `LNeuroevolution:setFitness`: Sets the fitness value for a chromosome by zero-based index.
- `LNeuroevolution:chromosomeToNet`: Converts one chromosome into a neural network handle when the index is valid.
- `LNeuroevolution:bestNetwork`: Converts the best chromosome into a neural network handle when one exists.
- `LNeuroevolution:bestFitness`: Returns the best fitness value in the population.
- `LNeuroevolution:popSize`: Returns the population size. This method is available to Lua scripts.
- `LNeuroevolution:generation`: Returns the current generation index.
- `LNeuroevolution:type`: Returns the Lua-visible type name for this neuroevolution handle.
- `LNeuroevolution:typeOf`: Returns whether this neuroevolution handle matches a supported type name.

### `LQLearner` Methods
- `LQLearner:chooseAction`: Chooses an action for a one-based state index using the learner's exploration policy.
- `LQLearner:bestAction`: Returns the highest-valued action for a one-based state index without exploration.
- `LQLearner:learn`: Applies one Q-learning update from a transition and reward.
- `LQLearner:getQValue`: Returns the stored Q-value for a one-based state and action pair.
- `LQLearner:setQValue`: Sets the stored Q-value for a one-based state and action pair.
- `LQLearner:endEpisode`: Decays epsilon and increments the episode count.
- `LQLearner:getStateCount`: Returns the number of states represented by this learner.
- `LQLearner:getActionCount`: Returns the number of actions represented by this learner.
- `LQLearner:setLearningRate`: Sets the Q-learning alpha learning rate.
- `LQLearner:getLearningRate`: Returns the Q-learning alpha learning rate.
- `LQLearner:setDiscountFactor`: Sets the Q-learning gamma discount factor.
- `LQLearner:getDiscountFactor`: Returns the Q-learning gamma discount factor.
- `LQLearner:setExplorationRate`: Sets the exploration rate used by action selection.
- `LQLearner:getExplorationRate`: Returns the exploration rate used by action selection.
- `LQLearner:setExplorationDecay`: Sets the exploration decay multiplier applied across episodes.
- `LQLearner:getExplorationDecay`: Returns the exploration decay multiplier.
- `LQLearner:serialize`: Serializes the Q-learner state to a JSON string.
- `LQLearner:deserialize`: Replaces the Q-learner state from a JSON string.
- `LQLearner:type`: Returns the Lua-visible type name for this Q-learner handle.
- `LQLearner:typeOf`: Returns whether this Q-learner handle matches a supported type name.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- The `ai` module re-exports all learning types for backward compatibility. Existing code using `lurek.ai.newNeuralNet()` etc. continues to work.
- All algorithms are deterministic when seeded, enabling reproducible runs.
- The learning module has no dependencies on AI-specific types (Blackboard, Agent, FSM, etc.).
- Neuroevolution imports from `learning::genetic` and `learning::neural_net` internally.
