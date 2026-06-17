-- ============================================================
-- Ireland Property Price Register Analysis
-- Script 04: Business Analysis Queries
-- Author: Kunal
-- Source: PSRA via Kaggle (CC BY 4.0)
-- ============================================================

USE ireland_property_db;

-- Note: All queries filter out non-full-market-price sales
-- and extreme outliers for accurate analysis.

-- ============================================================
-- SECTION 1: NATIONAL OVERVIEW
-- ============================================================

-- Q1. Total Sales and Revenue by Year (National)
SELECT
    YEAR(date_of_sale)                          AS sale_year,
    COUNT(*)                                    AS total_sales,
    ROUND(AVG(price_eur), 2)                    AS avg_price,
    ROUND(MIN(price_eur), 2)                    AS min_price,
    ROUND(MAX(price_eur), 2)                    AS max_price,
    ROUND(SUM(price_eur) / 1000000, 2)          AS total_value_millions
FROM property_sales
WHERE price_eur BETWEEN 10000 AND 10000000
  AND not_full_market_price = 0
GROUP BY YEAR(date_of_sale)
ORDER BY sale_year;

-- ----------------------------

-- Q2. Monthly Sales Volume Trend (All Years)
SELECT
    DATE_FORMAT(date_of_sale, '%Y-%m')          AS sale_month,
    COUNT(*)                                    AS total_sales,
    ROUND(AVG(price_eur), 2)                    AS avg_price
FROM property_sales
WHERE price_eur BETWEEN 10000 AND 10000000
  AND not_full_market_price = 0
GROUP BY DATE_FORMAT(date_of_sale, '%Y-%m')
ORDER BY sale_month;

-- ----------------------------

-- Q3. National Median Price by Year
-- (Median is more meaningful than average for property prices)
SELECT
    YEAR(date_of_sale)  AS sale_year,
    COUNT(*)            AS total_sales,
    ROUND(AVG(price_eur), 2) AS avg_price,
    -- Approximate median using percentile method
    SUBSTRING_INDEX(
        SUBSTRING_INDEX(
            GROUP_CONCAT(price_eur ORDER BY price_eur SEPARATOR ','),
            ',', CEIL(COUNT(*) / 2)
        ), ',', -1
    ) + 0               AS median_price
FROM property_sales
WHERE price_eur BETWEEN 10000 AND 10000000
  AND not_full_market_price = 0
GROUP BY YEAR(date_of_sale)
ORDER BY sale_year;


-- ============================================================
-- SECTION 2: COUNTY ANALYSIS
-- ============================================================

-- Q4. Average Property Price by County (All Time)
SELECT
    county,
    COUNT(*)                            AS total_sales,
    ROUND(AVG(price_eur), 2)            AS avg_price,
    ROUND(MIN(price_eur), 2)            AS min_price,
    ROUND(MAX(price_eur), 2)            AS max_price
FROM property_sales
WHERE price_eur BETWEEN 10000 AND 10000000
  AND not_full_market_price = 0
GROUP BY county
ORDER BY avg_price DESC;

-- ----------------------------

-- Q5. Top 5 Most Expensive Counties (Last 5 Years)
SELECT
    county,
    COUNT(*)                            AS total_sales,
    ROUND(AVG(price_eur), 2)            AS avg_price
FROM property_sales
WHERE price_eur BETWEEN 10000 AND 10000000
  AND not_full_market_price = 0
  AND YEAR(date_of_sale) >= YEAR(CURDATE()) - 5
GROUP BY county
ORDER BY avg_price DESC
LIMIT 5;

-- ----------------------------

-- Q6. Dublin vs Rest of Ireland — Average Price by Year
SELECT
    YEAR(date_of_sale)                          AS sale_year,
    ROUND(AVG(CASE WHEN county = 'Dublin' THEN price_eur END), 2)   AS dublin_avg,
    ROUND(AVG(CASE WHEN county != 'Dublin' THEN price_eur END), 2)  AS rest_of_ireland_avg,
    ROUND(
        AVG(CASE WHEN county = 'Dublin' THEN price_eur END) -
        AVG(CASE WHEN county != 'Dublin' THEN price_eur END)
    , 2)                                                             AS price_gap
