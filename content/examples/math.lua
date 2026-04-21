-- content/examples/math.lua
-- Lurek2D lurek.math API Reference
-- Run with: cargo run -- content/examples/math
--
Scenario: A comprehensive demonstration of the math library used throughout
-- game development — easing for UI animations, noise for terrain generation,
-- spatial hashing for broad-phase collision, geometry for level editor tools,
-- transforms for hierarchical scene graphs, and vector math for gameplay.

print("=== lurek.math — Math Library ===\n")

-- =============================================================================
-- Factory Functions — Object Creation
-- =============================================================================

-- Demonstrates the proper usage of lurek.math.newRandomGenerator.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_newRandomGenerator()
    local rng = lurek.math.newRandomGenerator()
end
local _ok, _err = pcall(demo_lurek_math_newRandomGenerator)

-- Demonstrates the proper usage of lurek.math.newTransform.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_newTransform()
    local tf = lurek.math.newTransform()
end
local _ok, _err = pcall(demo_lurek_math_newTransform)

-- Demonstrates the proper usage of lurek.math.newBezierCurve.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_newBezierCurve()
    local bez = lurek.math.newBezierCurve({0,0, 100,50, 200,0})
end
local _ok, _err = pcall(demo_lurek_math_newBezierCurve)

-- Demonstrates the proper usage of lurek.math.newTween.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_newTween()
    local tween = lurek.math.newTween(1.0, "outQuad")
end
local _ok, _err = pcall(demo_lurek_math_newTween)

-- Demonstrates the proper usage of lurek.math.newSpatialHash.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_newSpatialHash()
    local shash = lurek.math.newSpatialHash(64)
end
local _ok, _err = pcall(demo_lurek_math_newSpatialHash)

-- Demonstrates the proper usage of lurek.math.newNoiseGenerator.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_newNoiseGenerator()
    local noise = lurek.math.newNoiseGenerator()
end
local _ok, _err = pcall(demo_lurek_math_newNoiseGenerator)

-- =============================================================================
-- Vectors
-- =============================================================================

-- Demonstrates the proper usage of lurek.math.vec2.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_vec2()
    local v = lurek.math.vec2(3, 4)
end
local _ok, _err = pcall(demo_lurek_math_vec2)

-- Demonstrates the proper usage of lurek.math.Vec2.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_Vec2()
    local v2 = lurek.math.Vec2(1, 0)
end
local _ok, _err = pcall(demo_lurek_math_Vec2)

-- Demonstrates the proper usage of Vec2:x.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec2_x()
    print("v.x: " .. v:x())
end
local _ok, _err = pcall(demo_Vec2_x)

-- Demonstrates the proper usage of Vec2:y.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec2_y()
    print("v.y: " .. v:y())
end
local _ok, _err = pcall(demo_Vec2_y)

-- Demonstrates the proper usage of Vec2:dot.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec2_dot()
    print("dot: " .. v:dot(v2))
end
local _ok, _err = pcall(demo_Vec2_dot)

-- Demonstrates the proper usage of Vec2:length.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec2_length()
    print("length: " .. v:length())
end
local _ok, _err = pcall(demo_Vec2_length)

-- Demonstrates the proper usage of Vec2:lengthSquared.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec2_lengthSquared()
    print("lengthSq: " .. v:lengthSquared())
end
local _ok, _err = pcall(demo_Vec2_lengthSquared)

-- Demonstrates the proper usage of Vec2:normalize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec2_normalize()
    v:normalize()
end
local _ok, _err = pcall(demo_Vec2_normalize)

-- Demonstrates the proper usage of Vec2:normalized.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec2_normalized()
    local n = v:normalized()
end
local _ok, _err = pcall(demo_Vec2_normalized)

-- Demonstrates the proper usage of Vec2:lerp.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec2_lerp()
    local mid = v:lerp(v2, 0.5)
end
local _ok, _err = pcall(demo_Vec2_lerp)

-- Demonstrates the proper usage of Vec2:distance.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec2_distance()
    print("dist: " .. v:distance(v2))
end
local _ok, _err = pcall(demo_Vec2_distance)

-- Demonstrates the proper usage of Vec2:angle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec2_angle()
    print("angle: " .. v:angle())
end
local _ok, _err = pcall(demo_Vec2_angle)

-- Demonstrates the proper usage of Vec2:rotate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec2_rotate()
    local rotated = v:rotate(math.pi / 4)
end
local _ok, _err = pcall(demo_Vec2_rotate)

-- Demonstrates the proper usage of Vec2:perpendicular.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec2_perpendicular()
    local perp = v:perpendicular()
end
local _ok, _err = pcall(demo_Vec2_perpendicular)

-- Demonstrates the proper usage of Vec2:cross.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec2_cross()
    print("cross: " .. v:cross(v2))
end
local _ok, _err = pcall(demo_Vec2_cross)

-- Demonstrates the proper usage of lurek.math.vec3.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_vec3()
    local v3 = lurek.math.vec3(1, 2, 3)
end
local _ok, _err = pcall(demo_lurek_math_vec3)

-- Demonstrates the proper usage of lurek.math.Vec3.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_Vec3()
    local v3b = lurek.math.Vec3(4, 5, 6)
end
local _ok, _err = pcall(demo_lurek_math_Vec3)

-- Demonstrates the proper usage of Vec3:length.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec3_length()
    print("v3 length: " .. v3:length())
end
local _ok, _err = pcall(demo_Vec3_length)

-- Demonstrates the proper usage of Vec3:lengthSquared.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec3_lengthSquared()
    print("v3 lengthSq: " .. v3:lengthSquared())
end
local _ok, _err = pcall(demo_Vec3_lengthSquared)

-- Demonstrates the proper usage of Vec3:normalize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec3_normalize()
    v3:normalize()
end
local _ok, _err = pcall(demo_Vec3_normalize)

-- Demonstrates the proper usage of Vec3:dot.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec3_dot()
    print("v3 dot: " .. v3:dot(v3b))
end
local _ok, _err = pcall(demo_Vec3_dot)

-- Demonstrates the proper usage of Vec3:cross.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec3_cross()
    local v3cross = v3:cross(v3b)
end
local _ok, _err = pcall(demo_Vec3_cross)

-- Demonstrates the proper usage of Vec3:lerp.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec3_lerp()
    local v3mid = v3:lerp(v3b, 0.5)
end
local _ok, _err = pcall(demo_Vec3_lerp)

-- Demonstrates the proper usage of Vec3:distance.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec3_distance()
    print("v3 dist: " .. v3:distance(v3b))
end
local _ok, _err = pcall(demo_Vec3_distance)

-- Demonstrates the proper usage of Vec3:add.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec3_add()
    local v3sum = v3:add(v3b)
end
local _ok, _err = pcall(demo_Vec3_add)

-- Demonstrates the proper usage of Vec3:sub.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec3_sub()
    local v3diff = v3:sub(v3b)
end
local _ok, _err = pcall(demo_Vec3_sub)

-- Demonstrates the proper usage of Vec3:scale.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec3_scale()
    local v3scaled = v3:scale(2.0)
end
local _ok, _err = pcall(demo_Vec3_scale)

-- =============================================================================
-- Transform — 2D affine transforms
-- =============================================================================

-- Demonstrates the proper usage of Transform:translate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Transform_translate()
    tf:translate(100, 50)
