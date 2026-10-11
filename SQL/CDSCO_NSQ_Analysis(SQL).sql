-- =====================================================================
-- CDSCO NSQ DRUG QUALITY ANALYSIS (2019-2026)
-- =====================================================================
-- STEP 1: CREATE DATABASE (RUN THIS STATEMENT BY ITSELF)
CREATE DATABASE cdsco_nsq_analysis;

-- =====================================================================
-- SECTION A: CREATE TABLE (run after connecting to cdsco_nsq_analysis)
-- All 23 CSV columns are included. Date fields are TEXT so imported date
-- strings such as DD-MM-YYYY are preserved and can be validated in analysis.
-- =====================================================================

CREATE TABLE IF NOT EXISTS public.cdsco_nsq (
    report_year INTEGER,
    report_month INTEGER,
    report_month_name TEXT,
    reporting_month_year TEXT,
    product_name TEXT,
    product_short_name TEXT,
    batch_no TEXT,
    manufacturing_date TEXT,
    expiry_date TEXT,
    manufactured_by TEXT,
    manufacturer_short_name TEXT,
    nsq_result TEXT,
    nsq_result_short_name TEXT,
    reporting_source TEXT,
    reported_by_lab_or_state TEXT,
    manufacturer_address TEXT,
    manufacturer_city TEXT,
    manufacturer_state TEXT,
    quality_category TEXT,
    category_chemical_content INTEGER,
    category_physical INTEGER,
    category_microbiological INTEGER,
    category_other_identity INTEGER
);


-- =====================================================================
-- SECTION B: VERIFY CSV IMPORT (run after importing the CSV)
-- =====================================================================

SELECT COUNT(*) AS imported_rows
FROM public.cdsco_nsq;

SELECT *
FROM public.cdsco_nsq
LIMIT 10;

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'cdsco_nsq'
ORDER BY ordinal_position;

-- =====================================================================
-- SECTION 1: CHECK TABLE AND COLUMNS
-- =====================================================================

-- 1.1 Confirm the table exists and inspect its columns
SELECT
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'cdsco_nsq'
ORDER BY ordinal_position;

-- 1.2 Preview records
SELECT *
FROM cdsco_nsq
LIMIT 10;

-- 1.3 Total records
SELECT COUNT(*) AS total_nsq_records
FROM cdsco_nsq;

-- 1.4 Count distinct products, batches, manufacturers, and reporting labs/sources
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT NULLIF(TRIM(product_name), '')) AS distinct_product_names,
    COUNT(DISTINCT NULLIF(TRIM(batch_no), '')) AS distinct_batch_numbers,
    COUNT(DISTINCT NULLIF(TRIM(manufactured_by), '')) AS distinct_manufacturers,
    COUNT(DISTINCT NULLIF(TRIM(reported_by_lab_or_state), '')) AS distinct_reporting_labs_or_states
FROM cdsco_nsq;


-- =====================================================================
-- SECTION 2: DATA QUALITY AND VALIDATION
-- =====================================================================

-- 2.1 Missing or blank values in important columns
SELECT
    COUNT(*) FILTER (WHERE product_name IS NULL OR TRIM(product_name) = '') AS missing_product_name,
    COUNT(*) FILTER (WHERE batch_no IS NULL OR TRIM(batch_no) = '') AS missing_batch_no,
    COUNT(*) FILTER (WHERE manufactured_by IS NULL OR TRIM(manufactured_by) = '') AS missing_manufacturer,
    COUNT(*) FILTER (WHERE manufacturer_state IS NULL OR TRIM(manufacturer_state) = '') AS missing_manufacturer_state,
    COUNT(*) FILTER (WHERE nsq_result IS NULL OR TRIM(nsq_result) = '') AS missing_nsq_result,
    COUNT(*) FILTER (WHERE quality_category IS NULL OR TRIM(quality_category) = '') AS missing_quality_category,
    COUNT(*) FILTER (WHERE report_year IS NULL) AS missing_report_year,
    COUNT(*) FILTER (WHERE report_month IS NULL) AS missing_report_month
