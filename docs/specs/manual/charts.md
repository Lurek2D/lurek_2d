# charts manual spec overlay

## TL;DR

- Rasterizes line, bar, area, scatter, pie, histogram, and heatmap charts into RGBA buffers and drawable runtime textures.

## Summary

- The `charts` module is the engine's in-runtime data-visualization surface for users who want tables, counters, time series, and distributions to become readable graphics.
- It supports line, bar, area, scatter, pie, histogram, and heatmap views so different kinds of telemetry and balancing data can share one visualization system.
- That range matters because frame-time traces, economy curves, loot distributions, progression trends, and density-style data do not all want the same display form.
- Live projects often need to inspect those measurements without exporting them into external plotting tools first, and this module keeps that workflow inside the runtime.
- CPU-side rasterization is central because it makes chart output deterministic and portable across live UI, screenshots, reports, docs, and test artifacts.
- Styling controls keep the module useful for polished runtime dashboards as well as for raw debug panels, while interactive helpers such as nearest-point queries make exact values explorable instead of merely visible.
- Interactivity also matters because a chart often becomes useful only when a caller can inspect an exact point, bucket, or outlier instead of visually guessing from the overall shape.
- Portability is part of the module's practical value too, because the same chart can move between live overlays, screenshots, generated reports, and regression artifacts without changing the underlying data model.
- The module also helps bridge structured analysis and communication: once numbers become a chart, teams can compare trends, outliers, and distributions much faster than by reading rows or logs directly.
- The module is useful for telemetry, tuning, economy balancing, analytics overlays, progress dashboards, and any workflow where numbers should become images instead of logs.
- `dataframe` and other systems may own the source data, but `charts` owns the mapping from structured values to chart-specific visual form.
- Read `charts` as the place where engine-side measurements become inspectable visual explanations.

This module primarily collaborates with `color`, `dataframe`, `image`. Its responsibility should stay inside the `Feature Systems` group rather than absorb behavior owned by those neighbors.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
