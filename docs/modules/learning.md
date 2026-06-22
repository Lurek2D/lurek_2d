# Learning

## Purpose

Manages dynamic neural nets, attention blocks, transformers, and flat tensor buffers.

## When To Use

- Its defining feature is breadth across learning styles. Tensor math, feedforward models, convolutional structures, recurrent logic, attention, transformer-style components, Q-learning, bandits, genetic algorithms, and neuroevolution all coexist because game-related learning problems vary widely.
- That breadth matters because one project may want inference from a pretrained model, another may want online adaptation, and another may want population-based search or discrete action learning rather than gradient-heavy end-to-end training.
- The module therefore acts less like a single ML framework and more like an engine-owned research and experimentation toolkit with several entry points.

## Minimal Example

Example block: `lurek.learning.newNeuralNet`

```lua
do
    local net = lurek.learning.newNeuralNet()
    net:addLayer(3, 4, "linear")
    local net_layers = net:layerCount()
    net:addLayer(4, 4, "relu")
    net:addLayer(4, 2, "softmax")

    local output = net:forward({ 0.2, 0.6, -0.1 })
    example_print_log("lurek.learning.newNeuralNet layers", net:layerCount())
    example_print_log("lurek.learning.newNeuralNet firstOutput", output[1])
end
```

## Common Patterns

- Start with `lurek.learning.defineEnv` when exploring this module.
- Start with `lurek.learning.frameStack` when exploring this module.
- Start with `lurek.learning.loadOnnx` when exploring this module.
- Start with `lurek.learning.newBandit` when exploring this module.
- Start with `lurek.learning.newConv2D` when exploring this module.

## API Reference

