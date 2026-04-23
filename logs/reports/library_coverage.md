# Library Coverage

_Auto-generated 2026-04-23 — `python tools/audit/library_coverage.py`_

## Overview

| Library | Funcs | Doc% | @param% | @return% | API doc% | Test% | Test file? |
| ------- | ----: | ---: | ------: | -------: | -------: | ----: | :--------: |
| `battle` | 96 | 100.0 | 47.9 | 63.5 | 0.0 | 4.2 | ✅ |
| `cardgame` | 171 | 100.0 | 67.8 | 74.3 | 0.0 | 4.1 | ✅ |
| `cinematic` | 38 | 52.6 | 5.3 | 2.6 | 0.0 | 0.0 | ✅ |
| `combat` | 97 | 100.0 | 57.7 | 63.9 | 0.0 | 7.2 | ✅ |
| `crafting` | 167 | 85.0 | 50.9 | 68.3 | 0.0 | 10.2 | ✅ |
| `dialog` | 26 | 100.0 | 46.2 | 65.4 | 0.0 | 26.9 | ✅ |
| `doll` | 65 | 21.5 | 10.8 | 15.4 | 0.0 | 4.6 | ✅ |
| `economy` | 126 | 100.0 | 64.3 | 60.3 | 0.0 | 3.2 | ✅ |
| `inventory` | 90 | 100.0 | 58.9 | 81.1 | 0.0 | 6.7 | ✅ |
| `item` | 138 | 100.0 | 61.6 | 75.4 | 0.0 | 10.1 | ✅ |
| `lobby` | 22 | 100.0 | 40.9 | 72.7 | 0.0 | 50.0 | ✅ |
| `loot` | 32 | 100.0 | 65.6 | 93.8 | 0.0 | 0.0 | ✅ |
| `narrative` | 30 | 100.0 | 23.3 | 33.3 | 0.0 | 0.0 | ✅ |
| `netstate` | 34 | 88.2 | 47.1 | 58.8 | 0.0 | 0.0 | ✅ |
| `patterns` | 0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | ✅ |
| `province_map` | 82 | 98.8 | 75.6 | 68.3 | 0.0 | 19.5 | ✅ |
| `quest` | 56 | 100.0 | 60.7 | 83.9 | 0.0 | 7.1 | ✅ |
| `rhythm` | 26 | 15.4 | 3.8 | 3.8 | 0.0 | 0.0 | ✅ |
| `roguelike` | 32 | 40.6 | 3.1 | 6.2 | 0.0 | 0.0 | ✅ |
| `rpc` | 16 | 100.0 | 62.5 | 37.5 | 0.0 | 0.0 | ✅ |
| `scheduler` | 11 | 100.0 | 54.5 | 63.6 | 0.0 | 0.0 | ✅ |
| `stats` | 83 | 100.0 | 75.9 | 62.7 | 0.0 | 15.7 | ✅ |

## Summary

- Libraries audited: **22**
- Total public functions: **1438**
- Average docstring coverage: **81.9%**
- Average API doc coverage: **0.0%**
- Average test coverage: **7.7%**

## Gaps

### `battle`
- **Not in API doc**: `_checkBattleOver`, `addAction`, `addCombatant`, `addStatus`, `addTag`, `addToLog`, `attack`, `forceEnd`, `getAccuracy`, `getAction`, `getActionNames`, `getAliveNames`, `getAllNames`, `getBaseDamage`, `getCombatant` (+5 more)
- **No @covers**: `_checkBattleOver`, `addAction`, `addCombatant`, `addStatus`, `addTag`, `addToLog`, `attack`, `forceEnd`, `getAccuracy`, `getAction`, `getActionNames`, `getAliveNames`, `getAllNames`, `getBaseDamage`, `getCombatant` (+5 more)

