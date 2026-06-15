--- @title Dialog System
--- @desc Decision tree dialog with topics, branches, conditions, and speakers.

--@api: lurek.dialog.newAI
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("greeting", 1.0)
    print("lurek.dialog.newAI type=" .. ai:type())
    print("topics=" .. ai:getTopicCount())
end

--@api: lurek.dialog.newState
do
    local ds = lurek.dialog.newState()
    ds:start("greeting")
    print("lurek.dialog.newState type=" .. ds:type())
    print("active=" .. tostring(ds:isActive()))
end

--@api: lurek.dialog.newSpeakerRegistry
do
    local sr = lurek.dialog.newSpeakerRegistry()
    sr:add("guide", "Guide", "portraits/guide.png", "npc.guide")
    print("lurek.dialog.newSpeakerRegistry type=" .. sr:type())
    print("count=" .. sr:count())
end

--@api: LDialogueState:start
do
    local ds = lurek.dialog.newState()
    ds:start("intro")
    print("LDialogueState:start isActive=" .. tostring(ds:isActive()))
    print("current=" .. tostring(ds:current()))
end

--@api: LDialogueState:advance
do
    local ds = lurek.dialog.newState()
    ds:start("chat_intro")
    ds:advance("chat_reply")
    print("LDialogueState:advance current=" .. tostring(ds:current()))
end

--@api: LDialogueState:end_
do
    local ds = lurek.dialog.newState()
    ds:start("farewell")
    ds:end_()
    print("LDialogueState:end_ isActive=" .. tostring(ds:isActive()))
end

--@api: LDialogueState:current
do
    local ds = lurek.dialog.newState()
    ds:start("quest_offer")
    print("LDialogueState:current=" .. tostring(ds:current()))
end

--@api: LDialogueState:hasVisited
do
    local ds = lurek.dialog.newState()
    ds:start("info")
    ds:advance("bridge_warning")
    print("visited info=" .. tostring(ds:hasVisited("info")))
    print("visited bridge_warning=" .. tostring(ds:hasVisited("bridge_warning")))
end

--@api: LDialogueState:visitCount
do
    local ds = lurek.dialog.newState()
    ds:start("rumor_intro")
    ds:advance("rumor_detail")
    ds:advance("rumor_exit")
    print("LDialogueState:visitCount=" .. ds:visitCount())
end

--@api: LDialogueState:isActive
do
    local ds = lurek.dialog.newState()
    ds:start("greeting")
    print("LDialogueState:isActive=" .. tostring(ds:isActive()))
end

--@api: LDialogueState:setVariable
do
    local ds = lurek.dialog.newState()
    ds:setVariable("accepted", "no")
    print("LDialogueState:setVariable=" .. tostring(ds:getVariable("accepted")))
end

--@api: LDialogueState:getVariable
do
    local ds = lurek.dialog.newState()
    ds:setVariable("coins", "50")
    print("LDialogueState:getVariable=" .. tostring(ds:getVariable("coins")))
end

--@api: LDialogueState:reset
do
    local ds = lurek.dialog.newState()
    ds:start("cycle_a")
    ds:advance("cycle_b")
    ds:reset()
    print("LDialogueState:reset isActive=" .. tostring(ds:isActive()))
    print("visit count=" .. ds:visitCount())
end

--@api: LDialogueState:type
do
    local ds = lurek.dialog.newState()
    print("LDialogueState:type=" .. ds:type())
end

--@api: LDialogueState:typeOf
do
    local ds = lurek.dialog.newState()
    print("LDialogueState:typeOf LDialogueState=" .. tostring(ds:typeOf("LDialogueState")))
end

--@api: LSpeakerRegistry:add
do
    local sr = lurek.dialog.newSpeakerRegistry()
    sr:add("blacksmith", "Gordan", "gordan.png", "smith.voice")
    print("LSpeakerRegistry:add count=" .. sr:count())
end

--@api: LSpeakerRegistry:get
do
    local sr = lurek.dialog.newSpeakerRegistry()
    sr:add("guard", "Marcus")
    local spk = sr:get("guard")
    print("LSpeakerRegistry:get name=" .. tostring(spk and spk.name))
end

--@api: LSpeakerRegistry:remove
do
    local sr = lurek.dialog.newSpeakerRegistry()
    sr:add("temp", "Temp")
    sr:remove("temp")
    print("LSpeakerRegistry:remove count=" .. sr:count())
end

--@api: LSpeakerRegistry:count
do
    local sr = lurek.dialog.newSpeakerRegistry()
    sr:add("npc1", "Anna")
    sr:add("npc2", "Bob")
    print("LSpeakerRegistry:count=" .. sr:count())
end

--@api: LSpeakerRegistry:contains
do
    local sr = lurek.dialog.newSpeakerRegistry()
    sr:add("merchant", "Henri")
    print("LSpeakerRegistry:contains=" .. tostring(sr:contains("merchant")))
