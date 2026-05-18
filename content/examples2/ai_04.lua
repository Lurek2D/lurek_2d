--- AI Examples Part 4: Squad (cont.), Command Queue, Trait Profile, Stimulus World, Context Steering, Need System

--@api-stub: LSquad:getFormation
-- Returns the current formation type name.
do
    local sq = lurek.ai.newSquad("recon")
    sq:setFormation("line", 3.0)
    local f = sq:getFormation()
    print("formation = " .. f)
end

--@api-stub: LSquad:getFormationSpacing
-- Returns the spacing value used between formation positions.
do
    local sq = lurek.ai.newSquad("assault")
    sq:setFormation("wedge", 2.5)
    local s = sq:getFormationSpacing()
    print("spacing = " .. s)
end

--@api-stub: LSquad:getFormationPosition
-- Computes the world position for a member given the leader position and formation.
do
    local sq = lurek.ai.newSquad("patrol")
    sq:addMember("lead")
    sq:addMember("flank_l")
    sq:addMember("flank_r")
    sq:setFormation("wedge", 2.0)
    local x, y = sq:getFormationPosition(2, 100.0, 50.0)
    print("member 2 pos = " .. x .. ", " .. y)
end

--@api-stub: LSquad:getBlackboard
-- Returns the squad-level shared blackboard for coordination data.
do
    local sq = lurek.ai.newSquad("intel")
    local bb = sq:getBlackboard()
    bb:setNumber("threat_level", 3)
    print("squad bb threat = " .. bb:getNumber("threat_level"))
end

--@api-stub: LSquad:type
-- Returns the type name string "LSquad".
do
    local sq = lurek.ai.newSquad("test")
    print("type = " .. sq:type())
end

--@api-stub: LSquad:typeOf
-- Checks whether this object is of the given type name.
do
    local sq = lurek.ai.newSquad("test2")
    print("is LSquad = " .. tostring(sq:typeOf("LSquad")))
end

--@api-stub: LCommandQueue:enqueue
-- Adds a command to the back of the queue with a type label and callback.
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("move", function() print("  moving") end, { targetX = 10, targetY = 20 })
    cq:enqueue("attack", function() print("  attacking") end)
    print("queue size = " .. cq:getCount())
end

--@api-stub: LCommandQueue:pushFront
-- Inserts a command at the front of the queue (executes next).
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("patrol", function() end)
    cq:pushFront("dodge", function() print("  dodging") end)
    print("next type = " .. cq:getCurrentType())
end

--@api-stub: LCommandQueue:replace
-- Replaces all queued commands with a single new one.
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("idle", function() end)
    cq:enqueue("gather", function() end)
    cq:replace("retreat", function() print("  retreating") end)
    print("after replace count = " .. cq:getCount())
end

--@api-stub: LCommandQueue:cancelCurrent
-- Removes the currently executing (front) command from the queue.
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("walk", function() end)
    cq:enqueue("talk", function() end)
    cq:cancelCurrent()
    print("after cancel, type = " .. tostring(cq:getCurrentType()))
end

--@api-stub: LCommandQueue:clear
-- Removes all commands from the queue.
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("a", function() end)
    cq:enqueue("b", function() end)
    cq:clear()
    print("after clear, empty = " .. tostring(cq:isEmpty()))
end

--@api-stub: LCommandQueue:getCount
-- Returns the number of commands currently queued.
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("x", function() end)
    cq:enqueue("y", function() end)
    cq:enqueue("z", function() end)
    print("count = " .. cq:getCount())
end

--@api-stub: LCommandQueue:isEmpty
-- Returns true if the queue has no commands.
do
    local cq = lurek.ai.newCommandQueue()
    print("empty initially = " .. tostring(cq:isEmpty()))
    cq:enqueue("step", function() end)
    print("empty after enqueue = " .. tostring(cq:isEmpty()))
end

--@api-stub: LCommandQueue:getCurrentType
-- Returns the type label of the front command, or nil if empty.
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("harvest", function() end)
    print("current type = " .. tostring(cq:getCurrentType()))
end

--@api-stub: LCommandQueue:getCurrentTarget
-- Returns the target table of the front command, if set via opts.
do
    local cq = lurek.ai.newCommandQueue()
    cq:enqueue("go", function() end, { targetX = 5, targetY = 10 })
    local tgt = cq:getCurrentTarget()
    print("target = " .. tostring(tgt))
end

--@api-stub: LCommandQueue:type
-- Returns the type name string "LCommandQueue".
do
    local cq = lurek.ai.newCommandQueue()
    print("type = " .. cq:type())
end

--@api-stub: LCommandQueue:typeOf
-- Checks whether this object is of the given type name.
do
    local cq = lurek.ai.newCommandQueue()
    print("is LCommandQueue = " .. tostring(cq:typeOf("LCommandQueue")))
