/*
=======================================================================
BRONZE LOAD Script: FULL LOAD Procedure
=======================================================================
1. Here we load data using BULK INSERT From local file in table
2. Due to there frequent use, convert the script into STORED PROCEDURE
3. TRUNCATE --- To avoid the Duplicacy in the data.
   BULK INSERT ---- Insert the updated data again.
4. Using **TRY** and *CATCH** To avoid the Error during the loading.
5. Calculating the Loading time.
======================================================================

Caution: This Stored Procedure does not accept any parameter or return
        any value..
Usage Example:
    EXEC bronze.load_bronze;
========================================================================
*/


CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME;

	BEGIN TRY
		PRINT '=========================================='
		PRINT 'Loading Bronze Layer'
		PRINT '=========================================='


		PRINT '------------------------------------------'
		PRINT 'Loading CRM Table'
		PRINT '------------------------------------------'

		set @start_time = GETDATE();
		PRINT '>> Truncating table :bronze.crm_cust_info'
		TRUNCATE TABLE  bronze.crm_cust_info;
		PRINT '>> Insert into:bronze.crm_cust_info'
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\nisha\Desktop\Data Warehouse project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		PRINT '>> Truncating Table: bronze.crm_prd_info'
		TRUNCATE TABLE  bronze.crm_prd_info;

		PRINT '>> Insert into: bronze.crm_prd_info'
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\nisha\Desktop\Data Warehouse project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		PRINT '>> Truncate Table: bronze.crm_sales_details'
		TRUNCATE TABLE  bronze.crm_sales_details;

		PRINT '>> Insert into: bronze.crm_sales_details'
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\nisha\Desktop\Data Warehouse project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		PRINT '------------------------------------------'
		PRINT 'Loading CRM Table'
		PRINT '------------------------------------------'

		PRINT '>> Truncating table : bronze.erp_cust_az12 '
		TRUNCATE TABLE  bronze.erp_cust_az12;

		PRINT '>> Insert into : bronze.erp_cust_az12'
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\nisha\Desktop\Data Warehouse project\datasets\source_erp\cust_az12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		PRINT '>> Truncating table : bronze.erp_loc_a101'
		TRUNCATE TABLE  bronze.erp_loc_a101;

		Print '>> Insert into: bronze.erp_loc_a101'
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\nisha\Desktop\Data Warehouse project\datasets\source_erp\loc_a101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		Print '>> Truncating table: bronze.erp_px_cat_g1v2'
		TRUNCATE TABLE  bronze.erp_px_cat_g1v2;

		Print '>> Insert into: bronze.erp_px_cat_g1v2'
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\nisha\Desktop\Data Warehouse project\datasets\source_erp\px_cat_g1v2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();

		PRINT 'LOAD DURATION OF BRONZE: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) +'second';
		PRINT '---------'
	END TRY

	BEGIN CATCH 
		PRINT '=================================================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'ERROR MESSAGE '+ ERROR_MESSAGE();
		PRINT 'TOTAL ERROR NUMBER '+ CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR STATE '+ CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '==================================================================='
	END CATCH
END;
