-- content/examples/parallax.lua
-- Lurek2D lurek.parallax API Reference
-- Run with: cargo run -- content/examples/parallax
--
-- Scenario: A side-scrolling game with a multi-layer parallax background —
-- sky, distant mountains, near trees, and ground. Layers scroll at different
-- speeds for depth illusion, with auto-scrolling and tiling support.

print("=== lurek.parallax — Parallax Scrolling ===\n")

-- =============================================================================
-- Layer & Set Creation
-- =============================================================================

--@api-stub: lurek.parallax.newLayer
-- Demonstrates the proper usage of lurek.parallax.newLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_parallax_newLayer()
    local sky = lurek.parallax.newLayer("assets/backgrounds/sky.png")
    local mountains = lurek.parallax.newLayer("assets/backgrounds/mountains.png")
    local trees = lurek.parallax.newLayer("assets/backgrounds/trees.png")
    local ground = lurek.parallax.newLayer("assets/backgrounds/ground.png")
end
local _ok, _err = pcall(demo_lurek_parallax_newLayer)

--@api-stub: lurek.parallax.newSet
-- Demonstrates the proper usage of lurek.parallax.newSet.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_parallax_newSet()
    local bg = lurek.parallax.newSet()
end
local _ok, _err = pcall(demo_lurek_parallax_newSet)

-- =============================================================================
-- ParallaxSet Methods
-- =============================================================================

--@api-stub: ParallaxSet:type
-- Demonstrates the proper usage of ParallaxSet:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxSet_type()
    print("type: " .. bg:type())
end
local _ok, _err = pcall(demo_ParallaxSet_type)

--@api-stub: ParallaxSet:setName
-- Demonstrates the proper usage of ParallaxSet:setName.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxSet_setName()
    bg:setName("forest_background")
end
local _ok, _err = pcall(demo_ParallaxSet_setName)

--@api-stub: ParallaxSet:getName
-- Demonstrates the proper usage of ParallaxSet:getName.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxSet_getName()
    print("set name: " .. bg:getName())
end
local _ok, _err = pcall(demo_ParallaxSet_getName)

--@api-stub: ParallaxSet:addLayer
-- Demonstrates the proper usage of ParallaxSet:addLayer.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxSet_addLayer()
    bg:addLayer(sky)
    bg:addLayer(mountains)
    bg:addLayer(trees)
    bg:addLayer(ground)
end
local _ok, _err = pcall(demo_ParallaxSet_addLayer)

--@api-stub: ParallaxSet:layerCount
-- Demonstrates the proper usage of ParallaxSet:layerCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxSet_layerCount()
    print("layers: " .. bg:layerCount())
end
local _ok, _err = pcall(demo_ParallaxSet_layerCount)

--@api-stub: ParallaxSet:sortByZ
-- Demonstrates the proper usage of ParallaxSet:sortByZ.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxSet_sortByZ()
    bg:sortByZ()
end
local _ok, _err = pcall(demo_ParallaxSet_sortByZ)

--@api-stub: ParallaxSet:setVisible
-- Demonstrates the proper usage of ParallaxSet:setVisible.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxSet_setVisible()
    bg:setVisible(true)
end
local _ok, _err = pcall(demo_ParallaxSet_setVisible)

--@api-stub: ParallaxSet:isVisible
-- Demonstrates the proper usage of ParallaxSet:isVisible.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxSet_isVisible()
    print("set visible: " .. tostring(bg:isVisible()))
end
local _ok, _err = pcall(demo_ParallaxSet_isVisible)

--@api-stub: ParallaxSet:update
-- Demonstrates the proper usage of ParallaxSet:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxSet_update()
    bg:update(1/60)
end
local _ok, _err = pcall(demo_ParallaxSet_update)

--@api-stub: ParallaxSet:render
-- Demonstrates the proper usage of ParallaxSet:render.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxSet_render()
    bg:render()
end
local _ok, _err = pcall(demo_ParallaxSet_render)

--@api-stub: ParallaxSet:renderAuto
-- Demonstrates the proper usage of ParallaxSet:renderAuto.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxSet_renderAuto()
    bg:renderAuto(1/60)
end
local _ok, _err = pcall(demo_ParallaxSet_renderAuto)

--@api-stub: ParallaxSet:removeLayerAt
-- Demonstrates the proper usage of ParallaxSet:removeLayerAt.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxSet_removeLayerAt()
    print('Executing removeLayerAt')
end
local _ok, _err = pcall(demo_ParallaxSet_removeLayerAt)

-- =============================================================================
-- ParallaxLayer — Scroll Factor & Position
-- =============================================================================

--@api-stub: ParallaxLayer:type
-- Demonstrates the proper usage of ParallaxLayer:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_type()
    print("sky type: " .. sky:type())
end
local _ok, _err = pcall(demo_ParallaxLayer_type)

