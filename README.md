# Apple_Store_Sales_SQL_Analytics_Project
![banner](https://github.com/Sifat-1/Apple_Store_Sales_SQL_Analytics_Project/blob/main/pictures/apple-store-palo-alto.jpg)

## Overview
Advanced SQL analytics project using PostgreSQL to analyze over 1 million Apple Store sales and warranty records. This project focuses on extracting actionable insights from a realistic retail dataset by solving 20+ business-focused queries related to sales performance, product lifecycle, warranty trends, and store-level KPIs. It showcases advanced SQL techniques including window functions, CTEs, indexing, and performance optimization within a normalized database schema.

## The project includes:
- Designed and implemented a relational database schema with normalized tables and appropriate key constraints.
- Performed analytical exploration of sales and warranty data to identify patterns across time, geography, and product lines.
-  Optimized SQL queries by strategically implementing indexing and conducting performance benchmarking to enhance efficiency.
-  Answered real-world business questions by writing advanced SQL queries that deliver actionable insights.

## Key Features
- ### Database Schema: Built a 5-table relational database (sales, stores, products, warranty, category)
  - **Table :**
   1. `stores`: Contains information about store locations, including `store_id`, `store_name`, `city`, and `country`.
   2. `category`: Represents product categories, identified by `category_id` and `category_name`.
   3. `products`: Stores product details like `product_id`, `product_name`, `category_id`, `launch_date`, and `price`.
   4. `sales`: Tracks sales transactions with details like `sale_id`, `sale_date`, `store_id`, `product_id`, and `quantity`.
   5. `warranty`: Logs warranty claims with `claim_id`, c`laim_date`, `sale_id`, and `repair_status`.
       - **Relationship :**
           - sales links to stores and products
           - products links to category
           - warranty links to sales
 
     ### ERD Diagram:
    ![Database Schema](https://raw.githubusercontent.com/Sifat-1/Apple_Store_Sales_SQL_Analytics_Project/c72d9076ee3002fd5c8131d8950bb7a2646399ef/pictures/Screenshot%202025-05-30%20183408.png)
- ###  Performance Optimization:  Indexed and benchmarked queries for 90%+ speed improvements
     - To handle millions of rows and ensure high performance, indexes were created on the following columns:
       1. `sales(product_id)`: Improved query execution time for product-based sales analysis.
       2. `sales(store_id)`: Enhanced performance when filtering sales by store.
       3. `sales(sale_date)`: Accelerated date-based queries for identifying trends and seasonal patterns.

    - ### Optimization Impact:
    - #### Filtering by Product ID
    - #### Without Index:
     ![EXPLAIN Before Index](https://github.com/Sifat-1/Apple_Store_Sales_SQL_Analytics_Project/blob/main/pictures/query_time.png)
  - #### With Index:
   ![EXPLAIN After Index](https://github.com/Sifat-1/Apple_Store_Sales_SQL_Analytics_Project/blob/main/pictures/QT2.png)

       

  
