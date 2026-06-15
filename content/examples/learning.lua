-- content/examples/learning.lua
-- Demonstrates the lurek.learning module: neural networks, genetic algorithms,
-- Q-learning, multi-armed bandits, and neuroevolution.

--@api: lurek.learning.newNeuralNet
do
    local net = lurek.learning.newNeuralNet()
    net:addLayer(3, 4, "relu")
    net:addLayer(4, 2, "softmax")

    local output = net:forward({ 0.2, 0.6, -0.1 })
    print("lurek.learning.newNeuralNet layers", net:layerCount())
    print("lurek.learning.newNeuralNet firstOutput", output[1])
end

--@api: lurek.learning.newEngine
do
    local engine = lurek.learning.newEngine()
    print("lurek.learning.newEngine blocks", engine:blockCount())
    print("lua type = " .. type(engine))
end

--@api: LNeuralEngine:addDense
do
    local engine = lurek.learning.newEngine()
    engine:addDense(3, 4, "relu")
    print("LNeuralEngine:addDense params", engine:paramCount())
end

--@api: LNeuralEngine:addConv2D
do
    local engine = lurek.learning.newEngine()
    engine:addConv2D(1, 2, 3, 3, 1, 1, 1, 1)
    print("LNeuralEngine:addConv2D blocks", engine:blockCount())
end

--@api: LNeuralEngine:addMaxPool2D
do
    local engine = lurek.learning.newEngine()
    engine:addMaxPool2D(2, 2)
    print("LNeuralEngine:addMaxPool2D params", engine:paramCount())
end

--@api: LNeuralEngine:addTransformerEncoder
do
    local engine = lurek.learning.newEngine()
    engine:addTransformerEncoder(4, 2, 8)
    print("LNeuralEngine:addTransformerEncoder blocks", engine:blockCount())
end

--@api: LNeuralEngine:blockCount
do
    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    print("LNeuralEngine:blockCount", engine:blockCount())
end

--@api: LNeuralEngine:paramCount
do
    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    print("LNeuralEngine:paramCount", engine:paramCount())
end

--@api: LNeuralEngine:setWeights
do
    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    local weights = {}
    for i = 1, engine:paramCount() do
        weights[i] = 0.05 * i
    end
    print("LNeuralEngine:setWeights", engine:setWeights(weights))
end