FROM cdsco_nsq;

-- 2.2 Check blank strings across key text columns
SELECT
    COUNT(*) FILTER (WHERE NULLIF(TRIM(product_name), '') IS NULL) AS blank_product_name,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(product_short_name), '') IS NULL) AS blank_product_short_name,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(batch_no), '') IS NULL) AS blank_batch_no,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(manufactured_by), '') IS NULL) AS blank_manufacturer,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(manufacturer_city), '') IS NULL) AS blank_manufacturer_city,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(manufacturer_state), '') IS NULL) AS blank_manufacturer_state,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(nsq_result), '') IS NULL) AS blank_nsq_result,
    COUNT(*) FILTER (WHERE NULLIF(TRIM(quality_category), '') IS NULL) AS blank_quality_category
FROM cdsco_nsq;

-- 2.3 Duplicate product + batch combinations
-- This flags combinations that appear more than once; review before deleting anything.
SELECT
    product_name,
    batch_no,
    COUNT(*) AS record_count,
    COUNT(DISTINCT manufactured_by) AS manufacturer_count,
    COUNT(DISTINCT reporting_month_year) AS reporting_period_count
FROM cdsco_nsq
GROUP BY product_name, batch_no
HAVING COUNT(*) > 1
ORDER BY record_count DESC, product_name;

-- 2.4 Exact duplicate rows
SELECT
    report_year, report_month, product_name, batch_no, manufactured_by,
    nsq_result, reporting_source, reported_by_lab_or_state,
    COUNT(*) AS duplicate_count
FROM cdsco_nsq
GROUP BY
    report_year, report_month, product_name, batch_no, manufactured_by,
    nsq_result, reporting_source, reported_by_lab_or_state
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- 2.5 Check expected year range
SELECT report_year, COUNT(*) AS record_count
FROM cdsco_nsq
GROUP BY report_year
ORDER BY report_year;

-- 2.6 Check invalid or unexpected month numbers
SELECT report_month, COUNT(*) AS record_count
FROM cdsco_nsq
WHERE report_month IS NULL OR report_month NOT BETWEEN 1 AND 12
GROUP BY report_month
ORDER BY report_month;

-- 2.7 Check quality-category labels
SELECT quality_category, COUNT(*) AS record_count
FROM cdsco_nsq
GROUP BY quality_category
ORDER BY record_count DESC;

-- 2.8 Check that category flags contain only 0/1
SELECT
    COUNT(*) FILTER (WHERE category_chemical_content NOT IN (0,1) OR category_chemical_content IS NULL) AS invalid_chemical_flags,
    COUNT(*) FILTER (WHERE category_physical NOT IN (0,1) OR category_physical IS NULL) AS invalid_physical_flags,
    COUNT(*) FILTER (WHERE category_microbiological NOT IN (0,1) OR category_microbiological IS NULL) AS invalid_microbiological_flags,
    COUNT(*) FILTER (WHERE category_other_identity NOT IN (0,1) OR category_other_identity IS NULL) AS invalid_other_identity_flags
FROM cdsco_nsq;

-- 2.9 Compare quality_category with its flag columns
SELECT
    quality_category,
    COUNT(*) AS records,
    SUM(category_chemical_content) AS chemical_flag_sum,
    SUM(category_physical) AS physical_flag_sum,
    SUM(category_microbiological) AS microbiological_flag_sum,
    SUM(category_other_identity) AS other_identity_flag_sum
FROM cdsco_nsq
GROUP BY quality_category
ORDER BY records DESC;

-- 2.10 Check date text format (expected DD-MM-YYYY)
SELECT
    COUNT(*) FILTER (
        WHERE manufacturing_date IS NOT NULL
          AND TRIM(manufacturing_date) <> ''
          AND TRIM(manufacturing_date) !~ '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
    ) AS manufacturing_date_wrong_format,
    COUNT(*) FILTER (
        WHERE expiry_date IS NOT NULL
          AND TRIM(expiry_date) <> ''
          AND TRIM(expiry_date) !~ '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
    ) AS expiry_date_wrong_format
