# learning

## General Info

- Module group: `Feature Systems`
- Source path: `src/learning/`
- Binding: `src/lua_api/learning_api.rs`
- Namespace: `lurek.learning`
- Lua API surface: `20` functions, `18` types, `127` methods
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

The module now also includes advanced neural-building blocks for CPU-first sequence and spatial inference:

- **LurekTensor + GEMM** — Row-major tensor container, flatten/index helpers, and a lightweight matrix multiply helper used by higher-level layers.
- **Conv2D / MaxPool2D** — Deterministic 2D convolution and pooling layers over `[C,H,W]` tensors.
- **LstmLayer / GruLayer** — Recurrent layers with deterministic flat-parameter layouts for neuroevolution roundtrip use.
- **PositionalEncoding / MultiHeadAttention** — Transformer attention primitives over `[S,D]` tensors.
- **TransformerEncoderBlock / TransformerDecoderBlock** — Composed attention + layernorm + FFN superblocks with flat-parameter export/import.
- **LurekNeuralEngine** — Heterogeneous block container that packs/unpacks all trainable parameters into one flat genome buffer.

All types are pure CPU, headless-testable, and have zero rendering dependencies. The module is exposed to Lua via `lurek.learning.*`.

## Files

### [attention.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/learning/attention.rs)

- Implements attention primitives used by sequence-learning stacks in the learning subsystem.
- Provides positional encodings and multi-head attention flows over row-major tensor buffers.
- Computes query-key-value interactions and head projection paths for contextual token mixing.
- Integrates with shared evolutionary-layer contracts so parameters can be flattened and restored.
- Targets CPU inference and training-style experiments without external deep-learning runtimes.
- Supplies reusable building blocks consumed by transformer encoder and decoder compositions.

### [bandit.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/learning/bandit.rs)

- Implements multi-armed bandit optimization with per-arm reward history and posterior statistics.
- Supports epsilon-greedy, UCB-style, and Thompson-style selection strategies in one component.
- Tracks pull counts and cumulative rewards to adapt action choice under uncertain payoffs.
- Uses deterministic random helpers for reproducible sampling during probabilistic strategies.
- Exposes reward ingestion, arm selection, and reset operations for online learning loops.
- Fits lightweight decision problems where full planning frameworks are unnecessary.

### [conv.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/learning/conv.rs)

- Provides convolution and pooling layers for CPU-side learning and feature-extraction pipelines.
- Implements tensor-shape-aware forward passes over channel-first image-style inputs.
- Stores trainable kernels and biases in flat buffers compatible with evolutionary parameter flows.
- Supports stride and padding behavior needed for practical stacked convolution blocks.
- Supplies compact building blocks consumed by the higher-level neural engine.

### [engine.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/learning/engine.rs)

- Defines a dynamic neural engine that chains heterogeneous learning blocks in one runtime graph.
- Hosts dense, convolutional, recurrent, and transformer-like components behind a unified interface.
- Packs and unpacks flat parameter buffers so composite models work with evolutionary optimizers.
- Executes staged forward passes through configured block sequences on shared tensor carriers.
- Serves as the composition hub for mixed-architecture experimentation in the learning module.

### [env.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/learning/env.rs)

- Provides reinforcement-learning environment wrappers modeled after common Gym-like conventions.
- Describes action and observation spaces with bounded metadata suitable for generic agents.
- Includes frame-stack helpers that accumulate temporal context for history-dependent policies.
- Standardizes reset and step-style interaction shapes for training and evaluation loops.

### [evolutionary.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/learning/evolutionary.rs)

- Defines the shared trait contract for layers exposing flat trainable parameter buffers.
- Standardizes parameter counting, import, and export across heterogeneous learning layers.
- Enables neuroevolution and genetic workflows to operate on model components uniformly.

### [genetic.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/learning/genetic.rs)

- Implements population-based genetic optimization over flat genomes with explicit generation tracking.
- Executes elite preservation, parent selection, crossover, and mutation during evolution steps.
- Maintains stable chromosome identifiers to support lineage tracing across generations.
- Uses deterministic random and Gaussian sampling helpers for reproducible evolution runs.
- Serves as a general optimizer backend for learning components and parameter-search tasks.

### [mod.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/learning/mod.rs)

- High-level learning module that aggregates neural, evolutionary, and reinforcement components.
- Re-exports core model, optimizer, tensor, and environment types for unified caller access.
- Connects lightweight CPU learning primitives with optional ONNX inference capabilities.
- Defines the integration layer for experimentation-oriented training and decision systems.

### [neural_net.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/learning/neural_net.rs)

- Implements lightweight feed-forward neural networks with dense layers and selectable activations.
- Stores weights and biases in flat vectors for compact memory usage and easy serialization.
- Performs layer-by-layer forward propagation over vector inputs for inference and evaluation.
- Supports parameter counting plus import and export for optimizer and evolution workflows.
- Provides network-assembly helpers that append layers into ordered model pipelines.
- Targets simple ML tasks where minimal dependencies and predictable behavior are preferred.

### [neuroevolution.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/learning/neuroevolution.rs)

- Bridges genetic optimization and neural models to run population-based weight search workflows.
- Rebuilds networks from flat chromosomes using template layer specifications.
- Evaluates and records fitness before advancing generations through the underlying GA backend.
- Provides a focused orchestration layer for neuroevolution experiments and gameplay AI prototyping.

### [onnx.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/learning/onnx.rs)

- Provides ONNX model loading and inference by bridging `LurekTensor` data into tract runtimes.
- Builds optimized runnable plans from ONNX files for CPU execution paths.
- Converts input and output tensors between engine-native and tract-native representations.
- Exposes deterministic inference entry points used by learning APIs without game-loop coupling.

### [qlearner.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/learning/qlearner.rs)

- Implements tabular Q-learning over discrete state-action spaces with configurable hyperparameters.
- Stores Q-values in a flat table for fast index-based update and query operations.
- Applies epsilon-greedy action choice and Bellman updates during reinforcement cycles.
- Tracks episode and training metadata useful for monitoring learner progression.
- Supports persistence helpers for saving and reloading learned policy tables.

### [recurrent.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/learning/recurrent.rs)

- Provides recurrent sequence-learning layers including LSTM and GRU style stateful blocks.
- Stores gate parameters in flat row-major buffers suitable for CPU forward evaluation.
- Executes timestep iteration while carrying hidden-state context across sequence positions.
- Integrates with evolutionary parameter interfaces for genome-based optimization workflows.
- Offers compact recurrent primitives for temporal modeling without heavyweight dependencies.
- Serves as a reusable foundation for sequence tasks in higher-level learning engines.

### [tensor.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/learning/tensor.rs)

- Defines lightweight tensor containers and helpers used by learning components.
- Stores shape metadata and flat row-major data for predictable indexing behavior.
- Provides indexing, flattening, and conversion utilities needed by model layers.
- Includes compact numeric operations that support CPU learning pipelines.

### [transformer.rs](https://github.com/Lurek2D/lurek_2d/blob/main/src/learning/transformer.rs)

- Implements transformer-style blocks composed from attention, normalization, and feed-forward stages.
- Defines encoder and decoder building units operating over engine-native tensor structures.
- Applies residual pathways and normalization flows for stable sequence representation updates.
- Stores trainable parameters in flat vectors to align with evolutionary optimization tooling.
- Coordinates multi-stage forward execution across attention and projection subcomponents.
- Provides reusable transformer primitives for sequence learning and inference experiments.
- Integrates with the wider learning stack through common tensor and layer contracts.