end

--@api-stub: LTraitProfile:set
-- Sets the base value of a named trait.
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("courage", 0.7)
    tp:set("aggression", 0.3)
    print("courage = " .. tp:get("courage"))
end

--@api-stub: LTraitProfile:get
-- Returns the effective value of a trait (base + active modifiers).
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("speed", 1.0)
    tp:addModifier("speed", 0.5, 5.0, "buff")
    local effective = tp:get("speed")
    print("effective speed = " .. effective)
end

--@api-stub: LTraitProfile:getBase
-- Returns the base value of a trait, ignoring modifiers.
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("strength", 0.8)
    tp:addModifier("strength", 0.2, 10.0, "potion")
    print("base strength = " .. tp:getBase("strength"))
end

--@api-stub: LTraitProfile:addModifier
-- Adds a temporary modifier to a trait that expires after a duration.
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("defense", 0.5)
    tp:addModifier("defense", 0.3, 8.0, "shield_spell")
    print("defense with modifier = " .. tp:get("defense"))
end

--@api-stub: LTraitProfile:removeModifiers
-- Removes all modifiers from a given source.
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("luck", 0.4)
    tp:addModifier("luck", 0.2, 10.0, "charm")
    tp:addModifier("luck", 0.1, 5.0, "charm")
    tp:removeModifiers("charm")
    print("luck after remove = " .. tp:get("luck"))
end

--@api-stub: LTraitProfile:update
-- Advances time, expiring modifiers whose duration has elapsed.
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("rage", 0.5)
    tp:addModifier("rage", 0.5, 2.0, "berserk")
    tp:update(3.0)
    print("rage after 3s = " .. tp:get("rage"))
end

--@api-stub: LTraitProfile:has
-- Returns true if a trait with the given name exists.
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("wisdom", 0.6)
    print("has wisdom = " .. tostring(tp:has("wisdom")))
    print("has charm = " .. tostring(tp:has("charm")))
end

--@api-stub: LTraitProfile:traitCount
-- Returns the number of defined traits.
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("a", 0.1)
    tp:set("b", 0.2)
    tp:set("c", 0.3)
    print("trait count = " .. tp:traitCount())
end

--@api-stub: LTraitProfile:archetype
-- Returns a string label describing the dominant trait pattern.
do
    local tp = lurek.ai.newTraitProfile()
    tp:set("aggression", 0.9)
    tp:set("caution", 0.1)
    tp:set("curiosity", 0.4)
    local arch = tp:archetype()
    print("archetype = " .. arch)
end

--@api-stub: LTraitProfile:type
-- Returns the type name string "LTraitProfile".
do
    local tp = lurek.ai.newTraitProfile()
    print("type = " .. tp:type())
end

--@api-stub: LTraitProfile:typeOf
-- Checks whether this object is of the given type name.
do
    local tp = lurek.ai.newTraitProfile()
    print("is LTraitProfile = " .. tostring(tp:typeOf("LTraitProfile")))
end

--@api-stub: LStimulusWorld:addVisual
-- Adds a visual stimulus at a position with intensity, radius, and tag.
do
    local sw = lurek.ai.newStimulusWorld()
    local id = sw:addVisual(100, 200, 0.8, 50.0, "enemy_spotted")
    print("visual stimulus id = " .. id)
end

--@api-stub: LStimulusWorld:addAuditory
-- Adds an auditory stimulus at a position with intensity, radius, decay, and tag.
do
    local sw = lurek.ai.newStimulusWorld()
    local id = sw:addAuditory(50, 80, 0.6, 30.0, 0.1, "footstep")
    print("auditory stimulus id = " .. id)
end

--@api-stub: LStimulusWorld:remove
-- Removes a stimulus by its ID.
do
    local sw = lurek.ai.newStimulusWorld()
    local id = sw:addVisual(10, 10, 1.0, 20.0, "flash")
    sw:remove(id)
    print("removed stimulus, count = " .. sw:count())
end

--@api-stub: LStimulusWorld:update
-- Advances time, decaying auditory stimuli and removing expired ones.
do
    local sw = lurek.ai.newStimulusWorld()
    sw:addAuditory(0, 0, 1.0, 10.0, 0.5, "bang")
    sw:update(5.0)
    print("after update, count = " .. sw:count())
end

--@api-stub: LStimulusWorld:count
-- Returns the number of active stimuli.
do
    local sw = lurek.ai.newStimulusWorld()
    sw:addVisual(0, 0, 1.0, 10.0, "a")
    sw:addVisual(5, 5, 0.5, 8.0, "b")
    print("stimulus count = " .. sw:count())
end

