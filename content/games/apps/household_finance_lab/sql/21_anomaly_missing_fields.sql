SELECT
    txn_id,
    date,
    member_clean,
    category_clean,
    merchant,
    amount_abs,
    anomaly_issue,
    anomaly_score
FROM transactions
WHERE anomaly_issue = 'missing_fields'
