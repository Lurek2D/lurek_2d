--- @title Dialog System
--- @desc Decision tree dialog with topics, branches, conditions, and speakers.

--@api-stub: lurek.dialog.newAI
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("greeting", 1.0)
    print("lurek.dialog.newAI type=" .. ai:type())
    print("topics=" .. ai:getTopicCount())
end

--@api-stub: lurek.dialog.newState
do
    local ds = lurek.dialog.newState()
    ds:start("greeting")
    print("lurek.dialog.newState type=" .. ds:type())
    print("active=" .. tostring(ds:isActive()))
end

--@api-stub: lurek.dialog.newSpeakerRegistry
do
    local sr = lurek.dialog.newSpeakerRegistry()
    sr:add("guide", "Guide", "portraits/guide.png", "npc.guide")
    print("lurek.dialog.newSpeakerRegistry type=" .. sr:type())
    print("count=" .. sr:count())
end

--@api-stub: LDialogueState:start
do
    local ds = lurek.dialog.newState()
    ds:start("intro")
    print("LDialogueState:start isActive=" .. tostring(ds:isActive()))
    print("current=" .. tostring(ds:current()))
end

--@api-stub: LDialogueState:advance
do
    local ds = lurek.dialog.newState()
    ds:start("chat_intro")
    ds:advance("chat_reply")
    print("LDialogueState:advance current=" .. tostring(ds:current()))
end

--@api-stub: LDialogueState:end_
do
    local ds = lurek.dialog.newState()
    ds:start("farewell")
    ds:end_()
    print("LDialogueState:end_ isActive=" .. tostring(ds:isActive()))
end

--@api-stub: LDialogueState:current
do
    local ds = lurek.dialog.newState()
    ds:start("quest_offer")
    print("LDialogueState:current=" .. tostring(ds:current()))
end

--@api-stub: LDialogueState:hasVisited
do
    local ds = lurek.dialog.newState()
    ds:start("info")
    ds:advance("bridge_warning")
    print("visited info=" .. tostring(ds:hasVisited("info")))
    print("visited bridge_warning=" .. tostring(ds:hasVisited("bridge_warning")))
end

--@api-stub: LDialogueState:visitCount
do
    local ds = lurek.dialog.newState()
    ds:start("rumor_intro")
    ds:advance("rumor_detail")
    ds:advance("rumor_exit")
    print("LDialogueState:visitCount=" .. ds:visitCount())
end

--@api-stub: LDialogueState:isActive
do
    local ds = lurek.dialog.newState()
    ds:start("greeting")
    print("LDialogueState:isActive=" .. tostring(ds:isActive()))
end

--@api-stub: LDialogueState:setVariable
do
    local ds = lurek.dialog.newState()
    ds:setVariable("accepted", "no")
    print("LDialogueState:setVariable=" .. tostring(ds:getVariable("accepted")))
end

--@api-stub: LDialogueState:getVariable
do
    local ds = lurek.dialog.newState()
    ds:setVariable("coins", "50")
    print("LDialogueState:getVariable=" .. tostring(ds:getVariable("coins")))
end

--@api-stub: LDialogueState:reset
do
    local ds = lurek.dialog.newState()
    ds:start("cycle_a")
    ds:advance("cycle_b")
    ds:reset()
    print("LDialogueState:reset isActive=" .. tostring(ds:isActive()))
    print("visit count=" .. ds:visitCount())
end

--@api-stub: LDialogueState:type
do
    local ds = lurek.dialog.newState()
    print("LDialogueState:type=" .. ds:type())
end

--@api-stub: LDialogueState:typeOf
do
    local ds = lurek.dialog.newState()
    print("LDialogueState:typeOf LDialogueState=" .. tostring(ds:typeOf("LDialogueState")))
end

--@api-stub: LSpeakerRegistry:add
do
    local sr = lurek.dialog.newSpeakerRegistry()
    sr:add("blacksmith", "Gordan", "gordan.png", "smith.voice")
    print("LSpeakerRegistry:add count=" .. sr:count())
end

--@api-stub: LSpeakerRegistry:get
do
    local sr = lurek.dialog.newSpeakerRegistry()
    sr:add("guard", "Marcus")
    local spk = sr:get("guard")
    print("LSpeakerRegistry:get name=" .. tostring(spk and spk.name))
