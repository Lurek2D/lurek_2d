# learning

## TL;DR

- Manages dynamic neural nets, attention blocks, transformers, and flat tensor buffers.
- Supports genetic algorithms, neuroevolution, bandits, tabular Q-learning, and ONNX models.

## General Info

- Module group: `Feature Systems`
- Source path: `src/learning/`
- Binding: `src/lua_api/learning_api.rs`
- Namespace: `lurek.learning`
- Lua API surface: `21` functions, `19` types, `137` methods
- Rust test path(s): tests/rust/unit/learning_tests.rs
- Lua test path(s): tests/lua_reorg/unit/test_learning_core_unit.lua

## Summary

- This module gives users a script-accessible ML toolkit for inference, lightweight training loops, and policy experimentation.
- It supports tensor-based numeric workflows with deterministic CPU-side execution.
- Neural building blocks include dense, convolutional, recurrent, attention, and transformer-style components.
- Mixed architectures can be assembled through a unified engine rather than hardcoded model pipelines.
- Parameter import/export support enables model mutation, checkpointing, and external optimization workflows.
- Genetic algorithm support provides population-based optimization for parameter search.
- Neuroevolution helpers connect genomes to model structures for evolving behavior policies.
- Bandit strategies support online decision tuning under uncertainty.
- Tabular Q-learning support enables classic reinforcement-learning experiments in discrete spaces.
- Environment wrappers standardize observations, rewards, and termination controls.
- Frame-stack and time-limit wrappers help shape training contexts for temporal tasks.
- ONNX loading enables reuse of externally trained models for runtime inference.
- This bridges in-engine experimentation with broader ML tool ecosystems.
- The module supports prototyping AI behavior without requiring separate external runtimes.
- For users, this means shorter loops from idea to tested gameplay policy.
- It is useful for adaptive NPC logic, balancing agents, and simulation decision support.
- Deterministic tensor and model operations make behavior easier to test and debug.
- Script-level APIs keep model control close to gameplay systems that consume predictions.
- The practical value is flexible AI capability without committing to one single algorithm family.
- Users can combine supervised-style inference, RL, and evolutionary methods in one environment.
- This enables comparative experimentation before locking production strategy.
- It also lowers integration friction by sharing one data model across learning components.
- Overall, the module turns ML from an external dependency into an integrated engine feature set.
- Teams gain both rapid prototyping tools and deployable runtime inference paths.
- It helps bridge research ideas and shippable behavior systems with fewer rewrites.
- In short, users get a broad, scriptable learning sandbox aligned with game-runtime constraints.
- That makes AI development more iterative, observable, and maintainable.
- The module also supports long-term evolution as project AI needs grow in complexity.

This module is mostly self-contained inside the `Feature Systems` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Files

### attention.rs

- Implements attention primitives used by sequence-learning stacks in the learning subsystem.
- Provides positional encodings and multi-head attention flows over row-major tensor buffers.
- Computes query-key-value interactions and head projection paths for contextual token mixing.
- Integrates with shared evolutionary-layer contracts so parameters can be flattened and restored.
- Targets CPU inference and training-style experiments without external deep-learning runtimes.
- Supplies reusable building blocks consumed by transformer encoder and decoder compositions.

### bandit.rs

- Implements multi-armed bandit optimization with per-arm reward history and posterior statistics.
- Supports epsilon-greedy, UCB-style, and Thompson-style selection strategies in one component.
- Tracks pull counts and cumulative rewards to adapt action choice under uncertain payoffs.
- Uses deterministic random helpers for reproducible sampling during probabilistic strategies.
- Exposes reward ingestion, arm selection, and reset operations for online learning loops.
- Fits lightweight decision problems where full planning frameworks are unnecessary.

### conv.rs

- Provides convolution and pooling layers for CPU-side learning and feature-extraction pipelines.
- Implements tensor-shape-aware forward passes over channel-first image-style inputs.
- Stores trainable kernels and biases in flat buffers compatible with evolutionary parameter flows.
- Supports stride and padding behavior needed for practical stacked convolution blocks.
- Supplies compact building blocks consumed by the higher-level neural engine.

### engine.rs

- Defines a dynamic neural engine that chains heterogeneous learning blocks in one runtime graph.
- Hosts dense, convolutional, recurrent, and transformer-like components behind a unified interface.
- Packs and unpacks flat parameter buffers so composite models work with evolutionary optimizers.
- Executes staged forward passes through configured block sequences on shared tensor carriers.
- Serves as the composition hub for mixed-architecture experimentation in the learning module.

### env.rs

- Reinforcement learning environment abstractions following Gym-style conventions enabling training of generic agents on Lurek2D game tasks.
- Defines SpaceSpec descriptors for action and observation spaces with shape, bounds, and discrete action counts supporting policy network design.
- Implements FrameStack buffer accumulating historical observations into temporal context vectors required by recurrent and attention-based policies.
- Standardizes reset() and step() interaction contracts matching OpenAI Gym patterns for seamless integration with popular RL frameworks.

### evolutionary.rs

- Defines the shared trait contract for layers exposing flat trainable parameter buffers.
- Standardizes parameter counting, import, and export across heterogeneous learning layers.
- Enables neuroevolution and genetic workflows to operate on model components uniformly.

### genetic.rs

- Implements population-based genetic optimization over flat genomes with explicit generation tracking.
- Executes elite preservation, parent selection, crossover, and mutation during evolution steps.
- Maintains stable chromosome identifiers to support lineage tracing across generations.
- Uses deterministic random and Gaussian sampling helpers for reproducible evolution runs.
- Serves as a general optimizer backend for learning components and parameter-search tasks.

### mod.rs

- High-level learning module that aggregates neural, evolutionary, and reinforcement components.
- Re-exports core model, optimizer, tensor, and environment types for unified caller access.
- Connects lightweight CPU learning primitives with optional ONNX inference capabilities.
- Defines the integration layer for experimentation-oriented training and decision systems.

