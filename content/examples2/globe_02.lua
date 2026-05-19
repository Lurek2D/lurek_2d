--- Globe Module: LGlobeRegistry methods

--@api-stub: LGlobeRegistry:get
--@api-stub: LGlobeRegistry:names
--@api-stub: LGlobeRegistry:new
--@api-stub: LGlobeRegistry:remove
--@api-stub: LGlobeRegistry:type
--@api-stub: LGlobeRegistry:typeOf
-- Globe registry: look up, create, remove, and type-check globe entries.
do
    ---@type LGlobeRegistry?
    local reg = nil
    if reg then
        local globe = reg:get("earth")
        local all_names = reg:names()
        for _, n in ipairs(all_names) do print(n) end
        local g2 = reg:new("mars", { radius = 1.0, subdivisions = 3 })
        reg:remove("mars")
        print(reg:type())
        print(reg:typeOf("LGlobeRegistry"))
        print(reg:typeOf("Object"))
    end
end

print("globe_02.lua")
