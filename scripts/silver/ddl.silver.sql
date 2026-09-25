/*
=======================
CREATE SILVER TABLES

This script creates tables in the "Silver" schema, and dropping the existing ones if they already exist.

=======================
*/
IF OBJECT_ID('silver.crm_cust_info','U') IS NOT NULL
	DROP TABLE silver.crm_cust_info


CREATE TABLE silver.crm_cust_info (

cst_id INT,
cst_key NVARCHAR(50),
cst_firstname NVARCHAR(20),
cst_lastname NVARCHAR(40),
cst_marital_status NVARCHAR(10),
cst_gndr NVARCHAR(30),
cst_create_date DATE,
dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.crm_prd_info','U') IS NOT NULL
	DROP TABLE silver.crm_prd_info

CREATE TABLE silver.crm_prd_info (

prd_id INT,
cat_id NVARCHAR(50),
prd_key NVARCHAR(50),
prd_nm NVARCHAR(50),
prd_cost INT,
prd_line NVARCHAR(50),
prd_start DATE,
prd_end_date DATE,
dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.crm_sales_details','U') IS NOT NULL
	DROP TABLE silver.crm_sales_details

CREATE TABLE silver.crm_sales_details (

sls_order_number VARCHAR(50),
sls_prd_key NVARCHAR(50),
sls_cust_id INT,
sls_order_dt DATE,
sls_ship_dt DATE,
sls_due_dt DATE,
sls_sales INT,
sls_quantity INT,
sls_price INT,
dwh_create_date DATETIME2 DEFAULT GETDATE()	
);

IF OBJECT_ID('silver.erp_cust_az12','U') IS NOT NULL
	DROP TABLE silver.erp_cust_az12

CREATE TABLE silver.erp_cust_az12 (
	cid VARCHAR(50),
	bdate DATE,
	gen VARCHAR(50),
dwh_create_date DATETIME2 DEFAULT GETDATE()

);

IF OBJECT_ID('silver.erp_loc_a101','U') IS NOT NULL
	DROP TABLE silver.erp_loc_a101

CREATE TABLE silver.erp_loc_a101 (
	cid VARCHAR(50),
	cnrty VARCHAR(50),
dwh_create_date DATETIME2 DEFAULT GETDATE()

);

IF OBJECT_ID('silver.erp_px_cat_g1v2','U') IS NOT NULL
	DROP TABLE silver.erp_px_cat_g1v2

CREATE TABLE silver.erp_px_cat_g1v2 (
	id VARCHAR(50),
	cat VARCHAR(50),
	subcat VARCHAR(50),
	maintenance VARCHAR(50),
dwh_create_date DATETIME2 DEFAULT GETDATE()

);