FROM cdsco_nsq;

-- 2.11 Find records where manufacturing/expiry dates are missing
SELECT
    product_name, batch_no, manufactured_by, manufacturing_date, expiry_date
FROM cdsco_nsq
WHERE manufacturing_date IS NULL OR TRIM(manufacturing_date) = ''
   OR expiry_date IS NULL OR TRIM(expiry_date) = ''
ORDER BY product_name
LIMIT 200;


-- =====================================================================
-- SECTION 3: OVERALL SUMMARY AND TIME TRENDS
-- =====================================================================

-- 3.1 Records by year
SELECT
    report_year,
    COUNT(*) AS nsq_records,
    COUNT(DISTINCT product_name) AS distinct_product_names,
    COUNT(DISTINCT manufactured_by) AS distinct_manufacturers
FROM cdsco_nsq
GROUP BY report_year
ORDER BY report_year;

-- 3.2 Records by year and month
SELECT
    report_year,
    report_month,
    report_month_name,
    COUNT(*) AS nsq_records
FROM cdsco_nsq
GROUP BY report_year, report_month, report_month_name
ORDER BY report_year, report_month;

-- 3.3 Monthly trend across all years
SELECT
    report_month,
    report_month_name,
    COUNT(*) AS nsq_records
FROM cdsco_nsq
GROUP BY report_month, report_month_name
ORDER BY report_month;

-- 3.4 Year-over-year change in record counts
WITH yearly_counts AS (
    SELECT report_year, COUNT(*) AS nsq_records
    FROM cdsco_nsq
    GROUP BY report_year
)
SELECT
    report_year,
    nsq_records,
    LAG(nsq_records) OVER (ORDER BY report_year) AS previous_year_records,
    nsq_records - LAG(nsq_records) OVER (ORDER BY report_year) AS change_in_records,
    ROUND(
        (nsq_records - LAG(nsq_records) OVER (ORDER BY report_year)) * 100.0
        / NULLIF(LAG(nsq_records) OVER (ORDER BY report_year), 0),
        2
    ) AS percentage_change
FROM yearly_counts
ORDER BY report_year;

-- 3.5 Highest-record reporting months
SELECT
    reporting_month_year,
    report_year,
    report_month_name,
    COUNT(*) AS nsq_records
FROM cdsco_nsq
GROUP BY reporting_month_year, report_year, report_month_name
ORDER BY nsq_records DESC
LIMIT 15;


-- =====================================================================
-- SECTION 4: QUALITY CATEGORY ANALYSIS
-- =====================================================================

-- 4.1 Overall records by quality category
SELECT
    quality_category,
    COUNT(*) AS nsq_records,
    ROUND(COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM cdsco_nsq), 0), 2) AS percentage_of_dataset
FROM cdsco_nsq
GROUP BY quality_category
ORDER BY nsq_records DESC;

-- 4.2 Quality category trend by year
SELECT
    report_year,
    quality_category,
    COUNT(*) AS nsq_records
FROM cdsco_nsq
GROUP BY report_year, quality_category
ORDER BY report_year, nsq_records DESC;

-- 4.3 Quality category trend by month
SELECT
    report_year,
    report_month,
    report_month_name,
    quality_category,
    COUNT(*) AS nsq_records
FROM cdsco_nsq
GROUP BY report_year, report_month, report_month_name, quality_category
ORDER BY report_year, report_month, nsq_records DESC;

-- 4.4 Category flags summary
SELECT
    SUM(category_chemical_content) AS chemical_content_records,
    SUM(category_physical) AS physical_records,
    SUM(category_microbiological) AS microbiological_records,
    SUM(category_other_identity) AS other_identity_records,
    COUNT(*) AS total_records
FROM cdsco_nsq;

-- 4.5 Quality categories by reporting source
SELECT
    reporting_source,
    quality_category,
    COUNT(*) AS nsq_records
FROM cdsco_nsq
GROUP BY reporting_source, quality_category
ORDER BY reporting_source, nsq_records DESC;

