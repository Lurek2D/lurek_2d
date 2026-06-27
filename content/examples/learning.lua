-- content/examples/learning.lua
-- Demonstrates the lurek.learning module: neural networks, genetic algorithms,
-- Q-learning, multi-armed bandits, and neuroevolution.


--@api: lurek.learning.newNeuralNet
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local net = lurek.learning.newNeuralNet()
    net:addLayer(3, 4, "linear")
    local net_layers = net:layerCount()
    net:addLayer(4, 4, "relu")
    net:addLayer(4, 2, "softmax")

    local output = net:forward({ 0.2, 0.6, -0.1 })
    example_print_log("lurek.learning.newNeuralNet layers", net:layerCount())
    example_print_log("lurek.learning.newNeuralNet firstOutput", output[1])
end

--@api: lurek.learning.newEngine
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    local engine_blocks = engine:blockCount()
    example_print_log("lurek.learning.newEngine blocks", engine:blockCount())
    example_print_log("engine params = " .. engine:paramCount())
end

--@api: LNeuralEngine:addDense
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    local engine_blocks = engine:blockCount()
    engine:addDense(3, 4, "relu")
    example_print_log("LNeuralEngine:addDense params", engine:paramCount())
end

--@api: LNeuralEngine:addConv2D
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    local engine_blocks = engine:blockCount()
    engine:addConv2D(1, 2, 3, 3, 1, 1, 1, 1)
    example_print_log("LNeuralEngine:addConv2D blocks", engine:blockCount())
end

--@api: LNeuralEngine:addMaxPool2D
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    local engine_blocks = engine:blockCount()
    engine:addMaxPool2D(2, 2)
    example_print_log("LNeuralEngine:addMaxPool2D params", engine:paramCount())
end

--@api: LNeuralEngine:addTransformerEncoder
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    local engine_blocks = engine:blockCount()
    engine:addTransformerEncoder(4, 2, 8)
    example_print_log("LNeuralEngine:addTransformerEncoder blocks", engine:blockCount())
end

--@api: LNeuralEngine:blockCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    engine:addMaxPool2D(2, 2)
    local weights = engine:getWeights()
    example_print_log("LNeuralEngine:blockCount", engine:blockCount())
end

--@api: LNeuralEngine:paramCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    engine:addConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    local weights = engine:getWeights()
    example_print_log("LNeuralEngine:paramCount", engine:paramCount())
end

--@api: LNeuralEngine:setWeights
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    local weights = {}
    for i = 1, engine:paramCount() do
        weights[i] = 0.05 * i
    end
    example_print_log("LNeuralEngine:setWeights", engine:setWeights(weights))
end

