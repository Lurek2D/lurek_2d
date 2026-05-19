--- Parallax Module Part 2: layer type, set type

--@api-stub: LParallaxLayer:type
-- Type introspection on LParallaxLayer.
do
    local img = lurek.render.newImage("assets/textures/ray_water.png")
    local layer = lurek.parallax.newLayer({ image = img, scroll_factor = 0.5, z = -1 })
    print(layer:type())
end

--@api-stub: LParallaxSet:type
-- Type introspection on LParallaxSet.
do
    local set = lurek.parallax.newSet("bg_set")
    print(set:type())
end

print("parallax_02.lua")
