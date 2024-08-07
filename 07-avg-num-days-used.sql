-- this query calculates how many days each user used cody and then takes the average across all users
WITH cte AS (
  SELECT
    user_id,
    COUNT(DISTINCT TO_CHAR(event_logs.timestamp, 'YYYY-MM-DD')) AS days_used
  FROM
    event_logs
  WHERE
    event_logs.timestamp >= CURRENT_DATE - INTERVAL '30 days'
    AND event_logs.timestamp < CURRENT_DATE
    AND name IN (--cody-events-list-gets-inserted-here)
  GROUP BY
    user_id
)
SELECT
  AVG(days_used) AS average_days_used
FROM cte;
