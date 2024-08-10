-- this query calculates the number of days each user used cody and plots the distribution, also know as the "power user curve"
WITH cte AS (
  SELECT
    user_id,
    COUNT(DISTINCT TO_CHAR(timestamp, 'YYYY-MM-DD')) AS days_used
  FROM
    event_logs
  WHERE
    timestamp >= CURRENT_DATE - INTERVAL '30 days'
    AND timestamp < CURRENT_DATE
    AND name IN (--cody-events-list-gets-inserted-here)
  GROUP BY
    1
)
SELECT
  days_used,
  COUNT(DISTINCT user_id) AS distinct_users
FROM cte
GROUP BY
  1
ORDER BY
  1 ASC;
