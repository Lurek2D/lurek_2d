SELECT
    payment_method,
    SUM(expense_amount),
    COUNT(*)
FROM __SOURCE_TABLE__
WHERE __WHERE__
  AND expense_amount > ?
GROUP BY payment_method
ORDER BY payment_method ASC
