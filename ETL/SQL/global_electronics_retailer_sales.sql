WITH 
  sales AS (SELECT * FROM `lucaz-nguyen.Global_Electronics_Retailer_Sales.sales`),
  products AS (SELECT * FROM `lucaz-nguyen.Global_Electronics_Retailer_Sales.products`),
  exchange_rates AS (SELECT * FROM `lucaz-nguyen.Global_Electronics_Retailer_Sales.exchange_rates`),
  stores AS (SELECT * FROM `lucaz-nguyen.Global_Electronics_Retailer_Sales.stores`),
  customers AS (SELECT * FROM `lucaz-nguyen.Global_Electronics_Retailer_Sales.customers`)

-- 1. Find the Total Customers, Quantity, Sales, Stores and Products?


SELECT
  COUNT(DISTINCT c.customer_id) AS total_customers
  , COUNT(DISTINCT st.store_id) AS total_stores
  , COUNT(DISTINCT p.product_id) AS total_products
  , SUM(s.quantity) AS total_quantity
  , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd), 2) AS total_sales
  , ROUND(SUM(s.quantity * p.unit_cost_usd * e.units_per_usd), 2) AS total_manufacturing_cost
  , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd), 2) - ROUND(SUM(s.quantity * p.unit_cost_usd * e.units_per_usd), 2) AS profit
FROM sales AS s
FULL JOIN products AS p USING(product_id)
FULL JOIN exchange_rates AS e 
  ON s.order_date = e.date AND s.currency = e.currency
FULL JOIN stores AS st USING(store_id)
FULL JOIN customers AS c USING(customer_id)


-- 2. What is the distribution of customers across different continents, and how does it impact sales volume?


SELECT
  c.continent
  , COUNT(DISTINCT c.customer_id) AS total_customers
  , SUM(s.quantity) AS total_quantity
  , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd), 2) AS total_sales
  , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd) / 1000000, 2) AS total_sales_mil
FROM sales AS s
FULL JOIN customers AS c USING(customer_id)
FULL JOIN products AS p USING(product_id)
FULL JOIN exchange_rates AS e 
  ON s.order_date = e.date AND s.currency = e.currency
GROUP BY 1
ORDER BY 4 DESC


-- 3. How does customer age group influence purchasing behaviour, and which products are most popular within each group?


SELECT
  c.age_group AS age_group
  , p.product_name AS product_name
  , COUNT(s.order_id) AS total_orders
  , SUM(s.quantity) AS total_quantity
  , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd), 2) AS total_sales
  , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd) / 1000000, 3) AS total_sales_mil
FROM sales AS s
JOIN products AS p USING(product_id)
JOIN customers AS c USING(customer_id)
JOIN exchange_rates AS e 
  ON s.order_date = e.date AND s.currency = e.currency
GROUP BY 1,2
ORDER BY 5 DESC


-- 4. Are there specific cities or states with higher sales volumes? What are the characteristics of these regions?


SELECT
  c.state_name
  , c.city
  , COUNT(s.order_id) AS total_orders
  , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd), 2) AS total_sales
  , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd) / 1000000, 3) AS total_sales_mil
FROM sales AS s
JOIN products AS p USING(product_id)
JOIN customers AS c USING(customer_id)
JOIN exchange_rates AS e 
  ON s.order_date = e.date AND s.currency = e.currency
GROUP BY 1,2
ORDER BY 4 DESC


-- 5. How does the gender of customers influence product preferences and purchasing frequency?


SELECT 
  c.gender
  , p.product_name
  , COUNT(s.order_id) AS total_orders
  , SUM(s.quantity) AS total_quatity
  , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd), 2) AS total_sales
  , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd) / 1000, 2) AS total_sales_k
FROM sales AS s
JOIN customers AS c USING (customer_id)
JOIN products AS p USING (product_id)
JOIN exchange_rates AS e
  ON s.order_date = e.date AND s.currency = e.currency
GROUP BY 1,2 
ORDER BY 6 DESC


-- 6. What is the correlation between customer location (city/state) and the average order value?


SELECT
  c.state_name
  , c.city
  , ROUND(AVG(s.quantity * p.unit_price_usd * e.units_per_usd), 2) AS avg_total_sales
FROM sales AS s
JOIN customers AS c USING(customer_id)
JOIN products AS p USING(product_id)
JOIN exchange_rates AS e 
  ON s.order_date = e.date AND s.currency = e.currency
GROUP BY 1,2
ORDER BY 3 DESC


-- 7. Are there any correlations between customers birth month and their purchasing behavior?


SELECT
  EXTRACT(MONTH FROM c.birthday) AS month
  , COUNT(s.order_id) AS total_orders
  , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd), 2) AS total_sales
  , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd) / 1000000, 2) AS total_sales_mil
