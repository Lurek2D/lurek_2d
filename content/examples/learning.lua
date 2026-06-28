-- content/examples/learning.lua
-- Demonstrates the lurek.learning module: neural networks, genetic algorithms,
-- Q-learning, multi-armed bandits, and neuroevolution.


--@api: lurek.learning.newNeuralNet
do

    local net = lurek.learning.newNeuralNet()
    net:addLayer(3, 4, "linear")
    local net_layers = net:layerCount()
    net:addLayer(4, 4, "relu")
    net:addLayer(4, 2, "softmax")

    local output = net:forward({ 0.2, 0.6, -0.1 })
    lurek.log.info(tostring("lurek.learning.newNeuralNet layers") .. " " .. tostring(net:layerCount()))
    lurek.log.info(tostring("lurek.learning.newNeuralNet firstOutput") .. " " .. tostring(output[1]))
end

--@api: lurek.learning.newEngine
do

    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    local engine_blocks = engine:blockCount()
    lurek.log.info(tostring("lurek.learning.newEngine blocks") .. " " .. tostring(engine:blockCount()))
    lurek.log.info(tostring("engine params = " .. engine:paramCount()))
end

--@api: LNeuralEngine:addDense
do

    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    local engine_blocks = engine:blockCount()
    engine:addDense(3, 4, "relu")
    lurek.log.info(tostring("LNeuralEngine:addDense params") .. " " .. tostring(engine:paramCount()))
end

--@api: LNeuralEngine:addConv2D
do

    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    local engine_blocks = engine:blockCount()
    engine:addConv2D(1, 2, 3, 3, 1, 1, 1, 1)
    lurek.log.info(tostring("LNeuralEngine:addConv2D blocks") .. " " .. tostring(engine:blockCount()))
end

--@api: LNeuralEngine:addMaxPool2D
do

    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    local engine_blocks = engine:blockCount()
    engine:addMaxPool2D(2, 2)
    lurek.log.info(tostring("LNeuralEngine:addMaxPool2D params") .. " " .. tostring(engine:paramCount()))
end

--@api: LNeuralEngine:addTransformerEncoder
do

    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    local engine_blocks = engine:blockCount()
    engine:addTransformerEncoder(4, 2, 8)
    lurek.log.info(tostring("LNeuralEngine:addTransformerEncoder blocks") .. " " .. tostring(engine:blockCount()))
end

--@api: LNeuralEngine:blockCount
do

    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    engine:addMaxPool2D(2, 2)
    local weights = engine:getWeights()
    lurek.log.info(tostring("LNeuralEngine:blockCount") .. " " .. tostring(engine:blockCount()))
end

--@api: LNeuralEngine:paramCount
do

    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    engine:addConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    local weights = engine:getWeights()
    lurek.log.info(tostring("LNeuralEngine:paramCount") .. " " .. tostring(engine:paramCount()))
end

--@api: LNeuralEngine:setWeights
do

    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    local weights = {}
    for i = 1, engine:paramCount() do
        weights[i] = 0.05 * i
    end
    lurek.log.info(tostring("LNeuralEngine:setWeights") .. " " .. tostring(engine:setWeights(weights)))
end

