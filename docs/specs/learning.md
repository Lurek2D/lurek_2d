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
- Lua test path(s): tests/lua/unit/test_learning_core_unit.lua

## Summary

- The `learning` module is the engine's machine-learning and adaptive-policy surface for users who want experimentation, inference, and lightweight training loops to live inside the same runtime as gameplay and tooling code.
- Its defining feature is breadth across learning styles. Tensor math, feedforward models, convolutional structures, recurrent logic, attention, transformer-style components, Q-learning, bandits, genetic algorithms, and neuroevolution all coexist because game-related learning problems vary widely.
- That breadth matters because one project may want inference from a pretrained model, another may want online adaptation, and another may want population-based search or discrete action learning rather than gradient-heavy end-to-end training.
- The module therefore acts less like a single ML framework and more like an engine-owned research and experimentation toolkit with several entry points.
- Environment wrappers are an important part of the feature because learning is not only about models. It is also about observations, rewards, resets, episodes, action loops, and the staged interaction between a policy and a simulated task.
- This makes the module useful for reinforcement-style experimentation where the engine itself is part of the training or evaluation environment rather than merely a host for precomputed predictions.
- ONNX loading and parameter import or export matter because useful ML workflows rarely remain entirely inside one engine. Teams often train or inspect models externally and then bring those artifacts into runtime experimentation or inference.
- Bandits, Q-learning, and evolutionary support are particularly relevant for game-like adaptation where discrete choices, heuristic search, or population exploration may be more useful than large-scale supervised training.
- Deterministic tensor and model operations are also valuable because experimentation inside a game engine still needs inspectability. Teams often need results to be partially reproducible so they can debug or compare behavior meaningfully.
- The module is therefore useful for adaptive NPC behavior, tuning agents, recommendation-like systems, simulation control, encounter balancing, and tool-side analysis of what a model would choose under engine constraints.
- It is also useful for benchmarking several policy ideas against the same engine-side tasks.
- That shared experimentation surface keeps inference, adaptation, and evaluation workflows closer to the game systems they are meant to influence.
- It keeps those experiments closer to game-side consequences and iteration loops.
- From a boundary perspective, domain modules define the world, rewards, and consequences, while `learning` owns the tensors, models, adaptation strategies, and training-oriented utilities that make machine learning usable inside that world.
- Read `learning` as the place where research-oriented AI and practical engine workflows meet.

This module is mostly self-contained inside the `Feature Systems` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### attention.rs

- This file owns positional encoding and multi-head self-attention over row-major `[sequence, model]` tensor buffers.
- `PositionalEncoding` stores a precomputed sinusoid table, while `MultiHeadAttention` stores QKV and output projections.
- Self-attention forward math lives here because score scaling, softmax normalization, and head concatenation matter.
- The block also implements `EvolutionaryLayer` so attention weights can be flattened and restored by external optimizers.
- Local `linear` and `softmax_in_place` helpers stay here because they only serve attention projection internals.
- Open it when token-mixing behavior changes; transformer composition, tensors, and training loops live in siblings.

### bandit.rs

- This file owns multi-armed bandit state, covering arm statistics, strategy selection, and reward updates over time.
- `BanditArm` stores pull counts and reward totals, while `BanditStrategy` names epsilon-greedy, UCB1, and Thompson modes.
- Action selection lives here because exploration policy, posterior sampling, and UCB math depend on arm state.
- Reward ingestion and reset logic also stay here so online learning loops mutate one consistent bandit state owner.
- Deterministic RNG and Beta or Gamma samplers are local because probabilistic arm choice is part of bandit semantics.
- Open it when exploration strategy changes; Q-learning, genomes, and neural model execution live in sibling files.

### conv.rs

