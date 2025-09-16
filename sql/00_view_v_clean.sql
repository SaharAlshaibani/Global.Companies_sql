CREATE OR REPLACE VIEW v_clean AS
SELECT
  CAST(A AS UNSIGNED) AS rank_num,
  B                   AS company,
  C                   AS company_code,
  CASE
    WHEN D LIKE '% T' THEN CAST(REPLACE(REPLACE(D,'$',''),' T','') AS DECIMAL(20,6))*1e12
    WHEN D LIKE '% B' THEN CAST(REPLACE(REPLACE(D,'$',''),' B','') AS DECIMAL(20,6))*1e9
    WHEN D LIKE '% M' THEN CAST(REPLACE(REPLACE(D,'$',''),' M','') AS DECIMAL(20,6))*1e6
    ELSE NULL
  END                 AS marketcap_usd,
  CAST(REPLACE(REPLACE(E,'$',''),',','') AS DECIMAL(20,6)) AS price_usd,
  F                   AS origin_flag,
  G                   AS country
FROM mytable
WHERE A REGEXP '^[0-9]+$' AND B IS NOT NULL;
