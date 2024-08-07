-- calculates completion acceptance rate by day, for jetbrains and vscode
SELECT
  TO_CHAR(timestamp,
    'YYYY-MM-DD') AS timestamp_day,
  CASE
    WHEN COUNT(CASE
      WHEN name = 'cody.completion:suggested'
    AND client = 'jetbrains.cody'
    AND (public_argument->'metadata'->>'displayDuration')::float > 750 THEN 1
      ELSE NULL
  END) as count_suggestions_jetbrains
    CASE
    WHEN COUNT(CASE
      WHEN name = 'cody.completion:suggested'
    AND (public_argument->'metadata'->>'read') = '1'
    AND client = 'vscode.cody'
    AND (public_argument->'metadata'->>'otherCompletionProviderEnabled') = '0' THEN 1
      ELSE NULL
  END
    ) as count_suggestions_vscode
  CASE
    WHEN COUNT(CASE
      WHEN name = 'cody.completion:suggested'
    AND client = 'jetbrains.cody'
    AND (public_argument->'metadata'->>'displayDuration')::float > 750 THEN 1
      ELSE NULL
  END
    ) > 0 THEN COUNT(CASE
      WHEN name = 'cody.completion:accepted' AND client = 'jetbrains.cody' THEN 1
      ELSE NULL
  END
    )::float / COUNT(CASE
      WHEN name = 'cody.completion:suggested' AND client = 'jetbrains.cody' AND (public_argument->'metadata'->>'displayDuration')::float > 750 THEN 1
      ELSE NULL
  END
    )
    ELSE NULL
END
  AS completion_acceptance_rate_jetbrains
  CASE
    WHEN COUNT(CASE
      WHEN name = 'cody.completion:suggested'
    AND (public_argument->'metadata'->>'read') = '1'
    AND client = 'vscode.cody'
    AND (public_argument->'metadata'->>'otherCompletionProviderEnabled') = '0' THEN 1
      ELSE NULL
  END
    ) > 0 THEN COUNT(CASE
      WHEN name = 'cody.completion:accepted' AND client = 'vscode.cody' AND (public_argument->'metadata'->>'otherCompletionProviderEnabled') = '0' THEN 1
      ELSE NULL
  END
    )::float / COUNT(CASE
      WHEN name = 'cody.completion:suggested' AND (public_argument->'metadata'->>'read') = '1' AND client = 'vscode.cody' AND (public_argument->'metadata'->>'otherCompletionProviderEnabled') = '0' THEN 1
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
