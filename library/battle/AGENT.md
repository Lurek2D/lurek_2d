# `battle` - Agent Reference

| Property | Value |
| --- | --- |
| Tier | Tier 3 - Lureksome (pure Lua) |
| Source | `library/battle/init.lua` |
| Lua tests | `tests/lua/library/test_battle_library.lua` |
| Status | full |
| Optional bindings | `lurek.math.newRandomGenerator` |

## Purpose

Turn-based battle resolution with combatants, actions, status effects, typed
damage, initiative sorting, battle logs, and winner detection.

## Current shape

- `newCombatant(name)` creates a combatant with HP, MP, stats, resistances,
  status effects, actions, and metadata.
- `newAction(name)` creates an action with damage, accuracy, cooldown, HP/MP
  costs, tags, and metadata.
- `newStatusEffect(name, duration)` creates a stackable timed status entry.
- `newBattle(name)` owns combatants, logs, turn order, and `attack()` /
  `resolve()` helpers.

## Engine integration

- The library remains portable without engine bindings.
- Module RNG may delegate to `lurek.math.newRandomGenerator`.
- `battle.setDefaultRng(rng)` sets the default RNG for new battles.
- `battle:setRng(rng)` overrides RNG per battle instance.

## Notes

- Public API is compatibility-sensitive; keep constructor names, method names,
  and return shapes stable.
- `math.random` is still the fallback when no engine RNG is available.
