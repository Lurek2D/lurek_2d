-- DataFrame pivot table and window function Lua unit tests.
-- Tests are headless-safe (BDD framework).

-- @description Covers suite: DataFrame pivotTable, rollingMean, rollingSum, rank.
describe("DataFrame: pivotTable", function()

    -- @covers lurek.dataframe.DataFrame.pivotTable
    -- @description pivotTable reshapes a long DataFrame to wide format (mean agg, default).
    it("pivotTable reshapes long to wide with default mean aggregation", function()
        local df = lurek.dataframe.new()
        df:addColumn("player")
        df:addColumn("stat")
        df:addColumn("value")
        df:addRow({ player = "A", stat = "hp", value = 100 })
        df:addRow({ player = "A", stat = "mp", value = 50  })
        df:addRow({ player = "B", stat = "hp", value = 80  })
        df:addRow({ player = "B", stat = "mp", value = 60  })

        local wide = df:pivotTable("player", "stat", "value")
        expect_not_nil(wide)
        -- Should have 3 columns: player, hp, mp
        expect_equal(3, wide:ncols())
        -- Should have 2 rows: A and B
        expect_equal(2, wide:nrows())
        local hp = wide:getColumn("hp")
        local mp = wide:getColumn("mp")
        expect_near(100, hp[1], 0.001)
        expect_near(50,  mp[1], 0.001)
        expect_near(80,  hp[2], 0.001)
        expect_near(60,  mp[2], 0.001)
    end)

    -- @covers lurek.dataframe.DataFrame.pivotTable
    -- @description pivotTable with sum aggregation accumulates duplicate entries.
    it("pivotTable with sum aggregation", function()
        local df = lurek.dataframe.new()
        df:addColumn("group")
        df:addColumn("cat")
        df:addColumn("val")
        df:addRow({ group = "X", cat = "a", val = 10 })
        df:addRow({ group = "X", cat = "a", val = 20 })
        df:addRow({ group = "X", cat = "b", val = 5  })

        local wide = df:pivotTable("group", "cat", "val", "sum")
        expect_not_nil(wide)
        local a_col = wide:getColumn("a")
        expect_near(30, a_col[1], 0.001)  -- 10+20
        local b_col = wide:getColumn("b")
        expect_near(5, b_col[1], 0.001)
    end)

    -- @covers lurek.dataframe.DataFrame.pivotTable
    -- @description pivotTable with count aggregation counts rows per cell.
    it("pivotTable with count aggregation", function()
        local df = lurek.dataframe.new()
        df:addColumn("g")
        df:addColumn("c")
        df:addColumn("v")
        df:addRow({ g = "R1", c = "C1", v = 1 })
        df:addRow({ g = "R1", c = "C1", v = 2 })
        df:addRow({ g = "R1", c = "C2", v = 3 })

        local wide = df:pivotTable("g", "c", "v", "count")
        local c1 = wide:getColumn("C1")
        expect_equal(2, c1[1])  -- two rows for (R1, C1)
        local c2 = wide:getColumn("C2")
        expect_equal(1, c2[1])
    end)

end)

describe("DataFrame: rollingMean", function()

    -- @covers lurek.dataframe.DataFrame.rollingMean
    -- @description rollingMean returns new DataFrame with extra column; leaves original unchanged.
    it("rollingMean appends result column and preserves original", function()
        local df = lurek.dataframe.new()
        df:addColumn("v")
        df:addRow({ v = 2 })
        df:addRow({ v = 4 })
        df:addRow({ v = 6 })
        df:addRow({ v = 8 })

        local df2 = df:rollingMean("v", 2, "v_rm")
        -- Original df unchanged
        expect_equal(1, df:ncols())
        -- New df has 2 columns
        expect_equal(2, df2:ncols())
        local rm = df2:getColumn("v_rm")
        -- Row 1: window=2, only 1 predecessor → nil
        expect_nil(rm[1], "first row should be nil with window=2")
        -- Row 2: mean(2,4)=3
        expect_near(3.0, rm[2], 0.001)
        -- Row 3: mean(4,6)=5
        expect_near(5.0, rm[3], 0.001)
        -- Row 4: mean(6,8)=7
        expect_near(7.0, rm[4], 0.001)
    end)

    -- @covers lurek.dataframe.DataFrame.rollingMean
    -- @description rollingMean default result column name contains source column name.
    it("rollingMean uses default result column name", function()
        local df = lurek.dataframe.new()
        df:addColumn("score")
        df:addRow({ score = 10 })
        df:addRow({ score = 20 })

        local df2 = df:rollingMean("score", 2)
        local cols = df2:columns()
        expect_equal(2, #cols)
        expect_equal("score", cols[1])
        expect_equal("score_rolling_mean", cols[2])
    end)

end)

describe("DataFrame: rollingSum", function()

    -- @covers lurek.dataframe.DataFrame.rollingSum
    -- @description rollingSum returns new DataFrame with correct rolling sums.
    it("rollingSum produces correct sums", function()
        local df = lurek.dataframe.new()
        df:addColumn("v")
        df:addRow({ v = 1 })
        df:addRow({ v = 2 })
        df:addRow({ v = 3 })

        local df2 = df:rollingSum("v", 2, "v_rs")
        expect_equal(2, df2:ncols())
        local rs = df2:getColumn("v_rs")
        expect_nil(rs[1])
        expect_near(3.0, rs[2], 0.001)  -- 1+2
        expect_near(5.0, rs[3], 0.001)  -- 2+3
    end)

end)

describe("DataFrame: rank", function()

    -- @covers lurek.dataframe.DataFrame.rank
    -- @description rank descending assigns rank 1 to the highest score.
    it("rank desc assigns rank 1 to highest score", function()
        local df = lurek.dataframe.new()
        df:addColumn("score")
        df:addRow({ score = 30 })
        df:addRow({ score = 10 })
        df:addRow({ score = 20 })

        local df2 = df:rank("score", "desc", "rank")
        expect_equal(2, df2:ncols())
        local ranks = df2:getColumn("rank")
        -- score 30 → rank 1, score 20 → rank 2, score 10 → rank 3
        expect_near(1, ranks[1], 0.001)
        expect_near(3, ranks[2], 0.001)
        expect_near(2, ranks[3], 0.001)
    end)

    -- @covers lurek.dataframe.DataFrame.rank
    -- @description rank ascending assigns rank 1 to the lowest score.
    it("rank asc assigns rank 1 to lowest score", function()
        local df = lurek.dataframe.new()
        df:addColumn("score")
        df:addRow({ score = 30 })
        df:addRow({ score = 10 })
        df:addRow({ score = 20 })

        local df2 = df:rank("score", "asc", "rank")
        local ranks = df2:getColumn("rank")
        -- score 30 → rank 3, score 20 → rank 2, score 10 → rank 1
        expect_near(3, ranks[1], 0.001)
        expect_near(1, ranks[2], 0.001)
        expect_near(2, ranks[3], 0.001)
    end)

    -- @covers lurek.dataframe.DataFrame.rank
    -- @description rank uses default column name when resultCol omitted.
    it("rank uses default result column name", function()
        local df = lurek.dataframe.new()
        df:addColumn("pts")
        df:addRow({ pts = 5 })
        df:addRow({ pts = 3 })

        local df2 = df:rank("pts")
        local cols = df2:columns()
        expect_equal(2, #cols)
        expect_equal("pts_rank", cols[2])
    end)

end)

test_summary()
