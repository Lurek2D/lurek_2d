SELECT
    payment_method,
    SUM(expense_amount),
    COUNT(*)
FROM filtered_transactions
WHERE expense_amount > 0
GROUP BY payment_method
