--@api-stub: LSpring:isActive
--@api-stub: LSpring:isSettled
--@api-stub: LSpring:update
-- LSpring: physics-based spring animation.
do
    local obj = {x = 0}
    local sp = lurek.tween.spring(obj, {x = 100}, {stiffness = 200, damping = 20})
    sp:update(0.016)
    local active = sp:isActive()
    local settled = sp:isSettled()
    print("spring active:", active, "settled:", settled)
end

--@api-stub: LSpring:type
--@api-stub: LSpring:typeOf
-- LSpring type introspection.
do
    local state = {v = 0}
    local sp = lurek.tween.spring(state, {v = 50}, {stiffness = 150, damping = 15})
    local t = sp:type()
    local ok = sp:typeOf("LSpring")
    print("spring type:", t, "typeOf:", ok)
end
