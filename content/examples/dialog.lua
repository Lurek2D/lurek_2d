--- @title Dialog System
--- @desc Decision tree dialog with topics, branches, conditions, and speakers.

--@api: lurek.dialog.newAI
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("greeting", 1.0)
    ai:addTopic("quest_offer", 0.7)
    local type_name = ai:type()
    local topic_count = ai:getTopicCount()
    lurek.log.info("dialog AI ready: " .. type_name)
    lurek.log.info("topics prepared for tavern NPC = " .. topic_count)
end

--@api: lurek.dialog.newState
do
    local ds = lurek.dialog.newState()
    ds:start("greeting")
    ds:setVariable("speaker", "guide")
    local type_name = ds:type()
    local current = ds:current()
    lurek.log.info("dialog state type = " .. type_name)
    lurek.log.info("active=" .. tostring(ds:isActive()) .. " current=" .. tostring(current))
end

--@api: lurek.dialog.newSpeakerRegistry
do
    local sr = lurek.dialog.newSpeakerRegistry()
    sr:add("guide", "Guide", "portraits/guide.png", "npc.guide")
    local speaker = sr:get("guide")
    local type_name = sr:type()
    local count = sr:count()
    lurek.log.info("speaker registry type = " .. type_name)
    lurek.log.info("registered " .. speaker.name .. ", count=" .. count)
end

--@api: LDialogueState:start
do
    local ds = lurek.dialog.newState()
    ds:start("intro")
    ds:setVariable("branch", "intro")
    local active = ds:isActive()
    local current = ds:current()
    local visits = ds:visitCount()
    lurek.log.info("conversation started at " .. tostring(current))
    lurek.log.info("active=" .. tostring(active) .. " visits=" .. visits)
end

--@api: LDialogueState:advance
do
    local ds = lurek.dialog.newState()
    ds:start("chat_intro")
    ds:advance("chat_reply")
    local current = ds:current()
    local visited_intro = ds:hasVisited("chat_intro")
    local visits = ds:visitCount()
    lurek.log.info("advanced to " .. tostring(current))
    lurek.log.info("intro visited=" .. tostring(visited_intro) .. " total=" .. visits)
end

--@api: LDialogueState:end_
do
    local ds = lurek.dialog.newState()
    ds:start("farewell")
    local before = ds:isActive()
    ds:end_()
    local after = ds:isActive()
    local current = ds:current()
    lurek.log.info("dialog active before end = " .. tostring(before))
    lurek.log.info("after end active=" .. tostring(after) .. " current=" .. tostring(current))
end

--@api: LDialogueState:current
do
    local ds = lurek.dialog.newState()
    ds:start("quest_offer")
    ds:advance("quest_reward")
    local current = ds:current()
    local reward_path = ds:hasVisited("quest_reward")
    lurek.log.info("current node = " .. tostring(current))
    lurek.log.info("reward path active = " .. tostring(reward_path))
end

--@api: LDialogueState:hasVisited
do
    local ds = lurek.dialog.newState()
    ds:start("info")
    ds:advance("bridge_warning")
    lurek.log.info("visited info=" .. tostring(ds:hasVisited("info")))
    lurek.log.info("visited bridge_warning=" .. tostring(ds:hasVisited("bridge_warning")))
end

--@api: LDialogueState:visitCount
do
    local ds = lurek.dialog.newState()
    ds:start("rumor_intro")
    ds:advance("rumor_detail")
    ds:advance("rumor_exit")
    lurek.log.info("LDialogueState:visitCount=" .. ds:visitCount())
end

--@api: LDialogueState:isActive
do
    local ds = lurek.dialog.newState()
    ds:start("greeting")
    local active_before = ds:isActive()
    ds:end_()
    local active_after = ds:isActive()
    lurek.log.info("state active before end = " .. tostring(active_before))
    lurek.log.info("state active after end = " .. tostring(active_after))
end

--@api: LDialogueState:setVariable
do
    local ds = lurek.dialog.newState()
    ds:setVariable("accepted", "no")
    ds:setVariable("quest_id", "find-relic")
    local accepted = ds:getVariable("accepted")
    local quest_id = ds:getVariable("quest_id")
    lurek.log.info("accepted flag = " .. tostring(accepted))
    lurek.log.info("quest variable = " .. tostring(quest_id))
end

