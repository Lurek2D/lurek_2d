# log manual spec overlay

## TL;DR

- Runs structured logs with level-filtered sinks.

## Summary

- The `log` module is the common script-facing path for runtime diagnostics, so users can emit messages through one consistent logging surface instead of mixing ad hoc print styles.
- It keeps message formatting, structured fields, severity, and sink routing together, which lets debugging output scale from quick traces to retained logs.
- That common path makes filtering and correlation across subsystems easier.
- Read it as the standard language for script diagnostics when several systems need to be debugged through the same output flow.

This module primarily collaborates with `binary`, `runtime`. Its responsibility should stay inside the Foundations group rather than absorb behavior owned by those neighbors.

## Notes

- The shared sink registry can host hidden internal sinks alongside user-visible sinks; `listSinks`, `removeSink`, and `clearSinks` operate only on visible user-managed sinks.
- Memory sink reads now expose per-entry timestamps so downstream tooling can correlate retained log history with other diagnostics surfaces.

## Architecture Links

- [Runtime Tooling Boundaries](../../architecture/runtime-tooling-boundaries.md)
