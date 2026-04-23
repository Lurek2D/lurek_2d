# Lua Spec Coverage

_Auto-generated 2026-04-23 — `python tools/audit/lua_spec_coverage.py`_

| Module | Bound | In Spec | Missing | Stale | Coverage |
| ------ | ----: | ------: | ------: | ----: | -------: |
| `ai` | 35 | 0 | 35 | 0 | 0.0% |
| `animation` | 8 | 0 | 8 | 0 | 0.0% |
| `audio` | 99 | 1 | 98 | 0 | 1.0% |
| `automation` | 28 | 0 | 28 | 0 | 0.0% |
| `camera` | 1 | 0 | 1 | 0 | 0.0% |
| `compute` | 11 | 0 | 11 | 0 | 0.0% |
| `data` | 19 | 0 | 19 | 0 | 0.0% |
| `dataframe` | 7 | 0 | 7 | 0 | 0.0% |
| `devtools` | 14 | 0 | 14 | 0 | 0.0% |
| `docs` | 34 | 0 | 34 | 0 | 0.0% |
| `ecs` | 1 | 0 | 1 | 0 | 0.0% |
| `effect` | 11 | 0 | 11 | 0 | 0.0% |
| `engine` | 0 | — | — | — | — |
| `event` | 14 | 1 | 13 | 0 | 7.1% |
| `filesystem` | 37 | 0 | 37 | 0 | 0.0% |
| `globe` | 10 | 0 | 10 | 0 | 0.0% |
| `graph` | 1 | 0 | 1 | 0 | 0.0% |
| `image` | 10 | 0 | 10 | 0 | 0.0% |
| `input` | 26 | 0 | 26 | 0 | 0.0% |
| `light` | 18 | 0 | 18 | 0 | 0.0% |
| `math` | 113 | 0 | 113 | 0 | 0.0% |
| `minimap` | 1 | 0 | 1 | 0 | 0.0% |
| `mods` | 4 | 0 | 4 | 0 | 0.0% |
| `network` | 13 | 0 | 13 | 1 | 0.0% |
| `particle` | 3 | 0 | 3 | 0 | 0.0% |
| `pathfind` | 11 | 0 | 11 | 0 | 0.0% |
| `physics` | 51 | 0 | 51 | 0 | 0.0% |
| `pipeline` | 3 | 0 | 3 | 0 | 0.0% |
| `procgen` | 29 | 0 | 29 | 0 | 0.0% |
| `raycaster` | 12 | 0 | 12 | 0 | 0.0% |
| `save` | 1 | 0 | 1 | 1 | 0.0% |
| `scene` | 46 | 0 | 46 | 3 | 0.0% |
| `serial` | 10 | 0 | 10 | 0 | 0.0% |
| `spine` | 2 | 0 | 2 | 0 | 0.0% |
| `sprite` | 5 | 0 | 5 | 0 | 0.0% |
| `system` | 0 | — | — | — | — |
| `terminal` | 29 | 0 | 29 | 0 | 0.0% |
| `thread` | 5 | 0 | 5 | 0 | 0.0% |
| `tilemap` | 36 | 0 | 36 | 0 | 0.0% |
| `timer` | 22 | 0 | 22 | 1 | 0.0% |
| `tween` | 12 | 2 | 10 | 1 | 16.7% |
| `ui` | 75 | 0 | 75 | 0 | 0.0% |
| `window` | 50 | 0 | 50 | 0 | 0.0% |

## Gaps

### `ai`
- **Missing from spec**: `newAIDirector`, `newAILod`, `newAction`, `newBandit`, `newBehaviorTree`, `newBlackboard`, `newCommandQueue`, `newCondition`, `newContextSteering`, `newEmotionModel`, `newGOAPPlanner`, `newGeneticAlgorithm`, `newGuard`, `newHTNDomain`, `newInfluenceMap`, `newInverter`, `newMCTSEngine`, `newNeedSystem`, `newNeuralNet`, `newNeuroevolution` (+15 more)

