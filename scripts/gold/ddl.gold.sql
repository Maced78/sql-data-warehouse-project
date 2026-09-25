/*
  ==============================================
  Views for "Gold" schema tables, added 2 dimension and 1 fact table.
  These views can be used directly for analitcs and reporting.
  ==============================================



  ==============================================
  Dimension: gold.dim_customers
  ==============================================
*/

CREATE VIEW gold.dim_customers AS	
	
	SELECT 
	ROW_NUMBER() OVER(ORDER BY cc.cst_id) AS customer_key,
	cc.cst_id customer_id,
	cc.cst_key customer_number,
	cc.cst_firstname first_name,
	cc.cst_lastname last_name,
	CASE WHEN cc.cst_gndr IS NOT NULL THEN cc.cst_gndr 
	WHEN cc.cst_gndr = 'Unknown' AND ca.gen IS NOT NULL THEN ca.gen
	ELSE COALESCE(ca.gen,'n/a')
	END gender,
	cc.cst_marital_status marital_status,
	cb.cnrty country,
	ca.bdate birthday,
	cc.cst_create_date create_date
	FROM silver.crm_cust_info cc
	LEFT JOIN silver.erp_cust_az12 ca
	ON cc.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 cb
	ON cc.cst_key = cb.cid
  
/*
  ==============================================
  Dimension: gold.dim_products
  ==============================================
*/
  
CREATE VIEW gold.dim_products AS
	SELECT 
		ROW_NUMBER() OVER(ORDER BY pp.prd_start, pp.prd_key) product_key ,
		pp.prd_id product_id,
		pp.prd_key product_number,
		pp.prd_nm product_name,
		pp.cat_id category_id,
		pc.cat category,
		pc.subcat subcategory,
		pc.maintenance,
		pp.prd_cost cost,
		pp.prd_line product_line,
		pp.prd_start start_date

	FROM silver.crm_prd_info pp
	LEFT JOIN silver.erp_px_cat_g1v2 pc 
	ON pp.cat_id = pc.id

	WHERE pp.prd_end_date IS NULL -- Filtering all historical data
  
/*
  ==============================================
  Fact: gold.fact_sales
  ==============================================
*/
  
CREATE VIEW gold.fact_sales AS	
	SELECT 
	sd.sls_order_number order_number,
	pr.product_key,
	cr.customer_key,
	sd.sls_order_dt order_date,
	sd.sls_ship_dt shipping_date,
	sd.sls_due_dt due_date,
	sd.sls_sales sales,
	sd.sls_quantity quantity,
	sd.sls_price price
	FROM silver.crm_sales_details sd
	LEFT JOIN gold.dim_products pr
	ON sd.sls_prd_key = pr.product_number
	LEFT JOIN gold.dim_customers cr
	ON sd.sls_cust_id = cr.customer_id
