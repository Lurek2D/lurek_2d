# `quest` - Agent Reference

| Property | Value |
| --- | --- |
| Tier | Tier 3 - Lureksome (pure Lua) |
| Source | `library/quest/init.lua` |
| Lua tests | `tests/lua/library/test_quest_library.lua` |
| Status | full |
| Optional bindings | `lurek.patterns.newEventBus`, `lurek.serialize.toJson/fromJson` |

## Purpose

Quest tracking with staged objectives, journal entries, rewards, metadata, and
session-level quest-log helpers.

## Current shape

- `newObjective`, `newQuestStage`, `newQuest`, and `newQuestLog` build the main
  quest graph.
- Runtime quest statuses are `available`, `active`, `completed`, and `failed`.
- Runtime objective statuses are `pending`, `active`, `done`, `skipped`, and
  `failed`.
- `QuestLog` owns lifecycle helpers, reward helpers, status queries, and
  optional event emission.

## Engine integration

- `QuestLog:setEventBus()` accepts injected buses; otherwise the library may
  create one through `lurek.patterns.newEventBus`.
- `quest.toJson()` and `quest.fromJson()` use `lurek.serialize`.

## Notes

- Keep quest logic domain-specific; do not replace it with a generic engine
  state machine.
- Preserve current runtime status strings and constructor signatures.
