# learning

## TL;DR

- The `learning` module provides CPU-first machine learning primitives, from bandits and Q-learning to neural, recurrent, and transformer blocks with evolutionary optimization support.

## General Info

- Module group: `Feature Systems`
- Source path: `src/learning/`
- Binding: `src/lua_api/learning_api.rs`
- Namespace: `lurek.learning`
- Lua API surface: `20` functions, `18` types, `127` methods
- Rust test path(s): tests/rust/unit/learning_tests.rs
- Lua test path(s): tests/lua/unit/test_learning_core_unit.lua

## Summary

The `learning` module is the engine's standalone machine-learning toolkit. It provides reusable CPU-side algorithms that can run independently from high-level AI planners, so teams can apply learning workflows in gameplay logic, balancing systems, and analytics tools.

Its practical range includes lightweight online methods and deeper model building blocks. Bandits and tabular Q-learning support quick adaptive decisions, while feed-forward networks, convolution layers, recurrent layers, and transformer components support richer inference pipelines.

Evolutionary optimization is built into the same surface. Genetic search, neuroevolution orchestration, and flat-parameter interfaces let models be trained or tuned through population-based workflows without custom glue around each layer type.

A shared tensor foundation keeps data movement consistent across modules. Core tensor and matrix helpers, layer parameter packing, and import/export paths allow different model components to interoperate under one runtime contract.

The module is designed for deterministic, headless, CPU-first operation. This makes it practical for test pipelines, reproducible experiments, and runtime systems where predictable behavior matters more than external ML stack complexity.

Integration flexibility is another key benefit. Different systems can start with simple methods like bandits or tabular learners, then scale up to recurrent or attention-based models without leaving the same module surface or rewriting surrounding data plumbing.

Because parameter handling is standardized, experimentation and deployment use the same model lifecycle. Teams can iterate in controlled training loops, export stable state, and reuse those artifacts in live gameplay or tooling runs with minimal friction.

In practice, `lurek.learning` gives one complete learning workspace: define environments, build models, run inference, evolve parameters, and persist state through consistent Lua-facing APIs.

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

- `lurek.learning.defineEnv`: Defines a Lua-described RL environment from a config table.
- `lurek.learning.frameStack`: Creates a frame-stacking ring buffer of the last n observations.
- `lurek.learning.loadOnnx`: Loads and optimises an ONNX model from a file path.
- `lurek.learning.newBandit`: Creates a multi-armed bandit with a named selection strategy.
- `lurek.learning.newConv2D`: Creates a Conv2D layer wrapper for deterministic CPU spatial inference.
- `lurek.learning.newGeneticAlgorithm`: Creates a genetic algorithm population with fixed chromosome length.
- `lurek.learning.newGru`: Creates a stateful GRU layer wrapper.
- `lurek.learning.newLstm`: Creates a stateful LSTM layer wrapper.
- `lurek.learning.newMaxPool2D`: Creates a MaxPool2D layer wrapper.
- `lurek.learning.newMultiHeadAttention`: Creates a multi-head attention block.
- `lurek.learning.newNeuralNet`: Creates an empty feed-forward neural network.
- `lurek.learning.newNeuroevolution`: Creates a neuroevolution population from a layer specification table.
- `lurek.learning.newPositionalEncoding`: Creates a sinusoidal positional encoding helper.
- `lurek.learning.newQLearner`: Creates a Q-learner with fixed state and action counts.
- `lurek.learning.newTensor`: Creates a tensor from a shape (integer array) and flat float data (number array).
- `lurek.learning.newTransformerDecoder`: Creates a transformer decoder block.
- `lurek.learning.newTransformerEncoder`: Creates a transformer encoder block.
- `lurek.learning.normalizeEnv`: Wraps an LEnv so observations are normalised by subtracting mean and dividing by std.
- `lurek.learning.timeLimit`: Wraps an LEnv so episodes end automatically after max_steps steps.
- `lurek.learning.wrap`: Wraps a supported model (LQLearner, LNeuralNet, or LBandit) in a uniform LModel interface.

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

- `LBandit:armCount`: Returns the number of arms in this bandit.
- `LBandit:bestArm`: Returns the arm with the best current estimate.
- `LBandit:predict`: Alias for `select`. Selects an arm using the configured bandit strategy.
- `LBandit:reset`: Resets all bandit arm statistics. This method is available to Lua scripts.
- `LBandit:select`: Selects an arm using the configured bandit strategy.
- `LBandit:totalPulls`: Returns the total number of arm selections recorded by this bandit.
- `LBandit:type`: Returns the Lua-visible type name for this bandit handle.
- `LBandit:typeOf`: Returns whether this bandit handle matches a supported type name.
- `LBandit:update`: Updates one arm with a received reward.

