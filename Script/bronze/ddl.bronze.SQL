/*
=============================================================================
DDL Script : Create bronze table
=============================================================================
Script purpose: 
    This Script create table in the 'bronze' schema, droping existing table
    If this already exist run the drop statement.
=============================================================================
*/

-- Drop the table
if OBJECT_ID ('bronze.erp_pz_cat_g1v2' , 'U') IS NOT NULL
	DROP Table bronze.erp_pz_cat_g1v2

GO
Create Table bronze.crm_cust_info(
cst_id INT,
cst_key NVARCHAR(50),
cst_firstname NVARCHAR(50),
cst_lastname Nvarchar(50),
cst_marital_status NVARCHAR(50),
cst_gndr Nvarchar(50),
cst_create_date DATE
);

GO

Create table bronze.crm_prd_info (
	prd_id	INT,
	prd_key	Nvarchar(50),
	prd_nm	Nvarchar(50),
	prd_cost	INT,
	prd_line	Nvarchar(50),
	prd_start_dt	DATETIME,
	prd_end_dt		DATETIME
);
GO
Create Table bronze.crm_sales_details(
	sls_ord_num	Nvarchar(50),
	sls_prd_key Nvarchar(50),
	sls_cust_id int,
	sls_order_dt int,
	sls_ship_dt int,
	sls_due_dt int,
	sls_sales int,
	sls_quantity int,
	sls_price int
);
Go
Create table bronze.erp_loc_a101(
	cid		NVARCHAR(50),
	cntry	NVARCHAR(50)
);
GO
Create table bronze.erp_cust_az12(
	cid		nvarchar(50),
	bdate	date,
	gen		nvarchar(50)
);
Go
Create table bronze.erp_pz_cat_g1v2(
	id			nvarchar(50),
	cat			nvarchar(50),
	subcat		nvarchar(50),
	maintenance	nvarchar(50)
);




