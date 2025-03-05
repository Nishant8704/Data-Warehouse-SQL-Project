/*
------------------------------------------------------------------------------
LOADING data of BRONZE LAYER  INTO SILVER LAYER
------------------------------------------------------------------------------
STEP 1 : USE FULL LOAD (TRUNCATE & INSERT)
STEP 2 : Clear the Table each time before loading to silver.
STEP 3 : INSERT THE DATA
STEP 4 : USE error handing(TRY AND CATCH)
STEP 5 : Find total time required to Full load

EXEC silver.load_silver;
*/

Create or alter PROCEDURE silver.load_silver as
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME;
	BEGIN TRY
		PRINT '================================================';
		PRINT '**************LOADING SILVER LAYER**************';
		PRINT '================================================';

		PRINT '++++++++++++++++++++++++++++++++++++++++++++++++';
		PRINT '******************LOADING CRM TABLE*************';
		PRINT '++++++++++++++++++++++++++++++++++++++++++++++++';
		
		SET @start_time = getdate();
		PRINT '>> Truncating Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>> Inserting Data Info: silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date)

		SELECT 
			cst_id,
			cst_key,
			-- Remove unnessary space from the data -- Data inconsistency
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname)AS cst_lastname,
			-- Data Normalization and Standardization
			CASE WHEN TRIM(cst_marital_status) = 'M' THEN 'MARRIED'
				 WHEN trim(cst_marital_status) = 'S' THEN 'SINGLE'
				 ELSE 'n/a' -- handling missing value
			END cst_marital_status,
			CASE WHEN TRIM(cst_gndr)='F' THEN 'FEMALE'
				 WHEN TRIM(cst_gndr)= 'M' THEN 'MALE'
				 ELSE 'n/a'
			END cst_gndr,
			cst_create_date
		FROM (
			SELECT 
			*,
			ROW_NUMBER() OVER (Partition by cst_id ORDER BY cst_create_date DESC) as flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
		)t WHERE flag_last=1 --- removing duplicate or data filtering


		PRINT '>> Truncating Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT '>> Inserting Data Info: silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info(
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT 
			prd_id,
			REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id, -- Extract category ID
			SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,	   -- Extract Product Key
			prd_nm,
			ISNULL (prd_cost,0) as prd_cost,
			Case UPPER(TRIM(prd_line))
				WHEN 'M' Then 'Mountain'
				WHen 'R' THEN 'ROAD'
				when 'S' THEN 'Other Sales'
				WHEN 'T' THEN 'Touring'
				ELSE 'n/a'
			END AS prd_line,      -- Map Product line code to descriptive values
			CAST(prd_start_dt AS DATE) AS prd_start_dt,
			-- Calculate end date as one day before the next start date 
			CAST(
				LEAD(prd_start_dt) Over (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
		FROM bronze.crm_prd_info;


		PRINT '>> Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>> Inserting Data Info: silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details(
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		select 
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		Case WHEN sls_order_dt = 0 OR LEN(sls_order_dt)!=8 THEN NULL
			 ELSE CAST(CAST(sls_order_dt as varchar) AS DATE)
		END AS sls_order_dt, -- Order date in a date format

		Case WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt)!=8 THEN NULL
			 ELSE CAST(CAST(sls_ship_dt as varchar) AS DATE)
		END AS sls_ship_dt,

		Case WHEN sls_due_dt = 0 OR LEN(sls_due_dt)!=8 THEN NULL
			 ELSE CAST(CAST(sls_due_dt as varchar) AS DATE)
		END AS sls_due_dt,

		case when sls_sales IS NULL OR sls_sales<=0 OR sls_sales!=sls_quantity*ABS(sls_price)
			 THEN sls_quantity * ABS(sls_price)
			 ELSE sls_sales
		END sls_sales,
		sls_quantity,

		CASE WHEN sls_price IS NULL OR sls_price<=0
			 THEN sls_sales/NULLIF(sls_quantity,0)
			Else sls_price
		END sls_price
		FROM bronze.crm_sales_details;


		PRINT '+++++++++++++++++++++++++++++++++++++++++++++++++';
		PRINT '******************LOADING ERP TABLE**************';
		PRINT '+++++++++++++++++++++++++++++++++++++++++++++++++';

		PRINT '>> Truncating Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT '>> Inserting Data Info: silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12(
			cid,
			bdate,
			gen
		)
		Select 
			CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,len(cid))
				ELSE cid
			END  as cid,-- remove NAS Prefix

			CASE when bdate>getdate() THEN NULL
				else bdate
			end as bdate,-- set future birthday as NULL

			CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
				 WHEN upper(trim(gen)) IN ('M','MALE') THEN 'Male'
				 Else 'n/a'
			END as gen   -- Nomalize gender value and handle unknown cases
		FROM bronze.erp_cust_az12;


		PRINT '>> Truncating Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT '>> Inserting Data Info: silver.erp_loc_a101';
		INSERT into silver.erp_loc_a101(
			cid,
			cntry
		)
			Select 
			REPLACE(cid,'-','') as cid,
			case when TRIM(cntry) = 'DE' THEN 'Germany'
				 WHEN trim(cntry) IN ('US', 'USA') THEN 'United States'
				 When trim(cntry) = '' OR cntry IS NULL THEN 'n/a'
				 ELSE trim(cntry)
			END as cntry
		from bronze.erp_loc_a101;



		PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT '>> Inserting Data Info: silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2(
			id,
			cat,
			subcat,
			maintenance
		)
		SELECT
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2;

		SET @end_time = GETDATE();
		
		PRINT 'lOAD DURATION OF SILVER: '+CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+' second';
		PRINT '-----------'
	END TRY

	BEGIN CATCH
		PRINT '=============================================';
		PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER';
		PRINT 'ERROR MESSAGE '+ ERROR_MESSAGE();
		PRINT 'TOTAL ERROR NUMBER '+ CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR STATE '+ CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '=============================================';
	END CATCH
END 
