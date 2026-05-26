# Household Finance Lab

Business/data-science demo for a five-person household finance dashboard.

Features:
- Loads constants and profile defaults from `app/config.toml` through `lurek.data.parseToml`.
- Generates deterministic 2021-2025 CSV transactions with `lurek.math.newRandomGenerator`; only domain row assembly remains in Lua because there is no public household-finance generator.
- Loads generated CSV from GameFS with `lurek.dataframe.fromCSVFileAsync`, builds an `LDatabase`, and executes readable SQL files from `sql/` with `LDatabase:query` and filtered views with `LDatabase:queryParams`.
- Uses SQL arithmetic aliases for presentation metrics, including ratios and runway months returned directly by `LDatabase:queryParams`.
- All dashboard refresh queries are externalized to `sql/*.sql` files; Lua only supplies filter parameters to `LDatabase:queryParams`.
- Uses `LDataFrame` methods for z-score, outliers, grouped totals, samples, rolling mean, rolling sum, and percent change.
- Saves and restores the tabular cache through `LDatabase:save` and `lurek.dataframe.loadDatabase`; the small manifest is written with `lurek.serial.toJson`.
- Uses `lurek.ui` widgets for tabs, filters, buttons, tables, status, and chart generation. Tables use `LGuiTable:setDataFrame`/`setRows`, and charts use DataFrame helper APIs before rendering to images.
- Adds a `Widgets/API` tab showing live widget values, SQL status, dataframe table count, cache state, chart image status, save slot, and test report. The app-local report also checks mouse interaction paths for tabs, combo boxes, sliders, switches, and buttons.
- Uses `LLabel` widgets for filter labels and the live filter summary, samples `lurek.engine.getFrameProfile`/`lurek.render.getStats` for visible frame and render timing, and debounces filter changes so sliders do not run SQL on every immediate pointer step.

Layout:
- `main.lua` is only the composition root.
- `app/config.toml` and `app/config.lua` contain TOML-backed configuration.
- `app/data_generation.lua` contains Lurek RNG-backed domain row assembly.
- `app/data_pipeline.lua` contains CSV file loading, database cache glue, parameterized SQL refresh queries, and DataFrame outputs for charts/tables.
- `app/ui_controls.lua` and `app/ui_render.lua` use `lurek.ui` widgets, bulk table setters, status bar, DataFrame chart helpers, and chart image output.
- The app pins built-in bitmap UI fonts to native, non-scaled sizes (`font_size = 20`, `title_font_size = 24`, bold default font) and runs with `scale_mode = "none"` so text remains readable and avoids fractional whole-scene scaling blur.
- `sql/*.sql` contains the formatted database queries executed through `LDatabase:query`.
- `test.lua` is the colocated Lua harness entry point and writes `save/household_finance_lab/test_report.json`.

Run:
`cargo run --bin lurek2d -- content/games/apps/household_finance_lab`

Capture an 800x600 smoke screenshot:
`cargo run --bin lurek2d -- content/games/apps/household_finance_lab --window-width=800 --window-height=600 --screenshot=save/household_finance_lab/screen.png --screenshot-frames=60`

The app also writes its runtime smoke screenshot to `save/household_finance_lab/screen.png` through `lurek.render.saveScreenshot`.

Validate and test:
`python tools/validate/validate_game.py content/games/apps/household_finance_lab`

`cargo test --test games_load_test -- --nocapture`

`cargo test --test lua_tests lua_demo_colocated_games -- --nocapture`
