# Household Finance Lab

Business/data-science demo for a five-person household finance dashboard.

Features:
- Generates deterministic 2021-2025 CSV transactions in `app/data_generation.lua`.
- Loads CSV with `lurek.dataframe.fromCSV`, builds an `LDatabase`, executes query files from `sql/`, and saves per-table binary dataframe cache files under `save/household_finance_lab/cache/`.
- Uses compact app-local hitboxes for tabs, filters, row selection, cache reload, regeneration, state save, and screenshot capture.
- Adds a `Widgets` tab with KPI grid, trend cards, pipeline/API status, cache status, sparkline, payment mix, debt ratio, runway months, and selected details.
- Shows monthly cashflow, category bars, member totals, payment method mix, recurring merchants, anomaly scatter/list, heatmap, transaction table, logs, and test status.
- Detects duplicate charges, dirty categories, missing fields, high transfers, and outliers from SQL-ready helper columns.

Layout:
- `main.lua` is only the composition root.
- `app/*.lua` contains constants, generation, SQL runner, pipeline/cache, analytics, UI state, controls, rendering, charts, and test helpers.
- `sql/*.sql` contains the database queries executed through `LDatabase:query`.
- `test.lua` is the colocated Lua harness entry point and writes `save/household_finance_lab/test_report.json`.

Run:
`cargo run --bin lurek2d -- content/games/apps/household_finance_lab`

Capture a 1280x720 smoke screenshot:
`cargo run --bin lurek2d -- content/games/apps/household_finance_lab --window-width=1280 --window-height=720 --screenshot=content/games/apps/household_finance_lab/screen.png --screenshot-frames=60`

Validate and test:
`python tools/validate/validate_game.py content/games/apps/household_finance_lab`

`cargo test --test games_load_test -- --nocapture`

`cargo test --test lua_tests lua_demo_colocated_games -- --nocapture`
