# `stats` - Agent Reference

| Property | Value |
| --- | --- |
| Tier | Tier 3 - Lureksome (pure Lua) |
| Source | `library/stats/init.lua` |
| Lua tests | `tests/lua/library/test_stats_library.lua` |
| Status | full |
| Optional bindings | `lurek.math.clamp`, `lurek.serialize.toJson/fromJson` |

## Purpose

Character stats, buffs, thresholds, skills, perks, action points, morale,
traits, archetypes, and sheet snapshots.

## Current shape

- `newAttribute`, `newBuff`, `newSkill`, `newPerk`, `newActionPoints`,
  `newMorale`, `newTableThresholds`, `newLinearThresholds`, `newTraitDef`, and
  `newSheet` make up the main API surface.
- `Sheet` owns attribute definitions, buff stacking, resistances, AP, morale,
  XP, and level thresholds.
- `snapshotToJson()` and `snapshotFromJson()` round-trip snapshots through
  `lurek.serialize`.

## Engine integration

- `clamp()` prefers `lurek.math.clamp` when both bounds are present.
- JSON helpers use `lurek.serialize` and preserve open-ended bounds such as
  `math.huge` during round-trip conversion.

## Notes

- Keep existing sheet behavior and snapshot shape stable.
- This library remains domain logic rather than a thin engine wrapper.