FROM sales AS s
JOIN customers AS c USING(customer_id)
JOIN products AS p USING(product_id)
JOIN exchange_rates AS e 
  ON s.order_date = e.date AND s.currency = e.currency
GROUP BY 1
ORDER BY 1


-- 8. How does the sales volume vary throughout the year, and what are the peak months for different product categories?


SELECT
  FORMAT_DATE('%Y', order_date) AS year
  , EXTRACT(MONTH FROM order_date) AS month
  , p.category
  , SUM(quantity) AS total_quantity
FROM sales AS s
JOIN products AS p USING(product_id)
GROUP BY 1,2,3
ORDER BY 1,2,4 DESC


-- 9. Which store locations are the most profitable, and how does their performance compare to others?


SELECT
  st.store_id
  , st.country
  , st.state_name
  , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd), 2) AS total_sales
  , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd) / 1000000, 2) AS total_sales_mil
FROM sales AS s
JOIN stores AS st USING(store_id)
JOIN products AS p USING(product_id)
JOIN exchange_rates AS e ON s.order_date = e.date AND s.currency = e.currency
GROUP BY 1,2,3
ORDER BY 4 DESC


-- 10. How does the sales volume of new products compare to older products over time? 


, product_launch_date AS (
  SELECT
    s.product_id
    , MIN(s.order_date) AS launch_date
  FROM sales AS s
  GROUP BY 1
  ORDER BY 1
)

SELECT
  EXTRACT(YEAR FROM s.order_date) AS created_year
  , CASE  
    WHEN DATE_DIFF(s.order_date, pld.launch_date, YEAR) < 1 THEN 'New Product'
    ELSE 'Old Product' END AS product_type
  , SUM(s.quantity) AS total_quantity
FROM product_launch_date AS pld
JOIN sales AS s  USING(product_id)
GROUP BY 1,2
ORDER BY 1,2,3 DESC


-- 11. How does sales performance vary by day of the week across different regions?


SELECT
  FORMAT_DATE('%A', order_date) AS day_week
  , st.country
  , st.state_name
  , SUM(quantity) AS total_quantity
  , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd), 2) AS total_sales
  , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd) / 1000, 2) AS total_sales_k
FROM sales AS s
JOIN stores AS st USING(store_id)
JOIN products AS p USING(product_id)
JOIN exchange_rates AS e ON s.order_date = e.date AND s.currency = e.currency
GROUP BY 1,2,3
ORDER BY 5 DESC


-- 12. Are there any significant differences in sales performance for different store sizes?


SELECT
  st.store_id
  , st.state_name 
  , st.store_size_m2
  , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd), 2) AS total_sales
  , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd) / 1000, 2) AS total_sales_k
FROM sales AS s
JOIN stores AS st USING(store_id)
JOIN products AS p USING(product_id)
JOIN exchange_rates AS e ON s.order_date = e.date AND s.currency = e.currency
GROUP BY 1,2,3
ORDER BY 5 DESC


-- 13. How do sales volumes vary between online and physical store purchases?


SELECT
  s.platform
  , SUM(quantity) AS total_quantity
  , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd), 2) AS total_sales
  , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd) / 1000, 2) AS total_sales_k
FROM sales AS s
JOIN products AS p USING(product_id)
JOIN exchange_rates AS e ON s.order_date = e.date AND s.currency = e.currency
GROUP BY 1
ORDER BY 4 DESC


-- 14. What are the total sales values per customer, and how does each customer's sales compare to the highest spender? 


SELECT
  c.customer_id
  , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd), 2) AS total_sales
  , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd) / 1000, 2) AS total_sales_k
  , RANK() OVER(ORDER BY ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd) / 1000, 2) DESC) AS rank
FROM sales AS s 
JOIN customers AS c USING(customer_id)
JOIN products AS p USING(product_id)
JOIN exchange_rates AS e ON s.order_date = e.date AND s.currency = e.currency 
GROUP BY 1
ORDER BY 4 


-- 15. What is the sales trend for each month over the years, and how does each month's sales compare to the previous month and percentage Change Month wise?


, yearly_monthly_sales AS (
  SELECT
    FORMAT_DATE('%Y', order_date) AS years
    , EXTRACT(MONTH FROM order_date) AS months
    , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd), 2) AS total_sales
  FROM sales AS s
  JOIN customers AS c USING(customer_id)
  JOIN products AS p USING(product_id)
  JOIN exchange_rates AS e ON s.order_date = e.date AND s.currency = e.currency
  GROUP BY 1,2 
  ORDER BY 1,2
)

, change_by_year_month AS (
  SELECT 
    *
    , LAG(total_sales) OVER(ORDER BY years, months) AS previous_month_sale
  FROM yearly_monthly_sales
)