end

--@api: LSpeakerRegistry:type
do
    local sr = lurek.dialog.newSpeakerRegistry()
    print("LSpeakerRegistry:type=" .. sr:type())
end

--@api: LSpeakerRegistry:typeOf
do
    local sr = lurek.dialog.newSpeakerRegistry()
    print("LSpeakerRegistry:typeOf LSpeakerRegistry=" .. tostring(sr:typeOf("LSpeakerRegistry")))
end

--@api: LDialogueAI:addBranch
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("greeting", 1.0)
    local added = ai:addBranch("greeting", "hello_once", 2.0, "idle")
    print("LDialogueAI:addBranch ok=" .. tostring(added))
end

--@api: LDialogueAI:addTopic
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("weather", 0.5, "idle")
    print("LDialogueAI:addTopic count=" .. ai:getTopicCount())
end

--@api: LDialogueAI:clearUtilityScores
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("weather", 1.0, nil, nil, "weather_score")
    ai:setUtilityScore("weather_score", 0.9)
    ai:clearUtilityScores()
    print("LDialogueAI:clearUtilityScores ok")
    print("selected=" .. tostring(ai:selectTopic()))
end

--@api: LDialogueAI:getTopicCount
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("weather", 0.5)
    ai:addTopic("quest", 0.8)
    print("LDialogueAI:getTopicCount=" .. ai:getTopicCount())
end

--@api: LDialogueAI:selectBranch
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("friendly", 1.0, "idle")
    ai:addBranch("friendly", "weather_smalltalk", 1.0, "idle")
    ai:addBranch("friendly", "quest_prompt", 0.5, "idle")
    ai:setFSMState("idle")
    local branch = ai:selectBranch("friendly")
    print("LDialogueAI:selectBranch=" .. tostring(branch))
end

--@api: LDialogueAI:selectTopic
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("rumors", 0.7)
    ai:addTopic("trade", 1.0, nil, nil, "trade_score")
    ai:setUtilityScore("trade_score", 1.5)
    local topic = ai:selectTopic()
    print("LDialogueAI:selectTopic=" .. tostring(topic))
end

--@api: LDialogueAI:setBTStatus
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("combat_bark", 1.0, nil, "running")
    ai:setBTStatus("running")
    print("LDialogueAI:setBTStatus ok")
    print("selected=" .. tostring(ai:selectTopic()))
end

--@api: LDialogueAI:setFSMState
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("shop", 1.0, "shop")
    ai:setFSMState("shop")
    print("LDialogueAI:setFSMState ok")
    print("selected=" .. tostring(ai:selectTopic()))
end

--@api: LDialogueAI:setUtilityScore
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("danger", 0.3, nil, nil, "danger")
    ai:setUtilityScore("danger", 0.95)
    local topic = ai:selectTopic()
    print("LDialogueAI:setUtilityScore topic=" .. tostring(topic))
end

--@api: LDialogueAI:type
do
    local ai = lurek.dialog.newAI()
    print("LDialogueAI:type=" .. ai:type())
end

--@api: LDialogueAI:typeOf
do
    local ai = lurek.dialog.newAI()
    print("LDialogueAI:typeOf LDialogueAI=" .. tostring(ai:typeOf("LDialogueAI")))
end

--@api: lurek.dialog.newSequencer
do
    local seq = lurek.dialog.newSequencer()
    print("lurek.dialog.newSequencer type=" .. seq:type())
    print("state=" .. seq:getState())
end

--@api: lurek.dialog.say
do
    local node = lurek.dialog.say("Hero", "I'm ready!")
    print("lurek.dialog.say type=" .. node.type)
    print("actor=" .. node.actor)
    print("text=" .. node.text)
end

