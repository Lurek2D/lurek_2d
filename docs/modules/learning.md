# Learning

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

## Spec File Descriptions

_Poniższe opisy plików pochodzą bezpośrednio ze specyfikacji modułu (`docs/specs/<module>.md`)._

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

## Functions

### `lurek.learning.defineEnv`

Defines a Lua-described RL environment from a config table.

```lua
lurek.learning.defineEnv(config)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `config` | table | Config with `reset` (function), `step` (function), `obs_space` (table), `action_space` (table). |

**Returns**

| Type | Description |
|------|-------------|
| [LEnv](#lenv-handle) | New environment handle. |

**Example**

```lua
do
    local env = lurek.learning.defineEnv({
        reset = function() return {0.0, 0.0} end,
        step  = function(a) return {{0.1, 0.2}, 1.0, false, {}} end,
        obs_space    = { shape = {2}, low = {-1.0}, high = {1.0} },
        action_space = { n = 4 },
    })
    local obs = env:reset()
    print("lurek.learning.defineEnv type", env:type())
    print("lurek.learning.defineEnv obs[1]", obs[1])
end
```

---

### `lurek.learning.frameStack`

Creates a frame-stacking ring buffer of the last n observations.

```lua
lurek.learning.frameStack(n)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `n` | number | Number of frames to retain. |

**Returns**

