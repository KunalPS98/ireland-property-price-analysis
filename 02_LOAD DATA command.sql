-- ============================================================
-- Ireland Property Price Register Analysis
-- Script 02: Load CSV Data into MySQL
-- Author: Kunal
-- Source: Property Services Regulatory Authority (PSRA)
--         via Kaggle — CC BY 4.0
-- ============================================================

-- ============================================================
-- STEP 1: VERIFY LOCAL INFILE IS ENABLED
-- ============================================================
-- Run this first to confirm local file import is allowed.
-- Value should show 'ON' before proceeding.
-- If OFF: Edit connection → Advanced tab → add OPT_LOCAL_INFILE=1

SHOW VARIABLES LIKE 'local_infile';

-- ============================================================
-- STEP 2: SELECT THE DATABASE
-- ============================================================

USE ireland_property_db;

-- ============================================================
-- STEP 3: LOAD CSV DATA INTO TABLE
-- ============================================================
-- IMPORTANT: Update the file path below to match the location
-- of property_price_register_clean.csv on YOUR computer.
--
-- Windows example:
--   'C:/Users/YourName/Downloads/property_price_register_clean.csv'
--
-- Note: Use forward slashes (/) not backslashes (\) in the path.
-- Note: LINES TERMINATED BY '\n' — clean CSV uses Linux line endings.
-- ============================================================

LOAD DATA LOCAL INFILE 'D:/My Projects/MYSQL - Irish Property Price Register - Sales 2010 - 2026/property_price_register_clean.csv'
INTO TABLE property_sales
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(date_of_sale, address, county, eircode, price_eur, not_full_market_price, vat_exclusive, description, property_size);

-- ============================================================
-- STEP 4: VERIFY IMPORT WAS SUCCESSFUL
-- ============================================================
-- Expected result: 785,993 rows

SELECT COUNT(*) AS total_rows FROM property_sales;