### `animation`
- **Missing from spec**: `frame`, `fromAseprite`, `new`, `newBlendLayerSet`, `newCurve`, `newStateMachine`, `newSyncGroup`, `type`

### `audio`
- **Missing from spec**: `add_effect`, `applyBandpass`, `applyGain`, `applyHighpass`, `applyLowpass`, `clearFilter`, `clearMidiSoundFont`, `clearRandomPitch`, `clone`, `create_bus`, `crossfade`, `fadeIn`, `getActiveSourceCount`, `getBusPeak`, `getBusRms`, `getDistanceModel`, `getDopplerScale`, `getDuration`, `getFadeIn`, `getFreeBufferCount` (+78 more)

### `automation`
- **Missing from spec**: `getCurrentScript`, `getCurrentStep`, `getElapsedTime`, `getPlaybackSpeed`, `getScripts`, `getStepCount`, `getStepLimit`, `hasMacro`, `hasScript`, `isComplete`, `isHighlightMode`, `isPaused`, `isRunning`, `listMacros`, `load`, `loadFromToml`, `pause`, `playMacro`, `resume`, `saveMacro` (+8 more)

### `camera`
- **Missing from spec**: `new`

### `compute`
- **Missing from spec**: `affine2d`, `fft`, `fftMagnitude`, `fromTable`, `gaussianKernel`, `ifft`, `newArray`, `ones`, `range`, `rotate2dMatrix`, `zeros`

### `data`
- **Missing from spec**: `compress`, `crc32`, `decode`, `decompress`, `encode`, `encodeToml`, `fromMsgPack`, `getPackedSize`, `hash`, `newDataView`, `newRingBuffer`, `newWriter`, `pack`, `parseToml`, `read`, `size`, `toMsgPack`, `unpack`, `write`

### `dataframe`
- **Missing from spec**: `fromBinary`, `fromCSV`, `fromJSON`, `fromTable`, `newDataFrame`, `newDatabase`, `random`

### `devtools`
- **Missing from spec**: `avg`, `children`, `dt`, `fps`, `max`, `min`, `name`, `p50`, `p95`, `p99`, `samples`, `selfTime`, `startTime`, `time`

### `docs`
- **Missing from spec**: `checkStaleness`, `coverage`, `coverageModule`, `current`, `describe`, `exportAll`, `exportCheatsheet`, `exportCompletions`, `exportHover`, `exportMarkdown`, `exportSignatures`, `getCatalog`, `grade`, `incomplete`, `loadAll`, `loadToml`, `missing`, `missing`, `moduleScores`, `overallScore` (+14 more)

### `ecs`
- **Missing from spec**: `newUniverse`

### `effect`
- **Missing from spec**: `getEffectTypes`, `getShaderErrorDisplay`, `newCustomEffect`, `newEffect`, `newImageEffect`, `newOverlay`, `newPass`, `newPresetStack`, `newStack`, `newTransition`, `setShaderErrorDisplay`

### `event`
- **Missing from spec**: `clear`, `clearHistory`, `enableHistory`, `flushDeferred`, `getHistory`, `newSignal`, `poll`, `pump`, `push`, `pushDeferred`, `quit`, `restart`, `wait`

### `filesystem`
- **Missing from spec**: `append`, `copy`, `createDirectory`, `createTempFile`, `exists`, `getDirectoryItems`, `getIdentity`, `getInfo`, `getSaveDirectory`, `getSource`, `getUserDirectory`, `getWorkingDirectory`, `glob`, `isDirectory`, `isFile`, `lines`, `listRecursive`, `load`, `mkdir`, `mount` (+17 more)

### `globe`
- **Missing from spec**: `LOD_FAR`, `LOD_MID`, `LOD_NEAR`, `MAX_PROVINCES`, `get`, `greatCircleDistance`, `greatCirclePath`, `latLonToUnit`, `loadFromTOML`, `new`

### `graph`
- **Missing from spec**: `newGraph`