-- 4.6 Most common detailed NSQ test/result labels
SELECT
    nsq_result_short_name,
    COUNT(*) AS record_count
FROM cdsco_nsq
GROUP BY nsq_result_short_name
ORDER BY record_count DESC
LIMIT 25;

-- 4.7 Detailed NSQ result descriptions by year
SELECT
    report_year,
    nsq_result_short_name,
    COUNT(*) AS record_count
FROM cdsco_nsq
GROUP BY report_year, nsq_result_short_name
ORDER BY report_year, record_count DESC;


-- =====================================================================
-- SECTION 5: PRODUCT ANALYSIS
-- =====================================================================

-- 5.1 Most frequently listed product names
SELECT
    product_name,
    product_short_name,
    COUNT(*) AS nsq_records,
    COUNT(DISTINCT batch_no) AS distinct_batches,
    COUNT(DISTINCT manufactured_by) AS manufacturers
FROM cdsco_nsq
GROUP BY product_name, product_short_name
ORDER BY nsq_records DESC
LIMIT 25;

-- 5.2 Product names appearing in multiple reporting years
SELECT
    product_short_name,
    COUNT(*) AS nsq_records,
    COUNT(DISTINCT report_year) AS years_reported,
    MIN(report_year) AS first_report_year,
    MAX(report_year) AS latest_report_year
FROM cdsco_nsq
GROUP BY product_short_name
HAVING COUNT(DISTINCT report_year) > 1
ORDER BY years_reported DESC, nsq_records DESC
LIMIT 50;

-- 5.3 Products by quality category
SELECT
    product_short_name,
    quality_category,
    COUNT(*) AS nsq_records
FROM cdsco_nsq
GROUP BY product_short_name, quality_category
ORDER BY nsq_records DESC
LIMIT 100;

-- 5.4 Product + batch + manufacturer detail for review
SELECT
    report_year,
    reporting_month_year,
    product_name,
    batch_no,
    manufactured_by,
    nsq_result_short_name,
    quality_category,
    reporting_source,
    reported_by_lab_or_state
FROM cdsco_nsq
ORDER BY report_year DESC, product_name
LIMIT 200;


-- =====================================================================
-- SECTION 6: MANUFACTURER ANALYSIS
-- =====================================================================

-- 6.1 Manufacturers with the most NSQ records
SELECT
    manufactured_by,
    manufacturer_short_name,
    COUNT(*) AS nsq_records,
    COUNT(DISTINCT product_short_name) AS distinct_products,
    COUNT(DISTINCT batch_no) AS distinct_batches,
    COUNT(DISTINCT report_year) AS years_reported
FROM cdsco_nsq
GROUP BY manufactured_by, manufacturer_short_name
ORDER BY nsq_records DESC
LIMIT 25;

-- 6.2 Manufacturer trend by year
SELECT
    manufactured_by,
    report_year,
    COUNT(*) AS nsq_records
FROM cdsco_nsq
GROUP BY manufactured_by, report_year
ORDER BY manufactured_by, report_year;

-- 6.3 Manufacturer by quality category
SELECT
    manufacturer_short_name,
    quality_category,
    COUNT(*) AS nsq_records
FROM cdsco_nsq
GROUP BY manufacturer_short_name, quality_category
ORDER BY nsq_records DESC
LIMIT 100;

-- 6.4 Manufacturers with multiple distinct NSQ result types
SELECT
    manufacturer_short_name,
    COUNT(*) AS nsq_records,
    COUNT(DISTINCT nsq_result_short_name) AS distinct_result_types,
    COUNT(DISTINCT product_short_name) AS distinct_products
FROM cdsco_nsq
GROUP BY manufacturer_short_name
HAVING COUNT(DISTINCT nsq_result_short_name) >= 3
ORDER BY nsq_records DESC
LIMIT 50;

-- 6.5 Manufacturer and state detail
SELECT
    manufacturer_short_name,
    manufacturer_state,
    manufacturer_city,
    COUNT(*) AS nsq_records,
    COUNT(DISTINCT product_short_name) AS distinct_products
