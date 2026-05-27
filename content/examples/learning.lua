-- content/examples/learning.lua
-- Demonstrates the lurek.learning module: neural networks, genetic algorithms,
-- Q-learning, multi-armed bandits, and neuroevolution.

--@api-stub: lurek.learning.newNeuralNet
do
    local net = lurek.learning.newNeuralNet()
    net:addLayer(3, 4, "relu")
    net:addLayer(4, 2, "softmax")

    local output = net:forward({ 0.2, 0.6, -0.1 })
    print("lurek.learning.newNeuralNet layers", net:layerCount())
    print("lurek.learning.newNeuralNet firstOutput", output[1])
end

--@api-stub: lurek.learning.newGeneticAlgorithm
do
    local ga = lurek.learning.newGeneticAlgorithm(6, 4, 42)

    for index = 0, ga:popSize() - 1 do
        ga:setFitness(index, index * 0.25)
    end

    ga:evolve()
    print("lurek.learning.newGeneticAlgorithm generation", ga:generation())
    print("lurek.learning.newGeneticAlgorithm popSize", ga:popSize())
end

--@api-stub: lurek.learning.newQLearner
do
    local learner = lurek.learning.newQLearner(4, 3)
    learner:setLearningRate(0.2)
    learner:setDiscountFactor(0.9)
    learner:learn(1, 2, 1.0, 3)

    print("lurek.learning.newQLearner states", learner:getStateCount())
    print("lurek.learning.newQLearner q12", learner:getQValue(1, 2))
end

--@api-stub: lurek.learning.newBandit
do
    local bandit = lurek.learning.newBandit(4, "ucb1", 0.1, 99)
    local chosen_arm = bandit:select()
    bandit:update(chosen_arm, 0.75)

    print("lurek.learning.newBandit chosenArm", chosen_arm)
    print("lurek.learning.newBandit totalPulls", bandit:totalPulls())
end

--@api-stub: lurek.learning.newNeuroevolution
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

--@api-stub: LBandit:armCount
do
    local bandit = lurek.learning.newBandit(4, "ucb1", 0.1, 1)
    local arm_count = bandit:armCount()

    print("LBandit:armCount", arm_count)
end

--@api-stub: LBandit:bestArm
do
    local bandit = lurek.learning.newBandit(3, "ucb1", 0.1, 2)
    bandit:update(0, 0.25)
    bandit:update(1, 0.9)
    bandit:update(2, 0.4)

    print("LBandit:bestArm", bandit:bestArm())
end

--@api-stub: LBandit:reset
do
    local bandit = lurek.learning.newBandit(3, "thompson", 0.1, 3)
    local selected_arm = bandit:select()
    bandit:update(selected_arm, 0.5)
    bandit:reset()

    print("LBandit:reset pulls", bandit:totalPulls())
    print("LBandit:reset bestArm", bandit:bestArm())
end

--@api-stub: LBandit:select
do
    local bandit = lurek.learning.newBandit(5, "thompson", 0.1, 4)
    local first_arm = bandit:select()
    local second_arm = bandit:select()

    print("LBandit:select first", first_arm)
    print("LBandit:select second", second_arm)
end

--@api-stub: LBandit:totalPulls
do
    local bandit = lurek.learning.newBandit(3, "ucb1", 0.1, 5)
    bandit:select()
    bandit:select()
    local total_pulls = bandit:totalPulls()

    print("LBandit:totalPulls", total_pulls)
end

--@api-stub: LBandit:type
do
    local bandit = lurek.learning.newBandit(3, "ucb1", 0.1, 6)
    local type_name = bandit:type()

    print("LBandit:type", type_name)
end

--@api-stub: LBandit:typeOf
do
    local bandit = lurek.learning.newBandit(3, "ucb1", 0.1, 7)
    local is_bandit = bandit:typeOf("LBandit")
    local is_object = bandit:typeOf("LObject")

    print("LBandit:typeOf LBandit", tostring(is_bandit))
    print("LBandit:typeOf LObject", tostring(is_object))