#### LConv2D Type

- Lua wrapper over `Conv2D` for deterministic spatial inference and weight roundtrips.

##### Fields

- No documented fields.

##### Methods

- `LConv2D:forward`: Runs convolution over an input tensor shaped as `[channels,height,width]`.
- `LConv2D:getWeights`: Exports flattened convolution weights and biases from this layer.
- `LConv2D:paramCount`: Returns trainable parameter count for this Conv2D layer.
- `LConv2D:setWeights`: Loads flattened convolution weights and biases into this layer.
- `LConv2D:type`: Returns the Lua-visible type name for this wrapper.
- `LConv2D:typeOf`: Returns whether this userdata matches the requested type string.

#### LEnv Type

- Flat RL environment handle. Stores Lua callbacks and optional wrapping layers.

##### Fields

- No documented fields.

##### Methods

- `LEnv:actionSpace`: Returns the action space descriptor.
- `LEnv:obsSpace`: Returns the observation space descriptor.
- `LEnv:reset`: Resets the environment and returns the initial observation.
- `LEnv:step`: Advances the environment one step.
- `LEnv:type`: Returns this environment wrapper's type name `"LEnv"`.
- `LEnv:typeOf`: Returns whether this env handle matches a supported type name.

#### LFrameStack Type

- Lua handle wrapping a frame-stacking ring buffer.

##### Fields

- No documented fields.

##### Methods

- `LFrameStack:capacity`: Returns the maximum number of frames retained.
- `LFrameStack:get`: Returns the flattened observation stack, zero-padded when not yet full.
- `LFrameStack:push`: Pushes one observation into the stack.
- `LFrameStack:reset`: Clears all stored observation frames from the stack.
- `LFrameStack:type`: Returns the type name `"LFrameStack"`.
- `LFrameStack:typeOf`: Returns whether this frame stack handle matches a supported type name.

#### LGRU Type

- Stateful Lua wrapper over `GruLayer` with a mutable recurrent hidden-state buffer.

##### Fields

- No documented fields.

##### Methods

- `LGRU:forward`: Runs one GRU recurrent step on input data and returns next hidden state values.
- `LGRU:getWeights`: Exports flattened layer weights and biases from the wrapped GRU layer.
- `LGRU:paramCount`: Returns trainable parameter count for this GRU layer.
- `LGRU:reset`: Resets the recurrent hidden state buffer to zeros.
- `LGRU:setWeights`: Loads flattened layer weights and biases into the wrapped GRU layer.
- `LGRU:type`: Returns the Lua-visible type name for this wrapper.
- `LGRU:typeOf`: Returns whether this userdata matches the requested type string.

#### LGeneticAlgorithm Type

- Lua handle for a floating-point genetic algorithm population.

##### Fields

- No documented fields.

##### Methods

- `LGeneticAlgorithm:bestGenes`: Returns the genes for the best chromosome in the population.
- `LGeneticAlgorithm:evolve`: Advances the genetic algorithm by one generation.
- `LGeneticAlgorithm:generation`: Returns the current generation index.
- `LGeneticAlgorithm:getGenes`: Returns the genes for a chromosome by zero-based index.
- `LGeneticAlgorithm:popSize`: Returns the population size. This method is available to Lua scripts.
- `LGeneticAlgorithm:setFitness`: Sets the fitness value for a chromosome by zero-based index.
- `LGeneticAlgorithm:type`: Returns the Lua-visible type name for this genetic algorithm handle.
- `LGeneticAlgorithm:typeOf`: Returns whether this genetic algorithm handle matches a supported type name.

#### LLSTM Type

- Stateful Lua wrapper over `LstmLayer` with recurrent hidden and cell state buffers.

##### Fields

- No documented fields.

##### Methods

- `LLSTM:forward`: Runs one LSTM recurrent step on input data and returns next hidden state values.
- `LLSTM:getWeights`: Exports flattened layer weights and biases from the wrapped LSTM layer.
- `LLSTM:paramCount`: Returns trainable parameter count for this LSTM layer.
- `LLSTM:reset`: Resets both hidden and cell recurrent state buffers to zeros.
- `LLSTM:setWeights`: Loads flattened layer weights and biases into the wrapped LSTM layer.
- `LLSTM:type`: Returns the Lua-visible type name for this wrapper.
- `LLSTM:typeOf`: Returns whether this userdata matches the requested type string.