- This page is the generated API reference for this module.

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
| [LEnv](#lenv) | New environment handle. |

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
    example_print_log("lurek.learning.defineEnv type", env:type())
    example_print_log("lurek.learning.defineEnv obs[1]", obs[1])
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
| [LFrameStack](#lframestack) | New frame stack handle. |

**Example**

```lua
do
    local fs = lurek.learning.frameStack(3)
    fs:push({1.0, 2.0})
    fs:push({3.0, 4.0})
    local flat = fs:get()
    example_print_log("lurek.learning.frameStack capacity", fs:capacity())
    example_print_log("lurek.learning.frameStack flat len", #flat)
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
| `path` | string | Filesystem path to the `.onnx` model file inside the current sandbox root. |

**Returns**

| Type | Description |
|------|-------------|
| [LOnnxModel](#lonnxmodel) | Loaded model handle ready for inference. |

**Example**

```lua
do
    local ok, err = pcall(function()
        return lurek.learning.loadOnnx("nonexistent.onnx")
    end)
    local missing = "content/examples/assets/missing_model.onnx"
    local attempted = tostring(missing ~= nil)
    example_print_log("lurek.learning.loadOnnx missing file errors", tostring(not ok))
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
| [LBandit](#lbandit) | New bandit handle. |

**Example**

```lua
do
    local bandit = lurek.learning.newBandit(4, "ucb1", 0.1, 99)
    local warmup_arm = bandit:select()
    bandit:update(warmup_arm, 0.1)
    local chosen_arm = bandit:select()
    bandit:update(chosen_arm, 0.75)

    example_print_log("lurek.learning.newBandit chosenArm", chosen_arm)
    example_print_log("lurek.learning.newBandit totalPulls", bandit:totalPulls())
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
| [LConv2D](#lconv2d) | New Conv2D layer handle. |

**Example**

```lua
do
    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    local conv_weights = conv:getWeights()
    local conv_params = conv:paramCount()
    example_print_log("lurek.learning.newConv2D type", conv:type())
    example_print_log("weight count = " .. #conv_weights)
end
```

---

### `lurek.learning.newEngine`

Creates an empty heterogeneous neural engine.

```lua
lurek.learning.newEngine()
```

**Returns**

| Type | Description |
|------|-------------|
| [LNeuralEngine](#lneuralengine) | New neural engine handle. |

**Example**

```lua
do
    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    local engine_blocks = engine:blockCount()
    example_print_log("lurek.learning.newEngine blocks", engine:blockCount())
    example_print_log("engine params = " .. engine:paramCount())
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
| [LGeneticAlgorithm](#lgeneticalgorithm) | New genetic algorithm handle. |

**Example**

```lua
do
    local ga = lurek.learning.newGeneticAlgorithm(6, 4, 42)
    ga:setFitness(0, 0.1)
    local ga_generation = ga:generation()

    for index = 0, ga:popSize() - 1 do
        ga:setFitness(index, index * 0.25)
    end

    ga:evolve()
    example_print_log("lurek.learning.newGeneticAlgorithm generation", ga:generation())
    example_print_log("lurek.learning.newGeneticAlgorithm popSize", ga:popSize())
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
| [LGRU](#lgru) | New GRU layer handle with internal recurrent state. |

**Example**

```lua
do
    local gru = lurek.learning.newGru(2, 3)
    local gru_weights = gru:getWeights()
    local gru_params = gru:paramCount()
    example_print_log("lurek.learning.newGru type", gru:type())
    example_print_log("weight count = " .. #gru_weights)
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
| [LLSTM](#llstm) | New LSTM layer handle with internal recurrent state. |

**Example**

```lua
do
    local lstm = lurek.learning.newLstm(2, 3)
    local lstm_weights = lstm:getWeights()
    local lstm_params = lstm:paramCount()
    example_print_log("lurek.learning.newLstm type", lstm:type())
    example_print_log("weight count = " .. #lstm_weights)
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
| [LMaxPool2D](#lmaxpool2d) | New MaxPool2D layer handle. |

**Example**

```lua
do
    local pool = lurek.learning.newMaxPool2D(2, 2, 2, 2)
    local pool_type = pool:type()
    local pool_is = pool:typeOf("LMaxPool2D")
    example_print_log("lurek.learning.newMaxPool2D type", pool:type())
    example_print_log("pool configured = " .. tostring(pool_is))
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
| [LMultiHeadAttention](#lmultiheadattention) | New MHA handle. |

**Example**

```lua
do
    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    local mha_weights = mha:getWeights()
    local mha_params = mha:paramCount()
    example_print_log("lurek.learning.newMultiHeadAttention type", mha:type())
    example_print_log("attention configured = " .. tostring(mha_is))
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
| [LNeuralNet](#lneuralnet) | New neural network handle. |

**Example**

```lua
do
    local net = lurek.learning.newNeuralNet()
    net:addLayer(3, 4, "linear")
    local net_layers = net:layerCount()
    net:addLayer(4, 4, "relu")
    net:addLayer(4, 2, "softmax")

    local output = net:forward({ 0.2, 0.6, -0.1 })
    example_print_log("lurek.learning.newNeuralNet layers", net:layerCount())
    example_print_log("lurek.learning.newNeuralNet firstOutput", output[1])
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
| [LNeuroevolution](#lneuroevolution) | New neuroevolution handle. |

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
    example_print_log("lurek.learning.newNeuroevolution generation", evo:generation())
    example_print_log("lurek.learning.newNeuroevolution bestFitness", evo:bestFitness())
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
| [LPositionalEncoding](#lpositionalencoding) | New positional encoding handle. |

**Example**

```lua
do
    local pe = lurek.learning.newPositionalEncoding(4, 8)
    local pe_type = pe:type()
    local pe_is = pe:typeOf("LPositionalEncoding")
    example_print_log("lurek.learning.newPositionalEncoding type", pe:type())
    example_print_log("encoding configured = " .. tostring(pe_is))
end
```

---

### `lurek.learning.newQLearner`

Creates a Q-learner with fixed state and action counts.

```lua
lurek.learning.newQLearner(sc, ac, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sc` | number | Number of discrete states. |
| `ac` | number | Number of discrete actions. |
| `seed?` | number | Optional deterministic RNG seed used for exploration and replay. |

**Returns**

| Type | Description |
|------|-------------|
| [LQLearner](#lqlearner) | New Q-learner handle. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(4, 3)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setLearningRate(0.2)
    learner:setDiscountFactor(0.9)
    learner:learn(1, 2, 1.0, 3)

    example_print_log("lurek.learning.newQLearner states", learner:getStateCount())
    example_print_log("lurek.learning.newQLearner q12", learner:getQValue(1, 2))
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
| `data` | number[] | Flat finite element values matching the product of `shape`. |

**Returns**

| Type | Description |
|------|-------------|
| [LTensor](#ltensor) | New tensor handle. |

**Example**

```lua
do
    local t = lurek.learning.newTensor({2, 3}, {1.0, 2.0, 3.0, 4.0, 5.0, 6.0})
    local tensor_shape = t:shape()
    local tensor_len = t:len()
    example_print_log("lurek.learning.newTensor type", t:type())
    example_print_log("lurek.learning.newTensor len", t:len())
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
| [LTransformerDecoder](#ltransformerdecoder) | New decoder block handle. |

**Example**

```lua
do
    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    local dec_weights = dec:getWeights()
    local dec_params = dec:paramCount()
    example_print_log("lurek.learning.newTransformerDecoder type", dec:type())
    example_print_log("decoder configured = " .. tostring(dec_is))
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
| [LTransformerEncoder](#ltransformerencoder) | New encoder block handle. |

**Example**

```lua
do
    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    local enc_weights = enc:getWeights()
    local enc_params = enc:paramCount()
    example_print_log("lurek.learning.newTransformerEncoder type", enc:type())
    example_print_log("encoder configured = " .. tostring(enc_is))
end
```

---

### `lurek.learning.normalizeEnv`

Wraps an [LEnv](#lenv) so observations are normalised by subtracting mean and dividing by std.

```lua
lurek.learning.normalizeEnv(env, mean, std)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `env` | [LEnv](#lenv) | The environment to wrap. |
| `mean` | number[] | Per-dimension mean values matching the obs_space shape. |
| `std` | number[] | Per-dimension standard deviation values matching the obs_space shape. |

**Returns**

| Type | Description |
|------|-------------|
| [LEnv](#lenv) | New wrapped environment handle. |

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
    example_print_log("lurek.learning.normalizeEnv obs[1]", obs[1])
    example_print_log("lurek.learning.normalizeEnv obs[2]", obs[2])
end
```

---

### `lurek.learning.timeLimit`

Wraps an [LEnv](#lenv) so episodes end automatically after max_steps steps.

```lua
lurek.learning.timeLimit(env, max_steps)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `env` | [LEnv](#lenv) | The environment to wrap. |
| `max_steps` | number | Maximum number of steps before done is forced true. |

**Returns**

| Type | Description |
|------|-------------|
| [LEnv](#lenv) | New wrapped environment handle. |

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
    example_print_log("lurek.learning.timeLimit type", limited:type())
end
```

---

### `lurek.learning.wrap`

Wraps a supported model ([LQLearner](#lqlearner), [LNeuralNet](#lneuralnet), or [LBandit](#lbandit)) in a uniform [LModel](#lmodel) interface.

```lua
lurek.learning.wrap(model)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `model` | any | An [LQLearner](#lqlearner), [LNeuralNet](#lneuralnet), or [LBandit](#lbandit) instance. |

**Returns**

| Type | Description |
|------|-------------|
| [LModel](#lmodel) | A uniform model wrapper exposing predict(). |

**Example**

```lua
do
    local qlearner = lurek.learning.newQLearner(4, 2)
    local model = lurek.learning.wrap(qlearner)
    local model_type = model:type()
    local is_model = model:typeOf("LModel")
    example_print_log("wrapped model type = " .. model:type())
end
```

---

## Module Fields

*No module-level fields documented.*

## Enums

*No module-specific enums documented.*

## Types

- [LBandit](#lbandit)
- [LConv2D](#lconv2d)
- [LEnv](#lenv)
- [LFrameStack](#lframestack)
- [LGRU](#lgru)
- [LGeneticAlgorithm](#lgeneticalgorithm)
- [LLSTM](#llstm)
- [LMaxPool2D](#lmaxpool2d)
- [LModel](#lmodel)
- [LMultiHeadAttention](#lmultiheadattention)
- [LNeuralEngine](#lneuralengine)
- [LNeuralNet](#lneuralnet)
- [LNeuroevolution](#lneuroevolution)
- [LOnnxModel](#lonnxmodel)
- [LPositionalEncoding](#lpositionalencoding)
- [LQLearner](#lqlearner)
- [LTensor](#ltensor)
- [LTransformerDecoder](#ltransformerdecoder)
- [LTransformerEncoder](#ltransformerencoder)

## LBandit

### Type Fields

*No documented fields for this handle.*

### Type Methods

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
    local warmup_arm = bandit:select()
    bandit:update(warmup_arm, 0.1)
    local arm_count = bandit:armCount()

    example_print_log("LBandit:armCount", arm_count)
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
    local warmup_arm = bandit:select()
    bandit:update(warmup_arm, 0.1)
    bandit:update(0, 0.25)
    bandit:update(1, 0.9)
    bandit:update(2, 0.4)

    example_print_log("LBandit:bestArm", bandit:bestArm())
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
    local arms = b:armCount()
    local pulls = b:totalPulls()
    example_print_log("bandit predict = " .. action)
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
    local warmup_arm = bandit:select()
    bandit:update(warmup_arm, 0.1)
    local selected_arm = bandit:select()
    bandit:update(selected_arm, 0.5)
    bandit:reset()

    example_print_log("LBandit:reset pulls", bandit:totalPulls())
    example_print_log("LBandit:reset bestArm", bandit:bestArm())
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
    local warmup_arm = bandit:select()
    bandit:update(warmup_arm, 0.1)
    local first_arm = bandit:select()
    local second_arm = bandit:select()

    example_print_log("LBandit:select first", first_arm)
    example_print_log("LBandit:select second", second_arm)
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
    local warmup_arm = bandit:select()
    bandit:update(warmup_arm, 0.1)
    bandit:select()
    bandit:select()
    local total_pulls = bandit:totalPulls()

    example_print_log("LBandit:totalPulls", total_pulls)
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
| string | The string `[LBandit](#lbandit)`. |

**Example**

```lua
do
    local bandit = lurek.learning.newBandit(3, "ucb1", 0.1, 6)
    local warmup_arm = bandit:select()
    bandit:update(warmup_arm, 0.1)
    local type_name = bandit:type()

    example_print_log("LBandit:type", type_name)
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
| `name` | string | Type name to compare against `[LBandit](#lbandit)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local bandit = lurek.learning.newBandit(3, "ucb1", 0.1, 7)
    local warmup_arm = bandit:select()
    bandit:update(warmup_arm, 0.1)
    local is_bandit = bandit:typeOf("LBandit")
    local is_object = bandit:typeOf("LObject")

    example_print_log("LBandit:typeOf LBandit", tostring(is_bandit))
    example_print_log("LBandit totalPulls", bandit:totalPulls())
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
    local warmup_arm = bandit:select()
    bandit:update(warmup_arm, 0.1)
    local arm_index = bandit:select()
    bandit:update(arm_index, 0.8)

    example_print_log("LBandit:update arm", arm_index)
    example_print_log("LBandit:update bestArm", bandit:bestArm())
end
```

---

## LConv2D

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LConv2D:forward`

Runs convolution over an input tensor shaped as `[channels,height,width]`.

```lua
LConv2D:forward(input)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input` | [LTensor](#ltensor) | Input tensor for spatial convolution. |

**Returns**

| Type | Description |
|------|-------------|
| [LTensor](#ltensor) | Output tensor produced by this convolution layer. |

**Example**

```lua
do
    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    local conv_weights = conv:getWeights()
    local conv_params = conv:paramCount()
    local input = lurek.learning.newTensor({1, 2, 2}, {1, 2, 3, 4})
    local out = conv:forward(input)
    example_print_log("LConv2D:forward outW", out:shape()[3])
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
    local conv_weights = conv:getWeights()
    local conv_params = conv:paramCount()
    local got = conv:getWeights()
    example_print_log("LConv2D:getWeights", #got)
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
    local conv_weights = conv:getWeights()
    local conv_params = conv:paramCount()
    example_print_log("LConv2D:paramCount", conv:paramCount())
    example_print_log("weight count = " .. #conv_weights)
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
    local conv_weights = conv:getWeights()
    local conv_params = conv:paramCount()
    local count = conv:paramCount()
    local weights = {}
    for i = 1, count do
        weights[i] = 0.0
    end
    conv:setWeights(weights)
    example_print_log("LConv2D:setWeights count", count)
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
| string | The string `[LConv2D](#lconv2d)`. |

**Example**

```lua
do
    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    local conv_weights = conv:getWeights()
    local conv_params = conv:paramCount()
    example_print_log("LConv2D:type", conv:type())
    example_print_log("weight count = " .. #conv_weights)
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
| boolean | True when name is `[LConv2D](#lconv2d)` or `LObject`. |

**Example**

```lua
do
    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    local conv_weights = conv:getWeights()
    local conv_params = conv:paramCount()
    example_print_log("LConv2D:typeOf", tostring(conv:typeOf("LObject")))
    example_print_log("type = " .. tostring(conv:type()))
end
```

---

## LEnv

### Type Fields

*No documented fields for this handle.*

### Type Methods

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
    example_print_log("LEnv:actionSpace n", space.n)
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
    example_print_log("LEnv:obsSpace shape[1]", space.shape[1])
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
    example_print_log("LEnv:reset obs len", #obs)
    example_print_log("LEnv:reset obs[1]", obs[1])
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
    example_print_log("LEnv:step obs[1]", obs[1])
    example_print_log("LEnv:step reward", reward)
    example_print_log("LEnv:step done", tostring(done))
end
```

---

#### `LEnv:type`

Returns this environment wrapper's type name `"[LEnv](#lenv)"`.

```lua
LEnv:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LEnv](#lenv)`. |

**Example**

```lua
do
    local env = lurek.learning.defineEnv({
        reset = function() return {0.0} end,
        step  = function(a) return {{0.0}, 0.0, false, {}} end,
        obs_space    = { shape = {1}, low = {0.0}, high = {1.0} },
        action_space = { n = 2 },
    })
    example_print_log("LEnv:type", env:type())
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
| `name` | string | Type name to compare against `[LEnv](#lenv)` and `Object`. |

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
    example_print_log("LEnv:typeOf LEnv", tostring(env:typeOf("LEnv")))
    example_print_log("LEnv reset size", #env:reset())
end
```

---

## LFrameStack

### Type Fields

*No documented fields for this handle.*

### Type Methods

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
    fs:push({0.1})
    local flat = fs:get()
    example_print_log("LFrameStack:capacity", fs:capacity())
    example_print_log("stack width = " .. #flat)
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
    example_print_log("LFrameStack:get len", #flat)
    example_print_log("LFrameStack:get first", flat[1])
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
    local flat = fs:get()
    example_print_log("LFrameStack:push capacity", fs:capacity())
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
    example_print_log("LFrameStack:reset capacity", fs:capacity())
end
```

---

#### `LFrameStack:type`

Returns the type name `"[LFrameStack](#lframestack)"`.

```lua
LFrameStack:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LFrameStack](#lframestack)`. |

**Example**

```lua
do
    local fs = lurek.learning.frameStack(3)
    fs:push({0.1})
    local flat = fs:get()
    example_print_log("LFrameStack:type", fs:type())
    example_print_log("stack width = " .. #flat)
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
| `name` | string | Type name to compare against `[LFrameStack](#lframestack)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local fs = lurek.learning.frameStack(3)
    fs:push({0.1})
    local flat = fs:get()
    example_print_log("LFrameStack:typeOf LFrameStack", tostring(fs:typeOf("LFrameStack")))
    example_print_log("LFrameStack flattened len", #flat)
end
```

---

## LGRU

### Type Fields

*No documented fields for this handle.*

### Type Methods

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
    local gru_weights = gru:getWeights()
    local gru_params = gru:paramCount()
    local out = gru:forward({ 0.1, -0.2 })
    example_print_log("LGRU:forward outLen", #out)
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
    local gru_weights = gru:getWeights()
    local gru_params = gru:paramCount()
    local got = gru:getWeights()
    example_print_log("LGRU:getWeights", #got)
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
    local gru_weights = gru:getWeights()
    local gru_params = gru:paramCount()
    example_print_log("LGRU:paramCount", gru:paramCount())
    example_print_log("weight count = " .. #gru_weights)
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
    local gru_weights = gru:getWeights()
    local gru_params = gru:paramCount()
    gru:reset()
    example_print_log("LGRU:reset ok")
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
    local gru_weights = gru:getWeights()
    local gru_params = gru:paramCount()
    local count = gru:paramCount()
    local weights = {}
    for i = 1, count do
        weights[i] = 0.0
    end
    gru:setWeights(weights)
    example_print_log("LGRU:setWeights count", count)
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
| string | The string `[LGRU](#lgru)`. |

**Example**

```lua
do
    local gru = lurek.learning.newGru(2, 2)
    local gru_weights = gru:getWeights()
    local gru_params = gru:paramCount()
    example_print_log("LGRU:type", gru:type())
    example_print_log("weight count = " .. #gru_weights)
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
| boolean | True when name is `[LGRU](#lgru)` or `LObject`. |

**Example**

```lua
do
    local gru = lurek.learning.newGru(2, 2)
    local gru_weights = gru:getWeights()
    local gru_params = gru:paramCount()
    example_print_log("LGRU:typeOf", tostring(gru:typeOf("LObject")))
    example_print_log("type = " .. tostring(gru:type()))
end
```

---

## LGeneticAlgorithm

### Type Fields

*No documented fields for this handle.*

### Type Methods

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
    ga:setFitness(0, 0.1)
    local ga_generation = ga:generation()

    for index = 0, ga:popSize() - 1 do
        ga:setFitness(index, index)
    end

    local genes = ga:bestGenes()
    example_print_log("LGeneticAlgorithm:bestGenes count", #genes)
    example_print_log("LGeneticAlgorithm:bestGenes first", genes[1])
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
    ga:setFitness(0, 0.1)
    local ga_generation = ga:generation()

    for index = 0, ga:popSize() - 1 do
        ga:setFitness(index, index * 0.5)
    end

    ga:evolve()
    example_print_log("LGeneticAlgorithm:evolve generation", ga:generation())
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
    ga:setFitness(0, 0.1)
    local ga_generation = ga:generation()
    ga:evolve()
    ga:evolve()

    example_print_log("LGeneticAlgorithm:generation", ga:generation())
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
    ga:setFitness(0, 0.1)
    local ga_generation = ga:generation()
    local genes = ga:getGenes(0)

    example_print_log("LGeneticAlgorithm:getGenes count", #genes)
    example_print_log("LGeneticAlgorithm:getGenes first", genes[1])
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
    ga:setFitness(0, 0.1)
    local ga_generation = ga:generation()
    local pop_size = ga:popSize()

    example_print_log("LGeneticAlgorithm:popSize", pop_size)
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
    ga:setFitness(0, 0.1)
    local ga_generation = ga:generation()
    ga:setFitness(0, 1.25)
    ga:setFitness(1, 0.5)
    ga:evolve()

    example_print_log("LGeneticAlgorithm:setFitness generation", ga:generation())
    example_print_log("LGeneticAlgorithm:setFitness bestGenes", #ga:bestGenes())
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
| string | The string `[LGeneticAlgorithm](#lgeneticalgorithm)`. |

**Example**

```lua
do
    local ga = lurek.learning.newGeneticAlgorithm(4, 2, 16)
    ga:setFitness(0, 0.1)
    local ga_generation = ga:generation()
    local type_name = ga:type()

    example_print_log("LGeneticAlgorithm:type", type_name)
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
| `name` | string | Type name to compare against `[LGeneticAlgorithm](#lgeneticalgorithm)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local ga = lurek.learning.newGeneticAlgorithm(4, 2, 17)
    ga:setFitness(0, 0.1)
    local ga_generation = ga:generation()
    local is_ga = ga:typeOf("LGeneticAlgorithm")
    local is_object = ga:typeOf("LObject")

    example_print_log("LGeneticAlgorithm:typeOf LGeneticAlgorithm", tostring(is_ga))
    example_print_log("LGeneticAlgorithm popSize", ga:popSize())
end
```

---

## LLSTM

### Type Fields

*No documented fields for this handle.*

### Type Methods

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
    local lstm_weights = lstm:getWeights()
    local lstm_params = lstm:paramCount()
    local out = lstm:forward({ 0.1, -0.2 })
    example_print_log("LLSTM:forward outLen", #out)
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
    local lstm_weights = lstm:getWeights()
    local lstm_params = lstm:paramCount()
    local got = lstm:getWeights()
    example_print_log("LLSTM:getWeights", #got)
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
    local lstm_weights = lstm:getWeights()
    local lstm_params = lstm:paramCount()
    example_print_log("LLSTM:paramCount", lstm:paramCount())
    example_print_log("weight count = " .. #lstm_weights)
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
    local lstm_weights = lstm:getWeights()
    local lstm_params = lstm:paramCount()
    lstm:reset()
    example_print_log("LLSTM:reset ok")
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
    local lstm_weights = lstm:getWeights()
    local lstm_params = lstm:paramCount()
    local count = lstm:paramCount()
    local weights = {}
    for i = 1, count do
        weights[i] = 0.0
    end
    lstm:setWeights(weights)
    example_print_log("LLSTM:setWeights count", count)
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
| string | The string `[LLSTM](#llstm)`. |

**Example**

```lua
do
    local lstm = lurek.learning.newLstm(2, 2)
    local lstm_weights = lstm:getWeights()
    local lstm_params = lstm:paramCount()
    example_print_log("LLSTM:type", lstm:type())
    example_print_log("weight count = " .. #lstm_weights)
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
| boolean | True when name is `[LLSTM](#llstm)` or `LObject`. |

**Example**

```lua
do
    local lstm = lurek.learning.newLstm(2, 2)
    local lstm_weights = lstm:getWeights()
    local lstm_params = lstm:paramCount()
    example_print_log("LLSTM:typeOf", tostring(lstm:typeOf("LObject")))
    example_print_log("type = " .. tostring(lstm:type()))
end
```

---

## LMaxPool2D

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LMaxPool2D:forward`

Runs max-pooling over an input tensor shaped as `[channels,height,width]`.

```lua
LMaxPool2D:forward(input)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input` | [LTensor](#ltensor) | Input tensor for max-pooling. |

**Returns**

| Type | Description |
|------|-------------|
| [LTensor](#ltensor) | Output tensor after max-pooling reduction. |

**Example**

```lua
do
    local pool = lurek.learning.newMaxPool2D(2, 2, 2, 2)
    local pool_type = pool:type()
    local pool_is = pool:typeOf("LMaxPool2D")
    local input = lurek.learning.newTensor({1, 4, 4}, {
        1, 5, 2, 3,
        7, 4, 0, 6,
        9, 1, 8, 2,
        3, 2, 4, 1,
    })
    local out = pool:forward(input)
    example_print_log("LMaxPool2D:forward outH", out:shape()[2])
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
| string | The string `[LMaxPool2D](#lmaxpool2d)`. |

**Example**

```lua
do
    local pool = lurek.learning.newMaxPool2D(2, 2, 2, 2)
    local pool_type = pool:type()
    local pool_is = pool:typeOf("LMaxPool2D")
    example_print_log("LMaxPool2D:type", pool:type())
    example_print_log("pool configured = " .. tostring(pool_is))
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
| boolean | True when name is `[LMaxPool2D](#lmaxpool2d)` or `LObject`. |

**Example**

```lua
do
    local pool = lurek.learning.newMaxPool2D(2, 2, 2, 2)
    local pool_type = pool:type()
    local pool_is = pool:typeOf("LMaxPool2D")
    example_print_log("LMaxPool2D:typeOf", tostring(pool:typeOf("LObject")))
    example_print_log("type = " .. tostring(pool:type()))
end
```

---

## LModel

### Type Fields

*No documented fields for this handle.*

### Type Methods

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
    local model_type = model:type()
    local is_model = model:typeOf("LModel")
    local action = model:predict(0)
    example_print_log("model predict = " .. action)
end
```

---

#### `LModel:type`

Returns this wrapper's stable type name `"[LModel](#lmodel)"`.

```lua
LModel:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LModel](#lmodel)`. |

**Example**

```lua
do
    local qlearner = lurek.learning.newQLearner(4, 2)
    local model = lurek.learning.wrap(qlearner)
    local model_type = model:type()
    local is_model = model:typeOf("LModel")
    example_print_log("model type = " .. model:type())
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
| `name` | string | Type name to compare against `[LModel](#lmodel)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this wrapper. |

**Example**

```lua
do
    local qlearner = lurek.learning.newQLearner(4, 2)
    local model = lurek.learning.wrap(qlearner)
    local model_type = model:type()
    local is_model = model:typeOf("LModel")
    example_print_log("model typeOf LModel = " .. tostring(model:typeOf("LModel")))
end
```

---

## LMultiHeadAttention

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LMultiHeadAttention:forward`

Runs multi-head self-attention over an input tensor shaped as `[seq_len,d_model]`.

```lua
LMultiHeadAttention:forward(input)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input` | [LTensor](#ltensor) | Input sequence tensor for attention. |

**Returns**

| Type | Description |
|------|-------------|
| [LTensor](#ltensor) | Output sequence tensor after attention projection. |

**Example**

```lua
do
    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    local mha_weights = mha:getWeights()
    local mha_params = mha:paramCount()
    local x = lurek.learning.newTensor({2, 4}, {1, 0, 0, 1, 0, 1, 1, 0})
    local out = mha:forward(x)
    example_print_log("LMultiHeadAttention:forward outShape", out:shape()[2])
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
    local mha_weights = mha:getWeights()
    local mha_params = mha:paramCount()
    local got = mha:getWeights()
    example_print_log("LMultiHeadAttention:getWeights", #got)
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
    local mha_weights = mha:getWeights()
    local mha_params = mha:paramCount()
    example_print_log("LMultiHeadAttention:paramCount", mha:paramCount())
    example_print_log("weight count = " .. #mha:getWeights())
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
    local mha_weights = mha:getWeights()
    local mha_params = mha:paramCount()
    local count = mha:paramCount()
    local weights = {}
    for i = 1, count do
        weights[i] = 0.0
    end
    mha:setWeights(weights)
    example_print_log("LMultiHeadAttention:setWeights count", count)
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
| string | The string `[LMultiHeadAttention](#lmultiheadattention)`. |

**Example**

```lua
do
    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    local mha_weights = mha:getWeights()
    local mha_params = mha:paramCount()
    example_print_log("LMultiHeadAttention:type", mha:type())
    example_print_log("attention configured = " .. tostring(mha_is))
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
| boolean | True when name is `[LMultiHeadAttention](#lmultiheadattention)` or `LObject`. |

**Example**

```lua
do
    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    local mha_weights = mha:getWeights()
    local mha_params = mha:paramCount()
    example_print_log("LMultiHeadAttention:typeOf", tostring(mha:typeOf("LObject")))
    example_print_log("type = " .. tostring(mha:type()))
end
```

---

## LNeuralEngine

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LNeuralEngine:addConv2D`

Appends a convolutional 2D block to this engine.

```lua
LNeuralEngine:addConv2D(args)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `args` | table | Tuple arguments: in_channels, out_channels, kernel_h, kernel_w, optional stride_h, stride_w, pad_h, pad_w. |

**Example**

```lua
do
    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    local engine_blocks = engine:blockCount()
    engine:addConv2D(1, 2, 3, 3, 1, 1, 1, 1)
    example_print_log("LNeuralEngine:addConv2D blocks", engine:blockCount())
end
```

---

#### `LNeuralEngine:addDense`

Appends a dense neural layer block.

```lua
LNeuralEngine:addDense(inputs, outputs, activation)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `inputs` | number | Input vector size. |
| `outputs` | number | Output vector size. |
| `activation?` | string | Activation name; defaults to `relu`. |

**Example**

```lua
do
    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    local engine_blocks = engine:blockCount()
    engine:addDense(3, 4, "relu")
    example_print_log("LNeuralEngine:addDense params", engine:paramCount())
end
```

---

#### `LNeuralEngine:addMaxPool2D`

Appends a non-trainable MaxPool2D block.

```lua
LNeuralEngine:addMaxPool2D(kernel_h, kernel_w, stride_h, stride_w)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `kernel_h` | number | Kernel height. |
| `kernel_w` | number | Kernel width. |
| `stride_h?` | number | Vertical stride; defaults to kernel_h. |
| `stride_w?` | number | Horizontal stride; defaults to kernel_w. |

**Example**

```lua
do
    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    local engine_blocks = engine:blockCount()
    engine:addMaxPool2D(2, 2)
    example_print_log("LNeuralEngine:addMaxPool2D params", engine:paramCount())
end
```

---

#### `LNeuralEngine:addTransformerEncoder`

Appends a transformer encoder block.

```lua
LNeuralEngine:addTransformerEncoder(d_model, heads, ff_hidden)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `d_model` | number | Model width. |
| `heads` | number | Number of attention heads. |
| `ff_hidden` | number | Feed-forward hidden width. |

**Example**

```lua
do
    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    local engine_blocks = engine:blockCount()
    engine:addTransformerEncoder(4, 2, 8)
    example_print_log("LNeuralEngine:addTransformerEncoder blocks", engine:blockCount())
end
```

---

#### `LNeuralEngine:blockCount`

Returns the number of blocks in this engine.

```lua
LNeuralEngine:blockCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Block count. |

**Example**

```lua
do
    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    engine:addMaxPool2D(2, 2)
    local weights = engine:getWeights()
    example_print_log("LNeuralEngine:blockCount", engine:blockCount())
end
```

---

#### `LNeuralEngine:getWeights`

Returns all trainable parameters in block insertion order.

```lua
LNeuralEngine:getWeights()
```

**Returns**

| Type | Description |
|------|-------------|
| number[] | Flat parameter array. |

**Example**

```lua
do
    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    engine:setWeights({ 0.1, 0.2, 0.3, 0.4, 0.0, 0.0 })
    local params = engine:paramCount()
    example_print_log("LNeuralEngine:getWeights count", #engine:getWeights())
end
```

---

#### `LNeuralEngine:paramCount`

Returns the total trainable parameter count.

```lua
LNeuralEngine:paramCount()
```

**Returns**

| Type | Description |
|------|-------------|
| number | Parameter count. |

**Example**

```lua
do
    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    engine:addConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    local weights = engine:getWeights()
    example_print_log("LNeuralEngine:paramCount", engine:paramCount())
end
```

---

#### `LNeuralEngine:setWeights`

Replaces all trainable parameters from a flat numeric array.

```lua
LNeuralEngine:setWeights(weights)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `weights` | table | Flat parameter array in block insertion order. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied weight count matches the engine shape. |

**Example**

```lua
do
    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    local weights = {}
    for i = 1, engine:paramCount() do
        weights[i] = 0.05 * i
    end
    example_print_log("LNeuralEngine:setWeights", engine:setWeights(weights))
end
```

---

#### `LNeuralEngine:type`

Returns the Lua-visible type name for this neural engine handle.

```lua
LNeuralEngine:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LNeuralEngine](#lneuralengine)`. |

**Example**

```lua
do
    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    local engine_blocks = engine:blockCount()
    example_print_log("LNeuralEngine:type", engine:type())
    example_print_log("engine blocks after setup = " .. engine:blockCount())
end
```

---

#### `LNeuralEngine:typeOf`

Returns whether this neural engine handle matches a supported type name.

```lua
LNeuralEngine:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | string | Type name to compare against `[LNeuralEngine](#lneuralengine)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    local engine_blocks = engine:blockCount()
    example_print_log("LNeuralEngine:typeOf", engine:typeOf("LNeuralEngine"))
    example_print_log("type = " .. tostring(engine:type()))
end
```

---

## LNeuralNet

### Type Fields

*No documented fields for this handle.*

### Type Methods

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
    net:addLayer(2, 4, "linear")
    local net_layers = net:layerCount()
    net:addLayer(4, 6, "relu")
    net:addLayer(6, 2, "sigmoid")

    example_print_log("LNeuralNet:addLayer layerCount", net:layerCount())
    example_print_log("LNeuralNet:addLayer paramCount", net:paramCount())
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
    net:addLayer(3, 4, "linear")
    local net_layers = net:layerCount()
    net:addLayer(4, 4, "relu")
    net:addLayer(4, 1, "sigmoid")
    local output = net:forward({ 0.1, 0.5, 0.9 })

    example_print_log("LNeuralNet:forward out", output[1])
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
    net:addLayer(2, 2, "linear")
    local net_layers = net:layerCount()
    net:addLayer(2, 3, "relu")
    local weights = net:getWeights()

    example_print_log("LNeuralNet:getWeights count", #weights)
    example_print_log("LNeuralNet:getWeights first", weights[1])
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
    net:addLayer(2, 4, "linear")
    local net_layers = net:layerCount()
    net:addLayer(4, 8, "relu")
    net:addLayer(8, 4, "relu")
    net:addLayer(4, 1, "sigmoid")

    example_print_log("LNeuralNet:layerCount", net:layerCount())
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
    net:addLayer(2, 4, "linear")
    local net_layers = net:layerCount()
    net:addLayer(4, 4, "relu")
    net:addLayer(4, 1, "sigmoid")

    example_print_log("LNeuralNet:paramCount", net:paramCount())
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
    nn:addLayer(2, 2, "linear")
    local layers = nn:layerCount()
    local action = nn:predict({0.5, 0.3})
    example_print_log("nn predict = " .. tostring(action))
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

    example_print_log("LNeuralNet:setWeights applied", tostring(applied))
    example_print_log("LNeuralNet:setWeights paramCount", net:paramCount())
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
| string | The string `[LNeuralNet](#lneuralnet)`. |

**Example**

```lua
do
    local net = lurek.learning.newNeuralNet()
    net:addLayer(2, 2, "linear")
    local net_layers = net:layerCount()
    local type_name = net:type()

    example_print_log("LNeuralNet:type", type_name)
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
| `name` | string | Type name to compare against `[LNeuralNet](#lneuralnet)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local net = lurek.learning.newNeuralNet()
    net:addLayer(2, 2, "linear")
    local net_layers = net:layerCount()
    local is_net = net:typeOf("LNeuralNet")
    local is_object = net:typeOf("LObject")

    example_print_log("LNeuralNet:typeOf LNeuralNet", tostring(is_net))
    example_print_log("LNeuralNet paramCount", net:paramCount())
end
```

---

## LNeuroevolution

### Type Fields

*No documented fields for this handle.*

### Type Methods

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

    example_print_log("LNeuroevolution:bestFitness", evo:bestFitness())
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
| [LNeuralNet](#lneuralnet) | Neural network handle. |

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
    example_print_log("LNeuroevolution:bestNetwork type", best_net:type())
    example_print_log("LNeuroevolution:bestNetwork layers", best_net:layerCount())
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
| [LNeuralNet](#lneuralnet) | Neural network handle. |

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

    example_print_log("LNeuroevolution:chromosomeToNet type", net:type())
    example_print_log("LNeuroevolution:chromosomeToNet out", output[1])
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
    example_print_log("LNeuroevolution:evolve generation", evo:generation())
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

    example_print_log("LNeuroevolution:generation", evo:generation())
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

    example_print_log("LNeuroevolution:popSize", pop_size)
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

    example_print_log("LNeuroevolution:setFitness generation", evo:generation())
    example_print_log("LNeuroevolution:setFitness bestFitness", evo:bestFitness())
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
| string | The string `[LNeuroevolution](#lneuroevolution)`. |

**Example**

```lua
do
    local layer_spec = {
        { inputs = 2, outputs = 3, activation = "relu" },
        { inputs = 3, outputs = 1, activation = "sigmoid" }
    }
    local evo = lurek.learning.newNeuroevolution(layer_spec, 4, 25)
    local type_name = evo:type()

    example_print_log("LNeuroevolution:type", type_name)
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
| `name` | string | Type name to compare against `[LNeuroevolution](#lneuroevolution)` and `Object`. |

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

    example_print_log("LNeuroevolution:typeOf LNeuroevolution", tostring(is_evo))
    example_print_log("LNeuroevolution popSize", evo:popSize())
end
```

---

## LOnnxModel

### Type Fields

*No documented fields for this handle.*

### Type Methods

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
    local model = lurek.learning.loadOnnx("content/examples/assets/minimal_identity.onnx")
    local input_count = model:inputCount()
    local output_count = model:outputCount()
    example_print_log("LOnnxModel:inputCount", model:inputCount())
    example_print_log("model type = " .. model:type())
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
    local model = lurek.learning.loadOnnx("content/examples/assets/minimal_identity.onnx")
    local input_count = model:inputCount()
    local output_count = model:outputCount()
    example_print_log("LOnnxModel:outputCount", model:outputCount())
    example_print_log("model type = " .. model:type())
end
```

---

#### `LOnnxModel:run`

Runs inference on a table of [LTensor](#ltensor) inputs and returns a table of [LTensor](#ltensor) outputs.

```lua
LOnnxModel:run(inputs)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `inputs` | table | Array-indexed table of [LTensor](#ltensor) input values. |

**Returns**

| Type | Description |
|------|-------------|
| table | Array-indexed table of [LTensor](#ltensor) output values. |

**Example**

```lua
do
    local model = lurek.learning.loadOnnx("content/examples/assets/minimal_identity.onnx")
    local input_count = model:inputCount()
    local output_count = model:outputCount()
    local input = lurek.learning.newTensor({1}, {42.0})
    local outputs = model:run({ input })
    example_print_log("LOnnxModel:run outputs", #outputs)
    example_print_log("LOnnxModel:run first value", outputs[1]:data()[1])
end
```

---

#### `LOnnxModel:type`

Returns the type name `"[LOnnxModel](#lonnxmodel)"`.

```lua
LOnnxModel:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LOnnxModel](#lonnxmodel)`. |

**Example**

```lua
do
    local model = lurek.learning.loadOnnx("content/examples/assets/minimal_identity.onnx")
    local input_count = model:inputCount()
    local output_count = model:outputCount()
    example_print_log("LOnnxModel:type", model:type())
    example_print_log("typeOf LOnnxModel = " .. tostring(model:typeOf("LOnnxModel")))
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
| `name` | string | Type name to compare against `[LOnnxModel](#lonnxmodel)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local model = lurek.learning.loadOnnx("content/examples/assets/minimal_identity.onnx")
    local input_count = model:inputCount()
    local output_count = model:outputCount()
    example_print_log("LOnnxModel:typeOf LOnnxModel", tostring(model:typeOf("LOnnxModel")))
    example_print_log("LOnnxModel:type", model:type())
end
```

---

## LPositionalEncoding

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LPositionalEncoding:apply`

Applies sinusoidal positional encoding values to a `[seq_len,d_model]` tensor.

```lua
LPositionalEncoding:apply(input)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input` | [LTensor](#ltensor) | Input sequence tensor to encode. |

**Returns**

| Type | Description |
|------|-------------|
| [LTensor](#ltensor) | Encoded sequence tensor with added positional values. |

**Example**

```lua
do
    local pe = lurek.learning.newPositionalEncoding(4, 8)
    local pe_type = pe:type()
    local pe_is = pe:typeOf("LPositionalEncoding")
    local x = lurek.learning.newTensor({2, 4}, {0, 0, 0, 0, 0, 0, 0, 0})
    local out = pe:apply(x)
    example_print_log("LPositionalEncoding:apply d1", out:data()[1])
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
| string | The string `[LPositionalEncoding](#lpositionalencoding)`. |

**Example**

```lua
do
    local pe = lurek.learning.newPositionalEncoding(4, 8)
    local pe_type = pe:type()
    local pe_is = pe:typeOf("LPositionalEncoding")
    example_print_log("LPositionalEncoding:type", pe:type())
    example_print_log("encoding configured = " .. tostring(pe_is))
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
| boolean | True when name is `[LPositionalEncoding](#lpositionalencoding)` or `LObject`. |

**Example**

```lua
do
    local pe = lurek.learning.newPositionalEncoding(4, 8)
    local pe_type = pe:type()
    local pe_is = pe:typeOf("LPositionalEncoding")
    example_print_log("LPositionalEncoding:typeOf", tostring(pe:typeOf("LObject")))
    example_print_log("type = " .. tostring(pe:type()))
end
```

---

## LQLearner

### Type Fields

*No documented fields for this handle.*

### Type Methods

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
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setQValue(1, 1, 0.5)
    learner:setQValue(1, 2, 1.2)
    learner:setQValue(1, 3, 0.8)

    example_print_log("LQLearner:bestAction", learner:bestAction(1))
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
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setExplorationRate(0.0)
    learner:setQValue(1, 2, 2.0)
    local chosen_action = learner:chooseAction(1)

    example_print_log("LQLearner:chooseAction", chosen_action)
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
    example_print_log("LQLearner:deserialize q23", restored:getQValue(2, 3))
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
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setExplorationRate(0.8)
    learner:setExplorationDecay(0.5)
    learner:endEpisode()

    example_print_log("LQLearner:endEpisode explorationRate", learner:getExplorationRate())
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
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    local action_count = learner:getActionCount()

    example_print_log("LQLearner:getActionCount", action_count)
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
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setDiscountFactor(0.95)

    example_print_log("LQLearner:getDiscountFactor", learner:getDiscountFactor())
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
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:endEpisode()
    learner:endEpisode()
    example_print_log("LQLearner:getEpisodeCount", learner:getEpisodeCount())
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
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setExplorationDecay(0.97)

    example_print_log("LQLearner:getExplorationDecay", learner:getExplorationDecay())
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
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setExplorationRate(0.35)

    example_print_log("LQLearner:getExplorationRate", learner:getExplorationRate())
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
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setLearningRate(0.05)

    example_print_log("LQLearner:getLearningRate", learner:getLearningRate())
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
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setQValue(2, 3, 7.5)
    local value = learner:getQValue(2, 3)

    example_print_log("LQLearner:getQValue", value)
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
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    local state_count = learner:getStateCount()

    example_print_log("LQLearner:getStateCount", state_count)
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
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setLearningRate(0.5)
    learner:setDiscountFactor(0.0)
    learner:learn(1, 2, 1.0, 3)

    example_print_log("LQLearner:learn q12", learner:getQValue(1, 2))
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
    q:setQValue(0, 0, 0.5)
    local states = q:getStateCount()
    local action = q:predict(0)
    example_print_log("qlearner predict = " .. action)
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
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setQValue(1, 1, 1.5)
    local json = learner:serialize()

    example_print_log("LQLearner:serialize length", #json)
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
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setDiscountFactor(0.95)

    example_print_log("LQLearner:setDiscountFactor", learner:getDiscountFactor())
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
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setExplorationDecay(0.99)

    example_print_log("LQLearner:setExplorationDecay", learner:getExplorationDecay())
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
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setExplorationRate(0.5)

    example_print_log("LQLearner:setExplorationRate", learner:getExplorationRate())
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
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setLearningRate(0.05)

    example_print_log("LQLearner:setLearningRate", learner:getLearningRate())
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
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setQValue(3, 2, 4.2)

    example_print_log("LQLearner:setQValue", learner:getQValue(3, 2))
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
| string | The string `[LQLearner](#lqlearner)`. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    local type_name = learner:type()

    example_print_log("LQLearner:type", type_name)
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
| `name` | string | Type name to compare against `[LQLearner](#lqlearner)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    local is_learner = learner:typeOf("LQLearner")
    local is_object = learner:typeOf("LObject")

    example_print_log("LQLearner:typeOf LQLearner", tostring(is_learner))
    example_print_log("LQLearner states", learner:getStateCount())
end
```

---

## LTensor

### Type Fields

*No documented fields for this handle.*

### Type Methods

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
    local tensor_shape = t:shape()
    local tensor_len = t:len()
    local d = t:data()
    example_print_log("LTensor:data len", #d)
    example_print_log("LTensor:data first", d[1])
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
    local tensor_shape = t:shape()
    local tensor_len = t:len()
    example_print_log("LTensor:get index1", t:get(1))
    example_print_log("LTensor:get index3", t:get(3))
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
    local tensor_shape = t:shape()
    local tensor_len = t:len()
    example_print_log("LTensor:len", t:len())
    example_print_log("tensor rank = " .. #tensor_shape)
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
    local tensor_shape = t:shape()
    local tensor_len = t:len()
    local s = t:shape()
    example_print_log("LTensor:shape rank", #s)
    example_print_log("LTensor:shape dim0", s[1])
end
```

---

#### `LTensor:type`

Returns the type name `"[LTensor](#ltensor)"`.

```lua
LTensor:type()
```

**Returns**

| Type | Description |
|------|-------------|
| string | The string `[LTensor](#ltensor)`. |

**Example**

```lua
do
    local t = lurek.learning.newTensor({1}, {0.0})
    local tensor_shape = t:shape()
    local tensor_len = t:len()
    example_print_log("LTensor:type", t:type())
    example_print_log("tensor len = " .. tensor_len)
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
| `name` | string | Type name to compare against `[LTensor](#ltensor)` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| boolean | True when the supplied type name matches this handle. |

**Example**

```lua
do
    local t = lurek.learning.newTensor({1}, {0.0})
    local tensor_shape = t:shape()
    local tensor_len = t:len()
    example_print_log("LTensor:typeOf LTensor", tostring(t:typeOf("LTensor")))
    example_print_log("LTensor data size", #t:data())
end
```

---

## LTransformerDecoder

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTransformerDecoder:forward`

Runs one transformer decoder block over input and encoder-output tensors.

```lua
LTransformerDecoder:forward(input, encoder_out)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input` | [LTensor](#ltensor) | Decoder input sequence tensor. |
| `encoder_out` | [LTensor](#ltensor) | Encoder output sequence tensor. |

**Returns**

| Type | Description |
|------|-------------|
| [LTensor](#ltensor) | Output sequence tensor after decoder block operations. |

**Example**

```lua
do
    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    local dec_weights = dec:getWeights()
    local dec_params = dec:paramCount()
    local x = lurek.learning.newTensor({2, 4}, {1, 2, 3, 4, 4, 3, 2, 1})
    local e = lurek.learning.newTensor({2, 4}, {0, 1, 0, 1, 1, 0, 1, 0})
    local out = dec:forward(x, e)
    example_print_log("LTransformerDecoder:forward outRows", out:shape()[1])
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
    local dec_weights = dec:getWeights()
    local dec_params = dec:paramCount()
    local got = dec:getWeights()
    example_print_log("LTransformerDecoder:getWeights", #got)
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
    local dec_weights = dec:getWeights()
    local dec_params = dec:paramCount()
    example_print_log("LTransformerDecoder:paramCount", dec:paramCount())
    example_print_log("weight count = " .. #dec:getWeights())
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
    local dec_weights = dec:getWeights()
    local dec_params = dec:paramCount()
    local count = dec:paramCount()
    local weights = {}
    for i = 1, count do
        weights[i] = 0.0
    end
    dec:setWeights(weights)
    example_print_log("LTransformerDecoder:setWeights count", count)
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
| string | The string `[LTransformerDecoder](#ltransformerdecoder)`. |

**Example**

```lua
do
    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    local dec_weights = dec:getWeights()
    local dec_params = dec:paramCount()
    example_print_log("LTransformerDecoder:type", dec:type())
    example_print_log("decoder configured = " .. tostring(dec_is))
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
| boolean | True when name is `[LTransformerDecoder](#ltransformerdecoder)` or `LObject`. |

**Example**

```lua
do
    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    local dec_weights = dec:getWeights()
    local dec_params = dec:paramCount()
    example_print_log("LTransformerDecoder:typeOf", tostring(dec:typeOf("LObject")))
    example_print_log("type = " .. tostring(dec:type()))
end
```

---

## LTransformerEncoder

### Type Fields

*No documented fields for this handle.*

### Type Methods

#### `LTransformerEncoder:forward`

Runs one transformer encoder block over an input `[seq_len,d_model]` tensor.

```lua
LTransformerEncoder:forward(input)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input` | [LTensor](#ltensor) | Input sequence tensor for encoder processing. |

**Returns**

| Type | Description |
|------|-------------|
| [LTensor](#ltensor) | Output sequence tensor after encoder block operations. |

**Example**

```lua
do
    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    local enc_weights = enc:getWeights()
    local enc_params = enc:paramCount()
    local x = lurek.learning.newTensor({2, 4}, {1, 2, 3, 4, 4, 3, 2, 1})
    local out = enc:forward(x)
    example_print_log("LTransformerEncoder:forward outRows", out:shape()[1])
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
    local enc_weights = enc:getWeights()
    local enc_params = enc:paramCount()
    local got = enc:getWeights()
    example_print_log("LTransformerEncoder:getWeights", #got)
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
    local enc_weights = enc:getWeights()
    local enc_params = enc:paramCount()
    example_print_log("LTransformerEncoder:paramCount", enc:paramCount())
    example_print_log("weight count = " .. #enc:getWeights())
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
    local enc_weights = enc:getWeights()
    local enc_params = enc:paramCount()
    local count = enc:paramCount()
    local weights = {}
    for i = 1, count do
        weights[i] = 0.0
    end
    enc:setWeights(weights)
    example_print_log("LTransformerEncoder:setWeights count", count)
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
| string | The string `[LTransformerEncoder](#ltransformerencoder)`. |

**Example**

```lua
do
    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    local enc_weights = enc:getWeights()
    local enc_params = enc:paramCount()
    example_print_log("LTransformerEncoder:type", enc:type())
    example_print_log("encoder configured = " .. tostring(enc_is))
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
| boolean | True when name is `[LTransformerEncoder](#ltransformerencoder)` or `LObject`. |

**Example**

```lua
do
    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    local enc_weights = enc:getWeights()
    local enc_params = enc:paramCount()
    example_print_log("LTransformerEncoder:typeOf", tostring(enc:typeOf("LObject")))
    example_print_log("type = " .. tostring(enc:type()))
end
```

---