end

--@api-stub: LBandit:update
do
    local bandit = lurek.learning.newBandit(4, "ucb1", 0.1, 8)
    local arm_index = bandit:select()
    bandit:update(arm_index, 0.8)

    print("LBandit:update arm", arm_index)
    print("LBandit:update bestArm", bandit:bestArm())
end

--@api-stub: LGeneticAlgorithm:bestGenes
do
    local ga = lurek.learning.newGeneticAlgorithm(5, 3, 10)

    for index = 0, ga:popSize() - 1 do
        ga:setFitness(index, index)
    end

    local genes = ga:bestGenes()
    print("LGeneticAlgorithm:bestGenes count", #genes)
    print("LGeneticAlgorithm:bestGenes first", genes[1])
end

--@api-stub: LGeneticAlgorithm:evolve
do
    local ga = lurek.learning.newGeneticAlgorithm(5, 4, 11)

    for index = 0, ga:popSize() - 1 do
        ga:setFitness(index, index * 0.5)
    end

    ga:evolve()
    print("LGeneticAlgorithm:evolve generation", ga:generation())
end

--@api-stub: LGeneticAlgorithm:generation
do
    local ga = lurek.learning.newGeneticAlgorithm(4, 3, 12)
    ga:evolve()
    ga:evolve()

    print("LGeneticAlgorithm:generation", ga:generation())
end

--@api-stub: LGeneticAlgorithm:getGenes
do
    local ga = lurek.learning.newGeneticAlgorithm(4, 5, 13)
    local genes = ga:getGenes(0)

    print("LGeneticAlgorithm:getGenes count", #genes)
    print("LGeneticAlgorithm:getGenes first", genes[1])
end

--@api-stub: LGeneticAlgorithm:popSize
do
    local ga = lurek.learning.newGeneticAlgorithm(15, 8, 14)
    local pop_size = ga:popSize()

    print("LGeneticAlgorithm:popSize", pop_size)
end

--@api-stub: LGeneticAlgorithm:setFitness
do
    local ga = lurek.learning.newGeneticAlgorithm(6, 3, 15)
    ga:setFitness(0, 1.25)
    ga:setFitness(1, 0.5)
    ga:evolve()

    print("LGeneticAlgorithm:setFitness generation", ga:generation())
    print("LGeneticAlgorithm:setFitness bestGenes", #ga:bestGenes())
end

--@api-stub: LGeneticAlgorithm:type
do
    local ga = lurek.learning.newGeneticAlgorithm(4, 2, 16)
    local type_name = ga:type()

    print("LGeneticAlgorithm:type", type_name)
end

--@api-stub: LGeneticAlgorithm:typeOf
do
    local ga = lurek.learning.newGeneticAlgorithm(4, 2, 17)
    local is_ga = ga:typeOf("LGeneticAlgorithm")
    local is_object = ga:typeOf("LObject")

    print("LGeneticAlgorithm:typeOf LGeneticAlgorithm", tostring(is_ga))
    print("LGeneticAlgorithm:typeOf LObject", tostring(is_object))
end

--@api-stub: LNeuralNet:addLayer
do
    local net = lurek.learning.newNeuralNet()
    net:addLayer(4, 6, "relu")
    net:addLayer(6, 2, "sigmoid")

    print("LNeuralNet:addLayer layerCount", net:layerCount())
    print("LNeuralNet:addLayer paramCount", net:paramCount())
end

--@api-stub: LNeuralNet:forward
do
    local net = lurek.learning.newNeuralNet()
    net:addLayer(3, 4, "relu")
    net:addLayer(4, 1, "sigmoid")
    local output = net:forward({ 0.1, 0.5, 0.9 })

    print("LNeuralNet:forward out", output[1])
end

--@api-stub: LNeuralNet:getWeights
do
    local net = lurek.learning.newNeuralNet()
    net:addLayer(2, 3, "relu")
    local weights = net:getWeights()

    print("LNeuralNet:getWeights count", #weights)
    print("LNeuralNet:getWeights first", weights[1])
end

--@api-stub: LNeuralNet:layerCount
do
    local net = lurek.learning.newNeuralNet()
    net:addLayer(4, 8, "relu")
    net:addLayer(8, 4, "relu")
    net:addLayer(4, 1, "sigmoid")

    print("LNeuralNet:layerCount", net:layerCount())
end

--@api-stub: LNeuralNet:paramCount
do
    local net = lurek.learning.newNeuralNet()
    net:addLayer(2, 4, "relu")
    net:addLayer(4, 1, "sigmoid")

    print("LNeuralNet:paramCount", net:paramCount())
end

--@api-stub: LNeuralNet:setWeights
do
    local net = lurek.learning.newNeuralNet()
    net:addLayer(2, 2, "linear")
    local weights = net:getWeights()
    local applied = net:setWeights(weights)

    print("LNeuralNet:setWeights applied", tostring(applied))
    print("LNeuralNet:setWeights paramCount", net:paramCount())
end

--@api-stub: LNeuralNet:type
do
    local net = lurek.learning.newNeuralNet()
    local type_name = net:type()

    print("LNeuralNet:type", type_name)
end

--@api-stub: LNeuralNet:typeOf
do
    local net = lurek.learning.newNeuralNet()
    local is_net = net:typeOf("LNeuralNet")
    local is_object = net:typeOf("LObject")

    print("LNeuralNet:typeOf LNeuralNet", tostring(is_net))
    print("LNeuralNet:typeOf LObject", tostring(is_object))
end

--@api-stub: LNeuroevolution:bestFitness
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

--@api-stub: LNeuroevolution:bestNetwork
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

--@api-stub: LNeuroevolution:chromosomeToNet
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

--@api-stub: LNeuroevolution:evolve
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

--@api-stub: LNeuroevolution:generation
do
    local layer_spec = {
        { inputs = 2, outputs = 2, activation = "relu" },
        { inputs = 2, outputs = 1, activation = "sigmoid" }
    }
    local evo = lurek.learning.newNeuroevolution(layer_spec, 4, 22)
    evo:evolve()

    print("LNeuroevolution:generation", evo:generation())
end

--@api-stub: LNeuroevolution:popSize
do
    local layer_spec = {
        { inputs = 2, outputs = 3, activation = "relu" },
        { inputs = 3, outputs = 1, activation = "linear" }
    }
    local evo = lurek.learning.newNeuroevolution(layer_spec, 12, 23)
    local pop_size = evo:popSize()

    print("LNeuroevolution:popSize", pop_size)
end

--@api-stub: LNeuroevolution:setFitness
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

--@api-stub: LNeuroevolution:type
do
    local layer_spec = {
        { inputs = 2, outputs = 3, activation = "relu" },
        { inputs = 3, outputs = 1, activation = "sigmoid" }
    }
    local evo = lurek.learning.newNeuroevolution(layer_spec, 4, 25)
    local type_name = evo:type()

    print("LNeuroevolution:type", type_name)
end

--@api-stub: LNeuroevolution:typeOf
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

--@api-stub: LQLearner:bestAction
do
    local learner = lurek.learning.newQLearner(5, 3)
    learner:setQValue(1, 1, 0.5)
    learner:setQValue(1, 2, 1.2)
    learner:setQValue(1, 3, 0.8)

    print("LQLearner:bestAction", learner:bestAction(1))
end

--@api-stub: LQLearner:chooseAction
do
    local learner = lurek.learning.newQLearner(5, 3)
    learner:setExplorationRate(0.0)
    learner:setQValue(1, 2, 2.0)
    local chosen_action = learner:chooseAction(1)

    print("LQLearner:chooseAction", chosen_action)
end

--@api-stub: LQLearner:deserialize
do
    local source = lurek.learning.newQLearner(5, 3)
    source:setQValue(2, 3, 3.14)
    local saved = source:serialize()

    local restored = lurek.learning.newQLearner(5, 3)
    restored:deserialize(saved)
    print("LQLearner:deserialize q23", restored:getQValue(2, 3))
end

--@api-stub: LQLearner:endEpisode
do
    local learner = lurek.learning.newQLearner(8, 4)
    learner:setExplorationRate(0.8)
    learner:setExplorationDecay(0.5)
    learner:endEpisode()

    print("LQLearner:endEpisode explorationRate", learner:getExplorationRate())
end

--@api-stub: LQLearner:getActionCount
do
    local learner = lurek.learning.newQLearner(10, 4)
    local action_count = learner:getActionCount()

    print("LQLearner:getActionCount", action_count)
end

--@api-stub: LQLearner:getDiscountFactor
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setDiscountFactor(0.95)

    print("LQLearner:getDiscountFactor", learner:getDiscountFactor())
end

--@api-stub: LQLearner:getExplorationDecay
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setExplorationDecay(0.97)

    print("LQLearner:getExplorationDecay", learner:getExplorationDecay())
end

--@api-stub: LQLearner:getExplorationRate
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setExplorationRate(0.35)

    print("LQLearner:getExplorationRate", learner:getExplorationRate())
end

--@api-stub: LQLearner:getLearningRate
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setLearningRate(0.05)

    print("LQLearner:getLearningRate", learner:getLearningRate())
end

--@api-stub: LQLearner:getQValue
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(2, 3, 7.5)
    local value = learner:getQValue(2, 3)

    print("LQLearner:getQValue", value)
end

--@api-stub: LQLearner:getStateCount
do
    local learner = lurek.learning.newQLearner(10, 4)
    local state_count = learner:getStateCount()

    print("LQLearner:getStateCount", state_count)
end

--@api-stub: LQLearner:learn
do
    local learner = lurek.learning.newQLearner(6, 3)
    learner:setLearningRate(0.5)
    learner:setDiscountFactor(0.0)
    learner:learn(1, 2, 1.0, 3)

    print("LQLearner:learn q12", learner:getQValue(1, 2))
end

--@api-stub: LQLearner:serialize
do
    local learner = lurek.learning.newQLearner(5, 3)
    learner:setQValue(1, 1, 1.5)
    local json = learner:serialize()

    print("LQLearner:serialize length", #json)
end

--@api-stub: LQLearner:setDiscountFactor
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setDiscountFactor(0.95)

    print("LQLearner:setDiscountFactor", learner:getDiscountFactor())
end

--@api-stub: LQLearner:setExplorationDecay
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setExplorationDecay(0.99)

    print("LQLearner:setExplorationDecay", learner:getExplorationDecay())
end

--@api-stub: LQLearner:setExplorationRate
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setExplorationRate(0.5)

    print("LQLearner:setExplorationRate", learner:getExplorationRate())
end

--@api-stub: LQLearner:setLearningRate
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setLearningRate(0.05)

    print("LQLearner:setLearningRate", learner:getLearningRate())
end

--@api-stub: LQLearner:setQValue
do
    local learner = lurek.learning.newQLearner(8, 4)
    learner:setQValue(3, 2, 4.2)

    print("LQLearner:setQValue", learner:getQValue(3, 2))
end

--@api-stub: LQLearner:type
do
    local learner = lurek.learning.newQLearner(10, 4)
    local type_name = learner:type()

    print("LQLearner:type", type_name)
end

--@api-stub: LQLearner:typeOf
do
    local learner = lurek.learning.newQLearner(10, 4)
    local is_learner = learner:typeOf("LQLearner")
    local is_object = learner:typeOf("LObject")

    print("LQLearner:typeOf LQLearner", tostring(is_learner))
    print("LQLearner:typeOf LObject", tostring(is_object))
end

--@api-stub: LQLearner:getEpisodeCount
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:endEpisode()
    learner:endEpisode()
    print("LQLearner:getEpisodeCount", learner:getEpisodeCount())
end