--@api: LDialogueState:getVariable
do
    local ds = lurek.dialog.newState()
    ds:setVariable("coins", "50")
    ds:setVariable("discount", "10")
    local coins = ds:getVariable("coins")
    local discount = ds:getVariable("discount")
    lurek.log.info("merchant coins = " .. tostring(coins))
    lurek.log.info("discount percent = " .. tostring(discount))
end

--@api: LDialogueState:reset
do
    local ds = lurek.dialog.newState()
    ds:start("cycle_a")
    ds:advance("cycle_b")
    ds:reset()
    lurek.log.info("LDialogueState:reset isActive=" .. tostring(ds:isActive()))
    lurek.log.info("visit count=" .. ds:visitCount())
end

--@api: LDialogueState:type
do
    local ds = lurek.dialog.newState()
    ds:start("intro")
    local type_name = ds:type()
    local current = ds:current()
    local active = ds:isActive()
    lurek.log.info("state handle type = " .. type_name)
    lurek.log.info("active=" .. tostring(active) .. " current=" .. tostring(current))
end

--@api: LDialogueState:typeOf
do
    local ds = lurek.dialog.newState()
    local is_state = ds:typeOf("LDialogueState")
    local is_object = ds:typeOf("LObject")
    local is_registry = ds:typeOf("LSpeakerRegistry")
    lurek.log.info("is state = " .. tostring(is_state))
    lurek.log.info("registry cast valid = " .. tostring(is_registry) .. ", active=" .. tostring(ds:isActive()))
end

--@api: LSpeakerRegistry:add
do
    local sr = lurek.dialog.newSpeakerRegistry()
    sr:add("blacksmith", "Gordan", "gordan.png", "smith.voice")
    local speaker = sr:get("blacksmith")
    local count = sr:count()
    lurek.log.info("added speaker " .. speaker.name)
    lurek.log.info("registry count = " .. count)
end

--@api: LSpeakerRegistry:get
do
    local sr = lurek.dialog.newSpeakerRegistry()
    sr:add("guard", "Marcus")
    local spk = sr:get("guard")
    local exists = sr:contains("guard")
    local count = sr:count()
    lurek.log.info("speaker fetched = " .. tostring(spk and spk.name))
    lurek.log.info("exists=" .. tostring(exists) .. " count=" .. count)
end

--@api: LSpeakerRegistry:remove
do
    local sr = lurek.dialog.newSpeakerRegistry()
    sr:add("temp", "Temp")
    local before = sr:count()
    local removed = sr:remove("temp")
    local after = sr:count()
    lurek.log.info("removed temp speaker = " .. tostring(removed))
    lurek.log.info("count " .. before .. " -> " .. after)
end

--@api: LSpeakerRegistry:count
do
    local sr = lurek.dialog.newSpeakerRegistry()
    sr:add("npc1", "Anna")
    sr:add("npc2", "Bob")
    local total = sr:count()
    local anna = sr:get("npc1")
    lurek.log.info("registry size = " .. total)
    lurek.log.info("first speaker in scene = " .. anna.name)
end

--@api: LSpeakerRegistry:contains
do
    local sr = lurek.dialog.newSpeakerRegistry()
    sr:add("merchant", "Henri")
    local has_merchant = sr:contains("merchant")
    local has_guard = sr:contains("guard")
    lurek.log.info("merchant registered = " .. tostring(has_merchant))
    lurek.log.info("guard registered = " .. tostring(has_guard))
end

--@api: LSpeakerRegistry:type
do
    local sr = lurek.dialog.newSpeakerRegistry()
    sr:add("healer", "Mira")
    local type_name = sr:type()
    local count = sr:count()
    lurek.log.info("speaker registry type = " .. type_name)
    lurek.log.info("healer board count = " .. count)
end

--@api: LSpeakerRegistry:typeOf
do
    local sr = lurek.dialog.newSpeakerRegistry()
    local is_registry = sr:typeOf("LSpeakerRegistry")
    local is_object = sr:typeOf("LObject")
    local is_state = sr:typeOf("LDialogueState")
    lurek.log.info("is speaker registry = " .. tostring(is_registry))
    lurek.log.info("speaker registry count = " .. sr:count() .. ", state=" .. tostring(is_state))
end