- This file owns convolution and max-pooling layers over channel-first tensors used by CPU learning pipelines.
- `Conv2D` stores flat kernels and biases, while `MaxPool2D` owns pooling geometry without any trainable parameters.
- Forward passes live here because stride, padding, and pooling window semantics are specific to image-style layer math.
- `Conv2D` also implements `EvolutionaryLayer` so convolution weights can be packed for genetic or search-based training.
- Open it when spatial-layer behavior changes; tensors, dense nets, and engine orchestration live in sibling files.

### engine.rs

- This file owns the heterogeneous neural engine that chains dense, convolutional, recurrent, and transformer blocks.
- `NeuralBlock` is the tagged union over supported layer families, and `LurekNeuralEngine` owns the ordered block list.
- Flat parameter packing lives here because the engine must split one weight buffer across many different block shapes.
- This file does not define layer math; it orchestrates block storage, parameter routing, and composite-model boundaries.
- Open it when mixed-model composition changes; individual layer implementations live in their sibling owner files.

### env.rs

- This file owns small RL environment data helpers, namely `SpaceSpec` descriptors and the `FrameStack` history buffer.
- `SpaceSpec` describes observation or action bounds, while `FrameStack` flattens recent frames into context vectors.
- Padding and reset behavior live here because frame-history ownership belongs with the stack rather than with learners.
- Open it when observation-surface semantics change; policies, value tables, and neural blocks live in sibling files.

### error.rs

- This file owns typed validation and safety errors shared by learning constructors, inference, serialization, and Lua-facing helpers.
- It keeps failure reasons explicit so safe `try_*` APIs can reject invalid shapes, counts, paths, and numeric inputs consistently.
- Open it when learning callers need clearer diagnostics or when a new learning owner starts participating in the shared safety contract.

### evolutionary.rs

- This file owns the shared `EvolutionaryLayer` trait used by learning blocks that expose flat trainable parameters.
- It defines the minimal contract for counting, importing, and exporting weights so optimizers can treat layers uniformly.
- Open it when parameter-boundary semantics change; concrete layer math and training logic live in sibling files.

### genetic.rs

- This file owns population-based genetic optimization over flat chromosomes with ids, fitness, mutation, and elitism.
- `Chromosome` stores one genome, while `GeneticAlgorithm` owns the live population, RNG state, and generation counter.
- Tournament selection, crossover, mutation, and elite carryover all live here because they define reproduction semantics.
- Deterministic RNG is shared through a versioned learning RNG contract so repeated runs can reproduce the same evolution steps.
- Open it when genome evolution policy changes; neural decoding and bandit or Q-learning logic live in sibling files.

### limits.rs

- This file owns shared learning sizing and validation limits used by safe constructors, inference, and persistence helpers.
- It centralizes checked arithmetic and numeric policy so tensors, learners, genomes, and ONNX interop share one resource contract.
- Open it when ceilings or validation rules change across learning modules.

### mod.rs

- This module is the learning index, wiring tensors, dense and sequence layers, optimizers, and model adapters.
- It reexports neural, recurrent, convolutional, attention, and transformer owners from one subsystem entry point.
- `tensor.rs` owns row-major data carriers, while `evolutionary.rs` defines the flat-parameter contract shared by layers.
- `neural_net.rs`, `recurrent.rs`, `conv.rs`, and `attention.rs` implement CPU learning blocks with trainable weights.
- `transformer.rs` composes attention, norms, and feed-forward blocks, while `engine.rs` chains heterogeneous blocks.
- `genetic.rs`, `neuroevolution.rs`, `bandit.rs`, and `qlearner.rs` cover search and reinforcement loops.
- `onnx.rs` bridges external models, and `env.rs` plus `tensor.rs` define the data surfaces consumed by these learners.
- This file owns visibility and navigation only; actual math, training state, and inference behavior live in siblings.

### neural_net.rs

- This file owns dense feed-forward networks, including activations, layer storage, and ordered network assembly.
- `NeuralLayer` stores row-major weights and biases, while `Activation` centralizes the elementwise output transforms.
- Layer-by-layer forward propagation lives here because dense inference and softmax handling define this model family.
- Flat parameter import and export also live here so optimizers and neuroevolution can rebuild dense models.
- `NeuralNet` owns layer ordering and whole-network weight packing, not exploration policy, tensors, or sequence state.
- Open it when dense-model behavior changes; recurrent, convolutional, and attention-based blocks live in sibling files.

