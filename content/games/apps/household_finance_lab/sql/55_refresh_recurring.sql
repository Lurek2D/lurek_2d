SELECT
    merchant,
    SUM(expense_amount),
    AVG(expense_amount),
    COUNT(*)
FROM __SOURCE_TABLE__
WHERE __WHERE__
  AND recurring_value = ?
GROUP BY merchant
ORDER BY merchant ASC
LIMIT 8
