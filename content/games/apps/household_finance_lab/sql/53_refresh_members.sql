SELECT
    member_clean,
    SUM(income_amount),
    SUM(expense_amount),
    SUM(savings_amount),
    SUM(debt_amount),
    COUNT(*)
FROM __SOURCE_TABLE__
WHERE __WHERE__
GROUP BY member_clean
ORDER BY member_clean ASC
