-- content/examples/pathfind.lua
-- love2d-style usage snippets for the lurek.pathfind API (65 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/pathfind.lua

-- ── lurek.pathfind.* functions ──

--@api-stub: lurek.pathfind.newNavGrid
-- Creates a new NavGrid with all cells walkable.
-- Build once at startup; reuse across frames.
local navgrid = lurek.pathfind.newNavGrid(64, 64)
print("created", navgrid)
return navgrid

--@api-stub: lurek.pathfind.newPathfinder
-- Creates a new UnitPathfinder backed by a NavGrid.
-- Build once at startup; reuse across frames.
local pathfinder = lurek.pathfind.newPathfinder(grid_ud)
print("created", pathfinder)
return pathfinder

--@api-stub: lurek.pathfind.newFlowField
-- Creates a new FlowField backed by a NavGrid.
-- Build once at startup; reuse across frames.
local flowfield = lurek.pathfind.newFlowField(grid_ud)
print("created", flowfield)
return flowfield

--@api-stub: lurek.pathfind.newPathGrid
-- Creates a new PathGrid with per-cell cost and walkability.
-- Build once at startup; reuse across frames.
local pathgrid = lurek.pathfind.newPathGrid(64, 64, cell_size)
print("created", pathgrid)
return pathgrid

--@api-stub: lurek.pathfind.newPathFlowField
-- Creates a new BFS flow field from a PathGrid.
-- Build once at startup; reuse across frames.
local pathflowfield = lurek.pathfind.newPathFlowField(grid_ud)
print("created", pathflowfield)
return pathflowfield

--@api-stub: lurek.pathfind.setThreadCount
-- Sets the background pathfinding thread count (currently a no-op).
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.pathfind.setThreadCount(10)
print("setThreadCount applied")
print("ok")

--@api-stub: lurek.pathfind.getThreadCount
-- Returns the background pathfinding thread count (currently always 0).
-- Cheap to call; safe inside callbacks.
local value = lurek.pathfind.getThreadCount()
print("getThreadCount:", value)
return value

--@api-stub: lurek.pathfind.newNavGridFromTileMap
-- Builds a NavGrid from a TileMap layer, treating specified GIDs as blocked (unwalkable).
-- Build once at startup; reuse across frames.
local navgridfromtilemap = lurek.pathfind.newNavGridFromTileMap(tm_ud, 1, { x = 0, y = 0 })
print("created", navgridfromtilemap)
return navgridfromtilemap

--@api-stub: lurek.pathfind.newHexGrid
-- Creates a hex grid for pathfinding, LOS, FOV, and range queries.
-- Build once at startup; reuse across frames.
local hexgrid = lurek.pathfind.newHexGrid(64, 64, "hello")
print("created", hexgrid)
return hexgrid

--@api-stub: lurek.pathfind.newJpsGrid
-- Creates a uniform-cost grid optimised for Jump Point Search (orthogonal + diagonal).
-- Build once at startup; reuse across frames.
local jpsgrid = lurek.pathfind.newJpsGrid(64, 64)
print("created", jpsgrid)
return jpsgrid

--@api-stub: lurek.pathfind.rangeMap
-- Computes a Dijkstra range-of-movement map from an origin within a movement budget.
-- See the module spec for detailed semantics.
local result = lurek.pathfind.rangeMap({ x = 0, y = 0 })
print("rangeMap:", result)
return result

-- ── NavGrid methods ──

--@api-stub: NavGrid:getWidth
-- Returns the grid width in cells.
-- Cheap to call; safe inside callbacks.
local navGrid = lurek.pathfind.newNavGrid()  -- or your existing handle
local value = navGrid:getWidth()
print("NavGrid:getWidth ->", value)

--@api-stub: NavGrid:getHeight
-- Returns the grid height in cells.
-- Cheap to call; safe inside callbacks.
local navGrid = lurek.pathfind.newNavGrid()  -- or your existing handle
local value = navGrid:getHeight()
print("NavGrid:getHeight ->", value)

--@api-stub: NavGrid:getDimensions
-- Returns the grid dimensions as width, height.
-- Cheap to call; safe inside callbacks.
local navGrid = lurek.pathfind.newNavGrid()  -- or your existing handle
local value = navGrid:getDimensions()
print("NavGrid:getDimensions ->", value)

--@api-stub: NavGrid:setCost
-- Sets the traversal cost of a cell (1-based coordinates).
-- Apply at startup or in response to user input.
local navGrid = lurek.pathfind.newNavGrid()
navGrid:setCost(100, 100, cost)
print("NavGrid:setCost applied")

--@api-stub: NavGrid:getCost
-- Returns the traversal cost of a cell (1-based coordinates).
-- Cheap to call; safe inside callbacks.
local navGrid = lurek.pathfind.newNavGrid()  -- or your existing handle
local value = navGrid:getCost(100, 100)
print("NavGrid:getCost ->", value)

--@api-stub: NavGrid:isBlocked
-- Returns true if the cell is blocked (1-based coordinates).
-- Use as a guard inside lurek.update or event handlers.
local navGrid = lurek.pathfind.newNavGrid()
if navGrid:isBlocked(100, 100) then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: NavGrid:fill
-- Sets every cell to the given cost.
-- See the module spec for detailed semantics.
local navGrid = lurek.pathfind.newNavGrid()
navGrid:fill(cost)
print("NavGrid:fill done")

--@api-stub: NavGrid:loadFromString
-- Overwrites the grid from a raw byte string (row-major, one byte per cell).
-- May block — call from a worker thread for large payloads.
local navGrid = lurek.pathfind.newNavGrid()
navGrid:loadFromString({ x = 0, y = 0 })
print("NavGrid:loadFromString done")

--@api-stub: NavGrid:saveToString
-- Exports the cost grid as a byte string (row-major, one byte per cell).
-- May block — call from a worker thread for large payloads.
local navGrid = lurek.pathfind.newNavGrid()
navGrid:saveToString()
print("NavGrid:saveToString done")

--@api-stub: NavGrid:setChunkSize
-- Sets the HPA★ chunk size.
-- Apply at startup or in response to user input.
local navGrid = lurek.pathfind.newNavGrid()
navGrid:setChunkSize(10)
print("NavGrid:setChunkSize applied")

--@api-stub: NavGrid:getChunkSize
-- Returns the current HPA★ chunk size.
-- Cheap to call; safe inside callbacks.
local navGrid = lurek.pathfind.newNavGrid()  -- or your existing handle
local value = navGrid:getChunkSize()
print("NavGrid:getChunkSize ->", value)

--@api-stub: NavGrid:rebuildAbstract
-- Rebuilds the HPA★ abstract graph from the current grid state.
-- See the module spec for detailed semantics.
local navGrid = lurek.pathfind.newNavGrid()
navGrid:rebuildAbstract()
print("NavGrid:rebuildAbstract done")

--@api-stub: NavGrid:setDirty
-- Records a dirty rectangle for incremental HPA★ updates (1-based coordinates).
-- Apply at startup or in response to user input.
local navGrid = lurek.pathfind.newNavGrid()
navGrid:setDirty(100, 100, 64, 64)
print("NavGrid:setDirty applied")

--@api-stub: NavGrid:clearDirty
-- Clears all pending dirty rectangles.
-- Pair with the matching constructor to free resources.
local navGrid = lurek.pathfind.newNavGrid()
navGrid:clearDirty()
-- navGrid is now released
print("ok")

--@api-stub: NavGrid:setDiagonalMode
-- Sets the diagonal movement mode.
-- Apply at startup or in response to user input.
local navGrid = lurek.pathfind.newNavGrid()
navGrid:setDiagonalMode(mode)
print("NavGrid:setDiagonalMode applied")

--@api-stub: NavGrid:getDiagonalMode
-- Returns the current diagonal movement mode as a string.
-- Cheap to call; safe inside callbacks.
local navGrid = lurek.pathfind.newNavGrid()  -- or your existing handle
local value = navGrid:getDiagonalMode()
print("NavGrid:getDiagonalMode ->", value)

--@api-stub: NavGrid:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local navGrid = lurek.pathfind.newNavGrid()
navGrid:type()
print("NavGrid:type done")

--@api-stub: NavGrid:typeOf
-- Returns true if this object is of the given type.
-- See the module spec for detailed semantics.
local navGrid = lurek.pathfind.newNavGrid()
navGrid:typeOf("main")
print("NavGrid:typeOf done")

-- ── UnitPathfinder methods ──

--@api-stub: UnitPathfinder:getPathLength
-- Returns the euclidean length of a path table.
-- Cheap to call; safe inside callbacks.
local unitPathfinder = lurek.pathfind.newUnitPathfinder()  -- or your existing handle
local value = unitPathfinder:getPathLength("data/file.txt")
print("UnitPathfinder:getPathLength ->", value)

--@api-stub: UnitPathfinder:getPathCost
-- Returns the sum of grid traversal costs along a path.
-- Cheap to call; safe inside callbacks.
local unitPathfinder = lurek.pathfind.newUnitPathfinder()  -- or your existing handle
local value = unitPathfinder:getPathCost("data/file.txt")
print("UnitPathfinder:getPathCost ->", value)

--@api-stub: UnitPathfinder:setCacheEnabled
-- Enables or disables path result caching.
-- Apply at startup or in response to user input.
local unitPathfinder = lurek.pathfind.newUnitPathfinder()
unitPathfinder:setCacheEnabled(enabled)
print("UnitPathfinder:setCacheEnabled applied")

--@api-stub: UnitPathfinder:isCacheEnabled
-- Returns true if path result caching is enabled.
-- Use as a guard inside lurek.update or event handlers.
local unitPathfinder = lurek.pathfind.newUnitPathfinder()
if unitPathfinder:isCacheEnabled() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: UnitPathfinder:clearCache
-- Removes all cached path results.
-- Pair with the matching constructor to free resources.
local unitPathfinder = lurek.pathfind.newUnitPathfinder()
unitPathfinder:clearCache()
-- unitPathfinder is now released
print("ok")

--@api-stub: UnitPathfinder:getCacheSize
-- Returns the number of entries in the path cache.
-- Cheap to call; safe inside callbacks.
local unitPathfinder = lurek.pathfind.newUnitPathfinder()  -- or your existing handle
local value = unitPathfinder:getCacheSize()
print("UnitPathfinder:getCacheSize ->", value)

--@api-stub: UnitPathfinder:setCacheMaxSize
-- Sets the maximum number of cached path entries.
-- Apply at startup or in response to user input.
local unitPathfinder = lurek.pathfind.newUnitPathfinder()
unitPathfinder:setCacheMaxSize(10)
print("UnitPathfinder:setCacheMaxSize applied")

--@api-stub: UnitPathfinder:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local unitPathfinder = lurek.pathfind.newUnitPathfinder()
unitPathfinder:type()
print("UnitPathfinder:type done")

--@api-stub: UnitPathfinder:typeOf
-- Returns true if this object is of the given type.
-- See the module spec for detailed semantics.
local unitPathfinder = lurek.pathfind.newUnitPathfinder()
unitPathfinder:typeOf("main")
print("UnitPathfinder:typeOf done")

-- ── FlowField methods ──

--@api-stub: FlowField:getDirection
-- Returns the normalised direction vector at a cell (1-based coordinates).
-- Cheap to call; safe inside callbacks.
local flowField = lurek.pathfind.newFlowField()  -- or your existing handle
local value = flowField:getDirection(100, 100)
print("FlowField:getDirection ->", value)

--@api-stub: FlowField:getDirectionAngle
-- Returns the flow direction as an angle in radians (1-based coordinates).
-- Cheap to call; safe inside callbacks.
local flowField = lurek.pathfind.newFlowField()  -- or your existing handle
local value = flowField:getDirectionAngle(100, 100)
print("FlowField:getDirectionAngle ->", value)

--@api-stub: FlowField:getCostToTarget
-- Returns the integrated cost to the nearest target (1-based coordinates).
-- Cheap to call; safe inside callbacks.
local flowField = lurek.pathfind.newFlowField()  -- or your existing handle
local value = flowField:getCostToTarget(100, 100)
print("FlowField:getCostToTarget ->", value)

--@api-stub: FlowField:isCalculated
-- Returns true if the flow field has been computed at least once.
-- Use as a guard inside lurek.update or event handlers.
local flowField = lurek.pathfind.newFlowField()
if flowField:isCalculated() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: FlowField:getTargets
-- Returns the target cells from the most recent computation (1-based coordinates).
-- Cheap to call; safe inside callbacks.
local flowField = lurek.pathfind.newFlowField()  -- or your existing handle
local value = flowField:getTargets()
print("FlowField:getTargets ->", value)

--@api-stub: FlowField:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local flowField = lurek.pathfind.newFlowField()
flowField:type()
print("FlowField:type done")

--@api-stub: FlowField:typeOf
-- Returns true if this object is of the given type.
-- See the module spec for detailed semantics.
local flowField = lurek.pathfind.newFlowField()
flowField:typeOf("main")
print("FlowField:typeOf done")

-- ── PathGrid methods ──

--@api-stub: PathGrid:getWidth
-- Returns the grid width in cells.
-- Cheap to call; safe inside callbacks.
local pathGrid = lurek.pathfind.newPathGrid()  -- or your existing handle
local value = pathGrid:getWidth()
print("PathGrid:getWidth ->", value)

--@api-stub: PathGrid:getHeight
-- Returns the grid height in cells.
-- Cheap to call; safe inside callbacks.
local pathGrid = lurek.pathfind.newPathGrid()  -- or your existing handle
local value = pathGrid:getHeight()
print("PathGrid:getHeight ->", value)

--@api-stub: PathGrid:getCellSize
-- Returns the world-space size of each cell.
-- Cheap to call; safe inside callbacks.
local pathGrid = lurek.pathfind.newPathGrid()  -- or your existing handle
local value = pathGrid:getCellSize()
print("PathGrid:getCellSize ->", value)

--@api-stub: PathGrid:setWalkable
-- Sets the walkability of a cell (1-based coordinates).
-- Apply at startup or in response to user input.
local pathGrid = lurek.pathfind.newPathGrid()
pathGrid:setWalkable(100, 100, 64)
print("PathGrid:setWalkable applied")

--@api-stub: PathGrid:isWalkable
-- Returns true if a cell is walkable (1-based coordinates).
-- Use as a guard inside lurek.update or event handlers.
local pathGrid = lurek.pathfind.newPathGrid()
if pathGrid:isWalkable(100, 100) then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: PathGrid:setCost
-- Sets the cost multiplier for a cell (1-based coordinates).
-- Apply at startup or in response to user input.
local pathGrid = lurek.pathfind.newPathGrid()
pathGrid:setCost(100, 100, cost)
print("PathGrid:setCost applied")

--@api-stub: PathGrid:getCost
-- Returns the cost multiplier for a cell (1-based coordinates).
-- Cheap to call; safe inside callbacks.
local pathGrid = lurek.pathfind.newPathGrid()  -- or your existing handle
local value = pathGrid:getCost(100, 100)
print("PathGrid:getCost ->", value)

--@api-stub: PathGrid:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local pathGrid = lurek.pathfind.newPathGrid()
pathGrid:type()
print("PathGrid:type done")

--@api-stub: PathGrid:typeOf
-- Returns true if this object is of the given type.
-- See the module spec for detailed semantics.
local pathGrid = lurek.pathfind.newPathGrid()
pathGrid:typeOf("main")
print("PathGrid:typeOf done")

-- ── AiFlowField methods ──

--@api-stub: AiFlowField:getWidth
-- Returns the flow field grid width in cells.
-- Cheap to call; safe inside callbacks.
local aiFlowField = lurek.pathfind.newAiFlowField()  -- or your existing handle
local value = aiFlowField:getWidth()
print("AiFlowField:getWidth ->", value)

--@api-stub: AiFlowField:getHeight
-- Returns the flow field grid height in cells.
-- Cheap to call; safe inside callbacks.
local aiFlowField = lurek.pathfind.newAiFlowField()  -- or your existing handle
local value = aiFlowField:getHeight()
print("AiFlowField:getHeight ->", value)

--@api-stub: AiFlowField:hasGoal
-- Returns true if a goal has been set.
-- Use as a guard inside lurek.update or event handlers.
local aiFlowField = lurek.pathfind.newAiFlowField()
if aiFlowField:hasGoal() then print("yes") end
-- swap the constructor for your real handle
print("ok")

--@api-stub: AiFlowField:setGoal
-- Sets the goal cell and triggers BFS recomputation (1-based coordinates).
-- Apply at startup or in response to user input.
local aiFlowField = lurek.pathfind.newAiFlowField()
aiFlowField:setGoal(100, 100)
print("AiFlowField:setGoal applied")

--@api-stub: AiFlowField:getDirection
-- Returns the normalised direction toward the goal (1-based coordinates).
-- Cheap to call; safe inside callbacks.
local aiFlowField = lurek.pathfind.newAiFlowField()  -- or your existing handle
local value = aiFlowField:getDirection(100, 100)
print("AiFlowField:getDirection ->", value)

--@api-stub: AiFlowField:getDistance
-- Returns the BFS distance to the goal (1-based coordinates).
-- Cheap to call; safe inside callbacks.
local aiFlowField = lurek.pathfind.newAiFlowField()  -- or your existing handle
local value = aiFlowField:getDistance(100, 100)
print("AiFlowField:getDistance ->", value)

--@api-stub: AiFlowField:type
-- Returns the type name of this object.
-- See the module spec for detailed semantics.
local aiFlowField = lurek.pathfind.newAiFlowField()
aiFlowField:type()
print("AiFlowField:type done")

--@api-stub: AiFlowField:typeOf
-- Returns true if this object is of the given type.
-- See the module spec for detailed semantics.
local aiFlowField = lurek.pathfind.newAiFlowField()
aiFlowField:typeOf("main")
print("AiFlowField:typeOf done")

-- ── HexGrid methods ──

--@api-stub: HexGrid:setCost
-- Set movement cost for a cell (1-based coordinates).
-- Apply at startup or in response to user input.
local hexGrid = lurek.pathfind.newHexGrid()
hexGrid:setCost(col, row, cost)
print("HexGrid:setCost applied")

--@api-stub: HexGrid:isBlocked
-- Returns true if a cell is blocked (1-based coordinates).
-- Use as a guard inside lurek.update or event handlers.
local hexGrid = lurek.pathfind.newHexGrid()
if hexGrid:isBlocked(col, row) then print("yes") end
-- swap the constructor for your real handle
print("ok")

-- ── JpsGrid methods ──

--@api-stub: JpsGrid:isBlocked
-- Returns true if the cell is blocked (1-based coordinates).
-- Use as a guard inside lurek.update or event handlers.
local jpsGrid = lurek.pathfind.newJpsGrid()
if jpsGrid:isBlocked(100, 100) then print("yes") end
-- swap the constructor for your real handle
print("ok")