### `image`
- **Missing from spec**: `isCompressed`, `loadImage`, `loadLayered`, `newCompressedData`, `newImageData`, `newLayeredImage`, `newPaletteLut`, `newProvinceGrid`, `saveImage`, `savePNG`

### `input`
- **Missing from spec**: `advancePlayback`, `bind`, `clearBindings`, `gamepad`, `gap_ms`, `getBindings`, `getPlaybackFrame`, `isActionDown`, `isPlayingBack`, `isRecording`, `key`, `keyboard`, `kind`, `loadRecording`, `mouse`, `name`, `newCombo`, `startPlayback`, `startRecording`, `stopPlayback` (+6 more)

### `light`
- **Missing from spec**: `advanceFlickers`, `clear`, `getAmbient`, `getGodRayHints`, `getGroupCount`, `getLightCount`, `getMaxLights`, `getOccluderCount`, `isEnabled`, `newLight`, `newOccluder`, `setAmbient`, `setEnabled`, `setGroupColor`, `setGroupEnabled`, `setGroupIntensity`, `setMaxLights`, `syncAmbient`

### `math`
- **Missing from spec**: `Vec2`, `Vec3`, `aabbTree`, `abs`, `acos`, `angleBetween`, `applyEasing`, `asin`, `atan`, `atan2`, `bresenham`, `catmullRom`, `ceil`, `circleContainsPoint`, `circleIntersectsCircle`, `circleIntersectsLine`, `circleIntersectsSegment`, `clamp`, `clamp`, `closestPointOnSegment` (+93 more)

### `minimap`
- **Missing from spec**: `newMinimap`

### `mods`
- **Missing from spec**: `checkApiVersion`, `newMod`, `newModManager`, `newRegistry`

### `network`
- **Missing from spec**: `DEFAULT_CHANNELS`, `DEFAULT_PEERS`, `MAX_CHANNELS`, `MAX_PEERS`, `createLobby`, `discoverLobbies`, `newClient`, `newHost`, `newRuntime`, `newServer`, `pack`, `syncEntity`, `unpack`
- **Stale in spec**: `poll`

### `particle`
- **Missing from spec**: `fromTOML`, `newSystem`, `newTrail`

### `pathfind`
- **Missing from spec**: `getThreadCount`, `newFlowField`, `newHexGrid`, `newJpsGrid`, `newNavGrid`, `newNavGridFromTileMap`, `newPathFlowField`, `newPathGrid`, `newPathfinder`, `rangeMap`, `setThreadCount`

### `physics`
- **Missing from spec**: `CELL_AIR`, `CELL_FIRE`, `CELL_GAS`, `CELL_ROCK`, `CELL_SAND`, `CELL_WATER`, `attachShape`, `bodyA`, `bodyA`, `bodyA`, `bodyA`, `bodyA`, `bodyB`, `bodyB`, `bodyB`, `bodyB`, `bodyB`, `bodyId`, `debugDraw`, `destroyWorld` (+31 more)

### `pipeline`
- **Missing from spec**: `fromTable`, `newPipeline`, `newStep`

### `procgen`
- **Missing from spec**: `bspDungeon`, `bspDungeon`, `cellularAutomata`, `floodFill`, `generateName`, `generateName`, `generateNames`, `generateNames`, `heightmap`, `heightmap`, `lsystem`, `lsystem`, `lsystemSegments`, `lsystemSegments`, `noiseMap`, `noiseMap`, `noiseMapParallel`, `noiseMapParallel`, `perlinNoise`, `poissonDisk` (+9 more)

### `raycaster`
- **Missing from spec**: `distanceShade`, `new`, `newDoorManager`, `newHeightMap`, `newMap`, `newPointLight`, `newSpriteManager`, `openAmount`, `projectColumn`, `state`, `x`, `y`

### `save`
- **Missing from spec**: `newSaveManager`
- **Stale in spec**: `write`

