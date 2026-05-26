SELECT
    merchant,
    SUM(expense_amount),
    AVG(expense_amount),
    COUNT(*)
FROM filtered_transactions
WHERE recurring_value = 1
GROUP BY merchant
