# Learning

- The `learning` module provides standalone machine learning and evolutionary computation algorithms that can be used independently or integrated with the AI decision-making systems.

The `learning` module extracts machine learning and evolutionary computation primitives into a focused, standalone subsystem. These algorithms have no dependency on the AI decision-making infrastructure (FSMs, behavior trees, GOAP, etc.) and can be used in any game context — from evolving creature behaviors to adaptive difficulty tuning to player modeling.

The module contains five core components:

- **NeuralNet** — A lightweight feed-forward neural network with configurable dense layers and activation functions (ReLU, Sigmoid, Tanh, Linear, Softmax). Supports forward inference, weight import/export, and parameter counting.

- **GeneticAlgorithm** — A population-based optimizer with tournament selection, single-point crossover, Gaussian mutation, and elitism. Uses a deterministic xorshift64 RNG for reproducible evolution runs.

- **Neuroevolution** — An orchestrator that combines `GeneticAlgorithm` with `NeuralNet` to evolve neural network weights through population-based search. Chromosomes map directly to network parameters.

- **QLearner** — A tabular Q-learning agent with epsilon-greedy exploration, Bellman updates, episode decay, and JSON serialization for policy persistence.

- **Bandit** — A multi-armed bandit with three selection strategies: epsilon-greedy, UCB1, and Thompson sampling. Tracks per-arm statistics and supports full reset.

All types are pure CPU, headless-testable, and have zero rendering dependencies. The module is exposed to Lua via `lurek.learning.*`.

## Functions

### `lurek.learning.newBandit`

Creates a multi-armed bandit with a named selection strategy.

