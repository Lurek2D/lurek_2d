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

The module now also includes advanced neural-building blocks for CPU-first sequence and spatial inference:

- **LurekTensor + GEMM** — Row-major tensor container, flatten/index helpers, and a lightweight matrix multiply helper used by higher-level layers.
- **Conv2D / MaxPool2D** — Deterministic 2D convolution and pooling layers over `[C,H,W]` tensors.
- **LstmLayer / GruLayer** — Recurrent layers with deterministic flat-parameter layouts for neuroevolution roundtrip use.
- **PositionalEncoding / MultiHeadAttention** — Transformer attention primitives over `[S,D]` tensors.
- **TransformerEncoderBlock / TransformerDecoderBlock** — Composed attention + layernorm + FFN superblocks with flat-parameter export/import.
- **LurekNeuralEngine** — Heterogeneous block container that packs/unpacks all trainable parameters into one flat genome buffer.

All types are pure CPU, headless-testable, and have zero rendering dependencies. The module is exposed to Lua via `lurek.learning.*`.

## Files

### attention.rs

- Attention components for transformer-like sequence models.

### bandit.rs

- Compact multi-armed bandit storing per-arm reward history and posterior parameters.
- Strategy switch for epsilon-greedy, UCB1, and Thompson sampling policies.
- Selection, reward ingestion, and reset for adaptive arm choice without a planning framework.
- Internal gamma and beta sampling driven by a deterministic xorshift64 RNG.
- Per-arm pull counts, cumulative reward, and Bayesian alpha/beta parameter tracking.

### conv.rs

- Convolution and pooling layers for CPU learning pipelines.

### engine.rs

- Dynamic neural engine for composing heterogeneous learning blocks.

### env.rs

- Gym-compatible RL environment wrappers.

### evolutionary.rs

- Shared trait for layers that expose flat trainable parameters.

### genetic.rs

- Population-based genetic optimization storing genomes, fitness values, and generation bookkeeping.
- Evolution step preserving elites, tournament selection, crossover, and in-place mutation.
- Deterministic random helpers driving parent selection, crossover, and Gaussian mutation.
- Stable per-chromosome identifiers persisting across generations for lineage tracking.
- Seeded xorshift64 RNG with Box-Muller normal sampling for reproducible evolution.

### mod.rs

- Machine learning and evolutionary computation algorithms.
- This module provides standalone learning algorithms that can be used
- independently or integrated with the AI decision-making systems.
- # Submodules
- `neural_net` — Feedforward neural networks with backpropagation
- `neuroevolution` — Evolving neural network topologies
- `genetic` — Genetic algorithms with configurable crossover and mutation
- `qlearner` — Tabular Q-learning for reinforcement learning
- `bandit` — Multi-armed bandit strategies (UCB1, Thompson, epsilon-greedy)
- `env` — Gym-compatible RL environment wrappers
- `onnx` — ONNX model loading and inference via tract-onnx

### neural_net.rs

- Lightweight feed-forward neural-network with dense layers, activation modes, and flat parameters.
- Layer-local forward evaluation, activation application, and parameter counting.
- Network-level operations: append layers, run forward passes, load/export weight buffers.

### neuroevolution.rs

- Neuroevolution wrapper joining genetic algorithm with neural-network for population-based weight search.
- Template layer specification for rebuilding networks from flat chromosome genes.
- Orchestration logic mapping chromosomes to networks, recording fitness, and advancing evolution.

### onnx.rs

- ONNX model loading and inference via tract-onnx.
- Provides `OnnxModel` which loads and optimises an ONNX file into a runnable plan.
- `OnnxModel::run` converts `LurekTensor` inputs to tract `Tensor` values, runs the
- plan, and converts outputs back to `LurekTensor`, preserving output shapes.
- Used exclusively by `src/lua_api/learning_api.rs`; no game-loop dependencies.

### qlearner.rs

- Tabular Q-learning model with flat state-action value table and training parameters.
- Epsilon-greedy action selection, Bellman updates, and episode bookkeeping.
- Lightweight persistence helpers for serializing and reloading learned policies.

### recurrent.rs

- Recurrent learning layers for sequence modeling.

### tensor.rs

- Lightweight tensor helpers for learning features.
- Stores row-major tensor shape and data.
- Provides row-major index mapping and flatten helpers.
- Exposes a minimal GEMM helper used by learning layers.

### transformer.rs

- Transformer blocks built from attention, layer norm, and feed-forward layers.

## Lua API Ref

- Binding: `src/lua_api/learning_api.rs`
- Namespace: `lurek.learning`

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

### Enums

- No documented module-level enums/constants.

### Types


#### LBandit Type


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


##### Fields

- No documented fields.

##### Methods

- `LMaxPool2D:forward`: Runs max-pooling over an input tensor shaped as `[channels,height,width]`.
- `LMaxPool2D:type`: Returns the Lua-visible type name for this wrapper.
- `LMaxPool2D:typeOf`: Returns whether this userdata matches the requested type string.


#### LModel Type


##### Fields

- No documented fields.

##### Methods

- `LModel:predict`: Runs the wrapped model's prediction. Delegates to `chooseAction`, `forward`, or `select`
- `LModel:type`: Returns this wrapper's stable type name `"LModel"`.
- `LModel:typeOf`: Returns whether this model wrapper matches a supported type name.


#### LMultiHeadAttention Type


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


##### Fields

- No documented fields.

##### Methods

- `LOnnxModel:inputCount`: Returns the number of input tensors expected by the model.
- `LOnnxModel:outputCount`: Returns the number of output tensors produced by the model.
- `LOnnxModel:run`: Runs inference on a table of LTensor inputs and returns a table of LTensor outputs.
- `LOnnxModel:type`: Returns the type name `"LOnnxModel"`.
- `LOnnxModel:typeOf`: Returns whether this model handle matches a supported type name.


#### LPositionalEncoding Type


##### Fields

- No documented fields.

##### Methods

- `LPositionalEncoding:apply`: Applies sinusoidal positional encoding values to a `[seq_len,d_model]` tensor.
- `LPositionalEncoding:type`: Returns the Lua-visible type name for this wrapper.
- `LPositionalEncoding:typeOf`: Returns whether this userdata matches the requested type string.


#### LQLearner Type


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


##### Fields

- No documented fields.

##### Methods

- `LTransformerEncoder:forward`: Runs one transformer encoder block over an input `[seq_len,d_model]` tensor.
- `LTransformerEncoder:getWeights`: Exports flattened trainable parameters for this encoder block.
- `LTransformerEncoder:paramCount`: Returns trainable parameter count for this encoder block.
- `LTransformerEncoder:setWeights`: Loads flattened trainable parameters for this encoder block.
- `LTransformerEncoder:type`: Returns the Lua-visible type name for this wrapper.
- `LTransformerEncoder:typeOf`: Returns whether this userdata matches the requested type string.

## References

- No top-level `crate::<module>` imports were detected in this module's Rust source files.
