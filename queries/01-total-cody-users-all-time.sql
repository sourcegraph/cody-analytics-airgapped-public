-- Total Cody users, all time
SELECT
    COUNT(DISTINCT user_id) AS distinct_users
FROM
    event_logs
WHERE
    LOWER(name) LIKE 'cody%'
    AND name IN(
        --cody-events-list-gets-inserted-here
    );
