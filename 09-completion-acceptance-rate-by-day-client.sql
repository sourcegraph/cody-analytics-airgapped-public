-- calculates completion acceptance rate by day, for jetbrains and vscode
SELECT
  TO_CHAR(timestamp,
    'YYYY-MM-DD') AS timestamp_day,
  COUNT(CASE
      WHEN name = 'cody.completion.suggested'
    AND LOWER(client) LIKE 'jetbrains.cody%'
    AND cast(public_argument->>'displayDuration' as double precision) > 750 THEN 1
      ELSE NULL
  END) as count_suggestions_jetbrains,
   COUNT(CASE
      WHEN name = 'cody.completion.suggested'
    AND public_argument->>'read' = '1'
    AND LOWER(client) LIKE 'vscode.cody%'
    AND (public_argument->>'otherCompletionProviderEnabled') = '0' THEN 1
      ELSE NULL
  END
    ) as count_suggestions_vscode,
  CASE
    WHEN COUNT(CASE
      WHEN name = 'cody.completion.suggested'
    AND LOWER(client) LIKE 'jetbrains.cody%'
    AND cast(public_argument->>'displayDuration' as double precision) > 750 THEN 1
      ELSE NULL
  END
    ) > 0 THEN COUNT(CASE
      WHEN name = 'cody.completion.accepted' AND LOWER(client) LIKE 'jetbrains.cody%' THEN 1
      ELSE NULL
  END
    )::float / COUNT(CASE
      WHEN name = 'cody.completion.suggested' AND LOWER(client) LIKE 'jetbrains.cody%' AND cast(public_argument->>'displayDuration' as double precision) > 750 THEN 1
      ELSE NULL
  END
    )
    ELSE NULL
END
  AS completion_acceptance_rate_jetbrains,
  CASE
    WHEN COUNT(CASE
      WHEN name = 'cody.completion.suggested'
    AND public_argument->>'read' = '1'
    AND LOWER(client) LIKE 'vscode.cody%'
    AND public_argument->>'otherCompletionProviderEnabled' = '0' THEN 1
      ELSE NULL
  END
    ) > 0 THEN COUNT(CASE
      WHEN name = 'cody.completion.accepted' AND LOWER(client) LIKE 'vscode.cody%' AND public_argument->>'otherCompletionProviderEnabled' = '0' THEN 1
      ELSE NULL
  END
    )::float / COUNT(CASE
      WHEN name = 'cody.completion.suggested' AND public_argument->>'read' = '1' AND LOWER(client) LIKE 'vscode.cody%' AND public_argument->>'otherCompletionProviderEnabled' = '0' THEN 1
      ELSE NULL
  END
    )
    ELSE NULL
END
  AS completion_acceptance_rate_vscode
FROM
  event_logs
WHERE
  timestamp >= CURRENT_DATE - INTERVAL '30 days'
  AND timestamp < CURRENT_DATE
GROUP BY
  1;
