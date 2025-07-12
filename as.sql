-- Apple Retails Millions Rows Sales Schemas

-- DROP TABLE command

DROP TABLE IF EXISTS warranty;
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS category;-- parent table
DROP TABLE IF EXISTS stores; -- parent table

-- CREATE TABLE commands
-- stores
CREATE TABLE stores ( 
store_id VARCHAR (10) PRIMARY KEY, 
store_name VARCHAR (30),
city VARCHAR (25), 
country VARCHAR (25)
);

-- category
DROP TABLE IF EXISTS category;
CREATE TABLE category ( 
category_id VARCHAR (10) PRIMARY KEY,
category_name VARCHAR (20)
);

-- products
CREATE TABLE products (
product_id VARCHAR (10) PRIMARY KEY, 
product_name VARCHAR (35) ,
category_id VARCHAR (10) , -- FOREIGN KEY 
launch_date date,
price FLOAT,
CONSTRAINT fk_category FOREIGN KEY (category_id) REFERENCES category(category_id)
);

-- sales
CREATE TABLE sales
(
sale_id VARCHAR (15) PRIMARY KEY,
sale_date DATE,
store_id VARCHAR (10), -- FOREIGN KEY 
product_id VARCHAR (10), -- FOREIGN KEY 
quantity INT,
CONSTRAINT fk_store FOREIGN KEY (store_id) REFERENCES stores(store_id), 
CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);



-- warrenty
CREATE TABLE warranty
(
claim_id VARCHAR (10) PRIMARY KEY, 
claim_date date, 
sale_id VARCHAR (15) ,-- FOREIGN KEY
repair_status VARCHAR (15),
CONSTRAINT fk_orders FOREIGN KEY (sale_id) REFERENCES sales (sale_id)
) ;

-- Success Message
SELECT 'Schemas have created successfully' as Success_Message;

-- checking if tables are imported succesfully or not

SELECT * FROM category
SELECT * FROM stores
SELECT * FROM products
SELECT COUNT (*) FROM sales
SELECT * FROM warranty
-- improving Query time

-- before index creation for product id
-- "Execution Time: 62.212 ms"
-- "Planning Time: 0.705 ms"


 EXPLAIN ANALYZE
 SELECT *
 FROM sales
 WHERE product_id = 'P-38'
-- AFTER creating Index for product id
-- "Execution Time: 3.450 ms"
-- "Planning Time: 0.059 ms"
 CREATE INDEX sales_product_id ON sales(product_id);

-- before index creation for store id
-- "Execution Time: 140.042 ms"
-- "Planning Time: 0.074 ms"

 EXPLAIN ANALYZE
 SELECT *
 FROM sales
 WHERE store_id = 'ST-31'
 -- AFTER creating Index for store id
-- "Execution Time: 1.150 ms"
--  "Planning Time: 0.059 ms"
 
  CREATE INDEX sales_store_id ON sales(store_id);

 -- creating index for sale date
  CREATE INDEX sales_sale_date ON sales(sale_date);
  EXPLAIN ANALYZE
  SELECT *
  FROM sales
