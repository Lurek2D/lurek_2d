---
name: analytics
description: "Load this skill when collecting, parsing, or acting on diagnostic data from Lurek2D log files, performance counters, telemetry events, or game session records: structuring game events for analysis, extracting performance metrics from RUST_LOG output, finding crash patterns, using data to drive game balance or design decisions, or building an in-game telemetry pipeline. Use for: log parsing, session event recording, crash frequency analysis, performance histogram analysis, data-driven game balance. Skip it for live runtime debugging (use dev-debugging skill) or setting up log output (use logging skill)."
---
# analytics

## Mission

Own in-game event recording, log parsing, performance counter collection, session event schema, and data-driven decision heuristics.

## When To Load

- Parsing RUST_LOG output or game.log files for crash patterns or regressions
- Designing an in-game telemetry event pipeline
- Analysing performance data for frame spikes or slow sections
- Using play data for game balance or design decisions

## When To Skip

- Live runtime debugging → use dev-debugging skill
- Setting up log output → use logging skill

## Domain Knowledge

**Two tiers of analytics:**

| Tier | Source | Analysis method | Use for |
|------|--------|----------------|---------|
| Engine telemetry | RUST_LOG output, debug overlay | Offline grep/Python | Performance regressions, crash frequency |
| Game telemetry | lurek.filesystem.append() in scripts | Offline parse + visualise | Balance, funnel analysis, UX issues |

**Engine log analysis** — collect with RUST_LOG="lurek2d=debug" and Tee-Object to file. Extract frame times with Select-String for "frame_time" lines. Find errors/warnings by filtering log levels. Use Python for spike detection (parse frame times, flag values above threshold).

**Game telemetry pipeline** — record events as flat TOML-style lines with timestamp, event name, and key-value pairs via lurek.filesystem.append(). Keep events flat and human-readable.

**Mandatory events:** game_start (level, version), player_died (x, y, cause), level_complete (level, duration, attempts), game_quit (reason). Additional tuning events: item_used, enemy_killed, shop_purchase, ability_unlocked.

**Performance events:** record frame_time, draw_calls, gc_count, physics_step periodically for offline histogram analysis.

**Acting on findings:** death clusters suggest invisible hazards; low completion rates suggest difficulty spikes; frame spikes correlate with GC or physics complexity; item usage imbalances reveal meta problems.

**Privacy:** never record personal info; all logs stay local. No network telemetry in core engine.

## Companion File Index

None — all guidance is inline.

## References

- tools/audit/ — quality and coverage analysis scripts
- docs/specs/ — module reference files