```lua
-- signature
lurek.learning.newBandit(arm_count, strategy, epsilon, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `arm_count` | `number` | Number of selectable arms. |
| `strategy` | `string` | Strategy name such as `ucb1`, `thompson`, or an epsilon-greedy fallback. |
| `epsilon` | `number` | Exploration probability used by epsilon-greedy strategy and clamped to `[0, 1]`. |
| `seed` | `number` | Random seed used by the bandit. |

**Returns**

| Type | Description |
|------|-------------|
| `LBandit` | New bandit handle. |

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

### `lurek.learning.newGeneticAlgorithm`

Creates a genetic algorithm population with fixed chromosome length.

```lua
-- signature
lurek.learning.newGeneticAlgorithm(pop_size, gene_count, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `pop_size` | `number` | Number of chromosomes in the population. |
| `gene_count` | `number` | Number of floating-point genes per chromosome. |
| `seed` | `number` | Random seed used for population initialization and evolution. |

**Returns**

| Type | Description |
|------|-------------|
| `LGeneticAlgorithm` | New genetic algorithm handle. |

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

### `lurek.learning.newNeuralNet`

Creates an empty feed-forward neural network.

```lua
-- signature
lurek.learning.newNeuralNet()
```

**Returns**

| Type | Description |
|------|-------------|
| `LNeuralNet` | New neural network handle. |

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
-- signature
lurek.learning.newNeuroevolution(layer_spec, pop_size, seed)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `layer_spec` | `table` | Array of layer tables with `inputs`, `outputs`, and optional `activation` fields. |
| `pop_size` | `number` | Number of chromosomes in the population. |
| `seed` | `number` | Random seed used for population initialization and evolution. |

**Returns**

| Type | Description |
|------|-------------|
| `LNeuroevolution` | New neuroevolution handle. |

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

### `lurek.learning.newQLearner`

Creates a Q-learner with fixed state and action counts.

```lua
-- signature
lurek.learning.newQLearner(sc, ac)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `sc` | `number` | Number of discrete states. |
| `ac` | `number` | Number of discrete actions. |

**Returns**

| Type | Description |
|------|-------------|
| `LQLearner` | New Q-learner handle. |

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

### `lurek.learning.wrap`

Wraps a supported model (LQLearner, LNeuralNet, or LBandit) in a uniform LModel interface.

```lua
-- signature
lurek.learning.wrap(model)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `model` | `any` | An LQLearner, LNeuralNet, or LBandit instance. |

**Returns**

| Type | Description |
|------|-------------|
| `LModel` | A uniform model wrapper exposing predict(). |

---

## LBandit

### `LBandit:armCount`

Returns the number of arms in this bandit.

```lua
-- signature
LBandit:armCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Arm count. |

**Example**

```lua
do
    local bandit = lurek.learning.newBandit(4, "ucb1", 0.1, 1)
    local arm_count = bandit:armCount()

    print("LBandit:armCount", arm_count)
end
```

---

### `LBandit:bestArm`

Returns the arm with the best current estimate.

```lua
-- signature
LBandit:bestArm()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Zero-based best arm index. |

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

### `LBandit:predict`

Alias for `select`. Selects an arm using the configured bandit strategy.

```lua
-- signature
LBandit:predict()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Zero-based selected arm index. |

---

### `LBandit:reset`

Resets all bandit arm statistics. This method is available to Lua scripts.

```lua
-- signature
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

### `LBandit:select`

Selects an arm using the configured bandit strategy.

```lua
-- signature
LBandit:select()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Zero-based selected arm index. |

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

### `LBandit:totalPulls`

Returns the total number of arm selections recorded by this bandit.

```lua
-- signature
LBandit:totalPulls()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Total pull count. |

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

### `LBandit:type`

Returns the Lua-visible type name for this bandit handle.

```lua
-- signature
LBandit:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LBandit`. |

**Example**

```lua
do
    local bandit = lurek.learning.newBandit(3, "ucb1", 0.1, 6)
    local type_name = bandit:type()

    print("LBandit:type", type_name)
end
```

---

### `LBandit:typeOf`

Returns whether this bandit handle matches a supported type name.

```lua
-- signature
LBandit:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LBandit` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

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

### `LBandit:update`

Updates one arm with a received reward.

```lua
-- signature
LBandit:update(idx, reward)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | `number` | Zero-based arm index. |
| `reward` | `number` | Reward value assigned to the arm pull. |

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

## LGeneticAlgorithm

### `LGeneticAlgorithm:bestGenes`

Returns the genes for the best chromosome in the population.

```lua
-- signature
LGeneticAlgorithm:bestGenes()
```

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Array of best gene values, or an empty array when the population has no best chromosome. |

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

### `LGeneticAlgorithm:evolve`

Advances the genetic algorithm by one generation.

```lua
-- signature
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

### `LGeneticAlgorithm:generation`

Returns the current generation index.

```lua
-- signature
LGeneticAlgorithm:generation()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current generation count. |

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

### `LGeneticAlgorithm:getGenes`

Returns the genes for a chromosome by zero-based index.

```lua
-- signature
LGeneticAlgorithm:getGenes(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | `number` | Zero-based chromosome index. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Gene values, or an empty table for an invalid index. |

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

### `LGeneticAlgorithm:popSize`

Returns the population size. This method is available to Lua scripts.

```lua
-- signature
LGeneticAlgorithm:popSize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current population size. |

**Example**

```lua
do
    local ga = lurek.learning.newGeneticAlgorithm(15, 8, 14)
    local pop_size = ga:popSize()

    print("LGeneticAlgorithm:popSize", pop_size)
end
```

---

### `LGeneticAlgorithm:setFitness`

Sets the fitness value for a chromosome by zero-based index.

```lua
-- signature
LGeneticAlgorithm:setFitness(idx, fitness)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | `number` | Zero-based chromosome index. |
| `fitness` | `number` | Fitness value used by the next evolution step. |

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

### `LGeneticAlgorithm:type`

Returns the Lua-visible type name for this genetic algorithm handle.

```lua
-- signature
LGeneticAlgorithm:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LGeneticAlgorithm`. |

**Example**

```lua
do
    local ga = lurek.learning.newGeneticAlgorithm(4, 2, 16)
    local type_name = ga:type()

    print("LGeneticAlgorithm:type", type_name)
end
```

---

### `LGeneticAlgorithm:typeOf`

Returns whether this genetic algorithm handle matches a supported type name.

```lua
-- signature
LGeneticAlgorithm:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LGeneticAlgorithm` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

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

## LNeuralNet

### `LNeuralNet:addLayer`

Adds a neural network layer with an activation function.

```lua
-- signature
LNeuralNet:addLayer(inputs, outputs, activation)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `inputs` | `number` | Input count for the layer. |
| `outputs` | `number` | Output count for the layer. |
| `activation` | `string` | Activation name such as `relu`, `sigmoid`, `tanh`, `linear`, or `softmax`. |

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

### `LNeuralNet:forward`

Runs a forward pass and returns output values.

```lua
-- signature
LNeuralNet:forward(input)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input` | `table` | Array of numeric input values. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Numeric output values. |

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

### `LNeuralNet:getWeights`

Returns the network weights as a flat numeric array.

```lua
-- signature
LNeuralNet:getWeights()
```

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Numeric weights in engine layer order. |

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

### `LNeuralNet:layerCount`

Returns the number of layers in the network.

```lua
-- signature
LNeuralNet:layerCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Layer count. |

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

### `LNeuralNet:paramCount`

Returns the total number of trainable parameters.

```lua
-- signature
LNeuralNet:paramCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Parameter count. |

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

### `LNeuralNet:predict`

Alias for `forward`. Runs a forward pass and returns output values.

```lua
-- signature
LNeuralNet:predict(input)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `input` | `table` | Array of numeric input values. |

**Returns**

| Type | Description |
|------|-------------|
| `number[]` | Numeric output values. |

---

### `LNeuralNet:setWeights`

Replaces the network weights from a flat numeric array.

```lua
-- signature
LNeuralNet:setWeights(weights)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `weights` | `table` | Flat array of numeric weights in engine layer order. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied weight slice matches the network shape. |

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

### `LNeuralNet:type`

Returns the Lua-visible type name for this neural network handle.

```lua
-- signature
LNeuralNet:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LNeuralNet`. |

**Example**

```lua
do
    local net = lurek.learning.newNeuralNet()
    local type_name = net:type()

    print("LNeuralNet:type", type_name)
end
```

---

### `LNeuralNet:typeOf`

Returns whether this neural network handle matches a supported type name.

```lua
-- signature
LNeuralNet:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LNeuralNet` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

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

## LNeuroevolution

### `LNeuroevolution:bestFitness`

Returns the best fitness value in the population.

```lua
-- signature
LNeuroevolution:bestFitness()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Best fitness value. |

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

### `LNeuroevolution:bestNetwork`

Converts the best chromosome into a neural network handle when one exists.

```lua
-- signature
LNeuroevolution:bestNetwork()
```

**Returns**

| Type | Description |
|------|-------------|
| `LNeuralNet` | Neural network handle. |

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

### `LNeuroevolution:chromosomeToNet`

Converts one chromosome into a neural network handle when the index is valid.

```lua
-- signature
LNeuroevolution:chromosomeToNet(idx)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | `number` | Zero-based chromosome index. |

**Returns**

| Type | Description |
|------|-------------|
| `LNeuralNet` | Neural network handle. |

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

### `LNeuroevolution:evolve`

Advances the neuroevolution population by one generation.

```lua
-- signature
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

### `LNeuroevolution:generation`

Returns the current generation index.

```lua
-- signature
LNeuroevolution:generation()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current generation count. |

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

### `LNeuroevolution:popSize`

Returns the population size. This method is available to Lua scripts.

```lua
-- signature
LNeuroevolution:popSize()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current population size. |

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

### `LNeuroevolution:setFitness`

Sets the fitness value for a chromosome by zero-based index.

```lua
-- signature
LNeuroevolution:setFitness(idx, fitness)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `idx` | `number` | Zero-based chromosome index. |
| `fitness` | `number` | Fitness value used by the next evolution step. |

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

### `LNeuroevolution:type`

Returns the Lua-visible type name for this neuroevolution handle.

```lua
-- signature
LNeuroevolution:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LNeuroevolution`. |

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

### `LNeuroevolution:typeOf`

Returns whether this neuroevolution handle matches a supported type name.

```lua
-- signature
LNeuroevolution:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LNeuroevolution` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

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

## LQLearner

### `LQLearner:bestAction`

Returns the highest-valued action for a one-based state index without exploration.

```lua
-- signature
LQLearner:bestAction(state)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `state` | `number` | One-based state index. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | One-based best action index. |

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

### `LQLearner:chooseAction`

Chooses an action for a one-based state index using the learner's exploration policy.

```lua
-- signature
LQLearner:chooseAction(state)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `state` | `number` | One-based state index. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | One-based chosen action index. |

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

### `LQLearner:deserialize`

Replaces the Q-learner state from a JSON string.

```lua
-- signature
LQLearner:deserialize(json)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `json` | `string` | JSON data previously produced by `serialize`. |

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

### `LQLearner:endEpisode`

Decays epsilon and increments the episode count.

```lua
-- signature
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

### `LQLearner:getActionCount`

Returns the number of actions represented by this learner.

```lua
-- signature
LQLearner:getActionCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Action count. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(10, 4)
    local action_count = learner:getActionCount()

    print("LQLearner:getActionCount", action_count)
end
```

---

### `LQLearner:getDiscountFactor`

Returns the Q-learning gamma discount factor.

```lua
-- signature
LQLearner:getDiscountFactor()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current discount factor. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setDiscountFactor(0.95)

    print("LQLearner:getDiscountFactor", learner:getDiscountFactor())
end
```

---

### `LQLearner:getEpisodeCount`

Returns the total number of episodes completed so far.

```lua
-- signature
LQLearner:getEpisodeCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Episode count. |

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

### `LQLearner:getExplorationDecay`

Returns the exploration decay multiplier.

```lua
-- signature
LQLearner:getExplorationDecay()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current exploration decay multiplier. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setExplorationDecay(0.97)

    print("LQLearner:getExplorationDecay", learner:getExplorationDecay())
end
```

---

### `LQLearner:getExplorationRate`

Returns the exploration rate used by action selection.

```lua
-- signature
LQLearner:getExplorationRate()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current exploration rate. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setExplorationRate(0.35)

    print("LQLearner:getExplorationRate", learner:getExplorationRate())
end
```

---

### `LQLearner:getLearningRate`

Returns the Q-learning alpha learning rate.

```lua
-- signature
LQLearner:getLearningRate()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current learning rate. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setLearningRate(0.05)

    print("LQLearner:getLearningRate", learner:getLearningRate())
end
```

---

### `LQLearner:getQValue`

Returns the stored Q-value for a one-based state and action pair.

```lua
-- signature
LQLearner:getQValue(state, action)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `state` | `number` | One-based state index. |
| `action` | `number` | One-based action index. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | Current Q-value. |

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

### `LQLearner:getStateCount`

Returns the number of states represented by this learner.

```lua
-- signature
LQLearner:getStateCount()
```

**Returns**

| Type | Description |
|------|-------------|
| `number` | State count. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(10, 4)
    local state_count = learner:getStateCount()

    print("LQLearner:getStateCount", state_count)
end
```

---

### `LQLearner:learn`

Applies one Q-learning update from a transition and reward.

```lua
-- signature
LQLearner:learn(state, action, reward, next_state)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `state` | `number` | One-based previous state index. |
| `action` | `number` | One-based action index taken in the previous state. |
| `reward` | `number` | Reward received for the transition. |
| `next_state` | `number` | One-based next state index. |

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

### `LQLearner:predict`

Alias for `chooseAction`. Selects an action for the given one-based state using the learner's policy.

```lua
-- signature
LQLearner:predict(state)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `state` | `number` | One-based state index. |

**Returns**

| Type | Description |
|------|-------------|
| `number` | One-based chosen action index. |

---

### `LQLearner:serialize`

Serializes the Q-learner state to a JSON string.

```lua
-- signature
LQLearner:serialize()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | JSON representation of this learner. |

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

### `LQLearner:setDiscountFactor`

Sets the Q-learning gamma discount factor.

```lua
-- signature
LQLearner:setDiscountFactor(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Discount factor used by future updates. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setDiscountFactor(0.95)

    print("LQLearner:setDiscountFactor", learner:getDiscountFactor())
end
```

---

### `LQLearner:setExplorationDecay`

Sets the exploration decay multiplier applied across episodes.

```lua
-- signature
LQLearner:setExplorationDecay(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Exploration decay multiplier. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setExplorationDecay(0.99)

    print("LQLearner:setExplorationDecay", learner:getExplorationDecay())
end
```

---

### `LQLearner:setExplorationRate`

Sets the exploration rate used by action selection.

```lua
-- signature
LQLearner:setExplorationRate(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Exploration probability for future `chooseAction` calls. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setExplorationRate(0.5)

    print("LQLearner:setExplorationRate", learner:getExplorationRate())
end
```

---

### `LQLearner:setLearningRate`

Sets the Q-learning alpha learning rate.

```lua
-- signature
LQLearner:setLearningRate(v)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `v` | `number` | Learning rate used by future updates. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setLearningRate(0.05)

    print("LQLearner:setLearningRate", learner:getLearningRate())
end
```

---

### `LQLearner:setQValue`

Sets the stored Q-value for a one-based state and action pair.

```lua
-- signature
LQLearner:setQValue(state, action, value)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `state` | `number` | One-based state index. |
| `action` | `number` | One-based action index. |
| `value` | `number` | Q-value to store. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(8, 4)
    learner:setQValue(3, 2, 4.2)

    print("LQLearner:setQValue", learner:getQValue(3, 2))
end
```

---

### `LQLearner:type`

Returns the Lua-visible type name for this Q-learner handle.

```lua
-- signature
LQLearner:type()
```

**Returns**

| Type | Description |
|------|-------------|
| `string` | The string `LQLearner`. |

**Example**

```lua
do
    local learner = lurek.learning.newQLearner(10, 4)
    local type_name = learner:type()

    print("LQLearner:type", type_name)
end
```

---

### `LQLearner:typeOf`

Returns whether this Q-learner handle matches a supported type name.

```lua
-- signature
LQLearner:typeOf(name)
```

**Parameters**

| Name | Type | Description |
|------|------|-------------|
| `name` | `string` | Type name to compare against `LQLearner` and `Object`. |

**Returns**

| Type | Description |
|------|-------------|
| `boolean` | True when the supplied type name matches this handle. |

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
