--- Light Module: LLight:remove, LOccluder:remove, lurek.light functions

--@api-stub: LLight:remove
-- Remove a dynamic light from the scene.
do
    local lt = lurek.light.newLight(200, 300, 150)
    local r, g, b, a = lurek.light.getAmbient()
    print("ambient", r, g, b, a)
    local count = lurek.light.getLightCount()
    print("lights = " .. count)
    lt:remove()
    local count2 = lurek.light.getLightCount()
    print("after remove = " .. count2)
end

--@api-stub: LOccluder:remove
-- Remove an occluder from the scene.
do
    local vtbl = { 0, 0, 100, 0, 100, 100, 0, 100 }
    local occ = lurek.light.newOccluder(vtbl)
    local n = lurek.light.getOccluderCount()
    print("occluders = " .. n)
    occ:remove()
    local n2 = lurek.light.getOccluderCount()
    print("after remove = " .. n2)
end

--@api-stub: lurek.light.getAmbient
--@api-stub: lurek.light.isEnabled
--@api-stub: lurek.light.setMaxLights
-- Ambient color, max lights cap, and enabled state queries.
do
    local r, g, b, a = lurek.light.getAmbient()
    print("ambient", r, g, b, a)
    local mx = lurek.light.getMaxLights()
    print("max lights = " .. mx)
    local enabled = lurek.light.isEnabled()
    print("enabled = " .. tostring(enabled))
    lurek.light.setMaxLights(64)
    lurek.light.setEnabled(true)
    local r2, g2, b2, a2 = lurek.light.getAmbient()
    print("ambient2", r2, g2, b2, a2)
end

print("light_02.lua")