--@api: LNeuralEngine:getWeights
do
    local engine = lurek.learning.newEngine()
    engine:addDense(2, 2, "linear")
    engine:setWeights({ 0.1, 0.2, 0.3, 0.4, 0.0, 0.0 })
    print("LNeuralEngine:getWeights count", #engine:getWeights())
end

--@api: LNeuralEngine:type
do
    local engine = lurek.learning.newEngine()
    print("LNeuralEngine:type", engine:type())
    print("typeOf LObject = " .. tostring(engine:typeOf("LObject")))
end

--@api: LNeuralEngine:typeOf
do
    local engine = lurek.learning.newEngine()
    print("LNeuralEngine:typeOf", engine:typeOf("LNeuralEngine"))
    print("type = " .. tostring(engine:type()))
end

--@api: lurek.learning.newGeneticAlgorithm
do
    local ga = lurek.learning.newGeneticAlgorithm(6, 4, 42)

    for index = 0, ga:popSize() - 1 do
        ga:setFitness(index, index * 0.25)
    end

    ga:evolve()
    print("lurek.learning.newGeneticAlgorithm generation", ga:generation())
    print("lurek.learning.newGeneticAlgorithm popSize", ga:popSize())
end

--@api: lurek.learning.newQLearner
do
    local learner = lurek.learning.newQLearner(4, 3)
    learner:setLearningRate(0.2)
    learner:setDiscountFactor(0.9)
    learner:learn(1, 2, 1.0, 3)

    print("lurek.learning.newQLearner states", learner:getStateCount())
    print("lurek.learning.newQLearner q12", learner:getQValue(1, 2))
end

--@api: lurek.learning.newBandit
do
    local bandit = lurek.learning.newBandit(4, "ucb1", 0.1, 99)
    local chosen_arm = bandit:select()
    bandit:update(chosen_arm, 0.75)

    print("lurek.learning.newBandit chosenArm", chosen_arm)
    print("lurek.learning.newBandit totalPulls", bandit:totalPulls())
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
    print("lurek.learning.newNeuroevolution generation", evo:generation())
    print("lurek.learning.newNeuroevolution bestFitness", evo:bestFitness())
end

--@api: LBandit:armCount
do
    local bandit = lurek.learning.newBandit(4, "ucb1", 0.1, 1)
    local arm_count = bandit:armCount()

    print("LBandit:armCount", arm_count)
end

--@api: LBandit:bestArm
do
    local bandit = lurek.learning.newBandit(3, "ucb1", 0.1, 2)
    bandit:update(0, 0.25)
    bandit:update(1, 0.9)
    bandit:update(2, 0.4)

    print("LBandit:bestArm", bandit:bestArm())
end

--@api: LBandit:reset
do
    local bandit = lurek.learning.newBandit(3, "thompson", 0.1, 3)
    local selected_arm = bandit:select()
    bandit:update(selected_arm, 0.5)
    bandit:reset()

    print("LBandit:reset pulls", bandit:totalPulls())
    print("LBandit:reset bestArm", bandit:bestArm())
end

--@api: LBandit:select
do
    local bandit = lurek.learning.newBandit(5, "thompson", 0.1, 4)
    local first_arm = bandit:select()
    local second_arm = bandit:select()

    print("LBandit:select first", first_arm)
    print("LBandit:select second", second_arm)
end

--@api: LBandit:totalPulls
do
    local bandit = lurek.learning.newBandit(3, "ucb1", 0.1, 5)
    bandit:select()
    bandit:select()
    local total_pulls = bandit:totalPulls()

    print("LBandit:totalPulls", total_pulls)
end

--@api: LBandit:type
do
    local bandit = lurek.learning.newBandit(3, "ucb1", 0.1, 6)
    local type_name = bandit:type()

    print("LBandit:type", type_name)
end

--@api: LBandit:typeOf
do
    local bandit = lurek.learning.newBandit(3, "ucb1", 0.1, 7)
    local is_bandit = bandit:typeOf("LBandit")
    local is_object = bandit:typeOf("LObject")

    print("LBandit:typeOf LBandit", tostring(is_bandit))
    print("LBandit:typeOf LObject", tostring(is_object))
end

--@api: LBandit:update
do
    local bandit = lurek.learning.newBandit(4, "ucb1", 0.1, 8)
    local arm_index = bandit:select()
    bandit:update(arm_index, 0.8)

    print("LBandit:update arm", arm_index)
    print("LBandit:update bestArm", bandit:bestArm())
end

--@api: LGeneticAlgorithm:bestGenes
do
    local ga = lurek.learning.newGeneticAlgorithm(5, 3, 10)

    for index = 0, ga:popSize() - 1 do
        ga:setFitness(index, index)
    end

    local genes = ga:bestGenes()
    print("LGeneticAlgorithm:bestGenes count", #genes)
    print("LGeneticAlgorithm:bestGenes first", genes[1])
end

--@api: LGeneticAlgorithm:evolve
do
    local ga = lurek.learning.newGeneticAlgorithm(5, 4, 11)

    for index = 0, ga:popSize() - 1 do
        ga:setFitness(index, index * 0.5)
    end

    ga:evolve()
    print("LGeneticAlgorithm:evolve generation", ga:generation())
end

--@api: LGeneticAlgorithm:generation
do
    local ga = lurek.learning.newGeneticAlgorithm(4, 3, 12)
    ga:evolve()
    ga:evolve()

    print("LGeneticAlgorithm:generation", ga:generation())
end

--@api: LGeneticAlgorithm:getGenes
do
    local ga = lurek.learning.newGeneticAlgorithm(4, 5, 13)
    local genes = ga:getGenes(0)

    print("LGeneticAlgorithm:getGenes count", #genes)
    print("LGeneticAlgorithm:getGenes first", genes[1])
end

--@api: LGeneticAlgorithm:popSize
do
    local ga = lurek.learning.newGeneticAlgorithm(15, 8, 14)
    local pop_size = ga:popSize()

    print("LGeneticAlgorithm:popSize", pop_size)
end

--@api: LGeneticAlgorithm:setFitness
do
    local ga = lurek.learning.newGeneticAlgorithm(6, 3, 15)
    ga:setFitness(0, 1.25)
    ga:setFitness(1, 0.5)
    ga:evolve()

    print("LGeneticAlgorithm:setFitness generation", ga:generation())
    print("LGeneticAlgorithm:setFitness bestGenes", #ga:bestGenes())
end

--@api: LGeneticAlgorithm:type
do
    local ga = lurek.learning.newGeneticAlgorithm(4, 2, 16)
    local type_name = ga:type()

    print("LGeneticAlgorithm:type", type_name)
end

--@api: LGeneticAlgorithm:typeOf
do
    local ga = lurek.learning.newGeneticAlgorithm(4, 2, 17)
    local is_ga = ga:typeOf("LGeneticAlgorithm")
    local is_object = ga:typeOf("LObject")

    print("LGeneticAlgorithm:typeOf LGeneticAlgorithm", tostring(is_ga))
    print("LGeneticAlgorithm:typeOf LObject", tostring(is_object))
end

--@api: LNeuralNet:addLayer
do
    local net = lurek.learning.newNeuralNet()
    net:addLayer(4, 6, "relu")
    net:addLayer(6, 2, "sigmoid")

    print("LNeuralNet:addLayer layerCount", net:layerCount())
    print("LNeuralNet:addLayer paramCount", net:paramCount())
end

--@api: LNeuralNet:forward
do
    local net = lurek.learning.newNeuralNet()
    net:addLayer(3, 4, "relu")
    net:addLayer(4, 1, "sigmoid")
    local output = net:forward({ 0.1, 0.5, 0.9 })

    print("LNeuralNet:forward out", output[1])
end

--@api: LNeuralNet:getWeights
do
    local net = lurek.learning.newNeuralNet()
    net:addLayer(2, 3, "relu")
    local weights = net:getWeights()

    print("LNeuralNet:getWeights count", #weights)
    print("LNeuralNet:getWeights first", weights[1])
end

--@api: LNeuralNet:layerCount
do
    local net = lurek.learning.newNeuralNet()
    net:addLayer(4, 8, "relu")
    net:addLayer(8, 4, "relu")
    net:addLayer(4, 1, "sigmoid")

    print("LNeuralNet:layerCount", net:layerCount())
end

--@api: LNeuralNet:paramCount
do
    local net = lurek.learning.newNeuralNet()
    net:addLayer(2, 4, "relu")
    net:addLayer(4, 1, "sigmoid")

    print("LNeuralNet:paramCount", net:paramCount())
end

--@api: LNeuralNet:setWeights
do
    local net = lurek.learning.newNeuralNet()
    net:addLayer(2, 2, "linear")
    local weights = net:getWeights()
    local applied = net:setWeights(weights)

    print("LNeuralNet:setWeights applied", tostring(applied))
    print("LNeuralNet:setWeights paramCount", net:paramCount())
end

--@api: LNeuralNet:type
do
    local net = lurek.learning.newNeuralNet()
    local type_name = net:type()

    print("LNeuralNet:type", type_name)
end

--@api: LNeuralNet:typeOf
do
    local net = lurek.learning.newNeuralNet()
    local is_net = net:typeOf("LNeuralNet")
    local is_object = net:typeOf("LObject")

    print("LNeuralNet:typeOf LNeuralNet", tostring(is_net))
    print("LNeuralNet:typeOf LObject", tostring(is_object))
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

    print("LNeuroevolution:bestFitness", evo:bestFitness())
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
    print("LNeuroevolution:bestNetwork type", best_net:type())
    print("LNeuroevolution:bestNetwork layers", best_net:layerCount())
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

    print("LNeuroevolution:chromosomeToNet type", net:type())
    print("LNeuroevolution:chromosomeToNet out", output[1])
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
    print("LNeuroevolution:evolve generation", evo:generation())
end

--@api: LNeuroevolution:generation
do
    local layer_spec = {
        { inputs = 2, outputs = 2, activation = "relu" },
        { inputs = 2, outputs = 1, activation = "sigmoid" }
    }
    local evo = lurek.learning.newNeuroevolution(layer_spec, 4, 22)
    evo:evolve()

    print("LNeuroevolution:generation", evo:generation())
end

--@api: LNeuroevolution:popSize
do
    local layer_spec = {
        { inputs = 2, outputs = 3, activation = "relu" },
        { inputs = 3, outputs = 1, activation = "linear" }
    }
    local evo = lurek.learning.newNeuroevolution(layer_spec, 12, 23)
    local pop_size = evo:popSize()

    print("LNeuroevolution:popSize", pop_size)
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

    print("LNeuroevolution:setFitness generation", evo:generation())
    print("LNeuroevolution:setFitness bestFitness", evo:bestFitness())
end

--@api: LNeuroevolution:type
do
    local layer_spec = {
        { inputs = 2, outputs = 3, activation = "relu" },
        { inputs = 3, outputs = 1, activation = "sigmoid" }
    }
    local evo = lurek.learning.newNeuroevolution(layer_spec, 4, 25)
    local type_name = evo:type()

    print("LNeuroevolution:type", type_name)
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

    print("LNeuroevolution:typeOf LNeuroevolution", tostring(is_evo))
    print("LNeuroevolution:typeOf LObject", tostring(is_object))
end

--@api: lurek.learning.newLstm
do
    local lstm = lurek.learning.newLstm(2, 3)
    print("lurek.learning.newLstm type", lstm:type())
    print("typeOf LObject = " .. tostring(lstm:typeOf("LObject")))
end

--@api: LLSTM:forward
do
    local lstm = lurek.learning.newLstm(2, 3)
    local out = lstm:forward({ 0.1, -0.2 })
    print("LLSTM:forward outLen", #out)
end

--@api: lurek.learning.newGru
do
    local gru = lurek.learning.newGru(2, 3)
    print("lurek.learning.newGru type", gru:type())
    print("typeOf LObject = " .. tostring(gru:typeOf("LObject")))
end

--@api: LGRU:forward
do
    local gru = lurek.learning.newGru(2, 3)
    local out = gru:forward({ 0.1, -0.2 })
    print("LGRU:forward outLen", #out)
end

--@api: lurek.learning.newConv2D
do
    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    print("lurek.learning.newConv2D type", conv:type())
    print("typeOf LObject = " .. tostring(conv:typeOf("LObject")))
end

--@api: LConv2D:forward
do
    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    local input = lurek.learning.newTensor({1, 2, 2}, {1, 2, 3, 4})
    local out = conv:forward(input)
    print("LConv2D:forward outW", out:shape()[3])
end

--@api: lurek.learning.newMaxPool2D
do
    local pool = lurek.learning.newMaxPool2D(2, 2, 2, 2)
    print("lurek.learning.newMaxPool2D type", pool:type())
    print("typeOf LObject = " .. tostring(pool:typeOf("LObject")))
end

--@api: LMaxPool2D:forward
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

--@api: lurek.learning.newPositionalEncoding
do
    local pe = lurek.learning.newPositionalEncoding(4, 8)
    print("lurek.learning.newPositionalEncoding type", pe:type())
    print("typeOf LObject = " .. tostring(pe:typeOf("LObject")))
end

--@api: LPositionalEncoding:apply
do
    local pe = lurek.learning.newPositionalEncoding(4, 8)
    local x = lurek.learning.newTensor({2, 4}, {0, 0, 0, 0, 0, 0, 0, 0})
    local out = pe:apply(x)
    print("LPositionalEncoding:apply d1", out:data()[1])
end

--@api: lurek.learning.newMultiHeadAttention
do
    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    print("lurek.learning.newMultiHeadAttention type", mha:type())
    print("typeOf LObject = " .. tostring(mha:typeOf("LObject")))
end

--@api: LMultiHeadAttention:forward
do
    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    local x = lurek.learning.newTensor({2, 4}, {1, 0, 0, 1, 0, 1, 1, 0})
    local out = mha:forward(x)
    print("LMultiHeadAttention:forward outShape", out:shape()[2])
end

--@api: lurek.learning.newTransformerEncoder
do
    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    print("lurek.learning.newTransformerEncoder type", enc:type())
    print("typeOf LObject = " .. tostring(enc:typeOf("LObject")))
end

--@api: LTransformerEncoder:forward
do
    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    local x = lurek.learning.newTensor({2, 4}, {1, 2, 3, 4, 4, 3, 2, 1})
    local out = enc:forward(x)
    print("LTransformerEncoder:forward outRows", out:shape()[1])
end

--@api: lurek.learning.newTransformerDecoder
do
    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    print("lurek.learning.newTransformerDecoder type", dec:type())
    print("typeOf LObject = " .. tostring(dec:typeOf("LObject")))
end

--@api: LTransformerDecoder:forward
do
    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    local x = lurek.learning.newTensor({2, 4}, {1, 2, 3, 4, 4, 3, 2, 1})
    local e = lurek.learning.newTensor({2, 4}, {0, 1, 0, 1, 1, 0, 1, 0})
    local out = dec:forward(x, e)
    print("LTransformerDecoder:forward outRows", out:shape()[1])
end

--@api: LLSTM:reset
do
    local lstm = lurek.learning.newLstm(2, 2)
    lstm:reset()
    print("LLSTM:reset ok")
end

--@api: LLSTM:setWeights
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

--@api: LLSTM:getWeights
do
    local lstm = lurek.learning.newLstm(2, 2)
    local got = lstm:getWeights()
    print("LLSTM:getWeights", #got)
end

--@api: LLSTM:paramCount
do
    local lstm = lurek.learning.newLstm(2, 2)
    print("LLSTM:paramCount", lstm:paramCount())
    print("owner type = " .. tostring(lstm:type()))
end

--@api: LLSTM:type
do
    local lstm = lurek.learning.newLstm(2, 2)
    print("LLSTM:type", lstm:type())
    print("typeOf LObject = " .. tostring(lstm:typeOf("LObject")))
end

--@api: LLSTM:typeOf
do
    local lstm = lurek.learning.newLstm(2, 2)
    print("LLSTM:typeOf", tostring(lstm:typeOf("LObject")))
    print("type = " .. tostring(lstm:type()))
end

--@api: LGRU:reset
do
    local gru = lurek.learning.newGru(2, 2)
    gru:reset()
    print("LGRU:reset ok")
end

--@api: LGRU:setWeights
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

--@api: LGRU:getWeights
do
    local gru = lurek.learning.newGru(2, 2)
    local got = gru:getWeights()
    print("LGRU:getWeights", #got)
end

--@api: LGRU:paramCount
do
    local gru = lurek.learning.newGru(2, 2)
    print("LGRU:paramCount", gru:paramCount())
    print("owner type = " .. tostring(gru:type()))
end

--@api: LGRU:type
do
    local gru = lurek.learning.newGru(2, 2)
    print("LGRU:type", gru:type())
    print("typeOf LObject = " .. tostring(gru:typeOf("LObject")))
end

--@api: LGRU:typeOf
do
    local gru = lurek.learning.newGru(2, 2)
    print("LGRU:typeOf", tostring(gru:typeOf("LObject")))
    print("type = " .. tostring(gru:type()))
end

--@api: LConv2D:setWeights
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

--@api: LConv2D:getWeights
do
    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    local got = conv:getWeights()
    print("LConv2D:getWeights", #got)
end

--@api: LConv2D:paramCount
do
    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    print("LConv2D:paramCount", conv:paramCount())
    print("owner type = " .. tostring(conv:type()))
end

--@api: LConv2D:type
do
    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    print("LConv2D:type", conv:type())
    print("typeOf LObject = " .. tostring(conv:typeOf("LObject")))
end

--@api: LConv2D:typeOf
do
    local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
    print("LConv2D:typeOf", tostring(conv:typeOf("LObject")))
    print("type = " .. tostring(conv:type()))
end

--@api: LMaxPool2D:type
do
    local pool = lurek.learning.newMaxPool2D(2, 2, 2, 2)
    print("LMaxPool2D:type", pool:type())
    print("typeOf LObject = " .. tostring(pool:typeOf("LObject")))
end

--@api: LMaxPool2D:typeOf
do
    local pool = lurek.learning.newMaxPool2D(2, 2, 2, 2)
    print("LMaxPool2D:typeOf", tostring(pool:typeOf("LObject")))
    print("type = " .. tostring(pool:type()))
end

--@api: LPositionalEncoding:type
do
    local pe = lurek.learning.newPositionalEncoding(4, 8)
    print("LPositionalEncoding:type", pe:type())
    print("typeOf LObject = " .. tostring(pe:typeOf("LObject")))
end

--@api: LPositionalEncoding:typeOf
do
    local pe = lurek.learning.newPositionalEncoding(4, 8)
    print("LPositionalEncoding:typeOf", tostring(pe:typeOf("LObject")))
    print("type = " .. tostring(pe:type()))
end

--@api: LMultiHeadAttention:setWeights
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

--@api: LMultiHeadAttention:getWeights
do
    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    local got = mha:getWeights()
    print("LMultiHeadAttention:getWeights", #got)
end

--@api: LMultiHeadAttention:paramCount
do
    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    print("LMultiHeadAttention:paramCount", mha:paramCount())
    print("owner type = " .. tostring(mha:type()))
end

--@api: LMultiHeadAttention:type
do
    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    print("LMultiHeadAttention:type", mha:type())
    print("typeOf LObject = " .. tostring(mha:typeOf("LObject")))
end

--@api: LMultiHeadAttention:typeOf
do
    local mha = lurek.learning.newMultiHeadAttention(4, 2)
    print("LMultiHeadAttention:typeOf", tostring(mha:typeOf("LObject")))
    print("type = " .. tostring(mha:type()))
end

--@api: LTransformerEncoder:setWeights
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

--@api: LTransformerEncoder:getWeights
do
    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    local got = enc:getWeights()
    print("LTransformerEncoder:getWeights", #got)
end

--@api: LTransformerEncoder:paramCount
do
    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    print("LTransformerEncoder:paramCount", enc:paramCount())
    print("owner type = " .. tostring(enc:type()))
end

--@api: LTransformerEncoder:type
do
    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    print("LTransformerEncoder:type", enc:type())
    print("typeOf LObject = " .. tostring(enc:typeOf("LObject")))
end

--@api: LTransformerEncoder:typeOf
do
    local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
    print("LTransformerEncoder:typeOf", tostring(enc:typeOf("LObject")))
    print("type = " .. tostring(enc:type()))
end

--@api: LTransformerDecoder:setWeights
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

--@api: LTransformerDecoder:getWeights
do
    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    local got = dec:getWeights()
    print("LTransformerDecoder:getWeights", #got)
end

--@api: LTransformerDecoder:paramCount
do
    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    print("LTransformerDecoder:paramCount", dec:paramCount())
    print("owner type = " .. tostring(dec:type()))
end

--@api: LTransformerDecoder:type
do
    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    print("LTransformerDecoder:type", dec:type())
    print("typeOf LObject = " .. tostring(dec:typeOf("LObject")))
end

--@api: LTransformerDecoder:typeOf
do
    local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
    print("LTransformerDecoder:typeOf", tostring(dec:typeOf("LObject")))
    print("type = " .. tostring(dec:type()))
end

--@api: LQLearner:bestAction
do
    local learner = lurek.learning.newQLearner(5, 3)
    learner:setQValue(1, 1, 0.5)
    learner:setQValue(1, 2, 1.2)
    learner:setQValue(1, 3, 0.8)

    print("LQLearner:bestAction", learner:bestAction(1))
end

--@api: LQLearner:chooseAction
do
    local learner = lurek.learning.newQLearner(5, 3)
    learner:setExplorationRate(0.0)
    learner:setQValue(1, 2, 2.0)
    local chosen_action = learner:chooseAction(1)

    print("LQLearner:chooseAction", chosen_action)
end

--@api: LQLearner:deserialize
do
    local source = lurek.learning.newQLearner(5, 3)
    source:setQValue(2, 3, 3.14)
    local saved = source:serialize()

    local restored = lurek.learning.newQLearner(5, 3)
    restored:deserialize(saved)
    print("LQLearner:deserialize q23", restored:getQValue(2, 3))
end

--@api: LQLearner:endEpisode
do
    local learner = lurek.learning.newQLearner(8, 4)
    learner:setExplorationRate(0.8)
    learner:setExplorationDecay(0.5)
    learner:endEpisode()

    print("LQLearner:endEpisode explorationRate", learner:getExplorationRate())
end

--@api: LQLearner:getActionCount
do
    local learner = lurek.learning.newQLearner(10, 4)
    local action_count = learner:getActionCount()

    print("LQLearner:getActionCount", action_count)
end

--@api: LQLearner:getDiscountFactor
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setDiscountFactor(0.95)

    print("LQLearner:getDiscountFactor", learner:getDiscountFactor())
end

--@api: LQLearner:getExplorationDecay
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setExplorationDecay(0.97)

    print("LQLearner:getExplorationDecay", learner:getExplorationDecay())
end

--@api: LQLearner:getExplorationRate
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setExplorationRate(0.35)

    print("LQLearner:getExplorationRate", learner:getExplorationRate())
end

--@api: LQLearner:getLearningRate
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setLearningRate(0.05)

    print("LQLearner:getLearningRate", learner:getLearningRate())
end

--@api: LQLearner:getQValue
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setQValue(2, 3, 7.5)
    local value = learner:getQValue(2, 3)

    print("LQLearner:getQValue", value)
end

--@api: LQLearner:getStateCount
do
    local learner = lurek.learning.newQLearner(10, 4)
    local state_count = learner:getStateCount()

    print("LQLearner:getStateCount", state_count)
end

--@api: LQLearner:learn
do
    local learner = lurek.learning.newQLearner(6, 3)
    learner:setLearningRate(0.5)
    learner:setDiscountFactor(0.0)
    learner:learn(1, 2, 1.0, 3)

    print("LQLearner:learn q12", learner:getQValue(1, 2))
end

--@api: LQLearner:serialize
do
    local learner = lurek.learning.newQLearner(5, 3)
    learner:setQValue(1, 1, 1.5)
    local json = learner:serialize()

    print("LQLearner:serialize length", #json)
end

--@api: LQLearner:setDiscountFactor
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setDiscountFactor(0.95)

    print("LQLearner:setDiscountFactor", learner:getDiscountFactor())
end

--@api: LQLearner:setExplorationDecay
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setExplorationDecay(0.99)

    print("LQLearner:setExplorationDecay", learner:getExplorationDecay())
end

--@api: LQLearner:setExplorationRate
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setExplorationRate(0.5)

    print("LQLearner:setExplorationRate", learner:getExplorationRate())
end

--@api: LQLearner:setLearningRate
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:setLearningRate(0.05)

    print("LQLearner:setLearningRate", learner:getLearningRate())
end

--@api: LQLearner:setQValue
do
    local learner = lurek.learning.newQLearner(8, 4)
    learner:setQValue(3, 2, 4.2)

    print("LQLearner:setQValue", learner:getQValue(3, 2))
end

--@api: LQLearner:type
do
    local learner = lurek.learning.newQLearner(10, 4)
    local type_name = learner:type()

    print("LQLearner:type", type_name)
end

--@api: LQLearner:typeOf
do
    local learner = lurek.learning.newQLearner(10, 4)
    local is_learner = learner:typeOf("LQLearner")
    local is_object = learner:typeOf("LObject")

    print("LQLearner:typeOf LQLearner", tostring(is_learner))
    print("LQLearner:typeOf LObject", tostring(is_object))
end

--@api: LQLearner:getEpisodeCount
do
    local learner = lurek.learning.newQLearner(10, 4)
    learner:endEpisode()
    learner:endEpisode()
    print("LQLearner:getEpisodeCount", learner:getEpisodeCount())
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
    print("lurek.learning.defineEnv type", env:type())
    print("lurek.learning.defineEnv obs[1]", obs[1])
end

--@api: lurek.learning.frameStack
do
    local fs = lurek.learning.frameStack(3)
    fs:push({1.0, 2.0})
    fs:push({3.0, 4.0})
    local flat = fs:get()
    print("lurek.learning.frameStack capacity", fs:capacity())
    print("lurek.learning.frameStack flat len", #flat)
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
    print("lurek.learning.normalizeEnv obs[1]", obs[1])
    print("lurek.learning.normalizeEnv obs[2]", obs[2])
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
    print("lurek.learning.timeLimit type", limited:type())
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
    print("LEnv:reset obs len", #obs)
    print("LEnv:reset obs[1]", obs[1])
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
    print("LEnv:step obs[1]", obs[1])
    print("LEnv:step reward", reward)
    print("LEnv:step done", tostring(done))
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
    print("LEnv:obsSpace shape[1]", space.shape[1])
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
    print("LEnv:actionSpace n", space.n)
end

--@api: LEnv:type
do
    local env = lurek.learning.defineEnv({
        reset = function() return {0.0} end,
        step  = function(a) return {{0.0}, 0.0, false, {}} end,
        obs_space    = { shape = {1}, low = {0.0}, high = {1.0} },
        action_space = { n = 2 },
    })
    print("LEnv:type", env:type())
end

--@api: LEnv:typeOf
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

--@api: LFrameStack:push
do
    local fs = lurek.learning.frameStack(4)
    fs:push({0.1, 0.2})
    fs:push({0.3, 0.4})
    print("LFrameStack:push capacity", fs:capacity())
end

--@api: LFrameStack:get
do
    local fs = lurek.learning.frameStack(2)
    fs:push({1.0, 2.0})
    fs:push({3.0, 4.0})
    local flat = fs:get()
    print("LFrameStack:get len", #flat)
    print("LFrameStack:get first", flat[1])
end

--@api: LFrameStack:reset
do
    local fs = lurek.learning.frameStack(3)
    fs:push({1.0})
    fs:push({2.0})
    fs:reset()
    print("LFrameStack:reset capacity", fs:capacity())
end

--@api: LFrameStack:capacity
do
    local fs = lurek.learning.frameStack(5)
    print("LFrameStack:capacity", fs:capacity())
    print("owner type = " .. tostring(fs:type()))
end

--@api: LFrameStack:type
do
    local fs = lurek.learning.frameStack(3)
    print("LFrameStack:type", fs:type())
    print("typeOf LObject = " .. tostring(fs:typeOf("LObject")))
end

--@api: LFrameStack:typeOf
do
    local fs = lurek.learning.frameStack(3)
    print("LFrameStack:typeOf LFrameStack", tostring(fs:typeOf("LFrameStack")))
    print("LFrameStack:typeOf LObject", tostring(fs:typeOf("LObject")))
end

--@api: lurek.learning.newTensor
do
    local t = lurek.learning.newTensor({2, 3}, {1.0, 2.0, 3.0, 4.0, 5.0, 6.0})
    print("lurek.learning.newTensor type", t:type())
    print("lurek.learning.newTensor len", t:len())
end

--@api: lurek.learning.loadOnnx
do
    local ok, err = pcall(function()
        return lurek.learning.loadOnnx("nonexistent.onnx")
    end)
    print("lurek.learning.loadOnnx missing file errors", tostring(not ok))
end

--@api: LOnnxModel:run
do
    local model = lurek.learning.loadOnnx("content/examples/assets/minimal_identity.onnx")
    local input = lurek.learning.newTensor({1}, {42.0})
    local outputs = model:run({ input })
    print("LOnnxModel:run outputs", #outputs)
    print("LOnnxModel:run first value", outputs[1]:data()[1])
end

--@api: LOnnxModel:inputCount
do
    local model = lurek.learning.loadOnnx("content/examples/assets/minimal_identity.onnx")
    print("LOnnxModel:inputCount", model:inputCount())
    print("model type = " .. model:type())
end

--@api: LOnnxModel:outputCount
do
    local model = lurek.learning.loadOnnx("content/examples/assets/minimal_identity.onnx")
    print("LOnnxModel:outputCount", model:outputCount())
    print("model type = " .. model:type())
end

--@api: LOnnxModel:type
do
    local model = lurek.learning.loadOnnx("content/examples/assets/minimal_identity.onnx")
    print("LOnnxModel:type", model:type())
    print("typeOf LOnnxModel = " .. tostring(model:typeOf("LOnnxModel")))
end

--@api: LOnnxModel:typeOf
do
    local model = lurek.learning.loadOnnx("content/examples/assets/minimal_identity.onnx")
    print("LOnnxModel:typeOf LOnnxModel", tostring(model:typeOf("LOnnxModel")))
    print("LOnnxModel:type", model:type())
end

--@api: LTensor:shape
do
    local t = lurek.learning.newTensor({2, 3}, {1, 2, 3, 4, 5, 6})
    local s = t:shape()
    print("LTensor:shape rank", #s)
    print("LTensor:shape dim0", s[1])
end

--@api: LTensor:data
do
    local t = lurek.learning.newTensor({3}, {10.0, 20.0, 30.0})
    local d = t:data()
    print("LTensor:data len", #d)
    print("LTensor:data first", d[1])
end

--@api: LTensor:get
do
    local t = lurek.learning.newTensor({3}, {7.0, 8.0, 9.0})
    print("LTensor:get index1", t:get(1))
    print("LTensor:get index3", t:get(3))
end

--@api: LTensor:len
do
    local t = lurek.learning.newTensor({4}, {1.0, 2.0, 3.0, 4.0})
    print("LTensor:len", t:len())
    print("owner type = " .. tostring(t:type()))
end

--@api: LTensor:type
do
    local t = lurek.learning.newTensor({1}, {0.0})
    print("LTensor:type", t:type())
    print("typeOf LObject = " .. tostring(t:typeOf("LObject")))
end

--@api: LTensor:typeOf
do
    local t = lurek.learning.newTensor({1}, {0.0})
    print("LTensor:typeOf LTensor", tostring(t:typeOf("LTensor")))
    print("LTensor:typeOf LObject", tostring(t:typeOf("LObject")))
end

--@api: lurek.learning.wrap
do
    local qlearner = lurek.learning.newQLearner(4, 2)
    local model = lurek.learning.wrap(qlearner)
    print("wrapped model type = " .. model:type())
end

--@api: LBandit:predict
do
    local b = lurek.learning.newBandit(3, "ucb1", 0.1, 12345)
    local action = b:predict()
    print("bandit predict = " .. action)
end

--@api: LModel:predict
do
    local qlearner = lurek.learning.newQLearner(4, 2)
    local model = lurek.learning.wrap(qlearner)
    local action = model:predict(0)
    print("model predict = " .. action)
end

--@api: LModel:type
do
    local qlearner = lurek.learning.newQLearner(4, 2)
    local model = lurek.learning.wrap(qlearner)
    print("model type = " .. model:type())
end

--@api: LModel:typeOf
do
    local qlearner = lurek.learning.newQLearner(4, 2)
    local model = lurek.learning.wrap(qlearner)
    print("model typeOf LModel = " .. tostring(model:typeOf("LModel")))
end

--@api: LNeuralNet:predict
do
    local nn = lurek.learning.newNeuralNet()
    local action = nn:predict({0.5, 0.3})
    print("nn predict = " .. tostring(action))
end

--@api: LQLearner:predict
do
    local q = lurek.learning.newQLearner(4, 2)
    local action = q:predict(0)
    print("qlearner predict = " .. action)
end
