-- this query calculates the average number of daily active users
WITH cte AS (
  SELECT
    TO_CHAR(event_logs.timestamp, 'YYYY-MM-DD') AS timestamp_day,
    COUNT(DISTINCT user_id) AS distinct_users
  FROM
    event_logs
  WHERE
    event_logs.timestamp >= CURRENT_DATE - INTERVAL '30 days'
    AND event_logs.timestamp < CURRENT_DATE
    AND name IN (--cody-events-list-gets-inserted-here)
  GROUP BY
    1
)
SELECT
  AVG(cte.distinct_users) AS average_daily_users
FROM
  cte;