FROM property_sales
WHERE price_eur BETWEEN 10000 AND 10000000
  AND not_full_market_price = 0
GROUP BY YEAR(date_of_sale)
ORDER BY sale_year;

-- ----------------------------

-- Q7. Sales Volume by County — Which County Sells Most?
SELECT
    county,
    COUNT(*)                                            AS total_sales,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct_of_national_sales
FROM property_sales
WHERE price_eur BETWEEN 10000 AND 10000000
  AND not_full_market_price = 0
GROUP BY county
ORDER BY total_sales DESC;


-- ============================================================
-- SECTION 3: NEW VS SECOND-HAND ANALYSIS
-- ============================================================

-- Q8. New vs Second-Hand: Volume and Price Comparison by Year
SELECT
    YEAR(date_of_sale)                                              AS sale_year,
    CASE
        WHEN description LIKE '%New%' THEN 'New'
        ELSE 'Second-Hand'
    END                                                             AS property_type,
    COUNT(*)                                                        AS total_sales,
    ROUND(AVG(price_eur), 2)                                        AS avg_price
FROM property_sales
WHERE price_eur BETWEEN 10000 AND 10000000
  AND not_full_market_price = 0
GROUP BY YEAR(date_of_sale), property_type
ORDER BY sale_year, property_type;

-- ----------------------------