### `cardgame`
- **Not in API doc**: `add`, `addCounter`, `addRequiredCategory`, `addRequiredTag`, `addStack`, `addStat`, `addTag`, `addWith`, `allHaveTag`, `banType`, `build`, `buildNamed`, `built`, `capacity`, `checkDeckLimit` (+5 more)
- **No @covers**: `add`, `addCounter`, `addRequiredCategory`, `addRequiredTag`, `addStack`, `addStat`, `addTag`, `addWith`, `allHaveTag`, `banType`, `build`, `buildNamed`, `built`, `capacity`, `checkDeckLimit` (+5 more)

### `cinematic`
- **Not in API doc**: `_recompute_duration`, `_reset_clip_flags`, `add`, `audio`, `branch`, `call`, `cameraTo`, `dialog`, `export`, `fromTable`, `fromToml`, `getDuration`, `getTime`, `isFinished`, `isPlaying` (+5 more)
- **No @covers**: `_recompute_duration`, `_reset_clip_flags`, `add`, `audio`, `branch`, `call`, `cameraTo`, `dialog`, `export`, `fromTable`, `fromToml`, `getDuration`, `getTime`, `isFinished`, `isPlaying` (+5 more)

### `combat`
- **Not in API doc**: `activeChassisCount`, `activeCount`, `activeProjectileCount`, `addChassis`, `addPool`, `addSlot`, `addTurret`, `addWeapon`, `aimAtAngle`, `canFire`, `clampToArc`, `cleanup`, `computeMask`, `defineGroup`, `fire` (+5 more)
- **No @covers**: `activeChassisCount`, `activeCount`, `activeProjectileCount`, `addChassis`, `addPool`, `addSlot`, `addTurret`, `addWeapon`, `aimAtAngle`, `canFire`, `clampToArc`, `cleanup`, `computeMask`, `defineGroup`, `fire` (+5 more)

### `crafting`
- **Not in API doc**: `activeIds`, `add`, `addAttachment`, `addByproduct`, `addCondition`, `addEdge`, `addEffect`, `addFuel`, `addGroup`, `addIngredient`, `addModule`, `addNode`, `addOutput`, `addPerkToTree`, `addRecipe` (+5 more)
- **No @covers**: `activeIds`, `add`, `addAttachment`, `addByproduct`, `addCondition`, `addEdge`, `addEffect`, `addFuel`, `addGroup`, `addIngredient`, `addModule`, `addNode`, `addOutput`, `addPerkToTree`, `addRecipe` (+5 more)

### `dialog`
- **Not in API doc**: `advance`, `call`, `choice`, `choose`, `currentSpeaker`, `currentText`, `event`, `getChoiceLabels`, `getChoiceText`, `getEventBus`, `getSpeed`, `getState`, `isActive`, `isWaitingForChoice`, `jump` (+5 more)
- **No @covers**: `advance`, `choose`, `currentSpeaker`, `currentText`, `getChoiceLabels`, `getChoiceText`, `getEventBus`, `getSpeed`, `getState`, `isActive`, `isWaitingForChoice`, `load`, `off`, `on`, `revealedText` (+4 more)

### `doll`
- **Not in API doc**: `_iterSockets`, `addSocket`, `attach`, `detach`, `detachAll`, `draw`, `findSocket`, `getAbsoluteScale`, `getAttachedSockets`, `getAttribute`, `getAttributeKeys`, `getAttributes`, `getBody`, `getColor`, `getDrawList` (+5 more)
- **No @covers**: `_iterSockets`, `addSocket`, `attach`, `detach`, `detachAll`, `draw`, `findSocket`, `getAbsoluteScale`, `getAttachedSockets`, `getAttribute`, `getAttributeKeys`, `getAttributes`, `getBody`, `getColor`, `getDrawList` (+5 more)

### `economy`
- **Not in API doc**: `_clamp`, `add`, `addConversionRule`, `addModifier`, `canAfford`, `canAffordAll`, `clearModifiers`, `convert`, `effectiveRate`, `exchange`, `getAvailable`, `getCapacity`, `getConversionRules`, `getCooldown`, `getDecayPercent` (+5 more)
- **No @covers**: `_clamp`, `add`, `addConversionRule`, `addModifier`, `canAfford`, `canAffordAll`, `clearModifiers`, `convert`, `effectiveRate`, `exchange`, `getAvailable`, `getCapacity`, `getConversionRules`, `getCooldown`, `getDecayPercent` (+5 more)

