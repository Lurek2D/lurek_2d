SELECT
    txn_id,
    date,
    year,
    month,
    member_clean,
    category_clean,
    merchant,
    amount_abs,
    anomaly_issue,
    anomaly_severity,
    anomaly_score
FROM transactions
WHERE anomaly_issue != NULL
