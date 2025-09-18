/*
===================================================================================
DDL: Script : Create Bronze Tables
===================================================================================
Script Purpose:
      This script creates tables in the 'bronze' schema, dropping existing tables 
      if they already exist.
      Run this script to re-define the DDL structure of 'bronze' Tables
===================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @bronze_start DATETIME, @bronze_end DATETIME;
    DECLARE @start_time DATETIME, @end_time DATETIME;

    BEGIN TRY
        SET @bronze_start = GETDATE(); -- start of full bronze load

        PRINT '======================================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '======================================================================';

        PRINT '---------------------------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '---------------------------------------------------------------------';

        ---------------- CRM.CUST_INFO ----------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table:[bronze].[crm_cust_info]';
        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>> Inserting Data Into Table:[bronze].[crm_cust_info]';
        BULK INSERT bronze.crm_cust_info
        FROM 'K:\sql-ultimate-course\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH ( FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';


        ---------------- CRM.PRD_INFO ----------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table:[bronze].[crm_prd_info]';
        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>> Inserting Data Into Table:[bronze].[crm_prd_info]';
        BULK INSERT bronze.crm_prd_info
        FROM 'K:\sql-ultimate-course\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH ( FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';


        ---------------- CRM.SALES_DETAILS ----------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table:[bronze].[crm_sales_details]';
        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>> Inserting Data Into Table:[bronze].[crm_sales_details]';
        BULK INSERT bronze.crm_sales_details
        FROM 'K:\sql-ultimate-course\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH ( FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';


        PRINT '---------------------------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '---------------------------------------------------------------------';

        ---------------- ERP.CUST_AZ101 ----------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table:[bronze].[erp_cust_az101]';
        TRUNCATE TABLE bronze.erp_cust_az101;

        PRINT '>> Inserting Data Into Table:[bronze].[erp_cust_az101]';
        BULK INSERT bronze.erp_cust_az101
        FROM 'K:\sql-ultimate-course\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH ( FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';


        ---------------- ERP.LOC_A101 ----------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table:[bronze].[erp_loc_a101]';
        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>> Inserting Data Into Table:[bronze].[erp_loc_a101]';
        BULK INSERT bronze.erp_loc_a101
        FROM 'K:\sql-ultimate-course\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH ( FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';


        ---------------- ERP.PX_CAT_G1V2 ----------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table:[bronze].[erp_px_cat_g1v2]';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>> Inserting Data Into Table:[bronze].[erp_px_cat_g1v2]';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'K:\sql-ultimate-course\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH ( FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';


        -- Final Bronze Layer Duration
        SET @bronze_end = GETDATE();
        PRINT '======================================================================';
        PRINT '>> Load Duration of Whole Bronze Layer: ' 
              + CAST(DATEDIFF(second, @bronze_start, @bronze_end) AS NVARCHAR) + ' seconds';
        PRINT '======================================================================';

    END TRY
    BEGIN CATCH
        PRINT '========================================';
        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
        PRINT 'ERROR Message: ' + ERROR_MESSAGE();
        PRINT '========================================';
    END CATCH
END