--@api: LNeuralEngine:getWeights
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    engine:setWeights({ 0.1, 0.2, 0.3, 0.4, 0.0, 0.0 })
    local params = engine:paramCount()
    example_print_log("LNeuralEngine:getWeights count", #engine:getWeights())
end

--@api: LNeuralEngine:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    local engine_blocks = engine:blockCount()
    example_print_log("LNeuralEngine:type", engine:type())
    example_print_log("engine blocks after setup = " .. engine:blockCount())
end

--@api: LNeuralEngine:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    local engine_blocks = engine:blockCount()
    example_print_log("LNeuralEngine:typeOf", engine:typeOf("LNeuralEngine"))
    example_print_log("type = " .. tostring(engine:type()))
end

--@api: lurek.learning.newGeneticAlgorithm
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: lurek.learning.newQLearner
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local learner = lurek.learning.newQLearner(4, 3)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setLearningRate(0.2)
    learner:setDiscountFactor(0.9)
    learner:learn(1, 2, 1.0, 3)

    example_print_log("lurek.learning.newQLearner states", learner:getStateCount())
    example_print_log("lurek.learning.newQLearner q12", learner:getQValue(1, 2))
end

--@api: lurek.learning.newBandit
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local bandit = lurek.learning.newBandit(4, "ucb1", 0.1, 99)
    local warmup_arm = bandit:select()
    bandit:update(warmup_arm, 0.1)
    local chosen_arm = bandit:select()
    bandit:update(chosen_arm, 0.75)

    example_print_log("lurek.learning.newBandit chosenArm", chosen_arm)
    example_print_log("lurek.learning.newBandit totalPulls", bandit:totalPulls())
end

--@api: lurek.learning.newNeuroevolution
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: LBandit:armCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local bandit = lurek.learning.newBandit(4, "ucb1", 0.1, 1)
    local warmup_arm = bandit:select()
    bandit:update(warmup_arm, 0.1)
    local arm_count = bandit:armCount()

    example_print_log("LBandit:armCount", arm_count)
end

--@api: LBandit:bestArm
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local bandit = lurek.learning.newBandit(3, "ucb1", 0.1, 2)
    local warmup_arm = bandit:select()
    bandit:update(warmup_arm, 0.1)
    bandit:update(0, 0.25)
    bandit:update(1, 0.9)
    bandit:update(2, 0.4)

    example_print_log("LBandit:bestArm", bandit:bestArm())
end

--@api: LBandit:reset
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local bandit = lurek.learning.newBandit(3, "thompson", 0.1, 3)
    local warmup_arm = bandit:select()
    bandit:update(warmup_arm, 0.1)
    local selected_arm = bandit:select()
    bandit:update(selected_arm, 0.5)
    bandit:reset()

    example_print_log("LBandit:reset pulls", bandit:totalPulls())
    example_print_log("LBandit:reset bestArm", bandit:bestArm())
end

--@api: LBandit:select
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local bandit = lurek.learning.newBandit(5, "thompson", 0.1, 4)
    local warmup_arm = bandit:select()
    bandit:update(warmup_arm, 0.1)
    local first_arm = bandit:select()
    local second_arm = bandit:select()

    example_print_log("LBandit:select first", first_arm)
    example_print_log("LBandit:select second", second_arm)
end

--@api: LBandit:totalPulls
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local bandit = lurek.learning.newBandit(3, "ucb1", 0.1, 5)
    local warmup_arm = bandit:select()
    bandit:update(warmup_arm, 0.1)
    bandit:select()
    bandit:select()
    local total_pulls = bandit:totalPulls()

    example_print_log("LBandit:totalPulls", total_pulls)
end

--@api: LBandit:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local bandit = lurek.learning.newBandit(3, "ucb1", 0.1, 6)
    local warmup_arm = bandit:select()
    bandit:update(warmup_arm, 0.1)
    local type_name = bandit:type()

    example_print_log("LBandit:type", type_name)
end

--@api: LBandit:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local bandit = lurek.learning.newBandit(3, "ucb1", 0.1, 7)
    local warmup_arm = bandit:select()
    bandit:update(warmup_arm, 0.1)
    local is_bandit = bandit:typeOf("LBandit")
    local is_object = bandit:typeOf("LObject")

    example_print_log("LBandit:typeOf LBandit", tostring(is_bandit))
    example_print_log("LBandit totalPulls", bandit:totalPulls())
end

--@api: LBandit:update
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local bandit = lurek.learning.newBandit(4, "ucb1", 0.1, 8)
    local warmup_arm = bandit:select()
    bandit:update(warmup_arm, 0.1)
    local arm_index = bandit:select()
    bandit:update(arm_index, 0.8)

    example_print_log("LBandit:update arm", arm_index)
    example_print_log("LBandit:update bestArm", bandit:bestArm())
end

--@api: LGeneticAlgorithm:bestGenes
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: LGeneticAlgorithm:evolve
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ga = lurek.learning.newGeneticAlgorithm(5, 4, 11)
    ga:setFitness(0, 0.1)
    local ga_generation = ga:generation()

    for index = 0, ga:popSize() - 1 do
        ga:setFitness(index, index * 0.5)
    end

    ga:evolve()
    example_print_log("LGeneticAlgorithm:evolve generation", ga:generation())
end

--@api: LGeneticAlgorithm:generation
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ga = lurek.learning.newGeneticAlgorithm(4, 3, 12)
    ga:setFitness(0, 0.1)
    local ga_generation = ga:generation()
    ga:evolve()
    ga:evolve()

    example_print_log("LGeneticAlgorithm:generation", ga:generation())
end

--@api: LGeneticAlgorithm:getGenes
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ga = lurek.learning.newGeneticAlgorithm(4, 5, 13)
    ga:setFitness(0, 0.1)
    local ga_generation = ga:generation()
    local genes = ga:getGenes(0)

    example_print_log("LGeneticAlgorithm:getGenes count", #genes)
    example_print_log("LGeneticAlgorithm:getGenes first", genes[1])
end

--@api: LGeneticAlgorithm:popSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ga = lurek.learning.newGeneticAlgorithm(15, 8, 14)
    ga:setFitness(0, 0.1)
    local ga_generation = ga:generation()
    local pop_size = ga:popSize()

    example_print_log("LGeneticAlgorithm:popSize", pop_size)
end

--@api: LGeneticAlgorithm:setFitness
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ga = lurek.learning.newGeneticAlgorithm(6, 3, 15)
    ga:setFitness(0, 0.1)
    local ga_generation = ga:generation()
    ga:setFitness(0, 1.25)
    ga:setFitness(1, 0.5)
    ga:evolve()

    example_print_log("LGeneticAlgorithm:setFitness generation", ga:generation())
    example_print_log("LGeneticAlgorithm:setFitness bestGenes", #ga:bestGenes())
end

--@api: LGeneticAlgorithm:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ga = lurek.learning.newGeneticAlgorithm(4, 2, 16)
    ga:setFitness(0, 0.1)
    local ga_generation = ga:generation()
    local type_name = ga:type()

    example_print_log("LGeneticAlgorithm:type", type_name)
end

--@api: LGeneticAlgorithm:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local ga = lurek.learning.newGeneticAlgorithm(4, 2, 17)
    ga:setFitness(0, 0.1)
    local ga_generation = ga:generation()
    local is_ga = ga:typeOf("LGeneticAlgorithm")
    local is_object = ga:typeOf("LObject")

    example_print_log("LGeneticAlgorithm:typeOf LGeneticAlgorithm", tostring(is_ga))
    example_print_log("LGeneticAlgorithm popSize", ga:popSize())
end

--@api: LNeuralNet:addLayer
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local net = lurek.learning.newNeuralNet()
    net:addLayer(2, 4, "linear")
    local net_layers = net:layerCount()
    net:addLayer(4, 6, "relu")
    net:addLayer(6, 2, "sigmoid")

    example_print_log("LNeuralNet:addLayer layerCount", net:layerCount())
    example_print_log("LNeuralNet:addLayer paramCount", net:paramCount())
end

--@api: LNeuralNet:forward
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local net = lurek.learning.newNeuralNet()
    net:addLayer(3, 4, "linear")
    local net_layers = net:layerCount()
    net:addLayer(4, 4, "relu")
    net:addLayer(4, 1, "sigmoid")
    local output = net:forward({ 0.1, 0.5, 0.9 })

    example_print_log("LNeuralNet:forward out", output[1])
end

--@api: LNeuralNet:getWeights
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local net = lurek.learning.newNeuralNet()
    net:addLayer(2, 2, "linear")
    local net_layers = net:layerCount()
    net:addLayer(2, 3, "relu")
    local weights = net:getWeights()

    example_print_log("LNeuralNet:getWeights count", #weights)
    example_print_log("LNeuralNet:getWeights first", weights[1])
end

--@api: LNeuralNet:layerCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local net = lurek.learning.newNeuralNet()
    net:addLayer(2, 4, "linear")
    local net_layers = net:layerCount()
    net:addLayer(4, 8, "relu")
    net:addLayer(8, 4, "relu")
    net:addLayer(4, 1, "sigmoid")

    example_print_log("LNeuralNet:layerCount", net:layerCount())
end

--@api: LNeuralNet:paramCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local net = lurek.learning.newNeuralNet()
    net:addLayer(2, 4, "linear")
    local net_layers = net:layerCount()
    net:addLayer(4, 4, "relu")
    net:addLayer(4, 1, "sigmoid")

    example_print_log("LNeuralNet:paramCount", net:paramCount())
end

--@api: LNeuralNet:setWeights
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local net = lurek.learning.newNeuralNet()
    net:addLayer(2, 2, "linear")
    local weights = net:getWeights()
    local applied = net:setWeights(weights)

    example_print_log("LNeuralNet:setWeights applied", tostring(applied))
    example_print_log("LNeuralNet:setWeights paramCount", net:paramCount())
end

--@api: LNeuralNet:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local net = lurek.learning.newNeuralNet()
    net:addLayer(2, 2, "linear")
    local net_layers = net:layerCount()
    local type_name = net:type()

    example_print_log("LNeuralNet:type", type_name)
end

--@api: LNeuralNet:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local net = lurek.learning.newNeuralNet()
    net:addLayer(2, 2, "linear")
    local net_layers = net:layerCount()
    local is_net = net:typeOf("LNeuralNet")
    local is_object = net:typeOf("LObject")

    example_print_log("LNeuralNet:typeOf LNeuralNet", tostring(is_net))
    example_print_log("LNeuralNet paramCount", net:paramCount())
end

--@api: LNeuroevolution:bestFitness
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: LNeuroevolution:bestNetwork
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: LNeuroevolution:chromosomeToNet
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: LNeuroevolution:evolve
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: LNeuroevolution:generation
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local layer_spec = {
        { inputs = 2, outputs = 2, activation = "relu" },
        { inputs = 2, outputs = 1, activation = "sigmoid" }
    }
    local evo = lurek.learning.newNeuroevolution(layer_spec, 4, 22)
    evo:evolve()

    example_print_log("LNeuroevolution:generation", evo:generation())
end

--@api: LNeuroevolution:popSize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local layer_spec = {
        { inputs = 2, outputs = 3, activation = "relu" },
        { inputs = 3, outputs = 1, activation = "linear" }
    }
    local evo = lurek.learning.newNeuroevolution(layer_spec, 12, 23)
    local pop_size = evo:popSize()

    example_print_log("LNeuroevolution:popSize", pop_size)
end

--@api: LNeuroevolution:setFitness
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: LNeuroevolution:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local layer_spec = {
        { inputs = 2, outputs = 3, activation = "relu" },
        { inputs = 3, outputs = 1, activation = "sigmoid" }
    }
    local evo = lurek.learning.newNeuroevolution(layer_spec, 4, 25)
    local type_name = evo:type()

    example_print_log("LNeuroevolution:type", type_name)
end

--@api: LNeuroevolution:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: lurek.learning.newLstm
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lstm = lurek.learning.newLstm(2, 3)
    local lstm_weights = lstm:getWeights()
    local lstm_params = lstm:paramCount()
    example_print_log("lurek.learning.newLstm type", lstm:type())
    example_print_log("weight count = " .. #lstm_weights)
end

--@api: LLSTM:forward
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lstm = lurek.learning.newLstm(2, 3)
    local lstm_weights = lstm:getWeights()
    local lstm_params = lstm:paramCount()
    local out = lstm:forward({ 0.1, -0.2 })
    example_print_log("LLSTM:forward outLen", #out)
end

--@api: lurek.learning.newGru
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local gru = lurek.learning.newGru(2, 3)
    local gru_weights = gru:getWeights()
    local gru_params = gru:paramCount()
    example_print_log("lurek.learning.newGru type", gru:type())
    example_print_log("weight count = " .. #gru_weights)
end

--@api: LGRU:forward
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local gru = lurek.learning.newGru(2, 3)
    local gru_weights = gru:getWeights()
    local gru_params = gru:paramCount()
    local out = gru:forward({ 0.1, -0.2 })
    example_print_log("LGRU:forward outLen", #out)
end

--@api: lurek.learning.newConv2D
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    local conv_weights = conv:getWeights()
    local conv_params = conv:paramCount()
    example_print_log("lurek.learning.newConv2D type", conv:type())
    example_print_log("weight count = " .. #conv_weights)
end

--@api: LConv2D:forward
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    local conv_weights = conv:getWeights()
    local conv_params = conv:paramCount()
    local input = lurek.learning.newTensor({1, 2, 2}, {1, 2, 3, 4})
    local out = conv:forward(input)
    example_print_log("LConv2D:forward outW", out:shape()[3])
end

--@api: lurek.learning.newMaxPool2D
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pool = lurek.learning.newMaxPool2D(2, 2, 2, 2)
    local pool_type = pool:type()
    local pool_is = pool:typeOf("LMaxPool2D")
    example_print_log("lurek.learning.newMaxPool2D type", pool:type())
    example_print_log("pool configured = " .. tostring(pool_is))
end

--@api: LMaxPool2D:forward
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: lurek.learning.newPositionalEncoding
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pe = lurek.learning.newPositionalEncoding(4, 8)
    local pe_type = pe:type()
    local pe_is = pe:typeOf("LPositionalEncoding")
    example_print_log("lurek.learning.newPositionalEncoding type", pe:type())
    example_print_log("encoding configured = " .. tostring(pe_is))
end

--@api: LPositionalEncoding:apply
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pe = lurek.learning.newPositionalEncoding(4, 8)
    local pe_type = pe:type()
    local pe_is = pe:typeOf("LPositionalEncoding")
    local x = lurek.learning.newTensor({2, 4}, {0, 0, 0, 0, 0, 0, 0, 0})
    local out = pe:apply(x)
    example_print_log("LPositionalEncoding:apply d1", out:data()[1])
end

--@api: lurek.learning.newMultiHeadAttention
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    local mha_weights = mha:getWeights()
    local mha_params = mha:paramCount()
    example_print_log("lurek.learning.newMultiHeadAttention type", mha:type())
    example_print_log("attention configured = " .. tostring(mha_is))
end

--@api: LMultiHeadAttention:forward
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    local mha_weights = mha:getWeights()
    local mha_params = mha:paramCount()
    local x = lurek.learning.newTensor({2, 4}, {1, 0, 0, 1, 0, 1, 1, 0})
    local out = mha:forward(x)
    example_print_log("LMultiHeadAttention:forward outShape", out:shape()[2])
end

--@api: lurek.learning.newTransformerEncoder
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    local enc_weights = enc:getWeights()
    local enc_params = enc:paramCount()
    example_print_log("lurek.learning.newTransformerEncoder type", enc:type())
    example_print_log("encoder configured = " .. tostring(enc_is))
end

--@api: LTransformerEncoder:forward
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    local enc_weights = enc:getWeights()
    local enc_params = enc:paramCount()
    local x = lurek.learning.newTensor({2, 4}, {1, 2, 3, 4, 4, 3, 2, 1})
    local out = enc:forward(x)
    example_print_log("LTransformerEncoder:forward outRows", out:shape()[1])
end

--@api: lurek.learning.newTransformerDecoder
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    local dec_weights = dec:getWeights()
    local dec_params = dec:paramCount()
    example_print_log("lurek.learning.newTransformerDecoder type", dec:type())
    example_print_log("decoder configured = " .. tostring(dec_is))
end

--@api: LTransformerDecoder:forward
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    local dec_weights = dec:getWeights()
    local dec_params = dec:paramCount()
    local x = lurek.learning.newTensor({2, 4}, {1, 2, 3, 4, 4, 3, 2, 1})
    local e = lurek.learning.newTensor({2, 4}, {0, 1, 0, 1, 1, 0, 1, 0})
    local out = dec:forward(x, e)
    example_print_log("LTransformerDecoder:forward outRows", out:shape()[1])
end

--@api: LLSTM:reset
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lstm = lurek.learning.newLstm(2, 2)
    local lstm_weights = lstm:getWeights()
    local lstm_params = lstm:paramCount()
    lstm:reset()
    example_print_log("LLSTM:reset ok")
end

--@api: LLSTM:setWeights
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: LLSTM:getWeights
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lstm = lurek.learning.newLstm(2, 2)
    local lstm_weights = lstm:getWeights()
    local lstm_params = lstm:paramCount()
    local got = lstm:getWeights()
    example_print_log("LLSTM:getWeights", #got)
end

--@api: LLSTM:paramCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lstm = lurek.learning.newLstm(2, 2)
    local lstm_weights = lstm:getWeights()
    local lstm_params = lstm:paramCount()
    example_print_log("LLSTM:paramCount", lstm:paramCount())
    example_print_log("weight count = " .. #lstm_weights)
end

--@api: LLSTM:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lstm = lurek.learning.newLstm(2, 2)
    local lstm_weights = lstm:getWeights()
    local lstm_params = lstm:paramCount()
    example_print_log("LLSTM:type", lstm:type())
    example_print_log("weight count = " .. #lstm_weights)
end

--@api: LLSTM:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lstm = lurek.learning.newLstm(2, 2)
    local lstm_weights = lstm:getWeights()
    local lstm_params = lstm:paramCount()
    example_print_log("LLSTM:typeOf", tostring(lstm:typeOf("LObject")))
    example_print_log("type = " .. tostring(lstm:type()))
end

--@api: LGRU:reset
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local gru = lurek.learning.newGru(2, 2)
    local gru_weights = gru:getWeights()
    local gru_params = gru:paramCount()
    gru:reset()
    example_print_log("LGRU:reset ok")
end

--@api: LGRU:setWeights
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: LGRU:getWeights
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local gru = lurek.learning.newGru(2, 2)
    local gru_weights = gru:getWeights()
    local gru_params = gru:paramCount()
    local got = gru:getWeights()
    example_print_log("LGRU:getWeights", #got)
end

--@api: LGRU:paramCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local gru = lurek.learning.newGru(2, 2)
    local gru_weights = gru:getWeights()
    local gru_params = gru:paramCount()
    example_print_log("LGRU:paramCount", gru:paramCount())
    example_print_log("weight count = " .. #gru_weights)
end

--@api: LGRU:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local gru = lurek.learning.newGru(2, 2)
    local gru_weights = gru:getWeights()
    local gru_params = gru:paramCount()
    example_print_log("LGRU:type", gru:type())
    example_print_log("weight count = " .. #gru_weights)
end

--@api: LGRU:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local gru = lurek.learning.newGru(2, 2)
    local gru_weights = gru:getWeights()
    local gru_params = gru:paramCount()
    example_print_log("LGRU:typeOf", tostring(gru:typeOf("LObject")))
    example_print_log("type = " .. tostring(gru:type()))
end

--@api: LConv2D:setWeights
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: LConv2D:getWeights
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    local conv_weights = conv:getWeights()
    local conv_params = conv:paramCount()
    local got = conv:getWeights()
    example_print_log("LConv2D:getWeights", #got)
end

--@api: LConv2D:paramCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    local conv_weights = conv:getWeights()
    local conv_params = conv:paramCount()
    example_print_log("LConv2D:paramCount", conv:paramCount())
    example_print_log("weight count = " .. #conv_weights)
end

--@api: LConv2D:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    local conv_weights = conv:getWeights()
    local conv_params = conv:paramCount()
    example_print_log("LConv2D:type", conv:type())
    example_print_log("weight count = " .. #conv_weights)
end

--@api: LConv2D:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    local conv_weights = conv:getWeights()
    local conv_params = conv:paramCount()
    example_print_log("LConv2D:typeOf", tostring(conv:typeOf("LObject")))
    example_print_log("type = " .. tostring(conv:type()))
end

--@api: LMaxPool2D:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pool = lurek.learning.newMaxPool2D(2, 2, 2, 2)
    local pool_type = pool:type()
    local pool_is = pool:typeOf("LMaxPool2D")
    example_print_log("LMaxPool2D:type", pool:type())
    example_print_log("pool configured = " .. tostring(pool_is))
end

--@api: LMaxPool2D:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pool = lurek.learning.newMaxPool2D(2, 2, 2, 2)
    local pool_type = pool:type()
    local pool_is = pool:typeOf("LMaxPool2D")
    example_print_log("LMaxPool2D:typeOf", tostring(pool:typeOf("LObject")))
    example_print_log("type = " .. tostring(pool:type()))
end

--@api: LPositionalEncoding:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pe = lurek.learning.newPositionalEncoding(4, 8)
    local pe_type = pe:type()
    local pe_is = pe:typeOf("LPositionalEncoding")
    example_print_log("LPositionalEncoding:type", pe:type())
    example_print_log("encoding configured = " .. tostring(pe_is))
end

--@api: LPositionalEncoding:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local pe = lurek.learning.newPositionalEncoding(4, 8)
    local pe_type = pe:type()
    local pe_is = pe:typeOf("LPositionalEncoding")
    example_print_log("LPositionalEncoding:typeOf", tostring(pe:typeOf("LObject")))
    example_print_log("type = " .. tostring(pe:type()))
end

--@api: LMultiHeadAttention:setWeights
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: LMultiHeadAttention:getWeights
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    local mha_weights = mha:getWeights()
    local mha_params = mha:paramCount()
    local got = mha:getWeights()
    example_print_log("LMultiHeadAttention:getWeights", #got)
end

--@api: LMultiHeadAttention:paramCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    local mha_weights = mha:getWeights()
    local mha_params = mha:paramCount()
    example_print_log("LMultiHeadAttention:paramCount", mha:paramCount())
    example_print_log("weight count = " .. #mha:getWeights())
end

--@api: LMultiHeadAttention:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    local mha_weights = mha:getWeights()
    local mha_params = mha:paramCount()
    example_print_log("LMultiHeadAttention:type", mha:type())
    example_print_log("attention configured = " .. tostring(mha_is))
end

--@api: LMultiHeadAttention:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    local mha_weights = mha:getWeights()
    local mha_params = mha:paramCount()
    example_print_log("LMultiHeadAttention:typeOf", tostring(mha:typeOf("LObject")))
    example_print_log("type = " .. tostring(mha:type()))
end

--@api: LTransformerEncoder:setWeights
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: LTransformerEncoder:getWeights
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    local enc_weights = enc:getWeights()
    local enc_params = enc:paramCount()
    local got = enc:getWeights()
    example_print_log("LTransformerEncoder:getWeights", #got)
end

--@api: LTransformerEncoder:paramCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    local enc_weights = enc:getWeights()
    local enc_params = enc:paramCount()
    example_print_log("LTransformerEncoder:paramCount", enc:paramCount())
    example_print_log("weight count = " .. #enc:getWeights())
end

--@api: LTransformerEncoder:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    local enc_weights = enc:getWeights()
    local enc_params = enc:paramCount()
    example_print_log("LTransformerEncoder:type", enc:type())
    example_print_log("encoder configured = " .. tostring(enc_is))
end

--@api: LTransformerEncoder:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    local enc_weights = enc:getWeights()
    local enc_params = enc:paramCount()
    example_print_log("LTransformerEncoder:typeOf", tostring(enc:typeOf("LObject")))
    example_print_log("type = " .. tostring(enc:type()))
end

--@api: LTransformerDecoder:setWeights
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: LTransformerDecoder:getWeights
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    local dec_weights = dec:getWeights()
    local dec_params = dec:paramCount()
    local got = dec:getWeights()
    example_print_log("LTransformerDecoder:getWeights", #got)
end

--@api: LTransformerDecoder:paramCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    local dec_weights = dec:getWeights()
    local dec_params = dec:paramCount()
    example_print_log("LTransformerDecoder:paramCount", dec:paramCount())
    example_print_log("weight count = " .. #dec:getWeights())
end

--@api: LTransformerDecoder:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    local dec_weights = dec:getWeights()
    local dec_params = dec:paramCount()
    example_print_log("LTransformerDecoder:type", dec:type())
    example_print_log("decoder configured = " .. tostring(dec_is))
end

--@api: LTransformerDecoder:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    local dec_weights = dec:getWeights()
    local dec_params = dec:paramCount()
    example_print_log("LTransformerDecoder:typeOf", tostring(dec:typeOf("LObject")))
    example_print_log("type = " .. tostring(dec:type()))
end

--@api: LQLearner:bestAction
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local learner = lurek.learning.newQLearner(5, 3)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setQValue(1, 1, 0.5)
    learner:setQValue(1, 2, 1.2)
    learner:setQValue(1, 3, 0.8)

    example_print_log("LQLearner:bestAction", learner:bestAction(1))
end

--@api: LQLearner:chooseAction
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local learner = lurek.learning.newQLearner(5, 3)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setExplorationRate(0.0)
    learner:setQValue(1, 2, 2.0)
    local chosen_action = learner:chooseAction(1)

    example_print_log("LQLearner:chooseAction", chosen_action)
end

--@api: LQLearner:deserialize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local source = lurek.learning.newQLearner(5, 3)
    source:setQValue(2, 3, 3.14)
    local saved = source:serialize()

    local restored = lurek.learning.newQLearner(5, 3)
    restored:deserialize(saved)
    example_print_log("LQLearner:deserialize q23", restored:getQValue(2, 3))
end

--@api: LQLearner:endEpisode
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local learner = lurek.learning.newQLearner(8, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setExplorationRate(0.8)
    learner:setExplorationDecay(0.5)
    learner:endEpisode()

    example_print_log("LQLearner:endEpisode explorationRate", learner:getExplorationRate())
end

--@api: LQLearner:getActionCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    local action_count = learner:getActionCount()

    example_print_log("LQLearner:getActionCount", action_count)
end

--@api: LQLearner:getDiscountFactor
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setDiscountFactor(0.95)

    example_print_log("LQLearner:getDiscountFactor", learner:getDiscountFactor())
end

--@api: LQLearner:getExplorationDecay
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setExplorationDecay(0.97)

    example_print_log("LQLearner:getExplorationDecay", learner:getExplorationDecay())
end

--@api: LQLearner:getExplorationRate
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setExplorationRate(0.35)

    example_print_log("LQLearner:getExplorationRate", learner:getExplorationRate())
end

--@api: LQLearner:getLearningRate
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setLearningRate(0.05)

    example_print_log("LQLearner:getLearningRate", learner:getLearningRate())
end

--@api: LQLearner:getQValue
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setQValue(2, 3, 7.5)
    local value = learner:getQValue(2, 3)

    example_print_log("LQLearner:getQValue", value)
end

--@api: LQLearner:getStateCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    local state_count = learner:getStateCount()

    example_print_log("LQLearner:getStateCount", state_count)
end

--@api: LQLearner:learn
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local learner = lurek.learning.newQLearner(6, 3)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setLearningRate(0.5)
    learner:setDiscountFactor(0.0)
    learner:learn(1, 2, 1.0, 3)

    example_print_log("LQLearner:learn q12", learner:getQValue(1, 2))
end

--@api: LQLearner:serialize
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local learner = lurek.learning.newQLearner(5, 3)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setQValue(1, 1, 1.5)
    local json = learner:serialize()

    example_print_log("LQLearner:serialize length", #json)
end

--@api: LQLearner:setDiscountFactor
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setDiscountFactor(0.95)

    example_print_log("LQLearner:setDiscountFactor", learner:getDiscountFactor())
end

--@api: LQLearner:setExplorationDecay
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setExplorationDecay(0.99)

    example_print_log("LQLearner:setExplorationDecay", learner:getExplorationDecay())
end

--@api: LQLearner:setExplorationRate
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setExplorationRate(0.5)

    example_print_log("LQLearner:setExplorationRate", learner:getExplorationRate())
end

--@api: LQLearner:setLearningRate
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setLearningRate(0.05)

    example_print_log("LQLearner:setLearningRate", learner:getLearningRate())
end

--@api: LQLearner:setQValue
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local learner = lurek.learning.newQLearner(8, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setQValue(3, 2, 4.2)

    example_print_log("LQLearner:setQValue", learner:getQValue(3, 2))
end

--@api: LQLearner:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    local type_name = learner:type()

    example_print_log("LQLearner:type", type_name)
end

--@api: LQLearner:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    local is_learner = learner:typeOf("LQLearner")
    local is_object = learner:typeOf("LObject")

    example_print_log("LQLearner:typeOf LQLearner", tostring(is_learner))
    example_print_log("LQLearner states", learner:getStateCount())
end

--@api: LQLearner:getEpisodeCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:endEpisode()
    learner:endEpisode()
    example_print_log("LQLearner:getEpisodeCount", learner:getEpisodeCount())
end

--@api: lurek.learning.defineEnv
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: lurek.learning.frameStack
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fs = lurek.learning.frameStack(3)
    fs:push({1.0, 2.0})
    fs:push({3.0, 4.0})
    local flat = fs:get()
    example_print_log("lurek.learning.frameStack capacity", fs:capacity())
    example_print_log("lurek.learning.frameStack flat len", #flat)
end

--@api: lurek.learning.normalizeEnv
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: lurek.learning.timeLimit
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: LEnv:reset
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: LEnv:step
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

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

--@api: LEnv:obsSpace
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local env = lurek.learning.defineEnv({
        reset = function() return {0.0, 0.0} end,
        step  = function(a) return {{0.0, 0.0}, 0.0, false, {}} end,
        obs_space    = { shape = {4}, low = {-1.0}, high = {1.0} },
        action_space = { n = 2 },
    })
    local space = env:obsSpace()
    example_print_log("LEnv:obsSpace shape[1]", space.shape[1])
end

--@api: LEnv:actionSpace
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local env = lurek.learning.defineEnv({
        reset = function() return {0.0} end,
        step  = function(a) return {{0.0}, 0.0, false, {}} end,
        obs_space    = { shape = {1}, low = {0.0}, high = {1.0} },
        action_space = { n = 6 },
    })
    local space = env:actionSpace()
    example_print_log("LEnv:actionSpace n", space.n)
end

--@api: LEnv:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local env = lurek.learning.defineEnv({
        reset = function() return {0.0} end,
        step  = function(a) return {{0.0}, 0.0, false, {}} end,
        obs_space    = { shape = {1}, low = {0.0}, high = {1.0} },
        action_space = { n = 2 },
    })
    example_print_log("LEnv:type", env:type())
end

--@api: LEnv:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local env = lurek.learning.defineEnv({
        reset = function() return {0.0} end,
        step  = function(a) return {{0.0}, 0.0, false, {}} end,
        obs_space    = { shape = {1}, low = {0.0}, high = {1.0} },
        action_space = { n = 2 },
    })
    example_print_log("LEnv:typeOf LEnv", tostring(env:typeOf("LEnv")))
    example_print_log("LEnv reset size", #env:reset())
end

--@api: LFrameStack:push
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fs = lurek.learning.frameStack(4)
    fs:push({0.1, 0.2})
    fs:push({0.3, 0.4})
    local flat = fs:get()
    example_print_log("LFrameStack:push capacity", fs:capacity())
end

--@api: LFrameStack:get
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fs = lurek.learning.frameStack(2)
    fs:push({1.0, 2.0})
    fs:push({3.0, 4.0})
    local flat = fs:get()
    example_print_log("LFrameStack:get len", #flat)
    example_print_log("LFrameStack:get first", flat[1])
end

--@api: LFrameStack:reset
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fs = lurek.learning.frameStack(3)
    fs:push({1.0})
    fs:push({2.0})
    fs:reset()
    example_print_log("LFrameStack:reset capacity", fs:capacity())
end

--@api: LFrameStack:capacity
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fs = lurek.learning.frameStack(5)
    fs:push({0.1})
    local flat = fs:get()
    example_print_log("LFrameStack:capacity", fs:capacity())
    example_print_log("stack width = " .. #flat)
end

--@api: LFrameStack:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fs = lurek.learning.frameStack(3)
    fs:push({0.1})
    local flat = fs:get()
    example_print_log("LFrameStack:type", fs:type())
    example_print_log("stack width = " .. #flat)
end

--@api: LFrameStack:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local fs = lurek.learning.frameStack(3)
    fs:push({0.1})
    local flat = fs:get()
    example_print_log("LFrameStack:typeOf LFrameStack", tostring(fs:typeOf("LFrameStack")))
    example_print_log("LFrameStack flattened len", #flat)
end

--@api: lurek.learning.newTensor
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.learning.newTensor({2, 3}, {1.0, 2.0, 3.0, 4.0, 5.0, 6.0})
    local tensor_shape = t:shape()
    local tensor_len = t:len()
    example_print_log("lurek.learning.newTensor type", t:type())
    example_print_log("lurek.learning.newTensor len", t:len())
end

--@api: LTensor:shape
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.learning.newTensor({2, 3}, {1, 2, 3, 4, 5, 6})
    local tensor_shape = t:shape()
    local tensor_len = t:len()
    local s = t:shape()
    example_print_log("LTensor:shape rank", #s)
    example_print_log("LTensor:shape dim0", s[1])
end

--@api: LTensor:data
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.learning.newTensor({3}, {10.0, 20.0, 30.0})
    local tensor_shape = t:shape()
    local tensor_len = t:len()
    local d = t:data()
    example_print_log("LTensor:data len", #d)
    example_print_log("LTensor:data first", d[1])
end

--@api: LTensor:get
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.learning.newTensor({3}, {7.0, 8.0, 9.0})
    local tensor_shape = t:shape()
    local tensor_len = t:len()
    example_print_log("LTensor:get index1", t:get(1))
    example_print_log("LTensor:get index3", t:get(3))
end

--@api: LTensor:len
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.learning.newTensor({4}, {1.0, 2.0, 3.0, 4.0})
    local tensor_shape = t:shape()
    local tensor_len = t:len()
    example_print_log("LTensor:len", t:len())
    example_print_log("tensor rank = " .. #tensor_shape)
end

--@api: LTensor:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.learning.newTensor({1}, {0.0})
    local tensor_shape = t:shape()
    local tensor_len = t:len()
    example_print_log("LTensor:type", t:type())
    example_print_log("tensor len = " .. tensor_len)
end

--@api: LTensor:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local t = lurek.learning.newTensor({1}, {0.0})
    local tensor_shape = t:shape()
    local tensor_len = t:len()
    example_print_log("LTensor:typeOf LTensor", tostring(t:typeOf("LTensor")))
    example_print_log("LTensor data size", #t:data())
end

--@api: lurek.learning.wrap
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local qlearner = lurek.learning.newQLearner(4, 2)
    local model = lurek.learning.wrap(qlearner)
    local model_type = model:type()
    local is_model = model:typeOf("LModel")
    example_print_log("wrapped model type = " .. model:type())
end

--@api: LBandit:predict
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local b = lurek.learning.newBandit(3, "ucb1", 0.1, 12345)
    local action = b:predict()
    local arms = b:armCount()
    local pulls = b:totalPulls()
    example_print_log("bandit predict = " .. action)
end

--@api: LModel:predict
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local qlearner = lurek.learning.newQLearner(4, 2)
    local model = lurek.learning.wrap(qlearner)
    local model_type = model:type()
    local is_model = model:typeOf("LModel")
    local action = model:predict(0)
    example_print_log("model predict = " .. action)
end

--@api: LModel:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local qlearner = lurek.learning.newQLearner(4, 2)
    local model = lurek.learning.wrap(qlearner)
    local model_type = model:type()
    local is_model = model:typeOf("LModel")
    example_print_log("model type = " .. model:type())
end

--@api: LModel:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local qlearner = lurek.learning.newQLearner(4, 2)
    local model = lurek.learning.wrap(qlearner)
    local model_type = model:type()
    local is_model = model:typeOf("LModel")
    example_print_log("model typeOf LModel = " .. tostring(model:typeOf("LModel")))
end

--@api: LNeuralNet:predict
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local nn = lurek.learning.newNeuralNet()
    nn:addLayer(2, 2, "linear")
    local layers = nn:layerCount()
    local action = nn:predict({0.5, 0.3})
    example_print_log("nn predict = " .. tostring(action))
end

--@api: LQLearner:predict
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local q = lurek.learning.newQLearner(4, 2)
    q:setQValue(0, 0, 0.5)
    local states = q:getStateCount()
    local action = q:predict(0)
    example_print_log("qlearner predict = " .. action)
end