### neuroevolution.rs

- This file owns the bridge between flat genetic chromosomes and concrete dense neural-network instances.
- `Neuroevolution` stores the GA backend plus a layer template used to rebuild `NeuralNet` instances from genomes.
- Fitness assignment and generation advancement live here because this wrapper coordinates model decoding with search.
- Open it when genome-to-network mapping changes; dense layer math and raw genetic operators live in sibling files.

### onnx.rs

- This file owns ONNX model loading and inference through tract, bridging `LurekTensor` data into runnable CPU plans.
- `OnnxModel` stores the optimized tract plan plus cached input and output counts used for validation and inspection.
- Safe load and run helpers live here because external model optimization, sandboxing, and tensor conversion are this boundary.
- Open it when ONNX interop changes; native tensors and in-repo learning layers live in sibling files.

### qlearner.rs

- This file owns tabular Q-learning state, including the flat Q-table, exploration rate, and episode counters.
- `QLearner` keeps discrete state-action values in one row-major table so updates and greedy lookups stay cheap.
- Epsilon-greedy action choice, deterministic RNG state, and Bellman updates live here because they directly mutate learner-owned state.
- Serialization and deserialization also stay here so saved tables preserve dimensions, hyperparameters, and RNG state on reload.
- Open it when discrete RL policy changes; bandits, environments, and neural optimizers are owned by sibling files.

### recurrent.rs

- This file owns recurrent sequence layers, including LSTM and GRU gate storage plus single-step hidden-state updates.
- Each layer stores flattened gate matrices and biases so CPU recurrence and parameter exchange share one layout.
- `step` methods live here because gate equations, state transitions, and activation choices define recurrent behavior.
- Both layers implement `EvolutionaryLayer` locally so genomes can load and export full recurrent parameter buffers.
- No sequence batching framework lives here; the file focuses on one-step recurrent primitives for higher-level systems.
- Open it when temporal-state math changes; dense layers, attention blocks, and engine orchestration live elsewhere.

### rng.rs

- This file owns the deterministic RNG contract shared by learning components that need seedable, replayable randomness.
- It stores a small versioned state snapshot plus helpers for bounded integers, normalized floats, and Gaussian samples.
- Open it when learning reproducibility, replay restoration, or shared RNG semantics change.

### tensor.rs

- This file owns `LurekTensor`, the row-major tensor container used by ONNX, attention, convolution, and transformer code.
- It stores explicit shape metadata plus flat `f32` data, then offers indexing, flattening, zero allocation, and export.
- `gemm` also lives here because basic matrix multiply with optional bias is a shared primitive across learning layers.
- Open it when tensor layout or interop changes; model-specific forward logic lives in sibling learning files.

### transformer.rs

- This file owns transformer blocks built from attention, normalization, residual paths, and feed-forward projections.
- `LayerNorm`, encoder blocks, and decoder blocks store the trainable weights needed for CPU transformer execution.
- Encoder flow lives here because residual addition, normalization order, and feed-forward staging are block semantics.
- The decoder also lives here, including the cross-attention proxy that mixes encoder means into decoder context.
- Flat parameter packing is implemented here so evolutionary tooling can import and export transformer block weights.
- Local tensor helpers such as `add_tensors`, `linear`, and `row_mean` stay here because they serve block internals only.
- Open it when sequence-block behavior changes; raw attention, tensors, and engine orchestration live in sibling files.



## Lua API Ref

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
- `lurek.learning.newQLearner(sc, ac, seed?) -> LQLearner`: Creates a Q-learner with fixed state and action counts.
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

- `LNeuralEngine:addConv2D(args) -> nil`: Appends a convolutional 2D block to this engine.
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