--@api: LDialogueAI:addBranch
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("greeting", 1.0)
    local added = ai:addBranch("greeting", "hello_once", 2.0, "idle")
    ai:setFSMState("idle")
    local branch = ai:selectBranch("greeting")
    local topics = ai:getTopicCount()
    lurek.log.info("branch added = " .. tostring(added))
    lurek.log.info("selected branch = " .. tostring(branch) .. ", topics=" .. topics)
end

--@api: LDialogueAI:addTopic
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("weather", 0.5, "idle")
    ai:addTopic("trade", 0.8, "idle")
    ai:setFSMState("idle")
    local count = ai:getTopicCount()
    local topic = ai:selectTopic()
    lurek.log.info("topic count = " .. count)
    lurek.log.info("selected idle topic = " .. tostring(topic))
end

--@api: LDialogueAI:clearUtilityScores
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("weather", 1.0, nil, nil, "weather_score")
    ai:setUtilityScore("weather_score", 0.9)
    ai:clearUtilityScores()
    lurek.log.info("LDialogueAI:clearUtilityScores ok")
    lurek.log.info("selected=" .. tostring(ai:selectTopic()))
end

--@api: LDialogueAI:getTopicCount
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("weather", 0.5)
    ai:addTopic("quest", 0.8)
    ai:addTopic("rumor", 0.2)
    local count = ai:getTopicCount()
    local topic = ai:selectTopic()
    lurek.log.info("topic count = " .. count)
    lurek.log.info("currently selected topic = " .. tostring(topic))
end

--@api: LDialogueAI:selectBranch
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("friendly", 1.0, "idle")
    ai:addBranch("friendly", "weather_smalltalk", 1.0, "idle")
    ai:addBranch("friendly", "quest_prompt", 0.5, "idle")
    ai:setFSMState("idle")
    local branch = ai:selectBranch("friendly")
    lurek.log.info("LDialogueAI:selectBranch=" .. tostring(branch))
end

--@api: LDialogueAI:selectTopic
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("rumors", 0.7)
    ai:addTopic("trade", 1.0, nil, nil, "trade_score")
    ai:setUtilityScore("trade_score", 1.5)
    local topic = ai:selectTopic()
    lurek.log.info("LDialogueAI:selectTopic=" .. tostring(topic))
end

--@api: LDialogueAI:setBTStatus
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("combat_bark", 1.0, nil, "running")
    ai:setBTStatus("running")
    lurek.log.info("LDialogueAI:setBTStatus ok")
    lurek.log.info("selected=" .. tostring(ai:selectTopic()))
end

--@api: LDialogueAI:setFSMState
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("shop", 1.0, "shop")
    ai:setFSMState("shop")
    lurek.log.info("LDialogueAI:setFSMState ok")
    lurek.log.info("selected=" .. tostring(ai:selectTopic()))
end

--@api: LDialogueAI:setUtilityScore
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("danger", 0.3, nil, nil, "danger")
    ai:setUtilityScore("danger", 0.95)
    local topic = ai:selectTopic()
    lurek.log.info("LDialogueAI:setUtilityScore topic=" .. tostring(topic))
end

--@api: LDialogueAI:type
do
    local ai = lurek.dialog.newAI()
    ai:addTopic("greeting", 1.0)
    local type_name = ai:type()
    local count = ai:getTopicCount()
    lurek.log.info("dialog AI type = " .. type_name)
    lurek.log.info("registered topics = " .. count)
end

--@api: LDialogueAI:typeOf
do
    local ai = lurek.dialog.newAI()
    local is_ai = ai:typeOf("LDialogueAI")
    local is_object = ai:typeOf("LObject")
    local is_seq = ai:typeOf("LDialogSequencer")
    lurek.log.info("is dialogue AI = " .. tostring(is_ai))
    lurek.log.info("active branch after cast = " .. tostring(ai:selectBranch("weather")) .. ", sequencer=" .. tostring(is_seq))
end

--@api: lurek.dialog.newSequencer
do
    local seq = lurek.dialog.newSequencer()
    seq:load({ lurek.dialog.say("Guide", "Welcome to the inn.") })
    local type_name = seq:type()
    local state = seq:getState()
    local active = seq:isActive()
    lurek.log.info("sequencer type = " .. type_name)
    lurek.log.info("initial state = " .. state .. ", active=" .. tostring(active))
end

