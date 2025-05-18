CREATE OR REPLACE TABLE `amazon-analysis-460201.Amazon_Data.sales_clean_v2` AS
SELECT
  `Order ID` AS order_id,
  `Date`     AS order_date,
  `Status`   AS status,
  `Fulfilment`             AS fulfilment,
  `Sales Channel `         AS sales_channel,
  `ship-service-level`     AS ship_service_level,
  `Style`                  AS style,
  `SKU`                    AS sku,
  `Category`               AS category,
  `Size`                   AS size,
  `ASIN`                   AS asin,

  IFNULL( CAST(`Courier Status` AS STRING) , 'Unknown')          AS courier_status,
  `Qty`                        AS qty,        -- numeric
  currency,                                    -- keep as-is
  Amount        AS amount,                     -- keep as-is

  IFNULL( CAST(`ship-city`        AS STRING) , 'Not specified')  AS ship_city,
  IFNULL( CAST(`ship-state`       AS STRING) , 'Not specified')  AS ship_state,
  IFNULL( CAST(`ship-postal-code` AS STRING) , 'Not specified')  AS ship_postal_code,
  IFNULL( CAST(`ship-country`     AS STRING) , 'Not specified')  AS ship_country,

  IFNULL( CAST(`promotion-ids` AS STRING) , 'No promo')          AS promotion_ids,

  `B2B` AS b2b,

  IFNULL( CAST(`fulfilled-by` AS STRING), 'Unknown')             AS fulfilled_by
FROM `amazon-analysis-460201.Amazon_Data.sales`
WHERE NOT (currency IS NULL AND Amount IS NULL);   -- drop rows with both null

CREATE OR REPLACE VIEW `amazon-analysis-460201.Amazon_Data.sales_analysis_vw` AS
WITH base AS (
  SELECT
    sc.*,

    -- assure DATE type
    DATE(order_date)                              AS order_dte,

    -- calendar breakdowns
    EXTRACT(YEAR  FROM order_date)                AS order_year,
    EXTRACT(MONTH FROM order_date)                AS order_month,
    FORMAT_DATE('%B', DATE(order_date))           AS order_month_name,
    DATE_TRUNC(DATE(order_date), MONTH)           AS month_start,

    -- simple contribution proxy (amount * 35 %)
    CAST(amount AS NUMERIC) * 0.35                AS contribution_inr,

    -- crude return flag (adjust if you have better logic)
    CASE
        WHEN LOWER(status) LIKE '%return%' THEN 1
        ELSE 0
    END                                           AS is_return
  FROM `amazon-analysis-460201.Amazon_Data.sales_clean_v2` sc
),

kpi AS (
  SELECT
    b.*,

    -- share of total contribution
    contribution_inr
      / SUM(contribution_inr) OVER ()             AS contribution_pct,

    -- cumulative Pareto %
    SUM(contribution_inr) OVER (
        ORDER BY contribution_inr DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
      / SUM(contribution_inr) OVER ()             AS cum_contribution_pct,

    -- per-SKU return-rate
    AVG(is_return) OVER (PARTITION BY sku)        AS return_rate_pct
  FROM base b
)

SELECT * FROM kpi;
