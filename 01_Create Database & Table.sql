-- ============================================================
-- Ireland Property Price Register Analysis
-- Script 01: Create Database & Table
-- Author: Kunal
-- Source: Property Services Regulatory Authority (PSRA)
--         via Kaggle — CC BY 4.0
-- ============================================================

CREATE DATABASE IF NOT EXISTS ireland_property_db;
USE ireland_property_db;

DROP TABLE IF EXISTS property_sales;

CREATE TABLE property_sales (
    id                      INT AUTO_INCREMENT PRIMARY KEY,
    date_of_sale            DATE,
    address                 VARCHAR(500),
    county                  VARCHAR(100),
    eircode                 VARCHAR(20),
    price_eur               DECIMAL(15, 2),
    not_full_market_price   TINYINT(1),   -- 0 = Full market price, 1 = Not full market
    vat_exclusive           TINYINT(1),   -- 0 = VAT inclusive, 1 = VAT exclusive
    description             VARCHAR(255), -- New or Second-Hand
    property_size           VARCHAR(255)
);