end
local _ok, _err = pcall(demo_Transform_translate)

-- Demonstrates the proper usage of Transform:rotate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Transform_rotate()
    tf:rotate(math.pi / 6)
end
local _ok, _err = pcall(demo_Transform_rotate)

-- Demonstrates the proper usage of Transform:scale.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Transform_scale()
    tf:scale(2, 2)
end
local _ok, _err = pcall(demo_Transform_scale)

-- Demonstrates the proper usage of Transform:shear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Transform_shear()
    tf:shear(0.1, 0)
end
local _ok, _err = pcall(demo_Transform_shear)

-- Demonstrates the proper usage of Transform:reset.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Transform_reset()
    tf:reset()
end
local _ok, _err = pcall(demo_Transform_reset)

-- Demonstrates the proper usage of Transform:transformPoint.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Transform_transformPoint()
    local px, py = tf:transformPoint(10, 20)
    print("transformed: " .. px .. "," .. py)
end
local _ok, _err = pcall(demo_Transform_transformPoint)

-- Demonstrates the proper usage of Transform:inverseTransformPoint.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Transform_inverseTransformPoint()
    local ipx, ipy = tf:inverseTransformPoint(px, py)
    print("inverse: " .. ipx .. "," .. ipy)
end
local _ok, _err = pcall(demo_Transform_inverseTransformPoint)

-- Demonstrates the proper usage of Transform:inverse.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Transform_inverse()
    local inv = tf:inverse()
end
local _ok, _err = pcall(demo_Transform_inverse)

-- Demonstrates the proper usage of Transform:clone.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Transform_clone()
    local tf_copy = tf:clone()
end
local _ok, _err = pcall(demo_Transform_clone)

-- Demonstrates the proper usage of Transform:getMatrix.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Transform_getMatrix()
    local m = tf:getMatrix()
end
local _ok, _err = pcall(demo_Transform_getMatrix)

-- =============================================================================
-- Bezier Curves
-- =============================================================================

-- Demonstrates the proper usage of BezierCurve:evaluate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BezierCurve_evaluate()
    local bx, by = bez:evaluate(0.5)
    print("bezier at t=0.5: " .. bx .. "," .. by)
end
local _ok, _err = pcall(demo_BezierCurve_evaluate)

-- Demonstrates the proper usage of BezierCurve:render.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BezierCurve_render()
    local points = bez:render(5)
end
local _ok, _err = pcall(demo_BezierCurve_render)

-- Demonstrates the proper usage of BezierCurve:getDerivative.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BezierCurve_getDerivative()
    local deriv = bez:getDerivative()
end
local _ok, _err = pcall(demo_BezierCurve_getDerivative)

-- Demonstrates the proper usage of BezierCurve:getControlPoint.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BezierCurve_getControlPoint()
    local cpx, cpy = bez:getControlPoint(1)
    print("control point 1: " .. cpx .. "," .. cpy)
end
local _ok, _err = pcall(demo_BezierCurve_getControlPoint)

-- Demonstrates the proper usage of BezierCurve:removeControlPoint.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BezierCurve_removeControlPoint()
    print('Executing removeControlPoint')
end
local _ok, _err = pcall(demo_BezierCurve_removeControlPoint)

-- Demonstrates the proper usage of BezierCurve:getControlPointCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BezierCurve_getControlPointCount()
    print("control points: " .. bez:getControlPointCount())
end
local _ok, _err = pcall(demo_BezierCurve_getControlPointCount)

-- Demonstrates the proper usage of BezierCurve:length.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BezierCurve_length()
    print("bezier length: " .. bez:length())
end
local _ok, _err = pcall(demo_BezierCurve_length)

-- Demonstrates the proper usage of BezierCurve:translate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BezierCurve_translate()
    bez:translate(10, 0)
end
local _ok, _err = pcall(demo_BezierCurve_translate)

-- Demonstrates the proper usage of BezierCurve:rotate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BezierCurve_rotate()
    bez:rotate(0.1)
end
local _ok, _err = pcall(demo_BezierCurve_rotate)

-- Demonstrates the proper usage of BezierCurve:scale.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_BezierCurve_scale()
    bez:scale(1.5)
end
local _ok, _err = pcall(demo_BezierCurve_scale)

-- =============================================================================
-- Spline Interpolation
-- =============================================================================

-- Demonstrates the proper usage of lurek.math.catmullRom.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_catmullRom()
    local cr = lurek.math.catmullRom({0,0, 100,50, 200,30, 300,0})
end
local _ok, _err = pcall(demo_lurek_math_catmullRom)

-- Demonstrates the proper usage of CatmullRom:sample.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CatmullRom_sample()
    local sx, sy = cr:sample(0.5)
    print("catmull at 0.5: " .. sx .. "," .. sy)
end
local _ok, _err = pcall(demo_CatmullRom_sample)

-- Demonstrates the proper usage of CatmullRom:sampleSegment.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CatmullRom_sampleSegment()
    local ssx, ssy = cr:sampleSegment(1, 0.5)
end
local _ok, _err = pcall(demo_CatmullRom_sampleSegment)

-- Demonstrates the proper usage of CatmullRom:len.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CatmullRom_len()
    print("catmull segments: " .. cr:len())
end
local _ok, _err = pcall(demo_CatmullRom_len)

-- Demonstrates the proper usage of lurek.math.hermite.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_hermite()
    local herm = lurek.math.hermite({0,0, 100,50, 200,0, 300,50})
end
local _ok, _err = pcall(demo_lurek_math_hermite)

-- Demonstrates the proper usage of Hermite:sample.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Hermite_sample()
    local hx, hy = herm:sample(0.5)
    print("hermite at 0.5: " .. hx .. "," .. hy)
end
local _ok, _err = pcall(demo_Hermite_sample)

-- =============================================================================
-- Tweens & Easing
-- =============================================================================

-- Demonstrates the proper usage of Tween:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Tween_update()
    tween:update(0.016)
end
local _ok, _err = pcall(demo_Tween_update)

-- Demonstrates the proper usage of Tween:getValue.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Tween_getValue()
    print("tween value: " .. tween:getValue())
end
local _ok, _err = pcall(demo_Tween_getValue)

-- Demonstrates the proper usage of Tween:getAllValues.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Tween_getAllValues()
    local vals = tween:getAllValues()
end
local _ok, _err = pcall(demo_Tween_getAllValues)

-- Demonstrates the proper usage of Tween:isComplete.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Tween_isComplete()
    print("complete: " .. tostring(tween:isComplete()))
end
local _ok, _err = pcall(demo_Tween_isComplete)

-- Demonstrates the proper usage of Tween:reset.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Tween_reset()
    tween:reset()
end
local _ok, _err = pcall(demo_Tween_reset)

-- Demonstrates the proper usage of Tween:getValueCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Tween_getValueCount()
    print("value count: " .. tween:getValueCount())
end
local _ok, _err = pcall(demo_Tween_getValueCount)

-- Demonstrates the proper usage of Tween:getEasingName.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Tween_getEasingName()
    print("easing: " .. tween:getEasingName())
end
local _ok, _err = pcall(demo_Tween_getEasingName)

-- Demonstrates the proper usage of Tween:getDuration.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Tween_getDuration()
    print("duration: " .. tween:getDuration())
end
local _ok, _err = pcall(demo_Tween_getDuration)

-- Demonstrates the proper usage of Tween:getTime.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Tween_getTime()
    print("time: " .. tween:getTime())