--@api: lurek.dialog.say
do
    local node = lurek.dialog.say("Hero", "I'm ready!")
    local seq = lurek.dialog.newSequencer()
    seq:load({ node })
    seq:start()
    lurek.log.info("say node type = " .. node.type)
    lurek.log.info("speaker=" .. node.actor .. " text=" .. seq:currentText())
end

--@api: lurek.dialog.choice
do
    local node = lurek.dialog.choice("What do you do?", {"Fight", "Flee", "Talk"})
    local seq = lurek.dialog.newSequencer()
    seq:load({ node })
    seq:start()
    local labels = seq:getChoiceLabels()
    lurek.log.info("choice node type = " .. node.type)
    lurek.log.info("prompt=" .. seq:getChoiceText() .. " options=" .. #labels)
end

--@api: lurek.dialog.wait
do
    local node = lurek.dialog.wait(3.0)
    local timeline = { lurek.dialog.say("Guide", "Hold on."), node, lurek.dialog.say("Guide", "Done.") }
    local total_nodes = #timeline
    local seconds = node.seconds
    lurek.log.info("wait node type = " .. node.type)
    lurek.log.info("pause seconds = " .. seconds .. " across " .. total_nodes .. " timeline nodes")
end

--@api: lurek.dialog.event
do
    local node = lurek.dialog.event("combat_end", "victory")
    local timeline = { lurek.dialog.say("Hero", "We did it."), node }
    local last = timeline[#timeline]
    lurek.log.info("event node type = " .. last.type)
    lurek.log.info("event name=" .. last.name .. " data=" .. tostring(last.data))
end

--@api: lurek.dialog.call
do
    local node = lurek.dialog.call("on_quest_accepted")
    local timeline = { lurek.dialog.choice("Accept quest?", {"Yes", "No"}), node }
    local callback = timeline[2]
    lurek.log.info("call node type = " .. callback.type)
    lurek.log.info("callback name = " .. callback.name)
end

--@api: lurek.dialog.jump
do
    local node = lurek.dialog.jump("ending_good")
    local timeline = { lurek.dialog.say("Guide", "Choose your fate."), node }
    local jump = timeline[2]
    lurek.log.info("jump node type = " .. jump.type)
    lurek.log.info("jump target = " .. jump.target)
end

--@api: LDialogSequencer:load
do
    local seq = lurek.dialog.newSequencer()
    local nodes = {
        lurek.dialog.say("NPC", "Hello there!"),
        lurek.dialog.choice("How are you?", {"Good", "Bad"})
    }
    seq:load(nodes)
    lurek.log.info("LDialogSequencer:load ok")
end

--@api: LDialogSequencer:start
do
    local seq = lurek.dialog.newSequencer()
    seq:load({ lurek.dialog.say("NPC", "Beginning...") })
    seq:start()
    local state = seq:getState()
    local speaker = seq:currentSpeaker()
    local text = seq:currentText()
    lurek.log.info("state after start = " .. state)
    lurek.log.info("speaker=" .. tostring(speaker) .. " text=" .. text)
end

--@api: LDialogSequencer:update
do
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(10.0)
    seq:load({ lurek.dialog.say("NPC", "Hello") })
    seq:start()
    seq:update(0.15)
    lurek.log.info("LDialogSequencer:update revealed=" .. seq:revealedText())
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
    lurek.log.info("LDialogSequencer:advance text=" .. seq:currentText())
end

--@api: LDialogSequencer:skip
do
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(1.0)
    seq:load({ lurek.dialog.say("NPC", "Instant reveal") })
    seq:start()
    seq:skip()
    lurek.log.info("LDialogSequencer:skip revealed=" .. seq:revealedText())
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
    lurek.log.info("LDialogSequencer:choose state=" .. seq:getState())
end

--@api: LDialogSequencer:setSpeed
do
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(50.0)
    seq:load({ lurek.dialog.say("Guide", "Fast line reveal") })
    seq:start()
    seq:update(0.1)
    lurek.log.info("configured speed = " .. seq:getSpeed())
    lurek.log.info("revealed text after tick = " .. seq:revealedText())
end

--@api: LDialogSequencer:getSpeed
do
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(25.0)
    seq:load({ lurek.dialog.say("Guide", "Measured reveal") })
    seq:start()
    local speed = seq:getSpeed()
    local state = seq:getState()
    lurek.log.info("sequencer speed = " .. speed)
    lurek.log.info("state while typing = " .. state)
end

--@api: LDialogSequencer:getState
do
    local seq = lurek.dialog.newSequencer()
    seq:load({ lurek.dialog.say("NPC", "Text") })
    seq:start()
    local state = seq:getState()
    local active = seq:isActive()
    local speaker = seq:currentSpeaker()
    lurek.log.info("sequencer state = " .. state)
    lurek.log.info("active=" .. tostring(active) .. " speaker=" .. tostring(speaker))
end

--@api: LDialogSequencer:isActive
do
    local seq = lurek.dialog.newSequencer()
    lurek.log.info("idle active=" .. tostring(seq:isActive()))
    seq:load({ lurek.dialog.say("NPC", "Started") })
    seq:start()
    lurek.log.info("started active=" .. tostring(seq:isActive()))
end

--@api: LDialogSequencer:isWaitingForChoice
do
    local seq = lurek.dialog.newSequencer()
    seq:load({ lurek.dialog.choice("Pick:", {"Yes", "No"}) })
    seq:start()
    local waiting = seq:isWaitingForChoice()
    local prompt = seq:getChoiceText()
    local labels = seq:getChoiceLabels()
    lurek.log.info("waiting for choice = " .. tostring(waiting))
    lurek.log.info("prompt=" .. tostring(prompt) .. " options=" .. #labels)
end

--@api: LDialogSequencer:currentSpeaker
do
    local seq = lurek.dialog.newSequencer()
    seq:load({ lurek.dialog.say("Warrior", "At last!") })
    seq:start()
    local speaker = seq:currentSpeaker()
    local text = seq:currentText()
    local state = seq:getState()
    lurek.log.info("current speaker = " .. tostring(speaker))
    lurek.log.info("state=" .. state .. " text=" .. text)
end

--@api: LDialogSequencer:currentText
do
    local seq = lurek.dialog.newSequencer()
    seq:load({ lurek.dialog.say("NPC", "The full line here") })
    seq:start()
    local text = seq:currentText()
    local revealed = seq:revealedText()
    local speaker = seq:currentSpeaker()
    lurek.log.info("current text = " .. text)
    lurek.log.info("speaker=" .. tostring(speaker) .. " revealed=" .. revealed)
end

--@api: LDialogSequencer:revealedText
do
    local seq = lurek.dialog.newSequencer()
    seq:setSpeed(5.0)
    seq:load({ lurek.dialog.say("NPC", "Slowly revealed") })
    seq:start()
    seq:update(0.2)
    lurek.log.info("LDialogSequencer:revealedText=" .. seq:revealedText())
end

--@api: LDialogSequencer:getChoiceText
do
    local seq = lurek.dialog.newSequencer()
    seq:load({ lurek.dialog.choice("Your move?", {"Attack", "Defend"}) })
    seq:start()
    local prompt = seq:getChoiceText()
    local labels = seq:getChoiceLabels()
    local waiting = seq:isWaitingForChoice()
    lurek.log.info("choice prompt = " .. tostring(prompt))
    lurek.log.info("waiting=" .. tostring(waiting) .. " options=" .. #labels)
end

--@api: LDialogSequencer:getChoiceLabels
do
    local seq = lurek.dialog.newSequencer()
    seq:load({ lurek.dialog.choice("Pick:", {"Option A", "Option B", "Option C"}) })
    seq:start()
    local labels = seq:getChoiceLabels()
    lurek.log.info("LDialogSequencer:getChoiceLabels count=" .. #labels)
    lurek.log.info("first=" .. labels[1])
end

--@api: LDialogSequencer:type
do
    local seq = lurek.dialog.newSequencer()
    seq:load({ lurek.dialog.say("Guide", "Status check") })
    local type_name = seq:type()
    local state = seq:getState()
    lurek.log.info("sequencer type = " .. type_name)
    lurek.log.info("current state before start = " .. state)
end

--@api: LDialogSequencer:typeOf
do
    local seq = lurek.dialog.newSequencer()
    local is_seq = seq:typeOf("LDialogSequencer")
    local is_object = seq:typeOf("LObject")
    local is_ai = seq:typeOf("LDialogueAI")
    lurek.log.info("is sequencer = " .. tostring(is_seq))
    lurek.log.info("is object = " .. tostring(is_object) .. ", ai=" .. tostring(is_ai))
end
