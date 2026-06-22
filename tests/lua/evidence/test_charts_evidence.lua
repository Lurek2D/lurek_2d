-- Canonical evidence file for lurek.charts visual artifacts.

local OUT = evidence_output_dir("charts")

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

local function config(title)
    return {
        width = 360,
        height = 220,
        title = title,
        xLabel = "step",
        yLabel = "value",
        showLegend = true,
    }
end

-- @describe Evidence: lurek.charts visual outputs
describe("Evidence: lurek.charts visual outputs", function()
    before_each(function()
        ensure_evidence_dir("charts")
    end)

    -- Does: Renders line, bar, area, scatter, pie, histogram, and heatmap charts through each chart type's public renderImage API.
    -- Shows: The PNG artifacts should make every chart family visually reviewable: axes, labels, legends, marks, slices, bins, and heatmap cells.
    -- Artifact: tests/artifacts/current/charts/charts_line_revenue_trend.png, charts_bar_category_revenue.png, charts_area_layered_usage.png, charts_scatter_player_scores.png, charts_pie_market_share.png, charts_histogram_latency_distribution.png, charts_heatmap_region_load.png
    -- Why: Charts are a visual module, so evidence must prove that real chart APIs produce useful raster output rather than only returning numeric status.
    it("PNG: chart family renderImage gallery", function()
        local line = lurek.charts.newLine(config("Revenue trend"))
        line:addSeries("north", { { 1, 12 }, { 2, 18 }, { 3, 15 }, { 4, 24 }, { 5, 27 } })
        line:addSeries("south", { { 1, 9 }, { 2, 12 }, { 3, 18 }, { 4, 20 }, { 5, 22 } })
        save_png(line:renderImage(), OUT .. "charts_line_revenue_trend.png")

        local bar = lurek.charts.newBar(config("Category revenue"))
        bar:addSeries("revenue", {})
        bar:addSeries("cost", {})
        bar:addCategory("tools", { 42, 21 })
        bar:addCategory("maps", { 36, 18 })
        bar:addCategory("skins", { 58, 29 })
        save_png(bar:renderImage(), OUT .. "charts_bar_category_revenue.png")

        local area = lurek.charts.newArea(config("Layered usage"))
        area:addSeries("desktop", { { 1, 34 }, { 2, 36 }, { 3, 32 }, { 4, 30 }, { 5, 28 } })
        area:addSeries("mobile", { { 1, 18 }, { 2, 24 }, { 3, 31 }, { 4, 43 }, { 5, 51 } })
        save_png(area:renderImage(), OUT .. "charts_area_layered_usage.png")

        local scatter = lurek.charts.newScatter(config("Player scores"))
        scatter:setDotRadius(4)
        scatter:addSeries("players", { { 2, 8 }, { 4, 14 }, { 5, 13 }, { 7, 22 }, { 9, 25 }, { 10, 21 } })
        scatter:addSeries("bots", { { 1, 6 }, { 3, 9 }, { 6, 11 }, { 8, 17 }, { 11, 18 } })
        save_png(scatter:renderImage(), OUT .. "charts_scatter_player_scores.png")

        local pie = lurek.charts.newPie({ width = 360, height = 220, title = "Market share", showLegend = true })
        pie:addSegment("north", 42)
        pie:addSegment("south", 31)
        pie:addSegment("east", 18)
        pie:addSegment("west", 9)
        save_png(pie:renderImage(), OUT .. "charts_pie_market_share.png")

        local histogram = lurek.charts.newHistogram(config("Latency distribution"))
        histogram:setBinCount(8)
        histogram:addSeries("p50", { 12, 14, 18, 18, 21, 22, 25, 27, 30, 31, 33, 36 })
        histogram:addSeries("p95", { 28, 31, 35, 38, 42, 45, 49, 53, 58, 61, 65, 70 })
        save_png(histogram:renderImage(), OUT .. "charts_histogram_latency_distribution.png")

        local heatmap = lurek.charts.newHeatmap({ width = 360, height = 220, title = "Region load", showLegend = true })
        heatmap:setMatrix({
            { 12, 18, 24, 31 },
            { 8, 14, 28, 36 },
            { 5, 11, 20, 29 },
        }, { "north", "south", "east" }, { "q1", "q2", "q3", "q4" })
        heatmap:setShowValues(true)
        save_png(heatmap:renderImage(), OUT .. "charts_heatmap_region_load.png")
    end)

    -- Does: Builds line, heatmap, histogram, and pie charts from dataframe rows, then records nearest-point metadata from the rendered line chart.
    -- Shows: The PNG artifacts should prove dataframe-backed chart ingestion; the JSON artifact should identify the series, data point, and screen coordinates picked by nearest().
    -- Artifact: tests/artifacts/current/charts/charts_dataframe_line.png, charts_dataframe_heatmap.png, charts_dataframe_histogram.png, charts_dataframe_pie.png, charts_nearest_trace.json
    -- Why: This connects charts to real table-shaped data and proves that visual output and interactive point metadata come from the same chart API state.
    it("PNG+JSON: dataframe charts and nearest metadata", function()
        local monthly = lurek.dataframe.fromRows({ "month", "north", "south", "latency", "category", "share" }, {
            { 1, 12, 9, 18, "north", 42 },
            { 2, 18, 12, 21, "south", 31 },
            { 3, 15, 18, 24, "east", 18 },
            { 4, 24, 20, 31, "west", 9 },
            { 5, 27, 22, 29, "skip", "bad" },
        })

        local line = lurek.charts.newLine(config("Dataframe revenue"))
        expect_equal(5, line:addSeriesFromDataFrame("north", monthly, "month", "north"))
        expect_equal(5, line:addSeriesFromDataFrame("south", monthly, "month", "south"))
        save_png(line:renderImage(), OUT .. "charts_dataframe_line.png")

        local heat_rows = lurek.dataframe.fromRows({ "region", "quarter", "load" }, {
            { "north", "q1", 12 },
            { "north", "q2", 18 },
            { "south", "q1", 8 },
            { "south", "q2", 14 },
            { "east", "q1", 5 },
            { "east", "q2", 11 },
        })
        local heatmap = lurek.charts.newHeatmap({ width = 360, height = 220, title = "Dataframe load", showLegend = true })
        expect_equal(6, heatmap:setMatrixFromDataFrame(heat_rows, "region", "quarter", "load"))
        heatmap:setShowValues(true)
        save_png(heatmap:renderImage(), OUT .. "charts_dataframe_heatmap.png")

        local histogram = lurek.charts.newHistogram(config("Dataframe latency"))
        expect_equal(5, histogram:addSeriesFromDataFrame("latency", monthly, "latency"))
        save_png(histogram:renderImage(), OUT .. "charts_dataframe_histogram.png")

        local pie = lurek.charts.newPie({ width = 360, height = 220, title = "Dataframe share", showLegend = true })
        expect_equal(4, pie:addSegmentsFromDataFrame(monthly, "category", "share"))
        save_png(pie:renderImage(), OUT .. "charts_dataframe_pie.png")

        local nearest = line:nearest(220, 110)
        expect_type("table", nearest)
        local json = string.format(
            '{"series":"%s","index":%d,"x":%.3f,"y":%.3f,"screenX":%.3f,"screenY":%.3f,"distance":%.3f}',
            nearest.series,
            nearest.index,
            nearest.x,
            nearest.y,
            nearest.screenX,
            nearest.screenY,
            nearest.distance
        )
        write_text(OUT .. "charts_nearest_trace.json", json)
    end)
end)

test_summary()
