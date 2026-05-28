-- below query is generating totals for 1 row - fix it. We want totals for each row.

SELECT
    COUNT(*),
    SUM(income_amount),
    SUM(expense_amount),
    SUM(savings_amount),
    SUM(debt_amount),
    SUM(essential_amount),
    SUM(asset_amount)
FROM filtered_transactions

