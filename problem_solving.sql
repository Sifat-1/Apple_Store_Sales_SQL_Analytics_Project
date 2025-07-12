-- solving business problem
-- Find the number of stores in each country
SELECT country, COUNT(store_id) AS total_stores
FROM stores
GROUP BY country
ORDER BY 2 DESC;

-- Calculate the total number of units sold by each store.  
SELECT
str.store_id,
str.store_name,
SUM(quantity) as total_units
FROM sales sl
INNER JOIN stores str
ON str.store_id = sl.store_id
GROUP BY str.store_id,str.store_name -- or group by 1,2
ORDER BY total_units Desc; --order by 3


-- Identify how many sales occurred in December 2023.  
SELECT
COUNT (sale_id) as total_sales
FROM sales
WHERE TO_CHAR(sale_date,'MM-YYYY') = '12-2023';

-- Determine how many stores have never had a warranty claim filed.  
SELECT 
COUNT(*) as total_stores_not_claimed_warranty
FROM stores
WHERE store_id NOT IN(
 						SELECT 
 						DISTINCT (store_id)
 						FROM  sales s 
						RIGHT JOIN warranty w
 						on s.sale_id = w.sale_id
						 );-- recieved warranty claims stores

-- Calculate the percentage of warranty claims marked as "Warranty Void". 
SELECT
ROUND 
(COUNT(claim_id)/(SELECT COUNT(*) FROM warranty)::numeric * 100,2) as warranty_void_percentage
FROM warranty
WHERE repair_status = 'Warranty Void'

-- Identify which store had the highest total units sold in the last year. 

SELECT st.store_id, st.store_name, SUM (sl.quantity) as highest_unit_sold
FROM sales as sl
JOIN stores as st
ON st.store_id = sl.store_id
WHERE sale_date >= (CURRENT_DATE - INTERVAL '1 year')
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 1

-- Count the number of unique products sold in the last 2 year. 
SELECT
COUNT(DISTINCT(product_id) )as unique_products
FROM sales
WHERE sale_date >= (Current_date - Interval '2 year');

-- Find the average price of products in each category.
SELECT c.category_id, c.category_name, AVG(p.price) as avg_price

  FROM category as c
  JOIN products as p
  ON c.category_id = p.category_id
  GROUP BY 1,2
  ORDER BY 3 DESC
  
--  How many warranty claims were filed in 2020? 
SELECT COUNT (claim_id)
FROM warranty
WHERE TO_CHAR (claim_date,'YYYY')= '2020';
-- or we can write WHERE EXTRACT( YEAR FROM claim_date)= 2020

-- For each store, identify the best-selling day based on highest quantity sold. 
-- using cte and window function
WITH my_cte AS(
                SELECT store_id, SUM (quantity) AS total_unit_sold, TO_CHAR(sale_date, 'Day') AS day_name,
				RANK() OVER(PARTITION BY store_id ORDER BY SUM(quantity) DESC) AS rank
				FROM sales
				GROUP BY 1, 3
              )
SELECT  mc.store_id, st.store_name, mc.day_name, mc.total_unit_sold
FROM my_cte as mc
JOIN stores as st
ON mc.store_id = st.store_id
WHERE rank = 1

-- Identify the least selling product in each country for each year based on total units sold.  
			  
WITH my_cte as (

               SELECT sl.product_id, p.product_name,st.country, EXTRACT (YEAR FROM sl.sale_date) AS each_year, SUM(sl.quantity) AS total_sold_products,
			   RANK () OVER(PARTITION BY st.country,EXTRACT (YEAR FROM sl.sale_date) ORDER BY SUM (sl.quantity)ASC) AS rank
			   FROM stores as st
			   JOIN sales as sl
			   ON st.store_id = sl.store_id
			   JOIN products as p
			   ON sl.product_id = p.product_id
			   GROUP BY 1,2,3,4
)

SELECT product_name, country, each_year,total_sold_products
FROM my_cte
WHERE rank = 1

-- Calculate how many warranty claims were filed within 180 days of a product sale. 
SELECT COUNT (w.*)
FROM warranty as w
LEFT JOIN sales as s
ON s.sale_id = w.sale_id
WHERE w.claim_date - s.sale_date <= 180

-- Determine how many warranty claims were filed for products launched in the last three years.  

SELECT p.product_name, COUNT(w.claim_id),COUNT(s.sale_id)
FROM warranty as w
RIGHT JOIN 
sales as s 
ON w.sale_id = s.sale_id
JOIN 
products as p
ON s.product_id = p.product_id
WHERE p.launch_date >= CURRENT_DATE - INTERVAL'3 years'
GROUP BY 1
HAVING COUNT (w.claim_id)> 0

--  List the months in the last three years where sales exceeded 5,000 units in the USA.

SELECT  TO_CHAR (sl.sale_date, 'Month') AS listing_months,  SUM(sl.quantity) AS total_units_sold
FROM stores as st
JOIN
sales as sl
ON st.store_id = sl.store_id
WHERE sl.sale_date >= CURRENT_DATE - INTERVAL '3 years' AND st.country = 'USA'
GROUP BY 1
HAVING SUM(sl.quantity)>5000

-- Identify the product category with the most warranty claims filed in the last three years.

SELECT c.category_name, COUNT (w.claim_id) as total_claims_filed
FROM warranty as w
LEFT JOIN sales as s
ON w.sale_id = s.sale_id
JOIN products as p
ON s.product_id = p.product_id
JOIN category as c
ON p.category_id = c.category_id
 WHERE w.claim_date >= CURRENT_DATE - INTERVAL '3 years'
 GROUP BY 1
 ORDER BY 2 DESC
