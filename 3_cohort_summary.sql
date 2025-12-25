WITH base_metrics AS (
  SELECT
    user_pseudo_id,
    SUM((SELECT value.double_value FROM UNNEST(event_params) WHERE key = 'value')) AS total_spent
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE
    _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  GROUP BY
    user_pseudo_id
),

user_segments AS (
  SELECT
    user_pseudo_id,
    CASE
      WHEN total_spent > 100 THEN 'High Value'
      WHEN total_spent BETWEEN 10 AND 100 THEN 'Medium Value'
      ELSE 'Low Value'
    END AS customer_segment,
    total_spent
  FROM
    base_metrics
  WHERE total_spent > 0
)

SELECT
  customer_segment,
  COUNT(user_pseudo_id) AS total_customers,
  ROUND(SUM(total_spent), 2) AS total_revenue
FROM
  user_segments
GROUP BY
  customer_segment
ORDER BY
  total_revenue DESC;
