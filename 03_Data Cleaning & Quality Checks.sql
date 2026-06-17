-- ============================================================
-- Ireland Property Price Register Analysis
-- Script 03: Data Cleaning & Quality Checks
-- Author: Kunal
-- ============================================================

USE ireland_property_db;

-- ============================================================
-- SECTION 1: OVERVIEW
-- ============================================================

-- Total records
SELECT COUNT(*) AS total_records FROM property_sales;

-- Date range of the dataset
SELECT
    MIN(date_of_sale) AS earliest_sale,
    MAX(date_of_sale) AS latest_sale
FROM property_sales;

-- All counties in the dataset
SELECT DISTINCT county
FROM property_sales
ORDER BY county;

-- ============================================================
-- SECTION 2: NULL / MISSING VALUE CHECKS
-- ============================================================

SELECT
    SUM(CASE WHEN date_of_sale IS NULL OR date_of_sale = ''  THEN 1 ELSE 0 END) AS null_date,
    SUM(CASE WHEN address      IS NULL OR address = ''       THEN 1 ELSE 0 END) AS null_address,
    SUM(CASE WHEN county       IS NULL OR county = ''        THEN 1 ELSE 0 END) AS null_county,
    SUM(CASE WHEN eircode      IS NULL OR eircode = ''       THEN 1 ELSE 0 END) AS missing_eircode,
    SUM(CASE WHEN price_eur    IS NULL OR price_eur = 0      THEN 1 ELSE 0 END) AS null_or_zero_price,
    SUM(CASE WHEN property_size IS NULL OR property_size = '' THEN 1 ELSE 0 END) AS missing_property_size
FROM property_sales;

-- ============================================================
-- SECTION 3: DATA INTEGRITY CHECKS
-- ============================================================

-- Suspiciously low prices (below €5,000 — likely data errors)
SELECT COUNT(*) AS suspect_low_price
FROM property_sales
WHERE price_eur < 5000;

-- Suspiciously high prices (above €10 million — worth flagging)
SELECT COUNT(*) AS very_high_price
FROM property_sales
WHERE price_eur > 10000000;

-- Check for future dates (data entry errors)
SELECT COUNT(*) AS future_dated_records
FROM property_sales
WHERE date_of_sale > CURDATE();

-- Distribution of property description values
SELECT
    description,
    COUNT(*) AS total
FROM property_sales
GROUP BY description
ORDER BY total DESC;

-- Distribution of property size values
SELECT
    property_size,
    COUNT(*) AS total
FROM property_sales
GROUP BY property_size
ORDER BY total DESC;

-- ============================================================
-- SECTION 4: CLEAN VIEW — EXCLUDE OUTLIERS
-- ============================================================
-- Use this WHERE clause in your analysis queries to filter
-- out data quality issues:
--   WHERE price_eur BETWEEN 10000 AND 10000000
--   AND not_full_market_price = 0

-- Preview clean data
SELECT
    date_of_sale,
    county,
    price_eur,
    description
FROM property_sales
WHERE price_eur BETWEEN 10000 AND 10000000
  AND not_full_market_price = 0
LIMIT 10;

-- Count of clean records vs total
SELECT
    COUNT(*) AS clean_records,
    (SELECT COUNT(*) FROM property_sales) AS total_records
FROM property_sales
WHERE price_eur BETWEEN 10000 AND 10000000
  AND not_full_market_price = 0;