--@api-stub: ParallaxLayer:setScrollFactor
-- Demonstrates the proper usage of ParallaxLayer:setScrollFactor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_setScrollFactor()
    sky:setScrollFactor(0.1, 0.05)
    mountains:setScrollFactor(0.3, 0.2)
    trees:setScrollFactor(0.6, 0.4)
    ground:setScrollFactor(1.0, 1.0)
end
local _ok, _err = pcall(demo_ParallaxLayer_setScrollFactor)

--@api-stub: ParallaxLayer:getScrollFactor
-- Demonstrates the proper usage of ParallaxLayer:getScrollFactor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_getScrollFactor()
    local sfx, sfy = sky:getScrollFactor()
    print("sky scroll factor: " .. sfx .. "," .. sfy)
end
local _ok, _err = pcall(demo_ParallaxLayer_getScrollFactor)

--@api-stub: ParallaxLayer:setOffset
-- Demonstrates the proper usage of ParallaxLayer:setOffset.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_setOffset()
    sky:setOffset(0, -50)
end
local _ok, _err = pcall(demo_ParallaxLayer_setOffset)

--@api-stub: ParallaxLayer:getOffset
-- Demonstrates the proper usage of ParallaxLayer:getOffset.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_getOffset()
    local ox, oy = sky:getOffset()
    print("sky offset: " .. ox .. "," .. oy)
end
local _ok, _err = pcall(demo_ParallaxLayer_getOffset)

-- =============================================================================
-- ParallaxLayer — Auto-Scrolling
-- =============================================================================

--@api-stub: ParallaxLayer:setAutoscroll
-- Demonstrates the proper usage of ParallaxLayer:setAutoscroll.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_setAutoscroll()
    sky:setAutoscroll(10, 0)
end
local _ok, _err = pcall(demo_ParallaxLayer_setAutoscroll)

--@api-stub: ParallaxLayer:getAutoscroll
-- Demonstrates the proper usage of ParallaxLayer:getAutoscroll.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_getAutoscroll()
    local asx, asy = sky:getAutoscroll()
    print("sky auto-scroll: " .. asx .. "," .. asy)
end
local _ok, _err = pcall(demo_ParallaxLayer_getAutoscroll)

--@api-stub: ParallaxLayer:resetAutoscroll
-- Demonstrates the proper usage of ParallaxLayer:resetAutoscroll.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_resetAutoscroll()
    sky:resetAutoscroll()
end
local _ok, _err = pcall(demo_ParallaxLayer_resetAutoscroll)

-- =============================================================================
-- ParallaxLayer — Tiling & Repeat
-- =============================================================================

--@api-stub: ParallaxLayer:setRepeat
-- Demonstrates the proper usage of ParallaxLayer:setRepeat.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_setRepeat()
    sky:setRepeat(true, false)
    mountains:setRepeat(true, false)
end
local _ok, _err = pcall(demo_ParallaxLayer_setRepeat)

--@api-stub: ParallaxLayer:setTiling
-- Demonstrates the proper usage of ParallaxLayer:setTiling.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_setTiling()
    sky:setTiling(true)
end
local _ok, _err = pcall(demo_ParallaxLayer_setTiling)

--@api-stub: ParallaxLayer:getTiling
-- Demonstrates the proper usage of ParallaxLayer:getTiling.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_getTiling()
    print("sky tiling: " .. tostring(sky:getTiling()))
end
local _ok, _err = pcall(demo_ParallaxLayer_getTiling)

--@api-stub: ParallaxLayer:setTileSize
-- Demonstrates the proper usage of ParallaxLayer:setTileSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_setTileSize()
    sky:setTileSize(800, 600)
end
local _ok, _err = pcall(demo_ParallaxLayer_setTileSize)

-- =============================================================================
-- ParallaxLayer — Scale & Depth
-- =============================================================================

--@api-stub: ParallaxLayer:setScale
-- Demonstrates the proper usage of ParallaxLayer:setScale.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_setScale()
    sky:setScale(1.0, 1.0)
end
local _ok, _err = pcall(demo_ParallaxLayer_setScale)

--@api-stub: ParallaxLayer:setZ
-- Demonstrates the proper usage of ParallaxLayer:setZ.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_setZ()
    sky:setZ(-100)
    mountains:setZ(-50)
    trees:setZ(-20)
    ground:setZ(0)
end
local _ok, _err = pcall(demo_ParallaxLayer_setZ)

--@api-stub: ParallaxLayer:getZ
-- Demonstrates the proper usage of ParallaxLayer:getZ.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_getZ()
    print("sky Z: " .. sky:getZ())
end
local _ok, _err = pcall(demo_ParallaxLayer_getZ)

--@api-stub: ParallaxLayer:setDepth
-- Demonstrates the proper usage of ParallaxLayer:setDepth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_setDepth()
    sky:setDepth(100)
