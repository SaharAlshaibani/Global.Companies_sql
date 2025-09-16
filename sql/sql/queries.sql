/* 1) Top 10 (raw text from the source table) */
SELECT A AS rank, B AS company, D AS marketcap
FROM mytable
WHERE A REGEXP '^[0-9]+$'
ORDER BY CAST(A AS UNSIGNED)
LIMIT 10;

/* 2) Top 10 (numeric from v_clean) */
SELECT company, marketcap_usd
FROM v_clean
ORDER BY marketcap_usd DESC
LIMIT 10;

/* 3) Country aggregates + market share % (MySQL 5.7 compatible) */
SELECT
  c.country,
  COUNT(*) AS companies,
  SUM(c.marketcap_usd) AS total_marketcap_usd,
  100 * SUM(c.marketcap_usd) / (SELECT SUM(marketcap_usd) FROM v_clean) AS market_share_pct
FROM v_clean c
GROUP BY c.country
ORDER BY total_marketcap_usd DESC;

/* 4) Largest company per country (by market cap) */
SELECT vc.*
FROM v_clean vc
JOIN (
  SELECT country, MAX(marketcap_usd) AS max_cap
  FROM v_clean
  GROUP BY country
) m
  ON m.country = vc.country
 AND m.max_cap = vc.marketcap_usd
ORDER BY vc.country;

/* 5) Market-cap size buckets */
SELECT
  CASE
    WHEN marketcap_usd >= 1e12 THEN 'Mega (≥ $1T)'
    WHEN marketcap_usd >= 1e11 THEN 'Large ($100B–$1T)'
    WHEN marketcap_usd >= 1e10 THEN 'Mid ($10B–$100B)'
    WHEN marketcap_usd >= 1e9  THEN 'Small ($1B–$10B)'
    ELSE 'Micro (< $1B)'
  END AS cap_bucket,
  COUNT(*) AS companies,
  SUM(marketcap_usd) AS total_marketcap_usd
FROM v_clean
GROUP BY cap_bucket
ORDER BY total_marketcap_usd DESC;

/* 6) Countries with highest average market cap (min 3 companies) */
SELECT
  country,
  COUNT(*)           AS companies,
  AVG(marketcap_usd) AS avg_cap_usd,
  SUM(marketcap_usd) AS total_cap_usd
FROM v_clean
GROUP BY country
HAVING COUNT(*) >= 3
ORDER BY avg_cap_usd DESC;

/* 7) Top-3 companies per country (MySQL 5.7 variables trick) */
SET @r := 0;
SET @c := '';

SELECT country, company, company_code, marketcap_usd, rn
FROM (
  SELECT 
    t.*,
    @r := IF(@c = t.country, @r + 1, 1) AS rn,
    @c := t.country                      AS _set_country
  FROM (
    SELECT country, company, company_code, marketcap_usd
    FROM v_clean
    ORDER BY country, marketcap_usd DESC
  ) t
) ranked
WHERE rn <= 3
ORDER BY country, rn;

/* 8) Duplicate company_code detection (no rows = no duplicates) */
SELECT company_code, COUNT(*) AS cnt
FROM v_clean
WHERE company_code IS NOT NULL
GROUP BY company_code
HAVING COUNT(*) > 1
ORDER BY cnt DESC;

/* 9) Stock price distribution buckets */
SELECT
  CASE
    WHEN price_usd < 10   THEN '< $10'
    WHEN price_usd < 50   THEN '$10–$49'
    WHEN price_usd < 100  THEN '$50–$99'
    WHEN price_usd < 200  THEN '$100–$199'
    ELSE '≥ $200'
  END AS price_bucket,
  COUNT(*) AS companies
FROM v_clean
GROUP BY price_bucket
ORDER BY MIN(price_usd);

/* 10) Country filter example (USA) */
SELECT company, company_code, marketcap_usd, price_usd
FROM v_clean
WHERE country = 'USA'
ORDER BY marketcap_usd DESC;

/* 11) Average stock price (2 decimals) */
SELECT ROUND(AVG(price_usd), 2) AS avg_price
FROM v_clean;

/* 12) Quality check: rows missing numeric values */
SELECT *
FROM v_clean
WHERE marketcap_usd IS NULL OR price_usd IS NULL;

