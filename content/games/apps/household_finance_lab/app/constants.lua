local C = {}

C.WIDTH = 1280
C.HEIGHT = 720
C.SAVE_DIR = "save/household_finance_lab"
C.CACHE_DIR = C.SAVE_DIR .. "/cache"
C.CSV_PATH = C.SAVE_DIR .. "/transactions_2021_2025.csv"
C.LOG_PATH = C.SAVE_DIR .. "/app.log"
C.SCREENSHOT_PATH = C.SAVE_DIR .. "/dashboard.png"
C.TEST_REPORT_PATH = C.SAVE_DIR .. "/test_report.json"
C.CACHE_MANIFEST = C.CACHE_DIR .. "/manifest.json"
C.CACHE_VERSION = "household_finance_lab_cache_v2"

C.YEAR_MIN = 2021
C.YEAR_MAX = 2025

C.COLUMNS = {
    "txn_id", "date", "year", "month", "day", "month_index",
    "member", "member_clean", "role", "merchant", "category", "category_clean",
    "subcategory", "account", "payment_method", "direction", "amount", "signed_amount",
    "amount_abs", "income_amount", "expense_amount", "savings_amount", "debt_amount",
    "essential_amount", "asset_amount", "currency", "recurring", "recurring_value",
    "essential", "essential_value", "source", "location", "location_clean", "note",
    "anomaly_issue", "anomaly_severity", "anomaly_score", "duplicate_key",
}

C.MEMBERS = { "All", "Anna", "Marek", "Ola", "Kuba", "Luna", "Household", "Unassigned" }
C.CATEGORIES = {
    "All", "income", "groceries", "housing", "utilities", "transport", "school",
    "healthcare", "dog", "subscriptions", "entertainment", "repairs", "clothing",
    "holiday", "savings", "investment", "debt", "assets", "refunds",
}

C.CATEGORY_ALIASES = {
    grocereis = "groceries",
    transprot = "transport",
    utlities = "utilities",
    utilties = "utilities",
    subscrptions = "subscriptions",
}

C.COLORS = {
    bg = { 0.055, 0.060, 0.070, 1 },
    panel = { 0.105, 0.115, 0.130, 1 },
    panel2 = { 0.135, 0.148, 0.165, 1 },
    line = { 0.280, 0.310, 0.340, 1 },
    text = { 0.910, 0.930, 0.950, 1 },
    muted = { 0.610, 0.660, 0.710, 1 },
    green = { 0.180, 0.620, 0.400, 1 },
    red = { 0.850, 0.320, 0.280, 1 },
    blue = { 0.220, 0.470, 0.780, 1 },
    cyan = { 0.180, 0.630, 0.720, 1 },
    amber = { 0.900, 0.650, 0.250, 1 },
    violet = { 0.520, 0.420, 0.760, 1 },
}

C.CATEGORY_COLORS = {
    income = { 0.18, 0.62, 0.40, 1 },
    groceries = { 0.20, 0.50, 0.78, 1 },
    housing = { 0.52, 0.42, 0.76, 1 },
    utilities = { 0.90, 0.65, 0.25, 1 },
    transport = { 0.86, 0.38, 0.24, 1 },
    school = { 0.24, 0.62, 0.70, 1 },
    healthcare = { 0.78, 0.30, 0.42, 1 },
    dog = { 0.38, 0.58, 0.26, 1 },
    subscriptions = { 0.64, 0.44, 0.28, 1 },
    entertainment = { 0.80, 0.42, 0.68, 1 },
    repairs = { 0.42, 0.49, 0.56, 1 },
    clothing = { 0.30, 0.55, 0.45, 1 },
    holiday = { 0.25, 0.58, 0.88, 1 },
    savings = { 0.24, 0.64, 0.48, 1 },
    investment = { 0.36, 0.54, 0.82, 1 },
    debt = { 0.82, 0.30, 0.28, 1 },
    assets = { 0.34, 0.68, 0.58, 1 },
    refunds = { 0.62, 0.74, 0.32, 1 },
}

C.TABS = {
    "Widgets", "Cashflow", "Categories", "Members", "Payments", "Anomalies", "Transactions", "Logs",
}

C.SQL_FILES = {
    { file = "00_filtered_transactions.sql", table = "filtered_transactions" },
    { file = "10_summary_totals.sql", table = "summary_totals" },
    { file = "11_monthly_cashflow.sql", table = "monthly_cashflow" },
    { file = "12_category_totals.sql", table = "category_totals" },
    { file = "13_member_totals.sql", table = "member_totals" },
    { file = "14_payment_mix.sql", table = "payment_mix" },
    { file = "15_recurring_merchants.sql", table = "recurring_merchants" },
    { file = "20_anomaly_duplicates.sql", table = "anomaly_duplicates" },
    { file = "21_anomaly_missing_fields.sql", table = "anomaly_missing_fields" },
    { file = "22_anomaly_outliers.sql", table = "anomaly_outliers" },
    { file = "30_recent_transactions.sql", table = "recent_transactions" },
    { file = "40_widget_summary.sql", table = "widget_summary" },
}

C.AGG = {
    count = "COUNT(*)",
    income = "SUM(income_amount)",
    expense = "SUM(expense_amount)",
    savings = "SUM(savings_amount)",
    debt = "SUM(debt_amount)",
    essential = "SUM(essential_amount)",
    assets = "SUM(asset_amount)",
    signed = "SUM(signed_amount)",
    avg_expense = "AVG(expense_amount)",
}

return C