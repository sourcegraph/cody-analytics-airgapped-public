SELECT
    COUNT(DISTINCT user_id) AS distinct_users
FROM
    event_logs
WHERE
    timestamp >= CURRENT_DATE - INTERVAL '30 days'
    AND timestamp < CURRENT_DATE
    AND LOWER(name) LIKE 'cody%'
    AND name IN(
        --cody-events-list-gets-inserted-here
    );
