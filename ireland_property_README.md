# 🏠 Ireland Property Price Register Analysis — MySQL

## Overview

This project performs end-to-end SQL analysis on the **Irish Residential Property Price Register** — a real government dataset published by the **Property Services Regulatory Authority (PSRA)**. It covers every residential property sale in Ireland from **January 2010 to May 2026**, across all 26 counties — nearly **786,000 real transactions**.

The analysis answers real business questions about the Irish housing market including price trends, county comparisons, new vs second-hand homes, price growth over time, and market share — using advanced SQL techniques including CTEs, Window Functions, and aggregations.

---

## 📁 Repository Structure

```
ireland-property-analysis/
│
├── 01_Create_Database_&_Table.sql          # Create database and table schema
├── 02_LOAD_DATA_command.sql                # Load CSV into MySQL using LOAD DATA
├── 03_Data_Cleaning_&_Quality_Checks.sql   # Data quality and integrity checks
├── 04_Business_Analysis_Queries.sql        # 16 business analysis queries
├── property_price_register_clean.csv       # Cleaned dataset ready for MySQL import
└── README.md
```

---

## 📊 Dataset

| Detail | Info |
|--------|------|
| **Name** | Irish Property Price Register — Sales 2010–2026 |
| **Source** | Property Services Regulatory Authority (PSRA) |
| **Kaggle Link** | https://www.kaggle.com/datasets/fionnhughes/property-price-register |
| **Original Source** | https://www.propertypriceregister.ie |
| **Licence** | CC BY 4.0 (Open licence — free to use and redistribute) |
| **Total Rows** | 785,993 real property sales |
| **Date Range** | January 2010 – May 2026 |
| **Coverage** | All 26 counties in Ireland |

### Dataset Columns

| Column | Type | Description |
|--------|------|-------------|
| `date_of_sale` | DATE | Date the property sale was completed and registered |
| `address` | VARCHAR | Full address of the property |
| `county` | VARCHAR | County where the property is located |
| `eircode` | VARCHAR | Irish postal code (available from 2015 onwards) |
| `price_eur` | DECIMAL | Sale price in Euros |
| `not_full_market_price` | TINYINT | 0 = Normal market sale, 1 = Non-standard sale |
| `vat_exclusive` | TINYINT | 0 = VAT inclusive, 1 = VAT exclusive (new homes) |
| `description` | VARCHAR | New Dwelling or Second-Hand Dwelling |
| `property_size` | VARCHAR | Size category of the property in sq metres |

---

## 🧹 Data Cleaning Applied

The original Kaggle CSV had 4 data quality issues that were fixed before importing into MySQL:

| Issue | Original | Fixed |
|-------|----------|-------|
| **BOM Encoding** | File started with `\xef\xbb\xbf` (UTF-8 BOM) causing MySQL import to fail | Removed BOM, saved as clean UTF-8 |
| **Boolean values** | `True` / `False` text — MySQL does not understand this | Converted to `1` / `0` integers |
| **Irish language text** | `Teach/Árasán Cónaithe Nua`, `Teach/Árasán Cónaithe Atháimhe` | Translated to English equivalents |
| **Corrupted characters** | `Teach/?ras?n C?naithe Nua`, `n?os l? n? 38 m?adar` | Replaced with correct English text |

> These are real-world data quality issues that Data Analysts encounter daily — identifying and fixing them is part of the data cleaning process documented in `03_Data_Cleaning_&_Quality_Checks.sql`.

---

## 📋 Business Questions Answered (16 Queries)

### 🇮🇪 Section 1: National Overview
| # | Question |
|---|----------|
| Q1 | What is the total number of sales and average price each year nationally? |
| Q2 | What is the monthly sales volume trend over time? |
| Q3 | What is the national median property price by year? |

### 🗺️ Section 2: County Analysis
| # | Question |
|---|----------|
| Q4 | Which county has the highest average property price all time? |
| Q5 | What are the top 5 most expensive counties in the last 5 years? |
| Q6 | How does Dublin compare to the rest of Ireland in price, year by year? |
| Q7 | Which county has the highest share of national property sales? |

