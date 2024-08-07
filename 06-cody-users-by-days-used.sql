-- this query calculates the number of days each user used cody and plots the distribution, also know as the "power user curve"
WITH cte AS (
  SELECT
    event_logs.user_id,
    COUNT(DISTINCT TO_CHAR(event_logs.timestamp, 'YYYY-MM-DD')) AS days_used
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
  cte.days_used,
  COUNT(DISTINCT cte.user_id) AS distinct_users
FROM cte
GROUP BY
  1
ORDER BY
  1 ASC;
