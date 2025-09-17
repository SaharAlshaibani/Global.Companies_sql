# Global Companies — SQL Analysis (MySQL)

This repository provides **reusable SQL** to analyze a raw table `mytable` (columns **A..G**) and a cleaned view **`v_clean`** that converts textual market caps/prices into **numeric USD** for robust analytics.

## Raw columns
- **A** — Rank (number)  
- **B** — Company (text)  
- **C** — Company code / ticker (text)  
- **D** — Market cap (text, e.g., `$3.03 T`, `$611.4 B`, `$29.1 M`)  
- **E** — Stock price (text, e.g., `$407.21`)  
- **F** — Origin flag (emoji, optional)  
- **G** — Country (text)

> Emoji/Arabic data:
> ```sql
> SET NAMES utf8mb4;
> SET collation_connection = utf8mb4_unicode_ci;
> ```

## Repository structure
```text
.
├─ README.md
├─ sql/
│  ├─ 00_view_v_clean.sql     # creates the cleaned view `v_clean`
│  └─ 01_queries.sql          # modular analysis queries (run blocks individually)
└─ data/
   └─ companiesmarketcap.xlsx # optional local Excel copy

How to run
Ensure mytable exists and is loaded (seed a few rows or import your Excel/CSV).

Create the cleaning view:
SOURCE sql/00_view_v_clean.sql;


Execute the analysis blocks:
SOURCE sql/01_queries.sql;

Note: Some online tools (e.g., DB Fiddle) return a single result set per run—execute one block at a time.

What v_clean does

Parses $ and thousands separators.

Converts suffixes T/B/M → numeric USD (T×1e12, B×1e9, M×1e6).

Exposes: rank_num, company, company_code, marketcap_usd, price_usd, origin_flag, country.

Filters out header/blank ranks with A REGEXP '^[0-9]+$' AND B IS NOT NULL.

Included queries

Top 10 (raw & numeric)

Country aggregates + market share %

Largest company per country

Market-cap buckets (Mega / Large / Mid / Small / Micro)

Countries by highest average market cap (min 3 companies)

Top-3 companies per country (MySQL 5.7-friendly variables trick)

Duplicate company_code detection

Stock price distribution buckets

Country filter example (USA)

Average stock price (2 decimals)

Quality checks (missing numeric values)

Requirements

MySQL 5.7 or 8.0

On MySQL 8.0 you may replace the 5.7 variables trick with window functions (e.g., ROW_NUMBER()).

Data

Source (Kaggle):
Largest Companies by Market Cap

Download with Kaggle CLI

Authenticate once:
pip install kaggle
# Kaggle → Account → Create New API Token
# Save kaggle.json:
# Windows:  C:\Users\<YOU>\.kaggle\kaggle.json
# macOS/Linux:
mkdir -p ~/.kaggle
mv ~/Downloads/kaggle.json ~/.kaggle/
chmod 600 ~/.kaggle/kaggle.json


List files:
kaggle datasets files shiivvvaam/largest-companies-by-market-cap

Download all files into data/ and unzip:

kaggle datasets download -d shiivvvaam/largest-companies-by-market-cap -p data --unzip


(Optional) Download a single file by name:
kaggle datasets download -d shiivvvaam/largest-companies-by-market-cap -f "<exact_file_name.ext>" -p data --unzip

If the dataset provides CSV (not Excel), import the CSV into MySQL or convert locally to Excel before placing it under data/.
Troubleshooting

Incorrect string value (emoji) → ensure utf8mb4 session/table settings (see snippet above).

Header row appears → v_clean already filters by numeric rank; ensure the CSV header wasn’t inserted as data.

Single result set tools → run one query block at a time.
