/*
-------------------------------------------------
Creating the **DDL - DATA DEFINATION LANGUAGE**
-------------------------------------------------
STEP 1 :  Check the database whether the table exist of not
STEP 2 :  If exist Drop and then Insert
*/

IF object_ID ('silver.crm_cust_info','u') IS NOT NULL
	DROP TABLE silver.crm_cust_info;

Create Table silver.crm_cust_info(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname Nvarchar(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr Nvarchar(50),
	cst_create_date DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF object_ID ('silver.crm_prd_info','u') IS NOT NULL
	DROP TABLE silver.crm_prd_info;
Create table silver.crm_prd_info (
	prd_id	INT,
	prd_key	Nvarchar(50),
	prd_nm	Nvarchar(50),
	prd_cost	INT,
	prd_line	Nvarchar(50),
	prd_start_dt	DATETIME,
	prd_end_dt		DATETIME,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);


IF object_ID ('silver.crm_sales_details','u') IS NOT NULL
	DROP TABLE silver.crm_sales_details;
Create Table silver.crm_sales_details(
	sls_ord_num	Nvarchar(50),
	sls_prd_key Nvarchar(50),
	sls_cust_id int,
	sls_order_dt int,
	sls_ship_dt int,
	sls_due_dt int,
	sls_sales int,
	sls_quantity int,
	sls_price int,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);


IF object_ID ('silver.erp_loc_a101','u') IS NOT NULL
	DROP TABLE silver.erp_loc_a101;
Create table silver.erp_loc_a101(
	cid		NVARCHAR(50),
	cntry	NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);


IF object_ID ('silver.erp_cust_az12','u') IS NOT NULL
	DROP TABLE silver.erp_cust_az12;
Create table silver.erp_cust_az12(
	cid		nvarchar(50),
	bdate	date,
	gen		nvarchar(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);


IF object_ID ('silver.erp_px_cat_g1v2','u') IS NOT NULL
	DROP TABLE silver.erp_px_cat_g1v2;
Create table silver.erp_px_cat_g1v2(
	id			nvarchar(50),
	cat			nvarchar(50),
	subcat		nvarchar(50),
	maintenance	nvarchar(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
