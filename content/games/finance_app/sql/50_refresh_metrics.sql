SELECT
    COUNT(*) AS row_count,
    SUM(income_amount) AS income,
    SUM(expense_amount) AS expense,
    SUM(savings_amount) AS savings,
    SUM(debt_amount) AS debt,
    SUM(essential_amount) AS essential,
    SUM(asset_amount) AS assets,
    SUM(savings_amount) / SUM(income_amount) AS savings_rate,
    SUM(debt_amount) / SUM(income_amount) AS debt_ratio,
    SUM(essential_amount) / SUM(expense_amount) AS essential_ratio,
    SUM(expense_amount) / ? AS avg_expense,
    (50000 + SUM(asset_amount) * 0.08) / (SUM(expense_amount) / ?) AS runway_months
FROM __SOURCE_TABLE__
WHERE __WHERE__
