/*
=====================
Procedure: Load Silver layer ( Bronze -> Silver )
=====================

The purpose of the script is to perform ETL process to populate the "Silver" schema tables from "Bronze" schema.
Parameters: None

Exp for usage: EXEC silver.load_silver

=====================
*/
CREATE OR ALTER PROCEDURE silver.load_silver AS 
BEGIN
	DECLARE @begin_time DATETIME, @end_time DATETIME, @batch_begin_time DATETIME, @batch_end_time DATETIME
	BEGIN TRY
	SET @batch_begin_time = GETDATE();
	PRINT '================='
	PRINT 'Load Silver Layer'
	PRINT '================='


	SET @begin_time = GETDATE();
	TRUNCATE TABLE silver.crm_cust_info
	INSERT INTO silver.crm_cust_info (
	cst_id ,
	cst_key ,
	cst_firstname ,
	cst_lastname ,
	cst_marital_status ,
	cst_gndr ,
	cst_create_date 
	)

	SELECT 
		cst_id,
		cst_key,

		---Correct unnesessary spaces

		TRIM(cst_firstname),
		TRIM(cst_lastname),

		--- Maintain F & M & S words >> Data Normalization

		CASE 
			WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male' 
			WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
			ELSE 'Unknown' END cst_gndr,

		CASE 
			WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single' 
			WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
			ELSE 'Unknown' END cst_marital_status,
		
	cst_create_date

	--- Check if there any NULLs or Duplicates in Primary Key		

	FROM (
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) rownum
	FROM bronze.crm_cust_info WHERE cst_id IS NOT NULL )t
	WHERE rownum = 1
	SET @end_time = GETDATE();
	PRINT 'Load duration: ' + CAST(DATEDIFF(SECOND,@begin_time, @end_time) AS VARCHAR(50)) + 'seconds'

	SET @begin_time = GETDATE();
	TRUNCATE TABLE silver.crm_prd_info
	INSERT INTO silver.crm_prd_info (
	prd_id ,
	cat_id ,
	prd_key ,
	prd_nm ,
	prd_cost ,
	prd_line ,
	prd_start ,
	prd_end_date 

	)


	SELECT 
		prd_id,
	
		REPLACE(SUBSTRING(prd_key,1,5),'-','_') cat_id,
		SUBSTRING(prd_key,7,LEN(prd_key)) prd_key,
		prd_nm,
		COALESCE(prd_cost,0) prd_cost,
	
		CASE UPPER(TRIM(prd_line)) 
			 WHEN 'T' THEN 'Touring'
			 WHEN 'S' THEN 'other Sales'
			 WHEN 'M' THEN 'Mountain'
			 WHEN 'R' THEN 'Road'
			 ELSE 'Unknown' END prd_line,

		CAST(prd_start AS DATE)prd_start,
		CAST(LEAD(prd_start) OVER(PARTITION BY prd_key ORDER BY prd_start)-1 AS DATE)  prd_end_date
	FROM bronze.crm_prd_info
	SET @end_time = GETDATE();
	PRINT 'Load duration: ' + CAST(DATEDIFF(SECOND,@begin_time, @end_time) AS VARCHAR(50)) + 'seconds'

	SET @begin_time = GETDATE();
	TRUNCATE TABLE silver.crm_sales_details
	INSERT INTO silver.crm_sales_details(
	sls_order_number ,
	sls_prd_key ,
	sls_cust_id ,
	sls_order_dt ,
	sls_ship_dt ,
	sls_due_dt ,
	sls_sales ,
	sls_quantity ,
	sls_price
	)
	SELECT 
	sls_order_number,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN LEN(sls_order_dt) != 8 THEN NULL 
		ELSE CAST(CAST(sls_order_dt AS VARCHAR(50)) AS DATE) END sls_order_dt,

	CASE WHEN LEN(sls_ship_dt) != 8 THEN NULL 
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR(50)) AS DATE) END sls_ship_dt,

	CASE WHEN LEN(sls_due_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR(50)) AS DATE) END sls_due_dt,

	CASE WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price)  THEN ABS(sls_price*sls_quantity)
		ELSE sls_sales END sls_sales,
	sls_quantity,
	CASE WHEN sls_price < 0 THEN ABS(sls_price) 
		 WHEN  sls_price = 0 OR sls_price IS NULL THEN ABS(sls_sales/NULLIF(sls_quantity,0))
		 ELSE sls_price END sls_price

	FROM bronze.crm_sales_details

	SET @end_time = GETDATE();
	PRINT 'Load duration: ' + CAST(DATEDIFF(SECOND,@begin_time, @end_time) AS VARCHAR(50)) + 'seconds'

	SET @begin_time = GETDATE();
	TRUNCATE TABLE silver.erp_cust_az12
	INSERT INTO silver.erp_cust_az12 (
	cid,
	bdate,
	gen
	)

	SELECT 
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid)) 
		ELSE cid END cid,
	CASE WHEN bdate < '1926-01-01' OR bdate > GETDATE() THEN NULL 
		ELSE bdate END bdate,

	CASE WHEN UPPER(gen) = 'F' THEN 'Female'
		 WHEN UPPER(gen) = 'M' THEN 'Male'
		 WHEN gen = '' OR gen IS NULL THEN 'Unknown' 
		 ELSE gen END gen


	FROM bronze.erp_cust_az12

	SET @end_time = GETDATE();
	PRINT 'Load duration: ' + CAST(DATEDIFF(SECOND,@begin_time, @end_time) AS VARCHAR(50)) + 'seconds'

	SET @begin_time = GETDATE();
	TRUNCATE TABLE silver.erp_loc_a101
	INSERT INTO silver.erp_loc_a101 (
	cid,
	cnrty

	)

	SELECT  REPLACE(cid,'-','')cid,
	CASE WHEN TRIM(cnrty) IN ('US','USA') THEN 'United States'
		 WHEN TRIM(cnrty) = 'DE' THEN 'Germany'
		 WHEN TRIM(cnrty) = '' THEN NULL
		 ELSE TRIM(cnrty) END cnrty


	 FROM [bronze].[erp_loc_a101]

	 SET @end_time = GETDATE();
	PRINT 'Load duration: ' + CAST(DATEDIFF(SECOND,@begin_time, @end_time) AS VARCHAR(50)) + 'seconds'
	
	SET @begin_time = GETDATE();
	TRUNCATE TABLE silver.erp_px_cat_g1v2
	INSERT INTO silver.erp_px_cat_g1v2(
	id,
	cat,
	subcat,
	maintenance
	)

	SELECT 
	id,
	TRIM(cat)cat, 
	TRIM(subcat)subcat,
	TRIM(maintenance)maintenance

	FROM [bronze].[erp_px_cat_g1v2]

	SET @end_time = GETDATE();
	PRINT 'Load duration: ' + CAST(DATEDIFF(SECOND,@begin_time, @end_time) AS VARCHAR(50)) + 'seconds'
	SET @end_time = GETDATE();
	PRINT 'All layers load duration: ' + CAST(DATEDIFF(SECOND,@batch_begin_time, @batch_end_time) AS VARCHAR(50)) + 'seconds'
	END TRY
	BEGIN CATCH
	PRINT ERROR_MESSAGE();
	END CATCH
END
