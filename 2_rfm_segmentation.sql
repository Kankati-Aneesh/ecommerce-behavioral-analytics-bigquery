WITH base_metrics AS (
  SELECT
    user_pseudo_id,
    MAX(event_date) AS last_visit_date,
    COUNT(DISTINCT event_date) AS frequency,
    SUM(
      (SELECT value.double_value FROM UNNEST(event_params) WHERE key = 'value')
    ) AS total_spent
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE
    _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  GROUP BY
    user_pseudo_id
)

SELECT
  user_pseudo_id,
  last_visit_date,
  frequency,
  COALESCE(total_spent, 0) AS total_revenue,
  CASE
    WHEN total_spent > 100 THEN 'High Value'
    WHEN total_spent BETWEEN 10 AND 100 THEN 'Medium Value'
    ELSE 'Low Value / Window Shopper'
  END AS customer_segment
FROM
  base_metrics
WHERE
  total_spent > 0 
ORDER BY
  total_spent DESC
LIMIT 10;
