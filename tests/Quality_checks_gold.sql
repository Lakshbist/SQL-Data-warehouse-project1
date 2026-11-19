/* 
   ====================================================================================================
   Quality Checks
   ====================================================================================================
   Script purpose:
         This script performs quality checks to validate the integrity, consistency, and 
		 accuracy of the gold layer. These checks ensures:
		 - Uniqueness of surrogate keys in dimension tables.
		 - Referential integrity between fact and dimensional tables.
		 - Validation of relationships in the data model for analytical purposes.

   Usage Notes:
        - Run these checks after data loading silver layer.
		- investigate and resolve any discrepancies found during the checks.
*/

--====================================================================================================
-- Checking gold.dim_customers
--====================================================================================================
-- Check for uniqueness of customer key in gold.dim_customers
-- Expectations - no results.
select 
      customer_key,
      count(*) as duplicate_count
from gold.dim_customers
group by customer_key
having count(*)>1

--====================================================================================================
-- Checking gold.dim_products
--====================================================================================================
-- Check for uniqueness of product key in gold.dim_products
-- Expectations - no results.

select product_key,
       count(*) as duplicate_count
from gold.dim_products
group by product_key
having count(*)>1

--====================================================================================================
-- Checking gold.fact_sales
--====================================================================================================
-- Check the data model connectivity between fact and dimensions.

select * 
from gold.fact_sales as f
left join gold.dim_customers as c
on f.customer_key = c.customer_key
left join gold.dim_products as p
on f.product_key = p.product_key
where c.customer_key is null;