### neural_net.rs

- Implements lightweight feed-forward neural networks with dense layers and selectable activations.
- Stores weights and biases in flat vectors for compact memory usage and easy serialization.
- Performs layer-by-layer forward propagation over vector inputs for inference and evaluation.
- Supports parameter counting plus import and export for optimizer and evolution workflows.
- Provides network-assembly helpers that append layers into ordered model pipelines.
- Targets simple ML tasks where minimal dependencies and predictable behavior are preferred.

### neuroevolution.rs

- Bridges genetic optimization and neural models to run population-based weight search workflows.
- Rebuilds networks from flat chromosomes using template layer specifications.
- Evaluates and records fitness before advancing generations through the underlying GA backend.
- Provides a focused orchestration layer for neuroevolution experiments and gameplay AI prototyping.

### onnx.rs

- Provides ONNX model loading and inference by bridging `LurekTensor` data into tract runtimes.
- Builds optimized runnable plans from ONNX files for CPU execution paths.
- Converts input and output tensors between engine-native and tract-native representations.
- Exposes deterministic inference entry points used by learning APIs without game-loop coupling.

### qlearner.rs

- Implements tabular Q-learning over discrete state-action spaces with configurable hyperparameters.
- Stores Q-values in a flat table for fast index-based update and query operations.
- Applies epsilon-greedy action choice and Bellman updates during reinforcement cycles.
- Tracks episode and training metadata useful for monitoring learner progression.
- Supports persistence helpers for saving and reloading learned policy tables.

### recurrent.rs

- Provides recurrent sequence-learning layers including LSTM and GRU style stateful blocks.
- Stores gate parameters in flat row-major buffers suitable for CPU forward evaluation.
- Executes timestep iteration while carrying hidden-state context across sequence positions.
- Integrates with evolutionary parameter interfaces for genome-based optimization workflows.
- Offers compact recurrent primitives for temporal modeling without heavyweight dependencies.
- Serves as a reusable foundation for sequence tasks in higher-level learning engines.

### tensor.rs

- Lightweight tensor container with explicit row-major shape metadata and flat f32 data layout for CPU-based learning pipeline operations.
- Supports multi-dimensional indexing through flat_index() with shape validation and zero-based coordinate conversion for safe element access.
- Converts to tract Tensor format enabling interop with ONNX model inference engines for neural network evaluation on game tasks.
- Provides flatten(), gemm() operations enabling tensor transformations and basic linear algebra needed by learning layer computations.

### transformer.rs

- Implements transformer-style blocks composed from attention, normalization, and feed-forward stages.
- Defines encoder and decoder building units operating over engine-native tensor structures.
- Applies residual pathways and normalization flows for stable sequence representation updates.
- Stores trainable parameters in flat vectors to align with evolutionary optimization tooling.
- Coordinates multi-stage forward execution across attention and projection subcomponents.
- Provides reusable transformer primitives for sequence learning and inference experiments.
- Integrates with the wider learning stack through common tensor and layer contracts.

## Types