-- Determine the percentage chance of receiving warranty claims after each purchase for each country.
 
WITH my_cte AS (
                 SELECT  
				        st.country AS country,
				        COUNT(w.claim_id) AS total_claims, 
                        SUM (sl.quantity) AS total_sales
						FROM stores as st
						JOIN sales as sl
						ON st.store_id = sl.store_id
						LEFT JOIN 
						warranty as w
						ON sl.sale_id = w.sale_id
						GROUP BY 1
						)

SELECT country,total_claims,total_sales, ROUND(COALESCE(total_claims::numeric/total_sales::numeric*100,0),2) AS percentage_warrenty_claims
FROM my_cte
ORDER BY 4 DESC

-- Analyze the year-by-year growth ratio for each store. 

WITH yearly_sales AS(

                      SELECT 
					  st.store_id AS store_id,
					  st.store_name AS store_name, 
					  EXTRACT( YEAR FROM sl.sale_date) AS years,
					  SUM (p.price * sl.quantity) AS total_sales
					  FROM stores as st
					  JOIN
					  sales as sl
					  ON st.store_id = sl.store_id
					  JOIN
					  products as p
					  ON sl.product_id = p.product_id
					  GROUP BY 1,2,3
					  ORDER BY 1,2,3
					  
					  
                   ),
				   
     growth_ratio AS
	 (
          SELECT 
          store_name,
		  years,
		  LAG(total_sales, 1) OVER (PARTITION BY store_name ORDER BY years ASC ) AS last_year_sales,
		  total_sales AS current_year_sales
		  FROM yearly_sales
		  )

		  SELECT *,
		 ROUND ((current_year_sales - last_year_sales ):: numeric/
		       last_year_sales:: numeric* 100 ,3) AS YOY_growth_ratio
		FROM growth_ratio
		WHERE last_year_sales IS NOT NULL
		AND years <>EXTRACT (YEAR FROM CURRENT_DATE)

-- Calculate the correlation between product price and warranty claims for products sold in the last five years, segmented by price range. 

SELECT 
CASE
 WHEN p.price < 500 THEN 'Less Expensive product'
 WHEN p.price  BETWEEN 500 AND 1000 THEN 'Mid Range Product'
 ELSE 'Expensive product'
END AS price_segment,
COUNT(w.claim_id) AS total_claims
FROM warranty as w
LEFT JOIN sales as s
ON w.sale_id = s.sale_id
JOIN products as p
ON s.product_id = p.product_id
WHERE w.claim_date >= CURRENT_DATE - INTERVAL '5 year'
GROUP BY 1
-- Identify the store with the highest percentage of "Paid Repaired" claims relative to total claims filed. 
WITH paid_repair
AS
(SELECT 
	s.store_id,
	COUNT(w.claim_id) AS paid_repaired
	FROM sales as s
	RIGHT JOIN
	warranty as w
	ON s.sale_id = w.sale_id
	WHERE w.repair_status = 'Paid Repaired'
	GROUP BY 1
	),
total_repair_status AS
(
SELECT s.store_id,
       COUNT(w.claim_id) AS total_repair_status
	   FROM sales as s
	   RIGHT JOIN
	   warranty as w
	   ON s.sale_id = w.sale_id
	   GROUP BY 1

)
SELECT ts.store_id,
       st.store_name,
	   pr.paid_repaired,
	   ts.total_repair_status,
	   ROUND( pr.paid_repaired :: numeric / ts.total_repair_status*100,2) AS percentage_of_paid_repair
	   
FROM 	 paid_repair as pr
         JOIN
         total_repair_status as ts
		 ON pr.store_id = ts.store_id
		 JOIN
		 stores as st
		 ON st.store_id = pr.store_id
		 ORDER BY percentage_of_paid_repair DESC

--  Write a query to calculate the monthly running total of sales for each store over the past four years and compare trends during this period.
WITH monthly_sales
AS
(
SELECT
	s.store_id,
	EXTRACT(YEAR from s.sale_date) as year,
	EXTRACT(MONTH from s.sale_date) as month,
	SUM(p.price * s.quantity) as total_revenue
FROM sales as s
JOIN products as p
ON p.product_id = s.product_id
GROUP BY s.store_id,year,month
ORDER BY s.store_id,year,month
)
SELECT 
	store_id,
	month,
	year,
	total_revenue,
	SUM(total_revenue) OVER(PARTITION BY store_id ORDER BY year, month) as running_total
FROM monthly_sales

---  Analyze product sales trends over time, segmented into key periods: from launch to 6 months, 6-12 months, 12-18 months, and beyond 18 months.  

SELECT p.product_name,
       CASE
	   WHEN s.sale_date BETWEEN p.launch_date AND p.launch_date + INTERVAL '6 month' THEN '0-6 month'
	   WHEN s.sale_date BETWEEN p.launch_date + INTERVAL '6 month' AND p.launch_date + INTERVAL '12 month' THEN '6-12 month'
	   WHEN s.sale_date BETWEEN p.launch_date + INTERVAL '12 month' AND p.launch_date + INTERVAL '18 months' THEN '12-18 moths'
	   ELSE '18+'
	   END AS key_period,
	   SUM (s.quantity) AS total_sales
	   FROM sales as s 
	   JOIN
	   products as p
	   ON s.product_id = p.product_id
	   GROUP BY 1,2
	   ORDER BY 3 DESC