-- Q9. New vs Second-Hand Market Share by County
SELECT
    county,
    SUM(CASE WHEN description LIKE '%New%' THEN 1 ELSE 0 END)          AS new_homes,
    SUM(CASE WHEN description NOT LIKE '%New%' THEN 1 ELSE 0 END)      AS second_hand,
    COUNT(*)                                                            AS total,
    ROUND(SUM(CASE WHEN description LIKE '%New%' THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2)                                        AS new_home_pct
FROM property_sales
WHERE price_eur BETWEEN 10000 AND 10000000
  AND not_full_market_price = 0
GROUP BY county
ORDER BY new_home_pct DESC;


-- ============================================================
-- SECTION 4: PRICE BRACKET ANALYSIS
-- ============================================================

-- Q10. How Many Properties Sold in Each Price Bracket?
SELECT
    CASE
        WHEN price_eur < 100000              THEN 'Under €100k'
        WHEN price_eur BETWEEN 100000 AND 199999 THEN '€100k – €200k'
        WHEN price_eur BETWEEN 200000 AND 299999 THEN '€200k – €300k'
        WHEN price_eur BETWEEN 300000 AND 399999 THEN '€300k – €400k'
        WHEN price_eur BETWEEN 400000 AND 499999 THEN '€400k – €500k'
        WHEN price_eur BETWEEN 500000 AND 999999 THEN '€500k – €1M'
        ELSE 'Over €1M'
    END                                         AS price_bracket,
    COUNT(*)                                    AS total_sales,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct_of_sales
FROM property_sales
WHERE price_eur BETWEEN 10000 AND 10000000
  AND not_full_market_price = 0
GROUP BY price_bracket
ORDER BY MIN(price_eur);

-- ----------------------------

-- Q11. Properties Sold Over €500k by County
SELECT
    county,
    COUNT(*)                                    AS sales_over_500k,
    ROUND(AVG(price_eur), 2)                    AS avg_price
FROM property_sales
WHERE price_eur >= 500000
  AND not_full_market_price = 0
GROUP BY county
ORDER BY sales_over_500k DESC;


-- ============================================================
-- SECTION 5: ADVANCED SQL (Window Functions & CTEs)
-- ============================================================

-- Q12. Year-over-Year Price Growth by County (Window Function)
WITH yearly_county AS (
    SELECT
        county,
        YEAR(date_of_sale)              AS sale_year,
        ROUND(AVG(price_eur), 2)        AS avg_price
    FROM property_sales
    WHERE price_eur BETWEEN 10000 AND 10000000
      AND not_full_market_price = 0
    GROUP BY county, YEAR(date_of_sale)
)
SELECT
    county,
    sale_year,
    avg_price,
    LAG(avg_price) OVER (PARTITION BY county ORDER BY sale_year)    AS prev_year_price,
    ROUND(
        (avg_price - LAG(avg_price) OVER (PARTITION BY county ORDER BY sale_year))
        / LAG(avg_price) OVER (PARTITION BY county ORDER BY sale_year) * 100
    , 2)                                                            AS yoy_growth_pct
FROM yearly_county
ORDER BY county, sale_year;

-- ----------------------------

-- Q13. Rank Counties by Average Price Each Year (Window Function)
WITH county_yearly AS (
    SELECT
        county,
        YEAR(date_of_sale)          AS sale_year,
        ROUND(AVG(price_eur), 2)    AS avg_price
    FROM property_sales
    WHERE price_eur BETWEEN 10000 AND 10000000
      AND not_full_market_price = 0
    GROUP BY county, YEAR(date_of_sale)
)
SELECT
    county,
    sale_year,
    avg_price,
    RANK() OVER (PARTITION BY sale_year ORDER BY avg_price DESC) AS price_rank
FROM county_yearly
ORDER BY sale_year, price_rank;

-- ----------------------------

-- Q14. Running Total of National Property Sales by Year
WITH yearly_sales AS (
    SELECT
        YEAR(date_of_sale)      AS sale_year,
        COUNT(*)                AS total_sales
    FROM property_sales
    WHERE price_eur BETWEEN 10000 AND 10000000
      AND not_full_market_price = 0
    GROUP BY YEAR(date_of_sale)
)
SELECT
    sale_year,
    total_sales,
    SUM(total_sales) OVER (ORDER BY sale_year)  AS running_total_sales
FROM yearly_sales
ORDER BY sale_year;

-- ----------------------------

-- Q15. 3-Year Rolling Average Price — Dublin (Window Function)
WITH dublin_yearly AS (
    SELECT
        YEAR(date_of_sale)          AS sale_year,
        ROUND(AVG(price_eur), 2)    AS avg_price
    FROM property_sales
    WHERE county = 'Dublin'
      AND price_eur BETWEEN 10000 AND 10000000
      AND not_full_market_price = 0
    GROUP BY YEAR(date_of_sale)
)
SELECT
    sale_year,
    avg_price,
    ROUND(AVG(avg_price) OVER (
        ORDER BY sale_year
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2)                           AS rolling_3yr_avg
FROM dublin_yearly
ORDER BY sale_year;

-- ----------------------------

-- Q16. Percentage of Sales Above National Average Price Each Year
WITH yearly_avg AS (
    SELECT
        YEAR(date_of_sale)          AS sale_year,
        AVG(price_eur)              AS national_avg
    FROM property_sales
    WHERE price_eur BETWEEN 10000 AND 10000000
      AND not_full_market_price = 0
    GROUP BY YEAR(date_of_sale)
)
SELECT
    YEAR(ps.date_of_sale)                               AS sale_year,
    COUNT(*)                                            AS total_sales,
    SUM(CASE WHEN ps.price_eur > ya.national_avg THEN 1 ELSE 0 END)    AS above_avg_sales,
    ROUND(SUM(CASE WHEN ps.price_eur > ya.national_avg THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 2)                        AS pct_above_avg
FROM property_sales ps
JOIN yearly_avg ya ON YEAR(ps.date_of_sale) = ya.sale_year
WHERE ps.price_eur BETWEEN 10000 AND 10000000
  AND ps.not_full_market_price = 0
GROUP BY YEAR(ps.date_of_sale)
ORDER BY sale_year;