### `scene`
- **Missing from spec**: `clear`, `define`, `depth`, `deserializeScene`, `draw`, `fade`, `getActiveScenes`, `getCurrent`, `getData`, `getRegistered`, `getRegisteredNames`, `getStackSize`, `getTransitionProgress`, `getTransitionProgressEased`, `getTransitionTypes`, `hasData`, `hasRegistered`, `iris`, `isEmpty`, `isOverlay` (+26 more)
- **Stale in spec**: `process_late`, `process_physics`, `ready`

### `serial`
- **Missing from spec**: `decodeMsgPack`, `decodeXml`, `encodeMsgPack`, `fromCsv`, `fromJson`, `fromToml`, `toCsv`, `toJson`, `toToml`, `validate`

### `spine`
- **Missing from spec**: `newSkeleton`, `newSkeletonAnimation`

### `sprite`
- **Missing from spec**: `newAtlasSheet`, `newRPGMakerSheet`, `newSheet`, `parseAsepriteAtlas`, `parseAtlas`

### `terminal`
- **Missing from spec**: `addCompletion`, `applyTheme`, `clearCmdHistory`, `clearCompletions`, `cmdHistoryLen`, `getCompletions`, `getMaxCols`, `getMaxRows`, `getScrollback`, `newBorder`, `newButton`, `newLabel`, `newList`, `newPanel`, `newTerminal`, `newTextBox`, `nextCmd`, `nextCompletion`, `parseAnsi`, `prevCmd` (+9 more)

### `thread`
- **Missing from spec**: `async`, `getChannel`, `newChannel`, `newPool`, `newThread`

### `tilemap`
- **Missing from spec**: `FLOOR`, `NORTH_WALL`, `OBJECT`, `WEST_WALL`, `fromLDtk`, `fromScreenHex`, `fromScreenIso`, `height`, `hexArea`, `hexDistance`, `hexLine`, `hexNeighbors`, `hexReflect`, `hexRing`, `hexRotate`, `hexRound`, `hexSpiral`, `isoDirectionFromAngle`, `isoDirectionName`, `isoRotate` (+16 more)

### `timer`
- **Missing from spec**: `afterReal`, `chain`, `delay`, `getAverageDelta`, `getDelta`, `getFPS`, `getFrameCount`, `getMicroTime`, `getPhysicsDelta`, `getPhysicsMaxSteps`, `getSmoothedDelta`, `getTime`, `newScheduler`, `setPhysicsDelta`, `setPhysicsMaxSteps`, `setSmoothingFactor`, `sleep`, `step`, `tickRealTimers`, `tickWaits` (+2 more)
- **Stale in spec**: `wait`

### `tween`
- **Missing from spec**: `cancelAll`, `delay`, `getActiveCount`, `getEasingNames`, `newState`, `parallel`, `registerEasing`, `sequence`, `spring`, `to`
- **Stale in spec**: `fn`

### `ui`
- **Missing from spec**: `addToast`, `clearFocus`, `draw`, `drawToImage`, `flushCache`, `focusNext`, `focusPrev`, `getFocus`, `getRoot`, `getTheme`, `getToastCount`, `getWidgetCount`, `keypressed`, `loadLayout`, `loadLayoutFile`, `mousemoved`, `mousepressed`, `mousereleased`, `newAccordion`, `newAreaChart` (+55 more)

### `window`
- **Missing from spec**: `close`, `focus`, `fromPixels`, `getDPIScale`, `getDesktopDimensions`, `getDimensions`, `getDisplayCount`, `getDisplayName`, `getDisplayOrientation`, `getFullscreen`, `getFullscreenModes`, `getGameHeight`, `getGameWidth`, `getHeight`, `getMode`, `getNativeDPIScale`, `getPixelDimensions`, `getPosition`, `getSafeArea`, `getScaleInfo` (+30 more)

## Summary

- Modules with Lua bindings: **41**
- Modules with spec files: **41**
- Total bound functions: **917**
- Total covered in spec: **4**
- Overall coverage: **0.4%**