| Type | Description |
|------|-------------|
| [LFrameStack](#lframestack-handle) | New frame stack handle. |

**Example**

```lua
do
    local fs = lurek.learning.frameStack(3)
    fs:push({1.0, 2.0})
    fs:push({3.0, 4.0})
    local flat = fs:get()
    print("lurek.learning.frameStack capacity", fs:capacity())
    print("lurek.learning.frameStack flat len", #flat)
end
```

---

### `lurek.learning.loadOnnx`

Loads and optimises an ONNX model from a file path.

```lua
lurek.learning.loadOnnx(path)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `path` | string | Filesystem path to the `.onnx` model file. |

**Returns**

| Type | Description |
|------|-------------|
| [LOnnxModel](#lonnxmodel-handle) | Loaded model handle ready for inference. |

**Example**

```lua
do
    local ok, err = pcall(function()
        return lurek.learning.loadOnnx("nonexistent.onnx")
    end)
    print("lurek.learning.loadOnnx missing file errors", tostring(not ok))
end
```

---

### `lurek.learning.newBandit`

Creates a multi-armed bandit with a named selection strategy.

```lua
lurek.learning.newBandit(arm_count, strategy, epsilon, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `arm_count` | number | Number of selectable arms. |
| `strategy` | string | Strategy name such as `ucb1`, `thompson`, or an epsilon-greedy fallback. |
| `epsilon` | number | Exploration probability used by epsilon-greedy strategy and clamped to `[0, 1]`. |
| `seed` | number | Random seed used by the bandit. |

**Returns**

| Type | Description |
|------|-------------|
| [LBandit](#lbandit-handle) | New bandit handle. |

**Example**

```lua
do
    local bandit = lurek.learning.newBandit(4, "ucb1", 0.1, 99)
    local chosen_arm = bandit:select()
    bandit:update(chosen_arm, 0.75)

    print("lurek.learning.newBandit chosenArm", chosen_arm)
    print("lurek.learning.newBandit totalPulls", bandit:totalPulls())
end
```

---

### `lurek.learning.newConv2D`

Creates a Conv2D layer wrapper for deterministic CPU spatial inference.

```lua
lurek.learning.newConv2D(in_channels, out_channels, kernel_h, kernel_w, stride_h, stride_w, pad_h, pad_w)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `in_channels` | number | Input channel count. |
| `out_channels` | number | Output channel count. |
| `kernel_h` | number | Kernel height. |
| `kernel_w` | number | Kernel width. |
| `stride_h` | number | Vertical stride. |
| `stride_w` | number | Horizontal stride. |
| `pad_h` | number | Vertical zero-padding. |
| `pad_w` | number | Horizontal zero-padding. |

**Returns**

| Type | Description |
|------|-------------|
| [LConv2D](#lconv2d-handle) | New Conv2D layer handle. |

**Example**

```lua
do
    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    print("lurek.learning.newConv2D type", conv:type())
end
```

---

### `lurek.learning.newGeneticAlgorithm`

Creates a genetic algorithm population with fixed chromosome length.

```lua
lurek.learning.newGeneticAlgorithm(pop_size, gene_count, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pop_size` | number | Number of chromosomes in the population. |
| `gene_count` | number | Number of floating-point genes per chromosome. |
| `seed` | number | Random seed used for population initialization and evolution. |

**Returns**

| Type | Description |
|------|-------------|
| [LGeneticAlgorithm](#lgeneticalgorithm-handle) | New genetic algorithm handle. |

**Example**

```lua
do
    local ga = lurek.learning.newGeneticAlgorithm(6, 4, 42)

    for index = 0, ga:popSize() - 1 do
        ga:setFitness(index, index * 0.25)
    end

    ga:evolve()
    print("lurek.learning.newGeneticAlgorithm generation", ga:generation())
    print("lurek.learning.newGeneticAlgorithm popSize", ga:popSize())
end
```

---

### `lurek.learning.newGru`

Creates a stateful GRU layer wrapper.

```lua
lurek.learning.newGru(input_size, hidden_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input_size` | number | Input vector size for each step. |
| `hidden_size` | number | Hidden state size. |

**Returns**

| Type | Description |
|------|-------------|
| [LGRU](#lgru-handle) | New GRU layer handle with internal recurrent state. |

**Example**

```lua
do
    local gru = lurek.learning.newGru(2, 3)
    print("lurek.learning.newGru type", gru:type())
end
```

---

### `lurek.learning.newLstm`

Creates a stateful LSTM layer wrapper.

```lua
lurek.learning.newLstm(input_size, hidden_size)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input_size` | number | Input vector size for each step. |
| `hidden_size` | number | Hidden state size. |

**Returns**

| Type | Description |
|------|-------------|
| [LLSTM](#llstm-handle) | New LSTM layer handle with internal recurrent state. |

**Example**

```lua
do
    local lstm = lurek.learning.newLstm(2, 3)
    print("lurek.learning.newLstm type", lstm:type())
end
```

---

### `lurek.learning.newMaxPool2D`

Creates a MaxPool2D layer wrapper.

```lua
lurek.learning.newMaxPool2D(kernel_h, kernel_w, stride_h, stride_w)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `kernel_h` | number | Kernel height. |
| `kernel_w` | number | Kernel width. |
| `stride_h` | number | Vertical stride. |
| `stride_w` | number | Horizontal stride. |

**Returns**

| Type | Description |
|------|-------------|
| [LMaxPool2D](#lmaxpool2d-handle) | New MaxPool2D layer handle. |

**Example**

```lua
do
    local pool = lurek.learning.newMaxPool2D(2, 2, 2, 2)
    print("lurek.learning.newMaxPool2D type", pool:type())
end
```

---

### `lurek.learning.newMultiHeadAttention`

Creates a multi-head attention block.

```lua
lurek.learning.newMultiHeadAttention(d_model, num_heads)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `d_model` | number | Model width. |
| `num_heads` | number | Number of attention heads. |

**Returns**

| Type | Description |
|------|-------------|
| [LMultiHeadAttention](#lmultiheadattention-handle) | New MHA handle. |

**Example**

```lua
do
    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    print("lurek.learning.newMultiHeadAttention type", mha:type())
end
```

---

### `lurek.learning.newNeuralNet`

Creates an empty feed-forward neural network.

```lua
lurek.learning.newNeuralNet()
```

**Returns**

| Type | Description |
|------|-------------|
| [LNeuralNet](#lneuralnet-handle) | New neural network handle. |

**Example**

```lua
do
    local net = lurek.learning.newNeuralNet()
    net:addLayer(3, 4, "relu")
    net:addLayer(4, 2, "softmax")

    local output = net:forward({ 0.2, 0.6, -0.1 })
    print("lurek.learning.newNeuralNet layers", net:layerCount())
    print("lurek.learning.newNeuralNet firstOutput", output[1])
end
```

---

### `lurek.learning.newNeuroevolution`

Creates a neuroevolution population from a layer specification table.

```lua
lurek.learning.newNeuroevolution(layer_spec, pop_size, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer_spec` | table | Array of layer tables with `inputs`, `outputs`, and optional `activation` fields. |
| `pop_size` | number | Number of chromosomes in the population. |
| `seed` | number | Random seed used for population initialization and evolution. |

**Returns**

| Type | Description |
|------|-------------|
| [LNeuroevolution](#lneuroevolution-handle) | New neuroevolution handle. |

**Example**

```lua
do
    local layer_spec = {
        { inputs = 3, outputs = 5, activation = "relu" },
        { inputs = 5, outputs = 2, activation = "sigmoid" }
    }
    local evo = lurek.learning.newNeuroevolution(layer_spec, 5, 7)

    for index = 0, evo:popSize() - 1 do
        evo:setFitness(index, 0.4 + index * 0.1)
    end

    evo:evolve()
    print("lurek.learning.newNeuroevolution generation", evo:generation())
    print("lurek.learning.newNeuroevolution bestFitness", evo:bestFitness())
end
```

---

### `lurek.learning.newPositionalEncoding`

Creates a sinusoidal positional encoding helper.

```lua
lurek.learning.newPositionalEncoding(d_model, max_len)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `d_model` | number | Embedding width. |
| `max_len` | number | Maximum supported sequence length. |

**Returns**

| Type | Description |
|------|-------------|
| [LPositionalEncoding](#lpositionalencoding-handle) | New positional encoding handle. |

**Example**

```lua
do
    local pe = lurek.learning.newPositionalEncoding(4, 8)
    print("lurek.learning.newPositionalEncoding type", pe:type())
end
```

---

### `lurek.learning.newQLearner`

Creates a Q-learner with fixed state and action counts.

```lua
lurek.learning.newQLearner(sc, ac)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sc` | number | Number of discrete states. |
| `ac` | number | Number of discrete actions. |

**Returns**

| Type | Description |
|------|-------------|
| [LQLearner](#lqlearner-handle) | New Q-learner handle. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(4, 3)
    learner:setLearningRate(0.2)
    learner:setDiscountFactor(0.9)
    learner:learn(1, 2, 1.0, 3)

    print("lurek.learning.newQLearner states", learner:getStateCount())
    print("lurek.learning.newQLearner q12", learner:getQValue(1, 2))
end
```

---

### `lurek.learning.newTensor`

Creates a tensor from a shape (integer array) and flat float data (number array).

```lua
lurek.learning.newTensor(shape, data)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `shape` | number[] | Dimension sizes in row-major order. |
| `data` | number[] | Flat element values matching the product of `shape`. |

**Returns**

| Type | Description |
|------|-------------|
| [LTensor](#ltensor-handle) | New tensor handle. |

**Example**

```lua
do
    local t = lurek.learning.newTensor({2, 3}, {1.0, 2.0, 3.0, 4.0, 5.0, 6.0})
    print("lurek.learning.newTensor type", t:type())
    print("lurek.learning.newTensor len", t:len())
end
```

---

### `lurek.learning.newTransformerDecoder`

Creates a transformer decoder block.

```lua
lurek.learning.newTransformerDecoder(d_model, num_heads, d_ff)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `d_model` | number | Model width. |
| `num_heads` | number | Number of attention heads. |
| `d_ff` | number | Feed-forward hidden width. |

**Returns**

| Type | Description |
|------|-------------|
| [LTransformerDecoder](#ltransformerdecoder-handle) | New decoder block handle. |

**Example**

```lua
do
    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    print("lurek.learning.newTransformerDecoder type", dec:type())
end
```

---

### `lurek.learning.newTransformerEncoder`

Creates a transformer encoder block.

```lua
lurek.learning.newTransformerEncoder(d_model, num_heads, d_ff)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `d_model` | number | Model width. |
| `num_heads` | number | Number of attention heads. |
| `d_ff` | number | Feed-forward hidden width. |

**Returns**

| Type | Description |
|------|-------------|
| [LTransformerEncoder](#ltransformerencoder-handle) | New encoder block handle. |

**Example**

```lua
do
    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    print("lurek.learning.newTransformerEncoder type", enc:type())
end
```

---

### `lurek.learning.normalizeEnv`

Wraps an [LEnv](#lenv-handle) so observations are normalised by subtracting mean and dividing by std.

```lua
lurek.learning.normalizeEnv(env, mean, std)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `env` | [LEnv](#lenv-handle) | The environment to wrap. |
| `mean` | number[] | Per-dimension mean values matching the obs_space shape. |
| `std` | number[] | Per-dimension standard deviation values matching the obs_space shape. |

**Returns**

| Type | Description |
|------|-------------|
| [LEnv](#lenv-handle) | New wrapped environment handle. |

**Example**

```lua
do
    local base = lurek.learning.defineEnv({
        reset = function() return {2.0, 4.0} end,
        step  = function(a) return {{2.0, 4.0}, 1.0, false, {}} end,
        obs_space    = { shape = {2}, low = {0.0}, high = {10.0} },
        action_space = { n = 2 },
    })
    local wrapped = lurek.learning.normalizeEnv(base, {1.0, 2.0}, {1.0, 2.0})
    local obs = wrapped:reset()
    print("lurek.learning.normalizeEnv obs[1]", obs[1])
    print("lurek.learning.normalizeEnv obs[2]", obs[2])
end
```

---

### `lurek.learning.timeLimit`

Wraps an [LEnv](#lenv-handle) so episodes end automatically after max_steps steps.

```lua
lurek.learning.timeLimit(env, max_steps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `env` | [LEnv](#lenv-handle) | The environment to wrap. |
| `max_steps` | number | Maximum number of steps before done is forced true. |

**Returns**

| Type | Description |
|------|-------------|
| [LEnv](#lenv-handle) | New wrapped environment handle. |

**Example**

```lua
do
    local base = lurek.learning.defineEnv({
        reset = function() return {0.0} end,
        step  = function(a) return {{0.0}, 0.0, false, {}} end,
        obs_space    = { shape = {1}, low = {0.0}, high = {1.0} },
        action_space = { n = 2 },
    })
    local limited = lurek.learning.timeLimit(base, 5)
    limited:reset()
    print("lurek.learning.timeLimit type", limited:type())
end
```

---

### `lurek.learning.wrap`

Wraps a supported model ([LQLearner](#lqlearner-handle), [LNeuralNet](#lneuralnet-handle), or [LBandit](#lbandit-handle)) in a uniform [LModel](#lmodel-handle) interface.

```lua
lurek.learning.wrap(model)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `model` | any | An [LQLearner](#lqlearner-handle), [LNeuralNet](#lneuralnet-handle), or [LBandit](#lbandit-handle) instance. |

**Returns**

| Type | Description |
|------|-------------|
| [LModel](#lmodel-handle) | A uniform model wrapper exposing predict(). |

**Example**

```lua
do
    local qlearner = lurek.learning.newQLearner(4, 2)
    local model = lurek.learning.wrap(qlearner)
    print("wrapped model type = " .. model:type())
end
```

---

## Module Fields

*No module-level fields documented.*

## Types

- [LBandit Handle](#lbandit-handle)
- [LConv2D Handle](#lconv2d-handle)
- [LEnv Handle](#lenv-handle)
- [LFrameStack Handle](#lframestack-handle)
- [LGRU Handle](#lgru-handle)
- [LGeneticAlgorithm Handle](#lgeneticalgorithm-handle)
- [LLSTM Handle](#llstm-handle)
- [LMaxPool2D Handle](#lmaxpool2d-handle)
- [LModel Handle](#lmodel-handle)
- [LMultiHeadAttention Handle](#lmultiheadattention-handle)
- [LNeuralNet Handle](#lneuralnet-handle)
- [LNeuroevolution Handle](#lneuroevolution-handle)
- [LOnnxModel Handle](#lonnxmodel-handle)
- [LPositionalEncoding Handle](#lpositionalencoding-handle)
- [LQLearner Handle](#lqlearner-handle)
- [LTensor Handle](#ltensor-handle)
- [LTransformerDecoder Handle](#ltransformerdecoder-handle)
- [LTransformerEncoder Handle](#ltransformerencoder-handle)

## Callbacks

*No callback parameters documented in this module.*

## Enums

*No module-specific enums documented.*

## LBandit Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LBandit:armCount`

Returns the number of arms in this bandit.

```lua
LBandit:armCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Arm count. |

**Example**

```lua
do
    local bandit = lurek.learning.newBandit(4, "ucb1", 0.1, 1)
    local arm_count = bandit:armCount()

    print("LBandit:armCount", arm_count)
end
```

---

#### `LBandit:bestArm`

Returns the arm with the best current estimate.

```lua
LBandit:bestArm()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Zero-based best arm index. |

**Example**

```lua
do
    local bandit = lurek.learning.newBandit(3, "ucb1", 0.1, 2)
    bandit:update(0, 0.25)
    bandit:update(1, 0.9)
    bandit:update(2, 0.4)

    print("LBandit:bestArm", bandit:bestArm())
end
```

---

#### `LBandit:predict`

Alias for `select`. Selects an arm using the configured bandit strategy.

```lua
LBandit:predict()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Zero-based selected arm index. |

**Example**

```lua
do
    local b = lurek.learning.newBandit(3, "ucb1", 0.1, 12345)
    local action = b:predict()
    print("bandit predict = " .. action)
end
```

---

#### `LBandit:reset`

Resets all bandit arm statistics. This method is available to Lua scripts.

```lua
LBandit:reset()
```

**Example**

```lua
do
    local bandit = lurek.learning.newBandit(3, "thompson", 0.1, 3)
    local selected_arm = bandit:select()
    bandit:update(selected_arm, 0.5)
    bandit:reset()

    print("LBandit:reset pulls", bandit:totalPulls())
    print("LBandit:reset bestArm", bandit:bestArm())
end
```

---

#### `LBandit:select`

Selects an arm using the configured bandit strategy.

```lua
LBandit:select()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Zero-based selected arm index. |

**Example**

```lua
do
    local bandit = lurek.learning.newBandit(5, "thompson", 0.1, 4)
    local first_arm = bandit:select()
    local second_arm = bandit:select()

    print("LBandit:select first", first_arm)
    print("LBandit:select second", second_arm)
end
```

---

#### `LBandit:totalPulls`

Returns the total number of arm selections recorded by this bandit.

```lua
LBandit:totalPulls()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total pull count. |

**Example**

```lua
do
    local bandit = lurek.learning.newBandit(3, "ucb1", 0.1, 5)
    bandit:select()
    bandit:select()
    local total_pulls = bandit:totalPulls()

    print("LBandit:totalPulls", total_pulls)
end
```

---

#### `LBandit:type`

Returns the Lua-visible type name for this bandit handle.

```lua
LBandit:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LBandit](#lbandit-handle)`. |

**Example**

```lua
do
    local bandit = lurek.learning.newBandit(3, "ucb1", 0.1, 6)
    local type_name = bandit:type()

    print("LBandit:type", type_name)
end
```

---

#### `LBandit:typeOf`

Returns whether this bandit handle matches a supported type name.

```lua
LBandit:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LBandit](#lbandit-handle)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local bandit = lurek.learning.newBandit(3, "ucb1", 0.1, 7)
    local is_bandit = bandit:typeOf("LBandit")
    local is_object = bandit:typeOf("LObject")

    print("LBandit:typeOf LBandit", tostring(is_bandit))
    print("LBandit:typeOf LObject", tostring(is_object))
end
```

---

#### `LBandit:update`

Updates one arm with a received reward.

```lua
LBandit:update(idx, reward)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Zero-based arm index. |
| `reward` | number | Reward value assigned to the arm pull. |

**Example**

```lua
do
    local bandit = lurek.learning.newBandit(4, "ucb1", 0.1, 8)
    local arm_index = bandit:select()
    bandit:update(arm_index, 0.8)

    print("LBandit:update arm", arm_index)
    print("LBandit:update bestArm", bandit:bestArm())
end
```

---

## LConv2D Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LConv2D:forward`

Runs convolution over an input tensor shaped as `[channels,height,width]`.

```lua
LConv2D:forward(input)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input` | [LTensor](#ltensor-handle) | Input tensor for spatial convolution. |

**Returns**

| Type | Description |
|------|-------------|
| [LTensor](#ltensor-handle) | Output tensor produced by this convolution layer. |

**Example**

```lua
do
    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    local input = lurek.learning.newTensor({1, 2, 2}, {1, 2, 3, 4})
    local out = conv:forward(input)
    print("LConv2D:forward outW", out:shape()[3])
end
```

---

#### `LConv2D:getWeights`

Exports flattened convolution weights and biases from this layer.

```lua
LConv2D:getWeights()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Flat float genome in deterministic Conv2D parameter order. |

**Example**

```lua
do
    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    local got = conv:getWeights()
    print("LConv2D:getWeights", #got)
end
```

---

#### `LConv2D:paramCount`

Returns trainable parameter count for this Conv2D layer.

```lua
LConv2D:paramCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total number of trainable scalar parameters. |

**Example**

```lua
do
    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    print("LConv2D:paramCount", conv:paramCount())
end
```

---

#### `LConv2D:setWeights`

Loads flattened convolution weights and biases into this layer.

```lua
LConv2D:setWeights(weights)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `weights` | table | Flat float genome in Conv2D parameter order. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when weight count matches this layer geometry. |

**Example**

```lua
do
    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    local count = conv:paramCount()
    local weights = {}
    for i = 1, count do
        weights[i] = 0.0
    end
    conv:setWeights(weights)
    print("LConv2D:setWeights count", count)
end
```

---

#### `LConv2D:type`

Returns the Lua-visible type name for this wrapper.

```lua
LConv2D:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LConv2D](#lconv2d-handle)`. |

**Example**

```lua
do
    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    print("LConv2D:type", conv:type())
end
```

---

#### `LConv2D:typeOf`

Returns whether this userdata matches the requested type string.

```lua
LConv2D:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type string to compare against this userdata. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when name is `[LConv2D](#lconv2d-handle)` or `LObject`. |

**Example**

```lua
do
    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    print("LConv2D:typeOf", tostring(conv:typeOf("LObject")))
end
```

---

## LEnv Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LEnv:actionSpace`

Returns the action space descriptor.

```lua
LEnv:actionSpace()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Action space with shape/low/high or n fields. |

**Example**

```lua
do
    local env = lurek.learning.defineEnv({
        reset = function() return {0.0} end,
        step  = function(a) return {{0.0}, 0.0, false, {}} end,
        obs_space    = { shape = {1}, low = {0.0}, high = {1.0} },
        action_space = { n = 6 },
    })
    local space = env:actionSpace()
    print("LEnv:actionSpace n", space.n)
end
```

---

#### `LEnv:obsSpace`

Returns the observation space descriptor.

```lua
LEnv:obsSpace()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Observation space with shape, low, high fields. |

**Example**

```lua
do
    local env = lurek.learning.defineEnv({
        reset = function() return {0.0, 0.0} end,
        step  = function(a) return {{0.0, 0.0}, 0.0, false, {}} end,
        obs_space    = { shape = {4}, low = {-1.0}, high = {1.0} },
        action_space = { n = 2 },
    })
    local space = env:obsSpace()
    print("LEnv:obsSpace shape[1]", space.shape[1])
end
```

---

#### `LEnv:reset`

Resets the environment and returns the initial observation.

```lua
LEnv:reset()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Initial observation vector. |

**Example**

```lua
do
    local env = lurek.learning.defineEnv({
        reset = function() return {1.0, 2.0} end,
        step  = function(a) return {{0.0, 0.0}, 0.0, false, {}} end,
        obs_space    = { shape = {2}, low = {-1.0}, high = {1.0} },
        action_space = { n = 2 },
    })
    local obs = env:reset()
    print("LEnv:reset obs len", #obs)
    print("LEnv:reset obs[1]", obs[1])
end
```

---

#### `LEnv:step`

Advances the environment one step.

```lua
LEnv:step(action)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `action` | any | Action to apply (integer or table depending on action space). |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Next observation vector. |
| number | Reward for this step. |
| boolean | Whether the episode has ended. |
| table | Extra info table. |

**Example**

```lua
do
    local env = lurek.learning.defineEnv({
        reset = function() return {0.0} end,
        step  = function(a) return {{0.5}, 1.5, false, {}} end,
        obs_space    = { shape = {1}, low = {0.0}, high = {1.0} },
        action_space = { n = 3 },
    })
    local obs, reward, done, info = env:step(1)
    print("LEnv:step obs[1]", obs[1])
    print("LEnv:step reward", reward)
    print("LEnv:step done", tostring(done))
end
```

---

#### `LEnv:type`

Returns this environment wrapper's type name `"[LEnv](#lenv-handle)"`.

```lua
LEnv:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LEnv](#lenv-handle)`. |

**Example**

```lua
do
    local env = lurek.learning.defineEnv({
        reset = function() return {0.0} end,
        step  = function(a) return {{0.0}, 0.0, false, {}} end,
        obs_space    = { shape = {1}, low = {0.0}, high = {1.0} },
        action_space = { n = 2 },
    })
    print("LEnv:type", env:type())
end
```

---

#### `LEnv:typeOf`

Returns whether this env handle matches a supported type name.

```lua
LEnv:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LEnv](#lenv-handle)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local env = lurek.learning.defineEnv({
        reset = function() return {0.0} end,
        step  = function(a) return {{0.0}, 0.0, false, {}} end,
        obs_space    = { shape = {1}, low = {0.0}, high = {1.0} },
        action_space = { n = 2 },
    })
    print("LEnv:typeOf LEnv", tostring(env:typeOf("LEnv")))
    print("LEnv:typeOf LObject", tostring(env:typeOf("LObject")))
end
```

---

## LFrameStack Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LFrameStack:capacity`

Returns the maximum number of frames retained.

```lua
LFrameStack:capacity()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Frame capacity n. |

**Example**

```lua
do
    local fs = lurek.learning.frameStack(5)
    print("LFrameStack:capacity", fs:capacity())
end
```

---

#### `LFrameStack:get`

Returns the flattened observation stack, zero-padded when not yet full.

```lua
LFrameStack:get()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Flattened frame-stack vector of length capacity Ă— obs_dim. |

**Example**

```lua
do
    local fs = lurek.learning.frameStack(2)
    fs:push({1.0, 2.0})
    fs:push({3.0, 4.0})
    local flat = fs:get()
    print("LFrameStack:get len", #flat)
    print("LFrameStack:get first", flat[1])
end
```

---

#### `LFrameStack:push`

Pushes one observation into the stack.

```lua
LFrameStack:push(obs)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `obs` | number[] | Observation vector to push. |

**Example**

```lua
do
    local fs = lurek.learning.frameStack(4)
    fs:push({0.1, 0.2})
    fs:push({0.3, 0.4})
    print("LFrameStack:push capacity", fs:capacity())
end
```

---

#### `LFrameStack:reset`

Clears all stored observation frames from the stack.

```lua
LFrameStack:reset()
```

**Example**

```lua
do
    local fs = lurek.learning.frameStack(3)
    fs:push({1.0})
    fs:push({2.0})
    fs:reset()
    print("LFrameStack:reset capacity", fs:capacity())
end
```

---

#### `LFrameStack:type`

Returns the type name `"[LFrameStack](#lframestack-handle)"`.

```lua
LFrameStack:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LFrameStack](#lframestack-handle)`. |

**Example**

```lua
do
    local fs = lurek.learning.frameStack(3)
    print("LFrameStack:type", fs:type())
end
```

---

#### `LFrameStack:typeOf`

Returns whether this frame stack handle matches a supported type name.

```lua
LFrameStack:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LFrameStack](#lframestack-handle)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local fs = lurek.learning.frameStack(3)
    print("LFrameStack:typeOf LFrameStack", tostring(fs:typeOf("LFrameStack")))
    print("LFrameStack:typeOf LObject", tostring(fs:typeOf("LObject")))
end
```

---

## LGRU Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LGRU:forward`

Runs one GRU recurrent step on input data and returns next hidden state values.

```lua
LGRU:forward(input)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input` | table | Input vector with length equal to layer input_size. |

**Returns**

| Type | Description |
|------|-------------|
| table | Hidden-state vector with length equal to hidden_size. |

**Example**

```lua
do
    local gru = lurek.learning.newGru(2, 3)
    local out = gru:forward({ 0.1, -0.2 })
    print("LGRU:forward outLen", #out)
end
```

---

#### `LGRU:getWeights`

Exports flattened layer weights and biases from the wrapped GRU layer.

```lua
LGRU:getWeights()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Flat float genome in deterministic GRU parameter order. |

**Example**

```lua
do
    local gru = lurek.learning.newGru(2, 2)
    local got = gru:getWeights()
    print("LGRU:getWeights", #got)
end
```

---

#### `LGRU:paramCount`

Returns trainable parameter count for this GRU layer.

```lua
LGRU:paramCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total number of trainable scalar parameters. |

**Example**

```lua
do
    local gru = lurek.learning.newGru(2, 2)
    print("LGRU:paramCount", gru:paramCount())
end
```

---

#### `LGRU:reset`

Resets the recurrent hidden state buffer to zeros.

```lua
LGRU:reset()
```

**Returns**

| Type | Description |
|------|-------------|
| nil | No return value. |

**Example**

```lua
do
    local gru = lurek.learning.newGru(2, 2)
    gru:reset()
    print("LGRU:reset ok")
end
```

---

#### `LGRU:setWeights`

Loads flattened layer weights and biases into the wrapped GRU layer.

```lua
LGRU:setWeights(weights)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `weights` | table | Flat float genome in GRU parameter order. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when weight count matches this layer geometry. |

**Example**

```lua
do
    local gru = lurek.learning.newGru(2, 2)
    local count = gru:paramCount()
    local weights = {}
    for i = 1, count do
        weights[i] = 0.0
    end
    gru:setWeights(weights)
    print("LGRU:setWeights count", count)
end
```

---

#### `LGRU:type`

Returns the Lua-visible type name for this wrapper.

```lua
LGRU:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LGRU](#lgru-handle)`. |

**Example**

```lua
do
    local gru = lurek.learning.newGru(2, 2)
    print("LGRU:type", gru:type())
end
```

---

#### `LGRU:typeOf`

Returns whether this userdata matches the requested type string.

```lua
LGRU:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type string to compare against this userdata. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when name is `[LGRU](#lgru-handle)` or `LObject`. |

**Example**

```lua
do
    local gru = lurek.learning.newGru(2, 2)
    print("LGRU:typeOf", tostring(gru:typeOf("LObject")))
end
```

---

## LGeneticAlgorithm Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LGeneticAlgorithm:bestGenes`

Returns the genes for the best chromosome in the population.

```lua
LGeneticAlgorithm:bestGenes()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Array of best gene values, or an empty array when the population has no best chromosome. |

**Example**

```lua
do
    local ga = lurek.learning.newGeneticAlgorithm(5, 3, 10)

    for index = 0, ga:popSize() - 1 do
        ga:setFitness(index, index)
    end

    local genes = ga:bestGenes()
    print("LGeneticAlgorithm:bestGenes count", #genes)
    print("LGeneticAlgorithm:bestGenes first", genes[1])
end
```

---

#### `LGeneticAlgorithm:evolve`

Advances the genetic algorithm by one generation.

```lua
LGeneticAlgorithm:evolve()
```

**Example**

```lua
do
    local ga = lurek.learning.newGeneticAlgorithm(5, 4, 11)

    for index = 0, ga:popSize() - 1 do
        ga:setFitness(index, index * 0.5)
    end

    ga:evolve()
    print("LGeneticAlgorithm:evolve generation", ga:generation())
end
```

---

#### `LGeneticAlgorithm:generation`

Returns the current generation index.

```lua
LGeneticAlgorithm:generation()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current generation count. |

**Example**

```lua
do
    local ga = lurek.learning.newGeneticAlgorithm(4, 3, 12)
    ga:evolve()
    ga:evolve()

    print("LGeneticAlgorithm:generation", ga:generation())
end
```

---

#### `LGeneticAlgorithm:getGenes`

Returns the genes for a chromosome by zero-based index.

```lua
LGeneticAlgorithm:getGenes(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Zero-based chromosome index. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Gene values, or an empty table for an invalid index. |

**Example**

```lua
do
    local ga = lurek.learning.newGeneticAlgorithm(4, 5, 13)
    local genes = ga:getGenes(0)

    print("LGeneticAlgorithm:getGenes count", #genes)
    print("LGeneticAlgorithm:getGenes first", genes[1])
end
```

---

#### `LGeneticAlgorithm:popSize`

Returns the population size. This method is available to Lua scripts.

```lua
LGeneticAlgorithm:popSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current population size. |

**Example**

```lua
do
    local ga = lurek.learning.newGeneticAlgorithm(15, 8, 14)
    local pop_size = ga:popSize()

    print("LGeneticAlgorithm:popSize", pop_size)
end
```

---

#### `LGeneticAlgorithm:setFitness`

Sets the fitness value for a chromosome by zero-based index.

```lua
LGeneticAlgorithm:setFitness(idx, fitness)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Zero-based chromosome index. |
| `fitness` | number | Fitness value used by the next evolution step. |

**Example**

```lua
do
    local ga = lurek.learning.newGeneticAlgorithm(6, 3, 15)
    ga:setFitness(0, 1.25)
    ga:setFitness(1, 0.5)
    ga:evolve()

    print("LGeneticAlgorithm:setFitness generation", ga:generation())
    print("LGeneticAlgorithm:setFitness bestGenes", #ga:bestGenes())
end
```

---

#### `LGeneticAlgorithm:type`

Returns the Lua-visible type name for this genetic algorithm handle.

```lua
LGeneticAlgorithm:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LGeneticAlgorithm](#lgeneticalgorithm-handle)`. |

**Example**

```lua
do
    local ga = lurek.learning.newGeneticAlgorithm(4, 2, 16)
    local type_name = ga:type()

    print("LGeneticAlgorithm:type", type_name)
end
```

---

#### `LGeneticAlgorithm:typeOf`

Returns whether this genetic algorithm handle matches a supported type name.

```lua
LGeneticAlgorithm:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LGeneticAlgorithm](#lgeneticalgorithm-handle)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local ga = lurek.learning.newGeneticAlgorithm(4, 2, 17)
    local is_ga = ga:typeOf("LGeneticAlgorithm")
    local is_object = ga:typeOf("LObject")

    print("LGeneticAlgorithm:typeOf LGeneticAlgorithm", tostring(is_ga))
    print("LGeneticAlgorithm:typeOf LObject", tostring(is_object))
end
```

---

## LLSTM Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LLSTM:forward`

Runs one LSTM recurrent step on input data and returns next hidden state values.

```lua
LLSTM:forward(input)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input` | table | Input vector with length equal to layer input_size. |

**Returns**

| Type | Description |
|------|-------------|
| table | Hidden-state vector with length equal to hidden_size. |

**Example**

```lua
do
    local lstm = lurek.learning.newLstm(2, 3)
    local out = lstm:forward({ 0.1, -0.2 })
    print("LLSTM:forward outLen", #out)
end
```

---

#### `LLSTM:getWeights`

Exports flattened layer weights and biases from the wrapped LSTM layer.

```lua
LLSTM:getWeights()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Flat float genome in deterministic LSTM parameter order. |

**Example**

```lua
do
    local lstm = lurek.learning.newLstm(2, 2)
    local got = lstm:getWeights()
    print("LLSTM:getWeights", #got)
end
```

---

#### `LLSTM:paramCount`

Returns trainable parameter count for this LSTM layer.

```lua
LLSTM:paramCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total number of trainable scalar parameters. |

**Example**

```lua
do
    local lstm = lurek.learning.newLstm(2, 2)
    print("LLSTM:paramCount", lstm:paramCount())
end
```

---

#### `LLSTM:reset`

Resets both hidden and cell recurrent state buffers to zeros.

```lua
LLSTM:reset()
```

**Returns**

| Type | Description |
|------|-------------|
| nil | No return value. |

**Example**

```lua
do
    local lstm = lurek.learning.newLstm(2, 2)
    lstm:reset()
    print("LLSTM:reset ok")
end
```

---

#### `LLSTM:setWeights`

Loads flattened layer weights and biases into the wrapped LSTM layer.

```lua
LLSTM:setWeights(weights)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `weights` | table | Flat float genome in LSTM parameter order. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when weight count matches this layer geometry. |

**Example**

```lua
do
    local lstm = lurek.learning.newLstm(2, 2)
    local count = lstm:paramCount()
    local weights = {}
    for i = 1, count do
        weights[i] = 0.0
    end
    lstm:setWeights(weights)
    print("LLSTM:setWeights count", count)
end
```

---

#### `LLSTM:type`

Returns the Lua-visible type name for this wrapper.

```lua
LLSTM:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LLSTM](#llstm-handle)`. |

**Example**

```lua
do
    local lstm = lurek.learning.newLstm(2, 2)
    print("LLSTM:type", lstm:type())
end
```

---

#### `LLSTM:typeOf`

Returns whether this userdata matches the requested type string.

```lua
LLSTM:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type string to compare against this userdata. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when name is `[LLSTM](#llstm-handle)` or `LObject`. |

**Example**

```lua
do
    local lstm = lurek.learning.newLstm(2, 2)
    print("LLSTM:typeOf", tostring(lstm:typeOf("LObject")))
end
```

---

## LMaxPool2D Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LMaxPool2D:forward`

Runs max-pooling over an input tensor shaped as `[channels,height,width]`.

```lua
LMaxPool2D:forward(input)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input` | [LTensor](#ltensor-handle) | Input tensor for max-pooling. |

**Returns**

| Type | Description |
|------|-------------|
| [LTensor](#ltensor-handle) | Output tensor after max-pooling reduction. |

**Example**

```lua
do
    local pool = lurek.learning.newMaxPool2D(2, 2, 2, 2)
    local input = lurek.learning.newTensor({1, 4, 4}, {
        1, 5, 2, 3,
        7, 4, 0, 6,
        9, 1, 8, 2,
        3, 2, 4, 1,
    })
    local out = pool:forward(input)
    print("LMaxPool2D:forward outH", out:shape()[2])
end
```

---

#### `LMaxPool2D:type`

Returns the Lua-visible type name for this wrapper.

```lua
LMaxPool2D:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LMaxPool2D](#lmaxpool2d-handle)`. |

**Example**

```lua
do
    local pool = lurek.learning.newMaxPool2D(2, 2, 2, 2)
    print("LMaxPool2D:type", pool:type())
end
```

---

#### `LMaxPool2D:typeOf`

Returns whether this userdata matches the requested type string.

```lua
LMaxPool2D:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type string to compare against this userdata. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when name is `[LMaxPool2D](#lmaxpool2d-handle)` or `LObject`. |

**Example**

```lua
do
    local pool = lurek.learning.newMaxPool2D(2, 2, 2, 2)
    print("LMaxPool2D:typeOf", tostring(pool:typeOf("LObject")))
end
```

---

## LModel Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LModel:predict`

Runs the wrapped model's prediction. Delegates to `chooseAction`, `forward`, or `select`

```lua
LModel:predict(input)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input` | any | State index (integer) for QLearner/Bandit, or number array table for NeuralNet. |

**Returns**

| Type | Description |
|------|-------------|
| number | Action index for QLearner/Bandit; or number-array table for NeuralNet. (value 1). |
| table | Action index for QLearner/Bandit; or number-array table for NeuralNet. (value 2). |

**Example**

```lua
do
    local qlearner = lurek.learning.newQLearner(4, 2)
    local model = lurek.learning.wrap(qlearner)
    local action = model:predict(0)
    print("model predict = " .. action)
end
```

---

#### `LModel:type`

Returns this wrapper's stable type name `"[LModel](#lmodel-handle)"`.

```lua
LModel:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LModel](#lmodel-handle)`. |

**Example**

```lua
do
    local qlearner = lurek.learning.newQLearner(4, 2)
    local model = lurek.learning.wrap(qlearner)
    print("model type = " .. model:type())
end
```

---

#### `LModel:typeOf`

Returns whether this model wrapper matches a supported type name.

```lua
LModel:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LModel](#lmodel-handle)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this wrapper. |

**Example**

```lua
do
    local qlearner = lurek.learning.newQLearner(4, 2)
    local model = lurek.learning.wrap(qlearner)
    print("model typeOf LModel = " .. tostring(model:typeOf("LModel")))
end
```

---

## LMultiHeadAttention Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LMultiHeadAttention:forward`

Runs multi-head self-attention over an input tensor shaped as `[seq_len,d_model]`.

```lua
LMultiHeadAttention:forward(input)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input` | [LTensor](#ltensor-handle) | Input sequence tensor for attention. |

**Returns**

| Type | Description |
|------|-------------|
| [LTensor](#ltensor-handle) | Output sequence tensor after attention projection. |

**Example**

```lua
do
    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    local x = lurek.learning.newTensor({2, 4}, {1, 0, 0, 1, 0, 1, 1, 0})
    local out = mha:forward(x)
    print("LMultiHeadAttention:forward outShape", out:shape()[2])
end
```

---

#### `LMultiHeadAttention:getWeights`

Exports flattened projection weights and biases from this MHA block.

```lua
LMultiHeadAttention:getWeights()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Flat float genome in deterministic MHA parameter order. |

**Example**

```lua
do
    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    local got = mha:getWeights()
    print("LMultiHeadAttention:getWeights", #got)
end
```

---

#### `LMultiHeadAttention:paramCount`

Returns trainable parameter count for this MHA block.

```lua
LMultiHeadAttention:paramCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total number of trainable scalar parameters. |

**Example**

```lua
do
    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    print("LMultiHeadAttention:paramCount", mha:paramCount())
end
```

---

#### `LMultiHeadAttention:setWeights`

Loads flattened projection weights and biases into this MHA block.

```lua
LMultiHeadAttention:setWeights(weights)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `weights` | table | Flat float genome in MHA parameter order. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when weight count matches this block geometry. |

**Example**

```lua
do
    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    local count = mha:paramCount()
    local weights = {}
    for i = 1, count do
        weights[i] = 0.0
    end
    mha:setWeights(weights)
    print("LMultiHeadAttention:setWeights count", count)
end
```

---

#### `LMultiHeadAttention:type`

Returns the Lua-visible type name for this wrapper.

```lua
LMultiHeadAttention:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LMultiHeadAttention](#lmultiheadattention-handle)`. |

**Example**

```lua
do
    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    print("LMultiHeadAttention:type", mha:type())
end
```

---

#### `LMultiHeadAttention:typeOf`

Returns whether this userdata matches the requested type string.

```lua
LMultiHeadAttention:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type string to compare against this userdata. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when name is `[LMultiHeadAttention](#lmultiheadattention-handle)` or `LObject`. |

**Example**

```lua
do
    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    print("LMultiHeadAttention:typeOf", tostring(mha:typeOf("LObject")))
end
```

---

## LNeuralNet Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LNeuralNet:addLayer`

Adds a neural network layer with an activation function.

```lua
LNeuralNet:addLayer(inputs, outputs, activation)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `inputs` | number | Input count for the layer. |
| `outputs` | number | Output count for the layer. |
| `activation` | string | Activation name such as `relu`, `sigmoid`, `tanh`, `linear`, or `softmax`. |

**Example**

```lua
do
    local net = lurek.learning.newNeuralNet()
    net:addLayer(4, 6, "relu")
    net:addLayer(6, 2, "sigmoid")

    print("LNeuralNet:addLayer layerCount", net:layerCount())
    print("LNeuralNet:addLayer paramCount", net:paramCount())
end
```

---

#### `LNeuralNet:forward`

Runs a forward pass and returns output values.

```lua
LNeuralNet:forward(input)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input` | table | Array of numeric input values. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Numeric output values. |

**Example**

```lua
do
    local net = lurek.learning.newNeuralNet()
    net:addLayer(3, 4, "relu")
    net:addLayer(4, 1, "sigmoid")
    local output = net:forward({ 0.1, 0.5, 0.9 })

    print("LNeuralNet:forward out", output[1])
end
```

---

#### `LNeuralNet:getWeights`

Returns the network weights as a flat numeric array.

```lua
LNeuralNet:getWeights()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Numeric weights in engine layer order. |

**Example**

```lua
do
    local net = lurek.learning.newNeuralNet()
    net:addLayer(2, 3, "relu")
    local weights = net:getWeights()

    print("LNeuralNet:getWeights count", #weights)
    print("LNeuralNet:getWeights first", weights[1])
end
```

---

#### `LNeuralNet:layerCount`

Returns the number of layers in the network.

```lua
LNeuralNet:layerCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Layer count. |

**Example**

```lua
do
    local net = lurek.learning.newNeuralNet()
    net:addLayer(4, 8, "relu")
    net:addLayer(8, 4, "relu")
    net:addLayer(4, 1, "sigmoid")

    print("LNeuralNet:layerCount", net:layerCount())
end
```

---

#### `LNeuralNet:paramCount`

Returns the total number of trainable parameters.

```lua
LNeuralNet:paramCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Parameter count. |

**Example**

```lua
do
    local net = lurek.learning.newNeuralNet()
    net:addLayer(2, 4, "relu")
    net:addLayer(4, 1, "sigmoid")

    print("LNeuralNet:paramCount", net:paramCount())
end
```

---

#### `LNeuralNet:predict`

Alias for `forward`. Runs a forward pass and returns output values.

```lua
LNeuralNet:predict(input)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input` | table | Array of numeric input values. |

**Returns**

| Type | Description |
|------|-------------|
| number[] | Numeric output values. |

**Example**

```lua
do
    local nn = lurek.learning.newNeuralNet()
    local action = nn:predict({0.5, 0.3})
    print("nn predict = " .. tostring(action))
end
```

---

#### `LNeuralNet:setWeights`

Replaces the network weights from a flat numeric array.

```lua
LNeuralNet:setWeights(weights)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `weights` | table | Flat array of numeric weights in engine layer order. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied weight slice matches the network shape. |

**Example**

```lua
do
    local net = lurek.learning.newNeuralNet()
    net:addLayer(2, 2, "linear")
    local weights = net:getWeights()
    local applied = net:setWeights(weights)

    print("LNeuralNet:setWeights applied", tostring(applied))
    print("LNeuralNet:setWeights paramCount", net:paramCount())
end
```

---

#### `LNeuralNet:type`

Returns the Lua-visible type name for this neural network handle.

```lua
LNeuralNet:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LNeuralNet](#lneuralnet-handle)`. |

**Example**

```lua
do
    local net = lurek.learning.newNeuralNet()
    local type_name = net:type()

    print("LNeuralNet:type", type_name)
end
```

---

#### `LNeuralNet:typeOf`

Returns whether this neural network handle matches a supported type name.

```lua
LNeuralNet:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LNeuralNet](#lneuralnet-handle)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local net = lurek.learning.newNeuralNet()
    local is_net = net:typeOf("LNeuralNet")
    local is_object = net:typeOf("LObject")

    print("LNeuralNet:typeOf LNeuralNet", tostring(is_net))
    print("LNeuralNet:typeOf LObject", tostring(is_object))
end
```

---

## LNeuroevolution Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LNeuroevolution:bestFitness`

Returns the best fitness value in the population.

```lua
LNeuroevolution:bestFitness()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Best fitness value. |

**Example**

```lua
do
    local layer_spec = {
        { inputs = 2, outputs = 4, activation = "relu" },
        { inputs = 4, outputs = 1, activation = "sigmoid" }
    }
    local evo = lurek.learning.newNeuroevolution(layer_spec, 4, 18)

    for index = 0, evo:popSize() - 1 do
        evo:setFitness(index, 1.0 + index * 0.2)
    end

    print("LNeuroevolution:bestFitness", evo:bestFitness())
end
```

---

#### `LNeuroevolution:bestNetwork`

Converts the best chromosome into a neural network handle when one exists.

```lua
LNeuroevolution:bestNetwork()
```

**Returns**

| Type | Description |
|------|-------------|
| [LNeuralNet](#lneuralnet-handle) | Neural network handle. |

**Example**

```lua
do
    local layer_spec = {
        { inputs = 2, outputs = 3, activation = "relu" },
        { inputs = 3, outputs = 1, activation = "sigmoid" }
    }
    local evo = lurek.learning.newNeuroevolution(layer_spec, 4, 19)

    for index = 0, evo:popSize() - 1 do
        evo:setFitness(index, 0.5 + index * 0.3)
    end

    local best_net = evo:bestNetwork()
    print("LNeuroevolution:bestNetwork type", best_net:type())
    print("LNeuroevolution:bestNetwork layers", best_net:layerCount())
end
```

---

#### `LNeuroevolution:chromosomeToNet`

Converts one chromosome into a neural network handle when the index is valid.

```lua
LNeuroevolution:chromosomeToNet(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Zero-based chromosome index. |

**Returns**

| Type | Description |
|------|-------------|
| [LNeuralNet](#lneuralnet-handle) | Neural network handle. |

**Example**

```lua
do
    local layer_spec = {
        { inputs = 2, outputs = 3, activation = "relu" },
        { inputs = 3, outputs = 1, activation = "sigmoid" }
    }
    local evo = lurek.learning.newNeuroevolution(layer_spec, 4, 20)
    local net = evo:chromosomeToNet(0)
    local output = net:forward({ 0.3, 0.7 })

    print("LNeuroevolution:chromosomeToNet type", net:type())
    print("LNeuroevolution:chromosomeToNet out", output[1])
end
```

---

#### `LNeuroevolution:evolve`

Advances the neuroevolution population by one generation.

```lua
LNeuroevolution:evolve()
```

**Example**

```lua
do
    local layer_spec = {
        { inputs = 3, outputs = 4, activation = "relu" },
        { inputs = 4, outputs = 2, activation = "softmax" }
    }
    local evo = lurek.learning.newNeuroevolution(layer_spec, 5, 21)

    for index = 0, evo:popSize() - 1 do
        evo:setFitness(index, 0.2 + index * 0.15)
    end

    evo:evolve()
    print("LNeuroevolution:evolve generation", evo:generation())
end
```

---

#### `LNeuroevolution:generation`

Returns the current generation index.

```lua
LNeuroevolution:generation()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current generation count. |

**Example**

```lua
do
    local layer_spec = {
        { inputs = 2, outputs = 2, activation = "relu" },
        { inputs = 2, outputs = 1, activation = "sigmoid" }
    }
    local evo = lurek.learning.newNeuroevolution(layer_spec, 4, 22)
    evo:evolve()

    print("LNeuroevolution:generation", evo:generation())
end
```

---

#### `LNeuroevolution:popSize`

Returns the population size. This method is available to Lua scripts.

```lua
LNeuroevolution:popSize()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current population size. |

**Example**

```lua
do
    local layer_spec = {
        { inputs = 2, outputs = 3, activation = "relu" },
        { inputs = 3, outputs = 1, activation = "linear" }
    }
    local evo = lurek.learning.newNeuroevolution(layer_spec, 12, 23)
    local pop_size = evo:popSize()

    print("LNeuroevolution:popSize", pop_size)
end
```

---

#### `LNeuroevolution:setFitness`

Sets the fitness value for a chromosome by zero-based index.

```lua
LNeuroevolution:setFitness(idx, fitness)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | number | Zero-based chromosome index. |
| `fitness` | number | Fitness value used by the next evolution step. |

**Example**

```lua
do
    local layer_spec = {
        { inputs = 2, outputs = 4, activation = "relu" },
        { inputs = 4, outputs = 1, activation = "sigmoid" }
    }
    local evo = lurek.learning.newNeuroevolution(layer_spec, 4, 24)
    evo:setFitness(0, 0.8)
    evo:setFitness(1, 1.1)
    evo:evolve()

    print("LNeuroevolution:setFitness generation", evo:generation())
    print("LNeuroevolution:setFitness bestFitness", evo:bestFitness())
end
```

---

#### `LNeuroevolution:type`

Returns the Lua-visible type name for this neuroevolution handle.

```lua
LNeuroevolution:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LNeuroevolution](#lneuroevolution-handle)`. |

**Example**

```lua
do
    local layer_spec = {
        { inputs = 2, outputs = 3, activation = "relu" },
        { inputs = 3, outputs = 1, activation = "sigmoid" }
    }
    local evo = lurek.learning.newNeuroevolution(layer_spec, 4, 25)
    local type_name = evo:type()

    print("LNeuroevolution:type", type_name)
end
```

---

#### `LNeuroevolution:typeOf`

Returns whether this neuroevolution handle matches a supported type name.

```lua
LNeuroevolution:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LNeuroevolution](#lneuroevolution-handle)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local layer_spec = {
        { inputs = 2, outputs = 3, activation = "relu" },
        { inputs = 3, outputs = 1, activation = "sigmoid" }
    }
    local evo = lurek.learning.newNeuroevolution(layer_spec, 4, 26)
    local is_evo = evo:typeOf("LNeuroevolution")
    local is_object = evo:typeOf("LObject")

    print("LNeuroevolution:typeOf LNeuroevolution", tostring(is_evo))
    print("LNeuroevolution:typeOf LObject", tostring(is_object))
end
```

---

## LOnnxModel Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LOnnxModel:inputCount`

Returns the number of input tensors expected by the model.

```lua
LOnnxModel:inputCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Input tensor count. |

**Example**

```lua
do
    -- local model = lurek.learning.loadOnnx("model.onnx")
    -- print("LOnnxModel:inputCount", model:inputCount())
    print("LOnnxModel:inputCount stub ok", true)
end
```

---

#### `LOnnxModel:outputCount`

Returns the number of output tensors produced by the model.

```lua
LOnnxModel:outputCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Output tensor count. |

**Example**

```lua
do
    -- local model = lurek.learning.loadOnnx("model.onnx")
    -- print("LOnnxModel:outputCount", model:outputCount())
    print("LOnnxModel:outputCount stub ok", true)
end
```

---

#### `LOnnxModel:run`

Runs inference on a table of [LTensor](#ltensor-handle) inputs and returns a table of [LTensor](#ltensor-handle) outputs.

```lua
LOnnxModel:run(inputs)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `inputs` | table | Array-indexed table of [LTensor](#ltensor-handle) input values. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array-indexed table of [LTensor](#ltensor-handle) output values. |

**Example**

```lua
do
    -- Requires a real .onnx file; stub demonstrates the call shape only.
    -- local model = lurek.learning.loadOnnx("model.onnx")
    -- local input = lurek.learning.newTensor({1, 4}, {0.1, 0.2, 0.3, 0.4})
    -- local outputs = model:run({input})
    print("LOnnxModel:run stub ok", true)
end
```

---

#### `LOnnxModel:type`

Returns the type name `"[LOnnxModel](#lonnxmodel-handle)"`.

```lua
LOnnxModel:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LOnnxModel](#lonnxmodel-handle)`. |

**Example**

```lua
do
    -- local model = lurek.learning.loadOnnx("model.onnx")
    -- print("LOnnxModel:type", model:type())
    print("LOnnxModel:type stub ok", true)
end
```

---

#### `LOnnxModel:typeOf`

Returns whether this model handle matches a supported type name.

```lua
LOnnxModel:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LOnnxModel](#lonnxmodel-handle)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    -- local model = lurek.learning.loadOnnx("model.onnx")
    -- print("LOnnxModel:typeOf LOnnxModel", tostring(model:typeOf("LOnnxModel")))
    print("LOnnxModel:typeOf stub ok", true)
end
```

---

## LPositionalEncoding Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LPositionalEncoding:apply`

Applies sinusoidal positional encoding values to a `[seq_len,d_model]` tensor.

```lua
LPositionalEncoding:apply(input)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input` | [LTensor](#ltensor-handle) | Input sequence tensor to encode. |

**Returns**

| Type | Description |
|------|-------------|
| [LTensor](#ltensor-handle) | Encoded sequence tensor with added positional values. |

**Example**

```lua
do
    local pe = lurek.learning.newPositionalEncoding(4, 8)
    local x = lurek.learning.newTensor({2, 4}, {0, 0, 0, 0, 0, 0, 0, 0})
    local out = pe:apply(x)
    print("LPositionalEncoding:apply d1", out:data()[1])
end
```

---

#### `LPositionalEncoding:type`

Returns the Lua-visible type name for this wrapper.

```lua
LPositionalEncoding:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LPositionalEncoding](#lpositionalencoding-handle)`. |

**Example**

```lua
do
    local pe = lurek.learning.newPositionalEncoding(4, 8)
    print("LPositionalEncoding:type", pe:type())
end
```

---

#### `LPositionalEncoding:typeOf`

Returns whether this userdata matches the requested type string.

```lua
LPositionalEncoding:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type string to compare against this userdata. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when name is `[LPositionalEncoding](#lpositionalencoding-handle)` or `LObject`. |

**Example**

```lua
do
    local pe = lurek.learning.newPositionalEncoding(4, 8)
    print("LPositionalEncoding:typeOf", tostring(pe:typeOf("LObject")))
end
```

---

## LQLearner Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LQLearner:bestAction`

Returns the highest-valued action for a one-based state index without exploration.

```lua
LQLearner:bestAction(state)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `state` | number | One-based state index. |

**Returns**

| Type | Description |
|------|-------------|
| number | One-based best action index. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(5, 3)
    learner:setQValue(1, 1, 0.5)
    learner:setQValue(1, 2, 1.2)
    learner:setQValue(1, 3, 0.8)

    print("LQLearner:bestAction", learner:bestAction(1))
end
```

---

#### `LQLearner:chooseAction`

Chooses an action for a one-based state index using the learner's exploration policy.

```lua
LQLearner:chooseAction(state)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `state` | number | One-based state index. |

**Returns**

| Type | Description |
|------|-------------|
| number | One-based chosen action index. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(5, 3)
    learner:setExplorationRate(0.0)
    learner:setQValue(1, 2, 2.0)
    local chosen_action = learner:chooseAction(1)

    print("LQLearner:chooseAction", chosen_action)
end
```

---

#### `LQLearner:deserialize`

Replaces the Q-learner state from a JSON string.

```lua
LQLearner:deserialize(json)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `json` | string | JSON data previously produced by `serialize`. |

**Example**

```lua
do
    local source = lurek.learning.newQLearner(5, 3)
    source:setQValue(2, 3, 3.14)
    local saved = source:serialize()

    local restored = lurek.learning.newQLearner(5, 3)
    restored:deserialize(saved)
    print("LQLearner:deserialize q23", restored:getQValue(2, 3))
end
```

---

#### `LQLearner:endEpisode`

Decays epsilon and increments the episode count.

```lua
LQLearner:endEpisode()
```

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(8, 4)
    learner:setExplorationRate(0.8)
    learner:setExplorationDecay(0.5)
    learner:endEpisode()

    print("LQLearner:endEpisode explorationRate", learner:getExplorationRate())
end
```

---

#### `LQLearner:getActionCount`

Returns the number of actions represented by this learner.

```lua
LQLearner:getActionCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Action count. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(10, 4)
    local action_count = learner:getActionCount()

    print("LQLearner:getActionCount", action_count)
end
```

---

#### `LQLearner:getDiscountFactor`

Returns the Q-learning gamma discount factor.

```lua
LQLearner:getDiscountFactor()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current discount factor. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setDiscountFactor(0.95)

    print("LQLearner:getDiscountFactor", learner:getDiscountFactor())
end
```

---

#### `LQLearner:getEpisodeCount`

Returns the total number of episodes completed so far.

```lua
LQLearner:getEpisodeCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Episode count. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:endEpisode()
    learner:endEpisode()
    print("LQLearner:getEpisodeCount", learner:getEpisodeCount())
end
```

---

#### `LQLearner:getExplorationDecay`

Returns the exploration decay multiplier.

```lua
LQLearner:getExplorationDecay()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current exploration decay multiplier. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setExplorationDecay(0.97)

    print("LQLearner:getExplorationDecay", learner:getExplorationDecay())
end
```

---

#### `LQLearner:getExplorationRate`

Returns the exploration rate used by action selection.

```lua
LQLearner:getExplorationRate()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current exploration rate. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setExplorationRate(0.35)

    print("LQLearner:getExplorationRate", learner:getExplorationRate())
end
```

---

#### `LQLearner:getLearningRate`

Returns the Q-learning alpha learning rate.

```lua
LQLearner:getLearningRate()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Current learning rate. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setLearningRate(0.05)

    print("LQLearner:getLearningRate", learner:getLearningRate())
end
```

---

#### `LQLearner:getQValue`

Returns the stored Q-value for a one-based state and action pair.

```lua
LQLearner:getQValue(state, action)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `state` | number | One-based state index. |
| `action` | number | One-based action index. |

**Returns**

| Type | Description |
|------|-------------|
| number | Current Q-value. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(2, 3, 7.5)
    local value = learner:getQValue(2, 3)

    print("LQLearner:getQValue", value)
end
```

---

#### `LQLearner:getStateCount`

Returns the number of states represented by this learner.

```lua
LQLearner:getStateCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | State count. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(10, 4)
    local state_count = learner:getStateCount()

    print("LQLearner:getStateCount", state_count)
end
```

---

#### `LQLearner:learn`

Applies one Q-learning update from a transition and reward.

```lua
LQLearner:learn(state, action, reward, next_state)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `state` | number | One-based previous state index. |
| `action` | number | One-based action index taken in the previous state. |
| `reward` | number | Reward received for the transition. |
| `next_state` | number | One-based next state index. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(6, 3)
    learner:setLearningRate(0.5)
    learner:setDiscountFactor(0.0)
    learner:learn(1, 2, 1.0, 3)

    print("LQLearner:learn q12", learner:getQValue(1, 2))
end
```

---

#### `LQLearner:predict`

Alias for `chooseAction`. Selects an action for the given one-based state using the learner's policy.

```lua
LQLearner:predict(state)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `state` | number | One-based state index. |

**Returns**

| Type | Description |
|------|-------------|
| number | One-based chosen action index. |

**Example**

```lua
do
    local q = lurek.learning.newQLearner(4, 2)
    local action = q:predict(0)
    print("qlearner predict = " .. action)
end
```

---

#### `LQLearner:serialize`

Serializes the Q-learner state to a JSON string.

```lua
LQLearner:serialize()
```

**Returns**

| Type | Description |
|------|-------------|
| string | JSON representation of this learner. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(5, 3)
    learner:setQValue(1, 1, 1.5)
    local json = learner:serialize()

    print("LQLearner:serialize length", #json)
end
```

---

#### `LQLearner:setDiscountFactor`

Sets the Q-learning gamma discount factor.

```lua
LQLearner:setDiscountFactor(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Discount factor used by future updates. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setDiscountFactor(0.95)

    print("LQLearner:setDiscountFactor", learner:getDiscountFactor())
end
```

---

#### `LQLearner:setExplorationDecay`

Sets the exploration decay multiplier applied across episodes.

```lua
LQLearner:setExplorationDecay(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Exploration decay multiplier. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setExplorationDecay(0.99)

    print("LQLearner:setExplorationDecay", learner:getExplorationDecay())
end
```

---

#### `LQLearner:setExplorationRate`

Sets the exploration rate used by action selection.

```lua
LQLearner:setExplorationRate(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Exploration probability for future `chooseAction` calls. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setExplorationRate(0.5)

    print("LQLearner:setExplorationRate", learner:getExplorationRate())
end
```

---

#### `LQLearner:setLearningRate`

Sets the Q-learning alpha learning rate.

```lua
LQLearner:setLearningRate(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | number | Learning rate used by future updates. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setLearningRate(0.05)

    print("LQLearner:setLearningRate", learner:getLearningRate())
end
```

---

#### `LQLearner:setQValue`

Sets the stored Q-value for a one-based state and action pair.

```lua
LQLearner:setQValue(state, action, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `state` | number | One-based state index. |
| `action` | number | One-based action index. |
| `value` | number | Q-value to store. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(8, 4)
    learner:setQValue(3, 2, 4.2)

    print("LQLearner:setQValue", learner:getQValue(3, 2))
end
```

---

#### `LQLearner:type`

Returns the Lua-visible type name for this Q-learner handle.

```lua
LQLearner:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LQLearner](#lqlearner-handle)`. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(10, 4)
    local type_name = learner:type()

    print("LQLearner:type", type_name)
end
```

---

#### `LQLearner:typeOf`

Returns whether this Q-learner handle matches a supported type name.

```lua
LQLearner:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LQLearner](#lqlearner-handle)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(10, 4)
    local is_learner = learner:typeOf("LQLearner")
    local is_object = learner:typeOf("LObject")

    print("LQLearner:typeOf LQLearner", tostring(is_learner))
    print("LQLearner:typeOf LObject", tostring(is_object))
end
```

---

## LTensor Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LTensor:data`

Returns all elements as a flat number array in row-major order.

```lua
LTensor:data()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Flat element data. |

**Example**

```lua
do
    local t = lurek.learning.newTensor({3}, {10.0, 20.0, 30.0})
    local d = t:data()
    print("LTensor:data len", #d)
    print("LTensor:data first", d[1])
end
```

---

#### `LTensor:get`

Gets a single element by one-based multi-dimensional indices.

```lua
LTensor:get(indices)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `indices` | any | Variadic one-based index per dimension. |

**Returns**

| Type | Description |
|------|-------------|
| number | Element value at the given position. |

**Example**

```lua
do
    local t = lurek.learning.newTensor({3}, {7.0, 8.0, 9.0})
    print("LTensor:get index1", t:get(1))
    print("LTensor:get index3", t:get(3))
end
```

---

#### `LTensor:len`

Returns the total number of elements in the tensor.

```lua
LTensor:len()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total element count. |

**Example**

```lua
do
    local t = lurek.learning.newTensor({4}, {1.0, 2.0, 3.0, 4.0})
    print("LTensor:len", t:len())
end
```

---

#### `LTensor:shape`

Returns the tensor's dimension sizes as an integer array (one entry per axis).

```lua
LTensor:shape()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Dimension sizes in row-major order. |

**Example**

```lua
do
    local t = lurek.learning.newTensor({2, 3}, {1, 2, 3, 4, 5, 6})
    local s = t:shape()
    print("LTensor:shape rank", #s)
    print("LTensor:shape dim0", s[1])
end
```

---

#### `LTensor:type`

Returns the type name `"[LTensor](#ltensor-handle)"`.

```lua
LTensor:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LTensor](#ltensor-handle)`. |

**Example**

```lua
do
    local t = lurek.learning.newTensor({1}, {0.0})
    print("LTensor:type", t:type())
end
```

---

#### `LTensor:typeOf`

Returns whether this tensor handle matches a supported type name.

```lua
LTensor:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LTensor](#ltensor-handle)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local t = lurek.learning.newTensor({1}, {0.0})
    print("LTensor:typeOf LTensor", tostring(t:typeOf("LTensor")))
    print("LTensor:typeOf LObject", tostring(t:typeOf("LObject")))
end
```

---

## LTransformerDecoder Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LTransformerDecoder:forward`

Runs one transformer decoder block over input and encoder-output tensors.

```lua
LTransformerDecoder:forward(input, encoder_out)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input` | [LTensor](#ltensor-handle) | Decoder input sequence tensor. |
| `encoder_out` | [LTensor](#ltensor-handle) | Encoder output sequence tensor. |

**Returns**

| Type | Description |
|------|-------------|
| [LTensor](#ltensor-handle) | Output sequence tensor after decoder block operations. |

**Example**

```lua
do
    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    local x = lurek.learning.newTensor({2, 4}, {1, 2, 3, 4, 4, 3, 2, 1})
    local e = lurek.learning.newTensor({2, 4}, {0, 1, 0, 1, 1, 0, 1, 0})
    local out = dec:forward(x, e)
    print("LTransformerDecoder:forward outRows", out:shape()[1])
end
```

---

#### `LTransformerDecoder:getWeights`

Exports flattened trainable parameters for this decoder block.

```lua
LTransformerDecoder:getWeights()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Flat float genome in deterministic decoder parameter order. |

**Example**

```lua
do
    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    local got = dec:getWeights()
    print("LTransformerDecoder:getWeights", #got)
end
```

---

#### `LTransformerDecoder:paramCount`

Returns trainable parameter count for this decoder block.

```lua
LTransformerDecoder:paramCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total number of trainable scalar parameters. |

**Example**

```lua
do
    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    print("LTransformerDecoder:paramCount", dec:paramCount())
end
```

---

#### `LTransformerDecoder:setWeights`

Loads flattened trainable parameters for this decoder block.

```lua
LTransformerDecoder:setWeights(weights)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `weights` | table | Flat float genome in decoder parameter order. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when weight count matches this block geometry. |

**Example**

```lua
do
    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    local count = dec:paramCount()
    local weights = {}
    for i = 1, count do
        weights[i] = 0.0
    end
    dec:setWeights(weights)
    print("LTransformerDecoder:setWeights count", count)
end
```

---

#### `LTransformerDecoder:type`

Returns the Lua-visible type name for this wrapper.

```lua
LTransformerDecoder:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LTransformerDecoder](#ltransformerdecoder-handle)`. |

**Example**

```lua
do
    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    print("LTransformerDecoder:type", dec:type())
end
```

---

#### `LTransformerDecoder:typeOf`

Returns whether this userdata matches the requested type string.

```lua
LTransformerDecoder:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type string to compare against this userdata. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when name is `[LTransformerDecoder](#ltransformerdecoder-handle)` or `LObject`. |

**Example**

```lua
do
    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    print("LTransformerDecoder:typeOf", tostring(dec:typeOf("LObject")))
end
```

---

## LTransformerEncoder Handle

### Fields

*No documented fields for this handle.*

### Methods

#### `LTransformerEncoder:forward`

Runs one transformer encoder block over an input `[seq_len,d_model]` tensor.

```lua
LTransformerEncoder:forward(input)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input` | [LTensor](#ltensor-handle) | Input sequence tensor for encoder processing. |

**Returns**

| Type | Description |
|------|-------------|
| [LTensor](#ltensor-handle) | Output sequence tensor after encoder block operations. |

**Example**

```lua
do
    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    local x = lurek.learning.newTensor({2, 4}, {1, 2, 3, 4, 4, 3, 2, 1})
    local out = enc:forward(x)
    print("LTransformerEncoder:forward outRows", out:shape()[1])
end
```

---

#### `LTransformerEncoder:getWeights`

Exports flattened trainable parameters for this encoder block.

```lua
LTransformerEncoder:getWeights()
```

**Returns**

| Type | Description |
|------|-------------|
| table | Flat float genome in deterministic encoder parameter order. |

**Example**

```lua
do
    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    local got = enc:getWeights()
    print("LTransformerEncoder:getWeights", #got)
end
```

---

#### `LTransformerEncoder:paramCount`

Returns trainable parameter count for this encoder block.

```lua
LTransformerEncoder:paramCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Total number of trainable scalar parameters. |

**Example**

```lua
do
    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    print("LTransformerEncoder:paramCount", enc:paramCount())
end
```

---

#### `LTransformerEncoder:setWeights`

Loads flattened trainable parameters for this encoder block.

```lua
LTransformerEncoder:setWeights(weights)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `weights` | table | Flat float genome in encoder parameter order. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when weight count matches this block geometry. |

**Example**

```lua
do
    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    local count = enc:paramCount()
    local weights = {}
    for i = 1, count do
        weights[i] = 0.0
    end
    enc:setWeights(weights)
    print("LTransformerEncoder:setWeights count", count)
end
```

---

#### `LTransformerEncoder:type`

Returns the Lua-visible type name for this wrapper.

```lua
LTransformerEncoder:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LTransformerEncoder](#ltransformerencoder-handle)`. |

**Example**

```lua
do
    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    print("LTransformerEncoder:type", enc:type())
end
```

---

#### `LTransformerEncoder:typeOf`

Returns whether this userdata matches the requested type string.

```lua
LTransformerEncoder:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type string to compare against this userdata. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when name is `[LTransformerEncoder](#ltransformerencoder-handle)` or `LObject`. |

**Example**

```lua
do
    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    print("LTransformerEncoder:typeOf", tostring(enc:typeOf("LObject")))
end
```

---