#### LMaxPool2D Type

- Lua wrapper over `MaxPool2D` for deterministic non-trainable spatial downsampling.

##### Fields

- No documented fields.

##### Methods

- `LMaxPool2D:forward`: Runs max-pooling over an input tensor shaped as `[channels,height,width]`.
- `LMaxPool2D:type`: Returns the Lua-visible type name for this wrapper.
- `LMaxPool2D:typeOf`: Returns whether this userdata matches the requested type string.

#### LModel Type

- Wraps a supported model (LQLearner, LNeuralNet, or LBandit) in a uniform LModel interface.

##### Fields

- No documented fields.

##### Methods

- `LModel:predict`: Runs the wrapped model's prediction. Delegates to `chooseAction`, `forward`, or `select`
- `LModel:type`: Returns this wrapper's stable type name `"LModel"`.
- `LModel:typeOf`: Returns whether this model wrapper matches a supported type name.

#### LMultiHeadAttention Type

- Lua wrapper over `MultiHeadAttention`.

##### Fields

- No documented fields.

##### Methods

- `LMultiHeadAttention:forward`: Runs multi-head self-attention over an input tensor shaped as `[seq_len,d_model]`.
- `LMultiHeadAttention:getWeights`: Exports flattened projection weights and biases from this MHA block.
- `LMultiHeadAttention:paramCount`: Returns trainable parameter count for this MHA block.
- `LMultiHeadAttention:setWeights`: Loads flattened projection weights and biases into this MHA block.
- `LMultiHeadAttention:type`: Returns the Lua-visible type name for this wrapper.
- `LMultiHeadAttention:typeOf`: Returns whether this userdata matches the requested type string.

#### LNeuralNet Type

- Lua handle for a feed-forward neural network.

##### Fields

- No documented fields.

##### Methods

- `LNeuralNet:addLayer`: Adds a neural network layer with an activation function.
- `LNeuralNet:forward`: Runs a forward pass and returns output values.
- `LNeuralNet:getWeights`: Returns the network weights as a flat numeric array.
- `LNeuralNet:layerCount`: Returns the number of layers in the network.
- `LNeuralNet:paramCount`: Returns the total number of trainable parameters.
- `LNeuralNet:predict`: Alias for `forward`. Runs a forward pass and returns output values.
- `LNeuralNet:setWeights`: Replaces the network weights from a flat numeric array.
- `LNeuralNet:type`: Returns the Lua-visible type name for this neural network handle.
- `LNeuralNet:typeOf`: Returns whether this neural network handle matches a supported type name.

#### LNeuroevolution Type

- Lua handle for evolving neural network chromosomes.

##### Fields

- No documented fields.

##### Methods

- `LNeuroevolution:bestFitness`: Returns the best fitness value in the population.
- `LNeuroevolution:bestNetwork`: Converts the best chromosome into a neural network handle when one exists.
- `LNeuroevolution:chromosomeToNet`: Converts one chromosome into a neural network handle when the index is valid.
- `LNeuroevolution:evolve`: Advances the neuroevolution population by one generation.
- `LNeuroevolution:generation`: Returns the current generation index.
- `LNeuroevolution:popSize`: Returns the population size. This method is available to Lua scripts.
- `LNeuroevolution:setFitness`: Sets the fitness value for a chromosome by zero-based index.
- `LNeuroevolution:type`: Returns the Lua-visible type name for this neuroevolution handle.
- `LNeuroevolution:typeOf`: Returns whether this neuroevolution handle matches a supported type name.

#### LOnnxModel Type

- ONNX model handle that wraps a tract runnable plan for Lua-driven inference.

##### Fields

- No documented fields.

##### Methods

- `LOnnxModel:inputCount`: Returns the number of input tensors expected by the model.
- `LOnnxModel:outputCount`: Returns the number of output tensors produced by the model.
- `LOnnxModel:run`: Runs inference on a table of LTensor inputs and returns a table of LTensor outputs.
- `LOnnxModel:type`: Returns the type name `"LOnnxModel"`.
- `LOnnxModel:typeOf`: Returns whether this model handle matches a supported type name.

#### LPositionalEncoding Type

- Lua wrapper over `PositionalEncoding`.

##### Fields

- No documented fields.

