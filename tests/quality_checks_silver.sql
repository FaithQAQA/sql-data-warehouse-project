/*
================================================================================
Silver Layer Data Quality Checks
================================================================================
Purpose:
    This script validates the data integrity, consistency, and formatting of the 
    Silver layer tables. It is designed to catch potential issues such as:
    - Missing or duplicate primary keys.
    - Leading/trailing spaces in string fields.
    - Incorrect or inconsistent data formats.
    - Invalid date ranges and logical inconsistencies.
    - Mismatches in calculated fields (e.g., sales totals).

Usage:
    Execute after loading the Silver layer. Investigate any discrepancies found 
    and take corrective action in the source or transformation process.
================================================================================
*/

-- ===============================================================
-- Validation for 'silver.crm_cust_info'
-- ===============================================================

-- Ensure primary keys exist and are unique
SELECT 
    cst_id,
    COUNT(*) AS cnt
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Detect unnecessary spaces in key fields
SELECT 
    cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Review distinct values for marital status for consistency
SELECT DISTINCT 
    cst_marital_status
FROM silver.crm_cust_info;

-- ===============================================================
-- Validation for 'silver.crm_prd_info'
-- ===============================================================

-- Check for NULL or duplicated product IDs
SELECT 
    prd_id,
    COUNT(*) AS cnt
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Identify unwanted spaces in product names
SELECT 
    prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Validate product cost values
SELECT 
    prd_cost
FROM silver.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0;

-- Review product line classifications for consistency
SELECT DISTINCT 
    prd_line
FROM silver.crm_prd_info;

-- Ensure start and end dates are logically ordered
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- ===============================================================
-- Validation for 'silver.crm_sales_details'
-- ===============================================================

-- Detect invalid dates in the source data
SELECT 
    NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
   OR LEN(sls_due_dt) != 8 
   OR sls_due_dt < 19000101 
   OR sls_due_dt > 20500101;

-- Ensure order dates precede ship and due dates
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- Confirm sales calculations match quantity * price
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- ===============================================================
-- Validation for 'silver.erp_cust_az12'
-- ===============================================================

-- Identify birthdates outside expected range
SELECT DISTINCT 
    bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' 
   OR bdate > GETDATE();

-- Check gender values for consistency
SELECT DISTINCT 
    gen
FROM silver.erp_cust_az12;

-- ===============================================================
-- Validation for 'silver.erp_loc_a101'
-- ===============================================================

-- List unique country values to confirm standardization
SELECT DISTINCT 
    cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

-- ===============================================================
-- Validation for 'silver.erp_px_cat_g1v2'
-- ===============================================================

-- Detect fields with extra spaces
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat)
   OR maintenance != TRIM(maintenance);

-- Review unique maintenance categories for standardization
SELECT DISTINCT 
    maintenance
FROM silver.erp_px_cat_g1v2;

