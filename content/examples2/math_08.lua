--@api-stub: LNoiseGenerator:type
--@api-stub: LNoiseGenerator:typeOf
--@api-stub: lurek.math.voronoi
-- LNoiseGenerator type introspection and voronoi generation.
do
    local ng = lurek.math.newNoiseGenerator(42)
    local t = ng:type()
    local ok = ng:typeOf("LNoiseGenerator")
    local pts = {{x=0.2, y=0.3}, {x=0.7, y=0.8}, {x=0.5, y=0.1}}
    local cells = lurek.math.voronoi(pts)
    print("noise type:", t, "voronoi cells:", type(cells))
end

--@api-stub: LTween:getDuration
--@api-stub: LTween:getEasingName
--@api-stub: LTween:type
-- LTween duration and easing name introspection.
do
    local state = {x = 0}
    local tw = lurek.tween.to(state, {x = 100}, 2.0, "linear")
    local dur = tw:getDuration()
    local ename = tw:getEasingName()
    local t = tw:type()
    print("tween duration:", dur, "easing:", ename, "type:", t)
end

--@api-stub: LTween:typeOf
-- LTween typeOf check.
do
    local state = {v = 0}
    local tw = lurek.tween.to(state, {v = 1}, 0.5, "linear")
    local ok = tw:typeOf("LTween")
    local notok = tw:typeOf("LSpring")
    print("LTween typeOf LTween:", ok, "typeOf LSpring:", notok)
end
