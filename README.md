## Project Overview

This project performs data cleaning and analytical processing on Amazon sales data. The data is extracted from an Excel source and transformed in BigQuery using SQL to generate a clean, enriched dataset and an analysis view.

---
## Data Source

**File:** `Data/Sales_Data.xlsx`  
This file contains raw sales transaction records exported from Amazon.

---

## BigQuery Workflow

### 1. Cleaned Table: `sales_clean_v2`

**Script:** `sales_clean_and_analysis.sql`

This step standardizes and cleans the raw data from the table `Amazon_Data.sales` into `Amazon_Data.sales_clean_v2`.

**Key Transformations:**
- Renamed columns to snake_case format (e.g., `Order ID` → `order_id`)
- Filled nulls for critical fields with placeholders like `'Unknown'` or `'Not specified'`
- Ensured appropriate data types (e.g., `qty` as numeric, `order_date` as DATE)
- Filtered out rows where both `currency` and `amount` were NULL

---

### 2. Analysis View: `sales_analysis_vw`

This view builds on `sales_clean_v2` to provide metrics for deeper business insights.

**Calculated Fields Include:**
- `order_dte`, `order_year`, `order_month`, `order_month_name`, `month_start`: Calendar breakdowns
- `contribution_inr`: Estimated contribution (Amount × 35%)
- `is_return`: Flag to identify potential returns
- `contribution_pct`: Share of total contribution
- `cum_contribution_pct`: Cumulative contribution for Pareto analysis
- `return_rate_pct`: Average return rate per SKU

---

## Output

You will get:
- A clean, analysis-ready table: `Amazon_Data.sales_clean_v2`
- A summarized view for reporting and dashboarding: `Amazon_Data.sales_analysis_vw`

---

## Requirements

- Google BigQuery
- Permissions to read from and write to the `Amazon_Data` dataset
- Excel reader to examine `Sales_Data.xlsx` if needed

---

## Author

This project was created by Caleb Jackson for the purpose of sales performance and return-rate analysis using SQL on BigQuery.
