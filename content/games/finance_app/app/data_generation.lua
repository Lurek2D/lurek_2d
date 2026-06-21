local DataGeneration = {}

local function round2(value)
    return math.floor(value * 100 + 0.5) / 100
end

local function make_rng(seed)
    local engine_rng = lurek.math.newRandomGenerator(seed or 20260520)
    local rng = { engine = engine_rng }
    function rng:next()
        return self.engine:randomFloat(0, 1)
    end
    function rng:int(min_value, max_value)
        return self.engine:randomInt(min_value, max_value)
    end
    function rng:pick(values)
        return values[self:int(1, #values)]
    end
    function rng:money(base, spread)
        return round2(base + self.engine:randomNormal((spread or 0) / 3, 0))
    end
    function rng:state()
        return self.engine:getState()
    end
    return rng
end

local function profile_list(profile, name, fallback)
    local lists = profile.merchants or {}
    if lists[name] and #lists[name] > 0 then return lists[name] end
    return fallback
end

local function subscriptions_from_profile(profile)
    local subs = profile.subscriptions or {}
    local names = subs.merchants or { "StreamBox" }
    local bases = subs.base_amounts or { 42 }
    local out = {}
    for index, name in ipairs(names) do
        out[#out + 1] = { merchant = tostring(name), base = tonumber(bases[index]) or 30 }
    end
    return out
end

local function date_string(year, month, day)
    return string.format("%04d-%02d-%02d", year, month, day)
end

local function month_index(year, month, first_year)
    return (year - first_year) * 12 + month
end

local function bool_text(value)
    return value and "true" or "false"
end

local function clean_category(C, value)
    return C.CATEGORY_ALIASES[value] or value or ""
end

local function clean_member(value)
    if value == nil or value == "" then return "Unassigned" end
    return value
end

local function clean_location(value)
    if value == nil or value == "" then return "Unknown" end
    return value
end

local function derive_anomaly(C, txn, category_clean, member_clean, location_clean, amount, signed)
    local issue = txn.anomaly_issue or ""
    local severity = txn.anomaly_severity or ""
    local score = txn.anomaly_score or 0

    if issue == "" and (member_clean == "Unassigned" or location_clean == "Unknown") then
        issue = "missing_fields"
        severity = "low"
        score = 35
    end
    if issue == "" and C.CATEGORY_ALIASES[txn.category or ""] then
        issue = "category_typo"
        severity = "medium"
        score = 45
    end
    if issue == "" and txn.direction == "out" and (amount < 0 or signed > 0) then
        issue = "negative_expense"
        severity = "high"
        score = 80
    end
    if issue == "" and txn.direction == "out" and math.abs(amount) > 30000 then
        issue = "large_transfer"
        severity = "high"
        score = 95
    end

    if issue == "" then
        return "", "none", 0
    end
    return issue, severity ~= "" and severity or "medium", score
end

local function make_row(C, txn, counter, first_year)
    local year = txn.year
    local month = txn.month
    local day = txn.day
    local amount = round2(txn.amount or 0)
    local signed = txn.signed_amount
    if signed == nil then
        if txn.direction == "in" or txn.direction == "asset" then
            signed = math.abs(amount)
        else
            signed = -math.abs(amount)
        end
    end
    signed = round2(signed)

    local category_clean = clean_category(C, txn.category)
    local member_clean = clean_member(txn.member)
    local location_clean = clean_location(txn.location)
    local amount_abs = math.abs(signed)
    local savings_amount = 0
    local expense_amount = 0
    local income_amount = 0
    local debt_amount = 0
    local essential_amount = 0
    local asset_amount = 0

    if txn.direction == "in" then
        income_amount = amount_abs
    elseif txn.direction == "out" then
        if category_clean == "savings" or category_clean == "investment" then
            savings_amount = amount_abs
        else
            expense_amount = amount_abs
            if category_clean == "debt" or category_clean == "housing" then
                debt_amount = amount_abs
            end
            if txn.essential then
                essential_amount = amount_abs
            end
        end
    elseif txn.direction == "asset" then
        asset_amount = signed
    end

    local issue, severity, score = derive_anomaly(C, txn, category_clean, member_clean, location_clean, amount, signed)
    local duplicate_key = table.concat({ txn.date or date_string(year, month, day), member_clean, txn.merchant or "", tostring(round2(amount_abs)), category_clean }, "|")

    return {
        txn.txn_id or string.format("TXN%05d", counter),
        txn.date or date_string(year, month, day),
        year,
        month,
        day,
        month_index(year, month, first_year),
        txn.member or "",
        member_clean,
        txn.role or "family",
        txn.merchant or "",
        txn.category or "",
        category_clean,
        txn.subcategory or "",
        txn.account or "checking",
        txn.payment_method or "card",
        txn.direction or "out",
        amount,
        signed,
        amount_abs,
        income_amount,
        expense_amount,
        savings_amount,
        debt_amount,
        essential_amount,
        asset_amount,
        "PLN",
        bool_text(txn.recurring == true),
        txn.recurring and 1 or 0,
        bool_text(txn.essential == true),
        txn.essential and 1 or 0,
        txn.source or "synthetic",
        txn.location or "",
        location_clean,
        txn.note or "",
        issue,
        severity,
        score,
        duplicate_key,
    }
end

function DataGeneration.generate(C, options)
    options = options or {}
    local profile = C.PROFILE or {}
    local first_year = options.start_year or tonumber(profile.start_year) or C.YEAR_MIN
    local last_year = options.end_year or tonumber(profile.end_year) or C.YEAR_MAX
    local rng = make_rng(options.seed or tonumber(profile.seed) or 20260520)
    local rows = {}
    local counter = 0
    local days_in_month = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }

    local function add(txn)
        counter = counter + 1
        rows[#rows + 1] = make_row(C, txn, counter, C.YEAR_MIN)
        return rows[#rows]
    end

    local groceries = profile_list(profile, "groceries", { "Fresh Market", "Family Grocer", "Corner Bakery", "Local Butcher", "Green Farm" })
    local transport = profile_list(profile, "transport", { "Metro Pass", "Fuel Station", "Rail Tickets", "Bike Service" })
    local school = profile_list(profile, "school", { "Primary School", "Bookshop", "Math Tutor", "Sports Club", "Art Class" })
    local dog = profile_list(profile, "dog", { "Pet Food Store", "Vet Clinic", "Dog Groomer", "Pet Insurance" })
    local entertainment = profile_list(profile, "entertainment", { "Cinema", "Museum", "Board Game Cafe", "Streaming Store", "Play Center" })
    local locations = profile_list(profile, "locations", { "Warsaw", "Praga", "Mokotow", "Online", "Piaseczno" })
    local repairs = profile_list(profile, "repairs", { "Home Repair", "Car Service", "Appliance Parts", "Plumber" })
    local holidays = profile_list(profile, "holiday", { "Travel Agency", "Rail Holiday", "Mountain Stay", "Sea Apartment" })
    local refunds = profile_list(profile, "refunds", { "Tax Office", "Shop Refund", "Insurance Refund" })
    local freelance = profile_list(profile, "freelance", { "Design Client A", "Design Client B", "Consulting Client", "UX Workshop" })
    local healthcare = profile_list(profile, "healthcare", { "Clinic", "Pharmacy", "Dentist", "Optician" })
    local subscriptions = subscriptions_from_profile(profile)

    add({ date = "2021-01-01", year = 2021, month = 1, day = 1, member = "Household", role = "asset", merchant = "Opening Checking", category = "assets", subcategory = "checking_opening", account = "checking", payment_method = "system", direction = "asset", amount = 18000, signed_amount = 18000, essential = true, source = "asset_snapshot", location = "Home" })
    add({ date = "2021-01-01", year = 2021, month = 1, day = 1, member = "Household", role = "asset", merchant = "Opening Savings", category = "assets", subcategory = "savings_opening", account = "savings", payment_method = "system", direction = "asset", amount = 32000, signed_amount = 32000, essential = true, source = "asset_snapshot", location = "Home" })
    add({ date = "2021-01-01", year = 2021, month = 1, day = 1, member = "Household", role = "debt", merchant = "Bank Habitat", category = "debt", subcategory = "mortgage_balance", account = "mortgage", payment_method = "system", direction = "asset", amount = 410000, signed_amount = -410000, essential = true, source = "asset_snapshot", location = "Home" })

    for year = first_year, last_year do
        for month = 1, 12 do
            local days = days_in_month[month]
            local inflation = 1.0
                + (year - C.YEAR_MIN) * (tonumber(profile.inflation_yearly) or 0.045)
                + (month - 1) * (tonumber(profile.inflation_monthly) or 0.002)
            local idx = month_index(year, month, C.YEAR_MIN)

            add({ year = year, month = month, day = 26, member = "Anna", role = "parent_salary", merchant = "City Hospital", category = "income", subcategory = "salary", account = "checking", payment_method = "bank_transfer", direction = "in", amount = (tonumber(profile.base_income_anna) or 8350) * (1 + (year - C.YEAR_MIN) * 0.055), recurring = true, essential = true, source = "payroll", location = "Warsaw", note = "monthly salary" })
            for _ = 1, rng:int(4, 9) do
                add({ year = year, month = month, day = rng:int(2, days), member = "Marek", role = "parent_freelance", merchant = rng:pick(freelance), category = "income", subcategory = "freelance", payment_method = "bank_transfer", direction = "in", amount = rng:money((tonumber(profile.base_freelance) or 720) * inflation, 420), source = "invoice", location = "Online" })
            end

            add({ year = year, month = month, day = 2, member = "Household", merchant = "Bank Habitat", category = "housing", subcategory = "mortgage_payment", account = "mortgage", payment_method = "direct_debit", direction = "out", amount = (tonumber(profile.mortgage_payment) or 3920) * inflation, recurring = true, essential = true, source = "bank", location = "Warsaw" })
            add({ year = year, month = month, day = 5, member = "Household", merchant = "Car Finance", category = "debt", subcategory = "car_loan", account = "loan", payment_method = "direct_debit", direction = "out", amount = (tonumber(profile.car_loan_payment) or 840) * inflation, recurring = true, essential = true, source = "bank", location = "Warsaw" })

            for _, item in ipairs({ { "Power Grid", "utilities", "electricity", 360 }, { "Gas Utility", "utilities", "gas", 260 }, { "Water Utility", "utilities", "water", 170 }, { "Fiber Net", "utilities", "internet", 115 } }) do
                add({ year = year, month = month, day = rng:int(6, 18), member = "Household", merchant = item[1], category = item[2], subcategory = item[3], payment_method = "direct_debit", direction = "out", amount = rng:money(item[4] * inflation, item[4] * 0.18), recurring = true, essential = true, source = "bill", location = "Online" })
            end

            for _ = 1, rng:int(6, 9) do
                add({ year = year, month = month, day = rng:int(1, days), member = rng:pick({ "Anna", "Marek" }), merchant = rng:pick(groceries), category = "groceries", subcategory = rng:pick({ "weekly_shop", "bakery", "produce", "household_items" }), account = "credit_card", payment_method = "card", direction = "out", amount = rng:money(235 * inflation, 90), essential = true, source = "card", location = rng:pick(locations) })
            end
            for _ = 1, rng:int(4, 7) do
                add({ year = year, month = month, day = rng:int(1, days), member = rng:pick({ "Anna", "Marek", "Ola", "Kuba" }), merchant = rng:pick(transport), category = "transport", subcategory = rng:pick({ "fuel", "tickets", "parking", "service" }), account = "credit_card", payment_method = rng:pick({ "card", "cash" }), direction = "out", amount = rng:money(105 * inflation, 70), essential = true, source = "card", location = rng:pick(locations) })
            end
            for _ = 1, rng:int(2, 4) do
                add({ year = year, month = month, day = rng:int(1, days), member = rng:pick({ "Ola", "Kuba" }), role = "child", merchant = rng:pick(school), category = "school", subcategory = rng:pick({ "books", "tuition", "activities", "lunch" }), account = "credit_card", payment_method = "card", direction = "out", amount = rng:money(150 * inflation, 95), essential = true, source = "card", location = rng:pick(locations) })
            end
            for _ = 1, rng:int(2, 3) do
                add({ year = year, month = month, day = rng:int(1, days), member = "Luna", role = "dog", merchant = rng:pick(dog), category = "dog", subcategory = rng:pick({ "food", "vet", "grooming", "insurance" }), account = "credit_card", payment_method = "card", direction = "out", amount = rng:money(125 * inflation, 85), essential = true, source = "card", location = rng:pick(locations) })
            end
            for _ = 1, rng:int(1, 2) do
                add({ year = year, month = month, day = rng:int(1, days), member = rng:pick({ "Anna", "Marek", "Ola", "Kuba" }), merchant = rng:pick(healthcare), category = "healthcare", subcategory = rng:pick({ "medicine", "visit", "dental", "glasses" }), account = "credit_card", payment_method = "card", direction = "out", amount = rng:money(210 * inflation, 160), essential = true, source = "card", location = rng:pick(locations) })
            end

            for _, subscription in ipairs(subscriptions) do
                local creep = 1 + (idx - 1) * 0.008
                add({ year = year, month = month, day = rng:int(3, 25), member = "Household", merchant = subscription.merchant, category = "subscriptions", subcategory = "digital", account = "credit_card", payment_method = "direct_debit", direction = "out", amount = subscription.base * creep, recurring = true, essential = false, source = "subscription", location = "Online" })
            end
            for _ = 1, rng:int(1, 3) do
                add({ year = year, month = month, day = rng:int(1, days), member = rng:pick({ "Anna", "Marek", "Ola", "Kuba" }), merchant = rng:pick(entertainment), category = "entertainment", subcategory = rng:pick({ "cinema", "games", "culture", "weekend" }), account = "credit_card", payment_method = "card", direction = "out", amount = rng:money(190 * inflation, 130), source = "card", location = rng:pick(locations) })
            end
            if rng:next() < 0.55 then
                add({ year = year, month = month, day = rng:int(3, days), member = "Household", merchant = rng:pick(repairs), category = "repairs", subcategory = "home", payment_method = "card", direction = "out", amount = rng:money(520 * inflation, 390), source = "card", location = rng:pick(locations) })
            end
            if month == 7 or month == 8 or month == 12 then
                add({ year = year, month = month, day = rng:int(8, 22), member = "Household", merchant = rng:pick(holidays), category = "holiday", subcategory = "lodging", account = "credit_card", payment_method = "card", direction = "out", amount = rng:money(2600 * inflation, 1100), source = "card", location = rng:pick({ "Gdansk", "Zakopane", "Online", "Krakow" }) })
            end

            add({ year = year, month = month, day = 27, member = "Household", merchant = "Savings Account", category = "savings", subcategory = "monthly_transfer", account = "savings", payment_method = "bank_transfer", direction = "out", amount = (tonumber(profile.monthly_savings) or 1200) * inflation, recurring = true, source = "bank", location = "Online" })
            add({ year = year, month = month, day = 28, member = "Household", merchant = "Brokerage ETF", category = "investment", subcategory = "etf", account = "brokerage", payment_method = "bank_transfer", direction = "out", amount = (tonumber(profile.monthly_investment) or 850) * inflation, recurring = true, source = "bank", location = "Online" })
            if rng:next() < 0.45 then
                add({ year = year, month = month, day = rng:int(10, days), member = rng:pick({ "Anna", "Marek" }), merchant = rng:pick(refunds), category = "refunds", subcategory = "refund", payment_method = "bank_transfer", direction = "in", amount = rng:money(260 * inflation, 180), source = "refund", location = "Online" })
            end
        end
    end

    add({ date = "2022-04-14", year = 2022, month = 4, day = 14, member = "Anna", merchant = "Fresh Market", category = "grocereis", subcategory = "weekly_shop", account = "credit_card", payment_method = "card", direction = "out", amount = 412.40, essential = true, source = "card", location = "Mokotow", note = "typo category" })
    add({ date = "2022-04-14", year = 2022, month = 4, day = 14, member = "Anna", merchant = "Fresh Market", category = "groceries", subcategory = "weekly_shop", account = "credit_card", payment_method = "card", direction = "out", amount = 412.40, essential = true, source = "card", location = "Mokotow", note = "duplicate charge", anomaly_issue = "duplicate_charge", anomaly_severity = "high", anomaly_score = 90 })
    add({ date = "2023-09-10", year = 2023, month = 9, day = 10, member = "", merchant = "Metro Pass", category = "transprot", subcategory = "tickets", account = "credit_card", payment_method = "card", direction = "out", amount = 98.50, essential = true, source = "card", location = "", note = "missing owner and place" })
    add({ date = "2024-11-03", year = 2024, month = 11, day = 3, member = "Household", merchant = "Brokerage ETF", category = "investment", subcategory = "large_transfer", account = "brokerage", payment_method = "bank_transfer", direction = "out", amount = 85000, source = "bank", location = "Online", note = "too large transfer" })
    add({ date = "2025-05-08", year = 2025, month = 5, day = 8, member = "Luna", role = "dog", merchant = "Vet Clinic", category = "dog", subcategory = "surgery", account = "credit_card", payment_method = "card", direction = "out", amount = 6800, essential = true, source = "card", location = "Warsaw", note = "emergency vet", anomaly_issue = "zscore_outlier", anomaly_severity = "high", anomaly_score = 88 })

    local df = lurek.dataframe.fromRows(C.COLUMNS, rows)
    return {
        dataframe = df,
        csv = df:toCSV(),
        rows = #rows,
        rng_state = rng:state(),
    }
end

return DataGeneration