### `inventory`
- **Not in API doc**: `add`, `addContainer`, `addEquipSlot`, `addItem`, `addItemSet`, `addRequirement`, `addSlot`, `addTag`, `canAccept`, `clear`, `clone`, `containerNames`, `countItem`, `disableSubsystem`, `enableSubsystem` (+5 more)
- **No @covers**: `add`, `addContainer`, `addEquipSlot`, `addItem`, `addItemSet`, `addRequirement`, `addSlot`, `addTag`, `canAccept`, `clear`, `clone`, `containerNames`, `countItem`, `disableSubsystem`, `enableSubsystem` (+5 more)

### `item`
- **Not in API doc**: `add`, `addCounter`, `addStack`, `addStat`, `addTag`, `addType`, `addWith`, `banType`, `build`, `buildNamed`, `clear`, `clearTypes`, `clone`, `count`, `countByCategory` (+5 more)
- **No @covers**: `add`, `addCounter`, `addStack`, `addStat`, `addTag`, `addType`, `addWith`, `banType`, `build`, `buildNamed`, `clear`, `clearTypes`, `clone`, `count`, `countByCategory` (+5 more)

### `lobby`
- **Not in API doc**: `_handle`, `addPlayer`, `createRoom`, `getCurrentRoom`, `getEventBus`, `getHost`, `getPlayerCount`, `getPlayers`, `getRoomCount`, `isAllReady`, `joinRoom`, `leaveRoom`, `listRooms`, `new`, `onEvent` (+5 more)
- **No @covers**: `_handle`, `addPlayer`, `getCurrentRoom`, `getEventBus`, `getHost`, `getPlayerCount`, `new`, `poll`, `removePlayer`

### `loot`
- **Not in API doc**: `add`, `apply`, `clone`, `explain`, `fromList`, `fromToml`, `getCounter`, `getDefaultRng`, `guarantee`, `ids`, `isPrimed`, `merge`, `newDrop`, `newModifier`, `newPity` (+5 more)
- **No @covers**: `add`, `apply`, `clone`, `explain`, `fromList`, `fromToml`, `getCounter`, `getDefaultRng`, `guarantee`, `ids`, `isPrimed`, `merge`, `newDrop`, `newModifier`, `newPity` (+5 more)

### `narrative`
- **Not in API doc**: `bindFunction`, `canContinue`, `choose`, `compile`, `continue`, `continueAll`, `dumpProfile`, `formatList`, `fromBytecode`, `getChoices`, `getVar`, `gotoKnot`, `isAtChoice`, `isEnded`, `listVars` (+5 more)
- **No @covers**: `bindFunction`, `canContinue`, `choose`, `compile`, `continue`, `continueAll`, `dumpProfile`, `formatList`, `fromBytecode`, `getChoices`, `getVar`, `gotoKnot`, `isAtChoice`, `isEnded`, `listVars` (+5 more)

### `netstate`
- **Not in API doc**: `_broadcastTurn`, `_fireCallbacks`, `_handle`, `_markDirty`, `_sendFullState`, `beginTurn`, `clearCallbacks`, `endTurn`, `get`, `getAll`, `getCurrentTurn`, `getDirtyCount`, `getKeyCount`, `getKeyVersion`, `getTurnPeer` (+5 more)
- **No @covers**: `_broadcastTurn`, `_fireCallbacks`, `_handle`, `_markDirty`, `_sendFullState`, `beginTurn`, `clearCallbacks`, `endTurn`, `get`, `getAll`, `getCurrentTurn`, `getDirtyCount`, `getKeyCount`, `getKeyVersion`, `getTurnPeer` (+5 more)