SELECT 
  *
  , CONCAT(ROUND(((total_sales - previous_month_sale) / previous_month_sale)*100,2), ' %') AS change_percentage
FROM change_by_year_month
ORDER BY years, months


-- 16. Which products are the top sellers by quantity, and how much more are they selling compared to other products?


SELECT
  p.product_id
  , p.product_name
  , SUM(quantity) AS total_quantity
  , DENSE_RANK() OVER(ORDER BY SUM(quantity) DESC) AS product_rank
FROM sales AS s
JOIN products AS p USING(product_id)
GROUP BY 1, 2 
ORDER BY 4


-- 17. What is the total sales per store, and how does each store's performance compare to the average store performance?


SELECT
  st.store_id
  , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd), 2) AS total_sales
  , ROUND(AVG(SUM(s.quantity * p.unit_price_usd * e.units_per_usd)) OVER(), 2) AS avg_sales
  , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd) - AVG(SUM(s.quantity * p.unit_price_usd * e.units_per_usd)) OVER(), 2) AS sale_difference 
FROM sales AS s
JOIN stores AS st USING(store_id)
JOIN products AS p USING(product_id)
JOIN exchange_rates AS e ON s.order_date = e.date AND s.currency = e.currency
GROUP BY 1
ORDER BY 1


-- 18. What is the lifetime value of each customer, and who are the top 20 customers by sales in each state?


, by_customer AS (
  SELECT
    c.state_name
    , c.customer_id
    , c.customer_name
    , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd), 2) AS total_sales
  FROM sales AS s
  JOIN customers AS c USING(customer_id)
  JOIN products AS p USING(product_id)
  JOIN exchange_rates AS e ON s.order_date = e.date AND s.currency = e.currency
  GROUP BY 1, 2, 3
)

, calculate_rank_in_state  AS(
  SELECT
    *
    , RANK() OVER(PARTITION BY state_name ORDER BY total_sales DESC) AS rank_in_state
  FROM by_customer
  ORDER BY 1,4 DESC
)

SELECT
  *
FROM calculate_rank_in_state
WHERE rank_in_state <= 20


-- 19. What is the year-over-year sales growth for each store?


, store_over_year AS (
  SELECT
    st.store_id
    , FORMAT_DATE('%Y', order_date) AS years
    , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd), 2) AS total_sales
  FROM sales AS s
  JOIN stores AS st USING(store_id)
  JOIN products AS p USING(product_id)
  JOIN exchange_rates AS e ON s.order_date = e.date AND s.currency = e.currency
  GROUP BY 1,2 
  ORDER BY 1,2
)

, calculate_last_year AS (
  SELECT
    *
    , LAG(total_sales) OVER (PARTITION BY store_id ORDER BY years) AS previous_year
  FROM store_over_year
)

SELECT 
  *
  , CONCAT(ROUND(((total_sales - previous_year) / previous_year)*100,2), ' %') AS yoy_change 
FROM calculate_last_year
ORDER BY store_id


-- 20. How does each product perform in different State?


SELECT
  c.state_name
  , p.product_name
  , SUM(quantity) AS total_quantity
  , DENSE_RANK() OVER(PARTITION BY c.state_name ORDER BY SUM(quantity) DESC) AS state_rank
FROM sales AS s
JOIN customers AS c USING(customer_id)
JOIN products AS p USING(product_id)
JOIN exchange_rates AS e ON s.order_date = e.date AND s.currency = e.currency
GROUP BY 1,2 
ORDER BY 1


-- 21. What is the total sales for each product category, and how do different categories compare to each other?


SELECT
  p.category
  , ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd), 2) AS total_sales
  , DENSE_RANK() OVER(ORDER BY ROUND(SUM(s.quantity * p.unit_price_usd * e.units_per_usd), 2) DESC) AS category_rank
FROM sales AS s
JOIN customers AS c USING(customer_id)
JOIN products AS p USING(product_id)
JOIN exchange_rates AS e ON s.order_date = e.date AND s.currency = e.currency
GROUP BY 1
ORDER BY 3


-- 22. What trends can be observed in sales quantity for weekdays versus weekends over time?

, extract_dow AS (
  SELECT
    *
    , FORMAT_DATE('%A', order_date) AS day_of_week
  FROM sales AS s
)

, make_weekday_weekend AS (
  SELECT
    *
    , CASE  
      WHEN day_of_week  IN ('Monday','Tuesday','Wednesday','Thursday','Friday') THEN 'Weekday'
      WHEN day_of_week IN ('Saturday','Sunday') THEN 'Weekend'
      ELSE 'Undefined' END 
      AS weekday_or_weekend
  FROM extract_dow
)

SELECT
   FORMAT_DATE('%Y %b', order_date) AS year_month
  , weekday_or_weekend
  , SUM(quantity) AS total_quantity
FROM make_weekday_weekend
GROUP BY 1, 2