--@api-stub: LStimulusWorld:clear
-- Removes all stimuli.
do
    local sw = lurek.ai.newStimulusWorld()
    sw:addVisual(0, 0, 1.0, 10.0, "x")
    sw:addAuditory(1, 1, 0.5, 5.0, 0.2, "y")
    sw:clear()
    print("after clear, count = " .. sw:count())
end

--@api-stub: LStimulusWorld:type
-- Returns the type name string "LStimulusWorld".
do
    local sw = lurek.ai.newStimulusWorld()
    print("type = " .. sw:type())
end

--@api-stub: LStimulusWorld:typeOf
-- Checks whether this object is of the given type name.
do
    local sw = lurek.ai.newStimulusWorld()
    print("is LStimulusWorld = " .. tostring(sw:typeOf("LStimulusWorld")))
end

--@api-stub: LContextSteering:addSeekTarget
-- Adds a seek interest toward a world position with a weight.
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addSeekTarget(200, 150, 1.0)
    print("seek target added at (200, 150)")
end

--@api-stub: LContextSteering:addWander
-- Adds a random wander interest with jitter and weight.
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addWander(0.3, 0.5)
    print("wander behavior added")
end

--@api-stub: LContextSteering:addAvoidPoint
-- Adds a danger signal around a point with radius and weight.
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addAvoidPoint(50, 50, 20.0, 1.5)
    print("avoid point at (50, 50) radius 20")
end

--@api-stub: LContextSteering:addAvoidBounds
-- Adds a rectangular boundary avoidance with a margin.
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addAvoidBounds(0, 0, 800, 600, 30.0, 1.0)
    print("avoid bounds set for 800x600 area")
end

--@api-stub: LContextSteering:clearBehaviors
-- Removes all registered interest and danger behaviors.
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addSeekTarget(100, 100, 1.0)
    cs:addAvoidPoint(50, 50, 10.0, 1.0)
    cs:clearBehaviors()
    print("behaviors cleared")
end

--@api-stub: LContextSteering:evaluate
-- Evaluates all behaviors and returns the chosen steering direction.
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addSeekTarget(300, 200, 1.0)
    cs:addAvoidPoint(150, 150, 30.0, 2.0)
    local dx, dy = cs:evaluate(100, 100, 1.0, 0.0)
    print("direction = " .. dx .. ", " .. dy)
end

--@api-stub: LContextSteering:chosenMagnitude
-- Returns the magnitude of the last evaluated steering direction.
do
    local cs = lurek.ai.newContextSteering(8)
    cs:addSeekTarget(200, 200, 1.0)
    cs:evaluate(0, 0, 0, 0)
    local mag = cs:chosenMagnitude()
    print("magnitude = " .. mag)
end

--@api-stub: LContextSteering:slotCount
-- Returns the number of directional slots in this context map.
do
    local cs = lurek.ai.newContextSteering(16)
    print("slots = " .. cs:slotCount())
end

--@api-stub: LContextSteering:type
-- Returns the type name string "LContextSteering".
do
    local cs = lurek.ai.newContextSteering(8)
    print("type = " .. cs:type())
end

--@api-stub: LContextSteering:typeOf
-- Checks whether this object is of the given type name.
do
    local cs = lurek.ai.newContextSteering(8)
    print("is LContextSteering = " .. tostring(cs:typeOf("LContextSteering")))
end

--@api-stub: LNeedSystem:addNeed
-- Registers a need with a decay rate, urgency threshold, and urgency factor.
do
    local ns = lurek.ai.newNeedSystem()
    ns:addNeed("hunger", 0.1, 0.7, 2.0)
    ns:addNeed("thirst", 0.15, 0.6, 1.5)
    print("needs registered")
end

--@api-stub: LNeedSystem:update
-- Advances time, applying decay to all needs.
do
    local ns = lurek.ai.newNeedSystem()
    ns:addNeed("fatigue", 0.05, 0.8, 1.0)
    ns:update(2.0)
    local urgent = ns:mostUrgent()
    print("most urgent after 2s = " .. tostring(urgent))
end

--@api-stub: LNeedSystem:mostUrgent
-- Returns the name of the most urgent need, or nil if none are urgent.
do
    local ns = lurek.ai.newNeedSystem()
    ns:addNeed("hunger", 0.5, 0.3, 2.0)
    ns:update(1.0)
    local name = ns:mostUrgent()
    print("most urgent = " .. tostring(name))
end

--@api-stub: LNeedSystem:satisfy
-- Satisfies a need by the given amount, reducing its value.
do
    local ns = lurek.ai.newNeedSystem()
    ns:addNeed("thirst", 0.2, 0.5, 1.5)
    ns:update(3.0)
    ns:satisfy("thirst", 0.8)
    print("thirst satisfied")
end

print("ai_04.lua")
