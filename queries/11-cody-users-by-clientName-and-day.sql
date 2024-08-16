-- This query calculates daily active users, broken down by client name (extracted from the client field)
SELECT
  TO_CHAR(event_logs.timestamp, 'YYYY-MM-DD') AS timestamp_day,
  REGEXP_REPLACE(client, ':.*$', '') AS extracted_client,
  COUNT(DISTINCT event_logs.user_id) AS distinct_users
FROM
  event_logs
WHERE
  event_logs.timestamp >= CURRENT_DATE - INTERVAL '30 days'
  AND event_logs.timestamp < CURRENT_DATE
  AND name IN (
    --cody-events-list-gets-inserted-here
  )
GROUP BY
  1,
  2;
