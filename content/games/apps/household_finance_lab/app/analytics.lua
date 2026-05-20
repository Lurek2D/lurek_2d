local Analytics = {}

local function num(value)
    return tonumber(value) or 0
end

local function rows(frame)
    if not frame then return {} end
    return frame:toTable()
end

local function sort_desc(list, key)
    table.sort(list, function(a, b)
        return num(a[key]) > num(b[key])
    end)
end

local function current_member(C, state)
    return C.MEMBERS[state.member_index] or "All"
end

local function current_category(C, state)
    return C.CATEGORIES[state.category_index] or "All"
end

local function filter_where(ctx, table_name, include_anomalies)
    local C = ctx.C
    local state = ctx.state
    local clauses = {
        "year >= " .. tostring(state.start_year),
        "year <= " .. tostring(state.end_year),
    }
    local member = current_member(C, state)
    local category = current_category(C, state)
    if member ~= "All" then clauses[#clauses + 1] = "member_clean = " .. ctx.SQLRunner.quote(member) end
    if category ~= "All" then clauses[#clauses + 1] = "category_clean = " .. ctx.SQLRunner.quote(category) end
    if include_anomalies then
        clauses[#clauses + 1] = "anomaly_issue != NULL"
        clauses[#clauses + 1] = "anomaly_score >= " .. tostring(state.anomaly_threshold)
    elseif table_name == "transactions" and state.use_cleaned then
        clauses[#clauses + 1] = "anomaly_issue = NULL"
    end
    return table.concat(clauses, " AND ")
end

local function query(ctx, sql)
    return ctx.SQLRunner.query(ctx, sql)
end

local function first_row(frame)
    local table_rows = rows(frame)
    return table_rows[1] or {}
end

local function build_metrics(ctx, summary)
    local C = ctx.C
    local income = num(summary[C.AGG.income])
    local expense = num(summary[C.AGG.expense])
    local savings = num(summary[C.AGG.savings])
    local debt = num(summary[C.AGG.debt])
    local essential = num(summary[C.AGG.essential])
    local assets = num(summary[C.AGG.assets])
    local months = math.max(1, (ctx.state.end_year - ctx.state.start_year + 1) * 12)
    local avg_expense = expense / months
    return {
        count = num(summary[C.AGG.count]),
        income = income,
        expense = expense,
        savings = savings,
        debt = debt,
        essential = essential,
        assets = assets,
        net = income - expense - savings,
        savings_rate = income > 0 and savings / income or 0,
        debt_ratio = income > 0 and debt / income or 0,
        essential_ratio = expense > 0 and essential / expense or 0,
        runway_months = avg_expense > 0 and math.max(0, 50000 + assets * 0.08) / avg_expense or 0,
        avg_expense = avg_expense,
    }
end

local function normalize_monthly(ctx, monthly_rows)
    local out = {}
    for _, row in ipairs(monthly_rows) do
        out[#out + 1] = {
            month_index = num(row.month_index),
            year = num(row.year),
            month = num(row.month),
            income = num(row[ctx.C.AGG.income]),
            expense = num(row[ctx.C.AGG.expense]),
            savings = num(row[ctx.C.AGG.savings]),
            debt = num(row[ctx.C.AGG.debt]),
            essential = num(row[ctx.C.AGG.essential]),
            signed = num(row[ctx.C.AGG.signed]),
        }
    end
    table.sort(out, function(a, b) return a.month_index < b.month_index end)
    return out
end

local function trend_cards(monthly)
    local latest = monthly[#monthly] or {}
    local previous = monthly[#monthly - 1] or latest
    return {
        { label = "Income trend", value = latest.income or 0, delta = (latest.income or 0) - (previous.income or 0) },
        { label = "Expense trend", value = latest.expense or 0, delta = (latest.expense or 0) - (previous.expense or 0) },
        { label = "Savings trend", value = latest.savings or 0, delta = (latest.savings or 0) - (previous.savings or 0) },
        { label = "Net month", value = (latest.income or 0) - (latest.expense or 0) - (latest.savings or 0), delta = ((latest.income or 0) - (latest.expense or 0)) - ((previous.income or 0) - (previous.expense or 0)) },
    }
end

local function normalize_group(rows_in, label_key, value_key)
    local out = {}
    for _, row in ipairs(rows_in) do
        out[#out + 1] = {
            label = tostring(row[label_key] or ""),
            value = num(row[value_key]),
            count = num(row["COUNT(*)"]),
            row = row,
        }
    end
    sort_desc(out, "value")
    return out
end

local function build_heatmap(ctx, table_name, base_where, top_categories)
    local cells = {}
    local max_value = 1
    for cat_index = 1, math.min(8, #top_categories) do
        local category = top_categories[cat_index].label
        local sql = "SELECT month_index, SUM(expense_amount) FROM " .. table_name .. " WHERE " .. base_where .. " AND category_clean = " .. ctx.SQLRunner.quote(category) .. " GROUP BY month_index ORDER BY month_index ASC"
        local month_rows = rows(query(ctx, sql))
        for _, row in ipairs(month_rows) do
            local month = num(row.month_index)
            local value = num(row[ctx.C.AGG.expense])
            cells[#cells + 1] = { x = month, y = cat_index, value = value, category = category }
            if value > max_value then max_value = value end
        end
    end
    return { cells = cells, max = max_value, categories = top_categories }
end

function Analytics.refresh(ctx)
    local table_name = ctx.state.use_cleaned and "filtered_transactions" or "transactions"
    local where = filter_where(ctx, table_name, false)
    local anomaly_where = filter_where(ctx, "transactions", true)

    local summary = first_row(query(ctx, "SELECT COUNT(*), SUM(income_amount), SUM(expense_amount), SUM(savings_amount), SUM(debt_amount), SUM(essential_amount), SUM(asset_amount) FROM " .. table_name .. " WHERE " .. where))
    local monthly = normalize_monthly(ctx, rows(query(ctx, "SELECT month_index, year, month, SUM(income_amount), SUM(expense_amount), SUM(savings_amount), SUM(debt_amount), SUM(essential_amount), SUM(signed_amount) FROM " .. table_name .. " WHERE " .. where .. " GROUP BY month_index ORDER BY month_index ASC")))
    local categories = normalize_group(rows(query(ctx, "SELECT category_clean, SUM(expense_amount), COUNT(*) FROM " .. table_name .. " WHERE " .. where .. " AND expense_amount > 0 GROUP BY category_clean")), "category_clean", ctx.C.AGG.expense)
    local members = normalize_group(rows(query(ctx, "SELECT member_clean, SUM(expense_amount), COUNT(*) FROM " .. table_name .. " WHERE " .. where .. " AND expense_amount > 0 GROUP BY member_clean")), "member_clean", ctx.C.AGG.expense)
    local payment = normalize_group(rows(query(ctx, "SELECT payment_method, SUM(expense_amount), COUNT(*) FROM " .. table_name .. " WHERE " .. where .. " AND expense_amount > 0 GROUP BY payment_method")), "payment_method", ctx.C.AGG.expense)
    local recurring = normalize_group(rows(query(ctx, "SELECT merchant, SUM(expense_amount), AVG(expense_amount), COUNT(*) FROM " .. table_name .. " WHERE " .. where .. " AND recurring_value = 1 GROUP BY merchant")), "merchant", ctx.C.AGG.expense)
    local anomalies = rows(query(ctx, "SELECT txn_id, date, year, month, member_clean, category_clean, merchant, amount_abs, anomaly_issue, anomaly_severity, anomaly_score FROM transactions WHERE " .. anomaly_where .. " ORDER BY anomaly_score DESC LIMIT 40"))
    local recent = rows(query(ctx, "SELECT date, member_clean, category_clean, merchant, payment_method, signed_amount, anomaly_issue FROM " .. table_name .. " WHERE " .. where .. " ORDER BY date DESC LIMIT 44"))

    ctx.view = {
        table_name = table_name,
        where = where,
        metrics = build_metrics(ctx, summary),
        monthly = monthly,
        categories = categories,
        members = members,
        payment = payment,
        recurring = recurring,
        anomalies = anomalies,
        recent = recent,
        trend_cards = trend_cards(monthly),
        heatmap = build_heatmap(ctx, table_name, where, categories),
        refreshed_at = ctx.clock or 0,
    }
    ctx.state.needs_refresh = false
    return ctx.view
end

return Analytics