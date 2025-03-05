/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================
-----customer VIEW 
IF OBJECT_ID('gold.dim_customers','V') IS NOT NULL
	DROP VIEW gold.dim_customers
Create VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() Over(order by cst_id) as customer_key,
	ci.cst_id as Customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as first_name,
	ci.cst_lastname as last_name,
	la.cntry as country,
	ci.cst_marital_status as martial_status,
	Case when ci.cst_gndr !='n/a' THEN ci.cst_gndr    --CRM is master
		 ELSE COALESCE(ca.gen,'n/a')
	End as gender, -- Integration the gender
	ca.bdate as birthdate,
	ci.cst_create_date as create_date
from silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 ca
ON		ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON	ci.cst_key = la.cid;

-- Product Table View
IF OBJECT_ID('gold.dim_products','V') IS NOT NULL
	DROP VIEW gold.dim_products
CREATE VIEW gold.dim_products AS
SELECT 
	ROW_NUMBER() over(order by pn.prd_start_dt,pn.prd_key) AS product_key, 
	pn.prd_id as product_id,
	pn.prd_key as product_number,
	pn.prd_nm as product_name,

	pn.cat_id as category_id,
	pc.cat as category,
	pc.subcat as subcategory,

	pc.maintenance,

	pn.prd_cost as cost,
	pn.prd_line as product_line,
	pn.prd_start_dt as start_date
from silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
where prd_end_dt IS NULL   --- filter out all historical data


-- FACT TABLE 
IF OBJECT_ID('gold.fact_sales','V') IS NOT NULL
	DROP VIEW gold.fact_sales
CREATE VIEW gold.fact_sales AS
SELECT 
	sd.sls_ord_num as order_number,
	pr.product_key,
	Cu.customer_key,
	sd.sls_order_dt as order_date,
	sd.sls_ship_dt as shipping_date,
	sd.sls_due_dt as due_date,
	sd.sls_sales as sales_amount,
	sd.sls_quantity as quantity,
	sd.sls_price as price
FROM silver.crm_sales_details as sd
left join gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id;
