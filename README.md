# Global Companies — SQL Analysis (MySQL)

This repo provides **reusable SQL** to analyze a raw `mytable` (columns A..G) and a clean view `v_clean` that converts textual market caps/prices into **numeric USD**.

## Raw columns
- **A** Rank (number)
- **B** Company (text)
- **C** Company code / ticker (text)
- **D** Market cap (text, e.g., `$3.03 T`, `$611.4 B`, `$29.1 M`)
- **E** Stock price (text, e.g., `$407.21`)
- **F** Origin flag (emoji, optional)
- **G** Country (text)

> If you store emoji/Arabic:  
> `SET NAMES utf8mb4; SET collation_connection = utf8mb4_unicode_ci;`

## How to run
1. Ensure `mytable` exists and is loaded (use `data/sample_insert.sql` for a quick test).
2. Run `sql/00_view_v_clean.sql` to create `v_clean`.
3. Run any block from `sql/queries.sql`.  
   > If your tool shows one result set only (e.g., DB Fiddle), run one block at a time.

## Included queries
- Top 10 (raw & numeric)  
- Country aggregates + market share %  
- Largest company per country  
- Market-cap size buckets  
- Countries by highest average cap (min 3)  
- Top-3 companies per country (MySQL 5.7-friendly)  
- Duplicate `company_code` detection  
- Price distribution buckets  
- Country filter example (USA)  
- Average stock price (2 decimals)  
- Quality checks (missing numeric values)

## Notes
- `v_clean` handles `$`, commas, and suffixes **T/B/M** into numeric USD.  
- Tested on MySQL 5.7/8.0. Replace variables trick with window functions if on 8.0.
