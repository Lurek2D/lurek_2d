SELECT
    date,
    member_clean,
    category_clean,
    merchant,
    payment_method,
    signed_amount,
    anomaly_issue
FROM filtered_transactions
ORDER BY date DESC
LIMIT 30
