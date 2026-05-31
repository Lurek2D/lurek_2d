# learning

## TL;DR

- Manages dynamic neural nets, attention blocks, transformers, and flat tensor buffers.
- Supports genetic algorithms, neuroevolution, bandits, tabular Q-learning, and ONNX models.

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

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

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

- Provides reinforcement-learning environment wrappers modeled after common Gym-like conventions.
- Describes action and observation spaces with bounded metadata suitable for generic agents.
- Includes frame-stack helpers that accumulate temporal context for history-dependent policies.
- Standardizes reset and step-style interaction shapes for training and evaluation loops.

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

- Defines lightweight tensor containers and helpers used by learning components.
- Stores shape metadata and flat row-major data for predictable indexing behavior.
- Provides indexing, flattening, and conversion utilities needed by model layers.
- Includes compact numeric operations that support CPU learning pipelines.

### transformer.rs

- Implements transformer-style blocks composed from attention, normalization, and feed-forward stages.
- Defines encoder and decoder building units operating over engine-native tensor structures.
- Applies residual pathways and normalization flows for stable sequence representation updates.
- Stores trainable parameters in flat vectors to align with evolutionary optimization tooling.
- Coordinates multi-stage forward execution across attention and projection subcomponents.
- Provides reusable transformer primitives for sequence learning and inference experiments.
- Integrates with the wider learning stack through common tensor and layer contracts.

## Lua API Ref

### Functions

- `lurek.learning.defineEnv(config) -> LEnv`: Defines a Lua-described RL environment from a config table.
- `lurek.learning.frameStack(n) -> LFrameStack`: Creates a frame-stacking ring buffer of the last n observations.
- `lurek.learning.loadOnnx(path) -> LOnnxModel`: Loads and optimises an ONNX model from a file path.
- `lurek.learning.newBandit(arm_count, strategy, epsilon, seed) -> LBandit`: Creates a multi-armed bandit with a named selection strategy.
- `lurek.learning.newConv2D(in_channels, out_channels, kernel_h, kernel_w, stride_h, stride_w, pad_h, pad_w) -> LConv2D`: Creates a Conv2D layer wrapper for deterministic CPU spatial inference.
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