end

--@api-stub: LSpeakerRegistry:remove
do
    local sr = lurek.dialog.newSpeakerRegistry()
    sr:add("temp", "Temp")
    sr:remove("temp")
    print("LSpeakerRegistry:remove count=" .. sr:count())
end

--@api-stub: LSpeakerRegistry:count
do
    local sr = lurek.dialog.newSpeakerRegistry()
    sr:add("npc1", "Anna")
    sr:add("npc2", "Bob")
    print("LSpeakerRegistry:count=" .. sr:count())
end

--@api-stub: LSpeakerRegistry:contains
do
    local sr = lurek.dialog.newSpeakerRegistry()
    sr:add("merchant", "Henri")
    print("LSpeakerRegistry:contains=" .. tostring(sr:contains("merchant")))
end

--@api-stub: LSpeakerRegistry:type
do
    local sr = lurek.dialog.newSpeakerRegistry()
    print("LSpeakerRegistry:type=" .. sr:type())
end

--@api-stub: LSpeakerRegistry:typeOf
do
    local sr = lurek.dialog.newSpeakerRegistry()
    print("LSpeakerRegistry:typeOf LSpeakerRegistry=" .. tostring(sr:typeOf("LSpeakerRegistry")))
end

--@api-stub: LDialogueAI:addBranch
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("greeting", 1.0)
    local added = ai:addBranch("greeting", "hello_once", 2.0, "idle")
    print("LDialogueAI:addBranch ok=" .. tostring(added))
end

--@api-stub: LDialogueAI:addTopic
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("weather", 0.5, "idle")
    print("LDialogueAI:addTopic count=" .. ai:getTopicCount())
end

--@api-stub: LDialogueAI:clearUtilityScores
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("weather", 1.0, nil, nil, "weather_score")
    ai:setUtilityScore("weather_score", 0.9)
    ai:clearUtilityScores()
    print("LDialogueAI:clearUtilityScores ok")
    print("selected=" .. tostring(ai:selectTopic()))
end

--@api-stub: LDialogueAI:getTopicCount
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("weather", 0.5)
    ai:addTopic("quest", 0.8)
    print("LDialogueAI:getTopicCount=" .. ai:getTopicCount())
end

--@api-stub: LDialogueAI:selectBranch
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("friendly", 1.0, "idle")
    ai:addBranch("friendly", "weather_smalltalk", 1.0, "idle")
    ai:addBranch("friendly", "quest_prompt", 0.5, "idle")
    ai:setFSMState("idle")
    local branch = ai:selectBranch("friendly")
    print("LDialogueAI:selectBranch=" .. tostring(branch))
end

--@api-stub: LDialogueAI:selectTopic
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("rumors", 0.7)
    ai:addTopic("trade", 1.0, nil, nil, "trade_score")
    ai:setUtilityScore("trade_score", 1.5)
    local topic = ai:selectTopic()
    print("LDialogueAI:selectTopic=" .. tostring(topic))
end

--@api-stub: LDialogueAI:setBTStatus
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("combat_bark", 1.0, nil, "running")
    ai:setBTStatus("running")
    print("LDialogueAI:setBTStatus ok")
    print("selected=" .. tostring(ai:selectTopic()))
end

--@api-stub: LDialogueAI:setFSMState
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("shop", 1.0, "shop")
    ai:setFSMState("shop")
    print("LDialogueAI:setFSMState ok")
    print("selected=" .. tostring(ai:selectTopic()))
end

--@api-stub: LDialogueAI:setUtilityScore
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("danger", 0.3, nil, nil, "danger")
    ai:setUtilityScore("danger", 0.95)
    local topic = ai:selectTopic()
    print("LDialogueAI:setUtilityScore topic=" .. tostring(topic))
end

--@api-stub: LDialogueAI:type
do
    local ai = lurek.dialog.newAI()
    print("LDialogueAI:type=" .. ai:type())
end

--@api-stub: LDialogueAI:typeOf
do
    local ai = lurek.dialog.newAI()
    print("LDialogueAI:typeOf LDialogueAI=" .. tostring(ai:typeOf("LDialogueAI")))
end
