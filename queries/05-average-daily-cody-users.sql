-- this query calculates the average number of daily active users (excluding weekends)
WITH cte AS (
  SELECT
    TO_CHAR(timestamp, 'YYYY-MM-DD') AS timestamp_day,
    COUNT(DISTINCT user_id) AS distinct_users
  FROM
    event_logs
  WHERE
    timestamp >= CURRENT_DATE - INTERVAL '30 days'
    AND timestamp < CURRENT_DATE
    AND EXTRACT(DOW FROM timestamp) NOT IN (0,6) --remove weekends
    AND name IN (--cody-events-list-gets-inserted-here)
  GROUP BY
    1
)
SELECT
  AVG(distinct_users) AS average_daily_users
FROM
  cte;
