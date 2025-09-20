
-- ==========================================================
-- Create a Customer Dimension (gold.dim_customers)
-- Purpose: Standardize and enrich customer data for analytics
-- ==========================================================
CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,     -- Surrogate key for dimension
    ci.cst_id AS customer_id,                               -- Natural customer ID from source
    ci.cst_key AS customer_number,                          -- Business/customer number
    ci.cst_firstname AS first_name,                         -- Customer first name
    ci.cst_lastname AS last_name,                           -- Customer last name
    la.cntry AS country,                                    -- Country from location data
    ci.cst_material_status AS marital_status,               -- Marital status
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr          -- Use CRM gender if available
        ELSE COALESCE(ca.gen, 'n/a')                        -- Otherwise fallback to ERP data
    END AS gender,
    ca.bdate AS birthdate,                                  -- Birthdate from ERP
    ci.cst_create_date AS create_date                       -- Date customer was created
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az101 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid;


-- ==========================================================
-- Create a Product Dimension (gold.dim_products)
-- Purpose: Store descriptive product and category attributes
-- ==========================================================
CREATE VIEW gold.dim_prodcuts AS
SELECT
    ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key, -- Surrogate product key
    pn.prd_id AS product_id,                                               -- Natural product ID
    pn.prd_key AS product_number,                                          -- Product number
    pn.prd_nm AS product_name,                                             -- Product name
    pn.cat_id AS category_id,                                              -- Category ID reference
    pc.cat AS category,                                                    -- Category name
    pc.subcat AS subcategory,                                              -- Subcategory
    pc.maintenance,                                                        -- Maintenance indicator
    pn.prd_cost AS cost,                                                   -- Product cost
    pn.prd_line AS product_line,                                           -- Product line grouping
    pn.prd_start_dt AS start_date                                          -- Start date (active product)
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL;                                                  -- Only include active products


-- ==========================================================
-- Create a Sales Fact (gold.fact_sales)
-- Purpose: Store transactional sales data linked to dimensions
-- ==========================================================
CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num AS order_number,           -- Sales order number (transaction ID)
    pr.product_key,                           -- Link to product dimension
    cu.customer_id,                           -- Link to customer dimension
    sd.sls_order_dt AS order_date,            -- Order date
    sd.sls_ship_dt AS shipping_date,          -- Shipping date
    sd.sls_due_dt AS due_date,                -- Due date
    sd.sls_sales AS sales_amount,             -- Total sales amount
    sd.sls_quantity AS quantity,              -- Quantity sold
    sd.sls_price AS unit_price                -- Unit price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_prodcuts pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;