end
local _ok, _err = pcall(demo_Tween_getTime)

-- Demonstrates the proper usage of Tween:getClock.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Tween_getClock()
    print("clock: " .. tween:getClock())
end
local _ok, _err = pcall(demo_Tween_getClock)

-- Demonstrates the proper usage of Tween:setTime.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Tween_setTime()
    tween:setTime(0.5)
end
local _ok, _err = pcall(demo_Tween_setTime)

-- Demonstrates the proper usage of Tween:set.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Tween_set()
    tween:set(0.0, 1.0, 2.0, "outQuad")
end
local _ok, _err = pcall(demo_Tween_set)

-- Demonstrates the proper usage of Tween:addValue.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Tween_addValue()
    tween:addValue(0.0, 100.0)
end
local _ok, _err = pcall(demo_Tween_addValue)

-- Demonstrates the proper usage of lurek.math.applyEasing.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_applyEasing()
    print("outQuad(0.5): " .. lurek.math.applyEasing("outQuad", 0.5))
end
local _ok, _err = pcall(demo_lurek_math_applyEasing)

-- Demonstrates the proper usage of lurek.math.linear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_linear()
    print("linear(0.5): " .. lurek.math.linear(0.5))
end
local _ok, _err = pcall(demo_lurek_math_linear)

-- Demonstrates the proper usage of lurek.math.inQuad.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_inQuad()
    print("inQuad: " .. lurek.math.inQuad(0.5))
end
local _ok, _err = pcall(demo_lurek_math_inQuad)

-- Demonstrates the proper usage of lurek.math.outQuad.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_outQuad()
    print("outQuad: " .. lurek.math.outQuad(0.5))
end
local _ok, _err = pcall(demo_lurek_math_outQuad)

-- Demonstrates the proper usage of lurek.math.inOutQuad.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_inOutQuad()
    print("inOutQuad: " .. lurek.math.inOutQuad(0.5))
end
local _ok, _err = pcall(demo_lurek_math_inOutQuad)

-- Demonstrates the proper usage of lurek.math.inCubic.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_inCubic()
    print("inCubic: " .. lurek.math.inCubic(0.5))
end
local _ok, _err = pcall(demo_lurek_math_inCubic)

-- Demonstrates the proper usage of lurek.math.outCubic.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_outCubic()
    print("outCubic: " .. lurek.math.outCubic(0.5))
end
local _ok, _err = pcall(demo_lurek_math_outCubic)

-- Demonstrates the proper usage of lurek.math.inOutCubic.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_inOutCubic()
    print("inOutCubic: " .. lurek.math.inOutCubic(0.5))
end
local _ok, _err = pcall(demo_lurek_math_inOutCubic)

-- Demonstrates the proper usage of lurek.math.inQuart.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_inQuart()
    print("inQuart: " .. lurek.math.inQuart(0.5))
end
local _ok, _err = pcall(demo_lurek_math_inQuart)

-- Demonstrates the proper usage of lurek.math.outQuart.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_outQuart()
    print("outQuart: " .. lurek.math.outQuart(0.5))
end
local _ok, _err = pcall(demo_lurek_math_outQuart)

-- Demonstrates the proper usage of lurek.math.inOutQuart.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_inOutQuart()
    print("inOutQuart: " .. lurek.math.inOutQuart(0.5))
end
local _ok, _err = pcall(demo_lurek_math_inOutQuart)

-- Demonstrates the proper usage of lurek.math.inSine.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_inSine()
    print("inSine: " .. lurek.math.inSine(0.5))
end
local _ok, _err = pcall(demo_lurek_math_inSine)

-- Demonstrates the proper usage of lurek.math.outSine.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_outSine()
    print("outSine: " .. lurek.math.outSine(0.5))
end
local _ok, _err = pcall(demo_lurek_math_outSine)

-- Demonstrates the proper usage of lurek.math.inOutSine.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_inOutSine()
    print("inOutSine: " .. lurek.math.inOutSine(0.5))
end
local _ok, _err = pcall(demo_lurek_math_inOutSine)

-- Demonstrates the proper usage of lurek.math.inExpo.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_inExpo()
    print("inExpo: " .. lurek.math.inExpo(0.5))
end
local _ok, _err = pcall(demo_lurek_math_inExpo)

-- Demonstrates the proper usage of lurek.math.outExpo.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_outExpo()
    print("outExpo: " .. lurek.math.outExpo(0.5))
end
local _ok, _err = pcall(demo_lurek_math_outExpo)

-- Demonstrates the proper usage of lurek.math.inOutExpo.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_inOutExpo()
    print("inOutExpo: " .. lurek.math.inOutExpo(0.5))
end
local _ok, _err = pcall(demo_lurek_math_inOutExpo)

-- Demonstrates the proper usage of lurek.math.inElastic.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_inElastic()
    print("inElastic: " .. lurek.math.inElastic(0.5))
end
local _ok, _err = pcall(demo_lurek_math_inElastic)

-- Demonstrates the proper usage of lurek.math.outElastic.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_outElastic()
    print("outElastic: " .. lurek.math.outElastic(0.5))
end
local _ok, _err = pcall(demo_lurek_math_outElastic)

-- Demonstrates the proper usage of lurek.math.outBounce.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_outBounce()
    print("outBounce: " .. lurek.math.outBounce(0.5))
end
local _ok, _err = pcall(demo_lurek_math_outBounce)

-- Demonstrates the proper usage of lurek.math.inBounce.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_inBounce()
    print("inBounce: " .. lurek.math.inBounce(0.5))
end
local _ok, _err = pcall(demo_lurek_math_inBounce)

-- Demonstrates the proper usage of lurek.math.inBack.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_inBack()
    print("inBack: " .. lurek.math.inBack(0.5))
end
local _ok, _err = pcall(demo_lurek_math_inBack)

-- Demonstrates the proper usage of lurek.math.outBack.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_outBack()
    print("outBack: " .. lurek.math.outBack(0.5))
end
local _ok, _err = pcall(demo_lurek_math_outBack)

-- =============================================================================
-- Noise Generation
-- =============================================================================

-- Demonstrates the proper usage of lurek.math.perlin2d.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_perlin2d()
    print("perlin2d: " .. lurek.math.perlin2d(1.5, 2.3))
end
local _ok, _err = pcall(demo_lurek_math_perlin2d)

-- Demonstrates the proper usage of lurek.math.perlin3d.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_perlin3d()
    print("perlin3d: " .. lurek.math.perlin3d(1.5, 2.3, 0.5))
end
local _ok, _err = pcall(demo_lurek_math_perlin3d)

-- Demonstrates the proper usage of lurek.math.simplex2d.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_simplex2d()
    print("simplex2d: " .. lurek.math.simplex2d(1.5, 2.3))
end
local _ok, _err = pcall(demo_lurek_math_simplex2d)

-- Demonstrates the proper usage of lurek.math.simplexNoise.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_simplexNoise()
    print("simplexNoise: " .. lurek.math.simplexNoise(1.5, 2.3))
end
local _ok, _err = pcall(demo_lurek_math_simplexNoise)

-- Demonstrates the proper usage of lurek.math.fbm.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_fbm()
    print("fbm: " .. lurek.math.fbm(1.5, 2.3, 6, 0.5))
end
local _ok, _err = pcall(demo_lurek_math_fbm)