--@api: lurek.dialog.choice
do
    local node = lurek.dialog.choice("What do you do?", {"Fight", "Flee", "Talk"})
    print("lurek.dialog.choice type=" .. node.type)
    print("prompt=" .. node.prompt)
    print("options=" .. #node.options)
end

--@api: lurek.dialog.wait
do
    local node = lurek.dialog.wait(3.0)
    print("lurek.dialog.wait type=" .. node.type)
    print("seconds=" .. node.seconds)
end

--@api: lurek.dialog.event
do
    local node = lurek.dialog.event("combat_end", "victory")
    print("lurek.dialog.event type=" .. node.type)
    print("name=" .. node.name)
    print("data=" .. tostring(node.data))
end

--@api: lurek.dialog.call
do
    local node = lurek.dialog.call("on_quest_accepted")
    print("lurek.dialog.call type=" .. node.type)
    print("name=" .. node.name)
end

--@api: lurek.dialog.jump
do
    local node = lurek.dialog.jump("ending_good")
    print("lurek.dialog.jump type=" .. node.type)
    print("target=" .. node.target)
end

--@api: LDialogSequencer:load
do
    local seq = lurek.dialog.newSequencer()
    local nodes = {
        lurek.dialog.say("NPC", "Hello there!"),
        lurek.dialog.choice("How are you?", {"Good", "Bad"})
    }
    seq:load(nodes)
    print("LDialogSequencer:load ok")
end

--@api: LDialogSequencer:start
do
    local seq = lurek.dialog.newSequencer()
    seq:load({ lurek.dialog.say("NPC", "Beginning...") })
    seq:start()
    print("LDialogSequencer:start state=" .. seq:getState())
end

--@api: LDialogSequencer:update
do
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(10.0)
    seq:load({ lurek.dialog.say("NPC", "Hello") })
    seq:start()
    seq:update(0.15)
    print("LDialogSequencer:update revealed=" .. seq:revealedText())
end

--@api: LDialogSequencer:advance
do
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(1.0)
    seq:load({
        lurek.dialog.say("NPC", "Line one"),
        lurek.dialog.say("NPC", "Line two")
    })
    seq:start()
    seq:advance()
    seq:advance()
    print("LDialogSequencer:advance text=" .. seq:currentText())
end

--@api: LDialogSequencer:skip
do
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(1.0)
    seq:load({ lurek.dialog.say("NPC", "Instant reveal") })
    seq:start()
    seq:skip()
    print("LDialogSequencer:skip revealed=" .. seq:revealedText())
end

--@api: LDialogSequencer:choose
do
    local seq = lurek.dialog.newSequencer()
    seq:load({
        lurek.dialog.choice("Pick one:", {"A", "B", "C"}),
        lurek.dialog.say("NPC", "You picked!")
    })
    seq:start()
    seq:choose(2)
    print("LDialogSequencer:choose state=" .. seq:getState())
end

--@api: LDialogSequencer:setSpeed
do
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(50.0)
    print("LDialogSequencer:setSpeed speed=" .. seq:getSpeed())
end

--@api: LDialogSequencer:getSpeed
do
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(25.0)
    print("LDialogSequencer:getSpeed=" .. seq:getSpeed())
end

--@api: LDialogSequencer:getState
do
    local seq = lurek.dialog.newSequencer()
    seq:load({ lurek.dialog.say("NPC", "Text") })
    seq:start()
    print("LDialogSequencer:getState=" .. seq:getState())
end

--@api: LDialogSequencer:isActive
do
    local seq = lurek.dialog.newSequencer()
    print("idle active=" .. tostring(seq:isActive()))
    seq:load({ lurek.dialog.say("NPC", "Started") })
    seq:start()
    print("started active=" .. tostring(seq:isActive()))
end

--@api: LDialogSequencer:isWaitingForChoice
do
    local seq = lurek.dialog.newSequencer()
    seq:load({ lurek.dialog.choice("Pick:", {"Yes", "No"}) })
    seq:start()
    print("LDialogSequencer:isWaitingForChoice=" .. tostring(seq:isWaitingForChoice()))
end

--@api: LDialogSequencer:currentSpeaker
do
    local seq = lurek.dialog.newSequencer()
    seq:load({ lurek.dialog.say("Warrior", "At last!") })
    seq:start()
    print("LDialogSequencer:currentSpeaker=" .. tostring(seq:currentSpeaker()))
end

--@api: LDialogSequencer:currentText
do
    local seq = lurek.dialog.newSequencer()
    seq:load({ lurek.dialog.say("NPC", "The full line here") })
    seq:start()
    print("LDialogSequencer:currentText=" .. seq:currentText())
end

--@api: LDialogSequencer:revealedText
do
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(5.0)
    seq:load({ lurek.dialog.say("NPC", "Slowly revealed") })
    seq:start()
    seq:update(0.2)
    print("LDialogSequencer:revealedText=" .. seq:revealedText())
end

--@api: LDialogSequencer:getChoiceText
do
    local seq = lurek.dialog.newSequencer()
    seq:load({ lurek.dialog.choice("Your move?", {"Attack", "Defend"}) })
    seq:start()
    print("LDialogSequencer:getChoiceText=" .. tostring(seq:getChoiceText()))
end

--@api: LDialogSequencer:getChoiceLabels
do
    local seq = lurek.dialog.newSequencer()
    seq:load({ lurek.dialog.choice("Pick:", {"Option A", "Option B", "Option C"}) })
    seq:start()
    local labels = seq:getChoiceLabels()
    print("LDialogSequencer:getChoiceLabels count=" .. #labels)
    print("first=" .. labels[1])
end

--@api: LDialogSequencer:type
do
    local seq = lurek.dialog.newSequencer()
    print("LDialogSequencer:type=" .. seq:type())
end

--@api: LDialogSequencer:typeOf
do
    local seq = lurek.dialog.newSequencer()
    print("LDialogSequencer:typeOf LDialogSequencer=" .. tostring(seq:typeOf("LDialogSequencer")))
end