##### Methods

- `LPositionalEncoding:apply`: Applies sinusoidal positional encoding values to a `[seq_len,d_model]` tensor.
- `LPositionalEncoding:type`: Returns the Lua-visible type name for this wrapper.
- `LPositionalEncoding:typeOf`: Returns whether this userdata matches the requested type string.

#### LQLearner Type

- Lua handle for a Q-learning table with configurable exploration and learning parameters.

##### Fields

- No documented fields.

##### Methods

- `LQLearner:bestAction`: Returns the highest-valued action for a one-based state index without exploration.
- `LQLearner:chooseAction`: Chooses an action for a one-based state index using the learner's exploration policy.
- `LQLearner:deserialize`: Replaces the Q-learner state from a JSON string.
- `LQLearner:endEpisode`: Decays epsilon and increments the episode count.
- `LQLearner:getActionCount`: Returns the number of actions represented by this learner.
- `LQLearner:getDiscountFactor`: Returns the Q-learning gamma discount factor.
- `LQLearner:getEpisodeCount`: Returns the total number of episodes completed so far.
- `LQLearner:getExplorationDecay`: Returns the exploration decay multiplier.
- `LQLearner:getExplorationRate`: Returns the exploration rate used by action selection.
- `LQLearner:getLearningRate`: Returns the Q-learning alpha learning rate.
- `LQLearner:getQValue`: Returns the stored Q-value for a one-based state and action pair.
- `LQLearner:getStateCount`: Returns the number of states represented by this learner.
- `LQLearner:learn`: Applies one Q-learning update from a transition and reward.
- `LQLearner:predict`: Alias for `chooseAction`. Selects an action for the given one-based state using the learner's policy.
- `LQLearner:serialize`: Serializes the Q-learner state to a JSON string.
- `LQLearner:setDiscountFactor`: Sets the Q-learning gamma discount factor.
- `LQLearner:setExplorationDecay`: Sets the exploration decay multiplier applied across episodes.
- `LQLearner:setExplorationRate`: Sets the exploration rate used by action selection.
- `LQLearner:setLearningRate`: Sets the Q-learning alpha learning rate.
- `LQLearner:setQValue`: Sets the stored Q-value for a one-based state and action pair.
- `LQLearner:type`: Returns the Lua-visible type name for this Q-learner handle.
- `LQLearner:typeOf`: Returns whether this Q-learner handle matches a supported type name.

#### LTensor Type

- Flat tensor handle exposing shape, element access, and tract conversion to Lua.

##### Fields

- No documented fields.

##### Methods

- `LTensor:data`: Returns all elements as a flat number array in row-major order.
- `LTensor:get`: Gets a single element by one-based multi-dimensional indices.
- `LTensor:len`: Returns the total number of elements in the tensor.
- `LTensor:shape`: Returns the tensor's dimension sizes as an integer array (one entry per axis).
- `LTensor:type`: Returns the type name `"LTensor"`.
- `LTensor:typeOf`: Returns whether this tensor handle matches a supported type name.

#### LTransformerDecoder Type

- Lua wrapper over `TransformerDecoderBlock`.

##### Fields

- No documented fields.

##### Methods

- `LTransformerDecoder:forward`: Runs one transformer decoder block over input and encoder-output tensors.
- `LTransformerDecoder:getWeights`: Exports flattened trainable parameters for this decoder block.
- `LTransformerDecoder:paramCount`: Returns trainable parameter count for this decoder block.
- `LTransformerDecoder:setWeights`: Loads flattened trainable parameters for this decoder block.
- `LTransformerDecoder:type`: Returns the Lua-visible type name for this wrapper.
- `LTransformerDecoder:typeOf`: Returns whether this userdata matches the requested type string.

#### LTransformerEncoder Type

- Lua wrapper over `TransformerEncoderBlock`.

##### Fields

- No documented fields.

##### Methods

- `LTransformerEncoder:forward`: Runs one transformer encoder block over an input `[seq_len,d_model]` tensor.
- `LTransformerEncoder:getWeights`: Exports flattened trainable parameters for this encoder block.
- `LTransformerEncoder:paramCount`: Returns trainable parameter count for this encoder block.
- `LTransformerEncoder:setWeights`: Loads flattened trainable parameters for this encoder block.
- `LTransformerEncoder:type`: Returns the Lua-visible type name for this wrapper.
- `LTransformerEncoder:typeOf`: Returns whether this userdata matches the requested type string.
