SELECT
    TO_CHAR(timestamp, 'YYYY-MM') AS timestamp_month,
    COUNT(DISTINCT user_id) AS distinct_users
FROM
    event_logs
WHERE
    timestamp >= DATE_TRUNC('MONTH', CURRENT_DATE) - INTERVAL '3 MONTHS'
    AND timestamp < DATE_TRUNC('MONTH', CURRENT_DATE) + INTERVAL '1 MONTH'
    AND LOWER(name) LIKE 'cody%'
    AND name IN(
        --cody-events-list-gets-inserted-here
    )
GROUP BY
    1
ORDER BY
    1 DESC;
