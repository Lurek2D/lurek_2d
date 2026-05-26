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

### `neural_net.rs`
- Lightweight feed-forward neural-network with dense layers, activation modes, and flat parameters.
- Layer-local forward evaluation, activation application, and parameter counting.
- Network-level operations: append layers, run forward passes, load/export weight buffers.

### `genetic.rs`
- Population-based genetic optimization storing genomes, fitness values, and generation bookkeeping.
- Evolution step preserving elites, tournament selection, crossover, and in-place mutation.
- Deterministic random helpers driving parent selection, crossover, and Gaussian mutation.
- Stable per-chromosome identifiers persisting across generations for lineage tracking.
- Seeded xorshift64 RNG with Box-Muller normal sampling for reproducible evolution.

### `neuroevolution.rs`
- Neuroevolution wrapper joining genetic algorithm with neural-network for population-based weight search.
- Template layer specification for rebuilding networks from flat chromosome genes.
- Orchestration logic mapping chromosomes to networks, recording fitness, and advancing evolution.

### `qlearner.rs`
- Tabular Q-learning model with flat state-action value table and training parameters.
- Epsilon-greedy action selection, Bellman updates, and episode bookkeeping.
- Lightweight persistence helpers for serializing and reloading learned policies.

### `bandit.rs`
- Compact multi-armed bandit storing per-arm reward history and posterior parameters.
- Strategy switch for epsilon-greedy, UCB1, and Thompson sampling policies.
- Selection, reward ingestion, and reset for adaptive arm choice without a planning framework.
- Internal gamma and beta sampling driven by a deterministic xorshift64 RNG.
- Per-arm pull counts, cumulative reward, and Bayesian alpha/beta parameter tracking.

## Types

| Type | File | Description |
|------|------|-------------|
| `Activation` | `neural_net.rs` | Activation function enum (ReLU, Sigmoid, Tanh, Linear, Softmax) |
| `NeuralLayer` | `neural_net.rs` | Dense layer with row-major weights and per-output biases |
| `NeuralNet` | `neural_net.rs` | Ordered stack of dense layers for forward inference |
| `Chromosome` | `genetic.rs` | Evolving genome with fitness and stable id |
| `GeneticAlgorithm` | `genetic.rs` | Population-based genetic optimizer |
| `Neuroevolution` | `neuroevolution.rs` | GA-backed neural-network population manager |
| `QLearner` | `qlearner.rs` | Q-learning agent with flat state×action value table |
| `BanditArm` | `bandit.rs` | Single bandit arm with accumulated reward statistics |
| `BanditStrategy` | `bandit.rs` | Selection strategy enum (EpsilonGreedy, UCB1, ThompsonSampling) |
| `Bandit` | `bandit.rs` | Complete bandit agent with strategy and mutable arm set |

## Lua API Reference

### Constructors

| Function | Description |
|----------|-------------|
| `lurek.learning.newNeuralNet()` | Creates an empty feed-forward neural network |
| `lurek.learning.newGeneticAlgorithm(pop_size, gene_count, seed)` | Creates a GA population |
| `lurek.learning.newNeuroevolution(layer_spec, pop_size, seed)` | Creates neuroevolution population |
| `lurek.learning.newQLearner(states, actions)` | Creates a tabular Q-learner |
| `lurek.learning.newBandit(arm_count, strategy, epsilon, seed)` | Creates a multi-armed bandit |

### NeuralNet Methods

| Method | Description |
|--------|-------------|
| `:addLayer(inputs, outputs, activation)` | Adds a dense layer |
| `:forward(input)` | Runs forward pass, returns output table |
| `:setWeights(weights)` | Sets weights from flat array |
| `:getWeights()` | Returns weights as flat array |
| `:paramCount()` | Total learnable parameters |
| `:layerCount()` | Number of layers |

### GeneticAlgorithm Methods

| Method | Description |
|--------|-------------|
| `:evolve()` | Advances one generation |
| `:generation()` | Current generation index |
| `:popSize()` | Population size |
| `:setFitness(idx, fitness)` | Sets chromosome fitness |
| `:getGenes(idx)` | Returns chromosome genes |
| `:bestGenes()` | Returns best chromosome genes |

### Neuroevolution Methods

| Method | Description |
|--------|-------------|
| `:evolve()` | Advances one generation |
| `:setFitness(idx, fitness)` | Sets chromosome fitness |
| `:chromosomeToNet(idx)` | Converts chromosome to NeuralNet |
| `:bestNetwork()` | Returns best chromosome as NeuralNet |
| `:bestFitness()` | Best fitness value |
| `:popSize()` | Population size |
| `:generation()` | Current generation |

### QLearner Methods

| Method | Description |
|--------|-------------|
| `:chooseAction(state)` | Epsilon-greedy action selection |
| `:bestAction(state)` | Greedy best action |
| `:learn(state, action, reward, next_state)` | Bellman update |
| `:endEpisode()` | Decay epsilon, increment episode count |
| `:getQValue(state, action)` | Read Q-value |
| `:setQValue(state, action, value)` | Write Q-value |
| `:serialize()` | JSON export |
| `:deserialize(json)` | JSON import |

### Bandit Methods

| Method | Description |
|--------|-------------|
| `:select()` | Select arm via strategy |
| `:update(idx, reward)` | Update arm statistics |
| `:bestArm()` | Greedy best arm |
| `:reset()` | Reset all arm stats |
| `:armCount()` | Number of arms |
| `:totalPulls()` | Total selections |

## Notes

- The `ai` module re-exports all learning types for backward compatibility. Existing code using `lurek.ai.newNeuralNet()` etc. continues to work.
- All algorithms are deterministic when seeded, enabling reproducible runs.
- The learning module has no dependencies on AI-specific types (Blackboard, Agent, FSM, etc.).
- Neuroevolution imports from `learning::genetic` and `learning::neural_net` internally.

## References

- [ai.md](ai.md) — AI decision-making systems that can integrate with learning algorithms
- [docs/architecture/philosophy.md](../architecture/philosophy.md) — Module group taxonomy
