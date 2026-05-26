SELECT
    date,
    member_clean,
    category_clean,
    merchant,
    payment_method,
    signed_amount,
    anomaly_issue
FROM __SOURCE_TABLE__
WHERE __WHERE__
ORDER BY date DESC
LIMIT 44
