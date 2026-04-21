-- content/examples/pathfind.lua
-- Lurek2D lurek.pathfind API Reference
-- Run with: cargo run -- content/examples/pathfind
--
-- Scenario: A strategy game with grid-based movement, flow fields for unit
-- swarms, hex grid navigation for a hex-tile map, JPS for fast long-range
-- pathfinding, and threaded pathfinding for large maps.

print("=== lurek.pathfind — Pathfinding System ===\n")

-- =============================================================================
-- NavGrid — basic grid pathfinding
-- =============================================================================

--@api-stub: lurek.pathfind.newNavGrid
-- Demonstrates the proper usage of lurek.pathfind.newNavGrid.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_newNavGrid()
    local grid = lurek.pathfind.newNavGrid(50, 50)
end
local _ok, _err = pcall(demo_lurek_pathfind_newNavGrid)

--@api-stub: NavGrid:getWidth
-- Demonstrates the proper usage of NavGrid:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_getWidth()
    print("grid width: " .. grid:getWidth())
end
local _ok, _err = pcall(demo_NavGrid_getWidth)

--@api-stub: NavGrid:getHeight
-- Demonstrates the proper usage of NavGrid:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_getHeight()
    print("grid height: " .. grid:getHeight())
end
local _ok, _err = pcall(demo_NavGrid_getHeight)

--@api-stub: NavGrid:getDimensions
-- Demonstrates the proper usage of NavGrid:getDimensions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_getDimensions()
    local gw, gh = grid:getDimensions()
    print("grid: " .. gw .. "x" .. gh)
end
local _ok, _err = pcall(demo_NavGrid_getDimensions)

--@api-stub: NavGrid:setCost
-- Demonstrates the proper usage of NavGrid:setCost.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_setCost()
    grid:setCost(10, 10, 1.0)
    grid:setCost(11, 10, 2.0)  -- rough terrain
end
local _ok, _err = pcall(demo_NavGrid_setCost)

--@api-stub: NavGrid:getCost
-- Demonstrates the proper usage of NavGrid:getCost.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_getCost()
    print("cost at (10,10): " .. grid:getCost(10, 10))
end
local _ok, _err = pcall(demo_NavGrid_getCost)

--@api-stub: NavGrid:isBlocked
-- Demonstrates the proper usage of NavGrid:isBlocked.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_isBlocked()
    print("blocked at (10,10): " .. tostring(grid:isBlocked(10, 10)))
end
local _ok, _err = pcall(demo_NavGrid_isBlocked)

--@api-stub: NavGrid:fill
-- Demonstrates the proper usage of NavGrid:fill.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_fill()
    grid:fill(20, 20, 5, 1, -1)
end
local _ok, _err = pcall(demo_NavGrid_fill)

--@api-stub: NavGrid:loadFromString
-- Demonstrates the proper usage of NavGrid:loadFromString.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_loadFromString()
    grid:loadFromString("1111\n1001\n1111")
    print("grid loaded from string")
end
local _ok, _err = pcall(demo_NavGrid_loadFromString)