- `PositionalEncoding` (`struct`, `attention.rs`): Sinusoidal positional encoding for `[seq_len, d_model]` tensors. Details: fields: d_model: usize, max_len: usize, encoding: Vec<f32> | methods: apply (Add positional vectors in-place.); new (Precompute positional encoding table.)
- `MultiHeadAttention` (`struct`, `attention.rs`): CPU multi-head self-attention with combined linear projections. Details: fields: d_model: usize, num_heads: usize, d_k: usize, w_q: Vec<f32>, w_k: Vec<f32>, w_v: Vec<f32>, w_o: Vec<f32>, b_q: Vec<f32>, b_k: Vec<f32>, b_v: Vec<f32>, b_o: Vec<f32> | methods: forward (Run self-attention on `x` with shape `[S,D]`.); new (Create a zero-initialized MHA block.)
- `BanditArm` (`struct`, `bandit.rs`): A single bandit arm with accumulated reward statistics. Details: fields: pulls: u32, total_reward: f64, alpha: f64, beta: f64, label: Option<String> | methods: mean_reward (Return the empirical mean reward; returns 0.5 before the first pull.)
- `BanditStrategy` (`enum`, `bandit.rs`): Selection strategy used by `Bandit`. Details: variants: EpsilonGreedy, UCB1, ThompsonSampling
- `Bandit` (`struct`, `bandit.rs`): Complete bandit agent with one strategy and a mutable set of arms. Details: fields: arms: Vec<BanditArm>, strategy: BanditStrategy, total_pulls: u64 | methods: arm_count (Return the number of available arms.); best_arm (Return the greedy best arm by empirical mean reward.); new (Create a bandit with `arm_count` arms and a fixed RNG seed.); reset (Reset all arm statistics and the total pull counter.); select (Select an arm index according to the current strategy.); update (Update the chosen arm with an observed reward in the range `[0, 1]`.)
- `Conv2D` (`struct`, `conv.rs`): 2D convolution layer over `[channels, height, width]` tensors. Details: fields: in_channels: usize, out_channels: usize, kernel_size: (usize, stride: (usize, padding: (usize, weights: Vec<f32>, biases: Vec<f32> | methods: forward (Run convolution over one input tensor shaped `[C, H, W]`.); new (Create a zero-initialized convolution layer.)
- `MaxPool2D` (`struct`, `conv.rs`): Max pooling over `[channels, height, width]` tensors. Details: fields: kernel_size: (usize, stride: (usize | methods: forward (Run max pooling.); new (Create max pool layer.)
- `NeuralBlock` (`enum`, `engine.rs`): Supported functional blocks for `LurekNeuralEngine`. Details: variants: Dense, Conv2D, MaxPool2D, Lstm, Gru, TransformerEncoder, TransformerDecoder | methods: get_weights (Export trainable parameters for this block.); param_count (Trainable parameter count for this block.); set_weights (Load trainable parameters for this block.)
- `LurekNeuralEngine` (`struct`, `engine.rs`): Heterogeneous neural graph with deterministic flat-parameter packing. Details: methods: add_block (Append one block.); block_count (Number of blocks in the engine.); blocks (Immutable block access.); blocks_mut (Mutable block access.); get_weights (Export all trainable parameters in block insertion order.); new (Create an empty engine.); param_count (Total trainable parameter count across all blocks.); set_weights (Load a flat parameter buffer and split it across blocks in insertion order.)
- `SpaceSpec` (`struct`, `env.rs`): Space descriptor shared by observation and action spaces. Details: fields: shape: Vec<u32>, low: Vec<f32>, high: Vec<f32>, n: u32
- `FrameStack` (`struct`, `env.rs`): Frame stacking ring buffer for history-based observations. Details: methods: capacity (Returns the maximum number of frames retained.); get (Returns the flattened stack.); new (Creates a new empty frame stack with the given capacity.); push (Pushes an observation, discarding the oldest if at capacity.); reset (Clears all stored frames and resets the observed dimension.)
- `EvolutionaryLayer` (`trait`, `evolutionary.rs`): Contract for layers usable in neuroevolution workflows.
- `Chromosome` (`struct`, `genetic.rs`): Evolving genome with fitness and stable id. Details: fields: genes: Vec<f32>, fitness: f32, id: u64 | methods: new (Create a zeroed chromosome with `gene_count` genes.)
- `GeneticAlgorithm` (`struct`, `genetic.rs`): Population-based genetic optimizer. Details: fields: population: Vec<Chromosome>, gene_count: usize, mutation_rate: f32, mutation_std: f32, tournament_size: usize, elitism: usize, generation: usize | methods: best (Return the chromosome with the highest fitness, or `None` if empty.); evolve (Build the next generation using elitism, tournament selection, crossover, and mutation.); new (Create a population with random initial genes.); pop_size (Return the current population size.)
- `Activation` (`enum`, `neural_net.rs`): Activation function used by a layer. Details: variants: ReLU, Sigmoid, Tanh, Linear, Softmax | methods: apply (Apply the activation in place to `v`.); as_str (Return the canonical activation name.); from_str (Parse a lowercase activation name; unknown strings map to `Linear`.)
- `NeuralLayer` (`struct`, `neural_net.rs`): Dense layer with row-major weights and per-output biases. Details: fields: inputs: usize, outputs: usize, weights: Vec<f32>, biases: Vec<f32>, activation: Activation | methods: forward (Compute the layer output for `input`.); new (Create a zeroed dense layer.); param_count (Return the number of learnable parameters in the layer.)
- `NeuralNet` (`struct`, `neural_net.rs`): Ordered stack of dense layers. Details: methods: add_layer (Append a new dense layer.); forward (Run a forward pass through all layers.); get_weights (Return the flattened weights and biases.); layer_count (Return the number of layers.); new (Create an empty neural net.); param_count (Return the total number of learnable parameters.); set_weights (Load flattened weights and biases; returns `false` when the shape mismatches.)
- `Neuroevolution` (`struct`, `neuroevolution.rs`): GA-backed neural-network population manager. Details: fields: ga: GeneticAlgorithm, generation: usize | methods: best_fitness (Return the best fitness in the current population, or 0.0 if empty.); best_network (Build the network for the best chromosome, or `None` if the population is empty.); chromosome_to_net (Build a neural net from chromosome `i`; returns `None` when the index is invalid.); evolve (Advance the underlying genetic algorithm and generation counter.); new (Create a population for the provided layer spec.); pop_size (Return the population size.); population (Return the current chromosome slice.); set_fitness (Assign fitness to chromosome `i` when present.)
- `OnnxModel` (`struct`, `onnx.rs`): Loaded and optimised ONNX model wrapped around a tract runnable plan. Details: methods: input_count (Number of input tensors expected by the model.); load (Load an ONNX model from `path`, optimise it, and return a runnable handle.); output_count (Number of output tensors produced by the model.); run (Run inference on `inputs`, returning one `LurekTensor` per model output.)
- `QLearner` (`struct`, `qlearner.rs`): Q-learning agent with a flat `state × action` value table. Details: fields: state_count: usize, action_count: usize, qtable: Vec<f64>, alpha: f64, gamma: f64, epsilon: f64, epsilon_decay: f64, episode_count: u64 | methods: best_action (Return the action with the highest Q-value for `state`; ties broken by index.); choose_action (Return a randomly chosen action (explore) or the greedy best action (exploit).); deserialize (Parse a JSON Q-table string and overwrite the current table; returns error on shape mismatch.); end_episode (Decay epsilon and increment `episode_count`; call once at the end of each episode.); get_q (Return Q[state, action]; returns 0.0 if indices are out of bounds.); learn (Apply a Bellman update: `Q[s,a] ← Q[s,a] + α(r + γ·max Q[s'] − Q[s,a])`.); new (Create a zeroed Q-table for `state_count` states and `action_count` actions.); serialize (Serialize the Q-table to a compact JSON string `[[row0], [row1], ...]`.); set_q (Set Q[state, action] to `value`; no-op if indices are out of bounds.)
- `LstmLayer` (`struct`, `recurrent.rs`): CPU LSTM layer with combined gate matrices. Details: fields: input_size: usize, hidden_size: usize, w_gate: Vec<f32>, u_gate: Vec<f32>, b_gate: Vec<f32> | methods: new (Create a zero-initialized LSTM layer.); step (Execute one recurrent step.)
- `GruLayer` (`struct`, `recurrent.rs`): CPU GRU layer with combined gate matrices. Details: fields: input_size: usize, hidden_size: usize, w_gate: Vec<f32>, u_gate: Vec<f32>, b_gate: Vec<f32> | methods: new (Create a zero-initialized GRU layer.); step (Execute one recurrent step.)
- `LurekTensor` (`struct`, `tensor.rs`): Flat f32 tensor with explicit row-major shape metadata. Details: fields: shape: Vec<usize>, data: Vec<f32> | methods: flat_index (Convert multi-dimensional zero-based indices to a flat row-major offset.); flatten (Return a flattened copy with shape `[len]`.); get_element (Return the element at the given multi-dimensional indices (zero-based, row-major).); is_empty (True when there are no elements.); len (Returns the total number of tensor elements.); new (Create a tensor with the given `shape` and flat `data`.); to_tract_tensor (Build a tract `Tensor` from this handle for use as a model input.); zeros (Create a zero-filled tensor for the given `shape`.)
- `LayerNorm` (`struct`, `transformer.rs`): Layer normalization over a single model vector. Details: fields: d_model: usize, gamma: Vec<f32>, beta: Vec<f32>, epsilon: f32 | methods: forward_tensor (Normalize tensor rows for shape `[S,D]`.); forward_vec (Normalize one vector of length `d_model`.); new (Create layer norm with identity scale and zero bias.)
- `TransformerEncoderBlock` (`struct`, `transformer.rs`): Standard transformer encoder block. Details: fields: attention: MultiHeadAttention, norm1: LayerNorm, norm2: LayerNorm, ffn_w1: Vec<f32>, ffn_b1: Vec<f32>, ffn_w2: Vec<f32>, ffn_b2: Vec<f32>, d_model: usize, d_ff: usize | methods: forward (Forward pass for one encoder block.); new (Create a zero-initialized encoder block.)
- `TransformerDecoderBlock` (`struct`, `transformer.rs`): Transformer decoder block with self-attention and encoder cross-attention. Details: fields: self_attention: MultiHeadAttention, cross_attention: MultiHeadAttention, norm1: LayerNorm, norm2: LayerNorm, norm3: LayerNorm, ffn_w1: Vec<f32>, ffn_b1: Vec<f32>, ffn_w2: Vec<f32>, ffn_b2: Vec<f32>, d_model: usize, d_ff: usize | methods: forward (Forward pass for one decoder block.); new (Create a zero-initialized decoder block.)

## Functions

- `PositionalEncoding::new` (`attention.rs`): Precompute positional encoding table.
- `PositionalEncoding::apply` (`attention.rs`): Add positional vectors in-place.
- `MultiHeadAttention::new` (`attention.rs`): Create a zero-initialized MHA block.
- `MultiHeadAttention::forward` (`attention.rs`): Run self-attention on `x` with shape `[S,D]`.
- `BanditArm::mean_reward` (`bandit.rs`): Return the empirical mean reward; returns 0.5 before the first pull.
- `Bandit::new` (`bandit.rs`): Create a bandit with `arm_count` arms and a fixed RNG seed.
- `Bandit::arm_count` (`bandit.rs`): Return the number of available arms.
- `Bandit::select` (`bandit.rs`): Select an arm index according to the current strategy.
- `Bandit::update` (`bandit.rs`): Update the chosen arm with an observed reward in the range `[0, 1]`.
- `Bandit::best_arm` (`bandit.rs`): Return the greedy best arm by empirical mean reward.
- `Bandit::reset` (`bandit.rs`): Reset all arm statistics and the total pull counter.
- `Conv2D::new` (`conv.rs`): Create a zero-initialized convolution layer.
- `Conv2D::forward` (`conv.rs`): Run convolution over one input tensor shaped `[C, H, W]`.
- `MaxPool2D::new` (`conv.rs`): Create max pool layer.
- `MaxPool2D::forward` (`conv.rs`): Run max pooling.
- `NeuralBlock::param_count` (`engine.rs`): Trainable parameter count for this block.
- `NeuralBlock::set_weights` (`engine.rs`): Load trainable parameters for this block.
- `NeuralBlock::get_weights` (`engine.rs`): Export trainable parameters for this block.
- `LurekNeuralEngine::new` (`engine.rs`): Create an empty engine.
- `LurekNeuralEngine::add_block` (`engine.rs`): Append one block.
- `LurekNeuralEngine::blocks` (`engine.rs`): Immutable block access.
- `LurekNeuralEngine::blocks_mut` (`engine.rs`): Mutable block access.
- `LurekNeuralEngine::block_count` (`engine.rs`): Number of blocks in the engine.
- `LurekNeuralEngine::param_count` (`engine.rs`): Total trainable parameter count across all blocks.
- `LurekNeuralEngine::set_weights` (`engine.rs`): Load a flat parameter buffer and split it across blocks in insertion order.
- `LurekNeuralEngine::get_weights` (`engine.rs`): Export all trainable parameters in block insertion order.
- `FrameStack::new` (`env.rs`): Creates a new empty frame stack with the given capacity.
- `FrameStack::push` (`env.rs`): Pushes an observation, discarding the oldest if at capacity.
- `FrameStack::get` (`env.rs`): Returns the flattened stack.
- `FrameStack::reset` (`env.rs`): Clears all stored frames and resets the observed dimension.
- `FrameStack::capacity` (`env.rs`): Returns the maximum number of frames retained.
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
- `OnnxModel::load` (`onnx.rs`): Load an ONNX model from `path`, optimise it, and return a runnable handle.
- `OnnxModel::run` (`onnx.rs`): Run inference on `inputs`, returning one `LurekTensor` per model output.
- `OnnxModel::input_count` (`onnx.rs`): Number of input tensors expected by the model.
- `OnnxModel::output_count` (`onnx.rs`): Number of output tensors produced by the model.
- `QLearner::new` (`qlearner.rs`): Create a zeroed Q-table for `state_count` states and `action_count` actions.
- `QLearner::choose_action` (`qlearner.rs`): Return a randomly chosen action (explore) or the greedy best action (exploit).
- `QLearner::best_action` (`qlearner.rs`): Return the action with the highest Q-value for `state`; ties broken by index.
- `QLearner::learn` (`qlearner.rs`): Apply a Bellman update: `Q[s,a] ← Q[s,a] + α(r + γ·max Q[s'] − Q[s,a])`.
- `QLearner::end_episode` (`qlearner.rs`): Decay epsilon and increment `episode_count`; call once at the end of each episode.
- `QLearner::get_q` (`qlearner.rs`): Return Q[state, action]; returns 0.0 if indices are out of bounds.
- `QLearner::set_q` (`qlearner.rs`): Set Q[state, action] to `value`; no-op if indices are out of bounds.
- `QLearner::serialize` (`qlearner.rs`): Serialize the Q-table to a compact JSON string `[[row0], [row1], ...]`.
- `QLearner::deserialize` (`qlearner.rs`): Parse a JSON Q-table string and overwrite the current table; returns error on shape mismatch.
- `LstmLayer::new` (`recurrent.rs`): Create a zero-initialized LSTM layer.
- `LstmLayer::step` (`recurrent.rs`): Execute one recurrent step.
- `GruLayer::new` (`recurrent.rs`): Create a zero-initialized GRU layer.
- `GruLayer::step` (`recurrent.rs`): Execute one recurrent step.
- `LurekTensor::new` (`tensor.rs`): Create a tensor with the given `shape` and flat `data`.
- `LurekTensor::zeros` (`tensor.rs`): Create a zero-filled tensor for the given `shape`.
- `LurekTensor::len` (`tensor.rs`): Returns the total number of tensor elements.
- `LurekTensor::is_empty` (`tensor.rs`): True when there are no elements.
- `LurekTensor::get_element` (`tensor.rs`): Return the element at the given multi-dimensional indices (zero-based, row-major).
- `LurekTensor::flat_index` (`tensor.rs`): Convert multi-dimensional zero-based indices to a flat row-major offset.
- `LurekTensor::flatten` (`tensor.rs`): Return a flattened copy with shape `[len]`.
- `LurekTensor::to_tract_tensor` (`tensor.rs`): Build a tract `Tensor` from this handle for use as a model input.
- `gemm` (`tensor.rs`): Multiply matrix A `[m x k]` by matrix B `[k x n]` and optionally add a bias `[n]`.
- `LayerNorm::new` (`transformer.rs`): Create layer norm with identity scale and zero bias.
- `LayerNorm::forward_vec` (`transformer.rs`): Normalize one vector of length `d_model`.
- `LayerNorm::forward_tensor` (`transformer.rs`): Normalize tensor rows for shape `[S,D]`.
- `TransformerEncoderBlock::new` (`transformer.rs`): Create a zero-initialized encoder block.
- `TransformerEncoderBlock::forward` (`transformer.rs`): Forward pass for one encoder block.
- `TransformerDecoderBlock::new` (`transformer.rs`): Create a zero-initialized decoder block.
- `TransformerDecoderBlock::forward` (`transformer.rs`): Forward pass for one decoder block.

## Lua API Reference

### Functions

- `lurek.learning.defineEnv(config) -> LEnv`: Defines a Lua-described RL environment from a config table.
- `lurek.learning.frameStack(n) -> LFrameStack`: Creates a frame-stacking ring buffer of the last n observations.
- `lurek.learning.loadOnnx(path) -> LOnnxModel`: Loads and optimises an ONNX model from a file path.
- `lurek.learning.newBandit(arm_count, strategy, epsilon, seed) -> LBandit`: Creates a multi-armed bandit with a named selection strategy.
- `lurek.learning.newConv2D(in_channels, out_channels, kernel_h, kernel_w, stride_h, stride_w, pad_h, pad_w) -> LConv2D`: Creates a Conv2D layer wrapper for deterministic CPU spatial inference.
- `lurek.learning.newEngine() -> LNeuralEngine`: Creates an empty heterogeneous neural engine.
- `lurek.learning.newGeneticAlgorithm(pop_size, gene_count, seed) -> LGeneticAlgorithm`: Creates a genetic algorithm population with fixed chromosome length.
- `lurek.learning.newGru(input_size, hidden_size) -> LGRU`: Creates a stateful GRU layer wrapper.
- `lurek.learning.newLstm(input_size, hidden_size) -> LLSTM`: Creates a stateful LSTM layer wrapper.
- `lurek.learning.newMaxPool2D(kernel_h, kernel_w, stride_h, stride_w) -> LMaxPool2D`: Creates a MaxPool2D layer wrapper.
- `lurek.learning.newMultiHeadAttention(d_model, num_heads) -> LMultiHeadAttention`: Creates a multi-head attention block.
- `lurek.learning.newNeuralNet() -> LNeuralNet`: Creates an empty feed-forward neural network.
- `lurek.learning.newNeuroevolution(layer_spec, pop_size, seed) -> LNeuroevolution`: Creates a neuroevolution population from a layer specification table.
- `lurek.learning.newPositionalEncoding(d_model, max_len) -> LPositionalEncoding`: Creates a sinusoidal positional encoding helper.
- `lurek.learning.newQLearner(sc, ac) -> LQLearner`: Creates a Q-learner with fixed state and action counts.
- `lurek.learning.newTensor(shape, data) -> LTensor`: Creates a tensor from a shape (integer array) and flat float data (number array).
- `lurek.learning.newTransformerDecoder(d_model, num_heads, d_ff) -> LTransformerDecoder`: Creates a transformer decoder block.
- `lurek.learning.newTransformerEncoder(d_model, num_heads, d_ff) -> LTransformerEncoder`: Creates a transformer encoder block.
- `lurek.learning.normalizeEnv(env, mean, std) -> LEnv`: Wraps an LEnv so observations are normalised by subtracting mean and dividing by std.
- `lurek.learning.timeLimit(env, max_steps) -> LEnv`: Wraps an LEnv so episodes end automatically after max_steps steps.
- `lurek.learning.wrap(model) -> LModel`: Wraps a supported model (LQLearner, LNeuralNet, or LBandit) in a uniform LModel interface.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LBandit Type

- Lua handle for multi-armed bandit action selection.

##### Fields

- No documented fields.

##### Methods

- `LBandit:armCount() -> integer`: Returns the number of arms in this bandit.
- `LBandit:bestArm() -> integer`: Returns the arm with the best current estimate.
- `LBandit:predict() -> integer`: Alias for `select`. Selects an arm using the configured bandit strategy.
- `LBandit:reset() -> nil`: Resets all bandit arm statistics. This method is available to Lua scripts.
- `LBandit:select() -> integer`: Selects an arm using the configured bandit strategy.
- `LBandit:totalPulls() -> integer`: Returns the total number of arm selections recorded by this bandit.
- `LBandit:type() -> string`: Returns the Lua-visible type name for this bandit handle.
- `LBandit:typeOf(name) -> boolean`: Returns whether this bandit handle matches a supported type name.
- `LBandit:update(idx, reward) -> nil`: Updates one arm with a received reward.

#### LConv2D Type

- Lua wrapper over `Conv2D` for deterministic spatial inference and weight roundtrips.

##### Fields

- No documented fields.

##### Methods

- `LConv2D:forward(input) -> LTensor`: Runs convolution over an input tensor shaped as `[channels,height,width]`.
- `LConv2D:getWeights() -> table`: Exports flattened convolution weights and biases from this layer.
- `LConv2D:paramCount() -> integer`: Returns trainable parameter count for this Conv2D layer.
- `LConv2D:setWeights(weights) -> boolean`: Loads flattened convolution weights and biases into this layer.
- `LConv2D:type() -> string`: Returns the Lua-visible type name for this wrapper.
- `LConv2D:typeOf(name) -> boolean`: Returns whether this userdata matches the requested type string.

#### LEnv Type

- Flat RL environment handle. Stores Lua callbacks and optional wrapping layers.

##### Fields

- No documented fields.

##### Methods

- `LEnv:actionSpace() -> table`: Returns the action space descriptor.
- `LEnv:obsSpace() -> table`: Returns the observation space descriptor.
- `LEnv:reset() -> number[]`: Resets the environment and returns the initial observation.
- `LEnv:step(action) -> number[]`: Advances the environment one step.
- `LEnv:type() -> string`: Returns this environment wrapper's type name `"LEnv"`.
- `LEnv:typeOf(name) -> boolean`: Returns whether this env handle matches a supported type name.

#### LFrameStack Type

- Lua handle wrapping a frame-stacking ring buffer.

##### Fields

- No documented fields.

##### Methods

- `LFrameStack:capacity() -> integer`: Returns the maximum number of frames retained.
- `LFrameStack:get() -> number[]`: Returns the flattened observation stack, zero-padded when not yet full.
- `LFrameStack:push(obs) -> nil`: Pushes one observation into the stack.
- `LFrameStack:reset() -> nil`: Clears all stored observation frames from the stack.
- `LFrameStack:type() -> string`: Returns the type name `"LFrameStack"`.
- `LFrameStack:typeOf(name) -> boolean`: Returns whether this frame stack handle matches a supported type name.

#### LGRU Type

- Stateful Lua wrapper over `GruLayer` with a mutable recurrent hidden-state buffer.

##### Fields

- No documented fields.

##### Methods

- `LGRU:forward(input) -> table`: Runs one GRU recurrent step on input data and returns next hidden state values.
- `LGRU:getWeights() -> table`: Exports flattened layer weights and biases from the wrapped GRU layer.
- `LGRU:paramCount() -> integer`: Returns trainable parameter count for this GRU layer.
- `LGRU:reset() -> nil`: Resets the recurrent hidden state buffer to zeros.
- `LGRU:setWeights(weights) -> boolean`: Loads flattened layer weights and biases into the wrapped GRU layer.
- `LGRU:type() -> string`: Returns the Lua-visible type name for this wrapper.
- `LGRU:typeOf(name) -> boolean`: Returns whether this userdata matches the requested type string.

#### LGeneticAlgorithm Type

- Lua handle for a floating-point genetic algorithm population.

##### Fields

- No documented fields.

##### Methods

- `LGeneticAlgorithm:bestGenes() -> number[]`: Returns the genes for the best chromosome in the population.
- `LGeneticAlgorithm:evolve() -> nil`: Advances the genetic algorithm by one generation.
- `LGeneticAlgorithm:generation() -> integer`: Returns the current generation index.
- `LGeneticAlgorithm:getGenes(idx) -> number[]`: Returns the genes for a chromosome by zero-based index.
- `LGeneticAlgorithm:popSize() -> integer`: Returns the population size. This method is available to Lua scripts.
- `LGeneticAlgorithm:setFitness(idx, fitness) -> nil`: Sets the fitness value for a chromosome by zero-based index.
- `LGeneticAlgorithm:type() -> string`: Returns the Lua-visible type name for this genetic algorithm handle.
- `LGeneticAlgorithm:typeOf(name) -> boolean`: Returns whether this genetic algorithm handle matches a supported type name.

#### LLSTM Type

- Stateful Lua wrapper over `LstmLayer` with recurrent hidden and cell state buffers.

##### Fields

- No documented fields.

##### Methods

- `LLSTM:forward(input) -> table`: Runs one LSTM recurrent step on input data and returns next hidden state values.
- `LLSTM:getWeights() -> table`: Exports flattened layer weights and biases from the wrapped LSTM layer.
- `LLSTM:paramCount() -> integer`: Returns trainable parameter count for this LSTM layer.
- `LLSTM:reset() -> nil`: Resets both hidden and cell recurrent state buffers to zeros.
- `LLSTM:setWeights(weights) -> boolean`: Loads flattened layer weights and biases into the wrapped LSTM layer.
- `LLSTM:type() -> string`: Returns the Lua-visible type name for this wrapper.
- `LLSTM:typeOf(name) -> boolean`: Returns whether this userdata matches the requested type string.

#### LMaxPool2D Type

- Lua wrapper over `MaxPool2D` for deterministic non-trainable spatial downsampling.

##### Fields

- No documented fields.

##### Methods

- `LMaxPool2D:forward(input) -> LTensor`: Runs max-pooling over an input tensor shaped as `[channels,height,width]`.
- `LMaxPool2D:type() -> string`: Returns the Lua-visible type name for this wrapper.
- `LMaxPool2D:typeOf(name) -> boolean`: Returns whether this userdata matches the requested type string.

#### LModel Type

- Wraps a supported model (LQLearner, LNeuralNet, or LBandit) in a uniform LModel interface.

##### Fields

- No documented fields.

##### Methods

- `LModel:predict(input) -> integer, table`: Runs the wrapped model's prediction. Delegates to `chooseAction`, `forward`, or `select`
- `LModel:type() -> string`: Returns this wrapper's stable type name `"LModel"`.
- `LModel:typeOf(name) -> boolean`: Returns whether this model wrapper matches a supported type name.

#### LMultiHeadAttention Type

- Lua wrapper over `MultiHeadAttention`.

##### Fields

- No documented fields.

##### Methods

- `LMultiHeadAttention:forward(input) -> LTensor`: Runs multi-head self-attention over an input tensor shaped as `[seq_len,d_model]`.
- `LMultiHeadAttention:getWeights() -> table`: Exports flattened projection weights and biases from this MHA block.
- `LMultiHeadAttention:paramCount() -> integer`: Returns trainable parameter count for this MHA block.
- `LMultiHeadAttention:setWeights(weights) -> boolean`: Loads flattened projection weights and biases into this MHA block.
- `LMultiHeadAttention:type() -> string`: Returns the Lua-visible type name for this wrapper.
- `LMultiHeadAttention:typeOf(name) -> boolean`: Returns whether this userdata matches the requested type string.

#### LNeuralEngine Type

- Lua wrapper over a heterogeneous neural engine with flat parameter packing.

##### Fields

- No documented fields.

##### Methods

- `LNeuralEngine:addConv2D(in_channels, out_channels, kernel_h, kernel_w, stride_h?, stride_w?, pad_h?, pad_w?) -> nil`: Appends a Conv2D block.
- `LNeuralEngine:addDense(inputs, outputs, activation?) -> nil`: Appends a dense neural layer block.
- `LNeuralEngine:addMaxPool2D(kernel_h, kernel_w, stride_h?, stride_w?) -> nil`: Appends a non-trainable MaxPool2D block.
- `LNeuralEngine:addTransformerEncoder(d_model, heads, ff_hidden) -> nil`: Appends a transformer encoder block.
- `LNeuralEngine:blockCount() -> integer`: Returns the number of blocks in this engine.
- `LNeuralEngine:getWeights() -> number[]`: Returns all trainable parameters in block insertion order.
- `LNeuralEngine:paramCount() -> integer`: Returns the total trainable parameter count.
- `LNeuralEngine:setWeights(weights) -> boolean`: Replaces all trainable parameters from a flat numeric array.
- `LNeuralEngine:type() -> string`: Returns the Lua-visible type name for this neural engine handle.
- `LNeuralEngine:typeOf(name) -> boolean`: Returns whether this neural engine handle matches a supported type name.

#### LNeuralNet Type

- Lua handle for a feed-forward neural network.

##### Fields

- No documented fields.

##### Methods

- `LNeuralNet:addLayer(inputs, outputs, activation) -> nil`: Adds a neural network layer with an activation function.
- `LNeuralNet:forward(input) -> number[]`: Runs a forward pass and returns output values.
- `LNeuralNet:getWeights() -> number[]`: Returns the network weights as a flat numeric array.
- `LNeuralNet:layerCount() -> integer`: Returns the number of layers in the network.
- `LNeuralNet:paramCount() -> integer`: Returns the total number of trainable parameters.
- `LNeuralNet:predict(input) -> number[]`: Alias for `forward`. Runs a forward pass and returns output values.
- `LNeuralNet:setWeights(weights) -> boolean`: Replaces the network weights from a flat numeric array.
- `LNeuralNet:type() -> string`: Returns the Lua-visible type name for this neural network handle.
- `LNeuralNet:typeOf(name) -> boolean`: Returns whether this neural network handle matches a supported type name.

#### LNeuroevolution Type

- Lua handle for evolving neural network chromosomes.

##### Fields

- No documented fields.

##### Methods

- `LNeuroevolution:bestFitness() -> number`: Returns the best fitness value in the population.
- `LNeuroevolution:bestNetwork() -> LNeuralNet`: Converts the best chromosome into a neural network handle when one exists.
- `LNeuroevolution:chromosomeToNet(idx) -> LNeuralNet`: Converts one chromosome into a neural network handle when the index is valid.
- `LNeuroevolution:evolve() -> nil`: Advances the neuroevolution population by one generation.
- `LNeuroevolution:generation() -> integer`: Returns the current generation index.
- `LNeuroevolution:popSize() -> integer`: Returns the population size. This method is available to Lua scripts.
- `LNeuroevolution:setFitness(idx, fitness) -> nil`: Sets the fitness value for a chromosome by zero-based index.
- `LNeuroevolution:type() -> string`: Returns the Lua-visible type name for this neuroevolution handle.
- `LNeuroevolution:typeOf(name) -> boolean`: Returns whether this neuroevolution handle matches a supported type name.

#### LOnnxModel Type

- ONNX model handle that wraps a tract runnable plan for Lua-driven inference.

##### Fields

- No documented fields.

##### Methods

- `LOnnxModel:inputCount() -> integer`: Returns the number of input tensors expected by the model.
- `LOnnxModel:outputCount() -> integer`: Returns the number of output tensors produced by the model.
- `LOnnxModel:run(inputs) -> table`: Runs inference on a table of LTensor inputs and returns a table of LTensor outputs.
- `LOnnxModel:type() -> string`: Returns the type name `"LOnnxModel"`.
- `LOnnxModel:typeOf(name) -> boolean`: Returns whether this model handle matches a supported type name.

#### LPositionalEncoding Type

- Lua wrapper over `PositionalEncoding`.

##### Fields

- No documented fields.

##### Methods

- `LPositionalEncoding:apply(input) -> LTensor`: Applies sinusoidal positional encoding values to a `[seq_len,d_model]` tensor.
- `LPositionalEncoding:type() -> string`: Returns the Lua-visible type name for this wrapper.
- `LPositionalEncoding:typeOf(name) -> boolean`: Returns whether this userdata matches the requested type string.

#### LQLearner Type

- Lua handle for a Q-learning table with configurable exploration and learning parameters.

##### Fields

- No documented fields.

##### Methods

- `LQLearner:bestAction(state) -> integer`: Returns the highest-valued action for a one-based state index without exploration.
- `LQLearner:chooseAction(state) -> integer`: Chooses an action for a one-based state index using the learner's exploration policy.
- `LQLearner:deserialize(json) -> nil`: Replaces the Q-learner state from a JSON string.
- `LQLearner:endEpisode() -> nil`: Decays epsilon and increments the episode count.
- `LQLearner:getActionCount() -> integer`: Returns the number of actions represented by this learner.
- `LQLearner:getDiscountFactor() -> number`: Returns the Q-learning gamma discount factor.
- `LQLearner:getEpisodeCount() -> integer`: Returns the total number of episodes completed so far.
- `LQLearner:getExplorationDecay() -> number`: Returns the exploration decay multiplier.
- `LQLearner:getExplorationRate() -> number`: Returns the exploration rate used by action selection.
- `LQLearner:getLearningRate() -> number`: Returns the Q-learning alpha learning rate.
- `LQLearner:getQValue(state, action) -> number`: Returns the stored Q-value for a one-based state and action pair.
- `LQLearner:getStateCount() -> integer`: Returns the number of states represented by this learner.
- `LQLearner:learn(state, action, reward, next_state) -> nil`: Applies one Q-learning update from a transition and reward.
- `LQLearner:predict(state) -> integer`: Alias for `chooseAction`. Selects an action for the given one-based state using the learner's policy.
- `LQLearner:serialize() -> string`: Serializes the Q-learner state to a JSON string.
- `LQLearner:setDiscountFactor(v) -> nil`: Sets the Q-learning gamma discount factor.
- `LQLearner:setExplorationDecay(v) -> nil`: Sets the exploration decay multiplier applied across episodes.
- `LQLearner:setExplorationRate(v) -> nil`: Sets the exploration rate used by action selection.
- `LQLearner:setLearningRate(v) -> nil`: Sets the Q-learning alpha learning rate.
- `LQLearner:setQValue(state, action, value) -> nil`: Sets the stored Q-value for a one-based state and action pair.
- `LQLearner:type() -> string`: Returns the Lua-visible type name for this Q-learner handle.
- `LQLearner:typeOf(name) -> boolean`: Returns whether this Q-learner handle matches a supported type name.

#### LTensor Type

- Flat tensor handle exposing shape, element access, and tract conversion to Lua.

##### Fields

- No documented fields.

##### Methods

- `LTensor:data() -> number[]`: Returns all elements as a flat number array in row-major order.
- `LTensor:get(indices) -> number`: Gets a single element by one-based multi-dimensional indices.
- `LTensor:len() -> integer`: Returns the total number of elements in the tensor.
- `LTensor:shape() -> integer[]`: Returns the tensor's dimension sizes as an integer array (one entry per axis).
- `LTensor:type() -> string`: Returns the type name `"LTensor"`.
- `LTensor:typeOf(name) -> boolean`: Returns whether this tensor handle matches a supported type name.

#### LTransformerDecoder Type

- Lua wrapper over `TransformerDecoderBlock`.

##### Fields

- No documented fields.

##### Methods

- `LTransformerDecoder:forward(input, encoder_out) -> LTensor`: Runs one transformer decoder block over input and encoder-output tensors.
- `LTransformerDecoder:getWeights() -> table`: Exports flattened trainable parameters for this decoder block.
- `LTransformerDecoder:paramCount() -> integer`: Returns trainable parameter count for this decoder block.
- `LTransformerDecoder:setWeights(weights) -> boolean`: Loads flattened trainable parameters for this decoder block.
- `LTransformerDecoder:type() -> string`: Returns the Lua-visible type name for this wrapper.
- `LTransformerDecoder:typeOf(name) -> boolean`: Returns whether this userdata matches the requested type string.

#### LTransformerEncoder Type

- Lua wrapper over `TransformerEncoderBlock`.

##### Fields

- No documented fields.

##### Methods

- `LTransformerEncoder:forward(input) -> LTensor`: Runs one transformer encoder block over an input `[seq_len,d_model]` tensor.
- `LTransformerEncoder:getWeights() -> table`: Exports flattened trainable parameters for this encoder block.
- `LTransformerEncoder:paramCount() -> integer`: Returns trainable parameter count for this encoder block.
- `LTransformerEncoder:setWeights(weights) -> boolean`: Loads flattened trainable parameters for this encoder block.
- `LTransformerEncoder:type() -> string`: Returns the Lua-visible type name for this wrapper.
- `LTransformerEncoder:typeOf(name) -> boolean`: Returns whether this userdata matches the requested type string.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Notes

- No additional module-specific notes.