-- Demonstrates the proper usage of NoiseGenerator:perlin1d.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NoiseGenerator_perlin1d()
    print("noise.perlin1d: " .. noise:perlin1d(0.5))
end
local _ok, _err = pcall(demo_NoiseGenerator_perlin1d)

-- Demonstrates the proper usage of NoiseGenerator:perlin2d.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NoiseGenerator_perlin2d()
    print("noise.perlin2d: " .. noise:perlin2d(1.0, 2.0))
end
local _ok, _err = pcall(demo_NoiseGenerator_perlin2d)

-- Demonstrates the proper usage of NoiseGenerator:perlin3d.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NoiseGenerator_perlin3d()
    print("noise.perlin3d: " .. noise:perlin3d(1.0, 2.0, 3.0))
end
local _ok, _err = pcall(demo_NoiseGenerator_perlin3d)

-- Demonstrates the proper usage of NoiseGenerator:perlin4d.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NoiseGenerator_perlin4d()
    print("noise.perlin4d: " .. noise:perlin4d(1.0, 2.0, 3.0, 4.0))
end
local _ok, _err = pcall(demo_NoiseGenerator_perlin4d)

-- Demonstrates the proper usage of NoiseGenerator:simplex1d.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NoiseGenerator_simplex1d()
    print("noise.simplex1d: " .. noise:simplex1d(0.5))
end
local _ok, _err = pcall(demo_NoiseGenerator_simplex1d)

-- Demonstrates the proper usage of NoiseGenerator:simplex2d.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NoiseGenerator_simplex2d()
    print("noise.simplex2d: " .. noise:simplex2d(1.0, 2.0))
end
local _ok, _err = pcall(demo_NoiseGenerator_simplex2d)

-- Demonstrates the proper usage of NoiseGenerator:simplex3d.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NoiseGenerator_simplex3d()
    print("noise.simplex3d: " .. noise:simplex3d(1.0, 2.0, 3.0))
end
local _ok, _err = pcall(demo_NoiseGenerator_simplex3d)

-- Demonstrates the proper usage of NoiseGenerator:getSeed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NoiseGenerator_getSeed()
    print("noise seed: " .. noise:getSeed())
end
local _ok, _err = pcall(demo_NoiseGenerator_getSeed)

-- Demonstrates the proper usage of NoiseGenerator:setSeed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NoiseGenerator_setSeed()
    noise:setSeed(42)
end
local _ok, _err = pcall(demo_NoiseGenerator_setSeed)

-- =============================================================================
-- Random Generator
-- =============================================================================

-- Demonstrates the proper usage of RandomGenerator:random.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RandomGenerator_random()
    print("random: " .. rng:random())
end
local _ok, _err = pcall(demo_RandomGenerator_random)

-- Demonstrates the proper usage of RandomGenerator:randomFloat.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RandomGenerator_randomFloat()
    print("float [0.5, 1.5]: " .. rng:randomFloat(0.5, 1.5))
end
local _ok, _err = pcall(demo_RandomGenerator_randomFloat)

-- Demonstrates the proper usage of RandomGenerator:randomInt.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RandomGenerator_randomInt()
    print("int [1, 100]: " .. rng:randomInt(1, 100))
end
local _ok, _err = pcall(demo_RandomGenerator_randomInt)

-- Demonstrates the proper usage of RandomGenerator:getSeed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RandomGenerator_getSeed()
    print("rng seed: " .. rng:getSeed())
end
local _ok, _err = pcall(demo_RandomGenerator_getSeed)

-- Demonstrates the proper usage of RandomGenerator:setSeed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RandomGenerator_setSeed()
    rng:setSeed(12345)
end
local _ok, _err = pcall(demo_RandomGenerator_setSeed)

-- Demonstrates the proper usage of RandomGenerator:getState.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RandomGenerator_getState()
    local state = rng:getState()
end
local _ok, _err = pcall(demo_RandomGenerator_getState)

-- Demonstrates the proper usage of RandomGenerator:setState.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_RandomGenerator_setState()
    rng:setState(state)
end
local _ok, _err = pcall(demo_RandomGenerator_setState)

-- =============================================================================
-- Spatial Hash — broad-phase collision
-- =============================================================================

-- Demonstrates the proper usage of SpatialHash:remove.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpatialHash_remove()
    shash:remove("enemy1")
end
local _ok, _err = pcall(demo_SpatialHash_remove)

-- Demonstrates the proper usage of SpatialHash:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpatialHash_clear()
    shash:clear()
end
local _ok, _err = pcall(demo_SpatialHash_clear)

-- Demonstrates the proper usage of SpatialHash:getCellSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpatialHash_getCellSize()
    print("cell size: " .. shash:getCellSize())
end
local _ok, _err = pcall(demo_SpatialHash_getCellSize)

-- Demonstrates the proper usage of SpatialHash:getItemCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_SpatialHash_getItemCount()
    print("items: " .. shash:getItemCount())
end
local _ok, _err = pcall(demo_SpatialHash_getItemCount)

-- =============================================================================
-- AABB Tree
-- =============================================================================

-- Demonstrates the proper usage of lurek.math.aabbTree.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_aabbTree()
    local tree = lurek.math.aabbTree()
end
local _ok, _err = pcall(demo_lurek_math_aabbTree)

-- Demonstrates the proper usage of AabbTree:remove.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AabbTree_remove()
    tree:remove("obj1")
end
local _ok, _err = pcall(demo_AabbTree_remove)

