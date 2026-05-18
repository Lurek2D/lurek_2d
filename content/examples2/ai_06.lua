--- AI Examples Part 6: Genetic Algorithm (cont.), Bandit, Neuroevolution, Strategy AI, AI LOD

--@api-stub: LGeneticAlgorithm:popSize
-- Returns the population size.
do
    local ga = lurek.ai.newGeneticAlgorithm(20, 6, 99)
    print("pop size = " .. ga:popSize())
end

--@api-stub: LGeneticAlgorithm:setFitness
-- Sets the fitness value for a chromosome by zero-based index.
do
    local ga = lurek.ai.newGeneticAlgorithm(5, 3, 0)
    ga:setFitness(0, 10.0)
    ga:setFitness(1, 5.0)
    ga:setFitness(2, 8.0)
    print("fitness set for 3 chromosomes")
end

--@api-stub: LGeneticAlgorithm:getGenes
-- Returns the gene array for a chromosome by zero-based index.
do
    local ga = lurek.ai.newGeneticAlgorithm(4, 3, 42)
    local genes = ga:getGenes(0)
    print("genes[0] length = " .. #genes)
end

--@api-stub: LGeneticAlgorithm:bestGenes
-- Returns the gene array of the chromosome with the highest fitness.
do
    local ga = lurek.ai.newGeneticAlgorithm(5, 4, 7)
    for i = 0, 4 do
        ga:setFitness(i, i * 2.0)
    end
    ga:evolve()
    local best = ga:bestGenes()
    print("best genes length = " .. #best)
end

--@api-stub: LGeneticAlgorithm:type
-- Returns the type name string "LGeneticAlgorithm".
do
    local ga = lurek.ai.newGeneticAlgorithm(4, 2, 0)
    print("type = " .. ga:type())
end

--@api-stub: LGeneticAlgorithm:typeOf
-- Checks whether this object is of the given type name.
do
    local ga = lurek.ai.newGeneticAlgorithm(4, 2, 0)
    print("is LGeneticAlgorithm = " .. tostring(ga:typeOf("LGeneticAlgorithm")))
end

--@api-stub: LBandit:select
-- Selects an arm index using the configured strategy (e.g. epsilon-greedy, UCB1).
do
    local b = lurek.ai.newBandit(4, "epsilon_greedy", 0.1, 42)
    local arm = b:select()
    print("selected arm = " .. arm)
end

--@api-stub: LBandit:update
-- Updates the reward estimate for an arm after observing a result.
do
    local b = lurek.ai.newBandit(3, "ucb1", 0.0, 0)
    local arm = b:select()
    b:update(arm, 1.0)
    print("updated arm " .. arm .. " with reward 1.0")
end

--@api-stub: LBandit:bestArm
-- Returns the arm index with the highest estimated reward.
do
    local b = lurek.ai.newBandit(3, "epsilon_greedy", 0.0, 10)
    b:update(0, 0.5)
    b:update(1, 0.9)
    b:update(2, 0.3)
    print("best arm = " .. b:bestArm())
end

--@api-stub: LBandit:reset
-- Resets all arm statistics to initial state.
do
    local b = lurek.ai.newBandit(3, "epsilon_greedy", 0.1, 0)
    b:update(0, 1.0)
    b:update(1, 0.5)
    b:reset()
    print("total pulls after reset = " .. b:totalPulls())
end

--@api-stub: LBandit:armCount
-- Returns the number of arms in the bandit.
do
    local b = lurek.ai.newBandit(5, "ucb1", 0.0, 0)
    print("arm count = " .. b:armCount())
end

--@api-stub: LBandit:totalPulls
-- Returns the total number of arm selections made so far.
do
    local b = lurek.ai.newBandit(3, "epsilon_greedy", 0.1, 0)
    b:select()
    b:select()
    b:select()
    print("total pulls = " .. b:totalPulls())
end

--@api-stub: LBandit:type
-- Returns the type name string "LBandit".
do
    local b = lurek.ai.newBandit(2, "ucb1", 0.0, 0)
    print("type = " .. b:type())
end

--@api-stub: LBandit:typeOf
-- Checks whether this object is of the given type name.
do
    local b = lurek.ai.newBandit(2, "ucb1", 0.0, 0)
    print("is LBandit = " .. tostring(b:typeOf("LBandit")))
end

--@api-stub: LNeuroevolution:evolve
-- Runs one generation of selection, crossover, and mutation on the population.
do
    local ne = lurek.ai.newNeuroevolution(
        { { inputs = 2, outputs = 3, activation = "relu" }, { inputs = 3, outputs = 1, activation = "sigmoid" } },
        10, 42
    )
    for i = 0, 9 do
        ne:setFitness(i, math.random())
    end
    ne:evolve()
    print("evolved to gen " .. ne:generation())
end

--@api-stub: LNeuroevolution:setFitness
-- Sets the fitness value for a chromosome by zero-based index.
do
    local ne = lurek.ai.newNeuroevolution(
        { { inputs = 2, outputs = 2 } }, 5, 0
    )
    ne:setFitness(0, 10.0)
    ne:setFitness(4, 5.0)
    print("fitness assigned to chromosomes 0 and 4")
end

--@api-stub: LNeuroevolution:chromosomeToNet
-- Converts a chromosome into a usable neural network handle.
do
    local ne = lurek.ai.newNeuroevolution(
        { { inputs = 3, outputs = 2, activation = "relu" } }, 4, 7
    )
    local net = ne:chromosomeToNet(0)
    if net then
        print("network created from chromosome 0")
    end
end

--@api-stub: LNeuroevolution:bestNetwork
-- Returns the neural network of the best-performing chromosome.
do
    local ne = lurek.ai.newNeuroevolution(
        { { inputs = 2, outputs = 1 } }, 6, 0
    )
    for i = 0, 5 do ne:setFitness(i, i * 1.5) end
    ne:evolve()
    local best = ne:bestNetwork()
    print("best network obtained = " .. tostring(best ~= nil))
end

--@api-stub: LNeuroevolution:bestFitness
-- Returns the highest fitness value in the current population.
do
    local ne = lurek.ai.newNeuroevolution(
        { { inputs = 2, outputs = 1 } }, 4, 0
    )
    ne:setFitness(0, 3.0)
    ne:setFitness(1, 7.0)
    ne:setFitness(2, 5.0)
    ne:setFitness(3, 1.0)
    print("best fitness = " .. ne:bestFitness())
end

--@api-stub: LNeuroevolution:popSize
-- Returns the population size.
do
    local ne = lurek.ai.newNeuroevolution(
        { { inputs = 1, outputs = 1 } }, 12, 0
    )
    print("pop size = " .. ne:popSize())
end

--@api-stub: LNeuroevolution:generation
-- Returns the current generation number.
do
    local ne = lurek.ai.newNeuroevolution(
        { { inputs = 1, outputs = 1 } }, 4, 0
    )
    print("initial generation = " .. ne:generation())
end

--@api-stub: LNeuroevolution:type
-- Returns the type name string "LNeuroevolution".
do
    local ne = lurek.ai.newNeuroevolution(
        { { inputs = 1, outputs = 1 } }, 4, 0
    )
    print("type = " .. ne:type())
end

--@api-stub: LNeuroevolution:typeOf
-- Checks whether this object is of the given type name.
do
    local ne = lurek.ai.newNeuroevolution(
        { { inputs = 1, outputs = 1 } }, 4, 0
    )
    print("is LNeuroevolution = " .. tostring(ne:typeOf("LNeuroevolution")))
end

--@api-stub: LStrategyAI:addGoal
-- Registers a named strategic goal for evaluation.
do
    local strat = lurek.ai.newStrategyAI(5.0)
    strat:addGoal("expand")
    strat:addGoal("defend")
    strat:addGoal("research")
    print("goals registered")
end

--@api-stub: LStrategyAI:addTag
-- Adds a tag that can influence goal scoring logic.
do
    local strat = lurek.ai.newStrategyAI(3.0)
    strat:addTag("war_declared")
    strat:addTag("low_resources")
    print("tags added")
end

--@api-stub: LStrategyAI:removeTag
-- Removes a previously added tag.
do
    local strat = lurek.ai.newStrategyAI(3.0)
    strat:addTag("peace")
    strat:removeTag("peace")
    print("tag removed")
end

--@api-stub: LStrategyAI:update
-- Advances time; when the update interval elapses, scores all goals and picks the best.
do
    local strat = lurek.ai.newStrategyAI(1.0)
    strat:addGoal("attack")
    strat:addGoal("retreat")
    strat:update(1.5, function(goal)
        if goal == "attack" then return 0.8 end
        return 0.2
    end)
    print("active = " .. tostring(strat:activeGoal()))
end

--@api-stub: LStrategyAI:forceEvaluate
-- Forces immediate goal evaluation regardless of the update interval.
do
    local strat = lurek.ai.newStrategyAI(10.0)
    strat:addGoal("build")
    strat:addGoal("scout")
    strat:forceEvaluate(function(goal)
        if goal == "scout" then return 5.0 end
        return 1.0
    end)
    print("forced active = " .. tostring(strat:activeGoal()))
end

--@api-stub: LStrategyAI:activeGoal
-- Returns the name of the currently active goal, or nil if none.
do
    local strat = lurek.ai.newStrategyAI(1.0)
    strat:addGoal("idle")
    local active = strat:activeGoal()
    print("active goal = " .. tostring(active))
end

--@api-stub: LStrategyAI:timeUntilNext
-- Returns seconds remaining until the next scheduled evaluation.
do
    local strat = lurek.ai.newStrategyAI(5.0)
    strat:addGoal("wait")
    strat:update(2.0, function() return 1.0 end)
    print("time until next = " .. strat:timeUntilNext())
end

--@api-stub: LStrategyAI:type
-- Returns the type name string "LStrategyAI".
do
    local strat = lurek.ai.newStrategyAI(1.0)
    print("type = " .. strat:type())
end

--@api-stub: LStrategyAI:typeOf
-- Checks whether this object is of the given type name.
do
    local strat = lurek.ai.newStrategyAI(1.0)
    print("is LStrategyAI = " .. tostring(strat:typeOf("LStrategyAI")))
end

--@api-stub: LAILod:tierFor
-- Returns the LOD tier for an agent at a given distance from the reference position.
do
    local lod = lurek.ai.newAILod()
    local tier = lod:tierFor(100, 200, 0, 0)
    print("tier = " .. tier)
end

--@api-stub: LAILod:shouldUpdate
-- Returns true if a tier should run AI logic on the given frame.
do
    local lod = lurek.ai.newAILod()
    local run = lod:shouldUpdate(0, 1)
    print("tier 0 should update on frame 1 = " .. tostring(run))
end

--@api-stub: LAILod:tierCount
-- Returns the number of defined LOD tiers.
do
    local lod = lurek.ai.newAILod()
    print("tier count = " .. lod:tierCount())
end

--@api-stub: LAILod:tierName
-- Returns the name of a tier by zero-based index.
do
    local lod = lurek.ai.newAILod()
    local name = lod:tierName(0)
    print("tier 0 name = " .. name)
end

--@api-stub: LAILod:type
-- Returns the type name string "LAILod".
do
    local lod = lurek.ai.newAILod()
    print("type = " .. lod:type())
end

--@api-stub: LAILod:typeOf
-- Checks whether this object is of the given type name.
do
    local lod = lurek.ai.newAILod()
    print("is LAILod = " .. tostring(lod:typeOf("LAILod")))
end

print("ai_06.lua")