### 🏗️ Section 3: New vs Second-Hand
| # | Question |
|---|----------|
| Q8 | How do new and second-hand home prices compare each year? |
| Q9 | What share of sales in each county are new builds? |

### 💰 Section 4: Price Bracket Analysis
| # | Question |
|---|----------|
| Q10 | How many properties sold in each price bracket (Under €100k to Over €1M)? |
| Q11 | Which counties have the most sales over €500k? |

### 🔢 Section 5: Advanced SQL — Window Functions & CTEs
| # | Question |
|---|----------|
| Q12 | What is the year-over-year price growth % by county? (LAG) |
| Q13 | How do counties rank by average price each year? (RANK) |
| Q14 | What is the running total of national property sales by year? (SUM OVER) |
| Q15 | What is the 3-year rolling average price in Dublin? (AVG OVER ROWS) |
| Q16 | What percentage of sales are above the national average each year? (JOIN + CTE) |

---

## 🛠️ SQL Concepts Used

| Concept | Used In |
|---------|---------|
| `GROUP BY` + `HAVING` | National and county aggregations |
| `CASE WHEN` | Price brackets, property type classification |
| `CTE (WITH clause)` | Q12, Q13, Q14, Q15, Q16 |
| `Window Functions` | `RANK()`, `LAG()`, `SUM() OVER()`, `AVG() OVER()` |
| `DATE_FORMAT`, `YEAR()` | Time-based trend analysis |
| `JOIN` | Joining CTEs for year-over-year analysis |
| `ROUND`, `DECIMAL` | Price precision and formatting |
| `LOAD DATA LOCAL INFILE` | Bulk importing 786k rows into MySQL |

---

## ▶️ How to Run

### Prerequisites
- **MySQL Community Server 8.0+** — https://dev.mysql.com/downloads/mysql/
- **MySQL Workbench** — https://dev.mysql.com/downloads/workbench/

### Setup Steps

**Step 1 — Enable local file import (one-time)**

In MySQL Workbench, edit your connection:
- Right-click connection → Edit Connection → Advanced tab
- In the "Others" box add: `OPT_LOCAL_INFILE=1`
- Reconnect

Then run:
```sql
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile'; -- Should show ON
```

**Step 2 — Run scripts in order**

```
1. 01_Create_Database_&_Table.sql        → Creates database and empty table
2. 02_LOAD_DATA_command.sql              → Update file path, then import 786k rows
3. 03_Data_Cleaning_&_Quality_Checks.sql → Validate data quality
4. 04_Business_Analysis_Queries.sql      → Run individual queries (Ctrl+Enter)
```

**Step 3 — Update the file path in `02_LOAD_DATA_command.sql`**
```sql
-- Change this to your actual file path:
LOAD DATA LOCAL INFILE 'C:/Your/Path/property_price_register_clean.csv'
```

**Step 4 — Verify import**
```sql
SELECT COUNT(*) AS total_rows FROM property_sales;
-- Expected: 785,993
```

> Note: Use `\n` not `\r\n` for LINES TERMINATED BY — the clean CSV uses Linux line endings.

---

## 💡 Key Insights from the Data

- **Dublin** consistently has the highest average property price, often double the national average
- Property prices nationally crashed post-2010 and began recovering from **2013 onwards**
- **New homes** command a significant price premium over second-hand properties
- The majority of national sales fall in the **€200k – €400k** price bracket
- **Cork and Wicklow** are consistently among the top 3 most expensive counties after Dublin
- Sales volumes peaked around **2014–2015** and again in **2021–2022**
- Over **70% of Eircode data is missing** for sales before 2015 — the system launched in 2015

---

## 👤 Author

**Kunal PS**
MSc Data Analytics — Dublin Business School (2026)
QA Automation Engineer | Data Analytics Enthusiast
[GitHub: KunalPS98](https://github.com/KunalPS98)