FROM cdsco_nsq
GROUP BY manufacturer_short_name, manufacturer_state, manufacturer_city
ORDER BY nsq_records DESC
LIMIT 100;

-- 6.6 Manufacturer ranking by number of NSQ records
WITH manufacturer_counts AS (
    SELECT
        manufacturer_short_name,
        COUNT(*) AS nsq_records
    FROM cdsco_nsq
    GROUP BY manufacturer_short_name
)
SELECT
    manufacturer_short_name,
    nsq_records,
    RANK() OVER (ORDER BY nsq_records DESC) AS record_count_rank
FROM manufacturer_counts
ORDER BY record_count_rank, manufacturer_short_name
LIMIT 50;


-- =====================================================================
-- SECTION 7: STATE AND CITY ANALYSIS
-- =====================================================================

-- 7.1 Manufacturers' state with the most NSQ records
SELECT
    manufacturer_state,
    COUNT(*) AS nsq_records,
    COUNT(DISTINCT manufacturer_short_name) AS distinct_manufacturers,
    COUNT(DISTINCT product_short_name) AS distinct_products,
    COUNT(DISTINCT batch_no) AS distinct_batches
FROM cdsco_nsq
GROUP BY manufacturer_state
ORDER BY nsq_records DESC;

-- 7.2 State trend by year
SELECT
    report_year,
    manufacturer_state,
    COUNT(*) AS nsq_records
FROM cdsco_nsq
GROUP BY report_year, manufacturer_state
ORDER BY report_year, nsq_records DESC;

-- 7.3 Top cities by NSQ record count
SELECT
    manufacturer_state,
    manufacturer_city,
    COUNT(*) AS nsq_records,
    COUNT(DISTINCT manufacturer_short_name) AS distinct_manufacturers
FROM cdsco_nsq
GROUP BY manufacturer_state, manufacturer_city
ORDER BY nsq_records DESC
LIMIT 50;

-- 7.4 State by quality category
SELECT
    manufacturer_state,
    quality_category,
    COUNT(*) AS nsq_records
FROM cdsco_nsq
GROUP BY manufacturer_state, quality_category
ORDER BY manufacturer_state, nsq_records DESC;

-- 7.5 State by reporting source
SELECT
    manufacturer_state,
    reporting_source,
    COUNT(*) AS nsq_records
FROM cdsco_nsq
GROUP BY manufacturer_state, reporting_source
ORDER BY manufacturer_state, nsq_records DESC;

-- 7.6 State ranking by number of records
WITH state_counts AS (
    SELECT manufacturer_state, COUNT(*) AS nsq_records
    FROM cdsco_nsq
    GROUP BY manufacturer_state
)
SELECT
    manufacturer_state,
    nsq_records,
    DENSE_RANK() OVER (ORDER BY nsq_records DESC) AS state_rank
FROM state_counts
ORDER BY state_rank, manufacturer_state;


-- =====================================================================
-- SECTION 8: REPORTING SOURCE AND LAB ANALYSIS
-- =====================================================================

-- 8.1 Records by reporting source
SELECT
    reporting_source,
    COUNT(*) AS nsq_records,
    COUNT(DISTINCT reported_by_lab_or_state) AS distinct_reporting_entities
FROM cdsco_nsq
GROUP BY reporting_source
ORDER BY nsq_records DESC;

-- 8.2 Reporting labs/states with most records
SELECT
    reporting_source,
    reported_by_lab_or_state,
    COUNT(*) AS nsq_records,
    COUNT(DISTINCT product_short_name) AS distinct_products,
    COUNT(DISTINCT manufacturer_short_name) AS distinct_manufacturers
FROM cdsco_nsq
GROUP BY reporting_source, reported_by_lab_or_state
ORDER BY nsq_records DESC
LIMIT 50;

-- 8.3 Lab/source trend by year
SELECT
    report_year,
    reporting_source,
    COUNT(*) AS nsq_records
