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

This module represents the machine-learning runtime and artificial intelligence modeling subsystem, providing a rich collection of CPU-side training and inference blocks. It allows developers to build, organize, and evaluate various learning architectures directly in active game sessions. These models run without external runtime dependencies, utilizing flat, row-major tensor buffers for fast and predictable numeric calculations on the main CPU thread.

At the core of the neural modeling system is a dynamic network engine that chains diverse layer types into unified model pipelines. It supports feed-forward dense layers, spatial Conv2D grids, downsampling MaxPool2D layers, and stateful GRU or LSTM recurrent sequence blocks. Additionally, advanced sequence blocks like multi-head attention and transformer blocks are supported, complete with sinusoidal positional encodings for temporal context modeling.

To optimize weights, the module implements population-based genetic algorithms and neuroevolution workflows. Trainable parameters are exported and imported as flat floating-point buffers, allowing evolutionary search tools to manipulate layer architectures uniformly. The neuroevolution orchestrator rebuilds neural nets from flat chromosomes and tracks generation metadata, making it easy to evolve behavioral policies and prototype gameplay agents.

For decision-making tasks under uncertainty, the module integrates reinforcement learning components. A multi-armed bandit selector supports epsilon-greedy, Thompson sampling, and upper confidence bound strategies. This is paired with tabular Q-learning over discrete state-action spaces, supporting epsilon decay and Bellman updates. Environment wrappers standardize reward step structures and observation limits to streamline training loops.

Finally, the module provides a seamless path for integrating externally trained models via ONNX format loading. By converting native tensor descriptors into plan structures, it performs optimized CPU inference on pre-trained networks. This enables developers to deploy complex, industry-standard neural network policies directly into game scripts, combining local training, evolutionary prototyping, and external inference in one cohesive system.

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
