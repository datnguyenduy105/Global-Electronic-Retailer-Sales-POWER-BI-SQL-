WITH rename_column AS (
SELECT 
  `Order Number` AS order_id
  , `Line Item` AS line_item
  , `Order Date` AS order_date
  , `Delivery Date` AS delivery_date
  , CustomerKey AS customer_id
  , StoreKey AS store_id
  , ProductKey AS product_id
  , Quantity AS quantity
  , `Currency Code` AS currency
FROM `lucaz-nguyen.Global_Electronics_Retailer_Sales.Sales` 
)

, enrich AS (
SELECT 
  *
  , CASE
      WHEN delivery_date IS NOT NULL THEN 'Online_Purchase'
      ELSE 'Physical_Purchase'
      END
      AS platform
FROM rename_column

)

SELECT 
  *
FROM enrich