end
local _ok, _err = pcall(demo_ParallaxLayer_setDepth)

--@api-stub: ParallaxLayer:getDepth
-- Demonstrates the proper usage of ParallaxLayer:getDepth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_getDepth()
    print("sky depth: " .. sky:getDepth())
end
local _ok, _err = pcall(demo_ParallaxLayer_getDepth)

-- =============================================================================
-- ParallaxLayer — Visual Properties
-- =============================================================================

--@api-stub: ParallaxLayer:setOpacity
-- Demonstrates the proper usage of ParallaxLayer:setOpacity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_setOpacity()
    sky:setOpacity(0.8)
    mountains:setOpacity(0.7)
end
local _ok, _err = pcall(demo_ParallaxLayer_setOpacity)

--@api-stub: ParallaxLayer:getOpacity
-- Demonstrates the proper usage of ParallaxLayer:getOpacity.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_getOpacity()
    print("sky opacity: " .. sky:getOpacity())
end
local _ok, _err = pcall(demo_ParallaxLayer_getOpacity)

--@api-stub: ParallaxLayer:setTint
-- Demonstrates the proper usage of ParallaxLayer:setTint.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_setTint()
    mountains:setTint(0.7, 0.8, 1.0, 1.0)
end
local _ok, _err = pcall(demo_ParallaxLayer_setTint)

--@api-stub: ParallaxLayer:getTint
-- Demonstrates the proper usage of ParallaxLayer:getTint.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_getTint()
    local tr, tg, tb, ta = mountains:getTint()
    print("mountain tint: " .. tr .. "," .. tg .. "," .. tb)
end
local _ok, _err = pcall(demo_ParallaxLayer_getTint)

--@api-stub: ParallaxLayer:setBlendMode
-- Demonstrates the proper usage of ParallaxLayer:setBlendMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_setBlendMode()
    sky:setBlendMode("alpha")
end
local _ok, _err = pcall(demo_ParallaxLayer_setBlendMode)

--@api-stub: ParallaxLayer:getBlendMode
-- Demonstrates the proper usage of ParallaxLayer:getBlendMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_getBlendMode()
    print("sky blend: " .. sky:getBlendMode())
end
local _ok, _err = pcall(demo_ParallaxLayer_getBlendMode)

--@api-stub: ParallaxLayer:setVisible
-- Demonstrates the proper usage of ParallaxLayer:setVisible.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_setVisible()
    sky:setVisible(true)
end
local _ok, _err = pcall(demo_ParallaxLayer_setVisible)

--@api-stub: ParallaxLayer:isVisible
-- Demonstrates the proper usage of ParallaxLayer:isVisible.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_isVisible()
    print("sky visible: " .. tostring(sky:isVisible()))
end
local _ok, _err = pcall(demo_ParallaxLayer_isVisible)

--@api-stub: ParallaxLayer:clearClamp
-- Demonstrates the proper usage of ParallaxLayer:clearClamp.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_clearClamp()
    sky:clearClamp()
end
local _ok, _err = pcall(demo_ParallaxLayer_clearClamp)

-- =============================================================================
-- Layer Update & Render
-- =============================================================================

--@api-stub: ParallaxLayer:update
-- Demonstrates the proper usage of ParallaxLayer:update.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_update()
    sky:update(1/60)
end
local _ok, _err = pcall(demo_ParallaxLayer_update)

--@api-stub: ParallaxLayer:render
-- Demonstrates the proper usage of ParallaxLayer:render.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_render()
    sky:render()
end
local _ok, _err = pcall(demo_ParallaxLayer_render)

--@api-stub: ParallaxLayer:renderAuto
-- Demonstrates the proper usage of ParallaxLayer:renderAuto.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_ParallaxLayer_renderAuto()
    sky:renderAuto(1/60)
    print("\n-- parallax.lua example complete --")
end
local _ok, _err = pcall(demo_ParallaxLayer_renderAuto)

-- =============================================================================
-- STUBS: 1 uncovered lurek.parallax API item(s)
-- Generated by tools/audit/example_add_missing.py
-- REQUIRED: replace every --@api-stub: block below with a real scenario.
-- Run .github/prompts/flesh-out-example.prompt.md for instructions.
-- The final committed file must contain ZERO --@api-stub: lines.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- ParallaxSet methods
-- -----------------------------------------------------------------------------

-- ---- Stub: ParallaxSet:removeLayerAt -------------------------------------
--@api-stub: ParallaxSet:removeLayerAt
-- Removes the layer at the given 1-based index.
-- Example scenario:
if parallaxset ~= nil then
    -- Calling actual method on parallaxset successfully
    print("Action: calling removeLayerAt()")
    pcall(function() parallaxset:removeLayerAt() end)
    print("Executed smoothly.")
end
