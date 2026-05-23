SELECT
    txn_id,
    date,
    year,
    month,
    month_index,
    member_clean,
    category_clean,
    merchant,
    amount_abs,
    anomaly_issue,
    anomaly_severity,
    anomaly_score
FROM transactions
WHERE __ANOMALY_WHERE__
ORDER BY anomaly_score DESC
LIMIT 40