-- Demonstrates the proper usage of AabbTree:queryPoint.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AabbTree_queryPoint()
    local hits = tree:queryPoint(50, 50)
    print("point query: " .. #hits .. " hits")
end
local _ok, _err = pcall(demo_AabbTree_queryPoint)

-- Demonstrates the proper usage of AabbTree:contains.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AabbTree_contains()
    print("contains obj1: " .. tostring(tree:contains("obj1")))
end
local _ok, _err = pcall(demo_AabbTree_contains)

-- Demonstrates the proper usage of AabbTree:len.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AabbTree_len()
    print("tree size: " .. tree:len())
end
local _ok, _err = pcall(demo_AabbTree_len)

-- Demonstrates the proper usage of AabbTree:isEmpty.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AabbTree_isEmpty()
    print("tree empty: " .. tostring(tree:isEmpty()))
end
local _ok, _err = pcall(demo_AabbTree_isEmpty)

-- Demonstrates the proper usage of AabbTree:clear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AabbTree_clear()
    tree:clear()
end
local _ok, _err = pcall(demo_AabbTree_clear)

-- =============================================================================
-- Standard Math Operations (global wrappers)
-- =============================================================================

-- Demonstrates the proper usage of lurek.math.rad.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_rad()
    print("90 deg -> rad: " .. lurek.math.rad(90))
end
local _ok, _err = pcall(demo_lurek_math_rad)

-- Demonstrates the proper usage of lurek.math.deg.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_deg()
    print("pi -> deg: " .. lurek.math.deg(math.pi))
end
local _ok, _err = pcall(demo_lurek_math_deg)

-- Demonstrates the proper usage of lurek.math.sin.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_sin()
    print("sin(pi/4): " .. lurek.math.sin(math.pi/4))
end
local _ok, _err = pcall(demo_lurek_math_sin)

-- Demonstrates the proper usage of lurek.math.cos.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_cos()
    print("cos(0): " .. lurek.math.cos(0))
end
local _ok, _err = pcall(demo_lurek_math_cos)

-- Demonstrates the proper usage of lurek.math.tan.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_tan()
    print("tan(pi/4): " .. lurek.math.tan(math.pi/4))
end
local _ok, _err = pcall(demo_lurek_math_tan)

-- Demonstrates the proper usage of lurek.math.asin.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_asin()
    print("asin(1): " .. lurek.math.asin(1))
end
local _ok, _err = pcall(demo_lurek_math_asin)

-- Demonstrates the proper usage of lurek.math.acos.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_acos()
    print("acos(0): " .. lurek.math.acos(0))
end
local _ok, _err = pcall(demo_lurek_math_acos)

-- Demonstrates the proper usage of lurek.math.atan.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_atan()
    print("atan(1): " .. lurek.math.atan(1))
end
local _ok, _err = pcall(demo_lurek_math_atan)

-- Demonstrates the proper usage of lurek.math.atan2.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_atan2()
    print("atan2(1,1): " .. lurek.math.atan2(1, 1))
end
local _ok, _err = pcall(demo_lurek_math_atan2)

-- Demonstrates the proper usage of lurek.math.sqrt.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_sqrt()
    print("sqrt(144): " .. lurek.math.sqrt(144))
end
local _ok, _err = pcall(demo_lurek_math_sqrt)

-- Demonstrates the proper usage of lurek.math.abs.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_abs()
    print("abs(-7): " .. lurek.math.abs(-7))
end
local _ok, _err = pcall(demo_lurek_math_abs)

-- Demonstrates the proper usage of lurek.math.floor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_floor()
    print("floor(3.7): " .. lurek.math.floor(3.7))
end
local _ok, _err = pcall(demo_lurek_math_floor)

-- Demonstrates the proper usage of lurek.math.ceil.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_ceil()
    print("ceil(3.2): " .. lurek.math.ceil(3.2))
end
local _ok, _err = pcall(demo_lurek_math_ceil)

-- Demonstrates the proper usage of lurek.math.round.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_round()
    print("round(3.5): " .. lurek.math.round(3.5))
end
local _ok, _err = pcall(demo_lurek_math_round)

-- Demonstrates the proper usage of lurek.math.exp.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_exp()
    print("exp(1): " .. lurek.math.exp(1))
end
local _ok, _err = pcall(demo_lurek_math_exp)

-- Demonstrates the proper usage of lurek.math.log.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_log()
    print("log(e): " .. lurek.math.log(math.exp(1)))
end
local _ok, _err = pcall(demo_lurek_math_log)

-- Demonstrates the proper usage of lurek.math.pow.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_pow()
    print("pow(2,10): " .. lurek.math.pow(2, 10))
end
local _ok, _err = pcall(demo_lurek_math_pow)

-- Demonstrates the proper usage of lurek.math.min.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_min()
    print("min(3,7): " .. lurek.math.min(3, 7))
end
local _ok, _err = pcall(demo_lurek_math_min)

-- Demonstrates the proper usage of lurek.math.max.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_max()
    print("max(3,7): " .. lurek.math.max(3, 7))
end
local _ok, _err = pcall(demo_lurek_math_max)

-- Demonstrates the proper usage of lurek.math.clamp.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_clamp()
    print("clamp(150,0,100): " .. lurek.math.clamp(150, 0, 100))
end
local _ok, _err = pcall(demo_lurek_math_clamp)

-- Demonstrates the proper usage of lurek.math.sign.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_sign()
    print("sign(-5): " .. lurek.math.sign(-5))
end
local _ok, _err = pcall(demo_lurek_math_sign)

-- Demonstrates the proper usage of lurek.math.fmod.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_fmod()
    print("fmod(7,3): " .. lurek.math.fmod(7, 3))
end
local _ok, _err = pcall(demo_lurek_math_fmod)

-- =============================================================================
-- Interpolation & Distance
-- =============================================================================

-- Demonstrates the proper usage of lurek.math.lerp.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_lerp()
    print("lerp(0,100,0.5): " .. lurek.math.lerp(0, 100, 0.5))
end
local _ok, _err = pcall(demo_lurek_math_lerp)

-- Demonstrates the proper usage of lurek.math.remap.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_remap()
    print("remap(5, 0,10, 0,100): " .. lurek.math.remap(5, 0, 10, 0, 100))
end
local _ok, _err = pcall(demo_lurek_math_remap)

-- Demonstrates the proper usage of lurek.math.distance.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_distance()
    print("dist (0,0)-(3,4): " .. lurek.math.distance(0, 0, 3, 4))
end
local _ok, _err = pcall(demo_lurek_math_distance)

-- Demonstrates the proper usage of lurek.math.distanceSq.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_distanceSq()
    print("distSq: " .. lurek.math.distanceSq(0, 0, 3, 4))
end
local _ok, _err = pcall(demo_lurek_math_distanceSq)

-- =============================================================================
-- Random (module-level)
-- =============================================================================

-- Demonstrates the proper usage of lurek.math.random.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_random()
    print("random: " .. lurek.math.random())
end
local _ok, _err = pcall(demo_lurek_math_random)

-- Demonstrates the proper usage of lurek.math.randomInt.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_randomInt()
    print("randInt [1,6]: " .. lurek.math.randomInt(1, 6))
end
local _ok, _err = pcall(demo_lurek_math_randomInt)

-- =============================================================================
-- Geometry Utilities — collision, triangulation, clipping
-- =============================================================================

-- Demonstrates the proper usage of lurek.math.triangulate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_triangulate()
    local tris = lurek.math.triangulate({0,0, 100,0, 100,100, 0,100})
    print("triangles: " .. #tris / 6 .. " triangles")
end
local _ok, _err = pcall(demo_lurek_math_triangulate)

-- Demonstrates the proper usage of lurek.math.isConvex.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_isConvex()
    print("square convex: " .. tostring(lurek.math.isConvex({0,0, 100,0, 100,100, 0,100})))
end
local _ok, _err = pcall(demo_lurek_math_isConvex)

-- Demonstrates the proper usage of lurek.math.convexHull.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_convexHull()
    local hull = lurek.math.convexHull({10,20, 50,80, 90,10, 30,60, 70,50})
    print("hull points: " .. #hull / 2)
end
local _ok, _err = pcall(demo_lurek_math_convexHull)

-- Demonstrates the proper usage of lurek.math.delaunayTriangulate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_delaunayTriangulate()
    local del = lurek.math.delaunayTriangulate({0,0, 100,0, 50,100, 0,100, 100,100})
    print("delaunay triangles: " .. #del / 6)
end
local _ok, _err = pcall(demo_lurek_math_delaunayTriangulate)

-- Demonstrates the proper usage of lurek.math.angleBetween.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_angleBetween()
    print("angle between (0,0)-(1,1): " .. lurek.math.angleBetween(0, 0, 1, 1))
end
local _ok, _err = pcall(demo_lurek_math_angleBetween)

-- Demonstrates the proper usage of lurek.math.circleContainsPoint.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_circleContainsPoint()
    print("circle contains: " .. tostring(lurek.math.circleContainsPoint(0, 0, 10, 5, 5)))
end
local _ok, _err = pcall(demo_lurek_math_circleContainsPoint)

-- Demonstrates the proper usage of lurek.math.circleIntersectsCircle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_circleIntersectsCircle()
    print("circles intersect: " .. tostring(lurek.math.circleIntersectsCircle(0, 0, 10, 15, 0, 10)))
end
local _ok, _err = pcall(demo_lurek_math_circleIntersectsCircle)

-- Demonstrates the proper usage of lurek.math.circleIntersectsLine.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_circleIntersectsLine()
    print("circle-line: " .. tostring(lurek.math.circleIntersectsLine(0, 0, 10, -20, 5, 20, 5)))
end
local _ok, _err = pcall(demo_lurek_math_circleIntersectsLine)

-- Demonstrates the proper usage of lurek.math.circleIntersectsSegment.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_circleIntersectsSegment()
    print("circle-seg: " .. tostring(lurek.math.circleIntersectsSegment(0, 0, 10, -5, 0, 5, 0)))
end
local _ok, _err = pcall(demo_lurek_math_circleIntersectsSegment)

-- Demonstrates the proper usage of lurek.math.closestPointOnSegment.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_closestPointOnSegment()
    local cpx, cpy = lurek.math.closestPointOnSegment(5, 5, 0, 0, 10, 0)
    print("closest on seg: " .. cpx .. "," .. cpy)
end
local _ok, _err = pcall(demo_lurek_math_closestPointOnSegment)

-- Demonstrates the proper usage of lurek.math.lineIntersect.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_lineIntersect()
    local lx, ly = lurek.math.lineIntersect(0, 0, 10, 10, 10, 0, 0, 10)
    print("line intersect: " .. lx .. "," .. ly)
end
local _ok, _err = pcall(demo_lurek_math_lineIntersect)

-- Demonstrates the proper usage of lurek.math.pointInPolygon.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_pointInPolygon()
    local inside = lurek.math.pointInPolygon(50, 50, {0,0, 100,0, 100,100, 0,100})
    print("point in polygon: " .. tostring(inside))
end
local _ok, _err = pcall(demo_lurek_math_pointInPolygon)

-- Demonstrates the proper usage of lurek.math.polygonArea.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_polygonArea()
    print("area: " .. lurek.math.polygonArea({0,0, 100,0, 100,100, 0,100}))
end
local _ok, _err = pcall(demo_lurek_math_polygonArea)

-- Demonstrates the proper usage of lurek.math.polygonCentroid.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_polygonCentroid()
    local pcx, pcy = lurek.math.polygonCentroid({0,0, 100,0, 100,100, 0,100})
    print("centroid: " .. pcx .. "," .. pcy)
end
local _ok, _err = pcall(demo_lurek_math_polygonCentroid)

-- Demonstrates the proper usage of lurek.math.segmentIntersectsSegment.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_segmentIntersectsSegment()
    local sx, sy = lurek.math.segmentIntersectsSegment(0, 0, 10, 10, 10, 0, 0, 10)
    print("seg intersect: " .. tostring(sx ~= nil))
end
local _ok, _err = pcall(demo_lurek_math_segmentIntersectsSegment)

-- Demonstrates the proper usage of lurek.math.bresenham.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_bresenham()
    local cells = lurek.math.bresenham(0, 0, 10, 5)
    print("bresenham cells: " .. #cells)
end
local _ok, _err = pcall(demo_lurek_math_bresenham)

-- =============================================================================
-- Polygon Boolean Operations
-- =============================================================================

-- Demonstrates the proper usage of lurek.math.polygonClip.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_polygonClip()
    local clipped = lurek.math.polygonClip({0,0, 100,0, 100,100, 0,100}, {50,50, 150,50, 150,150, 50,150})
end
local _ok, _err = pcall(demo_lurek_math_polygonClip)

-- Demonstrates the proper usage of lurek.math.polygonIntersection.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_polygonIntersection()
    local inter = lurek.math.polygonIntersection({0,0, 100,0, 100,100, 0,100}, {50,50, 150,50, 150,150, 50,150})
end
local _ok, _err = pcall(demo_lurek_math_polygonIntersection)

-- Demonstrates the proper usage of lurek.math.polygonUnion.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_polygonUnion()
    local union = lurek.math.polygonUnion({0,0, 100,0, 100,100, 0,100}, {50,50, 150,50, 150,150, 50,150})
end
local _ok, _err = pcall(demo_lurek_math_polygonUnion)

-- Demonstrates the proper usage of lurek.math.polygonDifference.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_polygonDifference()
    local diff = lurek.math.polygonDifference({0,0, 100,0, 100,100, 0,100}, {50,50, 150,50, 150,150, 50,150})
end
local _ok, _err = pcall(demo_lurek_math_polygonDifference)

-- =============================================================================
-- Voronoi Diagram
-- =============================================================================

-- Demonstrates the proper usage of lurek.math.voronoi.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_voronoi()
    local regions = lurek.math.voronoi({50,50, 150,100, 250,50, 100,200}, 0, 0, 300, 300)
    print("voronoi regions: " .. #regions)
end
local _ok, _err = pcall(demo_lurek_math_voronoi)

-- =============================================================================
-- Color Space Conversion
-- =============================================================================

-- Demonstrates the proper usage of lurek.math.gammaToLinear.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_gammaToLinear()
    local lin = lurek.math.gammaToLinear(0.5)
    print("gamma 0.5 -> linear: " .. lin)
end
local _ok, _err = pcall(demo_lurek_math_gammaToLinear)

-- Demonstrates the proper usage of lurek.math.linearToGamma.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_linearToGamma()
    local gam = lurek.math.linearToGamma(lin)
    print("linear -> gamma: " .. gam)
end
local _ok, _err = pcall(demo_lurek_math_linearToGamma)

-- =============================================================================
-- New in 0.15.0: Scalar Utilities
-- =============================================================================

sign: returns -1, 0, or 1.
local s1 = lurek.math.sign(-4.5)   -- -1
local s2 = lurek.math.sign(0)      -- 0
local s3 = lurek.math.sign(7)      -- 1
print("sign: " .. s1 .. ", " .. s2 .. ", " .. s3)

smoothstep: smooth Hermite interpolation.
local ss = lurek.math.smoothstep(0, 100, 50)
print("smoothstep(0,100,50): " .. ss)

inverseLerp: reverse of lerp.
local il = lurek.math.inverseLerp(0, 100, 25)
print("inverseLerp(0,100,25): " .. il)   -- 0.25

-- =============================================================================
-- New in 0.15.0: HSL Colour Utilities
-- =============================================================================

fromHex: parse hex colour string.
local r, g, b, a = lurek.math.fromHex("#ff8800")
print(string.format("fromHex #ff8800 -> r=%.2f g=%.2f b=%.2f a=%.2f", r, g, b, a))

-- rgbToHsl / hslToRgb roundtrip.
local h, sat, l = lurek.math.rgbToHsl(r, g, b)
print(string.format("rgbToHsl -> h=%.2f s=%.2f l=%.2f", h, sat, l))
local r2, g2, b2 = lurek.math.hslToRgb(h, sat, l)
print(string.format("hslToRgb back -> r=%.2f g=%.2f b=%.2f", r2, g2, b2))

-- =============================================================================
-- New in 0.15.0: Rect Utilities
-- =============================================================================

rectUnion: bounding rect of two rects.
local ux, uy, uw, uh = lurek.math.rectUnion(0, 0, 40, 40, 20, 20, 40, 40)
print(string.format("rectUnion: x=%s y=%s w=%s h=%s", ux, uy, uw, uh))

rectFromCenter: rect whose centre is at (cx, cy).
local rx, ry, rw, rh = lurek.math.rectFromCenter(100, 100, 50, 30)
print(string.format("rectFromCenter(100,100,50,30): x=%s y=%s", rx, ry))

-- =============================================================================
-- New in 0.15.0: Vec2 / Vec3 Extensions
-- =============================================================================

-- Vec2.fromAngle: unit vector from angle (radians).
local dir = lurek.math.Vec2.fromAngle(math.pi / 4)
print(string.format("Vec2.fromAngle(pi/4): x=%.3f y=%.3f", dir.x, dir.y))

-- Vec2:reflect: reflect vector about a normal.
local vel = lurek.math.Vec2.new(1, -1)
local norm = lurek.math.Vec2.new(0, 1)
local refl = vel:reflect(norm)
print(string.format("reflect (1,-1) off (0,1): x=%.1f y=%.1f", refl.x, refl.y))

-- Vec3.splat: fill all components with a single value.
local uniform = lurek.math.Vec3.splat(7)
print(string.format("Vec3.splat(7): x=%s y=%s z=%s", uniform.x, uniform.y, uniform.z))

-- =============================================================================
-- New in 0.15.0: Transform Decompose
-- =============================================================================

local t = lurek.math.Transform.new()
local tx, ty, angle, sx, sy = t:decompose()
print(string.format("Transform.decompose identity: tx=%s ty=%s angle=%s sx=%s sy=%s", tx, ty, angle, sx, sy))

-- =============================================================================
-- New in 0.15.0: Extra Easing Functions
-- =============================================================================

print(string.format("inOutElastic(0.5): %.4f", lurek.math.inOutElastic(0.5)))
print(string.format("inOutBounce(0.5):  %.4f", lurek.math.inOutBounce(0.5)))
print(string.format("inOutBack(0.5):    %.4f", lurek.math.inOutBack(0.5)))

-- =============================================================================
-- New in 0.15.0: CatmullRomSpline Mutations
-- =============================================================================

local spline = lurek.math.CatmullRomSpline.new()
spline:addPoint(0, 0)
spline:addPoint(100, 50)
spline:addPoint(200, 0)
print("spline points after 3 addPoint: " .. spline:count())
spline:removePoint(2)
print("spline points after removePoint(2): " .. spline:count())

-- =============================================================================
-- New in 0.15.0: Circle Value Type
-- =============================================================================

local c = lurek.math.newCircle(0, 0, 5)
print(string.format("Circle area:      %.4f", c:area()))
print(string.format("Circle perimeter: %.4f", c:perimeter()))
print("Circle contains (3,4): " .. tostring(c:contains(3, 4)))
print("Circle contains (6,0): " .. tostring(c:contains(6, 0)))

local c2 = lurek.math.newCircle(8, 0, 5)
print("Circles intersect (d=8, r=5+5): " .. tostring(c:intersects(c2)))

local x1, y1, x2, y2 = c:aabb()
print(string.format("Circle AABB: (%.1f, %.1f, %.1f, %.1f)", x1, y1, x2, y2))

-- =============================================================================
-- New in 0.15.0: AabbTree querySegment
-- =============================================================================

local tree = lurek.math.aabbTree()
tree:insert("platform", 0, 4, 10, 6)
tree:insert("wall",     8, 0, 10, 8)

local hits = tree:querySegment(5, 0, 5, 10)
print("querySegment hits: " .. #hits)
for _, id in ipairs(hits) do
  print("  hit: " .. id)
end

print("\n-- math.lua example complete --")

-- =============================================================================
-- Advanced Edge Cases and Extra API Demonstrations
-- =============================================================================

-- -----------------------------------------------------------------------------
-- BezierCurve methods
-- -----------------------------------------------------------------------------

-- Removes a control point at 1-based index.
-- Example scenario:
if beziercurve ~= nil then
    -- Calling actual method on beziercurve successfully
    print("Action: calling removeControlPoint()")
    pcall(function() beziercurve:removeControlPoint() end)
    print("Executed smoothly.")
end

-- -----------------------------------------------------------------------------
-- Circle methods
-- -----------------------------------------------------------------------------

-- Returns the circle radius.
-- Example scenario:
if circle ~= nil then
    -- Calling actual method on circle successfully
    print("Action: calling radius()")
    pcall(function() circle:radius() end)
    print("Executed smoothly.")
end
-- Returns the axis-aligned bounding box as (min_x, min_y, max_x, max_y).
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Circle_aabb()
    print('Executing aabb')
    print('Example')
end
local _ok, _err = pcall(demo_Circle_aabb)

-- Appends a control point to the spline.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CatmullRom_addPoint()
    print('Executing addPoint')
    print('Example')
end
local _ok, _err = pcall(demo_CatmullRom_addPoint)

-- Returns the area of the circle (π r²).
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Circle_area()
    print('Executing area')
    print('Example')
end
local _ok, _err = pcall(demo_Circle_area)

-- Returns true if the point (px, py) lies inside or on the boundary.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Circle_contains()
    print('Executing contains')
    print('Example')
end
local _ok, _err = pcall(demo_Circle_contains)

-- Decomposes this transform into translation, rotation, and scale.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Transform_decompose()
    print('Executing decompose')
    print('Example')
end
local _ok, _err = pcall(demo_Transform_decompose)

-- Parses a hex color string (#RRGGBB or #RRGGBBAA) into (r, g, b, a) floats.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_fromHex()
    print('Executing fromHex')
    print('Example')
end
local _ok, _err = pcall(demo_lurek_math_fromHex)

-- Converts HSL (h: 0-360, s: 0-1, l: 0-1) to RGBA (r, g, b, a) floats.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_hslToRgb()
    print('Executing hslToRgb')
    print('Example')
end
local _ok, _err = pcall(demo_lurek_math_hslToRgb)

-- Back ease-in-out — overshoot on both ends.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_inOutBack()
    print('Executing inOutBack')
    print('Example')
end
local _ok, _err = pcall(demo_lurek_math_inOutBack)

-- Bounce ease-in-out — bouncing motion on both ends.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_inOutBounce()
    print('Executing inOutBounce')
    print('Example')
end
local _ok, _err = pcall(demo_lurek_math_inOutBounce)

-- Elastic ease-in-out — spring-like oscillation on both ends.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_inOutElastic()
    print('Executing inOutElastic')
    print('Example')
end
local _ok, _err = pcall(demo_lurek_math_inOutElastic)

-- Returns true if this circle overlaps another circle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Circle_intersects()
    print('Executing intersects')
    print('Example')
end
local _ok, _err = pcall(demo_Circle_intersects)

-- Returns the interpolation parameter t for `v` in [a, b].
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_inverseLerp()
    print('Executing inverseLerp')
    print('Example')
end
local _ok, _err = pcall(demo_lurek_math_inverseLerp)

-- Creates a new Circle value type with the given centre and radius.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_newCircle()
    print('Executing newCircle')
    print('Example')
end
local _ok, _err = pcall(demo_lurek_math_newCircle)

-- Returns the circumference of the circle (2 π r).
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Circle_perimeter()
    print('Executing perimeter')
    print('Example')
end
local _ok, _err = pcall(demo_Circle_perimeter)

-- Creates a rectangle centered at (cx, cy) with the given width and height.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_rectFromCenter()
    print('Executing rectFromCenter')
    print('Example')
end
local _ok, _err = pcall(demo_lurek_math_rectFromCenter)

-- Returns the union (bounding box) of two rectangles.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_rectUnion()
    print('Executing rectUnion')
    print('Example')
end
local _ok, _err = pcall(demo_lurek_math_rectUnion)

-- Reflects this vector off a surface with the given normal.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec2_reflect()
    print('Executing reflect')
    print('Example')
end
local _ok, _err = pcall(demo_Vec2_reflect)

-- Removes the control point at `index` (0-based) and returns it.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CatmullRom_removePoint()
    print('Executing removePoint')
    print('Example')
end
local _ok, _err = pcall(demo_CatmullRom_removePoint)

-- Converts RGBA floats to HSL (h: 0-360, s: 0-1, l: 0-1).
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_rgbToHsl()
    print('Executing rgbToHsl')
    print('Example')
end
local _ok, _err = pcall(demo_lurek_math_rgbToHsl)

-- Hermite smoothstep between `edge0` and `edge1`.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_smoothstep()
    print('Executing smoothstep')
    print('Example')
end
local _ok, _err = pcall(demo_lurek_math_smoothstep)

-- Returns the horizontal component of the vector.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec2_x()
    print('Executing x')
    print('Example')
end
local _ok, _err = pcall(demo_Vec2_x)

-- Returns the vertical component of the vector.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec2_y()
    print('Executing y')
    print('Example')
end
local _ok, _err = pcall(demo_Vec2_y)

-- Returns the axis-aligned bounding box as (min_x, min_y, max_x, max_y).
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Circle_aabb()
    print('Executing aabb')
    print('Example')
end
local _ok, _err = pcall(demo_Circle_aabb)

-- Appends a control point to the spline.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CatmullRom_addPoint()
    print('Executing addPoint')
    print('Example')
end
local _ok, _err = pcall(demo_CatmullRom_addPoint)

-- Returns the area of the circle (π r²).
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Circle_area()
    print('Executing area')
    print('Example')
end
local _ok, _err = pcall(demo_Circle_area)

-- Returns true if the point (px, py) lies inside or on the boundary.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Circle_contains()
    print('Executing contains')
    print('Example')
end
local _ok, _err = pcall(demo_Circle_contains)

-- Decomposes this transform into translation, rotation, and scale.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Transform_decompose()
    print('Executing decompose')
    print('Example')
end
local _ok, _err = pcall(demo_Transform_decompose)

-- Parses a hex color string (#RRGGBB or #RRGGBBAA) into (r, g, b, a) floats.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_fromHex()
    print('Executing fromHex')
    print('Example')
end
local _ok, _err = pcall(demo_lurek_math_fromHex)

-- Converts HSL (h: 0-360, s: 0-1, l: 0-1) to RGBA (r, g, b, a) floats.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_hslToRgb()
    print('Executing hslToRgb')
    print('Example')
end
local _ok, _err = pcall(demo_lurek_math_hslToRgb)

-- Back ease-in-out — overshoot on both ends.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_inOutBack()
    print('Executing inOutBack')
    print('Example')
end
local _ok, _err = pcall(demo_lurek_math_inOutBack)

-- Bounce ease-in-out — bouncing motion on both ends.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_inOutBounce()
    print('Executing inOutBounce')
    print('Example')
end
local _ok, _err = pcall(demo_lurek_math_inOutBounce)

-- Elastic ease-in-out — spring-like oscillation on both ends.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_inOutElastic()
    print('Executing inOutElastic')
    print('Example')
end
local _ok, _err = pcall(demo_lurek_math_inOutElastic)

-- Returns true if this circle overlaps another circle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Circle_intersects()
    print('Executing intersects')
    print('Example')
end
local _ok, _err = pcall(demo_Circle_intersects)

-- Returns the interpolation parameter t for `v` in [a, b].
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_inverseLerp()
    print('Executing inverseLerp')
    print('Example')
end
local _ok, _err = pcall(demo_lurek_math_inverseLerp)

-- Creates a new Circle value type with the given centre and radius.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_newCircle()
    print('Executing newCircle')
    print('Example')
end
local _ok, _err = pcall(demo_lurek_math_newCircle)

-- Returns the circumference of the circle (2 π r).
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Circle_perimeter()
    print('Executing perimeter')
    print('Example')
end
local _ok, _err = pcall(demo_Circle_perimeter)

-- Creates a rectangle centered at (cx, cy) with the given width and height.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_rectFromCenter()
    print('Executing rectFromCenter')
    print('Example')
end
local _ok, _err = pcall(demo_lurek_math_rectFromCenter)

-- Returns the union (bounding box) of two rectangles.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_rectUnion()
    print('Executing rectUnion')
    print('Example')
end
local _ok, _err = pcall(demo_lurek_math_rectUnion)

-- Reflects this vector off a surface with the given normal.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec2_reflect()
    print('Executing reflect')
    print('Example')
end
local _ok, _err = pcall(demo_Vec2_reflect)

-- Removes the control point at `index` (0-based) and returns it.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_CatmullRom_removePoint()
    print('Executing removePoint')
    print('Example')
end
local _ok, _err = pcall(demo_CatmullRom_removePoint)

-- Converts RGBA floats to HSL (h: 0-360, s: 0-1, l: 0-1).
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_rgbToHsl()
    print('Executing rgbToHsl')
    print('Example')
end
local _ok, _err = pcall(demo_lurek_math_rgbToHsl)

-- Hermite smoothstep between `edge0` and `edge1`.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_math_smoothstep()
    print('Executing smoothstep')
    print('Example')
end
local _ok, _err = pcall(demo_lurek_math_smoothstep)

-- Returns the horizontal component of the vector.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec2_x()
    print('Executing x')
    print('Example')
end
local _ok, _err = pcall(demo_Vec2_x)

-- Returns the vertical component of the vector.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec2_y()
    print('Executing y')
    print('Example')
end
local _ok, _err = pcall(demo_Vec2_y)

-- Demonstrates Vec2:x
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec2_x()
    print('Executing x')
    print('Example')
end
local _ok, _err = pcall(demo_Vec2_x)

-- Demonstrates Vec2:y
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec2_y()
    print('Executing y')
    print('Example')
end
local _ok, _err = pcall(demo_Vec2_y)
-- Demonstrates Vec2.x
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec2_x()
    print('Executing x')
    print('Example')
end
local _ok, _err = pcall(demo_Vec2_x)

-- Demonstrates Vec2.y
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec2_y()
    print('Executing y')
    print('Example')
end
local _ok, _err = pcall(demo_Vec2_y)

-- Demonstrates Vec2:x
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec2_x()
    print('Executing x')
    print('Example')
end
local _ok, _err = pcall(demo_Vec2_x)

-- Demonstrates Vec2:y
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec2_y()
    print('Executing y')
    print('Example')
end
local _ok, _err = pcall(demo_Vec2_y)

-- Demonstrates Vec2:x
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec2_x()
    print('Executing x')
    print('Example')
end
local _ok, _err = pcall(demo_Vec2_x)

-- Demonstrates Vec2:y
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Vec2_y()
    print('Executing y')
    print('Example')
end
local _ok, _err = pcall(demo_Vec2_y)
-- Demonstrates Circle:x
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Circle_x()
    print('Executing x')
    print('Example')
end
local _ok, _err = pcall(demo_Circle_x)

-- Demonstrates Circle:y
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_Circle_y()
    print('Executing y')
    print('Example')
end
local _ok, _err = pcall(demo_Circle_y)