FROM cdsco_nsq
GROUP BY report_year, reporting_source
ORDER BY report_year, reporting_source;

-- 8.4 NSQ quality category by reporting lab/state
SELECT
    reported_by_lab_or_state,
    quality_category,
    COUNT(*) AS nsq_records
FROM cdsco_nsq
GROUP BY reported_by_lab_or_state, quality_category
ORDER BY nsq_records DESC
LIMIT 100;


-- =====================================================================
-- SECTION 9: BATCH AND DATE REVIEW
-- =====================================================================

-- 9.1 Batches appearing more than once
SELECT
    batch_no,
    COUNT(*) AS record_count,
    COUNT(DISTINCT product_short_name) AS product_count,
    COUNT(DISTINCT manufacturer_short_name) AS manufacturer_count
FROM cdsco_nsq
WHERE batch_no IS NOT NULL AND TRIM(batch_no) <> ''
GROUP BY batch_no
HAVING COUNT(*) > 1
ORDER BY record_count DESC
LIMIT 100;

-- 9.2 Records with manufacturing date later than expiry date.
-- This uses strict DD-MM-YYYY conversion; run only after checking Section 2.10
-- reports zero wrong-format dates and confirming date values are valid.
SELECT
    product_name, batch_no, manufacturing_date, expiry_date, manufactured_by
FROM cdsco_nsq
WHERE manufacturing_date ~ '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
  AND expiry_date ~ '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
  AND TO_DATE(manufacturing_date, 'DD-MM-YYYY') > TO_DATE(expiry_date, 'DD-MM-YYYY')
ORDER BY product_name;

-- 9.3 Date span covered by the dataset (based on report month/year fields)
SELECT
    MIN(report_year) AS first_report_year,
    MAX(report_year) AS latest_report_year,
    MIN(report_month) AS earliest_month_number,
    MAX(report_month) AS latest_month_number,
    COUNT(DISTINCT reporting_month_year) AS distinct_reporting_months
FROM cdsco_nsq;


-- =====================================================================
-- SECTION 10: BUSINESS-FOCUSED SUMMARIES
-- =====================================================================

-- 10.1 Executive summary
SELECT
    COUNT(*) AS total_nsq_records,
    COUNT(DISTINCT product_short_name) AS distinct_products,
    COUNT(DISTINCT batch_no) AS distinct_batches,
    COUNT(DISTINCT manufacturer_short_name) AS distinct_manufacturers,
    COUNT(DISTINCT manufacturer_state) AS manufacturer_states,
    COUNT(DISTINCT reported_by_lab_or_state) AS reporting_entities,
    MIN(report_year) AS first_year,
    MAX(report_year) AS latest_year
FROM cdsco_nsq;

-- 10.2 Top 10 manufacturer states by records
SELECT
    manufacturer_state,
    COUNT(*) AS nsq_records,
    ROUND(COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM cdsco_nsq), 0), 2) AS share_of_dataset_pct
FROM cdsco_nsq
GROUP BY manufacturer_state
ORDER BY nsq_records DESC
LIMIT 10;

-- 10.3 Top 10 manufacturers by records
SELECT
    manufacturer_short_name,
    COUNT(*) AS nsq_records,
    ROUND(COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM cdsco_nsq), 0), 2) AS share_of_dataset_pct
FROM cdsco_nsq
GROUP BY manufacturer_short_name
ORDER BY nsq_records DESC
LIMIT 10;

-- 10.4 Top 10 detailed NSQ results
SELECT
    nsq_result_short_name,
    COUNT(*) AS nsq_records,
    ROUND(COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM cdsco_nsq), 0), 2) AS share_of_dataset_pct
FROM cdsco_nsq
GROUP BY nsq_result_short_name
ORDER BY nsq_records DESC
LIMIT 10;

-- 10.5 Highest-record year/category combinations
SELECT
    report_year,
    quality_category,
    COUNT(*) AS nsq_records
FROM cdsco_nsq
GROUP BY report_year, quality_category
ORDER BY nsq_records DESC
LIMIT 20;