### `province_map`
- **Not in API doc**: `addBuilding`, `addEdgeTag`, `adjacencyCount`, `adjacencyToGraph`, `allFactions`, `applyCategoryColor`, `applyGradientColor`, `calculateAllPositions`, `calculateCapital`, `colorToId`, `detectAdjacency`, `detectAdjacencyWithTags`, `distance`, `drain`, `emitAdjacencyChanged` (+5 more)
- **No @covers**: `addBuilding`, `addEdgeTag`, `adjacencyCount`, `calculateAllPositions`, `calculateCapital`, `colorToId`, `distance`, `drain`, `emitAdjacencyChanged`, `emitAdjacencyDetected`, `emitAdjacencyRemoved`, `emitBordersExtracted`, `emitFactionChanged`, `emitMapLoaded`, `emitMapModeApplied` (+5 more)

### `quest`
- **Not in API doc**: `activeCount`, `activeIds`, `activeObjectiveIds`, `addJournalEntry`, `addObjective`, `addQuest`, `addStage`, `addTag`, `advance`, `advanceObjective`, `allObjectivesComplete`, `clearObjectives`, `complete`, `completeQuest`, `completedCount` (+5 more)
- **No @covers**: `activeCount`, `activeIds`, `activeObjectiveIds`, `addJournalEntry`, `addObjective`, `addQuest`, `addStage`, `addTag`, `advance`, `advanceObjective`, `allObjectivesComplete`, `clearObjectives`, `complete`, `completeQuest`, `completedCount` (+5 more)

### `rhythm`
- **Not in API doc**: `at`, `beatTimeRemaining`, `cancel`, `cancelAll`, `dump`, `every`, `fromAudio`, `getBar`, `getBeat`, `getBpm`, `getJudgementWindows`, `getPhase`, `isOnBeat`, `isRunning`, `judge` (+5 more)
- **No @covers**: `at`, `beatTimeRemaining`, `cancel`, `cancelAll`, `dump`, `every`, `fromAudio`, `getBar`, `getBeat`, `getBpm`, `getJudgementWindows`, `getPhase`, `isOnBeat`, `isRunning`, `judge` (+5 more)

### `roguelike`
- **Not in API doc**: `add`, `addSource`, `attachTilemap`, `bake`, `bresenham`, `clearSources`, `compute`, `distanceAt`, `eachVisible`, `export`, `flee`, `gradientAt`, `isExplored`, `isVisible`, `lineOfSight` (+5 more)
- **No @covers**: `add`, `addSource`, `attachTilemap`, `bake`, `bresenham`, `clearSources`, `compute`, `distanceAt`, `eachVisible`, `export`, `flee`, `gradientAt`, `isExplored`, `isVisible`, `lineOfSight` (+5 more)

### `rpc`
- **Not in API doc**: `_dispatch`, `_expireTimeouts`, `broadcast`, `call`, `getHandlerCount`, `getNextId`, `getPendingCount`, `new`, `notify`, `onError`, `poll`, `register`, `resetIdCounter`, `setLogging`, `setTimeout` (+1 more)
- **No @covers**: `_dispatch`, `_expireTimeouts`, `broadcast`, `call`, `getHandlerCount`, `getNextId`, `getPendingCount`, `new`, `notify`, `onError`, `poll`, `register`, `resetIdCounter`, `setLogging`, `setTimeout` (+1 more)

### `scheduler`
- **Not in API doc**: `add`, `clear`, `clearErrors`, `getCount`, `getErrors`, `getStatus`, `newScheduler`, `pause`, `remove`, `resume`, `update`
- **No @covers**: `add`, `clear`, `clearErrors`, `getCount`, `getErrors`, `getStatus`, `newScheduler`, `pause`, `remove`, `resume`, `update`

### `stats`
- **Not in API doc**: `acquirePerk`, `addBuff`, `addXP`, `adjustMorale`, `applyArchetypes`, `applyDamage`, `applyTraitBuffs`, `beginTurn`, `checkMorale`, `clearBuffs`, `clearFlag`, `define`, `defineClass`, `definePerk`, `defineRace` (+5 more)
- **No @covers**: `acquirePerk`, `addBuff`, `addXP`, `adjustMorale`, `applyDamage`, `applyTraitBuffs`, `beginTurn`, `checkMorale`, `clearBuffs`, `clearFlag`, `define`, `definePerk`, `defineSkill`, `get`, `getActionPoints` (+5 more)
