-- command/chat/accepted completion events and distinct users, by day
SELECT
  TO_CHAR(timestamp, 'YYYY-MM-DD') AS timestamp_day,
  COUNT(CASE
      WHEN (name LIKE '%command%' OR name LIKE '%recipe%') AND (name NOT LIKE '%chat%') THEN 1
      ELSE NULL
  END) AS command_events,
  COUNT(DISTINCT CASE
      WHEN (name LIKE '%command%' OR name LIKE '%recipe%') AND (name NOT LIKE '%chat%') THEN user_id
      ELSE NULL
  END) AS distinct_command_users,
  COUNT(CASE
      WHEN (name IN ('cody.chat:submit', 'cody.chat-question:executed', 'cody.recipe.inline-chat:executed')) THEN 1
      ELSE NULL
  END) AS chat_events,
  COUNT(DISTINCT CASE
      WHEN name IN ('cody.chat:submit', 'cody.chat-question:executed', 'cody.recipe.inline-chat:executed') THEN user_id
      ELSE NULL
  END) AS distinct_chat_users,
  COUNT(DISTINCT CASE
      WHEN (name = 'cody.completion:accepted') AND ((public_argument->'metadata'->>'otherCompletionProvider')::int <> 1 OR public_argument->'metadata'->>'otherCompletionProvider' IS NULL) THEN user_id
      ELSE NULL
  END) AS completion_accepted_users,
  COUNT(CASE
      WHEN (name = 'cody.completion:accepted') AND ((public_argument->'metadata'->>'otherCompletionProvider')::int <> 1 OR public_argument->'metadata'->>'otherCompletionProvider' IS NULL) THEN 1
      ELSE NULL
  END) AS completion_accepted_events
FROM
  event_logs
WHERE
  timestamp >= CURRENT_DATE - INTERVAL '30 days'
  AND timestamp < CURRENT_DATE
  AND name IN ( --cody-events-list-gets-inserted-here
  )
GROUP BY
  1
ORDER BY
  1;
