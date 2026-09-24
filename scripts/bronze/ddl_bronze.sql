/*
In this part of code, necessary tables are created for bronze schema and ensured their availability with an if-case


*/


IF OBJECT_ID('bronze.crm_cust_info','U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info


CREATE TABLE bronze.crm_cust_info (

cst_id INT,
cst_key NVARCHAR(50),
cst_firstname NVARCHAR(20),
cst_lastname NVARCHAR(40),
cst_marital_status NVARCHAR(10),
cst_gndr NVARCHAR(30),
cst_create_date DATE
);

IF OBJECT_ID('bronze.prd_info','U') IS NOT NULL
	DROP TABLE bronze.prd_info

CREATE TABLE bronze.prd_info (

prd_id INT,
prd_key NVARCHAR(50),
prd_nm NVARCHAR(50),
prd_cost INT,
prd_line NVARCHAR(50),
prd_start DATETIME,
prd_end_date DATETIME
);

IF OBJECT_ID('bronze.crm_sales_details','U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details

CREATE TABLE bronze.crm_sales_details (

sls_order_number VARCHAR(50),
sls_prd_key NVARCHAR(50),
sls_cust_id INT,
sls_order_dt INT,
sls_ship_dt INT,
sls_due_dt INT,
sls_sales INT,
sls_quantity INT,
sls_price INT
);

IF OBJECT_ID('bronze.erp_cust_az12','U') IS NOT NULL
	DROP TABLE bronze.erp_cust_az12

CREATE TABLE bronze.erp_cust_az12 (
	cid VARCHAR(50),
	bdate DATE,
	gen VARCHAR(50)

);

IF OBJECT_ID('bronze.erp_loc_a101','U') IS NOT NULL
	DROP TABLE bronze.erp_loc_a101

CREATE TABLE bronze.erp_loc_a101 (
	cid VARCHAR(50),
	cnrty VARCHAR(50)

);

IF OBJECT_ID('bronze.erp_px_cat_g1v2','U') IS NOT NULL
	DROP TABLE bronze.erp_px_cat_g1v2

CREATE TABLE bronze.erp_px_cat_g1v2 (
	id VARCHAR(50),
	cat VARCHAR(50),
	subcat VARCHAR(50),
	maintenance VARCHAR(50)

);
