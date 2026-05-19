--- Tween Part 2: LTween extended, LTweenParallel, LTweenSequence, LTweenState, advanced module fns

--@api-stub: LTween.onComplete
--@api-stub: LTween:await
--@api-stub: LTween:getDuration
--@api-stub: LTween:getElapsed
--@api-stub: LTween:getProgress
--@api-stub: LTween:getRemaining
--@api-stub: LTween:isActive
--@api-stub: LTween:setRelative
--@api-stub: LTween:type
--@api-stub: LTween:typeOf
-- LTween extended: lifecycle, progress queries, callbacks, relative mode, type.
do
    local target = { x = 0.0 }
    local tw = lurek.tween.to(target, { x = 100 }, 1.0, "linear")
    print("duration=" .. tw:getDuration())
    print("elapsed=" .. tw:getElapsed())
    print("progress=" .. tw:getProgress())
    print("remaining=" .. tw:getRemaining())
    print("active=" .. tostring(tw:isActive()))
    tw:onComplete(function() print("tween_complete") end)
    tw:setRelative(false)
    print("type=" .. tw:type())
    print("typeOf=" .. tostring(tw:typeOf("LTween")))
    tw:await()
    tw:cancel()
end

--@api-stub: LTweenParallel.add
--@api-stub: LTweenParallel:isActive
--@api-stub: LTweenParallel.onComplete
--@api-stub: LTweenParallel:start
--@api-stub: LTweenParallel.tween
--@api-stub: LTweenParallel:type
--@api-stub: LTweenParallel:typeOf
-- LTweenParallel: run multiple tweens simultaneously.
do
    local a = { x = 0.0 }
    local b = { y = 0.0 }
    local par = lurek.tween.parallel()
    par:tween(1.0, a, { x = 50 }, "linear")
    par:tween(0.5, b, { y = 20 }, "easeinquad")
    local tw_extra = lurek.tween.to({ z = 0.0 }, { z = 10 }, 0.3, "linear")
    par:add(tw_extra)
    par:onComplete(function() print("parallel_done") end)
    print("par_active=" .. tostring(par:isActive()))
    print("par_type=" .. par:type())
    print("par_typeOf=" .. tostring(par:typeOf("LTweenParallel")))
    par:start()
    par:cancel()
end

--@api-stub: LTweenSequence.delay
--@api-stub: LTweenSequence.onComplete
--@api-stub: LTweenSequence.tween
--@api-stub: LTweenSequence:await
--@api-stub: LTweenSequence:isActive
--@api-stub: LTweenSequence:start
--@api-stub: LTweenSequence:type
--@api-stub: LTweenSequence:typeOf
-- LTweenSequence: chain tweens one after another.
do
    local obj = { x = 0.0, alpha = 1.0 }
    local seq = lurek.tween.sequence()
    seq:tween(0.5, obj, { x = 100 }, "linear")
    seq:delay(0.1, function() print("seq_delay_cb") end)
    seq:tween(0.5, obj, { alpha = 0 }, "easeout")
    seq:onComplete(function() print("seq_done") end)
    print("seq_active=" .. tostring(seq:isActive()))
    print("seq_type=" .. seq:type())
    print("seq_typeOf=" .. tostring(seq:typeOf("LTweenSequence")))
    seq:start()
    seq:await()
    seq:cancel()
end

--@api-stub: LTweenState:isComplete
--@api-stub: LTweenState:lerp
--@api-stub: LTweenState:t
--@api-stub: LTweenState:tick
--@api-stub: LTweenState:type
--@api-stub: LTweenState:typeOf
-- LTweenState: a manual time-state value for custom lerp.
do
    local state = lurek.tween.newState(1.0, "linear")
    state:tick(0.25)
    print("t=" .. state:t())
    print("lerp=" .. state:lerp(0, 100))
    print("complete=" .. tostring(state:isComplete()))
    print("type=" .. state:type())
    print("typeOf=" .. tostring(state:typeOf("LTweenState")))
end

--@api-stub: lurek.tween.cancelAll
--@api-stub: lurek.tween.getEasingNames
-- Cancel all active tweens and list registered easing functions.
do
    local target = { v = 0.0 }
    lurek.tween.to(target, { v = 1 }, 2.0, "linear")
    print("active=" .. lurek.tween.getActiveCount())
    lurek.tween.cancelAll()
    print("active_after=" .. lurek.tween.getActiveCount())

    local names = lurek.tween.getEasingNames()
    print("easing_count=" .. #names)
end

print("tween_02.lua")