--@api: LNeuralEngine:getWeights
do

    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    engine:setWeights({ 0.1, 0.2, 0.3, 0.4, 0.0, 0.0 })
    local params = engine:paramCount()
    lurek.log.info(tostring("LNeuralEngine:getWeights count") .. " " .. tostring(#engine:getWeights()))
end

--@api: LNeuralEngine:type
do

    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    local engine_blocks = engine:blockCount()
    lurek.log.info(tostring("LNeuralEngine:type") .. " " .. tostring(engine:type()))
    lurek.log.info(tostring("engine blocks after setup = " .. engine:blockCount()))
end

--@api: LNeuralEngine:typeOf
do

    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    local engine_blocks = engine:blockCount()
    lurek.log.info(tostring("LNeuralEngine:typeOf") .. " " .. tostring(engine:typeOf("LNeuralEngine")))
    lurek.log.info(tostring("type = " .. tostring(engine:type())))
end

--@api: lurek.learning.newGeneticAlgorithm
do

    local ga = lurek.learning.newGeneticAlgorithm(6, 4, 42)
    ga:setFitness(0, 0.1)
    local ga_generation = ga:generation()

    for index = 0, ga:popSize() - 1 do
        ga:setFitness(index, index * 0.25)
    end

    ga:evolve()
    lurek.log.info(tostring("lurek.learning.newGeneticAlgorithm generation") .. " " .. tostring(ga:generation()))
    lurek.log.info(tostring("lurek.learning.newGeneticAlgorithm popSize") .. " " .. tostring(ga:popSize()))
end

--@api: lurek.learning.newQLearner
do

    local learner = lurek.learning.newQLearner(4, 3)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setLearningRate(0.2)
    learner:setDiscountFactor(0.9)
    learner:learn(1, 2, 1.0, 3)

    lurek.log.info(tostring("lurek.learning.newQLearner states") .. " " .. tostring(learner:getStateCount()))
    lurek.log.info(tostring("lurek.learning.newQLearner q12") .. " " .. tostring(learner:getQValue(1, 2)))
end

--@api: lurek.learning.newBandit
do

    local bandit = lurek.learning.newBandit(4, "ucb1", 0.1, 99)
    local warmup_arm = bandit:select()
    bandit:update(warmup_arm, 0.1)
    local chosen_arm = bandit:select()
    bandit:update(chosen_arm, 0.75)

    lurek.log.info(tostring("lurek.learning.newBandit chosenArm") .. " " .. tostring(chosen_arm))
    lurek.log.info(tostring("lurek.learning.newBandit totalPulls") .. " " .. tostring(bandit:totalPulls()))
end

--@api: lurek.learning.newNeuroevolution
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
    lurek.log.info(tostring("lurek.learning.newNeuroevolution generation") .. " " .. tostring(evo:generation()))
    lurek.log.info(tostring("lurek.learning.newNeuroevolution bestFitness") .. " " .. tostring(evo:bestFitness()))
end

--@api: LBandit:armCount
do

    local bandit = lurek.learning.newBandit(4, "ucb1", 0.1, 1)
    local warmup_arm = bandit:select()
    bandit:update(warmup_arm, 0.1)
    local arm_count = bandit:armCount()

    lurek.log.info(tostring("LBandit:armCount") .. " " .. tostring(arm_count))
end

--@api: LBandit:bestArm
do

    local bandit = lurek.learning.newBandit(3, "ucb1", 0.1, 2)
    local warmup_arm = bandit:select()
    bandit:update(warmup_arm, 0.1)
    bandit:update(0, 0.25)
    bandit:update(1, 0.9)
    bandit:update(2, 0.4)

    lurek.log.info(tostring("LBandit:bestArm") .. " " .. tostring(bandit:bestArm()))
end

--@api: LBandit:reset
do

    local bandit = lurek.learning.newBandit(3, "thompson", 0.1, 3)
    local warmup_arm = bandit:select()
    bandit:update(warmup_arm, 0.1)
    local selected_arm = bandit:select()
    bandit:update(selected_arm, 0.5)
    bandit:reset()

    lurek.log.info(tostring("LBandit:reset pulls") .. " " .. tostring(bandit:totalPulls()))
    lurek.log.info(tostring("LBandit:reset bestArm") .. " " .. tostring(bandit:bestArm()))
end

--@api: LBandit:select
do

    local bandit = lurek.learning.newBandit(5, "thompson", 0.1, 4)
    local warmup_arm = bandit:select()
    bandit:update(warmup_arm, 0.1)
    local first_arm = bandit:select()
    local second_arm = bandit:select()

    lurek.log.info(tostring("LBandit:select first") .. " " .. tostring(first_arm))
    lurek.log.info(tostring("LBandit:select second") .. " " .. tostring(second_arm))
end

--@api: LBandit:totalPulls
do

    local bandit = lurek.learning.newBandit(3, "ucb1", 0.1, 5)
    local warmup_arm = bandit:select()
    bandit:update(warmup_arm, 0.1)
    bandit:select()
    bandit:select()
    local total_pulls = bandit:totalPulls()

    lurek.log.info(tostring("LBandit:totalPulls") .. " " .. tostring(total_pulls))
end

--@api: LBandit:type
do

    local bandit = lurek.learning.newBandit(3, "ucb1", 0.1, 6)
    local warmup_arm = bandit:select()
    bandit:update(warmup_arm, 0.1)
    local type_name = bandit:type()

    lurek.log.info(tostring("LBandit:type") .. " " .. tostring(type_name))
end

--@api: LBandit:typeOf
do

    local bandit = lurek.learning.newBandit(3, "ucb1", 0.1, 7)
    local warmup_arm = bandit:select()
    bandit:update(warmup_arm, 0.1)
    local is_bandit = bandit:typeOf("LBandit")
    local is_object = bandit:typeOf("LObject")

    lurek.log.info(tostring("LBandit:typeOf LBandit") .. " " .. tostring(tostring(is_bandit)))
    lurek.log.info(tostring("LBandit totalPulls") .. " " .. tostring(bandit:totalPulls()))
end

--@api: LBandit:update
do

    local bandit = lurek.learning.newBandit(4, "ucb1", 0.1, 8)
    local warmup_arm = bandit:select()
    bandit:update(warmup_arm, 0.1)
    local arm_index = bandit:select()
    bandit:update(arm_index, 0.8)

    lurek.log.info(tostring("LBandit:update arm") .. " " .. tostring(arm_index))
    lurek.log.info(tostring("LBandit:update bestArm") .. " " .. tostring(bandit:bestArm()))
end

--@api: LGeneticAlgorithm:bestGenes
do

    local ga = lurek.learning.newGeneticAlgorithm(5, 3, 10)
    ga:setFitness(0, 0.1)
    local ga_generation = ga:generation()

    for index = 0, ga:popSize() - 1 do
        ga:setFitness(index, index)
    end

    local genes = ga:bestGenes()
    lurek.log.info(tostring("LGeneticAlgorithm:bestGenes count") .. " " .. tostring(#genes))
    lurek.log.info(tostring("LGeneticAlgorithm:bestGenes first") .. " " .. tostring(genes[1]))
end

--@api: LGeneticAlgorithm:evolve
do

    local ga = lurek.learning.newGeneticAlgorithm(5, 4, 11)
    ga:setFitness(0, 0.1)
    local ga_generation = ga:generation()

    for index = 0, ga:popSize() - 1 do
        ga:setFitness(index, index * 0.5)
    end

    ga:evolve()
    lurek.log.info(tostring("LGeneticAlgorithm:evolve generation") .. " " .. tostring(ga:generation()))
end

--@api: LGeneticAlgorithm:generation
do

    local ga = lurek.learning.newGeneticAlgorithm(4, 3, 12)
    ga:setFitness(0, 0.1)
    local ga_generation = ga:generation()
    ga:evolve()
    ga:evolve()

    lurek.log.info(tostring("LGeneticAlgorithm:generation") .. " " .. tostring(ga:generation()))
end

--@api: LGeneticAlgorithm:getGenes
do

    local ga = lurek.learning.newGeneticAlgorithm(4, 5, 13)
    ga:setFitness(0, 0.1)
    local ga_generation = ga:generation()
    local genes = ga:getGenes(0)

    lurek.log.info(tostring("LGeneticAlgorithm:getGenes count") .. " " .. tostring(#genes))
    lurek.log.info(tostring("LGeneticAlgorithm:getGenes first") .. " " .. tostring(genes[1]))
end

--@api: LGeneticAlgorithm:popSize
do

    local ga = lurek.learning.newGeneticAlgorithm(15, 8, 14)
    ga:setFitness(0, 0.1)
    local ga_generation = ga:generation()
    local pop_size = ga:popSize()

    lurek.log.info(tostring("LGeneticAlgorithm:popSize") .. " " .. tostring(pop_size))
end

--@api: LGeneticAlgorithm:setFitness
do

    local ga = lurek.learning.newGeneticAlgorithm(6, 3, 15)
    ga:setFitness(0, 0.1)
    local ga_generation = ga:generation()
    ga:setFitness(0, 1.25)
    ga:setFitness(1, 0.5)
    ga:evolve()

    lurek.log.info(tostring("LGeneticAlgorithm:setFitness generation") .. " " .. tostring(ga:generation()))
    lurek.log.info(tostring("LGeneticAlgorithm:setFitness bestGenes") .. " " .. tostring(#ga:bestGenes()))
end

--@api: LGeneticAlgorithm:type
do

    local ga = lurek.learning.newGeneticAlgorithm(4, 2, 16)
    ga:setFitness(0, 0.1)
    local ga_generation = ga:generation()
    local type_name = ga:type()

    lurek.log.info(tostring("LGeneticAlgorithm:type") .. " " .. tostring(type_name))
end

--@api: LGeneticAlgorithm:typeOf
do

    local ga = lurek.learning.newGeneticAlgorithm(4, 2, 17)
    ga:setFitness(0, 0.1)
    local ga_generation = ga:generation()
    local is_ga = ga:typeOf("LGeneticAlgorithm")
    local is_object = ga:typeOf("LObject")

    lurek.log.info(tostring("LGeneticAlgorithm:typeOf LGeneticAlgorithm") .. " " .. tostring(tostring(is_ga)))
    lurek.log.info(tostring("LGeneticAlgorithm popSize") .. " " .. tostring(ga:popSize()))
end

--@api: LNeuralNet:addLayer
do

    local net = lurek.learning.newNeuralNet()
    net:addLayer(2, 4, "linear")
    local net_layers = net:layerCount()
    net:addLayer(4, 6, "relu")
    net:addLayer(6, 2, "sigmoid")

    lurek.log.info(tostring("LNeuralNet:addLayer layerCount") .. " " .. tostring(net:layerCount()))
    lurek.log.info(tostring("LNeuralNet:addLayer paramCount") .. " " .. tostring(net:paramCount()))
end

--@api: LNeuralNet:forward
do

    local net = lurek.learning.newNeuralNet()
    net:addLayer(3, 4, "linear")
    local net_layers = net:layerCount()
    net:addLayer(4, 4, "relu")
    net:addLayer(4, 1, "sigmoid")
    local output = net:forward({ 0.1, 0.5, 0.9 })

    lurek.log.info(tostring("LNeuralNet:forward out") .. " " .. tostring(output[1]))
end

--@api: LNeuralNet:getWeights
do

    local net = lurek.learning.newNeuralNet()
    net:addLayer(2, 2, "linear")
    local net_layers = net:layerCount()
    net:addLayer(2, 3, "relu")
    local weights = net:getWeights()

    lurek.log.info(tostring("LNeuralNet:getWeights count") .. " " .. tostring(#weights))
    lurek.log.info(tostring("LNeuralNet:getWeights first") .. " " .. tostring(weights[1]))
end

--@api: LNeuralNet:layerCount
do

    local net = lurek.learning.newNeuralNet()
    net:addLayer(2, 4, "linear")
    local net_layers = net:layerCount()
    net:addLayer(4, 8, "relu")
    net:addLayer(8, 4, "relu")
    net:addLayer(4, 1, "sigmoid")

    lurek.log.info(tostring("LNeuralNet:layerCount") .. " " .. tostring(net:layerCount()))
end

--@api: LNeuralNet:paramCount
do

    local net = lurek.learning.newNeuralNet()
    net:addLayer(2, 4, "linear")
    local net_layers = net:layerCount()
    net:addLayer(4, 4, "relu")
    net:addLayer(4, 1, "sigmoid")

    lurek.log.info(tostring("LNeuralNet:paramCount") .. " " .. tostring(net:paramCount()))
end

--@api: LNeuralNet:setWeights
do

    local net = lurek.learning.newNeuralNet()
    net:addLayer(2, 2, "linear")
    local weights = net:getWeights()
    local applied = net:setWeights(weights)

    lurek.log.info(tostring("LNeuralNet:setWeights applied") .. " " .. tostring(tostring(applied)))
    lurek.log.info(tostring("LNeuralNet:setWeights paramCount") .. " " .. tostring(net:paramCount()))
end

--@api: LNeuralNet:type
do

    local net = lurek.learning.newNeuralNet()
    net:addLayer(2, 2, "linear")
    local net_layers = net:layerCount()
    local type_name = net:type()

    lurek.log.info(tostring("LNeuralNet:type") .. " " .. tostring(type_name))
end

--@api: LNeuralNet:typeOf
do

    local net = lurek.learning.newNeuralNet()
    net:addLayer(2, 2, "linear")
    local net_layers = net:layerCount()
    local is_net = net:typeOf("LNeuralNet")
    local is_object = net:typeOf("LObject")

    lurek.log.info(tostring("LNeuralNet:typeOf LNeuralNet") .. " " .. tostring(tostring(is_net)))
    lurek.log.info(tostring("LNeuralNet paramCount") .. " " .. tostring(net:paramCount()))
end

--@api: LNeuroevolution:bestFitness
do

    local layer_spec = {
        { inputs = 2, outputs = 4, activation = "relu" },
        { inputs = 4, outputs = 1, activation = "sigmoid" }
    }
    local evo = lurek.learning.newNeuroevolution(layer_spec, 4, 18)

    for index = 0, evo:popSize() - 1 do
        evo:setFitness(index, 1.0 + index * 0.2)
    end

    lurek.log.info(tostring("LNeuroevolution:bestFitness") .. " " .. tostring(evo:bestFitness()))
end

--@api: LNeuroevolution:bestNetwork
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
    lurek.log.info(tostring("LNeuroevolution:bestNetwork type") .. " " .. tostring(best_net:type()))
    lurek.log.info(tostring("LNeuroevolution:bestNetwork layers") .. " " .. tostring(best_net:layerCount()))
end

--@api: LNeuroevolution:chromosomeToNet
do

    local layer_spec = {
        { inputs = 2, outputs = 3, activation = "relu" },
        { inputs = 3, outputs = 1, activation = "sigmoid" }
    }
    local evo = lurek.learning.newNeuroevolution(layer_spec, 4, 20)
    local net = evo:chromosomeToNet(0)
    local output = net:forward({ 0.3, 0.7 })

    lurek.log.info(tostring("LNeuroevolution:chromosomeToNet type") .. " " .. tostring(net:type()))
    lurek.log.info(tostring("LNeuroevolution:chromosomeToNet out") .. " " .. tostring(output[1]))
end

--@api: LNeuroevolution:evolve
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
    lurek.log.info(tostring("LNeuroevolution:evolve generation") .. " " .. tostring(evo:generation()))
end

--@api: LNeuroevolution:generation
do

    local layer_spec = {
        { inputs = 2, outputs = 2, activation = "relu" },
        { inputs = 2, outputs = 1, activation = "sigmoid" }
    }
    local evo = lurek.learning.newNeuroevolution(layer_spec, 4, 22)
    evo:evolve()

    lurek.log.info(tostring("LNeuroevolution:generation") .. " " .. tostring(evo:generation()))
end

--@api: LNeuroevolution:popSize
do

    local layer_spec = {
        { inputs = 2, outputs = 3, activation = "relu" },
        { inputs = 3, outputs = 1, activation = "linear" }
    }
    local evo = lurek.learning.newNeuroevolution(layer_spec, 12, 23)
    local pop_size = evo:popSize()

    lurek.log.info(tostring("LNeuroevolution:popSize") .. " " .. tostring(pop_size))
end

--@api: LNeuroevolution:setFitness
do

    local layer_spec = {
        { inputs = 2, outputs = 4, activation = "relu" },
        { inputs = 4, outputs = 1, activation = "sigmoid" }
    }
    local evo = lurek.learning.newNeuroevolution(layer_spec, 4, 24)
    evo:setFitness(0, 0.8)
    evo:setFitness(1, 1.1)
    evo:evolve()

    lurek.log.info(tostring("LNeuroevolution:setFitness generation") .. " " .. tostring(evo:generation()))
    lurek.log.info(tostring("LNeuroevolution:setFitness bestFitness") .. " " .. tostring(evo:bestFitness()))
end

--@api: LNeuroevolution:type
do

    local layer_spec = {
        { inputs = 2, outputs = 3, activation = "relu" },
        { inputs = 3, outputs = 1, activation = "sigmoid" }
    }
    local evo = lurek.learning.newNeuroevolution(layer_spec, 4, 25)
    local type_name = evo:type()

    lurek.log.info(tostring("LNeuroevolution:type") .. " " .. tostring(type_name))
end

--@api: LNeuroevolution:typeOf
do

    local layer_spec = {
        { inputs = 2, outputs = 3, activation = "relu" },
        { inputs = 3, outputs = 1, activation = "sigmoid" }
    }
    local evo = lurek.learning.newNeuroevolution(layer_spec, 4, 26)
    local is_evo = evo:typeOf("LNeuroevolution")
    local is_object = evo:typeOf("LObject")

    lurek.log.info(tostring("LNeuroevolution:typeOf LNeuroevolution") .. " " .. tostring(tostring(is_evo)))
    lurek.log.info(tostring("LNeuroevolution popSize") .. " " .. tostring(evo:popSize()))
end

--@api: lurek.learning.newLstm
do

    local lstm = lurek.learning.newLstm(2, 3)
    local lstm_weights = lstm:getWeights()
    local lstm_params = lstm:paramCount()
    lurek.log.info(tostring("lurek.learning.newLstm type") .. " " .. tostring(lstm:type()))
    lurek.log.info(tostring("weight count = " .. #lstm_weights))
end

--@api: LLSTM:forward
do

    local lstm = lurek.learning.newLstm(2, 3)
    local lstm_weights = lstm:getWeights()
    local lstm_params = lstm:paramCount()
    local out = lstm:forward({ 0.1, -0.2 })
    lurek.log.info(tostring("LLSTM:forward outLen") .. " " .. tostring(#out))
end

--@api: lurek.learning.newGru
do

    local gru = lurek.learning.newGru(2, 3)
    local gru_weights = gru:getWeights()
    local gru_params = gru:paramCount()
    lurek.log.info(tostring("lurek.learning.newGru type") .. " " .. tostring(gru:type()))
    lurek.log.info(tostring("weight count = " .. #gru_weights))
end

--@api: LGRU:forward
do

    local gru = lurek.learning.newGru(2, 3)
    local gru_weights = gru:getWeights()
    local gru_params = gru:paramCount()
    local out = gru:forward({ 0.1, -0.2 })
    lurek.log.info(tostring("LGRU:forward outLen") .. " " .. tostring(#out))
end

--@api: lurek.learning.newConv2D
do

    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    local conv_weights = conv:getWeights()
    local conv_params = conv:paramCount()
    lurek.log.info(tostring("lurek.learning.newConv2D type") .. " " .. tostring(conv:type()))
    lurek.log.info(tostring("weight count = " .. #conv_weights))
end

--@api: LConv2D:forward
do

    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    local conv_weights = conv:getWeights()
    local conv_params = conv:paramCount()
    local input = lurek.learning.newTensor({1, 2, 2}, {1, 2, 3, 4})
    local out = conv:forward(input)
    lurek.log.info(tostring("LConv2D:forward outW") .. " " .. tostring(out:shape()[3]))
end

--@api: lurek.learning.newMaxPool2D
do

    local pool = lurek.learning.newMaxPool2D(2, 2, 2, 2)
    local pool_type = pool:type()
    local pool_is = pool:typeOf("LMaxPool2D")
    lurek.log.info(tostring("lurek.learning.newMaxPool2D type") .. " " .. tostring(pool:type()))
    lurek.log.info(tostring("pool configured = " .. tostring(pool_is)))
end

--@api: LMaxPool2D:forward
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
    lurek.log.info(tostring("LMaxPool2D:forward outH") .. " " .. tostring(out:shape()[2]))
end

--@api: lurek.learning.newPositionalEncoding
do

    local pe = lurek.learning.newPositionalEncoding(4, 8)
    local pe_type = pe:type()
    local pe_is = pe:typeOf("LPositionalEncoding")
    lurek.log.info(tostring("lurek.learning.newPositionalEncoding type") .. " " .. tostring(pe:type()))
    lurek.log.info(tostring("encoding configured = " .. tostring(pe_is)))
end

--@api: LPositionalEncoding:apply
do

    local pe = lurek.learning.newPositionalEncoding(4, 8)
    local pe_type = pe:type()
    local pe_is = pe:typeOf("LPositionalEncoding")
    local x = lurek.learning.newTensor({2, 4}, {0, 0, 0, 0, 0, 0, 0, 0})
    local out = pe:apply(x)
    lurek.log.info(tostring("LPositionalEncoding:apply d1") .. " " .. tostring(out:data()[1]))
end

--@api: lurek.learning.newMultiHeadAttention
do

    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    local mha_weights = mha:getWeights()
    local mha_params = mha:paramCount()
    lurek.log.info(tostring("lurek.learning.newMultiHeadAttention type") .. " " .. tostring(mha:type()))
    lurek.log.info(tostring("attention configured = " .. tostring(mha_is)))
end

--@api: LMultiHeadAttention:forward
do

    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    local mha_weights = mha:getWeights()
    local mha_params = mha:paramCount()
    local x = lurek.learning.newTensor({2, 4}, {1, 0, 0, 1, 0, 1, 1, 0})
    local out = mha:forward(x)
    lurek.log.info(tostring("LMultiHeadAttention:forward outShape") .. " " .. tostring(out:shape()[2]))
end

--@api: lurek.learning.newTransformerEncoder
do

    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    local enc_weights = enc:getWeights()
    local enc_params = enc:paramCount()
    lurek.log.info(tostring("lurek.learning.newTransformerEncoder type") .. " " .. tostring(enc:type()))
    lurek.log.info(tostring("encoder configured = " .. tostring(enc_is)))
end

--@api: LTransformerEncoder:forward
do

    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    local enc_weights = enc:getWeights()
    local enc_params = enc:paramCount()
    local x = lurek.learning.newTensor({2, 4}, {1, 2, 3, 4, 4, 3, 2, 1})
    local out = enc:forward(x)
    lurek.log.info(tostring("LTransformerEncoder:forward outRows") .. " " .. tostring(out:shape()[1]))
end

--@api: lurek.learning.newTransformerDecoder
do

    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    local dec_weights = dec:getWeights()
    local dec_params = dec:paramCount()
    lurek.log.info(tostring("lurek.learning.newTransformerDecoder type") .. " " .. tostring(dec:type()))
    lurek.log.info(tostring("decoder configured = " .. tostring(dec_is)))
end

--@api: LTransformerDecoder:forward
do

    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    local dec_weights = dec:getWeights()
    local dec_params = dec:paramCount()
    local x = lurek.learning.newTensor({2, 4}, {1, 2, 3, 4, 4, 3, 2, 1})
    local e = lurek.learning.newTensor({2, 4}, {0, 1, 0, 1, 1, 0, 1, 0})
    local out = dec:forward(x, e)
    lurek.log.info(tostring("LTransformerDecoder:forward outRows") .. " " .. tostring(out:shape()[1]))
end

--@api: LLSTM:reset
do

    local lstm = lurek.learning.newLstm(2, 2)
    local lstm_weights = lstm:getWeights()
    local lstm_params = lstm:paramCount()
    lstm:reset()
    lurek.log.info(tostring("LLSTM:reset ok"))
end

--@api: LLSTM:setWeights
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
    lurek.log.info(tostring("LLSTM:setWeights count") .. " " .. tostring(count))
end

--@api: LLSTM:getWeights
do

    local lstm = lurek.learning.newLstm(2, 2)
    local lstm_weights = lstm:getWeights()
    local lstm_params = lstm:paramCount()
    local got = lstm:getWeights()
    lurek.log.info(tostring("LLSTM:getWeights") .. " " .. tostring(#got))
end

--@api: LLSTM:paramCount
do

    local lstm = lurek.learning.newLstm(2, 2)
    local lstm_weights = lstm:getWeights()
    local lstm_params = lstm:paramCount()
    lurek.log.info(tostring("LLSTM:paramCount") .. " " .. tostring(lstm:paramCount()))
    lurek.log.info(tostring("weight count = " .. #lstm_weights))
end

--@api: LLSTM:type
do

    local lstm = lurek.learning.newLstm(2, 2)
    local lstm_weights = lstm:getWeights()
    local lstm_params = lstm:paramCount()
    lurek.log.info(tostring("LLSTM:type") .. " " .. tostring(lstm:type()))
    lurek.log.info(tostring("weight count = " .. #lstm_weights))
end

--@api: LLSTM:typeOf
do

    local lstm = lurek.learning.newLstm(2, 2)
    local lstm_weights = lstm:getWeights()
    local lstm_params = lstm:paramCount()
    lurek.log.info(tostring("LLSTM:typeOf") .. " " .. tostring(tostring(lstm:typeOf("LObject"))))
    lurek.log.info(tostring("type = " .. tostring(lstm:type())))
end

--@api: LGRU:reset
do

    local gru = lurek.learning.newGru(2, 2)
    local gru_weights = gru:getWeights()
    local gru_params = gru:paramCount()
    gru:reset()
    lurek.log.info(tostring("LGRU:reset ok"))
end

--@api: LGRU:setWeights
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
    lurek.log.info(tostring("LGRU:setWeights count") .. " " .. tostring(count))
end

--@api: LGRU:getWeights
do

    local gru = lurek.learning.newGru(2, 2)
    local gru_weights = gru:getWeights()
    local gru_params = gru:paramCount()
    local got = gru:getWeights()
    lurek.log.info(tostring("LGRU:getWeights") .. " " .. tostring(#got))
end

--@api: LGRU:paramCount
do

    local gru = lurek.learning.newGru(2, 2)
    local gru_weights = gru:getWeights()
    local gru_params = gru:paramCount()
    lurek.log.info(tostring("LGRU:paramCount") .. " " .. tostring(gru:paramCount()))
    lurek.log.info(tostring("weight count = " .. #gru_weights))
end

--@api: LGRU:type
do

    local gru = lurek.learning.newGru(2, 2)
    local gru_weights = gru:getWeights()
    local gru_params = gru:paramCount()
    lurek.log.info(tostring("LGRU:type") .. " " .. tostring(gru:type()))
    lurek.log.info(tostring("weight count = " .. #gru_weights))
end

--@api: LGRU:typeOf
do

    local gru = lurek.learning.newGru(2, 2)
    local gru_weights = gru:getWeights()
    local gru_params = gru:paramCount()
    lurek.log.info(tostring("LGRU:typeOf") .. " " .. tostring(tostring(gru:typeOf("LObject"))))
    lurek.log.info(tostring("type = " .. tostring(gru:type())))
end

--@api: LConv2D:setWeights
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
    lurek.log.info(tostring("LConv2D:setWeights count") .. " " .. tostring(count))
end

--@api: LConv2D:getWeights
do

    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    local conv_weights = conv:getWeights()
    local conv_params = conv:paramCount()
    local got = conv:getWeights()
    lurek.log.info(tostring("LConv2D:getWeights") .. " " .. tostring(#got))
end

--@api: LConv2D:paramCount
do

    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    local conv_weights = conv:getWeights()
    local conv_params = conv:paramCount()
    lurek.log.info(tostring("LConv2D:paramCount") .. " " .. tostring(conv:paramCount()))
    lurek.log.info(tostring("weight count = " .. #conv_weights))
end

--@api: LConv2D:type
do

    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    local conv_weights = conv:getWeights()
    local conv_params = conv:paramCount()
    lurek.log.info(tostring("LConv2D:type") .. " " .. tostring(conv:type()))
    lurek.log.info(tostring("weight count = " .. #conv_weights))
end

--@api: LConv2D:typeOf
do

    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    local conv_weights = conv:getWeights()
    local conv_params = conv:paramCount()
    lurek.log.info(tostring("LConv2D:typeOf") .. " " .. tostring(tostring(conv:typeOf("LObject"))))
    lurek.log.info(tostring("type = " .. tostring(conv:type())))
end

--@api: LMaxPool2D:type
do

    local pool = lurek.learning.newMaxPool2D(2, 2, 2, 2)
    local pool_type = pool:type()
    local pool_is = pool:typeOf("LMaxPool2D")
    lurek.log.info(tostring("LMaxPool2D:type") .. " " .. tostring(pool:type()))
    lurek.log.info(tostring("pool configured = " .. tostring(pool_is)))
end

--@api: LMaxPool2D:typeOf
do

    local pool = lurek.learning.newMaxPool2D(2, 2, 2, 2)
    local pool_type = pool:type()
    local pool_is = pool:typeOf("LMaxPool2D")
    lurek.log.info(tostring("LMaxPool2D:typeOf") .. " " .. tostring(tostring(pool:typeOf("LObject"))))
    lurek.log.info(tostring("type = " .. tostring(pool:type())))
end

--@api: LPositionalEncoding:type
do

    local pe = lurek.learning.newPositionalEncoding(4, 8)
    local pe_type = pe:type()
    local pe_is = pe:typeOf("LPositionalEncoding")
    lurek.log.info(tostring("LPositionalEncoding:type") .. " " .. tostring(pe:type()))
    lurek.log.info(tostring("encoding configured = " .. tostring(pe_is)))
end

--@api: LPositionalEncoding:typeOf
do

    local pe = lurek.learning.newPositionalEncoding(4, 8)
    local pe_type = pe:type()
    local pe_is = pe:typeOf("LPositionalEncoding")
    lurek.log.info(tostring("LPositionalEncoding:typeOf") .. " " .. tostring(tostring(pe:typeOf("LObject"))))
    lurek.log.info(tostring("type = " .. tostring(pe:type())))
end

--@api: LMultiHeadAttention:setWeights
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
    lurek.log.info(tostring("LMultiHeadAttention:setWeights count") .. " " .. tostring(count))
end

--@api: LMultiHeadAttention:getWeights
do

    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    local mha_weights = mha:getWeights()
    local mha_params = mha:paramCount()
    local got = mha:getWeights()
    lurek.log.info(tostring("LMultiHeadAttention:getWeights") .. " " .. tostring(#got))
end

--@api: LMultiHeadAttention:paramCount
do

    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    local mha_weights = mha:getWeights()
    local mha_params = mha:paramCount()
    lurek.log.info(tostring("LMultiHeadAttention:paramCount") .. " " .. tostring(mha:paramCount()))
    lurek.log.info(tostring("weight count = " .. #mha:getWeights()))
end

--@api: LMultiHeadAttention:type
do

    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    local mha_weights = mha:getWeights()
    local mha_params = mha:paramCount()
    lurek.log.info(tostring("LMultiHeadAttention:type") .. " " .. tostring(mha:type()))
    lurek.log.info(tostring("attention configured = " .. tostring(mha_is)))
end

--@api: LMultiHeadAttention:typeOf
do

    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    local mha_weights = mha:getWeights()
    local mha_params = mha:paramCount()
    lurek.log.info(tostring("LMultiHeadAttention:typeOf") .. " " .. tostring(tostring(mha:typeOf("LObject"))))
    lurek.log.info(tostring("type = " .. tostring(mha:type())))
end

--@api: LTransformerEncoder:setWeights
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
    lurek.log.info(tostring("LTransformerEncoder:setWeights count") .. " " .. tostring(count))
end

--@api: LTransformerEncoder:getWeights
do

    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    local enc_weights = enc:getWeights()
    local enc_params = enc:paramCount()
    local got = enc:getWeights()
    lurek.log.info(tostring("LTransformerEncoder:getWeights") .. " " .. tostring(#got))
end

--@api: LTransformerEncoder:paramCount
do

    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    local enc_weights = enc:getWeights()
    local enc_params = enc:paramCount()
    lurek.log.info(tostring("LTransformerEncoder:paramCount") .. " " .. tostring(enc:paramCount()))
    lurek.log.info(tostring("weight count = " .. #enc:getWeights()))
end

--@api: LTransformerEncoder:type
do

    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    local enc_weights = enc:getWeights()
    local enc_params = enc:paramCount()
    lurek.log.info(tostring("LTransformerEncoder:type") .. " " .. tostring(enc:type()))
    lurek.log.info(tostring("encoder configured = " .. tostring(enc_is)))
end

--@api: LTransformerEncoder:typeOf
do

    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    local enc_weights = enc:getWeights()
    local enc_params = enc:paramCount()
    lurek.log.info(tostring("LTransformerEncoder:typeOf") .. " " .. tostring(tostring(enc:typeOf("LObject"))))
    lurek.log.info(tostring("type = " .. tostring(enc:type())))
end

--@api: LTransformerDecoder:setWeights
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
    lurek.log.info(tostring("LTransformerDecoder:setWeights count") .. " " .. tostring(count))
end

--@api: LTransformerDecoder:getWeights
do

    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    local dec_weights = dec:getWeights()
    local dec_params = dec:paramCount()
    local got = dec:getWeights()
    lurek.log.info(tostring("LTransformerDecoder:getWeights") .. " " .. tostring(#got))
end

--@api: LTransformerDecoder:paramCount
do

    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    local dec_weights = dec:getWeights()
    local dec_params = dec:paramCount()
    lurek.log.info(tostring("LTransformerDecoder:paramCount") .. " " .. tostring(dec:paramCount()))
    lurek.log.info(tostring("weight count = " .. #dec:getWeights()))
end

--@api: LTransformerDecoder:type
do

    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    local dec_weights = dec:getWeights()
    local dec_params = dec:paramCount()
    lurek.log.info(tostring("LTransformerDecoder:type") .. " " .. tostring(dec:type()))
    lurek.log.info(tostring("decoder configured = " .. tostring(dec_is)))
end

--@api: LTransformerDecoder:typeOf
do

    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    local dec_weights = dec:getWeights()
    local dec_params = dec:paramCount()
    lurek.log.info(tostring("LTransformerDecoder:typeOf") .. " " .. tostring(tostring(dec:typeOf("LObject"))))
    lurek.log.info(tostring("type = " .. tostring(dec:type())))
end

--@api: LQLearner:bestAction
do

    local learner = lurek.learning.newQLearner(5, 3)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setQValue(1, 1, 0.5)
    learner:setQValue(1, 2, 1.2)
    learner:setQValue(1, 3, 0.8)

    lurek.log.info(tostring("LQLearner:bestAction") .. " " .. tostring(learner:bestAction(1)))
end

--@api: LQLearner:chooseAction
do

    local learner = lurek.learning.newQLearner(5, 3)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setExplorationRate(0.0)
    learner:setQValue(1, 2, 2.0)
    local chosen_action = learner:chooseAction(1)

    lurek.log.info(tostring("LQLearner:chooseAction") .. " " .. tostring(chosen_action))
end

--@api: LQLearner:deserialize
do

    local source = lurek.learning.newQLearner(5, 3)
    source:setQValue(2, 3, 3.14)
    local saved = source:serialize()

    local restored = lurek.learning.newQLearner(5, 3)
    restored:deserialize(saved)
    lurek.log.info(tostring("LQLearner:deserialize q23") .. " " .. tostring(restored:getQValue(2, 3)))
end

--@api: LQLearner:endEpisode
do

    local learner = lurek.learning.newQLearner(8, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setExplorationRate(0.8)
    learner:setExplorationDecay(0.5)
    learner:endEpisode()

    lurek.log.info(tostring("LQLearner:endEpisode explorationRate") .. " " .. tostring(learner:getExplorationRate()))
end

--@api: LQLearner:getActionCount
do

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    local action_count = learner:getActionCount()

    lurek.log.info(tostring("LQLearner:getActionCount") .. " " .. tostring(action_count))
end

--@api: LQLearner:getDiscountFactor
do

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setDiscountFactor(0.95)

    lurek.log.info(tostring("LQLearner:getDiscountFactor") .. " " .. tostring(learner:getDiscountFactor()))
end

--@api: LQLearner:getExplorationDecay
do

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setExplorationDecay(0.97)

    lurek.log.info(tostring("LQLearner:getExplorationDecay") .. " " .. tostring(learner:getExplorationDecay()))
end

--@api: LQLearner:getExplorationRate
do

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setExplorationRate(0.35)

    lurek.log.info(tostring("LQLearner:getExplorationRate") .. " " .. tostring(learner:getExplorationRate()))
end

--@api: LQLearner:getLearningRate
do

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setLearningRate(0.05)

    lurek.log.info(tostring("LQLearner:getLearningRate") .. " " .. tostring(learner:getLearningRate()))
end

--@api: LQLearner:getQValue
do

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setQValue(2, 3, 7.5)
    local value = learner:getQValue(2, 3)

    lurek.log.info(tostring("LQLearner:getQValue") .. " " .. tostring(value))
end

--@api: LQLearner:getStateCount
do

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    local state_count = learner:getStateCount()

    lurek.log.info(tostring("LQLearner:getStateCount") .. " " .. tostring(state_count))
end

--@api: LQLearner:learn
do

    local learner = lurek.learning.newQLearner(6, 3)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setLearningRate(0.5)
    learner:setDiscountFactor(0.0)
    learner:learn(1, 2, 1.0, 3)

    lurek.log.info(tostring("LQLearner:learn q12") .. " " .. tostring(learner:getQValue(1, 2)))
end

--@api: LQLearner:serialize
do

    local learner = lurek.learning.newQLearner(5, 3)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setQValue(1, 1, 1.5)
    local json = learner:serialize()

    lurek.log.info(tostring("LQLearner:serialize length") .. " " .. tostring(#json))
end

--@api: LQLearner:setDiscountFactor
do

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setDiscountFactor(0.95)

    lurek.log.info(tostring("LQLearner:setDiscountFactor") .. " " .. tostring(learner:getDiscountFactor()))
end

--@api: LQLearner:setExplorationDecay
do

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setExplorationDecay(0.99)

    lurek.log.info(tostring("LQLearner:setExplorationDecay") .. " " .. tostring(learner:getExplorationDecay()))
end

--@api: LQLearner:setExplorationRate
do

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setExplorationRate(0.5)

    lurek.log.info(tostring("LQLearner:setExplorationRate") .. " " .. tostring(learner:getExplorationRate()))
end

--@api: LQLearner:setLearningRate
do

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setLearningRate(0.05)

    lurek.log.info(tostring("LQLearner:setLearningRate") .. " " .. tostring(learner:getLearningRate()))
end

--@api: LQLearner:setQValue
do

    local learner = lurek.learning.newQLearner(8, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:setQValue(3, 2, 4.2)

    lurek.log.info(tostring("LQLearner:setQValue") .. " " .. tostring(learner:getQValue(3, 2)))
end

--@api: LQLearner:type
do

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    local type_name = learner:type()

    lurek.log.info(tostring("LQLearner:type") .. " " .. tostring(type_name))
end

--@api: LQLearner:typeOf
do

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    local is_learner = learner:typeOf("LQLearner")
    local is_object = learner:typeOf("LObject")

    lurek.log.info(tostring("LQLearner:typeOf LQLearner") .. " " .. tostring(tostring(is_learner)))
    lurek.log.info(tostring("LQLearner states") .. " " .. tostring(learner:getStateCount()))
end

--@api: LQLearner:getEpisodeCount
do

    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(0, 0, 0.25)
    local learner_states = learner:getStateCount()
    learner:endEpisode()
    learner:endEpisode()
    lurek.log.info(tostring("LQLearner:getEpisodeCount") .. " " .. tostring(learner:getEpisodeCount()))
end

--@api: lurek.learning.defineEnv
do

    local env = lurek.learning.defineEnv({
        reset = function() return {0.0, 0.0} end,
        step  = function(a) return {{0.1, 0.2}, 1.0, false, {}} end,
        obs_space    = { shape = {2}, low = {-1.0}, high = {1.0} },
        action_space = { n = 4 },
    })
    local obs = env:reset()
    lurek.log.info(tostring("lurek.learning.defineEnv type") .. " " .. tostring(env:type()))
    lurek.log.info(tostring("lurek.learning.defineEnv obs[1]") .. " " .. tostring(obs[1]))
end

--@api: lurek.learning.frameStack
do

    local fs = lurek.learning.frameStack(3)
    fs:push({1.0, 2.0})
    fs:push({3.0, 4.0})
    local flat = fs:get()
    lurek.log.info(tostring("lurek.learning.frameStack capacity") .. " " .. tostring(fs:capacity()))
    lurek.log.info(tostring("lurek.learning.frameStack flat len") .. " " .. tostring(#flat))
end

--@api: lurek.learning.normalizeEnv
do

    local base = lurek.learning.defineEnv({
        reset = function() return {2.0, 4.0} end,
        step  = function(a) return {{2.0, 4.0}, 1.0, false, {}} end,
        obs_space    = { shape = {2}, low = {0.0}, high = {10.0} },
        action_space = { n = 2 },
    })
    local wrapped = lurek.learning.normalizeEnv(base, {1.0, 2.0}, {1.0, 2.0})
    local obs = wrapped:reset()
    lurek.log.info(tostring("lurek.learning.normalizeEnv obs[1]") .. " " .. tostring(obs[1]))
    lurek.log.info(tostring("lurek.learning.normalizeEnv obs[2]") .. " " .. tostring(obs[2]))
end

--@api: lurek.learning.timeLimit
do

    local base = lurek.learning.defineEnv({
        reset = function() return {0.0} end,
        step  = function(a) return {{0.0}, 0.0, false, {}} end,
        obs_space    = { shape = {1}, low = {0.0}, high = {1.0} },
        action_space = { n = 2 },
    })
    local limited = lurek.learning.timeLimit(base, 5)
    limited:reset()
    lurek.log.info(tostring("lurek.learning.timeLimit type") .. " " .. tostring(limited:type()))
end

--@api: LEnv:reset
do

    local env = lurek.learning.defineEnv({
        reset = function() return {1.0, 2.0} end,
        step  = function(a) return {{0.0, 0.0}, 0.0, false, {}} end,
        obs_space    = { shape = {2}, low = {-1.0}, high = {1.0} },
        action_space = { n = 2 },
    })
    local obs = env:reset()
    lurek.log.info(tostring("LEnv:reset obs len") .. " " .. tostring(#obs))
    lurek.log.info(tostring("LEnv:reset obs[1]") .. " " .. tostring(obs[1]))
end

--@api: LEnv:step
do

    local env = lurek.learning.defineEnv({
        reset = function() return {0.0} end,
        step  = function(a) return {{0.5}, 1.5, false, {}} end,
        obs_space    = { shape = {1}, low = {0.0}, high = {1.0} },
        action_space = { n = 3 },
    })
    local obs, reward, done, info = env:step(1)
    lurek.log.info(tostring("LEnv:step obs[1]") .. " " .. tostring(obs[1]))
    lurek.log.info(tostring("LEnv:step reward") .. " " .. tostring(reward))
    lurek.log.info(tostring("LEnv:step done") .. " " .. tostring(tostring(done)))
end

--@api: LEnv:obsSpace
do

    local env = lurek.learning.defineEnv({
        reset = function() return {0.0, 0.0} end,
        step  = function(a) return {{0.0, 0.0}, 0.0, false, {}} end,
        obs_space    = { shape = {4}, low = {-1.0}, high = {1.0} },
        action_space = { n = 2 },
    })
    local space = env:obsSpace()
    lurek.log.info(tostring("LEnv:obsSpace shape[1]") .. " " .. tostring(space.shape[1]))
end

--@api: LEnv:actionSpace
do

    local env = lurek.learning.defineEnv({
        reset = function() return {0.0} end,
        step  = function(a) return {{0.0}, 0.0, false, {}} end,
        obs_space    = { shape = {1}, low = {0.0}, high = {1.0} },
        action_space = { n = 6 },
    })
    local space = env:actionSpace()
    lurek.log.info(tostring("LEnv:actionSpace n") .. " " .. tostring(space.n))
end

--@api: LEnv:type
do

    local env = lurek.learning.defineEnv({
        reset = function() return {0.0} end,
        step  = function(a) return {{0.0}, 0.0, false, {}} end,
        obs_space    = { shape = {1}, low = {0.0}, high = {1.0} },
        action_space = { n = 2 },
    })
    lurek.log.info(tostring("LEnv:type") .. " " .. tostring(env:type()))
end

--@api: LEnv:typeOf
do

    local env = lurek.learning.defineEnv({
        reset = function() return {0.0} end,
        step  = function(a) return {{0.0}, 0.0, false, {}} end,
        obs_space    = { shape = {1}, low = {0.0}, high = {1.0} },
        action_space = { n = 2 },
    })
    lurek.log.info(tostring("LEnv:typeOf LEnv") .. " " .. tostring(tostring(env:typeOf("LEnv"))))
    lurek.log.info(tostring("LEnv reset size") .. " " .. tostring(#env:reset()))
end

--@api: LFrameStack:push
do

    local fs = lurek.learning.frameStack(4)
    fs:push({0.1, 0.2})
    fs:push({0.3, 0.4})
    local flat = fs:get()
    lurek.log.info(tostring("LFrameStack:push capacity") .. " " .. tostring(fs:capacity()))
end

--@api: LFrameStack:get
do

    local fs = lurek.learning.frameStack(2)
    fs:push({1.0, 2.0})
    fs:push({3.0, 4.0})
    local flat = fs:get()
    lurek.log.info(tostring("LFrameStack:get len") .. " " .. tostring(#flat))
    lurek.log.info(tostring("LFrameStack:get first") .. " " .. tostring(flat[1]))
end

--@api: LFrameStack:reset
do

    local fs = lurek.learning.frameStack(3)
    fs:push({1.0})
    fs:push({2.0})
    fs:reset()
    lurek.log.info(tostring("LFrameStack:reset capacity") .. " " .. tostring(fs:capacity()))
end

--@api: LFrameStack:capacity
do

    local fs = lurek.learning.frameStack(5)
    fs:push({0.1})
    local flat = fs:get()
    lurek.log.info(tostring("LFrameStack:capacity") .. " " .. tostring(fs:capacity()))
    lurek.log.info(tostring("stack width = " .. #flat))
end

--@api: LFrameStack:type
do

    local fs = lurek.learning.frameStack(3)
    fs:push({0.1})
    local flat = fs:get()
    lurek.log.info(tostring("LFrameStack:type") .. " " .. tostring(fs:type()))
    lurek.log.info(tostring("stack width = " .. #flat))
end

--@api: LFrameStack:typeOf
do

    local fs = lurek.learning.frameStack(3)
    fs:push({0.1})
    local flat = fs:get()
    lurek.log.info(tostring("LFrameStack:typeOf LFrameStack") .. " " .. tostring(tostring(fs:typeOf("LFrameStack"))))
    lurek.log.info(tostring("LFrameStack flattened len") .. " " .. tostring(#flat))
end

--@api: lurek.learning.newTensor
do

    local t = lurek.learning.newTensor({2, 3}, {1.0, 2.0, 3.0, 4.0, 5.0, 6.0})
    local tensor_shape = t:shape()
    local tensor_len = t:len()
    lurek.log.info(tostring("lurek.learning.newTensor type") .. " " .. tostring(t:type()))
    lurek.log.info(tostring("lurek.learning.newTensor len") .. " " .. tostring(t:len()))
end

--@api: LTensor:shape
do

    local t = lurek.learning.newTensor({2, 3}, {1, 2, 3, 4, 5, 6})
    local tensor_shape = t:shape()
    local tensor_len = t:len()
    local s = t:shape()
    lurek.log.info(tostring("LTensor:shape rank") .. " " .. tostring(#s))
    lurek.log.info(tostring("LTensor:shape dim0") .. " " .. tostring(s[1]))
end

--@api: LTensor:data
do

    local t = lurek.learning.newTensor({3}, {10.0, 20.0, 30.0})
    local tensor_shape = t:shape()
    local tensor_len = t:len()
    local d = t:data()
    lurek.log.info(tostring("LTensor:data len") .. " " .. tostring(#d))
    lurek.log.info(tostring("LTensor:data first") .. " " .. tostring(d[1]))
end

--@api: LTensor:get
do

    local t = lurek.learning.newTensor({3}, {7.0, 8.0, 9.0})
    local tensor_shape = t:shape()
    local tensor_len = t:len()
    lurek.log.info(tostring("LTensor:get index1") .. " " .. tostring(t:get(1)))
    lurek.log.info(tostring("LTensor:get index3") .. " " .. tostring(t:get(3)))
end

--@api: LTensor:len
do

    local t = lurek.learning.newTensor({4}, {1.0, 2.0, 3.0, 4.0})
    local tensor_shape = t:shape()
    local tensor_len = t:len()
    lurek.log.info(tostring("LTensor:len") .. " " .. tostring(t:len()))
    lurek.log.info(tostring("tensor rank = " .. #tensor_shape))
end

--@api: LTensor:type
do

    local t = lurek.learning.newTensor({1}, {0.0})
    local tensor_shape = t:shape()
    local tensor_len = t:len()
    lurek.log.info(tostring("LTensor:type") .. " " .. tostring(t:type()))
    lurek.log.info(tostring("tensor len = " .. tensor_len))
end

--@api: LTensor:typeOf
do

    local t = lurek.learning.newTensor({1}, {0.0})
    local tensor_shape = t:shape()
    local tensor_len = t:len()
    lurek.log.info(tostring("LTensor:typeOf LTensor") .. " " .. tostring(tostring(t:typeOf("LTensor"))))
    lurek.log.info(tostring("LTensor data size") .. " " .. tostring(#t:data()))
end

--@api: lurek.learning.wrap
do

    local qlearner = lurek.learning.newQLearner(4, 2)
    local model = lurek.learning.wrap(qlearner)
    local model_type = model:type()
    local is_model = model:typeOf("LModel")
    lurek.log.info(tostring("wrapped model type = " .. model:type()))
end

--@api: LBandit:predict
do

    local b = lurek.learning.newBandit(3, "ucb1", 0.1, 12345)
    local action = b:predict()
    local arms = b:armCount()
    local pulls = b:totalPulls()
    lurek.log.info(tostring("bandit predict = " .. action))
end

--@api: LModel:predict
do

    local qlearner = lurek.learning.newQLearner(4, 2)
    local model = lurek.learning.wrap(qlearner)
    local model_type = model:type()
    local is_model = model:typeOf("LModel")
    local action = model:predict(0)
    lurek.log.info(tostring("model predict = " .. action))
end

--@api: LModel:type
do

    local qlearner = lurek.learning.newQLearner(4, 2)
    local model = lurek.learning.wrap(qlearner)
    local model_type = model:type()
    local is_model = model:typeOf("LModel")
    lurek.log.info(tostring("model type = " .. model:type()))
end

--@api: LModel:typeOf
do

    local qlearner = lurek.learning.newQLearner(4, 2)
    local model = lurek.learning.wrap(qlearner)
    local model_type = model:type()
    local is_model = model:typeOf("LModel")
    lurek.log.info(tostring("model typeOf LModel = " .. tostring(model:typeOf("LModel"))))
end

--@api: LNeuralNet:predict
do

    local nn = lurek.learning.newNeuralNet()
    nn:addLayer(2, 2, "linear")
    local layers = nn:layerCount()
    local action = nn:predict({0.5, 0.3})
    lurek.log.info(tostring("nn predict = " .. tostring(action)))
end

--@api: LQLearner:predict
do

    local q = lurek.learning.newQLearner(4, 2)
    q:setQValue(0, 0, 0.5)
    local states = q:getStateCount()
    local action = q:predict(0)
    lurek.log.info(tostring("qlearner predict = " .. action))
end