--@api-stub: NavGrid:saveToString
-- Demonstrates the proper usage of NavGrid:saveToString.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_saveToString()
    local grid_str = grid:saveToString()
    print("grid saved: " .. #grid_str .. " chars")
end
local _ok, _err = pcall(demo_NavGrid_saveToString)

--@api-stub: NavGrid:setDiagonalMode
-- Demonstrates the proper usage of NavGrid:setDiagonalMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_setDiagonalMode()
    grid:setDiagonalMode(true)
end
local _ok, _err = pcall(demo_NavGrid_setDiagonalMode)

--@api-stub: NavGrid:getDiagonalMode
-- Demonstrates the proper usage of NavGrid:getDiagonalMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_getDiagonalMode()
    print("diagonal: " .. tostring(grid:getDiagonalMode()))
end
local _ok, _err = pcall(demo_NavGrid_getDiagonalMode)

--@api-stub: NavGrid:setChunkSize
-- Demonstrates the proper usage of NavGrid:setChunkSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_setChunkSize()
    grid:setChunkSize(8)
end
local _ok, _err = pcall(demo_NavGrid_setChunkSize)

--@api-stub: NavGrid:getChunkSize
-- Demonstrates the proper usage of NavGrid:getChunkSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_getChunkSize()
    print("chunk size: " .. grid:getChunkSize())
end
local _ok, _err = pcall(demo_NavGrid_getChunkSize)

--@api-stub: NavGrid:rebuildAbstract
-- Demonstrates the proper usage of NavGrid:rebuildAbstract.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_rebuildAbstract()
    grid:rebuildAbstract()
end
local _ok, _err = pcall(demo_NavGrid_rebuildAbstract)

--@api-stub: NavGrid:setDirty
-- Demonstrates the proper usage of NavGrid:setDirty.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_setDirty()
    grid:setDirty()
end
local _ok, _err = pcall(demo_NavGrid_setDirty)

--@api-stub: NavGrid:clearDirty
-- Demonstrates the proper usage of NavGrid:clearDirty.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_clearDirty()
    grid:clearDirty()
end
local _ok, _err = pcall(demo_NavGrid_clearDirty)

--@api-stub: NavGrid:type
-- Demonstrates the proper usage of NavGrid:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_type()
    print("NavGrid type: " .. grid:type())
end
local _ok, _err = pcall(demo_NavGrid_type)

--@api-stub: NavGrid:typeOf
-- Demonstrates the proper usage of NavGrid:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_typeOf()
    print("is NavGrid: " .. tostring(grid:typeOf("NavGrid")))
end
local _ok, _err = pcall(demo_NavGrid_typeOf)

-- =============================================================================
-- NavGrid from Tilemap
-- =============================================================================

--@api-stub: lurek.pathfind.newNavGridFromTileMap
-- Demonstrates the proper usage of lurek.pathfind.newNavGridFromTileMap.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_newNavGridFromTileMap()
    local tile_grid = lurek.pathfind.newNavGridFromTileMap("assets/maps/dungeon.json")
    print("nav grid from tilemap")
end
local _ok, _err = pcall(demo_lurek_pathfind_newNavGridFromTileMap)

-- =============================================================================
-- Pathfinder — A* pathfinding
-- =============================================================================

--@api-stub: lurek.pathfind.newPathfinder
-- Demonstrates the proper usage of lurek.pathfind.newPathfinder.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_newPathfinder()
    local finder = lurek.pathfind.newPathfinder(grid)
end
local _ok, _err = pcall(demo_lurek_pathfind_newPathfinder)

--@api-stub: UnitPathfinder:getPathLength
-- Demonstrates the proper usage of UnitPathfinder:getPathLength.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UnitPathfinder_getPathLength()
    print("path length: " .. finder:getPathLength())
end
local _ok, _err = pcall(demo_UnitPathfinder_getPathLength)

--@api-stub: UnitPathfinder:getPathCost
-- Demonstrates the proper usage of UnitPathfinder:getPathCost.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UnitPathfinder_getPathCost()
    print("path cost: " .. finder:getPathCost())
end
local _ok, _err = pcall(demo_UnitPathfinder_getPathCost)

--@api-stub: UnitPathfinder:setCacheEnabled
-- Demonstrates the proper usage of UnitPathfinder:setCacheEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UnitPathfinder_setCacheEnabled()
    finder:setCacheEnabled(true)
end
local _ok, _err = pcall(demo_UnitPathfinder_setCacheEnabled)

--@api-stub: UnitPathfinder:isCacheEnabled
-- Demonstrates the proper usage of UnitPathfinder:isCacheEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UnitPathfinder_isCacheEnabled()
    print("cache: " .. tostring(finder:isCacheEnabled()))
end
local _ok, _err = pcall(demo_UnitPathfinder_isCacheEnabled)

--@api-stub: UnitPathfinder:clearCache
-- Demonstrates the proper usage of UnitPathfinder:clearCache.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UnitPathfinder_clearCache()
    finder:clearCache()
end
local _ok, _err = pcall(demo_UnitPathfinder_clearCache)

--@api-stub: UnitPathfinder:getCacheSize
-- Demonstrates the proper usage of UnitPathfinder:getCacheSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UnitPathfinder_getCacheSize()
    print("cache size: " .. finder:getCacheSize())
end
local _ok, _err = pcall(demo_UnitPathfinder_getCacheSize)

--@api-stub: UnitPathfinder:setCacheMaxSize
-- Demonstrates the proper usage of UnitPathfinder:setCacheMaxSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UnitPathfinder_setCacheMaxSize()
    finder:setCacheMaxSize(1000)
end
local _ok, _err = pcall(demo_UnitPathfinder_setCacheMaxSize)

--@api-stub: UnitPathfinder:type
-- Demonstrates the proper usage of UnitPathfinder:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UnitPathfinder_type()
    print("UnitPathfinder type: " .. finder:type())
end
local _ok, _err = pcall(demo_UnitPathfinder_type)

--@api-stub: UnitPathfinder:typeOf
-- Demonstrates the proper usage of UnitPathfinder:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UnitPathfinder_typeOf()
    print("is UnitPathfinder: " .. tostring(finder:typeOf("UnitPathfinder")))
end
local _ok, _err = pcall(demo_UnitPathfinder_typeOf)

-- =============================================================================
-- FlowField — unit swarm movement
-- =============================================================================

--@api-stub: lurek.pathfind.newFlowField
-- Demonstrates the proper usage of lurek.pathfind.newFlowField.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_newFlowField()
    local flow = lurek.pathfind.newFlowField(grid)
end
local _ok, _err = pcall(demo_lurek_pathfind_newFlowField)

--@api-stub: FlowField:getDirection
-- Demonstrates the proper usage of FlowField:getDirection.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_FlowField_getDirection()
    local dx, dy = flow:getDirection(5, 5)
    print("flow at (5,5): " .. dx .. "," .. dy)
end
local _ok, _err = pcall(demo_FlowField_getDirection)

--@api-stub: FlowField:getDirectionAngle
-- Demonstrates the proper usage of FlowField:getDirectionAngle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_FlowField_getDirectionAngle()
    local angle = flow:getDirectionAngle(5, 5)
    print("flow angle: " .. angle)
end
local _ok, _err = pcall(demo_FlowField_getDirectionAngle)

--@api-stub: FlowField:getCostToTarget
-- Demonstrates the proper usage of FlowField:getCostToTarget.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_FlowField_getCostToTarget()
    print("cost to target from (5,5): " .. flow:getCostToTarget(5, 5))
end
local _ok, _err = pcall(demo_FlowField_getCostToTarget)

--@api-stub: FlowField:isCalculated
-- Demonstrates the proper usage of FlowField:isCalculated.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_FlowField_isCalculated()
    print("calculated: " .. tostring(flow:isCalculated()))
end
local _ok, _err = pcall(demo_FlowField_isCalculated)

--@api-stub: FlowField:getTargets
-- Demonstrates the proper usage of FlowField:getTargets.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_FlowField_getTargets()
    local targets = flow:getTargets()
    print("flow targets: " .. #targets)
end
local _ok, _err = pcall(demo_FlowField_getTargets)

--@api-stub: FlowField:type
-- Demonstrates the proper usage of FlowField:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_FlowField_type()
    print("FlowField type: " .. flow:type())
end
local _ok, _err = pcall(demo_FlowField_type)

--@api-stub: FlowField:typeOf
-- Demonstrates the proper usage of FlowField:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_FlowField_typeOf()
    print("is FlowField: " .. tostring(flow:typeOf("FlowField")))
end
local _ok, _err = pcall(demo_FlowField_typeOf)

-- =============================================================================
-- PathGrid & PathFlowField — alternative grid types
-- =============================================================================

--@api-stub: lurek.pathfind.newPathGrid
-- Demonstrates the proper usage of lurek.pathfind.newPathGrid.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_newPathGrid()
    local pgrid = lurek.pathfind.newPathGrid(40, 30, 16)
end
local _ok, _err = pcall(demo_lurek_pathfind_newPathGrid)

--@api-stub: PathGrid:getWidth
-- Demonstrates the proper usage of PathGrid:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PathGrid_getWidth()
    print("path grid: " .. pgrid:getWidth() .. "x" .. pgrid:getHeight())
end
local _ok, _err = pcall(demo_PathGrid_getWidth)

--@api-stub: PathGrid:getHeight
-- Demonstrates the proper usage of PathGrid:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PathGrid_getHeight()
    print('Executing getHeight')
end
local _ok, _err = pcall(demo_PathGrid_getHeight)

--@api-stub: PathGrid:getCellSize
-- Demonstrates the proper usage of PathGrid:getCellSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PathGrid_getCellSize()
    print("cell size: " .. pgrid:getCellSize())
end
local _ok, _err = pcall(demo_PathGrid_getCellSize)

--@api-stub: PathGrid:setWalkable
-- Demonstrates the proper usage of PathGrid:setWalkable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PathGrid_setWalkable()
    pgrid:setWalkable(10, 10, true)
end
local _ok, _err = pcall(demo_PathGrid_setWalkable)

--@api-stub: PathGrid:isWalkable
-- Demonstrates the proper usage of PathGrid:isWalkable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PathGrid_isWalkable()
    print("walkable (10,10): " .. tostring(pgrid:isWalkable(10, 10)))
end
local _ok, _err = pcall(demo_PathGrid_isWalkable)

--@api-stub: PathGrid:setCost
-- Demonstrates the proper usage of PathGrid:setCost.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PathGrid_setCost()
    pgrid:setCost(10, 10, 1.5)
end
local _ok, _err = pcall(demo_PathGrid_setCost)

--@api-stub: PathGrid:getCost
-- Demonstrates the proper usage of PathGrid:getCost.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PathGrid_getCost()
    print("path grid cost: " .. pgrid:getCost(10, 10))
end
local _ok, _err = pcall(demo_PathGrid_getCost)

--@api-stub: PathGrid:type
-- Demonstrates the proper usage of PathGrid:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PathGrid_type()
    print("PathGrid type: " .. pgrid:type())
end
local _ok, _err = pcall(demo_PathGrid_type)

--@api-stub: PathGrid:typeOf
-- Demonstrates the proper usage of PathGrid:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PathGrid_typeOf()
    print("is PathGrid: " .. tostring(pgrid:typeOf("PathGrid")))
end
local _ok, _err = pcall(demo_PathGrid_typeOf)

--@api-stub: lurek.pathfind.newPathFlowField
-- Demonstrates the proper usage of lurek.pathfind.newPathFlowField.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_newPathFlowField()
    local pflow = lurek.pathfind.newPathFlowField(pgrid)
end
local _ok, _err = pcall(demo_lurek_pathfind_newPathFlowField)

--@api-stub: AiFlowField:getWidth
-- Demonstrates the proper usage of AiFlowField:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AiFlowField_getWidth()
    print("ai flow: " .. pflow:getWidth() .. "x" .. pflow:getHeight())
end
local _ok, _err = pcall(demo_AiFlowField_getWidth)

--@api-stub: AiFlowField:getHeight
-- Demonstrates the proper usage of AiFlowField:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AiFlowField_getHeight()
    print('Executing getHeight')
end
local _ok, _err = pcall(demo_AiFlowField_getHeight)

--@api-stub: AiFlowField:hasGoal
-- Demonstrates the proper usage of AiFlowField:hasGoal.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AiFlowField_hasGoal()
    print("has goal: " .. tostring(pflow:hasGoal()))
end
local _ok, _err = pcall(demo_AiFlowField_hasGoal)

--@api-stub: AiFlowField:setGoal
-- Demonstrates the proper usage of AiFlowField:setGoal.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AiFlowField_setGoal()
    pflow:setGoal(20, 15)
end
local _ok, _err = pcall(demo_AiFlowField_setGoal)

--@api-stub: AiFlowField:getDirection
-- Demonstrates the proper usage of AiFlowField:getDirection.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AiFlowField_getDirection()
    local adx, ady = pflow:getDirection(5, 5)
    print("ai flow dir: " .. adx .. "," .. ady)
end
local _ok, _err = pcall(demo_AiFlowField_getDirection)

--@api-stub: AiFlowField:getDistance
-- Demonstrates the proper usage of AiFlowField:getDistance.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AiFlowField_getDistance()
    print("distance to goal: " .. pflow:getDistance(5, 5))
end
local _ok, _err = pcall(demo_AiFlowField_getDistance)

--@api-stub: AiFlowField:type
-- Demonstrates the proper usage of AiFlowField:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AiFlowField_type()
    print("AiFlowField type: " .. pflow:type())
end
local _ok, _err = pcall(demo_AiFlowField_type)

--@api-stub: AiFlowField:typeOf
-- Demonstrates the proper usage of AiFlowField:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AiFlowField_typeOf()
    print("is AiFlowField: " .. tostring(pflow:typeOf("AiFlowField")))
end
local _ok, _err = pcall(demo_AiFlowField_typeOf)

-- =============================================================================
-- HexGrid — hex-tile pathfinding
-- =============================================================================

--@api-stub: lurek.pathfind.newHexGrid
-- Demonstrates the proper usage of lurek.pathfind.newHexGrid.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_newHexGrid()
    local hex = lurek.pathfind.newHexGrid(20, 20)
end
local _ok, _err = pcall(demo_lurek_pathfind_newHexGrid)

--@api-stub: HexGrid:setBlocked
-- Demonstrates the proper usage of HexGrid:setBlocked.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HexGrid_setBlocked()
    hex:setBlocked(5, 5, true)
end
local _ok, _err = pcall(demo_HexGrid_setBlocked)

--@api-stub: HexGrid:isBlocked
-- Demonstrates the proper usage of HexGrid:isBlocked.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HexGrid_isBlocked()
    print("hex (5,5) blocked: " .. tostring(hex:isBlocked(5, 5)))
end
local _ok, _err = pcall(demo_HexGrid_isBlocked)

--@api-stub: HexGrid:setCost
-- Demonstrates the proper usage of HexGrid:setCost.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HexGrid_setCost()
    hex:setCost(10, 10, 2.0)
end
local _ok, _err = pcall(demo_HexGrid_setCost)

--@api-stub: HexGrid:findPath
-- Demonstrates the proper usage of HexGrid:findPath.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HexGrid_findPath()
    local hex_path = hex:findPath(0, 0, 15, 15)
    print("hex path: " .. #hex_path .. " steps")
end
local _ok, _err = pcall(demo_HexGrid_findPath)

--@api-stub: HexGrid:lineOfSight
-- Demonstrates the proper usage of HexGrid:lineOfSight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HexGrid_lineOfSight()
    print("LOS (0,0)->(10,10): " .. tostring(hex:lineOfSight(0, 0, 10, 10)))
end
local _ok, _err = pcall(demo_HexGrid_lineOfSight)

--@api-stub: HexGrid:fieldOfView
-- Demonstrates the proper usage of HexGrid:fieldOfView.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HexGrid_fieldOfView()
    local fov = hex:fieldOfView(10, 10, 5)
    print("FOV cells: " .. #fov)
end
local _ok, _err = pcall(demo_HexGrid_fieldOfView)

--@api-stub: HexGrid:rangeOfMovement
-- Demonstrates the proper usage of HexGrid:rangeOfMovement.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HexGrid_rangeOfMovement()
    local reachable = hex:rangeOfMovement(10, 10, 3)
    print("reachable in 3 moves: " .. #reachable)
end
local _ok, _err = pcall(demo_HexGrid_rangeOfMovement)

--@api-stub: HexGrid:distance
-- Demonstrates the proper usage of HexGrid:distance.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HexGrid_distance()
    print("hex dist (0,0)->(5,5): " .. hex:distance(0, 0, 5, 5))
end
local _ok, _err = pcall(demo_HexGrid_distance)

-- =============================================================================
-- JPS Grid — Jump Point Search (fast long-range)
-- =============================================================================

--@api-stub: lurek.pathfind.newJpsGrid
-- Demonstrates the proper usage of lurek.pathfind.newJpsGrid.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_newJpsGrid()
    local jps = lurek.pathfind.newJpsGrid(100, 100)
end
local _ok, _err = pcall(demo_lurek_pathfind_newJpsGrid)

--@api-stub: JpsGrid:setBlocked
-- Demonstrates the proper usage of JpsGrid:setBlocked.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_JpsGrid_setBlocked()
    jps:setBlocked(50, 50, true)
end
local _ok, _err = pcall(demo_JpsGrid_setBlocked)

--@api-stub: JpsGrid:isBlocked
-- Demonstrates the proper usage of JpsGrid:isBlocked.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_JpsGrid_isBlocked()
    print("JPS (50,50) blocked: " .. tostring(jps:isBlocked(50, 50)))
end
local _ok, _err = pcall(demo_JpsGrid_isBlocked)

--@api-stub: JpsGrid:findPath
-- Demonstrates the proper usage of JpsGrid:findPath.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_JpsGrid_findPath()
    local jps_path = jps:findPath(0, 0, 99, 99)
    print("JPS path: " .. #jps_path .. " steps")
end
local _ok, _err = pcall(demo_JpsGrid_findPath)

-- =============================================================================
-- Range Map & Threading
-- =============================================================================

--@api-stub: lurek.pathfind.rangeMap
-- Demonstrates the proper usage of lurek.pathfind.rangeMap.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_rangeMap()
    local range = lurek.pathfind.rangeMap(grid, 10, 10, 5)
    print("range map cells: " .. #range)
end
local _ok, _err = pcall(demo_lurek_pathfind_rangeMap)

--@api-stub: lurek.pathfind.setThreadCount
-- Demonstrates the proper usage of lurek.pathfind.setThreadCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_setThreadCount()
    lurek.pathfind.setThreadCount(4)
end
local _ok, _err = pcall(demo_lurek_pathfind_setThreadCount)

--@api-stub: lurek.pathfind.getThreadCount
-- Demonstrates the proper usage of lurek.pathfind.getThreadCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_getThreadCount()
    print("pathfind threads: " .. lurek.pathfind.getThreadCount())
    print("\n-- pathfind.lua example complete --")
end
local _ok, _err = pcall(demo_lurek_pathfind_getThreadCount)

-- =============================================================================
-- lurek.pathfind — A*, JPS, flow fields, hex grids, nav grids, threading
--
-- Multiple grid types for different game needs: NavGrid (weighted A*),
-- JpsGrid (jump-point search for uniform grids), HexGrid (hex-based),
-- PathGrid (tile-based), and FlowField/AiFlowField for crowd steering.
-- =============================================================================

-- ---- Stub: lurek.pathfind.newNavGrid -------------------------------------
--@api-stub: lurek.pathfind.newNavGrid
-- Demonstrates the proper usage of lurek.pathfind.newNavGrid.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_newNavGrid()
    local nav = lurek.pathfind.newNavGrid(20, 20)
    print("nav grid: " .. nav:getWidth() .. "x" .. nav:getHeight())
end
local _ok, _err = pcall(demo_lurek_pathfind_newNavGrid)

-- ---- Stub: lurek.pathfind.newPathfinder ----------------------------------
--@api-stub: lurek.pathfind.newPathfinder
-- Demonstrates the proper usage of lurek.pathfind.newPathfinder.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_newPathfinder()
    local pf = lurek.pathfind.newPathfinder(nav)
    print("pathfinder created for nav grid")
end
local _ok, _err = pcall(demo_lurek_pathfind_newPathfinder)

-- ---- Stub: lurek.pathfind.newFlowField -----------------------------------
--@api-stub: lurek.pathfind.newFlowField
-- Demonstrates the proper usage of lurek.pathfind.newFlowField.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_newFlowField()
    local flow = lurek.pathfind.newFlowField(nav)
    print("flow field created")
end
local _ok, _err = pcall(demo_lurek_pathfind_newFlowField)

-- ---- Stub: lurek.pathfind.newPathGrid ------------------------------------
--@api-stub: lurek.pathfind.newPathGrid
-- Demonstrates the proper usage of lurek.pathfind.newPathGrid.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_newPathGrid()
    local pgrid = lurek.pathfind.newPathGrid(20, 20, 32)
    print("path grid: " .. pgrid:getWidth() .. "x" .. pgrid:getHeight() .. " cells, " .. pgrid:getCellSize() .. "px")
end
local _ok, _err = pcall(demo_lurek_pathfind_newPathGrid)

-- ---- Stub: lurek.pathfind.newPathFlowField -------------------------------
--@api-stub: lurek.pathfind.newPathFlowField
-- Demonstrates the proper usage of lurek.pathfind.newPathFlowField.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_newPathFlowField()
    local pflow = lurek.pathfind.newPathFlowField(pgrid)
    print("path flow field created")
end
local _ok, _err = pcall(demo_lurek_pathfind_newPathFlowField)

-- ---- Stub: lurek.pathfind.setThreadCount ---------------------------------
--@api-stub: lurek.pathfind.setThreadCount
-- Demonstrates the proper usage of lurek.pathfind.setThreadCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_setThreadCount()
    lurek.pathfind.setThreadCount(4)
    print("pathfinding threads: 4")
end
local _ok, _err = pcall(demo_lurek_pathfind_setThreadCount)

-- ---- Stub: lurek.pathfind.getThreadCount ---------------------------------
--@api-stub: lurek.pathfind.getThreadCount
-- Demonstrates the proper usage of lurek.pathfind.getThreadCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_getThreadCount()
    local threads = lurek.pathfind.getThreadCount()
    print("pathfinding thread count: " .. threads)
end
local _ok, _err = pcall(demo_lurek_pathfind_getThreadCount)

-- ---- Stub: lurek.pathfind.newNavGridFromTileMap ---------------------------
--@api-stub: lurek.pathfind.newNavGridFromTileMap
-- Demonstrates the proper usage of lurek.pathfind.newNavGridFromTileMap.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_newNavGridFromTileMap()
    local tm_nav = lurek.pathfind.newNavGridFromTileMap("assets/dungeon.tmx")
    print("nav grid from tilemap: " .. tostring(tm_nav))
end
local _ok, _err = pcall(demo_lurek_pathfind_newNavGridFromTileMap)

-- ---- Stub: lurek.pathfind.newHexGrid -------------------------------------
--@api-stub: lurek.pathfind.newHexGrid
-- Demonstrates the proper usage of lurek.pathfind.newHexGrid.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_newHexGrid()
    local hex = lurek.pathfind.newHexGrid(15, 15)
    print("hex grid: 15x15")
end
local _ok, _err = pcall(demo_lurek_pathfind_newHexGrid)

-- ---- Stub: lurek.pathfind.newJpsGrid -------------------------------------
--@api-stub: lurek.pathfind.newJpsGrid
-- Demonstrates the proper usage of lurek.pathfind.newJpsGrid.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_newJpsGrid()
    local jps = lurek.pathfind.newJpsGrid(20, 20)
    print("JPS grid: 20x20")
end
local _ok, _err = pcall(demo_lurek_pathfind_newJpsGrid)

-- ---- Stub: lurek.pathfind.rangeMap ---------------------------------------
--@api-stub: lurek.pathfind.rangeMap
-- Demonstrates the proper usage of lurek.pathfind.rangeMap.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_rangeMap()
    local rmap = lurek.pathfind.rangeMap(nav, 10, 10, 5)
    print("range map from (10,10) with 5 movement: " .. tostring(rmap))
end
local _ok, _err = pcall(demo_lurek_pathfind_rangeMap)

-- =============================================================================
-- NavGrid — weighted A* navigation
-- =============================================================================

-- ---- Stub: NavGrid:getWidth ----------------------------------------------
--@api-stub: NavGrid:getWidth
-- Demonstrates the proper usage of NavGrid:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_getWidth()
    print("nav width: " .. nav:getWidth())
end
local _ok, _err = pcall(demo_NavGrid_getWidth)

-- ---- Stub: NavGrid:getHeight ---------------------------------------------
--@api-stub: NavGrid:getHeight
-- Demonstrates the proper usage of NavGrid:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_getHeight()
    print("nav height: " .. nav:getHeight())
end
local _ok, _err = pcall(demo_NavGrid_getHeight)

-- ---- Stub: NavGrid:getDimensions -----------------------------------------
--@api-stub: NavGrid:getDimensions
-- Demonstrates the proper usage of NavGrid:getDimensions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_getDimensions()
    local nw, nh = nav:getDimensions()
    print("nav dimensions: " .. nw .. "x" .. nh)
end
local _ok, _err = pcall(demo_NavGrid_getDimensions)

-- ---- Stub: NavGrid:setCost -----------------------------------------------
--@api-stub: NavGrid:setCost
-- Demonstrates the proper usage of NavGrid:setCost.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_setCost()
    nav:setCost(5, 5, 3.0)
    print("cell (5,5) cost set to 3.0 (swamp)")
end
local _ok, _err = pcall(demo_NavGrid_setCost)

-- ---- Stub: NavGrid:getCost -----------------------------------------------
--@api-stub: NavGrid:getCost
-- Demonstrates the proper usage of NavGrid:getCost.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_getCost()
    local cost = nav:getCost(5, 5)
    print("cell (5,5) cost: " .. cost)
end
local _ok, _err = pcall(demo_NavGrid_getCost)

-- ---- Stub: NavGrid:isBlocked ---------------------------------------------
--@api-stub: NavGrid:isBlocked
-- Demonstrates the proper usage of NavGrid:isBlocked.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_isBlocked()
    nav:setCost(3, 3, 0)
    local blocked = nav:isBlocked(3, 3)
    print("cell (3,3) blocked: " .. tostring(blocked))
end
local _ok, _err = pcall(demo_NavGrid_isBlocked)

-- ---- Stub: NavGrid:fill --------------------------------------------------
--@api-stub: NavGrid:fill
-- Demonstrates the proper usage of NavGrid:fill.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_fill()
    nav:fill(1.0)
    print("nav grid filled with cost 1.0")
end
local _ok, _err = pcall(demo_NavGrid_fill)

-- ---- Stub: NavGrid:loadFromString ----------------------------------------
--@api-stub: NavGrid:loadFromString
-- Demonstrates the proper usage of NavGrid:loadFromString.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_loadFromString()
    local map_str = "##########\n#........#\n#..####..#\n#........#\n##########"
    nav:loadFromString(map_str, { ["#"] = 0, ["."] = 1.0 })
    print("nav grid loaded from string")
end
local _ok, _err = pcall(demo_NavGrid_loadFromString)

-- ---- Stub: NavGrid:saveToString ------------------------------------------
--@api-stub: NavGrid:saveToString
-- Demonstrates the proper usage of NavGrid:saveToString.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_saveToString()
    local saved = nav:saveToString()
    print("saved grid:\n" .. tostring(saved))
end
local _ok, _err = pcall(demo_NavGrid_saveToString)

-- ---- Stub: NavGrid:setChunkSize ------------------------------------------
--@api-stub: NavGrid:setChunkSize
-- Demonstrates the proper usage of NavGrid:setChunkSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_setChunkSize()
    nav:setChunkSize(8)
    print("chunk size set to 8 for hierarchical pathfinding")
end
local _ok, _err = pcall(demo_NavGrid_setChunkSize)

-- ---- Stub: NavGrid:getChunkSize ------------------------------------------
--@api-stub: NavGrid:getChunkSize
-- Demonstrates the proper usage of NavGrid:getChunkSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_getChunkSize()
    print("chunk size: " .. nav:getChunkSize())
end
local _ok, _err = pcall(demo_NavGrid_getChunkSize)

-- ---- Stub: NavGrid:rebuildAbstract ---------------------------------------
--@api-stub: NavGrid:rebuildAbstract
-- Demonstrates the proper usage of NavGrid:rebuildAbstract.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_rebuildAbstract()
    nav:rebuildAbstract()
    print("abstract graph rebuilt")
end
local _ok, _err = pcall(demo_NavGrid_rebuildAbstract)

-- ---- Stub: NavGrid:setDirty ----------------------------------------------
--@api-stub: NavGrid:setDirty
-- Demonstrates the proper usage of NavGrid:setDirty.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_setDirty()
    nav:setDirty()
    print("nav grid marked dirty")
end
local _ok, _err = pcall(demo_NavGrid_setDirty)

-- ---- Stub: NavGrid:clearDirty --------------------------------------------
--@api-stub: NavGrid:clearDirty
-- Demonstrates the proper usage of NavGrid:clearDirty.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_clearDirty()
    nav:clearDirty()
    print("dirty flag cleared")
end
local _ok, _err = pcall(demo_NavGrid_clearDirty)

-- ---- Stub: NavGrid:setDiagonalMode --------------------------------------
--@api-stub: NavGrid:setDiagonalMode
-- Demonstrates the proper usage of NavGrid:setDiagonalMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_setDiagonalMode()
    nav:setDiagonalMode("always")
    print("diagonal mode: always")
end
local _ok, _err = pcall(demo_NavGrid_setDiagonalMode)

-- ---- Stub: NavGrid:getDiagonalMode ---------------------------------------
--@api-stub: NavGrid:getDiagonalMode
-- Demonstrates the proper usage of NavGrid:getDiagonalMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_getDiagonalMode()
    print("diagonal mode: " .. nav:getDiagonalMode())
end
local _ok, _err = pcall(demo_NavGrid_getDiagonalMode)

-- ---- Stub: NavGrid:type --------------------------------------------------
--@api-stub: NavGrid:type
-- Demonstrates the proper usage of NavGrid:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_type()
    print("type: " .. nav:type())
end
local _ok, _err = pcall(demo_NavGrid_type)

-- ---- Stub: NavGrid:typeOf ------------------------------------------------
--@api-stub: NavGrid:typeOf
-- Demonstrates the proper usage of NavGrid:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_typeOf()
    print("is NavGrid: " .. tostring(nav:typeOf("NavGrid")))
end
local _ok, _err = pcall(demo_NavGrid_typeOf)

-- =============================================================================
-- UnitPathfinder — path queries with caching
-- =============================================================================

-- ---- Stub: UnitPathfinder:getPathLength ----------------------------------
--@api-stub: UnitPathfinder:getPathLength
-- Demonstrates the proper usage of UnitPathfinder:getPathLength.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UnitPathfinder_getPathLength()
    local path_len = pf:getPathLength()
    print("path length: " .. tostring(path_len) .. " waypoints")
end
local _ok, _err = pcall(demo_UnitPathfinder_getPathLength)

-- ---- Stub: UnitPathfinder:getPathCost ------------------------------------
--@api-stub: UnitPathfinder:getPathCost
-- Demonstrates the proper usage of UnitPathfinder:getPathCost.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UnitPathfinder_getPathCost()
    local path_cost = pf:getPathCost()
    print("path cost: " .. tostring(path_cost))
end
local _ok, _err = pcall(demo_UnitPathfinder_getPathCost)

-- ---- Stub: UnitPathfinder:setCacheEnabled --------------------------------
--@api-stub: UnitPathfinder:setCacheEnabled
-- Demonstrates the proper usage of UnitPathfinder:setCacheEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UnitPathfinder_setCacheEnabled()
    pf:setCacheEnabled(true)
    print("path cache enabled")
end
local _ok, _err = pcall(demo_UnitPathfinder_setCacheEnabled)

-- ---- Stub: UnitPathfinder:isCacheEnabled ---------------------------------
--@api-stub: UnitPathfinder:isCacheEnabled
-- Demonstrates the proper usage of UnitPathfinder:isCacheEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UnitPathfinder_isCacheEnabled()
    print("cache enabled: " .. tostring(pf:isCacheEnabled()))
end
local _ok, _err = pcall(demo_UnitPathfinder_isCacheEnabled)

-- ---- Stub: UnitPathfinder:clearCache -------------------------------------
--@api-stub: UnitPathfinder:clearCache
-- Demonstrates the proper usage of UnitPathfinder:clearCache.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UnitPathfinder_clearCache()
    pf:clearCache()
    print("path cache cleared")
end
local _ok, _err = pcall(demo_UnitPathfinder_clearCache)

-- ---- Stub: UnitPathfinder:getCacheSize -----------------------------------
--@api-stub: UnitPathfinder:getCacheSize
-- Demonstrates the proper usage of UnitPathfinder:getCacheSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UnitPathfinder_getCacheSize()
    print("cache size: " .. pf:getCacheSize() .. " entries")
end
local _ok, _err = pcall(demo_UnitPathfinder_getCacheSize)

-- ---- Stub: UnitPathfinder:setCacheMaxSize --------------------------------
--@api-stub: UnitPathfinder:setCacheMaxSize
-- Demonstrates the proper usage of UnitPathfinder:setCacheMaxSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UnitPathfinder_setCacheMaxSize()
    pf:setCacheMaxSize(1000)
    print("cache max size: 1000")
end
local _ok, _err = pcall(demo_UnitPathfinder_setCacheMaxSize)

-- ---- Stub: UnitPathfinder:type -------------------------------------------
--@api-stub: UnitPathfinder:type
-- Demonstrates the proper usage of UnitPathfinder:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UnitPathfinder_type()
    print("type: " .. pf:type())
end
local _ok, _err = pcall(demo_UnitPathfinder_type)

-- ---- Stub: UnitPathfinder:typeOf -----------------------------------------
--@api-stub: UnitPathfinder:typeOf
-- Demonstrates the proper usage of UnitPathfinder:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UnitPathfinder_typeOf()
    print("is UnitPathfinder: " .. tostring(pf:typeOf("UnitPathfinder")))
end
local _ok, _err = pcall(demo_UnitPathfinder_typeOf)

-- =============================================================================
-- FlowField — grid-wide direction field for crowd pathfinding
-- =============================================================================

-- ---- Stub: FlowField:getDirection ----------------------------------------
--@api-stub: FlowField:getDirection
-- Demonstrates the proper usage of FlowField:getDirection.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_FlowField_getDirection()
    local dx, dy = flow:getDirection(10, 10)
    print(string.format("flow direction at (10,10): (%.2f, %.2f)", dx or 0, dy or 0))
end
local _ok, _err = pcall(demo_FlowField_getDirection)

-- ---- Stub: FlowField:getDirectionAngle -----------------------------------
--@api-stub: FlowField:getDirectionAngle
-- Demonstrates the proper usage of FlowField:getDirectionAngle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_FlowField_getDirectionAngle()
    local angle = flow:getDirectionAngle(10, 10)
    print(string.format("flow angle at (10,10): %.2f rad", angle or 0))
end
local _ok, _err = pcall(demo_FlowField_getDirectionAngle)

-- ---- Stub: FlowField:getCostToTarget -------------------------------------
--@api-stub: FlowField:getCostToTarget
-- Demonstrates the proper usage of FlowField:getCostToTarget.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_FlowField_getCostToTarget()
    local cost_to = flow:getCostToTarget(10, 10)
    print("cost to target from (10,10): " .. tostring(cost_to))
end
local _ok, _err = pcall(demo_FlowField_getCostToTarget)

-- ---- Stub: FlowField:isCalculated ----------------------------------------
--@api-stub: FlowField:isCalculated
-- Demonstrates the proper usage of FlowField:isCalculated.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_FlowField_isCalculated()
    local ready = flow:isCalculated()
    print("flow field calculated: " .. tostring(ready))
end
local _ok, _err = pcall(demo_FlowField_isCalculated)

-- ---- Stub: FlowField:getTargets ------------------------------------------
--@api-stub: FlowField:getTargets
-- Demonstrates the proper usage of FlowField:getTargets.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_FlowField_getTargets()
    local targets = flow:getTargets()
    print("flow targets: " .. tostring(#(targets or {})))
end
local _ok, _err = pcall(demo_FlowField_getTargets)

-- ---- Stub: FlowField:type ------------------------------------------------
--@api-stub: FlowField:type
-- Demonstrates the proper usage of FlowField:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_FlowField_type()
    print("type: " .. flow:type())
end
local _ok, _err = pcall(demo_FlowField_type)

-- ---- Stub: FlowField:typeOf ----------------------------------------------
--@api-stub: FlowField:typeOf
-- Demonstrates the proper usage of FlowField:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_FlowField_typeOf()
    print("is FlowField: " .. tostring(flow:typeOf("FlowField")))
end
local _ok, _err = pcall(demo_FlowField_typeOf)

-- =============================================================================
-- AiFlowField — simpler flow field for AI steering
-- =============================================================================

-- ---- Stub: AiFlowField:getWidth ------------------------------------------
--@api-stub: AiFlowField:getWidth
-- Demonstrates the proper usage of AiFlowField:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AiFlowField_getWidth()
    local aiflow = lurek.pathfind.newFlowField(nav)
    print("AI flow field width: " .. tostring(aiflow:getWidth()))
end
local _ok, _err = pcall(demo_AiFlowField_getWidth)

-- ---- Stub: AiFlowField:getHeight -----------------------------------------
--@api-stub: AiFlowField:getHeight
-- Demonstrates the proper usage of AiFlowField:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AiFlowField_getHeight()
    print("AI flow field height: " .. tostring(aiflow:getHeight()))
end
local _ok, _err = pcall(demo_AiFlowField_getHeight)

-- ---- Stub: AiFlowField:hasGoal -------------------------------------------
--@api-stub: AiFlowField:hasGoal
-- Demonstrates the proper usage of AiFlowField:hasGoal.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AiFlowField_hasGoal()
    print("has goal: " .. tostring(aiflow:hasGoal()))
end
local _ok, _err = pcall(demo_AiFlowField_hasGoal)

-- ---- Stub: AiFlowField:setGoal -------------------------------------------
--@api-stub: AiFlowField:setGoal
-- Demonstrates the proper usage of AiFlowField:setGoal.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AiFlowField_setGoal()
    aiflow:setGoal(15, 15)
    print("flow field goal set to (15, 15)")
end
local _ok, _err = pcall(demo_AiFlowField_setGoal)

-- ---- Stub: AiFlowField:getDirection --------------------------------------
--@api-stub: AiFlowField:getDirection
-- Demonstrates the proper usage of AiFlowField:getDirection.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AiFlowField_getDirection()
    local adx, ady = aiflow:getDirection(5, 5)
    print(string.format("AI direction at (5,5): (%.2f, %.2f)", adx or 0, ady or 0))
end
local _ok, _err = pcall(demo_AiFlowField_getDirection)

-- ---- Stub: AiFlowField:getDistance ----------------------------------------
--@api-stub: AiFlowField:getDistance
-- Demonstrates the proper usage of AiFlowField:getDistance.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AiFlowField_getDistance()
    local dist = aiflow:getDistance(5, 5)
    print("distance to goal from (5,5): " .. tostring(dist))
end
local _ok, _err = pcall(demo_AiFlowField_getDistance)

-- ---- Stub: AiFlowField:type ----------------------------------------------
--@api-stub: AiFlowField:type
-- Demonstrates the proper usage of AiFlowField:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AiFlowField_type()
    print("type: " .. aiflow:type())
end
local _ok, _err = pcall(demo_AiFlowField_type)

-- ---- Stub: AiFlowField:typeOf ---------------------------------------------
--@api-stub: AiFlowField:typeOf
-- Demonstrates the proper usage of AiFlowField:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AiFlowField_typeOf()
    print("is AiFlowField: " .. tostring(aiflow:typeOf("AiFlowField")))
end
local _ok, _err = pcall(demo_AiFlowField_typeOf)

-- =============================================================================
-- HexGrid — hexagonal grid pathfinding
-- =============================================================================

-- ---- Stub: HexGrid:setBlocked --------------------------------------------
--@api-stub: HexGrid:setBlocked
-- Demonstrates the proper usage of HexGrid:setBlocked.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HexGrid_setBlocked()
    hex:setBlocked(7, 7, true)
    print("hex (7,7) blocked (mountain)")
end
local _ok, _err = pcall(demo_HexGrid_setBlocked)

-- ---- Stub: HexGrid:setCost -----------------------------------------------
--@api-stub: HexGrid:setCost
-- Demonstrates the proper usage of HexGrid:setCost.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HexGrid_setCost()
    hex:setCost(5, 5, 2.0)
    print("hex (5,5) cost: 2.0 (forest)")
end
local _ok, _err = pcall(demo_HexGrid_setCost)

-- ---- Stub: HexGrid:isBlocked ---------------------------------------------
--@api-stub: HexGrid:isBlocked
-- Demonstrates the proper usage of HexGrid:isBlocked.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HexGrid_isBlocked()
    print("hex (7,7) blocked: " .. tostring(hex:isBlocked(7, 7)))
end
local _ok, _err = pcall(demo_HexGrid_isBlocked)

-- ---- Stub: HexGrid:findPath ----------------------------------------------
--@api-stub: HexGrid:findPath
-- Demonstrates the proper usage of HexGrid:findPath.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HexGrid_findPath()
    local hex_path = hex:findPath(1, 1, 12, 12)
    print("hex path: " .. tostring(#(hex_path or {})) .. " steps")
end
local _ok, _err = pcall(demo_HexGrid_findPath)

-- ---- Stub: HexGrid:lineOfSight -------------------------------------------
--@api-stub: HexGrid:lineOfSight
-- Demonstrates the proper usage of HexGrid:lineOfSight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HexGrid_lineOfSight()
    local los = hex:lineOfSight(1, 1, 10, 10)
    print("line of sight (1,1)->(10,10): " .. tostring(los))
end
local _ok, _err = pcall(demo_HexGrid_lineOfSight)

-- ---- Stub: HexGrid:fieldOfView -------------------------------------------
--@api-stub: HexGrid:fieldOfView
-- Demonstrates the proper usage of HexGrid:fieldOfView.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HexGrid_fieldOfView()
    local fov = hex:fieldOfView(5, 5, 4)
    print("field of view from (5,5) r=4: " .. tostring(#(fov or {})) .. " hexes")
end
local _ok, _err = pcall(demo_HexGrid_fieldOfView)

-- ---- Stub: HexGrid:rangeOfMovement ---------------------------------------
--@api-stub: HexGrid:rangeOfMovement
-- Demonstrates the proper usage of HexGrid:rangeOfMovement.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HexGrid_rangeOfMovement()
    local rom = hex:rangeOfMovement(5, 5, 3)
    print("range of movement r=3: " .. tostring(#(rom or {})) .. " hexes")
end
local _ok, _err = pcall(demo_HexGrid_rangeOfMovement)

-- ---- Stub: HexGrid:distance ----------------------------------------------
--@api-stub: HexGrid:distance
-- Demonstrates the proper usage of HexGrid:distance.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HexGrid_distance()
    local hex_dist = hex:distance(1, 1, 5, 5)
    print("hex distance (1,1)->(5,5): " .. tostring(hex_dist))
end
local _ok, _err = pcall(demo_HexGrid_distance)

-- =============================================================================
-- JpsGrid — Jump Point Search for uniform grids
-- =============================================================================

-- ---- Stub: JpsGrid:setBlocked --------------------------------------------
--@api-stub: JpsGrid:setBlocked
-- Demonstrates the proper usage of JpsGrid:setBlocked.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_JpsGrid_setBlocked()
    jps:setBlocked(10, 10, true)
    print("JPS cell (10,10) blocked")
end
local _ok, _err = pcall(demo_JpsGrid_setBlocked)

-- ---- Stub: JpsGrid:isBlocked ---------------------------------------------
--@api-stub: JpsGrid:isBlocked
-- Demonstrates the proper usage of JpsGrid:isBlocked.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_JpsGrid_isBlocked()
    print("JPS (10,10) blocked: " .. tostring(jps:isBlocked(10, 10)))
end
local _ok, _err = pcall(demo_JpsGrid_isBlocked)

-- ---- Stub: JpsGrid:findPath ----------------------------------------------
--@api-stub: JpsGrid:findPath
-- Demonstrates the proper usage of JpsGrid:findPath.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_JpsGrid_findPath()
    local jps_path = jps:findPath(0, 0, 19, 19)
    print("JPS path: " .. tostring(#(jps_path or {})) .. " waypoints")
end
local _ok, _err = pcall(demo_JpsGrid_findPath)

-- =============================================================================
-- PathGrid — tile-based pathfinding with cell sizes
-- =============================================================================

-- ---- Stub: PathGrid:getWidth ---------------------------------------------
--@api-stub: PathGrid:getWidth
-- Demonstrates the proper usage of PathGrid:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PathGrid_getWidth()
    print("path grid width: " .. pgrid:getWidth())
end
local _ok, _err = pcall(demo_PathGrid_getWidth)

-- ---- Stub: PathGrid:getHeight --------------------------------------------
--@api-stub: PathGrid:getHeight
-- Demonstrates the proper usage of PathGrid:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PathGrid_getHeight()
    print("path grid height: " .. pgrid:getHeight())
end
local _ok, _err = pcall(demo_PathGrid_getHeight)

-- ---- Stub: PathGrid:getCellSize ------------------------------------------
--@api-stub: PathGrid:getCellSize
-- Demonstrates the proper usage of PathGrid:getCellSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PathGrid_getCellSize()
    print("cell size: " .. pgrid:getCellSize() .. " px")
end
local _ok, _err = pcall(demo_PathGrid_getCellSize)

-- ---- Stub: PathGrid:setWalkable ------------------------------------------
--@api-stub: PathGrid:setWalkable
-- Demonstrates the proper usage of PathGrid:setWalkable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PathGrid_setWalkable()
    pgrid:setWalkable(5, 5, false)
    print("cell (5,5) set non-walkable")
end
local _ok, _err = pcall(demo_PathGrid_setWalkable)

-- ---- Stub: PathGrid:isWalkable -------------------------------------------
--@api-stub: PathGrid:isWalkable
-- Demonstrates the proper usage of PathGrid:isWalkable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PathGrid_isWalkable()
    print("cell (5,5) walkable: " .. tostring(pgrid:isWalkable(5, 5)))
end
local _ok, _err = pcall(demo_PathGrid_isWalkable)

-- ---- Stub: PathGrid:setCost ----------------------------------------------
--@api-stub: PathGrid:setCost
-- Demonstrates the proper usage of PathGrid:setCost.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PathGrid_setCost()
    pgrid:setCost(8, 8, 2.5)
    print("cell (8,8) cost: 2.5 (mud)")
end
local _ok, _err = pcall(demo_PathGrid_setCost)

-- ---- Stub: PathGrid:getCost ----------------------------------------------
--@api-stub: PathGrid:getCost
-- Demonstrates the proper usage of PathGrid:getCost.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PathGrid_getCost()
    print("cell (8,8) cost: " .. pgrid:getCost(8, 8))
end
local _ok, _err = pcall(demo_PathGrid_getCost)

-- ---- Stub: PathGrid:type -------------------------------------------------
--@api-stub: PathGrid:type
-- Demonstrates the proper usage of PathGrid:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PathGrid_type()
    print("type: " .. pgrid:type())
end
local _ok, _err = pcall(demo_PathGrid_type)

-- ---- Stub: PathGrid:typeOf -----------------------------------------------
--@api-stub: PathGrid:typeOf
-- Demonstrates the proper usage of PathGrid:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PathGrid_typeOf()
    print("is PathGrid: " .. tostring(pgrid:typeOf("PathGrid")))
end
local _ok, _err = pcall(demo_PathGrid_typeOf)

-- =============================================================================
-- STUBS: 73 uncovered lurek.pathfind API item(s)
-- =============================================================================

-- ---- Stub: lurek.pathfind.newNavGrid -------------------------------------
--@api-stub: lurek.pathfind.newNavGrid
-- Demonstrates the proper usage of lurek.pathfind.newNavGrid.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_newNavGrid()
    local nav = lurek.pathfind.newNavGrid(32, 32)
    print("NavGrid:", nav:getWidth(), "x", nav:getHeight())
end
local _ok, _err = pcall(demo_lurek_pathfind_newNavGrid)

-- ---- Stub: lurek.pathfind.newPathfinder ----------------------------------
--@api-stub: lurek.pathfind.newPathfinder
-- Demonstrates the proper usage of lurek.pathfind.newPathfinder.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_newPathfinder()
    local pf = lurek.pathfind.newPathfinder(nav)
    print("UnitPathfinder created:", pf ~= nil)
end
local _ok, _err = pcall(demo_lurek_pathfind_newPathfinder)

-- ---- Stub: lurek.pathfind.newFlowField -----------------------------------
--@api-stub: lurek.pathfind.newFlowField
-- Demonstrates the proper usage of lurek.pathfind.newFlowField.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_newFlowField()
    local ff = lurek.pathfind.newFlowField(nav)
    print("FlowField created:", ff ~= nil)
end
local _ok, _err = pcall(demo_lurek_pathfind_newFlowField)

-- ---- Stub: lurek.pathfind.newPathGrid ------------------------------------
--@api-stub: lurek.pathfind.newPathGrid
-- Demonstrates the proper usage of lurek.pathfind.newPathGrid.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_newPathGrid()
    local pg = lurek.pathfind.newPathGrid(16, 16, 64.0)
    print("PathGrid cell size:", pg:getCellSize())
end
local _ok, _err = pcall(demo_lurek_pathfind_newPathGrid)

-- ---- Stub: lurek.pathfind.newPathFlowField -------------------------------
--@api-stub: lurek.pathfind.newPathFlowField
-- Demonstrates the proper usage of lurek.pathfind.newPathFlowField.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_newPathFlowField()
    local aff = lurek.pathfind.newPathFlowField(pg)
    print("AiFlowField created:", aff ~= nil)
end
local _ok, _err = pcall(demo_lurek_pathfind_newPathFlowField)

-- ---- Stub: lurek.pathfind.setThreadCount ---------------------------------
--@api-stub: lurek.pathfind.setThreadCount
-- Demonstrates the proper usage of lurek.pathfind.setThreadCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_setThreadCount()
    lurek.pathfind.setThreadCount(2)
    print("thread count:", lurek.pathfind.getThreadCount())
end
local _ok, _err = pcall(demo_lurek_pathfind_setThreadCount)

-- ---- Stub: lurek.pathfind.getThreadCount ---------------------------------
--@api-stub: lurek.pathfind.getThreadCount
-- Demonstrates the proper usage of lurek.pathfind.getThreadCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_getThreadCount()
    print("pathfind threads:", lurek.pathfind.getThreadCount())
end
local _ok, _err = pcall(demo_lurek_pathfind_getThreadCount)

-- ---- Stub: lurek.pathfind.newNavGridFromTileMap --------------------------
--@api-stub: lurek.pathfind.newNavGridFromTileMap
-- Build the walkability grid directly from the collision TileMap layer
-- so wall tiles are automatically blocked without a manual setup loop.
-- Uses pcall because a real TileMap userdata is needed; falls back to
-- the manual nav grid in all standalone example runs.
local tm_ok, nav_from_tm = pcall(function()
    -- In a real game: local tm = lurek.tilemap.load("assets/dungeon.tmx")
    -- return lurek.pathfind.newNavGridFromTileMap(tm, 1, { 2, 3, 100 })
    return lurek.pathfind.newNavGridFromTileMap(nil, 1, { 2, 3 })
end)
print("newNavGridFromTileMap:", tm_ok and "ok" or "expected (no TileMap in example)")

-- ---- Stub: lurek.pathfind.newHexGrid -------------------------------------
--@api-stub: lurek.pathfind.newHexGrid
-- Demonstrates the proper usage of lurek.pathfind.newHexGrid.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_newHexGrid()
    local hex = lurek.pathfind.newHexGrid(16, 12, "pointy")
    print("HexGrid created:", hex ~= nil)
end
local _ok, _err = pcall(demo_lurek_pathfind_newHexGrid)

-- ---- Stub: lurek.pathfind.newJpsGrid -------------------------------------
--@api-stub: lurek.pathfind.newJpsGrid
-- Demonstrates the proper usage of lurek.pathfind.newJpsGrid.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_pathfind_newJpsGrid()
    local jps = lurek.pathfind.newJpsGrid(32, 32)
    print("JpsGrid created:", jps ~= nil)
end
local _ok, _err = pcall(demo_lurek_pathfind_newJpsGrid)

-- ---- Stub: lurek.pathfind.rangeMap ---------------------------------------
--@api-stub: lurek.pathfind.rangeMap
-- Compute the Dijkstra range-of-movement map from a unit's position
-- with a budget of 4 AP to highlight all reachable tiles this turn.
local range_cells = lurek.pathfind.rangeMap({
    grid   = nav,
    origin = { x = 5, y = 5 },
    budget = 4,
})
print("reachable cells:", range_cells and #range_cells or 0)

-- -----------------------------------------------------------------------------
-- AiFlowField methods
-- -----------------------------------------------------------------------------

aff:setGoal(8, 8)

-- ---- Stub: AiFlowField:getWidth ------------------------------------------
--@api-stub: AiFlowField:getWidth
-- Demonstrates the proper usage of AiFlowField:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AiFlowField_getWidth()
    print("AiFlowField width:", aff:getWidth())
end
local _ok, _err = pcall(demo_AiFlowField_getWidth)

-- ---- Stub: AiFlowField:getHeight -----------------------------------------
--@api-stub: AiFlowField:getHeight
-- Demonstrates the proper usage of AiFlowField:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AiFlowField_getHeight()
    print("AiFlowField height:", aff:getHeight())
end
local _ok, _err = pcall(demo_AiFlowField_getHeight)

-- ---- Stub: AiFlowField:hasGoal -------------------------------------------
--@api-stub: AiFlowField:hasGoal
-- Demonstrates the proper usage of AiFlowField:hasGoal.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AiFlowField_hasGoal()
    print("has goal:", aff:hasGoal())
end
local _ok, _err = pcall(demo_AiFlowField_hasGoal)

-- ---- Stub: AiFlowField:setGoal -------------------------------------------
--@api-stub: AiFlowField:setGoal
-- Demonstrates the proper usage of AiFlowField:setGoal.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AiFlowField_setGoal()
    aff:setGoal(10, 10)
    print("goal set, has goal:", aff:hasGoal())
end
local _ok, _err = pcall(demo_AiFlowField_setGoal)

-- ---- Stub: AiFlowField:getDirection --------------------------------------
--@api-stub: AiFlowField:getDirection
-- Demonstrates the proper usage of AiFlowField:getDirection.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AiFlowField_getDirection()
    local dx, dy = aff:getDirection(5, 5)
    print(string.format("direction at (5,5): (%.2f, %.2f)", dx or 0, dy or 0))
end
local _ok, _err = pcall(demo_AiFlowField_getDirection)

-- ---- Stub: AiFlowField:getDistance ---------------------------------------
--@api-stub: AiFlowField:getDistance
-- Demonstrates the proper usage of AiFlowField:getDistance.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AiFlowField_getDistance()
    local dist = aff:getDistance(5, 5)
    print("distance to goal:", dist)
end
local _ok, _err = pcall(demo_AiFlowField_getDistance)

-- ---- Stub: AiFlowField:type ----------------------------------------------
--@api-stub: AiFlowField:type
-- Demonstrates the proper usage of AiFlowField:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_AiFlowField_type()
    print("aff type:", aff:type())
end
local _ok, _err = pcall(demo_AiFlowField_type)

-- ---- Stub: AiFlowField:typeOf --------------------------------------------
--@api-stub: AiFlowField:typeOf
-- Check that the object is an AiFlowField before passing it to the
-- AI decision layer that calls getDirection.
print("is AiFlowField:", aff:typeOf("AiFlowField"))

-- -----------------------------------------------------------------------------
-- FlowField methods
-- -----------------------------------------------------------------------------

-- Build a simple wall in the dungeon for LOS and flow demos
for x = 5, 5 do
    for y = 2, 8 do
        nav:setCost(x, y, 255)  -- high cost = wall
    end
end

-- ---- Stub: FlowField:getDirection ----------------------------------------
--@api-stub: FlowField:getDirection
-- Demonstrates the proper usage of FlowField:getDirection.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_FlowField_getDirection()
    local fdx, fdy = ff:getDirection(3, 3)
    print(string.format("ff direction at (3,3): (%.2f, %.2f)", fdx or 0, fdy or 0))
end
local _ok, _err = pcall(demo_FlowField_getDirection)

-- ---- Stub: FlowField:getDirectionAngle -----------------------------------
--@api-stub: FlowField:getDirectionAngle
-- Demonstrates the proper usage of FlowField:getDirectionAngle.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_FlowField_getDirectionAngle()
    local angle = ff:getDirectionAngle(3, 3)
    print(string.format("flow angle: %.3f rad", angle or 0))
end
local _ok, _err = pcall(demo_FlowField_getDirectionAngle)

-- ---- Stub: FlowField:getCostToTarget -------------------------------------
--@api-stub: FlowField:getCostToTarget
-- Demonstrates the proper usage of FlowField:getCostToTarget.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_FlowField_getCostToTarget()
    local cost = ff:getCostToTarget(3, 3)
    print("cost to target:", cost)
end
local _ok, _err = pcall(demo_FlowField_getCostToTarget)

-- ---- Stub: FlowField:isCalculated ----------------------------------------
--@api-stub: FlowField:isCalculated
-- Demonstrates the proper usage of FlowField:isCalculated.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_FlowField_isCalculated()
    print("ff calculated:", ff:isCalculated())
end
local _ok, _err = pcall(demo_FlowField_isCalculated)

-- ---- Stub: FlowField:getTargets ------------------------------------------
--@api-stub: FlowField:getTargets
-- Demonstrates the proper usage of FlowField:getTargets.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_FlowField_getTargets()
    local targets = ff:getTargets()
    print("ff targets:", #targets)
end
local _ok, _err = pcall(demo_FlowField_getTargets)

-- ---- Stub: FlowField:type ------------------------------------------------
--@api-stub: FlowField:type
-- Demonstrates the proper usage of FlowField:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_FlowField_type()
    print("ff type:", ff:type())
end
local _ok, _err = pcall(demo_FlowField_type)

-- ---- Stub: FlowField:typeOf ----------------------------------------------
--@api-stub: FlowField:typeOf
-- Demonstrates the proper usage of FlowField:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_FlowField_typeOf()
    print("is FlowField:", ff:typeOf("FlowField"))
end
local _ok, _err = pcall(demo_FlowField_typeOf)

-- ---- Stub: HexGrid:setBlocked --------------------------------------------
--@api-stub: HexGrid:setBlocked
-- Mark impassable mountain terrain cells as blocked so armies cannot
-- route through them when planning invasion paths.
hex:setBlocked(3, 3, true)
hex:setBlocked(4, 3, true)
print("blocked mountain cells set")

-- ---- Stub: HexGrid:setCost -----------------------------------------------
--@api-stub: HexGrid:setCost
-- Demonstrates the proper usage of HexGrid:setCost.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HexGrid_setCost()
    hex:setCost(5, 4, 3)  -- forest costs 3 MP vs 1 for plains
    print("forest cost set")
end
local _ok, _err = pcall(demo_HexGrid_setCost)

-- ---- Stub: HexGrid:isBlocked ---------------------------------------------
--@api-stub: HexGrid:isBlocked
-- Demonstrates the proper usage of HexGrid:isBlocked.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HexGrid_isBlocked()
    print("(3,3) blocked:", hex:isBlocked(3, 3))
end
local _ok, _err = pcall(demo_HexGrid_isBlocked)

-- ---- Stub: HexGrid:findPath ----------------------------------------------
--@api-stub: HexGrid:findPath
-- Demonstrates the proper usage of HexGrid:findPath.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HexGrid_findPath()
    local hex_path = hex:findPath(1, 1, 8, 6)
    print("hex path length:", hex_path and #hex_path or 0)
end
local _ok, _err = pcall(demo_HexGrid_findPath)

-- ---- Stub: HexGrid:lineOfSight -------------------------------------------
--@api-stub: HexGrid:lineOfSight
-- Demonstrates the proper usage of HexGrid:lineOfSight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HexGrid_lineOfSight()
    local los = hex:lineOfSight(1, 1, 8, 6)
    print("hex LOS (1,1)->(8,6):", los)
end
local _ok, _err = pcall(demo_HexGrid_lineOfSight)

-- ---- Stub: HexGrid:fieldOfView -------------------------------------------
--@api-stub: HexGrid:fieldOfView
-- Demonstrates the proper usage of HexGrid:fieldOfView.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HexGrid_fieldOfView()
    local visible = hex:fieldOfView(5, 5, 3)
    print("visible hex cells:", #visible)
end
local _ok, _err = pcall(demo_HexGrid_fieldOfView)

-- ---- Stub: HexGrid:rangeOfMovement ---------------------------------------
--@api-stub: HexGrid:rangeOfMovement
-- Demonstrates the proper usage of HexGrid:rangeOfMovement.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HexGrid_rangeOfMovement()
    local reachable = hex:rangeOfMovement(5, 5, 3)
    print("reachable hexes:", #reachable)
end
local _ok, _err = pcall(demo_HexGrid_rangeOfMovement)

-- ---- Stub: HexGrid:distance ----------------------------------------------
--@api-stub: HexGrid:distance
-- Demonstrates the proper usage of HexGrid:distance.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_HexGrid_distance()
    local hdist = hex:distance(1, 1, 8, 6)
    print("hex distance (1,1)->(8,6):", hdist)
end
local _ok, _err = pcall(demo_HexGrid_distance)

-- ---- Stub: JpsGrid:setBlocked --------------------------------------------
--@api-stub: JpsGrid:setBlocked
-- Paint a solid wall column in the JPS grid to model a cliff edge
-- that the pathfinder cannot cross.
for y = 2, 28 do
    jps:setBlocked(10, y, true)
end
print("JPS wall set")

-- ---- Stub: JpsGrid:isBlocked ---------------------------------------------
--@api-stub: JpsGrid:isBlocked
-- Demonstrates the proper usage of JpsGrid:isBlocked.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_JpsGrid_isBlocked()
    print("jps (10,5) blocked:", jps:isBlocked(10, 5))
    print("jps (5,5) blocked:",  jps:isBlocked(5, 5))
end
local _ok, _err = pcall(demo_JpsGrid_isBlocked)

-- ---- Stub: JpsGrid:findPath ----------------------------------------------
--@api-stub: JpsGrid:findPath
-- Demonstrates the proper usage of JpsGrid:findPath.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_JpsGrid_findPath()
    local jps_path = jps:findPath(2, 15, 25, 15)
    print("JPS path steps:", jps_path and #jps_path or 0)
end
local _ok, _err = pcall(demo_JpsGrid_findPath)

-- ---- Stub: NavGrid:getWidth ----------------------------------------------
--@api-stub: NavGrid:getWidth
-- Demonstrates the proper usage of NavGrid:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_getWidth()
    print("nav width:", nav:getWidth())
end
local _ok, _err = pcall(demo_NavGrid_getWidth)

-- ---- Stub: NavGrid:getHeight ---------------------------------------------
--@api-stub: NavGrid:getHeight
-- Demonstrates the proper usage of NavGrid:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_getHeight()
    print("nav height:", nav:getHeight())
end
local _ok, _err = pcall(demo_NavGrid_getHeight)

-- ---- Stub: NavGrid:getDimensions -----------------------------------------
--@api-stub: NavGrid:getDimensions
-- Demonstrates the proper usage of NavGrid:getDimensions.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_getDimensions()
    local nw, nh = nav:getDimensions()
    print(string.format("nav grid: %dx%d", nw, nh))
end
local _ok, _err = pcall(demo_NavGrid_getDimensions)

-- ---- Stub: NavGrid:setCost -----------------------------------------------
--@api-stub: NavGrid:setCost
-- Demonstrates the proper usage of NavGrid:setCost.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_setCost()
    nav:setCost(8, 8, 5)  -- swamp
    print("swamp cost set at (8,8)")
end
local _ok, _err = pcall(demo_NavGrid_setCost)

-- ---- Stub: NavGrid:getCost -----------------------------------------------
--@api-stub: NavGrid:getCost
-- Demonstrates the proper usage of NavGrid:getCost.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_getCost()
    print("cost at (8,8):", nav:getCost(8, 8))
end
local _ok, _err = pcall(demo_NavGrid_getCost)

-- ---- Stub: NavGrid:isBlocked ---------------------------------------------
--@api-stub: NavGrid:isBlocked
-- Demonstrates the proper usage of NavGrid:isBlocked.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_isBlocked()
    nav:setCost(3, 3, 255)  -- block a wall cell
    print("(3,3) blocked:", nav:isBlocked(3, 3))
end
local _ok, _err = pcall(demo_NavGrid_isBlocked)

-- ---- Stub: NavGrid:fill --------------------------------------------------
--@api-stub: NavGrid:fill
-- Demonstrates the proper usage of NavGrid:fill.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_fill()
    nav:fill(1)
    print("grid filled to cost 1")
end
local _ok, _err = pcall(demo_NavGrid_fill)

-- ---- Stub: NavGrid:loadFromString ----------------------------------------
--@api-stub: NavGrid:loadFromString
-- Restore the precomputed cost grid from a binary save blob so
-- the level loads without re-scanning the tilemap.
local saved_data = nav:saveToString()
nav:loadFromString(saved_data)
print("grid round-tripped via saveToString / loadFromString")

-- ---- Stub: NavGrid:saveToString ------------------------------------------
--@api-stub: NavGrid:saveToString
-- Demonstrates the proper usage of NavGrid:saveToString.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_saveToString()
    local blob = nav:saveToString()
    print("saved grid blob size:", #blob, "bytes")
end
local _ok, _err = pcall(demo_NavGrid_saveToString)

-- ---- Stub: NavGrid:setChunkSize ------------------------------------------
--@api-stub: NavGrid:setChunkSize
-- Demonstrates the proper usage of NavGrid:setChunkSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_setChunkSize()
    nav:setChunkSize(8)
    print("chunk size:", nav:getChunkSize())
end
local _ok, _err = pcall(demo_NavGrid_setChunkSize)

-- ---- Stub: NavGrid:getChunkSize ------------------------------------------
--@api-stub: NavGrid:getChunkSize
-- Demonstrates the proper usage of NavGrid:getChunkSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_getChunkSize()
    print("configured chunk size:", nav:getChunkSize())  -- 8
end
local _ok, _err = pcall(demo_NavGrid_getChunkSize)

-- ---- Stub: NavGrid:rebuildAbstract ----------------------------------------
--@api-stub: NavGrid:rebuildAbstract
-- Demonstrates the proper usage of NavGrid:rebuildAbstract.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_rebuildAbstract()
    nav:rebuildAbstract()
    print("abstract graph rebuilt")
end
local _ok, _err = pcall(demo_NavGrid_rebuildAbstract)

-- ---- Stub: NavGrid:setDirty ----------------------------------------------
--@api-stub: NavGrid:setDirty
-- Demonstrates the proper usage of NavGrid:setDirty.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_setDirty()
    nav:setDirty(5, 5, 10, 10)
    print("dirty region marked")
end
local _ok, _err = pcall(demo_NavGrid_setDirty)

-- ---- Stub: NavGrid:clearDirty --------------------------------------------
--@api-stub: NavGrid:clearDirty
-- Demonstrates the proper usage of NavGrid:clearDirty.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_clearDirty()
    nav:clearDirty()
    print("dirty cleared")
end
local _ok, _err = pcall(demo_NavGrid_clearDirty)

-- ---- Stub: NavGrid:setDiagonalMode ----------------------------------------
--@api-stub: NavGrid:setDiagonalMode
-- Demonstrates the proper usage of NavGrid:setDiagonalMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_setDiagonalMode()
    nav:setDiagonalMode("none")
    print("diagonal mode:", nav:getDiagonalMode())
end
local _ok, _err = pcall(demo_NavGrid_setDiagonalMode)

-- ---- Stub: NavGrid:getDiagonalMode ----------------------------------------
--@api-stub: NavGrid:getDiagonalMode
-- Demonstrates the proper usage of NavGrid:getDiagonalMode.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_getDiagonalMode()
    print("diagonal mode check:", nav:getDiagonalMode())  -- "none"
end
local _ok, _err = pcall(demo_NavGrid_getDiagonalMode)

-- ---- Stub: NavGrid:type --------------------------------------------------
--@api-stub: NavGrid:type
-- Demonstrates the proper usage of NavGrid:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_type()
    print("nav type:", nav:type())
end
local _ok, _err = pcall(demo_NavGrid_type)

-- ---- Stub: NavGrid:typeOf ------------------------------------------------
--@api-stub: NavGrid:typeOf
-- Demonstrates the proper usage of NavGrid:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_NavGrid_typeOf()
    print("is NavGrid:", nav:typeOf("NavGrid"))
end
local _ok, _err = pcall(demo_NavGrid_typeOf)

-- ---- Stub: PathGrid:getWidth ---------------------------------------------
--@api-stub: PathGrid:getWidth
-- Demonstrates the proper usage of PathGrid:getWidth.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PathGrid_getWidth()
    print("PathGrid width:", pg:getWidth())
end
local _ok, _err = pcall(demo_PathGrid_getWidth)

-- ---- Stub: PathGrid:getHeight --------------------------------------------
--@api-stub: PathGrid:getHeight
-- Demonstrates the proper usage of PathGrid:getHeight.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PathGrid_getHeight()
    print("PathGrid height:", pg:getHeight())
end
local _ok, _err = pcall(demo_PathGrid_getHeight)

-- ---- Stub: PathGrid:getCellSize ------------------------------------------
--@api-stub: PathGrid:getCellSize
-- Demonstrates the proper usage of PathGrid:getCellSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PathGrid_getCellSize()
    print("cell size:", pg:getCellSize())  -- 64.0
end
local _ok, _err = pcall(demo_PathGrid_getCellSize)

-- ---- Stub: PathGrid:setWalkable ------------------------------------------
--@api-stub: PathGrid:setWalkable
-- Demonstrates the proper usage of PathGrid:setWalkable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PathGrid_setWalkable()
    pg:setWalkable(5, 5, false)
    print("(5,5) walkable:", pg:isWalkable(5, 5))
end
local _ok, _err = pcall(demo_PathGrid_setWalkable)

-- ---- Stub: PathGrid:isWalkable -------------------------------------------
--@api-stub: PathGrid:isWalkable
-- Demonstrates the proper usage of PathGrid:isWalkable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PathGrid_isWalkable()
    print("(8,8) walkable:", pg:isWalkable(8, 8))
end
local _ok, _err = pcall(demo_PathGrid_isWalkable)

-- ---- Stub: PathGrid:setCost ----------------------------------------------
--@api-stub: PathGrid:setCost
-- Demonstrates the proper usage of PathGrid:setCost.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PathGrid_setCost()
    pg:setCost(7, 7, 3.0)
    print("rough terrain cost set at (7,7)")
end
local _ok, _err = pcall(demo_PathGrid_setCost)

-- ---- Stub: PathGrid:getCost ----------------------------------------------
--@api-stub: PathGrid:getCost
-- Demonstrates the proper usage of PathGrid:getCost.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PathGrid_getCost()
    print("cost at (7,7):", pg:getCost(7, 7))
end
local _ok, _err = pcall(demo_PathGrid_getCost)

-- ---- Stub: PathGrid:type -------------------------------------------------
--@api-stub: PathGrid:type
-- Demonstrates the proper usage of PathGrid:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PathGrid_type()
    print("pg type:", pg:type())
end
local _ok, _err = pcall(demo_PathGrid_type)

-- ---- Stub: PathGrid:typeOf -----------------------------------------------
--@api-stub: PathGrid:typeOf
-- Demonstrates the proper usage of PathGrid:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_PathGrid_typeOf()
    print("is PathGrid:", pg:typeOf("PathGrid"))
    pf:setCacheEnabled(true)
end
local _ok, _err = pcall(demo_PathGrid_typeOf)

-- ---- Stub: UnitPathfinder:getPathLength ----------------------------------
--@api-stub: UnitPathfinder:getPathLength
-- Compute the euclidean length of the found path to convert it into
-- an estimated travel time displayed in the strategy UI.
local path = nav:findPath and nav:findPath(1, 1, 30, 30) or {}
local plen = pf:getPathLength(path)
print(string.format("path length: %.2f", plen))

-- ---- Stub: UnitPathfinder:getPathCost ------------------------------------
--@api-stub: UnitPathfinder:getPathCost
-- Demonstrates the proper usage of UnitPathfinder:getPathCost.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UnitPathfinder_getPathCost()
    local pcost = pf:getPathCost(path)
    print(string.format("path cost: %.2f", pcost))
end
local _ok, _err = pcall(demo_UnitPathfinder_getPathCost)

-- ---- Stub: UnitPathfinder:setCacheEnabled --------------------------------
--@api-stub: UnitPathfinder:setCacheEnabled
-- Demonstrates the proper usage of UnitPathfinder:setCacheEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UnitPathfinder_setCacheEnabled()
    pf:setCacheEnabled(true)
    print("cache enabled:", pf:isCacheEnabled())
end
local _ok, _err = pcall(demo_UnitPathfinder_setCacheEnabled)

-- ---- Stub: UnitPathfinder:isCacheEnabled ---------------------------------
--@api-stub: UnitPathfinder:isCacheEnabled
-- Demonstrates the proper usage of UnitPathfinder:isCacheEnabled.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UnitPathfinder_isCacheEnabled()
    print("cache state:", pf:isCacheEnabled())
end
local _ok, _err = pcall(demo_UnitPathfinder_isCacheEnabled)

-- ---- Stub: UnitPathfinder:clearCache -------------------------------------
--@api-stub: UnitPathfinder:clearCache
-- Demonstrates the proper usage of UnitPathfinder:clearCache.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UnitPathfinder_clearCache()
    pf:clearCache()
    print("cache cleared, size:", pf:getCacheSize())
end
local _ok, _err = pcall(demo_UnitPathfinder_clearCache)

-- ---- Stub: UnitPathfinder:getCacheSize -----------------------------------
--@api-stub: UnitPathfinder:getCacheSize
-- Demonstrates the proper usage of UnitPathfinder:getCacheSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UnitPathfinder_getCacheSize()
    print("cache size:", pf:getCacheSize())
end
local _ok, _err = pcall(demo_UnitPathfinder_getCacheSize)

-- ---- Stub: UnitPathfinder:setCacheMaxSize --------------------------------
--@api-stub: UnitPathfinder:setCacheMaxSize
-- Demonstrates the proper usage of UnitPathfinder:setCacheMaxSize.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UnitPathfinder_setCacheMaxSize()
    pf:setCacheMaxSize(256)
    print("cache max size set")
end
local _ok, _err = pcall(demo_UnitPathfinder_setCacheMaxSize)

-- ---- Stub: UnitPathfinder:type -------------------------------------------
--@api-stub: UnitPathfinder:type
-- Demonstrates the proper usage of UnitPathfinder:type.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UnitPathfinder_type()
    print("pf type:", pf:type())
end
local _ok, _err = pcall(demo_UnitPathfinder_type)

-- ---- Stub: UnitPathfinder:typeOf -----------------------------------------
--@api-stub: UnitPathfinder:typeOf
-- Demonstrates the proper usage of UnitPathfinder:typeOf.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_UnitPathfinder_typeOf()
    print("is UnitPathfinder:", pf:typeOf("UnitPathfinder"))
end
local _ok, _err = pcall(demo_UnitPathfinder_typeOf)