-- 10.6 Records needing data-cleaning review
SELECT
    product_name,
    batch_no,
    manufactured_by,
    manufacturer_city,
    manufacturer_state,
    quality_category,
    report_year
FROM cdsco_nsq
WHERE product_name IS NULL OR TRIM(product_name) = ''
   OR batch_no IS NULL OR TRIM(batch_no) = ''
   OR manufactured_by IS NULL OR TRIM(manufactured_by) = ''
   OR manufacturer_state IS NULL OR TRIM(manufacturer_state) = ''
   OR quality_category IS NULL OR TRIM(quality_category) = ''
ORDER BY report_year, product_name
LIMIT 500;


-- =====================================================================
-- SECTION 11: OPTIONAL CLEANING VIEW
-- =====================================================================
-- Creates a reusable view with trimmed text values. This does not modify
-- the source table. Run this after confirming the table/column names.
-- It retains all rows so cleaning decisions can be reviewed transparently.

CREATE OR REPLACE VIEW cdsco_nsq_cleaned AS
SELECT
    report_year,
    report_month,
    NULLIF(TRIM(report_month_name), '') AS report_month_name,
    NULLIF(TRIM(reporting_month_year), '') AS reporting_month_year,
    NULLIF(TRIM(product_name), '') AS product_name,
    NULLIF(TRIM(product_short_name), '') AS product_short_name,
    NULLIF(TRIM(batch_no), '') AS batch_no,
    NULLIF(TRIM(manufacturing_date), '') AS manufacturing_date,
    NULLIF(TRIM(expiry_date), '') AS expiry_date,
    NULLIF(TRIM(manufactured_by), '') AS manufactured_by,
    NULLIF(TRIM(manufacturer_short_name), '') AS manufacturer_short_name,
    NULLIF(TRIM(nsq_result), '') AS nsq_result,
    NULLIF(TRIM(nsq_result_short_name), '') AS nsq_result_short_name,
    NULLIF(TRIM(reporting_source), '') AS reporting_source,
    NULLIF(TRIM(reported_by_lab_or_state), '') AS reported_by_lab_or_state,
    NULLIF(TRIM(manufacturer_address), '') AS manufacturer_address,
    NULLIF(TRIM(manufacturer_city), '') AS manufacturer_city,
    NULLIF(TRIM(manufacturer_state), '') AS manufacturer_state,
    NULLIF(TRIM(quality_category), '') AS quality_category,
    category_chemical_content,
    category_physical,
    category_microbiological,
    category_other_identity
FROM cdsco_nsq;

-- Preview the cleaned view
SELECT *
FROM cdsco_nsq_cleaned
LIMIT 20;


-- =====================================================================
-- SECTION 12: OPTIONAL EXPORT-READY RESULT EXAMPLES
-- =====================================================================
-- Run a query, then in pgAdmin's Data Output grid use Save Results to File
-- to export its result as CSV for Power BI or Excel.

-- 12.1 Annual category summary
SELECT
    report_year,
    quality_category,
    COUNT(*) AS nsq_records
FROM cdsco_nsq_cleaned
GROUP BY report_year, quality_category
ORDER BY report_year, nsq_records DESC;

-- 12.2 State/category summary
SELECT
    manufacturer_state,
    quality_category,
    COUNT(*) AS nsq_records
FROM cdsco_nsq_cleaned
GROUP BY manufacturer_state, quality_category
ORDER BY manufacturer_state, nsq_records DESC;

-- 12.3 Manufacturer summary
SELECT
    manufacturer_short_name,
    COUNT(*) AS nsq_records,
    COUNT(DISTINCT product_short_name) AS distinct_products,
    COUNT(DISTINCT batch_no) AS distinct_batches,
    COUNT(DISTINCT report_year) AS years_reported
FROM cdsco_nsq_cleaned
GROUP BY manufacturer_short_name
ORDER BY nsq_records DESC;

-- =====================================================================
-- END OF CDSCO NSQ ANALYSIS
-- =====================================================================
