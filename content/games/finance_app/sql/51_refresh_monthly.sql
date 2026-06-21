SELECT
    month_index,
    year,
    month,
    SUM(income_amount),
    SUM(expense_amount),
    SUM(savings_amount),
    SUM(debt_amount),
    SUM(essential_amount),
    SUM(signed_amount)
FROM __SOURCE_TABLE__
WHERE __WHERE__
GROUP BY month_index
ORDER BY month_index ASC
