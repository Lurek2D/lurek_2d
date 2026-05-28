-- below query is generating totals for 1 row - fix it. We want totals for each row.

SELECT
    category_clean,
    SUM(expense_amount),
    COUNT(*)
FROM __SOURCE_TABLE__
WHERE __WHERE__
  AND expense_amount > ?
GROUP BY category_clean
ORDER BY category_clean ASC
LIMIT 12
