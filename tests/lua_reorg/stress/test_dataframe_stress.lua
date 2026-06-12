-- Lurek2D Stress Test: DataFrame Bulk Operations
-- Tests large DataFrames with many rows and columns

local function new_bulk_row_dataframe()
    local df = lurek.dataframe.newDataFrame()
    df:addColumn("id", 0)
    df:addColumn("name", "")
    df:addColumn("score", 0.0)
    return df
end

local function fill_bulk_rows(df, count)
    for i = 1, count do
        df:addRow({ id = i, name = "player_" .. i, score = i * 1.5 })
    end
end

local function new_value_dataframe()
    local df = lurek.dataframe.newDataFrame()
    df:addColumn("value", 0)
    return df
end

local function fill_value_rows(df, count)
    for i = 1, count do
        df:addRow({ value = i })
    end
end

local function new_many_columns_dataframe(column_count)
    local df = lurek.dataframe.newDataFrame()
    for c = 1, column_count do
        df:addColumn("col_" .. c, 0)
    end
    return df
end

local function populate_many_column_rows(df, row_count, column_count)
    for r = 1, row_count do
        local row = {}
        for c = 1, column_count do
            row["col_" .. c] = r * c
        end
        df:addRow(row)
    end
end

local function churn_temporary_columns(df, cycle_count)
    for cycle = 1, cycle_count do
        local name = "temp_" .. cycle
        df:addColumn(name, cycle)
        df:removeColumn(name)
    end
end

local function new_base_only_dataframe(row_count)
    local df = lurek.dataframe.newDataFrame()
    df:addColumn("base", 0)
    for i = 1, row_count do
        df:addRow({ base = i })
    end
    return df
end

-- @describe dataframe stress: bulk row insertion
describe("dataframe stress: bulk row insertion", function()
    -- @stress LDataFrame:addRow
    it("inserts 5000 rows", function()
        local df = new_bulk_row_dataframe()
        fill_bulk_rows(df, 5000)
        expect_equal(5000, df:nrows(), "5000 rows added")
        expect_equal(3, df:ncols(), "3 columns")
    end)

    -- @stress LDataFrame:getValue
    it("reads back all 5000 rows correctly", function()
        local df = new_value_dataframe()
        fill_value_rows(df, 5000)
        local val_1 = df:getValue(1, "value")
        local val_2500 = df:getValue(2500, "value")
        local val_5000 = df:getValue(5000, "value")

        expect_near(1, val_1, 0.01, "first row")
        expect_near(2500, val_2500, 0.01, "middle row")
        expect_near(5000, val_5000, 0.01, "last row")
    end)
end)

-- @describe dataframe stress: many columns
describe("dataframe stress: many columns", function()
    -- @stress LDataFrame:addColumn
    it("creates DataFrame with 50 columns", function()
        local df = new_many_columns_dataframe(50)
        populate_many_column_rows(df, 100, 50)
        expect_equal(100, df:nrows(), "100 rows")
        expect_equal(50, df:ncols(), "50 columns")
        local val = df:getValue(50, "col_25")
        expect_near(50 * 25, val, 0.01, "row 50 col 25")
    end)
end)

-- @describe dataframe stress: column operations
describe("dataframe stress: column operations", function()
    -- @stress LDataFrame:removeColumn
    it("adds and removes columns repeatedly", function()
        local df = new_base_only_dataframe(20)
        churn_temporary_columns(df, 100)
        expect_equal(20, df:nrows(), "rows preserved after column churn")
        expect_equal(1, df:ncols(), "only base column remains")
    end)
end)
test_summary()
