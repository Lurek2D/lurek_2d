-- Canonical evidence file for lurek.dataframe data outputs.


local OUT = evidence_output_dir("dataframe")

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function draw_outline(img, x, y, w, h, r, g, b, a)
    img:drawLine(x, y, x + w - 1, y, r, g, b, a or 255)
    img:drawLine(x + w - 1, y, x + w - 1, y + h - 1, r, g, b, a or 255)
    img:drawLine(x + w - 1, y + h - 1, x, y + h - 1, r, g, b, a or 255)
    img:drawLine(x, y + h - 1, x, y, r, g, b, a or 255)
end

local function fmt(value)
    return string.format("%.6f", tonumber(value) or 0)
end

local function frame_rows(df, cols, limit)
    local lines = {}
    local n = math.min(df:nrows(), limit or df:nrows())
    for row = 1, n do
        local parts = {}
        for i, col in ipairs(cols) do
            parts[i] = tostring(col) .. "=" .. tostring(df:getValue(row, col))
        end
        lines[#lines + 1] = "row" .. tostring(row) .. ":" .. table.concat(parts, ",")
    end
    return table.concat(lines, "\n")
end

local function draw_corr_matrix(img, matrix, cols, x0, y0, cell)
    for row = 1, #cols do
        for col = 1, #cols do
            local v = tonumber(matrix:getValue(row, cols[col])) or 0
            local t = math.max(0, math.min(1, (v + 1) / 2))
            local r = math.floor(42 + 178 * t)
            local g = math.floor(76 + 120 * (1 - math.abs(v)))
            local b = math.floor(210 - 130 * t)
            img:drawRect(x0 + (col - 1) * cell, y0 + (row - 1) * cell, cell - 2, cell - 2, r, g, b, 255)
            draw_outline(img, x0 + (col - 1) * cell, y0 + (row - 1) * cell, cell - 2, cell - 2, 236, 240, 246, 255)
        end
    end
end

-- @describe Evidence: lurek.dataframe data outputs
describe("Evidence: lurek.dataframe data outputs", function()
    before_each(function()
        ensure_evidence_dir("dataframe")
    end)
    -- Does: Runs "writes dataframe_csv_statistics.txt" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.dataframe.fromCSV, LDataFrame:sum, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/dataframe/dataframe_csv_statistics.txt
    -- Why: This is meaningful only if the visible/text output comes from lurek.dataframe.fromCSV, LDataFrame:sum, and related owner calls; export helpers are just the container.

    it("writes dataframe_csv_statistics.txt", function()
        local df = lurek.dataframe.fromCSV("values\n10\n20\n30\n40\n50")
        local text = table.concat({
            "row_count=5",
            "sum=" .. string.format("%.6f", df:sum("values")),
            "mean=" .. string.format("%.6f", df:mean("values")),
        }, "\n") .. "\n"
        write_text(OUT .. "dataframe_csv_statistics.txt", text)
    end)
    -- Does: Runs "writes dataframe_transform_snapshot.txt" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.dataframe.fromRows, LDataFrame:addColumn, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/dataframe/dataframe_transform_snapshot.txt
    -- Why: This is meaningful only if the visible/text output comes from lurek.dataframe.fromRows, LDataFrame:addColumn, and related owner calls; export helpers are just the container.

    it("writes dataframe_transform_snapshot.txt", function()
        local df = lurek.dataframe.fromRows(
            { "name", "age", "score" },
            {
                { "Alice", 30, 90 },
                { "Bob", 25, 85 },
                { "Cara", 35, 92 },
            }
        )
        df:addColumn("tier", "mid")
        df:setValue(1, "tier", "gold")
        df:setValue(3, "tier", "gold")
        local filtered = df:filter("age", ">", 28):sort("score", "desc")
        local row = filtered:getRow(1)
        local text = table.concat({
            "filtered_rows=" .. tostring(filtered:nrows()),
            "leader_name=" .. tostring(row.name),
            "leader_score=" .. tostring(row.score),
            "leader_tier=" .. tostring(row.tier),
        }, "\n") .. "\n"
        write_text(OUT .. "dataframe_transform_snapshot.txt", text)
    end)
    -- Does: Runs "writes dataframe_descriptive_statistics.txt" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LDataFrame:describe, LDataFrame:min, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/dataframe/dataframe_descriptive_statistics.txt
    -- Why: This is meaningful only if the visible/text output comes from LDataFrame:describe, LDataFrame:min, and related owner calls; export helpers are just the container.

    it("writes dataframe_descriptive_statistics.txt", function()
        local df = lurek.dataframe.fromRows(
            { "value" },
            {
                { 10 },
                { 20 },
                { 30 },
                { 40 },
            }
        )
        local stats = df:describe()
        local text = table.concat({
            "describe_rows=" .. tostring(stats:nrows()),
            "describe_cols=" .. tostring(stats:ncols()),
            "min=" .. string.format("%.6f", df:min("value")),
            "max=" .. string.format("%.6f", df:max("value")),
            "median=" .. string.format("%.6f", df:median("value")),
            "stddev=" .. string.format("%.6f", df:stddev("value")),
            "variance=" .. string.format("%.6f", df:variance("value")),
        }, "\n") .. "\n"
        write_text(OUT .. "dataframe_descriptive_statistics.txt", text)
    end)
    -- Does: Runs "writes dataframe_serialization_snapshot.txt" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LDataFrame:toCSV, LDataFrame:toJSON, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/dataframe/dataframe_serialization_snapshot.txt
    -- Why: This is meaningful only if the visible/text output comes from LDataFrame:toCSV, LDataFrame:toJSON, and related owner calls; export helpers are just the container.

    it("writes dataframe_serialization_snapshot.txt", function()
        local df = lurek.dataframe.fromCSV("name,score\nAlice,90\nBob,85\n")
        local csv = df:toCSV()
        local json = df:toJSON()
        local binary = df:toBinary()
        local restored = lurek.dataframe.fromBinary(binary)
        local text = table.concat({
            "csv_len=" .. tostring(#csv),
            "json_len=" .. tostring(#json),
            "binary_len=" .. tostring(#binary),
            "restored_rows=" .. tostring(restored:nrows()),
            "restored_name_1=" .. tostring(restored:getValue(1, "name")),
        }, "\n") .. "\n"
        write_text(OUT .. "dataframe_serialization_snapshot.txt", text)
    end)
    -- Does: Runs "writes dataframe_value_bars.png" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by LDataFrame:getColumn without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/dataframe/dataframe_value_bars.png
    -- Why: This is meaningful only if the visible/text output comes from LDataFrame:getColumn; export helpers are just the container.

    it("writes dataframe_value_bars.png", function()
        local df = lurek.dataframe.fromCSV("label,value\nA,10\nB,35\nC,22\nD,48\n")
        local values = df:getColumn("value")
        local img = lurek.image.newImageData(320, 180)
        img:fill(14, 16, 20, 255)
        img:drawRect(24, 20, 272, 132, 24, 28, 36, 255)
        draw_outline(img, 24, 20, 272, 132, 232, 236, 244, 255)
        for i, value in ipairs(values) do
            local x = 44 + (i - 1) * 60
            local h = math.floor((tonumber(value) or 0) * 2.2)
            local y = 136 - h
            img:drawRect(x, y, 32, h, 90 + i * 30, 140 + i * 10, 220, 255)
            draw_outline(img, x, y, 32, h, 240, 244, 248, 255)
        end
        save_png(img, OUT .. "dataframe_value_bars.png")
    end)
    -- Does: Runs "writes dataframe_structure_query_trace.txt" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.dataframe.newDataFrame, lurek.dataframe.fromJSON, and related owner calls without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/dataframe/dataframe_structure_query_trace.txt
    -- Why: This is meaningful only if the visible/text output comes from lurek.dataframe.newDataFrame, lurek.dataframe.fromJSON, and related owner calls; export helpers are just the container.

    it("writes dataframe_structure_query_trace.txt", function()
        local empty = lurek.dataframe.newDataFrame({ "name", "score" })
        local df = lurek.dataframe.fromJSON('[{"name":"A","score":10},{"name":"B","score":15},{"name":"C","score":15},{"name":"D","score":30}]')
        local cols = df:columns()
        local schema = df:schema()
        local schema_parts = {}
        for i, column in ipairs(schema) do
            schema_parts[i] = table.concat({
                tostring(column.name),
                tostring(column.dtype),
                tostring(column.nullable),
                tostring(column.count),
            }, ":")
        end
        local first_two = df:head(2)
        local last_one = df:tail(1)
        local middle = df:slice(2, 3)
        local picked = df:select("name")
        local table_rows = df:toTable()
        local iter_names = {}
        for _, row in df:rows() do
            iter_names[#iter_names + 1] = row.name
        end
        local lines = {
            "empty_rows=" .. tostring(empty:nrows()),
            "columns=" .. table.concat(cols, ","),
            "schema=" .. table.concat(schema_parts, ","),
            "count_score_15=" .. tostring(df:count("score", 15)),
            "head_first=" .. tostring(first_two:getValue(1, "name")),
            "tail_last=" .. tostring(last_one:getValue(1, "name")),
            "slice_rows=" .. tostring(middle:nrows()),
            "select_cols=" .. tostring(picked:ncols()),
            "rows_len=" .. tostring(#iter_names),
            "table_len=" .. tostring(#table_rows),
            "to_string_len=" .. tostring(#df:toString()),
        }
        write_text(OUT .. "dataframe_structure_query_trace.txt", table.concat(lines, "\n") .. "\n")
    end)
    -- Does: Builds a KPI table, derives margin columns, then summarizes by region and channel with grouped and parallel aggregations.
    -- Shows: The artifact demonstrates dataframe as an analysis pipeline with feature columns, grouped metrics, and categorical distributions.
    -- Artifact: tests/artifacts/current/dataframe/dataframe_grouped_kpi_pipeline.txt
    -- Why: It proves the module can turn raw tabular rows into higher-level business/science summaries without leaving the dataframe API.

    it("writes dataframe_grouped_kpi_pipeline.txt", function()
        local df = lurek.dataframe.fromRows(
            { "region", "channel", "revenue", "cost" },
            {
                { "north", "ads", 120, 40 },
                { "north", "organic", 90, 30 },
                { "south", "ads", 80, 55 },
                { "south", "organic", 140, 60 },
                { "west", "ads", 110, 75 },
                { "west", "organic", 160, 80 },
            }
        )
        local enriched = df:withEval("margin", "revenue - cost")
        enriched:normalizeCol("revenue", 0, 1, "revenue_norm")
        enriched:zscoreCol("margin", "margin_z")
        local margin_by_region = enriched:groupAgg("region", "margin", "sum")
        local revenue_by_channel = enriched:parGroupAgg("channel", "revenue", "mean")
        local grouped = enriched:groupByObj("region"):aggregate("margin", function(values)
            local total = 0
            for i = 1, #values do
                total = total + values[i]
            end
            return total / #values
        end)
        local lines = {
            "enriched_cols=" .. table.concat(enriched:columns(), ","),
            "margin_sum=" .. fmt(enriched:sum("margin")),
            "margin_mean=" .. fmt(enriched:mean("margin")),
            "high_margin_rows=" .. tostring(enriched:filter("margin", ">", 70):nrows()),
            "[margin_by_region]",
            margin_by_region:toString(),
            "[revenue_by_channel]",
            revenue_by_channel:toString(),
            "[grouped_custom_avg_margin]",
            grouped:toString(),
            "[channel_value_counts]",
            enriched:valueCounts("channel", { percent = true }):toString(),
        }
        write_text(OUT .. "dataframe_grouped_kpi_pipeline.txt", table.concat(lines, "\n") .. "\n")
    end)
    -- Does: Runs rolling mean/sum/min/max, percent change, cumulative sum, rank, and outlier extraction over a time-series table.
    -- Shows: The artifact exposes ordered window analytics that are useful for telemetry and experiment tracking.
    -- Artifact: tests/artifacts/current/dataframe/dataframe_window_risk_analysis.txt
    -- Why: It makes row-order-sensitive dataframe behavior visible as a derived time-series table.

    it("writes dataframe_window_risk_analysis.txt", function()
        local df = lurek.dataframe.fromRows(
            { "day", "loss", "latency" },
            {
                { "2026-06-01", 12, 42 },
                { "2026-06-02", 14, 45 },
                { "2026-06-03", 17, 47 },
                { "2026-06-04", 30, 90 },
                { "2026-06-05", 19, 48 },
                { "2026-06-06", 22, 52 },
            }
        )
        df:withRollingMean("loss", 3, "loss_ma3")
        df:withRollingSum("loss", 3, "loss_sum3")
        df:withRollingMin("latency", 3, "latency_floor3")
        df:withRollingMax("latency", 3, "latency_peak3")
        df:withPctChange("loss", "loss_pct")
        df:withCumsum("loss", "loss_total")
        df:withRank("latency", false, "latency_rank")
        local spikes = df:outliers("latency", 1.0)
        local lines = {
            "rows=" .. tostring(df:nrows()),
            "cols=" .. table.concat(df:columns(), ","),
            "last_loss_ma3=" .. fmt(df:getValue(6, "loss_ma3")),
            "last_loss_total=" .. fmt(df:getValue(6, "loss_total")),
            "worst_latency_rank_row4=" .. fmt(df:getValue(4, "latency_rank")),
            "spike_rows=" .. tostring(spikes:nrows()),
            "[window_rows]",
            frame_rows(df, { "day", "loss", "loss_ma3", "loss_pct", "latency_peak3", "latency_rank" }, 6),
        }
        write_text(OUT .. "dataframe_window_risk_analysis.txt", table.concat(lines, "\n") .. "\n")
    end)
    -- Does: Joins fact rows with player metadata, pivots long metrics into a wide table, and runs database SQL against the fact table.
    -- Shows: The artifact demonstrates relational-style reshape and query work inside the dataframe module.
    -- Artifact: tests/artifacts/current/dataframe/dataframe_join_pivot_query_trace.txt
    -- Why: It proves join, pivot, and SQL query APIs cooperate in a realistic analysis loop.

    it("writes dataframe_join_pivot_query_trace.txt", function()
        local facts = lurek.dataframe.fromRows(
            { "player", "stat", "value" },
            {
                { "ada", "damage", 34 },
                { "ada", "healing", 12 },
                { "bo", "damage", 22 },
                { "bo", "healing", 18 },
                { "cy", "damage", 44 },
                { "cy", "healing", 4 },
            }
        )
        local meta = lurek.dataframe.fromRows(
            { "player", "class", "cohort" },
            {
                { "ada", "mage", "A" },
                { "bo", "tank", "B" },
                { "cy", "rogue", "A" },
            }
        )
        local joined = facts:join(meta, "player", "player")
        local wide = facts:pivotTable("player", "stat", "value")
        local db = lurek.dataframe.newDatabase()
        db:addTable("facts", facts)
        db:addTable("meta", meta)
        local queried = db:query("SELECT player, value FROM facts WHERE value > 20")
        local lines = {
            "joined_rows=" .. tostring(joined:nrows()),
            "joined_cols=" .. table.concat(joined:columns(), ","),
            "first_joined_class=" .. tostring(joined:getValue(1, "class")),
            "[pivot]",
            wide:toString(),
            "[sql_value_gt_20]",
            queried:toString(),
        }
        write_text(OUT .. "dataframe_join_pivot_query_trace.txt", table.concat(lines, "\n") .. "\n")
    end)
    -- Does: Plans a deferred dataframe query with filter, sort, select, limit, and collect over an expression-derived feature.
    -- Shows: The artifact makes lazy execution visible as a staged data-prep path that materializes only at the end.
    -- Artifact: tests/artifacts/current/dataframe/dataframe_lazy_feature_pipeline.txt
    -- Why: It proves lazy pipelines can organize larger analysis workflows while keeping the eager source untouched.

    it("writes dataframe_lazy_feature_pipeline.txt", function()
        local source = lurek.dataframe.fromRows(
            { "name", "team", "score", "age" },
            {
                { "Alice", "red", 91, 29 },
                { "Ben", "blue", 77, 31 },
                { "Cara", "red", 88, 27 },
                { "Dio", "blue", 95, 35 },
                { "Eli", "gold", 69, 25 },
            }
        )
        local enriched = source:withEval("eff", "score * 0.8 + age * 0.2")
        local lazy = enriched:lazy():filter("eff", ">", 75):sort("eff", false):select({ "name", "team", "eff" }):limit(3)
        local collected = lazy:collect()
        local lines = {
            "source_rows=" .. tostring(source:nrows()),
            "enriched_rows=" .. tostring(enriched:nrows()),
            "collected_rows=" .. tostring(collected:nrows()),
            "source_cols_after_lazy=" .. table.concat(source:columns(), ","),
            "[collected]",
            frame_rows(collected, { "name", "team", "eff" }, 3),
        }
        write_text(OUT .. "dataframe_lazy_feature_pipeline.txt", table.concat(lines, "\n") .. "\n")
    end)
    -- Does: Converts rows to a vectorized frame, runs scalar ops, derived-column ops, parallel reduction, masking, and conversion back to dataframe rows.
    -- Shows: The artifact exposes the heavy numeric path for columnar dataframe workloads.
    -- Artifact: tests/artifacts/current/dataframe/dataframe_vecframe_compute_trace.txt
    -- Why: It demonstrates the module's vectorized execution layer rather than only table-shaped convenience methods.

    it("writes dataframe_vecframe_compute_trace.txt", function()
        local df = lurek.dataframe.fromCSV("hp,mp,dmg\n100,50,12\n80,70,18\n140,20,25\n")
        local vf = lurek.dataframe.toVec(df)
        vf:colMul("hp", 1.1)
        vf:colClamp("mp", 30, 65)
        vf:colOp("power", "hp", "add", "dmg")
        vf:parScalarOp({ "hp", "dmg" }, "mul", 0.5)
        local reductions = vf:parReduce({ "hp", "mp", "dmg", "power" }, "sum")
        local mask = vf:filterMask("power", ">", 100)
        local filtered = vf:applyMask(mask):toDataFrame()
        local out = vf:toDataFrame()
        local lines = {
            "vec_rows=" .. tostring(vf:nrows()),
            "vec_cols=" .. table.concat(vf:columns(), ","),
            "hp_type=" .. tostring(vf:colType("hp")),
            "sum_hp=" .. fmt(reductions.hp),
            "sum_mp=" .. fmt(reductions.mp),
            "sum_dmg=" .. fmt(reductions.dmg),
            "sum_power=" .. fmt(reductions.power),
            "mask=" .. tostring(mask[1]) .. "," .. tostring(mask[2]) .. "," .. tostring(mask[3]),
            "[filtered_power_gt_100]",
            filtered:toString(),
            "[post_vector_ops]",
            out:toString(),
        }
        write_text(OUT .. "dataframe_vecframe_compute_trace.txt", table.concat(lines, "\n") .. "\n")
    end)
    -- Does: Computes a three-column correlation matrix and renders it as a compact PNG heatmap.
    -- Shows: The artifact visualizes positive, negative, and weak relationships between numeric dataframe columns.
    -- Artifact: tests/artifacts/current/dataframe/dataframe_correlation_matrix_heatmap.png
    -- Why: It makes advanced dataframe analytics reviewable as an image instead of a table of opaque numbers.

    it("writes dataframe_correlation_matrix_heatmap.png", function()
        local df = lurek.dataframe.fromRows(
            { "speed", "accuracy", "fatigue" },
            {
                { 10, 91, 20 },
                { 14, 88, 27 },
                { 18, 83, 35 },
                { 22, 77, 46 },
                { 26, 70, 58 },
            }
        )
        local matrix = df:correlationMatrix()
        local img = lurek.image.newImageData(220, 180)
        img:fill(14, 16, 20, 255)
        img:drawRect(30, 18, 150, 150, 24, 28, 36, 255)
        draw_outline(img, 30, 18, 150, 150, 232, 236, 244, 255)
        draw_corr_matrix(img, matrix, { "speed", "accuracy", "fatigue" }, 48, 36, 40)
        save_png(img, OUT .. "dataframe_correlation_matrix_heatmap.png")
    end)
end)
test_summary()
